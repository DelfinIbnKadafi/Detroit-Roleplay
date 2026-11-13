Dialog:DL_DELETEBusiness(playerid, response, listitem, const inputtext[]) {
    new bussid = PlayerDeleteBusiness[playerid];
    PlayerDeleteBusiness[playerid] = 0;
    if(!response || !CanManageBusiness(playerid)) return 1;
    new index = GetBusinessIndex(bussid);
    if(index == -1) return SendMessageError(playerid, "Business tersebut sudah tidak tersedia.");
    if(!DeleteBusiness(index)) return SendMessageError(playerid, "Business gagal dihapus. Periksa database atau pastikan pintu tidak sedang diedit.");
    SendMessageInfo(playerid, "Berhasil menghapus business dari server dan database.");
    return 1;
}

Dialog:DIALOG_GANTI_NAMA_BUSI(playerid, response, listitem, const inputtext[]) {
    if(response == 0 && !GantiSendiriNamaBuss[playerid]) {
        new msg[256];
        format(msg, sizeof msg, "Nama Lama :\n%s\n\nMasukkan Nama Baru", Business[SheylaCantikImutBanget[playerid]][bnames]);
        return Dialog_Show(playerid, DIALOG_GANTI_NAMA_BUSI, DIALOG_STYLE_INPUT, "Business - Ganti Nama", msg, "Kirim", "Batal");
    }

    if(!GantiSendiriNamaBuss[playerid]) strcopy(Business[SheylaCantikImutBanget[playerid]][bnames], inputtext, MAX_Business_NAME + 1);

    UpdateBusinessObject(SheylaCantikImutBanget[playerid]);

    SaveDataBusiness(SheylaCantikImutBanget[playerid], Business[SheylaCantikImutBanget[playerid]]);

    return 1;
}


Dialog:DL_Business_LIST(playerid, response, listitem, const inputtext[]) {
    if(!CanManageBusiness(playerid)) return 1;
    if(response) { // left button or butnf
        if(PlayerBusinessListPage[playerid] == 1) return HidePlayerDialog(playerid);
        if(PlayerBusinessListPage[playerid] > 1) return ShowBusinessList(playerid, PlayerBusinessListPage[playerid] - 1);
    }
    // right button or butns
    if(PlayerBusinessListPage[playerid] == PlayerBusinessListPages[playerid]) return HidePlayerDialog(playerid);
    return ShowBusinessList(playerid, PlayerBusinessListPage[playerid] + 1);
}

stock ShowBusinessList(playerid, page) {
    new ownedCount;
    for(new i = 0; i < BusinessSlotLimit; i++) {
        if(ValidBusinessIndex(i) && Business[i][bownerid] != 0) ownedCount++;
    }
    if(ownedCount == 0) {
        PlayerBusinessListPage[playerid] = 1;
        return SendMessageInfo(playerid, "Belum ada business yang memiliki owner.");
    }

    new pages = (ownedCount + Business_PER_PAGE - 1) / Business_PER_PAGE;
    PlayerBusinessListPages[playerid] = pages;
    
    if(page < 1) page = 1;
    if(page > pages) page = pages;
    PlayerBusinessListPage[playerid] = page;

    new list[2048], line[224], title[64], types[32], count;
    strcat(list, "ID\tNama\tType\tOwner\n");
    for(new i = 0; i < BusinessSlotLimit; i++) {
        if(!ValidBusinessIndex(i) || Business[i][bownerid] == 0) continue;
        if(count >= (page - 1) * Business_PER_PAGE && count < page * Business_PER_PAGE) {
            GetBusinessTypeName(Business[i][btype], types, sizeof types);
            format(line, sizeof line, "%d\t%s\t%s\t%s\n", Business[i][bid], Business[i][bnames], types, Business[i][bownername]);
            strcat(list, line, sizeof list);
        }
        if(++count >= page * Business_PER_PAGE) break;
    }
    format(title, sizeof title, "Business - Halaman %d/%d", page, pages);

    new butnf[64], butns[64];

    if(page == 1) { format(butnf, sizeof butnf, "Close"); } else { format(butnf, sizeof butnf, "Sebelumnya"); }
    if(page == pages && pages > 1) { format(butns, sizeof butns, "Close"); } else if(page < pages) { format(butns, sizeof butns, "Selanjutnya"); }

    Dialog_Show(playerid, DL_Business_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, list, butnf, butns);
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
    if(businessid == -1 || Business[businessid][binterior] != 9 || !IsPlayerInBuyPoint(playerid, businessid)) return SendMessageError(playerid, "Kamu harus berada di titik beli business Fast Food!");
    if(Business[businessid][bsisa] < 1) return SendMessageError(playerid, "Business ini sudah kehabisan stock!");

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
    new data[BusinessData];
    data = Business[businessid];
    data[bsisa]--;
    data[bpendapatan] += price;
    if(!SaveDataBusiness(businessid, data)) return SendMessageError(playerid, "Pembelian gagal diproses. Uangmu tidak berkurang, silakan coba lagi.");

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

Dialog:AMBIL_UANG_BUS(playerid, response, listitem, const inputtext[]){
    if(!response) return 1;
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid]) return 1;

    new slot = SlotPlayerPickBus[playerid];
    if(slot < 0 || slot >= PlayerBusinessCount[playerid] || slot >= MAX_Business_PLAYER) return SendMessageError(playerid, "Business yang dipilih tidak valid.");
    new businessid = IdBusinessPlayer[playerid][slot];
    if(!ValidBusinessIndex(businessid) || Business[businessid][bownerid] != Pemain[playerid][pId]) return SendMessageError(playerid, "Business tersebut sudah tidak kamu miliki.");

    if(!ValidUnsignedInteger(inputtext)) return SendMessageError(playerid, "Input harus berupa angka positif!");

    new jumlah = strval(inputtext);
    if(jumlah <= 0) return SendMessageError(playerid, "Jumlah uang yang ditarik harus lebih dari 0!");
    if(jumlah > Business[businessid][bpendapatan]) return SendMessageError(playerid, "Jumlah uang yang ingin ditarik melebihi uang yang tersimpan!");
    if(GetPlayerMoney(playerid) > cellmax - jumlah) return SendMessageError(playerid, "Nominal melebihi batas saldo!");
    if(!SimpanPenarikanBusiness(playerid, businessid, jumlah)) return SendMessageError(playerid, "Penarikan gagal disimpan. Uangmu tidak berubah, silakan coba lagi.");

    GivePlayerMoney(playerid, jumlah);
    Pemain[playerid][pUang] = GetPlayerMoney(playerid);

    new money[32], msg[96];
    FormatUang(jumlah, money);
    format(msg, sizeof msg, "Berhasil menarik $%s dari pendapatan business.", money);
    SendMessageInfo(playerid, msg);

    return 1;
}

