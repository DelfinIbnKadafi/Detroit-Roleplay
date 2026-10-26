const fs = require('node:fs');
const path = require('node:path');

module.exports = (client) => {
    const modalsPath = path.join(__dirname, '../modals');

    if (!fs.existsSync(modalsPath)) {
        fs.mkdirSync(modalsPath, { recursive: true });
    }

    const files = fs.readdirSync(modalsPath).filter(file => file.endsWith('.js'));

    for (const file of files) {
        const filePath = path.join(modalsPath, file);
        const modal = require(filePath);

        const customId = modal.customId || modal.id;
        if (!customId || typeof modal.run !== 'function') {
            console.warn(`Modal handler tidak valid: ${file}`);
            continue;
        }

        client.modals.set(customId, modal);
        console.log(`Modal loaded: ${customId}`);
    }

    console.log("Modals Loaded!");
};
