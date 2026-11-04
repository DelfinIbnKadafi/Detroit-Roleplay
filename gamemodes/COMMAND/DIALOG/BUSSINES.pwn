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

Dialog:DL_BUSSINES_LIST(playerid, response, listitem, const inputtext[]) {
    if(!CanManageBussines(playerid)) return 1;
    if(response) {
        if(PlayerBussinesListPage[playerid] > 1) {
            return ShowBussinesList(playerid, PlayerBussinesListPage[playerid] - 1);
        }
        return ShowBussinesList(playerid, PlayerBussinesListPage[playerid]);
    }
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
    Dialog_Show(playerid, DL_BUSSINES_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, list, "Sebelumnya", "Berikutnya");
    return 1;
}
