// pay/berikan uang
CMD:pay(playerid, params[]) {
  new jumlah, targetid, msg[256];
  
  if(sscanf(params, "ud", targetid, jumlah)) {
    SendClientMessage(playerid, -1, "Gunakan: /pay <target> <jumlah>");
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
////////////////////////////////////////////////////////////////////////////////////////////////