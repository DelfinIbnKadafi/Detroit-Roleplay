# Detroit Roleplay Discord Bot

Bot Discord untuk menghubungkan registrasi karakter Detroit Roleplay dengan database gamemode. Bot menyediakan pendaftaran melalui Discord, kode verifikasi, sinkronisasi role, informasi akun, status server, dan tiket bantuan.

## Fitur

- **Registrasi karakter:** panel tombol dan formulir nama seperti `John_Smith`, dengan batas satu akun per Discord serta nama karakter yang unik.
- **Kode verifikasi:** kode acak 6 digit yang hanya ditampilkan kepada pemilik akun, dengan pilihan membuat ulang kode dan cooldown.
- **Role otomatis:** role diberikan setelah pemain menyelesaikan registrasi di dalam game.
- **Informasi akun:** profil, level, uang, bank, dan daftar kendaraan melalui respons privat.
- **Status server:** informasi server dan pemain online melalui query SA-MP/open.mp, termasuk panel status yang diperbarui otomatis.
- **Bantuan dan administrasi:** tiket privat, pengumuman melalui formulir, pencarian akun oleh admin, log aktivitas, serta pesan sambutan opsional.

## Alur Registrasi

1. Pemain menekan tombol **Daftar** atau menjalankan `/register` pada channel registrasi.
2. Pemain mengisi nama karakter dengan format `John_Smith` atau `John_Van_Smith`, maksimal 24 karakter.
3. Bot memeriksa nama dan pemilik Discord, lalu membuat data pada tabel `Pemain` dengan `verified = 0` beserta kode verifikasi.
4. Pemain masuk ke server game menggunakan nama karakter yang sama dan memasukkan kode tersebut.
5. Gamemode meminta pemain membuat password dan memilih gender, kemudian menyimpan `verified = 1`.
6. Bot mendeteksi perubahan tersebut dan memberikan role verified. Pemeriksaan berlangsung setiap 60 detik secara default; pemain dapat menggunakan `/syncrole` untuk memeriksa langsung.

Password dibuat di dalam game. Bot tidak meminta password melalui Discord. `/kode` menampilkan kode akun yang belum terverifikasi, sedangkan `/kode buat-ulang:true` menggantinya setelah cooldown. Jika kode diganti saat pemain sedang berada di game, pemain harus reconnect agar gamemode memuat kode terbaru.

Profil dan kendaraan mengikuti data terakhir yang disimpan gamemode. Tiket bantuan membuat channel privat untuk pemilik dan staf; penutupannya memerlukan konfirmasi dan menghapus channel beserta percakapannya.

## Instalasi

### 1. Siapkan kebutuhan

