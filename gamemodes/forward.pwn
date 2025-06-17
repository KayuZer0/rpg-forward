#include <open.mp>
#include <string>
#include <PawnPlus>
#include "izcmd.inc"
#include "sscanf2.inc"
#include "a_mysql.inc"
#include "timestamp.inc"
#include "Pawn.Regex.inc"

#define COLOR_ERROR         0xC0241FFF
#define COLOR_DARKNICERED 	0x9D000096
#define TEAM_RADIO_COLOR 	0xF2D068FF
#define COLOR_LIGHTGREEN 	0x9ACD32AA
#define COLOR_CHATBUBBLE    0xFFFFFFCC
#define COLOR_LIGHTBLUE 	0x00C3FFFF
#define COLOR_LIGHTRED 		0xFF6347FF
#define COLOR_LGREEN 		0xD7FFB3FF
#define COLOR_ORANGE        0xFFA500FF
#define COLOR_GOLD          0xFFB95EFF
#define COLOR_LIGHTGOLD 	0xFCD482FF
#define COLOR_MONEY 		0x4dad2bFF
#define COLOR_CLIENT        0xA9C4E4FF
#define COLOR_SERVER        0x5F9CC9FF
#define COLOR_WARNING 		0xDE1414FF
#define COLOR_ADMCHAT 		0xFFC266AA
#define COLOR_GRAD1 		0xB4B5B7FF
#define COLOR_GRAD2 		0xBFC0C2FF
#define COLOR_GRAD3 		0xCBCCCEFF
#define COLOR_GRAD4 		0xD8D8D8FF
#define COLOR_GRAD5 		0xE3E3E3FF
#define COLOR_GRAD6 		0xF0F0F0FF
#define COLOR_GREY 			0xAFAFAFAA
#define COLOR_GREEN 		0x33AA33AA
#define COLOR_RED 			0xFF0000FF
#define COLOR_NEWS 			0xFFA500AA
#define COLOR_LOGIN 		0x00D269FF
#define COLOR_DEPAR 		0x4646FFFF
#define COLOR_YELLOW 		0xFFFF00FF
#define COLOR_WHITE 		0xFFFFFFFF
#define COLOR_FADE1 		0xE6E6E6E6
#define COLOR_FADE2 		0xC8C8C8C8
#define COLOR_FADE3 		0xAAAAAAAA
#define COLOR_FADE4 		0x8C8C8C8C
#define COLOR_FADE5 		0x6E6E6E6E
#define COLOR_PURPLE 		0xC2A2DAAA
#define COLOR_DBLUE 		0x2641FEAA
#define COLOR_ALLDEPT 		0xFF8282AA
#define COLOR_NEWS 			0xFFA500AA
#define COLOR_DEPART 		0xFF8040FF
#define COLOR_DEPART2 		0xff3535FF
#define COLOR_LOGS 			0xE6833CFF
#define COLOR_BLUE      	0x211CDEC8
#define COLOR_DARKPINK      0xE7AAA5A5
#define COLOR_DGREEN    	0xAAFF82FF
#define COLOR_TUTORIAL      0x2CBD7AFF
#define COLOR_NICEGREEN     0x8DDE00FF

#define DIALOG_INFO 0
#define DIALOG_REGISTER_INPUT_EMAIL 1
#define DIALOG_REGISTER_INPUT_AGE 2
#define DIALOG_REGISTER_INPUT_PASSWORD 3
#define DIALOG_REGISTER_INPUT_REPEAT_PASSWORD 4
#define DIALOG_LOGIN 5

#define DEFAULT_MONEY 100000
#define DEFAULT_ADMIN 0

#define MAX_ADMIN_LEVEL 7

#define ERR_ADMIN_LEVEL "[ERROR]: You are not authorized to use that command."
#define ERR_NOT_ON_YOURSELF "[ERROR]: You can't use that command on yourself."
#define ERR_NO_PLAYER_FOUND "[ERROR]: No player found."
#define ERR_INVALID_VALUE "[ERROR]: Invalid value."

new PlayerText: pRegisterMenu_email[MAX_PLAYERS];
new PlayerText: pRegisterMenu_age[MAX_PLAYERS];
new PlayerText: pRegisterMenu_password[MAX_PLAYERS];
new PlayerText: pRegisterMenu_rePass[MAX_PLAYERS];

new PlayerText: pRegisterMenu_emailSymbol[MAX_PLAYERS];
new PlayerText: pRegisterMenu_ageSymbol[MAX_PLAYERS];
new PlayerText: pRegisterMenu_passwordSymbol[MAX_PLAYERS];
new PlayerText: pRegisterMenu_rePassSymbol[MAX_PLAYERS];

