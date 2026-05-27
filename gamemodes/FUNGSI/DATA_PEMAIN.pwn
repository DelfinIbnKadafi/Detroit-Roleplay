Fungsi: MuatDataPemain(playerid) {
  
  cache_get_value_int(0, "gender", Pemain[playerid][pGender]);
  cache_get_value_int(0, "skin", Pemain[playerid][pSkin]);
  cache_get_value_int(0, "level", Pemain[playerid][pLevel]);
  
  // float
  cache_get_value_name_float(0, "posx", PosisiPemain[playerid][x]);
  cache_get_value_name_float(0, "posy", PosisiPemain[playerid][y]);
  cache_get_value_name_float(0, "posz", PosisiPemain[playerid][z]);
  cache_get_value_name_float(0, "angel", PosisiPemain[playerid][angel]);
  
  cache_get_value_name_float(0, "nyawa", Pemain[playerid][pNyawa]);
  cache_get_value_name_float(0, "armor", Pemain[playerid][pArmor]);
  
  cache_get_value_int(0, "interior", PosisiPemain[playerid][int]);
  
  TipeLogin[playerid] = 0;
  
  SpawnPemainEx(playerid);
  
  return 1;
}

Fungsi: SimpanDataPemain(playerid) {
  return 1;
}