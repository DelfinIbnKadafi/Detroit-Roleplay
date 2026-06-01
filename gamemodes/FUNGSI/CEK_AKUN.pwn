Fungsi: CekVerifikasiAkun(playerid) 
{
  
  // ambil data akun
  cache_get_value_int(0, "id", Pemain[playerid][pId]);
  cache_get_value_int(0, "verified", Pemain[playerid][pVerified]);
  cache_get_value_int(0, "kode", Pemain[playerid][pKode]);
  cache_get_value_name(0, "sandi", Pemain[playerid][pPassword]);
  
  // belum terverifikasi
  new
    tmp[128]
  ;
  if(!Pemain[playerid][pVerified]) 
  {
    format(tmp, sizeof tmp, ""E_WHITE"Akun kamu belum terverifikasi oleh sistem.\nSilahkan masukan kode verifikasi 6 digit yang diberikan oleh bot.");
    Dialog_Show(playerid, DL_VERIFY_CODE, DIALOG_STYLE_INPUT, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Verifikasi Kode", tmp, "Verifikasi", "Batal");
    return 1;
  }
  else 
  {
    format(
      tmp, sizeof(tmp),
     ""E_WHITE"Akun kamu sudah terverifikasi oleh sistem. Silahkan masukkan password kamu dibawah ini dengan benar."
    );
  
    SetPVarInt(playerid, "login_attempts", 0);
    Dialog_Show(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Login", tmp, "Login", "Batal");
  }
  return 1;
}

// cek akun pemain
Fungsi: CekAkunPemain(playerid) 
{
  new 
    str[128]
  ;

  if(cache_num_rows() > 0) 
  {
    mysql_format(
      g_SQL, 
      str, sizeof(str),
      "SELECT id, verified, kode, sandi FROM Pemain WHERE nama='%e'", 
      Pemain[playerid][pNama]
    );
    mysql_tquery(g_SQL, str, "CekVerifikasiAkun", "i", playerid);
  }
  else
  {
    format(str, sizeof str, ""E_WHITE"Akun ini belum terdaftar oleh sistem. Silahkan daftarkan di official discord kami.");
    Dialog_Show(playerid, DL_TMP, DIALOG_STYLE_MSGBOX, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Unregistered Account", str, "Tutup", "");
    DelayedKick(playerid);
  }
  return 1;
}