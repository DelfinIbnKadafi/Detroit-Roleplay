stock bool:IsCurrentPlayerSession(playerid, sessionid, const expectedName[])
{
  return IsPlayerConnected(playerid)
    && PlayerSession[playerid] == sessionid
    && !strcmp(Pemain[playerid][pNama], expectedName, true);
}

Fungsi:AutoSavePlayer(playerid, sessionid)
{
  if(!IsCurrentPlayerSession(playerid, sessionid, Pemain[playerid][pNama]) || !StatusLogin[playerid]) return 1;
  SimpanDataPemain(playerid);
  SaveDataKendaraan(playerid);
  return 1;
}

Fungsi: MuatDataPemain(playerid, sessionid, const expectedName[])
{
  if(!IsCurrentPlayerSession(playerid, sessionid, expectedName)) return 1;
  if(cache_num_rows() != 1) {
    SendMessageError(playerid, "Data akun tidak dapat dimuat. Silakan masuk kembali.");
    DelayedKick(playerid);
    return 1;
  }

  cache_get_value_int(0, "admin", Admin[playerid]);
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
  cache_get_value_int(0, "phone", Pemain[playerid][pPhone]);
  cache_get_value_int(0, "phonestatus", Pemain[playerid][pPhoneStatus]);
  cache_get_value_name(0, "nohp", Pemain[playerid][pNohp]);
  cache_get_value_int(0, "ktp", Pemain[playerid][pKtp]);
  cache_get_value_name(0, "tanggallahir", Pemain[playerid][pDateBirth]);
  cache_get_value_int(0, "job", Pemain[playerid][pJob]);
  cache_get_value_int(0, "haus", Pemain[playerid][pHaus]);
  cache_get_value_int(0, "lapar", Pemain[playerid][pLapar]);
  cache_get_value_bool(0, "death", PlayerDeath[playerid]);
  SpawnPemainEx(playerid);
  return 1;
}

Fungsi: SimpanDataPemain(playerid) 
{
  if(!NewPlayerPendingSave[playerid]) {
    GetPlayerPos(
     playerid,
     PosisiPemain[playerid][pX],
     PosisiPemain[playerid][pY],
     PosisiPemain[playerid][pZ]
    );
    GetPlayerFacingAngle(playerid, PosisiPemain[playerid][pAngle]);
    PosisiPemain[playerid][pInt] = GetPlayerInterior(playerid);
    PosisiPemain[playerid][pVW] = GetPlayerVirtualWorld(playerid);
    Pemain[playerid][pSkin] = GetPlayerSkin(playerid);
    GetPlayerHealth(playerid, Pemain[playerid][pDarah]);
    GetPlayerArmour(playerid, Pemain[playerid][pArmor]);
    Pemain[playerid][pUang] = GetPlayerMoney(playerid);
  }
  
  new query[512];
  mysql_format(g_SQL, query, sizeof(query),
    "UPDATE Pemain SET posx='%f', posy='%f', posz='%f', angle='%f', interior='%d', virtualworld=%d, level='%d', skin='%d', darah='%f', armor='%f', uang='%d', bank='%d', norek='%d', phone='%d', phonestatus='%d', nohp='%e', ktp='%d', tanggallahir='%e', job='%d', haus='%d', lapar='%d', admin='%d', death='%d' WHERE id='%d'",
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
    
    Pemain[playerid][pPhone],
    Pemain[playerid][pPhoneStatus],
    Pemain[playerid][pNohp],
    
    Pemain[playerid][pKtp],
    Pemain[playerid][pDateBirth],
    
    Pemain[playerid][pJob],
    
    Pemain[playerid][pHaus],
    Pemain[playerid][pLapar],
    
    Admin[playerid],

    PlayerDeath[playerid],
    
    Pemain[playerid][pId]
  );
  mysql_tquery(g_SQL, query);
  return 1;
}

stock ResetDataPemain(playerid)
{
  static const data_pemain[DATA_PEMAIN];
  static const posisi_player[POSISI_PLAYER];
  static const data_kendaraan[DataVeh];

  Pemain[playerid] = data_pemain;
  PosisiPemain[playerid] = posisi_player;

  StatusLogin[playerid] = false;
  NewPlayerPendingSave[playerid] = false;
  Admin[playerid] = 0;
  AdminDuty[playerid] = false;
  Mute[playerid] = false;
  JumlahSpam[playerid] = 0;
  ChatWindowStart[playerid] = 0;
  TimerUnMute[playerid] = 0;
  JumVeh[playerid] = 0;
  PendingVehicleGrants[playerid] = 0;
  PilihanVeh[playerid] = 0;
  DeletePVar(playerid, "login_attempts");
  DeletePVar(playerid, "verify_attempts");
  for(new i = 0; i < MAX_KENDARAAN; i++) {
    PVeh[playerid][i] = data_kendaraan;
    PlayerVehID[playerid][i] = INVALID_VEHICLE_ID;
    VehicleIsSpawn[playerid][i] = false;
  }

  return 1;
}
