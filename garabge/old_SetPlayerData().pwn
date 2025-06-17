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