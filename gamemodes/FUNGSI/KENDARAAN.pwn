// Periksa apakah kendaraan terdaftar sebagai milik pemain.
stock bool:IsPlayerOwnedVehicle(vehicleid) {
  // Tolak ID kendaraan di luar batas server.
  if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES_SERVER) return false;

  new owner = VehServer[vehicleid][vsPemilik];
  new slot  = VehServer[vehicleid][vsSlot];

  // Pastikan pemilik dan slot kendaraan valid.
  if(owner < 0 || owner >= MAX_PLAYERS || slot < 0 || slot >= MAX_KENDARAAN) return false;
  return PVeh[owner][slot][vIdServer] == vehicleid;
}

// Periksa apakah slot kendaraan milik pemain berstatus mati.
stock bool:IsSlotKendaraanMati(playerid, slot) {
  return PVeh[playerid][slot][vDeath] != 0;
}

// Periksa apakah kendaraan milik pemain sudah mati.
stock bool:IsDeadPlayerVehicle(vehicleid) {
  // Kendaraan non-milik pemain tidak memiliki status mati.
  if(!IsPlayerOwnedVehicle(vehicleid)) return false;
  return IsSlotKendaraanMati(VehServer[vehicleid][vsPemilik], VehServer[vehicleid][vsSlot]);
}

// Periksa apakah pemain dan slot kendaraan berada dalam batas yang valid.
stock bool:IsSlotKendaraanValid(playerid, slot) {
  if(playerid < 0 || playerid >= MAX_PLAYERS) return false;
  return slot >= 0 && slot < MAX_KENDARAAN && slot < PVehInfo[playerid][viJumlah];
}

// Periksa apakah kesehatan kendaraan sudah masuk batas kritis.
// Ditulis dengan tanda ! agar nilai yang bukan angka (NaN) juga dianggap kritis.
stock bool:IsHealthKritis(Float:health) {
  return !(health > VEHICLE_CRITICAL_HEALTH);
}

// Ambil sisa bensin kendaraan milik pemain (0 jika bukan kendaraan pemain).
stock GetFuelKendaraan(vehicleid) {
  if(!IsPlayerOwnedVehicle(vehicleid)) return 0;
  return PVeh[VehServer[vehicleid][vsPemilik]][VehServer[vehicleid][vsSlot]][vFuel];
}

// Periksa apakah kendaraan milik pemain sedang terkunci.
stock bool:IsKendaraanTerkunci(vehicleid) {
  if(!IsPlayerOwnedVehicle(vehicleid)) return false;
  return PVeh[VehServer[vehicleid][vsPemilik]][VehServer[vehicleid][vsSlot]][vKunci] != 0;
}

// Periksa apakah model kendaraan didukung.
stock bool:IsSupportedVehicleModel(model) {
  return model >= 400 && model <= 611 && model != 449 && model != 537 && model != 538;
}

// Periksa apakah data kendaraan pada slot cukup lengkap untuk di-spawn.
stock bool:IsDataKendaraanLengkap(playerid, slot) {
  // Kendaraan harus punya ID database dan model yang didukung.
  if(PVeh[playerid][slot][vId] <= 0 || !IsSupportedVehicleModel(PVeh[playerid][slot][vModel])) return false;
  // Posisi harus berada di dalam peta.
  if(!ValidWorldPosition(PVeh[playerid][slot][vX], PVeh[playerid][slot][vY], PVeh[playerid][slot][vZ])) return false;
  // Sudut hadap harus masuk akal.
  return PVeh[playerid][slot][vAngel] >= -36000.0 && PVeh[playerid][slot][vAngel] <= 36000.0;
}

// Kosongkan data VehServer sebuah kendaraan. Generasi tidak ikut direset
// karena nilainya harus terus bertambah agar callback timer lama bisa dikenali.
stock ResetDataVehServer(vehicleid) {
  if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES_SERVER) return 0;
  VehServer[vehicleid][vsPemilik] = VEH_KOSONG;
  VehServer[vehicleid][vsSlot]    = VEH_KOSONG;
  VehServer[vehicleid][vsMesin]   = false;
  VehServer[vehicleid][vsAdmin]   = VEH_KOSONG;
  return 1;
}

// Kosongkan seluruh data kendaraan milik satu pemain (dipanggil dari ResetDataPemain).
stock ResetDataKendaraanPemain(playerid) {
  static const dataInfo[DataVehInfo];
  static const dataSlot[DataVeh];

  PVehInfo[playerid] = dataInfo;
  for(new i = 0; i < MAX_KENDARAAN; i++) {
    PVeh[playerid][i] = dataSlot;
    PVeh[playerid][i][vIdServer] = INVALID_VEHICLE_ID;
  }
  return 1;
}

// Ambil kendaraan pemilik pada slot tertentu.
stock GetOwnedVehicleInSlot(playerid, slot) {
  // Pastikan pemain dan slot berada dalam batas.
  if(!IsSlotKendaraanValid(playerid, slot)) return INVALID_VEHICLE_ID;
  new vehicleid = PVeh[playerid][slot][vIdServer];
  // Tolak kendaraan yang tidak sesuai data pemilik dan slot.
  if(!IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid)) return INVALID_VEHICLE_ID;
  if(VehServer[vehicleid][vsPemilik] != playerid || VehServer[vehicleid][vsSlot] != slot) return INVALID_VEHICLE_ID;
  return vehicleid;
}

// Periksa apakah pemain dan kendaraan berada di dunia yang sama.
stock bool:IsVehicleInPlayerWorld(playerid, vehicleid) {
  return IsPlayerConnected(playerid) && IsValidVehicle(vehicleid) && GetPlayerVirtualWorld(playerid) == GetVehicleVirtualWorld(vehicleid) && GetPlayerInterior(playerid) == GetVehicleInterior(vehicleid);
}

