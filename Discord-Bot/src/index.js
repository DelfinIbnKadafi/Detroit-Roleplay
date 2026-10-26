console.log("Starting BOT...");

require('dotenv').config()
const { Client, Collection, GatewayIntentBits, MessageFlags } = require("discord.js");
const mysql = require("./mysql");
const loadCommand = require('./handler/loadCommand');
const loadButton = require('./handler/loadButton');
const loadModal = require('./handler/loadModal');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages
    ]
});

client.commands = new Collection();
client.buttons = new Collection();
client.modals = new Collection();

client.on("clientReady", () => {
    console.log(`Logged in as ${client.user.tag}!`);
    loadCommand(client);
    loadButton(client);
    loadModal(client);
});

client.on("interactionCreate", async (interaction) => {
    try {
        if (interaction.isChatInputCommand()) {
            const command = client.commands.get(interaction.commandName);
            if (!command) return;
            await command.run(client, interaction);
        } else if (interaction.isButton()) {
            const button = client.buttons.get(interaction.customId);
            if (!button) return;
            await button.run(client, interaction);
        } else if (interaction.isModalSubmit()) {
            const modal = client.modals.get(interaction.customId);
            if (!modal) return;
            await modal.run(client, interaction);
        }
    } catch (error) {
        console.error("Interaction error:", error);
        try {
            if (interaction.replied || interaction.deferred) {
                await interaction.followUp({ content: "Terjadi error saat memproses interaksi!", flags: MessageFlags.Ephemeral });
            } else {
                await interaction.reply({ content: "Terjadi error saat memproses interaksi!", flags: MessageFlags.Ephemeral });
            }
        } catch (err) {
            console.error("Gagal mengirim error response:", err.message);
        }
    }
});

client.login(process.env.TOKEN);