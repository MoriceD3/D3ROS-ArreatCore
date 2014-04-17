#include-once

Func _dorun()
	_log("*** Starting new run", $LOG_LEVEL_VERBOSE)

	Local $hTimer = TimerInit()
	While Not offsetlist() And TimerDiff($hTimer) < 60000 ; 60secondes
		Sleep(40)
	WEnd

    If TimerDiff($hTimer) >= 60000 Then
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
	$PortBack = False

	StatsDisplay()

	If Not $hotkeycheck Then
		CheckHotkeys()
		CheckGameMode()
		Auto_spell_init()
		GestSpellInit()
		Load_Attrib_GlobalStuff()

		$maxhp = GetAttribute($_MyGuid, $Atrib_Hitpoints_Max_Total) ; dirty placement
		_log("Max HP : " & $maxhp, $LOG_LEVEL_VERBOSE)
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

	sequence($File_Sequence)
	_log("End Run. Gamefailed : " & $GameFailed, $LOG_LEVEL_VERBOSE)
	Return True
EndFunc   ;==>_dorun

Func _botting()
	_log("Start Botting", $LOG_LEVEL_VERBOSE)
	$bottingtime = TimerInit()

	AdlibRegister("Die2Fast", 1200000)
	While 1
		_log("New main loop", $LOG_LEVEL_DEBUG)

		offsetlist()

		If _onloginscreen() Then
			_log("LOGIN", $LOG_LEVEL_WARNING)
			_logind3()
			
			Local $WaitingTime = 0
			While Not _inmenu() And $WaitingTime < 155
			   Sleep(500)
			   $WaitingTime +=1
			WEnd
		EndIf

		; Si Choix_Act_Run <> 0 le bot passe en mode automatique
		If $Choix_Act_Run <> 0 And Not _onloginscreen() Then
			If _ingame() = true and $TypedeBot < 2 Then ;si en jeu lors du lancement auto
				WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
				MsgBox(0, "ERREUR", "Vous devez être dans le menu pour lancer un run en auto !")
				Terminate()
			EndIf
			SelectQuest()
		EndIf

		If _inmenu() And Not _onloginscreen() Then
			If Not $PartieSolo And $Totalruns > 1 Then
			    WriteMe($WRITE_ME_TAKE_BREAK_MENU) ; TChat
				WriteMe($WRITE_ME_RESTART_GAME) ; TChat
			EndIf
			_log("We are in menu : Resuming game", $LOG_LEVEL_VERBOSE)
			$DeathCountToggle = True
			_resumegame()
			Sleep(1500)
		EndIf

		While Not _onloginscreen() And Not _ingame()
			_log("Ingame False", $LOG_LEVEL_WARNING)
			If _checkdisconnect() Then
				_log("Disconnected dc4", $LOG_LEVEL_WARNING)
				ReConnect()
				While Not (_onloginscreen() Or _inmenu())
					Sleep(Random(10000, 15000))
				WEnd
				ContinueLoop 2
			EndIf
			_resumegame()
			Sleep(1500)
		WEnd

		If Not _onloginscreen() And Not _playerdead() And _ingame() Then
			If $Choix_Act_Run = -3 Then
				$Table_BountyAct = StringSplit($List_BountyAct,"|",2)
				_ArraySortRandom($Table_BountyAct)
				$temp = GetBountySequences($Table_BountyAct)
				If $temp = False Then
					_log("No possible bounty found. Skipping this run" , $LOG_LEVEL_ERROR)
					$File_Sequence = ""
					$BreakCounter += 1 ; On augmente qd meme le break counter pour éviter trop de création de game
				Else
					$File_Sequence = $temp
				EndIf
			EndIf

			If Not $File_Sequence = "" Then
				$timermaxgamelength = TimerInit()
				If _dorun() = True Then
					$Try_ResumeGame = 0
					$Try_Logind3 = 0
					$BreakCounter += 1 ;on se met a compter les games avant la pause
					$games += 1
					$gamecounter += 1
				EndIf
			EndIf
		EndIf

		If Not _onloginscreen() And Not _intown() And Not _playerdead() Then
			_log("Return to town after run", $LOG_LEVEL_VERBOSE)
			GoToTown()
		EndIf

		If (_intown() Or _playerdead()) And Not _onloginscreen() Then
			If Not _playerdead() And $games >= ($repairafterxxgames + Random(-2, 2, 1)) Then
				StashAndRepair()
				$games = 0
			EndIf

			If Not _checkdisconnect() Then
				_leavegame()
			Else
				_log("Disconnected dc2", $LOG_LEVEL_WARNING)
				ReConnect()
			EndIf

			If _playerdead() Then
				Sleep(Random(11000, 13000))
			EndIf
		EndIf

		Sleep(1000)
		_log('End of run looping : Not _inmenu() And Not _onloginscreen()')
		While Not _inmenu() And Not _onloginscreen()
			If _checkdisconnect() Then
				_log("Disconnected dc3", $LOG_LEVEL_WARNING)
				ReConnect()
			Else
			    Sleep(100)
			Endif
		WEnd

	WEnd
