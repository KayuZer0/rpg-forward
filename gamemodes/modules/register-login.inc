new pRegisterCacheEmail[MAX_PLAYERS][32];
new pRegisterCacheAge[MAX_PLAYERS];
new pRegisterCachePassword[MAX_PLAYERS][32];
new pRegisterCacheRepeatPassword[MAX_PLAYERS][32];

#define INPUT_EMAIL "Please input your E-mail address below:"
#define INPUT_AGE "Please input your age below:"
#define INPUT_PASS "Please input your password [8-32 chars] below:"

#define ERR_INPUT_EMAIL "Invalid email! Please input your E-mail address below:"
#define ERR_INPUT_AGE "Invalid age! Please input your age below:"
#define ERR_INPUT_PASS "Invalid password! Please input your password [8-32 chars] below:"

#define MINIMUM_PASSWORD 8
#define MAXIMUM_PASSWORD 32

// PLAYER DEFAULT VALUES:

#define DEFAULT_MONEY 10000
#define DEFAULT_ADMIN 0

forward REGISTER_LOGIN_OnPlayerConnect(playerid);
public REGISTER_LOGIN_OnPlayerConnect(playerid) {
	gMySqlRaceCheck[playerid]++;

	static const EMPTY_PLAYER[pData];
	PlayerData[playerid] = EMPTY_PLAYER;

	InitializeTempVars(playerid);

	GetPlayerName(playerid, PlayerData[playerid][pName], MAX_PLAYER_NAME);

	new query[256];

	format(query, sizeof(query), "SELECT * FROM users WHERE pName = '%s' LIMIT 1", PlayerData[playerid][pName]);
	mysql_tquery(db, query, "OnPlayerDataLoaded", "dd", playerid, gMySqlRaceCheck[playerid]);
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

forward REGISTER_LOGIN_OnDialogResponse(playerid, dialogid, response, listitem, const inputtext[]);
public REGISTER_LOGIN_OnDialogResponse(playerid, dialogid, response, listitem, const inputtext[]) {
	switch (dialogid) {
		case DIALOG_LOGIN: 
		{
			if (!response) { return Kick(playerid); }

			new hashedPass[65];
			SHA256_Hash(inputtext, PlayerData[playerid][pSalt], hashedPass, 65);

			if (!strcmp(hashedPass, PlayerData[playerid][pPassword], true)) {

				cache_set_active(PlayerData[playerid][pCacheID]);

				AssignInitialPlayerData(playerid);

				cache_delete(PlayerData[playerid][pCacheID]);

				PlayerData[playerid][pCacheID] = MYSQL_INVALID_CACHE;

				PlayerData[playerid][pIsLoggedIn] = true;

				SetSpawnInfo(playerid, NO_TEAM, 0, 2211.411621, 1237.904663, 10.820312, 269.15, WEAPON_SAWEDOFF, 36, WEAPON_UZI, 150, WEAPON_FIST, 0);
				SpawnPlayer(playerid);

				return 1;
			} else {
				PlayerData[playerid][pLoginAttempts]++;

				if (PlayerData[playerid][pLoginAttempts] >= 3) {
					ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX,
					"Login",
					"Too many failed login attempts!",
					"OK", "");
					return Kick(playerid);
				} else {
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
					"Login",
					"Incorrect password! Try again.",
					"Accept", "Cancel");
				}
			}
		}
		case DIALOG_REGISTER_INPUT_EMAIL: {
			static Regex:regex;
			regex = Regex_New("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$");
			if (strlen(inputtext) > 32 || strlen(inputtext) < 10 || !Regex_Check(inputtext, regex)) {
				return ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_EMAIL, DIALOG_STYLE_INPUT, "E-Mail", ERR_INPUT_EMAIL, "Accept", "Cancel");
			} else {
                SelectTextDraw(playerid, COLOR_WHITE);
				strcopy(pRegisterCacheEmail[playerid], inputtext, 128);

				PlayerTextDrawSetString(playerid, pRegisterMenu_emailTypebox[playerid], inputtext);
				PlayerTextDrawSetString(playerid, pRegisterMenu_emailSymbol[playerid], "LD_CHAT:thumbup");
			}
		}
		case DIALOG_REGISTER_INPUT_AGE: {
			if (strlen(inputtext) <= 0 || strval(inputtext) < 0 || strval(inputtext) > 99) {
				return ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_AGE, DIALOG_STYLE_INPUT, "Age", ERR_INPUT_AGE, "Accept", "Cancel");
			} else {
                SelectTextDraw(playerid, COLOR_WHITE);

				pRegisterCacheAge[playerid] = strval(inputtext);

				PlayerTextDrawSetString(playerid, pRegisterMenu_ageTypebox[playerid], "%d", strval(inputtext));
				PlayerTextDrawSetString(playerid, pRegisterMenu_ageSymbol[playerid], "LD_CHAT:thumbup");
			}
		}
		case DIALOG_REGISTER_INPUT_PASSWORD: {
			if (strlen(inputtext) < 8 || strlen(inputtext) > 32) {
				return ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_PASSWORD, DIALOG_STYLE_PASSWORD, "Password", ERR_INPUT_PASS, "Accept", "Cancel");
			} else {
                SelectTextDraw(playerid, COLOR_WHITE);

				strcopy(pRegisterCachePassword[playerid], inputtext, 32);

				new maskedPassword[32];

				for (new i = 0; i < strlen(inputtext); i++)
				{
					maskedPassword[i] = '|';
				}

				PlayerTextDrawSetString(playerid, pRegisterMenu_passwordTypebox[playerid], maskedPassword);
				PlayerTextDrawSetString(playerid, pRegisterMenu_passwordSymbol[playerid], "LD_CHAT:thumbup");
			}
		}
		case DIALOG_REGISTER_INPUT_REPEAT_PASSWORD: {
			if (strlen(inputtext) < 8 || strlen(inputtext) > 32) {
				return ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_REPEAT_PASSWORD, DIALOG_STYLE_PASSWORD, "Repeat Password", ERR_INPUT_PASS, "Accept", "Cancel");
			} else {
                SelectTextDraw(playerid, COLOR_WHITE);

				strcopy(pRegisterCacheRepeatPassword[playerid], inputtext, 32);

				new maskedPassword[32];

				for (new i = 0; i < strlen(inputtext); i++)
				{
					maskedPassword[i] = '|';
				}

				PlayerTextDrawSetString(playerid, pRegisterMenu_rePassTypebox[playerid], maskedPassword);
				PlayerTextDrawSetString(playerid, pRegisterMenu_rePassSymbol[playerid], "LD_CHAT:thumbup");
			}
		}
	}

    return 1;
}

