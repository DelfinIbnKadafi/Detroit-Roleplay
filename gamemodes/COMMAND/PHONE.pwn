// phone commands //////////////////////////////

CMD:togphone(playerid, params[]) {

  if(Pemain[playerid][pPhone] == 0) return SendMessageError(playerid, "Kamu tidak memiliki ponsel");

  if(Pemain[playerid][pPhoneStatus] == 0) {
    Pemain[playerid][pPhoneStatus] = 1;
    return SendMessageInfo(playerid, "Berhasil menghidupkan ponsel");
  }
  
  Pemain[playerid][pPhoneStatus] = 0;
  ClosePlayerCall(playerid);
  return SendMessageInfo(playerid, "Berhasil mengnonaktifkan ponsel");
}

CMD:call(playerid, params[]) {

  if(Pemain[playerid][pPhone] == 0) return SendMessageError(playerid, "Kamu tidak memiliki ponsel");
  if(Pemain[playerid][pPhoneStatus] == 0) return SendMessageError(playerid, "Ponsel kamu sedang tidak menyala, gunakan /togphone untuk menyalakanya");
  if(PlayerCall[playerid][inCall]) return SendMessageError(playerid, "kamu sedang berada di dalam panggilan lain");
  if(Pemain[playerid][pKuota] == 0) return SendMessageInfo(playerid, "Kamu tidak memiliki kuota intenet");

  new notargetint;
  if(sscanf(params, "d", notargetint)) return SendClientMessage(playerid, -1, "Gunakan: /call <nomor>");

  new notargetstr[17];
  format(notargetstr, sizeof notargetstr, "%d", notargetint);

  if(!strcmp(notargetstr, Pemain[playerid][pNohp])) return SendMessageError(playerid, "Tidak bisa menelpon diri sendiri");

  foreach(new i : Player) {
    if(strcmp(notargetstr, Pemain[i][pNohp])) continue;

    if(Pemain[i][pPhoneStatus] == 0) return SendMessageError(playerid, "Ponsel nomor tujuan sedang tidak aktif");

    if(Pemain[i][pKuota] == 0) return SendMessageError(playerid, "Tidak dapat menghubungkan ke telepon, pastikan ponsel target memiliki kuota");

    if(PlayerCall[i][inCall]) return SendMessageInfo(playerid, "Nomor tersebut sedang berada dalam panggilan lain");

    PlayerCall[playerid][inCall] = true;
    PlayerCall[i][inCall] = true;

    PlayerCall[playerid][answered] = false;
    PlayerCall[i][answered] = false;

    strcopy(PlayerCall[playerid][nomorTujuan], notargetstr);
    strcopy(PlayerCall[i][nomorTujuan], Pemain[playerid][pNohp]);

    PlayerCall[playerid][userTujuan] = i;
    PlayerCall[i][userTujuan] = playerid;

    new msg[256];
    format(msg, sizeof msg, "{ffff00}[CALL]{ffffff} Menelpon nomor %d...", notargetint);
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof msg, "{ffff00}[CALL]{ffffff} Telepon masuk dari %d, gunakan /answer untuk menjawab telepon atau /reject untuk menolak", notargetint);
    SendClientMessage(i, -1, msg);

    SetTimerEx("MatikanMemanggilTelepon", 30000, false, "i", playerid);

    Pemain[playerid][pKuota] -= 0.1;
    Pemain[i][pKuota] -= 0.1;

    return 1;
  }

  SendMessageInfo(playerid, "Tidak dapat menemukan nomor tersebut");
  return 1;
}

CMD:phone(playerid, params[]) {

  if(Pemain[playerid][pPhone] == 0) return SendMessageError(playerid, "Kamu tidak memiliki ponsel");
  if(Pemain[playerid][pPhoneStatus] == 0) return SendMessageError(playerid, "Ponsel kamu sedang tidak menyala, gunakan /togphone untuk menyalakanya");

  // coming soon

  return 1;
}

CMD:answer(playerid, params[]) {
  if(Pemain[playerid][pPhoneStatus] == 0) return SendMessageError(playerid, "Ponsel kamu sedang tidak aktif");
  if(!PlayerCall[playerid][inCall]) return SendMessageError(playerid, "Kamu tidak menerima telepon apapun");
  if(PlayerCall[playerid][answered]) return SendMessageError(playerid, "Kamu sudah menjawab telepon");

  new targetid = PlayerCall[playerid][userTujuan];

  if(targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid)) {
    ClosePlayerCall(playerid);
    return SendMessageError(playerid, "Panggilan sudah tidak tersedia");
  }

  PlayerCall[playerid][inCall] = true;
  PlayerCall[playerid][userTujuan] = targetid;
  strcopy(PlayerCall[playerid][nomorTujuan], Pemain[targetid][pNohp]);
  PlayerCall[playerid][answered] = true;

  PlayerCall[targetid][inCall] = true;
  PlayerCall[targetid][userTujuan] = playerid;
  strcopy(PlayerCall[targetid][nomorTujuan], Pemain[playerid][pNohp]);
  PlayerCall[targetid][answered] = true;
  
  SendClientMessage(playerid, -1, "{ffff00}[CALL]{ffffff} Berhasil menjawab telepon, silahkan mulai bicara");
  SendClientMessage(targetid, -1, "{ffff00}[CALL]{ffffff} Panggilan telah dijawab");

  return 1;
}