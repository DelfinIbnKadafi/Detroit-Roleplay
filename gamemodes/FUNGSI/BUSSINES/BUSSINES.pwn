

/// valid bus
stock bool:ValidBusinessIndex(index) {
    return index >= 0 && index < MAX_Business && Business[index][bactive] && Business[index][bid] > 0;
}


// posisi business
stock GetBusinessInteriorPosition(interiorid, &Float:jojox, &Float:jojoy, &Float:jojoz) {
    jojox = 0.0;
    jojoy = 0.0;
    jojoz = 0.0;
    if(interiorid == 17) { // market
        jojox = -25.7220;
        jojoy = -187.8216;
        jojoz = 1003.5469;
        return 1;
    }
    else if(interiorid == 9) { // fast food
        jojox = 364.75;
        jojoy = -11.50;
        jojoz = 1001.8516;
        return 1;
    }
    return 0;
}


// buat item (pickup) didalam interior bus
stock MakeBusinessInteriorItem() {

    new Float:px, Float:py, Float:pz;
    
    // market
    GetBusinessInteriorPosition(17, px, py, pz);
    CreateDynamicPickup(19132, 1, px, py, pz, -1, 17, -1, 50.0);
    GetBusinessBuyPosition(17, px, py, pz);
    CreateDynamicPickup(1274, 1, px, py, pz, -1, 17, -1, 50.0);
    CreateDynamic3DTextLabel("{ffff00}/buy {ffffff}atau gunakan {00ff40}ALT", 0xFFFFFFFF, px, py, pz + 0.5, 3.0);

    // fast food
    GetBusinessInteriorPosition(9, px, py, pz);
    CreateDynamicPickup(19132, 1, px, py, pz, -1, 9, -1, 50.0);
    GetBusinessBuyPosition(9, px, py, pz);
    CreateDynamicPickup(1274, 1, px, py, pz, -1, 9, -1, 50.0);
    CreateDynamic3DTextLabel("{ffff00}/buy {ffffff}atau gunakan {00ff40}ALT", 0xFFFFFFFF, px, py, pz + 0.5, 3.0);

    return 1;
}



///////////////////////////////////////////////////////////

// deteksi pintu business
Fungsi:DeteksiPintuBusiness(playerid) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || IsPlayerInAnyVehicle(playerid)) return 0;

    if(IsPlayerExterior(playerid)) {
        new index = GetNearbyBusinessIndex(playerid, 2.0);
        if(index == -1) return 0;

        // Business yang belum punya owner tidak bisa dimasuki, beri tahu cara membelinya
        if(Business[index][bownerid] == 0) {
            new msg[144], moneysss[32];
            FormatUang(Business[index][bprice], moneysss);
            format(msg, sizeof msg, "{00EBFF}[INFO]{FFFFFF} Business ini dijual seharga {55FF62}$%s{FFFFFF}. Gunakan /buybusiness untuk membelinya.", moneysss);
            SendClientMessage(playerid, 0xFFFFFFFF, msg);
            return 1;
        }
        return MasukKeBusiness(playerid, index);
    }

    new busindex = GetPlayerBusinessIndex(playerid);
    if(busindex == -1) return 0;

    new Float:jojox, Float:jojoy, Float:jojoz;
    if(!GetBusinessInteriorPosition(Business[busindex][binterior], jojox, jojoy, jojoz)) return 0;
    if(!IsPlayerInRangeOfPoint(playerid, 2.0, jojox, jojoy, jojoz)) return 0;

    return KeluarDariBusiness(playerid, busindex);
}

// mencari business yang sedang dimasuki player
stock GetPlayerBusinessIndex(playerid) {
    new interiorid = GetPlayerInterior(playerid), worldid = GetPlayerVirtualWorld(playerid);
    if(interiorid == 0 || worldid == 0) return -1;
    for(new i = 0; i < BusinessSlotLimit; i ++) {
        if(!ValidBusinessIndex(i)) continue;
        if(Business[i][bid] == worldid && Business[i][binterior] == interiorid) return i;
    }
    return -1;
}

