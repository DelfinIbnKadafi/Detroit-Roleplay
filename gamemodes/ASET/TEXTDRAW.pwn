/*
jun52011 (discord) hbe textdraw creator
*/

new Text:BACKROUNd_HBE[10];
new PlayerText:HBE_LAPAR[MAX_PLAYERS];
new PlayerText:HBE_HAUS[MAX_PLAYERS];
new PlayerText:HBE_NYAWA[MAX_PLAYERS];

new PlayerText:VehSpeed[MAX_PLAYERS];
new PlayerText:HealthVeh[MAX_PLAYERS];
new PlayerText:FuelVeh[MAX_PLAYERS];
new Text:Backround_Speedo[10];

stock LoadPlayerTextdraw(playerid) {
  // vehicle
  VehSpeed[playerid] = CreatePlayerTextDraw(playerid, 618.000, 399.000, "0 KMH");
  PlayerTextDrawLetterSize(playerid, VehSpeed[playerid], 0.300, 1.500);
  PlayerTextDrawAlignment(playerid, VehSpeed[playerid], TEXT_DRAW_ALIGN_CENTRE);
  PlayerTextDrawColour(playerid, VehSpeed[playerid], -1);
  PlayerTextDrawSetShadow(playerid, VehSpeed[playerid], 1);
  PlayerTextDrawSetOutline(playerid, VehSpeed[playerid], 1);
  PlayerTextDrawBackgroundColour(playerid, VehSpeed[playerid], 150);
  PlayerTextDrawFont(playerid, VehSpeed[playerid], TEXT_DRAW_FONT_2);
  PlayerTextDrawSetProportional(playerid, VehSpeed[playerid], true);
  
  HealthVeh[playerid] = CreatePlayerTextDraw(playerid, 616.000, 523.000, "100");
  PlayerTextDrawLetterSize(playerid, HealthVeh[playerid], 0.300, 1.500);
  PlayerTextDrawAlignment(playerid, HealthVeh[playerid], TEXT_DRAW_ALIGN_CENTRE);
  PlayerTextDrawColour(playerid, HealthVeh[playerid], -1);
  PlayerTextDrawSetShadow(playerid, HealthVeh[playerid], 1);
  PlayerTextDrawSetOutline(playerid, HealthVeh[playerid], 1);
  PlayerTextDrawBackgroundColour(playerid, HealthVeh[playerid], 150);
  PlayerTextDrawFont(playerid, HealthVeh[playerid], TEXT_DRAW_FONT_2);
  PlayerTextDrawSetProportional(playerid, HealthVeh[playerid], true);

  FuelVeh[playerid] = CreatePlayerTextDraw(playerid, 616.000, 549.000, "100");
  PlayerTextDrawLetterSize(playerid, FuelVeh[playerid], 0.300, 1.500);
  PlayerTextDrawAlignment(playerid, FuelVeh[playerid], TEXT_DRAW_ALIGN_CENTRE);
  PlayerTextDrawColour(playerid, FuelVeh[playerid], -1);
  PlayerTextDrawSetShadow(playerid, FuelVeh[playerid], 1);
  PlayerTextDrawSetOutline(playerid, FuelVeh[playerid], 1);
  PlayerTextDrawBackgroundColour(playerid, FuelVeh[playerid], 150);
  PlayerTextDrawFont(playerid, FuelVeh[playerid], TEXT_DRAW_FONT_2);
  PlayerTextDrawSetProportional(playerid, FuelVeh[playerid], true);
  
  // hbe
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
  
  // Speedo 
  Backround_Speedo[0] = TextDrawCreate(557.000, 393.000, "LD_SPAC:white");
  TextDrawTextSize(Backround_Speedo[0], 90.000, 79.000);
  TextDrawAlignment(Backround_Speedo[0], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(Backround_Speedo[0], 170);
  TextDrawSetShadow(Backround_Speedo[0], 0);
  TextDrawSetOutline(Backround_Speedo[0], 0);
  TextDrawBackgroundColour(Backround_Speedo[0], 255);
  TextDrawFont(Backround_Speedo[0], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(Backround_Speedo[0], true);

  Backround_Speedo[1] = TextDrawCreate(566.000, 396.000, "HUD:radar_impound");
  TextDrawTextSize(Backround_Speedo[1], 19.000, 19.000);
  TextDrawAlignment(Backround_Speedo[1], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(Backround_Speedo[1], -1);
  TextDrawSetShadow(Backround_Speedo[1], 0);
  TextDrawSetOutline(Backround_Speedo[1], 0);
  TextDrawBackgroundColour(Backround_Speedo[1], 255);
  TextDrawFont(Backround_Speedo[1], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(Backround_Speedo[1], true);

  Backround_Speedo[2] = TextDrawCreate(565.000, 422.000, "HUD:radar_modGarage");
  TextDrawTextSize(Backround_Speedo[2], 20.000, 20.000);
  TextDrawAlignment(Backround_Speedo[2], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(Backround_Speedo[2], -1);
  TextDrawSetShadow(Backround_Speedo[2], 0);
  TextDrawSetOutline(Backround_Speedo[2], 0);
  TextDrawBackgroundColour(Backround_Speedo[2], 255);
  TextDrawFont(Backround_Speedo[2], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(Backround_Speedo[2], true);

  Backround_Speedo[3] = TextDrawCreate(566.000, 445.000, "HUD:radar_spray");
  TextDrawTextSize(Backround_Speedo[3], 23.000, 24.000);
  TextDrawAlignment(Backround_Speedo[3], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(Backround_Speedo[3], -1);
  TextDrawSetShadow(Backround_Speedo[3], 0);
  TextDrawSetOutline(Backround_Speedo[3], 0);
  TextDrawBackgroundColour(Backround_Speedo[3], 255);
  TextDrawFont(Backround_Speedo[3], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(Backround_Speedo[3], true);

  Backround_Speedo[4] = TextDrawCreate(627.000, 448.000, "o");
  TextDrawLetterSize(Backround_Speedo[4], 0.200, 0.999);
  TextDrawAlignment(Backround_Speedo[4], TEXT_DRAW_ALIGN_CENTRE);
  TextDrawColour(Backround_Speedo[4], -1);
  TextDrawSetShadow(Backround_Speedo[4], 1);
  TextDrawSetOutline(Backround_Speedo[4], 1);
  TextDrawBackgroundColour(Backround_Speedo[4], 150);
  TextDrawFont(Backround_Speedo[4], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(Backround_Speedo[4], true);

  Backround_Speedo[5] = TextDrawCreate(630.000, 451.000, "\\");
  TextDrawLetterSize(Backround_Speedo[5], -0.329, 0.999);
  TextDrawAlignment(Backround_Speedo[5], TEXT_DRAW_ALIGN_CENTRE);
  TextDrawColour(Backround_Speedo[5], -1);
  TextDrawSetShadow(Backround_Speedo[5], 1);
  TextDrawSetOutline(Backround_Speedo[5], 1);
  TextDrawBackgroundColour(Backround_Speedo[5], 150);
  TextDrawFont(Backround_Speedo[5], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(Backround_Speedo[5], true);

  Backround_Speedo[6] = TextDrawCreate(633.000, 453.000, "o");
  TextDrawLetterSize(Backround_Speedo[6], 0.200, 0.999);
  TextDrawAlignment(Backround_Speedo[6], TEXT_DRAW_ALIGN_CENTRE);
  TextDrawColour(Backround_Speedo[6], -1);
  TextDrawSetShadow(Backround_Speedo[6], 1);
  TextDrawSetOutline(Backround_Speedo[6], 1);
  TextDrawBackgroundColour(Backround_Speedo[6], 150);
  TextDrawFont(Backround_Speedo[6], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(Backround_Speedo[6], true);

  Backround_Speedo[7] = TextDrawCreate(627.000, 422.000, "o");
  TextDrawLetterSize(Backround_Speedo[7], 0.200, 0.999);
  TextDrawAlignment(Backround_Speedo[7], TEXT_DRAW_ALIGN_CENTRE);
  TextDrawColour(Backround_Speedo[7], -1);
  TextDrawSetShadow(Backround_Speedo[7], 1);
  TextDrawSetOutline(Backround_Speedo[7], 1);
  TextDrawBackgroundColour(Backround_Speedo[7], 150);
  TextDrawFont(Backround_Speedo[7], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(Backround_Speedo[7], true);

  Backround_Speedo[8] = TextDrawCreate(630.000, 425.000, "\\");
  TextDrawLetterSize(Backround_Speedo[8], -0.329, 0.999);
  TextDrawAlignment(Backround_Speedo[8], TEXT_DRAW_ALIGN_CENTRE);
  TextDrawColour(Backround_Speedo[8], -1);
  TextDrawSetShadow(Backround_Speedo[8], 1);
  TextDrawSetOutline(Backround_Speedo[8], 1);
  TextDrawBackgroundColour(Backround_Speedo[8], 150);
  TextDrawFont(Backround_Speedo[8], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(Backround_Speedo[8], true);

  Backround_Speedo[9] = TextDrawCreate(633.000, 427.000, "o");
  TextDrawLetterSize(Backround_Speedo[9], 0.200, 0.999);
  TextDrawAlignment(Backround_Speedo[9], TEXT_DRAW_ALIGN_CENTRE);
  TextDrawColour(Backround_Speedo[9], -1);
  TextDrawSetShadow(Backround_Speedo[9], 1);
  TextDrawSetOutline(Backround_Speedo[9], 1);
  TextDrawBackgroundColour(Backround_Speedo[9], 150);
  TextDrawFont(Backround_Speedo[9], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(Backround_Speedo[9], true);
  
  // hbe
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
  TextDrawColour(BACKROUNd_HBE[3], 0xD72B3FFF);
  TextDrawSetShadow(BACKROUNd_HBE[3], 0);
  TextDrawSetOutline(BACKROUNd_HBE[3], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[3], 255);
  TextDrawFont(BACKROUNd_HBE[3], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[3], true);

  BACKROUNd_HBE[4] = TextDrawCreate(603.000, 293.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[4], 34.000, 44.000);
  TextDrawAlignment(BACKROUNd_HBE[4], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[4], 0xD72B3FFF);
  TextDrawSetShadow(BACKROUNd_HBE[4], 0);
  TextDrawSetOutline(BACKROUNd_HBE[4], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[4], 255);
  TextDrawFont(BACKROUNd_HBE[4], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[4], true);

  BACKROUNd_HBE[5] = TextDrawCreate(603.000, 293.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[5], 34.000, 44.000);
  TextDrawAlignment(BACKROUNd_HBE[5], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[5], 0xD72B3FFF);
  TextDrawSetShadow(BACKROUNd_HBE[5], 0);
  TextDrawSetOutline(BACKROUNd_HBE[5], 0);
  TextDrawBackgroundColour(BACKROUNd_HBE[5], 255);
  TextDrawFont(BACKROUNd_HBE[5], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKROUNd_HBE[5], true);

  BACKROUNd_HBE[6] = TextDrawCreate(603.000, 253.000, "LD_BEAT:chit");
  TextDrawTextSize(BACKROUNd_HBE[6], 34.000, 44.000);
  TextDrawAlignment(BACKROUNd_HBE[6], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKROUNd_HBE[6], 0xD72B3FFF);
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
