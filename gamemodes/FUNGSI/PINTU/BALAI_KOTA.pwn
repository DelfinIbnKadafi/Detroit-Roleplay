#define EXT_BALAI_KOTA_x 1481.04
#define EXT_BALAI_KOTA_y -1771.79
#define EXT_BALAI_KOTA_z 18.78
#define EXT_BALAI_KOTA_a 8.06

#define INT_BALAI_KOTA_x 920.27
#define INT_BALAI_KOTA_y -1475.06
#define INT_BALAI_KOTA_z 2754.33
#define INT_BALAI_KOTA_a 2.24

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