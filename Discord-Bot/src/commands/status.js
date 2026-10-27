const { SlashCommandBuilder, EmbedBuilder } = require("discord.js");
const { querySAMP } = require("../query");

module.exports = {
    data: new SlashCommandBuilder()
        .setName("status")
        .setDescription("Menampilkan status server SA:MP / open.mp Detroit Roleplay"),

    async run(client, interaction) {
        const host = process.env.SAMP_HOST || "127.0.0.1";
        const port = parseInt(process.env.SAMP_PORT, 10) || 7777;

        const server = (client && client.serverStatus) ? client.serverStatus : await querySAMP(host, port);

        if (!server.online) {
            const offlineEmbed = new EmbedBuilder()
                .setTitle("🔴 Server Offline")
                .setDescription("Server SA:MP / open.mp Detroit Roleplay sedang offline atau tidak dapat dijangkau.")
                .setColor("#ED4245")
                .addFields(
                    { name: "IP & Port", value: `\`${host}:${port}\``, inline: true },
                    { name: "Status", value: "🔴 Offline", inline: true }
                )
                .setTimestamp()
                .setFooter({ text: "Detroit Roleplay" });

            return interaction.reply({ embeds: [offlineEmbed] });
        }

        const onlineEmbed = new EmbedBuilder()
            .setTitle(`🎮 ${server.name}`)
            .setDescription("Status server **Detroit Roleplay** saat ini.")
            .setColor("#57F287")
            .addFields(
                { name: "Status", value: "🟢 Online", inline: true },
                { name: "IP & Port", value: `\`${host}:${port}\``, inline: true },
                { name: "Ping", value: `\`${server.ping}ms\``, inline: true },
                { name: "Gamemode", value: `\`${server.gamemode}\``, inline: true },
                { name: "Map", value: `\`${server.map}\``, inline: true },
                { name: "Players", value: `\`${server.players} / ${server.maxPlayers}\``, inline: true }
            )
            .setTimestamp()
            .setFooter({ text: "Detroit Roleplay" });

        if (server.playerList && server.playerList.length > 0) {
            const list = server.playerList.slice(0, 20).join(", ");
            const more = server.playerList.length > 20 ? ` ...dan ${server.playerList.length - 20} lainnya` : "";
            onlineEmbed.addFields({
                name: `Daftar Pemain (${server.playerList.length})`,
                value: list + more || "-"
            });
        }

        return interaction.reply({ embeds: [onlineEmbed] });
    }
};
