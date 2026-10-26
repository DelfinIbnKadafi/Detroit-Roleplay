const test = require('node:test');
const assert = require('node:assert/strict');
const { PermissionFlagsBits, ChannelType } = require('discord.js');
const { RoleSync } = require('../src/discord');
const { Tickets } = require('../src/tickets');

const config = { guildId: '123456789012345678', verifiedRoleId: '234567890123456789', ticketStaffRoleId: '345678901234567890', ticketCategoryId: '456789012345678901', adminRoleIds: [] };

test('role sync adds verified role only after the game verifies the account', async () => {
  const added = [];
  const removed = [];
  let verified = 0;
  let has = false;
  const role = { id: config.verifiedRoleId };
  const member = { roles: { cache: { has: () => has }, async add(value) { added.push(value.id); has = true; }, async remove(value) { removed.push(value.id); has = false; } } };
  const guild = { id: config.guildId, roles: { async fetch() { return role; } }, members: { async fetchMe() { return { permissions: { has: () => true }, roles: { highest: { comparePositionTo: () => 1 } } }; }, async fetch() { return member; } } };
  const sync = new RoleSync({ guilds: { async fetch() { return guild; } } }, config, { async requireAccount() { return { verified }; } }, { async write() {} });
  assert.equal(await sync.sync('567890123456789012'), false);
  assert.deepEqual(added, []);
  verified = 1;
  assert.equal(await sync.sync('567890123456789012'), true);
  assert.deepEqual(added, [config.verifiedRoleId]);
  await sync.sync('567890123456789012');
  assert.equal(added.length, 1);
  verified = 0;
  await sync.sync('567890123456789012');
  assert.deepEqual(removed, [config.verifiedRoleId]);
});

test('ticket closure rejects members who are neither owner nor staff', async () => {
  const tickets = new Tickets({}, config, { async execute() { return [[{ owner_id: '567890123456789012', channel_id: '678901234567890123', status: 'open' }]]; } }, {});
  const interaction = { user: { id: '789012345678901234' }, channelId: '678901234567890123', member: { roles: [] }, memberPermissions: { has: () => false } };
  await assert.rejects(tickets.getClosable(interaction), /Hanya pemilik tiket atau staf/);
  interaction.member.roles = [config.ticketStaffRoleId];
  assert.ok(await tickets.getClosable(interaction));
});

test('opening a ticket hides the channel from everyone and reserves a single owner first', async () => {
  const sequence = [];
  let options;
  const guild = { id: config.guildId,
    channels: { async fetch() { return { type: ChannelType.GuildCategory, id: config.ticketCategoryId }; }, async create(value) { sequence.push('create'); options = value; return { id: '678901234567890123', async send() {} }; } },
    roles: { async fetch() { return { id: config.ticketStaffRoleId }; } },
    members: { async fetchMe() { return { id: '890123456789012345', permissions: { has: () => true } }; } }
  };
  const pool = { async execute(sql) { sequence.push(sql.startsWith('INSERT') ? 'reserve' : 'update'); return [{ affectedRows: 1 }]; } };
  const tickets = new Tickets({ guilds: { async fetch() { return guild; } } }, config, pool, { async write() {} });
  await tickets.open({ id: '567890123456789012' }, 'Help', 'My problem');
  assert.deepEqual(sequence, ['reserve', 'create', 'update']);
  assert.ok(options.permissionOverwrites.find(item => item.id === config.guildId).deny.includes(PermissionFlagsBits.ViewChannel));
  assert.ok(options.permissionOverwrites.find(item => item.id === '567890123456789012').allow.includes(PermissionFlagsBits.ViewChannel));
  assert.ok(!options.permissionOverwrites.some(item => item.id === config.verifiedRoleId));
});

test('failed Discord channel deletion leaves the active ticket recoverable', async () => {
  const sqlCalls = [];
  const pool = { async execute(sql) { sqlCalls.push(sql); if(sql.startsWith('SELECT')) return [[{ owner_id: '567890123456789012', channel_id: '678901234567890123', status: 'open' }]]; return [{ affectedRows: 1 }]; } };
  const channel = { guildId: config.guildId, type: ChannelType.GuildText, guild: { members: { async fetchMe() { return {}; } } }, permissionsFor() { return { has: () => true }; }, async delete() { throw Object.assign(new Error('missing permissions'), { code: 50013 }); } };
  const tickets = new Tickets({ channels: { async fetch() { return channel; } } }, config, pool, {});
  await assert.rejects(tickets.close({ user: { id: '567890123456789012' }, channelId: '678901234567890123' }), /missing permissions/);
  assert.ok(sqlCalls.some(sql => sql.includes("SET status = 'open'")));
  assert.ok(!sqlCalls.some(sql => sql.startsWith('DELETE')));
});
