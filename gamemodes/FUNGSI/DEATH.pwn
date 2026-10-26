stock BatalkanStatusDown(playerid) {
  KillTimer(TimerDown[playerid]);
  TimerDown[playerid] = 0;
  DownGeneration[playerid]++;
  return 1;
}

stock JadwalkanStatusDown(playerid) {
  BatalkanStatusDown(playerid);
  TogglePlayerControllable(playerid, false);
  TimerDown[playerid] = SetTimerEx("TerapkanStatusDown", 1000, false, "iii", playerid, PlayerSession[playerid], DownGeneration[playerid]);
  return 1;
}

Fungsi: TerapkanStatusDown(playerid, sessionid, generation) {
  if(!IsPlayerAccountReady(playerid) || PlayerSession[playerid] != sessionid || DownGeneration[playerid] != generation || !PlayerDeath[playerid]) return 1;
  TimerDown[playerid] = 0;
  TogglePlayerControllable(playerid, false);
  SetPlayerHealth(playerid, 100.0);
  ApplyAnimationEx(playerid, "SWAT", "gnstwall_injurd", 4.1, false, true, true, true, 0);
  SendMessageInfo(playerid, "Gunakan /death untuk respawn di hospital.");
  return 1;
}

Fungsi: RevivePlayer(playerid, Float:x, Float:y, Float:z) {
    if(!IsPlayerAccountReady(playerid) || !ValidWorldPosition(x, y, z)) return 0;
    BatalkanStatusDown(playerid);
    ClearAnimations(playerid);
    TogglePlayerControllable(playerid, true);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerPos(playerid, x, y, z);
    PlayerDeath[playerid] = false;
    Pemain[playerid][pDarah] = 100.0;
    GetPlayerPos(playerid, PosisiPemain[playerid][pX], PosisiPemain[playerid][pY], PosisiPemain[playerid][pZ]);
    SimpanDataPemain(playerid);
    return 1;
}

stock RespawnPlayerHospital(playerid) {
    if(!IsPlayerAccountReady(playerid) || !PlayerDeath[playerid]) return 0;
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    RevivePlayer(playerid, 1380.94, -41.82, 1001.07);
    SetPlayerFacingAngle(playerid, 0.7);
    GivePlayerMoney(playerid, -100000);
    SimpanDataPemain(playerid);
    SendMessageInfo(playerid, "Paramedis telah menemukan dirimu yang sekarat, dan kamu telah di respawn di rumah sakit.");
    SendMessageInfo(playerid, "Bayaran untuk rumah sakit adalah 100.000");
    return 1;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason) {
    if(!IsPlayerAccountReady(playerid)) return 1;
    if(!PlayerDeath[playerid]) {
        PlayerDeath[playerid] = true;
        SendMessageInfo(playerid, "Kamu sedang sekarat.");
    }

    GetPlayerPos(playerid, PosisiPemain[playerid][pX], PosisiPemain[playerid][pY], PosisiPemain[playerid][pZ]);
    GetPlayerFacingAngle(playerid, PosisiPemain[playerid][pAngle]);
    PosisiPemain[playerid][pInt] = GetPlayerInterior(playerid);
    PosisiPemain[playerid][pVW] = GetPlayerVirtualWorld(playerid);
    Pemain[playerid][pDarah] = 100.0;
    SetSpawnInfo(playerid, NO_TEAM, Pemain[playerid][pSkin], PosisiPemain[playerid][pX], PosisiPemain[playerid][pY], PosisiPemain[playerid][pZ], PosisiPemain[playerid][pAngle]);
    SpawnPlayer(playerid);
    SetCameraBehindPlayer(playerid);
    SimpanDataPemain(playerid);
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
{
    if(IsPlayerAccountReady(playerid) && PlayerDeath[playerid]) {
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, Pemain[playerid][pArmor]);
    }
    return 1;
}
