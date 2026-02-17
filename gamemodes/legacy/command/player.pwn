// command
CMD:help(playerid)
{
    SendMessageInfo(playerid, "membuka menu help.");
  
    ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST,
        {CD7000}Detroit {FFFFFF}Roleplay - Help", "Account\nGeneral\nVehicle\nJob\nHouse\nBusines",
        "Pilih",
        "Keluar"
    );
    
    return 1;
}

CMD:me(playerid, params[])
{
    new text[128];

    if (isnull(params))
        return SendClientMessage(playerid, -1, "Usage: /me <text>");

    format(text, sizeof(text), "%s %s", Player[playerid][pName], params);

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;

        new Float:ix, Float:iy, Float:iz;
        GetPlayerPos(i, ix, iy, iz);

        if(GetDistanceBetweenCoords(px, py, pz, ix, iy, iz) <= 20.0)
        {
            SendClientMessage(i, 0x6B0E66FF, text);
        }
    }
    return 1;
}

CMD:do(playerid, params[])
{
    new text[128];

    if (isnull(params))
        return SendClientMessage(playerid, -1, "Usage: /do <text>");

    format(text, sizeof(text), "%s (%s)", params, Player[playerid][pName]);

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;

        new Float:ix, Float:iy, Float:iz;
        GetPlayerPos(i, ix, iy, iz);

        if(GetDistanceBetweenCoords(px, py, pz, ix, iy, iz) <= 20.0)
        {
            SendClientMessage(i, 0x6B0E66FF, text);
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
        271.25
        0, 0, 0, 0, 0, 0
    );

    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);

    SpawnPlayer(playerid);

    SetPlayerHealth(playerid, 100);
    
    SendMessageInfo(playerid, "Kamu telah terbangun dari pingsan")
    
    new query[256];
    mysql_format(g_SQL, query, sizeof(query),
        "UPDATE players SET death = 0 WHERE username='%e'",
        Player[playerid][pName]
    );
    mysql_tquery(g_SQL, query, "SavePlayerData", "i", playerid);
}