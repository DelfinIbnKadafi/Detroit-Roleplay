//===[VARIABLE]===//
new MySQL:g_SQL;

new bool:StatusLogin[MAX_PLAYERS];

// mute
new JumlahSpam[MAX_PLAYERS];
new bool:Mute[MAX_PLAYERS];

// kendaraan
new JumVeh[MAX_PLAYERS];
new PilihanVeh[MAX_PLAYERS];

new VehID[MAX_VEHICLES_SERVER];
new VehOwner[MAX_VEHICLES_SERVER];
new VehSlot[MAX_VEHICLES_SERVER];
new bool:MesinVeh[MAX_VEHICLES_SERVER];
new bool:VehicleIsSpawn[MAX_KENDARAAN];

// timer 
new TimerLapar[MAX_PLAYERS];
new TimerHaus[MAX_PLAYERS];
new TimerHBE[MAX_PLAYERS];

// gender 
new const GetGender[][] = {
  "Gay/Lesbi", "Pria", "Wanita"
};