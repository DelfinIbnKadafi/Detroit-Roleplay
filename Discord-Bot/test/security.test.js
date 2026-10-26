const test = require('node:test');
const assert = require('node:assert/strict');
const { validateName, Cooldowns, Locks, safeText } = require('../src/security');
const { parseConfig } = require('../src/config');

function env() {
  return { DISCORD_BOT_TOKEN: 'test-token', CLIENT_ID: '123456789012345678', GUILD_ID: '234567890123456789', CHANNEL_REGISTER_ID: '345678901234567890', ROLE_VERIFIED: '456789012345678901', HOST_DB: 'localhost', USERNAME_DB: 'test', DATABASE_NAME: 'test' };
}

test('character names cannot contain SQL, Discord mentions, digits, or exceed SA-MP limits', () => {
  assert.equal(validateName(' John_Smith '), 'John_Smith');
  assert.equal(validateName('John_Van_Smith'), 'John_Van_Smith');
  for(const name of ['john_smith', 'John', "John_Smith' OR 1=1", '@everyone', 'John_123', 'J_S', 'A'.repeat(25), 'John__Smith']) assert.throws(() => validateName(name));
});

test('cooldowns expire and do not affect a different user', () => {
  let now = 1000;
  const cooldowns = new Cooldowns(() => now);
  cooldowns.take('a', 10);
  assert.throws(() => cooldowns.take('a', 10), /10 detik/);
  cooldowns.take('b', 10);
  now += 10000;
  cooldowns.take('a', 10);
});

test('locks stop overlapping mutations and are released after a failed task', async () => {
  const locks = new Locks();
  let release;
  const task = locks.run('account', () => new Promise(resolve => { release = resolve; }));
  await assert.rejects(locks.run('account', async () => {}), /masih diproses/);
  release();
  await task;
  await assert.rejects(locks.run('account', async () => { throw new Error('fail'); }), /fail/);
  assert.equal(await locks.run('account', async () => 42), 42);
});

test('configuration preserves IDs as strings and rejects invalid numeric settings', () => {
  const config = parseConfig(env());
  assert.equal(config.guildId, '234567890123456789');
  assert.equal(typeof config.guildId, 'string');
  assert.equal(config.database.port, 3306);
  for(const patch of [{ GUILD_ID: '123' }, { PORT_DB: '3306abc' }, { ROLE_SYNC_SECONDS: '0' }, { ENABLE_MEMBER_EVENTS: 'yes' }, { TICKET_CATEGORY_ID: '567890123456789012' }, { GAME_HOST: 'https://server.com' }]) assert.throws(() => parseConfig({ ...env(), ...patch }));
});

test('untrusted displayed text cannot create mentions or markdown links', () => {
  assert.equal(safeText('@everyone'), '@\u200beveryone');
  assert.match(safeText('[click](https://example.com)'), /\\\[/);
});
