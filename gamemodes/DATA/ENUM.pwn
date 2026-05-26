// Data player
enum DataPemain {
  pNama[MAX_PLAYER_NAME],
  pId,
  pVerified,
  pKode,
  pPassword[256],
  pGender,
  pSkin,
  pLevel
};

new Pemain[MAX_PLAYERS][DataPemain];

// posisi player
enum PosisiPlayer {
  Float:x,
  Float:y,
  Float:z,
  Float:angel
};

new PosisiPemain[MAX_PLAYERS][PosisiPlayer];
/////////////////////////////////////////////////////

// enum dialog 
enum {
  DIALOG_UNUSED,
  DIALOG_VERIFIKASI_KODE,
  DIALOG_BUAT_PASSWORD,
  DIALOG_LOGIN,
  DIALOG_GENDER
};