// Periksa apakah pemain berada dalam jarak tertentu dari kendaraan.
stock bool:IsPlayerDekatKendaraan(playerid, vehicleid, Float:jarak = 4.0) {
  new Float:x, Float:y, Float:z;
  if(!GetVehiclePos(vehicleid, x, y, z)) return false;
  return IsPlayerInRangeOfPoint(playerid, jarak, x, y, z);
}

// Salin posisi, sudut, dunia, dan interior kendaraan yang sedang aktif ke data slot.
stock SalinPosisiKendaraan(owner, slot, vehicleid) {
  GetVehiclePos(vehicleid, PVeh[owner][slot][vX], PVeh[owner][slot][vY], PVeh[owner][slot][vZ]);
  GetVehicleZAngle(vehicleid, PVeh[owner][slot][vAngel]);
  PVeh[owner][slot][vWorld] = GetVehicleVirtualWorld(vehicleid);
  PVeh[owner][slot][vInterior] = GetVehicleInterior(vehicleid);
  return 1;
}

// Mulai memuat data kendaraan pemain.
stock MuatDataKendaraan(playerid) {
  PVehInfo[playerid][viDimuat] = false;
  new query[128];
  mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `Kendaraan` WHERE `pid` = %d ORDER BY `vid`", Pemain[playerid][pId]);

  mysql_tquery(g_SQL, query, "OnVehiclesLoaded", "iis", playerid, PlayerSession[playerid], Pemain[playerid][pNama]);
  return 1;
}

// Proses hasil pemuatan data kendaraan.
Fungsi:OnVehiclesLoaded(playerid, sessionid, const expectedName[]) {
  // Abaikan hasil yang bukan sesi aktif atau data yang sudah dimuat.
  if(!IsCurrentPlayerSession(playerid, sessionid, expectedName) || !IsPlayerAccountReady(playerid) || PVehInfo[playerid][viDimuat]) return 1;
  new rows = cache_num_rows();
  new bool:normalized[MAX_KENDARAAN];
  for(new i = 0; i < rows && i < MAX_KENDARAAN; i++) {
    new databaseid;
    cache_get_value_name_int(i, "vid", databaseid);

    // Hasil pemuatan yang tertunda tidak boleh menimpa data kendaraan yang lebih baru
    // (kondisi mati atau posisi) milik kendaraan yang sedang aktif.
    new vehicleid = PVeh[playerid][i][vIdServer];
    new bool:kendaraanAktif = IsValidVehicle(vehicleid) && IsPlayerOwnedVehicle(vehicleid);
    if(PVeh[playerid][i][vId] == databaseid && (IsSlotKendaraanMati(playerid, i) || kendaraanAktif)) continue;

    PVeh[playerid][i][vId] = databaseid;
    cache_get_value_name_int(i, "model", PVeh[playerid][i][vModel]);
    cache_get_value_name_int(i, "color1", PVeh[playerid][i][vColor1]);
    cache_get_value_name_int(i, "color2", PVeh[playerid][i][vColor2]);

    cache_get_value_name(i, "plate", PVeh[playerid][i][vPlate], 17);

    cache_get_value_name_float(i, "health", PVeh[playerid][i][vHealth]);
    cache_get_value_name_float(i, "x", PVeh[playerid][i][vX]);
    cache_get_value_name_float(i, "y", PVeh[playerid][i][vY]);
    cache_get_value_name_float(i, "z", PVeh[playerid][i][vZ]);
    cache_get_value_name_float(i, "angel", PVeh[playerid][i][vAngel]);

    cache_get_value_name_int(i, "fuel", PVeh[playerid][i][vFuel]);
    cache_get_value_name_int(i, "kunci", PVeh[playerid][i][vKunci]);

    cache_get_value_name_int(i, "death", PVeh[playerid][i][vDeath]);
    // Tandai kendaraan mati jika status atau kesehatannya menunjukkan kerusakan kritis.
    if(IsSlotKendaraanMati(playerid, i) || IsHealthKritis(PVeh[playerid][i][vHealth])) {
      normalized[i] = !IsSlotKendaraanMati(playerid, i);
      PVeh[playerid][i][vDeath] = 1;
      PVeh[playerid][i][vHealth] = 0.0;
      SiapkanVisualKendaraanMati(playerid, i);
    }
    // Batasi kesehatan kendaraan ke nilai maksimum.
    else if(PVeh[playerid][i][vHealth] > 1000.0) PVeh[playerid][i][vHealth] = 1000.0;
  }
  PVehInfo[playerid][viJumlah] = rows < MAX_KENDARAAN ? rows : MAX_KENDARAAN;
  PVehInfo[playerid][viDimuat] = true;
  for(new i = 0; i < PVehInfo[playerid][viJumlah]; i++) {
    // Simpan perubahan status kendaraan yang dinormalisasi.
    if(normalized[i]) SaveSatuKendaraan(playerid, i, false);
  }
  return 1;
}

