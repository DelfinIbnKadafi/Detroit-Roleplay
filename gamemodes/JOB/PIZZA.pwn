new bool:PlayerDeliveredPizza[MAX_PLAYERS] = false;
new bool:PlayerCanGetPizza[MAX_PLAYERS] = true;
new TimerPizza[MAX_PLAYERS];
new Float:DropPizzaLocation[MAX_PLAYERS][3]; // x = 0 y = 0 z = 0

Fungsi: ResetPlayerPizza(playerid) {

    PlayerDeliveredPizza[playerid] = false;
    PlayerCanGetPizza[playerid] = true;

    if(IsValidTimer(TimerPizza[playerid])) KillTimer(TimerPizza[playerid]);
    TimerPizza[playerid] = -1;

    return 1;
}

enum PizzaVeh {
    bool:mesin,
    Float:fuelpizza,
    vhid
}

new PizzaVehData[5][PizzaVeh];

Fungsi: ResetKendaraanPizza() {
    new Float:y = -1792.4;
    for(new i = 0; i < 5; i++) {
        if(IsValidVehicle(PizzaVehData[i][vhid])) DestroyVehicle(PizzaVehData[i][vhid]);
        PizzaVehData[i][fuelpizza] = 100;
        PizzaVehData[i][mesin] = false;
        y -= 1.5;
        PizzaVehData[i][vhid] = CreateVehicle(448, 2097.5, y, 13.4, 88.7, 3, 5, -1);
        ResetDataVehServer(PizzaVehData[i][vhid]);
    }
    return 1;
}

stock IsPizzaVehicle(vehicleid) {
    for(new i = 0; i < 5; i++) {
        if(PizzaVehData[i][vhid] == vehicleid) return 1;
    }
    return 0;
}

stock GetPizzaVehicleFuel(vehicleid) {
    for(new i = 0; i < 5; i++) {
        if(PizzaVehData[i][vhid] == vehicleid) return floatround(PizzaVehData[i][fuelpizza]);
    }
    return 0;
}

CMD:getpizza(playerid, params[]) {

    if(Pemain[playerid][pJob] != 1) return SendMessageError(playerid, "Kamu tidak bekerja sebagai pengantar pizza!");

    if(!PlayerCanGetPizza[playerid]) return SendMessageError(playerid, "Kamu harus menunggu waktu jeda 2 menit dimulai dari terakhir kali mengantarkan pizza sebelum mengantarkan pizza lain!");

    if(PlayerDeliveredPizza[playerid]) return SendMessageError(playerid, "Kamu sudah membawa pizza, antarkan terlebih dahulu!");

    SetPlayerAttachedObject(playerid, 0, 19571, 1, -0.131999, -0.152999, -0.005000, 0.500000, 87.499885, 0.000000);

    PlayerDeliveredPizza[playerid] = true;
    PlayerCanGetPizza[playerid] = false;

    // set drop location
    new droprandom = random(7); // might be 0, or 1 (maximum is max-1)

    switch(droprandom) {
        case 0: {
            DropPizzaLocation[playerid][0] = 1326.36;
            DropPizzaLocation[playerid][1] = -1090.50;
            DropPizzaLocation[playerid][2] = 28;
        }
        case 1: {
            DropPizzaLocation[playerid][0] = 852.39;
            DropPizzaLocation[playerid][1] = -1422.31;
            DropPizzaLocation[playerid][2] = 13.81;
        }
        case 2: {
            DropPizzaLocation[playerid][0] = 280.93;
            DropPizzaLocation[playerid][1] = -1768.08;
            DropPizzaLocation[playerid][2] = 4.53;
        }
        case 3: {
            DropPizzaLocation[playerid][0] = 657.18;
            DropPizzaLocation[playerid][1] = -1652.59;
            DropPizzaLocation[playerid][2] = 15.40;
        }
        case 4: {
            DropPizzaLocation[playerid][0] = 1410.97;
            DropPizzaLocation[playerid][1] = -920.84;
            DropPizzaLocation[playerid][2] = 38.42;
        }
        case 5: {
            DropPizzaLocation[playerid][0] = 1496.96;
            DropPizzaLocation[playerid][1] = -688.03;
            DropPizzaLocation[playerid][2] = 95.56;
        }
        case 6: {
            DropPizzaLocation[playerid][0] = 1016.90;
            DropPizzaLocation[playerid][1] = -762.86;
            DropPizzaLocation[playerid][2] = 112.56;
        }
    }

    SetPlayerCheckpoint(playerid, DropPizzaLocation[playerid][0], DropPizzaLocation[playerid][1], DropPizzaLocation[playerid][2], 1.5);

    return SendMessageInfo(playerid, "Berhasil mengambil pizza, silahkan antarkan pizza ke tempat tujuan, lalu gunakan /droppizza untuk meletakkan pizza.");
}

CMD:droppizza(playerid, params[]) {

    if(Pemain[playerid][pJob] != 1) return SendMessageError(playerid, "Kamu tidak bekerja sebagai pengantar pizza!");

    if(!PlayerDeliveredPizza[playerid]) return SendMessageError(playerid, "Kamu tidak membawa pizza apapun, ambillah terlebih dahulu!");

    if(!IsPlayerInRangeOfPoint(playerid, 1.5, DropPizzaLocation[playerid][0], DropPizzaLocation[playerid][1], DropPizzaLocation[playerid][2])) return SendMessageError(playerid, "Kamu belum sampai di lokasi tujuan!");

    if(IsPlayerInAnyVehicle(playerid)) return SendMessageError(playerid, "Kamu harus keluar kendaraan untuk menaruh pizza!");

    ApplyAnimationEx(playerid, "BOMBER", "BOM_Plant", 4.1, false, false, false, false, SYNC_ALL);

    PlayerDeliveredPizza[playerid] = false;

    GivePlayerMoney(playerid, 70000);

    RemovePlayerAttachedObject(playerid, 0);

    TimerPizza[playerid] = SetTimerEx("ResetPlayerPizza", 120000, false, "i", playerid);

    return 1;
}