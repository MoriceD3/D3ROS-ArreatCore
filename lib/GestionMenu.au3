#include-once
#include <File.au3>
#cs ----------------------------------------------------------------------------

	Extension permettant de gerer le menu

#ce ----------------------------------------------------------------------------

;--------------------------------------------------------------
; Choix de l'acte
;-------------------------------------------------------------

Func SelectGameType($SelectGameType, $auto)

	;Automatisation des sequences sur enchainement de run
	If $auto Then
		Switch $SelectGameType
			Case -3
				$File_Sequence = ""
			Case -2
				$File_Sequence = $SequenceFileAdventure
			Case 1
				$File_Sequence = $SequenceFileAct1
			Case 2
				$File_Sequence = $SequenceFileAct2
			Case 3
			    $File_Sequence = $SequenceFileAct3PtSauve
			Case 222
				$File_Sequence = $SequenceFileAct222
			Case 232
				$File_Sequence = $SequenceFileAct232
			Case 283
				$File_Sequence = $SequenceFileAct283
			Case 299
			    $File_Sequence = $SequenceFileAct299
			Case 333
				$File_Sequence = $SequenceFileAct333
			Case 362
				$File_Sequence = $SequenceFileAct362
			Case 373
				$File_Sequence = $SequenceFileAct373
			Case 374
				$File_Sequence = $SequenceFileAct374
			Case 411
			    $File_Sequence = $SequenceFileAct411
			Case 442
			    $File_Sequence = $SequenceFileAct442
		EndSwitch
	EndIf

	Local $Waiting_Time = 0
	While Not _inmenu() And $TypedeBot <> 2 And $Waiting_Time < 50
	   Sleep(1000)
	   $Waiting_Time += 1
	WEnd

	If $Follower Then
	   Return
	Else
	   While _inmenu() And Not fastcheckuiitemactived("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.ChangeQuestButton", 270)
			If Not _checkdisconnect() Then
			   _log("Wait Other Follower")
			   sleep(1000)
			Else
			   Return
			EndIf
	   WEnd
    EndIf


	CheckWindowsClosed()
	;Selection du Heros en auto
	If ($TypedeBot = 1) Then
	   If ($Totalruns = 1) Or $NewHeros Then
		  If $NewHeros Then
			 Sleep(Random(3000, 3500, 1))
		  EndIf
		  SelectHero()
		  If ($SelectGameType <> -1 And $SelectGameType < 4) And $FirstConfigModeOk Then
			 Return
		  EndIf
	   EndIf
	EndIf

	Sleep(Random(1500, 2000, 1))

	If $TypedeBot <> 2 And _inmenu() Then
		Sleep(Random(700, 800, 1))
		_log("Game Settings", $LOG_LEVEL_DEBUG)
		ClickUI("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.ChangeQuestButton", 270)
		Sleep(Random(700, 800, 1))

		Local $Waiting_Time = 0
		While Not IsGameSettingsOpened() And $Waiting_Time < 11
		   Sleep(500)
		   $Waiting_Time += 1
		WEnd

		If IsGameSettingsOpened() Then
		   If ($Totalruns = 1) Or ($NewHeros And Not $FirstConfigModeOk) Then
			  _log("Passage de la partie en mode privé", $LOG_LEVEL_DEBUG)
			  ClickUi("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.AdventureModeContent.PrivateGameButton" , 1647)
			  Sleep(Random(600, 800, 1))
			  If $SelectGameType > -2 Then
				 _log("Passage en mode Campagne", $LOG_LEVEL_DEBUG)
				 ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeButton", 199)
				 Sleep(Random(600, 800, 1))
				 If $TypedeBot = 1 Then
					SelectDifficultyMonsterPower()
				 EndIf
			  Else
				 _log("Passage en mode Aventure", $LOG_LEVEL_DEBUG)
				 ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.AdventureModeButton", 1581)
				 Sleep(Random(600, 800, 1))
				 If $TypedeBot = 1 Then
					SelectDifficultyMonsterPower()
				 EndIf
				 _log("Save And Close")
				 ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.SaveAndClose", 809)
				 Sleep(Random(600, 800, 1))
				 Return
			  EndIf
		   EndIf

		   Local $Waiting_Time = 0
		   While Not IsGameSettingsOpened() And $Waiting_Time < 11
			  Sleep(500)
			  $Waiting_Time += 1
		   WEnd

		  ;Selection -> CHANGER DE QUETE
		   _log("Choose a New Quest", $LOG_LEVEL_DEBUG)
		   ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeContent.ChangeQuestButton" , 954)
		   Sleep(Random(700, 800, 1))

		   Local $Waiting_Time = 0
		   While Not IsQuestOpened() And $Waiting_Time < 11
			  Sleep(500)
			  $Waiting_Time += 1
		   WEnd

		   If Not IsQuestOpened() Then
			  _log("Quest Menu No Opened, Retry ", $LOG_LEVEL_DEBUG)
			  Local $TryOpened = 0
			  While Not IsQuestOpened() And $TryOpened < 6
				 ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeContent.ChangeQuestButton" , 954)
				 $TryOpened += 1
				 _log("Try " & $TryOpened & " Open Quest Menu", $LOG_LEVEL_DEBUG)
				 Sleep(2000)
			  WEnd
		   EndIf

		   ;Selection de la quête
		   If IsQuestOpened() Then

			  Sleep(Random(600, 800, 1))
			  _log("Scroll The List Of Quests")
			  For $i = 1 To Random(40, 41, 1) Step 1;balayer toutes les quêtes
				 MouseWheel("up")
				 Sleep(Random(100, 150, 1))
			  Next

			  ;selection d'une quete pour fermer les sous quetes
			  _log("Close The Current Quests")
			  ClickUIMode(0, 0, -20, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
			  Sleep(1000)
			  ClickUIMode(0, 0, -20, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
			  Sleep(1000)

			  Switch $SelectGameType
				   Case 1;selection de la quête 10.1 act 1
					  _log("Choose Act 1, Quest 10.1", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 7 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 10")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 1 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 1")

				   Case 2;selection de la quête 8.3
					  _log("Choose Act 2, Quest 8.3", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 16 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 0, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 8")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 3")

				   Case 3;selection de la quête 7.3
					  _log("Choose Act 3, Quest 7.3", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 26 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 0, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 7")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 5, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 3")

				   Case 222;Act 2 quête 2 sous quête 2 --> Tuer Lieutenent Vachem
					  _log("Choose Act 2, Quest 2.2 --> Tuer Lieutenent Vachem", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 10 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -20, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 2")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -45, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 2")

				   Case 232;Act 2 quête 3 sous quête 2 --> Tuer Maghda
					  _log("Choose Act 2, Quest 3.2 --> Tuer Maghda", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 11 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -20, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 3")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -40, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 2")

				   Case 283;Act 2 quête 8 sous quête 3 --> Tuer Zoltun Kulle
					  _log("Choose Act 2, Quest 8.3 --> Tuer Zoltun Kulle", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 16 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 0, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 8")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 3")

				   Case 299;Act 2 quête 10 sous quête 1 --> Tuer Belial
					  _log("Choose Act 2, Quest 10.1 --> Tuer Belial", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 18 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 0, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 10")
					  Sleep(Random(600, 800, 1))

					  ClickUIMode(0, 0, 50, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 1")

				   Case 333 ; Act 3 quête 3 sous quête 3 --> tuez Ghom
					  _log("Choose Act 3, Quest 3.3 --> tuez Ghom", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 22 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 3")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 0, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 3")

				   Case 362 ; Act 3 quête 6 sous quête 2 --> Tuez le briseur de siège
					  _log("Choose Act 3, Quest 6.2 --> Tuez Briseur De Siège", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 25 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 0, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 6")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -30, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 2")

				   Case 373 ; Act 3 quête 7 sous quête 3 --> Terrasez Asmodam
					  _log("Choose Act 3, Quest 7.3 --> Terrasez Asmodam", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 26 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 0, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 7")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 5, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 3")

				   Case 374 ; Act 3 quête 7 sous quête 3 --> Terrasez Asmodam, Iskatu et Rakanoth
					  _log("Choose Act 3, Quest 7.3 --> Terrasez Asmodam, Iskatu et Rakanoth", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 26 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 0, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 7")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 5, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 3")

				   Case 411 ; Act 4 quête 1 sous quête 1 --> Terrasez Iskatu et Rakanoth
					  _log("Choose Act 4, Quest 1.1 --> Terrasez Iskatu et Rakanoth", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 27 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 45, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 1")
					  Sleep(Random(600, 800, 1))

					  ClickUIMode(0, 0, 90, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 1")

				   Case 442 ; Act 4 quête 4 sous quête 2 --> Terrasez Diablo
					  _log("Choose Act 4, Quest 4.2 --> Terrasez Diablo", $LOG_LEVEL_DEBUG)
					  For $i = 1 To 27 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 215, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Quest 4")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 200, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61", 810)
					  _log("Select Sub Quest 2")

			  EndSwitch

			  Sleep(Random(300, 400, 1))
			  _log("Validate Quest")
			  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.SelectQuestButton" , 663)
			  Sleep(Random(1000, 1500, 1))

			  If IsQuestChangeUiOpened() Then
				 _log("Detection Quests Change", $LOG_LEVEL_DEBUG)
				 Sleep(Random(300, 400, 1))
				 _log("Validate To Change Current Quests")
				 ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList.OkButton", 1606)
			  EndIf
			  Sleep(Random(600, 800, 1))
			  _log("Save And Close")
			  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.SaveAndClose", 809)
			  Sleep(Random(800, 1000, 1))
			  CheckWindowsClosed()
		   Else
			  _log("Quest Menu No Opened, Back To Menu", $LOG_LEVEL_DEBUG)
			  CheckWindowsClosed()
			  _log("Retry SelectQuest", $LOG_LEVEL_DEBUG)
			  SelectQuest()
		   EndIf
	   Else
		  _log("Game Settings No Opened, Retry SelectQuest", $LOG_LEVEL_DEBUG)
		  SelectQuest()
	   EndIf
	EndIf
EndFunc   ;==>SelectGameType

Func SelectQuest()
	If _checkdisconnect() Or _onloginscreen() Then
	   Return
	EndIf
	If $CheckChangeHeros Then
	   SetNewHeros()
	EndIf
	If ($Choix_Act_Run = -3) And (($Totalruns = 1) Or $NewHeros) Then
	   SelectGameType(-3, True)
	EndIf
	If ($Choix_Act_Run = -2) And (($Totalruns = 1) Or $NewHeros) Then
	   SelectGameType(-2, True)
	EndIf
	If ($Choix_Act_Run = 1) And (($Totalruns = 1) Or $NewHeros) Then
	   SelectGameType(1, True)
	EndIf
	If ($Choix_Act_Run = 2) And (($Totalruns = 1) Or $NewHeros) Then
	   SelectGameType(2, True)
	EndIf
	If ($Choix_Act_Run = 3) Then
	   If ($Totalruns = 1) Then
		  SelectGameType(3, True)
	   EndIf
	   If (($Totalruns = 2) And Not $CheckChangeHeros) Then
		  $File_Sequence = $SequenceFileAct3
	   EndIf
	   If $CheckChangeHeros Then
		  If $NewHeros Then
			 If Not $FirstConfigModeOk Then
				SelectGameType(3, True)
			 Else
				SelectGameType(3, False)
			 EndIf
		  EndIf
		  If $RunCounter_BeforeChangeHeros = 1 Then
			 $File_Sequence = $SequenceFileAct3
		  EndIf
	   EndIf
	EndIf
	If ($Choix_Act_Run = 222) Then
	   SelectGameType(222, True)
	EndIf
	If ($Choix_Act_Run = 232) Then
	   SelectGameType(232, True)
	EndIf
	If ($Choix_Act_Run = 283) Then
	   SelectGameType(283, True)
	EndIf
	If ($Choix_Act_Run = 299) Then
	   SelectGameType(299, True)
	EndIf
	If ($Choix_Act_Run = 333) Then
	   SelectGameType(333, True)
	EndIf
	If ($Choix_Act_Run = 362) Then
	   SelectGameType(362, True)
	EndIf
	If ($Choix_Act_Run = 373) Then
	   SelectGameType(373, True)
	EndIf
	If ($Choix_Act_Run = 374) Then
	   SelectGameType(374, True)
	EndIf
	If ($Choix_Act_Run = 411) Then
	   SelectGameType(411, True)
    EndIf
	If ($Choix_Act_Run = 442) Then
	   SelectGameType(442, True)
	EndIf

	;Selection de la quete en automatique et enchainement des actes
	If $Choix_Act_Run = -1 Then
		;Initialisation de la séquence
		If ($Totalruns = 1) Or ($Totalruns = $NbreRunChangSeqAlea) Then
			$act = 0
			$NombreRun_Encour = 0
			;Chainage aléatoire ou non des actes
			If $Sequence_Aleatoire Then
				;$ChainageActe[6][3]=[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
				Local $ligne = Random(0, 5, 1)
				For $colonne = 0 To 2 Step 1
					$ChainageActeEnCour[$colonne] = $ChainageActe[$ligne][$colonne]
				Next
			Else
				$ChainageActeEnCour[0] = 1
				$ChainageActeEnCour[1] = 2
				$ChainageActeEnCour[2] = 3
			EndIf
			$ColonneEnCour = 0
			$Act_Encour = $ChainageActeEnCour[$ColonneEnCour]
			SelectGameType($Act_Encour, True)

			;Création d un fichier de log pour le mode automatique
			If ($Totalruns = 1) Then
				Local $TIME = @MDAY & @MON & @YEAR & "_" & @HOUR & @MIN & @SEC
				$fileLog = ".\stats\StatsRunAuto" & $TIME & ".txt"
				FileWrite($fileLog, "Run automatique du " & @MDAY & "/" & @MON & "/" & @YEAR & " à " & @HOUR & ":" & @MIN & ":" & @SEC & @CRLF)
				$numLigneFichier = 2
				_FileWriteToLine($fileLog, $numLigneFichier, "Chainage : Act " & $ChainageActeEnCour[0] & ", " & $ChainageActeEnCour[1] & " et " & $ChainageActeEnCour[2], 1)
				$numLigneFichier = $numLigneFichier + 1
			Else
				$numLigneFichier = $numLigneFichier + 1
				Local $TIME = @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC
				_FileWriteToLine($fileLog, $numLigneFichier, $TIME, 1)
				$numLigneFichier = $numLigneFichier + 1
				_FileWriteToLine($fileLog, $numLigneFichier, "Changement de Chainage : Act " & $ChainageActeEnCour[0] & ", " & $ChainageActeEnCour[1] & " et " & $ChainageActeEnCour[2], 1)
				$numLigneFichier = $numLigneFichier + 1
				_FileWriteToLine($fileLog, $numLigneFichier, "Act " & $Act_Encour & ": " & $NombreRun_Encour & "/" & $NombreDeRun, 1)
				$NbreRunChangSeqAlea = $NbreRunChangSeqAlea + $Totalruns
			EndIf

			If ($Nombre_de_Run = 0) Then
				Switch $Act_Encour
					Case 1
						$NombreDeRun = Random($NombreMiniAct1, $NombreMaxiAct1, 1)
					Case 2
						$NombreDeRun = Random($NombreMiniAct2, $NombreMaxiAct2, 1)
					Case 3
						$NombreDeRun = Random($NombreMiniAct3, $NombreMaxiAct3, 1)
				EndSwitch
			Else
				$NombreDeRun = $Nombre_de_Run
			EndIf
		EndIf

		;Changement d acte lorsque l'on a atteint le mombre de run max
		If ($NombreRun_Encour >= $NombreDeRun) Then
			$act = 0
			If $ColonneEnCour < 2 Then
				$ColonneEnCour = $ColonneEnCour + 1
			Else
				$ColonneEnCour = 0
			EndIf
			$Act_Encour = $ChainageActeEnCour[$ColonneEnCour]
			SelectGameType($Act_Encour, True)
			$NombreRun_Encour = 1
			If ($Nombre_de_Run = 0) Then
				Switch $Act_Encour
					Case 1
						$NombreDeRun = Random($NombreMiniAct1, $NombreMaxiAct1, 1)
					Case 2
						$NombreDeRun = Random($NombreMiniAct2, $NombreMaxiAct2, 1)
					Case 3
						$NombreDeRun = Random($NombreMiniAct3, $NombreMaxiAct3, 1)
				EndSwitch
			EndIf
			$numLigneFichier = $numLigneFichier + 1
			Local $TIME = @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC
			_FileWriteToLine($fileLog, $numLigneFichier, $TIME, 1)
			$numLigneFichier = $numLigneFichier + 1
			_FileWriteToLine($fileLog, $numLigneFichier, "Act " & $Act_Encour & ": " & $NombreRun_Encour & "/" & $NombreDeRun, 1)
		Else
			If ($Act_Encour = 3) And ($NombreRun_Encour = 1) Then
				$File_Sequence = $SequenceFileAct3
			EndIf
			$NombreRun_Encour = $NombreRun_Encour + 1
			_FileWriteToLine($fileLog, $numLigneFichier, "Act " & $Act_Encour & ": " & $NombreRun_Encour & "/" & $NombreDeRun, 1)
		EndIf
	EndIf
EndFunc   ;==>SelectQuest

Func SelectHero()

	_log("Switch Hero", $LOG_LEVEL_DEBUG)
	ClickUI("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Slot1.LayoutRoot.SwitchHero", 1223)
	Sleep(Random(600, 800, 1))

    Local $Waiting_Time = 0
	While Not IsMenuHeroSelectOpened() And $Waiting_Time < 11
	   Sleep(500)
	   $Waiting_Time += 1
	WEnd

	If IsMenuHeroSelectOpened() Then

	   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.HeroSelectList.HeroList._scrollbar.up", 606)
	   Sleep(Random(600, 800, 1))

	   _log("Scroll The List Of Heros")
	   For $i = 1 To Random(13, 15, 1) Step 1
		  MouseWheel("up")
		  Sleep(Random(100, 150, 1))
	   Next

	   Sleep(Random(500, 750, 1))

	   Switch $ListOfHeros[$TabHeros]
			Case 1
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed36", 1109)
			   _log("Select Hero 1")
			Case 2
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed37", 1100)
			   _log("Select Hero 2")
			Case 3
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed38", 1464)
			   _log("Select Hero 3")
			Case 4
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed39", 1889)
			   _log("Select Hero 4")
			Case 5
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed40", 821)
			   _log("Select Hero 5")
			Case 6
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed41", 1264)
			   _log("Select Hero 6")
			Case 7
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed42", 1458)
			   _log("Select Hero 7")
			Case 8
			   For $i = 1 To 5 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed40", 821)
			   _log("Select Hero 8")
			Case 9
			   For $i = 1 To 5 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed41", 1264)
			   _log("Select Hero 9")
			Case 10
			   For $i = 1 To 5 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed42", 1458)
			   _log("Select Hero 10")
			Case 11
			   For $i = 1 To 9 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed41", 1264)
			   _log("Select Hero 11")
			Case 12
			   For $i = 1 To 9 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed42", 1458)
			   _log("Select Hero 12")
			Case 13
			   For $i = 1 To 13 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed40", 821)
			   _log("Select Hero 13")
			Case 14
			   For $i = 1 To 13 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed41", 1264)
			   _log("Select Hero 14")
			Case 15
			   For $i = 1 To 13 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed42", 1458)
			   _log("Select Hero 15")
	   EndSwitch
	   Sleep(Random(600, 800, 1))

	   _log("Validate Hero")
	   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.SelectHeroButton", 1022)
	   Sleep(Random(2000, 2500, 1)) ; temps mini de chargement du hero 2000ms
	   CheckWindowsClosed()
    Else
	   If Not _checkdisconnect() Then
		  _log("Hero Menu No Opened, Retry SelectHero", $LOG_LEVEL_DEBUG)
		  SelectHero()
	   Else
		  Return
	   EndIf
    EndIf
EndFunc   ;==>SelectHero

Func SelectDifficultyMonsterPower()

	_log("Change Difficulty", $LOG_LEVEL_DEBUG)
	If  $Choix_Act_Run > -2 Then
	   ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeContent.ChangeDifficultyButton" , 269)
	   Sleep(Random(600, 800, 1))
	Else
	  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.AdventureModeContent.ChangeDifficultyButton" , 1969)
	  Sleep(Random(600, 800, 1))
    EndIf

    Local $Waiting_Time = 0
	While Not IsGameDifficultyOpened() And $Waiting_Time < 11
	   Sleep(500)
	   $Waiting_Time += 1
	WEnd

	If IsGameDifficultyOpened() Then

	   Switch $difficulte
			Case 1 ;Normal
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_0" , 1865)
				_log("Select Difficulte Normal")
			Case 2 ;Difficile
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_1" , 1392)
				_log("Select Difficulte Hard")
			Case 3 ;Expert
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_2" , 588)
				_log("Select Difficulte Expert")
			Case 4 ;Calvaire
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_3" , 1037)
				_log("Select Difficulte Master")
			Case 5 ;Tourment
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_4" , 1164)
				_log("Select Difficulte Torment " & $PuisMonstre)
	   EndSwitch

	   Sleep(Random(600, 800, 1))

	   ;Selection de la barre du menu des difficulté de Tourment
	   If $difficulte = 5 Then
		  Switch $PuisMonstre
			   Case 1
				   ClickUIMode(1, -130, 0, "Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Details.Slider.MaxSlider.trackDown")
			   Case 2
				   ClickUIMode(1, -80, 0, "Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Details.Slider.MaxSlider.trackDown")
			   Case 3
				   ClickUIMode(1, -30, 0, "Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Details.Slider.MaxSlider.trackDown")
			   Case 4
				   ClickUIMode(1, 20, 0, "Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Details.Slider.MaxSlider.trackDown")
			   Case 5
				   ClickUIMode(1, 70, 0, "Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Details.Slider.MaxSlider.trackDown")
			   Case 6
				   ClickUIMode(1, 120, 0, "Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Details.Slider.MaxSlider.trackDown")
		  EndSwitch

		  Sleep(Random(600, 800, 1))
	   EndIf

	   _log("Validate Difficulty")
	   ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.PlayGameButton" , 253); tap OK Difficulty
	   Sleep(Random(1000, 1500, 1))
    Else
	   If Not _checkdisconnect() Then
		  _log("Game Difficulty No Opened, Retry Select Difficulty And MonsterPower", $LOG_LEVEL_DEBUG)
		  SelectDifficultyMonsterPower()
	   Else
		  Return
	   EndIf
    EndIf
EndFunc   ;==>SelectDifficultyMonsterPower

Func SetNewHeros()

	If Not $NbTabHeros Then
	   For $i = 1 To UBound($ListOfHeros) - 1
		  $NbTabHeros += 1
	   Next

	   If $NbTabHeros = 1 Then
		  $CheckChangeHeros = 0
	   EndIf
	   If $CheckChangeHeros Then
		  If $Follower Then
			 _log("Pas Changement De Perso Follower Active", $LOG_LEVEL_DEBUG)
			 $CheckChangeHeros = 0
		  EndIf
		  If ($TypedeBot <> 1) Then
			 _log("Passage En Type De Bot 1", $LOG_LEVEL_DEBUG)
			 $TypedeBot = 1
		  EndIf
		  If ($Choix_Act_Run = -1) Then ;TODO a retirer une fois gerer
			 WinSetOnTop("Diablo III", "", 0)
			 MsgBox(0, "ERREUR", "Le Mode Choix_Act_Run = -1 n'est pas gerer pour l'instant,pour un changement de perso !")
			 Terminate()
		  EndIf
	   EndIf
	   Return
	EndIf

	If $CheckChangeHeros And $FirstPass_SetNewHeros Then

	   $RunCounter_BeforeChangeHeros += 1
	   $FirstPass_SetNewHeros = 0

	   If $RunCounter_BeforeChangeHeros >= ($NbRunChangeHeros + (Random(2, 4, 1))) Then
		  $TabHeros += 1
		  If $TabHeros > $NbTabHeros Then
			 $FirstConfigModeOk = 1
			 $TabHeros = 1
		  EndIf

		  _log("New Heros " & $ListOfHeros[$TabHeros], $LOG_LEVEL_DEBUG)
		  InitSettingsHeros()
		  $RunCounter_BeforeChangeHeros = 0
		  $NewHeros = 1
	   EndIf
	EndIf
EndFunc  ;==> SetNewHeros

Func ClickUIMode($mode, $x, $y, $name, $bucket = -1)
	If $bucket = -1 Then ;no bucket given slow method
		$result = GetOfsUI($name, 1)
	Else ;bucket given, fast method
		$result = GetOfsFastUI($name, $bucket)
	EndIf

	If $result = False Then
		_log("(ClickUI) UI DOESNT EXIT ! -> " & $name & " (" & $bucket  & ")", $LOG_LEVEL_ERROR)
		Return False
	EndIf

	Dim $Point = GetPositionUI($result)

	While $Point[0] = 0 AND $Point[1] = 0
		$Point = GetPositionUI($result)
		sleep(250)
	WEnd

	Dim $Point2 = GetUIRectangle($Point[0] + $x, $Point[1] + $y, $Point[2] + $x, $Point[3] + $y)

	Switch $mode
		 Case 0
			MouseMove(($Point2[0] + $Point2[2] / 2) , $Point2[1] + $Point2[3] / 2)
			Sleep(500)
			MouseClick("left")
		 Case 1
			MouseClick("left", ($Point2[0] + $Point2[2] / 2) , $Point2[1] + $Point2[3] / 2)
			MouseDown("left")
			Sleep(300)
			MouseUp("left")
			Sleep(50)
    EndSwitch
EndFunc  ;====> ClickUIMode

Func CheckWindowsClosed()
    If IsMenuHeroSelectOpened() Then
	   _log("Menu Hero Select Not Close --> Closed", $LOG_LEVEL_DEBUG)
	   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.SelectHeroButton", 1022)
	   Sleep(2000)
	EndIf
	If IsQuestChangeUiOpened() Then
	   _log("Quest Change Ui Not Close --> Closed", $LOG_LEVEL_DEBUG)
	   ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList.Cancel", 873)
	   Sleep(2000)
	EndIf
	If IsQuestOpened() Then
	   _log("Quest Menu Not Close --> Closed", $LOG_LEVEL_DEBUG)
	   ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.ChangeQuest_CloseButton", 1098)
	   Sleep(2000)
	EndIf
	If IsGameSettingsOpened() Then
	   _log("Game Settings Not Close --> Closed", $LOG_LEVEL_DEBUG)
	   ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.OverlayContainer.PageHeader.CloseButton" , 1355)
	   Sleep(500)
	EndIf
EndFunc ; ==> CheckCloseWindows

Func IsQuestChangeUiOpened()
    Return fastcheckuiitemvisible("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList.Cancel", 1, 873)
EndFunc   ;==>IsQuestChangeUiOpened OK

Func IsGameSettingsOpened()
    Return fastcheckuiitemvisible("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeButton", 1, 199)
EndFunc   ;==>IsGameSettingsOpened

Func IsQuestOpened()
    Return fastcheckuiitemvisible("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.SelectQuestButton", 1, 663)
EndFunc   ;==>IsQuestOpened

Func IsGameDifficultyOpened()
    Return fastcheckuiitemvisible("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.PlayGameButton", 1, 253)
EndFunc   ;==>IsGameDifficultyOpened

Func IsMenuHeroSelectOpened()
    Return fastcheckuiitemvisible("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.SelectHeroButton", 1, 1022)
EndFunc   ;==>IsMenuHeroSelectOpened