// kendaraan
stock bool:IsPlayerOwnedVehicle(vehicleid) {
  if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES_SERVER) return false;

  new owner = VehOwner[vehicleid];
  new slot  = VehSlot[vehicleid];

  if(owner < 0 || owner >= MAX_PLAYERS || slot < 0 || slot >= MAX_KENDARAAN) return false;
  return PlayerVehID[owner][slot] == vehicleid;
}

stock bool:IsDeadPlayerVehicle(vehicleid) {
  if(!IsPlayerOwnedVehicle(vehicleid)) return false;
  return PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vDeath] != 0;
}

stock MuatDataKendaraan(playerid) {
  VehiclesLoaded[playerid] = false;
  new query[128];
  mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `Kendaraan` WHERE `pid` = %d ORDER BY `vid`", Pemain[playerid][pId]);

  mysql_tquery(g_SQL, query, "OnVehiclesLoaded", "iis", playerid, PlayerSession[playerid], Pemain[playerid][pNama]);
  return 1;
}

Fungsi:OnVehiclesLoaded(playerid, sessionid, const expectedName[]) {
  if(!IsCurrentPlayerSession(playerid, sessionid, expectedName) || !IsPlayerAccountReady(playerid) || VehiclesLoaded[playerid]) return 1;
  new rows = cache_num_rows();
  for(new i = 0; i < rows && i < MAX_KENDARAAN; i++) {
    new databaseid;
    cache_get_value_name_int(i, "vid", databaseid);
    // A pending load must not overwrite a live vehicle's newer death or position.
    new vehicleid = PlayerVehID[playerid][i];
    if(PVeh[playerid][i][vId] == databaseid && (PVeh[playerid][i][vDeath] != 0 || TimerRespawnVeh[playerid][i] != 0 || (IsValidVehicle(vehicleid) && IsPlayerOwnedVehicle(vehicleid)))) continue;

    cache_get_value_name_int(i, "vid", PVeh[playerid][i][vId]);
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
    if(PVeh[playerid][i][vDeath] != 0) {
      PVeh[playerid][i][vDeath] = 1;
      PVeh[playerid][i][vHealth] = 0.0;
    }
  }
  JumVeh[playerid] = rows < MAX_KENDARAAN ? rows : MAX_KENDARAAN;
  VehiclesLoaded[playerid] = true;
  return 1;
}

stock SaveSatuKendaraan(playerid, slot, bool:ambilposisi = true) {
  if(slot < 0 || slot >= JumVeh[playerid]) return 0;
  new vehicleid = PlayerVehID[playerid][slot];
  if(PVeh[playerid][slot][vDeath] != 0) PVeh[playerid][slot][vHealth] = 0.0;
  if(ambilposisi && IsValidVehicle(vehicleid) && IsPlayerOwnedVehicle(vehicleid) && VehOwner[vehicleid] == playerid && VehSlot[vehicleid] == slot) {
    if(PVeh[playerid][slot][vDeath] == 0) GetVehicleHealth(vehicleid, PVeh[playerid][slot][vHealth]);
    GetVehiclePos(vehicleid, PVeh[playerid][slot][vX], PVeh[playerid][slot][vY], PVeh[playerid][slot][vZ]);
    GetVehicleZAngle(vehicleid, PVeh[playerid][slot][vAngel]);
  }
  new query[384];
  mysql_format(g_SQL, query, sizeof(query), "UPDATE Kendaraan SET health='%.1f', x='%.4f', y='%.4f', z='%.4f', angel='%.4f', fuel=%d, kunci=%d, death=%d WHERE vid='%d'", PVeh[playerid][slot][vHealth], PVeh[playerid][slot][vX], PVeh[playerid][slot][vY], PVeh[playerid][slot][vZ], PVeh[playerid][slot][vAngel], PVeh[playerid][slot][vFuel], PVeh[playerid][slot][vKunci], PVeh[playerid][slot][vDeath], PVeh[playerid][slot][vId]);
  mysql_tquery(g_SQL, query);
  return 1;
}

