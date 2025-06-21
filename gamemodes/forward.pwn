
#define PP_SYNTAX_THREADED

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
	// Temp:
	pCurrentPickup,
	pInHouseID,
	pInBusinessID,

	// Login:
	bool: pIsLoggedIn,
	pLoginAttempts,
	pLoginTimer,

	// Account info:
	pName[MAX_PLAYER_NAME],
	pEmail[32],
	pAge,
	pPassword[65],
	pSalt[17],
	Cache: pCacheID,

	// Ban info:
	pBannedUntil,
	pBannedBy[MAX_PLAYER_NAME],
	pBanReason[128],

	// Stats:
	pAdmin,
	pMoney,
	pJob
}
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
	hPickupID,
	hExtPickupObj,
	hIntPickupObj,
	Text3D: hExtLabelObj,
	Text3D: hIntLabelObj
}
new HouseData[MAX_HOUSES][hData];

enum __:pkData {
	pkType,
	pkHID,
	pkJBID
}
new PickupData[MAX_PICKUPS][pkData];

enum __:jbData {
	jbName[16],
	jbOwner[MAX_PLAYER_NAME],
	Float: jbMarkerX,
	Float: jbMarkerY,
	Float: jbMarkerZ,
	jbPickupID,
	jbPickupObj,
	Text3D: jbLabelObj
}
new JobData[MAX_JOBS][jbData];

new Iterator:AdminsOnline<MAX_PLAYERS>;

#include "../gamemodes/modules/utils.inc"

#include "../gamemodes/modules/gui.inc"

#include "../gamemodes/modules/register-login.inc"
#include "../gamemodes/modules/admincmds.inc"
#include "../gamemodes/modules/houses.inc"
#include "../gamemodes/modules/jobs.inc"
#include "../gamemodes/modules/playercommands.inc"

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
	LoadJobs();

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
	HOUSES_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys);
	JOBS_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys);

	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid){
	if (PlayerData[playerid][pCurrentPickup] != pickupid) PlayerData[playerid][pCurrentPickup] = pickupid;
	//SendClientMessage(playerid, COLOR_ORANGE, "You entered pickup with ID %d of type %d", pickupid, PickupData[PlayerData[playerid][pCurrentPickup]][pkType]);
	return 1;
}

// Data save functions

stock SavePlayer(playerid) {
	new query[1024];

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

	mysql_format(db, query, sizeof(query),
	"%s `pMoney` = '%d', \
	`pAdmin` = '%d', \
	`pBannedUntil` = '%e', \
	`pBannedBy` = '%e', \
	`pBanReason` = '%e', \
	`pJob` = '%d'",
	
	query,
	PlayerData[playerid][pMoney],
	PlayerData[playerid][pAdmin],
	PlayerData[playerid][pBannedUntil],
	PlayerData[playerid][pBannedBy],
	PlayerData[playerid][pBanReason],
	PlayerData[playerid][pJob]);

	mysql_format(db, query, sizeof(query), "%s WHERE `pName` = '%e'", query, PlayerData[playerid][pName]);

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

stock SaveHouse(houseid) {
    new query[1024];

    mysql_format(db, query, sizeof(query),
    "UPDATE `houses` SET \
    `hName` = '%s', \
    `hDesc` = '%s', \
    `hOwner` = '%s', \
    `hExtX` = '%f', \
    `hExtY` = '%f', \
    `hExtZ` = '%f', \
    `hIntX` = '%f', \
    `hIntY` = '%f', \
    `hIntZ` = '%f', \
    `hInterior` = '%d', \
    `hPickupID` = '%d'",
    
    HouseData[houseid][hName],
    HouseData[houseid][hDesc],
    HouseData[houseid][hOwner],
    HouseData[houseid][hExtX],
    HouseData[houseid][hExtY],
    HouseData[houseid][hExtZ],
    HouseData[houseid][hIntX],
    HouseData[houseid][hIntY],
    HouseData[houseid][hIntZ],
    HouseData[houseid][hInterior],
    HouseData[houseid][hPickupID]);

    mysql_format(db, query, sizeof(query), "%s WHERE `hID` = '%d'", query, houseid);

    mysql_tquery(db, query, "OnHouseSaved", "i", houseid);
}

forward OnHouseSaved(houseid);
public OnHouseSaved(houseid) {
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

stock SaveJob(jobid) {
    new query[1024];

    mysql_format(db, query, sizeof(query),
    "UPDATE `jobs` SET \
    `jbName` = '%e', \
    `jbOwner` = '%e', \
    `jbMarkerX` = '%d', \
    `jbMarkerY` = '%d', \
    `jbMarkerZ` = '%d', \
    `jbPickupID` = '%d'" \
    
    JobData[jobid][jbName],
	JobData[jobid][jbOwner],
	JobData[jobid][jbMarkerX],
	JobData[jobid][jbMarkerY],
	JobData[jobid][jbMarkerZ],
	JobData[jobid][jbPickupID],);

    mysql_format(db, query, sizeof(query), "%s WHERE `jbID` = '%d'", query, jobid);

    mysql_tquery(db, query, "OnHouseSaved", "i", jobid);
}

forward OnJobSaved(jobid);
public OnJobSaved(jobid) {
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