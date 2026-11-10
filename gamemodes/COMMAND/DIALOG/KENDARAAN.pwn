Dialog:DL_VEHLIST(playerid, response, listitem, inputtext[]) {
  if(!response || !IsPlayerAccountReady(playerid)) return 1;
  if(!IsSlotKendaraanValid(playerid, listitem)) return 1;

  new judul[64], pilihan[128];
  new vnama[32];
  GetVehicleModelName(PVeh[playerid][listitem][vModel], vnama, sizeof(vnama));
  format(judul, sizeof(judul), "Kendaraan: %s", vnama);
  format(pilihan, sizeof(pilihan), "Spawn Kendaraan\nLihat Info\nKunci\nTrack");

  PVehInfo[playerid][viPilihan] = listitem;
  Dialog_Show(playerid, DL_AKSIVEH, DIALOG_STYLE_LIST, judul, pilihan, "Pilih", "Batal");
  return 1;
}

Dialog:DL_AKSIVEH(playerid, response, listitem, inputtext[]) {
  if(!response || !IsPlayerAccountReady(playerid)) return 1;

  new slot = PVehInfo[playerid][viPilihan];
  if(!IsSlotKendaraanValid(playerid, slot)) return 1;

  switch(listitem) {
    case 0: {
      // spawn veh
      if(GetOwnedVehicleInSlot(playerid, slot) != INVALID_VEHICLE_ID) return SendMessageError(playerid, "Kendaraan tersebut telah di spawn");

      if(SpawnKendaraanPlayer(playerid, slot) == INVALID_VEHICLE_ID) {
        return SendMessageError(playerid, "Kendaraan gagal di-spawn. Batas kendaraan server mungkin tercapai.");
      }

      SendMessageInfo(playerid, "Kendaraan telah di-spawn.");
      return 1;
    }
    case 1: {
      // info
      new vnama[32], str[128];
      if(IsSlotKendaraanMati(playerid, slot)) PVeh[playerid][slot][vHealth] = 0.0;
      GetVehicleModelName(PVeh[playerid][slot][vModel], vnama, sizeof(vnama));
      format(str, sizeof(str), "Model Kendaraan: %s\n\nId Kendaraan: %d\n\nKondisi: %.1f", vnama, PVeh[playerid][slot][vId], PVeh[playerid][slot][vHealth]);
      Dialog_Show(playerid, DL_INFOVEH, DIALOG_STYLE_MSGBOX, "Info Kendaraan", str, "Kembali", " ");
      return 1;
    }
    case 2: {
      // kunci
      new vehicleid = GetOwnedVehicleInSlot(playerid, slot);
      if(!IsValidVehicle(vehicleid)) return SendMessageError(playerid, "Kendaraan belum di-spawn.");

      // Perbarui posisi tersimpan, lalu pastikan pemain berada di dekat kendaraan
      SalinPosisiKendaraan(playerid, slot, vehicleid);
      if(!IsVehicleInPlayerWorld(playerid, vehicleid) || !IsPlayerDekatKendaraan(playerid, vehicleid)) {
        return SendMessageError(playerid, "Kamu terlalu jauh dari kendaraan ini.");
      }

      return ToggleKunciKendaraan(playerid, slot);
    }
    case 3: {
      // track
      new vehicleid = GetOwnedVehicleInSlot(playerid, slot);

      // Jika kendaraan sedang di-spawn, ambil posisi terbarunya
      if(IsValidVehicle(vehicleid)) SalinPosisiKendaraan(playerid, slot, vehicleid);
      if(PVeh[playerid][slot][vWorld] != GetPlayerVirtualWorld(playerid) || PVeh[playerid][slot][vInterior] != GetPlayerInterior(playerid)) {
        return SendMessageError(playerid, "Kendaraan berada di world atau interior yang berbeda.");
      }

      SetPlayerCheckpoint(playerid, PVeh[playerid][slot][vX], PVeh[playerid][slot][vY], PVeh[playerid][slot][vZ], 2.0);
      SendMessageInfo(playerid, "Checkpoint menuju kendaraan telah dibuat!");
      return 1;
    }
  }
  return 1;
}