Fungsi: LoadBussines() {
    if(BussinesReady) return 1;

    new baris = cache_num_rows();
    for(new i = 0; i < baris; i++) {
        new index = GetFreeBussinesSlot(), bussid;
        if(index == -1) {
            printf("[BUSSINES] Batas %d business tercapai, sisa data tidak dimuat.", MAX_BUSSINES);
            break;
        }
        cache_get_value_name_int(i, "id", bussid);
        if(bussid <= 0 || GetBussinesIndex(bussid) != -1) continue;

        Bussines[index][bid] = bussid;
        cache_get_value_name_int(i, "ownerid", Bussines[index][bownerid]);
        cache_get_value_name_float(i, "posx", Bussines[index][bx]);
        cache_get_value_name_float(i, "posy", Bussines[index][by]);
        cache_get_value_name_float(i, "posz", Bussines[index][bz]);
        cache_get_value_name_int(i, "type", Bussines[index][btype]);
        cache_get_value_name_int(i, "stock", Bussines[index][bsisa]);
        cache_get_value_name(i, "name", Bussines[index][bnames], MAX_BUSSINES_NAME + 1);
        cache_get_value_name(i, "ownername", Bussines[index][bownername], MAX_PLAYER_NAME + 1);
        cache_get_value_name_int(i, "price", Bussines[index][bprice]);
        cache_get_value_name_int(i, "interior", Bussines[index][binterior]);

        if(!ValidBussinesName(Bussines[index][bnames]) || !ValidBussinesPosition(Bussines[index][bx], Bussines[index][by], Bussines[index][bz]) || Bussines[index][bownerid] < 0 || Bussines[index][btype] < 0 || Bussines[index][btype] > 127 || Bussines[index][bsisa] < 0) {
            printf("[BUSSINES] Data business ID %d tidak valid, data tidak dimuat.", bussid);
            ResetBussinesSlot(index);
            continue;
        }
        new Float:interiorx, Float:interiory, Float:interiorz;
        if(!GetBusinessInteriorPosition(Bussines[index][binterior], interiorx, interiory, interiorz)) {
            Bussines[index][binterior] = GetBussinesTypeInterior(Bussines[index][btype]);
            new fixquery[96];
            mysql_format(g_SQL, fixquery, sizeof fixquery, "UPDATE bussines SET interior = %d WHERE id = %d", Bussines[index][binterior], bussid);
            mysql_tquery(g_SQL, fixquery);
            printf("[BUSSINES] Interior business ID %d diperbaiki menjadi %d.", bussid, Bussines[index][binterior]);
        }
        if(!MakeBussinesObject(index)) {
            printf("[BUSSINES] Gagal membuat pintu atau text label business ID %d.", bussid);
            ResetBussinesSlot(index);
            continue;
        }
        ActivateBussinesSlot(index);
        printf("Berhasil meload bussines id %d", bussid);
    }
    BussinesReady = true;
    printf("[BUSSINES] Berhasil memuat %d business dari database.", BussinesCount);
    return 1;
}

stock bool:ExecuteBussinesWrite(const query[], &affected, &insertid) {
    new Cache:result = mysql_query(g_SQL, query);
    new error = mysql_errno(g_SQL);
    if(error != 0 || !cache_is_valid(result)) {
        printf("[BUSSINES] Gagal menyimpan data ke database. (#%d)", error);
        if(cache_is_valid(result)) cache_delete(result);
        return false;
    }
    affected = cache_affected_rows();
    insertid = cache_insert_id();
    cache_delete(result);
    return true;
}

stock bool:BussinesExists(bussid) {
    new query[128];
    mysql_format(g_SQL, query, sizeof query, "SELECT id FROM bussines WHERE id = %d LIMIT 1", bussid);
    new Cache:result = mysql_query(g_SQL, query);
    new bool:exists = mysql_errno(g_SQL) == 0 && cache_is_valid(result) && cache_num_rows() == 1;
    if(cache_is_valid(result)) cache_delete(result);
    return exists;
}

stock bool:GetBussinesOwnerName(ownerid, output[], size) {
    if(ownerid == 0) {
        format(output, size, "None");
        return true;
    }
    if(ownerid < 0) return false;
    new query[128];
    mysql_format(g_SQL, query, sizeof query, "SELECT nama FROM Pemain WHERE id = %d LIMIT 1", ownerid);
    new Cache:result = mysql_query(g_SQL, query);
    new bool:found = mysql_errno(g_SQL) == 0 && cache_is_valid(result) && cache_num_rows() == 1;
    if(found) cache_get_value_name(0, "nama", output, size);
    if(cache_is_valid(result)) cache_delete(result);
    return found;
}

