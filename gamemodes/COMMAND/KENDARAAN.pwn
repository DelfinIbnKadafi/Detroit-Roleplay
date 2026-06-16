// kendaraan
CMD:myveh(playerid, params[]) {
  if(JumVeh[playerid] == 0) {
    SendMessageInfo(playerid, "Kamu tidak memiliki kendaraan!");
    return 1;
  }

  new liststr[256], line[64];
  for(new i = 0; i < JumVeh[playerid]; i++) {
    new vnama[32];
    GetVehicleModelName(PVeh[playerid][i][vModel], vnama, sizeof(vnama));
    format(line, sizeof(line), "%d\t%s\n", PVeh[playerid][i][vId], vnama);
    strcat(liststr, line, sizeof(liststr));
  }
  Dialog_Show(playerid, DL_VEHLIST, DIALOG_STYLE_LIST, "Id\tModel", liststr, "Pilih", "Batal");
  return 1;
}

CMD:en(playerid, params[]) {
  if(!IsPlayerInAnyVehicle(playerid)) {
    SendMessageError(playerid, "Kamu tidak berada di kendaraan manapun");
    return 1;
  }
  else {
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

CMD:lockveh(playerid, params[]) {
  
  if(IsPlayerInAnyVehicle(playerid)) {
    new vehicleid = GetPlayerVehicleID(playerid);
    new Float:vx, Float:vy, Float:vz;
    GetVehiclePos(vehicleid, vx, vy, vz);
    if(IsPlayerInRangeOfPoint(playerid, 4.0, vx, vy, vz)) {
      if(VehOwner[vehicleid] != playerid) {
        return 1;
      }
      else {
        if(PVeh[playerid][VehSlot[vehicleid]][vKunci] == 0) {
          PVeh[playerid][VehSlot[vehicleid]][vKunci] = 1;
          SetVehicleParamsEx(vehicleid, MesinVeh[vehicleid], 0, 0, 1, 0, 0, 0);
          SendMessageInfo(playerid, "Kendaraan berhasil dikunci.");
        }
        else {
          PVeh[playerid][VehSlot[vehicleid]][vKunci] = 0;
          SetVehicleParamsEx(vehicleid, MesinVeh[vehicleid], 0, 0, 0, 0, 0, 0);
          SendMessageInfo(playerid, "Kunci kendaraan berhasil dibuka.");
        }
      }
    }
    return 1;
  }
  
  for(new i = 0; i < JumVeh[playerid]; i++) {
    new Float:vx, Float:vy, Float:vz;
    
    if(!IsValidVehicle(VehID[PVeh[playerid][i][vId]])) {
      continue;
    }
    
    GetVehiclePos(VehID[PVeh[playerid][i][vId]], vx, vy, vz);
    if(!IsPlayerInRangeOfPoint(playerid, 4.0, vx, vy, vz)) {
      continue;
    }
    else {
      if(PVeh[playerid][i][vKunci] == 0) {
        PVeh[playerid][i][vKunci] = 1;
        SetVehicleParamsEx(VehID[PVeh[playerid][i][vId]], MesinVeh[VehID[PVeh[playerid][i][vId]]], 0, 0, 1, 0, 0, 0);
        SendMessageInfo(playerid, "Kendaraan berhasil dikunci.");
        return 1;
      }
      else {
        PVeh[playerid][i][vKunci] = 0;
        SetVehicleParamsEx(VehID[PVeh[playerid][i][vId]], MesinVeh[VehID[PVeh[playerid][i][vId]]], 0, 0, 0, 0, 0, 0);
        SendMessageInfo(playerid, "Kunci kendaraan berhasil dibuka.");
        return 1;
      }
    }
  }
  return 1;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////