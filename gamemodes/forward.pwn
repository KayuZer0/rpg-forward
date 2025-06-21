#include <open.mp>
#include <string>
#include <PawnPlus>
#include "izcmd.inc"
#include "sscanf2.inc"
#include "a_mysql.inc"
#include "timestamp.inc"
#include "Pawn.Regex.inc"
#include <streamer>
#include <YSI/YSI_Data/y_iterate>

#include "../gamemodes/modules/globaldefines.inc"

new MySQL:db;
new gMySqlRaceCheck[MAX_PLAYERS];

enum _:pData {
	pCurrentPickup,
	pInHouseID,
	pInBusinessID,

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

enum _:hData {
	hName[32],
	hDesc[64],
	hOwner[MAX_PLAYER_NAME],
	Float: hExtX,
	Float: hExtY,
	Float: hExtZ,
	Float: hIntX,
	Float: hIntY,
	Float: hIntZ,
	hInterior,
	hPickupID
};
new HouseData[100][hData];

enum __:pkData {
	pkType,
	pkHID,
	pkJBID
}
new PickupData[MAX_PICKUPS][pkData];

new Iterator:AdminsOnline<MAX_PLAYERS>;

#include "../gamemodes/modules/utils.inc"

#include "../gamemodes/modules/gui.inc"

#include "../gamemodes/modules/register-login.inc"
#include "../gamemodes/modules/admincmds.inc"
#include "../gamemodes/modules/houses.inc"


main() {
	mysql_log(ALL);
	return 1;
}

public OnGameModeInit() {
	db = mysql_connect("localhost", "root", "", "rpg-forward", MySQLOpt:0);

	if(mysql_errno(db)) { printf(ERR_MYSQL_CONNECT, mysql_errno(db)); return 1; } else { printf(MYSQL_CONNECTED); }

	SetGameModeText("Indev");
	AddPlayerClass(0, 2495.3547, -1688.2319, 13.6774, 351.1646, WEAPON_M4, 500, WEAPON_KNIFE, 1, WEAPON_COLT45, 100);

	DisableInteriorEnterExits();
	LoadHouses();

	return 1;
}

public OnGameModeExit() {
	CountDynamicPickups();
	DestroyAllDynamicPickups();

	CountDynamicObjects();
	DestroyAllDynamicObjects();

	CountDynamic3DTextLabels();
	DestroyAllDynamic3DTextLabels();

	CountDynamicCPs();
	DestroyAllDynamicCPs();

	return 1;
}

public OnPlayerConnect(playerid) {
	new tps = GetServerTickRate();
	SendClientMessage(playerid, COLOR_ORANGE, "Server TPS: %d", tps);

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
	if KEY_PRESSED(KEY_SECONDARY_ATTACK) {
		new currentPickup = PlayerData[playerid][pCurrentPickup];
		switch (PickupData[currentPickup][pkType]) {
			case PICKUP_TYPE_HOUSE: {
				new hID = PickupData[currentPickup][pkHID];
				if (GetPlayerInterior(playerid) == 0) {
					new Float: dist = GetPlayerDistanceFromPoint(playerid, Float:HouseData[hID][hExtX], Float:HouseData[hID][hExtY], Float:HouseData[hID][hExtZ]);
					if (dist < 1.0) {
						PlayerData[playerid][pInHouseID] = hID;
						SetPlayerInterior(playerid, HouseData[hID][hInterior]);
						SetPlayerVirtualWorld(playerid, hID);
						SetPlayerPos(playerid, Float: HouseData[hID][hIntX], Float: HouseData[hID][hIntY], Float: HouseData[hID][hIntZ]);
					}

				} else {
					new Float: dist = GetPlayerDistanceFromPoint(playerid, Float:HouseData[hID][hIntX], Float:HouseData[hID][hIntY], Float:HouseData[hID][hIntZ]);
					if (dist < 1.0) {
						PlayerData[playerid][pInHouseID] = -1;
						SetPlayerInterior(playerid, 0);
						SetPlayerVirtualWorld(playerid, 0);
						SetPlayerPos(playerid, Float: HouseData[hID][hExtX], Float: HouseData[hID][hExtY], Float: HouseData[hID][hExtZ]);
					}
				}
			}
		}
	}

	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid){
	if (PlayerData[playerid][pCurrentPickup] != pickupid) PlayerData[playerid][pCurrentPickup] = pickupid;
	//SendClientMessage(playerid, COLOR_ORANGE, "You entered pickup with ID %d of type %d", pickupid, PickupData[PlayerData[playerid][pCurrentPickup]][pkType]);
	return 1;
}

stock SavePlayer(playerid) {
	new query[1024];
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));

	mysql_format(db, query, sizeof(query),
	"UPDATE users SET \
	`pName` = '%e', \
	`pEmail` = '%e', \
	`pAge` = '%d', \
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

	mysql_tquery(db, query, "OnPlayerSaved", "i", playerid);
}

forward OnPlayerSaved(playerid);
public OnPlayerSaved(playerid) {
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