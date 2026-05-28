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