new PlayerText: pRegisterMenu_emailTypebox[MAX_PLAYERS];
new PlayerText: pRegisterMenu_ageTypebox[MAX_PLAYERS];
new PlayerText: pRegisterMenu_passwordTypebox[MAX_PLAYERS];
new PlayerText: pRegisterMenu_rePassTypebox[MAX_PLAYERS];

new PlayerText: pRegisterMenu_buttonRegister[MAX_PLAYERS];
new PlayerText: pRegisterMenu_buttonCancel[MAX_PLAYERS];

new pRegisterCacheEmail[MAX_PLAYERS][32];
new pRegisterCacheAge[MAX_PLAYERS];
new pRegisterCachePassword[MAX_PLAYERS][32];
new pRegisterCacheRepeatPassword[MAX_PLAYERS][32];

new MySQL:db;

enum _:moneyOperations {
	add,
	set
};

enum _:pDataTypes {
	data_int,
	data_float,
	data_bool,
	data_array,
	data_string
};

enum _:pData
{
	bool: pIsLoggedIn,
	pLoginAttempts,
	pLoginTimer,

	pName[MAX_PLAYER_NAME],
	pEmail[32],
	pAge,
	pPassword[65],
	pSalt[17],
	Cache: pCacheID,

	pBannedUntil,
	pBannedBy[MAX_PLAYER_NAME],
	pBanReason[128],

	pAdmin,
	pMoney,
};
new PlayerData[MAX_PLAYERS][pData];
new gMySqlRaceCheck[MAX_PLAYERS];

main() {
	new data2[][] = {"pEmail", "pBanReason"};
	new values2[][] = {{1, 1, 3, 7}, "Nigga"};
	SetPlayerDataArrayTwo(0, data2, values2, "is", "42", sizeof(data2));

	return 1;
}

public OnGameModeInit() {

	db = mysql_connect("localhost", "root", "", "rpg-forward", MySQLOpt:0);

	if(mysql_errno(db)) {
		printf("** [MySQL] Couldn't connect to the database (%d).", mysql_errno(db));
		return 1;
	}

	printf("MYSQL CONNECTION SUCCESSFUL!");

	SetGameModeText("Crazy bomboclat!");
	AddPlayerClass(0, 2495.3547, -1688.2319, 13.6774, 351.1646, WEAPON_M4, 500, WEAPON_KNIFE, 1, WEAPON_COLT45, 100);
	return 1;
}

public OnPlayerConnect(playerid) {
	gMySqlRaceCheck[playerid]++;

	static const EMPTY_PLAYER[pData];
	PlayerData[playerid] = EMPTY_PLAYER;

	GetPlayerName(playerid, PlayerData[playerid][pName], MAX_PLAYER_NAME);

	SetPlayerCameraPos(playerid, 1000.0, 1000.0, 50.0);
	SetPlayerCameraLookAt(playerid, 1000.0, 1005.0, 50.0); 

	new query[256];

	format(query, sizeof(query), "SELECT * FROM users WHERE name = '%s' LIMIT 1", PlayerData[playerid][pName]);
	mysql_tquery(db, query, "OnPlayerDataLoaded", "dd", playerid, gMySqlRaceCheck[playerid]);

	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	gMySqlRaceCheck[playerid]++;

	if (cache_is_valid(PlayerData[playerid][pCacheID]))
	{
		cache_delete(PlayerData[playerid][pCacheID]);
		PlayerData[playerid][pCacheID] = MYSQL_INVALID_CACHE;
	}

	PlayerData[playerid][pIsLoggedIn] = false;

	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	return 1;
}

