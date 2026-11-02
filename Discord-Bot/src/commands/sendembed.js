
const {
    SlashCommandBuilder,
    EmbedBuilder,
    ButtonBuilder,
    ButtonStyle,
    ActionRowBuilder
} = require("discord.js");

module.exports = {
    data: new SlashCommandBuilder()
        .setName("register")
        .setDescription("Embed Register"),

    async run(client, interaction) {
        const embed = new EmbedBuilder()
            .setTitle("Detroit Roleplay - Register")
            .setDescription("Untuk register atau membuat akun kedalam server,\n silahkan klik tombol dibawah untuk register\nGunakan format **First_Last**\nContoh : **Bryan_Walton**, **Sheyla_Pratama**")
            .setColor("#ff9900");

        const button = new ButtonBuilder()
            .setCustomId("reg_btn")
            .setLabel("Register")
            .setStyle(ButtonStyle.Primary);

        const row = new ActionRowBuilder()
            .addComponents(button);

        await interaction.reply({
            embeds: [embed],
            components: [row]
        });
    }
};
