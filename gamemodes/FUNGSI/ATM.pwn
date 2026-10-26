enum atmdata {
    STREAMER_TAG_OBJECT:object,
    STREAMER_TAG_3D_TEXT_LABEL:label,
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
new bool:AtmReady;
new AtmEditor[MAX_ATM] = {INVALID_PLAYER_ID, ...};

enum atmedited {
    STREAMER_TAG_OBJECT:objid,
    edit_atm_id,
    bool:active
}
new playereditatm[MAX_PLAYERS][atmedited];
new idatmplayeruse[MAX_PLAYERS] = {-1, ...}; // id is atm[the_id]

stock GetAtmIndex(atmid) {
    for(new i = 0; i < atmcount; i++) {
        if(atm[i][id] == atmid) return i;
    }
    return -1;
}

stock ResetAtmSlot(index) {
    if(IsValidDynamicObject(atm[index][object])) DestroyDynamicObject(atm[index][object]);
    if(IsValidDynamic3DTextLabel(atm[index][label])) DestroyDynamic3DTextLabel(atm[index][label]);
    static const empty[atmdata];
    atm[index] = empty;
    AtmEditor[index] = INVALID_PLAYER_ID;
    return 1;
}

Fungsi:CreateAtmLabel(index) {
    new msg[256], money[128];
    FormatUang(atm[index][cadangan], money);
    format(msg, sizeof msg, "[%d]\n{55ff62}[ATM]{ffffff}\nUse /atm or ALT to use atm\n{1ed030}$%s", atm[index][id], money);
    atm[index][label] = CreateDynamic3DTextLabel(msg, -1, atm[index][posx], atm[index][posy], atm[index][posz], 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    return IsValidDynamic3DTextLabel(atm[index][label]);
}

Fungsi: LoadAtm() {
    if(AtmReady) return 1;
    new baris = cache_num_rows();
    for(new i = 0; i < baris && atmcount < MAX_ATM; i++) {
        new index = atmcount;
        cache_get_value_name_int(i, "id", atm[index][id]);
        cache_get_value_name_float(i, "posx", atm[index][posx]);
        cache_get_value_name_float(i, "posy", atm[index][posy]);
        cache_get_value_name_float(i, "posz", atm[index][posz]);
        cache_get_value_name_float(i, "angle", atm[index][angle]);
        cache_get_value_name_int(i, "cadangan", atm[index][cadangan]);
        if(atm[index][id] <= 0 || GetAtmIndex(atm[index][id]) != -1 || !ValidWorldPosition(atm[index][posx], atm[index][posy], atm[index][posz]) || !(atm[index][angle] >= -36000.0 && atm[index][angle] <= 36000.0) || atm[index][cadangan] < 0) {
            ResetAtmSlot(index);
            continue;
        }
        atm[index][object] = CreateDynamicObject(19324, atm[index][posx], atm[index][posy], atm[index][posz], 0.0, 0.0, atm[index][angle], 0, 0, -1);

        // coba print debug atm yang jelas
        printf("[ATM-DEBUG] ID %d | object=%d | valid=%d | pos=%.2f, %.2f, %.2f", atm[index][id], atm[index][object], IsValidDynamicObject(atm[index][object]), atm[index][posx], atm[index][posy], atm[index][posz]);
        if(!IsValidDynamicObject(atm[index][object]) || !CreateAtmLabel(index)) {
            printf("[ATM] Gagal membuat object atau 3D text label untuk ATM ID %d.", atm[index][id]);
            ResetAtmSlot(index);
            continue;
        }
        atmcount++;
    }
    AtmReady = true;
    printf("[ATM] Berhasil memuat %d ATM dari database.", atmcount);
    return 1;
}

stock bool:ExecuteAtmWrite(const query[], &insertid, &affected) {
    new Cache:result = mysql_query(g_SQL, query);
    new bool:success = mysql_errno(g_SQL) == 0 && cache_is_valid(result);
    if(success) {
        insertid = cache_insert_id();
        affected = cache_affected_rows();
    }
    if(cache_is_valid(result)) cache_delete(result);
    return success;
}

stock bool:SimpanTransaksiAtm(playerid, index, jumlah, bool:deposit) {
    if(!CanUseAtm(playerid) || index != idatmplayeruse[playerid] || jumlah <= 0 || Pemain[playerid][pId] <= 0) return false;
    new uang = GetPlayerMoney(playerid), bank = Pemain[playerid][pBank], cadanganAtm = atm[index][cadangan];
    if(deposit) {
        if(uang < jumlah || bank > cellmax - jumlah || cadanganAtm > cellmax - jumlah) return false;
    }
    else if(bank < jumlah || cadanganAtm < jumlah || uang > cellmax - jumlah) return false;
    if(!SimpanDataPemain(playerid)) return false;

    new query[512], insertid, affected;
    new uangBaru = deposit ? uang - jumlah : uang + jumlah;
    new bankBaru = deposit ? bank + jumlah : bank - jumlah;
    new cadanganBaru = deposit ? cadanganAtm + jumlah : cadanganAtm - jumlah;
    // Saldo pemain dan cadangan ATM berubah bersama, bukan disimpan terpisah
    mysql_format(g_SQL, query, sizeof query, "UPDATE Pemain AS p JOIN atm AS a ON a.id = %d SET p.uang = %d, p.bank = %d, a.cadangan = %d WHERE p.id = %d AND p.uang = %d AND p.bank = %d AND a.cadangan = %d", atm[index][id], uangBaru, bankBaru, cadanganBaru, Pemain[playerid][pId], uang, bank, cadanganAtm);
    return ExecuteAtmWrite(query, insertid, affected) && affected == 2;
}

Fungsi: CreateAtm(Float:x, Float:y, Float:z, Float:a) {
    if(!AtmReady || atmcount >= MAX_ATM || !ValidWorldPosition(x + 2.0, y, z) || !(a >= -36000.0 && a <= 36000.0)) return 0;
    new index = atmcount;
    ResetAtmSlot(index);
    atm[index][posx] = x + 2.0;
    atm[index][posy] = y;
    atm[index][posz] = z;
    atm[index][angle] = a;
    atm[index][cadangan] = 1000000;
    atm[index][object] = CreateDynamicObject(19324, atm[index][posx], y, z, 0.0, 0.0, a, 0, 0, -1);
    if(!IsValidDynamicObject(atm[index][object]) || !CreateAtmLabel(index)) {
        ResetAtmSlot(index);
        return 0;
    }
    new query[512], insertid, affected;
    mysql_format(g_SQL, query, sizeof query, "INSERT INTO atm (posx, posy, posz, angle, cadangan) VALUES (%.6f, %.6f, %.6f, %.6f, %d)", atm[index][posx], y, z, a, atm[index][cadangan]);
    if(!ExecuteAtmWrite(query, insertid, affected) || affected != 1 || insertid <= 0) {
        ResetAtmSlot(index);
        return 0;
    }
    atm[index][id] = insertid;
    atmcount++;
    EditTextAtm(index);

    // lakukan hal yang sama untuk debug atm
    printf("[ATM-DEBUG] ID %d | object=%d | valid=%d | pos=%.2f, %.2f, %.2f", atm[index][id], atm[index][object], IsValidDynamicObject(atm[index][object]), atm[index][posx], atm[index][posy], atm[index][posz]);
    return 1;
}

Fungsi: SaveDataAtm(index) {
    if(index < 0 || index >= atmcount) return 0;
    new query[512], insertid, affected;
    mysql_format(g_SQL, query, sizeof query, "UPDATE atm SET posx = %.6f, posy = %.6f, posz = %.6f, angle = %.6f, cadangan = %d WHERE id = %d", atm[index][posx], atm[index][posy], atm[index][posz], atm[index][angle], atm[index][cadangan], atm[index][id]);
    if(!ExecuteAtmWrite(query, insertid, affected)) return 0;
    if(affected == 0) {
        mysql_format(g_SQL, query, sizeof query, "SELECT id FROM atm WHERE id = %d LIMIT 1", atm[index][id]);
        new Cache:result = mysql_query(g_SQL, query);
        new bool:exists = mysql_errno(g_SQL) == 0 && cache_is_valid(result) && cache_num_rows() == 1;
        if(cache_is_valid(result)) cache_delete(result);
        return exists;
    }
    return 1;
}

Fungsi:ResetAtmEdit(playerid) {
    new index = GetAtmIndex(playereditatm[playerid][edit_atm_id]);
    new bool:wasEditing = playereditatm[playerid][active];
    playereditatm[playerid][objid] = INVALID_STREAMER_ID;
    playereditatm[playerid][edit_atm_id] = 0;
    playereditatm[playerid][active] = false;
    if(index != -1 && AtmEditor[index] == playerid) {
        AtmEditor[index] = INVALID_PLAYER_ID;
        SetDynamicObjectPos(atm[index][object], atm[index][posx], atm[index][posy], atm[index][posz]);
        SetDynamicObjectRot(atm[index][object], 0.0, 0.0, atm[index][angle]);
    }
    if(wasEditing && IsPlayerConnected(playerid)) CancelEdit(playerid);
    return 1;
}

Fungsi: EditAtm(playerid, ATMid) {
    if(!IsPlayerAccountReady(playerid) || Admin[playerid] < 1 || !IsPlayerExterior(playerid)) return 0;
    if(PlayerEditBussines[playerid] != -1 || playereditatm[playerid][active]) return 0;
    new index = GetAtmIndex(ATMid);
    if(index == -1 || AtmEditor[index] != INVALID_PLAYER_ID || !IsPlayerInRangeOfPoint(playerid, 20.0, atm[index][posx], atm[index][posy], atm[index][posz])) return 0;
    playereditatm[playerid][objid] = atm[index][object];
    playereditatm[playerid][edit_atm_id] = ATMid;
    playereditatm[playerid][active] = true;
    AtmEditor[index] = playerid;
    if(!EditDynamicObject(playerid, atm[index][object])) {
        ResetAtmEdit(playerid);
        return 0;
    }
    return 1;
}

Fungsi: SaveEditAtm(ATMid, Float:x, Float:y, Float:z, Float:facingAngle) {
    new index = GetAtmIndex(ATMid);
    if(index == -1 || !ValidWorldPosition(x, y, z) || !(facingAngle >= -36000.0 && facingAngle <= 36000.0)) return 0;
    new Float:previous[4];
    previous[0] = atm[index][posx];
    previous[1] = atm[index][posy];
    previous[2] = atm[index][posz];
    previous[3] = atm[index][angle];
    atm[index][posx] = x;
    atm[index][posy] = y;
    atm[index][posz] = z;
    atm[index][angle] = facingAngle;
    if(!SaveDataAtm(index)) {
        atm[index][posx] = previous[0];
        atm[index][posy] = previous[1];
        atm[index][posz] = previous[2];
        atm[index][angle] = previous[3];
        return 0;
    }
    SetDynamicObjectPos(atm[index][object], x, y, z);
    SetDynamicObjectRot(atm[index][object], 0.0, 0.0, facingAngle);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, atm[index][label], E_STREAMER_X, x);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, atm[index][label], E_STREAMER_Y, y);
    Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, atm[index][label], E_STREAMER_Z, z);
    return 1;
}

public OnPlayerEditDynamicObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    if(HandleBussinesEdit(playerid, objectid, response, x, y, z)) return 1;
    if(!playereditatm[playerid][active] || playereditatm[playerid][objid] != objectid) return 1;
    if(!IsPlayerAccountReady(playerid) || Admin[playerid] < 1 || !IsPlayerExterior(playerid)) return ResetAtmEdit(playerid);
    if(response == _:EDIT_RESPONSE_FINAL) {
        if(!SaveEditAtm(playereditatm[playerid][edit_atm_id], x, y, z, rz)) SendMessageError(playerid, "Posisi ATM gagal disimpan. Posisi lama tetap digunakan.");
        else SendMessageInfo(playerid, "Berhasil mengubah dan menyimpan posisi ATM.");
        ResetAtmEdit(playerid);
    }
    else if(response == _:EDIT_RESPONSE_CANCEL) ResetAtmEdit(playerid);
    return 1;
}

Fungsi: EditTextAtm(index) {
    new msg[256], money[128];
    FormatUang(atm[index][cadangan], money);
    format(msg, sizeof msg, "[%d]\n{55ff62}[ATM]{ffffff}\nUse /atm or ALT to use atm\n{1ed030}$%s", atm[index][id], money);
    UpdateDynamic3DTextLabelText(atm[index][label], -1, msg);
    return 1;
}

