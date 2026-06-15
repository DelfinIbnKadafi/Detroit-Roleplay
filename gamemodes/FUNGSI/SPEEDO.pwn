Fungsi: UpdateSpeedoMeter(playerid) {
  if(!IsPlayerInAnyVehicle(playerid)) return 1;
  
  new vehicleid = GetPlayerVehicleID(playerid);
  new speed = GetVehicleSpeed(vehicleid);
  
  new str[16];
  format(str, sizeof(str), "%d", speed);
  PlayerTextDrawSetString(playerid, VEHSPEED[playerid][2], str);
  
  new len = strlen(str);
  
  if(len == 1) {
    PlayerTextDrawSetPos(playerid, VEHSPEED[playerid][2], 495.000 + 4.000, 402.000);
  }
  else if(len == 2) {
    PlayerTextDrawSetPos(playerid, VEHSPEED[playerid][2], 495.000 + 8.000, 402.000);
  }
  else if(len == 3) {
    PlayerTextDrawSetPos(playerid, VEHSPEED[playerid][2], 495.000, 402.000);
  }
  
  format(str, sizeof(str), "%d", PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel]);
  PlayerTextDrawSetString(playerid, VEHSPEED[playerid][1], str);
  
  new Float:floathealth;
  GetVehicleHealth(vehicleid, floathealth);
  new hpveh = floatround(floathealth, floatround_floor) / 10;
  format(str, sizeof(str), "%d", hpveh);
  PlayerTextDrawSetString(playerid, VEHSPEED[playerid][0], str);
  
  return 1;
}

stock ShowHideSpeedo(playerid, bool:showorhide) {
  if(showorhide == true) {
    for(new i  = 0; i < 4;  i++) {
      TextDrawShowForPlayer(playerid, BACKGROUND_SPEDO[i]);
    }
    for(new i = 0; i <  3; i ++) {
      PlayerTextDrawShow(playerid, VEHSPEED[playerid][i]);
    }
    
    new vehicleid = GetPlayerVehicleID(playerid);
    new speed = GetVehicleSpeed(vehicleid);
    
    new str[16];
    format(str, sizeof(str), "%d", speed);
    PlayerTextDrawSetString(playerid, VEHSPEED[playerid][2], str);
    
    format(str, sizeof(str), "%d", PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel]);
    PlayerTextDrawSetString(playerid, VEHSPEED[playerid][1], str);
    
    new Float:floathealth;
    GetVehicleHealth(vehicleid, floathealth);
    new hpveh = floatround(floathealth, floatround_floor) / 10;
    format(str, sizeof(str), "%d", hpveh);
    PlayerTextDrawSetString(playerid, VEHSPEED[playerid][0], str);
    
    SetTimerEx("UpdateSpeedoMeter", 250, true, "i",  playerid);
  }
  else {
    for(new i = 0; i < 4; i++) {
      TextDrawHideForPlayer(playerid, BACKGROUND_SPEDO[i]);
    }
    for(new i = 0; i <  3; i ++) {
      PlayerTextDrawHide(playerid, VEHSPEED[playerid][i]);
    }
  }
  return 1;
}