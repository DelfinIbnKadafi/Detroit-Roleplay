Dialog:DIALOG_PHONE(playerid, response, listitem, const inputtext[]) {
    if(!response) return 1;

    switch(listitem) {
        // informasi
        case 0: {
            new dlg[512];
            format(dlg, sizeof dlg, "Nomor Telepon : %s\nKuota Internet : %.1fgb", Pemain[playerid][pNohp], Pemain[playerid][pKuota]);
            Dialog_Show(playerid, DLG_PH, DIALOG_STYLE_MSGBOX, "My Phone - Informasi", dlg, "Keluar", " ");
            return 1;
        }
        // telpon
        case 1: {
            Dialog_Show(playerid, DIALOG_PHONE_CALL, DIALOG_STYLE_INPUT, "Telpon - Nomor", "Masukkan nomor telepon", "Kirim", "Batal");
        }
        // matikan ponsel
        case 2: {
            Pemain[playerid][pPhoneStatus] = 0;
            return SendMessageInfo(playerid, "Berhasil mematikan ponsel");
        }
    }

    return 1;
}

Dialog:DIALOG_PHONE_CALL(playerid, response, listitem, const inputtext[]) {
    if(!response) return 1;

    if(strlen(inputtext) < 1) return SendMessageError(playerid, "Input tidak boleh kosong");

    if(!StringIsInteger(inputtext)) return SendMessageError(playerid, "Input harus berupa angka");

    CallLocalFunction("cmd_call", "is", playerid, inputtext);

    return 1;
}