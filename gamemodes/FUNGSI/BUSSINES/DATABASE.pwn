Fungsi: LoadBusiness() {
    if(BusinessReady) return 1;

    new baris = cache_num_rows();
    for(new i = 0; i < baris; i++) {
        new index = GetFreeBusinessSlot(), bussid;
        if(index == -1) {
            printf("[Business] Batas %d business tercapai, sisa data tidak dimuat.", MAX_Business);
            break;
        }
        cache_get_value_name_int(i, "id", bussid);
        if(bussid <= 0 || GetBusinessIndex(bussid) != -1) continue;

        Business[index][bid] = bussid;
        cache_get_value_name_int(i, "ownerid", Business[index][bownerid]);
        cache_get_value_name_float(i, "posx", Business[index][bx]);
        cache_get_value_name_float(i, "posy", Business[index][by]);
        cache_get_value_name_float(i, "posz", Business[index][bz]);
        cache_get_value_name_int(i, "type", Business[index][btype]);
        cache_get_value_name_int(i, "stock", Business[index][bsisa]);
        cache_get_value_name(i, "name", Business[index][bnames], MAX_Business_NAME + 1);
        cache_get_value_name(i, "ownername", Business[index][bownername], MAX_PLAYER_NAME + 1);
        cache_get_value_name_int(i, "price", Business[index][bprice]);
        cache_get_value_name_int(i, "interior", Business[index][binterior]);

        if(!ValidBusinessName(Business[index][bnames]) || !ValidBusinessPosition(Business[index][bx], Business[index][by], Business[index][bz]) || Business[index][bownerid] < 0 || Business[index][btype] < 0 || Business[index][btype] > 127 || Business[index][bsisa] < 0) {
            printf("[Business] Data business ID %d tidak valid, data tidak dimuat.", bussid);
            ResetBusinessSlot(index);
            continue;
        }
        new Float:interiorx, Float:interiory, Float:interiorz;
        if(!GetBusinessInteriorPosition(Business[index][binterior], interiorx, interiory, interiorz)) {
            Business[index][binterior] = GetBusinessTypeInterior(Business[index][btype]);
            new fixquery[96];
            mysql_format(g_SQL, fixquery, sizeof fixquery, "UPDATE bussines SET interior = %d WHERE id = %d", Business[index][binterior], bussid);
            mysql_tquery(g_SQL, fixquery);
            printf("[Business] Interior business ID %d diperbaiki menjadi %d.", bussid, Business[index][binterior]);
        }
        if(!MakeBusinessObject(index)) {
            printf("[Business] Gagal membuat pintu atau text label business ID %d.", bussid);
            ResetBusinessSlot(index);
            continue;
        }
        ActivateBusinessSlot(index);
        printf("Berhasil meload Business id %d", bussid);
    }
    BusinessReady = true;
    printf("[Business] Berhasil memuat %d business dari database.", BusinessCount);

    MakeBusinessInteriorItem();

    return 1;
}

stock bool:ExecuteBusinessWrite(const query[], &affected, &insertid) {
    new Cache:result = mysql_query(g_SQL, query);
    new error = mysql_errno(g_SQL);
    if(error != 0 || !cache_is_valid(result)) {
        printf("[Business] Gagal menyimpan data ke database. (#%d)", error);
        if(cache_is_valid(result)) cache_delete(result);
        return false;
    }
    affected = cache_affected_rows();
    insertid = cache_insert_id();
    cache_delete(result);
    return true;
}

stock bool:BusinessExists(bussid) {
    new query[128];
    mysql_format(g_SQL, query, sizeof query, "SELECT id FROM bussines WHERE id = %d LIMIT 1", bussid);
    new Cache:result = mysql_query(g_SQL, query);
    new bool:exists = mysql_errno(g_SQL) == 0 && cache_is_valid(result) && cache_num_rows() == 1;
    if(cache_is_valid(result)) cache_delete(result);
    return exists;
}

