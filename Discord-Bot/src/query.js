const dgram = require('node:dgram');
const dns = require('node:dns').promises;
const { UserError } = require('./errors');

function requestPacket(address, port, opcode) {
  const packet = Buffer.alloc(11);
  packet.write('SAMP');
  address.split('.').forEach((part, index) => { packet[4 + index] = Number(part); });
  packet.writeUInt16LE(port, 8);
  packet.write(opcode, 10);
  return packet;
}

function parseResponse(buffer, opcode) {
  let offset = 11;
  function need(bytes) { if(offset + bytes > buffer.length) throw new Error('Paket query server tidak lengkap.'); }
  function u8() { need(1); return buffer.readUInt8(offset++); }
  function u16() { need(2); const value = buffer.readUInt16LE(offset); offset += 2; return value; }
  function i32() { need(4); const value = buffer.readInt32LE(offset); offset += 4; return value; }
  function text(length) { if(length < 0 || length > 4096) throw new Error('Panjang data query tidak valid.'); need(length); const value = buffer.toString('utf8', offset, offset + length); offset += length; return value; }
  if(buffer.length < 11 || buffer.toString('ascii', 0, 4) !== 'SAMP' || buffer.toString('ascii', 10, 11) !== opcode) throw new Error('Header query tidak valid.');
  if(opcode === 'i') return { password: Boolean(u8()), players: u16(), maxPlayers: u16(), name: text(i32()), gamemode: text(i32()), language: text(i32()) };
  if(opcode === 'c') {
    const count = u16();
    if(count > 1000) throw new Error('Jumlah pemain query tidak valid.');
    return Array.from({ length: count }, () => ({ name: text(u8()), score: i32() }));
  }
  throw new Error('Opcode tidak didukung.');
}

async function sendQuery(host, port, opcode, timeout) {
  let dnsTimer;
  const lookup = dns.lookup(host, { family: 4 });
  const resolutionTimeout = new Promise((_, reject) => { dnsTimer = setTimeout(() => reject(new Error('DNS query timeout.')), timeout); });
  const { address } = await Promise.race([lookup, resolutionTimeout]).finally(() => clearTimeout(dnsTimer));
  const packet = requestPacket(address, port, opcode);
  return new Promise((resolve, reject) => {
    const socket = dgram.createSocket('udp4');
    let finished = false;
    const timer = setTimeout(() => finish(new Error('Query timeout.')), timeout);
    function finish(error, data) {
      if(finished) return;
      finished = true;
      clearTimeout(timer);
      try { socket.close(); } catch {}
      if(error) reject(error); else resolve(data);
    }
    socket.once('error', error => finish(error));
    socket.on('message', (data, remote) => {
      if(remote.address !== address || remote.port !== port || !data.subarray(0, 11).equals(packet)) return;
      try { finish(null, parseResponse(data, opcode)); } catch(error) { finish(error); }
    });
    socket.send(packet, port, address, error => { if(error) finish(error); });
  });
}

class GameQuery {
  constructor(config) { this.config = config; this.cache = new Map(); this.pending = new Map(); }
  async get(opcode = 'i') {
    if(!this.config.gameHost) throw new UserError('Status game belum dikonfigurasi oleh administrator.');
    const cached = this.cache.get(opcode);
    if(cached && cached.expires > Date.now()) return cached.value;
    if(this.pending.has(opcode)) return this.pending.get(opcode);
    const task = sendQuery(this.config.gameHost, this.config.gamePort, opcode, this.config.queryTimeout).then(value => {
      this.cache.set(opcode, { value, expires: Date.now() + 15000 });
      return value;
    }).finally(() => this.pending.delete(opcode));
    this.pending.set(opcode, task);
    return task;
  }
}

module.exports = { requestPacket, parseResponse, sendQuery, GameQuery };
