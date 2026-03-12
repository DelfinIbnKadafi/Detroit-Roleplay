//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        BASIC GAMEMODE DETROIT ROLEPLAY          /////////////////////
/////////////////////        MADE BY DELFIN IBN KADAFI.                           /////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//========[CONTRIBUTOR]========//
/*
• Delfin Ibn Kadafi - Founder and Scripter
• Panntzyy - Scripter
• Martin - Scripter (Then)
*/

//===[INCLUDE]===//
#include <a_samp>
#include <sscanf2>
#include <streamer>
#include <a_mysql>
#include <foreach>

// Utils modular //
#include "Modules\Utils\map.pwn"
#include "Modules\Utils\textdraw.pwn"

// main modular //
#include "Modules\Core\defines.pwn"
#include "Modules\Core\variables.pwn"
#include "Modules\Core\enumerations.pwn"
#include "Modules\Core\native.pwn"
#include "Modules\Core\functions.pwn"

// server modular //
#include "Modules\Server\dialogresponse.pwn"
#include "Modules\Dynamic\atm.pwn"

// command modular //
#include "Modules\Command\player.pwn"

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
    LoadMap();
    LoadATM();
    LoadTd();
    return 1;
}

public OnGameModeExit()
{
    mysql_close(g_SQL);
    return 1;
}

public OnPlayerConnect(playerid)
{
	LoadPlayerTd(playerid);
	
	for(new i = 0; i < 2; i++);
	{
    	TextDrawShowForPlayer(playerid, Nama_Server[i]);
    }
    
    SetPlayerColor(playerid, 0xFFFFFFFF);
    GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);

    SpamCount[playerid] = 0;
    muted[playerid] = 0;
    
    RemoveMap(playerid);

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
	SendMessageError(playerid, "Kamu harus login/register terlebih dahulu!");
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
    
    new msg[256];
    format(msg, sizeof(msg), "%s says: %s", Player[playerid][pName], text);

    ProxDetector(20.0, playerid, msg);
    return 0;
}

public OnPlayerDeath(playerid, killerid, reason)
{	 
    SavePlayerData(playerid);
    
    if(killerid != INVALID_PLAYER_ID)
    {
        new killerName[MAX_PLAYER_NAME];
        GetPlayerName(killerid, killerName, sizeof(killerName));
        
        new msgdeath[144];
        format(msgdeath, sizeof(msgdeath), "Kamu telah pingsan karena dibunuh oleh %s", killerName);
        SendClientMessage(playerid, 0xFF0000FF, msgdeath);
    }
    else
    {
        SendMessageInfo(playerid, "Kamu telah pingsan karena kehabisan darah");
    }
    
    SendMessageInfo(playerid, "Gunakan /death untuk bangun dari pingsan di rumah sakit");
    
    PlayerDeath[playerid] = 1;
    
    new query[128];
    mysql_format(g_SQL, query, sizeof(query),
        "UPDATE players SET death = 1 WHERE username='%e'",
        Player[playerid][pName]
    );
    mysql_tquery(g_SQL, query, "PlayerIsDeath", "i", playerid);
    
    return 1;
}