Dialog:DL_VEHLIST(playerid, response, listitem, inputtext[]) {
  if(!response) return 1;

  new judul[64], pilihan[128];
  new vnama[32];
  GetVehicleModelName(PVeh[playerid][listitem][vModel], vnama, sizeof(vnama));
  format(judul, sizeof(judul), "Kendaraan: %s", vnama);
  format(pilihan, sizeof(pilihan), "Spawn Kendaraan\nLihat Info\nKunci\nTrack");

  PilihanVeh[playerid] = listitem;
  Dialog_Show(playerid, DL_AKSIVEH, DIALOG_STYLE_LIST, judul, pilihan, "Pilih", "Batal");
  return 1;
}

Dialog:DL_AKSIVEH(playerid, response, listitem, inputtext[]) {
  if(!response) return 1;

  new idp = PilihanVeh[playerid];

  switch(listitem) {
    case 0: {
      // spawn veh
      new dbid = PVeh[playerid][idp][vId];
      new vehicleid = CreateVehicle(
       PVeh[playerid][idp][vModel],
       PVeh[playerid][idp][vX],
       PVeh[playerid][idp][vY],
       PVeh[playerid][idp][vZ],
       PVeh[playerid][idp][vAngel],
       PVeh[playerid][idp][vColor1],
       PVeh[playerid][idp][vColor2],
       -1
      );
      
      VehID[dbid] = vehicleid;
      
      VehOwner[vehicleid] = playerid;
      VehSlot[vehicleid] = idp;
      
      MesinVeh[vehicleid] = false;
      
      SetVehicleHealth(vehicleid, PVeh[playerid][idp][vHealth]);
      
      SendMessageInfo(playerid, "Kendaran telah di spawn");
      return 1;
    }
    case 1: {
      new vnama[32], str[128];
      GetVehicleModelName(PVeh[playerid][idp][vModel], vnama, sizeof(vnama));
      format(str, sizeof(str), "Model Kendaraan: %s\n\nId Kendaraan: %d\n\nKondisi: %.1f",vnama, PVeh[playerid][idp][vId], PVeh[playerid][idp][vHealth]);
      Dialog_Show(playerid, DL_INFOVEH, DIALOG_STYLE_MSGBOX, "Info Kendaraan", str, "Kembali", " ");
      return 1;
    }
    case 2: {
      if(!IsPlayerInRangeOfPoint(playerid, 4.0, PVeh[playerid][idp][vX], PVeh[playerid][idp][vY], PVeh[playerid][idp][vZ])) {
        SendMessageError(playerid, "Kamu terlalu jauh dari kendaraan ini.");
        return 1;
      }
      new vname[32];
      GetVehicleModelName(PVeh[playerid][idp][vModel], vname, sizeof(vname));

      if(PVeh[playerid][idp][vKunci] == 0) {
        PVeh[playerid][idp][vKunci] = 1;
        SendMessageInfo(playerid, "Kendaraan berhasil di kunci");
      }
      else {
        PVeh[playerid][idp][vKunci] = 0;
        SendMessageInfo(playerid, "Kunci kendaraan berhadil di buka");
      }
      return 1;
    }
    case 3: {
      // track
      SetPlayerCheckpoint(playerid,
       PVeh[playerid][idp][vX],
       PVeh[playerid][idp][vY],
       PVeh[playerid][idp][vZ],
       2.0
      );
      SendMessageInfo(playerid, "Chekpoint menuju kendaraan telah dibuat!");
      return 1;
    }
  }
  return 1;
}