// Simpan data satu kendaraan ke basis data.
stock SaveSatuKendaraan(playerid, slot, bool:ambilposisi = true) {
  // Tolak pemain atau slot yang tidak valid.
  if(!IsSlotKendaraanValid(playerid, slot)) return 0;
  // Pastikan kendaraan dan akun sudah memiliki ID basis data.
  if(PVeh[playerid][slot][vId] <= 0 || Pemain[playerid][pId] <= 0) return 0;
  new vehicleid = GetOwnedVehicleInSlot(playerid, slot);
  // Periksa kondisi kendaraan yang masih hidup sebelum disimpan (jika kritis, langsung ditandai mati dan disimpan).
  if(ambilposisi && !IsSlotKendaraanMati(playerid, slot) && CekKondisiKendaraan(vehicleid)) return 1;
  // Kendaraan mati selalu disimpan dengan kesehatan nol.
  if(IsSlotKendaraanMati(playerid, slot)) PVeh[playerid][slot][vHealth] = 0.0;
  // Ambil kondisi terkini dari kendaraan yang masih terhubung ke slot ini.
  if(ambilposisi && vehicleid != INVALID_VEHICLE_ID) {
    // Perbarui kesehatan hanya jika kendaraan belum mati.
    if(!IsSlotKendaraanMati(playerid, slot)) GetVehicleHealth(vehicleid, PVeh[playerid][slot][vHealth]);
    SalinPosisiKendaraan(playerid, slot, vehicleid);
  }
  new query[384];
  mysql_format(g_SQL, query, sizeof(query), "UPDATE Kendaraan SET health='%.1f', x='%.4f', y='%.4f', z='%.4f', angel='%.4f', fuel=%d, kunci=%d, death=%d WHERE vid='%d' AND pid=%d", PVeh[playerid][slot][vHealth], PVeh[playerid][slot][vX], PVeh[playerid][slot][vY], PVeh[playerid][slot][vZ], PVeh[playerid][slot][vAngel], PVeh[playerid][slot][vFuel], PVeh[playerid][slot][vKunci], PVeh[playerid][slot][vDeath], PVeh[playerid][slot][vId], Pemain[playerid][pId]);
  mysql_tquery(g_SQL, query);
  return 1;
}

// Simpan seluruh kendaraan pemain.
stock SaveDataKendaraan(playerid) {
  for(new i = 0; i < PVehInfo[playerid][viJumlah]; i++) SaveSatuKendaraan(playerid, i);
  return 1;
}

// Hancurkan seluruh kendaraan milik pemain.
stock HancurkanKendaraanPlayer(playerid) {
  for(new i = 0; i < PVehInfo[playerid][viJumlah]; i++) {
    new vehicleid = PVeh[playerid][i][vIdServer];
    PVeh[playerid][i][vIdServer] = INVALID_VEHICLE_ID;
    // Lewati slot yang kendaraannya tidak lagi cocok dengan data pemilik.
    if(!IsValidVehicle(vehicleid) || VehServer[vehicleid][vsPemilik] != playerid || VehServer[vehicleid][vsSlot] != i) continue;
    ResetDataVehServer(vehicleid);
    DestroyVehicle(vehicleid);
  }
  return 1;
}

// Ambil nama kendaraan berdasarkan model.
stock GetVehicleModelName(modelid, name[], len) {
  static const vehicleNames[][] = {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perennial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch",
    "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto",
    "Taxi", "Washington", "Bobcat", "Mr Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee",
    "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer 1", "Previon", "Coach", "Cabbie", "Stallion",
    "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram",
    "Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
    "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina",
    "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxville", "Benson",
    "Mesa", "RC Goblin", "Hotring A", "Hotring B", "Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike",
    "Mountain Bike", "Beagle", "Cropdust", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal",
    "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune", "Cadrona", "FBI Truck", "Willard",
    "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex",
    "Vincent", "Bullet", "Clover", "Sadler", "Firetruck LA", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa",
    "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster A", "Monster B", "Uranus", "Jester",
    "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Freight Flat",
    "Streak Carriage", "Kart", "Mower", "Duneride", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog",
    "Club", "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police LS", "Police SF", "Police LV",
    "Police Ranger", "Picador", "S.W.A.T.", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer", "Luggage Trailer", "Stair Trailer",
    "Boxville", "Farm Plow", "Utility Trailer"
  };

  // Gunakan nama yang tersedia untuk model yang didukung.
  if(modelid >= 400 && modelid <= 611) {
    format(name, len, "%s", vehicleNames[modelid - 400]);
    return 1;
  }
  format(name, len, "Unknown");
  return 0;
}

// Kendaraan admin ditandai lewat VehServer[vehicleid][vsAdmin] (berisi playerid admin pembuatnya).

// Daftarkan kendaraan yang baru dibuat sebagai kendaraan admin milik pemain.
stock DaftarkanKendaraanAdmin(playerid, vehicleid) {
  // ID kendaraan bisa dipakai ulang, jadi bersihkan dulu sisa data pemilik sebelumnya.
  ResetDataVehServer(vehicleid);
  VehServer[vehicleid][vsGenerasi]++;
  VehServer[vehicleid][vsMesin] = true;
  VehServer[vehicleid][vsAdmin] = playerid;
  return 1;
}

// Periksa apakah kendaraan tercatat sebagai kendaraan admin.
stock bool:IsAdminVehicle(vehicleid) {
  if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES_SERVER) return false;
  return VehServer[vehicleid][vsAdmin] != VEH_KOSONG;
}

// Hapus kendaraan dari daftar kendaraan admin.
stock RemoveAdminVehicle(vehicleid) {
  if(vehicleid > 0 && vehicleid < MAX_VEHICLES_SERVER) VehServer[vehicleid][vsAdmin] = VEH_KOSONG;
  return 1;
}

// Hancurkan seluruh kendaraan admin milik pemain.
stock DestroyAdminVehicles(playerid) {
  for(new vehicleid = 1; vehicleid < MAX_VEHICLES_SERVER; vehicleid++) {
    // Lewati kendaraan yang bukan milik admin ini.
    if(VehServer[vehicleid][vsAdmin] != playerid) continue;
    // Hancurkan kendaraan jika masih valid.
    if(IsValidVehicle(vehicleid)) DestroyVehicle(vehicleid);
    ResetDataVehServer(vehicleid);
  }
  return 1;
}

