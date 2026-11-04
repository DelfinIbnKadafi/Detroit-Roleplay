// bussines data
#define MAX_BUSSINES_NAME 128
#define BUSSINES_PER_PAGE 10
#define BUSSINES_PICKUP_MODEL 19132
#define BUSSINES_DEFAULT_PRICE 15000000
#define BUSSINES_DEFAULT_INTERIOR 17

enum BussinesData {
    bool:bactive,
    bid,
    bnames[MAX_BUSSINES_NAME + 1],
    STREAMER_TAG_PICKUP:bpickup,
    STREAMER_TAG_3D_TEXT_LABEL:blabel,
    STREAMER_TAG_OBJECT:bexitobject,
    bownerid,
    bownername[MAX_PLAYER_NAME + 1],
    Float:bx,
    Float:by,
    Float:bz,
    btype,
    bsisa,
    bprice,
    binterior
}

new Bussines[MAX_BUSSINES][BussinesData];
new BussinesCount;
// Batas atas slot yang terpakai (index tertinggi + 1), supaya loop tidak selalu memeriksa seluruh MAX_BUSSINES slot
new BussinesSlotLimit;
new bool:BussinesReady;
new BussinesEditor[MAX_BUSSINES] = {INVALID_PLAYER_ID, ...};
new PlayerEditBussines[MAX_PLAYERS] = {-1, ...};
new STREAMER_TAG_OBJECT:PlayerBussinesObject[MAX_PLAYERS];
new PlayerDeleteBussines[MAX_PLAYERS];
new PlayerBussinesListPage[MAX_PLAYERS];
