// pay/berikan uang
CMD:pay(playerid, params[]) {
  new jumlah, targetid, msg[256];
  
  if(sscanf(params, "ud", targetid, jumlah)) {
    SendClientMessage(playerid, -1, "Gunakan: /pay <target> <jumlah>");
    return 1;
  }
  if(targetid == playerid) {
    SendMessageError(playerid, "kamu tidak bisa memberi uang kedirimu sendiri!");
    return 1;
  }
  if(GetPlayerMoney(playerid) < jumlah) {
    SendMessageError(playerid, "Uangmu tidak cukup!");
    return 1;
  }
  if(jumlah < 1000 || jumlah > 1000000) {
    SendMessageError(playerid, "Jumlah uang yang diberikan minimal 1000 rupiah dan maksimal 1.000.000 rupiah");
    return 1;
  }
  if(!IsPlayerConnected(targetid)) {
    SendMessageError(playerid, "Pemain yang dituju tidak online!");
    return 1;
  }
  
  new Float:x, Float:y, Float:z, Float:prabowo;
  GetPlayerPos(playerid, x, y, z);
  new nama_target[MAX_PLAYER_NAME];
  GetPlayerName(targetid, nama_target, MAX_PLAYER_NAME);
  
  new Float:jarak = GetPlayerDistanceFromPoint(targetid, x, y, z);
  if(jarak <= 3.0) {
    GivePlayerMoney(playerid, -jumlah);
    GivePlayerMoney(targetid, jumlah);
    
    ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, false, false, false, false, 4670);
    ApplyAnimation(targetid, "DEALER", "DEALER_DEAL", 4.1, false, false, false, false, 3170);
    
    format(msg, sizeof(msg), "%s memberikan uang sebanyak %d rupiah kepada %s", Pemain[playerid][pNama], jumlah, nama_target);
    SendClientMessage(playerid, 0x6B0E66FF, msg);
    
    foreach(new i:Player) {
      if(!IsPlayerConnected(i) || i == playerid) continue;
      prabowo = GetPlayerDistanceFromPoint(i, x, y, z);
      if (prabowo <= 10.0) {
        SendClientMessage(i, 0x6B0E66FF, msg);
      }
    }
  }
  else {
    SendMessageError(playerid, "Pemain yang dituju tidak berada didekatmu!");
    return 1;
  }
  return 1;
}




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
    
    if(PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel] == 0) return 1;
    
    if(MesinVeh[vehicleid] == false) {
      SendMessageInfo(playerid, "Menghidupkan mesin kendaraan");
      MesinVeh[vehicleid] = true;
      SetVehicleParamsEx(vehicleid, 1, 0, 0, PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vKunci], 0, 0, 0);
    }
    else {
      SendMessageInfo(playerid, "Mematikan mesin kendaraan");
      MesinVeh[vehicleid] = false;
      SetVehicleParamsEx(vehicleid, 0, 0, 0, PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vKunci], 0, 0, 0);
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