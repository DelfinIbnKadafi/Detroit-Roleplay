console.log("Starting BOT...");

require('dotenv').config({ path: require('node:path').join(__dirname, '../.env') });
const { Client, Collection, GatewayIntentBits, MessageFlags, ActivityType } = require("discord.js");
const mysql = require("./mysql");
const loadCommand = require('./handler/loadCommand');
const loadButton = require('./handler/loadButton');
const loadModal = require('./handler/loadModal');
const { querySAMP } = require("./query");

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages
    ]
});

client.commands = new Collection();
client.buttons = new Collection();
client.modals = new Collection();

let presenceInterval = null;

async function updateServerPresence() {
    const host = process.env.SAMP_HOST || "127.0.0.1";
    const port = parseInt(process.env.SAMP_PORT, 10) || 7777;

    try {
        const server = await querySAMP(host, port);
        const activityText = server.online
            ? `DETROIT ROLEPLAY | ${server.players}/${server.maxPlayers} Online!`
            : `DETROIT ROLEPLAY | Server Offline`;

        if (client.user && typeof client.user.setActivity === "function") {
            client.user.setActivity(activityText, { type: ActivityType.Playing });
        }
    } catch (err) {
        // Abaikan error saat refresh presence agar background loop tetap berjalan
    }
}

client.once("clientReady", () => {
    console.log(`Logged in as ${client.user.tag}!`);
    updateServerPresence();
    if (presenceInterval) clearInterval(presenceInterval);
    presenceInterval = setInterval(updateServerPresence, 30000);
});

client.on("error", (error) => {
    console.error("Client error:", error);
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
        if (error.code === 10062) {
            console.warn("[DTRP-BOT] Interaksi kedaluwarsa (> 3 detik) atau tidak valid di Discord API (Unknown Interaction).");
            return;
        }
        console.error("Interaction error:", error);
        try {
            if (interaction.deferred && !interaction.replied) {
                await interaction.editReply({ content: "Terjadi error saat memproses interaksi!" });
            } else if (interaction.replied) {
                await interaction.followUp({ content: "Terjadi error saat memproses interaksi!", flags: MessageFlags.Ephemeral });
            } else {
                await interaction.reply({ content: "Terjadi error saat memproses interaksi!", flags: MessageFlags.Ephemeral });
            }
        } catch (err) {
            console.error("Gagal mengirim error response:", err.message);
        }
    }
});

async function startBot() {
    if (!process.env.TOKEN) throw new Error("ERROR: TOKEN tidak ditemukan di file .env");

    try {
        await mysql.query("SELECT 1");
    } catch (error) {
        console.log("[DTRP-BOT] Database connection failed!");
        throw error;
    }
    console.log("[DTRP-BOT] Database connected!");

    // Pastikan satu akun Discord hanya bisa membuat satu karakter
    const [indexes] = await mysql.query("SHOW INDEX FROM Pemain");
    const uniqueIndexes = indexes.filter(index => Number(index.Non_unique) === 0);
    const hasDiscordIndex = uniqueIndexes.some(index => index.Column_name === "discordid" && uniqueIndexes.filter(key => key.Key_name === index.Key_name).length === 1);
    if (!hasDiscordIndex) throw new Error("Index unik discordid belum tersedia. Sesuaikan tabel Pemain dengan database/detroit-db.sql terlebih dahulu.");

    loadCommand(client);
    loadButton(client);
    loadModal(client);
    await client.login(process.env.TOKEN);
}

startBot().catch(async (error) => {
    console.error("[DTRP-BOT] Gagal menjalankan bot:", error);
    process.exitCode = 1;
    if (presenceInterval) clearInterval(presenceInterval);
    client.destroy();
    try {
        await mysql.end();
    } catch (err) {
        console.error("[DTRP-BOT] Gagal menutup koneksi database:", err);
    }
});
