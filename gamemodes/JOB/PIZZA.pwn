new bool:PlayerDeliveredPizza[MAX_PLAYERS] = false;
new bool:PlayerCanGetPizza[MAX_PLAYERS] = true;
new TimerPizza[MAX_PLAYERS];

stock ResetPlayerPizza(playerid) {

    PlayerDeliveredPizza[playerid] = false;
    PlayerCanGetPizza[playerid] = true;

    if(IsValidTimer(TimerPizza[playerid])) KillTimer(TimerPizza[playerid]);

    return 1;
}

CMD:getpizza(playerid, params[]) {

    if(Pemain[playerid][pJob] != 1) return SendMessageError(playerid, "Kamu tidak bekerja sebagai pengantar pizza!");

    if(!PlayerCanGetPizza[playerid]) return SendMessageError(playerid, "Kamu harus menunggu waktu jeda 2 menit dimulai dari terakhir kali mengantarkan pizza sebelum mengantarkan pizza lain!");

    if(PlayerDeliveredPizza[playerid]) return SendMessageError(playerid, "Kamu sudah membawa pizza, antarkan terlebih dahulu!");

    SetPlayerAttachedObject(playerid, 0, 19571, 1, -0.131999, -0.152999, -0.005000, 0.500000, 87.499885, 0.000000);

    PlayerDeliveredPizza[playerid] = true;

    // will continue to add drop location

    return SendMessageInfo(playerid, "Berhasil mengambil pizza, silahkan antarkan pizza ke tempat tujuan, lalu gunakan /droppizza untuk meletakkan pizza ke tujuan.");
}