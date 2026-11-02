/// valid bus
stock bool:ValidBussinesIndex(index) {
    return index >= 0 && index < MAX_BUSSINES && Bussines[index][bactive] && Bussines[index][bid] > 0;
}


// posisi business
stock GetBusinessInteriorPosition(interiorid, &Float:jojox, &Float:jojoy, &Float:jojoz) {
    jojox = 0.0;
    jojoy = 0.0;
    jojoz = 0.0;
    if(interiorid == 17) {
        jojox = -25.7220;
        jojoy = -187.8216;
        jojoz = 1003.5469;
        return 1;
    }
    else if(interiorid == 9) {
        jojox = 364.75;
        jojoy = -11.50;
        jojoz = 1001.8516;
        return 1;
    }
    return 0;
}

///////////////////////////////////////////////////////////

// deteksi pintu business
Fungsi:DeteksiPintuBusiness(playerid) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || IsPlayerInAnyVehicle(playerid)) return 0;

    if(IsPlayerExterior(playerid)) {
        new index = GetNearbyBussinesIndex(playerid, 2.0);
        if(index == -1) return 0;

        // Business yang belum punya owner tidak bisa dimasuki, beri tahu cara membelinya
        if(Bussines[index][bownerid] == 0) {
            new msg[144], moneysss[32];
            FormatUang(Bussines[index][bprice], moneysss);
            format(msg, sizeof msg, "{00EBFF}[INFO]{FFFFFF} Business ini dijual seharga {55FF62}$%s{FFFFFF}. Gunakan /buybusiness untuk membelinya.", moneysss);
            SendClientMessage(playerid, 0xFFFFFFFF, msg);
            return 1;
        }
        return MasukKeBusiness(playerid, index);
    }

    new busindex = GetPlayerBusinessIndex(playerid);
    if(busindex == -1) return 0;

    new Float:jojox, Float:jojoy, Float:jojoz;
    if(!GetBusinessInteriorPosition(Bussines[busindex][binterior], jojox, jojoy, jojoz)) return 0;
    if(!IsPlayerInRangeOfPoint(playerid, 2.0, jojox, jojoy, jojoz)) return 0;

    return KeluarDariBusiness(playerid, busindex);
}

// mencari business yang sedang dimasuki player
stock GetPlayerBusinessIndex(playerid) {
    new interiorid = GetPlayerInterior(playerid), worldid = GetPlayerVirtualWorld(playerid);
    if(interiorid == 0 || worldid == 0) return -1;
    for(new i = 0; i < BussinesSlotLimit; i ++) {
        if(!ValidBussinesIndex(i)) continue;
        if(Bussines[i][bid] == worldid && Bussines[i][binterior] == interiorid) return i;
    }
    return -1;
}

// mencari business terdekat dari player (semua business, baik yang sudah dimiliki maupun belum)
stock GetNearbyBussinesIndex(playerid, Float:range = 2.0) {
    new nearest = -1, Float:nearestdistance = range, Float:distance;
    for(new i = 0; i < BussinesSlotLimit; i ++) {
        if(!ValidBussinesIndex(i)) continue;
        distance = GetPlayerDistanceFromPoint(playerid, Bussines[i][bx], Bussines[i][by], Bussines[i][bz]);
        if(distance <= nearestdistance) {
            nearest = i;
            nearestdistance = distance;
        }
    }
    return nearest;
}

// masuk ke business
stock MasukKeBusiness(playerid, busindex) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || IsPlayerInAnyVehicle(playerid) || !IsPlayerExterior(playerid) || !ValidBussinesIndex(busindex)) return 0;

    if(Bussines[busindex][bownerid] == 0) {
        SendMessageError(playerid, "Business ini belum memiliki owner.");
        return 0;
    }

    new Float:jojox, Float:jojoy, Float:jojoz;
    if(!GetBusinessInteriorPosition(Bussines[busindex][binterior], jojox, jojoy, jojoz)) {
        SendMessageError(playerid, "Interior business belum tersedia.");
        return 0;
    }

    SetPlayerInterior(playerid, Bussines[busindex][binterior]);
    SetPlayerVirtualWorld(playerid, Bussines[busindex][bid]);
    Streamer_UpdateEx(playerid, jojox, jojoy, jojoz, Bussines[busindex][bid], Bussines[busindex][binterior]);
    SetPlayerPos(playerid, jojox, jojoy, jojoz);
    playerinbussines[playerid] = true;

    return 1;
}

// keluar dari business
stock KeluarDariBusiness(playerid, busindex) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || IsPlayerInAnyVehicle(playerid) || !ValidBussinesIndex(busindex)) return 0;
    if(GetPlayerInterior(playerid) != Bussines[busindex][binterior] || GetPlayerVirtualWorld(playerid) != Bussines[busindex][bid]) return 0;

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    Streamer_UpdateEx(playerid, Bussines[busindex][bx], Bussines[busindex][by], Bussines[busindex][bz], 0, 0);
    SetPlayerPos(playerid, Bussines[busindex][bx], Bussines[busindex][by], Bussines[busindex][bz]);
    playerinbussines[playerid] = false;

    return 1;
}

///////////////////////////////////////////////////////////

stock DekatBusiness(playerid) {
    for(new i = 0; i < BussinesSlotLimit; i ++) {
        if(!ValidBussinesIndex(i) || Bussines[i][bownerid] == 0) continue;
        if(IsPlayerInRangeOfPoint(playerid, 2.0, Bussines[i][bx], Bussines[i][by], Bussines[i][bz])) return 1;
    }
    return 0;
}

