// pay/berikan uang
CMD:pay(playerid, params[]) {
  new jumlah, targetid, msg[256];
  
  if(sscanf(params, "ud", targetid, jumlah)) {
    SendClientMessage(playerid, -1, "Gunakan: /pay <target> <jumlah>");
    return 1;
  }
  if(targetid == playerid) {
    SendMessageError(playerid, "kamu tidak bisa memberi uang kedirimu sendiri!");
    return 1;
  }
  if(GetPlayerMoney(playerid) < jumlah) {
    SendMessageError(playerid, "Uangmu tidak cukup!");
    return 1;
  }
  if(jumlah < 1000 || jumlah > 1000000) {
    SendMessageError(playerid, "Jumlah uang yang diberikan minimal 1000 rupiah dan maksimal 1.000.000 rupiah");
    return 1;
  }
  if(!IsPlayerConnected(targetid)) {
    SendMessageError(playerid, "Pemain yang dituju tidak online!");
    return 1;
  }
  if(!IsPlayerAccountReady(targetid)) return SendMessageError(playerid, "Pemain yang dituju belum login!");
  if(GetPlayerMoney(targetid) > 2147483647 - jumlah) return SendMessageError(playerid, "Uang pemain yang dituju melebihi batas saldo!");
  
  new Float:x, Float:y, Float:z;
  GetPlayerPos(playerid, x, y, z);
  new nama_target[MAX_PLAYER_NAME + 1];
  GetPlayerName(targetid, nama_target, sizeof(nama_target));
  
  new Float:jarak = GetPlayerDistanceFromPoint(targetid, x, y, z);
  if(jarak <= 3.0) {
    if(GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid)) {
      SendMessageError(playerid, "Pemain yang dituju tidak berada di dunia yang sama.");
      return 1;
    }
    if(!SimpanTransferPemain(playerid, targetid, jumlah)) return SendMessageError(playerid, "Transaksi gagal disimpan. Silakan coba lagi.");
    GivePlayerMoney(playerid, -jumlah);
    GivePlayerMoney(targetid, jumlah);
    Pemain[playerid][pUang] = GetPlayerMoney(playerid);
    Pemain[targetid][pUang] = GetPlayerMoney(targetid);
    
    ApplyAnimation(playerid, "DEALER", "shop_pay", 4.1, false, false, false, false, 4670);
    ApplyAnimation(targetid, "DEALER", "DEALER_DEAL", 4.1, false, false, false, false, 3170);
    
    format(msg, sizeof(msg), "%s memberikan uang sebanyak %d rupiah kepada %s", Pemain[playerid][pNama], jumlah, nama_target);
    SendProximityMessage(playerid, 10.0, 0x6B0E66FF, msg);
  }
  else {
    SendMessageError(playerid, "Pemain yang dituju tidak berada didekatmu!");
    return 1;
  }
  return 1;
}

CMD:stats(playerid, params[])
{
  new stats[512], job[64], money;

  GetJobName(Pemain[playerid][pJob], job);
  money = GetPlayerMoney(playerid);
  
  new hpstr[32], hpno[32];
  if(Pemain[playerid][pPhone] == 0) {
    format(hpstr, sizeof(hpstr), "Tidak Ada");
    format(hpno, sizeof(hpno), "-");
  }
  else {
    format(hpno, sizeof(hpno), "%s", Pemain[playerid][pNohp]);
    if(Pemain[playerid][pPhoneStatus] == 0) {
      format(hpstr, sizeof(hpstr), "Tidak Aktif");
    }
    else {
      format(hpstr, sizeof(hpstr), "Aktif");
    }
  }

  new moneystring[128], bankstring[128];
  FormatUang(money, moneystring);
  FormatUang(Pemain[playerid][pBank], bankstring);
  
  format(stats, sizeof(stats),
    "Nama : %s | Gender : %s | Uang : %s | Saldo Bank : %s | Norek : %d | Tanggal Lahir : %s | Pekerjaan : %s\nPonsel : %s | No Telepon : %s",
    Pemain[playerid][pNama],
    GetGender[Pemain[playerid][pGender]],
    moneystring,
    bankstring,
    Pemain[playerid][pNorek],
    Pemain[playerid][pDateBirth],
    job,
    hpstr,
    hpno
  );

  Dialog_Show(playerid, DL_STATS, DIALOG_STYLE_MSGBOX, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Stats", stats, "Keluar", "");

  return 1;
}

CMD:help(playerid, params[]) {
  ShowHelpDialog(playerid);
  return 1;
}

CMD:enter(playerid, params[]) {
  if(IsPlayerInAnyVehicle(playerid)) return 1;
  
  if(DeteksiPintuBalaiKota(playerid)) return 1;
  if(DeteksiPintuHospital(playerid)) return 1;

  if(DeteksiPintuBusiness(playerid)) return 1;
  return 1;
}

CMD:balkot(playerid, params[]) {
  ShowBalkotMenu(playerid);
  return 1;
}

CMD:atm(playerid, params[]) {
  if(!IsPlayerSpawned(playerid)) return 1;
  PlayerUseAtm(playerid);
  return 1;
}

CMD:death(playerid, params[]) {
  if(PlayerDeath[playerid]) {
    RespawnPlayerHospital(playerid);
  }
  else {
    SendMessageError(playerid, "Kamu sedang tidak sekarat/down.");
  }
  return 1;
}

// phone commands
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

  PlayerCall[playerid][inCall] = false;
  PlayerCall[i][inCall] = false;

  PlayerCall[playerid][answered] = false;
  PlayerCall[i][answered] = false;

  new msg[128];
  format(msg, sizeof msg, "Panggilan tidak terjawab oleh %s", PlayerCall[playerid][nomorTujuan]);

  strcopy(PlayerCall[playerid][nomorTujuan], "");
  strcopy(PlayerCall[i][nomorTujuan], "");

  PlayerCall[playerid][userTujuan] = -1;
  PlayerCall[i][userTujuan] = -1;

  SendMessageInfo(playerid, "Panggilan tidak diangkat selama 30 detik, menghentikan panggilan secara otomatis");
  SendMessageInfo(i, msg);

  return 1;
}

CMD:call(playerid, params[]) {

  if(Pemain[playerid][pPhone] == 0) return SendMessageError(playerid, "Kamu tidak memiliki ponsel");
  if(PlayerCall[playerid][inCall]) return SendMessageError(playerid, "kamu sedang berada di dalam panggilan lain");
  if(Pemain[playerid][pKuota] == 0) return SendMessageInfo(playerid, "Kamu tidak memiliki kuota intenet");

  new notargetint;
  if(sscanf(params, "d", notargetint)) return SendClientMessage(playerid, -1, "Gunakan: /call <nomor>");

  new notargetstr[17];
  format(notargetstr, sizeof notargetstr, "%d", notargetint);

  if(!strcmp(notargetstr, Pemain[playerid][pNohp])) return SendMessageError(playerid, "Tidak bisa menelpon diri sendiri");

  foreach(new i : Player) {
    if(strcmp(notargetstr, Pemain[i][pNohp])) continue;

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

    return 1;
  }

  return 1;
}

CMD:phone(playerid, params[]) {

  if(Pemain[playerid][pPhone] == 0) return SendMessageError(playerid, "Kamu tidak memiliki ponsel");
  if(Pemain[playerid][pPhoneStatus] == 0) return SendMessageError(playerid, "Ponsel kamu sedang tidak menyala, gunakan /togphone untuk menyalakanya");

  return 1;
}