#define EXT_BALAI_KOTA_x 1481.04
#define EXT_BALAI_KOTA_y -1771.79
#define EXT_BALAI_KOTA_z 18.78
#define EXT_BALAI_KOTA_a 8.06

#define INT_BALAI_KOTA_x 920.27
#define INT_BALAI_KOTA_y -1475.06
#define INT_BALAI_KOTA_z 2754.33
#define INT_BALAI_KOTA_a 2.24

#define BALAI_KOTA_X 918.81
#define BALAI_KOTA_Y -1463.48
#define BALAI_KOTA_Z 2754.33

stock DeteksiPintuBalaiKota(playerid) {
  if(GetPlayerDistanceFromPoint(playerid, EXT_BALAI_KOTA_x, EXT_BALAI_KOTA_y, EXT_BALAI_KOTA_z) <= 2) {
    SetPlayerPos(playerid, INT_BALAI_KOTA_x, INT_BALAI_KOTA_y, INT_BALAI_KOTA_z);
    SetPlayerFacingAngle(playerid, INT_BALAI_KOTA_a);
    return 1;
  }
  else if(GetPlayerDistanceFromPoint(playerid, INT_BALAI_KOTA_x, INT_BALAI_KOTA_y, INT_BALAI_KOTA_z) <= 2) {
    SetPlayerPos(playerid, EXT_BALAI_KOTA_x, EXT_BALAI_KOTA_y, EXT_BALAI_KOTA_z);
    SetPlayerFacingAngle(playerid, EXT_BALAI_KOTA_a);
    return 1;
  }
  
  return 0;
}

stock TanggalLahirValid(playerid, const date[]) {
  new day, month[16], year;
  new maxday;

  if(sscanf(date, "is[16]i", day, month, year)) {
    SendMessageError(playerid, "Tanggal lahir tidak valid!");
    Dialog_Show(playerid, DL_BALKOT_KTP_DATE, DIALOG_STYLE_INPUT, "Detroit City Hall", "Masukkan tanggal lahir\nContoh : 10 Oktober 2007", "Kirim", "Batal");
    return 0;
  }

  if(
    !strcmp(month, "Januari", true) ||
    !strcmp(month, "Maret", true) ||
    !strcmp(month, "Mei", true) ||
    !strcmp(month, "Juli", true) ||
    !strcmp(month, "Agustus", true) ||
    !strcmp(month, "Oktober", true) ||
    !strcmp(month, "Desember", true)
  ) {
    maxday = 31;
  }
  else if(
    !strcmp(month, "April", true) ||
    !strcmp(month, "Juni", true) ||
    !strcmp(month, "September", true) ||
    !strcmp(month, "November", true)
  ) {
    maxday = 30;
  }
  else if(
    !strcmp(month, "Februari", true)
  ) {
    maxday = 29;
  }
  else {
    SendMessageError(playerid, "Bulan tidak valid!");
    Dialog_Show(playerid, DL_BALKOT_KTP_DATE, DIALOG_STYLE_INPUT, "Detroit City Hall", "Masukkan tanggal lahir\nContoh : 10 Oktober 2007", "Kirim", "Batal");
    return 0;
  }

  if(day < 1 || day > maxday) {
    SendMessageError(playerid, "Tanggal tidak valid!");
    Dialog_Show(playerid, DL_BALKOT_KTP_DATE, DIALOG_STYLE_INPUT, "Detroit City Hall", "Masukkan tanggal lahir\nContoh : 10 Oktober 2007", "Kirim", "Batal");
    return 0;
  }

  return 1;
}

stock ShowBalkotMenu(playerid) {
  if(IsPlayerInRangeOfPoint(playerid, 2.0, BALAI_KOTA_X, BALAI_KOTA_Y, BALAI_KOTA_Z)) {
    new str[256];

    format(str, sizeof(str), "Buat Kartu Tanda Penduduk - 130.000 Rupiah");

    Dialog_Show(playerid, DL_BALKOT_MENU, DIALOG_STYLE_LIST, "Detroit City Hall", str, "Pilih", "Batal");
  }
}

Dialog:DL_BALKOT_MENU(playerid, response, listitem, const inputtext[]) {
  if(!response) return 1;

  switch(listitem) {
    case 0: {
      Dialog_Show(playerid, DL_BALKOT_KTP_DATE, DIALOG_STYLE_INPUT, "Detroit City Hall", "Masukkan tanggal lahir\nContoh : 10 Oktober 2007", "Kirim", "Batal");
    }
  }

  return 1;
}

Dialog:DL_BALKOT_KTP_DATE(playerid, response, listitem, const inputtext[]) {
  if(!response) return 1;

  if(!TanggalLahirValid(playerid, inputtext))
    return 1;

  if(GetPlayerMoney(playerid) < 130000) {
    SendMessageError(playerid, "Uang tidak cukup!");
    return 1;
  }

  format(Pemain[playerid][pDateBirth], 64, "%s", inputtext);

  Pemain[playerid][pKtp] = 1;

  GivePlayerMoney(playerid, -130000);

  SendMessageInfo(playerid, "Berhasil membuat KTP!");

  return 1;
}