# Detroit Roleplay - Discord Bot

Discord Bot ini digunakan untuk mendaftarkan akun pemain Detroit Roleplay melalui Discord.
Data pendaftaran disimpan ke database yang sama dengan gamemode, sehingga pemain dapat
langsung melanjutkan verifikasi saat masuk ke dalam server.

## Cara Kerja

Gunakan perintah `/register` untuk mengirim embed pendaftaran ke channel Discord.
Pemain dapat menekan tombol Register, kemudian mengisi nama karakter dengan format
`First_Last`, seperti `John_Doe`. Panjang nama yang digunakan adalah 3-24 karakter,
huruf pertama pada kedua bagian nama harus kapital, dan bagian lainnya dapat berisi huruf atau angka.

Setelah pendaftaran berhasil, bot akan menyimpan Discord ID, nama karakter, dan kode
verifikasi 6 digit ke tabel `Pemain`. Kode tersebut hanya ditampilkan kepada pemain
yang mendaftar. Satu akun Discord hanya dapat digunakan untuk satu karakter, dan nama
yang sudah digunakan tidak dapat didaftarkan kembali.

Pemain kemudian masuk ke server menggunakan nama karakter yang sudah didaftarkan.
Masukkan kode dari bot saat diminta oleh gamemode, lalu buat password dan pilih gender
untuk menyelesaikan pendaftaran. Status `verified` akan diubah oleh gamemode setelah
proses tersebut selesai. Bot tidak membuat atau menyimpan password pemain.

Jika sudah pernah mendaftar, tekan kembali tombol Register untuk melihat nama karakter,
kode verifikasi, dan status akun. Jika database sedang lambat, form dapat tetap terbuka,
namun bot akan memeriksa kembali data akun saat form dikirim.

## Instalasi

