#include-once
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
			Case 1
				$Hero_Axe_Z = $Act1_Hero_Axe_Z
				$File_Sequence = $SequenceFileAct1
			Case 2
				$Hero_Axe_Z = $Act2_Hero_Axe_Z
				$File_Sequence = $SequenceFileAct2
			Case 3
				$Hero_Axe_Z = $Act3_Hero_Axe_Z
				$File_Sequence = $SequenceFileAct3PtSauve
			Case 333
				$Hero_Axe_Z = $Act3_Hero_Axe_Z
				$File_Sequence = $SequenceFileAct333
			Case 362
				$Hero_Axe_Z = $Act3_Hero_Axe_Z
				$File_Sequence = $SequenceFileAct362
			Case 373
				$Hero_Axe_Z = $Act3_Hero_Axe_Z
				$File_Sequence = $SequenceFileAct373
		EndSwitch
	EndIf
	; fin Automatisation des sequences sur enchainement de run

	;Selection du Heros
	If ($Totalruns = 1) And ($TypedeBot = 1) Then
		SelectHero()
	EndIf

	Sleep(Random(2500, 3000, 1));pause pour laiser temps quiter la game

	If $TypedeBot <> 2 Then
		;Selection -> CHANGER DE QUETE
		Sleep(Random(300, 400, 1))
		RandomMouseClick(106, 270)
		Sleep(Random(300, 400, 1))

		;Selection de la difficulte et de la puissance des monstres
		If ($Totalruns = 1) And ($TypedeBot = 1) Then
			SelectDifficultyMonsterPower()
		EndIf

		;Selection de la quête

		;Initialisation de la quete 1.2 preparation de l'arborescense des quêtes comparaison au choix des portails en reduisant l'arbo
		$xSelectGameType = Random(100, 200)
		;$ySelectGameType=170
		$ySelectGameType = Random(169, 171)

		;Selection d'une quête au hasard
		MouseMove($xSelectGameType, $ySelectGameType + 80, Random(12, 14, 1))
		MouseClick("left")
		Sleep(Random(600, 800, 1))

		;vitesse de test ok =15
		MouseMove($xSelectGameType, $ySelectGameType, Random(12, 14, 1))

		;valeur de test ok 27 ... mini pour balayer toutes les quêtes 26
		For $i = 1 To Random(27, 28, 1) Step 1
			MouseWheel("up")
			;Valeur de test ok 100
			Sleep(Random(100, 150, 1))
		Next

		;valeur de test ok 1000
		MouseClick("left")
		Sleep(Random(600, 800, 1))
		MouseClick("left")
		Sleep(Random(600, 800, 1))

		Switch $SelectGameType
			Case 1
				;selection de la quête 10.1 act 1
				For $i = 1 To 1 Step 1
					MouseWheel("down")
					Sleep(Random(100, 150, 1))
				Next

				$posSelectGameType = MouseGetPos()
				$xSelectGameType = $posSelectGameType[0]
				$ySelectGameType = $posSelectGameType[1] + 40

				MouseMove($xSelectGameType, $ySelectGameType, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))
				MouseMove($xSelectGameType, $ySelectGameType + 30, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))

			Case 2
				;selection de la quête 8.3
				For $i = 1 To 4 Step 1
					MouseWheel("down")
					Sleep(Random(100, 150, 1))
				Next

				$posSelectGameType = MouseGetPos()
				$xSelectGameType = $posSelectGameType[0]
				$ySelectGameType = $posSelectGameType[1] + 27

				MouseMove($xSelectGameType, $ySelectGameType, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))
				MouseMove($xSelectGameType, $ySelectGameType + 70, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))

			Case 3
				;selection de la quête 7.3
				For $i = 1 To 6 Step 1
					MouseWheel("down")
					Sleep(Random(100, 150, 1))
				Next

				$posSelectGameType = MouseGetPos()
				$xSelectGameType = $posSelectGameType[0]
				$ySelectGameType = $posSelectGameType[1] + 130

				MouseMove($xSelectGameType, $ySelectGameType, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))
				MouseMove($xSelectGameType, $ySelectGameType + 70, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))

			Case 333 ; Act 3 quête 3 sous quête 3 --> tuez Ghom
				For $i = 1 To 22 Step 1
					MouseWheel("down")
					Sleep(150)
				Next
				$posSelectGameType = MouseGetPos()
				$xSelectGameType = $posSelectGameType[0]
				$ySelectGameType = $posSelectGameType[1] + 64
				MouseMove($xSelectGameType, $ySelectGameType, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))
				MouseMove($xSelectGameType, $ySelectGameType + 66, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))

			Case 362 ; Act 3 quête 6 sous quête 2 --> Tuez le briseur de siège
				For $i = 1 To 27 Step 1
					MouseWheel("down")
					Sleep(150)
				Next
				$posSelectGameType = MouseGetPos()
				$xSelectGameType = $posSelectGameType[0]
				$ySelectGameType = $posSelectGameType[1] + 73
				MouseMove($xSelectGameType, $ySelectGameType, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))
				MouseMove($xSelectGameType, $ySelectGameType + 44, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))

			Case 373 ; Act 3 quête 7 sous quête 3 --> Terrasez Asmodam
				For $i = 1 To 27 Step 1
					MouseWheel("down")
					Sleep(Random(100, 150, 1))
				Next

				$posSelectGameType = MouseGetPos()
				$xSelectGameType = $posSelectGameType[0]
				$ySelectGameType = $posSelectGameType[1] + 95

				MouseMove($xSelectGameType, $ySelectGameType, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))
				MouseMove($xSelectGameType, $ySelectGameType + 70, 15)
				MouseClick("left")
				Sleep(Random(600, 800, 1))
		EndSwitch

		;Bp choisir la quete
		Sleep(Random(300, 400, 1))
		RandomMouseClick(500, 475)
		Sleep(Random(300, 400, 1))
		; Bp validation de la quête
		If IsQuestChangeUiOpened() Then
			_log("Détection de changement quête")
			Sleep(Random(300, 400, 1))
			RandomMouseClick(350, 350)
		EndIf
	EndIf
