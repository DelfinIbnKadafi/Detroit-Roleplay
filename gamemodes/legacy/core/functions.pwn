//===[ FORWARD FUNCTIONS ]===//
forward CekUcpPlayer(playerid);
forward KickPlayerTimer(playerid);
forward CekVerifiedPlayer(playerid);
forward CekAccountPlayer(playerid);
forward OnPlayerLogin(playerid);
forward OnPasswordSet(playerid);
forward LoadPlayerData(playerid);
forward SpawnPlayerLogin(playerid);
forward SavePlayerData(playerid);
forward AutoUnMute(playerid);
forward PlayerIsDeath(playerid);

//=====[ PUBLIC FUNCTION ]=====//
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
    cache_get_value_int(0, "job1", Player[playerid][pJob1]);
    cache_get_value_int(0, "job2", Player[playerid][pJob2]);
    cache_get_value_int(0, "hunger", Player[playerid][pHunger]);
    cache_get_value_int(0, "energi", Player[playerid][pEnergi]);
    cache_get_value_int(0, "admin", Player[playerid][pAdmin]);
    cache_get_value_int(0, "death", PlayerDeath[playerid]);
    
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
    
    if(Registered[playerid] == 0)
    {
        SendMessageServer(playerid, "Selamat datang kembali di server Detroit Roleplay");
    }
    
    TextDrawShowForPlayer(playerid, BACKGROUND_STATS[0]);
TextDrawShowForPlayer(playerid, BACKGROUND_STATS[1]);
TextDrawShowForPlayer(playerid, BACKGROUND_STATS[2]);

PlayerTextDrawShow(playerid, HUNGER[playerid]);
PlayerTextDrawShow(playerid, ENERGY[playerid]);
    
    UpdateStatsHbe(playerid);

    TogglePlayerSpectating(playerid, false);
    
    if(PlayerDeath[playerid] == 1)
    {
        PlayerIsDeath(playerid);
        SetPlayerScore(playerid, Player[playerid][pLevel]);
        GivePlayerMoney(playerid, Player[playerid][pMoney]);
        return 1;
    }

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
        job1=%d, job2=%d, \
        tinggi=%d, berat=%d, \
        skin=%d, interior=%d, \
        posx=%f, posy=%f, posz=%f, angle=%f, \
        nyawa=%f, armor=%f, hunger=%d, energi=%d, admin=%d \
        WHERE id=%d",

        Player[playerid][pMoney],
        Player[playerid][pBank],
        Player[playerid][pLevel],

        Player[playerid][pJob1],
        Player[playerid][pJob2],

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
        
        Player[playerid][pHunger],
        Player[playerid][pEnergi],
        Player[playerid][pAdmin],

        Player[playerid][pId]
    );
    mysql_tquery(g_SQL, query);
    return 1;
}

public OnPasswordSet(playerid)
{
    SendMessageServer(playerid, "Selamat datang di server Detroit Roleplay");
    
    TogglePlayerSpectating(playerid, false);

    SetSpawnInfo(playerid, 0, 147, 1496.65, -1716.51, 14.04, 90.0, 0, 0, 0, 0, 0, 0);

    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);

    SpawnPlayer(playerid);
    
    Registered[playerid] = 1;

    GivePlayerMoney(playerid, 100000);
    SetPlayerScore(playerid, 1);
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

stock AntiSpam(playerid)
{
    SpamCount[playerid]++;
    
    switch (SpamCount[playerid])
    {
        case 1:
        {
            ChatSpamTime[playerid][0] = gettime();
        }
        case 2:
        {
            if((gettime() - ChatSpamTime[playerid][0]) < 4)
            {
                SendMessageInfo(playerid, "You have received a warning (1/3)! (Reason: Spam)");
                ChatSpamTime[playerid][1] = gettime();
            }
            else SpamCount[playerid] = 0;
        }
        case 3:
        {
            if((gettime() - ChatSpamTime[playerid][1]) < 4)
            {
                SendMessageInfo(playerid, "You have received a warning (2/3)! (Reason: Spam)");
                ChatSpamTime[playerid][2] = gettime();
            }
            else SpamCount[playerid] = 0;
        }
        case 4..50:
        {
            new string[128], name[24];
            GetPlayerName(playerid, name, 24);
            
            if((gettime() - ChatSpamTime[playerid][2]) < 4)
            {
                format(string, sizeof(string), "Player %s has been muted for %d minutes! (Reason: Spam!)", name, AutoUnmuteTime);
                SendClientMessageToAll(0xFF0000FF, string);
                
                SendMessageInfo(playerid, "You have received your final warning (3/3)! (Reason: Spam)");
                
                muted[playerid] = 1;
                SetTimerEx("AutoUnMute", AutoUnmuteTime * 60000, false, "i", playerid);
            }
        }
    }
    return 1;
}

public AutoUnMute(playerid)
{
    muted[playerid] = 0;
    SpamCount[playerid] = 0;
    SendMessageServer(playerid, "You have been unmuted automatically!");
    return 1;
}

public PlayerIsDeath(playerid)
{
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
    
    SetPlayerHealth(playerid, 100);
    
    ApplyAnimation(playerid, "CRACK", "crckidle2", 4.1, 1, 0, 0, 1, 0);
    TogglePlayerControllable(playerid, 0);

    return 1;
}

stock UpdateStatsHbe(playerid)
{
    new str[16];

    format(str, sizeof(str), "%d", Player[playerid][pHunger]);
    PlayerTextDrawSetString(playerid, HUNGER[playerid], str);

    format(str, sizeof(str), "%d", Player[playerid][pEnergi]);
    PlayerTextDrawSetString(playerid, ENERGY[playerid], str);
}