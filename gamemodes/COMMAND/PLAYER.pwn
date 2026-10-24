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
    GivePlayerMoney(playerid, -jumlah);
    GivePlayerMoney(targetid, jumlah);
    
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
  FormatUang(money, bankstring);
  
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