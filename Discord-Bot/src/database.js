function createDatabase(config) {
  return require('mysql2/promise').createPool({ ...config.database, charset: 'utf8mb4', waitForConnections: true, connectionLimit: 5, queueLimit: 50, connectTimeout: 10000, supportBigNumbers: true, bigNumberStrings: true, multipleStatements: false });
}

async function assertSchema(pool) {
  const [rows] = await pool.execute('SELECT version FROM discord_bot_schema WHERE id = 1');
  if(rows[0]?.version !== 1) throw new Error('Jalankan npm run migrate terlebih dahulu.');
  await pool.execute('SELECT discordid, nama, verified, kode, discord_code_updated_at FROM Pemain LIMIT 0');
}

module.exports = { createDatabase, assertSchema };