// mencari business terdekat dari player (semua business, baik yang sudah dimiliki maupun belum)
stock GetNearbyBusinessIndex(playerid, Float:range = 2.0) {
    new nearest = -1, Float:nearestdistance = range, Float:distance;
    for(new i = 0; i < BusinessSlotLimit; i ++) {
        if(!ValidBusinessIndex(i)) continue;
        distance = GetPlayerDistanceFromPoint(playerid, Business[i][bx], Business[i][by], Business[i][bz]);
        if(distance <= nearestdistance) {
            nearest = i;
            nearestdistance = distance;
        }
    }
    return nearest;
}

// masuk ke business
stock MasukKeBusiness(playerid, busindex) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || IsPlayerInAnyVehicle(playerid) || !IsPlayerExterior(playerid) || !ValidBusinessIndex(busindex)) return 0;

    if(Business[busindex][bownerid] == 0) {
        SendMessageError(playerid, "Business ini belum memiliki owner.");
        return 0;
    }

    new Float:jojox, Float:jojoy, Float:jojoz;
    if(!GetBusinessInteriorPosition(Business[busindex][binterior], jojox, jojoy, jojoz)) {
        SendMessageError(playerid, "Interior business belum tersedia.");
        return 0;
    }

    SetPlayerInterior(playerid, Business[busindex][binterior]);
    SetPlayerVirtualWorld(playerid, Business[busindex][bid]);
    Streamer_UpdateEx(playerid, jojox, jojoy, jojoz, Business[busindex][bid], Business[busindex][binterior]);
    SetPlayerPos(playerid, jojox, jojoy, jojoz);
    playerinBusiness[playerid] = true;

    return 1;
}

// keluar dari business
stock KeluarDariBusiness(playerid, busindex) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || IsPlayerInAnyVehicle(playerid) || !ValidBusinessIndex(busindex)) return 0;
    if(GetPlayerInterior(playerid) != Business[busindex][binterior] || GetPlayerVirtualWorld(playerid) != Business[busindex][bid]) return 0;

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    Streamer_UpdateEx(playerid, Business[busindex][bx], Business[busindex][by], Business[busindex][bz], 0, 0);
    SetPlayerPos(playerid, Business[busindex][bx], Business[busindex][by], Business[busindex][bz]);
    playerinBusiness[playerid] = false;

    return 1;
}

///////////////////////////////////////////////////////////

// memeriksa apakah player berada di dekat business yang sudah dimiliki
stock DekatBusiness(playerid) {
    for(new i = 0; i < BusinessSlotLimit; i ++) {
        if(!ValidBusinessIndex(i) || Business[i][bownerid] == 0) continue;
        if(IsPlayerInRangeOfPoint(playerid, 2.0, Business[i][bx], Business[i][by], Business[i][bz])) return 1;
    }
    return 0;
}

// deteksi pintu keluar business
stock DekatPintuKeluarBusiness(playerid) {
    new busindex = GetPlayerBusinessIndex(playerid);
    if(busindex == -1) return 0;

    new Float:jojox, Float:jojoy, Float:jojoz;
    if(!GetBusinessInteriorPosition(Business[busindex][binterior], jojox, jojoy, jojoz)) return 0;
    return IsPlayerInRangeOfPoint(playerid, 2.0, jojox, jojoy, jojoz);
}

///////////////////////////////////////////////////////////

// mencari indeks business berdasarkan ID business
stock GetBusinessIndex(bussid) {
    if(bussid <= 0) return -1;
    for(new i = 0; i < BusinessSlotLimit; i++) {
        if(ValidBusinessIndex(i) && Business[i][bid] == bussid) return i;
    }
    return -1;
}

// mencari slot kosong untuk business baru
stock GetFreeBusinessSlot() {
    for(new i = 0; i < MAX_Business; i++) {
        if(!Business[i][bactive]) return i;
    }
    return -1;
}

// menentukan interior berdasarkan tipe business
stock GetBusinessTypeInterior(type) {

    switch(type) {
        case 0: return 17; // market
        case 1: return 9; // fast food
    }
    
    // jika busisness type tidak valid, berikan default
    return Business_DEFAULT_INTERIOR;
}

