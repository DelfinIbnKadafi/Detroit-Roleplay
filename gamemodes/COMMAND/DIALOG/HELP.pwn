stock ShowHelpDialog(playerid) {
  Dialog_Show(playerid, DL_HELP_MAIN, DIALOG_STYLE_LIST, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Help", "Roleplay Command\nBasic Command\nVehicle Command", "Pilih", "Batal");
  
  return 1;
}

Dialog:DL_HELP_MAIN(playerid, response, listitem, const inputtext[]) {
  if(!response) return 1;
  
  switch(listitem) {
    case 0: {
      Dialog_Show(playerid, DL_HELP, DIALOG_STYLE_LIST, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Roleplay Command", "/s\n/l\n/do\n/me", "Kembali", " ");
    }
    case 1: {
      Dialog_Show(playerid, DL_HELP, DIALOG_STYLE_LIST, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Basic Command", "/pay\n/help\n/stats\n/enter", "Kembali", " ");
    }
    case 2: {
      Dialog_Show(playerid, DL_HELP, DIALOG_STYLE_LIST, ""E_DETROIT"Detroit "E_WHITE"Roleplay - Roleplay Command", "/myveh\n/en\n/lockveh", "Kembali", " ");
    }
  }
  return 1;
}