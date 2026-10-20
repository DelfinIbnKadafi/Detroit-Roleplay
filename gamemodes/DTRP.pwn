// main includes
#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <easyDialog>
#include <a_mysql>
#include <strlib>
#include <samp_bcrypt>
#include <zcmd>
#include <foreach>

// local includes
#include "DATA/header"
#include "ASET/header"
#include "FUNGSI/header"
#include "JOB/header"
#include "COMMAND/DIALOG/header"
#include "COMMAND/header"

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
    
    LoadMapping();
    LoadTextdraw();

    // pikirkan secara logika
    // bagaimana caranya membuat sebuah sistem, jadi bakal ambil semua data dalam tabel tertentu di sebuah tabel
    // lalu mengambil data kedalam fungsi LoadAtm()
    mysql_tquery(g_SQL, "SELECT * FROM `atm`", "LoadAtm", "");

    DisableInteriorEnterExits();
    
    ShowNameTags(true);
    
    return 1;
}

// connect/disconnect
public OnPlayerConnect(playerid) 
{
  PlayerSession[playerid]++;
  if(PlayerSession[playerid] <= 0) PlayerSession[playerid] = 1;
  ResetAtmEdit(playerid);
  ResetDataPemain(playerid);
  for(new i = 0; i < 3; i++) {
    TextDrawShowForPlayer(playerid, LOGO_SERVER[i]);
  }
  
  StatusLogin[playerid] = false;
  
  SetPlayerColor(playerid, 0xFFFFFFFF);
  LoadPlayerTextdraw(playerid);
  GetPlayerName(playerid, Pemain[playerid][pNama], MAX_PLAYER_NAME + 1);
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
  mysql_pquery(g_SQL, query, "CekAkunPemain", "iis", playerid, PlayerSession[playerid], Pemain[playerid][pNama]);
  return 1;
}

public OnGameModeExit()
{
  foreach(new playerid : Player) {
    if(!StatusLogin[playerid]) continue;
    SimpanDataPemain(playerid);
    SaveDataKendaraan(playerid);
  }
  return 1;
}

public OnPlayerDisconnect(playerid, reason) 
{
  new bool:wasLoggedIn = StatusLogin[playerid];
  StatusLogin[playerid] = false;
  PlayerSession[playerid]++;
  TdPintuShown[playerid] = false;

  KillTimer(TimerLapar[playerid]);
  KillTimer(TimerHaus[playerid]);
  KillTimer(TimerHBE[playerid]);
  KillTimer(TimerSpedo[playerid]);
  KillTimer(TimerUnMute[playerid]);
  KillTimer(TimerAutoSave[playerid]);
  DestroyAdminVehicles(playerid);

  if(wasLoggedIn) {
    SimpanDataPemain(playerid);
    SaveDataKendaraan(playerid);
    HancurkanKendaraanPlayer(playerid);
  }
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