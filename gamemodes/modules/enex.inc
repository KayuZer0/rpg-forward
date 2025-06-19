#define MAX_ENEX 10

#define ENEX_MAX_NAME 24
#define ENEX_MAX_DESC 48

#define ENEX_SPAWN_INT 0

enum exData {
    exObjID,
    exIntObjID,
    exModelID,
    exInterior,
    Float: exPos[3],
    Float: exIntPos[3],
    Text3D: exLabelObj,
    Text3D: exIntLabelObj,
    exName[ENEX_MAX_NAME],
    exDesc[ENEX_MAX_DESC]
}

new EnexData[MAX_ENEX][exData];

stock InitEnex() {
    CreateEnex(ENEX_SPAWN_INT, 1239, 15, "Test", "Test",  Float: {1951.806152, 1342.011474, 15.367187}, Float: {207.630004, -110.579940, 1005.132812});
}

stock CreateEnex(id, modelid, interior, const name[], const desc[], const Float: pos[3], const Float: intPos[3]) {
    EnexData[id][exObjID] = CreateDynamicPickup(modelid, 0, Float:pos[0], Float:pos[1], Float:pos[2], -1, -1, -1);
    EnexData[id][exIntObjID] = CreateDynamicPickup(modelid, 0, Float:intPos[0], Float:intPos[1], Float:intPos[2], -1, interior, -1);
    
    new label[ENEX_MAX_NAME];
    format(label, sizeof(label), "Name: %s\nDesc: %s", name, desc);
    EnexData[id][exLabelObj] = CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:pos[0], Float:pos[1], Float:pos[2], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1);
    EnexData[id][exIntLabelObj] = CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:intPos[0], Float:intPos[1], Float:intPos[2], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, interior, -1);
    
    EnexData[id][exModelID] = modelid;
    EnexData[id][exInterior] = interior;
    EnexData[id][exPos] = pos;
    EnexData[id][exIntPos] = intPos;
    strcopy(EnexData[id][exName], name, ENEX_MAX_NAME);
    strcopy(EnexData[id][exDesc], name, ENEX_MAX_DESC);
}


WORLDMANIP_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
    if KEY_PRESSED(KEY_SECONDARY_ATTACK) {
        for (new i = 0; i < MAX_ENEX; i++) {

            if (GetPlayerInterior(playerid) == 0) {
                new Float: distToEnex = GetPlayerDistanceFromPoint(playerid, EnexData[i][exPos][0], EnexData[i][exPos][1], EnexData[i][exPos][2]);
                SendClientMessage(playerid, COLOR_ORANGE, "Distance to ENEX: %f", distToEnex);

                if (distToEnex < 1.0) {
                    SetPlayerInterior(playerid, EnexData[i][exInterior]);
                    SetPlayerPos(playerid, EnexData[i][exIntPos][0], EnexData[i][exIntPos][1], EnexData[i][exIntPos][2]);
                    return 1;
                }
            } else {
                new Float: distToEnex = GetPlayerDistanceFromPoint(playerid, EnexData[i][exIntPos][0], EnexData[i][exIntPos][1], EnexData[i][exIntPos][2]);
                SendClientMessage(playerid, COLOR_ORANGE, "Distance to ENEX: %f", distToEnex);

                if (distToEnex < 1.0) {
                    SetPlayerInterior(playerid, 0);
                    SetPlayerPos(playerid, EnexData[i][exPos][0], EnexData[i][exPos][1], EnexData[i][exPos][2]);
                    return 1;
                }
            }
        }
    }

    return 1;
}