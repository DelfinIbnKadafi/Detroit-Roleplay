stock DelayedKick(playerid, const timer = 500) {
    SetTimerEx("KickPemain", timer, false, "i", playerid);
    return 1;
}
Fungsi: KickPemain(playerid) {
	if(!IsPlayerConnected(playerid)) 
		return 0;

	Kick(playerid);
	return 1;
}