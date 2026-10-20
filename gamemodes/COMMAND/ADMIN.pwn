CMD:ahelp(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  
  Dialog_Show(playerid, DL_AHELP, DIALOG_STYLE_LIST, "Admin Command Help", "/aduty\n/sethp\n/setarmour\n/gotoplayer\n/getplayer\n/givemoney\n/getmoney\n/getplayermoney (Get player Info Money)\n/spawnaveh\n/destroyaveh\n/jetpack\n/giveveh", "keluar", " ");
  
  return 1;
}

CMD:giveveh(playerid, params[]) {
  if(Admin[playerid] < 2) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new target, model, color;
  if(sscanf(params, "iii", target, model, color)) {
    SendClientMessage(playerid, -1, "Gunakan: /giveveh <playerid> <modelid> <colorid>");
    return 1;
  }

  if(!IsPlayerConnected(target)) {
    SendMessageError(playerid, "Player yang dituju sedang tidak online!");
    return 1;
  }
  if(model < 400 || model > 611 || color < 0 || color > 255) {
    SendMessageError(playerid, "Model kendaraan atau warna tidak valid!");
    return 1;
  }
  if(BerikanKendaraan(target, model, color) == 0) {
    SendMessageError(playerid, "Player sudah memiliki batas maksimal kendaraan!");
    return 1;
  }
  else {
    SendMessageInfo(playerid, "Berhasil memberi kendaraan ke player");
    SendMessageInfo(target, "Admin telah memberikan kendaraan kepadamu.");
  }
  
  return 1;
}

CMD:jetpack(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  
  SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
  return 1;
}

CMD:aduty(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  if(AdminDuty[playerid] == true) {
    AdminDuty[playerid] = false;
    SendMessageInfo(playerid, "Kamu sudah off duty sebagai admin");
    SetPlayerColor(playerid, -1);
  }
  else {
    AdminDuty[playerid] = true;
    SendMessageInfo(playerid, "Kamu sudah on duty sebagai admin");
    SetPlayerColor(playerid, 0xFF0000FF);
  }
  return 1;
}

CMD:sethp(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new target, amount;
  if(sscanf(params, "ii", target, amount)) {
    SendClientMessage(playerid, -1, "Gunakan: /sethp <playerid> <amount>");
    return 1;
  }
  if(!IsPlayerConnected(target)) {
    SendMessageError(playerid, "Player yang dituju sedang tidak online!");
    return 1;
  }
  new Float:fhp = float(amount);
  SetPlayerHealth(target, fhp);
  
  SendMessageInfo(target, "Nyawa kamu sudah diubah oleh admin.");
  SendMessageInfo(playerid, "Berhasil mengubah nyawa player.");
  return 1;
}

CMD:setarmour(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new target, amount;
  if(sscanf(params, "ii", target, amount)) {
    SendClientMessage(playerid, -1, "Gunakan: /setarmour <playerid> <amount>");
    return 1;
  }
  if(!IsPlayerConnected(target)) {
    SendMessageError(playerid, "Player yang dituju sedang tidak online!");
    return 1;
  }
  new Float:farmour = float(amount);
  SetPlayerArmour(target, farmour);
  
  SendMessageInfo(target, "Armour kamu sudah diubah oleh admin.");
  SendMessageInfo(playerid, "Berhasil mengubah armour player.");
  return 1;
}

CMD:gotoplayer(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new target;
  if(sscanf(params, "i", target)) {
    SendClientMessage(playerid, -1, "Gunakan: /gotoplayer <playerid>");
    return 1;
  }
  if(!IsPlayerConnected(target)) {
    SendMessageError(playerid, "Player yang dituju sedang tidak online!");
    return 1;
  }
  new Float:x, Float:y, Float:z;
  GetPlayerPos(target, x, y, z);
  SetPlayerInterior(playerid, GetPlayerInterior(target));
  SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(target));
  SetPlayerPos(playerid, x + 2.00, y, z);
  return 1;
}

