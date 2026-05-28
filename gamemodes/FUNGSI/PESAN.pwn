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