forward REGISTER_LOGIN_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
public REGISTER_LOGIN_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	if (playertextid == pRegisterMenu_emailTypebox[playerid])
	{
        CancelSelectTextDraw(playerid);
		ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_EMAIL, DIALOG_STYLE_INPUT, "E-Mail", INPUT_EMAIL, "Accept", "Cancel");
		return 1;
	}
	else if (playertextid == pRegisterMenu_ageTypebox[playerid])
	{
        CancelSelectTextDraw(playerid);
		ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_AGE, DIALOG_STYLE_INPUT, "Age", INPUT_AGE, "Accept", "Cancel");
		return 1;
	}
	else if (playertextid == pRegisterMenu_passwordTypebox[playerid])
	{
        CancelSelectTextDraw(playerid);
		ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_PASSWORD, DIALOG_STYLE_PASSWORD, "Password", INPUT_PASS, "Accept", "Cancel");
		return 1;
	}
	else if (playertextid == pRegisterMenu_rePassTypebox[playerid])
	{
        CancelSelectTextDraw(playerid);
		ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_REPEAT_PASSWORD, DIALOG_STYLE_PASSWORD, "Repeat Password", INPUT_PASS, "Accept", "Cancel");
		return 1;
	} 
	else if (playertextid == pRegisterMenu_buttonRegister[playerid])
	{
		if (!pRegisterCacheAge[playerid] || strlen(pRegisterCacheEmail[playerid]) == 0 || strlen(pRegisterCachePassword[playerid]) == 0 || strlen(pRegisterCacheRepeatPassword[playerid]) == 0) {
			ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "Invalid fields", "Please make sure all fields are valid.", "Accept", "");
			return 1;
		} else if (strcmp(pRegisterCachePassword[playerid], pRegisterCacheRepeatPassword[playerid], true) != 0) {
			ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "Passwords don't match", "Please make sure both passwords match.", "Accept", "");
			return 1;
		} else {
			for (new i = 0; i < 16; i++) {
				PlayerData[playerid][pSalt][i] = random(94) + 33;
			}

			SHA256_Hash(pRegisterCachePassword[playerid], PlayerData[playerid][pSalt], PlayerData[playerid][pPassword]);

			new query[221];
			format(query, sizeof(query), "INSERT INTO `users` (`pName`, `pPassword`, `pSalt`, `pEmail`, `pAge`) VALUES ('%s', '%s', '%s', '%s', '%d')", PlayerData[playerid][pName], PlayerData[playerid][pPassword], PlayerData[playerid][pSalt], pRegisterCacheEmail[playerid], pRegisterCacheAge[playerid]);
			mysql_tquery(db, query, "OnPlayerRegistered", "d", playerid);
			
			return 1;
		}
	}
	else if (playertextid == pRegisterMenu_buttonCancel[playerid])
	{
		HideRegisterMenu(playerid);
		DelayKick(playerid);
	}

	return 1;
}

