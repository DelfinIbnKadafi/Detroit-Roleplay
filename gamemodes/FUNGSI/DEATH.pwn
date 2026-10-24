Fungsi: TerapkanStatusDown(playerid) {
  TogglePlayerControllable(playerid, false);
  SetPlayerHealth(playerid, 100.0);
  ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.1, false, true, true, true, 1);
  SendMessageInfo(playerid, "Gunakan /death untuk respawn di hospital.");
  return 1;
}

Fungsi: RevivePlayer(playerid, Float:x, Float:y, Float:z) {
    ClearAnimations(playerid);
    TogglePlayerControllable(playerid, true);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerPos(playerid, x, y, z);
    PlayerDeath[playerid] = false;
    return 1;
}

stock RespawnPlayerHospital(playerid) {
    RevivePlayer(playerid, 1380.94, -41.82, 1001.07);
    SetPlayerFacingAngle(playerid, 0.7);
    GivePlayerMoney(playerid, -100000);
    SendMessageInfo(playerid, "Paramedis telah menemukan dirimu yang sekarat, dan kamu telah di respawn di rumah sakit.");
    SendMessageInfo(playerid, "Bayaran untuk rumah sakit adalah 100.000");
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
    TogglePlayerControllable(playerid, false);
    SetTimerEx("TerapkanStatusDown", 500, false, "i", playerid);
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