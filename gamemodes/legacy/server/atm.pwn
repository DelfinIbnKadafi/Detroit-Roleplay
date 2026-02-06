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