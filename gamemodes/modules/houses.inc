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

    new where[32];
    mysql_format(db, where, sizeof(where), " WHERE `hID` = '%d'", houseid);
    strcat(query, where, sizeof(query));

    mysql_tquery(db, query, "OnHouseSaved", "i", houseid);
}

//[POS]: X: 2210.995361 | Y: 1285.725463 | Z: 10.820312 | ROT: 179.601882

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