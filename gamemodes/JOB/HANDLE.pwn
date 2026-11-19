stock GetJobName(idjob, dest[], size = sizeof(dest)) {
  new const jobname[][] = {
    "Pengangguran",
    "Pengantar Pizza",
    "Kurir Paket",
    "Penambang",
    "Pemotong Kayu",
    "Mekanik"
  };

  if(idjob < 0 || idjob >= sizeof(jobname)) {
    format(dest, size, "Tidak Ada");
    return 0;
  }

  format(dest, size, "%s", jobname[idjob]);
  
  return 1;
}

stock ResetJob(playerid) {

  ResetPlayerPizza(playerid);

  return 1;
}

CMD:getjob(playerid, params[]) {

  if(Pemain[playerid][pJob] != 0) return SendMessageError(playerid, "Kamu sudah memiliki pekerjaan, gunakan /resignjob untuk keluar");

  if(IsPlayerInRangeOfPoint(playerid, 1.5, 2097.5, -1801.50, 13.4)) {
    Pemain[playerid][pJob] = 1;
    return SendMessageInfo(playerid, "Berhasil mendaftar sebagai pengantar pizza!");
  }

  return 1;
}

CMD:resignjob(playerid, params[]) {

  if(Pemain[playerid][pJob] == 0) return SendMessageError(playerid, "Kamu tidak memiliki pekerjaan apapun!");

  Pemain[playerid][pJob] = 0;

  return SendMessageInfo(playerid, "Berhasil keluar dari pekerjaan!");
}