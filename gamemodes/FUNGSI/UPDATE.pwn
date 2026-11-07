public OnPlayerUpdate(playerid) {
  new bool:exitDoor;
  if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
    if(CekKondisiKendaraan(GetPlayerVehicleID(playerid))) return 0;
  }
  if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || IsPlayerInAnyVehicle(playerid)) {
    if(TdPintuShown[playerid]) {
      TextDrawHideForPlayer(playerid, TD_PINTU);
      TextDrawHideForPlayer(playerid, TD_PINTU);
      TdPintuShown[playerid] = false;
      TdPintuExitShown[playerid] = false;
    }
    return 1;
  }
  
  dekatPintu[playerid] = false;
  exitDoor = false;
  
  if(IsPlayerExterior(playerid)) {
    if(GetPlayerDistanceFromPoint(playerid, EXT_BALAI_KOTA_x, EXT_BALAI_KOTA_y, EXT_BALAI_KOTA_z) <= 2 || GetPlayerDistanceFromPoint(playerid, INT_BALAI_KOTA_x, INT_BALAI_KOTA_y, INT_BALAI_KOTA_z) <= 2) {
      dekatPintu[playerid] = true;
    }
    if(GetPlayerDistanceFromPoint(playerid, EXT_HOSPITAL_X, EXT_HOSPITAL_Y, EXT_HOSPITAL_Z) <= 2 || GetPlayerDistanceFromPoint(playerid, INT_HOSPITAL_X, INT_HOSPITAL_Y, INT_HOSPITAL_Z) <= 2) {
      dekatPintu[playerid] = true;
    }
    if(DekatBusiness(playerid) == 1) {
      dekatPintu[playerid] = true;
    }
  }
  else if(DekatPintuKeluarBusiness(playerid)) {
    dekatPintu[playerid] = true;
    exitDoor = true;
  }
  
  if(dekatPintu[playerid] && (!TdPintuShown[playerid] || TdPintuExitShown[playerid] != exitDoor)) {
    TextDrawHideForPlayer(playerid, TD_PINTU);
    TextDrawHideForPlayer(playerid, TD_PINTU);
    if(exitDoor) {
      TextDrawShowForPlayer(playerid, TD_PINTU);
      TdPintuExitShown[playerid] = true;
    }
    else {
      TextDrawShowForPlayer(playerid, TD_PINTU);
      TdPintuExitShown[playerid] = false;
    }
    TdPintuShown[playerid] = true;
  }
  else if(!dekatPintu[playerid] && TdPintuShown[playerid]) {
    TextDrawHideForPlayer(playerid, TD_PINTU);
    TextDrawHideForPlayer(playerid, TD_PINTU);
    TdPintuShown[playerid] = false;
    TdPintuExitShown[playerid] = false;
  }

  return 1;
}