stock SaveDataKendaraan(playerid) {
  for(new i = 0; i < JumVeh[playerid]; i++) SaveSatuKendaraan(playerid, i);
  return 1;
}

stock HancurkanKendaraanPlayer(playerid) {
  for(new i = 0; i < JumVeh[playerid]; i++) {
    KillTimer(TimerRespawnVeh[playerid][i]);
    TimerRespawnVeh[playerid][i] = 0;
    new vehicleid = PlayerVehID[playerid][i];
    if(!IsValidVehicle(vehicleid) || VehOwner[vehicleid] != playerid || VehSlot[vehicleid] != i) {
      PlayerVehID[playerid][i] = INVALID_VEHICLE_ID;
      VehicleIsSpawn[playerid][i] = false;
      continue;
    }
    VehicleIsSpawn[playerid][i] = false;
    VehOwner[vehicleid] = -1;
    VehSlot[vehicleid] = -1;
    MesinVeh[vehicleid] = false;
    PlayerVehID[playerid][i] = INVALID_VEHICLE_ID;
    DestroyVehicle(vehicleid);
  }
  return 1;
}

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

  if(modelid >= 400 && modelid <= 611) {
    format(name, len, "%s", vehicleNames[modelid - 400]);
    return 1;
  }
  format(name, len, "Unknown");
  return 0;
}

stock SetVehicleEngineAndLock(vehicleid, bool:engine, bool:locked) {
  if(!IsValidVehicle(vehicleid)) return 0;
  if(IsDeadPlayerVehicle(vehicleid)) engine = false;
  new currentEngine, lights, alarm, doors, bonnet, boot, objective;
  GetVehicleParamsEx(vehicleid, currentEngine, lights, alarm, doors, bonnet, boot, objective);
  SetVehicleParamsEx(vehicleid, engine, lights, alarm, locked, bonnet, boot, objective);
  MesinVeh[vehicleid] = engine;
  return 1;
}

stock TerapkanKendaraanMati(vehicleid) {
  if(!IsValidVehicle(vehicleid) || !IsDeadPlayerVehicle(vehicleid)) return 0;
  new owner = VehOwner[vehicleid], slot = VehSlot[vehicleid];
  PVeh[owner][slot][vHealth] = 0.0;
  new Float:health;
  GetVehicleHealth(vehicleid, health);
  if(health != DEAD_VEHICLE_HEALTH) SetVehicleHealth(vehicleid, DEAD_VEHICLE_HEALTH);
  SetVehicleEngineAndLock(vehicleid, false, PVeh[owner][slot][vKunci] != 0);
  return 1;
}

stock SpawnKendaraanPlayer(playerid, slot, world = 0, interior = 0) {
  if(slot < 0 || slot >= JumVeh[playerid] || TimerRespawnVeh[playerid][slot] != 0) return INVALID_VEHICLE_ID;
  new vehicleid = PlayerVehID[playerid][slot];
  if(IsValidVehicle(vehicleid) && IsPlayerOwnedVehicle(vehicleid) && VehOwner[vehicleid] == playerid && VehSlot[vehicleid] == slot) return vehicleid;
  PlayerVehID[playerid][slot] = INVALID_VEHICLE_ID;
  VehicleIsSpawn[playerid][slot] = false;
  vehicleid = CreateVehicle(PVeh[playerid][slot][vModel], PVeh[playerid][slot][vX], PVeh[playerid][slot][vY], PVeh[playerid][slot][vZ], PVeh[playerid][slot][vAngel], PVeh[playerid][slot][vColor1], PVeh[playerid][slot][vColor2], -1);
  if(vehicleid == INVALID_VEHICLE_ID) return INVALID_VEHICLE_ID;
  RemoveAdminVehicle(vehicleid);
  PlayerVehID[playerid][slot] = vehicleid;
  VehicleIsSpawn[playerid][slot] = true;
  VehOwner[vehicleid] = playerid;
  VehSlot[vehicleid] = slot;
  VehicleGeneration[vehicleid]++;
  SetVehicleVirtualWorld(vehicleid, world);
  LinkVehicleToInterior(vehicleid, interior);
  SetVehicleEngineAndLock(vehicleid, false, PVeh[playerid][slot][vKunci] != 0);
  if(IsDeadPlayerVehicle(vehicleid)) TerapkanKendaraanMati(vehicleid);
  else SetVehicleHealth(vehicleid, PVeh[playerid][slot][vHealth]);
  return vehicleid;
}

