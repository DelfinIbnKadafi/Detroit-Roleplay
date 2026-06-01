
// Data player
enum DATA_PEMAIN 
{
  pNama[MAX_PLAYER_NAME],
  pId,
  pVerified,
  pKode,
  pPassword[BCRYPT_HASH_LENGTH],
  pGender,
  pSkin,
  pLevel,
  Float:pDarah,
  Float:pArmor,
  pUang
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
  vPlate[16],
  Float:vHealth,
  Float:vX,
  Float:vY,
  Float:vZ,
  Float:vAngel
};

new PVeh[MAX_PLAYERS][MAX_KENDARAAN][DataVeh];