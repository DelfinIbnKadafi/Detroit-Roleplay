// Server Description
#define SERVER_NAME 			"Detroit Project Roleplay"
#define SERVER_VERSION 			"0.1.4"

//------[ Makro ]------//
#define Fungsi:%0(%1) 			forward %0(%1); public %0(%1)

// stuff
#define MAX_LOGIN_ATTEMPTS		3
#define MAX_VERIFY_ATTEMPTS		5

#define DEFAULT_MALE_SKIN		59
#define DEFAULT_FEMALE_SKIN		141
#define DEFAULT_POS_X   		1743.06
#define DEFAULT_POS_Y   		-1862.50
#define DEFAULT_POS_Z   		13.57
#define DEFAULT_POS_A   		3.34

// veh 
#define MAX_VEHICLES_SERVER MAX_VEHICLES
#define MAX_KENDARAAN 5
#define VEHICLE_CRITICAL_HEALTH 300.0
#define VEHICLE_HEALTH_CHECK_INTERVAL 100
#define DEAD_VEHICLE_HEALTH 999999.0
#define VEH_KOSONG (-1) // nilai awal pemilik/slot/admin pada VehServer (artinya: tidak ada)

// tipe kendaraan, lihat GetTipeKendaraan di FUNGSI/KENDARAAN.pwn
#define VEHTIPE_LAIN 0 // kendaraan yang tidak terdaftar sebagai tipe apa pun
#define VEHTIPE_PLAYER 1 // kendaraan milik pemain
#define VEHTIPE_ADMIN 2 // kendaraan yang dibuat admin (/spawnaveh)
#define VEHTIPE_JOB_PIZZA 3 // pizza veh

// Business
#define MAX_Business 1000
#define MAX_Business_PLAYER 3