Dialog:AKSI_BUSINESS(playerid, response, listitem, const inputtext[]) {
    if(!response) return 1;
    if(!IsPlayerAccountReady(playerid)) return 1;

    new slot = SlotPlayerPickBus[playerid];
    if(slot < 0 || slot >= PlayerBusinessCount[playerid] || slot >= MAX_Business_PLAYER) return SendMessageError(playerid, "Business yang dipilih tidak valid.");
    new businessid = IdBusinessPlayer[playerid][slot];
    if(!ValidBusinessIndex(businessid) || Business[businessid][bownerid] != Pemain[playerid][pId]) return SendMessageError(playerid, "Business tersebut sudah tidak kamu miliki.");

    new judul[128];
    new msg[512];
    new mny[64];
    new typ[64];
    new pndpt[64];

    // informasi
    format(judul, sizeof judul, "%S - Informasi", Business[businessid][bnames]);
    FormatUang(Business[businessid][bprice], mny);
    FormatUang(Business[businessid][bpendapatan], pndpt);
    GetBusinessTypeName(Business[businessid][btype], typ, sizeof typ);
    format(msg, sizeof msg, "Nama : %s\nType : %s\nStock : %d\nPendapatan : %s\nHarga Business : %s", Business[businessid][bnames], typ, Business[businessid][bsisa], pndpt, mny);
    if(listitem == 0) Dialog_Show(playerid, tmp_dialog, DIALOG_STYLE_MSGBOX, judul, msg, "Keluar", "");
    
    // track
    else if(listitem == 1) SetPlayerCheckpoint(playerid, Business[businessid][bx], Business[businessid][by], Business[businessid][bz], 2.0);

    // change name
    else if(listitem == 2) { ShowChangeNamaBusiness(playerid, businessid); GantiSendiriNamaBuss[playerid] = true; }

    // ambil pendapatan
    else if(listitem == 3) {
        format(msg, sizeof msg, "Jumlah pendapatan : %s\n\nMasukkan jumlah uang yang ingin ditarik", pndpt);
        Dialog_Show(playerid, AMBIL_UANG_BUS, DIALOG_STYLE_INPUT, "Tarik Uang Business", msg, "Kirim", "Batal");
    }

    return 1;
}

Dialog:DIALOG_MYBUSS(playerid, response, listitem, const inputtext[]) {
    if(!response) return 1;
    if(!IsPlayerAccountReady(playerid)) return 1;
    if(listitem < 0 || listitem >= PlayerBusinessCount[playerid] || listitem >= MAX_Business_PLAYER) return SendMessageError(playerid, "Business yang dipilih tidak valid.");

    SlotPlayerPickBus[playerid] = listitem;

    new businessid = IdBusinessPlayer[playerid][listitem];
    if(!ValidBusinessIndex(businessid) || Business[businessid][bownerid] != Pemain[playerid][pId]) return SendMessageError(playerid, "Business tersebut sudah tidak kamu miliki.");
    Dialog_Show(playerid, AKSI_BUSINESS, DIALOG_STYLE_LIST, Business[businessid][bnames], "Informasi\nTrack\nGanti Nama\nTarik Uang", "Pilih", "Batal");

    return 1;
}

stock ShowMyBusiness(playerid) {

    // reset firts
    MuatBusinessPlayer(playerid);

    SlotPlayerPickBus[playerid] = -1;

    if(PlayerBusinessCount[playerid] == 0) return SendMessageInfo(playerid, "Kamu tidak memiliki business.");

    new msg[256];
    msg[0] = '\0';

    // start from 0 to player business count - 1
    for(new i = 0; i < PlayerBusinessCount[playerid]; i++) {

        if(Business[IdBusinessPlayer[playerid][i]][bactive] == false) continue;

        if(i > 0) strcat(msg, "\n", sizeof msg);
        strcat(msg, Business[IdBusinessPlayer[playerid][i]][bnames], sizeof msg);
    }

    Dialog_Show(playerid, DIALOG_MYBUSS, DIALOG_STYLE_TABLIST, "My Business", msg, "Pilih", "Batal");

    return 1;
}