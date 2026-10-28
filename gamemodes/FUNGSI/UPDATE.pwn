public OnPlayerUpdate(playerid) {
  if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
    if(CekKondisiKendaraan(GetPlayerVehicleID(playerid))) return 0;
  }
  if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || IsPlayerInAnyVehicle(playerid)) {
    if(TdPintuShown[playerid]) {
      TextDrawHideForPlayer(playerid, TD_PINTU);
      TdPintuShown[playerid] = false;
    }
    return 1;
  }
  
  dekatPintu[playerid] = false;
  
  if(GetPlayerDistanceFromPoint(playerid, EXT_BALAI_KOTA_x, EXT_BALAI_KOTA_y, EXT_BALAI_KOTA_z) <= 2 || GetPlayerDistanceFromPoint(playerid, INT_BALAI_KOTA_x, INT_BALAI_KOTA_y, INT_BALAI_KOTA_z) <= 2) {
    dekatPintu[playerid] = true;
  }
  if(GetPlayerDistanceFromPoint(playerid, EXT_HOSPITAL_X, EXT_HOSPITAL_Y, EXT_HOSPITAL_Z) <= 2 || GetPlayerDistanceFromPoint(playerid, INT_HOSPITAL_X, INT_HOSPITAL_Y, INT_HOSPITAL_Z) <= 2) {
    dekatPintu[playerid] = true;
  }
  
  if(dekatPintu[playerid] && !TdPintuShown[playerid]) {
    TextDrawShowForPlayer(playerid, TD_PINTU);
    TdPintuShown[playerid] = true;
  }
  else if(!dekatPintu[playerid] && TdPintuShown[playerid]) {
    TextDrawHideForPlayer(playerid, TD_PINTU);
    TdPintuShown[playerid] = false;
  }

  return 1;
}