stock bool:CanUseAtm(playerid) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid]) return false;
    new index = idatmplayeruse[playerid];
    if(!AtmReady || index < 0 || index >= atmcount || !IsValidDynamicObject(atm[index][object]) || !IsPlayerExterior(playerid) || AtmEditor[index] != INVALID_PLAYER_ID || !IsPlayerInRangeOfPoint(playerid, 3.0, atm[index][posx], atm[index][posy], atm[index][posz])) {
        SendMessageError(playerid, "ATM tidak tersedia atau kamu terlalu jauh dari ATM.");
        return false;
    }
    return true;
}

stock GetNearbyAtm(playerid) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid] || !AtmReady || !IsPlayerExterior(playerid)) return -1;
    for(new i = 0; i < atmcount; i++) {
        if(IsValidDynamicObject(atm[i][object]) && AtmEditor[i] == INVALID_PLAYER_ID && IsPlayerInRangeOfPoint(playerid, 3.0, atm[i][posx], atm[i][posy], atm[i][posz])) return i;
    }
    return -1;
}

Fungsi: PlayerUseAtm(playerid) {
    idatmplayeruse[playerid] = GetNearbyAtm(playerid);
    if(idatmplayeruse[playerid] == -1) return SendMessageError(playerid, "Kamu tidak berada di dekat ATM.");
    new judul[64], money[32];
    FormatUang(Pemain[playerid][pBank], money);
    format(judul, sizeof judul, "%s - $%s", Pemain[playerid][pNama], money);
    Dialog_Show(playerid, ATMDialog, DIALOG_STYLE_LIST, judul, "Deposit\nWithdraw\nTransfer", "Pilih", "Batal");
    return 1;
}