// memeriksa apakah nama business valid
stock bool:ValidBusinessName(const name[]) {
    new length = strlen(name), bool:hasLetter;
    if(length < 1 || length > MAX_Business_NAME) return false;
    for(new i = 0; i < length; i++) {
        if(name[i] < ' ' || name[i] == '{' || name[i] == '}' || name[i] == 127) return false;
        if(name[i] > ' ') hasLetter = true;
    }
    return hasLetter;
}

// memeriksa apakah nilai business berupa angka bulat nonnegatif yang valid
stock bool:ValidBusinessNumber(const value[]) {
    return ValidUnsignedInteger(value);
}

// memeriksa apakah koordinat business berada di posisi dunia yang valid
stock bool:ValidBusinessPosition(Float:x, Float:y, Float:z) {
    return ValidWorldPosition(x, y, z);
}

// mengambil nama tipe business ke dalam output
stock GetBusinessTypeName(type, output[], size) {
    if(type == 0) format(output, size, "Market");
    else if(type == 1) format(output, size, "Fast Food");
    else format(output, size, "Unknown (Type : %d)", type);
    return 1;
}

// menyusun teks informasi business untuk ditampilkan
stock GetBusinessText(index, output[], size) {
    new types[32];
    GetBusinessTypeName(Business[index][btype], types, sizeof types);
    if(Business[index][bownerid] != 0) {
        format(output, size, "[%d]\n%s\nOwner : %s\nType : %s\nStock : %d", Business[index][bid], Business[index][bnames], Business[index][bownername], types, Business[index][bsisa]);
        return 1;
    }
    new moneysss[128];
    FormatUang(Business[index][bprice], moneysss);
    format(output, size, "[%d]\n%s $%s\n/buybusiness\nOwner : %s\nType : %s\nStock : %d", Business[index][bid], Business[index][bnames], moneysss, Business[index][bownername], types, Business[index][bsisa]);

    return 1;
}

// menghapus pickup dan label business di area luar
stock DestroyBusinessObject(index) {
    if(IsValidDynamicPickup(Business[index][bpickup])) DestroyDynamicPickup(Business[index][bpickup]);
    if(IsValidDynamic3DTextLabel(Business[index][blabel])) DestroyDynamic3DTextLabel(Business[index][blabel]);
    Business[index][bpickup] = STREAMER_TAG_PICKUP:INVALID_STREAMER_ID;
    Business[index][blabel] = STREAMER_TAG_3D_TEXT_LABEL:INVALID_STREAMER_ID;
    return 1;
}

// membuat pickup dan label business
stock MakeBusinessObject(index) {
    new msg[384];
    DestroyBusinessObject(index);
    GetBusinessText(index, msg, sizeof msg);
    Business[index][bpickup] = CreateDynamicPickup(Business_PICKUP_MODEL, 1, Business[index][bx], Business[index][by], Business[index][bz], 0, 0, -1, 50.0);
    if(IsValidDynamicPickup(Business[index][bpickup])) {
        Business[index][blabel] = CreateDynamic3DTextLabel(msg, -1, Business[index][bx], Business[index][by], Business[index][bz] + 0.5, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    }
    if(!IsValidDynamicPickup(Business[index][bpickup]) || !IsValidDynamic3DTextLabel(Business[index][blabel])) {
        DestroyBusinessObject(index);
        return 0;
    }
    return 1;
}

// memperbarui posisi dan informasi object business
stock UpdateBusinessObject(index) {
    if(!IsValidDynamicPickup(Business[index][bpickup]) || !IsValidDynamic3DTextLabel(Business[index][blabel])) return MakeBusinessObject(index);

    new msg[384];
    GetBusinessText(index, msg, sizeof msg);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, Business[index][bpickup], E_STREAMER_X, Business[index][bx]);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, Business[index][bpickup], E_STREAMER_Y, Business[index][by]);
    Streamer_SetFloatData(STREAMER_TYPE_PICKUP, Business[index][bpickup], E_STREAMER_Z, Business[index][bz]);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, Business[index][blabel], E_STREAMER_X, Business[index][bx]);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, Business[index][blabel], E_STREAMER_Y, Business[index][by]);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, Business[index][blabel], E_STREAMER_Z, Business[index][bz] + 0.5);
    UpdateDynamic3DTextLabelText(Business[index][blabel], -1, msg);
    return 1;
}

