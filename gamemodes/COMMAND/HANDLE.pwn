public OnPlayerCommandText(playerid, cmdtext[]) {
  if(StatusLogin[playerid] == false) {
    SendMessageError(playerid, "Kamu harus login agar bisa menggunakan command!");
    return 1; // cmd dibatalkan, tidak diteruskan ke zcmd
  }
  return 0; // belum ditangani disini, lanjutkan ke zcmd untuk diproses
}