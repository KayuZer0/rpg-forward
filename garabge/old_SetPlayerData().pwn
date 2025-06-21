stock SetPlayerData(playerid, data, dataMysql[], value, dataType) {
	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));

	new query[128];
	switch(dataType) {
		case data_int: format(query, sizeof(query), "UPDATE users SET `%s` = %d WHERE name = '%s'", dataMysql, value, playerName);
		case data_float: format(query, sizeof(query), "UPDATE users SET `%s` = %0.2f WHERE name = '%s'", dataMysql, __:value, playerName);
		case data_bool: format(query, sizeof(query), "UPDATE users SET `%s` = %d WHERE name = '%s'", dataMysql, value, playerName);
		default: format(query, sizeof(query), "UPDATE users SET `%s` = %d WHERE name = '%s'", dataMysql, value, playerName); // Treated as int.
	}

	mysql_tquery(db, query, "OnPlayerDataSet", "i", playerid);
	//SendClientMessage(playerid, 0xFFA500AA, query);

	PlayerData[playerid][data] = __:value;
	return 1;
}

stock SetPlayerDataArray(playerid, data, dataMysql[], const value[], valueSize, dataType) {
	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));

	new query[128];
	if (dataType == data_string) {
		format(query, sizeof(query), "UPDATE users SET `%s` = '%s' WHERE name = '%s'", dataMysql, value, playerName);
	} else {
		new arrayString[128];
		ArrayToString(value, valueSize, arrayString, sizeof(arrayString));			
		format(query, sizeof(query), "UPDATE users SET `%s` = '%s' WHERE name = '%s'", dataMysql, arrayString, playerName);
	}

	mysql_tquery(db, query, "OnPlayerDataSet", "i", playerid);
	//SendClientMessage(playerid, 0xFFA500AA, query);

	for (new i = 0; i < valueSize; i++) {
		PlayerData[playerid][data + i] = value[i];
	}

	return 1;
}

new Iterator:NearEnex[MAX_PLAYERS]<MAX_ENEX>;

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
    Iter_Init(NearEnex);
    CreateEnex(1239, 15, "Test", "Test",  Float: {1951.806152, 1342.011474, 15.367187}, Float: {207.630004, -110.579940, 1005.132812});
}

stock CreateEnex(modelid, interior, const name[], const desc[], const Float: pos[3], const Float: intPos[3]) {
    pickupCount++;
    new id = pickupCount;
    pickupCount++;

    EnexData[id][exObjID] = CreateDynamicPickup(modelid, 1, Float:pos[0], Float:pos[1], Float:pos[2], -1, -1, -1);
    EnexData[id][exIntObjID] = CreateDynamicPickup(modelid, 1, Float:intPos[0], Float:intPos[1], Float:intPos[2], -1, interior, -1);
    
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

    PickupData[id][pkID] = id;
    PickupData[id][pkType] = PICKUP_TYPE_ENEX;

    PickupData[id + 1][pkID] = id;
    PickupData[id + 1][pkType] = PICKUP_TYPE_ENEX;

    printf("%d", EnexData[id][exObjID]);
    printf("%d", EnexData[id][exIntObjID]);
    printf("%d", IsValidDynamicPickup(STREAMER_TAG_PICKUP:0));
}
