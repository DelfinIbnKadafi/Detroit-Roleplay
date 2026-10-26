const { randomInt } = require('node:crypto');
const { validateName } = require('./security');
const { UserError } = require('./errors');

class Accounts {
  constructor(pool, config) { this.pool = pool; this.config = config; }
  async byDiscord(discordId) {
    const [rows] = await this.pool.execute('SELECT id, discordid, nama, verified, kode, level, uang, bank, job, gender, discord_code_updated_at FROM Pemain WHERE discordid = ? LIMIT 1', [discordId]);
    return rows[0] || null;
  }
  async requireAccount(discordId) {
    const account = await this.byDiscord(discordId);
    if(!account) throw new UserError('Kamu belum memiliki akun. Gunakan tombol Daftar atau /register.');
    return account;
  }
  async register(discordId, rawName) {
    const name = validateName(rawName);
    if(await this.byDiscord(discordId)) throw new UserError('Discord kamu sudah terhubung ke akun. Gunakan /akun atau /kode.');
    const code = randomInt(100000, 1000000);
    try {
      await this.pool.execute('INSERT INTO Pemain (discordid, nama, verified, kode, discord_code_updated_at) VALUES (?, ?, 0, ?, UTC_TIMESTAMP())', [discordId, name, code]);
    } catch(error) {
      if(error.code === 'ER_DUP_ENTRY') throw new UserError('Nama karakter atau akun Discord sudah terdaftar. Gunakan nama lain atau periksa /akun.');
      throw error;
    }
    return { nama: name, kode: code, verified: 0 };
  }
  async code(discordId, regenerate = false) {
    const account = await this.requireAccount(discordId);
    if(account.verified) throw new UserError('Akun sudah terverifikasi di dalam game dan tidak membutuhkan kode lagi.');
    if(!regenerate && Number(account.kode) >= 100000 && Number(account.kode) <= 999999) return account;
    let code;
    do { code = randomInt(100000, 1000000); } while(code === Number(account.kode));
    const [result] = await this.pool.execute('UPDATE Pemain SET kode = ?, discord_code_updated_at = UTC_TIMESTAMP() WHERE id = ? AND verified = 0 AND (discord_code_updated_at IS NULL OR discord_code_updated_at <= DATE_SUB(UTC_TIMESTAMP(), INTERVAL ? SECOND))', [code, account.id, this.config.codeCooldown]);
    if(result.affectedRows !== 1) throw new UserError(`Kode belum dapat diganti. Tunggu ${this.config.codeCooldown} detik dan pastikan akun belum terverifikasi.`);
    return { ...account, kode: code };
  }
  async vehicles(discordId) {
    const account = await this.requireAccount(discordId);
    const [rows] = await this.pool.execute('SELECT vid, model, plate, fuel, health, death FROM Kendaraan WHERE pid = ? ORDER BY vid LIMIT 5', [account.id]);
    return { account, vehicles: rows };
  }
  async verifiedAccounts(afterId = 0) {
    const [rows] = await this.pool.execute('SELECT id, discordid, verified FROM Pemain WHERE id > ? ORDER BY id LIMIT 100', [afterId]);
    return rows;
  }
}

module.exports = { Accounts };
