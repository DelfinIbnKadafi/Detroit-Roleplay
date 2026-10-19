Fungsi: AutoUnMute(playerid, sessionid)
{
  if(!IsPlayerConnected(playerid) || PlayerSession[playerid] != sessionid) return 1;

  Mute[playerid] = false;
  JumlahSpam[playerid] = 0;
  ChatWindowStart[playerid] = 0;
  TimerUnMute[playerid] = 0;

  SendMessageInfo(playerid, "Kamu sudah tidak dibisukan oleh server!");
  return 1;
}