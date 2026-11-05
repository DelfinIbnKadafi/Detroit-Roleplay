
// fungsi mengambil posisi poin beli business
Fungsi: GetBusinessBuyPosition(interiorid, Float:buyx, Float:buyy, Float:buyz) {
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



// fungsi mengecek apakah player berada dalam radius 1,5 dari titik poin pembelian business
stock IsPlayerInBuyPoint(playerid, busindex) {
    if(GetPlayerBusinessIndex(playerid) != busindex) return 0;

    new Float:buyx, Float:buyy, Float:buyz;

    if(!GetBusinessBuyPosition(Bussines[busindex][binterior], buyx, buyy, buyz)) return 0;

    return IsPlayerInRangeOfPoint(playerid, 1.5, buyx, buyy, buyz);
}

// fungsi yang menunjukan dialog membeli item di business
stock ShowBuyDialog(playerid) {

    // cek jika player berada di business lokasi business tertentu
    new status;
    status = GetPlayerBusinessIndex(playerid); // mengembalikan index bus jika player di business

    // player tidak berada di business mana pun
    if(status == -1) return 0;

    // cek apa player ada di dekat poin beli
    if(IsPlayerInBuyPoint(playerid, status) == 1) {
        switch(Bussines[status][binterior]) {
            case 17: {
                return Dialog_Show(playerid, BUY_MARKET, DIALOG_STYLE_LIST, "Market - Buy", "Belum ada apa apa bang", "Beli", "Batal");
            }
            case 9: {
                return Dialog_Show(playerid, BUY_FASTFOOD, DIALOG_STYLE_LIST, "Fast Food - Buy", "Burger $30.000\nPizza $40.000\nCola $15.000", "Beli", "Batal");
            }
        }
    }
    else {
        SendMessageError(playerid, "Kamu tidak berada di titik beli manapun");
    }


    return 1;
}