// menghapus data dan mengosongkan slot business
stock ResetBusinessSlot(index) {
    static const empty[BusinessData];
    DestroyBusinessObject(index);
    Business[index] = empty;
    BusinessEditor[index] = INVALID_PLAYER_ID;
    while(BusinessSlotLimit > 0 && !Business[BusinessSlotLimit - 1][bactive]) BusinessSlotLimit--;
    return 1;
}

// menandai slot business sebagai aktif setelah semua data dan object siap
stock ActivateBusinessSlot(index) {
    Business[index][bactive] = true;
    BusinessCount++;
    if(index >= BusinessSlotLimit) BusinessSlotLimit = index + 1;
    return 1;
}

// memindahkan player keluar dari interior business secara paksa (business dihapus atau interior berubah)
stock KeluarkanPemainDariBusiness(index) {
    if(index < 0 || index >= MAX_Business || Business[index][bid] <= 0) return 0;
    new total;
    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++) {
        if(!IsPlayerConnected(playerid)) continue;
        if(GetPlayerVirtualWorld(playerid) != Business[index][bid] || GetPlayerInterior(playerid) != Business[index][binterior]) continue;
        if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Streamer_UpdateEx(playerid, Business[index][bx], Business[index][by], Business[index][bz], 0, 0);
        SetPlayerPos(playerid, Business[index][bx], Business[index][by], Business[index][bz]);
        playerinBusiness[playerid] = false;
        SendMessageInfo(playerid, "Kamu dipindahkan keluar karena business ini diubah atau dihapus.");
        total++;
    }
    return total;
}

// memeriksa apakah player dapat mengelola business
stock bool:CanManageBusiness(playerid) {
    if(!IsPlayerAccountReady(playerid) || Admin[playerid] < 1) {
        SendMessageError(playerid, "Kamu tidak memiliki akses untuk menggunakan command ini!");
        return false;
    }
    if(!BusinessReady) {
        SendMessageError(playerid, "Data business belum selesai dimuat. Silakan coba lagi atau periksa database.");
        return false;
    }
    return true;
}

// memeriksa apakah player berada di luar interior
stock bool:IsBusinessExterior(playerid) {
    return IsPlayerExterior(playerid);
}

// menghapus seluruh data dan object business
stock DestroyAllBusiness() {
    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++) {
        ResetBusinessEdit(playerid);
        PlayerDeleteBusiness[playerid] = 0;
    }
    for(new i = 0; i < MAX_Business; i++) ResetBusinessSlot(i);
    BusinessCount = 0;
    BusinessSlotLimit = 0;
    BusinessReady = false;
    return 1;
}

// menampilkan dialog untuk mengganti nama business
stock ShowChangeNamaBusiness(playerid, busindex) {
    SheylaCantikImutBanget[playerid] = busindex;
    new msg[256];
    format(msg, sizeof msg, "Nama Lama :\n%s\n\nMasukkan Nama Baru", Business[busindex][bnames]);
    Dialog_Show(playerid, DIALOG_GANTI_NAMA_BUSI, DIALOG_STYLE_INPUT, "Business - Ganti Nama", msg, "Kirim", "Batal");
    return 1;
}

// muat data business player
stock MuatBusinessPlayer(playerid) {
    printf("Start to load business player %s", Pemain[playerid][pNama]);

    for(new i = 0; i < 3; i++) IdBusinessPlayer[playerid][i] = -1;
    PlayerBusinessCount[playerid] = 0;

    for(new i = 0; i < BusinessSlotLimit && PlayerBusinessCount[playerid] < 3; i++) {
        if(Business[i][bownerid] != Pemain[playerid][pId]) continue;

        IdBusinessPlayer[playerid][PlayerBusinessCount[playerid]] = i;
        PlayerBusinessCount[playerid]++;
    }

    printf("Berhasil meload %d business dari player %s", PlayerBusinessCount[playerid], Pemain[playerid][pNama]);

    return 1;
}