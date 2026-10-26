
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

// veh 
enum DataVeh {
  vId,
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
  vKunci,
  vDeath
};

new PVeh[MAX_PLAYERS][MAX_KENDARAAN][DataVeh];
