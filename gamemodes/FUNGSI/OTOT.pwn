public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
  if((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK)) {
    if(IsPlayerInAnyVehicle(playerid)) return 1;
    if(DeteksiPintuBalaiKota(playerid)) return 1;
    if(DeteksiPintuHospital(playerid)) return 1;
  }
  if((newkeys & KEY_NO) && !(oldkeys & KEY_NO)) {
    if(!IsPlayerInAnyVehicle(playerid)) return 1;
    
    new vehicleid;
    vehicleid = GetPlayerVehicleID(playerid);
    if(!IsPlayerOwnedVehicle(vehicleid)) return 1;
    if(GetVehicleDriver(vehicleid) != playerid) return 1;
    if(PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel] == 0) {
      SendMessageError(playerid, "Bahan bakar kendaraan ini sudah habis!");
      return 1;
    }
    
    if(MesinVeh[vehicleid] == false) {
      SendMessageInfo(playerid, "Menghidupkan mesin kendaraan....");
      SetTimerEx("HidupMatiMesinVeh", 2000, false, "iiii", playerid, vehicleid, true, PlayerSession[playerid]);
      TextDrawShowForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
    }
    else {
      SendMessageInfo(playerid, "Mematikan mesin kendaraan....");
      SetTimerEx("HidupMatiMesinVeh", 2000, false, "iiii", playerid, vehicleid, false, PlayerSession[playerid]);
      TextDrawShowForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
    }
  }
  return 1;
}