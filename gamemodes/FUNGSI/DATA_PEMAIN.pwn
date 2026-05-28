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

  // posisi
  GetPlayerPos(playerid,
   PosisiPemain[playerid][x],
   PosisiPemain[playerid][y],
   PosisiPemain[playerid][z]
  );
  
  GetPlayerFacingAngle(playerid, PosisiPemain[playerid][angel]);
  PosisiPemain[playerid][int] = GetPlayerInterior(playerid);
  
  // set
  Pemain[playerid][pLevel] = GetPlayerScore(playerid);
  Pemain[playerid][pSkin] = GetPlayerSkin(playerid);
  
  GetPlayerHealth(playerid, Pemain[playerid][pNyawa]);
  GetPlayerArmour(playerid, Pemain[playerid][pArmor]);
  
  new query[512];
  mysql_format(g_SQL, query, sizeof(query),
   "UPDATE Pemain SET posx='%f', posy='%f', posz='%z', angel='%f', interior='%d', level='%d', skin='%d', nyawa='%f', armor='%f' WHERE id='%d'", 
  );
  
  return 1;
}