stock DestroyAllAtm() {
    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++) ResetAtmEdit(playerid);
    for(new i = 0; i < atmcount; i++) ResetAtmSlot(i);
    atmcount = 0;
    AtmReady = false;
    return 1;
}

Dialog:ATMDialog(playerid, response, listitem, const inputtext[]) {
    if(response == 0) {
        return 1;
    }
    if(!CanUseAtm(playerid)) return 1;

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

    // transfer
    if(listitem == 2) {
        Dialog_Show(playerid, Transfer_NO_ATM, DIALOG_STYLE_INPUT, "Transfer", "Masukkan nomor rekening tujuan.", "Enter", "Batal");
        return 1;
    }

    return 1;
}

Dialog:DepositATM(playerid, response, listitem, const inputtext[]) {
    if(response == 0) {
        return 1;
    }
    if(!CanUseAtm(playerid)) return 1;

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

    if(!ValidUnsignedInteger(inputtext)) return SendMessageError(playerid, "Nominal melebihi batas saldo!");
    new jumlah = strval(inputtext);

    if(jumlah <= 0) return SendMessageError(playerid, "Nominal deposit harus lebih dari 0!");

    if(jumlah > GetPlayerMoney(playerid)) return SendMessageError(playerid, "Uangmu tidak cukup!");
    new index = idatmplayeruse[playerid];
    if(Pemain[playerid][pBank] > 2147483647 - jumlah || atm[index][cadangan] > 2147483647 - jumlah) return SendMessageError(playerid, "Nominal melebihi batas saldo!");
    if(!SimpanTransaksiAtm(playerid, index, jumlah, true)) return SendMessageError(playerid, "Transaksi gagal disimpan. Silakan coba lagi.");
    atm[index][cadangan] += jumlah;

    GivePlayerMoney(playerid, -jumlah);
    Pemain[playerid][pUang] = GetPlayerMoney(playerid);
    Pemain[playerid][pBank] += jumlah;

    EditTextAtm(idatmplayeruse[playerid]);

    SendMessageInfo(playerid, "Sukses mendepositkan uang!");

    return 1;
}


Dialog:WithdrawATM(playerid, response, listitem, const inputtext[]) {
    if(response == 0) {
        return 1;
    }
    if(!CanUseAtm(playerid)) return 1;

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

    if(!ValidUnsignedInteger(inputtext)) return SendMessageError(playerid, "Nominal melebihi batas saldo!");
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
    if(GetPlayerMoney(playerid) > 2147483647 - jumlah) return SendMessageError(playerid, "Nominal melebihi batas saldo!");
    new index = idatmplayeruse[playerid];
    if(!SimpanTransaksiAtm(playerid, index, jumlah, false)) return SendMessageError(playerid, "Transaksi gagal disimpan. Silakan coba lagi.");
    atm[index][cadangan] -= jumlah;

    Pemain[playerid][pBank] -= jumlah;
    GivePlayerMoney(playerid, jumlah);
    Pemain[playerid][pUang] = GetPlayerMoney(playerid);

    EditTextAtm(idatmplayeruse[playerid]);

    SendMessageInfo(playerid, "Sukses menarik uang dari bank!");

    return 1;
}

new norek_atm_masukkan[MAX_PLAYERS];

