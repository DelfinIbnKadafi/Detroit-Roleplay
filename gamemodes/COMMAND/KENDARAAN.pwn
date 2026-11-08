// kendaraan
CMD:myveh(playerid, params[]) {
  if(PVehInfo[playerid][viJumlah] == 0) {
    SendMessageInfo(playerid, "Kamu tidak memiliki kendaraan!");
    return 1;
  }

  new liststr[256], line[64];
  for(new i = 0; i < PVehInfo[playerid][viJumlah]; i++) {
    new vnama[32];
    GetVehicleModelName(PVeh[playerid][i][vModel], vnama, sizeof(vnama));
    format(line, sizeof(line), "%d\t%s\n", PVeh[playerid][i][vId], vnama);
    strcat(liststr, line, sizeof(liststr));
  }
  Dialog_Show(playerid, DL_VEHLIST, DIALOG_STYLE_TABLIST, "ID\tModel", liststr, "Pilih", "Batal");
  return 1;
}

CMD:en(playerid, params[]) {
  return ToggleMesinKendaraan(playerid);
}

CMD:lockveh(playerid, params[]) {
  // Pemain sedang berada di dalam kendaraan: kunci kendaraan yang sedang dinaiki
  if(IsPlayerInAnyVehicle(playerid)) {
    new vehicleid = GetPlayerVehicleID(playerid);
    if(!IsPlayerOwnedVehicle(vehicleid)) return SendMessageError(playerid, "Ini bukan kendaraan milikmu!");
    if(!IsVehicleInPlayerWorld(playerid, vehicleid)) return SendMessageError(playerid, "Kamu terlalu jauh dari kendaraan ini.");
    if(!IsPlayerDekatKendaraan(playerid, vehicleid)) return 1;
    if(VehServer[vehicleid][vsPemilik] != playerid) return SendMessageError(playerid, "Ini bukan kendaraan milikmu!");
    return ToggleKunciKendaraan(playerid, VehServer[vehicleid][vsSlot]);
  }

  // Pemain berada di luar: cari kendaraan miliknya yang paling dulu ditemukan di sekitar
  for(new slot = 0; slot < PVehInfo[playerid][viJumlah]; slot++) {
    new vehicleid = GetOwnedVehicleInSlot(playerid, slot);
    // Lewati kendaraan yang belum di-spawn, beda dunia, atau terlalu jauh
    if(!IsVehicleInPlayerWorld(playerid, vehicleid) || !IsPlayerDekatKendaraan(playerid, vehicleid)) continue;
    return ToggleKunciKendaraan(playerid, slot);
  }
  return 1;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////