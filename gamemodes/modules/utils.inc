enum _:moneyOperations {
	add,
	set
};

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

stock DebugArray(const any:arr[], size, const name[] = "value") {
    printf("Debugging %s:", name);
    for (new i = 0; i < size; i++)
    {
        printf("%s[%d] = %d", name, i, arr[i]);
    }
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

stock ChangePlayerMoney(playerid, money, changeMode = add) {
	switch (changeMode) {
		case add: {
			GivePlayerMoney(playerid, money);
			PlayerData[playerid][pMoney] = PlayerData[playerid][pMoney] + money;
			SavePlayer(playerid);
		}
		case set: {
			GivePlayerMoney(playerid, money - PlayerData[playerid][pMoney]);
			PlayerData[playerid][pMoney] = money;
			SavePlayer(playerid);
		}	
	}
}