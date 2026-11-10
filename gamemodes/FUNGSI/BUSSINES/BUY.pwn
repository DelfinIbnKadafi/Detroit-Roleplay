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



// fungsi mengecek apakah player berada dalam radius 1 dari titik poin pembelian business
stock IsPlayerInBuyPoint(playerid, busindex) {
    if(!ValidBusinessIndex(busindex) || GetPlayerBusinessIndex(playerid) != busindex) return 0;

    new Float:buyx, Float:buyy, Float:buyz;

    if(!GetBusinessBuyPosition(Business[busindex][binterior], buyx, buyy, buyz)) return 0;

    return IsPlayerInRangeOfPoint(playerid, 1.0, buyx, buyy, buyz);
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

    switch(Business[status][binterior]) {
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