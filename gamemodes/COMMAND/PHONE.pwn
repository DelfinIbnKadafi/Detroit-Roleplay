// phone commands ///////////////////////////////
CMD:togphone(playerid, params[]) {

  if(Pemain[playerid][pPhone] == 0) return SendMessageError(playerid, "Kamu tidak memiliki ponsel");

  if(Pemain[playerid][pPhoneStatus] == 0) {
    Pemain[playerid][pPhoneStatus] = 1;
    return SendMessageInfo(playerid, "Berhasil menghidupkan ponsel");
  }
  
  Pemain[playerid][pPhoneStatus] = 0;
  return SendMessageInfo(playerid, "Berhasil mengnonaktifkan ponsel");
}

Fungsi: MatikanMemanggilTelepon(playerid) {
  if(PlayerCall[playerid][answered]) return 1;

  new i = PlayerCall[playerid][userTujuan];

  if(i < 0 || i >= MAX_PLAYERS || !IsPlayerConnected(i)) return 1;

  if(IsPlayerConnected(i) && strcmp(Pemain[i][pNohp], PlayerCall[playerid][nomorTujuan]) == 0) {
    PlayerCall[i][inCall] = false;
    PlayerCall[i][answered] = false;
    PlayerCall[i][userTujuan] = -1;

    new msg[128];
    format(msg, sizeof msg, "Panggilan tidak terjawab oleh %s", PlayerCall[i][nomorTujuan]);
    strcopy(PlayerCall[i][nomorTujuan], "");
    SendMessageInfo(i, msg);
  }

  if(IsPlayerConnected(playerid) && strcmp(Pemain[playerid][pNohp], PlayerCall[i][nomorTujuan]) == 0) {
    PlayerCall[playerid][inCall] = false;
    PlayerCall[playerid][answered] = false;
    PlayerCall[playerid][userTujuan] = -1;
    strcopy(PlayerCall[playerid][nomorTujuan], "");
    SendMessageInfo(playerid, "Panggilan tidak diangkat selama 30 detik, menghentikan panggilan secara otomatis");
  }

  return 1;
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
    format(msg, sizeof msg, "Menelpon nomor %d...", notargetint);
    SendClientMessage(playerid, 0xffff00ff, msg);
    format(msg, sizeof msg, "Telepon masuk dari %d, gunakan /answer untuk menjawab telepon", notargetint);
    SendClientMessage(i, 0xffff00ff, msg);

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
  // coming soon
  return 1;
}