forward REGISTER_LOGIN_OnPlayerDisconnect(playerid, reason);
public REGISTER_LOGIN_OnPlayerDisconnect(playerid, reason) {
	gMySqlRaceCheck[playerid]++;

	if (cache_is_valid(PlayerData[playerid][pCacheID]))
	{
		cache_delete(PlayerData[playerid][pCacheID]);
		PlayerData[playerid][pCacheID] = MYSQL_INVALID_CACHE;
	}

	PlayerData[playerid][pIsLoggedIn] = false;

	Iter_Remove(AdminsOnline, playerid);
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
	PlayerData[playerid][pBannedUntil] = -1;
	PlayerData[playerid][pJob] = -1;

	format(pRegisterCacheEmail[playerid], sizeof(pRegisterCacheEmail[]), "");
	pRegisterCacheAge[playerid] = 0;
	format(pRegisterCachePassword[playerid], sizeof(pRegisterCachePassword[]), "");
	format(pRegisterCacheRepeatPassword[playerid], sizeof(pRegisterCacheRepeatPassword[]), "");

	HideRegisterMenu(playerid);

	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);

	//[POS]: X: 2211.411621 | Y: 1237.904663 | Z: 10.820312 | ROT: 181.238906
	SetSpawnInfo(playerid, NO_TEAM, 0, 2211.411621, 1237.904663, 10.820312, 269.15, WEAPON_SAWEDOFF, 36, WEAPON_UZI, 150, WEAPON_FIST, 0);
	SpawnPlayer(playerid);
	
	return 1;
}

stock AssignInitialPlayerData(playerid) {
	cache_get_value_int(0, "pMoney", PlayerData[playerid][pMoney]);
	cache_get_value_int(0, "pAdmin", PlayerData[playerid][pAdmin]);
	cache_get_value(0, "pEmail", PlayerData[playerid][pEmail], 32);
	cache_get_value_int(0, "pAge", PlayerData[playerid][pAge]);
	cache_get_value_int(0, "pJob", PlayerData[playerid][pJob]);

	Iter_Add(AdminsOnline, playerid);

	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);

	return 1;
}

stock InitializeTempVars(playerid) {
	PlayerData[playerid][pCurrentPickup] = -1;
	PlayerData[playerid][pInHouseID] = -1;
	PlayerData[playerid][pInBusinessID] = -1;
}