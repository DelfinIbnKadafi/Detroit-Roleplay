stock ResetBussinesEdit(playerid) {
    new index = PlayerEditBussines[playerid];
    PlayerEditBussines[playerid] = -1;
    if(index >= 0 && index < MAX_BUSSINES && BussinesEditor[index] == playerid) {
        BussinesEditor[index] = INVALID_PLAYER_ID;
        if(IsPlayerConnected(playerid) && IsValidDynamicPickup(Bussines[index][bpickup])) Streamer_ToggleItem(playerid, STREAMER_TYPE_PICKUP, Bussines[index][bpickup], true);
    }
    if(IsValidDynamicObject(PlayerBussinesObject[playerid])) {
        if(IsPlayerConnected(playerid)) CancelEdit(playerid);
        DestroyDynamicObject(PlayerBussinesObject[playerid]);
    }
    PlayerBussinesObject[playerid] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
    return 1;
}

stock bool:EditBussines(playerid, index) {
    if(!IsPlayerAccountReady(playerid) || Admin[playerid] < 1) return false;
    if(!ValidBussinesIndex(index) || !IsBussinesExterior(playerid)) return false;
    if(PlayerEditBussines[playerid] != -1 || playereditatm[playerid][active] || BussinesEditor[index] != INVALID_PLAYER_ID) return false;
    if(!IsPlayerInRangeOfPoint(playerid, 20.0, Bussines[index][bx], Bussines[index][by], Bussines[index][bz])) return false;

    // Pickup tidak bisa diedit langsung, gunakan object sementara milik admin
    new STREAMER_TAG_OBJECT:objectid = CreateDynamicObject(BUSSINES_PICKUP_MODEL, Bussines[index][bx], Bussines[index][by], Bussines[index][bz], 0.0, 0.0, 0.0, 0, 0, playerid);
    if(!IsValidDynamicObject(objectid)) return false;
    PlayerBussinesObject[playerid] = objectid;
    PlayerEditBussines[playerid] = index;
    BussinesEditor[index] = playerid;
    Streamer_ToggleItem(playerid, STREAMER_TYPE_PICKUP, Bussines[index][bpickup], false);
    Streamer_Update(playerid, STREAMER_TYPE_OBJECT);
    if(!EditDynamicObject(playerid, objectid)) {
        ResetBussinesEdit(playerid);
        return false;
    }
    return true;
}

stock HandleBussinesEdit(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z) {
    new index = PlayerEditBussines[playerid];
    if(index == -1 || PlayerBussinesObject[playerid] != objectid) return 0;
    if(!ValidBussinesIndex(index) || BussinesEditor[index] != playerid || !IsPlayerAccountReady(playerid) || Admin[playerid] < 1 || !IsBussinesExterior(playerid)) {
        ResetBussinesEdit(playerid);
        return 1;
    }
    if(response == _:EDIT_RESPONSE_CANCEL) {
        ResetBussinesEdit(playerid);
        SendMessageInfo(playerid, "Edit posisi business dibatalkan.");
    }
    else if(response == _:EDIT_RESPONSE_FINAL) {
        new data[BussinesData];
        data = Bussines[index];
        data[bx] = x;
        data[by] = y;
        data[bz] = z;
        new bool:saved = SaveDataBussines(index, data);
        ResetBussinesEdit(playerid);
        if(!saved) SendMessageError(playerid, "Posisi business gagal disimpan. Posisi lama tetap digunakan.");
        else SendMessageInfo(playerid, "Berhasil mengubah dan menyimpan posisi business.");
    }
    return 1;
}