EndFunc   ;==>_botting

Func CheckAndDefineSize()
	If $PointFinal[0] = 0 And $PointFinal[1] = 0 And $PointFinal[2] = 0 And $PointFinal[3] = 0 Then

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

		_log("Zone Clickable -> Y[0] : " & $PointFinal[0] & " - X[1] : " & $PointFinal[1] & " - Width[2] : " & $PointFinal[2] & " - Height[3] : " & $PointFinal[3], $LOG_LEVEL_DEBUG)
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

	Return $coord
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

Func CheckGameMode()
    _Log("What game mode you are", $LOG_LEVEL_DEBUG)

	While Not _checkWPopen() And Not _checkdisconnect()
		Send("M")
		Sleep(1000)
	WEnd

	If fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.BountyOverlay.Rewards.BagReward", 1, 85) Then
	   $ModePlaying = $PLAYING_MODE_ADVENTURE
	   _Log("Adventure Mode", $LOG_LEVEL_VERBOSE)
	Else
	   $ModePlaying = $PLAYING_MODE_STORY
	   _Log("Story Mode", $LOG_LEVEL_VERBOSE)
	EndIf

	While _checkWPopen() And Not _checkdisconnect()
	   Send($KeyCloseWindows)
	   Sleep(250)
	WEnd
	Sleep(500)
EndFunc
 
;;--------------------------------------------------------------------------------
;;     Check KeyTo avoid sell of equiped stuff
;;--------------------------------------------------------------------------------
Func CheckHotkeys()
	_log("CheckHotkeys", $LOG_LEVEL_DEBUG)
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
	_log("Check des touches OK", $LOG_LEVEL_VERBOSE)
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
		Sleep(500)
	EndIf
	If $PreBuff2 Then
		buff2()
		If $delaiBuff2 Then
			AdlibRegister("buff2", $delaiBuff2 * Random(1, 1.2))
		EndIf
		Sleep(500)
	EndIf
	If $PreBuff3 Then
		buff3()
		If $delaiBuff3 Then
			AdlibRegister("buff3", $delaiBuff3 * Random(1, 1.2))
		EndIf
		Sleep(500)
	EndIf
	If $PreBuff4 Then
		buff4()
		If $delaiBuff4 Then
			AdlibRegister("buff4", $delaiBuff4 * Random(1, 1.2))
		EndIf
		Sleep(500)
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
	_log("Lancement du buff 1 en pré-buff")
	Send($Key1)
EndFunc   ;==>buff1

Func buff2()
	_log("Lancement du buff 2 en pré-buff")
	Send($Key2)
EndFunc   ;==>buff2

Func buff3()
	_log("Lancement du buff 3 en pré-buff")
	Send($Key3)
EndFunc   ;==>buff3

Func buff4()
	_log("Lancement du buff 4 en pré-buff")
	Send($Key4)
EndFunc   ;==>buff4