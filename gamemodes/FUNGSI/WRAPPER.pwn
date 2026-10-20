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

FormatUang(jumlah, output[]) {
    new angka[32];
    valstr(angka, jumlah);
	
    new len = strlen(angka);
    new pos = 0;
	
    for (new i = 0; i < len; i++) {
        output[pos++] = angka[i];

        if (i < len - 1 && (len - i - 1) % 3 == 0) {
            output[pos++] = '.';
        }
    }

    output[pos] = EOS;
    return 1;
}