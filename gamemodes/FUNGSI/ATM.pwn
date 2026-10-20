enum atmdata {
    object,
    Text3D:label,
    id,
    Float:posx,
    Float:posy,
    Float:posz,
    Float:angle,
    cadangan
}

#define MAX_ATM 1000
new atm[MAX_ATM][atmdata];
new atmcount;

Fungsi:CreateAtmLabel(index) {
    new msg[256], money[128];
    FormatUang(atm[index][cadangan], money);
    format(msg, sizeof(msg), "[%d]\n{55ff62}[ATM]{ffffff}\nUse /atm or ALT to use atm\n{1ed030}$%s", atm[index][id], money);
    atm[index][label] = Create3DTextLabel(msg, -1, atm[index][posx], atm[index][posy], atm[index][posz], 7.0, 0);
    return atm[index][label] != INVALID_3DTEXT_ID;
}

Fungsi: LoadAtm() {
    atmcount = 0;

    new baris;
    cache_get_row_count(baris);

    for (new i = 0; i < baris && atmcount < MAX_ATM; i++) {
        new index = atmcount;
        cache_get_value_name_int(i, "id", atm[index][id]);
        cache_get_value_name_float(i, "posx", atm[index][posx]);
        cache_get_value_name_float(i, "posy", atm[index][posy]);
        cache_get_value_name_float(i, "posz", atm[index][posz]);
        cache_get_value_name_float(i, "angle", atm[index][angle]);
        cache_get_value_name_int(i, "cadangan", atm[index][cadangan]);

        atm[index][object] = CreateObject(19324, atm[index][posx], atm[index][posy], atm[index][posz], 0.0, 0.0, atm[index][angle]);
        if(atm[index][object] == INVALID_OBJECT_ID) {
            printf("[ATM] Failed to create object for ATM ID %d.", atm[index][id]);
            continue;
        }
        if(!CreateAtmLabel(index)) {
            printf("[ATM] Failed to create 3D label for ATM ID %d.", atm[index][id]);
        }
        atmcount++;
    }

    return 1;
}

Fungsi: CreateAtm(Float:x, Float:y, Float:z, Float:a) {
    if (atmcount >= MAX_ATM) return 0;

    new highestID = 0;
    for (new i = 0; i < atmcount; i++) {
        if (atm[i][id] > highestID) highestID = atm[i][id];
    }

    x += 2.0;

    new index = atmcount;
    atm[index][id] = highestID + 1;
    atm[index][posx] = x;
    atm[index][posy] = y;
    atm[index][posz] = z;
    atm[index][angle] = a;
    atm[index][cadangan] = 1000000;

    atm[index][object] = CreateObject(19324, x, y, z, 0.0, 0.0, a);
    if(atm[index][object] == INVALID_OBJECT_ID) return 0;
    if(!CreateAtmLabel(index)) {
        DestroyObject(atm[index][object]);
        return 0;
    }

    new query[512];
    mysql_format(g_SQL, query, sizeof(query),
        "INSERT INTO `atm` (`id`, `posx`, `posy`, `posz`, `angle`, `cadangan`) VALUES (%d, %f, %f, %f, %f, %d)",
        atm[index][id], atm[index][posx], atm[index][posy], atm[index][posz], atm[index][angle], atm[index][cadangan]);
    mysql_tquery(g_SQL, query);

    atmcount++;
    return 1;
}

enum atmedited {
    objid,
    edit_atm_id,
    bool:active
}
new playereditatm[MAX_PLAYERS][atmedited];

new idatmplayeruse[MAX_PLAYERS]; // id is atm[the_id]

Fungsi:ResetAtmEdit(playerid) {
    playereditatm[playerid][objid] = INVALID_OBJECT_ID;
    playereditatm[playerid][edit_atm_id] = 0;
    playereditatm[playerid][active] = false;
    return 1;
}

Fungsi: EditAtm(playerid, ATMid) {
    for(new i = 0; i < atmcount; i++) {
        if(atm[i][id] == ATMid) {
            if(!EditObject(playerid, atm[i][object])) return 0;
            playereditatm[playerid][objid] = atm[i][object];
            playereditatm[playerid][edit_atm_id] = atm[i][id];
            playereditatm[playerid][active] = true;
            return 1;
        }
    }
    return 0;
}

Fungsi: SaveEditAtm(ATMid, Float:x, Float:y, Float:z, Float:facingAngle) {
    new index = -1;
    for(new i = 0; i < atmcount; i++) {
        if(atm[i][id] == ATMid) {
            index = i;
            break;
        }
    }
    if(index == -1) return 0;

    atm[index][posx] = x;
    atm[index][posy] = y;
    atm[index][posz] = z;
    atm[index][angle] = facingAngle;
    SetObjectPos(atm[index][object], x, y, z);
    SetObjectRot(atm[index][object], 0.0, 0.0, facingAngle);

    Delete3DTextLabel(atm[index][label]);
    if(!CreateAtmLabel(index)) {
        printf("[ATM] Failed to recreate 3D label for ATM ID %d.", ATMid);
    }

    new query[256];
    mysql_format(g_SQL, query, sizeof(query),
        "UPDATE `atm` SET `posx` = %f, `posy` = %f, `posz` = %f, `angle` = %f WHERE `id` = %d",
        x, y, z, facingAngle, ATMid);
    mysql_tquery(g_SQL, query);
    return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, EDIT_RESPONSE:response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ) {
    if(playerobject || !playereditatm[playerid][active] || playereditatm[playerid][objid] != objectid) return 1;

    if(response == EDIT_RESPONSE_FINAL) {
        SaveEditAtm(playereditatm[playerid][edit_atm_id], fX, fY, fZ, fRotZ);
        ResetAtmEdit(playerid);
    }
    else if(response == EDIT_RESPONSE_CANCEL) {
        for(new i = 0; i < atmcount; i++) {
            if(atm[i][object] == objectid) {
                SetObjectPos(objectid, atm[i][posx], atm[i][posy], atm[i][posz]);
                SetObjectRot(objectid, 0.0, 0.0, atm[i][angle]);
                break;
            }
        }
        ResetAtmEdit(playerid);
    }
    return 1;
}

