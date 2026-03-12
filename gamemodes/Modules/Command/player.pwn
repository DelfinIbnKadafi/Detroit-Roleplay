// command
CMD:me(playerid, params[])
{
    if(isnull(params))
        return SendClientMessage(playerid, -1, "Usage: /me <text>");

    new text[144], pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));

    format(text, sizeof(text), "%s %s", pName, params);

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 20.0, px, py, pz))
        {
            SendClientMessage(i, 0x6B0E66FF, text);
        }
    }
    return 1;
}

CMD:do(playerid, params[])
{
    if(isnull(params))
        return SendClientMessage(playerid, -1, "Usage: /do <text>");

    new text[144], pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));

    format(text, sizeof(text), "%s (%s)", params, pName);

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 20.0, px, py, pz))
        {
            SendClientMessage(i, 0x6B0E66FF, text);
        }
    }
    return 1;
}

CMD:s(playerid, params[])
{
    if(isnull(params))
        return SendClientMessage(playerid, -1, "Usage: /s <text>");

    new text[144], pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));

    format(text, sizeof(text), "(SHOUT) %s : %s", pName, params);

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 35.0, px, py, pz))
        {
            SendClientMessage(i, -1, text);
        }
    }
    return 1;
}

CMD:l(playerid, params[])
{
    if(isnull(params))
        return SendClientMessage(playerid, -1, "Usage: /l <text>");

    new text[144], pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));

    format(text, sizeof(text), "(LOW) %s : %s", pName, params);

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 10.0, px, py, pz))
        {
            SendClientMessage(i, -1, text);
        }
    }
    return 1;
}

CMD:death(playerid)
{
    if(PlayerDeath[playerid] == 0)
    {
        return 1;
    }
    
    PlayerDeath[playerid] = 0;
    
    SetSpawnInfo(playerid,
        0,
        PlayerSpawn[playerid][pSkin],
        1177.6423,
        -1324.4136,
        14.0740,
        271.25,
        0, 0, 0, 0, 0, 0
    );

    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);

    SpawnPlayer(playerid);

    SetPlayerHealth(playerid, 100);
    
    SendMessageInfo(playerid, "Kamu telah terbangun dari pingsan");

    new query[256];
    mysql_format(g_SQL, query, sizeof(query),
        "UPDATE players SET death = 0 WHERE username='%e'",
        Player[playerid][pName]
    );
    mysql_tquery(g_SQL, query, "SavePlayerData", "i", playerid);

    return 1;
}

CMD:help(playerid)
{
    SendMessageInfo(playerid, "membuka menu help.");
  
    ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST,
        "{CD7000}Detroit {FFFFFF}Roleplay - Help", "Account\nGeneral\nVehicle\nJob\nHouse\nBusines",
        "Pilih",
        "Keluar"
    );
    
    return 1;
}