// Atur kondisi mesin dan kunci kendaraan.
stock SetVehicleEngineAndLock(vehicleid, bool:engine, bool:locked) {
  // Abaikan ID kendaraan yang tidak valid.
  if(!IsValidVehicle(vehicleid)) return 0;
  // Jangan hidupkan mesin kendaraan yang kondisinya kritis.
  if(engine && CekKondisiKendaraan(vehicleid)) return 0;
  // Kendaraan mati tidak boleh menyalakan mesin.
  if(IsDeadPlayerVehicle(vehicleid)) engine = false;
  new currentEngine, lights, alarm, doors, bonnet, boot, objective;
  GetVehicleParamsEx(vehicleid, currentEngine, lights, alarm, doors, bonnet, boot, objective);
  // Perbarui parameter hanya jika status mesin atau kunci berubah.
  if(currentEngine != _:engine || doors != _:locked) SetVehicleParamsEx(vehicleid, engine, lights, alarm, locked, bonnet, boot, objective);
  VehServer[vehicleid][vsMesin] = engine;
  return 1;
}

// Kunci atau buka kunci kendaraan pada slot milik pemain, lalu beri tahu pemain.
// Pemanggil bertanggung jawab memastikan kendaraan sudah di-spawn dan berada dalam jangkauan.
stock ToggleKunciKendaraan(playerid, slot) {
  new vehicleid = PVeh[playerid][slot][vIdServer];

  // Kendaraan terbuka: kunci
  if(PVeh[playerid][slot][vKunci] == 0) {
    PVeh[playerid][slot][vKunci] = 1;
    SetVehicleEngineAndLock(vehicleid, VehServer[vehicleid][vsMesin], true);
    SendMessageInfo(playerid, "Kendaraan berhasil dikunci.");
  }
  // Kendaraan terkunci: buka
  else {
    PVeh[playerid][slot][vKunci] = 0;
    SetVehicleEngineAndLock(vehicleid, VehServer[vehicleid][vsMesin], false);
    SendMessageInfo(playerid, "Kunci kendaraan berhasil dibuka.");
  }
  return 1;
}

// Batalkan timer perubahan mesin dan sembunyikan indikatornya.
stock BatalkanTimerMesin(playerid) {
  KillTimer(PVehInfo[playerid][viTimerMesin]);
  PVehInfo[playerid][viTimerMesin] = 0;
  TextDrawHideForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
  TextDrawHideForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
  return 1;
}

// Nyalakan atau matikan mesin kendaraan yang sedang dikemudikan.
stock ToggleMesinKendaraan(playerid) {
  // Abaikan pemain yang belum siap atau sedang mati.
  if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid]) return 1;
  // Minta pemain masuk ke kendaraan terlebih dahulu.
  if(!IsPlayerInAnyVehicle(playerid)) return SendMessageError(playerid, "Kamu tidak berada di kendaraan manapun.");
  new vehicleid = GetPlayerVehicleID(playerid);
  // Fitur ini hanya berlaku untuk kendaraan milik pemain.
  if(!IsPlayerOwnedVehicle(vehicleid)) return SendMessageError(playerid, "Mesin manual hanya tersedia untuk kendaraan milik pemain.");
  // Hanya pengemudi yang dapat mengubah status mesin.
  if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
  // Hentikan jika kondisi kendaraan perlu ditangani.
  if(CekKondisiKendaraan(vehicleid)) return 1;
  // Kendaraan mati tidak dapat dinyalakan kembali.
  if(IsDeadPlayerVehicle(vehicleid)) {
    BatalkanTimerMesin(playerid);
    TerapkanKendaraanMati(vehicleid);
    return SendMessageError(playerid, "Kendaraan ini sudah mati dan tidak bisa dihidupkan kembali!");
  }
  // Cegah timer perubahan mesin berjalan berulang.
  if(PVehInfo[playerid][viTimerMesin] != 0) return 1;
  // Mesin tidak dapat dinyalakan tanpa bahan bakar.
  if(!VehServer[vehicleid][vsMesin] && GetFuelKendaraan(vehicleid) <= 0) return SendMessageError(playerid, "Bahan bakar kendaraan ini sudah habis!");
  new bool:hidup = !VehServer[vehicleid][vsMesin];
  PVehInfo[playerid][viTimerMesin] = SetTimerEx("HidupMatiMesinVeh", 2000, false, "iiiii", playerid, vehicleid, hidup, PlayerSession[playerid], VehServer[vehicleid][vsGenerasi]);
  // Tampilkan indikator saat mesin akan dinyalakan.
  if(hidup) {
    SendMessageInfo(playerid, "Menghidupkan mesin kendaraan....");
    TextDrawShowForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
  }
  // Tampilkan indikator saat mesin akan dimatikan.
  else {
    SendMessageInfo(playerid, "Mematikan mesin kendaraan....");
    TextDrawShowForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
  }
  return 1;
}

