#include-once

Func _dorun()
	_log("======== new run ==========")

	Local $hTimer = TimerInit()
	While Not offsetlist() And TimerDiff($hTimer) < 30000 ; 30secondes
		Sleep(40)
	WEnd

    If TimerDiff($hTimer) >= 30000 Then
        Return False
    EndIf

	If $Totalruns = 1 And Not $PartieSolo Then 
		SetConfigPartieSolo(); TChat configuration du settings
	EndIf

	If $GameFailed = 0 Then
		$success += 1
	EndIf

	$successratio = $success / $Totalruns

	$GameFailed = 0
	$SkippedMove = 0

	StatsDisplay()

	If Not $hotkeycheck Then
		_log("CheckHotkeys init")
		CheckHotkeys()
		_log("Auto_Spell_init init")
		Auto_spell_init()
		_log("GestSpellInit")
		GestSpellInit()
		_log("LoadAttribGlobalStuff init")
		Load_Attrib_GlobalStuff()

		$maxhp = GetAttribute($_MyGuid, $Atrib_Hitpoints_Max_Total) ; dirty placement
		_log("Max HP : " & $maxhp)
		GetMaxResource($_MyGuid, $namecharacter)
		Send($KeyPortal)
		Sleep(500)
		Detect_Str_full_inventory()
		CheckAndDefineSize()
	EndIf

	If Not $PartieSolo Then 
		WriteMe($WRITE_ME_WELCOME) ; TChat
	EndIf
	
	GetAct()
	EmergencyStopCheck()

	If _checkRepair() Then
		NeedRepair()
	Else
		$NeedRepairCount = 0
	EndIf

	Sleep(100)

	enoughtPotions()
	init_sequence()

	sequence()
	_log("End Run. Gamefailed : " & $GameFailed)
	Return True
EndFunc   ;==>_dorun

Func _botting()
	_log("Start Botting")
	$bottingtime = TimerInit()

	AdlibRegister("Die2Fast", 1200000)
	While 1
		_log("new main loop")

		offsetlist()

		If _onloginscreen() Then
			_log("LOGIN")
			_logind3()
			Sleep(Random(60000, 120000))
		EndIf

		; Si Choix_Act_Run <> 0 le bot passe en mode automatique
		If $Choix_Act_Run <> 0 And _onloginscreen() = False Then
			If _ingame() = true and $TypedeBot < 2 Then ;si en jeu lors du lancement auto
				WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
				MsgBox(0, "ERREUR", "Vous devez être dans le menu pour lancer un run en auto !")
				Terminate()
			EndIf
			SelectQuest()
		EndIf

		If _inmenu() And _onloginscreen() = False Then
			If Not $PartieSolo And $Totalruns > 1 Then
			    WriteMe($WRITE_ME_TAKE_BREAK_MENU) ; TChat
				WriteMe($WRITE_ME_RESTART_GAME) ; TChat
			EndIf

			$DeathCountToggle = True
			_resumegame()
		EndIf

		While _onloginscreen() = False And _ingame() = False
			_log("Ingame False")
			If _checkdisconnect() Then
				$disconnectcount += 1
				_log("Disconnected dc4")
				Sleep(1000)
				ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022);pacht 8.2e
				Sleep(1000)
				While Not (_onloginscreen() Or _inmenu())
					Sleep(Random(10000, 15000))
				WEnd
				ContinueLoop 2
			EndIf
			_resumegame()
		WEnd

		If _onloginscreen() = False And _playerdead() = False And _ingame() = True Then
			$timermaxgamelength = TimerInit()
			If _dorun() = True Then
				$Try_ResumeGame = 0
				$Try_Logind3 = 0
				$BreakCounter += 1;on ce met a compter les games avant la pause
				$games += 1
				$gamecounter += 1
			EndIf
		EndIf


		If _onloginscreen() = False And _intown() = False And _playerdead() = False Then
			GoToTown()
		EndIf

		_log("start GoToTown from main 2")
		If _intown() Or _playerdead() And _onloginscreen() = False Then
			If _playerdead() = False And $games >= ($repairafterxxgames + Random(-2, 2, 1)) Then
				StashAndRepair()
				$games = 0
			EndIf

			If Not _checkdisconnect() Then
				_leavegame()
			Else
				_log("Disconnected dc2")
				$disconnectcount += 1
				Sleep(1000)
				ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022);pacht 8.2e
				sleep(50)
				ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022);pacht 8.2e
			EndIf

			If _playerdead() Then
				Sleep(Random(11000, 13000))
			EndIf
		EndIf

		Sleep(1000)
		_log('loop _inmenu() = False And _onloginscreen()')

		While _inmenu() = False And _onloginscreen() = False
			Sleep(10)
			If  _checkdisconnect() Then ; update 8.2d
				Sleep(1000)
				ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022);pacht 8.2e
				sleep(50)
				ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022);pacht 8.2e
			else
			;continue
			endif ; fin update 8.2d
		WEnd

	WEnd
