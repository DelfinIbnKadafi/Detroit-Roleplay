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

//===[OnGameModeInit]===//

public OnGameModeInit() {
    SetGameModeText(server_version);

    g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
    if(mysql_errno(g_SQL) != 0) {
        print("[MySQL] Koneksi GAGAL!");
        SendRconCommand("exits");
        return 0;
    }

    printf("[MySQL] Koneksi BERHASIL ke database '%s' (Handle: %d)", MYSQL_DATABASE, _:g_SQL);
    mysql_set_charset("utf8mb4", g_SQL);
    
    DisableInteriorEnterExits();
    
    return 1;
}

public OnPlayerRequestSpawn(playerid) {
  if(StatusLogin[playerid] == false) {
    SendMessageError(playerid, "Login dulu, baru bisa spawn");
    return 1;
  }
  return 0;
}