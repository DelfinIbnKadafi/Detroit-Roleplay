CMD:ahelp(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  
  Dialog_Show(playerid, DL_AHELP, DIALOG_STYLE_LIST, "Admin Command Help", "/aduty\n/sethp\n/setarmour\n/gotoplayer\n/getplayer\n/givemoney\n/getmoney\n/getplayermoney (Get player Info Money)\n/spawnaveh\n/destroyaveh", "keluar", " ");
  
  return 1;
}

CMD:aduty(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  if(AdminDuty[playerid] == true) {
    AdminDuty[playerid] = false;
    SendMessageInfo(playerid, "Kamu sudah of duty sebagai admin");
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
  SetPlayerHealth(playerid, fhp);
  
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
  SetPlayerArmour(playerid, farmour);
  
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
  if(amount < 1) {
    SendMessageError(playerid, "Tidak boleh kurang dari 0!");
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
  GivePlayerMoney(target, -amount);
  SendMessageInfo(target, "Uang kamu sudah diambil oleh admin! oleh admin!");
  SendMessageInfo(playerid, "Berhasil mengambil uang  player.");
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

new aveh[1000];
new jumaveh;

CMD:spawnaveh(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  new id, color;
  if(sscanf(params, "ii", id, color)) {
    SendClientMessage(playerid, -1, "Gunakan: /spawnaveh <vehid> <color>");
    return 1;
  }
  new Float:x, Float:y, Float:z, Float:a;
  GetPlayerPos(playerid, x, y, z);
  GetPlayerFacingAngle(playerid, a);
  
  jumaveh++;
  aveh[jumaveh] = CreateVehicle(id, x + 3.00, y, z, a, color, color, -1, false);
  SendMessageInfo(playerid, "Berhasil spawn veh");
  return 1;
}

CMD:destroyaveh(playerid, params[]) {
  if(Admin[playerid] < 1) {
    SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
    return 1;
  }
  for(new i = 0; i < jumaveh; i++) {
    DestroyVehicle(aveh[i]);
  }
  return 1;
}