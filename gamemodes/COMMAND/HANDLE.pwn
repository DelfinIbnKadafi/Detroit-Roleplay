public OnPlayerCommandReceived(playerid, cmdtext[]) {
  if(StatusLogin[playerid] == false) {
    SendMessageError(playerid, "Kamu harus login agar bisa menggunakan command!");
    return 0;
  }
  return 1;
}