EndFunc   ;==>_botting

Func CheckAndDefineSize()
	if $SizeWindows = 0 Then
		$SizeWindows = WinGetClientSize("[CLASS:D3 Main Window Class]")
		_log("Size Windows X : " & $SizeWindows[0] & " - Y : " & $SizeWindows[1])
	EndIF

	if $PointFinal[0] = 0 AND $PointFinal[1] = 0 AND $PointFinal[2] = 0 AND $PointFinal[3] = 0 Then

		;$result = GetOfsUI("Root.NormalLayer.game_notify_dialog_backgroundScreen.dlg_new_paragon.button", 0)
		$OfsBtnParagon = GetOfsFastUI("Root.NormalLayer.game_notify_dialog_backgroundScreen.dlg_new_paragon.button", 1028)
		Dim $TruePointBtnParagon = GetPositionUI($OfsBtnParagon)
		Dim $PointParagon = GetUIRectangle($TruePointBtnParagon[0], $TruePointBtnParagon[1], $TruePointBtnParagon[2], $TruePointBtnParagon[3])

		;$result = GetOfsUI("Root.NormalLayer.eventtext_bkgrnd.eventtext_region.checkbox", 0)
		$OfsBtnCheckBox = GetOfsFastUI("Root.NormalLayer.eventtext_bkgrnd.eventtext_region.checkbox", 31)
		Dim $TruePointCheckBox = GetPositionUI($OfsBtnCheckBox)
		Dim $PointCheckBox = GetUIRectangle($TruePointCheckBox[0], $TruePointCheckBox[1], $TruePointCheckBox[2], $TruePointCheckBox[3])

		;$result = GetOfsUI("Root.NormalLayer.portraits.stack.party_stack.portrait_0.Background", 0)
		$OfsPortrait = GetOfsFastUI("Root.NormalLayer.portraits.stack.party_stack.portrait_0.Background", 707)
		Dim $TruePointPortrait = GetPositionUI($OfsPortrait)
		Dim $PointPortrait = GetUIRectangle($TruePointPortrait[0], $TruePointPortrait[1], $TruePointPortrait[2], $TruePointPortrait[3])

		$PointFinal[0] = $PointPortrait[3] + $PointPortrait[0]
		$PointFinal[1] = $PointPortrait[2] + $PointPortrait[1]
		$PointFinal[2] = $PointCheckBox[0] - $PointFinal[1]
		$PointFinal[3] = $PointParagon[1] - $PointFinal[0]

		_log("Zone Clickable -> Y[0] : " & $PointFinal[0] & " - X[1] : " & $PointFinal[1] & " - Width[2] : " & $PointFinal[2] & " - Height[3] : " & $PointFinal[3])
	EndIF
EndFunc

Func Checkclickable($coord)
	if $coord[1] <= $PointFinal[0] Then
		$coord[1] = $PointFinal[0] + 1
	Elseif $coord[1] >= ($PointFinal[0] + $PointFinal[3]) Then
		$coord[1] =  ($PointFinal[0] + $PointFinal[3]) - 1
	EndIF

	if $coord[0] <= $PointFinal[1] Then
		$coord[0] = $PointFinal[1] + 1
	Elseif $coord[0] >= ($PointFinal[1] + $PointFinal[2]) Then
		$coord[0] = ($PointFinal[1] + $PointFinal[2]) - 1
	EndIF

	return $coord