stock BatalkanTimerMesin(playerid) {
  KillTimer(TimerMesin[playerid]);
  TimerMesin[playerid] = 0;
  TextDrawHideForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
  TextDrawHideForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
  return 1;
}

stock ToggleMesinKendaraan(playerid) {
  if(!IsPlayerInAnyVehicle(playerid)) return SendMessageError(playerid, "Kamu tidak berada di kendaraan manapun.");
  new vehicleid = GetPlayerVehicleID(playerid);
  if(!IsPlayerOwnedVehicle(vehicleid)) return SendMessageError(playerid, "Mesin manual hanya tersedia untuk kendaraan milik pemain.");
  if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
  if(IsDeadPlayerVehicle(vehicleid)) {
    BatalkanTimerMesin(playerid);
    TerapkanKendaraanMati(vehicleid);
    return SendMessageError(playerid, "Kendaraan ini sudah mati dan tidak bisa dihidupkan kembali!");
  }
  if(TimerMesin[playerid] != 0) return 1;
  if(!MesinVeh[vehicleid] && PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel] <= 0) return SendMessageError(playerid, "Bahan bakar kendaraan ini sudah habis!");
  new bool:hidup = !MesinVeh[vehicleid];
  TimerMesin[playerid] = SetTimerEx("HidupMatiMesinVeh", 2000, false, "iiiii", playerid, vehicleid, hidup, PlayerSession[playerid], VehicleGeneration[vehicleid]);
  if(hidup) {
    SendMessageInfo(playerid, "Menghidupkan mesin kendaraan....");
    TextDrawShowForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
  }
  else {
    SendMessageInfo(playerid, "Mematikan mesin kendaraan....");
    TextDrawShowForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
  }
  return 1;
}

stock bool:IsAdminVehicle(vehicleid) {
  for(new i = 0; i < jumaveh && i < MAX_VEHICLES_SERVER; i++) {
    if(aveh[i] == vehicleid) return true;
  }
  return false;
}

stock RemoveAdminVehicle(vehicleid) {
  for(new i = 0; i < jumaveh; i++) {
    if(aveh[i] != vehicleid) continue;
    jumaveh--;
    aveh[i] = aveh[jumaveh];
    avehOwner[i] = avehOwner[jumaveh];
    return 1;
  }
  return 1;
}

stock DestroyAdminVehicles(playerid) {
  for(new i = 0; i < jumaveh;) {
    if(avehOwner[i] != playerid) {
      i++;
      continue;
    }
    if(IsValidVehicle(aveh[i])) DestroyVehicle(aveh[i]);
    VehOwner[aveh[i]] = -1;
    VehSlot[aveh[i]] = -1;
    MesinVeh[aveh[i]] = false;
    jumaveh--;
    aveh[i] = aveh[jumaveh];
    avehOwner[i] = avehOwner[jumaveh];
  }
  return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
  #pragma unused ispassenger
  if(IsPlayerOwnedVehicle(vehicleid)) {
    new owner = VehOwner[vehicleid];
    new slot = VehSlot[vehicleid];
    if(PVeh[owner][slot][vDeath] != 0) {
      TerapkanKendaraanMati(vehicleid);
      SendMessageError(playerid, "Kendaraan ini sudah mati dan tidak bisa dihidupkan kembali!");
      return 1;
    }
    if(PVeh[owner][slot][vKunci] == 1) {
      SendMessageError(playerid, "Kendaraan ini terkunci!");
    }
    SendMessageInfo(playerid, "Gunakan /en atau tombol N untuk menghidupkan mesin kendaraan.");
  }
  return 1;
}

