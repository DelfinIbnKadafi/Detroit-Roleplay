stock ShowHideHbeTextdraw(playerid, bool:showorhide) {
  if(showorhide == true) {
    for(new i = 0; i < 3; i++) {
      TextDrawShowForPlayer(playerid, BACKGROUND_HBE[i]);
    }
    PlayerTextDrawShow(playerid, STATS[playerid][0]);
    PlayerTextDrawShow(playerid, STATS[playerid][1]);
    
    new str[16];
    format(str, sizeof(str), "%d", Pemain[playerid][pLapar]);
    PlayerTextDrawSetString(playerid, STATS[playerid][0], str);
    
    format(str, sizeof(str), "%d", Pemain[playerid][pHaus]);
    PlayerTextDrawSetString(playerid, STATS[playerid][1], str);
    
    SetTimerEx("UpdateTextdrawHbe", 1000, true, "i", playerid);
    SetTimerEx("KurangiLaparHaus", 120000, true, "i", playerid);
  }
  else {
    for(new i = 0; i < 3; i++) {
      TextDrawHideForPlayer(playerid, BACKGROUND_HBE[i]);
    }
    PlayerTextDrawHide(playerid, STATS[playerid][0]);
    PlayerTextDrawHide(playerid, STATS[playerid][1]);
  }
  return 1;
}

Fungsi: UpdateTextdrawHbe(playerid) {
  new str[16];
  format(str, sizeof(str), "%d", Pemain[playerid][pLapar]);
  PlayerTextDrawSetString(playerid, STATS[playerid][0], str);
  
  format(str, sizeof(str), "%d", Pemain[playerid][pHaus]);
  PlayerTextDrawSetString(playerid, STATS[playerid][1], str);
  return 1;
}

Fungsi: KurangiLaparHaus(playerid) {
  if(Pemain[playerid][pLapar] > 0) {
    Pemain[playerid][pLapar] -= 1;
  }
  if(Pemain[playerid][pHaus] > 0) {
    Pemain[playerid][pHaus] -= 1;
  }
  return 1;
}