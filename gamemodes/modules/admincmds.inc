#define CMD_NEEDADMIN(%0) if (PlayerData[playerid][pAdmin] < %0) { SendClientMessage(playerid, COLOR_DARKNICERED, ERR_ADMIN_LEVEL); return 1; }

#define CMD_USAGE(%0) SendClientMessage(playerid, COLOR_DARKNICERED, "[USAGE]: %s", %0); return 1;

#define CMD_NOT_ON_SELF if (playerid == targetid) { SendClientMessage(playerid, COLOR_DARKNICERED, ERR_NOT_ON_YOURSELF); return 1; }

#define CMD_MUST_BE_CONNECTED(%0) if (!IsPlayerConnected(%0)) { SendClientMessage(playerid, COLOR_DARKNICERED, ERR_NO_PLAYER_FOUND); return 1; }

#define CMD_MUST_BE_LOGGED_IN if (PlayerData[playerid][pIsLoggedIn] != true) return 1

#define MAX_ADMIN_LEVEL 7

CMD:test(playerid, params[]) {
	CMD_MUST_BE_LOGGED_IN;

	SendClientMessage(playerid, -1, "lol");

	return 1;
}

CMD:ban(playerid, params[]) {
	new targetid, duration, reason[128];

	CMD_NEEDADMIN(1)

	if (sscanf(params, "iis[128]", targetid, duration, reason)){
		CMD_USAGE("/ban <id> <days (0 = permanent)> <reason>")
	}

	CMD_MUST_BE_CONNECTED(targetid)

	if (duration < 0) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_INVALID_VALUE);
		return 1;
	}

	if (duration == 0) {
		SendClientMessageToAll(COLOR_DARKNICERED, "Player %s was banned by Admin %s. Reason: %s", PlayerData[targetid][pName], PlayerData[playerid][pName], reason);
		PlayerData[targetid][pBannedUntil] = 0;
	} else {
		new bannedUntil = gettime() + (duration * 86400);

		PlayerData[targetid][pBannedUntil] = bannedUntil;
		SendClientMessageToAll(COLOR_DARKNICERED, "Player %s was banned by Admin %s for %d days. Reason: %s", PlayerData[targetid][pName], PlayerData[playerid][pName], duration, reason);
	}

	PlayerData[targetid][pBannedBy] = PlayerData[playerid][pName];
	PlayerData[targetid][pBanReason] = reason;

	SavePlayer(targetid);

	Kick(targetid);

	return 1;
}

CMD:kick(playerid, params[]) {
	new targetid, reason[128];

	CMD_NEEDADMIN(1)

	if (sscanf(params, "is[128]", targetid, reason)){
        CMD_USAGE("/kick <id> <reason>")
	}

    CMD_MUST_BE_CONNECTED(targetid)

	SendClientMessageToAll(COLOR_DARKNICERED, "Player %s was kicked by Admin %s. Reason: %s", PlayerData[targetid][pName], PlayerData[playerid][pName], reason);
	Kick(targetid);

	return 1;
}

CMD:slap(playerid, params[]) {
    new targetid;

    CMD_NEEDADMIN(1)

    if (sscanf(params, "i", targetid)){
        CMD_USAGE("/slap <id>")
	}

    CMD_MUST_BE_CONNECTED(targetid)

    new Float: x, Float: y, Float: z;
    GetPlayerPos(targetid, x, y, z);
    SetPlayerPos(targetid, x, y, z + 1.5);

    SendClientMessage(playerid, 0xFFA500AA, "You slapped %s.", PlayerData[targetid][pName]);
	SendClientMessage(targetid, 0xFFA500AA, "Admin %s slapped you.", PlayerData[playerid][pName]);

    return 1;
}

