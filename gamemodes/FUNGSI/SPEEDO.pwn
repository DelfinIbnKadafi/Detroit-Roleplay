UpdateSpeedo(playerid)
{
  if(!IsPlayerInAnyVehicle(playerid)) return 1;

  new vehicleid = GetPlayerVehicleID(playerid);

  new Float:vx, Float:vy, Float:vz;
  new Float:speedFloat;
  new speed;

  new Float:vHealth;
  new hp;
  new fuel;

  GetVehicleVelocity(vehicleid, vx, vy, vz);

  speedFloat = floatsqroot((vx * vx) + (vy * vy) + (vz * vz)) * 180.0;
  speed = floatround(speedFloat, floatround_floor);

  new str[32];

  format(str, sizeof(str), "%d KM/H", speed);
  PlayerTextDrawSetString(playerid, VehSpeed[playerid], str);

  GetVehicleHealth(vehicleid, vHealth);
  hp = floatround(vHealth, floatround_floor);

  format(str, sizeof(str), "%d", hp);
  PlayerTextDrawSetString(playerid, HealthVeh[playerid], str);

  fuel = PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel];

  format(str, sizeof(str), "%d", fuel);
  PlayerTextDrawSetString(playerid, FuelVeh[playerid], str);

  return 1;
}

stock HideSpeedoMeter(playerid) {
  for(new i = 0; i < 10; i++) {
    TextDrawHideForPlayer(playerid, Backround_Speedo[i]);
  }
  
  PlayerTextDrawHide(playerid, VehSpeed[playerid]);
  PlayerTextDrawHide(playerid, HealthVeh[playerid]);
  PlayerTextDrawHide(playerid, FuelVeh[playerid]);

  return 1;
}

stock ShowSpeedoMeter(playerid) {
  for(new i = 0; i < 10; i++) {
    TextDrawShowForPlayer(playerid, Backround_Speedo[i]);
  }

  PlayerTextDrawShow(playerid, VehSpeed[playerid]);
  PlayerTextDrawShow(playerid, HealthVeh[playerid]);
  PlayerTextDrawShow(playerid, FuelVeh[playerid]);

  SetTimerEx("UpdateSpeedo", 500, true, "i", playerid);

  return 1;
}