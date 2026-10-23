public OnPlayerDeath(playerid, killerid, WEAPON:reason) {
    if(!PlayerDeath[playerid]) {
        PlayerDeath[playerid] = true;
        GetPlayerPos(playerid, PosisiPemain[playerid][pX], PosisiPemain[playerid][pY], PosisiPemain[playerid][pZ]);
        SpawnPlayer(playerid);
        SetPlayerPos(playerid, PosisiPemain[playerid][pX], PosisiPemain[playerid][pY], PosisiPemain[playerid][pZ]);
        SimpanDataPemain(playerid);
        TogglePlayerControllable(playerid, false);
        SendMessageInfo(playerid, "Kamu sedang sekarat.");
        ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.1, true, true, true, true, 1);
    }
    return 1;
}