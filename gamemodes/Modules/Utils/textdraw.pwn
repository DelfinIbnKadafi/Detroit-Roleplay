// variable td
new Text:Nama_Server[2];
new Text:BACKGROUND_STATS[3];
new PlayerText:HUNGER[MAX_PLAYERS];
new PlayerText:ENERGY[MAX_PLAYERS];

LoadTd()
{
    // Nama server
    Nama_Server[0] = TextDrawCreate(306.000, 4.000, "D");
    TextDrawLetterSize(Nama_Server[0], 0.849, 4.199);
    TextDrawAlignment(Nama_Server[0], 1);
    TextDrawColor(Nama_Server[0], -764862721);
    TextDrawSetShadow(Nama_Server[0], 1);
    TextDrawSetOutline(Nama_Server[0], 1);
    TextDrawBackgroundColor(Nama_Server[0], 150);
    TextDrawFont(Nama_Server[0], 0);
    TextDrawSetProportional(Nama_Server[0], 1);

    Nama_Server[1] = TextDrawCreate(294.000, 31.000, "Roleplay");
    TextDrawLetterSize(Nama_Server[1], 0.369, 1.999);
    TextDrawAlignment(Nama_Server[1], 1);
    TextDrawColor(Nama_Server[1], -1);
    TextDrawSetShadow(Nama_Server[1], 1);
    TextDrawSetOutline(Nama_Server[1], 1);
    TextDrawBackgroundColor(Nama_Server[1], 150);
    TextDrawFont(Nama_Server[1], 1);
    TextDrawSetProportional(Nama_Server[1], 1);
    // End of Nama server
    
    // Stats player
    BACKGROUND_STATS[0] = TextDrawCreate(571.000, 385.000, "LD_SPAC:white");
    TextDrawTextSize(BACKGROUND_STATS[0], 79.000, 78.000);
    TextDrawAlignment(BACKGROUND_STATS[0], 1);
    TextDrawColor(BACKGROUND_STATS[0], 150);
    TextDrawSetShadow(BACKGROUND_STATS[0], 0);
    TextDrawSetOutline(BACKGROUND_STATS[0], 0);
    TextDrawBackgroundColor(BACKGROUND_STATS[0], 255);
    TextDrawFont(BACKGROUND_STATS[0], 4);
    TextDrawSetProportional(BACKGROUND_STATS[0], 1);
    
    BACKGROUND_STATS[1] = TextDrawCreate(573.000, 389.000, "HUD:radar_burgerShot");
    TextDrawTextSize(BACKGROUND_STATS[1], 30.000, 30.000);
    TextDrawAlignment(BACKGROUND_STATS[1], 1);
    TextDrawColor(BACKGROUND_STATS[1], -1);
    TextDrawSetShadow(BACKGROUND_STATS[1], 0);
    TextDrawSetOutline(BACKGROUND_STATS[1], 0);
    TextDrawBackgroundColor(BACKGROUND_STATS[1], 255);
    TextDrawFont(BACKGROUND_STATS[1], 4);
    TextDrawSetProportional(BACKGROUND_STATS[1], 1);
    
    BACKGROUND_STATS[2] = TextDrawCreate(579.000, 422.000, "HUD:radar_diner");
    TextDrawTextSize(BACKGROUND_STATS[2], 19.000, 20.000);
    TextDrawAlignment(BACKGROUND_STATS[2], 1);
    TextDrawColor(BACKGROUND_STATS[2], -1);
    TextDrawSetShadow(BACKGROUND_STATS[2], 0);
    TextDrawSetOutline(BACKGROUND_STATS[2], 0);
    TextDrawBackgroundColor(BACKGROUND_STATS[2], 255);
    TextDrawFont(BACKGROUND_STATS[2], 4);
    TextDrawSetProportional(BACKGROUND_STATS[2], 1);
    
    // End of Stats player
    
}

LoadPlayerTd(playerid)
{
	HUNGER[playerid] = CreatePlayerTextDraw(playerid, 603.000, 398.000, "100");
    PlayerTextDrawLetterSize(playerid, HUNGER[playerid], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, HUNGER[playerid], 1);
    PlayerTextDrawColor(playerid, HUNGER[playerid], -1);
    PlayerTextDrawSetShadow(playerid, HUNGER[playerid], 1);
    PlayerTextDrawSetOutline(playerid, HUNGER[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, HUNGER[playerid], 150);
    PlayerTextDrawFont(playerid, HUNGER[playerid], 1);
    PlayerTextDrawSetProportional(playerid, HUNGER[playerid], 1);
    
    ENERGY[playerid] = CreatePlayerTextDraw(playerid, 603.000, 425.000, "100");
    PlayerTextDrawLetterSize(playerid, ENERGY[playerid], 0.300, 1.500);
    PlayerTextDrawAlignment(playerid, ENERGY[playerid], 1);
    PlayerTextDrawColor(playerid, ENERGY[playerid], -1);
    PlayerTextDrawSetShadow(playerid, ENERGY[playerid], 1);
    PlayerTextDrawSetOutline(playerid, ENERGY[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, ENERGY[playerid], 150);
    PlayerTextDrawFont(playerid, ENERGY[playerid], 1);
    PlayerTextDrawSetProportional(playerid, ENERGY[playerid], 1);
}