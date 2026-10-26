
stock MakeBussinesObject(bussid) {
    Bussines[bussid][pickup] = CreateDynamicPickup(19132, 1, Bussines[bussid][bx], Bussines[bussid][by], Bussines[bussid][bz], -1, -1, -1, 10.0);
    new msg[256], types[32];
    if(Bussines[bussid][btype] == 0) {
        strcopy(types, "Market", sizeof types);
    }
    format(msg, sizeof msg, "[%d]\n%s\nOwner : %s\nType : %s\nStock : %d", Bussines[bussid][id], Bussines[bussid][bnames], Bussines[bussid][ownername], types, Bussines[bussid][sisa]);
    Bussines[bussid][label] = Create3DTextLabel(msg, -1, Bussines[bussid][bx], Bussines[bussid][by], Bussines[bussid][bz], 5.0, -1);
}

LoadBussines() {
    new baris = cache_num_rows();

    if(baris < 1) return 1;

    // start from 0, MAX_BUSSINES is 1000
    for(new i = 0; i < baris; i++) {
        BussinesCount++;
        cache_get_value_name_int(i, "id", Bussines[BussinesCount][id]);
        cache_get_value_name_int(i, "ownerid", Bussines[BussinesCount][bownerid]);
        cache_get_value_name_float(i, "posx", Bussines[BussinesCount][bx]);
        cache_get_value_name_float(i, "posy", Bussines[BussinesCount][by]);
        cache_get_value_name_float(i, "posz", Bussines[BussinesCount][bz]);
        cache_get_value_name_int(i, "type", Bussines[BussinesCount][btype]);
        cache_get_value_name_int(i, "stock", Bussines[BussinesCount][sisa]);
        cache_get_value_name(i, "name", Bussines[BussinesCount][bnames], sizeof Bussines[BussinesCount][bnames]);

        format(msg, sizeof msg, "Berhasil meload bussines id %d", Bussines[BussinesCount][id]);
        printf(msg);

        MakeBussinesObject(BussinesCount);
    }

    return 1;
}