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
    cache_get_value_name_float(i, "angel", PVeh[playerid][i][vAngel]);
    
    cache_get_value_name_int(i, "fuel", PVeh[playerid][i][vFuel]);
    cache_get_value_name_int(i, "kunci", PVeh[playerid][i][vKunci]);

    JumVeh[playerid]++;
  }

  cache_delete(result);
  return 1;
}

stock SaveDataKendaraan(playerid) {
  if(JumVeh[playerid] == 0) {
    return 1;
  }
    
  for(new i = 0; i < JumVeh[playerid]; i++) {
    new vehicleid = VehID[PVeh[playerid][i][vId]];
    if(IsValidVehicle(vehicleid)) {
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
     "UPDATE Kendaraan SET health='%.1f', x='%.4f', y='%.4f', z='%.4f', angel='%.4f', fuel=%d, kunci=%d WHERE vid='%d'",
     PVeh[playerid][i][vHealth],
     PVeh[playerid][i][vX],
     PVeh[playerid][i][vY],
     PVeh[playerid][i][vZ],
     PVeh[playerid][i][vAngel],
     PVeh[playerid][i][vFuel],
     PVeh[playerid][i][vKunci],
     PVeh[playerid][i][vId]
    );
    mysql_tquery(g_SQL, query);
  }
  return 1;
}

stock HancurkanKendaraanPlayer(playerid) {
  for(new i = 0; i < JumVeh[playerid]; i++) {
    if(!IsValidVehicle(VehID[PVeh[playerid][i][vId]])) continue;
    DestroyVehicle(VehID[PVeh[playerid][i][vId]]);
  }
  return 1;
}

stock GetVehicleModelName(modelid, name[], len) {
  new const vehicleNames[][] = {
    "Landstalker", "Bravura", "Buffano", "Linerunner", "Perennial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch",
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
    "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Kendrick", "Savanna", "Bandito", "Freight Flat",
    "Streak Carriage", "Kart", "Mower", "Duneride", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30"
  };

  if(modelid >= 400 && modelid <= 611) {
    format(name, len, "%s", vehicleNames[modelid - 400]);
    return 1;
  }
  return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
  new owner = VehOwner[vehicleid];
  new slot  = VehSlot[vehicleid];
  
  if(owner < 0 || owner >= MAX_PLAYERS) return 1;
  if(slot < 0 || slot >= MAX_KENDARAAN) return 1;
  
  if(PVeh[owner][slot][vKunci] == 1) {
    SendMessageError(playerid, "Kendaraan ini terkunci!");
    return 0;
  }
    
  return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
  return 1;
}