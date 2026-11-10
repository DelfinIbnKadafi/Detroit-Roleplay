//===[VARIABLE]===//
new MySQL:g_SQL;

new bool:StatusLogin[MAX_PLAYERS];
new bool:NewPlayerPendingSave[MAX_PLAYERS];
new PlayerSession[MAX_PLAYERS];
new bool:PlayerKicking[MAX_PLAYERS];

new PlayerDeath[MAX_PLAYERS] = false;
new TimerDown[MAX_PLAYERS];
new DownGeneration[MAX_PLAYERS];

// mute
new JumlahSpam[MAX_PLAYERS];
new bool:Mute[MAX_PLAYERS];
new ChatWindowStart[MAX_PLAYERS];
new TimerUnMute[MAX_PLAYERS];

// kendaraan
// Data kendaraan (PVeh, PVehInfo, VehServer) ada di DATA/ENUM.pwn
new TimerDeadVehicle;
new TimerLoadAtm;

// timer 
new TimerLapar[MAX_PLAYERS];
new TimerHaus[MAX_PLAYERS];
new TimerHBE[MAX_PLAYERS];
new TimerSpedo[MAX_PLAYERS];
new TimerAutoSave[MAX_PLAYERS];

// gender 
new const GetGender[][] = {
  "Belum diatur", "Pria", "Wanita"
};

// admin
new Admin[MAX_PLAYERS];
new bool:AdminDuty[MAX_PLAYERS];

// pintu
new bool:TdPintuShown[MAX_PLAYERS];
new bool:TdPintuExitShown[MAX_PLAYERS];
new bool:dekatPintu[MAX_PLAYERS] = false;

// busines player
new bool:playerinbussines[MAX_PLAYERS] = false;
new PlayerBusinessCount[MAX_PLAYERS] = 0;
new IdBusinessPlayer[MAX_PLAYERS][MAX_BUSSINES_PLAYER];