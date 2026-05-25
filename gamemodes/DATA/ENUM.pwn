// Data player
enum DataPemain {
  pNama[MAX_PLAYER_NAME],
  pId,
  pVerified,
  pKode,
  pPassword[256]
};

new Pemain[MAX_PLAYERS][DataPemain];
/////////////////////////////////////////////////////

// enum dialog 
enum dialog_akun {
  DIALOG_UNUSED,
  DIALOG_VERIFIKASI_KODE,
  DIALOG_BUAT_PASSWORD,
  DIALOG_LOGIN
};