// Selesaikan permintaan perubahan status mesin.
Fungsi:HidupMatiMesinVeh(playerid, vehicleid, bool:hidupormati, sessionid, generation) {
  // Abaikan callback dari pemain yang sesi atau statusnya sudah berubah.
  if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || PlayerSession[playerid] != sessionid) return 1;
  // Abaikan callback jika kendaraan sudah diganti.
  if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES_SERVER || VehServer[vehicleid][vsGenerasi] != generation) return 1;
  BatalkanTimerMesin(playerid);
  // Pastikan kendaraan masih valid dan bukan kendaraan admin.
  if(!IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid) || IsAdminVehicle(vehicleid)) return 1;
  // Hentikan proses jika kondisi kendaraan berubah.
  if(CekKondisiKendaraan(vehicleid)) return 1;
  // Jangan aktifkan mesin kendaraan mati.
  if(IsDeadPlayerVehicle(vehicleid)) {
    TerapkanKendaraanMati(vehicleid);
    return 1;
  }
  // Pastikan pemain masih mengemudikan kendaraan yang sama.
  if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid) != vehicleid) return 1;
  // Batalkan penyalaan jika bahan bakar habis.
  if(hidupormati && GetFuelKendaraan(vehicleid) <= 0) return 1;
  SetVehicleEngineAndLock(vehicleid, hidupormati, IsKendaraanTerkunci(vehicleid));
  return 1;
}

// Siapkan kondisi visual kendaraan mati.
stock SiapkanVisualKendaraanMati(playerid, slot) {
  // Bodi tetap mengikuti kerusakan terakhir, kap yang masih utuh dibuat rusak
  new hood = _:PVeh[playerid][slot][vDoors] & 0xFF;
  // Rusakkan kap jika masih utuh.
  if(hood < 2) PVeh[playerid][slot][vDoors] = VEHICLE_DOOR_STATUS:(_:PVeh[playerid][slot][vDoors] | 2);
  return 1;
}

// Terapkan kembali kerusakan tersimpan pada kendaraan mati.
stock TerapkanKerusakanKendaraanMati(vehicleid) {
  // Pastikan kendaraan valid dan berstatus mati.
  if(!IsValidVehicle(vehicleid) || !IsDeadPlayerVehicle(vehicleid)) return 0;
  new owner = VehServer[vehicleid][vsPemilik], slot = VehServer[vehicleid][vsSlot];
  new VEHICLE_PANEL_STATUS:panels, VEHICLE_DOOR_STATUS:doors, VEHICLE_LIGHT_STATUS:lights, VEHICLE_TYRE_STATUS:tyres;
  // Ambil status kerusakan kendaraan saat ini.
  if(!GetVehicleDamageStatus(vehicleid, panels, doors, lights, tyres)) return 0;
  // Terapkan kerusakan tersimpan jika kondisinya berbeda.
  if(panels != PVeh[owner][slot][vPanels] || doors != PVeh[owner][slot][vDoors] || lights != PVeh[owner][slot][vLights] || tyres != PVeh[owner][slot][vTyres]) {
    UpdateVehicleDamageStatus(vehicleid, PVeh[owner][slot][vPanels], PVeh[owner][slot][vDoors], PVeh[owner][slot][vLights], PVeh[owner][slot][vTyres]);
  }
  return 1;
}

// Terapkan kondisi kendaraan mati.
stock TerapkanKendaraanMati(vehicleid) {
  // Pastikan kendaraan valid dan berstatus mati.
  if(!IsValidVehicle(vehicleid) || !IsDeadPlayerVehicle(vehicleid)) return 0;
  new owner = VehServer[vehicleid][vsPemilik], slot = VehServer[vehicleid][vsSlot];
  PVeh[owner][slot][vHealth] = 0.0;
  new Float:health;
  GetVehicleHealth(vehicleid, health);
  // Atur kesehatan ke nilai khusus kendaraan mati.
  if(health != DEAD_VEHICLE_HEALTH) SetVehicleHealth(vehicleid, DEAD_VEHICLE_HEALTH);
  SetVehicleEngineAndLock(vehicleid, false, IsKendaraanTerkunci(vehicleid));
  TerapkanKerusakanKendaraanMati(vehicleid);
  return 1;
}

// Tandai kendaraan sebagai mati dan simpan kondisinya.
// Kendaraan yang sama tetap dipakai, pemain tetap berada di kursinya.
stock TandaiKendaraanMati(vehicleid) {
  // Pastikan kendaraan valid dan milik pemain.
  if(!IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid)) return 0;
  new owner = VehServer[vehicleid][vsPemilik], slot = VehServer[vehicleid][vsSlot];
  // Hindari memproses ulang kendaraan yang sudah mati.
  if(IsSlotKendaraanMati(owner, slot)) {
    TerapkanKendaraanMati(vehicleid);
    return 0;
  }

  // Tandai lebih dulu agar callback lain tidak bisa menghidupkan kendaraan ini
  PVeh[owner][slot][vDeath] = 1;
  PVeh[owner][slot][vHealth] = 0.0;
  SalinPosisiKendaraan(owner, slot, vehicleid);
  GetVehicleDamageStatus(vehicleid, PVeh[owner][slot][vPanels], PVeh[owner][slot][vDoors], PVeh[owner][slot][vLights], PVeh[owner][slot][vTyres]);
  SiapkanVisualKendaraanMati(owner, slot);
  TerapkanKendaraanMati(vehicleid);
  SaveSatuKendaraan(owner, slot, false);

  foreach(new playerid : Player) {
    // Abaikan pemain yang tidak berada di kendaraan ini.
    if(GetPlayerVehicleID(playerid) != vehicleid) continue;
    BatalkanTimerMesin(playerid);
    UpdateSpeedoMeter(playerid);
    SendMessageError(playerid, "Mesin kendaraan mengalami kerusakan total. Kendaraan tidak bisa dihidupkan kembali!");
  }
  return 1;
}

