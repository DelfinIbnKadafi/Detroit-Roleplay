Dialog:DL_DELETEBUSSINES(playerid, response, listitem, const inputtext[]) {
    new bussid = PlayerDeleteBussines[playerid];
    PlayerDeleteBussines[playerid] = 0;
    if(!response || !CanManageBussines(playerid)) return 1;
    new index = GetBussinesIndex(bussid);
    if(index == -1) return SendMessageError(playerid, "Business tersebut sudah tidak tersedia.");
    if(!DeleteBussines(index)) return SendMessageError(playerid, "Business gagal dihapus. Periksa database atau pastikan pintu tidak sedang diedit.");
    SendMessageInfo(playerid, "Berhasil menghapus business dari server dan database.");
    return 1;
}


Dialog:DIALOG_GANTI_NAMA_BUSI(playerid, response, listitem, const inputtext[]) {
    if(response == 0) {
        new msg[256];
        format(msg, sizeof msg, "Nama Lama :\n%s\n\nMasukkan Nama Baru", Bussines[SheylaCantikImutBanget[playerid]][bnames]);
        return Dialog_Show(playerid, DIALOG_GANTI_NAMA_BUSI, DIALOG_STYLE_INPUT, "Business - Ganti Nama", msg, "Kirim", "Batal");
    }

    strcopy(Bussines[SheylaCantikImutBanget[playerid]][bnames], inputtext, MAX_BUSSINES_NAME + 1);

    UpdateBussinesObject(SheylaCantikImutBanget[playerid]);

    SaveDataBussines(SheylaCantikImutBanget[playerid], Bussines[SheylaCantikImutBanget[playerid]]);

    return 1;
}


Dialog:DL_BUSSINES_LIST(playerid, response, listitem, const inputtext[]) {
    if(!CanManageBussines(playerid)) return 1;
    if(response) { // left button or butnf
        if(PlayerBussinesListPage[playerid] == 1) return HidePlayerDialog(playerid);
        if(PlayerBussinesListPage[playerid] > 1) return ShowBussinesList(playerid, PlayerBussinesListPage[playerid] - 1);
    }
    // right button or butns
    if(PlayerBussinesListPage[playerid] == PlayerBussinesListPages[playerid]) return HidePlayerDialog(playerid);
    return ShowBussinesList(playerid, PlayerBussinesListPage[playerid] + 1);
}

stock ShowBussinesList(playerid, page) {
    new ownedCount;
    for(new i = 0; i < BussinesSlotLimit; i++) {
        if(ValidBussinesIndex(i) && Bussines[i][bownerid] != 0) ownedCount++;
    }
    if(ownedCount == 0) {
        PlayerBussinesListPage[playerid] = 1;
        return SendMessageInfo(playerid, "Belum ada business yang memiliki owner.");
    }

    new pages = (ownedCount + BUSSINES_PER_PAGE - 1) / BUSSINES_PER_PAGE;
    PlayerBussinesListPages[playerid] = pages;
    
    if(page < 1) page = 1;
    if(page > pages) page = pages;
    PlayerBussinesListPage[playerid] = page;

    new list[2048], line[224], title[64], types[32], count;
    strcat(list, "ID\tNama\tType\tOwner\n");
    for(new i = 0; i < BussinesSlotLimit; i++) {
        if(!ValidBussinesIndex(i) || Bussines[i][bownerid] == 0) continue;
        if(count >= (page - 1) * BUSSINES_PER_PAGE && count < page * BUSSINES_PER_PAGE) {
            GetBussinesTypeName(Bussines[i][btype], types, sizeof types);
            format(line, sizeof line, "%d\t%s\t%s\t%s\n", Bussines[i][bid], Bussines[i][bnames], types, Bussines[i][bownername]);
            strcat(list, line, sizeof list);
        }
        if(++count >= page * BUSSINES_PER_PAGE) break;
    }
    format(title, sizeof title, "Business - Halaman %d/%d", page, pages);

    new butnf[64], butns[64];

    if(page == 1) { format(butnf, sizeof butnf, "Close"); } else { format(butnf, sizeof butnf, "Sebelumnya"); }
    if(page == pages && pages > 1) { format(butns, sizeof butns, "Close"); } else if(page < pages) { format(butns, sizeof butns, "Selanjutnya"); }

    Dialog_Show(playerid, DL_BUSSINES_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, list, butnf, butns);
    return 1;
}


// buy business
Dialog:BUY_MARKET(playerid, response, listitem, const inputtext[]) {
    if(!response) return 1;
    return SendMessageInfo(playerid, "Market ini belum menjual item apa pun.");
}

Dialog:BUY_FASTFOOD(playerid, response, listitem, const inputtext[]) {
    if(!response) return 1;
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid]) return 1;

    // dialog bisa tetap terbuka setelah player berpindah tempat, jadi pastikan player masih di titik beli business Fast Food
    new businessid = GetPlayerBusinessIndex(playerid);
    if(businessid == -1 || Bussines[businessid][binterior] != 9 || !IsPlayerInBuyPoint(playerid, businessid)) return SendMessageError(playerid, "Kamu harus berada di titik beli business Fast Food!");
    if(Bussines[businessid][bsisa] < 1) return SendMessageError(playerid, "Business ini sudah kehabisan stock!");

    new price, hunger, thirst, item[16];

    switch(listitem) {
        case 0: {
            price = 30000;
            hunger = 20;
            format(item, sizeof item, "Burger");
        }
        case 1: {
            price = 40000;
            hunger = 30;
            format(item, sizeof item, "Pizza");
        }
        case 2: {
            price = 15000;
            thirst = 20;
            format(item, sizeof item, "Cola");
        }
        default: return 1;
    }

    if(GetPlayerMoney(playerid) < price) return SendMessageError(playerid, "Uangmu tidak cukup");

    // stock berkurang dan tersimpan ke database lebih dulu, jika gagal pembelian dibatalkan dan uang tidak berkurang
    new data[BussinesData];
    data = Bussines[businessid];
    data[bsisa]--;
    if(!SaveDataBussines(businessid, data)) return SendMessageError(playerid, "Pembelian gagal diproses. Uangmu tidak berkurang, silakan coba lagi.");

    GivePlayerMoney(playerid, -price);
    Pemain[playerid][pUang] = GetPlayerMoney(playerid);

    if(hunger > 0) {
        Pemain[playerid][pLapar] += hunger;
        if(Pemain[playerid][pLapar] > 100) Pemain[playerid][pLapar] = 100;
    }

    if(thirst > 0) {
        Pemain[playerid][pHaus] += thirst;
        if(Pemain[playerid][pHaus] > 100) Pemain[playerid][pHaus] = 100;
    }

    new msg[144], moneysss[32];
    FormatUang(price, moneysss);
    format(msg, sizeof msg, "{00EBFF}[INFO]{FFFFFF} Kamu membeli %s seharga {55FF62}$%s{FFFFFF}.", item, moneysss);
    SendClientMessage(playerid, 0xFFFFFFFF, msg);

    UpdateTextdrawHbe(playerid, PlayerSession[playerid]);

    return 1;
}