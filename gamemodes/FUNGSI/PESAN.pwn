//===[PESAN SERVER]===//
#define SendMessageError(%1,%2)  SendClientMessage(%1, 0xFFFFFF, "{FF0000}[ERROR]{FFFFFF} "%2)
#define SendMessageWarning(%1,%2)  SendClientMessage(%1, 0xFFFFFF, "{FF0000}[WARNING]{FFFFFF} "%2)
#define SendMessageInfo(%1,%2)   SendClientMessage(%1, 0xFFFFFF, "{00EBFF}[INFO]{FFFFFF} "%2)
#define SendMessageServer(%1,%2) SendClientMessage(%1, 0xFFFFFF, "{00EBFF}[SERVER]{FFFFFF} "%2)


stock ClearPlayerChat(playerid, lines = 75) {
	for(new i ; i < lines; i ++) {
		SendClientMessage(playerid, -1, " ");
	}
}

stock ShowGreetings(playerid)
{
	ClearPlayerChat(playerid);
	SendMessageServer(playerid, "Halo %s, selamat datang di %s", Pemain[playerid][pNama], SERVER_NAME);
	return 1;
}

public OnPlayerText(playerid, text[]) {
  // player bisa chat sbnyk 3 kali, lalu akan dimute

  if(StatusLogin[playerid] == false) {
    SendMessageError(playerid, "Kamu harus login agar bisa mengirim pesan!");
    return 1;
  }
  
  if(Mute[playerid] == true) {
    SendMessageError(playerid, "Kamu sedang dibisukan!");
    return 1;
  }
  
  new msg[256];
  format(msg, sizeof(msg), "%s says: %s", Pemain[playerid][pNama], text);
  
  new Float:px, Float:py, Float:pz;
  GetPlayerPos(playerid, px, py, pz);

  // radius chat
  new Float:radius = 20.0;

  foreach(new i : Player) {
  
    new Float:d = GetPlayerDistanceFromPoint(i, px, py, pz);

    if (d <= radius / 4)
      SendClientMessage(i, 0xFFFFFFFF, msg);
    else if (d <= radius / 2)
      SendClientMessage(i, 0xDDDDDDFF, msg);
    else if (d <= radius)
      SendClientMessage(i, 0xAAAAAAFF, msg);
  }
  
  SendClientMessage(playerid, 0xFFFFFFFF, msg);
  AntiSpam(playerid); // antispam diletakkan di paling bawah agar player benar benar bisa kirim pesan 3x
  
  return 0;
}