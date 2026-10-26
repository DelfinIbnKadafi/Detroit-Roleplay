const test = require('node:test');
const assert = require('node:assert/strict');
const { MessageFlags, PermissionFlagsBits } = require('discord.js');
const { createHandler } = require('../src/handler');
const { Cooldowns, Locks } = require('../src/security');
const { commands } = require('../src/commands');
const views = require('../src/views');

function fixture(kind, id, overrides = {}) {
  const calls = [];
  const interaction = {
    guildId: '123456789012345678', channelId: '234567890123456789', user: { id: '345678901234567890' }, member: { roles: [] }, memberPermissions: { has: () => false },
    commandName: kind === 'command' ? id : undefined, customId: kind === 'command' ? undefined : id,
    isChatInputCommand: () => kind === 'command', isButton: () => kind === 'button', isModalSubmit: () => kind === 'modal',
    async deferReply(payload) { calls.push({ action: 'defer', payload }); this.deferred = true; },
    async reply(payload) { calls.push({ action: 'reply', payload }); this.replied = true; },
    async editReply(payload) { calls.push({ action: 'edit', payload }); },
    async showModal(payload) { calls.push({ action: 'modal', payload }); this.replied = true; },
    options: { getBoolean: () => false, getUser: () => ({ id: '456789012345678901' }) }, fields: { getTextInputValue: () => 'John_Smith' }, ...overrides
  };
  const auditCalls = [];
  const services = { config: { guildId: interaction.guildId, registerChannelId: interaction.channelId, adminRoleIds: [] }, cooldowns: new Cooldowns(), locks: new Locks(), audit: { async write(...args) { auditCalls.push(args); }, error() {} }, accounts: {}, tickets: {}, roles: {}, panels: {}, query: {}, client: {} };
  return { interaction, calls, services, auditCalls };
}

test('all slash-command and modal/button payloads serialize through Discord builders', () => {
  const data = commands().map(command => command.toJSON());
  assert.equal(data.length, new Set(data.map(command => command.name)).size);
  assert.equal(data.length, 15);
  assert.equal(data.find(command => command.name === 'setup').default_member_permissions, PermissionFlagsBits.ManageGuild.toString());
  for(const modal of [views.registerModal(), views.ticketModal(), views.announceModal('123456789012345678')]) assert.ok(modal.toJSON());
  for(const panel of [views.registerPanel(), views.ticketPanel()]) {
    panel.embeds.forEach(embed => embed.toJSON());
    panel.components.forEach(row => row.toJSON());
  }
});

test('non-admins cannot execute account lookup or spoof announcement modal submissions', async () => {
  for(const [kind, id] of [['command', 'account-info'], ['modal', 'announce:123456789012345678']]) {
    const f = fixture(kind, id);
    f.services.accounts.requireAccount = async () => { assert.fail('unauthorized account access'); };
    await createHandler(f.services)(f.interaction);
    assert.match(f.calls.at(-1).payload.content, /hanya dapat digunakan admin/);
  }
});

test('another guild cannot use the bot or access accounts', async () => {
  const f = fixture('command', 'akun');
  f.interaction.guildId = '999999999999999999';
  await createHandler(f.services)(f.interaction);
  assert.match(f.calls[0].payload.content, /server Discord yang dikonfigurasi/);
});

test('registration enforces the configured channel even for forged modal submissions', async () => {
  const f = fixture('modal', 'register:submit');
  f.interaction.channelId = '999999999999999999';
  f.services.accounts.register = async () => { assert.fail('wrong channel must not register'); };
  await createHandler(f.services)(f.interaction);
  assert.match(f.calls.at(-1).payload.content, /Gunakan registrasi/);
});

test('registration code is private and never included in audit logs', async () => {
  const f = fixture('modal', 'register:submit');
  f.services.accounts.register = async (userId, name) => {
    assert.equal(userId, f.interaction.user.id);
    assert.equal(name, 'John_Smith');
    return { nama: name, kode: 123456 };
  };
  await createHandler(f.services)(f.interaction);
  assert.equal(f.calls[0].payload.flags, MessageFlags.Ephemeral);
  assert.match(f.calls.at(-1).payload.embeds[0].toJSON().description, /123456/);
  assert.doesNotMatch(JSON.stringify(f.auditCalls), /123456(?!789)/);
});

test('self account requests always use the interacting user', async () => {
  const f = fixture('command', 'akun');
  f.services.accounts.requireAccount = async userId => {
    assert.equal(userId, f.interaction.user.id);
    return { id: 1, nama: 'John_Smith', verified: 1 };
  };
  await createHandler(f.services)(f.interaction);
  assert.equal(f.calls[0].payload.flags, MessageFlags.Ephemeral);
  assert.equal(f.calls.at(-1).payload.embeds[0].toJSON().title, 'Profil Akun');
});

test('ticket close confirmation is bound to both user and channel', async () => {
  const f = fixture('button', 'ticket:confirm:234567890123456789:999999999999999999');
  f.services.tickets.getClosable = async () => { assert.fail('forged confirmation'); };
  await createHandler(f.services)(f.interaction);
  assert.match(f.calls.at(-1).payload.content, /bukan milikmu/);
});
