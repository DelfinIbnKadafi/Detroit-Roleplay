const fs = require('node:fs');
const path = require('node:path');

module.exports = (client) => {
    const buttonsPath = path.join(__dirname, '../buttons');

    if (!fs.existsSync(buttonsPath)) {
        fs.mkdirSync(buttonsPath, { recursive: true });
    }

    const files = fs.readdirSync(buttonsPath).filter(file => file.endsWith('.js'));

    for (const file of files) {
        const filePath = path.join(buttonsPath, file);
        const button = require(filePath);

        const customId = button.customId || button.id;
        if (!customId || typeof button.run !== 'function') {
            console.warn(`Button handler tidak valid: ${file}`);
            continue;
        }

        client.buttons.set(customId, button);
        console.log(`Button loaded: ${customId}`);
    }

    console.log("Buttons Loaded!");
};