CMD:setadmin(playerid, params[]) {
	new targetid, level;

    CMD_NEEDADMIN(7)

	if (sscanf(params, "ii", targetid, level)){
        CMD_USAGE("/setadmin <id> <level>")
	}

	CMD_NOT_ON_SELF

	CMD_MUST_BE_CONNECTED(targetid)

	if (level > MAX_ADMIN_LEVEL || level < 0) {
		SendClientMessage(playerid, 0xFF4444AA, ERR_INVALID_VALUE);
		return 1;
	}

	PlayerData[targetid][pAdmin] = level;
	SavePlayer(targetid);

	if (level == 0) {
		if (Iter_Contains(AdminsOnline, playerid)) {
			Iter_Remove(AdminsOnline, playerid);
		}
	} else {
		if (!Iter_Contains(AdminsOnline, playerid)) {
			Iter_Add(AdminsOnline, playerid);
		}
	}

	SendClientMessage(playerid, 0xFFA500AA, "You set %s's Admin Level to %d.", PlayerData[targetid][pName], level);
	SendClientMessage(targetid, 0xFFA500AA, "Admin %s set your Admin Level to %d.", PlayerData[playerid][pName], level);

	return 1;

}

CMD:setmoney(playerid, params[]) {
	new targetid, money;

	CMD_NEEDADMIN(5)

	if (sscanf(params, "ii", targetid, money)){
		CMD_USAGE("/setmoney <id> <amount>")
	}

	CMD_MUST_BE_CONNECTED(targetid)

	if (money > 999999999 || money < 0) {SendClientMessage(playerid, 0xFF4444AA, ERR_INVALID_VALUE); return 1;}

	ChangePlayerMoney(targetid, money, set);

	SendClientMessage(playerid, COLOR_ORANGE, "You set %s's money to $%d.", PlayerData[targetid][pName], money);
	SendClientMessage(targetid, COLOR_ORANGE, "Admin %s set your money to $%d.", PlayerData[playerid][pName], money);

	return 1;
}

CMD:givemoney(playerid, params[]) {
	new targetid, money;

	CMD_NEEDADMIN(5)

	if (sscanf(params, "ii", targetid, money)){
		CMD_USAGE("/givemoney <id> <amount>")
	}

	CMD_MUST_BE_CONNECTED(targetid)

	if (money > 999999999 || (PlayerData[targetid][pMoney] <= 0 && money < 0) || money == 0) {SendClientMessage(playerid, 0xFF4444AA, ERR_INVALID_VALUE); return 1;}

	ChangePlayerMoney(playerid, money, add);

	if (money < 0) {
		SendClientMessage(playerid, 0xFFA500AA, "You took $%d from player %s.", abs(money), PlayerData[targetid][pName]);
		SendClientMessage(targetid, 0xFFA500AA, "Admin %s took $%d from you.", PlayerData[playerid][pName], abs(money));
	} else {
		SendClientMessage(playerid, 0xFFA500AA, "You gave $%d to player %s.", money, PlayerData[targetid][pName]);
		SendClientMessage(targetid, 0xFFA500AA, "Admin %s gave you $%d.", PlayerData[playerid][pName], money);
	}


	return 1;
}

CMD:clearchat(playerid, params[]) {
	new authorName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, authorName, sizeof(authorName));

	CMD_NEEDADMIN(1)

	for (new i = 0; i < 254; i++) {
		SendClientMessageToAll(COLOR_WHITE, "");
	}

	SendClientMessageToAll(0xFFA500AA, "Admin %s cleared the chat.", PlayerData[playerid][pName]);

	return 1;
}

CMD:spawncar(playerid, params[]) {
	new vehicleid, color1, color2;

	CMD_NEEDADMIN(1)

	if (sscanf(params, "iii", vehicleid, color1, color2)){
		CMD_USAGE("/spawncar <id> <color1> <color2>")
	}

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	new spawnedCar = CreateVehicle(vehicleid, x, y, z, a, color1, color2, -1, false);

	SetVehicleVirtualWorld(spawnedCar, GetPlayerVirtualWorld(playerid));

	PutPlayerInVehicle(playerid, spawnedCar, 0);

	SendClientMessage(playerid, 0xFFA500AA, "Ti-am spawnat bolidu' cumetre. Cu placere se spune.");

	return 1;
}