Fungsi: EditTextAtm(theatmid) {
    new msg[256], money[128];
    FormatUang(atm[theatmid][cadangan], money);
    format(msg, sizeof(msg), "[%d]\n{55ff62}[ATM]{ffffff}\nUse /atm or ALT to use atm\n{1ed030}$%s", atm[theatmid][id], money);
    Update3DTextLabelText(atm[theatmid][label], -1, msg);
    return 1;
}

Fungsi: PlayerUseAtm(playerid) {
    for(new i = 0; i < atmcount; i++) {
        if(IsPlayerInRangeOfPoint(playerid, 3.0, atm[i][posx], atm[i][posy], atm[i][posz])) {
            new judul[256], money[128];
            FormatUang(Pemain[playerid][pBank], money);
            idatmplayeruse[playerid] = i;
            format(judul, sizeof judul, "%s - $%s", Pemain[playerid][pNama], money);
            Dialog_Show(playerid, ATMDialog, DIALOG_STYLE_LIST, judul, "Deposit\nWithdraw\nTransfer", "Pilih", "Batal");
            break;
        }
    }
    return 1;
}

Dialog:ATMDialog(playerid, response, listitem, inputtext[]) {
    if(response == 0) {
        return 1;
    }

    // deposit
    if(listitem == 0) {
        Dialog_Show(playerid, DepositATM, DIALOG_STYLE_INPUT, "Deposit", "Masukkan uang untuk di depositkan.", "Enter", "Batal");
        return 1;
    }

    // withdraw
    if(listitem == 1) {
        Dialog_Show(playerid, WithdrawATM, DIALOG_STYLE_INPUT, "Withdraw", "Masukkan uang yang ingin ditarik.", "Enter", "Batal");
        return 1;
    }

    return 1;
}

Dialog:DepositATM(playerid, response, listitem, inputtext[]) {
    if(response == 0) {
        return 1;
    }

    new length = strlen(inputtext);

    if(length < 1) {
        SendMessageError(playerid, "Input harus lebih dari 0 karakter!");
        Dialog_Show(playerid, DepositATM, DIALOG_STYLE_INPUT, "Deposit", "Masukkan uang untuk di depositkan.", "Enter", "Batal");
        return 1;
    }

    if(inputtext[0] == '-') {
        SendMessageError(playerid, "Nominal tidak boleh minus");
        Dialog_Show(playerid, DepositATM, DIALOG_STYLE_INPUT, "Deposit", "Masukkan uang untuk di depositkan.", "Enter", "Batal");
        return 1;
    }

    for(new i = 0; i < length; i++) {
        if(inputtext[i] < '0' || inputtext[i] > '9') {
            SendMessageError(playerid, "Input harus berupa angka!");
            Dialog_Show(playerid, DepositATM, DIALOG_STYLE_INPUT, "Deposit", "Masukkan uang untuk di depositkan.", "Enter", "Batal");
            return 1;
        }
    }

    new jumlah = strval(inputtext);

    if(jumlah <= 0) return SendMessageError(playerid, "Nominal deposit harus lebih dari 0!");

    if(jumlah > Pemain[playerid][pUang]) return SendMessageError(playerid, "Uangmu tidak cukup!");

    GivePlayerMoney(playerid, -jumlah);
    Pemain[playerid][pBank] += jumlah;

    SimpanDataPemain(playerid);

    atm[idatmplayeruse[playerid]][cadangan] += jumlah;

    EditTextAtm(idatmplayeruse[playerid]);

    SendMessageInfo(playerid, "Sukses mendepositkan uang!");

    return 1;
}


Dialog:WithdrawATM(playerid, response, listitem, inputtext[]) {
    if(response == 0) {
        return 1;
    }

    new length = strlen(inputtext);

    if(length < 1) {
        SendMessageError(playerid, "Input harus lebih dari 0 karakter!");
        Dialog_Show(playerid, WithdrawATM, DIALOG_STYLE_INPUT, "Withdraw", "Masukkan uang yang ingin ditarik.", "Enter", "Batal");
        return 1;
    }

    for(new i = 0; i < length; i++) {
        if(inputtext[i] < '0' || inputtext[i] > '9') {
            SendMessageError(playerid, "Input harus berupa angka!");
            Dialog_Show(playerid, WithdrawATM, DIALOG_STYLE_INPUT, "Withdraw", "Masukkan uang yang ingin ditarik.", "Enter", "Batal");
            return 1;
        }
    }

    new jumlah = strval(inputtext);

    if(jumlah <= 0) {
        SendMessageError(playerid, "Nominal withdraw harus lebih dari 0!");
        return 1;
    }

    if(jumlah > Pemain[playerid][pBank]) {
        SendMessageError(playerid, "Saldo bankmu tidak cukup!");
        return 1;
    }

    if(jumlah > atm[idatmplayeruse[playerid]][cadangan]) {
        SendMessageError(playerid, "Uang tunai di ATM tidak cukup!");
        return 1;
    }

    Pemain[playerid][pBank] -= jumlah;
    GivePlayerMoney(playerid, jumlah);

    SimpanDataPemain(playerid);

    atm[idatmplayeruse[playerid]][cadangan] -= jumlah;

    EditTextAtm(idatmplayeruse[playerid]);

    SendMessageInfo(playerid, "Sukses menarik uang dari bank!");

    return 1;
}