Siapkan Node.js 18 atau lebih baru, MySQL atau MariaDB, serta aplikasi bot dari
[Discord Developer Portal](https://discord.com/developers/applications).
Anda dapat menggunakan Node.js 24 untuk menjalankan bot ini.

1. Clone Repositori

Gunakan perintah Git berikut untuk menyalin repositori ke perangkat lokal Anda:

    git clone https://github.com/DelfinIbnKadafi/Detroit-Roleplay.git
    cd Detroit-Roleplay/Discord-Bot

2. Install Package

Jalankan perintah berikut di dalam folder `Discord-Bot`:

    npm ci

Package yang diperlukan akan diinstall berdasarkan `package-lock.json`.
Folder `node_modules` tidak perlu diupload ke GitHub.

3. Setup Database

Untuk instalasi baru, buat database terlebih dahulu, kemudian import file
[`database/detroit-db.sql`](../database/detroit-db.sql) dari folder root repositori.
Anda dapat menggunakan phpMyAdmin atau MySQL client untuk melakukan import.

Contoh melalui MySQL client, dijalankan dari folder `Discord-Bot`:

    mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS dtrp CHARACTER SET utf8mb4;"
    mysql -u root -p dtrp < ../database/detroit-db.sql

Jika Anda sudah memiliki database dari versi sebelumnya, jangan import ulang file
tersebut ke database yang sedang dipakai. Backup database, lalu jalankan
[`database/discord-bot.sql`](../database/discord-bot.sql) sekali untuk menambahkan
index unik pada `discordid`:

    mysql -u root -p dtrp < ../database/discord-bot.sql

Instalasi baru sudah memiliki index ini, sehingga tidak perlu menjalankan file tambahan.
Jika migrasi gagal karena Discord ID duplikat, periksa akun yang bersangkutan terlebih
dahulu. Migrasi ini tidak menghapus atau menggabungkan akun pemain.

Contoh untuk mencari Discord ID yang terdaftar lebih dari sekali:

    SELECT discordid, COUNT(*) AS jumlah FROM Pemain GROUP BY discordid HAVING COUNT(*) > 1;

4. Setup `.env`

Salin file `.env.example` menjadi `.env`, kemudian isi credentials bot dan database Anda.
Pastikan database ini sama dengan yang digunakan pada `mysql.ini` milik gamemode.

Contoh:

    TOKEN=token_bot_anda
    CLIENT_ID=application_id_anda
    GUILD_ID=server_id_anda

    DB_HOST=127.0.0.1
    DB_PORT=3306
    DB_USER=root
    DB_PASSWORD=
    DB_NAME=dtrp

`TOKEN` dapat diambil pada halaman Bot di Developer Portal. `CLIENT_ID` adalah
Application ID pada halaman General Information. Untuk mengambil `GUILD_ID`, aktifkan
Developer Mode pada pengaturan Discord, lalu klik kanan server dan pilih Copy Server ID.

Isi `GUILD_ID` jika command hanya ingin didaftarkan ke satu server. Kosongkan nilainya
jika Anda ingin mendaftarkan command secara global. Sebaiknya tetap isi `CLIENT_ID`
meskipun bot masih dapat mencoba membacanya dari token.

Konfigurasi lama menggunakan `HOST`, `PORT`, `USER`, `PASSWORD`, dan `DATABASE` pada
file `.env` masih didukung. Variabel `DB_*` akan didahulukan jika keduanya tersedia.
Jika password mengandung tanda `#`, bungkus nilainya dengan tanda kutip.
Jangan membagikan token atau mengupload file `.env` ke repositori.

5. Undang Bot ke Server

Pada Developer Portal, buka OAuth2 URL Generator, pilih scope `bot` dan
`applications.commands`, lalu berikan permission View Channels, Send Messages, dan
Embed Links. Buka URL yang dihasilkan untuk mengundang bot ke server Anda.

Bot ini menggunakan slash command, tombol, dan modal. Message Content Intent tidak
diperlukan untuk fitur pendaftaran yang tersedia saat ini.

## Menjalankan Bot

1. Daftarkan Command

Setelah file `.env` selesai diisi, jalankan:

    npm run deploy

Jalankan kembali perintah ini jika nama, deskripsi, atau pilihan slash command diubah.
Perintah ini tidak menjalankan bot dan tidak memerlukan koneksi database.

2. Jalankan Bot

    npm start

Bot akan memeriksa koneksi database dan index `discordid` terlebih dahulu.
Jika berhasil login, console akan menampilkan `Logged in as ...`.
Gunakan `/register` di channel yang ingin digunakan untuk pendaftaran.

Pastikan proses bot tetap berjalan agar tombol dan form dapat digunakan.
Untuk menghentikan bot dari terminal, tekan `Ctrl+C`.

## Struktur Folder

File utama bot berada di `src/index.js`, sedangkan koneksi database berada di
`src/mysql.js`. Folder `src/commands` berisi slash command, `src/buttons` menangani
tombol, dan `src/modals` menangani form yang dikirim oleh pemain. Semua handler
dimuat dari folder `src/handler` saat bot dijalankan.

Jika ingin menambahkan command, tombol, atau modal baru, Anda dapat mengikuti bentuk
file yang sudah tersedia di masing-masing folder. Nama command dan `customId` harus
sesuai dengan yang digunakan pada interaksi Discord.

## Pengujian

Untuk menjalankan pengujian lokal:

    npm test

Pengujian menggunakan interaksi Discord dan database tiruan, sehingga tidak memerlukan
token maupun akses ke database server. Pengujian ini memeriksa validasi nama,
pendaftaran ganda, penanganan insert yang gagal, serta respons saat database lambat.

## Kendala

Jika command tidak muncul, periksa `CLIENT_ID` dan `GUILD_ID`, lalu jalankan kembali
`npm run deploy`. Command global dapat membutuhkan waktu untuk muncul di semua server.
Pastikan bot diundang dengan scope `applications.commands` dan command boleh digunakan
pada channel tersebut.

Jika koneksi database gagal, pastikan MySQL sudah berjalan, credentials sesuai, dan
user database memiliki akses ke database Detroit Roleplay. Error `Table ... doesn't
exist` biasanya terjadi karena database belum diimport atau `DB_NAME` menunjuk ke
database yang berbeda. Nama tabel yang digunakan adalah `Pemain`, termasuk huruf kapitalnya.

Jika muncul pesan index unik belum tersedia, jalankan migrasi untuk database lama
seperti pada langkah instalasi. Error `Duplicate key name` saat menjalankan migrasi
berarti index dengan nama tersebut sudah ada.

## Kontribusi

Kontribusi Anda sangat dihargai untuk pengembangan bot ini.
Jika Anda ingin berkontribusi, silakan lakukan Fork pada repositori ini,
buat perubahan, lalu kirimkan Pull Request.

## Lisensi

Bot ini merupakan bagian dari Detroit Roleplay. Anda bebas menggunakan, memodifikasi,
dan membagikannya sesuai dengan lisensi pada repositori ini.
Terima kasih telah menggunakan Detroit Roleplay.

**MIT LICENSE**
