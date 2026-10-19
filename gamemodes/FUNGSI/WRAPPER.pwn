stock DelayedKick(playerid, const timer = 500) {
    SetTimerEx("KickPemain", timer, false, "ii", playerid, PlayerSession[playerid]);
    return 1;
}
Fungsi: KickPemain(playerid, sessionid) {
	if(!IsPlayerConnected(playerid) || PlayerSession[playerid] != sessionid)
		return 0;

	Kick(playerid);
	return 1;
}