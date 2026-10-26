const { ChannelType, PermissionFlagsBits, ButtonStyle } = require('discord.js');
const { UserError } = require('./errors');
const { isAdmin, hasRole, textChannel } = require('./discord');
const { embed, row, button } = require('./views');
const { safeText } = require('./security');

class Tickets {
  constructor(client, config, pool, audit) { this.client = client; this.config = config; this.pool = pool; this.audit = audit; }
  assertEnabled() { if(!this.config.ticketCategoryId) throw new UserError('Fitur tiket belum diaktifkan oleh administrator.'); }
  async open(user, subject, description) {
    this.assertEnabled();
    subject = subject.trim();
    description = description.trim();
    if(!subject || !description) throw new UserError('Judul dan penjelasan tiket tidak boleh kosong.');
    const guild = await this.client.guilds.fetch(this.config.guildId);
    const category = await guild.channels.fetch(this.config.ticketCategoryId);
    const staff = await guild.roles.fetch(this.config.ticketStaffRoleId);
    const me = await guild.members.fetchMe();
    if(!category || category.type !== ChannelType.GuildCategory || !staff || staff.id === guild.id || staff.id === this.config.verifiedRoleId) throw new UserError('Kategori atau role staf tiket tidak valid. Role staf harus khusus staf, bukan everyone/verified.');
    if(!me.permissions.has([PermissionFlagsBits.ManageChannels, PermissionFlagsBits.ManageRoles])) throw new UserError('Bot memerlukan Manage Channels dan Manage Roles untuk membuat tiket.');
    try {
      await this.pool.execute("INSERT INTO discord_bot_tickets (guild_id, owner_id, subject, description) VALUES (?, ?, ?, ?)", [guild.id, user.id, subject, description]);
    } catch(error) {
      if(error.code === 'ER_DUP_ENTRY') throw new UserError('Kamu sudah mempunyai tiket aktif atau tiketmu sedang dibuat.');
      throw error;
    }
    let channel;
    try {
      const allow = [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory, PermissionFlagsBits.AttachFiles, PermissionFlagsBits.EmbedLinks];
      const deny = [PermissionFlagsBits.MentionEveryone, PermissionFlagsBits.CreatePublicThreads, PermissionFlagsBits.CreatePrivateThreads];
      channel = await guild.channels.create({ name: `bantuan-${user.id.slice(-8)}`, type: ChannelType.GuildText, parent: category.id, topic: `dtrp-ticket:owner:${user.id}`, permissionOverwrites: [{ id: guild.id, deny: [PermissionFlagsBits.ViewChannel] }, { id: user.id, allow, deny }, { id: staff.id, allow, deny }, { id: me.id, allow: [...allow, PermissionFlagsBits.ManageChannels] }], reason: 'Tiket bantuan Detroit Roleplay' });
      await this.pool.execute("UPDATE discord_bot_tickets SET channel_id = ?, status = 'open' WHERE guild_id = ? AND owner_id = ?", [channel.id, guild.id, user.id]);
      await channel.send({ content: `<@${user.id}>`, embeds: [embed(safeText(subject, 200), `${safeText(description, 2000)}\n\nPemilik: <@${user.id}>\nTiket ini dapat dilihat pemilik, staf, dan administrator Discord. Menutup tiket akan menghapus channel beserta percakapannya.`)], components: [row(button('ticket:close', 'Tutup Tiket', ButtonStyle.Danger))], allowedMentions: { users: [user.id], parse: [] } });
    } catch(error) {
      if(!channel) {
        // Jika request Discord timeout, channel mungkin sudah tercipta: pulihkan saat restart.
        if(error.code && typeof error.code === 'number') await this.pool.execute('DELETE FROM discord_bot_tickets WHERE guild_id = ? AND owner_id = ? AND channel_id IS NULL', [guild.id, user.id]);
      }
      if(channel) throw new UserError(`Channel tiket sudah dibuat: <#${channel.id}>. Panelnya gagal dikirim; gunakan /ticket-close di channel tiket jika perlu menutupnya.`);
      throw error;
    }
    await this.audit.write('Tiket dibuka', `Pemilik: ${user.id}\nChannel: <#${channel.id}>\nJudul: ${safeText(subject)}`);
    return channel;
  }
  async getClosable(interaction) {
    const [rows] = await this.pool.execute('SELECT owner_id, channel_id, status FROM discord_bot_tickets WHERE guild_id = ? AND channel_id = ?', [this.config.guildId, interaction.channelId]);
    const ticket = rows[0];
    if(!ticket) throw new UserError('Channel ini bukan tiket aktif.');
    if(ticket.owner_id !== interaction.user.id && !isAdmin(interaction, this.config) && !hasRole(interaction.member, this.config.ticketStaffRoleId)) throw new UserError('Hanya pemilik tiket atau staf yang dapat menutup tiket ini.');
    return ticket;
  }
  async close(interaction) {
    const ticket = await this.getClosable(interaction);
    const [result] = await this.pool.execute("UPDATE discord_bot_tickets SET status = 'closing' WHERE guild_id = ? AND owner_id = ? AND status = 'open'", [this.config.guildId, ticket.owner_id]);
    if(result.affectedRows !== 1) throw new UserError('Tiket sedang diproses. Tunggu sebentar.');
    try {
      const channel = await textChannel(this.client, this.config, ticket.channel_id, [PermissionFlagsBits.ManageChannels]);
      await channel.delete(`Tiket ditutup oleh ${interaction.user.id}`);
    } catch(error) {
      if(error.code !== 10003) {
        await this.pool.execute("UPDATE discord_bot_tickets SET status = 'open' WHERE guild_id = ? AND owner_id = ?", [this.config.guildId, ticket.owner_id]);
        throw error;
      }
    }
    await this.pool.execute('DELETE FROM discord_bot_tickets WHERE guild_id = ? AND owner_id = ?', [this.config.guildId, ticket.owner_id]);
    await this.audit.write('Tiket ditutup', `Pemilik: ${ticket.owner_id}\nDitutup oleh: ${interaction.user.id}\nChannel ID: ${ticket.channel_id}`);
  }
  async recover() {
    if(!this.config.ticketCategoryId) return;
    const guild = await this.client.guilds.fetch(this.config.guildId);
    const channels = await guild.channels.fetch();
    const [tickets] = await this.pool.execute('SELECT owner_id, channel_id, status FROM discord_bot_tickets WHERE guild_id = ?', [guild.id]);
    for(const ticket of tickets) {
      const channel = ticket.channel_id ? channels.get(ticket.channel_id) : channels.find(item => item?.parentId === this.config.ticketCategoryId && item.topic === `dtrp-ticket:owner:${ticket.owner_id}`);
      if(channel) await this.pool.execute("UPDATE discord_bot_tickets SET channel_id = ?, status = 'open' WHERE guild_id = ? AND owner_id = ?", [channel.id, guild.id, ticket.owner_id]);
      else await this.pool.execute('DELETE FROM discord_bot_tickets WHERE guild_id = ? AND owner_id = ?', [guild.id, ticket.owner_id]);
    }
  }
}

module.exports = { Tickets };