CMD:vre(playerid, args[]) {
	CMD_NEEDADMIN(1)

	if (IsPlayerInAnyVehicle(playerid)) {
		DestroyVehicle(GetPlayerVehicleID(playerid));
		SendClientMessage(playerid, COLOR_ORANGE, "Car deleted.");
	} else {
		SendClientMessage(playerid, COLOR_DARKNICERED, "You are not in a car.");
	}

	return 1;
}

CMD:gotojob(playerid, params[]) {
	new targetjob;

	CMD_NEEDADMIN(1)

	if (sscanf(params, "i", targetjob)){
		CMD_USAGE("/gotojob <jon id>")
	}

	SetPlayerPos(playerid, Float:JobData[targetjob][jbMarkerX], Float:JobData[targetjob][jbMarkerY], Float:JobData[targetjob][jbMarkerZ]);

	SendClientMessage(playerid, COLOR_ORANGE, "You teleported to Job ID %d.", targetjob);

	return 1;
}

CMD:goto(playerid, params[]){
    new targetid;

    CMD_NEEDADMIN(1)

	if (sscanf(params, "i", targetid)){
		CMD_USAGE("/goto <id>")
	}

    CMD_MUST_BE_CONNECTED(targetid)
    
    new Float: x, Float: y, Float: z;

    GetPlayerPos(targetid, x, y, z);

    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
	SetPlayerInterior(playerid, GetPlayerInterior(targetid));
    SetPlayerPos(playerid, x, y + 0.25, z);


    SendClientMessage(playerid, COLOR_ORANGE, "You teleported to %s.", PlayerData[targetid][pName]);
    SendClientMessage(targetid, COLOR_ORANGE, "Admin %s teleported to you.", PlayerData[playerid][pName]);

    return 1;
}

CMD:gethere(playerid, params[]){
    new targetid;

    CMD_NEEDADMIN(1)

	if (sscanf(params, "i", targetid)){
		CMD_USAGE("/gethere <id>")
	}

    CMD_MUST_BE_CONNECTED(targetid)
    
    new Float: x, Float: y, Float: z;

    GetPlayerPos(playerid, x, y, z);

    SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
	SetPlayerInterior(targetid, GetPlayerInterior(playerid));
    SetPlayerPos(targetid, x, y + 0.25, z);

    SendClientMessage(playerid, COLOR_ORANGE, "You teleported %s to you.", PlayerData[targetid][pName]);
    SendClientMessage(targetid, COLOR_ORANGE, "Admin %s teleported you to them.", PlayerData[playerid][pName]);

    return 1;
}

CMD:a(playerid, params[]) {
    new message[128];

	CMD_NEEDADMIN(1)

	if (sscanf(params, "s[128]", message)){
		CMD_USAGE("/a <message>")
	}

    if (strlen(message) < 0) {CMD_USAGE("/a <message>")}

	foreach (new i : AdminsOnline) {
		SendClientMessage(i, COLOR_DARKNICERED, "(/a) Admin %s: {FF5733}%s", PlayerData[playerid][pName], message);
	}

	return 1;
}

CMD:pickup(playerid, params[]) {
	new pickupid;

	CMD_NEEDADMIN(7)

	new Float: x, Float: y, Float: z;
	GetPlayerPos(playerid, x, y, z);

	if (sscanf(params, "i", pickupid)){
		CMD_USAGE("/pickup <pickupid>")
	}

	CreateDynamicPickup(pickupid, 1, Float:x, Float:y, Float:z);

	//CreateEnex(objid, 15, "Test", "Test",  Float: pPos, Float: {207.630004, -110.579940, 1005.132812});
	SendClientMessage(playerid, COLOR_ORANGE, "Enex created.");
	return 1;
}