- Node.js versi **22.12.0 atau lebih baru** dan npm.
- MySQL 5.7+ atau MariaDB 10.2+.
- Database Detroit Roleplay yang sudah diimpor dari `database/detroit-db.sql` milik gamemode.
- Aplikasi bot Discord yang dibuat melalui [Discord Developer Portal](https://discord.com/developers/applications).

Bot dan gamemode harus menggunakan database yang sama. Untuk fitur status, host bot harus dapat mengakses port UDP server game.

### 2. Undang dan atur bot

Di Developer Portal, gunakan scope **`bot`** dan **`applications.commands`** untuk mengundang bot ke server Discord.

Berikan izin berikut pada channel yang digunakan:

- View Channels
- Send Messages
- Embed Links
- Read Message History
- Manage Roles untuk role verified
- Manage Channels dan Manage Roles untuk tiket
- Attach Files untuk lampiran pada tiket

Letakkan role bot **di atas role verified**. Role verified harus berupa role biasa yang dapat dikelola bot.

Jika ingin mengaktifkan sambutan dan sinkronisasi saat anggota bergabung kembali, aktifkan **Server Members Intent** pada halaman Bot di Developer Portal dan gunakan `ENABLE_MEMBER_EVENTS=true`. Fitur registrasi tidak memerlukan Message Content Intent.

### 3. Pasang dependensi

Ekstrak paket bot, buka terminal pada folder `Discord-Bot`, kemudian jalankan:

```sh
npm ci
```

### 4. Isi konfigurasi

Salin `.env.example` menjadi `.env`.

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Linux:

```sh
cp .env.example .env
```

Isi konfigurasi berikut:

| Variabel | Keterangan |
| --- | --- |
| `DISCORD_BOT_TOKEN` | Token bot dari Developer Portal |
| `CLIENT_ID` | Application ID aplikasi bot |
| `GUILD_ID` | ID server Discord |
| `CHANNEL_REGISTER_ID` | ID channel registrasi |
| `ROLE_VERIFIED` | ID role untuk pemain yang selesai registrasi di game |
| `HOST_DB`, `PORT_DB` | Host dan port MySQL; port default `3306` |
| `USERNAME_DB`, `PASSWORD_DB`, `DATABASE_NAME` | User, password, dan nama database gamemode |
| `ADMIN_ROLE_IDS` | Opsional: ID role admin, dipisahkan koma |
| `CHANNEL_LOG_ID` | Opsional: ID channel log khusus staf |
| `CHANNEL_WELCOME_ID` | Opsional: ID channel sambutan |
| `TICKET_CATEGORY_ID`, `TICKET_STAFF_ROLE_ID` | Opsional: kategori dan role khusus staf tiket; isi keduanya untuk mengaktifkan tiket |
| `GAME_HOST`, `GAME_PORT` | Host dan port game untuk fitur status; port default `7777` |

`CLIENT_ID` dan `GUILD_ID` berbeda. Aktifkan Developer Mode pada pengaturan Discord untuk menyalin ID server, channel, dan role. `GAME_HOST` diisi hostname atau IPv4 tanpa protokol dan port. Role staf tiket harus berbeda dari role verified.

Biarkan pengaturan interval pada `.env.example` menggunakan nilai default jika tidak perlu diubah. Simpan `.env` secara privat dan jangan unggah ke GitHub.

### 5. Jalankan migrasi dan daftarkan command

Backup database, lalu hentikan sementara gamemode dan bot sebelum menjalankan migrasi:

```sh
npm run migrate
```

Migrasi menyiapkan tabel bot, mengubah `discordid` menjadi `VARCHAR(20)`, dan menambahkan pembatas akun ganda. Data akun serta kendaraan dipertahankan. Jika terdapat ID Discord tidak valid atau data ganda, migrasi akan berhenti agar data diperbaiki secara manual. ID yang sudah terpotong oleh tipe `INT` lama tidak dapat dipulihkan otomatis.

Setelah migrasi selesai, daftarkan slash command:

```sh
npm run deploy
```

Command didaftarkan pada server yang ditentukan oleh `GUILD_ID`. Jalankan ulang perintah ini ketika daftar command berubah. Gunakan aplikasi bot khusus proyek ini karena proses deploy mengganti daftar guild command milik aplikasi tersebut.

### 6. Nyalakan bot dan pasang panel

```sh
npm start
```

Gamemode dapat dijalankan kembali setelah migrasi selesai. Saat bot online, gunakan command berikut di Discord:

```text
/setup panel:Registrasi channel:#registrasi
/setup panel:Tiket Bantuan channel:#bantuan
/setup panel:Status Server channel:#status
```

Pilih jenis panel melalui pilihan command Discord dan sesuaikan channel tujuan. Panel registrasi wajib berada di channel yang sama dengan `CHANNEL_REGISTER_ID`. Panel tiket dan status hanya dipasang jika konfigurasinya sudah diisi.

Command admin secara default membutuhkan izin **Manage Server**. Jika menggunakan role dari `ADMIN_ROLE_IDS`, berikan akses command melalui **Server Settings → Integrations → bot → Commands**.

Bot siap digunakan setelah panel registrasi terpasang. Pemain dapat memakai `/help` untuk melihat command, `/akun` untuk profil, `/kendaraan` untuk daftar kendaraan, dan `/ticket` untuk membuka bantuan.
