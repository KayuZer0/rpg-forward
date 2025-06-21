CMD:sethousename(playerid, params[]) {
    new houseName[32];

	if (sscanf(params, "s[32]", houseName)){
		CMD_USAGE("/sethousename <name>")
	}

    if (PlayerData[playerid][pInHouseID] == -1) {
        SendClientMessage(playerid, COLOR_DARKNICERED, "You aren't inside your house!");
        return 1;
    } else {
        if (strcmp(PlayerData[playerid][pName], HouseData[PlayerData[playerid][pInHouseID]][hOwner])) {
            SendClientMessage(playerid, COLOR_DARKNICERED, "You aren't inside your house!");
            return 1;
        } else {
            HouseData[PlayerData[playerid][pInHouseID]][hName] = houseName;

            new label[128];
            format(label, sizeof(label), "%s\nOwner: %s\n%s", HouseData[PlayerData[playerid][pInHouseID]][hName], HouseData[PlayerData[playerid][pInHouseID]][hOwner], HouseData[PlayerData[playerid][pInHouseID]][hDesc]);

            UpdateDynamic3DTextLabelText(HouseData[PlayerData[playerid][pInHouseID]][hExtLabelObj], COLOR_ORANGE, label);
            UpdateDynamic3DTextLabelText(HouseData[PlayerData[playerid][pInHouseID]][hIntLabelObj], COLOR_ORANGE, label);

            SaveHouse(PlayerData[playerid][pInHouseID]);

            SendClientMessage(playerid, COLOR_ORANGE, "Set your house name to: %s", houseName);
            return 1;
        }
    }
}