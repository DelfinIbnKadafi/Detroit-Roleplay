const { Client, GatewayIntentBits, Events } = require('discord.js');
const { loadConfig } = require('./config');
const { createDatabase, assertSchema } = require('./database');
const { Accounts } = require('./accounts');
const { Meta } = require('./meta');
const { GameQuery } = require('./query');
const { Cooldowns, Locks } = require('./security');
const { Audit, RoleSync, textChannel } = require('./discord');
const { Panels } = require('./panels');
const { Tickets } = require('./tickets');
const { createHandler } = require('./handler');

async function main() {
  let client;
  let pool;
  const timers = [];
  let stopping = false;
  async function stop(exitCode = 0) {
    if(stopping) return;
    stopping = true;
    timers.forEach(timer => clearInterval(timer));
    const deadline = setTimeout(() => process.exit(exitCode || 1), 10000);
    deadline.unref();
    if(client) await client.destroy().catch(() => {});
    if(pool) await pool.end().catch(() => {});
    clearTimeout(deadline);
    process.exitCode = exitCode;
  }
  try {
    const config = loadConfig();
    pool = createDatabase(config);
    await pool.execute('SELECT 1');
    await assertSchema(pool);
    const intents = [GatewayIntentBits.Guilds];
    if(config.memberEvents) intents.push(GatewayIntentBits.GuildMembers);
    client = new Client({ intents, allowedMentions: { parse: [] } });
    const audit = new Audit(client, config);
    const accounts = new Accounts(pool, config);
    const meta = new Meta(pool);
    const query = new GameQuery(config);
    const cooldowns = new Cooldowns();
    const locks = new Locks();
    const roles = new RoleSync(client, config, accounts, audit);
    const panels = new Panels(client, config, meta, query, audit);
    const tickets = new Tickets(client, config, pool, audit);
    client.on(Events.InteractionCreate, createHandler({ config, accounts, roles, panels, tickets, query, audit, cooldowns, locks, client }));
    client.on(Events.Error, error => audit.error('DISCORD', error));
    client.once(Events.ClientReady, async ready => {
      try {
        await ready.guilds.fetch(config.guildId);
        await textChannel(client, config, config.registerChannelId);
        await tickets.recover();
        console.log(`Bot aktif sebagai ${ready.user.tag}. Gunakan /setup untuk memasang panel.`);
        void roles.run();
        void panels.refreshStatus();
        timers.push(setInterval(() => { void roles.run(); }, config.roleSyncSeconds * 1000));
        timers.push(setInterval(() => { void panels.refreshStatus(); }, config.statusUpdateSeconds * 1000));
      } catch(error) {
        audit.error('READY', error);
        await stop(1);
      }
    });
    client.on(Events.GuildMemberAdd, async member => {
      if(member.guild.id !== config.guildId || member.user.bot) return;
      try {
        roles.seen.delete(member.id);
        const account = await accounts.byDiscord(member.id);
        if(account) await roles.sync(member.id);
        if(config.welcomeChannelId) {
          const channel = await textChannel(client, config, config.welcomeChannelId);
          await channel.send({ content: `Selamat datang <@${member.id}> di Detroit Roleplay! Daftar atau periksa akunmu di <#${config.registerChannelId}>.`, allowedMentions: { users: [member.id], parse: [] } });
        }
      } catch(error) { audit.error('MEMBER_JOIN', error); }
    });
    process.once('SIGINT', () => { void stop(); });
    process.once('SIGTERM', () => { void stop(); });
    process.on('unhandledRejection', error => { audit.error('UNHANDLED', error || {}); void stop(1); });
    await client.login(config.token);
  } catch(error) {
    console.error(`[STARTUP] Bot gagal dijalankan (${error.code || error.name}). Periksa .env, koneksi MySQL, migrasi, dan konfigurasi Discord.`);
    if(error.name === 'UserError') console.error(error.message);
    await stop(1);
  }
}

if(require.main === module) main();
module.exports = { main };