CMD:getplayer(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new target;
  if(sscanf(params, "i", target)) {
    SendClientMessage(playerid, -1, "Gunakan: /getplayer <playerid>");
    return 1;
  }
  if(!IsPlayerConnected(target)) {
    SendMessageError(playerid, "Player yang dituju sedang tidak online!");
    return 1;
  }
  new Float:x, Float:y, Float:z;
  GetPlayerPos(playerid, x, y, z);
  SetPlayerInterior(target, GetPlayerInterior(playerid));
  SetPlayerVirtualWorld(target, GetPlayerVirtualWorld(playerid));
  SetPlayerPos(target, x + 2.00, y, z);
  return 1;
}

CMD:givemoney(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new target, amount;
  if(sscanf(params, "ii", target, amount)) {
    SendClientMessage(playerid, -1, "Gunakan: /givemoney <playerid> <amount>");
    return 1;
  }
  if(!IsPlayerConnected(target)) {
    SendMessageError(playerid, "Player yang dituju sedang tidak online!");
    return 1;
  }
  if(amount < 1 || amount > 1000000 || amount > 2147483647 - GetPlayerMoney(target)) {
    SendMessageError(playerid, "Jumlah uang tidak valid atau melebihi batas saldo!");
    return 1;
  }
  
  GivePlayerMoney(target, amount);
  SendMessageInfo(target, "Kamu sudah diberi uang oleh admin!");
  SendMessageInfo(playerid, "Berhasil memberi uang ke player.");
  return 1;
}

CMD:getmoney(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new target, amount;
  if(sscanf(params, "ii", target, amount)) {
    SendClientMessage(playerid, -1, "Gunakan: /getmoney <playerid> <amount>");
    return 1;
  }
  if(!IsPlayerConnected(target)) {
    SendMessageError(playerid, "Player yang dituju sedang tidak online!");
    return 1;
  }
  if(amount <= 0 || amount > GetPlayerMoney(target)) {
    SendMessageError(playerid, "Jumlah uang harus positif dan tidak boleh melebihi saldo pemain!");
    return 1;
  }
  GivePlayerMoney(target, -amount);
  SendMessageInfo(target, "Uang kamu sudah diambil oleh admin!");
  SendMessageInfo(playerid, "Berhasil mengambil uang player.");
  return 1;
}

CMD:getplayermoney(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new target;
  if(sscanf(params, "i", target)) {
    SendClientMessage(playerid, -1, "Gunakan: /getplayermoney <playerid>");
    return 1;
  }
  if(!IsPlayerConnected(target)) {
    SendMessageError(playerid, "Player yang dituju sedang tidak online!");
    return 1;
  }
  new money = GetPlayerMoney(target);
  new str[256];
  format(str, sizeof(str), "Jumlah uang player tersebut adalah %d Rupiah", money);
  
  SendClientMessage(playerid, -1, str);
  return 1;
}

CMD:spawnaveh(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new vehhhid, color;
  if(sscanf(params, "ii", vehhhid, color)) {
    SendClientMessage(playerid, -1, "Gunakan: /spawnaveh <vehid> <color>");
    return 1;
  }
  new Float:x, Float:y, Float:z, Float:a;
  GetPlayerPos(playerid, x, y, z);
  GetPlayerFacingAngle(playerid, a);

  if(vehhhid < 400 || vehhhid > 611 || color < 0 || color > 255) {
    SendMessageError(playerid, "Model kendaraan atau warna tidak valid!");
    return 1;
  }
  if(jumaveh >= sizeof(aveh)) {
    SendMessageError(playerid, "Batas kendaraan admin telah tercapai!");
    return 1;
  }

  new vehicleid = CreateVehicle(vehhhid, x + 3.00, y, z, a, color, color, -1, false);
  if(vehicleid == INVALID_VEHICLE_ID) {
    SendMessageError(playerid, "Kendaraan gagal di-spawn. Batas kendaraan server mungkin tercapai.");
    return 1;
  }
  aveh[jumaveh] = vehicleid;
  avehOwner[jumaveh] = playerid;
  jumaveh++;
  VehOwner[vehicleid] = -1;
  VehSlot[vehicleid] = -1;
  MesinVeh[vehicleid] = false;
  SetVehicleParamsEx(vehicleid, true, false, false, false, false, false, false);
  SendMessageInfo(playerid, "Berhasil spawn veh");
  return 1;
}

CMD:destroyaveh(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  DestroyAdminVehicles(playerid);
  SendMessageInfo(playerid, "Semua kendaraan admin milikmu telah dihancurkan.");
  return 1;
}