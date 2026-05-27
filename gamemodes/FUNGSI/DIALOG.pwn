public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

  // login sistem
  if(dialogid == DIALOG_LOGIN) {
    // tombol kirim
    if(response == 1) {
      // sandi benar
      new hashpw[65];
      SHA256_Hash(inputtext, "DELFIN", hashpw, sizeof(hashpw));
      
      if(strcmp(hashpw, Pemain[playerid][pPassword], true) == 0) {
        SendMessageServer(playerid, "Password benar, selamat bermain");
        // ubah variabel status login
        StatusLogin[playerid] = true;
        
        new blah[256];
        format(blah, sizeof(blah), "{59ff28}[SERVER]{fff000} %s {ffffff}memasuki server.", Pemain[playerid][pNama]);
        SendClientMessageToAll(0xffffff, blah);
        
        new data[512];
        mysql_format(g_SQL, data, sizeof(data), "SELECT gender, skin, posx, posy, posz, interior, nyawa, armor, angel, level FROM Pemain WHERE id='%d'",
        Pemain[playerid][pId]);
        mysql_tquery(g_SQL, data, "MuatDataPemain", "i", playerid);
        
        return 1;
      }
      // sandi salah
      else {
        SendMessageError(playerid, "Sandi salah!");
        
        new str[512];
        format(str, sizeof(str),
         "Akun {FFF000}%s {FFFFFF}sudah terdaftar.\n\nSilahkan masukkan password akun anda.\n\nPassword salah!",
         Pemain[playerid][pNama]
        );
        
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
         "{CD7000}Detroit {FFFFFF}Roleplay - Account Login",
         str,
         "Kirim", "Batal"
        );
        return 1;
      }
    }
    // tombol batal
    else {
      SetTimerEx("KickPemain", 5000, false, "i", playerid);
    }
  }
  
  // verifikasi kode
  if(dialogid == DIALOG_VERIFIKASI_KODE) {
    if(response == 1) {
      new inputkode;
      inputkode = strval(inputtext);
      
      // kode benar
      if(inputkode == Pemain[playerid][pKode]) {
        SendMessageServer(playerid, "Kode verifikasi benar, silahkan buat password anda!");
        
        new str[256];
        format(str, sizeof(str), "Silahkan masukkan password akun baru anda!");
        
        ShowPlayerDialog(playerid, DIALOG_BUAT_PASSWORD, DIALOG_STYLE_INPUT,
         "{CD7000}Detroit {FFFFFF}Roleplay - Account Creation",
         str,
         "Kirim", "Batal"
        );
        
        return 1;
      }
      // kode salah
      else {
        new str[256];
        format(str, sizeof(str),
         "Akun {FFF000}%s {FFFFFF}belum diverifikasi.\n\nMasukkan kode verifikasi 6 digit yang telah diberikan.\n\nKode vertifikasi salah!",
         Pemain[playerid][pNama]
        );
    
        ShowPlayerDialog(playerid, DIALOG_VERIFIKASI_KODE, DIALOG_STYLE_INPUT,
         "{CD7000}Detroit {FFFFFF}Roleplay - Account Verification",
         str,
         "Kirim", "Batal"
        );
        return 1;
      }
    }
    // tombol batal
    else {
      SetTimerEx("KickPemain", 5000, false, "i", playerid);
    }
  }
  
  // buat sandi
  if(dialogid == DIALOG_BUAT_PASSWORD) {
    if(response == 1) {
      
      // hash pw 
      SHA256_Hash(inputtext, "DELFIN", pwbaru[playerid], sizeof(pwbaru[]));
      
      ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST,
       "{CD7000}Detroit {FFFFFF}Roleplay - Account Creation Gender",
       "Pria\n\nWanita",
       "Pilih", "Batal");
       
      return 1;
    }
    // tombol batal
    else {
      SetTimerEx("KickPemain", 5000, false, "i", playerid);
    }
  }
  
  // gender/kelamin
  if(dialogid == DIALOG_GENDER) {
    if(response == 1) {
      // Pria
      if(listitem == 0) {
        gender[playerid] = 1;
        OnSetGender(playerid);
        return 1;
      }
      else if(listitem == 1) {
        gender[playerid] = 2;
        OnSetGender(playerid);
        return 1;
      }
    }
    // tombol batal
    else {
      SetTimerEx("KickPemain", 5000, false, "i", playerid);
    }
  }
  
  return 0;
}