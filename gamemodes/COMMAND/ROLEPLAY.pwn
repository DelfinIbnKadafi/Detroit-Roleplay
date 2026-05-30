// rp cmd
CMD:south(playerid, params[]) {
  new text[512];
  
  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /south <text>");
    return 1;
  }
  
  format(text, sizeof(text), "[TERIAK] %s %s", Pemain[playerid][pNama], params);
  
  new Float:px, Float:py, Float:pz, Float:k;
  GetPlayerPos(playerid, px, py, pz);

  foreach(new i : Player) {
    if(!IsPlayerConnected(i) || i == playerid) continue;
    // hitung jarak
    k = GetPlayerDistanceFromPoint(i, px, py, pz);
    if(k <= 10.0) {
      SendClientMessage(i, 0xFFFFFFFF, text);
    }
  }

  SendClientMessage(playerid, 0xFFFFFFFF, text);
  
  return 1;
}

CMD:low(playerid, params[]) {
  new text[512];
  
  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /low <text>");
    return 1;
  }
  
  format(text, sizeof(text), "[KECIL] %s %s", Pemain[playerid][pNama], params);
  
  new Float:px, Float:py, Float:pz, Float:k;
  GetPlayerPos(playerid, px, py, pz);

  foreach(new i : Player) {
    if(!IsPlayerConnected(i) || i == playerid) continue;
    // hitung jarak
    k = GetPlayerDistanceFromPoint(i, px, py, pz);
    if(k <= 10.0) {
      SendClientMessage(i, 0xFFFFFFFF, text);
    }
  }

  SendClientMessage(playerid, 0xFFFFFFFF, text);
  
  return 1;
}

CMD:do(playerid, params[]) {
  new text[512];

  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /do <text>");
    return 1;
  }

  format(text, sizeof(text), "(%s) %s", params, Pemain[playerid][pNama]);

  new Float:px, Float:py, Float:pz, Float:k;
  GetPlayerPos(playerid, px, py, pz);

  foreach(new i : Player) {
    if(!IsPlayerConnected(i) || i == playerid) continue;
    // hitung jarak
    k = GetPlayerDistanceFromPoint(i, px, py, pz);
    if(k <= 10.0) {
      SendClientMessage(i, 0xFFFFFFFF, text);
    }
  }

  SendClientMessage(playerid, 0x6B0E66FF, text);

  return 1;
}

CMD:me(playerid, params[]) {
  new text[512];

  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /me <text>");
    return 1;
  }

  format(text, sizeof(text), "%s %s", Pemain[playerid][pNama], params);

  new Float:px, Float:py, Float:pz, Float:k;
  GetPlayerPos(playerid, px, py, pz);

  foreach(new i : Player) {
    if(!IsPlayerConnected(i) || i == playerid) continue;
    // hitung jarak
    k = GetPlayerDistanceFromPoint(i, px, py, pz);
    if(k <= 10.0) {
      SendClientMessage(i, 0xFFFFFFFF, text);
    }
  }

  SendClientMessage(playerid, 0x6B0E66FF, text);

  return 1;
}

