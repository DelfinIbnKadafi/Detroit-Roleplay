// bussines data
#define MAX_BUSSINES_NAME 128
#define BUSSINES_PER_PAGE 10
#define BUSSINES_PICKUP_MODEL 19132

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
    bsisa
}

new Bussines[MAX_BUSSINES][BussinesData];
new BussinesCount;
new bool:BussinesReady;
new BussinesEditor[MAX_BUSSINES] = {INVALID_PLAYER_ID, ...};
new PlayerEditBussines[MAX_PLAYERS] = {-1, ...};
new STREAMER_TAG_OBJECT:PlayerBussinesObject[MAX_PLAYERS];
new PlayerDeleteBussines[MAX_PLAYERS];
