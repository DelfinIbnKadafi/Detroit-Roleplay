require('dotenv').config();
const { REST, Routes } = require('discord.js');
const fs = require('node:fs');
const path = require('node:path');

const commands = [];
const commandsPath = path.join(__dirname, 'commands');

if (!fs.existsSync(commandsPath)) {
    console.error(`Folder commands tidak ditemukan di: ${commandsPath}`);
    process.exit(1);
}

const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js'));

for (const file of commandFiles) {
    const filePath = path.join(commandsPath, file);
    const command = require(filePath);

    if (command.data && typeof command.data.toJSON === 'function') {
        commands.push(command.data.toJSON());
    } else {
        console.warn(`[WARNING] Command di ${file} tidak memiliki property "data" yang valid.`);
    }
}

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

const rest = new REST().setToken(token);

(async () => {
    try {
        console.log(`Memulai pendaftaran ${commands.length} slash command...`);

        if (process.env.GUILD_ID) {
            const data = await rest.put(
                Routes.applicationGuildCommands(clientId, process.env.GUILD_ID),
                { body: commands }
            );
            console.log(`Berhasil mendaftarkan ${data.length} command ke Guild (Server ID: ${process.env.GUILD_ID})!`);
        } else {
            const data = await rest.put(
                Routes.applicationCommands(clientId),
                { body: commands }
            );
            console.log(`Berhasil mendaftarkan ${data.length} command secara Global!`);
            console.log('(Catatan: Command global kadang butuh waktu beberapa menit s/d 1 jam agar muncul di semua server)');
        }
    } catch (error) {
        console.error('Terjadi error saat mendaftarkan command:', error);
    }
})();
