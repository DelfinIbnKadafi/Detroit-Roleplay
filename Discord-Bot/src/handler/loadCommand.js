const fs = require('node:fs');
const path = require('node:path');

module.exports = (client) => {
    const commandsPath = path.join(__dirname, '../commands');

    const files = fs.readdirSync(commandsPath)
        .filter(file => file.endsWith('.js'));

    for (const file of files) {
        const filePath = path.join(commandsPath, file);
        const command = require(filePath);

        if (!command.data || typeof command.run !== 'function') {
            console.warn(`Command tidak valid: ${file}`);
            continue;
        }

        client.commands.set(command.data.name, command);

        console.log(`Command loaded: ${command.data.name}`);
    }

    console.log("Commands Loaded!");
};