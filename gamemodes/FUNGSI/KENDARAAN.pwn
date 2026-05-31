// kendaraan
stock MuatDataKendaraan(playerid) {
  new query[128];
  mysql_format(g_SQL, query, sizeof(query),
   "SELECT * FROM `Kendaraan` WHERE `pid` = %d", Pemain[playerid][pId]);

  new Cache:result = mysql_query(g_SQL, query);

  JumVeh[playerid] = 0;

  new rows = cache_num_rows();
  for(new i = 0; i < rows && i < MAX_KENDARAAN; i++) {
    cache_get_value_name_int(i, "vid", PVeh[playerid][i][vId]);
    cache_get_value_name_int(i, "model", PVeh[playerid][i][vModel]);
    cache_get_value_name_int(i, "color1", PVeh[playerid][i][vColor1]);
    cache_get_value_name_int(i, "color2", PVeh[playerid][i][vColor2]);
    
    cache_get_value_name(i, "plate", PVeh[playerid][i][vPlate], 16);
    
    cache_get_value_name_float(i, "health", PVeh[playerid][i][vHealth]);
    cache_get_value_name_float(i, "x", PVeh[playerid][i][vX]);
    cache_get_value_name_float(i, "y", PVeh[playerid][i][vY]);
    cache_get_value_name_float(i, "z", PVeh[playerid][i][vZ]);

    JumVeh[playerid]++;
  }

  cache_delete(result);
  return 1;
}