EndFunc   ;==>SelectGameType

;Selection de la quete en automatique
Func SelectQuest()
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
			$Hero_Axe_Z = $Act3_Hero_Axe_Z
			$File_Sequence = $SequenceFileAct3
		EndIf
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

	;Selection de la quete en automatique et enchainement des actes
	If $Choix_Act_Run = -1 Then
		;Initialisation de la séquence
		If ($Totalruns = 1) Or ($Totalruns = $NbreRunChangSeqAlea) Then
			$act = 0
			$NombreRun_Encour = 0
			;Chainage aléatoire ou non des actes
			If $Sequence_Aleatoire = "True" Then
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
				$Hero_Axe_Z = $Act3_Hero_Axe_Z
				$File_Sequence = $SequenceFileAct3
			EndIf
			$NombreRun_Encour = $NombreRun_Encour + 1
			_FileWriteToLine($fileLog, $numLigneFichier, "Act " & $Act_Encour & ": " & $NombreRun_Encour & "/" & $NombreDeRun, 1)
		EndIf
	EndIf
EndFunc   ;==>SelectQuest

Func SelectHero()

	; bonton Changer de heros
	MouseMove(Random(350, 430), Random(515, 520), Random(12, 14, 1))
	MouseClick("left")
	Sleep(Random(600, 800, 1))

	;positionnement dans la liste des heros
	MouseMove(Random(105, 120), Random(140, 240), Random(12, 14, 1))
	Sleep(Random(600, 800, 1))

	;Choix du heros
	For $i = 1 To Random(6, 7, 1) Step 1
		MouseWheel("up")
		;Valeur de test ok 100
		Sleep(Random(100, 150, 1))
	Next

	$XherosPmin = 150
	$XherosPmax = 155
	$YHeros1min = 120
	$YHeros1max = 130
	Local $offsetHerosYmin = 49
	Local $offsetHerosYmax = 51

	Switch $Heros
		Case 1
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 2
			$YHeros1min = $YHeros1min + $offsetHerosYmin
			$YHeros1max = $YHeros1max + $offsetHerosYmax
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 3
			$YHeros1min = $YHeros1min + ($offsetHerosYmin * 2)
			$YHeros1max = $YHeros1max + ($offsetHerosYmax * 2)
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 4
			$YHeros1min = $YHeros1min + ($offsetHerosYmin * 3)
			$YHeros1max = $YHeros1max + ($offsetHerosYmax * 3)
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 5
			$YHeros1min = $YHeros1min + ($offsetHerosYmin * 4)
			$YHeros1max = $YHeros1max + ($offsetHerosYmax * 4)
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 6
			$YHeros1min = $YHeros1min + ($offsetHerosYmin * 5)
			$YHeros1max = $YHeros1max + ($offsetHerosYmax * 5)
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 7
			$YHeros1min = $YHeros1min + ($offsetHerosYmin * 6)
			$YHeros1max = $YHeros1max + ($offsetHerosYmax * 6)
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 8
			For $i = 1 To 5 Step 1
				MouseWheel("down")
				;Valeur de test ok 100
				Sleep(Random(100, 150, 1))
			Next
			$YHeros1min = $YHeros1min + ($offsetHerosYmin * 4)
			$YHeros1max = $YHeros1max + ($offsetHerosYmax * 4)
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 9
			For $i = 1 To 5 Step 1
				MouseWheel("down")
				;Valeur de test ok 100
				Sleep(Random(100, 150, 1))
			Next
			$YHeros1min = $YHeros1min + ($offsetHerosYmin * 5)
			$YHeros1max = $YHeros1max + ($offsetHerosYmax * 5)
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
		Case 10
			For $i = 1 To 5 Step 1
				MouseWheel("down")
				;Valeur de test ok 100
				Sleep(Random(100, 150, 1))
			Next
			$YHeros1min = $YHeros1min + ($offsetHerosYmin * 6)
			$YHeros1max = $YHeros1max + ($offsetHerosYmax * 6)
			MouseMove(Random($XherosPmin, $XherosPmax, 1), Random($YHeros1min, $YHeros1max, 1), Random(12, 14, 1))
	EndSwitch
	Sleep(Random(600, 800, 1))

	;selection du Heros
	MouseClick("left")
	Sleep(Random(600, 800, 1))

	;Deplacement sur le bp choisir
	MouseMove(Random(330, 450, 1), Random(512, 515, 1), Random(12, 14, 1))
	Sleep(Random(600, 800, 1))
	;Clic sur le bouton choisir temps mini de chargement du hero 4000ms
	MouseClick("left")
	Sleep(Random(6000, 8000, 1))
