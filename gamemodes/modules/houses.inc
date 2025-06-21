#define HOUSE_ENEX_DISTANCE_THRESHOLD 1.0

forward HOUSES_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys);
public HOUSES_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
	if KEY_PRESSED(KEY_SECONDARY_ATTACK) {
		if (PlayerData[playerid][pCurrentPickup] == -1) {return 1;}

		new currentPickup = PlayerData[playerid][pCurrentPickup];

		switch (PickupData[currentPickup][pkType]) {

			case PICKUP_TYPE_HOUSE: {

				new hID = PickupData[currentPickup][pkHID];
				new Float: dist;
				if (GetPlayerInterior(playerid) == 0) {
					dist = GetPlayerDistanceFromPoint(playerid, Float:HouseData[hID][hExtX], Float:HouseData[hID][hExtY], Float:HouseData[hID][hExtZ]);
					if (dist < HOUSE_ENEX_DISTANCE_THRESHOLD) {
						EnterHouse(playerid, hID);
					}

				} else {
					dist = GetPlayerDistanceFromPoint(playerid, Float:HouseData[hID][hIntX], Float:HouseData[hID][hIntY], Float:HouseData[hID][hIntZ]);
					if (dist < HOUSE_ENEX_DISTANCE_THRESHOLD) {
						ExitHouse(playerid, hID);
					}
				}
			}
		}
	}
    return 1;
}

stock LoadHouses() {
    new query[128];
    mysql_format(db, query, sizeof(query), "SELECT * FROM `houses`");
    mysql_tquery(db, query, "OnHouseDataLoaded");
}

forward OnHouseDataLoaded();
public OnHouseDataLoaded() {
	new rowCount;
    printf("ROW COUNT: %d", rowCount);
	cache_get_row_count(rowCount);
    if (rowCount > 0) {
        for (new i = 0; i < rowCount; i++) {
            cache_get_value(i, "hOwner", HouseData[i][hOwner], MAX_PLAYER_NAME);
            cache_get_value(i, "hName", HouseData[i][hName], 32);
            cache_get_value(i, "hDesc", HouseData[i][hDesc], 64);
            cache_get_value_float(i, "hExtX", HouseData[i][hExtX]);
            cache_get_value_float(i, "hExtY", HouseData[i][hExtY]);
            cache_get_value_float(i, "hExtZ", HouseData[i][hExtZ]);
            cache_get_value_float(i, "hIntX", HouseData[i][hIntX]);
            cache_get_value_float(i, "hIntY", HouseData[i][hIntY]);
            cache_get_value_float(i, "hIntZ", HouseData[i][hIntZ]);
            cache_get_value_int(i, "hInterior", HouseData[i][hInterior]);
            cache_get_value_int(i, "hPickupID", HouseData[i][hPickupID]);

            HouseData[i][hExtPickupObj] = CreateDynamicPickup(HouseData[i][hPickupID], 1, Float:HouseData[i][hExtX], Float:HouseData[i][hExtY], Float:HouseData[i][hExtZ], -1, -1, -1);
            HouseData[i][hIntPickupObj] = CreateDynamicPickup(HouseData[i][hPickupID], 1, Float:HouseData[i][hIntX], Float:HouseData[i][hIntY], Float:HouseData[i][hIntZ], i, HouseData[i][hInterior], -1);

            new label[128];
            format(label, sizeof(label), "%s\nOwner: %s\n%s", HouseData[i][hName], HouseData[i][hOwner], HouseData[i][hDesc]);

            HouseData[i][hExtLabelObj] = CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:HouseData[i][hExtX], Float:HouseData[i][hExtY], Float:HouseData[i][hExtZ], Float:10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1);
            HouseData[i][hIntLabelObj] = CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:HouseData[i][hIntX], Float:HouseData[i][hIntY], Float:HouseData[i][hIntZ], Float:10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, i, HouseData[i][hInterior], -1);

			PickupData[HouseData[i][hIntPickupObj]][pkType] = PICKUP_TYPE_HOUSE;
			PickupData[HouseData[i][hIntPickupObj]][pkHID] = i;

			PickupData[HouseData[i][hExtPickupObj]][pkType] = PICKUP_TYPE_HOUSE;
			PickupData[HouseData[i][hExtPickupObj]][pkHID] = i;
        }
    }
}

stock EnterHouse(playerid, hID) {
    PlayerData[playerid][pInHouseID] = hID;
    SetPlayerInterior(playerid, HouseData[hID][hInterior]);
    SetPlayerVirtualWorld(playerid, hID);
    SetPlayerPos(playerid, Float:HouseData[hID][hIntX], Float:HouseData[hID][hIntY], Float:HouseData[hID][hIntZ]);
}

stock ExitHouse(playerid, hID) {
    PlayerData[playerid][pInHouseID] = -1;
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, Float:HouseData[hID][hExtX], Float:HouseData[hID][hExtY], Float:HouseData[hID][hExtZ]);
}
