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
  
  // GetJobName(idjob, output)
  
  return 1;
}