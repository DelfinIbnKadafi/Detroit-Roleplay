const { EmbedBuilder, MessageFlags } = require("discord.js");
const mysql = require("../mysql");

module.exports = {
    customId: "reg_modal",
    async run(client, interaction) {
        const discordId = interaction.user.id;
        const username = interaction.fields.getTextInputValue("username").trim();

        // 1. Pengecekan Discord ID apakah sudah terdaftar
        const [checkDiscord] = await mysql.execute("SELECT id, nama, kode FROM Pemain WHERE discordid = ?", [discordId]);
        if (checkDiscord.length > 0) {
            return interaction.reply({
                content: `❌ Akun Discord kamu sudah terdaftar dengan nama **${checkDiscord[0].nama}**!`,
                flags: MessageFlags.Ephemeral
            });
        }

        // 2. Pengecekan format nama (Roleplay: First_Last, 3-24 karakter)
        const nameRegex = /^[A-Z][a-zA-Z0-9]*_[A-Z][a-zA-Z0-9]*$/;
        if (!nameRegex.test(username) || username.length < 3 || username.length > 24) {
            return interaction.reply({
                content: "❌ Format nama tidak valid! Gunakan format Roleplay: **Nama_Depan** (Contoh: `John_Doe`), huruf kapital di awal kata dan dipisah garis bawah (`_`).",
                flags: MessageFlags.Ephemeral
            });
        }

        // 3. Pengecekan apakah nama sudah dipakai pemain lain
        const [checkName] = await mysql.execute("SELECT id FROM Pemain WHERE nama = ?", [username]);
        if (checkName.length > 0) {
            return interaction.reply({
                content: `❌ Nama **${username}** sudah digunakan oleh pemain lain. Silakan pilih nama lain!`,
                flags: MessageFlags.Ephemeral
            });
        }

        // 4. Generate random kode verifikasi 6 digit (100000 - 999999)
        const randomCode = Math.floor(100000 + Math.random() * 900000);

        // 5. Insert ke tabel Pemain
        await mysql.execute(
            "INSERT INTO Pemain (discordid, nama, kode) VALUES (?, ?, ?)",
            [discordId, username, randomCode]
        );

        // 6. Response Embed ke pengguna
        const embed = new EmbedBuilder()
            .setTitle("✅ Pendaftaran Berhasil!")
            .setDescription(`Selamat datang di **Detroit Roleplay**, akun kamu telah berhasil dibuat!`)
            .setColor("#00FF88")
            .addFields(
                { name: "👤 Nama Karakter", value: `\`${username}\``, inline: true },
                { name: "🔑 Kode Verifikasi", value: `\`${randomCode}\``, inline: true },
            )
            .setFooter({ text: "Simpan kode ini dengan baik!" })
            .setTimestamp();

        await interaction.reply({
            embeds: [embed],
            flags: MessageFlags.Ephemeral
        });
    }
};