// Periksa dan perbarui kondisi kendaraan.
stock CekKondisiKendaraan(vehicleid) {
  // Abaikan kendaraan tidak valid atau bukan milik pemain.
  if(!IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid)) return 0;
  new Float:health;
  // Hentikan pemeriksaan jika kesehatan gagal dibaca.
  if(!GetVehicleHealth(vehicleid, health)) return 0;
  // Pertahankan status kendaraan yang sudah mati.
  if(IsDeadPlayerVehicle(vehicleid)) {
    new bool:changed = health != DEAD_VEHICLE_HEALTH;
    TerapkanKendaraanMati(vehicleid);
    return _:changed;
  }
  // Tandai kendaraan jika kesehatannya kritis.
  if(IsHealthKritis(health)) return TandaiKendaraanMati(vehicleid);
  // Batasi kesehatan kendaraan ke nilai maksimum.
  if(health > 1000.0) {
    health = 1000.0;
    SetVehicleHealth(vehicleid, health);
  }
  PVeh[VehServer[vehicleid][vsPemilik]][VehServer[vehicleid][vsSlot]][vHealth] = health;
  return 0;
}

// Munculkan kendaraan pemain pada dunia dan interior yang ditentukan.
stock SpawnKendaraanPlayer(playerid, slot, world = -1, interior = -1) {
  // Pastikan pemain dan slot kendaraan valid.
  if(!IsSlotKendaraanValid(playerid, slot)) return INVALID_VEHICLE_ID;
  // Gunakan dunia tersimpan jika tidak ditentukan.
  if(world < 0) world = PVeh[playerid][slot][vWorld];
  // Gunakan interior tersimpan jika tidak ditentukan.
  if(interior < 0) interior = PVeh[playerid][slot][vInterior];
  new vehicleid = GetOwnedVehicleInSlot(playerid, slot);
  // Gunakan kembali kendaraan yang sudah muncul.
  if(vehicleid != INVALID_VEHICLE_ID) {
    CekKondisiKendaraan(vehicleid);
    return vehicleid;
  }
  PVeh[playerid][slot][vIdServer] = INVALID_VEHICLE_ID;
  // Tolak data kendaraan yang tidak lengkap atau tidak valid.
  if(!IsDataKendaraanLengkap(playerid, slot)) return INVALID_VEHICLE_ID;
  // Tandai kendaraan mati jika kesehatannya sudah kritis.
  if(!IsSlotKendaraanMati(playerid, slot) && IsHealthKritis(PVeh[playerid][slot][vHealth])) {
    PVeh[playerid][slot][vDeath] = 1;
    PVeh[playerid][slot][vHealth] = 0.0;
    SaveSatuKendaraan(playerid, slot, false);
  }
  vehicleid = CreateVehicle(PVeh[playerid][slot][vModel], PVeh[playerid][slot][vX], PVeh[playerid][slot][vY], PVeh[playerid][slot][vZ], PVeh[playerid][slot][vAngel], PVeh[playerid][slot][vColor1], PVeh[playerid][slot][vColor2], -1);
  // Hentikan proses jika kendaraan gagal dibuat.
  if(vehicleid == INVALID_VEHICLE_ID) return INVALID_VEHICLE_ID;
  RemoveAdminVehicle(vehicleid);
  PVeh[playerid][slot][vIdServer] = vehicleid;
  VehServer[vehicleid][vsPemilik] = playerid;
  VehServer[vehicleid][vsSlot] = slot;
  VehServer[vehicleid][vsGenerasi]++;
  PVeh[playerid][slot][vWorld] = world;
  PVeh[playerid][slot][vInterior] = interior;
  SetVehicleVirtualWorld(vehicleid, world);
  LinkVehicleToInterior(vehicleid, interior);
  // Terapkan pelat jika kendaraan memilikinya.
  if(strlen(PVeh[playerid][slot][vPlate])) SetVehicleNumberPlate(vehicleid, PVeh[playerid][slot][vPlate]);
  SetVehicleEngineAndLock(vehicleid, false, IsKendaraanTerkunci(vehicleid));
  // Pulihkan tampilan kendaraan jika statusnya mati.
  if(IsDeadPlayerVehicle(vehicleid)) {
    SiapkanVisualKendaraanMati(playerid, slot);
    TerapkanKendaraanMati(vehicleid);
  }
  else SetVehicleHealth(vehicleid, PVeh[playerid][slot][vHealth]);
  return vehicleid;
}

// Tambahkan kendaraan baru ke data pemain.
Fungsi: BerikanKendaraan(playerid, model, color) {
  // Pastikan akun siap dan data kendaraan sudah dimuat.
  if(!IsPlayerAccountReady(playerid) || !PVehInfo[playerid][viDimuat]) return 0;
  // Batasi jumlah kendaraan pemain.
  if(PVehInfo[playerid][viJumlah] >= MAX_KENDARAAN) return 0;
  // Validasi model dan warna kendaraan.
  if(!IsSupportedVehicleModel(model) || color < 0 || color > 255) return 0;
  SaveDataKendaraan(playerid);

  new Float:x, Float:y, Float:z;
  GetPlayerPos(playerid, x, y, z);
  // Pastikan posisi kendaraan baru berada di area yang valid.
  if(!ValidWorldPosition(x + 2.0, y, z)) return 0;

  new query[512];
  mysql_format(g_SQL, query, sizeof(query), "INSERT INTO Kendaraan (pid, model, color1, color2, fuel, x, y, z) VALUES ('%d', '%d', '%d', '%d', '%d', '%.4f', '%.4f', '%.4f')", Pemain[playerid][pId], model, color, color, 100, x + 2, y, z);
  new Cache:result = mysql_query(g_SQL, query);
  new bool:saved = mysql_errno(g_SQL) == 0 && cache_is_valid(result) && cache_affected_rows() == 1;
  new databaseid;
  // Catat ID kendaraan setelah penyimpanan berhasil.
  if(saved) databaseid = cache_insert_id();
  // Lepaskan hasil kueri setelah selesai digunakan.
  if(cache_is_valid(result)) cache_delete(result);
  // Batalkan penambahan jika penyimpanan gagal.
  if(!saved || databaseid <= 0) return 0;

  new slot = PVehInfo[playerid][viJumlah]++;
  static const empty[DataVeh];
  PVeh[playerid][slot] = empty;
  PVeh[playerid][slot][vId] = databaseid;
  PVeh[playerid][slot][vModel] = model;
  PVeh[playerid][slot][vColor1] = color;
  PVeh[playerid][slot][vColor2] = color;
  PVeh[playerid][slot][vFuel] = 100;
  PVeh[playerid][slot][vHealth] = 1000.0;
  PVeh[playerid][slot][vX] = x + 2.0;
  PVeh[playerid][slot][vY] = y;
  PVeh[playerid][slot][vZ] = z;
  PVeh[playerid][slot][vIdServer] = INVALID_VEHICLE_ID;
  return 1;
}

