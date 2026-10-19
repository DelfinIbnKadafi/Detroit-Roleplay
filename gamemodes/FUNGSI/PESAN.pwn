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
	new msg[128];
	format(msg, sizeof(msg), "{00EBFF}[SERVER]{FFFFFF} Halo %s, selamat datang di %s", Pemain[playerid][pNama], SERVER_NAME);
	SendClientMessage(playerid, 0xFFFFFF, msg);
	return 1;
}

stock bool:CanSendChat(playerid)
{
  if(!StatusLogin[playerid]) {
    SendMessageError(playerid, "Kamu harus login agar bisa mengirim pesan!");
    return false;
  }
  if(Mute[playerid]) {
    SendMessageError(playerid, "Kamu sedang dibisukan!");
    return false;
  }

  new now = GetTickCount();
  if(now - ChatWindowStart[playerid] > 5000) {
    JumlahSpam[playerid] = 0;
    ChatWindowStart[playerid] = now;
  }

  if(++JumlahSpam[playerid] >= 3) {
    Mute[playerid] = true;
    SendMessageWarning(playerid, "Kamu dibisukan karena spam!");
    TimerUnMute[playerid] = SetTimerEx("AutoUnMute", 10000, false, "ii", playerid, PlayerSession[playerid]);
    return false;
  }
  return true;
}

stock SendProximityMessage(playerid, Float:radius, color, const message[])
{
  new Float:px, Float:py, Float:pz;
  GetPlayerPos(playerid, px, py, pz);

  foreach(new i : Player) {
    if(!StatusLogin[i]) continue;
    if(GetPlayerInterior(i) != GetPlayerInterior(playerid)) continue;
    if(GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid)) continue;
    if(GetPlayerDistanceFromPoint(i, px, py, pz) <= radius) {
      SendClientMessage(i, color, message);
    }
  }
  return 1;
}

stock GetRoleplayName(playerid, name[], size)
{
  format(name, size, "%s", Pemain[playerid][pNama]);
  for(new i = 0; name[i] != '\0'; i++) {
    if(name[i] == '_') name[i] = ' ';
  }
  return 1;
}

public OnPlayerText(playerid, text[])
{
  if(isnull(text) || strlen(text) < 1) {
    return 0;
  }
  if(strlen(text) > 100) {
    SendMessageError(playerid, "Pesan terlalu panjang (maksimal 100 karakter).");
    return 0;
  }
  if(!CanSendChat(playerid)) return 0;

  new Float:px, Float:py, Float:pz;
  GetPlayerPos(playerid, px, py, pz);

  new msg[144];
  format(msg, sizeof(msg), "%s says: %s", Pemain[playerid][pNama], text);

  new Float:radius = 20.0;

  foreach(new i : Player)
  {
    if(!StatusLogin[i]) continue;
    if(GetPlayerInterior(i) != GetPlayerInterior(playerid)) continue;
    if(GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid)) continue;

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

  return 0;
}