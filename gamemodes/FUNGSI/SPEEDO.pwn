Fungsi:UpdateSpeedoMeter(playerid) {
  if(!IsPlayerAccountReady(playerid)) return 1;
  if(!IsPlayerInAnyVehicle(playerid)) return ShowHideSpeedo(playerid, false);
  new vehicleid = GetPlayerVehicleID(playerid);
  if(!IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid)) return ShowHideSpeedo(playerid, false);

  new str[16];
  format(str, sizeof(str), "%d", GetVehicleSpeed(vehicleid));
  PlayerTextDrawSetString(playerid, VEHSPEED[playerid][2], str);
  format(str, sizeof(str), "%d", PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel]);
  PlayerTextDrawSetString(playerid, VEHSPEED[playerid][1], str);

  new hpveh = 0;
  if(!IsDeadPlayerVehicle(vehicleid)) {
    new Float:health;
    GetVehicleHealth(vehicleid, health);
    if(health > VEHICLE_CRITICAL_HEALTH) {
        if(health > 1000.0) health = 1000.0;
        hpveh = floatround((health - VEHICLE_CRITICAL_HEALTH) / (1000.0 - VEHICLE_CRITICAL_HEALTH) * 100.0, floatround_floor);
    }
  }
  format(str, sizeof(str), "%d", hpveh);
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
    if(!IsPlayerInAnyVehicle(playerid) || !IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid)) return 0;
    // Fill the values before showing the textdraw, including health 0 for dead vehicles.
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