CMD:getpos(playerid, params[]) {
	new Float: x, Float: y, Float: z, Float: a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	SendClientMessage(playerid, COLOR_ORANGE, "[POS]: X: %f | Y: %f | Z: %f | ROT: %f", x, y, z, a);
	return 1;
}

CMD:testset(playerid, params[]) {
	return 1;
}

CMD:testget(playerid, params[]){
	SendClientMessage(playerid, COLOR_ORANGE, "%d", PlayerData[playerid][pJob]);
	SendClientMessage(playerid, COLOR_ORANGE, "%d", PlayerData[playerid][pCurrentPickup]);
	return 1;
}

new startTick;
new responses;
new queryCount; // Number of queries to run

CMD:testqps(playerid, params[])
{
	CMD_NEEDADMIN(7)

	new howMany;

	if (sscanf(params, "i", howMany)){
		CMD_USAGE("/testqps <how many queries>")
	}

	queryCount = howMany;

    startTick = GetTickCount();

    for (new i = 0; i < queryCount; i++)
    {
		new query[1024];
		format(query, sizeof(query), "UPDATE users SET `pName` = 'Niggu', `pEmail` = 'test@test.com', `pPassword` = '0C4835C225FF0C266AC558DD56A209BF76F0A2A9CDDF587FCB67A68BF50A18D3', `pSalt` = 'Wsf3cEZC;>p}BVUw', `pAge` = '0', `pMoney` = '0', `pAdmin` = 0, `pBannedUntil` = 0, `pBannedBy` = 'Nobody', `pBanReason` = 'Prost' WHERE `pName` = 'Niggu'");
        mysql_tquery(db, query, "OnTestQpsQueryFinished", "i", playerid);
    }

    return 1;
}

CMD:testforloop(playerid, params[]) {
	CMD_NEEDADMIN(7)
	new Iterator:ConnectedPlayers<MAX_PLAYERS>;
	Iter_Add(ConnectedPlayers, playerid);

	new Connected[MAX_PLAYERS];
	Connected[playerid] = true;

	new howMany;

	if (sscanf(params, "i", howMany)){
		CMD_USAGE("/testforloop <how many loops>")
	}

	new loopsDone = 0;
	new startTime = GetTickCount();
	for (new i = 0; i < howMany; i++) {
		if (playerid == 0) {
			new xyz = 0;
			//new isCon = IsPlayerConnected(playerid);
			//new isCon = Iter_Contains(ConnectedPlayers, playerid);
			//new isCon = Connected[playerid];
			//SavePlayer(playerid);
			//NewSavePlayer(playerid);
		}
		loopsDone ++;
	}

	if (loopsDone >= howMany) {
		new endTime = GetTickCount();
		new totalTime = endTime - startTime;
		SendClientMessage(playerid, COLOR_ORANGE, "[For() Test] Executed %d loops in %d ms.", howMany, totalTime);
		SendClientMessage(playerid, COLOR_ORANGE, "[For() Test]: Approx %0.2f loops per second.", (howMany * 1000.0) / float(totalTime));
	}

	return 1;
}

forward OnTestQpsQueryFinished(playerid);
public OnTestQpsQueryFinished(playerid) {
	if (mysql_errno(db)) {
		SendClientMessage(playerid, COLOR_ORANGE, "[QPS Test]: MySQL Error: %d", mysql_errno(db));
		return 1;
	}

	responses++;

	if (responses >= queryCount) {
		new totalTime = GetTickCount() - startTick;
		SendClientMessage(playerid, COLOR_ORANGE, "[QPS Test]: %d queries executed in %d ms.", queryCount, totalTime);
		SendClientMessage(playerid, COLOR_ORANGE, "[QPS Test]: Approx %0.2f queries per second.", (queryCount * 1000.0) / float(totalTime));
		responses = 0;
		queryCount = 0;
	}

	return 1;
}