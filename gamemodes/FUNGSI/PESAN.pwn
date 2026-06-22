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

public OnPlayerText(playerid, text[])
{
  if(!StatusLogin[playerid]) {
    SendMessageError(playerid, "Kamu harus login agar bisa mengirim pesan!");
    return 0;
  }

  if(Mute[playerid]) {
    SendMessageError(playerid, "Kamu sedang dibisukan!");
    return 0;
  }

  if(isnull(text) || strlen(text) < 1) {
    return 0;
  }

  new Float:px, Float:py, Float:pz;
  GetPlayerPos(playerid, px, py, pz);

  new msg[144];
  format(msg, sizeof(msg), "%s says: %s", Pemain[playerid][pNama], text);

  new Float:radius = 20.0;

  foreach(new i : Player)
  {
    if(!IsPlayerConnected(i)) continue;

    new Float:dist = GetPlayerDistanceFromPoint(i, px, py, pz);
    new color;

    if(dist <= radius / 4.0) {
      color = 0xFFFFFFFF;
    }
    else if(dist <= radius / 2.0) {
      color = 0xDDDDDDFF;
    }
    else if(dist <= radius) {
      color = 0xAAAAAAFF;
    }
    else continue;

    SendClientMessage(i, color, msg);
  }

  // reset spam kalau player diam
  new now = GetTickCount();

  if(now - LastChatTime[playerid] > 5000) {
    JumlahSpam[playerid] = 0;
  }

  LastChatTime[playerid] = now;

  if(!Mute[playerid]) {
    JumlahSpam[playerid]++;

    if(JumlahSpam[playerid] >= 3)
    {
      Mute[playerid] = true;
      SendMessageWarning(playerid, "Kamu dibisukan karena spam!");

      SetTimerEx("AutoUnMute", 10000, false, "i", playerid);
    }
  }

  return 0;
}