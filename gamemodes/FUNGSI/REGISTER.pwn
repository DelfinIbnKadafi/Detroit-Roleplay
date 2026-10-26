stock ShowRegisterDialog(playerid)
{
  new
    dl[64],
    gender = Pemain[playerid][pGender]
  ;

  format(dl, sizeof dl, "Data\tValue\nGender:\t%s", gender == 1 ? "Laki-laki" : gender == 2 ? "Perempuan" : "-");
  Dialog_Show(playerid, DL_REGISTER, DIALOG_STYLE_TABLIST_HEADERS, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Register", dl, "Isi", "Batal");
  return 1;
}

stock HandleRegister(playerid)
{
  if(PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_REGISTER || (Pemain[playerid][pGender] != 1 && Pemain[playerid][pGender] != 2)) return 0;
  if(strlen(Pemain[playerid][pPassword]) != BCRYPT_HASH_LENGTH - 1) return 0;
  PlayerLoginStep[playerid] = LOGIN_SAVING;
  Pemain[playerid][pNorek] = random(900000000) + 100000000;
  new query[768];
  // Simpan data awal bersama verifikasi agar tidak hilang jika player disconnect
  mysql_format(g_SQL, query, sizeof query, "UPDATE Pemain SET verified=1, sandi='%e', gender=%d, skin=%d, level=1, uang=100000, norek=%d, posx=%.6f, posy=%.6f, posz=%.6f, angle=%.6f, interior=0, virtualworld=0, darah=100.0, armor=0.0, lapar=100, haus=100 WHERE id=%d AND verified=0", Pemain[playerid][pPassword], Pemain[playerid][pGender], Pemain[playerid][pGender] == 2 ? DEFAULT_FEMALE_SKIN : DEFAULT_MALE_SKIN, Pemain[playerid][pNorek], DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, DEFAULT_POS_A, Pemain[playerid][pId]);


  mysql_tquery(g_SQL, query, "OnRegisterComplete", "iis", playerid, PlayerSession[playerid], Pemain[playerid][pNama]);
  return 1;
}

Fungsi:OnRegisterComplete(playerid, sessionid, const expectedName[])
{
  if(!IsCurrentPlayerSession(playerid, sessionid, expectedName) || PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_SAVING) return 1;
  if(cache_affected_rows() != 1) {
    SendMessageError(playerid, "Data registrasi gagal disimpan. Silakan hubungi admin.");
    return DelayedKick(playerid);
  }
  Pemain[playerid][pVerified] = 1;
  SpawnPemainEx(playerid, .new_player = true);
  return 1;
}


Dialog:DL_REGISTER(playerid, response, listitem, const inputtext[])
{
  if(PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_REGISTER) return 1;
  if(!response)
    return DelayedKick(playerid);

  if(listitem == 0) return Dialog_Show(playerid, DL_REGISTER_GENDER, DIALOG_STYLE_LIST, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Register Gender", "Laki-laki\nPerempuan", "Pilih", "Batal");
  return 1;
}

Dialog:DL_REGISTER_GENDER(playerid, response, listitem, const inputtext[])
{
  if(PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_REGISTER) return 1;
  if(!response)
    return ShowRegisterDialog(playerid);

  if(listitem < 0 || listitem > 1) return ShowRegisterDialog(playerid);
  Pemain[playerid][pGender] = listitem + 1;
  HandleRegister(playerid);
  return 1;
}

Fungsi: OnHashPassword(playerid, hashid, sessionid, const expectedName[]) {
  if(!IsCurrentPlayerSession(playerid, sessionid, expectedName) || PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_HASHING) return 1;
  Pemain[playerid][pPassword] = 0; // sm kayak EOS atau '\0'
  bcrypt_get_hash(Pemain[playerid][pPassword], BCRYPT_HASH_LENGTH);
  if(strlen(Pemain[playerid][pPassword]) != BCRYPT_HASH_LENGTH - 1) {
    SendMessageError(playerid, "Password gagal diproses. Silakan masuk kembali.");
    return DelayedKick(playerid);
  }
  PlayerLoginStep[playerid] = LOGIN_REGISTER;
  printf("Succesfully hash password register!");
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
  Dialog_Show(playerid, DL_CREATE_PW, DIALOG_STYLE_INPUT, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Buat Password", body, "Buat", "Batal");
  return 1;
}


// dl responses
Dialog:DL_VERIFY_CODE(playerid, response, listitem, const inputtext[])
{
  if(PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_CODE) return 1;
  if(!response)
      return DelayedKick(playerid);

  new
    code,
    tmp[128]
  ;
  if(strlen(inputtext) != 6 || !ValidUnsignedInteger(inputtext) || sscanf(inputtext, "d", code))
  {
    new attempts = GetPVarInt(playerid, "verify_attempts") + 1;
    SetPVarInt(playerid, "verify_attempts", attempts);
    SendMessageError(playerid, "Input harus berupa angka");
    if(attempts >= MAX_VERIFY_ATTEMPTS) {
      SendMessageError(playerid, "Batas percobaan kode verifikasi tercapai.");
      return DelayedKick(playerid);
    }
    format(tmp, sizeof tmp, ""E_WHITE"Akun kamu belum terverifikasi oleh sistem.\nSilahkan masukan kode verifikasi 6 digit yang diberikan oleh bot.");
    Dialog_Show(playerid, DL_VERIFY_CODE, DIALOG_STYLE_INPUT, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Verifikasi Kode", tmp, "Verifikasi", "Batal");
  }
  else
  {
    if(Pemain[playerid][pKode] > 0 && code == Pemain[playerid][pKode])
    {
      DeletePVar(playerid, "verify_attempts");
      PlayerLoginStep[playerid] = LOGIN_CREATE_PASSWORD;
      SendMessageServer(playerid, "Kode verifikasi benar, silahkan buat password anda!");
      ShowCreatePasswordDialog(playerid);
    }
    else
    {
      new attempts = GetPVarInt(playerid, "verify_attempts") + 1;
      SetPVarInt(playerid, "verify_attempts", attempts);
      SendMessageError(playerid, "Kode yang kamu masukkan salah. Jika mengalami kendala silahkan hubungi admin.");
      if(attempts >= MAX_VERIFY_ATTEMPTS) {
        SendMessageError(playerid, "Batas percobaan kode verifikasi tercapai.");
        return DelayedKick(playerid);
      }
      format(tmp, sizeof tmp, ""E_WHITE"Akun kamu belum terverifikasi oleh sistem.\nSilahkan masukan kode verifikasi 6 digit yang diberikan oleh bot.");
      Dialog_Show(playerid, DL_VERIFY_CODE, DIALOG_STYLE_INPUT, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Verifikasi Kode", tmp, "Verifikasi", "Batal");
    }
  }
  return 1;
}

Dialog:DL_CREATE_PW(playerid, response, listitem, const inputtext[])
{
  if(PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_CREATE_PASSWORD) return 1;
  if(!response)
      return DelayedKick(playerid);

  if(strlen(inputtext) < 8 || strlen(inputtext) > 32)
  {
    SendMessageError(playerid, "Panjang password tidak valid!");
    ShowCreatePasswordDialog(playerid);
  }
  else {
    PlayerLoginStep[playerid] = LOGIN_HASHING;
    bcrypt_hash(playerid, "OnHashPassword", inputtext, BCRYPT_COST, "is", PlayerSession[playerid], Pemain[playerid][pNama]);
  }
  return 1;
}
