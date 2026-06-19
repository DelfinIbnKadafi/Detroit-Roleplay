#define EXT_BALAI_KOTA_x 0.0
#define EXT_BALAI_KOTA_y 0.0
#define EXT_BALAI_KOTA_z 0.0

#define INT_BALAI_KOTA_x 0.0
#define INT_BALAI_KOTA_y 0.0
#define INT_BALAI_KOTA_z 0.0

stock DeteksiPintuBalaiKota(playerid) {
  if(GetPlayerDistanceFromPoint(playerid, EXT_BALAI_KOTA_x, EXT_BALAI_KOTA_y, EXT_BALAI_KOTA_z) <= 2) {
    SetPlayerPos(playerid, INT_BALAI_KOTA_x, INT_BALAI_KOTA_y, INT_BALAI_KOTA_z);
    return 1;
  }
  else if(GetPlayerDistanceFromPoint(playerid, INT_BALAI_KOTA_x, INT_BALAI_KOTA_y, INT_BALAI_KOTA_z) <= 2) {
    SetPlayerPos(playerid, EXT_BALAI_KOTA_x, EXT_BALAI_KOTA_y, EXT_BALAI_KOTA_z);
    return 1;
  }
  return 0;
}