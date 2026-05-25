// DETROIT ROLEPLAY - OPEN SOURCE GAMMODE

//========[CONTRIBUTOR]========//
/*
• Delfin Ibn Kadafi - Founder and Scripter
• Panntzyy - Scripter
• Martin - Scripter (Then)
*/

//===[INCLUDE]===//
#include <a_samp>
#include <sscanf2>
#include <streamer>
#include <a_mysql>

//===[MODULES]===//
#include "DATA/VARIABLE.pwn"
#include "DATA/DEFINE.pwn"
#include "DATA/ENUM.pwn"

#include "FUNGSI/PESAN.pwn"
#include "FUNGSI/KICK.pwn"
#include "FUNGSI/LOGIN.pwn"
#include "FUNGSI/DIALOG.pwn"

//===[OnGameModeInit]===//

public OnGameModeInit() {
    SetGameModeText(server_version);

    g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
    if(mysql_errno(g_SQL) != 0) {
        print("[MySQL] Koneksi GAGAL!");
        SendRconCommand("exit");
        return 0;
    }

    printf("[MySQL] Koneksi BERHASIL ke database '%s' (Handle: %d)", MYSQL_DATABASE, _:g_SQL);
    mysql_set_charset("utf8mb4", g_SQL);
    
    return 1;
}

public OnPlayerConnect(playerid) {
  // ambil nama
  GetPlayerName(playerid, Pemain[playerid][pNama], MAX_PLAYER_NAME);
  ///////////////////////////////////////////////////////////////////
  SendMessageServer(playerid, "Selamat datang di server Detroit Roleplay.");
  SendMessageServer(playerid, "Akun kamu sedang kami proses");
  
  // cek akun player
  new query[256];
  mysql_format(g_SQL, query, sizeof(query),
   "SELECT * FROM Pemain WHERE nama='%e'",
   Pemain[playerid][pNama]);
  mysql_tquery(g_SQL, query, "CekAkunPemain", "i", playerid);
  /////////////////////////////////////////////////////////////
  
  return 1;
}

public OnPlayerRequestSpawn(playerid) {
  return 0;
}

public OnPlayerDisconnect(playerid, reason) {
  return 1;
}