public OnPlayerSpawn(playerid) {
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	switch (dialogid) {

		case DIALOG_INFO: return 1;

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

				SetSpawnInfo(playerid, NO_TEAM, 0, 1958.33, 1343.12, 15.36, 269.15, WEAPON_SAWEDOFF, 36, WEAPON_UZI, 150, WEAPON_FIST, 0);
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
				return ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_EMAIL, DIALOG_STYLE_INPUT, "E-Mail", "Invalid input! Please input email address.", "Accept", "Cancel");
			} else {
				strcopy(pRegisterCacheEmail[playerid], inputtext, 128);

				PlayerTextDrawSetString(playerid, pRegisterMenu_emailTypebox[playerid], inputtext);
				PlayerTextDrawSetString(playerid, pRegisterMenu_emailSymbol[playerid], "LD_CHAT:thumbup");
			}
		}
		case DIALOG_REGISTER_INPUT_AGE: {
			if (strlen(inputtext) <= 0 || strval(inputtext) < 0 || strval(inputtext) > 99) {
				return ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_AGE, DIALOG_STYLE_INPUT, "Age", "Invalid input! Please input your age.", "Accept", "Cancel");
			} else {
				pRegisterCacheAge[playerid] = strval(inputtext);

				PlayerTextDrawSetString(playerid, pRegisterMenu_ageTypebox[playerid], "%d", strval(inputtext));
				PlayerTextDrawSetString(playerid, pRegisterMenu_ageSymbol[playerid], "LD_CHAT:thumbup");
			}
		}
		case DIALOG_REGISTER_INPUT_PASSWORD: {
			if (strlen(inputtext) < 5 || strlen(inputtext) > 32) {
				return ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_PASSWORD, DIALOG_STYLE_PASSWORD, "Password", "Invalid input! Please input your password.", "Accept", "Cancel");
			} else {
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
			if (strlen(inputtext) < 5 || strlen(inputtext) > 32) {
				return ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_REPEAT_PASSWORD, DIALOG_STYLE_PASSWORD, "Repeat Password", "Invalid input! Please input your password again.", "Accept", "Cancel");
			} else {
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

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {

	if (playertextid == pRegisterMenu_emailTypebox[playerid])
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_EMAIL, DIALOG_STYLE_INPUT, "E-Mail", "Please input your E-mail address.", "Accept", "Cancel");
		return 1;
	}
	else if (playertextid == pRegisterMenu_ageTypebox[playerid])
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_AGE, DIALOG_STYLE_INPUT, "Age", "Please input your age.", "Accept", "Cancel");
		return 1;
	}
	else if (playertextid == pRegisterMenu_passwordTypebox[playerid])
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_PASSWORD, DIALOG_STYLE_PASSWORD, "Password", "Please input your password.", "Accept", "Cancel");
		return 1;
	}
	else if (playertextid == pRegisterMenu_rePassTypebox[playerid])
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER_INPUT_REPEAT_PASSWORD, DIALOG_STYLE_PASSWORD, "Repeat Password", "Please input your password again.", "Accept", "Cancel");
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
			format(query, sizeof(query), "INSERT INTO `users` (`name`, `password`, `salt`, `email`, `age`) VALUES ('%s', '%s', '%s', '%s', '%d')", PlayerData[playerid][pName], PlayerData[playerid][pPassword], PlayerData[playerid][pSalt], pRegisterCacheEmail[playerid], pRegisterCacheAge[playerid]);
			mysql_tquery(db, query, "OnPlayerRegistered", "d", playerid);
			
			return 1;
		}
	}
	else if (playertextid == pRegisterMenu_buttonCancel[playerid])
	{
		HideRegisterMenu(playerid);
		DelayKick(playerid);
	}

	return 0;
}

CMD:testset(playerid, params[]) {
	return 1;
}

CMD:testget(playerid, params[]){
	SendClientMessage(playerid, COLOR_ORANGE, "%d", PlayerData[playerid][pAdmin]);
	return 1;
}

CMD:givemoney(playerid, params[]) {
	new targetid, money;

	new authorName[MAX_PLAYER_NAME];
	new targetName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, authorName, sizeof(authorName));
	GetPlayerName(targetid, targetName, sizeof(targetName));

	if (!HasAdminLevel(playerid, 5)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	if (sscanf(params, "ii", targetid, money)){
		SendClientMessage(playerid, 0xFF4444AA, "[USAGE]: /givemoney <id> <amount>");
		return 1;
	}

	if (!IsPlayerConnected(targetid)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_NO_PLAYER_FOUND);
		return 1;
	}

	if (money > 999999999 || (PlayerData[targetid][pMoney] <= 0 && money < 0) || money == 0) {SendClientMessage(playerid, 0xFF4444AA, ERR_INVALID_VALUE); return 1;}

	ChangePlayerMoney(playerid, money, add);

	if (money < 0) {
		SendClientMessage(playerid, 0xFFA500AA, "You took $%d from player %s.", abs(money), targetName);
		SendClientMessage(targetid, 0xFFA500AA, "Admin %s took $%d from you.", authorName, abs(money));
	} else {
		SendClientMessage(playerid, 0xFFA500AA, "You gave $%d to player %s.", money, targetName);
		SendClientMessage(targetid, 0xFFA500AA, "Admin %s gave you $%d.", authorName, money);
	}


	return 1;
}

