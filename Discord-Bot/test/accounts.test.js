const test = require('node:test');
const assert = require('node:assert/strict');
const { Accounts } = require('../src/accounts');

const discordId = '123456789012345678';

test('registration keeps the exact Discord snowflake and waits for in-game verification', async () => {
  let inserted;
  const pool = { async execute(sql, values) {
    if(sql.startsWith('SELECT')) return [[]];
    inserted = { sql, values };
    return [{ affectedRows: 1 }];
  } };
  const account = await new Accounts(pool, {}).register(discordId, 'John_Smith');
  assert.equal(inserted.values[0], discordId);
  assert.equal(typeof inserted.values[0], 'string');
  assert.match(inserted.sql, /VALUES \(\?, \?, 0, \?, UTC_TIMESTAMP\(\)\)/);
  assert.equal(account.verified, 0);
  assert.match(String(account.kode), /^[1-9]\d{5}$/);
  assert.doesNotMatch(inserted.sql, /sandi/);
});

test('an already-linked Discord account cannot register another character', async () => {
  let count = 0;
  const pool = { async execute() { count++; return [[{ id: 1, discordid: discordId }]]; } };
  await assert.rejects(new Accounts(pool, {}).register(discordId, 'John_Smith'), /sudah terhubung/);
  assert.equal(count, 1);
});

test('a unique-constraint race produces a user-facing error', async () => {
  const pool = { async execute(sql) {
    if(sql.startsWith('SELECT')) return [[]];
    throw Object.assign(new Error('duplicate'), { code: 'ER_DUP_ENTRY' });
  } };
  await assert.rejects(new Accounts(pool, {}).register(discordId, 'John_Smith'), /sudah terdaftar/);
});

test('verified accounts cannot receive or regenerate registration codes', async () => {
  let writes = 0;
  const pool = { async execute(sql) {
    if(!sql.startsWith('SELECT')) writes++;
    return [[{ id: 1, verified: 1, kode: 123456 }]];
  } };
  const accounts = new Accounts(pool, { codeCooldown: 60 });
  await assert.rejects(accounts.code(discordId, false), /sudah terverifikasi/);
  await assert.rejects(accounts.code(discordId, true), /sudah terverifikasi/);
  assert.equal(writes, 0);
});

test('regeneration uses an atomic verified check and persistent database cooldown', async () => {
  const calls = [];
  const pool = { async execute(sql, values) {
    calls.push({ sql, values });
    if(sql.startsWith('SELECT')) return [[{ id: 9, verified: 0, kode: 123456 }]];
    return [{ affectedRows: 0 }];
  } };
  await assert.rejects(new Accounts(pool, { codeCooldown: 60 }).code(discordId, true), /Tunggu 60 detik/);
  assert.match(calls[1].sql, /verified = 0/);
  assert.match(calls[1].sql, /discord_code_updated_at <= DATE_SUB/);
  assert.equal(calls[1].values[2], 60);
  assert.notEqual(calls[1].values[0], 123456);
});

test('showing an existing code never changes it', async () => {
  let calls = 0;
  const pool = { async execute() { calls++; return [[{ id: 1, verified: 0, kode: 123456 }]]; } };
  assert.equal((await new Accounts(pool, {}).code(discordId)).kode, 123456);
  assert.equal(calls, 1);
});

test('successful regeneration returns the persisted code and never exposes passwords', async () => {
  let persisted;
  const pool = { async execute(sql, values) {
    if(sql.startsWith('SELECT')) return [[{ id: 5, verified: 0, kode: 123456 }]];
    persisted = values[0];
    return [{ affectedRows: 1 }];
  } };
  const result = await new Accounts(pool, { codeCooldown: 60 }).code(discordId, true);
  assert.equal(result.kode, persisted);
  assert.notEqual(result.kode, 123456);
  assert.equal(result.sandi, undefined);
});
