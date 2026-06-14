stock ShowHbeTextdraw(playerid) {
  /*for(new i = 0; i < 10; i++) {
      TextDrawShowForPlayer(playerid, BACKROUNd_HBE[i]);
  }*/

  new lapar[4], haus[4], nyawa[4];
  
  format(nyawa, sizeof(nyawa), "%d", floatround(Pemain[playerid][pDarah], floatround_floor));
  format(lapar, sizeof(lapar), "%d", Pemain[playerid][pLapar]);
  format(haus,  sizeof(haus),  "%d", Pemain[playerid][pHaus]);
  
  PlayerTextDrawSetString(playerid, HBE_LAPAR[playerid], lapar);
  PlayerTextDrawSetString(playerid, HBE_HAUS[playerid],  haus);
  PlayerTextDrawSetString(playerid, HBE_NYAWA[playerid], nyawa);
  
  PlayerTextDrawShow(playerid, HBE_LAPAR[playerid]);
  PlayerTextDrawShow(playerid, HBE_HAUS[playerid]);
  PlayerTextDrawShow(playerid, HBE_NYAWA[playerid]);
  
  SetTimerEx("UpdateTextdrawHbe", 1000, true, "i", playerid);
  SetTimerEx("KurangiLaparHaus", 180000, true, "i", playerid);
  return 1;
}

Fungsi: UpdateTextdrawHbe(playerid) {
  new lapar[4], haus[4], nyawa[4];
  
  GetPlayerHealth(playerid, Pemain[playerid][pDarah]);
  
  format(nyawa, sizeof(nyawa), "%d", floatround(Pemain[playerid][pDarah], floatround_floor));
  format(lapar, sizeof(lapar), "%d", Pemain[playerid][pLapar]);
  format(haus,  sizeof(haus),  "%d", Pemain[playerid][pHaus]);
  
  PlayerTextDrawSetString(playerid, HBE_LAPAR[playerid], lapar);
  PlayerTextDrawSetString(playerid, HBE_HAUS[playerid],  haus);
  PlayerTextDrawSetString(playerid, HBE_NYAWA[playerid], nyawa);
  return 1;
}

Fungsi: KurangiLaparHaus(playerid) {
  if(Pemain[playerid][pLapar] == 0) return 1;
  if(Pemain[playerid][pHaus] == 0) return 1;
  
  Pemain[playerid][pLapar]--;
  Pemain[playerid][pHaus]--;
  
  return 1;
}