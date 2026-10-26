

stock SpawnPemainEx(playerid, bool:new_player = false) 
{
  ResetPlayerMoney(playerid);
  if(!new_player) 
  {
    SetPlayerScore(playerid, Pemain[playerid][pLevel]);
    GivePlayerMoney(playerid, Pemain[playerid][pUang]);

    SetSpawnInfo(
      playerid,
      NO_TEAM,
      Pemain[playerid][pSkin],
      PosisiPemain[playerid][pX],
      PosisiPemain[playerid][pY],
      PosisiPemain[playerid][pZ],
      PosisiPemain[playerid][pAngle]
    );

    MuatDataKendaraan(playerid);
    
  }
  else 
  {
    NewPlayerPendingSave[playerid] = true;
    VehiclesLoaded[playerid] = true;
    Pemain[playerid][pLevel] = 1;
    Pemain[playerid][pSkin] = Pemain[playerid][pGender] == 2 ? DEFAULT_FEMALE_SKIN : DEFAULT_MALE_SKIN;
    Pemain[playerid][pDarah] = 100.0;
    Pemain[playerid][pArmor] = 0.0;
    Pemain[playerid][pUang] = 100000;
    PosisiPemain[playerid][pX] = DEFAULT_POS_X;
    PosisiPemain[playerid][pY] = DEFAULT_POS_Y;
    PosisiPemain[playerid][pZ] = DEFAULT_POS_Z;
    PosisiPemain[playerid][pAngle] = DEFAULT_POS_A;
    PosisiPemain[playerid][pInt] = 0;
    PosisiPemain[playerid][pVW] = 0;
    SetSpawnInfo(
      playerid,
      NO_TEAM,
      Pemain[playerid][pGender] == 2 ? DEFAULT_FEMALE_SKIN : DEFAULT_MALE_SKIN,
      DEFAULT_POS_X,
      DEFAULT_POS_Y,
      DEFAULT_POS_Z,
      DEFAULT_POS_A
    );    
    SetPlayerScore(playerid, 1);
    GivePlayerMoney(playerid, 100000);
    
    Pemain[playerid][pHaus] = 100;
    Pemain[playerid][pLapar] = 100;
    Pemain[playerid][pDarah] = 100.0;
    if(Pemain[playerid][pNorek] <= 0) Pemain[playerid][pNorek] = random(900000000) + 100000000;
    
    Pemain[playerid][pKtp] = 0;
    
    Admin[playerid] = 0;
    
    format(Pemain[playerid][pDateBirth],  64, "None");
  }

  ShowHideHbeTextdraw(playerid, true);
  StatusLogin[playerid] = true;
  PlayerLoginStep[playerid] = LOGIN_FINISHED;

  ShowGreetings(playerid);
  SpawnPlayer(playerid);
  if(PlayerDeath[playerid]) {
    SendMessageInfo(playerid, "Terakhir kali kamu login adalah saat kamu sedang sekarat.");
  }

  if(Admin[playerid] > 0) {
    SendMessageServer(playerid, "Kamu memiliki akses sebagai admin, gunakan /ahelp untuk daftar command admin.");
  }
  KillTimer(TimerAutoSave[playerid]);
  TimerAutoSave[playerid] = SetTimerEx("AutoSavePlayer", 300000, true, "ii", playerid, PlayerSession[playerid]);

  return 1;
}

public OnPlayerSpawn(playerid)
{
  if(!StatusLogin[playerid]) return 1;
  SetPlayerHealth(playerid, Pemain[playerid][pDarah]);
  SetPlayerArmour(playerid, Pemain[playerid][pArmor]);
  SetPlayerInterior(playerid, PosisiPemain[playerid][pInt]);
  SetPlayerVirtualWorld(playerid, PosisiPemain[playerid][pVW]);
  if(PlayerDeath[playerid]) JadwalkanStatusDown(playerid);
  else TogglePlayerControllable(playerid, true);
  if(NewPlayerPendingSave[playerid]) {
    NewPlayerPendingSave[playerid] = false;
    SimpanDataPemain(playerid);
  }
  return 1;
}
