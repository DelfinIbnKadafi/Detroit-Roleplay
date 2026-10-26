//===[VARIABLE]===//
new MySQL:g_SQL;

new bool:StatusLogin[MAX_PLAYERS];
new bool:NewPlayerPendingSave[MAX_PLAYERS];
new PlayerSession[MAX_PLAYERS];

new PlayerDeath[MAX_PLAYERS] = false;

// mute
new JumlahSpam[MAX_PLAYERS];
new bool:Mute[MAX_PLAYERS];
new ChatWindowStart[MAX_PLAYERS];
new TimerUnMute[MAX_PLAYERS];

// kendaraan
new JumVeh[MAX_PLAYERS];
new PendingVehicleGrants[MAX_PLAYERS];
new PilihanVeh[MAX_PLAYERS];

new PlayerVehID[MAX_PLAYERS][MAX_KENDARAAN];
new VehOwner[MAX_VEHICLES_SERVER] = {-1, ...};
new VehSlot[MAX_VEHICLES_SERVER] = {-1, ...};
new bool:MesinVeh[MAX_VEHICLES_SERVER];
new bool:VehicleIsSpawn[MAX_PLAYERS][MAX_KENDARAAN];
new VehicleGeneration[MAX_VEHICLES_SERVER];
new TimerRespawnVeh[MAX_PLAYERS][MAX_KENDARAAN];
new TimerDeadVehicle;

// timer 
new TimerLapar[MAX_PLAYERS];
new TimerHaus[MAX_PLAYERS];
new TimerHBE[MAX_PLAYERS];
new TimerSpedo[MAX_PLAYERS];
new TimerAutoSave[MAX_PLAYERS];
new TimerMesin[MAX_PLAYERS];

// gender 
new const GetGender[][] = {
  "Belum diatur", "Pria", "Wanita"
};

// admin
new Admin[MAX_PLAYERS];
new bool:AdminDuty[MAX_PLAYERS];
new aveh[MAX_VEHICLES_SERVER];
new avehOwner[MAX_VEHICLES_SERVER];
new jumaveh;

// pintu
new bool:TdPintuShown[MAX_PLAYERS];
new bool:dekatPintu[MAX_PLAYERS] = false;