CMD:ban(playerid, params[]) {
	new targetid, duration, reason[128];

	new authorName[MAX_PLAYER_NAME];
	new targetName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, authorName, sizeof(authorName));
	GetPlayerName(targetid, targetName, sizeof(targetName));

	if (!HasAdminLevel(playerid, 1)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	if (sscanf(params, "iis[128]", targetid, duration, reason)){
		SendClientMessage(playerid, 0xFF4444AA, "[USAGE]: /ban <id> <days (0 = permanent)> <reason>");
		return 1;
	}

	if (!IsPlayerConnected(targetid)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_NO_PLAYER_FOUND);
		return 1;
	}

	if (duration < 0) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_INVALID_VALUE);
		return 1;
	}

	if (duration == 0) {
		SendClientMessageToAll(COLOR_DARKNICERED, "Player %s was banned by Admin %s. Reason: %s", targetName, authorName, reason);

		new data[][] = {"pBannedUntil"};
		new values[] = {-1};
		SetPlayerData(playerid, data, values, sizeof(data));
	} else {
		new bannedUntil = gettime() + (duration * 86400);

		new data[][] = {"pBannedUntil"};
		new values[1]; values[0] = bannedUntil;
		SetPlayerData(playerid, data, values, sizeof(data));
		SendClientMessageToAll(COLOR_DARKNICERED, "Player %s was banned by Admin %s for %d days. Reason: %s", targetName, authorName, duration, reason);
	}

	SetPlayerDataArray(targetid, pBannedBy, "banned_by", authorName, sizeof(authorName), data_string);
	SetPlayerDataArray(targetid, pBanReason, "ban_reason", reason, sizeof(authorName), data_string);

	Kick(targetid);

	return 1;
}

CMD:kick(playerid, params[]) {
	new targetid, reason[128];

	new authorName[MAX_PLAYER_NAME];
	new targetName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, authorName, sizeof(authorName));
	GetPlayerName(targetid, targetName, sizeof(targetName));

	if (!HasAdminLevel(playerid, 1)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	if (sscanf(params, "is[128]", targetid, reason)){
		SendClientMessage(playerid, 0xFF4444AA, "[USAGE]: /kick <id> <reason>");
		return 1;
	}

	if (!IsPlayerConnected(targetid)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_NO_PLAYER_FOUND);
		return 1;
	}

	SendClientMessageToAll(COLOR_DARKNICERED, "Player %s was kicked by Admin %s. Reason: %s", targetName, authorName, reason);
	Kick(targetid);

	return 1;
}

CMD:clearchat(playerid, params[]) {
	new authorName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, authorName, sizeof(authorName));

	if (!HasAdminLevel(playerid, 1)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	for (new i = 0; i < 254; i++) {
		SendClientMessageToAll(COLOR_WHITE, "");
	}

	SendClientMessageToAll(0xFFA500AA, "Admin %s cleared the chat.", authorName);

	return 1;
}

CMD:a(playerid, params[]) {
	new authorName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, authorName, sizeof(authorName));

	if (!HasAdminLevel(playerid, 1)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	if (strlen(params) > 0){
		for (new i = 0; i < MAX_PLAYERS; i++) {
			if (IsPlayerConnected(i)) {
				if (PlayerData[i][pAdmin] > 0) {
					SendClientMessage(i, COLOR_DARKNICERED, "(/a) Admin %s: {FF5733}%s", authorName, params);
					return 1;
				}
			}
		}
	} else {
		SendClientMessage(playerid, 0xFF4444AA, "[USAGE]: /a <message>");
		return 1;
	}

	return 1;
}

CMD:setmoney(playerid, params[]) {
	new targetid, money;

	new authorName[MAX_PLAYER_NAME];
	new targetName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, authorName, sizeof(authorName));
	GetPlayerName(targetid, targetName, sizeof(targetName));

	if (!HasAdminLevel(playerid, 5)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	if (sscanf(params, "ii", targetid, money)){
		SendClientMessage(playerid, 0xFF4444AA, "[USAGE]: /setmoney <id> <amount>");
		return 1;
	}

	if (!IsPlayerConnected(targetid)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_NO_PLAYER_FOUND);
		return 1;
	}

	if (money > 999999999 || money < 0) {SendClientMessage(playerid, 0xFF4444AA, ERR_INVALID_VALUE); return 1;}

	ChangePlayerMoney(playerid, money, set);

	SendClientMessage(playerid, 0xFFA500AA, "You set %s's money to $%d.", targetName, money);
	SendClientMessage(targetid, 0xFFA500AA, "Admin %s set your money to $%d.", authorName, money);

	return 1;
}

