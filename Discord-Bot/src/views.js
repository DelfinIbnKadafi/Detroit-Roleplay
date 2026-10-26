const { EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle, ModalBuilder, TextInputBuilder, TextInputStyle } = require('discord.js');
const { safeText } = require('./security');

function embed(title, description) {
  const result = new EmbedBuilder().setColor(0x00b8d4).setTitle(title).setFooter({ text: 'Detroit Roleplay' }).setTimestamp();
  if(description) result.setDescription(description);
  return result;
}

function button(id, label, style = ButtonStyle.Primary) { return new ButtonBuilder().setCustomId(id).setLabel(label).setStyle(style); }
function row(...components) { return new ActionRowBuilder().addComponents(...components); }
function field(id, label, max, style = TextInputStyle.Short) { return new TextInputBuilder().setCustomId(id).setLabel(label).setStyle(style).setMaxLength(max).setRequired(true); }

function registerModal() {
  const input = field('character', 'Nama karakter (contoh: John_Smith)', 24).setMinLength(3);
  return new ModalBuilder().setCustomId('register:submit').setTitle('Daftar Detroit Roleplay').addComponents(row(input));
}

function ticketModal() {
  return new ModalBuilder().setCustomId('ticket:submit').setTitle('Bantuan Detroit Roleplay').addComponents(row(field('subject', 'Judul masalah', 100)), row(field('description', 'Jelaskan masalahmu (jangan tulis password)', 1000, TextInputStyle.Paragraph)));
}

function announceModal(channelId) {
  return new ModalBuilder().setCustomId(`announce:${channelId}`).setTitle('Buat Pengumuman').addComponents(row(field('title', 'Judul pengumuman', 200)), row(field('body', 'Isi pengumuman', 3500, TextInputStyle.Paragraph)));
}

function registerPanel() {
  return { embeds: [embed('Detroit Roleplay • Registrasi', 'Daftarkan nama karakter melalui tombol di bawah. Setelah mendapat kode 6 digit, masuk ke game memakai nama karakter yang sama, masukkan kode, lalu buat password di dalam game.\n\nKode dan data akun hanya terlihat oleh pemiliknya.')], components: [row(button('register:open', 'Daftar'), button('account:code', 'Kode Verifikasi', ButtonStyle.Secondary), button('account:profile', 'Akun Saya', ButtonStyle.Secondary))] };
}

function ticketPanel() {
  return { embeds: [embed('Bantuan Detroit Roleplay', 'Tekan tombol di bawah untuk membuka channel privat bersama staf. Satu tiket aktif untuk setiap anggota. Jangan bagikan password atau kode verifikasi.')], components: [row(button('ticket:open', 'Buka Tiket'))] };
}

function codeView(account) {
  return { embeds: [embed('Kode Verifikasi', `Nama karakter: **${safeText(account.nama)}**\nKode: **${account.kode}**\n\nMasuk ke game menggunakan nama di atas. Masukkan kode, buat password, lalu pilih gender.\nJika kode baru dibuat ulang ketika kamu sedang di game, reconnect agar kode terbaru dimuat.\nJangan bagikan kode ini kepada orang lain.`)], components: [row(button('account:regenerate', 'Buat Ulang Kode', ButtonStyle.Secondary), button('account:profile', 'Akun Saya', ButtonStyle.Secondary))] };
}

function profileView(account) {
  const rupiah = value => `Rp${Number(value || 0).toLocaleString('id-ID')}`;
  return { embeds: [embed('Profil Akun').addFields({ name: 'Nama karakter', value: safeText(account.nama), inline: true }, { name: 'Status', value: account.verified ? 'Terverifikasi di game' : 'Menunggu verifikasi di game', inline: true }, { name: 'Level', value: String(account.level || 1), inline: true }, { name: 'Uang', value: rupiah(account.uang), inline: true }, { name: 'Bank', value: rupiah(account.bank), inline: true }, { name: 'ID Akun', value: String(account.id), inline: true }).setDescription('Data mengikuti simpanan terakhir dari gamemode.')], components: [row(button('account:vehicles', 'Kendaraan', ButtonStyle.Secondary), button('account:sync', 'Sinkronkan Role', ButtonStyle.Secondary))] };
}

function vehicleView(data) {
  const description = data.vehicles.map((vehicle, index) => `${index + 1}. Model **${vehicle.model}** • Plat ${safeText(vehicle.plate || '-')}\nID: ${vehicle.vid} • BBM: ${vehicle.fuel ?? 0} • Kondisi: ${vehicle.death ? 'Mati / rusak total' : `${Math.round(Number(vehicle.health) / 10)}%`}`).join('\n\n');
  return { embeds: [embed(`Kendaraan ${data.account.nama}`, description || 'Akun ini belum memiliki kendaraan.')] };
}

async function statusView(query, config) {
  if(!config.gameHost) return { embeds: [embed('Status Server', 'GAME_HOST belum dikonfigurasi.')] };
  try {
    const info = await query.get('i');
    return { embeds: [embed('Status Server • Online').setColor(0x2ecc71).addFields({ name: 'Nama', value: safeText(info.name), inline: false }, { name: 'Alamat', value: `${config.gameHost}:${config.gamePort}`, inline: true }, { name: 'Pemain', value: `${info.players}/${info.maxPlayers}`, inline: true }, { name: 'Gamemode', value: safeText(info.gamemode), inline: true }, { name: 'Bahasa', value: safeText(info.language), inline: true }, { name: 'Password server', value: info.password ? 'Ya' : 'Tidak', inline: true })] };
  } catch {
    return { embeds: [embed('Status Server • Tidak Terjangkau', `Alamat: ${config.gameHost}:${config.gamePort}\nServer belum merespons query UDP. Server mungkin offline, query dimatikan, atau koneksi diblokir.`).setColor(0xe67e22)] };
  }
}

module.exports = { embed, button, row, registerModal, ticketModal, announceModal, registerPanel, ticketPanel, codeView, profileView, vehicleView, statusView };
