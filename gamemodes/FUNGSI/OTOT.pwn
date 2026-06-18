public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
  if(newkeys == KEY_NO) {
    if(!IsPlayerInAnyVehicle(playerid)) return 1;
    
    new vehicleid;
    vehicleid = GetPlayerVehicleID(playerid);
    
    if(GetVehicleDriver(vehicleid) != playerid) return 1;
    if(PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel] == 0) return 1;
    
    if(MesinVeh[vehicleid] == false) {
      SendMessageInfo(playerid, "Menghidupkan mesin kendaraan....");
      SetTimerEx("HidupMatiMesinVeh", 2000, false, "iii", playerid, vehicleid, true);
      TextDrawShowForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
    }
    else {
      SendMessageInfo(playerid, "Mematikan mesin kendaraan....");
      SetTimerEx("HidupMatiMesinVeh", 2000, false, "iii", playerid, vehicleid, false);
      TextDrawShowForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
    }
  }
  return 1;
}