CMD:setadmin(playerid, params[]) {
	new targetid, level;

	new authorName[MAX_PLAYER_NAME];
	new targetName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, authorName, sizeof(authorName));
	GetPlayerName(targetid, targetName, sizeof(targetName));

	if (!HasAdminLevel(playerid, 7)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	if (sscanf(params, "ii", targetid, level)){
		SendClientMessage(playerid, 0xFF4444AA, "[USAGE]: /setadmin <id> <level>");
		return 1;
	}

	if (playerid == targetid) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_NOT_ON_YOURSELF);
		return 1;
	}

	if (!IsPlayerConnected(targetid)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_NO_PLAYER_FOUND);
		return 1;
	}

	if (level > MAX_ADMIN_LEVEL || level < 0) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_INVALID_VALUE);
		return 1;
	}

	new data[][] = {"pAdmin"};
	new values[1]; values[0] = level;
	SetPlayerData(playerid, data, values, sizeof(data));

	SendClientMessage(playerid, 0xFFA500AA, "You set %s's Admin Level to %d.", targetName, level);
	SendClientMessage(targetid, 0xFFA500AA, "Admin %s set your Admin Level to %d.", authorName, level);

	return 1;

}

CMD:reloaduser(playerid, params[]) {
	new targetid;

	if (!HasAdminLevel(playerid, 0)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	if (sscanf(params, "i", targetid)){
		SendClientMessage(playerid, 0xFF4444AA, "[USAGE]: /reloaduser <id>");
		return 1;
	}

	new query[256];
	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(targetid, playerName, sizeof(playerName));
	format(query, sizeof(query), "SELECT * FROM users WHERE name = '%s' LIMIT 1", playerName);
	mysql_tquery(db, query, "OnConnectPullDBValues", "i", playerid);
	SendClientMessage(playerid, 0xFFFFFFAA, "Requested data.");

	return 1;
}

CMD:spawncar(playerid, params[]) {
	new vehicleid, color1, color2;

	if (!HasAdminLevel(playerid, 3)) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_ADMIN_LEVEL);
		return 1;
	}

	if (sscanf(params, "iii", vehicleid, color1, color2)){
		SendClientMessage(playerid, 0xFF4444AA, "[USAGE]: /spawncar <id> <color1> <color2>");
		return 1;
	}

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	new spawnedCar = CreateVehicle(vehicleid, x, y, z, a, color1, color2, -1, false);

	PutPlayerInVehicle(playerid, spawnedCar, 0);

	SendClientMessage(playerid, 0xFFA500AA, "Ti-am spawnat bolidu' cumetre. Cu placere se spune.");

	return 1;
}

stock AssignInitialPlayerData(playerid) {

	cache_get_value_int(0, "money", PlayerData[playerid][pMoney]);
	cache_get_value_int(0, "pAdmin", PlayerData[playerid][pAdmin]);

	GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);

	return 1;
}

stock SetPlayerData(playerid, data[][], values[], dataSize) {
	new bufferDataStr[256];
	new bufferValueStr[256];

	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));

	for (new i = 0; i < dataSize; i++) {
		SendClientMessage(playerid, COLOR_ORANGE, data[i]);

		new trueData = FieldFromName(data[i]);
		PlayerData[playerid][trueData] = values[i];

        format(bufferDataStr, sizeof(bufferDataStr), "%s`%s`%s",
            bufferDataStr,
            data[i],
            (i < dataSize - 1) ? ", " : "");

		// if (is int) {}
        if (values[i] == floatround(values[i], floatround_ceil)) {
			printf("IS INT");
			format(bufferValueStr, sizeof(bufferValueStr), "%s%d%s",
				bufferValueStr,
				values[i],
				(i < dataSize - 1) ? ", " : "");
		} else {
			printf("IS NOT INT");
			format(bufferValueStr, sizeof(bufferValueStr), "%s%f%s",
				bufferValueStr,
				Float: values[i],
				(i < dataSize - 1) ? ", " : "");
		}
	}

	new query[256];
	format(query, sizeof(query), "UPDATE users SET (%s) = (%s) WHERE name = '%s'", bufferDataStr, bufferValueStr, playerName);
	printf(query);
	//mysql_tquery(db, query, "OnPlayerDataSet", "i", playerid);
	return 1;
}

