public OnPlayerCommandReceived(playerid, cmdtext[]) {
  if(!IsPlayerAccountReady(playerid)) {
    SendMessageError(playerid, "Kamu harus login agar bisa menggunakan command!");
    return 0;
  }
  return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success) {
  if(!success) {
    SendMessageError(playerid, "Command tidak dikenal.");
  }
  return 1;
}
