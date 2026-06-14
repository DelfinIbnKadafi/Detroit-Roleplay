// logo server 
new Text:LOGO_SERVER[3];

//  hbe
new Text:BACKGROUND_HBE[3];
new PlayerText:STATS[MAX_PLAYERS][2]; //  0 = lapar, 1 = haus

// speedo 
new Text:BACKGROUND_SPEDO[4];
new PlayerText:VEHSPEED[MAX_PLAYERS][3]; // 0 = kerusakan , 1 = fuel, 3 = speed

stock LoadPlayerTextdraw(playerid) {
  // speedo value
  VEHSPEED[playerid][0] = CreatePlayerTextDraw(playerid, 543.000, 395.000, "100");
  PlayerTextDrawLetterSize(playerid, VEHSPEED[playerid][0], 0.300, 1.500);
  PlayerTextDrawAlignment(playerid, VEHSPEED[playerid][0], TEXT_DRAW_ALIGN_LEFT);
  PlayerTextDrawColour(playerid, VEHSPEED[playerid][0], -1);
  PlayerTextDrawSetShadow(playerid, VEHSPEED[playerid][0], 1);
  PlayerTextDrawSetOutline(playerid, VEHSPEED[playerid][0], 1);
  PlayerTextDrawBackgroundColour(playerid, VEHSPEED[playerid][0], 150);
  PlayerTextDrawFont(playerid, VEHSPEED[playerid][0], TEXT_DRAW_FONT_1);
  PlayerTextDrawSetProportional(playerid, VEHSPEED[playerid][0], true);

  VEHSPEED[playerid][1] = CreatePlayerTextDraw(playerid, 542.000, 425.000, "100");
  PlayerTextDrawLetterSize(playerid, VEHSPEED[playerid][1], 0.300, 1.500);
  PlayerTextDrawAlignment(playerid, VEHSPEED[playerid][1], TEXT_DRAW_ALIGN_LEFT);
  PlayerTextDrawColour(playerid, VEHSPEED[playerid][1], -1);
  PlayerTextDrawSetShadow(playerid, VEHSPEED[playerid][1], 1);
  PlayerTextDrawSetOutline(playerid, VEHSPEED[playerid][1], 1);
  PlayerTextDrawBackgroundColour(playerid, VEHSPEED[playerid][1], 150);
  PlayerTextDrawFont(playerid, VEHSPEED[playerid][1], TEXT_DRAW_FONT_1);
  PlayerTextDrawSetProportional(playerid, VEHSPEED[playerid][1], true);

  VEHSPEED[playerid][2] = CreatePlayerTextDraw(playerid, 495.000, 402.000, "999");
  PlayerTextDrawLetterSize(playerid, VEHSPEED[playerid][2], 0.300, 1.500);
  PlayerTextDrawAlignment(playerid, VEHSPEED[playerid][2], TEXT_DRAW_ALIGN_LEFT);
  PlayerTextDrawColour(playerid, VEHSPEED[playerid][2], -1);
  PlayerTextDrawSetShadow(playerid, VEHSPEED[playerid][2], 1);
  PlayerTextDrawSetOutline(playerid, VEHSPEED[playerid][2], 1);
  PlayerTextDrawBackgroundColour(playerid, VEHSPEED[playerid][2], 150);
  PlayerTextDrawFont(playerid, VEHSPEED[playerid][2], TEXT_DRAW_FONT_1);
  PlayerTextDrawSetProportional(playerid, VEHSPEED[playerid][2], true);
  
  // hbe
  // lapar = 0
  STATS[playerid][0] = CreatePlayerTextDraw(playerid, 601.000, 398.000, "100");
  PlayerTextDrawLetterSize(playerid, STATS[playerid][0], 0.300, 1.500);
  PlayerTextDrawAlignment(playerid, STATS[playerid][0], TEXT_DRAW_ALIGN_LEFT);
  PlayerTextDrawColour(playerid, STATS[playerid][0], -1);
  PlayerTextDrawSetShadow(playerid, STATS[playerid][0], 1);
  PlayerTextDrawSetOutline(playerid, STATS[playerid][0], 1);
  PlayerTextDrawBackgroundColour(playerid, STATS[playerid][0], 150);
  PlayerTextDrawFont(playerid, STATS[playerid][0], TEXT_DRAW_FONT_1);
  PlayerTextDrawSetProportional(playerid, STATS[playerid][0], true);
  // haus = 1
  STATS[playerid][1] = CreatePlayerTextDraw(playerid, 601.000, 426.000, "100");
  PlayerTextDrawLetterSize(playerid, STATS[playerid][1], 0.300, 1.500);
  PlayerTextDrawAlignment(playerid, STATS[playerid][1], TEXT_DRAW_ALIGN_LEFT);
  PlayerTextDrawColour(playerid, STATS[playerid][1], -1);
  PlayerTextDrawSetShadow(playerid, STATS[playerid][1], 1);
  PlayerTextDrawSetOutline(playerid, STATS[playerid][1], 1);
  PlayerTextDrawBackgroundColour(playerid, STATS[playerid][1], 150);
  PlayerTextDrawFont(playerid, STATS[playerid][1], TEXT_DRAW_FONT_1);
  PlayerTextDrawSetProportional(playerid, STATS[playerid][1], true);
  ////////////////////////////////////////////////////////////////////////
  
  return 1;
}

