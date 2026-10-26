#define EXT_HOSPITAL_X 1172.59
#define EXT_HOSPITAL_Y -1323.37
#define EXT_HOSPITAL_Z 15.40
#define EXT_HOSPITAL_A 272.0

#define INT_HOSPITAL_X 1402.58
#define INT_HOSPITAL_Y -26.14 
#define INT_HOSPITAL_Z 1000.86
#define INT_HOSPITAL_A 185.47

stock DeteksiPintuHospital(playerid) {
  if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 0;
  if(GetPlayerDistanceFromPoint(playerid, EXT_HOSPITAL_X, EXT_HOSPITAL_Y, EXT_HOSPITAL_Z) <= 2) {
    PindahkanPemain(playerid, INT_HOSPITAL_X, INT_HOSPITAL_Y, INT_HOSPITAL_Z);
    SetPlayerFacingAngle(playerid, INT_HOSPITAL_A);
    return 1;
  }
  else if(GetPlayerDistanceFromPoint(playerid, INT_HOSPITAL_X, INT_HOSPITAL_Y, INT_HOSPITAL_Z) <= 2) {
    PindahkanPemain(playerid, EXT_HOSPITAL_X, EXT_HOSPITAL_Y, EXT_HOSPITAL_Z);
    SetPlayerFacingAngle(playerid, EXT_HOSPITAL_A);
    return 1;
  }
  
  return 0;
}
