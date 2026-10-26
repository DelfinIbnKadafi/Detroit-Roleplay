# Detroit Roleplay - Business

Sistem ini digunakan untuk membuat dan mengatur pintu business dari dalam game.
Saat server dijalankan, data pada tabel `bussines` akan dimuat menjadi pickup pintu
dan 3D text label. Format label tetap menampilkan ID, nama, Owner, Type, dan Stock.

Untuk sekarang pintu berada di luar bangunan, pada interior 0 dan virtual world 0.
Pintu belum terhubung ke interior, menu pembelian, maupun sistem transaksi.
Stock dan owner yang tersedia saat ini merupakan data business yang dapat diatur admin.

## Instalasi

Compile kembali `gamemodes/DTRP.pwn` menggunakan compiler Pawn dan include yang tersedia
pada repositori ini. Pastikan plugin MySQL dan Streamer dimuat saat server dijalankan.

Tabel `bussines` sudah tersedia pada `database/detroit-db.sql` untuk instalasi baru.
Jika database Anda belum memiliki tabel tersebut, pilih database yang digunakan oleh
gamemode, lalu import `database/bussines.sql` dari folder root repositori.
File tambahan tersebut hanya membuat tabel jika belum tersedia dan tidak menghapus data.
Setelah tabel siap, jalankan atau restart server untuk memuat pintu business.

Jika tabel business sudah dibuat sebelumnya, pastikan kolomnya sesuai dengan file SQL.
Kolom `id` harus menjadi primary key dengan auto increment. Nama tabel tetap menggunakan
`bussines`, sehingga data lama tidak perlu dipindahkan ke tabel dengan nama baru.

## Command Admin

Semua command pengelolaan business membutuhkan admin level 1 atau lebih tinggi dan
pemain sudah login. Command juga tersedia pada `/ahelp`.

| Command | Kegunaan |
| --- | --- |
| `/createbusiness <type> <nama>` | Membuat business pada posisi admin. |
| `/editbusiness <id> pos` | Membuka editor posisi pintu. Admin harus berada dalam jarak 20 meter. |
| `/editbusiness <id> here` | Memindahkan pintu ke posisi admin saat ini. |
| `/editbusiness <id> name <nama>` | Mengubah nama business. |
| `/editbusiness <id> type <angka>` | Mengubah tipe business. |
| `/editbusiness <id> stock <jumlah>` | Mengubah stock business. |
| `/editbusiness <id> owner <id akun>` | Menentukan pemilik berdasarkan `Pemain.id` pada database. |
| `/editbusiness <id> owner 0` | Menghapus pemilik business. |
| `/gotobusiness <id>` | Teleport ke pintu business. Admin harus turun dari kendaraan. |
| `/businesslist [halaman]` | Melihat daftar business, 10 business per halaman. |
| `/deletebusiness <id>` | Membuka konfirmasi untuk menghapus business. |
| `/cancelbusinessedit` | Membatalkan editor posisi yang sedang digunakan. |

ID pada command adalah ID business di database, bukan urutan atau index array.
ID akun pemilik juga merupakan ID database, sehingga pemilik tidak harus sedang online.
Pembatalan editor tetap dapat digunakan jika akses admin dicabut saat proses edit.

Contoh:

    /createbusiness 0 Market Los Santos
    /editbusiness 1 pos
    /editbusiness 1 name Delfin Market
    /editbusiness 1 stock 500
    /editbusiness 1 owner 7

Type `0` ditampilkan sebagai Market seperti pada sistem sebelumnya.
Nilai `1-127` disimpan dan ditampilkan sebagai `Type <angka>`, sehingga tipe lain dapat
dikembangkan nanti. Business baru memiliki stock 100 dan belum memiliki pemilik.
Nama business dapat berisi 1-128 karakter, tanpa baris baru, tab, atau kode warna.

## Penyimpanan Data

Pembuatan, perubahan, dan penghapusan langsung disimpan ke database.
Pesan berhasil hanya dikirim setelah query berhasil. Jika penyimpanan gagal, data dan
posisi lama tetap digunakan. Tidak perlu menunggu pemain disconnect untuk menyimpan business.

Editor menggunakan object sementara khusus admin karena pickup tidak dapat diedit
langsung. Hanya posisi yang disimpan, sedangkan rotasi pada editor tidak digunakan
oleh pickup. Tombol Save menyimpan posisi, dan Cancel atau `/cancelbusinessedit`
membuang perubahan yang belum disimpan.

Satu pintu hanya dapat diedit oleh satu admin pada waktu yang sama. Perubahan data dan
penghapusan pintu tersebut ditolak selama editor posisi masih digunakan. Jika admin
disconnect, object sementara dibersihkan dan business dapat diedit kembali oleh admin lain.

Maksimal business yang dimuat mengikuti `MAX_BUSSINES`, yaitu 1000.
Slot business yang dihapus dapat digunakan kembali tanpa mengubah ID business lainnya.
Data yang tidak valid atau melebihi batas akan dicatat pada console saat load.

## Struktur File

`DATA.pwn` berisi enum, batas nama, serta status editor business. File ini dimuat melalui
`DATA/header.inc` agar data business dapat digunakan oleh callback dan sistem lainnya.

`BUSSINES.pwn` menangani pencarian ID, validasi, pickup, dan text label.
`DATABASE.pwn` menangani load, insert, update, serta delete pada database.
`EDIT.pwn` menangani object sementara, penguncian editor, dan pembatalan edit.

Command admin berada di `COMMAND/BUSSINES.pwn`, sedangkan dialog daftar dan konfirmasi
hapus berada di `COMMAND/DIALOG/BUSSINES.pwn`. Callback editor diteruskan dari
`OnPlayerEditDynamicObject` yang sebelumnya sudah digunakan oleh sistem ATM.
