const { REST, Routes } = require('discord.js');
const { loadConfig } = require('../src/config');
const { commands } = require('../src/commands');

async function main() {
  try {
    const config = loadConfig();
    const body = commands().map(command => command.toJSON());
    await new REST({ version: '10' }).setToken(config.token).put(Routes.applicationGuildCommands(config.clientId, config.guildId), { body });
    console.log(`${body.length} command berhasil didaftarkan untuk server yang dikonfigurasi.`);
  } catch(error) {
    console.error(`Pendaftaran command gagal (${error.code || 'CONFIG'}). Periksa token, Application ID, Guild ID, dan izin instalasi bot.`);
    process.exitCode = 1;
  }
}

main();