stock bool:GetBusinessOwnerName(ownerid, output[], size) {
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

stock CreateBusiness(const name[], type, Float:x, Float:y, Float:z) {
    if(!BusinessReady || !ValidBusinessName(name) || type < 0 || type > 127 || !ValidBusinessPosition(x, y, z)) return -1;
    new index = GetFreeBusinessSlot();
    if(index == -1) return -1;

    format(Business[index][bnames], MAX_Business_NAME + 1, "%s", name);
    format(Business[index][bownername], MAX_PLAYER_NAME + 1, "None");
    Business[index][bownerid] = 0;
    Business[index][btype] = type;
    Business[index][bsisa] = 100;
    Business[index][bx] = x;
    Business[index][by] = y;
    Business[index][bz] = z;
    Business[index][bprice] = Business_DEFAULT_PRICE;

    // semua type business memakai interior sesuai GetBusinessTypeInterior
    Business[index][binterior] = GetBusinessTypeInterior(type);

    // Jangan insert jika pintu atau text label gagal dibuat
    if(!MakeBusinessObject(index)) {
        ResetBusinessSlot(index);
        return -1;
    }
    new query[768], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "INSERT INTO bussines (name, ownerid, posx, posy, posz, type, stock, price, interior) VALUES ('%e', 0, %.6f, %.6f, %.6f, %d, 100, %d, %d)", name, x, y, z, type, Business_DEFAULT_PRICE, Business[index][binterior]);
    if(!ExecuteBusinessWrite(query, affected, insertid) || affected != 1 || insertid <= 0) {
        ResetBusinessSlot(index);
        return -1;
    }
    Business[index][bid] = insertid;
    ActivateBusinessSlot(index);
    UpdateBusinessObject(index);
    return index;
}

stock bool:SaveDataBusiness(index, const data[BusinessData]) {
    if(!ValidBusinessIndex(index) || data[bid] != Business[index][bid]) return false;
    if(!ValidBusinessName(data[bnames]) || !ValidBusinessPosition(data[bx], data[by], data[bz]) || data[bownerid] < 0 || data[btype] < 0 || data[btype] > 127 || data[bsisa] < 0 || data[bprice] < 0) return false;
    new Float:interiorx, Float:interiory, Float:interiorz;
    if(!GetBusinessInteriorPosition(data[binterior], interiorx, interiory, interiorz)) return false;

    new query[1024], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "UPDATE bussines SET name = '%e', ownerid = %d, posx = %.6f, posy = %.6f, posz = %.6f, type = %d, stock = %d, price = %d, interior = %d WHERE id = %d", data[bnames], data[bownerid], data[bx], data[by], data[bz], data[btype], data[bsisa], data[bprice], data[binterior], data[bid]);
    if(!ExecuteBusinessWrite(query, affected, insertid)) return false;
    if(affected == 0 && !BusinessExists(data[bid])) return false;

    // Player yang sedang berada di interior lama harus dikeluarkan sebelum interior business berubah
    if(data[binterior] != Business[index][binterior]) KeluarkanPemainDariBusiness(index);

    // Data lama tetap dipakai jika query gagal
    Business[index] = data;
    if(!UpdateBusinessObject(index)) printf("[Business] Data ID %d tersimpan, tetapi pintu atau text label gagal diperbarui.", data[bid]);
    return true;
}

stock bool:DeleteBusiness(index) {
    if(!ValidBusinessIndex(index) || BusinessEditor[index] != INVALID_PLAYER_ID) return false;
    new query[256], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "DELETE FROM bussines WHERE id = %d", Business[index][bid]);
    if(!ExecuteBusinessWrite(query, affected, insertid) || affected != 1) return false;

    // Player online di dalam business dipindahkan ke pintu luar agar tidak terjebak tanpa pintu keluar
    KeluarkanPemainDariBusiness(index);

    // Player offline yang terakhir tersimpan di dalam business ini juga dipindahkan ke pintu luar
    mysql_format(g_SQL, query, sizeof query, "UPDATE Pemain SET posx = %.6f, posy = %.6f, posz = %.6f, interior = 0, virtualworld = 0 WHERE virtualworld = %d AND interior = %d", Business[index][bx], Business[index][by], Business[index][bz], Business[index][bid], Business[index][binterior]);
    if(!ExecuteBusinessWrite(query, affected, insertid)) printf("[Business] Gagal memindahkan posisi tersimpan player dari business ID %d.", Business[index][bid]);

    ResetBusinessSlot(index);
    BusinessCount--;
    return true;
}

