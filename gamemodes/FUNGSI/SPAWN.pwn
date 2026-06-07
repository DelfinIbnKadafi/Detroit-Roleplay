stock SpawnPemainEx(playerid, bool:new_player = false) 
{
  if(!new_player) 
  {
    SetPlayerHealth(playerid, Pemain[playerid][pDarah]);
    SetPlayerArmour(playerid, Pemain[playerid][pArmor]);
    SetPlayerInterior(playerid, PosisiPemain[playerid][pInt]);
    SetPlayerVirtualWorld(playerid, PosisiPemain[playerid][pVW]);
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
    
    ShowHbeTextdraw(playerid);
    
    StatusLogin[playerid] = true;
    SpawnPlayer(playerid);
    MuatDataKendaraan(playerid);
    
  }
  else 
  {
    SetPlayerHealth(playerid, 100.0);
    SetSpawnInfo(
      playerid,
      NO_TEAM,
      Pemain[playerid][pGender] ? DEFAULT_MALE_SKIN : DEFAULT_FEMALE_SKIN,
      DEFAULT_POS_X,
      DEFAULT_POS_Y,
      DEFAULT_POS_Z,
      DEFAULT_POS_A
    );    
    SetPlayerScore(playerid, 1);
    GivePlayerMoney(playerid, 100000);
  }
  Pemain[playerid][pHaus] = 100;
  Pemain[playerid][pLapar] = 100;
  Pemain[playerid][pDarah] = 100.0;
  
  ShowHbeTextdraw(playerid);
  MuatDataKendaraan(playerid);
  
  StatusLogin[playerid] = true;
  
  ShowGreetings(playerid);
  SpawnPlayer(playerid);
  return 1;
}