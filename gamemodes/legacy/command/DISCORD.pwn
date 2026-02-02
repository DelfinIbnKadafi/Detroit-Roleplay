//====[DISCORD COMMAND]====//
#include <discord-connector>
#include <discord-cmd>

#define CHANNEL_REGISTER 

forward CheckDiscordRegister(discordid[], username_input[], DCC_Channel:channel);

stock SendVerificationDM(discordid[], username[], code)
{
    new DCC_User:user;
    user = DCC_FindUserById(discordid);
    if(user == DCC_INVALID_USER) return 1;

    new message[512];
    format(message, sizeof(message),
        "```DETROIT ROLEPLAY - ACCOUNT```\n\n"
        "Terima kasih telah mendaftarkan akun anda di server Detroit Roleplay.\n\n"
        "Gunakan kode verifikasi di bawah ini untuk register.\n\n"
        "```USERNAME : %s```\n\n"
        "```CODE : %d```\n\n"
        "Jangan berikan kode verifikasi ini kepada siapapun!\n\n"
        "Terima kasih.",
        username,
        code
    );

    DCC_SendUserMessage(user, message);
    return 1;
}

DCMD:register(user, channel, params[])
{
    if(channel != CHANNEL_REGISTER)
        return 1;

    if(isnull(params))
    {
        DCC_SendChannelMessage(channel, 
            "Format salah! Gunakan: !register Nama_Nama");
        return 1;
    }

    if(!IsValidRoleplayName(params))
    {
        DCC_SendChannelMessage(channel,
            "Nama harus menggunakan format: Nama_Nama");
        return 1;
    }

    new discordid[32];
    DCC_GetUserId(user, discordid, sizeof(discordid));

    new query[256];
    mysql_format(g_SQL, query, sizeof(query),
        "SELECT username FROM players WHERE discord='%e' LIMIT 1",
        discordid);
    mysql_tquery(g_SQL, query, "CheckDiscordRegister", "sss",
        discordid, params, channel);

    return 1;
}

public CheckDiscordRegister(discordid[], username_input[], DCC_Channel:channel)
{
    if(cache_num_rows() > 0)
    {
        new username[24];
        cache_get_value_name(0, "username", username);

        new msg[144];
        format(msg, sizeof(msg),
            "Kamu sudah mendaftarkan akun mu dengan nama **%s**",
            username);

        DCC_SendChannelMessage(channel, msg);
    }
    else
    {
        new code = random(900000) + 100000;

        new query[256];
        mysql_format(g_SQL, query, sizeof(query),
            "INSERT INTO players (username, discord, verified, code) \
            VALUES ('%e','%e',0,'%d')",
            username_input, discordid, code);
        mysql_tquery(g_SQL, query);

        SendVerificationDM(discordid, username_input, code);
    }
    return 1;
}