const { UserError } = require('./errors');

function validateName(input) {
  const name = input.trim();
  if(name.length < 3 || name.length > 24 || !/^[A-Z][a-z]+(?:_[A-Z][a-z]+)+$/.test(name)) throw new UserError('Gunakan nama karakter seperti John_Smith (3–24 karakter, huruf dan garis bawah).');
  return name;
}

class Cooldowns {
  constructor(now = Date.now) { this.entries = new Map(); this.now = now; }
  take(key, seconds) {
    const now = this.now();
    const until = this.entries.get(key) || 0;
    if(until > now) throw new UserError(`Tunggu ${Math.ceil((until - now) / 1000)} detik sebelum mencoba lagi.`);
    this.entries.set(key, now + seconds * 1000);
    if(this.entries.size > 1000) for(const [entry, expiry] of this.entries) if(expiry <= now) this.entries.delete(entry);
  }
}

class Locks {
  constructor() { this.active = new Set(); }
  async run(key, task) {
    if(this.active.has(key)) throw new UserError('Permintaan sebelumnya masih diproses. Tunggu sebentar.');
    this.active.add(key);
    try { return await task(); } finally { this.active.delete(key); }
  }
}

function safeText(value, max = 1000) {
  return String(value ?? '-').replace(/@/g, '@\u200b').replace(/([\\`*_~|>\[\]])/g, '\\$1').slice(0, max) || '-';
}

module.exports = { validateName, Cooldowns, Locks, safeText };
