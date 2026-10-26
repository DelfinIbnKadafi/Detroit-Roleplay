stock bool:ValidBussinesIndex(index) {
    return index >= 0 && index < MAX_BUSSINES && Bussines[index][bactive] && Bussines[index][bid] > 0;
}

stock GetBussinesIndex(bussid) {
    if(bussid <= 0) return -1;
    for(new i = 0; i < MAX_BUSSINES; i++) {
        if(ValidBussinesIndex(i) && Bussines[i][bid] == bussid) return i;
    }
    return -1;
}

stock GetFreeBussinesSlot() {
    for(new i = 0; i < MAX_BUSSINES; i++) {
        if(!Bussines[i][bactive]) return i;
    }
    return -1;
}

stock bool:ValidBussinesName(const name[]) {
    new length = strlen(name), bool:hasLetter;
    if(length < 1 || length > MAX_BUSSINES_NAME) return false;
    for(new i = 0; i < length; i++) {
        if(name[i] < ' ' || name[i] == '{' || name[i] == '}' || name[i] == 127) return false;
        if(name[i] > ' ') hasLetter = true;
    }
    return hasLetter;
}

stock bool:ValidBussinesNumber(const value[]) {
    return ValidUnsignedInteger(value);
}

stock bool:ValidBussinesPosition(Float:x, Float:y, Float:z) {
    return ValidWorldPosition(x, y, z);
}

stock GetBussinesTypeName(type, output[], size) {
    if(type == 0) format(output, size, "Market");
    else format(output, size, "Type %d", type);
    return 1;
}

stock GetBussinesText(index, output[], size) {
    new types[32];
    GetBussinesTypeName(Bussines[index][btype], types, sizeof types);
    format(output, size, "[%d]\n%s\nOwner : %s\nType : %s\nStock : %d", Bussines[index][bid], Bussines[index][bnames], Bussines[index][bownername], types, Bussines[index][bsisa]);
    return 1;
}

stock DestroyBussinesObject(index) {
    if(IsValidDynamicPickup(Bussines[index][bpickup])) DestroyDynamicPickup(Bussines[index][bpickup]);
    if(IsValidDynamic3DTextLabel(Bussines[index][blabel])) DestroyDynamic3DTextLabel(Bussines[index][blabel]);
    Bussines[index][bpickup] = STREAMER_TAG_PICKUP:INVALID_STREAMER_ID;
    Bussines[index][blabel] = STREAMER_TAG_3D_TEXT_LABEL:INVALID_STREAMER_ID;
    return 1;
}

stock MakeBussinesObject(index) {
    new msg[384];
    DestroyBussinesObject(index);
    GetBussinesText(index, msg, sizeof msg);
    Bussines[index][bpickup] = CreateDynamicPickup(BUSSINES_PICKUP_MODEL, 1, Bussines[index][bx], Bussines[index][by], Bussines[index][bz], 0, 0, -1, 50.0);
    if(IsValidDynamicPickup(Bussines[index][bpickup])) {
        Bussines[index][blabel] = CreateDynamic3DTextLabel(msg, -1, Bussines[index][bx], Bussines[index][by], Bussines[index][bz] + 0.5, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    }
    if(!IsValidDynamicPickup(Bussines[index][bpickup]) || !IsValidDynamic3DTextLabel(Bussines[index][blabel])) {
        DestroyBussinesObject(index);
        return 0;
    }
    return 1;
}

stock UpdateBussinesObject(index) {
    if(!IsValidDynamicPickup(Bussines[index][bpickup]) || !IsValidDynamic3DTextLabel(Bussines[index][blabel])) return MakeBussinesObject(index);

    new msg[384];
    GetBussinesText(index, msg, sizeof msg);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, Bussines[index][bpickup], E_STREAMER_X, Bussines[index][bx]);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, Bussines[index][bpickup], E_STREAMER_Y, Bussines[index][by]);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, Bussines[index][bpickup], E_STREAMER_Z, Bussines[index][bz]);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, Bussines[index][blabel], E_STREAMER_X, Bussines[index][bx]);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, Bussines[index][blabel], E_STREAMER_Y, Bussines[index][by]);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, Bussines[index][blabel], E_STREAMER_Z, Bussines[index][bz] + 0.5);
    UpdateDynamic3DTextLabelText(Bussines[index][blabel], -1, msg);
    return 1;
}

stock ResetBussinesSlot(index) {
    static const empty[BussinesData];
    DestroyBussinesObject(index);
    Bussines[index] = empty;
    BussinesEditor[index] = INVALID_PLAYER_ID;
    return 1;
}

stock bool:CanManageBussines(playerid) {
    if(!IsPlayerAccountReady(playerid) || Admin[playerid] < 1) {
        SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
        return false;
    }
    if(!BussinesReady) {
        SendMessageError(playerid, "Data business belum selesai dimuat. Silakan coba lagi atau periksa database.");
        return false;
    }
    return true;
}

stock bool:IsBussinesExterior(playerid) {
    return IsPlayerExterior(playerid);
}

stock DestroyAllBussines() {
    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++) {
        ResetBussinesEdit(playerid);
        PlayerDeleteBussines[playerid] = 0;
    }
    for(new i = 0; i < MAX_BUSSINES; i++) ResetBussinesSlot(i);
    BussinesCount = 0;
    BussinesReady = false;
    return 1;
}
