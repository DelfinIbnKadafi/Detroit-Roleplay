// main includes
#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <a_mysql>
#include <strlib>
#include <samp_bcrypt>
#include <easyDialog>
#include <zcmd>
#include <foreach>


// local includes
#include "DATA/header" 
#include "FUNGSI/header"
#include "COMMAND/header"
#include "COMMAND/DIALOG/header"


main(){}

public OnGameModeInit() 
{
    g_SQL = mysql_connect_file();
    if(g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0) 
    {
      printf("[MySQL] Telah terjadi kesalahan saat menghubungkan koneksi mysql. (#%d)", mysql_errno(g_SQL));
      SendRconCommand("exit");
      return 0;
    }

    printf("[MySQL] Koneksi mysql berhasil terhubung dengan baik.");
    mysql_set_charset("utf8mb4", g_SQL);
    SetGameModeText(SERVER_VERSION);
    return 1;
}

// connect/disconnect
public OnPlayerConnect(playerid) 
{
  SetPlayerColor(playerid, 0xFFFFFFFF);
  GetPlayerName(playerid, Pemain[playerid][pNama], MAX_PLAYER_NAME);
  SendMessageServer(playerid, "Selamat datang di server Detroit Roleplay.");
  SendMessageServer(playerid, "Akun kamu sedang kami proses");
  
  // cek akun player
  new query[256];
  mysql_format(
    g_SQL, 
    query, sizeof(query),
    "SELECT * FROM Pemain WHERE nama='%e'",
    Pemain[playerid][pNama]
  );
  mysql_pquery(g_SQL, query, "CekAkunPemain", "i", playerid);  
  return 1;
}

public OnPlayerDisconnect(playerid, reason) 
{
  SimpanDataPemain(playerid);
  ResetDataPemain(playerid);
  return 1;
}
//////////////////////////////////////////////////////////////////////////

public OnPlayerRequestSpawn(playerid) 
{
  return 0;
}

public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle)
{
  printf("[MySQL] %s (Public-Function: %s) (#%d)", error, callback, errorid);
  return 1;
}