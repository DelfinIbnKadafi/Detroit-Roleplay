
enum LoginStep {
  LOGIN_LOADING,
  LOGIN_CODE,
  LOGIN_CREATE_PASSWORD,
  LOGIN_HASHING,
  LOGIN_REGISTER,
  LOGIN_SAVING,
  LOGIN_PASSWORD,
  LOGIN_VERIFYING,
  LOGIN_LOAD_DATA,
  LOGIN_FINISHED
}

new LoginStep:PlayerLoginStep[MAX_PLAYERS];

// Data player
enum DATA_PEMAIN 
{
  pNama[MAX_PLAYER_NAME + 1],
  pId,
  pVerified,
  pKode,
  pPassword[BCRYPT_HASH_LENGTH],
  pGender,
  pSkin,
  pLevel,
  Float:pDarah,
  Float:pArmor,
  pUang,
  pBank,
  pNorek,
  pPhone,
  pPhoneStatus,
  pNohp[17],
  pKtp,
  pDateBirth[65],
  pJob,
  pHaus,
  pLapar
};

enum POSISI_PLAYER 
{
  Float:pX,
  Float:pY,
  Float:pZ,
  Float:pAngle,
  pInt,
  pVW
};

new Pemain[MAX_PLAYERS][DATA_PEMAIN];
new PosisiPemain[MAX_PLAYERS][POSISI_PLAYER];




// kendaraan
enum DataVeh {
  vId,  // kolom vid, ID unik di database
  vModel,
  vColor1,
  vColor2,
  vPlate[17],
  Float:vHealth,
  Float:vX,
  Float:vY,
  Float:vZ,
  Float:vAngel,
  vFuel,
  vKunci, // 0 = terbuka, 1 = terkunci
  vDeath, // 0 = hidup, 1 = mati total
  VEHICLE_PANEL_STATUS:vPanels,
  VEHICLE_DOOR_STATUS:vDoors,
  VEHICLE_LIGHT_STATUS:vLights,
  VEHICLE_TYRE_STATUS:vTyres,
  vWorld,
  vInterior,
  vIdServer // ID kendaraan di server (INVALID_VEHICLE_ID jika belum di-spawn)
};

enum DataVehInfo {
  viJumlah,  // jumlah kendaraan yang dimiliki
  viPilihan,  // slot yang dipilih di dialog /myveh
  bool:viDimuat,  // true jika data kendaraan sudah selesai dimuat dari database
  viTimerMesin   // timer menghidupkan / mematikan mesin
};

enum DataVehServer {
  vsPemilik, // playerid pemilik, VEH_KOSONG jika bukan kendaraan pemain
  vsSlot,  // slot milik pemilik, VEH_KOSONG jika bukan kendaraan pemain
  bool:vsMesin,   // true jika mesin sedang menyala
  vsGenerasi,   // bertambah setiap kendaraan dibuat, untuk membatalkan callback timer lama
  vsAdmin   // playerid admin yang membuat kendaraan, VEH_KOSONG jika bukan kendaraan admin
};

new PVeh[MAX_PLAYERS][MAX_KENDARAAN][DataVeh];
new PVehInfo[MAX_PLAYERS][DataVehInfo];
new VehServer[MAX_VEHICLES_SERVER][DataVehServer] = {{VEH_KOSONG, VEH_KOSONG, false, 0, VEH_KOSONG}, ...};
