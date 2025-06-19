#include <open.mp>
#include <string>
#include <PawnPlus>
#include "izcmd.inc"
#include "sscanf2.inc"
#include "a_mysql.inc"
#include "timestamp.inc"
#include "Pawn.Regex.inc"
#include <streamer>

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

#define KEY_PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define KEY_RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

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

#include <utils>
#include <datamanip>
#include <gui>
#include <admincmds>
#include <worldmanip>

main() {
	//new data[][] = {"pBannedBy", "pBanReason"};
	//new values[2][128]; values[0] = "authorName"; values[1][0] = 0; values[1][1] = 1;
	//SetPlayerDataArray(0, data, values, "si", {0,2}, sizeof(data));

	return 1;
}

public OnGameModeInit() {
	DisableInteriorEnterExits();

	db = mysql_connect("localhost", "root", "", "rpg-forward", MySQLOpt:0);

	if(mysql_errno(db)) {
		printf("** [MySQL] Couldn't connect to the database (%d).", mysql_errno(db));
		return 1;
	}

	printf("MYSQL CONNECTION SUCCESSFUL!");

	InitEnex();

	SetGameModeText("Indev");
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

	format(query, sizeof(query), "SELECT * FROM users WHERE pName = '%s' LIMIT 1", PlayerData[playerid][pName]);
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

	return 0;
}

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
	WORLDMANIP_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys);
}
