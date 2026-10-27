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

        if(!ValidBussinesName(Bussines[index][bnames]) || !ValidBussinesPosition(Bussines[index][bx], Bussines[index][by], Bussines[index][bz]) || Bussines[index][bownerid] < 0 || Bussines[index][btype] < 0 || Bussines[index][btype] > 127 || Bussines[index][bsisa] < 0) {
            printf("[BUSSINES] Data business ID %d tidak valid, data tidak dimuat.", bussid);
            ResetBussinesSlot(index);
            continue;
        }
        if(!MakeBussinesObject(index)) {
            printf("[BUSSINES] Gagal membuat pintu atau text label business ID %d.", bussid);
            ResetBussinesSlot(index);
            continue;
        }
        Bussines[index][bactive] = true;
        BussinesCount++;
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

    // Jangan insert jika pintu atau text label gagal dibuat
    if(!MakeBussinesObject(index)) {
        ResetBussinesSlot(index);
        return -1;
    }
    new query[768], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "INSERT INTO bussines (name, ownerid, posx, posy, posz, type, stock) VALUES ('%e', 0, %.6f, %.6f, %.6f, %d, 100)", name, x, y, z, type);
    if(!ExecuteBussinesWrite(query, affected, insertid) || affected != 1 || insertid <= 0) {
        ResetBussinesSlot(index);
        return -1;
    }
    Bussines[index][bid] = insertid;
    Bussines[index][bactive] = true;
    BussinesCount++;
    UpdateBussinesObject(index);
    return index;
}

stock bool:SaveDataBussines(index, const data[BussinesData]) {
    if(!ValidBussinesIndex(index) || data[bid] != Bussines[index][bid]) return false;
    if(!ValidBussinesName(data[bnames]) || !ValidBussinesPosition(data[bx], data[by], data[bz]) || data[bownerid] < 0 || data[btype] < 0 || data[btype] > 127 || data[bsisa] < 0) return false;

    new query[1024], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "UPDATE bussines SET name = '%e', ownerid = %d, posx = %.6f, posy = %.6f, posz = %.6f, type = %d, stock = %d WHERE id = %d", data[bnames], data[bownerid], data[bx], data[by], data[bz], data[btype], data[bsisa], data[bid]);
    if(!ExecuteBussinesWrite(query, affected, insertid)) return false;
    if(affected == 0 && !BussinesExists(data[bid])) return false;

    // Data lama tetap dipakai jika query gagal
    Bussines[index] = data;
    if(!UpdateBussinesObject(index)) printf("[BUSSINES] Data ID %d tersimpan, tetapi pintu atau text label gagal diperbarui.", data[bid]);
    return true;
}

stock bool:DeleteBussines(index) {
    if(!ValidBussinesIndex(index) || BussinesEditor[index] != INVALID_PLAYER_ID) return false;
    new query[128], affected, insertid;
    mysql_format(g_SQL, query, sizeof query, "DELETE FROM bussines WHERE id = %d", Bussines[index][bid]);
    if(!ExecuteBussinesWrite(query, affected, insertid) || affected != 1) return false;
    ResetBussinesSlot(index);
    BussinesCount--;
    return true;
}
