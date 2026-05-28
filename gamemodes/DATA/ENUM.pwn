// Data player
enum DATA_PEMAIN 
{
  pNama[MAX_PLAYER_NAME],
  pId,
  pVerified,
  pKode,
  pPassword[256],
  pGender,
  pSkin,
  pLevel,
  Float:pDarah,
  Float:pArmor
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

enum {
  DIALOG_UNUSED,
  DIALOG_VERIFIKASI_KODE,
  DIALOG_BUAT_PASSWORD,
  DIALOG_LOGIN,
  DIALOG_GENDER
};

enum DEFAULT_POS 
{
  Float:x = 0.0,
  Float:y = 0.0,
  Float:z = 0.0,
  Float:angel = 0.0
};

new DefaultPos[DEFAULT_POS];

enum DSkin {
  pria = 147,
  wanita = 150
}

new DefaultSkin[DSkin];
new Pemain[MAX_PLAYERS][DATA_PEMAIN];
new PosisiPemain[MAX_PLAYERS][POSISI_PLAYER];