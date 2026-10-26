const fs = require('node:fs');
const path = require('node:path');
const { loadConfig } = require('../src/config');
const { createDatabase } = require('../src/database');

async function migrate(pool) {
  const connection = await pool.getConnection();
  let locked = false;
  try {
    const [[lock]] = await connection.execute("SELECT GET_LOCK('dtrp_discord_migration', 10) AS acquired");
    if(!lock.acquired) throw new Error('Migrasi lain sedang berjalan. Coba lagi nanti.');
    locked = true;
    const [columns] = await connection.execute('SHOW COLUMNS FROM Pemain');
    for(const column of ['id', 'discordid', 'nama', 'verified', 'kode']) if(!columns.some(item => item.Field === column)) throw new Error(`Kolom Pemain.${column} tidak ditemukan. Import database/detroit-db.sql dari gamemode lebih dahulu.`);
    const [duplicates] = await connection.execute('SELECT discordid FROM Pemain GROUP BY discordid HAVING COUNT(*) > 1 LIMIT 1');
    if(duplicates.length) throw new Error('Ada discordid ganda. Perbaiki pemilik akun secara manual sebelum migrasi; tidak ada data yang dihapus.');
    const [invalid] = await connection.execute("SELECT id FROM Pemain WHERE discordid IS NULL OR CAST(discordid AS CHAR) NOT REGEXP '^[0-9]{17,20}$' LIMIT 1");
    if(invalid.length) throw new Error('Ada discordid tidak valid, mungkin terpotong oleh INT lama. Koreksi ID Discord pemilik akun secara manual; ID asli tidak dapat dipulihkan otomatis.');
    const [duplicateNames] = await connection.execute('SELECT nama FROM Pemain GROUP BY nama HAVING COUNT(*) > 1 LIMIT 1');
    if(duplicateNames.length) throw new Error('Ada nama karakter ganda. Perbaiki sebelum migrasi.');
    const [[versionTable]] = await connection.execute("SELECT COUNT(*) AS total FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'discord_bot_schema'");
    if(Number(versionTable.total) > 0) {
      const [versions] = await connection.execute('SELECT version FROM discord_bot_schema WHERE id = 1');
      if(versions[0]?.version > 1) throw new Error('Versi database lebih baru daripada bot. Gunakan versi bot yang sesuai.');
    }
    await connection.execute('ALTER TABLE Pemain MODIFY discordid VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL');
    if(!columns.some(item => item.Field === 'discord_code_updated_at')) await connection.execute('ALTER TABLE Pemain ADD COLUMN discord_code_updated_at DATETIME DEFAULT NULL');
    const [indexes] = await connection.execute('SHOW INDEX FROM Pemain');
    function hasUnique(column) {
      return indexes.some(index => !index.Non_unique && index.Column_name === column && indexes.filter(item => item.Key_name === index.Key_name).length === 1);
    }
    if(!hasUnique('discordid')) await connection.execute('ALTER TABLE Pemain ADD UNIQUE KEY uq_pemain_discordid (discordid)');
    if(!hasUnique('nama')) await connection.execute('ALTER TABLE Pemain ADD UNIQUE KEY uq_pemain_nama_discord_bot (nama)');
    const statements = fs.readFileSync(path.join(__dirname, '..', 'sql', 'bot-tables.sql'), 'utf8').split(';').map(item => item.trim()).filter(Boolean);
    for(const statement of statements) await connection.execute(statement);
    await connection.execute('INSERT INTO discord_bot_schema (id, version) VALUES (1, 1) ON DUPLICATE KEY UPDATE version = VALUES(version)');
  } finally {
    if(locked) await connection.execute("SELECT RELEASE_LOCK('dtrp_discord_migration')").catch(() => {});
    connection.release();
  }
}

async function main() {
  let pool;
  try {
    pool = createDatabase(loadConfig());
    await migrate(pool);
    console.log('Migrasi selesai. Data Pemain dan Kendaraan dipertahankan.');
  } catch(error) {
    console.error(`Migrasi gagal: ${error.sqlMessage ? 'MySQL menolak migrasi. Periksa schema/izin ALTER, CREATE, SELECT, INSERT, UPDATE.' : error.message}`);
    process.exitCode = 1;
  } finally { if(pool) await pool.end(); }
}

if(require.main === module) main();
module.exports = { migrate };
