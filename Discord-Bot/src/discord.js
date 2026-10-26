const { PermissionFlagsBits, ChannelType } = require('discord.js');
const { UserError } = require('./errors');
const { embed } = require('./views');

function hasRole(member, roleId) {
  return member?.roles?.cache ? member.roles.cache.has(roleId) : Boolean(member?.roles?.includes(roleId));
}

function isAdmin(interaction, config) {
  return Boolean(interaction.memberPermissions?.has(PermissionFlagsBits.ManageGuild) || config.adminRoleIds.some(id => hasRole(interaction.member, id)));
}

function requireAdmin(interaction, config) {
  if(!isAdmin(interaction, config)) throw new UserError('Command ini hanya dapat digunakan admin bot.');
}

async function textChannel(client, config, channelId, extra = []) {
  const channel = await client.channels.fetch(channelId);
  if(!channel || channel.guildId !== config.guildId || channel.type !== ChannelType.GuildText) throw new UserError('Channel harus berupa channel teks di server Discord yang dikonfigurasi.');
  const me = await channel.guild.members.fetchMe();
  const needed = [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.EmbedLinks, ...extra];
  if(!channel.permissionsFor(me)?.has(needed)) throw new UserError('Bot belum memiliki izin melihat channel, mengirim pesan, embed, atau izin tambahan yang dibutuhkan.');
  return channel;
}

class Audit {
  constructor(client, config) { this.client = client; this.config = config; }
  async write(title, description) {
    console.log(`[ACTIVITY] ${title}`);
    if(!this.config.logChannelId) return;
    try {
      const channel = await textChannel(this.client, this.config, this.config.logChannelId);
      await channel.send({ embeds: [embed(title, description.slice(0, 3900))], allowedMentions: { parse: [] } });
    } catch(error) { console.error(`[LOG] Pengiriman log gagal (${error.code || 'PERMISSION'}).`); }
  }
  error(scope, error) {
    // Jangan log query, bind parameters, token, kode verifikasi, atau detail koneksi.
    console.error(`[${scope}] Operasi gagal (${error.code || error.name || 'UNKNOWN'}).`);
  }
}

class RoleSync {
  constructor(client, config, accounts, audit) { this.client = client; this.config = config; this.accounts = accounts; this.audit = audit; this.seen = new Map(); this.running = false; }
  async sync(discordId) {
    const account = await this.accounts.requireAccount(discordId);
    const guild = await this.client.guilds.fetch(this.config.guildId);
    const me = await guild.members.fetchMe();
    const role = await guild.roles.fetch(this.config.verifiedRoleId);
    if(!role || role.id === guild.id || role.managed || !me.permissions.has(PermissionFlagsBits.ManageRoles) || me.roles.highest.comparePositionTo(role) <= 0) throw new UserError('Role verified belum dapat dikelola bot. Periksa Manage Roles dan posisi role bot.');
    let member;
    try { member = await guild.members.fetch({ user: discordId, force: true }); } catch(error) { if(error.code === 10007) return false; throw error; }
    const has = member.roles.cache.has(role.id);
    if(account.verified && !has) {
      await member.roles.add(role, 'Akun Detroit Roleplay selesai diverifikasi di dalam game.');
      await this.audit.write('Role verified diberikan', `Discord ID: ${discordId}`);
    } else if(!account.verified && has) {
      await member.roles.remove(role, 'Akun belum terverifikasi di dalam game.');
    }
    this.seen.set(discordId, { verified: Boolean(account.verified), checked: Date.now() });
    return Boolean(account.verified);
  }
  async run() {
    if(this.running) return;
    this.running = true;
    try {
      let after = 0;
      while(true) {
        const accounts = await this.accounts.verifiedAccounts(after);
        if(!accounts.length) break;
        for(const account of accounts) {
          const seen = this.seen.get(account.discordid);
          if(seen && seen.verified === Boolean(account.verified) && Date.now() - seen.checked < 6 * 3600000) continue;
          try {
            await this.sync(account.discordid);
            if(!this.seen.has(account.discordid)) this.seen.set(account.discordid, { verified: Boolean(account.verified), checked: Date.now() });
          } catch(error) { this.audit.error('ROLE_SYNC', error); }
        }
        after = accounts.at(-1).id;
        if(accounts.length < 100) break;
      }
    } catch(error) { this.audit.error('ROLE_SYNC', error); } finally { this.running = false; }
  }
}

module.exports = { hasRole, isAdmin, requireAdmin, textChannel, Audit, RoleSync };
