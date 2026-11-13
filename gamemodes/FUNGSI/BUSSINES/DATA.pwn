// Business data
#define MAX_Business_NAME 128
#define Business_PER_PAGE 10
#define Business_PICKUP_MODEL 19132
#define Business_DEFAULT_PRICE 45000000
#define Business_DEFAULT_INTERIOR 17

enum BusinessData {
    bool:bactive,
    bid,
    bnames[MAX_Business_NAME + 1],
    STREAMER_TAG_PICKUP:bpickup,
    STREAMER_TAG_3D_TEXT_LABEL:blabel,
    bownerid,
    bownername[MAX_PLAYER_NAME + 1],
    Float:bx,
    Float:by,
    Float:bz,
    btype,
    bsisa,
    bprice,
    binterior,
    bpendapatan
}

new Business[MAX_Business][BusinessData];
new BusinessCount;
// Batas atas slot yang terpakai (index tertinggi + 1), supaya loop tidak selalu memeriksa seluruh MAX_Business slot
new BusinessSlotLimit;
new bool:BusinessReady;
new BusinessEditor[MAX_Business] = {INVALID_PLAYER_ID, ...};
new PlayerEditBusiness[MAX_PLAYERS] = {-1, ...};
new STREAMER_TAG_OBJECT:PlayerBusinessObject[MAX_PLAYERS];

new PlayerDeleteBusiness[MAX_PLAYERS];

// pages
new PlayerBusinessListPage[MAX_PLAYERS];
new PlayerBusinessListPages[MAX_PLAYERS];


// variabel yang berisi index business yang akan diubah namanya
new SheylaCantikImutBanget[MAX_PLAYERS];


// ubah nama dari sistem atau sendiri
new GantiSendiriNamaBuss[MAX_PLAYERS];