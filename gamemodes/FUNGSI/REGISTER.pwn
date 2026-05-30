stock ShowRegisterDialog(playerid)
{
	new 
		dl[64],
		gender = Pemain[playerid][pGender]
	;
	
	strcat(dl, "Data\tValue\n");
	format(
		dl, sizeof dl,
		"%s\
		Gender: %s",
		dl,
		gender == 1 ? "Laki-laki" : gender == 2 ? "Perempuan" : "-"
	);
	Dialog_Show(playerid, DL_REGISTER, DIALOG_STYLE_TABLIST_HEADERS, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Register", dl, "Isi", "Batal");
	return 1;
}

stock HandleRegister(playerid)
{
  new query[256];
  mysql_format(
    g_SQL, query, 
    sizeof(query), 
    "UPDATE Pemain SET verified=1, sandi='%e', gender='%d' WHERE id='%d'",
    Pemain[playerid][pPassword], Pemain[playerid][pGender], Pemain[playerid][pId]
  );


  if(mysql_tquery(g_SQL, query))
  {
    SpawnPemainEx(playerid, .new_player = true);
  }
  else 
  {
    // error, cek (OnQueryError)...
    SendMessageInfo(playerid, "Kesalahan tidak terduga. (check: OnQueryError)");
    DelayedKick(playerid);
  }
  return 1;
}


Dialog:DL_REGISTER(playerid, response, listitem, const inputtext[])
{
	if(!response)
		return DelayedKick(playerid);

	if(listitem == 0) return Dialog_Show(playerid, DL_REGISTER_GENDER, DIALOG_STYLE_LIST, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Register Gender", "Laki-laki\nPerempuan", "Pilih", "Batal");
	return 1;
}

Dialog:DL_REGISTER_GENDER(playerid, response, listitem, const inputtext[])
{
	if(!response)
		return ShowRegisterDialog(playerid);

	Pemain[playerid][pGender] = listitem + 1;
	HandleRegister(playerid);
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
     ""E_WHITE"Silahkan masukkan password untuk akun anda, minimal 8-32 karakter!"
    );
    Dialog_Show(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Register", tmp, "Login", "Batal");
  }
  else bcrypt_hash(playerid, "OnHashPassword", inputtext, BCRYPT_COST);
  return 1;
}