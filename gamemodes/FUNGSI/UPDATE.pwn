public OnPlayerUpdate(playerid) {
  if(IsPlayerInAnyVehicle(playerid)) {
    if(TdPintuShown[playerid]) {
      TextDrawHideForPlayer(playerid, TD_PINTU[0]);
      TextDrawHideForPlayer(playerid, TD_PINTU[1]);
      TdPintuShown[playerid] = false;
    }
    return 1;
  }
  
  new bool:dekatPintu = false;
  
  if(GetPlayerDistanceFromPoint(playerid, EXT_BALAI_KOTA_x, EXT_BALAI_KOTA_y, EXT_BALAI_KOTA_z) <= 2 || GetPlayerDistanceFromPoint(playerid, INT_BALAI_KOTA_x, INT_BALAI_KOTA_y, INT_BALAI_KOTA_z) <= 2) {
    dekatPintu = true;
  }
  else {
    dekatPintu = false;
  }
  
  if(dekatPintu && !TdPintuShown[playerid]) {
    TextDrawShowForPlayer(playerid, TD_PINTU[0]);
    TextDrawShowForPlayer(playerid, TD_PINTU[1]);
    TdPintuShown[playerid] = true;
  }
  else if(!dekatPintu && TdPintuShown[playerid]) {
    TextDrawHideForPlayer(playerid, TD_PINTU[0]);
    TextDrawHideForPlayer(playerid, TD_PINTU[1]);
    TdPintuShown[playerid] = false;
  }
  return 1;
}