// Tangani pemain yang mulai memasuki kendaraan.
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
  #pragma unused ispassenger
  CekKondisiKendaraan(vehicleid);
  // Berikan perlakuan khusus pada kendaraan milik pemain.
  if(IsPlayerOwnedVehicle(vehicleid)) {
    // Cegah pemain memasuki kendaraan yang sudah mati.
    if(IsDeadPlayerVehicle(vehicleid)) {
      TerapkanKendaraanMati(vehicleid);
      SendMessageError(playerid, "Kendaraan ini sudah mati dan tidak bisa dihidupkan kembali!");
      return 1;
    }
    // Beri tahu pemain jika kendaraan terkunci.
    if(IsKendaraanTerkunci(vehicleid)) {
      SendMessageError(playerid, "Kendaraan ini terkunci!");
    }
    SendMessageInfo(playerid, "Gunakan /en atau tombol N untuk menghidupkan mesin kendaraan.");
  }
  return 1;
}

// Perbarui tampilan kendaraan saat status pemain berubah.
public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate) {
  // Bersihkan timer dan speedometer saat pemain keluar dari kendaraan.
  if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) {
    BatalkanTimerMesin(playerid);
    ShowHideSpeedo(playerid, false);
  }
  // Perbarui speedometer saat pemain masuk kendaraan.
  if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) {
    new vehicleid = GetPlayerVehicleID(playerid);
    CekKondisiKendaraan(vehicleid);
    // Terapkan kondisi mati saat kendaraan dimasuki.
    if(IsDeadPlayerVehicle(vehicleid)) TerapkanKendaraanMati(vehicleid);
    ShowHideSpeedo(playerid, IsPlayerOwnedVehicle(vehicleid));
  }
  return 1;
}

// Hitung kecepatan kendaraan.
stock GetVehicleSpeed(vehicleid) {
  new Float:x, Float:y, Float:z;
  GetVehicleVelocity(vehicleid, x, y, z);
  return floatround(floatsqroot((x * x) + (y * y) + (z * z)) * 180, floatround_floor);
}

// Tangani kendaraan yang hancur.
public OnVehicleDeath(vehicleid, killerid) {
  #pragma unused killerid
  // Hapus kendaraan admin yang hancur.
  if(IsValidVehicle(vehicleid) && IsAdminVehicle(vehicleid)) {
    RemoveAdminVehicle(vehicleid);
    DestroyVehicle(vehicleid);
    return 1;
  }
  // Tetap tangani ledakan instan, tenggelam, atau laporan death dari client
  TandaiKendaraanMati(vehicleid);
  return 1;
}

// Pulihkan kondisi kendaraan saat muncul kembali.
public OnVehicleSpawn(vehicleid) {
  // Abaikan kendaraan yang bukan milik pemain.
  if(!IsPlayerOwnedVehicle(vehicleid)) return 1;
  new owner = VehServer[vehicleid][vsPemilik], slot = VehServer[vehicleid][vsSlot];
  // Pulihkan lokasi dan kerusakan kendaraan yang mati.
  if(IsSlotKendaraanMati(owner, slot)) {
    SetVehiclePos(vehicleid, PVeh[owner][slot][vX], PVeh[owner][slot][vY], PVeh[owner][slot][vZ]);
    SetVehicleZAngle(vehicleid, PVeh[owner][slot][vAngel]);
    SetVehicleVirtualWorld(vehicleid, PVeh[owner][slot][vWorld]);
    LinkVehicleToInterior(vehicleid, PVeh[owner][slot][vInterior]);
    TerapkanKendaraanMati(vehicleid);
    return 1;
  }
  // Tandai kendaraan jika kesehatannya sudah kritis.
  if(IsHealthKritis(PVeh[owner][slot][vHealth])) {
    TandaiKendaraanMati(vehicleid);
    return 1;
  }
  SetVehicleHealth(vehicleid, PVeh[owner][slot][vHealth]);
  // Hentikan pemulihan jika pemeriksaan kondisi menemukan masalah.
  if(CekKondisiKendaraan(vehicleid)) return 1;
  SetVehicleEngineAndLock(vehicleid, false, IsKendaraanTerkunci(vehicleid));
  return 1;
}

// Periksa kondisi kendaraan setelah status kerusakan berubah.
public OnVehicleDamageStatusUpdate(vehicleid, playerid) {
  #pragma unused playerid
  CekKondisiKendaraan(vehicleid);
  return 1;
}

// Pantau kondisi semua kendaraan pemain.
Fungsi:JagaKendaraanMati() {
  foreach(new playerid : Player) {
    for(new slot = 0; slot < PVehInfo[playerid][viJumlah]; slot++) {
      CekKondisiKendaraan(PVeh[playerid][slot][vIdServer]);
    }
  }
  return 1;
}