// mengubah owner business di memori lalu memperbarui text label
// hanya dipanggil setelah kepemilikan berhasil tersimpan di database
stock PindahkanKepemilikanBusiness(bussindex, playerid) {
    if(!ValidBusinessIndex(bussindex) || !IsPlayerAccountReady(playerid)) return 0;

    Business[bussindex][bownerid] = Pemain[playerid][pId];
    format(Business[bussindex][bownername], MAX_PLAYER_NAME + 1, "%s", Pemain[playerid][pNama]);
    if(!UpdateBusinessObject(bussindex)) printf("[Business] Business ID %d berpindah owner, tetapi pintu atau text label gagal diperbarui.", Business[bussindex][bid]);

    return 1;
}

// menyimpan pembelian dalam satu query: uang player berkurang dan owner business berubah bersamaan
// query hanya berhasil jika business masih tanpa owner dan harganya belum berubah
stock bool:SimpanPembelianBusiness(playerid, bussindex) {
    if(!IsPlayerAccountReady(playerid) || !ValidBusinessIndex(bussindex) || Pemain[playerid][pId] <= 0) return false;
    new harga = Business[bussindex][bprice], uang = GetPlayerMoney(playerid);
    if(harga <= 0 || uang < harga) return false;

    // Samakan uang di database dengan uang di game sebelum transaksi
    if(!SimpanDataPemain(playerid)) return false;

    new query[512];
    mysql_format(g_SQL, query, sizeof query, "UPDATE Pemain AS pm JOIN bussines AS bs ON bs.id = %d SET pm.uang = %d, bs.ownerid = pm.id WHERE pm.id = %d AND pm.uang = %d AND bs.ownerid = 0 AND bs.price = %d", Business[bussindex][bid], uang - harga, Pemain[playerid][pId], uang, harga);
    new Cache:result = mysql_query(g_SQL, query);
    new bool:saved = mysql_errno(g_SQL) == 0 && cache_is_valid(result) && cache_affected_rows() == 2;
    if(cache_is_valid(result)) cache_delete(result);
    return saved;
}

stock BuyBusiness(playerid) {
    if(!IsPlayerAccountReady(playerid) || PlayerDeath[playerid]) return 0;
    if(!BusinessReady) return SendMessageError(playerid, "Data business belum selesai dimuat. Silakan coba lagi.");
    if(IsPlayerInAnyVehicle(playerid)) return SendMessageError(playerid, "Turun dari kendaraan terlebih dahulu.");
    if(!IsPlayerExterior(playerid)) return SendMessageError(playerid, "Business hanya bisa dibeli dari luar bangunan.");

    new index = GetNearbyBusinessIndex(playerid, 2.0);
    if(index == -1) return SendMessageError(playerid, "Kamu tidak berada di dekat pintu business manapun!");
    if(Business[index][bownerid] != 0) return SendMessageError(playerid, "Business ini sudah dimiliki oleh orang lain!");
    if(BusinessEditor[index] != INVALID_PLAYER_ID) return SendMessageError(playerid, "Business ini sedang diedit oleh admin.");
    if(Business[index][bprice] <= 0) return SendMessageError(playerid, "Business ini sedang tidak dijual.");
    if(GetPlayerMoney(playerid) < Business[index][bprice]) return SendMessageError(playerid, "Uangmu tidak cukup!");

    new harga = Business[index][bprice];
    if(!SimpanPembelianBusiness(playerid, index)) return SendMessageError(playerid, "Pembelian gagal diproses. Uangmu tidak berkurang, silakan coba lagi.");

    GivePlayerMoney(playerid, -harga);
    Pemain[playerid][pUang] = GetPlayerMoney(playerid);
    PindahkanKepemilikanBusiness(index, playerid);

    new msg[144], moneysss[32];
    FormatUang(harga, moneysss);
    format(msg, sizeof msg, "{00EBFF}[INFO]{FFFFFF} Kamu berhasil membeli business ID %d seharga {55FF62}$%s{FFFFFF}.", Business[index][bid], moneysss);
    SendClientMessage(playerid, 0xFFFFFFFF, msg);

    ShowChangeNamaBusiness(playerid, index);
    SheylaCantikImutBanget[playerid] = index;

    return 1;
}