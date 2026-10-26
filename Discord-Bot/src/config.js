const path = require('node:path');
const { UserError } = require('./errors');

function parseConfig(env) {
  function value(key) { return (env[key] || '').trim(); }
  function required(key) {
    const result = value(key);
    if(!result) throw new UserError(`Konfigurasi ${key} belum diisi.`);
    return result;
  }
  function id(key, optional = false) {
    const result = optional ? value(key) : required(key);
    if(result && !/^\d{17,20}$/.test(result)) throw new UserError(`${key} harus berupa ID Discord 17–20 digit.`);
    return result;
  }
  function integer(key, fallback, min, max) {
    const raw = value(key);
    if(raw && !/^\d+$/.test(raw)) throw new UserError(`${key} harus berupa bilangan bulat.`);
    const result = raw ? Number(raw) : fallback;
    if(!Number.isInteger(result) || result < min || result > max) throw new UserError(`${key} harus berada antara ${min} dan ${max}.`);
    return result;
  }
  const memberEvents = value('ENABLE_MEMBER_EVENTS') || 'false';
  if(!['true', 'false'].includes(memberEvents)) throw new UserError('ENABLE_MEMBER_EVENTS harus true atau false.');
  const config = {
    token: required('DISCORD_BOT_TOKEN'),
    clientId: id('CLIENT_ID'),
    guildId: id('GUILD_ID'),
    registerChannelId: id('CHANNEL_REGISTER_ID'),
    verifiedRoleId: id('ROLE_VERIFIED'),
    logChannelId: id('CHANNEL_LOG_ID', true),
    welcomeChannelId: id('CHANNEL_WELCOME_ID', true),
    ticketCategoryId: id('TICKET_CATEGORY_ID', true),
    ticketStaffRoleId: id('TICKET_STAFF_ROLE_ID', true),
    adminRoleIds: value('ADMIN_ROLE_IDS') ? value('ADMIN_ROLE_IDS').split(',').map(item => item.trim()) : [],
    memberEvents: memberEvents === 'true',
    gameHost: value('GAME_HOST'),
    gamePort: integer('GAME_PORT', 7777, 1, 65535),
    queryTimeout: integer('QUERY_TIMEOUT_MS', 3000, 250, 10000),
    roleSyncSeconds: integer('ROLE_SYNC_SECONDS', 60, 30, 3600),
    statusUpdateSeconds: integer('STATUS_UPDATE_SECONDS', 60, 30, 3600),
    codeCooldown: integer('CODE_COOLDOWN_SECONDS', 60, 30, 3600),
    database: { host: required('HOST_DB'), user: required('USERNAME_DB'), password: env.PASSWORD_DB || '', database: required('DATABASE_NAME'), port: integer('PORT_DB', 3306, 1, 65535) }
  };
  if(config.adminRoleIds.some(item => !/^\d{17,20}$/.test(item))) throw new UserError('ADMIN_ROLE_IDS berisi ID yang tidak valid.');
  if(Boolean(config.ticketCategoryId) !== Boolean(config.ticketStaffRoleId)) throw new UserError('TICKET_CATEGORY_ID dan TICKET_STAFF_ROLE_ID harus diisi bersamaan.');
  if(config.gameHost && !/^[a-zA-Z0-9.-]{1,253}$/.test(config.gameHost)) throw new UserError('GAME_HOST harus hostname atau IPv4 tanpa protokol maupun port.');
  return config;
}

function loadConfig() {
  require('dotenv').config({ path: path.join(__dirname, '..', '.env'), quiet: true });
  return parseConfig(process.env);
}

module.exports = { parseConfig, loadConfig };
