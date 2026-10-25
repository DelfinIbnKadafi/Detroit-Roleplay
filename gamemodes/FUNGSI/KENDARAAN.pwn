// kendaraan
stock MuatDataKendaraan(playerid) {
  new query[128];
  mysql_format(g_SQL, query, sizeof(query),
   "SELECT * FROM `Kendaraan` WHERE `pid` = %d", Pemain[playerid][pId]);

  mysql_tquery(g_SQL, query, "OnVehiclesLoaded", "iis", playerid, PlayerSession[playerid], Pemain[playerid][pNama]);
  return 1;
}

Fungsi:OnVehiclesLoaded(playerid, sessionid, const expectedName[]) {
  if(!IsCurrentPlayerSession(playerid, sessionid, expectedName) || !StatusLogin[playerid]) return 1;
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
    cache_get_value_name_float(i, "angel", PVeh[playerid][i][vAngel]);
    
    cache_get_value_name_int(i, "fuel", PVeh[playerid][i][vFuel]);
    cache_get_value_name_int(i, "kunci", PVeh[playerid][i][vKunci]);

    cache_get_value_name_int(i, "death", PVeh[playerid][i][vDeath]);

    JumVeh[playerid]++;
  }

  return 1;
}

Fungsi:OnVehicleGranted(playerid, sessionid, const expectedName[]) {
  if(!IsCurrentPlayerSession(playerid, sessionid, expectedName)) return 1;
  if(PendingVehicleGrants[playerid] > 0) PendingVehicleGrants[playerid]--;
  if(cache_affected_rows() != 1) {
    SendMessageError(playerid, "Kendaraan gagal disimpan ke database.");
    return 1;
  }
  MuatDataKendaraan(playerid);
  return 1;
}

stock SaveDataKendaraan(playerid) {
  if(JumVeh[playerid] == 0) {
    return 1;
  }
    
  for(new i = 0; i < JumVeh[playerid]; i++) {
    new vehicleid = PlayerVehID[playerid][i];
    if(IsValidVehicle(vehicleid) && VehOwner[vehicleid] == playerid && VehSlot[vehicleid] == i) {
      GetVehicleHealth(vehicleid, PVeh[playerid][i][vHealth]);
      GetVehiclePos(vehicleid,
       PVeh[playerid][i][vX],
       PVeh[playerid][i][vY],
       PVeh[playerid][i][vZ]
      );
      GetVehicleZAngle(vehicleid, PVeh[playerid][i][vAngel]);
    }
      
    new query[256];
    mysql_format(g_SQL, query, sizeof(query),
     "UPDATE Kendaraan SET health='%.1f', x='%.4f', y='%.4f', z='%.4f', angel='%.4f', fuel=%d, kunci=%d, death=%d WHERE vid='%d'",
     PVeh[playerid][i][vHealth],
     PVeh[playerid][i][vX],
     PVeh[playerid][i][vY],
     PVeh[playerid][i][vZ],
     PVeh[playerid][i][vAngel],
     PVeh[playerid][i][vFuel],
     PVeh[playerid][i][vKunci],
     PVeh[playerid][i][vDeath],
     PVeh[playerid][i][vId]
    );
    mysql_tquery(g_SQL, query);
  }
  return 1;
}

stock HancurkanKendaraanPlayer(playerid) {
  for(new i = 0; i < JumVeh[playerid]; i++) {
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
  return 0;
}

stock bool:IsPlayerOwnedVehicle(vehicleid) {
  if(vehicleid < 0 || vehicleid >= MAX_VEHICLES_SERVER) return false;

  new owner = VehOwner[vehicleid];
  new slot  = VehSlot[vehicleid];

  if(owner < 0 || owner >= MAX_PLAYERS || slot < 0 || slot >= MAX_KENDARAAN) return false;
  return PlayerVehID[owner][slot] == vehicleid;
}

stock SetVehicleEngineAndLock(vehicleid, bool:engine, bool:locked) {
  new currentEngine, lights, alarm, doors, bonnet, boot, objective;
  GetVehicleParamsEx(vehicleid, currentEngine, lights, alarm, doors, bonnet, boot, objective);
  SetVehicleParamsEx(vehicleid, engine, lights, alarm, locked, bonnet, boot, objective);
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
    if(PVeh[owner][slot][vKunci] == 1) {
      SendMessageError(playerid, "Kendaraan ini terkunci!");
    }
    SendMessageInfo(playerid, "Gunakan /en atau tombol N untuk menghidupkan mesin kendaraan.");
  }
  return 1;
}