stock LoadTextdraw() {
  // speedo backround
  BACKGROUND_SPEDO[0] = TextDrawCreate(487.000, 380.000, "LD_SPAC:white");
  TextDrawTextSize(BACKGROUND_SPEDO[0], 78.000, 137.000);
  TextDrawAlignment(BACKGROUND_SPEDO[0], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKGROUND_SPEDO[0], 150);
  TextDrawSetShadow(BACKGROUND_SPEDO[0], 0);
  TextDrawSetOutline(BACKGROUND_SPEDO[0], 0);
  TextDrawBackgroundColour(BACKGROUND_SPEDO[0], 255);
  TextDrawFont(BACKGROUND_SPEDO[0], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKGROUND_SPEDO[0], true);

  BACKGROUND_SPEDO[1] = TextDrawCreate(522.000, 388.000, "HUD:radar_modGarage");
  TextDrawTextSize(BACKGROUND_SPEDO[1], 16.000, 28.000);
  TextDrawAlignment(BACKGROUND_SPEDO[1], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKGROUND_SPEDO[1], -1);
  TextDrawSetShadow(BACKGROUND_SPEDO[1], 0);
  TextDrawSetOutline(BACKGROUND_SPEDO[1], 0);
  TextDrawBackgroundColour(BACKGROUND_SPEDO[1], 255);
  TextDrawFont(BACKGROUND_SPEDO[1], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKGROUND_SPEDO[1], true);

  BACKGROUND_SPEDO[2] = TextDrawCreate(523.000, 421.000, "HUD:radar_spray");
  TextDrawTextSize(BACKGROUND_SPEDO[2], 16.000, 22.000);
  TextDrawAlignment(BACKGROUND_SPEDO[2], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKGROUND_SPEDO[2], -1);
  TextDrawSetShadow(BACKGROUND_SPEDO[2], 0);
  TextDrawSetOutline(BACKGROUND_SPEDO[2], 0);
  TextDrawBackgroundColour(BACKGROUND_SPEDO[2], 255);
  TextDrawFont(BACKGROUND_SPEDO[2], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKGROUND_SPEDO[2], true);

  BACKGROUND_SPEDO[3] = TextDrawCreate(492.000, 422.000, "KM/H");
  TextDrawLetterSize(BACKGROUND_SPEDO[3], 0.300, 1.500);
  TextDrawAlignment(BACKGROUND_SPEDO[3], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKGROUND_SPEDO[3], -1);
  TextDrawSetShadow(BACKGROUND_SPEDO[3], 1);
  TextDrawSetOutline(BACKGROUND_SPEDO[3], 1);
  TextDrawBackgroundColour(BACKGROUND_SPEDO[3], 150);
  TextDrawFont(BACKGROUND_SPEDO[3], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(BACKGROUND_SPEDO[3], true);
  ////////////////////////////////////////////////////////////////////////////
  
  // hbe
  BACKGROUND_HBE[0] = TextDrawCreate(567.000, 381.000, "LD_SPAC:white");
  TextDrawTextSize(BACKGROUND_HBE[0], 98.000, 105.000);
  TextDrawAlignment(BACKGROUND_HBE[0], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKGROUND_HBE[0], 150);
  TextDrawSetShadow(BACKGROUND_HBE[0], 0);
  TextDrawSetOutline(BACKGROUND_HBE[0], 0);
  TextDrawBackgroundColour(BACKGROUND_HBE[0], 255);
  TextDrawFont(BACKGROUND_HBE[0], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKGROUND_HBE[0], true);

  BACKGROUND_HBE[1] = TextDrawCreate(575.000, 391.000, "HUD:radar_burgerShot");
  TextDrawTextSize(BACKGROUND_HBE[1], 19.000, 25.000);
  TextDrawAlignment(BACKGROUND_HBE[1], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKGROUND_HBE[1], -1);
  TextDrawSetShadow(BACKGROUND_HBE[1], 0);
  TextDrawSetOutline(BACKGROUND_HBE[1], 0);
  TextDrawBackgroundColour(BACKGROUND_HBE[1], 255);
  TextDrawFont(BACKGROUND_HBE[1], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKGROUND_HBE[1], true);

  BACKGROUND_HBE[2] = TextDrawCreate(575.000, 419.000, "HUD:radar_diner");
  TextDrawTextSize(BACKGROUND_HBE[2], 18.000, 27.000);
  TextDrawAlignment(BACKGROUND_HBE[2], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(BACKGROUND_HBE[2], -1);
  TextDrawSetShadow(BACKGROUND_HBE[2], 0);
  TextDrawSetOutline(BACKGROUND_HBE[2], 0);
  TextDrawBackgroundColour(BACKGROUND_HBE[2], 255);
  TextDrawFont(BACKGROUND_HBE[2], TEXT_DRAW_FONT_SPRITE_DRAW);
  TextDrawSetProportional(BACKGROUND_HBE[2], true);
  
  // logo server 
  LOGO_SERVER[0] = TextDrawCreate(297.000, 12.000, "DETROIT");
  TextDrawLetterSize(LOGO_SERVER[0], 0.358, 2.098);
  TextDrawTextSize(LOGO_SERVER[0], 34.000, 34.000);
  TextDrawAlignment(LOGO_SERVER[0], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(LOGO_SERVER[0], -764862721);
  TextDrawSetShadow(LOGO_SERVER[0], 1);
  TextDrawSetOutline(LOGO_SERVER[0], 1);
  TextDrawBackgroundColour(LOGO_SERVER[0], 150);
  TextDrawFont(LOGO_SERVER[0], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(LOGO_SERVER[0], true);

  LOGO_SERVER[1] = TextDrawCreate(297.000, 28.000, "ROLEPLAY");
  TextDrawLetterSize(LOGO_SERVER[1], 0.300, 1.500);
  TextDrawAlignment(LOGO_SERVER[1], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(LOGO_SERVER[1], -1);
  TextDrawSetShadow(LOGO_SERVER[1], 1);
  TextDrawSetOutline(LOGO_SERVER[1], 1);
  TextDrawBackgroundColour(LOGO_SERVER[1], 150);
  TextDrawFont(LOGO_SERVER[1], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(LOGO_SERVER[1], true);

  LOGO_SERVER[2] = TextDrawCreate(31.000, 434.000, "MIT LICENSE");
  TextDrawLetterSize(LOGO_SERVER[2], 0.300, 1.500);
  TextDrawAlignment(LOGO_SERVER[2], TEXT_DRAW_ALIGN_LEFT);
  TextDrawColour(LOGO_SERVER[2], -1);
  TextDrawSetShadow(LOGO_SERVER[2], 1);
  TextDrawSetOutline(LOGO_SERVER[2], 1);
  TextDrawBackgroundColour(LOGO_SERVER[2], 150);
  TextDrawFont(LOGO_SERVER[2], TEXT_DRAW_FONT_1);
  TextDrawSetProportional(LOGO_SERVER[2], true);
  //////////////////////////////////////////////////////////////
  
  return 1;
}
