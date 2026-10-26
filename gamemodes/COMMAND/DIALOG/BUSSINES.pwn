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
    return 1;
}
