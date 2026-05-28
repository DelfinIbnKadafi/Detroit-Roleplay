// connect/disconnect

public OnPlayerConnect(playerid) {
  SetPlayerColor(playerid, 0xFFFFFFFF);
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

public OnPlayerDisconnect(playerid, reason) {
  new blah[256];
  format(blah, sizeof(blah), "{59ff28}[SERVER]{fff000} %s {ffffff}meninggalkan server.", Pemain[playerid][pNama]);
  SendClientMessageToAll(0xffffff, blah);
  
  // save data
  SimpanDataPemain(playerid);
  return 1;
}