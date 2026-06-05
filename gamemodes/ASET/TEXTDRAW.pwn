/*
jun52011 (discord) hbe textdraw creator
*/

new Text:BACKROUNd_HBE[10];
new PlayerText:HBE_LAPAR[MAX_PLAYERS];
new PlayerText:HBE_HAUS[MAX_PLAYERS];
new PlayerText:HBE_NYAWA[MAX_PLAYERS];

stock LoadPlayerTextdraw(playerid) {
  HBE_LAPAR[playerid] = CreatePlayerTextDraw(playerid, 616.0, 285.0, "100");
  PlayerTextDrawLetterSize(playerid, HBE_LAPAR[playerid], 0.150, 1.000);
  PlayerTextDrawAlignment(playerid, HBE_LAPAR[playerid], TEXT_DRAW_ALIGN_LEFT);
  PlayerTextDrawColour(playerid, HBE_LAPAR[playerid], 0xD0D0D0FF);
  PlayerTextDrawSetShadow(playerid, HBE_LAPAR[playerid], 1);
  PlayerTextDrawSetOutline(playerid, HBE_LAPAR[playerid], 1);
  PlayerTextDrawBackgroundColour(playerid, HBE_LAPAR[playerid], 150);
  PlayerTextDrawFont(playerid, HBE_LAPAR[playerid], TEXT_DRAW_FONT_1);
  PlayerTextDrawSetProportional(playerid, HBE_LAPAR[playerid], true);
  
  HBE_HAUS[playerid] = CreatePlayerTextDraw(playerid, 616.0, 324.0, "100");
  PlayerTextDrawLetterSize(playerid, HBE_HAUS[playerid], 0.150, 1.000);
  PlayerTextDrawAlignment(playerid, HBE_HAUS[playerid], TEXT_DRAW_ALIGN_LEFT);
  PlayerTextDrawColour(playerid, HBE_HAUS[playerid], 0xD0D0D0FF);
  PlayerTextDrawSetShadow(playerid, HBE_HAUS[playerid], 1);
  PlayerTextDrawSetOutline(playerid, HBE_HAUS[playerid], 1);
  PlayerTextDrawBackgroundColour(playerid, HBE_HAUS[playerid], 150);
  PlayerTextDrawFont(playerid, HBE_HAUS[playerid], TEXT_DRAW_FONT_1);
  PlayerTextDrawSetProportional(playerid, HBE_HAUS[playerid], true);
  
  HBE_NYAWA[playerid] = CreatePlayerTextDraw(playerid, 616.0, 364.0, "100");
  PlayerTextDrawLetterSize(playerid, HBE_NYAWA[playerid], 0.150, 1.000);
  PlayerTextDrawAlignment(playerid, HBE_NYAWA[playerid], TEXT_DRAW_ALIGN_LEFT);
  PlayerTextDrawColour(playerid, HBE_NYAWA[playerid], 0xD0D0D0FF);
  PlayerTextDrawSetShadow(playerid, HBE_NYAWA[playerid], 1);
  PlayerTextDrawSetOutline(playerid, HBE_NYAWA[playerid], 1);
  PlayerTextDrawBackgroundColour(playerid, HBE_NYAWA[playerid], 150);
  PlayerTextDrawFont(playerid, HBE_NYAWA[playerid], TEXT_DRAW_FONT_1);
  PlayerTextDrawSetProportional(playerid, HBE_NYAWA[playerid], true);
  
  return 1;
}

