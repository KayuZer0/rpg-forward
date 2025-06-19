#include <open.mp>
#include <string>
#include <PawnPlus>
#include "izcmd.inc"
#include "sscanf2.inc"
#include "a_mysql.inc"
#include "timestamp.inc"
#include "Pawn.Regex.inc"
#include <streamer>

new MySQL:db;
new gMySqlRaceCheck[MAX_PLAYERS];

new pRegisterCacheEmail[MAX_PLAYERS][32];
new pRegisterCacheAge[MAX_PLAYERS];
new pRegisterCachePassword[MAX_PLAYERS][32];
new pRegisterCacheRepeatPassword[MAX_PLAYERS][32];

enum _:pData {
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

#include "../gamemodes/modules/globaldefines.inc"

#include "../gamemodes/modules/utils.inc"

#include "../gamemodes/modules/datamanip.inc"

#include "../gamemodes/modules/gui.inc"
#include "../gamemodes/modules/admincmds.inc"
#include "../gamemodes/modules/enex.inc"


main() {
	return 1;
}

public OnGameModeInit() {
	db = mysql_connect("localhost", "root", "", "rpg-forward", MySQLOpt:0);

	if(mysql_errno(db)) { printf(ERR_MYSQL_CONNECT, mysql_errno(db)); return 1; } else { printf(MYSQL_CONNECTED); }

	SetGameModeText("Indev");
	AddPlayerClass(0, 2495.3547, -1688.2319, 13.6774, 351.1646, WEAPON_M4, 500, WEAPON_KNIFE, 1, WEAPON_COLT45, 100);

	DisableInteriorEnterExits();
	InitEnex();

	return 1;
}

public OnPlayerConnect(playerid) {
	REGISTER_LOGIN_OnPlayerConnect(playerid);

	SetPlayerCameraPos(playerid, 1000.0, 1000.0, 50.0);
	SetPlayerCameraLookAt(playerid, 1000.0, 1005.0, 50.0); 

	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	REGISTER_LOGIN_OnPlayerDisconnect(playerid, reason);

	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	return 1;
}

public OnPlayerSpawn(playerid) {
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if (dialogid == DIALOG_INFO) return 1;

	REGISTER_LOGIN_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);

	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	REGISTER_LOGIN_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);

	return 1;
}

public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
	WORLDMANIP_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys);
}

// REGISTER LOGIN

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

forward REGISTER_LOGIN_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
public REGISTER_LOGIN_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
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

	return 1;
}

forward REGISTER_LOGIN_OnPlayerConnect(playerid);
public REGISTER_LOGIN_OnPlayerConnect(playerid) {
	gMySqlRaceCheck[playerid]++;

	static const EMPTY_PLAYER[pData];
	PlayerData[playerid] = EMPTY_PLAYER;

	GetPlayerName(playerid, PlayerData[playerid][pName], MAX_PLAYER_NAME);

	new query[256];

	format(query, sizeof(query), "SELECT * FROM users WHERE pName = '%s' LIMIT 1", PlayerData[playerid][pName]);
	mysql_tquery(db, query, "OnPlayerDataLoaded", "dd", playerid, gMySqlRaceCheck[playerid]);
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
}