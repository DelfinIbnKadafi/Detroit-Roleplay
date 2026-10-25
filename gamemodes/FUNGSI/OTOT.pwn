public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
  if((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK)) {
    if(IsPlayerInAnyVehicle(playerid)) return 1;
    if(DeteksiPintuBalaiKota(playerid)) return 1;
    if(DeteksiPintuHospital(playerid)) return 1;
  }
  if((newkeys & KEY_NO) && !(oldkeys & KEY_NO)) {
    if(!IsPlayerInAnyVehicle(playerid)) return 1;
    ToggleMesinKendaraan(playerid);
  }
  return 1;
}