EndFunc

Func ClickInventory($c, $l)
	$result = GetOfsFastUI("Root.NormalLayer.inventory_dialog_mainPage.timer slot 0 x0 y0", 1509)
	Dim $Point = GetPositionUI($result)
	Dim $Point2 = GetUIRectangle($Point[0], $Point[1], $Point[2], $Point[3])

	$FirstCaseX = $Point2[0] + $Point2[2] / 2
	$FirstCaseY = $Point2[1] + $Point2[3] / 2

	$SizeCaseX =  $Point2[2]
	$SizeCaseY =  $Point2[3]

	$XCoordinate = $FirstCaseX + $c * $SizeCaseX
	$YCoordinate = $FirstCaseY + $l * $SizeCaseY

	MouseClick("right", $XCoordinate, $YCoordinate)
EndFunc


;;--------------------------------------------------------------------------------
;;     Check KeyTo avoid sell of equiped stuff
;;--------------------------------------------------------------------------------
Func CheckHotkeys()
	Sleep(2000)
	Send($KeyInventory)
	Sleep(500)
	If _checkInventoryopen() = False Then
		WinSetOnTop("Diablo III", "", 0)
		MsgBox(0, "Mauvais Hotkey", "La touche pour ouvrir l'inventaire doit être : " & $KeyInventory & @CRLF)
		Terminate()
	EndIf
	Sleep(185)
	Send($KeyCloseWindows) ; make sure we close everything
	Sleep(250)
	If _checkInventoryopen() = True Then
		WinSetOnTop("Diablo III", "", 0)
		MsgBox(0, "Mauvais Hotkey", "La touche pour fermer les fenêtres doit être : " & $KeyCloseWindows & @CRLF)
		Terminate()
	EndIf
	_log("Check des touches OK")
	$hotkeycheck = True
EndFunc   ;==>CheckHotkeys


;;--------------------------------------------------------------------------------
;;     Initialise Buffs while in training Area
;;--------------------------------------------------------------------------------
Func Buffinit()
	If $PreBuff1 Then
		buff1()
		If $delaiBuff1 Then
			AdlibRegister("buff1", $delaiBuff1 * Random(1, 1.2))
		EndIf
		Sleep(400)
	EndIf
	If $PreBuff2 Then
		buff2()
		If $delaiBuff2 Then
			AdlibRegister("buff2", $delaiBuff2 * Random(1, 1.2))
		EndIf
		Sleep(400)
	EndIf
	If $PreBuff3 Then
		buff3()
		If $delaiBuff3 Then
			AdlibRegister("buff3", $delaiBuff3 * Random(1, 1.2))
		EndIf
		Sleep(400)
	EndIf
	If $PreBuff4 Then
		buff4()
		If $delaiBuff4 Then
			AdlibRegister("buff4", $delaiBuff4 * Random(1, 1.2))
		EndIf
		Sleep(400)
	EndIf
EndFunc   ;==>Buffinit



;;--------------------------------------------------------------------------------
;;     Stop All buff timers
;;--------------------------------------------------------------------------------
Func UnBuff()
	If $delaiBuff1 And $PreBuff1 Then
		AdlibUnRegister("buff1")
	EndIf
	If $delaiBuff2 And $PreBuff2 Then
		AdlibUnRegister("buff2")
	EndIf
	If $delaiBuff3 And $PreBuff3 Then
		AdlibUnRegister("buff3")
	EndIf
	If $delaiBuff4 And $PreBuff4 Then
		AdlibUnRegister("buff4")
	EndIf
EndFunc   ;==>UnBuff

Func buff1()
	Send($Key1)
EndFunc   ;==>buff1

Func buff2()
	Send($Key2)
EndFunc   ;==>buff2

Func buff3()
	Send($Key3)
EndFunc   ;==>buff3

Func buff4()
	Send($Key4)
EndFunc   ;==>buff4