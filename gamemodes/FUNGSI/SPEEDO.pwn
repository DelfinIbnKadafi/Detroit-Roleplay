Fungsi: UpdateSpeedo(playerid) {
  if(!IsPlayerInAnyVehicle(playerid)) return 1;
  
  new vehicleid = GetPlayerVehicleID(playerid);
  if(!IsValidVehicle(vehicleid)) return 1;
  
  new speed = GetVehicleSpeed(playerid);
  
  new owner = VehOwner[vehicleid];
  
  
  return 1;
}

stock HideSpeedoMeter(playerid) {
  
  return 1;
}

stock ShowSpeedoMeter(playerid) {

  return 1;
}