Dialog:Transfer_NO_ATM(playerid, response, listitem, const inputtext[]) {
    if(response == 0) {
        return 1;
    }
    if(!CanUseAtm(playerid)) return 1;

    new length = strlen(inputtext);

    if(length < 1) {
        SendMessageError(playerid, "Input harus lebih dari 0 karakter!");
        Dialog_Show(playerid, Transfer_NO_ATM, DIALOG_STYLE_INPUT, "Transfer", "Masukkan nomor rekening tujuan.", "Enter", "Batal");
        return 1;
    }

    for(new i = 0; i < length; i++) {
        if(inputtext[i] < '0' || inputtext[i] > '9') {
            SendMessageError(playerid, "Input harus berupa angka!");
            Dialog_Show(playerid, Transfer_NO_ATM, DIALOG_STYLE_INPUT, "Transfer", "Masukkan nomor rekening tujuan.", "Enter", "Batal");
            return 1;
        }
    }

    if(!ValidUnsignedInteger(inputtext) || strval(inputtext) <= 0) return SendMessageError(playerid, "Nomor rekening tidak valid!");
    norek_atm_masukkan[playerid] = strval(inputtext);

    if(norek_atm_masukkan[playerid] == Pemain[playerid][pNorek]) {
        SendMessageError(playerid, "Tidak bisa transfer ke rekening sendiri!");
        Dialog_Show(playerid, Transfer_NO_ATM, DIALOG_STYLE_INPUT, "Transfer", "Masukkan nomor rekening tujuan.", "Enter", "Batal");
        return 1;
    }

    Dialog_Show(playerid, Transfer_Jum_ATM, DIALOG_STYLE_INPUT, "Transfer", "Masukkan jumlah uang yang ingin ditransfer.", "Enter", "Batal");

    return 1;
}

Dialog:Transfer_Jum_ATM(playerid, response, listitem, const inputtext[]) {
    if(response == 0) {
        return 1;
    }
    if(!CanUseAtm(playerid)) return 1;

    new length = strlen(inputtext);

    if(length < 1) {
        SendMessageError(playerid, "Input harus lebih dari 0 karakter!");
        Dialog_Show(playerid, Transfer_Jum_ATM, DIALOG_STYLE_INPUT, "Transfer", "Masukkan jumlah uang yang ingin ditransfer.", "Enter", "Batal");
        return 1;
    }

    for(new i = 0; i < length; i++) {
        if(inputtext[i] < '0' || inputtext[i] > '9') {
            SendMessageError(playerid, "Input harus berupa angka!");
            Dialog_Show(playerid, Transfer_Jum_ATM, DIALOG_STYLE_INPUT, "Transfer", "Masukkan jumlah uang yang ingin ditransfer.", "Enter", "Batal");
            return 1;
        }
    }

    if(!ValidUnsignedInteger(inputtext)) return SendMessageError(playerid, "Nominal melebihi batas saldo!");
    new jumlah = strval(inputtext);

    if(jumlah > Pemain[playerid][pBank]) return SendMessageError(playerid, "Uang di rekening mu tidak cukup!");
    if(jumlah < 1) return SendMessageError(playerid, "Jumlah tidak boleh kurang dari 0!");

    if(norek_atm_masukkan[playerid] <= 0 || norek_atm_masukkan[playerid] == Pemain[playerid][pNorek]) return SendMessageError(playerid, "Tidak bisa transfer ke rekening sendiri!");
    new target = INVALID_PLAYER_ID;
    foreach(new i : Player) {
        if(!IsPlayerAccountReady(i) || Pemain[i][pNorek] != norek_atm_masukkan[playerid]) continue;
        if(target != INVALID_PLAYER_ID) return SendMessageError(playerid, "Nomor rekening terdaftar lebih dari sekali. Silakan hubungi admin.");
        target = i;
    }
    if(target == INVALID_PLAYER_ID) return SendMessageError(playerid, "Rekening tujuan tidak ditemukan atau pemiliknya sedang offline.");
    if(Pemain[target][pBank] > 2147483647 - jumlah) return SendMessageError(playerid, "Saldo rekening tujuan melebihi batas!");
    if(!SimpanTransferPemain(playerid, target, jumlah, true)) return SendMessageError(playerid, "Transaksi gagal disimpan. Silakan coba lagi.");
    Pemain[target][pBank] += jumlah;
    Pemain[playerid][pBank] -= jumlah;
    new msg[256], jumlahstring[128];
    FormatUang(jumlah, jumlahstring);
    format(msg, sizeof msg, "{00EBFF}[INFO]{FFFFFF} %s telah mentransfer $%s ke rekening mu.", Pemain[playerid][pNama], jumlahstring);
    SendClientMessage(target, -1, msg);
    SendMessageInfo(playerid, "Sukses mentransfer uang!");
    norek_atm_masukkan[playerid] = -1;

    return 1;
}
