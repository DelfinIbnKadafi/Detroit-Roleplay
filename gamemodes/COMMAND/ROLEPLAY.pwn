CMD:do(playerid, params[]) {
  new text[512];

  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /do <text>");
    return 1;
  }

  format(text, sizeof(text), "(%s) %s", params, Pemain[playerid][pNama]);

  new Float:px, Float:py, Float:pz;
  GetPlayerPos(playerid, px, py, pz);

  foreach(new i : Player) {
    if(!IsPlayerConnected(i) || i == playerid) continue;
      // hitung jarak
      new Float:k = GetPlayerDistanceFromPoint(i, px, py, pz);
      
      if(k <= 20.0) {
        SendClientMessage(i, 0x6B0E66FF, text);
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

  new Float:px, Float:py, Float:pz;
  GetPlayerPos(playerid, px, py, pz);

  foreach(new i : Player) {
    if(!IsPlayerConnected(i) || i == playerid) continue;
      // hitung jarak
      new Float:k = GetPlayerDistanceFromPoint(i, px, py, pz);
      if(k <= 20.0) {
        SendClientMessage(i, 0x6B0E66FF, text);
      }
  }

  SendClientMessage(playerid, 0x6B0E66FF, text);

  return 1;
}