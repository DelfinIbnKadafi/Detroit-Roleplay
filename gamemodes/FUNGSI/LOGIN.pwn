stock SpawnPemainEx(playerid, bool:new_player = false) 
{
  if(!new_player) 
  {
    SetPlayerHealth(playerid, Pemain[playerid][pDarah]);
    SetPlayerArmour(playerid, Pemain[playerid][pArmor]);
    SetPlayerInterior(playerid, PosisiPemain[playerid][pInt]);
    SetPlayerVirtualWorld(playerid, PosisiPemain[playerid][pVW]);
    SetPlayerScore(playerid, Pemain[playerid][pLevel]);
    SetSpawnInfo(
      playerid,
      NO_TEAM,
      Pemain[playerid][pSkin],
      PosisiPemain[playerid][pX],
      PosisiPemain[playerid][pY],
      PosisiPemain[playerid][pZ],
      PosisiPemain[playerid][pAngle]
    );    
  }
  else 
  {
    SetPlayerHealth(playerid, 100.0);
    SetSpawnInfo(
      playerid,
      NO_TEAM,
      Pemain[playerid][pGender] ? DEFAULT_MALE_SKIN : DEFAULT_FEMALE_SKIN,
      DEFAULT_POS_X,
      DEFAULT_POS_Y,
      DEFAULT_POS_Z,
      DEFAULT_POS_A
    );    
    SetPlayerScore(playerid, 1);
  }

  ShowGreetings(playerid);
  SpawnPlayer(playerid);
  return 1;
}

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
     ""E_WHITE"Akun kamu sudah terverifikasi oleh sistem. Silahkan masukkan password kamu dibawah ini dengan benar.\n\
     Kamu mempunya "#MAX_LOGIN_ATTEMPTS" kali kesempatan login untuk memasukkan password"
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

Fungsi: OnVerifyPassword(playerid, bool:success)
{
  new 
    attempts = GetPVarInt(playerid, "login_attempts")
  ;
  if(!success)
  {
    if(++attempts > MAX_LOGIN_ATTEMPTS) 
    {
      SendMessageServer(playerid, "Kamu telah login dengan password yang salah sebanyak "#MAX_LOGIN_ATTEMPTS" kali.");
      SendMessageServer(playerid, "Jika mengalami lupa passsword silahkan laporkan kepada admin.");
      DelayedKick(playerid);
    }
    else
    {
      SendMessageError(playerid, "Kamu memasukkan password yang salah. (attempts: %d/"#MAX_LOGIN_ATTEMPTS")", attempts);
      new tmp[256];
      format(
        tmp, sizeof(tmp),
       ""E_WHITE"Akun kamu sudah terverifikasi oleh sistem.\nSilahkan masukkan password kamu dibawah ini dengan benar.\n\
       Kamu mempunya "#MAX_LOGIN_ATTEMPTS" kali kesempatan login untuk memasukkan password"
      );    
      Dialog_Show(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Login", tmp, "Login", "Batal");
    }

    SetPVarInt(playerid, "login_attempts", attempts);
  }
  else
  {
    new 
      query[32]
    ;

    DeletePVar(playerid, "login_attempts");
    mysql_format(g_SQL, query, sizeof query, "SELECT * FROM Pemain where id=%d", Pemain[playerid][pId]);
    mysql_tquery(g_SQL, query, "MuatDataPemain", "d", playerid);
  }
  return 1;
}

Fungsi: OnHashPassword(playerid)
{
  Pemain[playerid][pPassword] = 0; // sm kayak EOS atau '\0'
  bcrypt_get_hash(Pemain[playerid][pPassword]);
  ShowRegisterDialog(playerid);
  return 1;
}


stock ShowCreatePasswordDialog(playerid)
{
  new
    body[256]
  ;
  format(
    body, 
    sizeof body,
    ""E_WHITE"Silahkan buat password akun kamu dibawah ini dengan mengikuti format berikut:\n\
    - Panjang password harus 8-32 karakter"
  );
  Dialog_Show(playerid, DL_CREATE_PW, DIALOG_STYLE_INPUT, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Buat Passsword", body, "Buat", "Batal");
  return 1;
}


// dl responses
Dialog:DL_VERIFY_CODE(playerid, response, listitem, const inputtext[])
{
  if(!response) 
      return DelayedKick(playerid);

  new 
    code,
    tmp[128]
  ;
  if(sscanf(inputtext, "d", code))
  {
    SendMessageError(playerid, "Input harus berupa angka");
    format(tmp, sizeof tmp, ""E_WHITE"Akun kamu belum terverifikasi oleh sistem.\nSilahkan masukan kode verifikasi 6 digit yang diberikan oleh bot.");
    Dialog_Show(playerid, DL_VERIFY_CODE, DIALOG_STYLE_INPUT, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Verifikasi Kode", tmp, "Verifikasi", "Batal");
  }
  else
  {
    if(code == Pemain[playerid][pKode])
    {
        SendMessageServer(playerid, "Kode verifikasi benar, silahkan buat password anda!");
        ShowCreatePasswordDialog(playerid);
    }
    else
    {
      SendMessageError(playerid, "Kode yang kamu masukkan salah. Jika mengalami kendala silahkan hubungi admin.");
      format(tmp, sizeof tmp, ""E_WHITE"Akun kamu belum terverifikasi oleh sistem.\nSilahkan masukan kode verifikasi 6 digit yang diberikan oleh bot.");
      Dialog_Show(playerid, DL_VERIFY_CODE, DIALOG_STYLE_INPUT, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Verifikasi Kode", tmp, "Verifikasi", "Batal");
    }
  }
  return 1;
}

Dialog:DL_LOGIN(playerid, response, listitem, const inputtext[])
{
  if(!response)
    return DelayedKick(playerid);

  if(strlen(inputtext) < 8 || strlen(inputtext) > 32) 
  {
    SendMessageError(playerid, "Panjang password tidak valid!");
    new tmp[256];
    format(
      tmp, sizeof(tmp),
     ""E_WHITE"Akun kamu sudah terverifikasi oleh sistem. Silahkan masukkan password kamu dibawah ini dengan benar.\n\
     Kamu mempunya 3 kali kesempatan login untuk memasukkan password"
    );
    Dialog_Show(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Login", tmp, "Login", "Batal");
  }
  else bcrypt_verify(playerid, "OnVerifyPassword", inputtext, Pemain[playerid][pPassword]);
  return 1;
}

Dialog:DL_CREATE_PW(playerid, response, listitem, const inputtext[])
{
  if(!response)
      return DelayedKick(playerid);

  if(strlen(inputtext) < 8 || strlen(inputtext) > 32) 
  {
    SendMessageError(playerid, "Panjang password tidak valid!");
    new tmp[256];
    format(
      tmp, sizeof(tmp),
     ""E_WHITE"Akun kamu sudah terverifikasi oleh sistem. Silahkan masukkan password kamu dibawah ini dengan benar.\n\
     Kamu mempunya 3 kali kesempatan login untuk memasukkan password"
    );
    Dialog_Show(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Login", tmp, "Login", "Batal");
  }
  else bcrypt_hash(playerid, "OnHashPassword", inputtext, BCRYPT_COST);
  return 1;
}