// deteksi pintu keluar business
stock DekatPintuKeluarBusiness(playerid) {
    new busindex = GetPlayerBusinessIndex(playerid);
    if(busindex == -1) return 0;

    new Float:jojox, Float:jojoy, Float:jojoz;
    if(!GetBusinessInteriorPosition(Bussines[busindex][binterior], jojox, jojoy, jojoz)) return 0;
    return IsPlayerInRangeOfPoint(playerid, 2.0, jojox, jojoy, jojoz);
}

///////////////////////////////////////////////////////////

stock GetBussinesIndex(bussid) {
    if(bussid <= 0) return -1;
    for(new i = 0; i < BussinesSlotLimit; i++) {
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

stock GetBussinesTypeInterior(type) {

    switch(type) {
        case 0: return 17; // market
        case 1: return 9; // fast food
    }
    
    // jika busisness type tidak valid, berikan default
    return BUSSINES_DEFAULT_INTERIOR;
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
    if(type == 1) format(output, size, "Fast Food");
    else format(output, size, "Type %d", type);
    return 1;
}

stock GetBussinesText(index, output[], size) {
    new types[32];
    GetBussinesTypeName(Bussines[index][btype], types, sizeof types);
    if(Bussines[index][bownerid] != 0) {
        format(output, size, "[%d]\n%s\nOwner : %s\nType : %s\nStock : %d", Bussines[index][bid], Bussines[index][bnames], Bussines[index][bownername], types, Bussines[index][bsisa]);
        return 1;
    }
    new moneysss[128];
    FormatUang(Bussines[index][bprice], moneysss);
    format(output, size, "[%d]\n%s $%s\nOwner : %s\nType : %s\nStock : %d", Bussines[index][bid], Bussines[index][bnames], moneysss, Bussines[index][bownername], types, Bussines[index][bsisa]);

    return 1;
}

stock MakeBussinesExitObject(index) {
    if(IsValidDynamicObject(Bussines[index][bexitobject])) DestroyDynamicObject(Bussines[index][bexitobject]);
    Bussines[index][bexitobject] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
    if(Bussines[index][bid] <= 0) return 1;

    new Float:jojox, Float:jojoy, Float:jojoz;
    if(!GetBusinessInteriorPosition(Bussines[index][binterior], jojox, jojoy, jojoz)) return 0;

    Bussines[index][bexitobject] = CreateDynamicObject(BUSSINES_PICKUP_MODEL, jojox, jojoy, jojoz, 0.0, 0.0, 0.0, Bussines[index][bid], Bussines[index][binterior], INVALID_PLAYER_ID, 100.0);
    return IsValidDynamicObject(Bussines[index][bexitobject]);
}

stock DestroyBussinesObject(index) {
    if(IsValidDynamicPickup(Bussines[index][bpickup])) DestroyDynamicPickup(Bussines[index][bpickup]);
    if(IsValidDynamic3DTextLabel(Bussines[index][blabel])) DestroyDynamic3DTextLabel(Bussines[index][blabel]);
    if(IsValidDynamicObject(Bussines[index][bexitobject])) DestroyDynamicObject(Bussines[index][bexitobject]);
    Bussines[index][bpickup] = STREAMER_TAG_PICKUP:INVALID_STREAMER_ID;
    Bussines[index][blabel] = STREAMER_TAG_3D_TEXT_LABEL:INVALID_STREAMER_ID;
    Bussines[index][bexitobject] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
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
    if(!IsValidDynamicPickup(Bussines[index][bpickup]) || !IsValidDynamic3DTextLabel(Bussines[index][blabel]) || !MakeBussinesExitObject(index)) {
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
    // Dibuat ulang agar world dan interior pintu keluar selalu mengikuti data business terbaru
    if(!MakeBussinesExitObject(index)) return 0;
    return 1;
}

stock ResetBussinesSlot(index) {
    static const empty[BussinesData];
    DestroyBussinesObject(index);
    Bussines[index] = empty;
    BussinesEditor[index] = INVALID_PLAYER_ID;
    while(BussinesSlotLimit > 0 && !Bussines[BussinesSlotLimit - 1][bactive]) BussinesSlotLimit--;
    return 1;
}

// menandai slot business sebagai aktif setelah semua data dan object siap
stock ActivateBussinesSlot(index) {
    Bussines[index][bactive] = true;
    BussinesCount++;
    if(index >= BussinesSlotLimit) BussinesSlotLimit = index + 1;
    return 1;
}

// memindahkan player keluar dari interior business secara paksa (business dihapus atau interior berubah)
stock KeluarkanPemainDariBusiness(index) {
    if(index < 0 || index >= MAX_BUSSINES || Bussines[index][bid] <= 0) return 0;
    new total;
    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++) {
        if(!IsPlayerConnected(playerid)) continue;
        if(GetPlayerVirtualWorld(playerid) != Bussines[index][bid] || GetPlayerInterior(playerid) != Bussines[index][binterior]) continue;
        if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Streamer_UpdateEx(playerid, Bussines[index][bx], Bussines[index][by], Bussines[index][bz], 0, 0);
        SetPlayerPos(playerid, Bussines[index][bx], Bussines[index][by], Bussines[index][bz]);
        playerinbussines[playerid] = false;
        SendMessageInfo(playerid, "Kamu dipindahkan keluar karena business ini diubah atau dihapus.");
        total++;
    }
    return total;
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
    BussinesSlotLimit = 0;
    BussinesReady = false;
    return 1;
}