stock CreateBussines(const name[], type, Float:x, Float:y, Float:z) {
    if(!BussinesReady || !ValidBussinesName(name) || type < 0 || type > 127 || !ValidBussinesPosition(x, y, z)) return -1;
    new index = GetFreeBussinesSlot();
    if(index == -1) return -1;

    format(Bussines[index][bnames], MAX_BUSSINES_NAME + 1, "%s", name);
    format(Bussines[index][bownername], MAX_PLAYER_NAME + 1, "None");
    Bussines[index][bownerid] = 0;
    Bussines[index][btype] = type;
    Bussines[index][bsisa] = 100;
    Bussines[index][bx] = x;
    Bussines[index][by] = y;
    Bussines[index][bz] = z;
    Bussines[index][bprice] = BUSSINES_DEFAULT_PRICE;

    // semua type business memakai interior sesuai GetBussinesTypeInterior
    Bussines[index][binterior] = GetBussinesTypeInterior(type);

    // Jangan insert jika pintu atau text label gagal dibuat
    if(!MakeBussinesObject(index)) {
        ResetBussinesSlot(index);
        return -1;
    }
    new query[768], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "INSERT INTO bussines (name, ownerid, posx, posy, posz, type, stock, price, interior) VALUES ('%e', 0, %.6f, %.6f, %.6f, %d, 100, %d, %d)", name, x, y, z, type, BUSSINES_DEFAULT_PRICE, Bussines[index][binterior]);
    if(!ExecuteBussinesWrite(query, affected, insertid) || affected != 1 || insertid <= 0) {
        ResetBussinesSlot(index);
        return -1;
    }
    Bussines[index][bid] = insertid;
    ActivateBussinesSlot(index);
    UpdateBussinesObject(index);
    return index;
}

stock bool:SaveDataBussines(index, const data[BussinesData]) {
    if(!ValidBussinesIndex(index) || data[bid] != Bussines[index][bid]) return false;
    if(!ValidBussinesName(data[bnames]) || !ValidBussinesPosition(data[bx], data[by], data[bz]) || data[bownerid] < 0 || data[btype] < 0 || data[btype] > 127 || data[bsisa] < 0 || data[bprice] < 0) return false;
    new Float:interiorx, Float:interiory, Float:interiorz;
    if(!GetBusinessInteriorPosition(data[binterior], interiorx, interiory, interiorz)) return false;

    new query[1024], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "UPDATE bussines SET name = '%e', ownerid = %d, posx = %.6f, posy = %.6f, posz = %.6f, type = %d, stock = %d, price = %d, interior = %d WHERE id = %d", data[bnames], data[bownerid], data[bx], data[by], data[bz], data[btype], data[bsisa], data[bprice], data[binterior], data[bid]);
    if(!ExecuteBussinesWrite(query, affected, insertid)) return false;
    if(affected == 0 && !BussinesExists(data[bid])) return false;

    // Player yang sedang berada di interior lama harus dikeluarkan sebelum interior business berubah
    if(data[binterior] != Bussines[index][binterior]) KeluarkanPemainDariBusiness(index);

    // Data lama tetap dipakai jika query gagal
    Bussines[index] = data;
    if(!UpdateBussinesObject(index)) printf("[BUSSINES] Data ID %d tersimpan, tetapi pintu atau text label gagal diperbarui.", data[bid]);
    return true;
}

stock bool:DeleteBussines(index) {
    if(!ValidBussinesIndex(index) || BussinesEditor[index] != INVALID_PLAYER_ID) return false;
    new query[256], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "DELETE FROM bussines WHERE id = %d", Bussines[index][bid]);
    if(!ExecuteBussinesWrite(query, affected, insertid) || affected != 1) return false;

    // Player online di dalam business dipindahkan ke pintu luar agar tidak terjebak tanpa pintu keluar
    KeluarkanPemainDariBusiness(index);

    // Player offline yang terakhir tersimpan di dalam business ini juga dipindahkan ke pintu luar
    mysql_format(g_SQL, query, sizeof query, "UPDATE Pemain SET posx = %.6f, posy = %.6f, posz = %.6f, interior = 0, virtualworld = 0 WHERE virtualworld = %d AND interior = %d", Bussines[index][bx], Bussines[index][by], Bussines[index][bz], Bussines[index][bid], Bussines[index][binterior]);
    if(!ExecuteBussinesWrite(query, affected, insertid)) printf("[BUSSINES] Gagal memindahkan posisi tersimpan player dari business ID %d.", Bussines[index][bid]);

    ResetBussinesSlot(index);
    BussinesCount--;
    return true;
}

