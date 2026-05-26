// definisi fungsi login
forward CekAkunPemain(playerid);
forward CekVerifikasiAkun(playerid);
forward OnSetGender(playerid);
forward PemainSetData(playerid);
forward MuatDataLogin(playerid);
forward SpawnPemainEx(playerid);

// fungsi spawn pemain
public SpawnPemainEx(playerid) {
  // login
  if(TipeLogin[playerid] == 0) {
  
    return 1;
  }
  // register
  if(TipeLogin[playerid] == 1) {
    
    return 1;
  }
  
  return 1;
}

// load data login
public MuatDataLogin(playerid) {
  
  cache_get_value_int(0, "gender", Pemain[playerid][pGender]);
  cache_get_value_int(0, "skin", Pemain[playerid][pSkin]);
  cache_get_value_int(0, "level", Pemain[playerid][pLevel]);
  
  // float
  cache_get_value_name_float(0, "posx", PosisiPemain[playerid][x]);
  cache_get_value_name_float(0, "posy", PosisiPemain[playerid][y]);
  cache_get_value_name_float(0, "posz", PosisiPemain[playerid][z]);
  cache_get_value_name_float(0, "angel", PosisiPemain[playerid][angel]);
  
  TipeLogin[playerid] = 0;
  
  SpawnPemainEx(playerid);
  
  return 1;
}

// setelah player set data
public PemainSetData(playerid) {
  
  return 1;
}

// set gender
public OnSetGender(playerid) {
  new query[256];
  mysql_format(g_SQL, query, sizeof(query), "UPDATE Pemain SET verified=1, sandi='%e', gender='%d' WHERE id='%d'",
  pwbaru[playerid], gender[playerid], Pemain[playerid][pId]);
  mysql_tquery(g_SQL, query, "PemainSetData","i", playerid);
  
  // set status login
  StatusLogin[playerid] = true;
  
  return 1;
}

// cek verifikasi akun pemain
public CekVerifikasiAkun(playerid) {
  
  // ambil data akun
  cache_get_value_int(0, "id", Pemain[playerid][pId]);
  cache_get_value_int(0, "verified", Pemain[playerid][pVerified]);
  cache_get_value_int(0, "kode", Pemain[playerid][pKode]);
  cache_get_value_name(0, "sandi", Pemain[playerid][pPassword]);
  
  // belum terverifikasi
  if(Pemain[playerid][pVerified] == 0) {
    new str[256];
    format(str, sizeof(str),
     "Akun {FFF000}%s {FFFFFF}belum diverifikasi.\n\nMasukkan kode verifikasi 6 digit yang telah diberikan.",
     Pemain[playerid][pNama]
    );
    
    ShowPlayerDialog(playerid, DIALOG_VERIFIKASI_KODE, DIALOG_STYLE_INPUT,
     "{CD7000}Detroit {FFFFFF}Roleplay - Account Verification",
     str,
     "Kirim", "Batal"
    );
    return 1;
  }
  // sudah terverifikasi/login
  else {
    new str[512];
    format(str, sizeof(str),
     "Akun {FFF000}%s {FFFFFF}sudah terdaftar.\n\nSilahkan masukkan password akun anda.",
     Pemain[playerid][pNama]
    );
    
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
     "{CD7000}Detroit {FFFFFF}Roleplay - Account Login",
     str,
     "Kirim", "Batal"
    );
  }
  return 1;
}

// cek akun pemain
public CekAkunPemain(playerid) {
  if(!IsPlayerConnected(playerid)) {
    return 1;
  }
  
  if(cache_num_rows() > 0) {
    new query[256];
    mysql_format(g_SQL, query, sizeof(query),
     "SELECT id, verified, kode, sandi FROM Pemain WHERE nama='%e'", 
     Pemain[playerid][pNama]
    );
    mysql_tquery(g_SQL, query, "CekVerifikasiAkun", "i", playerid);
    
    return 1;
  }
  
  // tidak ada akun/Data
  
  new str[256];
  format(str, sizeof(str), "Akun {e516fd}%s {ffffff}belum terdaftar, silahkan daftarkan\n\nakun anda di discord kami.", Pemain[playerid][pNama]);
  
  ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX,
   "{CD7000}Detroit {FFFFFF}Roleplay - Account Information",
   str,
   "Kembali", " "
  );
  
  SetTimerEx("KickPemain", 5000, false, "i", playerid);
  
  return 1;
}