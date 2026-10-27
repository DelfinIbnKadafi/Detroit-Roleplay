require('dotenv').config({ path: require('node:path').join(__dirname, '../.env') });
const { REST, Routes } = require('discord.js');

const token = process.env.TOKEN;
if (!token) {
    console.error('ERROR: TOKEN tidak ditemukan di file .env');
    process.exit(1);
}

let clientId = process.env.CLIENT_ID;
if (!clientId) {
    try {
        clientId = Buffer.from(token.split('.')[0], 'base64').toString('utf8');
    } catch {
        console.error('ERROR: Gagal membaca CLIENT_ID dari token. Harap isi CLIENT_ID di .env');
        process.exit(1);
    }
}

if (!/^\d{17,20}$/.test(clientId) || (process.env.GUILD_ID && !/^\d{17,20}$/.test(process.env.GUILD_ID))) {
    console.error('ERROR: CLIENT_ID atau GUILD_ID tidak valid. Harap periksa ID di .env');
    process.exit(1);
}

const rest = new REST().setToken(token);
const commandScopes = [
    { name: 'Global', route: Routes.applicationCommands(clientId) }
];

if (process.env.GUILD_ID) {
    commandScopes.push({
        name: `Guild ${process.env.GUILD_ID}`,
        route: Routes.applicationGuildCommands(clientId, process.env.GUILD_ID)
    });
}

(async () => {
    let failed = false;

    for (const scope of commandScopes) {
        try {
            await rest.put(scope.route, { body: [] });
            console.log(`Berhasil menghapus seluruh slash command ${scope.name}.`);
        } catch (error) {
            failed = true;
            console.error(`Gagal menghapus slash command ${scope.name}:`, error);
        }
    }

    if (failed) process.exitCode = 1;
})();
