const { SlashCommandBuilder, MessageFlags } = require("discord.js");
const mysql = require("../mysql");

module.exports = {
    data: new SlashCommandBuilder()
        .setName("setadmin")
        .setDescription("Mengatur level admin karakter pemain.")
        .addStringOption(option => option.setName("name_name").setDescription("Nama karakter pemain, contoh John_Doe").setRequired(true).setMaxLength(24))
        .addIntegerOption(option => option.setName("leveladmin").setDescription("Level admin baru (0 untuk mencabut admin)").setRequired(true).setMinValue(0).setMaxValue(2147483647)),

    async run(client, interaction) {
        const allowedRoleId = process.env.SETADMIN_ROLE_ID;

        if (!allowedRoleId || !/^\\d{17,20}$/.test(allowedRoleId)) {
            return interaction.reply({ content: "Command /setadmin belum dikonfigurasi dengan benar oleh pengelola bot.", flags: MessageFlags.Ephemeral });
        }

        if (!interaction.inGuild() || !interaction.member?.roles?.cache?.has(allowedRoleId)) {
            return interaction.reply({ content: "Kamu tidak memiliki izin untuk menggunakan command ini.", flags: MessageFlags.Ephemeral });
        }

        const nama = interaction.options.getString("name_name", true).trim();
        const levelAdmin = interaction.options.getInteger("leveladmin", true);

        if (!/^[A-Z][A-Za-z0-9]*_[A-Z][A-Za-z0-9]*$/.test(nama)) {
            return interaction.reply({ content: "Format nama karakter tidak valid. Gunakan format First_Last, misalnya John_Doe.", flags: MessageFlags.Ephemeral });
        }

        try {
            const [players] = await mysql.execute("SELECT id, nama, admin FROM Pemain WHERE nama = ? LIMIT 1", [nama]);

            if (players.length === 0) {
                return interaction.reply({ content: "Karakter " + nama + " tidak ditemukan di database.", flags: MessageFlags.Ephemeral });
            }

            const player = players[0];
            await mysql.execute("UPDATE Pemain SET admin = ? WHERE id = ?", [levelAdmin, player.id]);

            return interaction.reply({
                content: "Level admin karakter " + player.nama + " berhasil diubah dari " + player.admin + " menjadi " + levelAdmin + ".",
                flags: MessageFlags.Ephemeral
            });
        } catch (error) {
            console.error("[DTRP-BOT] Gagal menjalankan /setadmin:", error);
            return interaction.reply({ content: "Terjadi kesalahan saat memperbarui level admin. Periksa log bot.", flags: MessageFlags.Ephemeral });
        }
    }
};