public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate) {
  if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) {
    ShowHideSpeedo(playerid, false);
  }
  if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) {
    new vehicleid = GetPlayerVehicleID(playerid);
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

Fungsi: HidupMatiMesinVeh(playerid, vehicleid, bool:hidupormati, sessionid) {
  if(!IsPlayerConnected(playerid) || PlayerSession[playerid] != sessionid) return 1;
  if(!IsPlayerConnected(playerid) || !IsValidVehicle(vehicleid)) return 1;
  if(!IsPlayerOwnedVehicle(vehicleid) || IsAdminVehicle(vehicleid)) {
    TextDrawHideForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
    TextDrawHideForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
    return 1;
  }
  if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid) != vehicleid) {
    TextDrawHideForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
    TextDrawHideForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
    return 1;
  }
  
  if(hidupormati == true) {
    SetVehicleEngineAndLock(vehicleid, true, PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vKunci] != 0);
    MesinVeh[vehicleid] = true;
    TextDrawHideForPlayer(playerid, MENGHIDUPKAN_MESIN_KENDARAAN[0]);
  }
  else {
    SetVehicleEngineAndLock(vehicleid, false, PVeh[VehOwner[vehicleid]][VehSlot[vehicleid]][vKunci] != 0);
    MesinVeh[vehicleid] = false;
    TextDrawHideForPlayer(playerid, MEMATIKAN_MESIN_KENDARAAN[0]);
  }
  return 1;
}

Fungsi: BerikanKendaraan(playerid, model, color) {
  if(!IsPlayerConnected(playerid) || !StatusLogin[playerid]) return 0;
  if(JumVeh[playerid] + PendingVehicleGrants[playerid] >= MAX_KENDARAAN) return 0;
  if(model < 400 || model > 611 || color < 0 || color > 255) return 0;
  SaveDataKendaraan(playerid);
  
  new Float:x, Float:y, Float:z;
  GetPlayerPos(playerid, x, y, z);
  
  new query[512];
  mysql_format(g_SQL, query, sizeof(query), "INSERT INTO Kendaraan (pid, model, color1, color2, fuel, x, y, z) VALUES ('%d', '%d', '%d', '%d', '%d', '%.4f', '%.4f', '%.4f')", Pemain[playerid][pId], model, color, color, 100, x + 2, y, z);
  PendingVehicleGrants[playerid]++;
  mysql_tquery(g_SQL, query, "OnVehicleGranted", "iis", playerid, PlayerSession[playerid], Pemain[playerid][pNama]);
  return 1;
}

// vehicle hancur
public OnVehicleDeath(vehicleid, killerid) {

  // hancurkan vehicle yang respawn
  DestroyVehicle(vehicleid);

  foreach(new i : Player) {
    for(new a = 0; a < JumVeh[i]; i++) {
      if(vehicleid == PlayerVehID[i][a]) {
        GetVehiclePos(vehicleid, PVeh[i][a][vX], PVeh[i][a][vY], PVeh[i][a][vZ]);
        GetVehicleZAngle(vehicleid, PVeh[i][a][vAngel]);
        new idp = a;
        PlayerVehID[i][a] = CreateVehicle(
          PVeh[i][idp][vModel],
          PVeh[i][idp][vX],
          PVeh[i][idp][vY],
          PVeh[i][idp][vZ],
          PVeh[i][idp][vAngel],
          PVeh[i][idp][vColor1],
          PVeh[i][idp][vColor2],
          -1
        );
        SetVehicleHealth(PlayerVehID[i][a], 999999.0);
        PVeh[i][a][vDeath] = 1;

        break;
      }
      continue;
    }
  }
  return 1;
}