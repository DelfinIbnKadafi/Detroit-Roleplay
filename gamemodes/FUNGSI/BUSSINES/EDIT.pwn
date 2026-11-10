stock ResetBusinessEdit(playerid) {
    new index = PlayerEditBusiness[playerid];
    PlayerEditBusiness[playerid] = -1;
    if(index >= 0 && index < MAX_Business && BusinessEditor[index] == playerid) {
        BusinessEditor[index] = INVALID_PLAYER_ID;
        if(IsPlayerConnected(playerid) && IsValidDynamicPickup(Business[index][bpickup])) Streamer_ToggleItem(playerid, STREAMER_TYPE_PICKUP, Business[index][bpickup], true);
    }
    if(IsValidDynamicObject(PlayerBusinessObject[playerid])) {
        if(IsPlayerConnected(playerid)) CancelEdit(playerid);
        DestroyDynamicObject(PlayerBusinessObject[playerid]);
    }
    PlayerBusinessObject[playerid] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
    return 1;
}

stock bool:EditBusiness(playerid, index) {
    if(!IsPlayerAccountReady(playerid) || Admin[playerid] < 1) return false;
    if(!ValidBusinessIndex(index) || !IsBusinessExterior(playerid)) return false;
    if(PlayerEditBusiness[playerid] != -1 || playereditatm[playerid][active] || BusinessEditor[index] != INVALID_PLAYER_ID) return false;
    if(!IsPlayerInRangeOfPoint(playerid, 20.0, Business[index][bx], Business[index][by], Business[index][bz])) return false;

    // Pickup tidak bisa diedit langsung, gunakan object sementara milik admin
    new STREAMER_TAG_OBJECT:objectid = CreateDynamicObject(Business_PICKUP_MODEL, Business[index][bx], Business[index][by], Business[index][bz], 0.0, 0.0, 0.0, 0, 0, playerid);
    if(!IsValidDynamicObject(objectid)) return false;
    PlayerBusinessObject[playerid] = objectid;
    PlayerEditBusiness[playerid] = index;
    BusinessEditor[index] = playerid;
    Streamer_ToggleItem(playerid, STREAMER_TYPE_PICKUP, Business[index][bpickup], false);
    Streamer_Update(playerid, STREAMER_TYPE_OBJECT);
    if(!EditDynamicObject(playerid, objectid)) {
        ResetBusinessEdit(playerid);
        return false;
    }
    return true;
}

stock HandleBusinessEdit(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z) {
    new index = PlayerEditBusiness[playerid];
    if(index == -1 || PlayerBusinessObject[playerid] != objectid) return 0;
    if(!ValidBusinessIndex(index) || BusinessEditor[index] != playerid || !IsPlayerAccountReady(playerid) || Admin[playerid] < 1 || !IsBusinessExterior(playerid)) {
        ResetBusinessEdit(playerid);
        return 1;
    }
    if(response == _:EDIT_RESPONSE_CANCEL) {
        ResetBusinessEdit(playerid);
        SendMessageInfo(playerid, "Edit posisi business dibatalkan.");
    }
    else if(response == _:EDIT_RESPONSE_FINAL) {
        new data[BusinessData];
        data = Business[index];
        data[bx] = x;
        data[by] = y;
        data[bz] = z;
        new bool:saved = SaveDataBusiness(index, data);
        ResetBusinessEdit(playerid);
        if(!saved) SendMessageError(playerid, "Posisi business gagal disimpan. Posisi lama tetap digunakan.");
        else SendMessageInfo(playerid, "Berhasil mengubah dan menyimpan posisi business.");
    }
    return 1;
}
