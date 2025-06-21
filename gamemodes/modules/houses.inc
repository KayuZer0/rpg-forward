stock LoadHouses() {
    new query[128];
    mysql_format(db, query, sizeof(query), "SELECT * FROM `houses`");
    mysql_tquery(db, query, "OnHouseDataLoaded");
}

forward OnHouseDataLoaded();
public OnHouseDataLoaded() {
	new rowCount;
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

            new extobj = CreateDynamicPickup(HouseData[i][hPickupID], 1, Float:HouseData[i][hExtX], Float:HouseData[i][hExtY], Float:HouseData[i][hExtZ], -1, -1, -1);
            new intobj = CreateDynamicPickup(HouseData[i][hPickupID], 1, Float:HouseData[i][hIntX], Float:HouseData[i][hIntY], Float:HouseData[i][hIntZ], -1, HouseData[i][hInterior], -1);

            new label[128];
            format(label, sizeof(label), "%s\nOwner: %s\n%s", HouseData[i][hName], HouseData[i][hOwner], HouseData[i][hDesc]);

            CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:HouseData[i][hExtX], Float:HouseData[i][hExtY], Float:HouseData[i][hExtZ], Float:10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1);
            CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:HouseData[i][hIntX], Float:HouseData[i][hIntY], Float:HouseData[i][hIntZ], Float:10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, HouseData[i][hInterior], -1);

			PickupData[intobj][pkType] = PICKUP_TYPE_HOUSE;
			PickupData[intobj][pkHID] = i;

			PickupData[extobj][pkType] = PICKUP_TYPE_HOUSE;
			PickupData[extobj][pkHID] = i;
        }
    }
}