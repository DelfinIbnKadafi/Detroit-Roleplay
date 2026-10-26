-- Untuk database lama, jalankan sekali setelah memilih database Detroit Roleplay
-- Jika gagal karena data duplikat, periksa akun yang bersangkutan terlebih dahulu
ALTER TABLE `Pemain`
  ADD UNIQUE KEY `uq_pemain_discordid` (`discordid`);
