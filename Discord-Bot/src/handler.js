const { MessageFlags, ButtonStyle } = require('discord.js');
const { UserError } = require('./errors');
const { isAdmin, requireAdmin, textChannel } = require('./discord');
const { safeText } = require('./security');
const views = require('./views');

function createHandler(services) {
  const { config, accounts, roles, panels, tickets, query, audit, cooldowns, locks, client } = services;

  function registrationChannel(interaction) {
    if(interaction.channelId !== config.registerChannelId) throw new UserError(`Gunakan registrasi di <#${config.registerChannelId}>.`);
  }
  async function privateReply(interaction, payload) {
    if(interaction.deferred || interaction.replied) return interaction.editReply({ ...payload, allowedMentions: { parse: [] } });
    return interaction.reply({ ...payload, flags: MessageFlags.Ephemeral, allowedMentions: { parse: [] } });
  }
  async function defer(interaction) { await interaction.deferReply({ flags: MessageFlags.Ephemeral }); }
  async function profile(interaction) { await defer(interaction); await privateReply(interaction, views.profileView(await accounts.requireAccount(interaction.user.id))); }
  async function code(interaction, regenerate) {
    await defer(interaction);
    const account = await locks.run(`account:${interaction.user.id}`, () => accounts.code(interaction.user.id, regenerate));
    if(regenerate) await audit.write('Kode verifikasi dibuat ulang', `Discord ID: ${interaction.user.id}`);
    await privateReply(interaction, views.codeView(account));
  }
  async function sync(interaction) {
    await defer(interaction);
    const verified = await roles.sync(interaction.user.id);
    await privateReply(interaction, { content: verified ? 'Role sudah disinkronkan dengan akun yang terverifikasi.' : 'Akun belum terverifikasi. Selesaikan registrasi di dalam game terlebih dahulu.' });
  }
  async function vehicles(interaction) { await defer(interaction); await privateReply(interaction, views.vehicleView(await accounts.vehicles(interaction.user.id))); }
  async function closePrompt(interaction) {
    await defer(interaction);
    await tickets.getClosable(interaction);
    await privateReply(interaction, { content: 'Tutup tiket dan hapus channel beserta seluruh percakapannya?', components: [views.row(views.button(`ticket:confirm:${interaction.channelId}:${interaction.user.id}`, 'Ya, Tutup Tiket', ButtonStyle.Danger), views.button('ticket:cancel', 'Batal', ButtonStyle.Secondary))] });
  }
  async function command(interaction) {
    const name = interaction.commandName;
    if(name === 'register') { registrationChannel(interaction); return interaction.showModal(views.registerModal()); }
    if(name === 'akun') return profile(interaction);
    if(name === 'kode') return code(interaction, interaction.options.getBoolean('buat-ulang') || false);
    if(name === 'kendaraan') return vehicles(interaction);
    if(name === 'syncrole') return sync(interaction);
    if(name === 'ticket') { tickets.assertEnabled(); return interaction.showModal(views.ticketModal()); }
    if(name === 'ticket-close') return closePrompt(interaction);
    if(name === 'announce') { requireAdmin(interaction, config); return interaction.showModal(views.announceModal(interaction.options.getChannel('channel', true).id)); }
    await defer(interaction);
    if(name === 'help') {
      let description = '**Akun:** /register, /akun, /kode, /kendaraan, /syncrole\n**Informasi:** /status, /players, /ping\n**Bantuan:** /ticket, /ticket-close\n\nDaftar memakai Nama_Belakang. Bot memberikan kode 6 digit. Masuk ke game dengan nama yang sama untuk verifikasi dan membuat password.';
      if(isAdmin(interaction, config)) description += '\n\n**Admin:** /setup, /account-info, /reset-code, /announce';
      return privateReply(interaction, { embeds: [views.embed('Panduan Bot', description)] });
    }
    if(name === 'ping') return privateReply(interaction, { content: `WebSocket: ${Math.max(0, client.ws.ping)} ms • Uptime: ${Math.floor(process.uptime() / 60)} menit.` });
    if(name === 'status') return privateReply(interaction, await views.statusView(query, config));
    if(name === 'players') {
      let players;
      try { players = await query.get('c'); } catch(error) {
        if(error instanceof UserError) throw error;
        throw new UserError('Daftar pemain belum dapat diambil. Server mungkin membatasi player query atau tidak dapat dijangkau.');
      }
      const lines = players.slice(0, 50).map((player, index) => `${index + 1}. ${safeText(player.name, 60)} • Level/score ${player.score}`);
      let description = lines.join('\n') || 'Tidak ada pemain online.';
      if(players.length > 50) description += `\n…dan ${players.length - 50} pemain lain.`;
      return privateReply(interaction, { embeds: [views.embed(`Pemain Online (${players.length})`, description.slice(0, 3900))] });
    }
    requireAdmin(interaction, config);
    if(name === 'setup') {
      const type = interaction.options.getString('panel', true);
      const channel = interaction.options.getChannel('channel', true);
      const message = await locks.run(`panel:${type}`, () => panels.setup(type, channel.id));
      await audit.write('Panel bot dipasang', `Admin: ${interaction.user.id}\nJenis: ${type}\nChannel: <#${channel.id}>`);
      return privateReply(interaction, { content: `Panel siap: ${message.url}` });
    }
    if(name === 'account-info') {
      const user = interaction.options.getUser('user', true);
      const account = await accounts.requireAccount(user.id);
      await audit.write('Admin melihat akun', `Admin: ${interaction.user.id}\nPemilik: ${user.id}`);
      const payload = views.profileView(account);
      payload.components = [];
      return privateReply(interaction, payload);
    }
    if(name === 'reset-code') {
      const user = interaction.options.getUser('user', true);
      await locks.run(`account:${user.id}`, () => accounts.code(user.id, true));
      await audit.write('Admin mereset kode verifikasi', `Admin: ${interaction.user.id}\nPemilik: ${user.id}`);
      return privateReply(interaction, { content: 'Kode akun yang belum terverifikasi sudah diganti. Pemilik dapat melihatnya lewat /kode dan perlu reconnect jika sedang di game.' });
    }
    throw new UserError('Command tidak dikenal. Jalankan npm run deploy untuk memperbarui command.');
  }
  async function button(interaction) {
    const id = interaction.customId;
    if(id === 'register:open') { registrationChannel(interaction); return interaction.showModal(views.registerModal()); }
    if(id === 'account:profile') return profile(interaction);
    if(id === 'account:code') return code(interaction, false);
    if(id === 'account:regenerate') return code(interaction, true);
    if(id === 'account:sync') return sync(interaction);
    if(id === 'account:vehicles') return vehicles(interaction);
    if(id === 'ticket:open') { tickets.assertEnabled(); return interaction.showModal(views.ticketModal()); }
    if(id === 'ticket:close') return closePrompt(interaction);
    if(id === 'ticket:cancel') return interaction.update({ content: 'Penutupan tiket dibatalkan.', components: [] });
    if(id.startsWith('ticket:confirm:')) {
      const [, , channelId, userId] = id.split(':');
      if(channelId !== interaction.channelId || userId !== interaction.user.id) throw new UserError('Konfirmasi tiket ini bukan milikmu.');
      await tickets.getClosable(interaction);
      await interaction.update({ content: 'Tiket sedang ditutup.', components: [] });
      return locks.run(`ticket-close:${channelId}`, () => tickets.close(interaction));
    }
    throw new UserError('Tombol tidak dikenal atau sudah tidak berlaku.');
  }
  async function modal(interaction) {
    const id = interaction.customId;
    if(id === 'register:submit') {
      registrationChannel(interaction);
      await defer(interaction);
      cooldowns.take(`register:${interaction.user.id}`, 10);
      const account = await locks.run(`account:${interaction.user.id}`, () => accounts.register(interaction.user.id, interaction.fields.getTextInputValue('character')));
      await audit.write('Akun didaftarkan', `Pemilik: ${interaction.user.id}\nKarakter: ${safeText(account.nama)}`);
      return privateReply(interaction, views.codeView(account));
    }
    if(id === 'ticket:submit') {
      await defer(interaction);
      cooldowns.take(`ticket:${interaction.user.id}`, 60);
      const channel = await locks.run(`ticket:${interaction.user.id}`, () => tickets.open(interaction.user, interaction.fields.getTextInputValue('subject'), interaction.fields.getTextInputValue('description')));
      return privateReply(interaction, { content: `Tiketmu sudah dibuat: <#${channel.id}>.` });
    }
    if(id.startsWith('announce:')) {
      requireAdmin(interaction, config);
      await defer(interaction);
      const channelId = id.slice('announce:'.length);
      if(!/^\d{17,20}$/.test(channelId)) throw new UserError('Channel pengumuman tidak valid.');
      const title = interaction.fields.getTextInputValue('title').trim();
      const body = interaction.fields.getTextInputValue('body').trim();
      if(!title || !body) throw new UserError('Judul dan isi pengumuman tidak boleh kosong.');
      const channel = await textChannel(client, config, channelId);
      const message = await channel.send({ embeds: [views.embed(safeText(title, 250), safeText(body, 3900))], allowedMentions: { parse: [] } });
      await audit.write('Pengumuman dikirim', `Admin: ${interaction.user.id}\nChannel: <#${channelId}>`);
      return privateReply(interaction, { content: `Pengumuman terkirim: ${message.url}` });
    }
    throw new UserError('Formulir tidak dikenal atau sudah tidak berlaku.');
  }
  return async function handle(interaction) {
    if(!interaction.isChatInputCommand() && !interaction.isButton() && !interaction.isModalSubmit()) return;
    try {
      if(interaction.guildId !== config.guildId) throw new UserError('Bot hanya tersedia di server Discord yang dikonfigurasi.');
      cooldowns.take(`interaction:${interaction.user.id}:${interaction.commandName || interaction.customId}`, 2);
      if(interaction.isChatInputCommand()) await command(interaction);
      else if(interaction.isButton()) await button(interaction);
      else await modal(interaction);
    } catch(error) {
      if(!(error instanceof UserError)) audit.error('INTERACTION', error);
      const content = error instanceof UserError ? error.message : 'Permintaan gagal diproses. Coba lagi sebentar atau hubungi staf.';
      try { await privateReply(interaction, { content, embeds: [], components: [] }); } catch(replyError) { audit.error('INTERACTION_REPLY', replyError); }
    }
  };
}

module.exports = { createHandler };
