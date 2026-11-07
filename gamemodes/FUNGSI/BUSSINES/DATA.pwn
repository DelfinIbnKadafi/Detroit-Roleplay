// bussines data
#define MAX_BUSSINES_NAME 128
#define BUSSINES_PER_PAGE 10
#define BUSSINES_PICKUP_MODEL 19132
#define BUSSINES_BUY_PICKUP_MODEL 1274
#define BUSSINES_DEFAULT_PRICE 15000000
#define BUSSINES_DEFAULT_INTERIOR 17

enum BussinesData {
    bool:bactive,
    bid,
    bnames[MAX_BUSSINES_NAME + 1],
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

// object panah pintu keluar (PlayerObject) dan pickup titik beli (PlayerPickup), hanya ada selama player berada di interior business
new PlayerBussinesExitObject[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...};
new PlayerBussinesBuyPickup[MAX_PLAYERS] = {INVALID_PICKUP, ...};
// ID business (sama dengan virtual world) dan interior tempat object tersebut dibuat, 0 jika player tidak punya object
new PlayerBussinesObjectBid[MAX_PLAYERS];
new PlayerBussinesObjectInt[MAX_PLAYERS];
new PlayerDeleteBussines[MAX_PLAYERS];

// pages
new PlayerBussinesListPage[MAX_PLAYERS];
new PlayerBussinesListPages[MAX_PLAYERS];