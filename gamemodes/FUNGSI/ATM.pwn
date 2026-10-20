enum atmdata {
    object,
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

Fungsi: LoadAtm() {

    atmcount = 0;

    new baris;
    cache_get_row_count(baris);

    if(cache_num_rows() > 0) {
        for(new i = 0; i < baris; i++) {
            atmcount++;
            cache_get_value_name_int(i, "id", atm[atmcount][id]);
            cache_get_value_name_float(i, "posx", atm[atmcount][posx]);
            cache_get_value_name_float(i, "posy", atm[atmcount][posy]);
            cache_get_value_name_float(i, "posz", atm[atmcount][posz]);
            cache_get_value_name_float(i, "angle", atm[atmcount][angle]);
            cache_get_value_name_int(i, "cadangan", atm[atmcount][cadangan]);

            atm[atmcount][object] = CreateObject(19324, atm[atmcount][posx], atm[atmcount][posy], atm[atmcount][posz], atm[atmcount][angle], 90, 90);

            continue;
        }
    }

    return 1;
}