stock SetPlayerDataArrayTwo(playerid, data[][], values[][], const valueTypes[], const valueSizes[], dataSize) {
	new bufferDataStr[256];
	new bufferValueStr[256];
	new arrToStr[32];

	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));

	for (new i = 0; i < dataSize; i++) {
		SendClientMessage(playerid, COLOR_ORANGE, data[i]);

		new trueData = FieldFromName(data[i]);
		PlayerData[playerid][trueData] = values[i][0];

        format(bufferDataStr, sizeof(bufferDataStr), "%s`%s`%s",
            bufferDataStr,
            data[i],
            (i < dataSize - 1) ? ", " : "");

		// if (is int) {}
        if (valueTypes[i] == 's') {
			format(bufferValueStr, sizeof(bufferValueStr), "%s%s%s",
				bufferValueStr,
				values[i],
				(i < dataSize - 1) ? ", " : "");
		} else {
			
			ArrayToString(values[i], valueSizes[i] - '0', arrToStr, sizeof(arrToStr));
			printf("Array to string: %s", arrToStr);

			format(bufferValueStr, sizeof(bufferValueStr), "%s%s%s",
				bufferValueStr,
				arrToStr,
				(i < dataSize - 1) ? ", " : "");
		}
	}

	new query[256];
	format(query, sizeof(query), "UPDATE users SET (%s) = (%s) WHERE name = '%s'", bufferDataStr, bufferValueStr, playerName);
	printf(query);
	//mysql_tquery(db, query, "OnPlayerDataSet", "i", playerid);
	return 1;
}

