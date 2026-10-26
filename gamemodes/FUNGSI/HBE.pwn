Fungsi: KurangiLapar(playerid, sessionid) {
  if(!IsPlayerAccountReady(playerid) || PlayerSession[playerid] != sessionid) return 1;
  if(Pemain[playerid][pLapar] > 0) {
    Pemain[playerid][pLapar] --;
  }
  return 1;
}

Fungsi: KurangiHaus(playerid, sessionid) {
  if(!IsPlayerAccountReady(playerid) || PlayerSession[playerid] != sessionid) return 1;
  if(Pemain[playerid][pHaus] > 0) {
    Pemain[playerid][pHaus] --;
  }
  return 1;
}

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
    
    KillTimer(TimerHBE[playerid]);
    KillTimer(TimerLapar[playerid]);
    KillTimer(TimerHaus[playerid]);
    
    TimerHBE[playerid] = SetTimerEx("UpdateTextdrawHbe", 5000, true, "ii", playerid, PlayerSession[playerid]);
    TimerLapar[playerid] = SetTimerEx("KurangiLapar", 180000, true, "ii", playerid, PlayerSession[playerid]);
    TimerHaus[playerid] = SetTimerEx("KurangiHaus", 120000, true, "ii", playerid, PlayerSession[playerid]);
  }
  else {
    for(new i = 0; i < 3; i++) {
      TextDrawHideForPlayer(playerid, BACKGROUND_HBE[i]);
    }
    PlayerTextDrawHide(playerid, STATS[playerid][0]);
    PlayerTextDrawHide(playerid, STATS[playerid][1]);
    
    KillTimer(TimerHBE[playerid]);
    KillTimer(TimerLapar[playerid]);
    KillTimer(TimerHaus[playerid]);
    TimerHBE[playerid] = 0;
    TimerLapar[playerid] = 0;
    TimerHaus[playerid] = 0;
  }
  return 1;
}

Fungsi: UpdateTextdrawHbe(playerid, sessionid) {
  if(!IsPlayerAccountReady(playerid) || PlayerSession[playerid] != sessionid) return 1;
  new str[16];
  format(str, sizeof(str), "%d", Pemain[playerid][pLapar]);
  PlayerTextDrawSetString(playerid, STATS[playerid][0], str);
  
  format(str, sizeof(str), "%d", Pemain[playerid][pHaus]);
  PlayerTextDrawSetString(playerid, STATS[playerid][1], str);
  return 1;
}
