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