public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate) {
  if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) {
    BatalkanTimerMesin(playerid);
    ShowHideSpeedo(playerid, false);
  }
  if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) {
    new vehicleid = GetPlayerVehicleID(playerid);
    if(IsDeadPlayerVehicle(vehicleid)) TerapkanKendaraanMati(vehicleid);
    ShowHideSpeedo(playerid, IsPlayerOwnedVehicle(vehicleid));
  }
  return 1;
}

stock GetVehicleSpeed(vehicleid) {
  new Float:x, Float:y, Float:z, Float:SpeedFloat;
  new Speed;
  
  GetVehicleVelocity(vehicleid, x, y, z);
  SpeedFloat = floatsqroot((x * x) + (y * y) + (z * z)) *  180;
  
  Speed = floatround(SpeedFloat, floatround_floor);
  
  return Speed;
}

Fungsi:HidupMatiMesinVeh(playerid, vehicleid, bool:hidupormati, sessionid, generation) {
  if(!IsPlayerConnected(playerid) || PlayerSession[playerid] != sessionid) return 1;
  if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES_SERVER || VehicleGeneration[vehicleid] != generation) return 1;
  BatalkanTimerMesin(playerid);
  if(!IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid) || IsAdminVehicle(vehicleid)) return 1;
  if(IsDeadPlayerVehicle(vehicleid)) {
    TerapkanKendaraanMati(vehicleid);
    return 1;
  }
  if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid) != vehicleid) return 1;
  if(hidupormati && PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vFuel] <= 0) return 1;
  SetVehicleEngineAndLock(vehicleid, hidupormati, PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vKunci] != 0);
  return 1;
}

Fungsi: BerikanKendaraan(playerid, model, color) {
  if(!IsPlayerAccountReady(playerid) || !VehiclesLoaded[playerid]) return 0;
  if(JumVeh[playerid] >= MAX_KENDARAAN) return 0;
  if(model < 400 || model > 611 || color < 0 || color > 255) return 0;
  SaveDataKendaraan(playerid);
  
  new Float:x, Float:y, Float:z;
  GetPlayerPos(playerid, x, y, z);
  
  new query[512];
  mysql_format(g_SQL, query, sizeof(query), "INSERT INTO Kendaraan (pid, model, color1, color2, fuel, x, y, z) VALUES ('%d', '%d', '%d', '%d', '%d', '%.4f', '%.4f', '%.4f')", Pemain[playerid][pId], model, color, color, 100, x + 2, y, z);
  new Cache:result = mysql_query(g_SQL, query);
  new bool:saved = mysql_errno(g_SQL) == 0 && cache_is_valid(result) && cache_affected_rows() == 1;
  new databaseid;
  if(saved) databaseid = cache_insert_id();
  if(cache_is_valid(result)) cache_delete(result);
  if(!saved || databaseid <= 0) return 0;

  new slot = JumVeh[playerid]++;
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
  PlayerVehID[playerid][slot] = INVALID_VEHICLE_ID;
  VehicleIsSpawn[playerid][slot] = false;
  return 1;
}

