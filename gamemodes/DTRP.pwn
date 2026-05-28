// DETROIT ROLEPLAY - OPEN SOURCE GAMMODE

//========[CONTRIBUTOR]========//
/*
• Delfin Ibn Kadafi - Founder and Scripter
• Panntzyy - Scripter
• Martin - Scripter (Then)
* Enkgq - Scripter (Three)
*/

//===[INCLUDE]===//
#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <a_mysql>
#include <zcmd>

//===[MODULES]===//
#include "DATA/HEADER" 
#include "FUNGSI/HEADER"
#include "COMMAND/HEADER"

main(){}

public OnGameModeInit() 
{
    g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
    if(g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0) 
    {
      printf("[MySQL] Telah terjadi kesalahan saat menghubungkan koneksi mysql. (#%d)", mysql_errno(g_SQL));
      SendRconCommand("exit");
      return 0;
    }

    printf("[MySQL] Koneksi BERHASIL ke database '%s' (Handle: %d)", MYSQL_DATABASE, _:g_SQL);
    mysql_set_charset("utf8mb4", g_SQL);
    SetGameModeText(SERVER_VERSION);
    DisableInteriorEnterExits();
    return 1;
}

public OnPlayerRequestSpawn(playerid) {
  return 0;
}

public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle)
{
  printf("[MySQL] %s (Public-Function: %s) (#%d)", error, callback, errorid);
  return 1;
}