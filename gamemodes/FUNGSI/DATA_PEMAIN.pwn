Fungsi: MuatDataPemain(playerid) 
{
  
  cache_get_value_int(0, "gender", Pemain[playerid][pGender]);
  cache_get_value_int(0, "skin", Pemain[playerid][pSkin]);
  cache_get_value_int(0, "level", Pemain[playerid][pLevel]);
  cache_get_value_int(0, "interior", PosisiPemain[playerid][pInt]);
  cache_get_value_int(0, "virtualworld", PosisiPemain[playerid][pVW]);
  cache_get_value_name_float(0, "posx", PosisiPemain[playerid][pX]);
  cache_get_value_name_float(0, "posy", PosisiPemain[playerid][pY]);
  cache_get_value_name_float(0, "posz", PosisiPemain[playerid][pZ]);
  cache_get_value_name_float(0, "angle", PosisiPemain[playerid][pAngle]);
  cache_get_value_name_float(0, "darah", Pemain[playerid][pDarah]);
  cache_get_value_name_float(0, "armor", Pemain[playerid][pArmor]);
  cache_get_value_int(0, "uang", Pemain[playerid][pUang]);
  cache_get_value_int(0, "bank", Pemain[playerid][pBank]);
  cache_get_value_int(0, "norek", Pemain[playerid][pNorek]);
  cache_get_value_int(0, "ktp", Pemain[playerid][pKtp]);
  cache_get_value_name(0, "tanggallahir", Pemain[playerid][pDateBirth]);
  cache_get_value_int(0, "job", Pemain[playerid][pJob]);
  cache_get_value_int(0, "haus", Pemain[playerid][pHaus]);
  cache_get_value_int(0, "lapar", Pemain[playerid][pLapar]);
  SpawnPemainEx(playerid);
  return 1;
}

Fungsi: SimpanDataPemain(playerid) 
{
  GetPlayerPos(
   playerid,
   PosisiPemain[playerid][pX],
   PosisiPemain[playerid][pY],
   PosisiPemain[playerid][pZ]
  );
  
  GetPlayerFacingAngle(playerid, PosisiPemain[playerid][pAngle]);
  PosisiPemain[playerid][pInt] = GetPlayerInterior(playerid);
  PosisiPemain[playerid][pVW] = GetPlayerVirtualWorld(playerid);
  
  // set
  Pemain[playerid][pSkin] = GetPlayerSkin(playerid);
  
  GetPlayerHealth(playerid, Pemain[playerid][pDarah]);
  GetPlayerArmour(playerid, Pemain[playerid][pArmor]);
  
  Pemain[playerid][pUang] = GetPlayerMoney(playerid);
  
  new query[512];
  mysql_format(g_SQL, query, sizeof(query),
    "UPDATE Pemain SET posx='%f', posy='%f', posz='%f', angle='%f', interior='%d', virtualworld=%d, level='%d', skin='%d', darah='%f', armor='%f', uang='%d', bank='%d', norek='%d', ktp='%d', tanggallahir='%s', job='%d', haus='%d', lapar='%d' WHERE id='%d'",
    PosisiPemain[playerid][pX],
    PosisiPemain[playerid][pY],
    PosisiPemain[playerid][pZ],
    PosisiPemain[playerid][pAngle],
    PosisiPemain[playerid][pInt],
    PosisiPemain[playerid][pVW],
    
    Pemain[playerid][pLevel],
    Pemain[playerid][pSkin],
    Pemain[playerid][pDarah],
    Pemain[playerid][pArmor],
    
    Pemain[playerid][pUang],
    Pemain[playerid][pBank],
    Pemain[playerid][pNorek],
    
    Pemain[playerid][pKtp],
    Pemain[playerid][pDateBirth],
    
    Pemain[playerid][pJob],
    
    Pemain[playerid][pHaus],
    Pemain[playerid][pLapar],
    
    Pemain[playerid][pId]
  );
  mysql_query(g_SQL, query);
  return 1;
}

stock ResetDataPemain(playerid)
{
  static const data_pemain[DATA_PEMAIN];
  static const posisi_player[POSISI_PLAYER];

  Pemain[playerid] = data_pemain;
  PosisiPemain[playerid] = posisi_player;
  return 1;
}