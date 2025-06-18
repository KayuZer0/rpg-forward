stock SavePlayer(playerid) {
	new query[1024];
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));

	mysql_format(db, query, sizeof(query),
	"UPDATE users SET \
	`pName` = '%e', \
	`pEmail` = '%e', \
	`pAge` = '%e', \
	`pPassword` = '%e', \
	`pSalt` = '%e', ",
	
	PlayerData[playerid][pName],
	PlayerData[playerid][pEmail],
	PlayerData[playerid][pAge],
	PlayerData[playerid][pPassword],
	PlayerData[playerid][pSalt]);


	new tmp[256];
	mysql_format(db, tmp, sizeof(tmp),
	"`pMoney` = '%d', \
	`pAdmin` = '%d', \
	`pBannedUntil` = '%e', \
	`pBannedBy` = '%e', \
	`pBanReason` = '%e'",
	
	PlayerData[playerid][pMoney],
	PlayerData[playerid][pAdmin],
	PlayerData[playerid][pBannedUntil],
	PlayerData[playerid][pBannedBy],
	PlayerData[playerid][pBanReason]);
	strcat(query, tmp, sizeof(query));

	new where[32];
	mysql_format(db, where, sizeof(where), " WHERE `pName` = '%e'", name);
	strcat(query, where, sizeof(query));

	mysql_tquery(db, query, "OnPlayerDataSet", "i", playerid);

	printf(query);
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

stock AssignInitialPlayerData(playerid) {

	cache_get_value_int(0, "pMoney", PlayerData[playerid][pMoney]);
	cache_get_value_int(0, "pAdmin", PlayerData[playerid][pAdmin]);
	cache_get_value(0, "pEmail", PlayerData[playerid][pEmail], 32);
	cache_get_value_int(0, "pAge", PlayerData[playerid][pAge]);


	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);

	return 1;
}

forward OnPlayerRegistered(playerid);
public OnPlayerRegistered(playerid) {
	ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "Registration", 
	"Account successfully registered, you have been automatically logged in.", 
	"Okay", "");

	PlayerData[playerid][pIsLoggedIn] = true;

	PlayerData[playerid][pMoney] = DEFAULT_MONEY;
	PlayerData[playerid][pAdmin] = DEFAULT_ADMIN;
	PlayerData[playerid][pEmail] = pRegisterCacheEmail[playerid];
	PlayerData[playerid][pAge] = pRegisterCacheAge[playerid];

	format(pRegisterCacheEmail[playerid], sizeof(pRegisterCacheEmail[]), "");
	pRegisterCacheAge[playerid] = 0;
	format(pRegisterCachePassword[playerid], sizeof(pRegisterCachePassword[]), "");
	format(pRegisterCacheRepeatPassword[playerid], sizeof(pRegisterCacheRepeatPassword[]), "");

	HideRegisterMenu(playerid);

	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);

	SetSpawnInfo(playerid, NO_TEAM, 0, 1958.33, 1343.12, 15.36, 269.15, WEAPON_SAWEDOFF, 36, WEAPON_UZI, 150, WEAPON_FIST, 0);
	SpawnPlayer(playerid);
	
	return 1;
}

stock ChangePlayerMoney(playerid, money, changeMode = add) {
	switch (changeMode) {
		case add: {
			GivePlayerMoney(playerid, money);
			PlayerData[playerid][pMoney] = PlayerData[playerid][pMoney] + money;
			SavePlayer(playerid);
		}
		case set: {
			GivePlayerMoney(playerid, money - PlayerData[playerid][pMoney]);
			PlayerData[playerid][pMoney] = money;
			SavePlayer(playerid);
		}	
	}
}

forward OnPlayerDataLoaded(playerid, racecheck);
public OnPlayerDataLoaded(playerid, racecheck) {
	if (racecheck != gMySqlRaceCheck[playerid]) { return Kick(playerid); }

	cache_get_value_int(0, "pBannedUntil", PlayerData[playerid][pBannedUntil]);
	cache_get_value(0, "pBannedBy", PlayerData[playerid][pBannedBy], MAX_PLAYER_NAME);
	cache_get_value(0, "pBanReason", PlayerData[playerid][pBanReason], 128);

	if (PlayerData[playerid][pBannedUntil] != 0) 
	{
		new bannedUntilString[128];

		if (PlayerData[playerid][pBannedUntil] == 0) 
		{
			format(bannedUntilString, sizeof(bannedUntilString), "Permanent (ban will not expire)");

		} 
		else if (gettime() < PlayerData[playerid][pBannedUntil]) 
		{
			new year, month, day, hour, minute, second;
			stamp2datetime(PlayerData[playerid][pBannedUntil], year, month, day, hour, minute, second);
			format(bannedUntilString, sizeof(bannedUntilString), "%02d/%02d/%d - %d:%d", day, month, year, hour, minute, second);
		} 

		SendClientMessage(playerid, COLOR_DARKNICERED, "------------------------------------------");
		SendClientMessage(playerid, COLOR_DARKNICERED, "You have been banned!");
		SendClientMessage(playerid, COLOR_DARKNICERED, "------------------------------------------");
		SendClientMessage(playerid, COLOR_DARKNICERED, "Banned until: %s", bannedUntilString);
		SendClientMessage(playerid, COLOR_DARKNICERED, "Banned by: %s", PlayerData[playerid][pBannedBy]);
		SendClientMessage(playerid, COLOR_DARKNICERED, "Banned for: %s", PlayerData[playerid][pBanReason]);
		SendClientMessage(playerid, COLOR_DARKNICERED, "------------------------------------------");

		new bannedDialog[128];
		format(bannedDialog, sizeof(bannedDialog), "\nBanned Until: %s\nBanned by: %s\nBanned for: %s", bannedUntilString, PlayerData[playerid][pBannedBy], PlayerData[playerid][pBanReason]);

		ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "You have been banned!", bannedDialog, "Quit", "");

		DelayKick(playerid);

		return 1;
	}

	new dialog[115];
	if (cache_num_rows() > 0) {
		cache_get_value(0, "pPassword", PlayerData[playerid][pPassword], 65);
		cache_get_value(0, "pSalt", PlayerData[playerid][pSalt], 17);

		printf(PlayerData[playerid][pPassword]);
		printf(PlayerData[playerid][pSalt]);

		PlayerData[playerid][pCacheID] = cache_save();

		format(dialog, sizeof dialog, "This account (%s) is registered. \nPlease login by entering your password in the field below:", PlayerData[playerid][pName]);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", dialog, "Login", "Cancel");

	} else {
		ShowRegisterMenu(playerid);
	}

	return 1;
}