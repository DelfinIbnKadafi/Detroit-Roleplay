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

CMD:createatm(playerid)
{
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new query[256];
    format(query, sizeof(query),
    "INSERT INTO atm (posx,posy,posz,angle) VALUES (%f,%f,%f,%f)",
    x,y,z,a);
    mysql_tquery(g_SQL, query, "OnATMCreated", "ffff", x,y,z,a);
    return 1;
}

CMD:editatm(playerid, params[])
{
    new id;
    if(sscanf(params, "d", id)) return SendClientMessage(playerid, -1, "Gunakan: /editatm <id>");

    for(new i=0;i<ATMCount;i++)
    {
        if(ATMID[i] == id)
        {
            new Float:x, Float:y, Float:z, Float:a;
            GetPlayerPos(playerid, x, y, z);
            GetPlayerFacingAngle(playerid, a);

            DestroyDynamicObject(ATMObject[i]);

            ATMPos[i][0] = x;
            ATMPos[i][1] = y;
            ATMPos[i][2] = z;
            ATMPos[i][3] = a;

            ATMObject[i] = CreateDynamicObject(19324, x,y,z, 0.0,0.0,a);

            new query[256];
            format(query, sizeof(query),
            "UPDATE atm SET posx=%f,posy=%f,posz=%f,angle=%f WHERE id=%d",
            x,y,z,a,id);
            mysql_tquery(g_SQL, query);

            SendClientMessage(playerid, -1, "ATM berhasil dipindahkan.");
            return 1;
        }
    }
    return SendClientMessage(playerid, -1, "ATM ID tidak ditemukan.");
}