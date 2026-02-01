//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////        BASIC GAMEMODE DETROIT ROLEPLAY          /////////////////////
/////////////////////        MADE BY DELFIN IBN KADAFI.                           /////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//========[CONTRIBUTOR]========//
/*
• Delfin Ibn Kadafi - Founder and Scripter
*/

//===[INCLUDE]===//
#include <a_samp>
#include <sscanf2>
#include <streamer>
#include <a_mysql>
#include <foreach>

//===[ENUM & VARIABEL]===//
new MySQL:g_SQL;

enum PlayerData
{
    pName[MAX_PLAYER_NAME],
    pId,
    pVerified,
    pCode,
    pPassword[65],
    pLevel,
    pLahir[10],
    pTinggi,
    pBerat,
    pMoney,
    pBank,
    pPhone,
    pRek
};

new Player[MAX_PLAYERS][PlayerData];

enum PSpawn
{
    Float:pPosx,
    Float:pPosy,
    Float:pPosz,
    Float:pAngle,
    pSkin,
    Float:pNyawa,
    Float:pArmor
};

new Float:PlayerSpawn[MAX_PLAYERS][PSpawn];
new PlayerInt[MAX_PLAYERS];

//===[FORWARD]===//
forward CekUcpPlayer(playerid);
forward KickPlayerTimer(playerid);
forward CekVerifiedPlayer(playerid);
forward CekAccountPlayer(playerid);
forward OnPlayerLogin(playerid);
forward SendMessageError(playerid, const text[]);
forward SendMessageServer(playerid, const text[]);
forward SendMessageInfo(playerid, const text[]);
forward OnPasswordSet(playerid);
forward LoadPlayerData(playerid);
forward PlayerSpawnLogin(playerid);
forward SpawnPlayerLogin(playerid);
forward SavePlayerData(playerid);

//===[DATA]===//
#include "DATA\CONFIG.pwn"
#include "DATA\DIALOG_DEFINE.pwn"
#include "DATA\SEND_MESSAGE.pwn"
#include "DATA\DIALOG_RESPONSE.pwn"

//===[FUNCTION]===//
public OnGameModeInit()
{
    SetGameModeText("DTRP v0.0.2");

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

public CekUcpPlayer(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;

    if(cache_num_rows() > 0)
    {
        new query[256];
        mysql_format(g_SQL, query, sizeof(query),
            "SELECT id, verified, code FROM players WHERE username='%e'",
            Player[playerid][pName]
        );
        mysql_tquery(g_SQL, query, "CekVerifiedPlayer", "i", playerid);
    }
    else
    {
        SetTimerEx("KickPlayerTimer", 7000, false, "i", playerid);

        new str[512];
        format(str, sizeof(str),
        "UCP {FFF000}%s {FFFFFF}belum terdaftar.\n\nSilahkan daftar UCP di Discord kami terlebih dahulu\nlalu gunakan kode verifikasi yang diberikan.",
        Player[playerid][pName]);

        ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX,
            "{CD7000}Detroit {FFFFFF}Roleplay - Account",
            str,
            "Kembali",
            " "
        );
    }
    return 1;
}

public KickPlayerTimer(playerid)
{
    if(IsPlayerConnected(playerid))
    {
        Kick(playerid);
    }
    return 1;
}

public CekVerifiedPlayer(playerid)
{
    cache_get_value_int(0, "id", Player[playerid][pId]);
    cache_get_value_int(0, "verified", Player[playerid][pVerified]);
    cache_get_value_int(0, "code", Player[playerid][pCode]);

    CekAccountPlayer(playerid);
    return 1;
}

public CekAccountPlayer(playerid)
{
    new query[256];

    if(Player[playerid][pVerified] == 0)
    {
        new str[512];
        format(str, sizeof(str),
            "Akun {FFF000}%s {FFFFFF}belum diverifikasi.\n\nMasukkan kode verifikasi 6 digit yang telah diberikan.",
            Player[playerid][pName]
        );

        ShowPlayerDialog(playerid, DIALOG_REGISTER_VERTIFIKASI, DIALOG_STYLE_INPUT,
            "{CD7000}Detroit {FFFFFF}Roleplay - Account Verification",
            str,
            "Lanjut",
            "Kembali"
        );
    }
    else
    {
        mysql_format(g_SQL, query, sizeof(query),
            "SELECT password FROM players WHERE id=%d",
            Player[playerid][pId]
        );
        mysql_tquery(g_SQL, query, "OnPlayerLogin", "i", playerid);
    }
    return 1;
}

public OnPlayerLogin(playerid)
{
    cache_get_value_name(0, "password", Player[playerid][pPassword]);

    new str[512];
    format(str, sizeof(str),
        "Akun {FFF000}%s {FFFFFF}sudah terdaftar.\n\nSilahkan masukkan password akun anda.",
        Player[playerid][pName]
    );

    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,
        "{CD7000}Detroit {FFFFFF}Roleplay - Account Login",
        str,
        "Lanjut",
        "Kembali"
    );
    return 1;
}

