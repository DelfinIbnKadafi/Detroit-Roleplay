CMD:createbusiness(playerid, params[]) {
    if(!CanManageBussines(playerid)) return 1;
    if(!IsBussinesExterior(playerid)) return SendMessageError(playerid, "Business hanya bisa dibuat di luar bangunan pada virtual world 0.");

    new typeString[16], name[144];
    if(sscanf(params, "s[16]s[144]", typeString, name)) return SendClientMessage(playerid, -1, "Gunakan: /createbusiness <type> <nama> (0 = Market)");
    if(!ValidBussinesNumber(typeString) || strval(typeString) > 127 || !ValidBussinesName(name)) return SendMessageError(playerid, "Type harus 0-127 dan nama business harus 1-128 karakter tanpa kode warna.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new index = CreateBussines(name, strval(typeString), x, y, z);
    if(index == -1) return SendMessageError(playerid, "Business gagal dibuat. Periksa database, posisi, atau batas pintu dan text label.");

    new msg[144];
    format(msg, sizeof msg, "{00EBFF}[INFO]{FFFFFF} Berhasil membuat business ID %d. Gunakan /editbusiness %d pos untuk mengatur pintu.", Bussines[index][bid], Bussines[index][bid]);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:editbusiness(playerid, params[]) {
    if(!CanManageBussines(playerid)) return 1;
    new idString[16], option[16], value[144];
    if(sscanf(params, "s[16]s[16]S()[144]", idString, option, value)) return SendClientMessage(playerid, -1, "Gunakan: /editbusiness <id> <pos/here/name/type/stock/owner> [nilai]");
    if(!ValidBussinesNumber(idString)) return SendMessageError(playerid, "ID business tidak valid!");
    new index = GetBussinesIndex(strval(idString));
    if(index == -1) return SendMessageError(playerid, "Business tidak ditemukan!");
    if(BussinesEditor[index] != INVALID_PLAYER_ID) return SendMessageError(playerid, "Business tersebut sedang diedit. Selesaikan atau batalkan edit terlebih dahulu.");
    if(PlayerEditBussines[playerid] != -1) return SendMessageError(playerid, "Selesaikan atau batalkan edit posisi business yang sedang berjalan.");

    if(!strcmp(option, "pos", true)) {
        if(strlen(value)) return SendClientMessage(playerid, -1, "Gunakan: /editbusiness <id> pos");
        if(!EditBussines(playerid, index)) return SendMessageError(playerid, "Gagal memulai edit. Dekati pintu dalam jarak 20 meter dan pastikan tidak sedang mengedit ATM.");
        SendMessageInfo(playerid, "Atur posisi pintu lalu tekan Save. Gunakan /cancelbusinessedit untuk membatalkan.");
        return 1;
    }

    new data[BussinesData];
    data = Bussines[index];
    if(!strcmp(option, "here", true)) {
        if(strlen(value)) return SendClientMessage(playerid, -1, "Gunakan: /editbusiness <id> here");
        if(!IsBussinesExterior(playerid)) return SendMessageError(playerid, "Pintu business harus berada di luar bangunan pada virtual world 0.");
        GetPlayerPos(playerid, data[bx], data[by], data[bz]);
    }
    else if(!strcmp(option, "name", true)) {
        if(!ValidBussinesName(value)) return SendMessageError(playerid, "Nama business harus 1-128 karakter tanpa kode warna.");
        format(data[bnames], MAX_BUSSINES_NAME + 1, "%s", value);
    }
    else if(!strcmp(option, "type", true)) {
        if(!ValidBussinesNumber(value) || strval(value) > 127) return SendMessageError(playerid, "Type business harus 0-127. Type 0 adalah Market.");
        data[btype] = strval(value);
    }
    else if(!strcmp(option, "stock", true)) {
        if(!ValidBussinesNumber(value)) return SendMessageError(playerid, "Stock business harus berupa angka 0-2147483647.");
        data[bsisa] = strval(value);
    }
    else if(!strcmp(option, "owner", true)) {
        if(!ValidBussinesNumber(value)) return SendMessageError(playerid, "Gunakan ID akun pemilik dari database, atau 0 untuk menghapus pemilik.");
        data[bownerid] = strval(value);
        if(!GetBussinesOwnerName(data[bownerid], data[bownername], MAX_PLAYER_NAME + 1)) return SendMessageError(playerid, "Akun pemilik tidak ditemukan atau database gagal diakses.");
    }
    else return SendClientMessage(playerid, -1, "Gunakan: /editbusiness <id> <pos/here/name/type/stock/owner> [nilai]");

    if(!SaveDataBussines(index, data)) return SendMessageError(playerid, "Data business gagal disimpan. Data lama tetap digunakan.");
    SendMessageInfo(playerid, "Berhasil mengubah dan menyimpan data business.");
    return 1;
}

CMD:cancelbusinessedit(playerid, params[]) {
    if(PlayerEditBussines[playerid] == -1) return SendMessageError(playerid, "Kamu sedang tidak mengedit posisi business.");
    ResetBussinesEdit(playerid);
    SendMessageInfo(playerid, "Edit posisi business dibatalkan.");
    return 1;
}

CMD:gotobusiness(playerid, params[]) {
    if(!CanManageBussines(playerid)) return 1;
    if(PlayerEditBussines[playerid] != -1) return SendMessageError(playerid, "Selesaikan atau batalkan edit posisi business terlebih dahulu.");
    if(!ValidBussinesNumber(params)) return SendClientMessage(playerid, -1, "Gunakan: /gotobusiness <id>");
    new index = GetBussinesIndex(strval(params));
    if(index == -1) return SendMessageError(playerid, "Business tidak ditemukan!");
    if(IsPlayerInAnyVehicle(playerid)) return SendMessageError(playerid, "Turun dari kendaraan terlebih dahulu.");
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, Bussines[index][bx] + 1.0, Bussines[index][by], Bussines[index][bz]);
    SendMessageInfo(playerid, "Berhasil teleport ke pintu business.");
    return 1;
}

CMD:deletebusiness(playerid, params[]) {
    PlayerDeleteBussines[playerid] = 0;
    if(!CanManageBussines(playerid)) return 1;
    if(!ValidBussinesNumber(params)) return SendClientMessage(playerid, -1, "Gunakan: /deletebusiness <id>");
    new index = GetBussinesIndex(strval(params));
    if(index == -1) return SendMessageError(playerid, "Business tidak ditemukan!");
    if(BussinesEditor[index] != INVALID_PLAYER_ID) return SendMessageError(playerid, "Business tersebut sedang diedit. Selesaikan atau batalkan edit terlebih dahulu.");

    new msg[256];
    format(msg, sizeof msg, "Hapus business ID %d (%s)?\nPintu, text label, dan data business akan dihapus dari database.", Bussines[index][bid], Bussines[index][bnames]);
    PlayerDeleteBussines[playerid] = Bussines[index][bid];
    Dialog_Show(playerid, DL_DELETEBUSSINES, DIALOG_STYLE_MSGBOX, "Hapus Business", msg, "Hapus", "Batal");
    return 1;
}

CMD:businesslist(playerid, params[]) {
    if(!CanManageBussines(playerid)) return 1;
    if(BussinesCount == 0) return SendMessageInfo(playerid, "Belum ada business yang dimuat.");
    new page = 1, pages = (BussinesCount + BUSSINES_PER_PAGE - 1) / BUSSINES_PER_PAGE;
    if(strlen(params)) {
        if(!ValidBussinesNumber(params)) return SendClientMessage(playerid, -1, "Gunakan: /businesslist [halaman]");
        page = strval(params);
    }
    if(page < 1 || page > pages) return SendMessageError(playerid, "Halaman business tidak tersedia.");

    new list[2048], line[224], title[64], types[32], count;
    strcat(list, "ID\tNama\tType\tOwner\n");
    for(new i = 0; i < MAX_BUSSINES; i++) {
        if(!ValidBussinesIndex(i)) continue;
        if(count >= (page - 1) * BUSSINES_PER_PAGE && count < page * BUSSINES_PER_PAGE) {
            GetBussinesTypeName(Bussines[i][btype], types, sizeof types);
            format(line, sizeof line, "%d\t%s\t%s\t%s\n", Bussines[i][bid], Bussines[i][bnames], types, Bussines[i][bownername]);
            strcat(list, line, sizeof list);
        }
        if(++count >= page * BUSSINES_PER_PAGE) break;
    }
    format(title, sizeof title, "Business - Halaman %d/%d", page, pages);
    Dialog_Show(playerid, DL_BUSSINES_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, list, "Tutup", "");
    return 1;
}
