stock TerapkanStatusDown(playerid)
{
  TogglePlayerControllable(playerid, false);
  SetPlayerHealth(playerid, 100.0);
  ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.1, true, true, true, true, 1);
  return 1;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason) {
    if(!PlayerDeath[playerid]) {
        PlayerDeath[playerid] = true;
        GetPlayerPos(playerid, PosisiPemain[playerid][pX], PosisiPemain[playerid][pY], PosisiPemain[playerid][pZ]);
        GetPlayerFacingAngle(playerid, PosisiPemain[playerid][pAngle]);
        PosisiPemain[playerid][pInt] = GetPlayerInterior(playerid);
        PosisiPemain[playerid][pVW] = GetPlayerVirtualWorld(playerid);
        SendMessageInfo(playerid, "Kamu sedang sekarat.");
    }

    SpawnPlayer(playerid);
    SetPlayerInterior(playerid, PosisiPemain[playerid][pInt]);
    SetPlayerVirtualWorld(playerid, PosisiPemain[playerid][pVW]);
    SetPlayerPos(playerid, PosisiPemain[playerid][pX], PosisiPemain[playerid][pY], PosisiPemain[playerid][pZ]);
    SetPlayerFacingAngle(playerid, PosisiPemain[playerid][pAngle]);
    SetCameraBehindPlayer(playerid);
    SetTimerEx("TerapkanStatusDown", 2000, false, "i", playerid);
    SimpanDataPemain(playerid);
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
    if(PlayerDeath[playerid]) {
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, Pemain[playerid][pArmor]);
    }
    return 1;
}