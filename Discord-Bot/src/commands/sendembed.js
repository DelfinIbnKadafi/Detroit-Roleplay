
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
            .setTitle("Register")
            .setDescription("klik tombol dibawah untuk register")
            .setColor("#FF0000");

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
