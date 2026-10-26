const { PermissionFlagsBits } = require('discord.js');
const { registerPanel, ticketPanel, statusView } = require('./views');
const { textChannel } = require('./discord');
const { UserError } = require('./errors');

class Panels {
  constructor(client, config, meta, query, audit) { this.client = client; this.config = config; this.meta = meta; this.query = query; this.audit = audit; this.updating = false; }
  async payload(type) {
    if(type === 'register') return registerPanel();
    if(type === 'ticket') {
      if(!this.config.ticketCategoryId) throw new UserError('Tiket belum dikonfigurasi. Isi kategori dan role staf terlebih dahulu.');
      return ticketPanel();
    }
    if(type === 'status') {
      if(!this.config.gameHost) throw new UserError('Isi GAME_HOST sebelum memasang panel status.');
      return statusView(this.query, this.config);
    }
    throw new UserError('Jenis panel tidak dikenal.');
  }
  async setup(type, channelId) {
    if(type === 'register' && channelId !== this.config.registerChannelId) throw new UserError('Panel registrasi harus dipasang di CHANNEL_REGISTER_ID dari .env.');
    const payload = await this.payload(type);
    const channel = await textChannel(this.client, this.config, channelId, [PermissionFlagsBits.ReadMessageHistory]);
    const previous = await this.meta.get(`panel:${type}`);
    if(previous && previous.channelId === channelId) {
      let message;
      try { message = await channel.messages.fetch(previous.messageId); } catch(error) { if(error.code !== 10008) throw error; }
      if(message?.author.id === this.client.user.id) {
        await message.edit({ ...payload, allowedMentions: { parse: [] } });
        return message;
      }
    }
    const message = await channel.send({ ...payload, allowedMentions: { parse: [] } });
    await this.meta.set(`panel:${type}`, { channelId, messageId: message.id });
    if(previous) {
      try {
        const old = await textChannel(this.client, this.config, previous.channelId, [PermissionFlagsBits.ReadMessageHistory]);
        const oldMessage = await old.messages.fetch(previous.messageId);
        if(oldMessage.author.id === this.client.user.id) await oldMessage.delete();
      } catch(error) { this.audit.error('OLD_PANEL', error); }
    }
    return message;
  }
  async refreshStatus() {
    if(this.updating) return;
    this.updating = true;
    try {
      const panel = await this.meta.get('panel:status');
      if(!panel) return;
      const channel = await textChannel(this.client, this.config, panel.channelId, [PermissionFlagsBits.ReadMessageHistory]);
      const message = await channel.messages.fetch(panel.messageId);
      if(message.author.id === this.client.user.id) await message.edit(await statusView(this.query, this.config));
    } catch(error) { this.audit.error('STATUS_PANEL', error); } finally { this.updating = false; }
  }
}

module.exports = { Panels };
