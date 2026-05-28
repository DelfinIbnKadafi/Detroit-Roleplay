CMD:koordinat(playerid)
{
    new Float:posX, Float:posY, Float:posZ, Float:posA;

    GetPlayerPos(playerid, posX, posY, posZ);
    GetPlayerFacingAngle(playerid, posA);

    new str[144];
    format(str, sizeof(str),
        "X: %.2f | Y: %.2f | Z: %.2f | Angle: %.2f",
        posX, posY, posZ, posA
    );

    SendClientMessage(playerid, 0xFFFFFFFF, str);
    return 1;
}