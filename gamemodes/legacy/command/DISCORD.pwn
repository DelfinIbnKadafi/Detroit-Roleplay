//====[DISCORD COMMAND]====//
#include <discord-connector>
#include <discord-cmd>

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