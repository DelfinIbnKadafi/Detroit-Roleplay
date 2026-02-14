enum
{
    DIALOG_UNUSED,
    DIALOG_LOGIN,
    DIALOG_REGISTER_VERTIFIKASI,
    DIALOG_REGISTER_PASSWORD,
    DIALOG_REGISTER_DATE,
    DIALOG_REGISTER_TINGGI,
    DIALOG_REGISTER_BERAT,
    DIALOG_HELP,
    DIALOG_HELP_GENERAL,
    DIALOG_HELP_ACCOUNT,
    DIALOG_HELP_VEHCILE,
    DIALOG_HELP_JOB,
    DIALOG_HELP_HOUSE,
    DIALOG_HELP_BUSINES
}


enum PlayerData
{
    pName[MAX_PLAYER_NAME],
    pId,
    pVerified,
    pCode,
    pPassword[65],
    pLevel,
    pLahir[10],
    pTinggi,
    pBerat,
    pMoney,
    pBank,
    pPhone,
    pRek,
    pJob1,
    pJob2
};

new Player[MAX_PLAYERS][PlayerData];
new PlayerIsDeath[MAX_PLAYERS];

enum PSpawn
{
    Float:pPosx,
    Float:pPosy,
    Float:pPosz,
    Float:pAngle,
    pSkin,
    Float:pNyawa,
    Float:pArmor
};

new Float:PlayerSpawn[MAX_PLAYERS][PSpawn];
new PlayerInt[MAX_PLAYERS];