EndFunc   ;==>SelectHero

Func SelectDifficultyMonsterPower()

	;Selection de la fleche du menu déroulant de la difficulté

	MouseMove(Random(183, 186), Random(474, 476), Random(12, 14, 1))
	MouseClick("left")
	Sleep(Random(600, 800, 1))

	Switch $difficulte
		Case 1 ;Normal
			MouseMove(Random(90, 110, 1), Random(495, 500, 1), Random(12, 14, 1))
		Case 2 ;Cauchemar
			MouseMove(Random(90, 110, 1), Random(516, 519, 1), Random(12, 14, 1))
		Case 3 ;Enfer
			MouseMove(Random(90, 110, 1), Random(535, 538, 1), Random(12, 14, 1))
		Case 4 ;Arma
			MouseMove(Random(90, 110, 1), Random(551, 555, 1), Random(12, 14, 1))
	EndSwitch
	Sleep(Random(600, 800, 1))
	MouseClick("left")
	Sleep(Random(600, 800, 1))


	;Selection de la fleche du menu déroulant de la Puissance des monstres
	MouseMove(Random(309, 311, 1), Random(473, 475, 1), Random(12, 14, 1))
	Sleep(Random(600, 800, 1))
	MouseClick("left")
	Sleep(Random(600, 800, 1))

	; Initialisation de la liste déroulante de la PM
	MouseMove(Random(220, 280, 1), Random(497, 499, 1), Random(12, 14, 1))
	For $i = 1 To Random(4, 6, 1) Step 1
		MouseWheel("up")
		;Valeur de test ok 100
		Sleep(Random(100, 150, 1))
	Next

	#cs
		Selection de la puissance des monstres
		Selection de la puissance des monstres comprise entre 5 et 9
		Selection de la puissance des monstres = 10
	#ce

	If ($PuisMonstre > 4) And ($PuisMonstre < 10) Then
		For $i = 1 To 3 Step 1
			MouseWheel("down")
			;Valeur de test ok 100
			Sleep(Random(100, 150, 1))
		Next
	EndIf

	If ($PuisMonstre = 10) Then
		For $i = 1 To 4 Step 1
			MouseWheel("down")
			;Valeur de test ok 100
			Sleep(Random(100, 150, 1))
		Next
	EndIf

	Switch $PuisMonstre
		Case 0
			MouseMove(Random(230, 240, 1), Random(497, 499, 1), Random(12, 14, 1))
		Case 1
			MouseMove(Random(220, 280, 1), Random(518, 520, 1), Random(12, 14, 1))
		Case 2
			MouseMove(Random(220, 280, 1), Random(536, 538, 1), Random(12, 14, 1))
		Case 3
			MouseMove(Random(220, 280, 1), Random(556, 558, 1), Random(12, 14, 1))
		Case 4
			MouseMove(Random(220, 280, 1), Random(573, 574, 1), Random(12, 14, 1))
		Case 5
			MouseMove(Random(220, 280, 1), Random(497, 499, 1), Random(12, 14, 1))
		Case 6
			MouseMove(Random(220, 280, 1), Random(518, 520, 1), Random(12, 14, 1))
		Case 7
			MouseMove(Random(220, 280, 1), Random(538, 539, 1), Random(12, 14, 1))
		Case 8
			MouseMove(Random(220, 280, 1), Random(556, 558, 1), Random(12, 14, 1))
		Case 9
			MouseMove(Random(220, 280, 1), Random(573, 574, 1), Random(12, 14, 1))
		Case 10
			MouseMove(Random(220, 280, 1), Random(573, 574, 1), Random(12, 14, 1))
	EndSwitch
	Sleep(Random(600, 800, 1))
	MouseClick("left")
	Sleep(Random(600, 800, 1))
EndFunc   ;==>SelectDifficultyMonsterPower
