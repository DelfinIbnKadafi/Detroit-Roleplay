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
  Dialog_Show(playerid, DL_VEHLIST, DIALOG_STYLE_TABLIST, "Id\tModel", liststr, "Pilih", "Batal");
  return 1;
}

CMD:en(playerid, params[]) {
  return ToggleMesinKendaraan(playerid);
}

CMD:lockveh(playerid, params[]) {
  
  if(IsPlayerInAnyVehicle(playerid)) {
    new vehicleid = GetPlayerVehicleID(playerid);
    if(!IsPlayerOwnedVehicle(vehicleid)) {
      SendMessageError(playerid, "Ini bukan kendaraan milikmu!");
      return 1;
    }
    if(!IsVehicleInPlayerWorld(playerid, vehicleid)) return SendMessageError(playerid, "Kamu terlalu jauh dari kendaraan ini.");
    new Float:vx, Float:vy, Float:vz;
    GetVehiclePos(vehicleid, vx, vy, vz);
    if(IsPlayerInRangeOfPoint(playerid, 4.0, vx, vy, vz)) {
      if(VehOwner[vehicleid] != playerid) {
        SendMessageError(playerid, "Ini bukan kendaraan milikmu!");
        return 1;
      }
      else {
        if(PVeh[playerid][VehSlot[vehicleid]][vKunci] == 0) {
          PVeh[playerid][VehSlot[vehicleid]][vKunci] = 1;
          SetVehicleEngineAndLock(vehicleid, MesinVeh[vehicleid], true);
          SendMessageInfo(playerid, "Kendaraan berhasil dikunci.");
        }
        else {
          PVeh[playerid][VehSlot[vehicleid]][vKunci] = 0;
          SetVehicleEngineAndLock(vehicleid, MesinVeh[vehicleid], false);
          SendMessageInfo(playerid, "Kunci kendaraan berhasil dibuka.");
        }
      }
    }
    return 1;
  }
  
  for(new i = 0; i < JumVeh[playerid]; i++) {
    new Float:vx, Float:vy, Float:vz;
    new vehicleid = GetOwnedVehicleInSlot(playerid, i);
    
    if(!IsVehicleInPlayerWorld(playerid, vehicleid)) {
      continue;
    }
    
    GetVehiclePos(vehicleid, vx, vy, vz);
    if(!IsPlayerInRangeOfPoint(playerid, 4.0, vx, vy, vz)) {
      continue;
    }
    else {
      if(PVeh[playerid][i][vKunci] == 0) {
        PVeh[playerid][i][vKunci] = 1;
        SetVehicleEngineAndLock(vehicleid, MesinVeh[vehicleid], true);
        SendMessageInfo(playerid, "Kendaraan berhasil dikunci.");
        return 1;
      }
      else {
        PVeh[playerid][i][vKunci] = 0;
        SetVehicleEngineAndLock(vehicleid, MesinVeh[vehicleid], false);
        SendMessageInfo(playerid, "Kunci kendaraan berhasil dibuka.");
        return 1;
      }
    }
  }
  return 1;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////