public OnPasswordSet(playerid)
{
    SendMessageServer(playerid, "Selamat datang di server Detroit Roleplay);
    
    TogglePlayerSpectating(playerid, false);

    SetSpawnInfo(playerid, 0, 147, 1496.65, -1716.51, 14.04, 90.0, 0, 0, 0, 0, 0, 0);

    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);

    SpawnPlayer(playerid);

    GivePlayerMoney(playerid, 100000);
    SetPlayerScore(playerid, 1);
    return 1;
}

public LoadPlayerData(playerid)
{
    cache_get_value_int(0, "money", Player[playerid][pMoney]);
    cache_get_value_int(0, "bank", Player[playerid][pBank]);
    cache_get_value_int(0, "phone", Player[playerid][pPhone]);
    cache_get_value_int(0, "rek", Player[playerid][pRek]);
    cache_get_value_int(0, "level", Player[playerid][pLevel]);
    cache_get_value_name(0, "lahir", Player[playerid][pLahir]);
    cache_get_value_int(0, "tinggi", Player[playerid][pTinggi]);
    cache_get_value_int(0, "berat", Player[playerid][pBerat]);    
    cache_get_value_int(0, "skin", PlayerSpawn[playerid][pSkin]);
    cache_get_value_int(0, "interior", PlayerInt[playerid]);
    cache_get_value_float(0, "posx", PlayerSpawn[playerid][pPosx]);
    cache_get_value_float(0, "posy", PlayerSpawn[playerid][pPosy]);
    cache_get_value_float(0, "posz", PlayerSpawn[playerid][pPosz]);
    cache_get_value_float(0, "angle", PlayerSpawn[playerid][pAngle]);
    cache_get_value_float(0, "nyawa", PlayerSpawn[playerid][pNyawa]);
    cache_get_value_float(0, "armor", PlayerSpawn[playerid][pArmor]);
    
    SpawnPlayerLogin(playerid);
    return 1;
}

public SpawnPlayerLogin(playerid)
{
    new msg[256];
    format(msg, sizeof(msg),
        "{00EBFF}[SERVER]{FFF000} %s {FFFFFF}telah bergabung ke server.",
        Player[playerid][pName]
    );
    SendClientMessageToAll(0xFFFFFFFF, msg);
    
    SendMessageServer(playerid, "Selamat datang kembali di server Detroit Roleplay);

    TogglePlayerSpectating(playerid, false);

    SetSpawnInfo(playerid,
        0,
        PlayerSpawn[playerid][pSkin],
        PlayerSpawn[playerid][pPosx],
        PlayerSpawn[playerid][pPosy],
        PlayerSpawn[playerid][pPosz],
        PlayerSpawn[playerid][pAngle],
        0, 0, 0, 0, 0, 0
    );

    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, PlayerInt[playerid]);

    SpawnPlayer(playerid);

    SetPlayerHealth(playerid, PlayerSpawn[playerid][pNyawa]);
    SetPlayerArmour(playerid, PlayerSpawn[playerid][pArmor]);
    SetPlayerScore(playerid, Player[playerid][pLevel]);
    GivePlayerMoney(playerid, Player[playerid][pMoney]);

    return 1;
}

public SavePlayerData(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(Player[playerid][pId] == 0) return 0;

    GetPlayerPos(playerid,
        PlayerSpawn[playerid][pPosx],
        PlayerSpawn[playerid][pPosy],
        PlayerSpawn[playerid][pPosz]
    );

    GetPlayerFacingAngle(playerid, PlayerSpawn[playerid][pAngle]);
    GetPlayerHealth(playerid, PlayerSpawn[playerid][pNyawa]);
    GetPlayerArmour(playerid, PlayerSpawn[playerid][pArmor]);

    PlayerSpawn[playerid][pSkin] = GetPlayerSkin(playerid);
    PlayerInt[playerid] = GetPlayerInterior(playerid);

    Player[playerid][pMoney] = GetPlayerMoney(playerid);
    Player[playerid][pLevel] = GetPlayerScore(playerid);

    new query[512];
    mysql_format(g_SQL, query, sizeof(query),
        "UPDATE players SET \
        money=%d, bank=%d, level=%d, \
        tinggi=%d, berat=%d, \
        skin=%d, interior=%d, \
        posx=%f, posy=%f, posz=%f, angle=%f, \
        nyawa=%f, armor=%f \
        WHERE id=%d",
        
        Player[playerid][pMoney],
        Player[playerid][pBank],
        Player[playerid][pLevel],
        Player[playerid][pTinggi],
        Player[playerid][pBerat],

        PlayerSpawn[playerid][pSkin],
        PlayerInt[playerid],

        PlayerSpawn[playerid][pPosx],
        PlayerSpawn[playerid][pPosy],
        PlayerSpawn[playerid][pPosz],
        PlayerSpawn[playerid][pAngle],

        PlayerSpawn[playerid][pNyawa],
        PlayerSpawn[playerid][pArmor],

        Player[playerid][pId]
    );

    mysql_tquery(g_SQL, query);
    return 1;

}

public OnPlayerText(playerid, text[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    new msg[256]
    format(msg, sizeof(msg), "%s says: %s", Player[playerid][pName], text);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 20.0, x, y, z))
        {
            SendClientMessage(i, 0xFFFFFFFF, msg);
            return 1;
        }
    }
    return 0;
}