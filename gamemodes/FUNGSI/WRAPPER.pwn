stock DelayedKick(playerid, const timer = 500) {
    PlayerKicking[playerid] = true;
    SetTimerEx("KickPemain", timer, false, "ii", playerid, PlayerSession[playerid]);
    return 1;
}
Fungsi: KickPemain(playerid, sessionid) {
	if(!IsPlayerConnected(playerid) || PlayerSession[playerid] != sessionid)
		return 0;

	Kick(playerid);
	return 1;
}

stock bool:IsPlayerAccountReady(playerid) {
    return playerid >= 0 && playerid < MAX_PLAYERS && IsPlayerConnected(playerid) && StatusLogin[playerid] && !PlayerKicking[playerid];
}

stock bool:ValidUnsignedInteger(const value[]) {
    new length = strlen(value);
    if(length < 1 || length > 10) return false;
    for(new i = 0; i < length; i++) {
        if(value[i] < '0' || value[i] > '9') return false;
    }
    if(length == 10 && strcmp(value, "2147483647") > 0) return false;
    return true;
}

stock bool:ValidWorldPosition(Float:x, Float:y, Float:z) {
    return x >= -20000.0 && x <= 20000.0 && y >= -20000.0 && y <= 20000.0 && z >= -1000.0 && z <= 20000.0;
}

stock bool:IsPlayerExterior(playerid) {
    return GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0;
}

stock bool:PindahkanPemain(playerid, Float:x, Float:y, Float:z) {
    if(!IsPlayerConnected(playerid) || !ValidWorldPosition(x, y, z)) return false;
    // Muat object tujuan sebelum player dipindahkan ke lantai mapping
    Streamer_UpdateEx(playerid, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
    return SetPlayerPos(playerid, x, y, z);
}

FormatUang(jumlah, output[]) {
    new angka[32];
    valstr(angka, jumlah);
	
    new len = strlen(angka);
    new pos = 0;
	
    for (new i = 0; i < len; i++) {
        output[pos++] = angka[i];

        if (angka[i] != '-' && i < len - 1 && (len - i - 1) % 3 == 0) {
            output[pos++] = '.';
        }
    }

    output[pos] = EOS;
    return 1;
}

stock ApplyAnimationEx(playerid, const library[], const anim[], Float:fDelta, bool:loop, bool:lockx, bool:locky, bool:freeze, time) {
    ApplyAnimation(playerid, library, "null", fDelta, loop, lockx, locky, freeze, time, SYNC_NONE);
    new ret = 0;
    ret = ApplyAnimation(playerid, library, anim, fDelta, loop, lockx, locky, freeze, time, SYNC_NONE);
    return ret;
}
