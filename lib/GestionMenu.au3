#include-once
#include <File.au3>
#cs ----------------------------------------------------------------------------

	Extension permettant de gerer le menu

#ce ----------------------------------------------------------------------------

;--------------------------------------------------------------
; Choix de l'acte
;-------------------------------------------------------------

Func SelectGameType($SelectGameType, $auto)

	Local $xSelectGameType, $ySelectGameType, $posSelectGameType
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

	;Selection du Heros
	If ($Totalruns = 1) And ($TypedeBot = 1) Then
		SelectHero()
	EndIf

	Sleep(Random(1500, 2000, 1))

	Local $Waiting_Time = 0
	While Not _inmenu() And $TypedeBot <> 2 And $Waiting_Time < 40
	   Sleep(500)
	   $Waiting_Time += 1
	WEnd

	If $TypedeBot <> 2 And _inmenu() Then
		;Selection -> CHANGER DE QUETE
		Sleep(Random(700, 800, 1))
		_Log("Game Settings")
		ClickUI("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu") ; tap paramètre de la partie
		Sleep(Random(700, 800, 1))

		Local $Waiting_Time = 0
		While Not IsGameSettingsOpened() And $Waiting_Time < 11
		   Sleep(500)
		   $Waiting_Time += 1
		WEnd

		If IsGameSettingsOpened() Then

			If ($Totalruns = 1) Then
			   If $SelectGameType > -2 Then
				  _log("Passage en mode Campagne", $LOG_LEVEL_DEBUG)
				  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeButton", 199)
				  Sleep(1000)
				  ;Selection de la difficulte et de la puissance des monstres
				  If $TypedeBot = 1 Then
					 SelectDifficultyMonsterPower()
				  EndIf
			   Else
				  _log("Passage en mode Aventure", $LOG_LEVEL_DEBUG)
				  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.AdventureModeButton", 1581)
				  Sleep(Random(600, 800, 1))
				  ;Selection de la difficulte et de la puissance des monstres
				  If $TypedeBot = 1 Then
					 SelectDifficultyMonsterPower()
				  EndIf
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

		   _Log("Choose a New Quest")
		   ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeContent.ChangeQuestButton"); tap changer
		   Sleep(Random(700, 800, 1))

		   Local $Waiting_Time = 0
		   While Not IsQuestOpened() And $Waiting_Time < 11
			  Sleep(500)
			  $Waiting_Time += 1
		   WEnd

		   ;Selection de la quête
		   If IsQuestOpened() Then

			  ;Selection de la scrollbar
			  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.QuestMenu.NavigationMenuList._scrollbar.thumb")
			  Sleep(Random(600, 800, 1))

			  ;valeur de test ok 27 ... mini pour balayer toutes les quêtes 26
			  For $i = 1 To Random(40, 41, 1) Step 1
				 MouseWheel("up")
				 ;Valeur de test ok 100
				 Sleep(Random(100, 150, 1))
			  Next

			  ;selection d'une quete pour fermer les sous quetes
			  ClickUIMode(0, 0, -20, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
			  Sleep(1500)
			  ClickUIMode(0, 0, -20, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
			  Sleep(1000)

			  Switch $SelectGameType
				   Case 1;selection de la quête 10.1 act 1

					  For $i = 1 To 7 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 1 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 2;selection de la quête 8.3

					  For $i = 1 To 16 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 3;selection de la quête 7.3

					  For $i = 1 To 26 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 5, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 222;Act 2 quête 2 sous quête 2 --> Tuer Lieutenent Vachem

					  For $i = 1 To 10 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -20, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -45, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 232;Act 2 quête 3 sous quête 2 --> Tuer Maghda

					  For $i = 1 To 11 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -20, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -40, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 283;Act 2 quête 8 sous quête 3 --> Tuer Zoltun Kulle

					  For $i = 1 To 16 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 299;Act 2 quête 10 sous quête 1 --> Tuer Belial

					  For $i = 1 To 18 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  ClickUIMode(0, 0, 50, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 333 ; Act 3 quête 3 sous quête 3 --> tuez Ghom

					  For $i = 1 To 22 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -10, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 362 ; Act 3 quête 6 sous quête 2 --> Tuez le briseur de siège

					  For $i = 1 To 25 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 1 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, -17, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed62")

				   Case 373 ; Act 3 quête 7 sous quête 3 --> Terrasez Asmodam

					  For $i = 1 To 26 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 5, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 374 ; Act 3 quête 7 sous quête 3 --> Terrasez Asmodam, Iskatu et Rakanoth

					  For $i = 1 To 26 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 5, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 411 ; Act 4 quête 1 sous quête 1 --> Terrasez Iskatu et Rakanoth

					  For $i = 1 To 27 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 45, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					  ClickUIMode(0, 0, 90, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

				   Case 442 ; Act 4 quête 4 sous quête 2 --> Terrasez Diablo

					  For $i = 1 To 27 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next
					  ClickUIMode(0, 0, 215, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")
					  Sleep(Random(600, 800, 1))

					   For $i = 1 To 2 Step 1
						 MouseWheel("down")
						 Sleep(Random(100, 150, 1))
					  Next

					  ClickUIMode(0, 0, 200, "Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.unnamed61")

			  EndSwitch

			  ;Bp choisir la quete
			  Sleep(Random(300, 400, 1))
			  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.ChangeQuest.SelectQuestButton") ; Tap OK 'Choose a new quest'
			  Sleep(Random(1000, 1500, 1))

			  ; Bp validation de la quête
			  If IsQuestChangeUiOpened() Then
				 _log("Détection de changement quête")
				 Sleep(Random(300, 400, 1))
				 Send("{ENTER}")
			  EndIf
			  Sleep(Random(600, 800, 1))
			  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.SaveAndClose", 809) ; tap sauvegarder et fermer
			  Sleep(Random(800, 1000, 1))
		   Else
			  _Log("Quest Menu No Opened", $LOG_LEVEL_DEBUG)
		   EndIf
	   Else
		  _Log("Game Settings No Opened", $LOG_LEVEL_DEBUG)
	   EndIf
	EndIf
EndFunc   ;==>SelectGameType

;Selection de la quete en automatique
Func SelectQuest()
	If ($Choix_Act_Run = -3) And ($Totalruns = 1) Then
		SelectGameType(-3, True)
	EndIf
	If ($Choix_Act_Run = -2) And ($Totalruns = 1) Then
		SelectGameType(-2, True)
	EndIf
	If ($Choix_Act_Run = 1) And ($Totalruns = 1) Then
		SelectGameType(1, True)
	EndIf
	If ($Choix_Act_Run = 2) And ($Totalruns = 1) Then
		SelectGameType(2, True)
	EndIf
	If ($Choix_Act_Run = 3) Then
		If ($Totalruns = 1) Then
			SelectGameType(3, True)
		EndIf
		If ($Totalruns = 2) Then
			$File_Sequence = $SequenceFileAct3
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

	; bonton Changer de heros
	_Log("Switch Hero")
	ClickUI("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Slot1.LayoutRoot.SwitchHero")
	Sleep(Random(600, 800, 1))

    Local $Waiting_Time = 0
	While Not IsMenuHeroSelectOpened() And $Waiting_Time < 11
	   Sleep(500)
	   $Waiting_Time += 1
	WEnd

	If IsMenuHeroSelectOpened() Then

	   ;positionnement sur la scrollbar
	   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.HeroSelectList.HeroList._scrollbar")
	   Sleep(Random(600, 800, 1))

	   ;Choix du heros
	   For $i = 1 To Random(10, 11, 1) Step 1
		  MouseWheel("up")
		  ;Valeur de test ok 100
		  Sleep(Random(100, 150, 1))
	   Next

	   Sleep(Random(500, 750, 1))

	   Switch $Heros
			Case 1
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed36")
			Case 2
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed37")
			Case 3
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed38")
			Case 4
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed39")
			Case 5
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed40")
			Case 6
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed41")
			Case 7
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed42")
			Case 8
			   For $i = 1 To 5 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed40")

			Case 9
			   For $i = 1 To 5 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed41")

			Case 10
			   For $i = 1 To 5 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed42")

			Case 11
			   For $i = 1 To 9 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed41")

			Case 12
			   For $i = 1 To 9 Step 1
				  MouseWheel("down")
				  Sleep(Random(100, 150, 1))
			   Next
			   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.d3StackPanel.unnamed42")

	   EndSwitch
	   Sleep(Random(600, 800, 1))

	   ;Deplacement sur le bp choisir
	   ClickUI("Root.NormalLayer.BattleNetHeroSelect_main.LayoutRoot.SelectHeroButton")
	   Sleep(Random(2000, 2500, 1)) ; temps mini de chargement du hero 2000ms
    Else
	   _Log("Hero Menu No Opened", $LOG_LEVEL_DEBUG)
    EndIf
EndFunc   ;==>SelectHero

Func SelectDifficultyMonsterPower()

	;Selection de la difficulté
	_Log("Change Difficulty")
	If  $Choix_Act_Run > -2 Then
	   ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeContent.ChangeDifficultyButton")
	   Sleep(Random(600, 800, 1))
	Else
	  ClickUI("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.AdventureModeContent.ChangeDifficultyButton")
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
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_0")
			Case 2 ;Difficile
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_1")
			Case 3 ;Expert
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_2")
			Case 4 ;Calvaire
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_3")
			Case 5 ;Tourment
			    ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.Difficulty_4")
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

	   ClickUI("Root.TopLayer.BattleNetGameDifficulty_main.LayoutRoot.OverlayContainer.PlayGameButton"); tap OK Difficulty
	   Sleep(Random(1000, 1500, 1))
    Else
	   _Log("Game Difficulty No Opened", $LOG_LEVEL_DEBUG)
    EndIf

EndFunc   ;==>SelectDifficultyMonsterPower


Func ClickUIMode($mode, $x, $y, $name, $bucket = -1)

	If $bucket = -1 Then ;no bucket given slow method
		$result = GetOfsUI($name, 1)
	Else ;bucket given, fast method
		$result = GetOfsFastUI($name, $bucket)
	EndIf

	If $result = false Then
		_log("(ClickUI) UI DOESNT EXIT ! -> " & $name)
		return false
	EndIf

	Dim $Point = GetPositionUI($result)

	While $Point[0] = 0 AND $Point[1] = 0
		$Point = GetPositionUI($result)
		sleep(500)
	WEnd

	Dim $Point2 = GetUIRectangle($Point[0] + $x, $Point[1] + $y, $Point[2] + $x, $Point[3] + $y)

	Switch $mode
		 Case 0
			MouseClick("left", ($Point2[0] + $Point2[2] / 2) , $Point2[1] + $Point2[3] / 2)
		 Case 1
			MouseClick("left", ($Point2[0] + $Point2[2] / 2) , $Point2[1] + $Point2[3] / 2)
			MouseDown("left")
			Sleep(300)
			MouseUp("left")
			Sleep(50)
    EndSwitch

EndFunc  ;====> ClickUISlider


Func IsQuestChangeUiOpened()
    Return fastcheckuiitemvisible("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 1, 2022)
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
