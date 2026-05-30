public OnPlayerCommandText(playerid, cmdtext[]) {
  if(StatusLogin[playerid] == false) {
    SendMessageError(playerid, "Kamu harus login agar bisa menggunakan command!");
    return 0; // seharusnya cmd akan dibatalkan
  }
  return 1; // dan akan dilanjutkan oleh zcmd
}