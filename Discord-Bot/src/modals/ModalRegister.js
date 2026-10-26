const { EmbedBuilder, MessageFlags } = require("discord.js");
const { randomInt } = require("node:crypto");
const mysql = require("../mysql");

module.exports = {
    customId: "reg_modal",
    async run(client, interaction) {
        await interaction.deferReply({ flags: MessageFlags.Ephemeral });
        const discordId = interaction.user.id;
        const username = interaction.fields.getTextInputValue("username").trim();

        // 1. Pengecekan Discord ID apakah sudah terdaftar
        const [checkDiscord] = await mysql.execute("SELECT id, nama, kode FROM Pemain WHERE discordid = ? LIMIT 1", [discordId]);
        if (checkDiscord.length > 0) {
            return interaction.editReply({
                content: `❌ Akun Discord kamu sudah terdaftar dengan nama **${checkDiscord[0].nama}**!`
            });
        }

        // 2. Pengecekan format nama (Roleplay: First_Last, 3-24 karakter)
        const nameRegex = /^[A-Z][a-zA-Z0-9]*_[A-Z][a-zA-Z0-9]*$/;
        if (!nameRegex.test(username) || username.length < 3 || username.length > 24) {
            return interaction.editReply({
                content: "❌ Format nama tidak valid! Gunakan format Roleplay: **Nama_Depan** (Contoh: `John_Doe`), huruf kapital di awal kata dan dipisah garis bawah (`_`)."
            });
        }

        // 3. Pengecekan apakah nama sudah dipakai pemain lain
        const [checkName] = await mysql.execute("SELECT id FROM Pemain WHERE nama = ? LIMIT 1", [username]);
        if (checkName.length > 0) {
            return interaction.editReply({
                content: `❌ Nama **${username}** sudah digunakan oleh pemain lain. Silakan pilih nama lain!`
            });
        }

        // 4. Generate random kode verifikasi 6 digit (100000 - 999999)
        const randomCode = randomInt(100000, 1000000);

        // 5. Insert ke tabel Pemain
        try {
            await mysql.execute("INSERT INTO Pemain (discordid, nama, kode, verified) VALUES (?, ?, ?, 0)", [discordId, username, randomCode]);
        } catch (error) {
            if (error.code !== "ER_DUP_ENTRY") throw error;

            // Data bisa terdaftar dari interaksi lain setelah pengecekan awal
            const [registered] = await mysql.execute("SELECT nama FROM Pemain WHERE discordid = ? LIMIT 1", [discordId]);
            if (registered.length > 0) {
                return interaction.editReply({ content: `❌ Akun Discord kamu sudah terdaftar dengan nama **${registered[0].nama}**!` });
            }

            const [usedName] = await mysql.execute("SELECT id FROM Pemain WHERE nama = ? LIMIT 1", [username]);
            if (usedName.length > 0) {
                return interaction.editReply({ content: `❌ Nama **${username}** sudah digunakan oleh pemain lain. Silakan pilih nama lain!` });
            }
            throw error;
        }

        // 6. Response Embed ke pengguna
        const embed = new EmbedBuilder()
            .setTitle("✅ Pendaftaran Berhasil!")
            .setDescription(`Selamat datang di **Detroit Roleplay**, akun kamu telah berhasil dibuat!`)
            .setColor("#00FF88")
            .addFields({ name: "👤 Nama Karakter", value: `\`${username}\``, inline: true }, { name: "🔑 Kode Verifikasi", value: `\`${randomCode}\``, inline: true })
            .setFooter({ text: "Simpan kode ini dengan baik!" })
            .setTimestamp();

        await interaction.editReply({
            embeds: [embed]
        });
    }
};
