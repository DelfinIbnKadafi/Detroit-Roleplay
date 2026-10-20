// rp cmd
CMD:s(playerid, params[]) {
  new message[144];

  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /s <text>");
    return 1;
  }
  if(strlen(params) > 100) {
    SendMessageError(playerid, "Pesan terlalu panjang (maksimal 100 karakter).");
    return 1;
  }
  if(!CanSendChat(playerid)) return 1;

  new name[MAX_PLAYER_NAME + 1];
  GetRoleplayName(playerid, name, sizeof(name));
  format(message, sizeof(message), "[TERIAK] %s %s", name, params);
  SendProximityMessage(playerid, 30.0, 0xFFFFFFFF, message);
  
  return 1;
}

CMD:l(playerid, params[]) {
  new message[144];
  
  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /l <text>");
    return 1;
  }
  if(strlen(params) > 100) {
    SendMessageError(playerid, "Pesan terlalu panjang (maksimal 100 karakter).");
    return 1;
  }
  if(!CanSendChat(playerid)) return 1;
  new name[MAX_PLAYER_NAME + 1];
  GetRoleplayName(playerid, name, sizeof(name));
  format(message, sizeof(message), "[KECIL] %s %s", name, params);
  SendProximityMessage(playerid, 10.0, 0xFFFFFFFF, message);
  
  return 1;
}

CMD:do(playerid, params[]) {
  new message[144];

  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /do <text>");
    return 1;
  }
  if(strlen(params) > 100) {
    SendMessageError(playerid, "Pesan terlalu panjang (maksimal 100 karakter).");
    return 1;
  }
  if(!CanSendChat(playerid)) return 1;

  new name[MAX_PLAYER_NAME + 1];
  GetRoleplayName(playerid, name, sizeof(name));
  format(message, sizeof(message), "(%s) %s", params, name);
  SendProximityMessage(playerid, 20.0, 0xb600c4FF, message);

  return 1;
}

CMD:me(playerid, params[]) {
  new message[144];

  if (isnull(params)) {
    SendClientMessage(playerid, -1, "Gunakan: /me <text>");
    return 1;
  }
  if(strlen(params) > 100) {
    SendMessageError(playerid, "Pesan terlalu panjang (maksimal 100 karakter).");
    return 1;
  }
  if(!CanSendChat(playerid)) return 1;

  new name[MAX_PLAYER_NAME + 1];
  GetRoleplayName(playerid, name, sizeof(name));
  format(message, sizeof(message), "%s %s", name, params);
  SendProximityMessage(playerid, 20.0, 0xb600c4FF, message);

  return 1;
}
