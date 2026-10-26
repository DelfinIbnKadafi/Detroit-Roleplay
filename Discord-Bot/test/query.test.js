const test = require('node:test');
const assert = require('node:assert/strict');
const dgram = require('node:dgram');
const { once } = require('node:events');
const { requestPacket, parseResponse, sendQuery, GameQuery } = require('../src/query');

function i32(value) { const result = Buffer.alloc(4); result.writeInt32LE(value); return result; }
function text(value) { const bytes = Buffer.from(value); return Buffer.concat([i32(bytes.length), bytes]); }
function infoPayload() { return Buffer.concat([Buffer.from([0, 2, 0, 50, 0]), text('Detroit'), text('DTRP 0.1.1'), text('Indonesia')]); }

test('query packet encodes IPv4 and little-endian port', () => {
  assert.equal(requestPacket('127.0.0.1', 7777, 'i').toString('hex'), '53414d507f000001611e69');
});

test('query parser reads actual server information and rejects truncated or oversized data', () => {
  const packet = Buffer.concat([requestPacket('127.0.0.1', 7777, 'i'), infoPayload()]);
  assert.deepEqual(parseResponse(packet, 'i'), { password: false, players: 2, maxPlayers: 50, name: 'Detroit', gamemode: 'DTRP 0.1.1', language: 'Indonesia' });
  assert.throws(() => parseResponse(packet.subarray(0, 20), 'i'));
  assert.throws(() => parseResponse(Buffer.concat([requestPacket('127.0.0.1', 7777, 'i'), Buffer.from([0, 0, 0, 0, 0]), i32(999999)]), 'i'));
});

test('query parser reads player names and signed scores', () => {
  const payload = Buffer.concat([Buffer.from([1, 0, 10]), Buffer.from('John_Smith'), i32(-1)]);
  assert.deepEqual(parseResponse(Buffer.concat([requestPacket('127.0.0.1', 7777, 'c'), payload]), 'c'), [{ name: 'John_Smith', score: -1 }]);
});

test('UDP integration uses a real local socket and coalesces repeated requests', async () => {
  const server = dgram.createSocket('udp4');
  server.bind(0, '127.0.0.1');
  await once(server, 'listening');
  let requests = 0;
  server.on('message', (message, remote) => {
    requests++;
    server.send(Buffer.concat([message, infoPayload()]), remote.port, remote.address);
  });
  try {
    const query = new GameQuery({ gameHost: '127.0.0.1', gamePort: server.address().port, queryTimeout: 1000 });
    const [one, two] = await Promise.all([query.get('i'), query.get('i')]);
    assert.equal(one.name, 'Detroit');
    assert.deepEqual(one, two);
    await query.get('i');
    assert.equal(requests, 1);
  } finally { server.close(); }
});

test('UDP request times out when no response arrives', async () => {
  const server = dgram.createSocket('udp4');
  server.bind(0, '127.0.0.1');
  await once(server, 'listening');
  try { await assert.rejects(sendQuery('127.0.0.1', server.address().port, 'i', 30), /timeout/i); } finally { server.close(); }
});
