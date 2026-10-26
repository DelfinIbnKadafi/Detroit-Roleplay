const test = require('node:test');
const assert = require('node:assert/strict');
const { migrate } = require('../scripts/migrate');

function fixture(options = {}) {
  const calls = [];
  let released = false;
  const connection = { async execute(sql) {
    calls.push(sql);
    if(sql.includes('GET_LOCK')) return [[{ acquired: 1 }]];
    if(sql.startsWith('SHOW COLUMNS')) return [['id', 'discordid', 'nama', 'verified', 'kode'].map(Field => ({ Field }))];
    if(sql.includes('GROUP BY discordid')) return [options.duplicate ? [{ discordid: '1' }] : []];
    if(sql.includes('NOT REGEXP')) return [options.invalid ? [{ id: 1 }] : []];
    if(sql.includes('GROUP BY nama')) return [[]];
    if(sql.includes('information_schema.tables')) return [[{ total: '0' }]];
    if(sql.startsWith('SHOW INDEX')) return [[{ Non_unique: 0, Column_name: 'nama', Key_name: 'uq_name' }]];
    return [{ affectedRows: 1 }];
  }, release() { released = true; } };
  return { pool: { async getConnection() { return connection; } }, calls, released: () => released };
}

test('migration refuses duplicate owners before altering or deleting any data', async () => {
  const f = fixture({ duplicate: true });
  await assert.rejects(migrate(f.pool), /discordid ganda/);
  assert.ok(f.calls.every(sql => !/^(ALTER|DELETE|UPDATE|INSERT|CREATE)/.test(sql)));
  assert.ok(f.released());
  assert.ok(f.calls.some(sql => sql.includes('RELEASE_LOCK')));
});

test('migration refuses truncated INT Discord IDs without inventing replacements', async () => {
  const f = fixture({ invalid: true });
  await assert.rejects(migrate(f.pool), /tidak dapat dipulihkan/);
  assert.ok(f.calls.every(sql => !/^(ALTER|DELETE|UPDATE|INSERT|CREATE)/.test(sql)));
});

test('fresh migration handles MySQL bigint COUNT returned as string zero', async () => {
  const f = fixture();
  await migrate(f.pool);
  assert.ok(!f.calls.some(sql => sql === 'SELECT version FROM discord_bot_schema WHERE id = 1'));
  assert.ok(f.calls.some(sql => sql.includes('MODIFY discordid VARCHAR(20)')));
  assert.ok(f.calls.some(sql => sql.includes('UNIQUE KEY uq_pemain_discordid')));
  assert.ok(f.calls.some(sql => sql.includes('INSERT INTO discord_bot_schema')));
  assert.ok(!f.calls.some(sql => /^(DROP|DELETE|TRUNCATE)/.test(sql)));
});
