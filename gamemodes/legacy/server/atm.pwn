// atm

forward OnATMLoaded();

LoadATM()
{
    mysql_tquery(g_SQL, "SELECT * FROM atm", "OnATMLoaded");
}

public OnATMLoaded()
{
    new rows = cache_num_rows();
    ATMCount = 0;

    for(new i = 0; i < rows; i++)
    {
        ATMID[i] = cache_get_value_int(i, "id");
        ATMPos[i][0] = cache_get_value_float(i, "posx");
        ATMPos[i][1] = cache_get_value_float(i, "posy");
        ATMPos[i][2] = cache_get_value_float(i, "posz");
        ATMPos[i][3] = cache_get_value_float(i, "angle");

        ATMObject[i] = CreateDynamicObject(19324,
            ATMPos[i][0], ATMPos[i][1], ATMPos[i][2],
            0.0, 0.0, ATMPos[i][3]
        );

        ATMCount++;
    }
    printf("[ATM] %d ATM berhasil diload.", ATMCount);
}

forward OnATMCreated(Float:x, Float:y, Float:z, Float:a);
public OnATMCreated(Float:x, Float:y, Float:z, Float:a)
{
    new id = cache_insert_id();

    ATMID[ATMCount] = id;
    ATMPos[ATMCount][0] = x;
    ATMPos[ATMCount][1] = y;
    ATMPos[ATMCount][2] = z;
    ATMPos[ATMCount][3] = a;

    ATMObject[ATMCount] = CreateDynamicObject(19324, x,y,z, 0.0,0.0,a);

    ATMCount++;
    printf("[ATM] ATM baru dibuat ID %d", id);
}