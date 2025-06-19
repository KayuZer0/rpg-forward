#define MAX_ENEX 1

#define ENEX_MAX_NAME 24
#define ENEX_MAX_DESC 48

#define ENEX_SPAWN_INT 0

enum exData {
    exObjID,
    exIntObjID,
    exModelID,
    exInterior,
    Float: exPosX,
    Float: exPosY,
    Float: exPosZ,
    Float: exIntPosX,
    Float: exIntPosY,
    Float: exIntPosZ,
    Text3D: exLabelObj,
    Text3D: exIntLabelObj,
    exName[ENEX_MAX_NAME],
    exDesc[ENEX_MAX_DESC]
}

new EnexData[MAX_ENEX][exData];

stock InitEnex() {
    CreateEnex(ENEX_SPAWN_INT, 1239, 15, "Test", "Test", 1951.806152, 1342.011474, 15.367187, 207.630004, -110.579940, 1005.132812);
}

stock CreateEnex(id, modelid, interior, const name[], const desc[], Float: x, Float: y, Float: z, Float: intX, Float: intY, Float: intZ) {
    EnexData[id][exObjID] = CreateDynamicPickup(modelid, 0, Float:x, Float:y, Float:z, -1, -1, -1);
    EnexData[id][exIntObjID] = CreateDynamicPickup(modelid, 0, Float:intX, Float:intY, Float:intZ, -1, interior, -1);
    
    new label[ENEX_MAX_NAME];
    format(label, sizeof(label), "Name: %s\nDesc: %s", name, desc);
    EnexData[id][exLabelObj] = CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:x, Float:y, Float:z, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1);
    EnexData[id][exIntLabelObj] = CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:intX, Float:intY, Float:intZ, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, interior, -1);
    
    EnexData[id][exModelID] = modelid;
    EnexData[id][exInterior] = interior;
    EnexData[id][exPosX] = x;
    EnexData[id][exPosY] = y;
    EnexData[id][exPosZ] = z;
    EnexData[id][exIntPosX] = intX;
    EnexData[id][exIntPosY] = intY;
    EnexData[id][exIntPosZ] = intZ;
    strcopy(EnexData[id][exName], name, ENEX_MAX_NAME);
    strcopy(EnexData[id][exDesc], name, ENEX_MAX_DESC);
}


WORLDMANIP_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
    if KEY_PRESSED(KEY_SECONDARY_ATTACK) {
        for (new i = 0; i < MAX_ENEX; i++) {

            if (GetPlayerInterior(playerid) == 0) {
                new Float: distToEnex = GetPlayerDistanceFromPoint(playerid, EnexData[i][exPosX], EnexData[i][exPosY], EnexData[i][exPosZ]);
                SendClientMessage(playerid, COLOR_ORANGE, "Distance to ENEX: %f", distToEnex);

                if (distToEnex < 1.0) {
                    SetPlayerInterior(playerid, EnexData[i][exInterior]);
                    SetPlayerPos(playerid, EnexData[i][exIntPosX], EnexData[i][exIntPosY], EnexData[i][exIntPosZ]);
                    return 1;
                }
            } else {
                new Float: distToEnex = GetPlayerDistanceFromPoint(playerid, EnexData[i][exIntPosX], EnexData[i][exIntPosY], EnexData[i][exIntPosZ]);
                SendClientMessage(playerid, COLOR_ORANGE, "Distance to ENEX: %f", distToEnex);

                if (distToEnex < 1.0) {
                    SetPlayerInterior(playerid, 0);
                    SetPlayerPos(playerid, EnexData[i][exPosX], EnexData[i][exPosY], EnexData[i][exPosZ]);
                    return 1;
                }
            }
        }
    }

    return 1;
}