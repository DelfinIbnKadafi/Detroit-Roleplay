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
       Kamu mempunyai "#MAX_LOGIN_ATTEMPTS" kali kesempatan login untuk memasukkan password"
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