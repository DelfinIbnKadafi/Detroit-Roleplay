Fungsi:UpdateSpeedoMeter(playerid) {
  if(!IsPlayerAccountReady(playerid)) return 1;
  if(!IsPlayerInAnyVehicle(playerid)) return ShowHideSpeedo(playerid, false);
  new vehicleid = GetPlayerVehicleID(playerid);
  if(!IsValidVehicle(vehicleid)) return ShowHideSpeedo(playerid, false);

  new str[16];
  format(str, sizeof(str), "%d", GetVehicleSpeed(vehicleid));
  PlayerTextDrawSetString(playerid, VEHSPEED[playerid][2], str);

  // Bahan bakar hanya untuk kendaraan yang memakai sistem bahan bakar, selain itu tampil "-".
  if(IsVehicleFuelEnabled(vehicleid)) format(str, sizeof(str), "%d", GetFuelKendaraan(vehicleid));
  else format(str, sizeof(str), "-");
  PlayerTextDrawSetString(playerid, VEHSPEED[playerid][1], str);

  format(str, sizeof(str), "%d", GetHealthPersenKendaraan(vehicleid));
  PlayerTextDrawSetString(playerid, VEHSPEED[playerid][0], str);
  return 1;
}

Fungsi:TimerUpdateSpeedo(playerid, sessionid) {
  if(!IsPlayerAccountReady(playerid) || PlayerSession[playerid] != sessionid) return 1;
  return UpdateSpeedoMeter(playerid);
}

stock ShowHideSpeedo(playerid, bool:showorhide) {
  KillTimer(TimerSpedo[playerid]);
  TimerSpedo[playerid] = 0;
  if(showorhide) {
    new vehicleid = GetPlayerVehicleID(playerid);
    if(!IsPlayerInAnyVehicle(playerid) || !IsValidVehicle(vehicleid)) return 0;
    // Isi nilainya sebelum textdraw ditampilkan, termasuk kesehatan 0 untuk kendaraan mati.
    UpdateSpeedoMeter(playerid);
    for(new i = 0; i < 4; i++) TextDrawShowForPlayer(playerid, BACKGROUND_SPEDO[i]);
    for(new i = 0; i < 3; i++) PlayerTextDrawShow(playerid, VEHSPEED[playerid][i]);
    TimerSpedo[playerid] = SetTimerEx("TimerUpdateSpeedo", 250, true, "ii", playerid, PlayerSession[playerid]);
  }
  else {
    for(new i = 0; i < 4; i++) TextDrawHideForPlayer(playerid, BACKGROUND_SPEDO[i]);
    for(new i = 0; i < 3; i++) PlayerTextDrawHide(playerid, VEHSPEED[playerid][i]);
  }
  return 1;
}
