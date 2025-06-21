#define JOB_MARKER_DISTANCE_THRESHOLD 1.0

forward JOBS_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys);
public JOBS_OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys) {
	if KEY_PRESSED(KEY_YES) {
		if (PlayerData[playerid][pCurrentPickup] == -1) { return 1; }

		new currentPickup = PlayerData[playerid][pCurrentPickup];

		if (PickupData[currentPickup][pkType] == PICKUP_TYPE_JOB) {
            printf("niggerinoo!!!");

            new jobid = PickupData[currentPickup][pkJBID];
            new Float: dist;

            dist = GetPlayerDistanceFromPoint(playerid, Float:JobData[jobid][jbMarkerX], Float:JobData[jobid][jbMarkerY], Float:JobData[jobid][jbMarkerZ]);
            if (dist < JOB_MARKER_DISTANCE_THRESHOLD) {
                GetJob(playerid, jobid);
            }
			
		}
	}

    if KEY_PRESSED(KEY_NO) {
		if (PlayerData[playerid][pCurrentPickup] == -1) {return 1;}

		new currentPickup = PlayerData[playerid][pCurrentPickup];

		if (PickupData[currentPickup][pkType] == PICKUP_TYPE_JOB) {

            new jobid = PickupData[currentPickup][pkJBID];
            new Float: dist;

            dist = GetPlayerDistanceFromPoint(playerid, Float:JobData[jobid][jbMarkerX], Float:JobData[jobid][jbMarkerY], Float:JobData[jobid][jbMarkerZ]);
            if (dist < JOB_MARKER_DISTANCE_THRESHOLD) {
                QuitJob(playerid);
            }
			
		}
     }
    return 1;
}

stock GetJob(playerid, jobid) {
    if (PlayerData[playerid][pJob] != -1) { return SendClientMessage(playerid, COLOR_DARKNICERED, "You already have a job. You need to quit it first!"); }

    PlayerData[playerid][pJob] = jobid;
    SavePlayer(playerid);
    SendClientMessage(playerid, COLOR_ORANGE, "Your new job is now: %s!", JobData[jobid][jbName]);

    return 1;
}

stock QuitJob(playerid) {
    if (PlayerData[playerid][pJob] == -1) { return SendClientMessage(playerid, COLOR_DARKNICERED, "You don't have a job!"); }

    PlayerData[playerid][pJob] = -1;
    SavePlayer(playerid);
    SendClientMessage(playerid, COLOR_ORANGE, "You quit your job!");

    return 1;
}

stock LoadJobs() {
    new query[128];
    mysql_format(db, query, sizeof(query), "SELECT * FROM `jobs`");
    mysql_tquery(db, query, "OnJobDataLoaded");
}

forward OnJobDataLoaded();
public OnJobDataLoaded() {
	new rowCount;
	cache_get_row_count(rowCount);
    if (rowCount > 0) {
        for (new i = 0; i < rowCount; i++) {
            cache_get_value(i, "jbName", JobData[i][jbName], 16);
            cache_get_value(i, "jbOwner", JobData[i][jbOwner], MAX_PLAYER_NAME);
            cache_get_value_float(i, "jbMarkerX", JobData[i][jbMarkerX]);
            cache_get_value_float(i, "jbMarkerY", JobData[i][jbMarkerY]);
            cache_get_value_float(i, "jbMarkerZ", JobData[i][jbMarkerZ]);
            cache_get_value_int(i, "jbPickupID", JobData[i][jbPickupID]);

            JobData[i][jbPickupObj] = CreateDynamicPickup(JobData[i][jbPickupID], 1, Float:JobData[i][jbMarkerX], Float:JobData[i][jbMarkerY], Float:JobData[i][jbMarkerZ], -1, -1, -1);

            printf("Is ther niggers in the niggy::::: %d", JobData[i][jbPickupObj]);

            new label[128];
            format(label, sizeof(label), "%s\nOwner: %s\nPress Y to get job\nPress N to quit job", JobData[i][jbName], JobData[i][jbOwner]);

            JobData[i][jbLabelObj] = CreateDynamic3DTextLabel(label, COLOR_ORANGE, Float:JobData[i][jbMarkerX], Float:JobData[i][jbMarkerY], Float:JobData[i][jbMarkerZ], Float:10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1);

			PickupData[JobData[i][jbPickupObj]][pkType] = PICKUP_TYPE_JOB;
			PickupData[JobData[i][jbPickupObj]][pkJBID] = i;
        }
    }
}
