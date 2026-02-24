ProxDetector(Float:radius, playerid, const text[])
{
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    foreach (new i : Player)
    {
        new Float:d = GetPlayerDistanceFromPoint(i, px, py, pz);

        if (d <= radius / 4)
            SendClientMessage(i, 0xFFFFFFFF, text);
        else if (d <= radius / 2)
            SendClientMessage(i, 0xDDDDDDFF, text);
        else if (d <= radius)
            SendClientMessage(i, 0xAAAAAAFF, text);
    }
}