// Perbaiki kendaraan milik pemain dan simpan hasilnya.
stock bool:RepairKendaraanPlayer(vehicleid) {
  // Pastikan kendaraan valid dan dimiliki pemain.
  if(!IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid)) return false;

  new owner = VehServer[vehicleid][vsPemilik], slot = VehServer[vehicleid][vsSlot];
  // Pastikan slot pemain masih menunjuk kendaraan yang sama.
  if(GetOwnedVehicleInSlot(owner, slot) != vehicleid) return false;

  // Hentikan proses jika perbaikan kendaraan gagal.
  if(!RepairVehicle(vehicleid)) return false;
  // Pulihkan kesehatan penuh sebelum memperbarui data kendaraan.
  if(!SetVehicleHealth(vehicleid, 1000.0)) {
    // Terapkan ulang status mati jika kendaraan belum berhasil pulih.
    if(IsDeadPlayerVehicle(vehicleid)) TerapkanKendaraanMati(vehicleid);
    return false;
  }

  new Float:health;
  // Pastikan kendaraan memiliki kesehatan yang valid setelah diperbaiki.
  if(!GetVehicleHealth(vehicleid, health) || health <= VEHICLE_CRITICAL_HEALTH) {
    // Pertahankan status mati jika pemulihan belum berhasil.
    if(IsDeadPlayerVehicle(vehicleid)) TerapkanKendaraanMati(vehicleid);
    return false;
  }

  PVeh[owner][slot][vDeath] = 0;
  PVeh[owner][slot][vHealth] = health;
  PVeh[owner][slot][vPanels] = VEHICLE_PANEL_STATUS:0;
  PVeh[owner][slot][vDoors] = VEHICLE_DOOR_STATUS:0;
  PVeh[owner][slot][vLights] = VEHICLE_LIGHT_STATUS:0;
  PVeh[owner][slot][vTyres] = VEHICLE_TYRE_STATUS:0;

  SetVehicleEngineAndLock(vehicleid, false, IsKendaraanTerkunci(vehicleid));

  foreach(new playerid : Player) {
    // Segarkan speedometer pemain yang berada di kendaraan ini.
    if(GetPlayerVehicleID(playerid) == vehicleid) UpdateSpeedoMeter(playerid);
  }

  // Laporkan kegagalan menyimpan hasil perbaikan.
  if(!SaveSatuKendaraan(owner, slot, true)) {
    printf("[VEHICLE] Gagal menyimpan hasil repair: vehicleid=%d, owner=%d, slot=%d", vehicleid, owner, slot);
  }
  return true;
}

// Cegah pemanggilan kesehatan atau perbaikan menghidupkan kendaraan mati.
// Lindungi kendaraan dari perubahan kesehatan yang tidak valid.
stock bool:SetVehicleHealthProtected(vehicleid, Float:health) {
  // Abaikan ID kendaraan yang tidak valid.
  if(!IsValidVehicle(vehicleid)) return false;
  // Cegah perubahan jika pemeriksaan kondisi kendaraan menemukan kerusakan.
  if(IsPlayerOwnedVehicle(vehicleid) && CekKondisiKendaraan(vehicleid)) return false;
  // Pertahankan kondisi kendaraan yang sudah mati.
  if(IsDeadPlayerVehicle(vehicleid)) {
    TerapkanKendaraanMati(vehicleid);
    return false;
  }
  // Validasi dan simpan kesehatan kendaraan milik pemain.
  if(IsPlayerOwnedVehicle(vehicleid)) {
    // Tolak nilai kesehatan di luar rentang yang diizinkan.
    if(!(health >= 0.0 && health <= 1000.0)) return false;
    // Tandai kendaraan jika kesehatan mencapai batas kritis.
    if(health <= VEHICLE_CRITICAL_HEALTH) {
      TandaiKendaraanMati(vehicleid);
      return true;
    }
    PVeh[VehServer[vehicleid][vsPemilik]][VehServer[vehicleid][vsSlot]][vHealth] = health;
  }
  return SetVehicleHealth(vehicleid, health);
}

// Lindungi proses perbaikan agar kendaraan mati tidak hidup kembali.
stock bool:RepairVehicleProtected(vehicleid) {
  // Abaikan ID kendaraan yang tidak valid.
  if(!IsValidVehicle(vehicleid)) return false;
  // Cegah perbaikan jika kondisi kendaraan perlu ditangani.
  if(IsPlayerOwnedVehicle(vehicleid) && CekKondisiKendaraan(vehicleid)) return false;
  // Pertahankan kondisi kendaraan yang sudah mati.
  if(IsDeadPlayerVehicle(vehicleid)) {
    TerapkanKendaraanMati(vehicleid);
    return false;
  }
  new bool:repaired = RepairVehicle(vehicleid);
  // Perbarui data kerusakan jika kendaraan pemain berhasil diperbaiki.
  if(repaired && IsPlayerOwnedVehicle(vehicleid)) {
    new owner = VehServer[vehicleid][vsPemilik], slot = VehServer[vehicleid][vsSlot];
    PVeh[owner][slot][vHealth] = 1000.0;
    PVeh[owner][slot][vPanels] = VEHICLE_PANEL_STATUS:0;
    PVeh[owner][slot][vDoors] = VEHICLE_DOOR_STATUS:0;
    PVeh[owner][slot][vLights] = VEHICLE_LIGHT_STATUS:0;
    PVeh[owner][slot][vTyres] = VEHICLE_TYRE_STATUS:0;
  }
  return repaired;
}

#define SetVehicleHealth SetVehicleHealthProtected
#define RepairVehicle RepairVehicleProtected