forward OnPlayerDataLoaded(playerid, racecheck);
public OnPlayerDataLoaded(playerid, racecheck) {
	if (racecheck != gMySqlRaceCheck[playerid]) { return Kick(playerid); }

	cache_get_value_int(0, "banned_until", PlayerData[playerid][pBannedUntil]);
	cache_get_value(0, "banned_by", PlayerData[playerid][pBannedBy], MAX_PLAYER_NAME);
	cache_get_value(0, "ban_reason", PlayerData[playerid][pBanReason], 128);
	cache_get_value(0, "email", PlayerData[playerid][pEmail], 32);
	cache_get_value_int(0, "age", PlayerData[playerid][pAge]);

	printf("%d", PlayerData[playerid][pBannedUntil]);
	printf(PlayerData[playerid][pBannedBy]);
	printf(PlayerData[playerid][pBanReason]);
	if (PlayerData[playerid][pBannedUntil] != 0) 
	{
		new bannedUntilString[128];

		if (PlayerData[playerid][pBannedUntil] == -1) 
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
		cache_get_value(0, "password", PlayerData[playerid][pPassword], 65);
		cache_get_value(0, "salt", PlayerData[playerid][pSalt], 17);

		printf(PlayerData[playerid][pPassword]);
		printf(PlayerData[playerid][pSalt]);

		PlayerData[playerid][pCacheID] = cache_save();

		format(dialog, sizeof dialog, "This account (%s) is registered. \nPlease login by entering your password in the field below:", PlayerData[playerid][pName]);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", dialog, "Login", "Cancel");

	} else {
		ShowRegisterMenu(playerid);
		//format(dialog, sizeof dialog, "Welcome %s, you can register by entering your password in the field below:", PlayerData[playerid][pName]);
		//ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", dialog, "Register", "Cancel");
	}

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

stock DebugArray(const any:arr[], size, const name[] = "value") {
    printf("Debugging %s:", name);
    for (new i = 0; i < size; i++)
    {
        printf("%s[%d] = %d", name, i, arr[i]);
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

/*stock FormatArrayToString(const arr[], size, dest[], destSize){
    strcopy(dest, "[", destSize);
	//strcopy(dest[], const source[], maxlength = sizeof (dest)) // start with the opening bracket

    for (new i = 0; i < size; i++)
    {
        new tmp[12]; // enough to hold an int
        format(tmp, sizeof(tmp), "%d", arr[i]);
        strcat(dest, tmp, destSize);

        if (i < size - 1)
        {
            strcat(dest, ", ", destSize); // comma and space
        }
    }

    strcat(dest, "]", destSize);
	
	return 1;
}*/

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

stock ShowRegisterMenu(playerid) {
	pRegisterMenu_email[playerid] = CreatePlayerTextDraw(playerid, 222.000, 73.000, "E-mail Address:");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_email[playerid], 0.300, 1.500);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_email[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_email[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_email[playerid], true);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_email[playerid], true);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_email[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_email[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_email[playerid], true);

	pRegisterMenu_ageTypebox[playerid] = CreatePlayerTextDraw(playerid, 225.000, 151.000, "Click to enter text");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_ageTypebox[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_ageTypebox[playerid], 400.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_ageTypebox[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_ageTypebox[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_ageTypebox[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_ageTypebox[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_ageTypebox[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_ageTypebox[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_ageTypebox[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_ageTypebox[playerid], t_TEXT_DRAW_FONT:1);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_ageTypebox[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_ageTypebox[playerid], true);

	pRegisterMenu_emailTypebox[playerid] = CreatePlayerTextDraw(playerid, 225.000, 98.000, "Click to enter text");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_emailTypebox[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_emailTypebox[playerid], 400.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_emailTypebox[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_emailTypebox[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_emailTypebox[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_emailTypebox[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_emailTypebox[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_emailTypebox[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_emailTypebox[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_emailTypebox[playerid], t_TEXT_DRAW_FONT:1);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_emailTypebox[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_emailTypebox[playerid], true);

	pRegisterMenu_emailSymbol[playerid] = CreatePlayerTextDraw(playerid, 196.000, 95.000, "LD_CHAT:thumbdn");
	PlayerTextDrawTextSize(playerid, pRegisterMenu_emailSymbol[playerid], 20.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_emailSymbol[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_emailSymbol[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_emailSymbol[playerid], 0);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_emailSymbol[playerid], 0);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_emailSymbol[playerid], 255);
	PlayerTextDrawFont(playerid, pRegisterMenu_emailSymbol[playerid], t_TEXT_DRAW_FONT:4);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_emailSymbol[playerid], true);

	pRegisterMenu_ageSymbol[playerid] = CreatePlayerTextDraw(playerid, 196.000, 148.000, "LD_CHAT:thumbdn");
	PlayerTextDrawTextSize(playerid, pRegisterMenu_ageSymbol[playerid], 20.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_ageSymbol[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_ageSymbol[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_ageSymbol[playerid], 0);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_ageSymbol[playerid], 0);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_ageSymbol[playerid], 255);
	PlayerTextDrawFont(playerid, pRegisterMenu_ageSymbol[playerid], t_TEXT_DRAW_FONT:4);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_ageSymbol[playerid], true);

	pRegisterMenu_passwordTypebox[playerid] = CreatePlayerTextDraw(playerid, 225.000, 201.000, "Click to enter text");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_passwordTypebox[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_passwordTypebox[playerid], 400.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_passwordTypebox[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_passwordTypebox[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_passwordTypebox[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_passwordTypebox[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_passwordTypebox[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_passwordTypebox[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_passwordTypebox[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_passwordTypebox[playerid], t_TEXT_DRAW_FONT:1);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_passwordTypebox[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_passwordTypebox[playerid], true);

	pRegisterMenu_passwordSymbol[playerid] = CreatePlayerTextDraw(playerid, 196.000, 198.000, "LD_CHAT:thumbdn");
	PlayerTextDrawTextSize(playerid, pRegisterMenu_passwordSymbol[playerid], 20.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_passwordSymbol[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_passwordSymbol[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_passwordSymbol[playerid], 0);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_passwordSymbol[playerid], 0);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_passwordSymbol[playerid], 255);
	PlayerTextDrawFont(playerid, pRegisterMenu_passwordSymbol[playerid], t_TEXT_DRAW_FONT:4);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_passwordSymbol[playerid], true);

	pRegisterMenu_rePassTypebox[playerid] = CreatePlayerTextDraw(playerid, 225.000, 258.000, "Click to enter text");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_rePassTypebox[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_rePassTypebox[playerid], 400.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_rePassTypebox[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_rePassTypebox[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_rePassTypebox[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_rePassTypebox[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_rePassTypebox[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_rePassTypebox[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_rePassTypebox[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_rePassTypebox[playerid], t_TEXT_DRAW_FONT:1);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_rePassTypebox[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_rePassTypebox[playerid], true);

	pRegisterMenu_rePassSymbol[playerid] = CreatePlayerTextDraw(playerid, 196.000, 255.000, "LD_CHAT:thumbdn");
	PlayerTextDrawTextSize(playerid, pRegisterMenu_rePassSymbol[playerid], 20.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_rePassSymbol[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_rePassSymbol[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_rePassSymbol[playerid], 0);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_rePassSymbol[playerid], 0);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_rePassSymbol[playerid], 255);
	PlayerTextDrawFont(playerid, pRegisterMenu_rePassSymbol[playerid], t_TEXT_DRAW_FONT:4);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_rePassSymbol[playerid], true);

	pRegisterMenu_buttonRegister[playerid] = CreatePlayerTextDraw(playerid, 264.000, 309.000, "Register");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_buttonRegister[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_buttonRegister[playerid], 400.000, 70.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_buttonRegister[playerid], TEXT_DRAW_ALIGN_CENTER);
	PlayerTextDrawColour(playerid, pRegisterMenu_buttonRegister[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_buttonRegister[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_buttonRegister[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_buttonRegister[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_buttonRegister[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_buttonRegister[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_buttonRegister[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_buttonRegister[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_buttonRegister[playerid], true);

	pRegisterMenu_age[playerid] = CreatePlayerTextDraw(playerid, 222.000, 129.000, "Your age:");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_age[playerid], 0.300, 1.500);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_age[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_age[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_age[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_age[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_age[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_age[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_age[playerid], true);

	pRegisterMenu_password[playerid] = CreatePlayerTextDraw(playerid, 222.000, 178.000, "Choose a password:");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_password[playerid], 0.300, 1.500);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_password[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_password[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_password[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_password[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_password[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_password[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_password[playerid], true);

	pRegisterMenu_rePass[playerid] = CreatePlayerTextDraw(playerid, 222.000, 236.000, "Repeat Password:");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_rePass[playerid], 0.300, 1.500);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_rePass[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_rePass[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_rePass[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_rePass[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_rePass[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_rePass[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_rePass[playerid], true);

	pRegisterMenu_buttonCancel[playerid] = CreatePlayerTextDraw(playerid, 362.000, 309.000, "Cancel");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_buttonCancel[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_buttonCancel[playerid], 500.000, 70.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_buttonCancel[playerid], TEXT_DRAW_ALIGN_CENTER);
	PlayerTextDrawColour(playerid, pRegisterMenu_buttonCancel[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_buttonCancel[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_buttonCancel[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_buttonCancel[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_buttonCancel[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_buttonCancel[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_buttonCancel[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_buttonCancel[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_buttonCancel[playerid], true);

	PlayerTextDrawShow(playerid, pRegisterMenu_email[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_age[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_password[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_rePass[playerid]);

	PlayerTextDrawShow(playerid, pRegisterMenu_emailSymbol[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_ageSymbol[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_passwordSymbol[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_rePassSymbol[playerid]);

	PlayerTextDrawShow(playerid, pRegisterMenu_emailTypebox[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_ageTypebox[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_passwordTypebox[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_rePassTypebox[playerid]);

	PlayerTextDrawShow(playerid, pRegisterMenu_buttonRegister[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_buttonCancel[playerid]);

	SelectTextDraw(playerid, COLOR_WHITE);

}

stock HideRegisterMenu(playerid) {
	PlayerTextDrawHide(playerid, pRegisterMenu_email[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_age[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_password[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_rePass[playerid]);

	PlayerTextDrawHide(playerid, pRegisterMenu_emailSymbol[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_ageSymbol[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_passwordSymbol[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_rePassSymbol[playerid]);

	PlayerTextDrawHide(playerid, pRegisterMenu_emailTypebox[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_ageTypebox[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_passwordTypebox[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_rePassTypebox[playerid]);

	PlayerTextDrawHide(playerid, pRegisterMenu_buttonRegister[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_buttonCancel[playerid]);

	pRegisterMenu_email[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_age[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_password[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_rePass[playerid] = INVALID_PLAYER_TEXT_DRAW;

	pRegisterMenu_emailSymbol[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_ageSymbol[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_passwordSymbol[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_rePassSymbol[playerid] = INVALID_PLAYER_TEXT_DRAW;

	pRegisterMenu_emailTypebox[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_ageTypebox[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_passwordTypebox[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_rePassTypebox[playerid] = INVALID_PLAYER_TEXT_DRAW;

	pRegisterMenu_buttonRegister[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_buttonCancel[playerid] = INVALID_PLAYER_TEXT_DRAW;

	CancelSelectTextDraw(playerid);
}

stock HasAdminLevel(playerid, minimumLevel) {
	return PlayerData[playerid][pAdmin] >= minimumLevel;
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

// Auto-generated by tools/compilefields.py
stock FieldFromName(const fieldName[]) {
    if (!strcmp(fieldName, "pIsLoggedIn", true)) return pIsLoggedIn;
    if (!strcmp(fieldName, "pLoginAttempts", true)) return pLoginAttempts;
    if (!strcmp(fieldName, "pLoginTimer", true)) return pLoginTimer;
    if (!strcmp(fieldName, "pName", true)) return pName;
    if (!strcmp(fieldName, "pEmail", true)) return pEmail;
    if (!strcmp(fieldName, "pAge", true)) return pAge;
    if (!strcmp(fieldName, "pPassword", true)) return pPassword;
    if (!strcmp(fieldName, "pSalt", true)) return pSalt;
    if (!strcmp(fieldName, "pCacheID", true)) return pCacheID;
    if (!strcmp(fieldName, "pBannedUntil", true)) return pBannedUntil;
    if (!strcmp(fieldName, "pBannedBy", true)) return pBannedBy;
    if (!strcmp(fieldName, "pBanReason", true)) return pBanReason;
    if (!strcmp(fieldName, "pAdmin", true)) return pAdmin;
    if (!strcmp(fieldName, "pMoney", true)) return pMoney;
    return -1;
}
