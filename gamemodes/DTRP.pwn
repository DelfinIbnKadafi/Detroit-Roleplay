//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        BASIC GAMEMODE DETROIT ROLEPLAY          /////////////////////
/////////////////////        MADE BY DELFIN IBN KADAFI.                           /////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//========[CONTRIBUTOR]========//
/*
• Delfin Ibn Kadafi - Founder and Scripter
• Panntzyy - Scripter
• Martin - Scripter
*/

//===[INCLUDE]===//
#include <a_samp>
#include <sscanf2>
#include <streamer>
#include <a_mysql>
#include <foreach>


// main modular //
#include "legacy\core\defines.pwn"
#include "legacy\core\variables.pwn"
#include "legacy\core\enumerations.pwn"
#include "legacy\core\native.pwn"
#include "legacy\core\functions.pwn"

// command modular
// #include "legacy\command\discord.pwn"

// server
#include "legacy\server\OnPlayerDialogResponse.pwn"
#include "legacy\mapping.pwn"

// server core //
public OnGameModeInit()
{
    SetGameModeText(server_version);

    g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
    if(mysql_errno(g_SQL) != 0)
    {
        print("[MySQL] Koneksi GAGAL!");
        SendRconCommand("exit");
        return 0;
    }

    printf("[MySQL] Koneksi BERHASIL ke database '%s' (Handle: %d)", MYSQL_DATABASE, _:g_SQL);
    mysql_set_charset("utf8mb4", g_SQL);

    DisableInteriorEnterExits();
    // LoadMapping();
    return 1;
}

public OnGameModeExit()
{
    mysql_close(g_SQL);
    return 1;
}

public OnPlayerConnect(playerid)
{
    SetPlayerColor(playerid, 0xFFFFFFFF);
    GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);

    SpamCount[playerid] = 0;
    muted[playerid] = 0;

    new query[256];
    mysql_format(g_SQL, query, sizeof(query),
        "SELECT * FROM players WHERE username='%e'",
        Player[playerid][pName]
    );
    mysql_tquery(g_SQL, query, "CekUcpPlayer", "i", playerid);
    return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
    SavePlayerData(playerid);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if(muted[playerid] == 1)
    {
        SendClientMessage(playerid, 0xFF0000FF, "You have been muted!");
        return 0;
    }
    
    AntiSpam(playerid);
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    new msg[256];
    format(msg, sizeof(msg), "%s says: %s", Player[playerid][pName], text);

    ProxDetector(20.0, playerid, msg);
    return 0;
}
