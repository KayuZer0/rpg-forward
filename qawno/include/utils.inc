stock SetPlayerData(playerid, data[][], values[], dataSize) {
	new bufferDataValueStr[128];

	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));

	for (new i = 0; i < dataSize; i++) {
		new bufferDataStr[256];
		new bufferValueStr[256];

		//SendClientMessage(playerid, COLOR_ORANGE, data[i]);

		new trueData = FieldFromName(data[i]);
		PlayerData[playerid][trueData] = values[i];

        format(bufferDataStr, sizeof(bufferDataStr), "%s", data[i]);

		// if (is int) {}
        if (values[i] == floatround(values[i], floatround_ceil)) {
			format(bufferValueStr, sizeof(bufferValueStr), "%s%d",
				bufferValueStr,
				values[i]);
		} else {
			format(bufferValueStr, sizeof(bufferValueStr), "%s%f",
				bufferValueStr,
				Float: values[i]);
		}
		
		format(bufferDataValueStr, sizeof(bufferDataValueStr), "%s`%s` = '%s'%s", bufferDataValueStr, bufferDataStr, bufferValueStr, (i < dataSize - 1) ? ", " : "");
	}

	new query[256];
	format(query, sizeof(query), "UPDATE `users` SET %s WHERE `pName` = '%s'", bufferDataValueStr, playerName);
	mysql_tquery(db, query, "OnPlayerDataSet", "i", playerid);
	return 1;
}

stock SetPlayerDataArray(playerid, data[][], values[][], const valueTypes[], const valueSizes[], dataSize) {
	new bufferDataValueStr[256];

	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));

	for (new i = 0; i < dataSize; i++) {
		new bufferDataStr[128];
		new bufferValueStr[256];

		new arrToStr[32];

		//SendClientMessage(playerid, COLOR_ORANGE, data[i]);

		new trueData = FieldFromName(data[i]);
		PlayerData[playerid][trueData] = values[i][0];

        format(bufferDataStr, sizeof(bufferDataStr), "%s", data[i]);

		// if (is int) {}
        if (valueTypes[i] == 's') {
			format(bufferValueStr, sizeof(bufferValueStr), "%s%s",
				bufferValueStr,
				values[i]);
		} else {
			
			ArrayToString(values[i], valueSizes[i], arrToStr, sizeof(arrToStr));
			format(bufferValueStr, sizeof(bufferValueStr), "%s%s%s",
				bufferValueStr,
				arrToStr,
				(i < dataSize - 1) ? ", " : "");
		}

		format(bufferDataValueStr, sizeof(bufferDataValueStr), "%s`%s` = '%s'%s", bufferDataValueStr, bufferDataStr, bufferValueStr, (i < dataSize - 1) ? ", " : "");
	}

	new query[256];
	format(query, sizeof(query), "UPDATE `users` SET %s WHERE `pName` = '%s'", bufferDataValueStr, playerName);
	mysql_tquery(db, query, "OnPlayerDataSet", "i", playerid);
	return 1;
}

forward OnPlayerDataSet(playerid);
public OnPlayerDataSet(playerid) {
	if (!mysql_errno(db))
    {
        printf("Data inserted successfuly!");
    }
    else
    {
        printf("Error [%d] when inserting data!", mysql_errno(db));
    }
    return 1;
}

stock ChangePlayerMoney(playerid, money, changeMode = add) {
	switch (changeMode) {
		case add: {
			GivePlayerMoney(playerid, money);

			new data[][] = {"pMoney"};
			new values[1]; values[0] = PlayerData[playerid][pMoney] + money;
			SetPlayerData(playerid, data, values, sizeof(data));
		}
		case set: {
			GivePlayerMoney(playerid, money - PlayerData[playerid][pMoney]);
			new data[][] = {"pMoney"};
			new values[1]; values[0] = money;
			SetPlayerData(playerid, data, values, sizeof(data));
		}	
	}
}

stock ArrayToString(const arr[], size, dest[], dest_size) {
    format(dest, dest_size, "["); // Start with the opening bracket
    for (new i = 0; i < size; i++)
    {
        new temp[12];
        format(temp, sizeof(temp), "%d", arr[i]);
        strcat(dest, temp, dest_size);

        if (i < size - 1)
        {
            strcat(dest, ", ", dest_size);
        }
    }
    strcat(dest, "]", dest_size); // Close the bracket
}

stock DebugArray(const any:arr[], size, const name[] = "value") {
    printf("Debugging %s:", name);
    for (new i = 0; i < size; i++)
    {
        printf("%s[%d] = %d", name, i, arr[i]);
    }
}

stock abs(value) {
    return (value < 0) ? -value : value;
}

stock IsFloat(value) {
	return value == floatround(values[i], floatround_ceil);
}

stock DelayKick(playerid, wait = 500) {
	SetTimerEx("OnDelayKick", wait, false, "i", playerid);
	return 1; // 5000 ms = 5s
}

forward OnDelayKick(playerid);
public OnDelayKick(playerid) {
	Kick(playerid);
	return 1;
}

stock HasAdminLevel(playerid, minimumLevel) {
    if (PlayerData[playerid][pAdmin] < minimumLevel) {
        SendClientMessage(playerid, COLOR_DARKNICERED, ERR_ADMIN_LEVEL);
        return 0;
    }
    return 1;
}