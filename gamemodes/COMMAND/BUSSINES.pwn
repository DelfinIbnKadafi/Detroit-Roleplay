CMD:createbusiness(playerid, params[]) {
    if(!CanManageBusiness(playerid)) return 1;
    if(!IsBusinessExterior(playerid)) return SendMessageError(playerid, "Business hanya bisa dibuat di luar bangunan pada virtual world 0.");

    new typeString[16];
    if(sscanf(params, "s[16]", typeString)) return SendClientMessage(playerid, -1, "Gunakan: /createbusiness <type> (0 = Market, 1 = Fast Food");
    if(!ValidBusinessNumber(typeString) || strval(typeString) > 127) return SendMessageError(playerid, "Type harus 0-127.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new index = CreateBusiness("For Sell", strval(typeString), x, y, z);
    if(index == -1) return SendMessageError(playerid, "Business gagal dibuat. Periksa database, posisi, atau batas pintu dan text label.");

    new msg[144];
    format(msg, sizeof msg, "{00EBFF}[INFO]{FFFFFF} Berhasil membuat business ID %d. Gunakan /editbusiness %d pos untuk mengatur pintu.", Business[index][bid], Business[index][bid]);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:editbusiness(playerid, params[]) {
    if(!CanManageBusiness(playerid)) return 1;
    new idString[16], option[16], value[144];
    if(sscanf(params, "s[16]s[16]S()[144]", idString, option, value)) return SendClientMessage(playerid, -1, "Gunakan: /editbusiness <id> <pos/here/name/type/stock/price/owner> [nilai]");
    if(!ValidBusinessNumber(idString)) return SendMessageError(playerid, "ID business tidak valid!");
    new index = GetBusinessIndex(strval(idString));
    if(index == -1) return SendMessageError(playerid, "Business tidak ditemukan!");
    if(BusinessEditor[index] != INVALID_PLAYER_ID) return SendMessageError(playerid, "Business tersebut sedang diedit. Selesaikan atau batalkan edit terlebih dahulu.");
    if(PlayerEditBusiness[playerid] != -1) return SendMessageError(playerid, "Selesaikan atau batalkan edit posisi business yang sedang berjalan.");

    if(!strcmp(option, "pos", true)) {
        if(strlen(value)) return SendClientMessage(playerid, -1, "Gunakan: /editbusiness <id> pos");
        if(!EditBusiness(playerid, index)) return SendMessageError(playerid, "Gagal memulai edit. Dekati pintu dalam jarak 20 meter dan pastikan tidak sedang mengedit ATM.");
        SendMessageInfo(playerid, "Atur posisi pintu lalu tekan Save. Gunakan /cancelbusinessedit untuk membatalkan.");
        return 1;
    }

    new data[BusinessData];
    data = Business[index];
    if(!strcmp(option, "here", true)) {
        if(strlen(value)) return SendClientMessage(playerid, -1, "Gunakan: /editbusiness <id> here");
        if(!IsBusinessExterior(playerid)) return SendMessageError(playerid, "Pintu business harus berada di luar bangunan pada virtual world 0.");
        GetPlayerPos(playerid, data[bx], data[by], data[bz]);
    }
    else if(!strcmp(option, "name", true)) {
        if(!ValidBusinessName(value)) return SendMessageError(playerid, "Nama business harus 1-128 karakter tanpa kode warna.");
        format(data[bnames], MAX_Business_NAME + 1, "%s", value);
    }
    else if(!strcmp(option, "type", true)) {
        if(!ValidBusinessNumber(value) || strval(value) > 127) return SendMessageError(playerid, "Type business harus 0-127. Type 0 adalah Market.");
        data[btype] = strval(value);
        data[binterior] = GetBusinessTypeInterior(data[btype]);
    }
    else if(!strcmp(option, "stock", true)) {
        if(!ValidBusinessNumber(value)) return SendMessageError(playerid, "Stock business harus berupa angka 0-2147483647.");
        data[bsisa] = strval(value);
    }
    else if(!strcmp(option, "price", true)) {
        if(!ValidBusinessNumber(value) || strval(value) < 1) return SendMessageError(playerid, "Harga business harus berupa angka 1-2147483647.");
        data[bprice] = strval(value);
    }
    else if(!strcmp(option, "owner", true)) {
        if(!ValidBusinessNumber(value)) return SendMessageError(playerid, "Gunakan ID akun pemilik dari database, atau 0 untuk menghapus pemilik.");
        data[bownerid] = strval(value);
        if(!GetBusinessOwnerName(data[bownerid], data[bownername], MAX_PLAYER_NAME + 1)) return SendMessageError(playerid, "Akun pemilik tidak ditemukan atau database gagal diakses.");
    }
    else return SendClientMessage(playerid, -1, "Gunakan: /editbusiness <id> <pos/here/name/type/stock/price/owner> [nilai]");

    if(!SaveDataBusiness(index, data)) return SendMessageError(playerid, "Data business gagal disimpan. Data lama tetap digunakan.");
    SendMessageInfo(playerid, "Berhasil mengubah dan menyimpan data business.");
    return 1;
}

CMD:cancelbusinessedit(playerid, params[]) {
    if(PlayerEditBusiness[playerid] == -1) return SendMessageError(playerid, "Kamu sedang tidak mengedit posisi business.");
    ResetBusinessEdit(playerid);
    SendMessageInfo(playerid, "Edit posisi business dibatalkan.");
    return 1;
}

CMD:gotobusiness(playerid, params[]) {
    if(!CanManageBusiness(playerid)) return 1;
    if(PlayerEditBusiness[playerid] != -1) return SendMessageError(playerid, "Selesaikan atau batalkan edit posisi business terlebih dahulu.");
    if(!ValidBusinessNumber(params)) return SendClientMessage(playerid, -1, "Gunakan: /gotobusiness <id>");
    new index = GetBusinessIndex(strval(params));
    if(index == -1) return SendMessageError(playerid, "Business tidak ditemukan!");
    if(IsPlayerInAnyVehicle(playerid)) return SendMessageError(playerid, "Turun dari kendaraan terlebih dahulu.");
    if(!ValidBusinessPosition(Business[index][bx] + 1.0, Business[index][by], Business[index][bz])) return SendMessageError(playerid, "Koordinat tidak valid!");
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    PindahkanPemain(playerid, Business[index][bx] + 1.0, Business[index][by], Business[index][bz]);
    SendMessageInfo(playerid, "Berhasil teleport ke pintu business.");
    return 1;
}

CMD:deletebusiness(playerid, params[]) {
    PlayerDeleteBusiness[playerid] = 0;
    if(!CanManageBusiness(playerid)) return 1;
    if(!ValidBusinessNumber(params)) return SendClientMessage(playerid, -1, "Gunakan: /deletebusiness <id>");
    new index = GetBusinessIndex(strval(params));
    if(index == -1) return SendMessageError(playerid, "Business tidak ditemukan!");
    if(BusinessEditor[index] != INVALID_PLAYER_ID) return SendMessageError(playerid, "Business tersebut sedang diedit. Selesaikan atau batalkan edit terlebih dahulu.");

    new msg[256];
    format(msg, sizeof msg, "Hapus business ID %d (%s)?\nPintu, text label, dan data business akan dihapus dari database.", Business[index][bid], Business[index][bnames]);
    PlayerDeleteBusiness[playerid] = Business[index][bid];
    Dialog_Show(playerid, DL_DELETEBusiness, DIALOG_STYLE_MSGBOX, "Hapus Business", msg, "Hapus", "Batal");
    return 1;
}

CMD:businesslist(playerid, params[]) {
    if(!CanManageBusiness(playerid)) return 1;
    PlayerBusinessListPage[playerid] = 1;
    return ShowBusinessList(playerid, PlayerBusinessListPage[playerid]);
}

CMD:closebusinesslist(playerid, params[]) {
    if(!CanManageBusiness(playerid)) return 1;
    HidePlayerDialog(playerid);
    return 1;
}

CMD:buybusiness(playerid, params[]) {
    if(PlayerBusinessCount[playerid] == 3) return SendMessageError(playerid, "Kamu hanya bisa memiliki 3 business!");
    BuyBusiness(playerid);
    return 1;
}

CMD:buy(playerid, params[]) {
    ShowBuyDialog(playerid);
    return 1;
}

CMD:mybus(playerid, params[]) {
    ShowMyBusiness(playerid);
    return 1;
}