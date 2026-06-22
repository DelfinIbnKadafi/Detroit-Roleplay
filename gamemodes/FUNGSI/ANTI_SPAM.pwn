Fungsi: AutoUnMute(playerid)
{
  if(!IsPlayerConnected(playerid)) return 1;

  Mute[playerid] = false;
  JumlahSpam[playerid] = 0;

  SendMessageInfo(playerid, "Kamu sudah tidak dibisukan oleh server!");
  return 1;
}