stock LoadTextdraw() {
  BACKROUNd_HBE[0] = TextDrawCreate(600.000, 250.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[0], 40.000, 50.000);
  TextDrawAlignment(BACKROUNd_HBE[0], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[0], 255);
  TextDrawSetShadow(BACKROUNd_HBE[0], 0);
  TextDrawSetOutline(BACKROUNd_HBE[0], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[0], 255);
  TextDrawFont(BACKROUNd_HBE[0], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[0], true);
  
  BACKROUNd_HBE[1] = TextDrawCreate(600.000, 290.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[1], 40.000, 50.000);
  TextDrawAlignment(BACKROUNd_HBE[1], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[1], 255);
  TextDrawSetShadow(BACKROUNd_HBE[1], 0);
  TextDrawSetOutline(BACKROUNd_HBE[1], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[1], 255);
  TextDrawFont(BACKROUNd_HBE[1], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[1], true);
  
  BACKROUNd_HBE[2] = TextDrawCreate(600.000, 330.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[2], 40.000, 50.000);
  TextDrawAlignment(BACKROUNd_HBE[2], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[2], 255);
  TextDrawSetShadow(BACKROUNd_HBE[2], 0);
  TextDrawSetOutline(BACKROUNd_HBE[2], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[2], 255);
  TextDrawFont(BACKROUNd_HBE[2], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[2], true);

  BACKROUNd_HBE[3] = TextDrawCreate(603.000, 333.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[3], 34.000, 44.000);
  TextDrawAlignment(BACKROUNd_HBE[3], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[3], -2686721);
  TextDrawSetShadow(BACKROUNd_HBE[3], 0);
  TextDrawSetOutline(BACKROUNd_HBE[3], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[3], 255);
  TextDrawFont(BACKROUNd_HBE[3], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[3], true);

  BACKROUNd_HBE[4] = TextDrawCreate(603.000, 293.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[4], 34.000, 44.000);
  TextDrawAlignment(BACKROUNd_HBE[4], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[4], -2686721);
  TextDrawSetShadow(BACKROUNd_HBE[4], 0);
  TextDrawSetOutline(BACKROUNd_HBE[4], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[4], 255);
  TextDrawFont(BACKROUNd_HBE[4], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[4], true);

  BACKROUNd_HBE[5] = TextDrawCreate(603.000, 293.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[5], 34.000, 44.000);
  TextDrawAlignment(BACKROUNd_HBE[5], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[5], -2686721);
  TextDrawSetShadow(BACKROUNd_HBE[5], 0);
  TextDrawSetOutline(BACKROUNd_HBE[5], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[5], 255);
  TextDrawFont(BACKROUNd_HBE[5], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[5], true);

  BACKROUNd_HBE[6] = TextDrawCreate(603.000, 253.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[6], 34.000, 44.000);
  TextDrawAlignment(BACKROUNd_HBE[6], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[6], -2686721);
  TextDrawSetShadow(BACKROUNd_HBE[6], 0);
  TextDrawSetOutline(BACKROUNd_HBE[6], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[6], 255);
  TextDrawFont(BACKROUNd_HBE[6], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[6], true);

  BACKROUNd_HBE[7] = TextDrawCreate(610.000, 262.000, "HUD:radar_burgerShot");
  TextDrawTextSize(BACKROUNd_HBE[7], 20.000, 28.000);
  TextDrawAlignment(BACKROUNd_HBE[7], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[7], -1);
  TextDrawSetShadow(BACKROUNd_HBE[7], 0);
  TextDrawSetOutline(BACKROUNd_HBE[7], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[7], 255);
  TextDrawFont(BACKROUNd_HBE[7], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[7], true);

  BACKROUNd_HBE[8] = TextDrawCreate(610.000, 302.000, "HUD:radar_diner");
  TextDrawTextSize(BACKROUNd_HBE[8], 20.000, 25.000);
  TextDrawAlignment(BACKROUNd_HBE[8], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[8], -1);
  TextDrawSetShadow(BACKROUNd_HBE[8], 0);
  TextDrawSetOutline(BACKROUNd_HBE[8], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[8], 255);
  TextDrawFont(BACKROUNd_HBE[8], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[8], true);

  BACKROUNd_HBE[9] = TextDrawCreate(613.000, 344.000, "HUD:radar_girlfriend");
  TextDrawTextSize(BACKROUNd_HBE[9], 15.000, 25.000);
  TextDrawAlignment(BACKROUNd_HBE[9], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[9], -1);
  TextDrawSetShadow(BACKROUNd_HBE[9], 0);
  TextDrawSetOutline(BACKROUNd_HBE[9], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[9], 255);
  TextDrawFont(BACKROUNd_HBE[9], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[9], true);
  
  return 1;
}