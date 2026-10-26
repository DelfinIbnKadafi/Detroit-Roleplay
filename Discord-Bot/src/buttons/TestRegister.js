const { ModalBuilder, TextInputBuilder, TextInputStyle, ActionRowBuilder, MessageFlags } = require("discord.js");
const mysql = require("../mysql");

module.exports = {
    customId: "reg_btn",
    async run(client, interaction) {
        // Pengecekan apakah discordid sudah terdaftar
        const [rows] = await mysql.execute("SELECT nama, kode, verified FROM Pemain WHERE discordid = ?", [interaction.user.id]);
        if (rows.length > 0) {
            const player = rows[0];
            return interaction.reply({
                content: `❌ Kamu sudah terdaftar!\n• **Nama Karakter**: \`${player.nama}\`\n• **Kode Verifikasi**: \`${player.kode}\`\n• **Status**: ${player.verified ? "Sudah Terverifikasi" : "Belum Verifikasi di In-Game"}`,
                flags: MessageFlags.Ephemeral
            });
        }

        const modal = new ModalBuilder()
            .setCustomId("reg_modal")
            .setTitle("Register Detroit Roleplay");

        const textInput = new TextInputBuilder()
            .setCustomId("username")
            .setLabel("Nama Karakter (Format: First_Last)")
            .setStyle(TextInputStyle.Short)
            .setPlaceholder("Contoh: John_Doe")
            .setMinLength(3)
            .setMaxLength(24)
            .setRequired(true);

        const firstActionRow = new ActionRowBuilder().addComponents(textInput);
        modal.addComponents(firstActionRow);

        await interaction.showModal(modal);
    }
};
