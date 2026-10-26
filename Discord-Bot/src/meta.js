class Meta {
  constructor(pool) { this.pool = pool; }
  async get(key) {
    const [rows] = await this.pool.execute('SELECT value FROM discord_bot_meta WHERE name = ?', [key]);
    return rows[0] ? JSON.parse(rows[0].value) : null;
  }
  async set(key, value) {
    await this.pool.execute('INSERT INTO discord_bot_meta (name, value) VALUES (?, ?) ON DUPLICATE KEY UPDATE value = VALUES(value)', [key, JSON.stringify(value)]);
  }
}

module.exports = { Meta };
