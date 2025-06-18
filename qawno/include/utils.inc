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

stock FieldFromName(const fieldName[]) {
    if (!strcmp(fieldName, "pIsLoggedIn", true)) return pIsLoggedIn;
    if (!strcmp(fieldName, "pLoginAttempts", true)) return pLoginAttempts;
    if (!strcmp(fieldName, "pLoginTimer", true)) return pLoginTimer;
    if (!strcmp(fieldName, "pName", true)) return pName;
    if (!strcmp(fieldName, "pEmail", true)) return pEmail;
    if (!strcmp(fieldName, "pAge", true)) return pAge;
    if (!strcmp(fieldName, "pPassword", true)) return pPassword;
    if (!strcmp(fieldName, "pSalt", true)) return pSalt;
    if (!strcmp(fieldName, "pCacheID", true)) return pCacheID;
    if (!strcmp(fieldName, "pBannedUntil", true)) return pBannedUntil;
    if (!strcmp(fieldName, "pBannedBy", true)) return pBannedBy;
    if (!strcmp(fieldName, "pBanReason", true)) return pBanReason;
    if (!strcmp(fieldName, "pAdmin", true)) return pAdmin;
    if (!strcmp(fieldName, "pMoney", true)) return pMoney;
    return -1;
}