// mengubah owner business di memori lalu memperbarui text label
// hanya dipanggil setelah kepemilikan berhasil tersimpan di database
stock PindahkanKepemilikanBusiness(bussindex, playerid) {
    if(!ValidBussinesIndex(bussindex) || !IsPlayerAccountReady(playerid)) return 0;

    Bussines[bussindex][bownerid] = Pemain[playerid][pId];
    format(Bussines[bussindex][bownername], MAX_PLAYER_NAME + 1, "%s", Pemain[playerid][pNama]);
    if(!UpdateBussinesObject(bussindex)) printf("[BUSSINES] Business ID %d berpindah owner, tetapi pintu atau text label gagal diperbarui.", Bussines[bussindex][bid]);

    return 1;
}

// menyimpan pembelian dalam satu query: uang player berkurang dan owner business berubah bersamaan
// query hanya berhasil jika business masih tanpa owner dan harganya belum berubah
stock bool:SimpanPembelianBusiness(playerid, bussindex) {
    if(!IsPlayerAccountReady(playerid) || !ValidBussinesIndex(bussindex) || Pemain[playerid][pId] <= 0) return false;
    new harga = Bussines[bussindex][bprice], uang = GetPlayerMoney(playerid);
    if(harga <= 0 || uang < harga) return false;

    // Samakan uang di database dengan uang di game sebelum transaksi
    if(!SimpanDataPemain(playerid)) return false;

    new query[512];
    mysql_format(g_SQL, query, sizeof query, "UPDATE Pemain AS pm JOIN bussines AS bs ON bs.id = %d SET pm.uang = %d, bs.ownerid = pm.id WHERE pm.id = %d AND pm.uang = %d AND bs.ownerid = 0 AND bs.price = %d", Bussines[bussindex][bid], uang - harga, Pemain[playerid][pId], uang, harga);
    new Cache:result = mysql_query(g_SQL, query);
    new bool:saved = mysql_errno(g_SQL) == 0 && cache_is_valid(result) && cache_affected_rows() == 2;
    if(cache_is_valid(result)) cache_delete(result);
    return saved;
}


// temp var, the name i make random and bad, so its never can use in another file when next developer edit this, if they not see this
new SheylaCantikImutBanget[MAX_PLAYERS];

stock BuyBusiness(playerid) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid]) return 0;
    if(!BussinesReady) return SendMessageError(playerid, "Data business belum selesai dimuat. Silakan coba lagi.");
    if(IsPlayerInAnyVehicle(playerid)) return SendMessageError(playerid, "Turun dari kendaraan terlebih dahulu.");
    if(!IsPlayerExterior(playerid)) return SendMessageError(playerid, "Business hanya bisa dibeli dari luar bangunan.");

    new index = GetNearbyBussinesIndex(playerid, 2.0);
    if(index == -1) return SendMessageError(playerid, "Kamu tidak berada di dekat pintu business manapun!");
    if(Bussines[index][bownerid] != 0) return SendMessageError(playerid, "Business ini sudah dimiliki oleh orang lain!");
    if(BussinesEditor[index] != INVALID_PLAYER_ID) return SendMessageError(playerid, "Business ini sedang diedit oleh admin.");
    if(Bussines[index][bprice] <= 0) return SendMessageError(playerid, "Business ini sedang tidak dijual.");
    if(GetPlayerMoney(playerid) < Bussines[index][bprice]) return SendMessageError(playerid, "Uangmu tidak cukup!");

    new harga = Bussines[index][bprice];
    if(!SimpanPembelianBusiness(playerid, index)) return SendMessageError(playerid, "Pembelian gagal diproses. Uangmu tidak berkurang, silakan coba lagi.");

    GivePlayerMoney(playerid, -harga);
    Pemain[playerid][pUang] = GetPlayerMoney(playerid);
    PindahkanKepemilikanBusiness(index, playerid);

    new msg[144], moneysss[32];
    FormatUang(harga, moneysss);
    format(msg, sizeof msg, "{00EBFF}[INFO]{FFFFFF} Kamu berhasil membeli business ID %d seharga {55FF62}$%s{FFFFFF}.", Bussines[index][bid], moneysss);
    SendClientMessage(playerid, 0xFFFFFFFF, msg);

    ShowChangeNamaBusiness(playerid, index);
    SheylaCantikImutBanget[playerid] = index;

    return 1;
}