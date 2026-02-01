//===[CALLBACK SEND MESSAGE]===//
public SendMessageError(playerid, const text[])
{
    new msg[144];
    format(msg, sizeof(msg), "{FF0000}[ERROR]{FFFFFF} %s", text);
    SendClientMessage(playerid, 0xFFFFFF, msg);
    return 1;
}

public SendMessageServer(playerid, const text[])
{
    new msg[144];
    format(msg, sizeof(msg), "{00EBFF}[SERVER]{FFFFFF} %s", text);
    SendClientMessage(playerid, 0xFFFFFF, msg);
    return 1;
}

public SendMessageInfo(playerid, const text[])
{
    new msg[144];
    format(msg, sizeof(msg), "{00EBFF}[INFO]{FFFFFF} %s", text);
    SendClientMessage(playerid, 0xFFFFFF, msg);
    return 1;
}
//===[END SEND MESSAGE]===//
