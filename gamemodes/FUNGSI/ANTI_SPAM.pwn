Fungsi: AutoUnMute(playerid) {
  JumlahSpam[playerid] = 0;
  SendMessageInfo(playerid, "Kamu sudah tidak dibisukan oleh server!");
  Mute[playerid] = false;
  return 1;
}

stock AntiSpam(playerid) {
  if(Mute[playerid] == true) return 1;
  if(JumlahSpam[playerid] < 3) {
    JumlahSpam[playerid]++;
    return 1;
  }
  if(JumlahSpam[playerid] == 3) {
    Mute[playerid] = true;
    SetTimerEx("AutoUnMute", 10000, false, "i", playerid);
  }
  return 1;
}