new PlayerText: pRegisterMenu_email[MAX_PLAYERS];
new PlayerText: pRegisterMenu_age[MAX_PLAYERS];
new PlayerText: pRegisterMenu_password[MAX_PLAYERS];
new PlayerText: pRegisterMenu_rePass[MAX_PLAYERS];

new PlayerText: pRegisterMenu_emailSymbol[MAX_PLAYERS];
new PlayerText: pRegisterMenu_ageSymbol[MAX_PLAYERS];
new PlayerText: pRegisterMenu_passwordSymbol[MAX_PLAYERS];
new PlayerText: pRegisterMenu_rePassSymbol[MAX_PLAYERS];

new PlayerText: pRegisterMenu_emailTypebox[MAX_PLAYERS];
new PlayerText: pRegisterMenu_ageTypebox[MAX_PLAYERS];
new PlayerText: pRegisterMenu_passwordTypebox[MAX_PLAYERS];
new PlayerText: pRegisterMenu_rePassTypebox[MAX_PLAYERS];

new PlayerText: pRegisterMenu_buttonRegister[MAX_PLAYERS];
new PlayerText: pRegisterMenu_buttonCancel[MAX_PLAYERS];

stock ShowRegisterMenu(playerid) {
	pRegisterMenu_email[playerid] = CreatePlayerTextDraw(playerid, 222.000, 73.000, "E-mail Address:");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_email[playerid], 0.300, 1.500);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_email[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_email[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_email[playerid], true);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_email[playerid], true);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_email[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_email[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_email[playerid], true);

	pRegisterMenu_ageTypebox[playerid] = CreatePlayerTextDraw(playerid, 225.000, 151.000, "Click to enter text");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_ageTypebox[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_ageTypebox[playerid], 400.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_ageTypebox[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_ageTypebox[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_ageTypebox[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_ageTypebox[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_ageTypebox[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_ageTypebox[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_ageTypebox[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_ageTypebox[playerid], t_TEXT_DRAW_FONT:1);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_ageTypebox[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_ageTypebox[playerid], true);

	pRegisterMenu_emailTypebox[playerid] = CreatePlayerTextDraw(playerid, 225.000, 98.000, "Click to enter text");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_emailTypebox[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_emailTypebox[playerid], 400.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_emailTypebox[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_emailTypebox[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_emailTypebox[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_emailTypebox[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_emailTypebox[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_emailTypebox[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_emailTypebox[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_emailTypebox[playerid], t_TEXT_DRAW_FONT:1);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_emailTypebox[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_emailTypebox[playerid], true);

	pRegisterMenu_emailSymbol[playerid] = CreatePlayerTextDraw(playerid, 196.000, 95.000, "LD_CHAT:thumbdn");
	PlayerTextDrawTextSize(playerid, pRegisterMenu_emailSymbol[playerid], 20.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_emailSymbol[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_emailSymbol[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_emailSymbol[playerid], 0);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_emailSymbol[playerid], 0);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_emailSymbol[playerid], 255);
	PlayerTextDrawFont(playerid, pRegisterMenu_emailSymbol[playerid], t_TEXT_DRAW_FONT:4);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_emailSymbol[playerid], true);

	pRegisterMenu_ageSymbol[playerid] = CreatePlayerTextDraw(playerid, 196.000, 148.000, "LD_CHAT:thumbdn");
	PlayerTextDrawTextSize(playerid, pRegisterMenu_ageSymbol[playerid], 20.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_ageSymbol[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_ageSymbol[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_ageSymbol[playerid], 0);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_ageSymbol[playerid], 0);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_ageSymbol[playerid], 255);
	PlayerTextDrawFont(playerid, pRegisterMenu_ageSymbol[playerid], t_TEXT_DRAW_FONT:4);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_ageSymbol[playerid], true);

	pRegisterMenu_passwordTypebox[playerid] = CreatePlayerTextDraw(playerid, 225.000, 201.000, "Click to enter text");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_passwordTypebox[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_passwordTypebox[playerid], 400.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_passwordTypebox[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_passwordTypebox[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_passwordTypebox[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_passwordTypebox[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_passwordTypebox[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_passwordTypebox[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_passwordTypebox[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_passwordTypebox[playerid], t_TEXT_DRAW_FONT:1);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_passwordTypebox[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_passwordTypebox[playerid], true);

	pRegisterMenu_passwordSymbol[playerid] = CreatePlayerTextDraw(playerid, 196.000, 198.000, "LD_CHAT:thumbdn");
	PlayerTextDrawTextSize(playerid, pRegisterMenu_passwordSymbol[playerid], 20.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_passwordSymbol[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_passwordSymbol[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_passwordSymbol[playerid], 0);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_passwordSymbol[playerid], 0);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_passwordSymbol[playerid], 255);
	PlayerTextDrawFont(playerid, pRegisterMenu_passwordSymbol[playerid], t_TEXT_DRAW_FONT:4);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_passwordSymbol[playerid], true);

	pRegisterMenu_rePassTypebox[playerid] = CreatePlayerTextDraw(playerid, 225.000, 258.000, "Click to enter text");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_rePassTypebox[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_rePassTypebox[playerid], 400.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_rePassTypebox[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_rePassTypebox[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_rePassTypebox[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_rePassTypebox[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_rePassTypebox[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_rePassTypebox[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_rePassTypebox[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_rePassTypebox[playerid], t_TEXT_DRAW_FONT:1);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_rePassTypebox[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_rePassTypebox[playerid], true);

	pRegisterMenu_rePassSymbol[playerid] = CreatePlayerTextDraw(playerid, 196.000, 255.000, "LD_CHAT:thumbdn");
	PlayerTextDrawTextSize(playerid, pRegisterMenu_rePassSymbol[playerid], 20.000, 20.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_rePassSymbol[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_rePassSymbol[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_rePassSymbol[playerid], 0);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_rePassSymbol[playerid], 0);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_rePassSymbol[playerid], 255);
	PlayerTextDrawFont(playerid, pRegisterMenu_rePassSymbol[playerid], t_TEXT_DRAW_FONT:4);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_rePassSymbol[playerid], true);

	pRegisterMenu_buttonRegister[playerid] = CreatePlayerTextDraw(playerid, 264.000, 309.000, "Register");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_buttonRegister[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_buttonRegister[playerid], 400.000, 70.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_buttonRegister[playerid], TEXT_DRAW_ALIGN_CENTER);
	PlayerTextDrawColour(playerid, pRegisterMenu_buttonRegister[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_buttonRegister[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_buttonRegister[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_buttonRegister[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_buttonRegister[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_buttonRegister[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_buttonRegister[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_buttonRegister[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_buttonRegister[playerid], true);

	pRegisterMenu_age[playerid] = CreatePlayerTextDraw(playerid, 222.000, 129.000, "Your age:");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_age[playerid], 0.300, 1.500);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_age[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_age[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_age[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_age[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_age[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_age[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_age[playerid], true);

	pRegisterMenu_password[playerid] = CreatePlayerTextDraw(playerid, 222.000, 178.000, "Choose a password:");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_password[playerid], 0.300, 1.500);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_password[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_password[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_password[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_password[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_password[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_password[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_password[playerid], true);

	pRegisterMenu_rePass[playerid] = CreatePlayerTextDraw(playerid, 222.000, 236.000, "Repeat Password:");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_rePass[playerid], 0.300, 1.500);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_rePass[playerid], TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawColour(playerid, pRegisterMenu_rePass[playerid], -1);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_rePass[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_rePass[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_rePass[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_rePass[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_rePass[playerid], true);

	pRegisterMenu_buttonCancel[playerid] = CreatePlayerTextDraw(playerid, 362.000, 309.000, "Cancel");
	PlayerTextDrawLetterSize(playerid, pRegisterMenu_buttonCancel[playerid], 0.300, 1.500);
	PlayerTextDrawTextSize(playerid, pRegisterMenu_buttonCancel[playerid], 500.000, 70.000);
	PlayerTextDrawAlignment(playerid, pRegisterMenu_buttonCancel[playerid], TEXT_DRAW_ALIGN_CENTER);
	PlayerTextDrawColour(playerid, pRegisterMenu_buttonCancel[playerid], -1);
	PlayerTextDrawUseBox(playerid, pRegisterMenu_buttonCancel[playerid], true);
	PlayerTextDrawBoxColour(playerid, pRegisterMenu_buttonCancel[playerid], 150);
	PlayerTextDrawSetShadow(playerid, pRegisterMenu_buttonCancel[playerid], 1);
	PlayerTextDrawSetOutline(playerid, pRegisterMenu_buttonCancel[playerid], 1);
	PlayerTextDrawBackgroundColour(playerid, pRegisterMenu_buttonCancel[playerid], 150);
	PlayerTextDrawFont(playerid, pRegisterMenu_buttonCancel[playerid], t_TEXT_DRAW_FONT:3);
	PlayerTextDrawSetProportional(playerid, pRegisterMenu_buttonCancel[playerid], true);
	PlayerTextDrawSetSelectable(playerid, pRegisterMenu_buttonCancel[playerid], true);

	PlayerTextDrawShow(playerid, pRegisterMenu_email[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_age[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_password[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_rePass[playerid]);

	PlayerTextDrawShow(playerid, pRegisterMenu_emailSymbol[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_ageSymbol[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_passwordSymbol[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_rePassSymbol[playerid]);

	PlayerTextDrawShow(playerid, pRegisterMenu_emailTypebox[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_ageTypebox[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_passwordTypebox[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_rePassTypebox[playerid]);

	PlayerTextDrawShow(playerid, pRegisterMenu_buttonRegister[playerid]);
	PlayerTextDrawShow(playerid, pRegisterMenu_buttonCancel[playerid]);

	SelectTextDraw(playerid, COLOR_WHITE);

}

stock HideRegisterMenu(playerid) {
	PlayerTextDrawHide(playerid, pRegisterMenu_email[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_age[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_password[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_rePass[playerid]);

	PlayerTextDrawHide(playerid, pRegisterMenu_emailSymbol[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_ageSymbol[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_passwordSymbol[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_rePassSymbol[playerid]);

	PlayerTextDrawHide(playerid, pRegisterMenu_emailTypebox[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_ageTypebox[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_passwordTypebox[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_rePassTypebox[playerid]);

	PlayerTextDrawHide(playerid, pRegisterMenu_buttonRegister[playerid]);
	PlayerTextDrawHide(playerid, pRegisterMenu_buttonCancel[playerid]);

	pRegisterMenu_email[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_age[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_password[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_rePass[playerid] = INVALID_PLAYER_TEXT_DRAW;

	pRegisterMenu_emailSymbol[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_ageSymbol[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_passwordSymbol[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_rePassSymbol[playerid] = INVALID_PLAYER_TEXT_DRAW;

	pRegisterMenu_emailTypebox[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_ageTypebox[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_passwordTypebox[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_rePassTypebox[playerid] = INVALID_PLAYER_TEXT_DRAW;

	pRegisterMenu_buttonRegister[playerid] = INVALID_PLAYER_TEXT_DRAW;
	pRegisterMenu_buttonCancel[playerid] = INVALID_PLAYER_TEXT_DRAW;

	CancelSelectTextDraw(playerid);
}