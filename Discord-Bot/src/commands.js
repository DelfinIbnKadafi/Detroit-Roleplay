const { SlashCommandBuilder, PermissionFlagsBits, ChannelType } = require('discord.js');

function commands() {
  function command(name, description) { return new SlashCommandBuilder().setName(name).setDescription(description).setDMPermission(false); }
  function admin(name, description) { return command(name, description).setDefaultMemberPermissions(PermissionFlagsBits.ManageGuild); }
  return [
    command('help', 'Lihat panduan dan daftar command bot.'),
    command('ping', 'Lihat latensi dan uptime bot.'),
    command('register', 'Daftarkan nama karakter Detroit Roleplay.'),
    command('akun', 'Lihat profil akun milikmu secara privat.'),
    command('kode', 'Lihat atau buat ulang kode verifikasi akun.').addBooleanOption(option => option.setName('buat-ulang').setDescription('Ganti kode lama. Reconnect ke game setelah kode diganti.')),
    command('kendaraan', 'Lihat kendaraan milik akunmu.'),
    command('syncrole', 'Sinkronkan role dengan status verifikasi akun.'),
    command('status', 'Lihat status server game.'),
    command('players', 'Lihat pemain yang sedang online.'),
    command('ticket', 'Buka formulir tiket bantuan privat.'),
    command('ticket-close', 'Tutup tiket bantuan di channel ini.'),
    admin('setup', 'Pasang atau perbarui panel bot.').addStringOption(option => option.setName('panel').setDescription('Jenis panel.').setRequired(true).addChoices({ name: 'Registrasi', value: 'register' }, { name: 'Tiket Bantuan', value: 'ticket' }, { name: 'Status Server', value: 'status' })).addChannelOption(option => option.setName('channel').setDescription('Channel tujuan panel.').addChannelTypes(ChannelType.GuildText).setRequired(true)),
    admin('account-info', 'Cari akun melalui pemilik Discord (khusus admin).').addUserOption(option => option.setName('user').setDescription('Pemilik akun.').setRequired(true)),
    admin('reset-code', 'Ganti kode akun yang belum diverifikasi.').addUserOption(option => option.setName('user').setDescription('Pemilik akun.').setRequired(true)),
    admin('announce', 'Buat pengumuman melalui formulir.').addChannelOption(option => option.setName('channel').setDescription('Channel tujuan pengumuman.').addChannelTypes(ChannelType.GuildText).setRequired(true))
  ];
}

module.exports = { commands };
