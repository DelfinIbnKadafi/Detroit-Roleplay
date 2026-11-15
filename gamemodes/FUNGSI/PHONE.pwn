Fungsi: ClosePlayerCall(playerid) {
  if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;

  new targetid = PlayerCall[playerid][userTujuan];
  if(targetid >= 0 && targetid < MAX_PLAYERS && IsPlayerConnected(targetid) && PlayerCall[targetid][userTujuan] == playerid) {
    PlayerCall[targetid][inCall] = false;
    PlayerCall[targetid][answered] = false;
    PlayerCall[targetid][userTujuan] = -1;
    strcopy(PlayerCall[targetid][nomorTujuan], "");
  }

  PlayerCall[playerid][inCall] = false;
  PlayerCall[playerid][answered] = false;
  PlayerCall[playerid][userTujuan] = -1;
  strcopy(PlayerCall[playerid][nomorTujuan], "");
  return 1;
}

Fungsi: MatikanMemanggilTelepon(playerid) {
  if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 1;
  if(PlayerCall[playerid][answered] || !PlayerCall[playerid][inCall]) return 1;

  new targetid = PlayerCall[playerid][userTujuan];

  if(targetid >= 0 && targetid < MAX_PLAYERS && IsPlayerConnected(targetid) && PlayerCall[targetid][userTujuan] == playerid) {
    new msg[128];
    format(msg, sizeof msg, "Panggilan tidak terjawab oleh %s", PlayerCall[targetid][nomorTujuan]);
    SendMessageInfo(targetid, msg);
  }

  SendMessageInfo(playerid, "Panggilan tidak diangkat selama 30 detik, menghentikan panggilan secara otomatis");
  ClosePlayerCall(playerid);
  return 1;
}

stock ChatInCall(playerid, const text[]) {

  if(!IsPlayerConnected(playerid) || !PlayerCall[playerid][inCall] || !PlayerCall[playerid][answered]) return 1;

  new pembicaraLain = PlayerCall[playerid][userTujuan];

  if(pembicaraLain < 0 || pembicaraLain >= MAX_PLAYERS || !IsPlayerConnected(pembicaraLain)) return 1;
  if(!PlayerCall[pembicaraLain][inCall] || !PlayerCall[pembicaraLain][answered]) return 1;

  new msg[256];
  format(msg, sizeof msg, "{ffffff}[{00ffff}%s{ffffff}] {ffff00}%s", Pemain[playerid][pNohp], text);
  SendClientMessage(playerid, -1, msg);
  SendClientMessage(pembicaraLain, -1, msg);



  new Float:px, Float:py, Float:pz;
  GetPlayerPos(playerid, px, py, pz);

  format(msg, sizeof msg, "{00ffff}[In Call] {ffffff}%s", text);

  foreach(new i : Player) {
    new Float:ds = GetPlayerDistanceFromPoint(i, px, py, pz);
    if(ds <= 10.0 && i != playerid && i != pembicaraLain) {
      SendClientMessage(i, -1, msg);
    }
  }

  return 1;
}