// Recreate after the old death callback finishes, even if its vehicle ID is reused.
public OnVehicleDeath(vehicleid, killerid) {
  #pragma unused killerid
  if(IsValidVehicle(vehicleid) && IsAdminVehicle(vehicleid)) {
    RemoveAdminVehicle(vehicleid);
    DestroyVehicle(vehicleid);
    return 1;
  }
  if(!IsValidVehicle(vehicleid) || !IsPlayerOwnedVehicle(vehicleid)) return 1;
  new owner = VehOwner[vehicleid], slot = VehSlot[vehicleid];
  new world = GetVehicleVirtualWorld(vehicleid), interior = GetVehicleInterior(vehicleid);
  GetVehiclePos(vehicleid, PVeh[owner][slot][vX], PVeh[owner][slot][vY], PVeh[owner][slot][vZ]);
  GetVehicleZAngle(vehicleid, PVeh[owner][slot][vAngel]);
  PVeh[owner][slot][vDeath] = 1;
  PVeh[owner][slot][vHealth] = 0.0;
  SaveSatuKendaraan(owner, slot, false);
  foreach(new playerid : Player) {
    if(GetPlayerVehicleID(playerid) != vehicleid) continue;
    BatalkanTimerMesin(playerid);
    ShowHideSpeedo(playerid, false);
  }
  VehOwner[vehicleid] = -1;
  VehSlot[vehicleid] = -1;
  MesinVeh[vehicleid] = false;
  VehicleGeneration[vehicleid]++;
  PlayerVehID[owner][slot] = INVALID_VEHICLE_ID;
  VehicleIsSpawn[owner][slot] = false;
  DestroyVehicle(vehicleid);
  KillTimer(TimerRespawnVeh[owner][slot]);
  TimerRespawnVeh[owner][slot] = SetTimerEx("RespawnKendaraanMati", 250, false, "iiiiii", owner, slot, PlayerSession[owner], PVeh[owner][slot][vId], world, interior);
  return 1;
}

Fungsi:RespawnKendaraanMati(playerid, slot, sessionid, databaseid, world, interior) {
  if(!IsPlayerConnected(playerid) || !StatusLogin[playerid] || PlayerSession[playerid] != sessionid) return 1;
  if(slot < 0 || slot >= JumVeh[playerid] || PVeh[playerid][slot][vId] != databaseid || PVeh[playerid][slot][vDeath] == 0) return 1;
  TimerRespawnVeh[playerid][slot] = 0;
  if(SpawnKendaraanPlayer(playerid, slot, world, interior) == INVALID_VEHICLE_ID) SendMessageError(playerid, "Kendaraan mati gagal dibuat. Gunakan /myveh untuk mencoba spawn kembali.");
  return 1;
}

public OnVehicleSpawn(vehicleid) {
  if(!IsPlayerOwnedVehicle(vehicleid)) return 1;
  new owner = VehOwner[vehicleid], slot = VehSlot[vehicleid];
  if(IsDeadPlayerVehicle(vehicleid)) {
    SetVehiclePos(vehicleid, PVeh[owner][slot][vX], PVeh[owner][slot][vY], PVeh[owner][slot][vZ]);
    SetVehicleZAngle(vehicleid, PVeh[owner][slot][vAngel]);
    TerapkanKendaraanMati(vehicleid);
  }
  else SetVehicleEngineAndLock(vehicleid, false, PVeh[owner][slot][vKunci] != 0);
  return 1;
}

Fungsi:JagaKendaraanMati() {
  foreach(new playerid : Player) {
    for(new slot = 0; slot < JumVeh[playerid]; slot++) {
      if(PVeh[playerid][slot][vDeath] == 0) continue;
      TerapkanKendaraanMati(PlayerVehID[playerid][slot]);
    }
  }
  return 1;
}

// Keep future health/repair calls in this gamemode from reviving dead vehicles.
stock bool:SetVehicleHealthProtected(vehicleid, Float:health) {
  if(IsDeadPlayerVehicle(vehicleid)) {
    TerapkanKendaraanMati(vehicleid);
    return false;
  }
  return SetVehicleHealth(vehicleid, health);
}

stock bool:RepairVehicleProtected(vehicleid) {
  if(IsDeadPlayerVehicle(vehicleid)) {
    TerapkanKendaraanMati(vehicleid);
    return false;
  }
  return RepairVehicle(vehicleid);
}

#define SetVehicleHealth SetVehicleHealthProtected
#define RepairVehicle RepairVehicleProtected
