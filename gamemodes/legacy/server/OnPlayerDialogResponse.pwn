//===[DIALOG RESPONSE FILE]===//
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!response) return 1;

    //=================[LOGIN]=================//
    if(dialogid == DIALOG_LOGIN)
    {
        if(!strlen(inputtext))
        {
            SendMessageError(playerid, "Password tidak boleh kosong!");

            new str[512];
            format(str, sizeof(str),
                "Akun {FFF000}%s {FFFFFF}sudah terdaftar, silahkan masukkan\n\
                password akun anda.\n\n\
                {FF0000}[ERROR]{FFFFFF} Password tidak boleh kosong!",
                Player[playerid][pName]
            );

            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,
                "{CD7000}Detroit {FFFFFF}Roleplay - Account Login",
                str,
                "Lanjut",
                "Kembali"
            );
            return 1;
        }

        if(strcmp(inputtext, Player[playerid][pPassword], false) != 0)
        {
            SendMessageError(playerid, "Password salah!");

            new str[512];
            format(str, sizeof(str),
                "Akun {FFF000}%s {FFFFFF}sudah terdaftar, silahkan masukkan\n\
                password akun anda.\n\n\
                {FF0000}[ERROR]{FFFFFF} Password salah!",
                Player[playerid][pName]
            );

            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,
                "{CD7000}Detroit {FFFFFF}Roleplay - Account Login",
                str,
                "Lanjut",
                "Kembali"
            );
            return 1;
        }

        // ===== PASSWORD BENAR (KODE ASLI) =====
        SendMessageInfo(playerid, "Password benar, silahkan bermain.");

        new query[512];
        mysql_format(g_SQL, query, sizeof(query),
            "SELECT money, level, skin, lahir, tinggi, berat, bank, phone, rek, \
            interior, posx, posy, posz, angle, nyawa, hunger, energi, armor, job1, job2, death, \
            admin \
            FROM players WHERE id = %d",
            Player[playerid][pId]
        );
        mysql_tquery(g_SQL, query, "LoadPlayerData", "d", playerid);
        return 1;
    }
    //=================[VERIFIKASI]=================//
    if(dialogid == DIALOG_REGISTER_VERTIFIKASI)
    {
        if(strval(inputtext) != Player[playerid][pCode])
        {
            new str[512];
            format(str, sizeof(str),
                "Akun {FFF000}%s {FFFFFF}belum diverifikasi, silahkan masukkan\n\
                kode verifikasi 6 digit yang telah diberikan.\n\n\
                {FF0000}[ERROR]{FFFFFF} Kode verifikasi salah!",
                Player[playerid][pName]
            );

            ShowPlayerDialog(playerid, DIALOG_REGISTER_VERTIFIKASI, DIALOG_STYLE_INPUT,
                "{CD7000}Detroit {FFFFFF}Roleplay - Account Verification",
                str,
                "Lanjut",
                "Kembali"
            );
            return 1;
        }

        SendMessageInfo(playerid, "Kode verifikasi benar, silahkan buat password.");

        ShowPlayerDialog(playerid, DIALOG_REGISTER_PASSWORD, DIALOG_STYLE_INPUT,
            "{CD7000}Detroit {FFFFFF}Roleplay - Account Create",
            "Masukkan password untuk akun anda.\n\
            Minimal 4 karakter atau lebih.",
            "Lanjut",
            "Kembali"
        );
        return 1;
    }

    //=================[PASSWORD]=================//
    if(dialogid == DIALOG_REGISTER_PASSWORD)
    {
        if(strlen(inputtext) < 4)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER_PASSWORD, DIALOG_STYLE_INPUT,
                "{CD7000}Detroit {FFFFFF}Roleplay - Account Create",
                "Masukkan password untuk akun anda.\n\
                Minimal 4 karakter atau lebih.\n\n\
                {FF0000}[ERROR]{FFFFFF} Password kurang dari 4 karakter!",
                "Lanjut",
                "Kembali"
            );
            return 1;
        }

        format(Player[playerid][pPassword], 65, "%s", inputtext);

        ShowPlayerDialog(playerid, DIALOG_REGISTER_DATE, DIALOG_STYLE_INPUT,
            "{CD7000}Detroit {FFFFFF}Roleplay - Account Create",
            "Masukkan tanggal lahir karakter anda.\n\
            {FFF000}DD/MM/YYYY.",
            "Lanjut",
            "Kembali"
        );
        return 1;
    }

    //=================[TANGGAL LAHIR]=================//
    if(dialogid == DIALOG_REGISTER_DATE)
    {
        if(strlen(inputtext) != 10)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER_DATE, DIALOG_STYLE_INPUT,
                "{CD7000}Detroit {FFFFFF}Roleplay - Account Create",
                "Masukkan tanggal lahir karakter anda.\n\
                {FFF000}DD/MM/YYYY.\n\n\
                {FF0000}[ERROR]{FFFFFF} Format tanggal lahir tidak sesuai!",
                "Lanjut",
                "Kembali"
            );
            return 1;
        }

        format(Player[playerid][pLahir], 12, "%s", inputtext);

        ShowPlayerDialog(playerid, DIALOG_REGISTER_TINGGI, DIALOG_STYLE_INPUT,
            "{CD7000}Detroit {FFFFFF}Roleplay - Account Create",
            "Masukkan tinggi karakter anda.\n\
            Contoh : 170",
            "Lanjut",
            "Kembali"
        );
        return 1;
    }

    //=================[TINGGI]=================//
    if(dialogid == DIALOG_REGISTER_TINGGI)
    {
        new tinggi = strval(inputtext);
        if(tinggi < 120 || tinggi > 220)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER_TINGGI, DIALOG_STYLE_INPUT,
                "{CD7000}Detroit {FFFFFF}Roleplay - Account Create",
                "Masukkan tinggi karakter anda.\n\
                Contoh: 170\n\n\
                {FF0000}[ERROR]{FFFFFF} Tinggi tidak valid!",
                "Lanjut",
                "Kembali"
            );
            return 1;
        }

        Player[playerid][pTinggi] = tinggi;
        ShowPlayerDialog(playerid, DIALOG_REGISTER_BERAT, DIALOG_STYLE_INPUT,
            "{CD7000}Detroit {FFFFFF}Roleplay - Account Create",
            "Masukkan berat karakter anda.\n\
            Contoh: 60",
            "Lanjut",
            "Kembali"
        );
        return 1;
    }

    //=================[BERAT]=================//
    if(dialogid == DIALOG_REGISTER_BERAT)
    {
        new berat = strval(inputtext);
        if(berat < 30 || berat > 200)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER_BERAT, DIALOG_STYLE_INPUT,
                "{CD7000}Detroit {FFFFFF}Roleplay - Account Create",
                "Masukkan berat karakter anda.\n\
                Contoh: 60\n\n\
                {FF0000}[ERROR]{FFFFFF} Berat tidak valid!",
                "Lanjut",
                "Kembali"
            );
            return 1;
        }

        Player[playerid][pBerat] = berat;

        new query[512];
        mysql_format(g_SQL, query, sizeof(query),
            "UPDATE players SET password='%e', lahir='%e', tinggi=%d, berat=%d, \
            verified=1 WHERE id=%d",
            Player[playerid][pPassword],
            Player[playerid][pLahir],
            Player[playerid][pTinggi],
            Player[playerid][pBerat],
            Player[playerid][pId]
        );
        mysql_tquery(g_SQL, query, "OnPasswordSet", "d", playerid);
        return 1;
    }

    return 0;
}
