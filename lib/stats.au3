#include-once
 ; ------------------------------------------------------------
; Ce fichier contient toutes les fonctions liées auxs stats
; -------------------------------------------------------------


Func extendedstats()
	If $Totalruns >= 15 Then

		$sessionstats = "data.addRow([new Date(" & @YEAR & "," & @MON & "," & @MDAY & "," & @HOUR & "," & @MIN & ")," & ($dif_timer_stat / ($Totalruns) / 1000) & "," & $GOLDMOYbyH / 1000 & "," & ($Xp_Moy_Hrs / 100000) & "," & (($Death*3 + $Res_compt) / $Totalruns)*100 & "," & $successratio * 1000 & "]);"
		$szFile = "statscontrol.html"
		$szText = FileRead($szFile)
		$szText = StringReplace($szText, "//GoGoAu3End", $sessionstats & @CRLF & "//GoGoAu3End")
		FileDelete($szFile)
		FileWrite($szFile,$szText)
	EndIf
EndFunc   ;==>extendedstats

Func StatsDisplay()

        Local $index, $offset, $count, $item[4]
		Local $Xp_Moy_HrsPerte_Ratio = 0
		Local $GoldBySaleRatio = 0
		Local $LossGoldMoyH = 0
		Local $GoldByColectRatio = 0
		Local $GoldByRepaireRatio = 0
		Local $dif_timer_stat_game_Ratio = 0
		Local $dif_timer_stat_pause_Ratio = 0

		startIterateLocalActor($index, $offset, $count)
        While iterateLocalActorList($index, $offset, $count, $item)
		   If StringInStr($item[1], "GoldCoin-") Then
			  $GOLD = IterateActorAtribs($item[0], $Atrib_ItemStackQuantityLo)
			  ExitLoop
		   EndIf
        WEnd

        If $Totalruns = 1 Then
			$GOLDINI = $GOLD
			$begin_timer_stat = TimerInit()
			$GF = Ceiling(GetAttributeSelf($Atrib_Gold_Find) * 100)
			$MF = Ceiling(GetAttributeSelf($Atrib_Magic_Find) * 100)
			$PR = GetAttributeSelf($Atrib_Gold_PickUp_Radius)
			$MS = (GetAttributeSelf($Atrib_Movement_Scalar_Capped_Total) - 1) * 100
			$EBP = Ceiling(GetAttributeSelf($Atrib_Experience_Bonus_Percent) * 100)
		Else
			$GOLDInthepocket = $GOLD - $GOLDINI
			$GOLDMOY = $GOLDInthepocket / ($Totalruns - 1)
			$GoldBySaleRatio = ($GoldBySale / $GOLDInthepocket * 100);ratio des ventes
			$GoldByColectRatio = (($GOLDInthepocket - $GoldBySale + $GoldByRepaire) / $GOLDInthepocket * 100);ratio de l'or collecté
			$GoldByRepaireRatio = ($GoldByRepaire / $GOLDInthepocket * 100);ratio du coût des réparation
			$dif_timer_stat = TimerDiff($begin_timer_stat);temps total
			$dif_timer_stat_pause = ($tempsPauseGame + $tempsPauserepas);calcule du temps de pause (game + repas)=total pause
			$dif_timer_stat_game = ($dif_timer_stat - $dif_timer_stat_pause);calcule (temps totale - temps total pause)=Temps de jeu
			$dif_timer_stat_game_Ratio = ($dif_timer_stat_game / $dif_timer_stat * 100);ratio temps total jeu
			$dif_timer_stat_pause_Ratio = ($dif_timer_stat_pause / $dif_timer_stat * 100);ration temps de pause total
			$GOLDMOYbyH = $GOLDInthepocket * 3600000 / $dif_timer_stat;calcule du gold à l'heure temps total
			$GOLDMOYbyHgame = $GOLDInthepocket * 3600000 / $dif_timer_stat_game;calcule du gold à l'heure temp de jeu
			$LossGoldMoyH = (($GOLDMOYbyHgame - $GOLDMOYbyH) / $GOLDMOYbyHgame * 100);ratio de la perte d'or due à la pause
        EndIf

        ;stat XP

        ;Xp nécessaire pour passer un niveau de paragon


        If $Totalruns = 1 Then

			$NiveauParagon = GetAttributeSelf($Atrib_Alt_Level)
			$ExperienceNextLevel = GetAttributeSelf($Atrib_Alt_Experience_Next_Lo)
			$Expencours = $level[$NiveauParagon + 1] - $ExperienceNextLevel
			$Xp_Run = 0
			$Xp_Total = 0
			$Xp_Moy_Run = 0
			$Xp_Moy_Hrs = 0
			$time_Xp = 0
			$CoffreTaken = 0
			$time_Xp = formatTime($time_Xp)

        Else
			;calcul de l'xp du run
			If $NiveauParagon = GetAttributeSelf($Atrib_Alt_Level) Then; verification de level up (égalité => pas de level up
				  $Xp_Run = ($level[GetAttributeSelf($Atrib_Alt_Level) + 1] - GetAttributeSelf($Atrib_Alt_Experience_Next_Lo)) - $Expencours;experience run n - experience run n-1
			EndIf

			$Expencours = $level[GetAttributeSelf($Atrib_Alt_Level) + 1] - GetAttributeSelf($Atrib_Alt_Experience_Next_Lo)

			If $NiveauParagon <> GetAttributeSelf($Atrib_Alt_Level) Then
				  $Xp_Run = $ExperienceNextLevel + $Expencours
			EndIf

			$Xp_Total = $Xp_Total + $Xp_Run
			$Xp_Moy_Run = $Xp_Total / ($Totalruns - 1)
			$Xp_Moy_Hrs = $Xp_Total * 3600000 / $dif_timer_stat;on calcule l'xp/heure en temps total
			$Xp_Moy_Hrsgame = $Xp_Total * 3600000 / $dif_timer_stat_game;on calcule l'xp/heure en temps de jeu
			$Xp_Moy_HrsPerte = ($Xp_Moy_Hrsgame - $Xp_Moy_Hrs);on calcule la perte due aux pauses
			$Xp_Moy_HrsPerte_Ratio = ($Xp_Moy_HrsPerte / $Xp_Moy_Hrsgame * 100);ratio de la perte xp/heure due aux pauses
			$NiveauParagon = GetAttributeSelf($Atrib_Alt_Level)
			$ExperienceNextLevel = GetAttributeSelf($Atrib_Alt_Experience_Next_Lo)

			;calcul temps avant prochain niveau
			$Xp_Moy_Sec = $Xp_Total * 1000 / $dif_timer_stat
			$time_Xp = Int($ExperienceNextLevel / $Xp_Moy_Sec) * 1000
			$time_Xp = formatTime($time_Xp)

        EndIf
        ;########

        $timer_stat_total = formatTime($dif_timer_stat); temps total

        If $Totalruns = 1 Then
			$timer_stat_run_moyen = 0
			;Lv_stat=lv
			;Xp_next_stat=Xp_next
			;Xprun=0
			;Xptotal=0
			;Xpmoyen=0
        Else
			;;;$dif_timer_stat_moyen = $dif_timer_stat / ($Totalruns - 1)
			$timer_stat_run_moyen = formatTime($dif_timer_stat_game / ($Totalruns - 1));on recalcule le temps moyen d'un run par rapport au temps de jeu
        EndIf


	    GetAct()
        $DebugMessage = "                                 INFOS RUN ACTE " & $Act & @CRLF
		$DebugMessage = $DebugMessage & "Runs : " & $Totalruns & @CRLF
        $DebugMessage = $DebugMessage & "Morts : " & $Death & @CRLF
        $DebugMessage = $DebugMessage & "Resurrections : " & $Res_compt & @CRLF
        $DebugMessage = $DebugMessage & "Deconnexions  : " & $disconnectcount & @CRLF
		$DebugMessage = $DebugMessage & "Sanctuaires Pris : " & $CheckTakeShrineTaken & @CRLF
		$DebugMessage = $DebugMessage & "Coffres Ouverts : " & $CoffreTaken & @CRLF
		$DebugMessage = $DebugMessage & "Elites Rencontres : " & $CptElite & @CRLF
		$DebugMessage = $DebugMessage & "Success Runs : " & Round($successratio * 100) & "%   ( " & ($Totalruns - $success) & " Avortés )" & @CRLF
		$DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
		$DebugMessage = $DebugMessage & "                                 INFOS COFFRE" & @CRLF
		$DebugMessage = $DebugMessage & "Nombre Objets Recycles : " & $ItemToRecycle & @CRLF
		$DebugMessage = $DebugMessage & "Nombre de Legs au Coffre : " & $nbLegs & @CRLF
		$DebugMessage = $DebugMessage & "Nombre de Rares au Coffre : " & $nbRares & @CRLF
		$DebugMessage = $DebugMessage & "Objets Stockes Dans le Coffre : " & $ItemToStash & @CRLF
		$DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
		$DebugMessage = $DebugMessage & "                                 INFOS GOLD" & @CRLF
		$DebugMessage = $DebugMessage & "Gold au Coffre : " & Format_Number(Ceiling($GOLD)) & @CRLF
		$DebugMessage = $DebugMessage & "Gold Total Obtenu  : " & Format_Number(Ceiling($GOLDInthepocket)) & @CRLF
		$DebugMessage = $DebugMessage & "Gold Moyen/Run : " & Format_Number(Ceiling($GOLDMOY)) & @CRLF
		$DebugMessage = $DebugMessage & "Gold Moyen/Heure : " & Format_Number(Ceiling($GOLDMOYbyH)) & @CRLF
		;$DebugMessage = $DebugMessage & "Gold Moyen/Heure Jeu : " & Format_Number(Ceiling($GOLDMOYbyHgame)) & @CRLF ;====> gold de temps de jeu
		$DebugMessage = $DebugMessage & "Perte Moyenne/Heure : " & Format_Number(Ceiling($GOLDMOYbyH - $GOLDMOYbyHgame)) & "   (" & Round($LossGoldMoyH) & "%)" & @CRLF
		$DebugMessage = $DebugMessage & "Nombre d'Objets Vendus :  " & $ItemToSell & "  /  " & Format_Number(Ceiling($GoldBySale)) & "   (" & Round($GoldBySaleRatio) & "%)" & @CRLF
		$DebugMessage = $DebugMessage & "Gold Obtenu par Collecte  :    " & Format_Number(Ceiling($GOLDInthepocket - $GoldBySale + $GoldByRepaire)) & "   (" & Round($GoldByColectRatio) & "%)" & @CRLF
		$DebugMessage = $DebugMessage & "Nombre de Réparations : " & $RepairORsell & " / - " & Format_Number(Ceiling($GoldByRepaire)) & "   (- " & Round($GoldByRepaireRatio) & "%)" & @CRLF
		$DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
        $DebugMessage = $DebugMessage & "                                 INFOS TEMPS " & @CRLF
		$DebugMessage = $DebugMessage & "Durée Moyenne/Run : " & $timer_stat_run_moyen & @CRLF
		$DebugMessage = $DebugMessage & "Temps Total De Bot:   " & $timer_stat_total & @CRLF
		$DebugMessage = $DebugMessage & "Temps Total En Jeu :   " & formatTime($dif_timer_stat_game) & " (" & Round($dif_timer_stat_game_Ratio) & "%)" & @CRLF
		$DebugMessage = $DebugMessage & "Pauses Effectuées : " & ($BreakTimeCounter + $PauseRepasCounter) & "  /  " & formatTime($dif_timer_stat_pause) & " (" & Round($dif_timer_stat_pause_Ratio) & "%)" & @CRLF
		;stats XP
        $DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
        $DebugMessage = $DebugMessage & "                                 INFOS XP" & @CRLF
		If ($Xp_Total < 1000000) Then ;afficher en "K"
                $DebugMessage = $DebugMessage & "XP Obtenu : " & Int($Xp_Total)/1000 & " K" & @CRLF
        EndIf
        If ($Xp_Total > 999999) and ($Xp_Total < 1000000000) Then ;afficher en "M"
                $DebugMessage = $DebugMessage & "XP Obtenu : " & Int($Xp_Total/1000)/1000 & " M" & @CRLF
		EndIf
		If ($Xp_Total > 999999999) Then ;afficher sous forme "x xxx M"
                $DebugMessage = $DebugMessage & "XP Obtenu : " & Int($Xp_Total/1000000)/1000 & " M" & @CRLF
		EndIf

        If ($Xp_Moy_Run < 1000000) Then ;afficher en "K"
                $DebugMessage = $DebugMessage & "XP Moyen par run : " & Int($Xp_Moy_Run/1000) & " K" & @CRLF
        EndIf
        If ($Xp_Moy_Run > 999999) Then ;afficher en "M"
                $DebugMessage = $DebugMessage & "XP Moyen par run : " & Int($Xp_Moy_Run/1000)/1000 & " M" & @CRLF
        EndIf

        If ($Xp_Moy_Hrs < 1000000) Then ;afficher en "K"
                $DebugMessage = $DebugMessage & "XP Moyen par heure : " & Int($Xp_Moy_Hrs/1000) & " K" & @CRLF
        EndIf
        If ($Xp_Moy_Hrs > 999999) Then ;afficher en "M"
                $DebugMessage = $DebugMessage & "XP Moyen par heure : " & Int($Xp_Moy_Hrs/1000)/1000 & " M" & @CRLF
        EndIf
        If ($Xp_Moy_HrsPerte < 1000000) Then ;affiché en "K"
			$DebugMessage = $DebugMessage & "Perte Moyenne/Heure : -" & Int($Xp_Moy_HrsPerte/1000) & " K (" & Round($Xp_Moy_HrsPerte_Ratio) & "%)" & @CRLF
		EndIf
		If ($Xp_Moy_HrsPerte > 999999) Then ;affiché en "M"
			$DebugMessage = $DebugMessage & "Perte Moyenne/Heure : -" & Format_Number(Int($Xp_Moy_HrsPerte/1000)/1000) & " M (" & Round($Xp_Moy_HrsPerte_Ratio) & "%)" & @CRLF
		EndIf
        $DebugMessage = $DebugMessage & "Temps Avant Prochain LVL : " & $time_Xp & @CRLF
        $DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
		$DebugMessage = $DebugMessage & "                                 INFOS PERSO " & @CRLF
        $DebugMessage = $DebugMessage & $nameCharacter & " [ " & $NiveauParagon & " ] " & @CRLF
        $DebugMessage = $DebugMessage & "PickUp Radius  : " & $PR & @CRLF
		$DebugMessage = $DebugMessage & "Movement Speed : " & Round($MS) & " %" & @CRLF
		$DebugMessage = $DebugMessage & "DPS Constatés : " & Format_Number(Ceiling($AverageDps/1000)) & " K " & @CRLF;pacth 8.2e
		$DebugMessage = $DebugMessage & "Gold Find Equipement : " & $GF & " %" & @CRLF
        $DebugMessage = $DebugMessage & "Magic Find Equipement : " & $MF & " %" & @CRLF
		$DebugMessage = $DebugMessage & "Bonus d'XP Equipement : " & $EBP & " %" & @CRLF
		$DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
	    $DebugMessage = $DebugMessage & "Heure début run: " & @HOUR & ":" & @MIN & @CRLF
		Switch $Choix_Act_Run
			Case -1
				  $file = FileOpen($fileLog, 0)
				  $line = FileReadLine($file, 1)
				  $DebugMessage = $DebugMessage & $line & @CRLF
				  $line = FileReadLine($file, $numLigneFichier)
				  $DebugMessage = $DebugMessage & $line & @CRLF
				  FileClose($file)
			Case 0
				  $DebugMessage = $DebugMessage & "Mode normal" & @CRLF
			Case 1
				  $DebugMessage = $DebugMessage & "Acte 1 en automatique" & @CRLF
			Case 2
				  $DebugMessage = $DebugMessage & "Acte 2 en automatique" & @CRLF
			Case 3
				  $DebugMessage = $DebugMessage & "Acte 3 en automatique" & @CRLF
		EndSwitch

		$MESSAGE = $DebugMessage
		Local $posd3 = WinGetPos("Diablo III")
		$DebugX = $posd3[0] + $posd3[2] + 10
		$DebugY = $posd3[1]
        ToolTip($MESSAGE, $DebugX, $DebugY)

        $Totalruns = $Totalruns + 1 ;compte le nombre de run

EndFunc   ;==>StatsDisplay