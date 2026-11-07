
// fungsi mengambil posisi poin beli business
stock GetBusinessBuyPosition(interiorid, &Float:buyx, &Float:buyy, &Float:buyz) {
    buyx = 0.0;
    buyy = 0.0;
    buyz = 0.0;
    if(interiorid == 17) {
        buyx = -29.06;
        buyy = -184.81;
        buyz = 1003.54;
        return 1;
    }
    else if(interiorid == 9) {
        buyx = 369.45;
        buyy = -6.38;
        buyz = 1001.85;
        return 1;
    }
    return 0;
}



// mengosongkan data object dan pickup business milik player (tidak menghapus apa pun di server)
// dipakai saat player connect/disconnect, karena server sudah menghapus object dan pickup milik player yang disconnect
stock ResetPlayerBussinesObjectData(playerid) {
    PlayerBussinesExitPickup[playerid] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
    PlayerBussinesBuyPickup[playerid] = STREAMER_TAG_PICKUP:INVALID_STREAMER_ID;
    PlayerBussinesObjectBid[playerid] = 0;
    PlayerBussinesObjectInt[playerid] = 0;
    return 1;
}

// menghapus object panah pintu keluar dan pickup titik beli milik player
stock DestroyPlayerBussinesObjects(playerid) {
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if(IsValidDynamicObject(PlayerBussinesExitPickup[playerid])) DestroyDynamicObject(PlayerBussinesExitPickup[playerid]);
    if(IsValidDynamicPickup(PlayerBussinesBuyPickup[playerid])) DestroyDynamicPickup(PlayerBussinesBuyPickup[playerid]);
    ResetPlayerBussinesObjectData(playerid);
    return 1;
}

// membuat object panah pintu keluar dan pickup titik beli untuk player di interior business
// dipanggil tepat setelah player dipindahkan ke interior
stock MakePlayerBussinesObjects(playerid, busindex) {
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    // hapus sisa object lama (jika ada) agar tidak menumpuk
    DestroyPlayerBussinesObjects(playerid);
    if(!IsPlayerConnected(playerid) || !ValidBussinesIndex(busindex)) return 0;

    new Float:exitx, Float:exity, Float:exitz, Float:buyx, Float:buyy, Float:buyz;
    if(!GetBusinessInteriorPosition(Bussines[busindex][binterior], exitx, exity, exitz)) return 0;

    PlayerBussinesObjectBid[playerid] = Bussines[busindex][bid];
    PlayerBussinesObjectInt[playerid] = Bussines[busindex][binterior];

    // panah pintu keluar, hanya terlihat oleh player ini
    PlayerBussinesExitPickup[playerid] = CreateDynamicPickup(BUSSINES_PICKUP_MODEL, 1, exitx, exity, exitz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 50.0);
    new bool:success = IsValidDynamicPickup(PlayerBussinesExitPickup[playerid]) != 0;

    // pickup di titik pembelian, hanya terlihat oleh player ini
    if(GetBusinessBuyPosition(Bussines[busindex][binterior], buyx, buyy, buyz)) {
        PlayerBussinesBuyPickup[playerid] = CreateDynamicPickup(BUSSINES_BUY_PICKUP_MODEL, 1, buyx, buyy, buyz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 50.0);
        if(!IsValidDynamicPickup(PlayerBussinesBuyPickup[playerid])) success = false;
    }

    Streamer_Update(playerid);

    return success;
}

// memastikan player yang berada di interior business punya object dan pickup business
// dipakai saat spawn (mis. login di dalam business atau respawn setelah mati di dalam business)
// dan menghapus object jika player ternyata tidak lagi berada di business
stock SyncPlayerBussinesObjects(playerid) {
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;

    new busindex = GetPlayerBusinessIndex(playerid);
    if(busindex == -1) return DestroyPlayerBussinesObjects(playerid);

    new bool:hasObject = IsValidDynamicObject(PlayerBussinesExitPickup[playerid]) != 0;
    new bool:hasPickup = IsValidDynamicPickup(PlayerBussinesBuyPickup[playerid]) != 0;
    
    if(hasObject && hasPickup && PlayerBussinesObjectBid[playerid] == Bussines[busindex][bid] && PlayerBussinesObjectInt[playerid] == Bussines[busindex][binterior]) return 1;

    return MakePlayerBussinesObjects(playerid, busindex);
}

// menghapus object dan pickup business jika player sudah berpindah dari interior business tanpa lewat pintu keluar
// (mis. dipindahkan admin atau respawn di hospital), dipanggil dari OnPlayerUpdate sehingga harus ringan
stock CekObjectBusinessPlayer(playerid) {
    if(PlayerBussinesObjectBid[playerid] == 0) return 0;
    if(GetPlayerVirtualWorld(playerid) == PlayerBussinesObjectBid[playerid] && GetPlayerInterior(playerid) == PlayerBussinesObjectInt[playerid]) return 0;
    DestroyPlayerBussinesObjects(playerid);
    return 1;
}



// fungsi mengecek apakah player berada dalam radius 1,5 dari titik poin pembelian business
stock IsPlayerInBuyPoint(playerid, busindex) {
    if(!ValidBussinesIndex(busindex) || GetPlayerBusinessIndex(playerid) != busindex) return 0;

    new Float:buyx, Float:buyy, Float:buyz;

    if(!GetBusinessBuyPosition(Bussines[busindex][binterior], buyx, buyy, buyz)) return 0;

    return IsPlayerInRangeOfPoint(playerid, 1.5, buyx, buyy, buyz);
}

// fungsi yang menunjukan dialog membeli item di business
stock ShowBuyDialog(playerid) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid]) return 0;

    // cek jika player berada di business lokasi business tertentu
    new status;
    status = GetPlayerBusinessIndex(playerid); // mengembalikan index bus jika player di business

    // player tidak berada di business mana pun
    if(status == -1) return SendMessageError(playerid, "Kamu tidak berada di dalam business manapun");

    // cek apa player ada di dekat poin beli
    if(!IsPlayerInBuyPoint(playerid, status)) return SendMessageError(playerid, "Kamu tidak berada di titik beli manapun");

    switch(Bussines[status][binterior]) {
        case 17: {
            return Dialog_Show(playerid, BUY_MARKET, DIALOG_STYLE_LIST, "Market - Buy", "Belum ada apa apa bang", "Beli", "Batal");
        }
        case 9: {
            return Dialog_Show(playerid, BUY_FASTFOOD, DIALOG_STYLE_LIST, "Fast Food - Buy", "Burger $30.000\nPizza $40.000\nCola $15.000", "Beli", "Batal");
        }
    }

    // interior business ini belum punya menu pembelian
    return SendMessageError(playerid, "Business ini belum memiliki menu pembelian");
}