Fungsi: OnVerifyPassword(playerid, bool:success)
{
  if(!IsHashSessionValid(playerid) || PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_VERIFYING) {
    printf("[LOGIN] OnVerifyPassword DIBATALKAN: pid=%d step=%d kicking=%d", playerid, _:PlayerLoginStep[playerid], _:PlayerKicking[playerid]);
    return 1;
  }

  new 
    attempts = GetPVarInt(playerid, "login_attempts")
  ;
  if(!success)
  {
    if(++attempts >= MAX_LOGIN_ATTEMPTS)
    {
      SendMessageServer(playerid, "Kamu telah login dengan password yang salah sebanyak "#MAX_LOGIN_ATTEMPTS" kali.");
      SendMessageServer(playerid, "Jika mengalami lupa password silahkan laporkan kepada admin.");
      DelayedKick(playerid);
    }
    else
    {
      PlayerLoginStep[playerid] = LOGIN_PASSWORD;
      new err[128];
      format(err, sizeof(err), "{FF0000}[ERROR]{FFFFFF} Kamu memasukkan password yang salah. (attempts: %d/"#MAX_LOGIN_ATTEMPTS")", attempts);
      SendClientMessage(playerid, 0xFFFFFF, err);
      new tmp[256];
      format(
        tmp, sizeof(tmp),
       ""E_WHITE"Akun kamu sudah terverifikasi oleh sistem.\nSilahkan masukkan password kamu dibawah ini dengan benar."
      );    
      Dialog_Show(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Login", tmp, "Login", "Batal");
    }

    SetPVarInt(playerid, "login_attempts", attempts);
  }
  else
  {
    new 
      query[256]
    ;

    DeletePVar(playerid, "login_attempts");
    PlayerLoginStep[playerid] = LOGIN_LOAD_DATA;
    mysql_format(g_SQL, query, sizeof query, "SELECT * FROM Pemain where id=%d", Pemain[playerid][pId]);
    mysql_tquery(g_SQL, query, "MuatDataPemain", "iis", playerid, PlayerSession[playerid], Pemain[playerid][pNama]);
  }
  return 1;
}

Dialog:DL_LOGIN(playerid, response, listitem, const inputtext[])
{
  if(PlayerKicking[playerid] || PlayerLoginStep[playerid] != LOGIN_PASSWORD) return 1;
  if(!response)
    return DelayedKick(playerid);

  if(strlen(inputtext) < 8 || strlen(inputtext) > 32) 
  {
    SendMessageError(playerid, "Panjang password tidak valid!");
    new tmp[256];
    format(
      tmp, sizeof(tmp),
     ""E_WHITE"Akun kamu sudah terverifikasi oleh sistem. Silahkan masukkan password kamu dibawah ini dengan benar."
    );
    Dialog_Show(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Login", tmp, "Login", "Batal");
  }
  else {
    PlayerLoginStep[playerid] = LOGIN_VERIFYING;
    PlayerHashSession[playerid] = PlayerSession[playerid];
    bcrypt_verify(playerid, "OnVerifyPassword", inputtext, Pemain[playerid][pPassword]);
  }
  return 1;
}
