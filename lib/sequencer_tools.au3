#include-once

Global $Table_mtp[1][5]
Global $count_mtp = 0
Global $Table_important[1][4]
Global $count_Important = 0
Global $Scene_table_totale[1][8]
Global $NavCell_table_totale[1][8]
Global $Buff_MeshMinX = 999999
Global $Buff_MeshMinY = 999999
Global $Buff_MeshMaxX = 0
Global $Buff_MeshMaxY = 0
Global $posNumberMod = 3
Global $drawLineNumbers = False

Global $Iterate_Objet[1]

Global $SaveSequenceData = True
Global $DrawAttackRange = True
Global $DrawPositionName = True
Global $DrawScene = "True"
Global $DrawNavCellWalkable = "False"
Global $DrawNavCellUnWalkable = "True"
Global $DrawArrow = "True"
Global $DrawMtp = "True"

Global $SceneColor = "0xFF000000"
Global $NavcellWalkableColor = "0xFF85DB24"
Global $NavcellUnWalkableColor = "0xFF83888a"
Global $ArrowColor = "0xFF00FFC0"
Global $ArrowColorNoAttack = "0xFF00C0FF"
Global $MtpColor = "0xFFFF0000"
Global $nameSequenceTxt = "-sequence-" & @MON &  @MDAY & @HOUR & @MIN & @SEC
Global $PictureScene = "-pictureScene-" & @MON &  @MDAY & @HOUR & @MIN & @SEC
Global $Picturemtp = "-picturemtp-" & @MON &  @MDAY & @HOUR & @MIN & @SEC
Global $nameObjectListTxt = "-ObjectList-" & @MON &  @MDAY & @HOUR & @MIN & @SEC
Global $mapDataIni = "-MapData-" & @MON &  @MDAY & @HOUR & @MIN & @SEC

Global $SequencerToolsHandle
Global $recordSceneButton = 0
Global $recordObjectButton = 0
Global $recordImportantButton = 0
Global $DrawSceneButton = 0

Func ShowSequencerTools()
	$SequencerToolsHandle = GUICreate("Sequencer tools", 300, 620, Default, Default, $WS_BORDER, $WS_EX_TOPMOST)
	If $SequencerToolsHandle = 0 Then
		_Log("Problem starting debug tools", $LOG_LEVEL_ERROR)
		Return
	EndIf
	GUISetOnEvent($GUI_EVENT_CLOSE, "On_SequencerTools_Close")

	$recordSceneButton = GUICtrlCreateLabel("Enregistrer la scène : F1", 10, 10, 280, 20)
    $recordObjectButton = GUICtrlCreateLabel("Enregistrer les objets : F3", 10, 30, 280, 20)

    $hButton3 = GUICtrlCreateButton("Marquer une position (ù)", 10, 60, 280, 30)
	GUICtrlSetOnEvent($hButton3, "SequencerMarkPos")
	$hButton3 = GUICtrlCreateButton("Marquer un sleep (F6)", 10, 120, 280, 30)
	GUICtrlSetOnEvent($hButton3, "SequencerAddSleep")
	$hButton3 = GUICtrlCreateButton("Marquer un interact Acteur (F7)", 10, 160, 280, 30)
	GUICtrlSetOnEvent($hButton3, "SequencerAddInteractActor")
	$hButton3 = GUICtrlCreateButton("Marquer un interact Porte (F8)", 10, 200, 280, 30)
	GUICtrlSetOnEvent($hButton3, "SequencerAddInteractDoor")
	$hButton3 = GUICtrlCreateButton("Marquer un interact Portail (F9)", 10, 240, 280, 30)
	GUICtrlSetOnEvent($hButton3, "SequencerAddInteractPortal")
	$recordImportantButton = GUICtrlCreateButton("Marquer une emplacement (F10)", 10, 280, 280, 30)
	GUICtrlSetOnEvent($recordImportantButton, "SequencerMarkImportant")

    GUICtrlCreateLabel("Bienvenue dans le sequencer :" & @CRLF & @CRLF & "Appuyer sur F1 et ou F3 pour commencer l'enregistrement." & @CRLF  _
    	& @CRLF & "Appuyer sur ù pour ajouter des points à la séquence." & @CRLF _
    	& "Appuyer sur F10 pour marquer des positions importantes." & @CRLF & @CRLF _
    	& "Quand le bouton Dessiner la scene est désactiver, attendre un peu le temps que le bot finisse son scan." & @CRLF & @CRLF _
    	& "Quand tout est fini appuyer sur le bouton Dessiner la scène (ou F2)." & @CRLF  & @CRLF _
    	& "Vérifier le contenu du répertoire sequencer et améliorer les séquences si nécessaire.", 10, 380, 280, 260)

    $DrawSceneButton = GUICtrlCreateButton("Dessiner la scene et quitter (F2)", 10, 340, 280, 30)
    GUICtrlSetOnEvent($DrawSceneButton, "Draw_Scene")
    GUICtrlSetState($DrawSceneButton, $GUI_DISABLE)

	GUISetState()
EndFunc

Func On_SequencerTools_Close()
	GUIDelete($SequencerToolsHandle)
	Terminate()
EndFunc

Func tri_flag()
	Dim $table_Walkable[1][8]
	Dim $table_UnWalkable[1][8]
	Local $count_walkable = 0
	Local $count_Unwalkable = 0

	For $i = 0 To Ubound($NavCell_Table_Totale) - 1
			if $NavCell_Table_Totale[$i][6] = 1 Then ;walkable
				$count_walkable += 1
				Redim $table_Walkable[$Count_Walkable][10]
				$table_Walkable[$count_walkable-1][0] = $NavCell_Table_Totale[$i][0]
				$table_Walkable[$count_walkable-1][1] = $NavCell_Table_Totale[$i][1]
				$table_Walkable[$count_walkable-1][2] = $NavCell_Table_Totale[$i][2]
				$table_Walkable[$count_walkable-1][3] = $NavCell_Table_Totale[$i][3]
				$table_Walkable[$count_walkable-1][4] = $NavCell_Table_Totale[$i][4]
				$table_Walkable[$count_walkable-1][5] = $NavCell_Table_Totale[$i][5]
				$table_Walkable[$count_walkable-1][6] = $NavCell_Table_Totale[$i][6]
				$table_Walkable[$count_walkable-1][7] = $NavCell_Table_Totale[$i][7]
			Else ;Unwalkable
				$count_UnWalkable += 1
				Redim $table_UnWalkable[$Count_UnWalkable][10]
				$table_UnWalkable[$count_Unwalkable-1][0] = $NavCell_Table_Totale[$i][0]
				$table_UnWalkable[$count_Unwalkable-1][1] = $NavCell_Table_Totale[$i][1]
				$table_UnWalkable[$count_Unwalkable-1][2] = $NavCell_Table_Totale[$i][2]
				$table_UnWalkable[$count_Unwalkable-1][3] = $NavCell_Table_Totale[$i][3]
				$table_UnWalkable[$count_Unwalkable-1][4] = $NavCell_Table_Totale[$i][4]
				$table_UnWalkable[$count_Unwalkable-1][5] = $NavCell_Table_Totale[$i][5]
				$table_UnWalkable[$count_Unwalkable-1][6] = $NavCell_Table_Totale[$i][6]
				$table_UnWalkable[$count_Unwalkable-1][7] = $NavCell_Table_Totale[$i][7]
			EndIf
		Next

	For $i = 0 to Ubound($table_Walkable) - 1
		$NavCell_Table_Totale[$i][0] = $table_Walkable[$i][0]
		$NavCell_Table_Totale[$i][1] = $table_Walkable[$i][1]
		$NavCell_Table_Totale[$i][2] = $table_Walkable[$i][2]
		$NavCell_Table_Totale[$i][3] = $table_Walkable[$i][3]
		$NavCell_Table_Totale[$i][4] = $table_Walkable[$i][4]
		$NavCell_Table_Totale[$i][5] = $table_Walkable[$i][5]
		$NavCell_Table_Totale[$i][6] = $table_Walkable[$i][6]
		$NavCell_Table_Totale[$i][7] = $table_Walkable[$i][7]
	Next

	For $i = 0 To Ubound($table_UnWalkable) - 1
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][0] = $table_UnWalkable[$i][0]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][1] = $table_UnWalkable[$i][1]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][2] = $table_UnWalkable[$i][2]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][3] = $table_UnWalkable[$i][3]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][4] = $table_UnWalkable[$i][4]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][5] = $table_UnWalkable[$i][5]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][6] = $table_UnWalkable[$i][6]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][7] = $table_UnWalkable[$i][7]
	Next

	Return $NavCell_Table_Totale
EndFunc

Global $hImage
Global $hGraphic
Global $attackRange = 50

Func Draw_MultipleMapData($datafiles, $sequenceFile = False)

	$filescount = UBound($datafiles)

	$area = -1
	$Buff_MeshMinX = 0
	$Buff_MeshMaxX = 0
	$Buff_MeshMinY = 0
	$Buff_MeshMaxY = 0

	Local $count_position = 0

	For $z = 1 to $filescount - 1
		_log("Loading file : " & $datafiles[$z])
		$temp = IniRead($datafiles[$z], "SceneInfo", "AreaId", -1)
		If $area <> -1 And $area <> $temp Then
			_log("Erreur : Mélange de plusieurs areaID ! ", $LOG_LEVEL_ERROR)
			MsgBox(0, "Erreur : ", "Plusiers areaID différents ! Vérifier votre sélection.")
			Return
		EndIf
		$temp_Buff_MeshMinX = IniRead($datafiles[$z], "SceneInfo", "MeshMinX", -1)
		$temp_Buff_MeshMaxX = IniRead($datafiles[$z], "SceneInfo", "MeshMaxX", -1)
		$temp_Buff_MeshMinY = IniRead($datafiles[$z], "SceneInfo", "MeshMinY", -1)
		$temp_Buff_MeshMaxY = IniRead($datafiles[$z], "SceneInfo", "MeshMaxY", -1)

		If $temp_Buff_MeshMinX < $Buff_MeshMinX Then
			$Buff_MeshMinX = $temp_Buff_MeshMinX
		EndIf
		If $temp_Buff_MeshMinY < $Buff_MeshMinY Then
			$Buff_MeshMinY = $temp_Buff_MeshMinY
		EndIf
		If $temp_Buff_MeshMaxX > $Buff_MeshMaxX Then
			$Buff_MeshMaxX = $temp_Buff_MeshMaxX
		EndIf
		If $temp_Buff_MeshMaxY > $Buff_MeshMaxY Then
			$Buff_MeshMaxY = $temp_Buff_MeshMaxY
		EndIf

	Next

	Initiate_GDIpicture($Buff_MeshMaxY - $Buff_MeshMinY, $Buff_MeshMaxX - $Buff_MeshMinX)

	For $z = 1 to $filescount - 1

		Local $count_scene = 0
		Local $count_navcell = 0

		$meshSize = IniRead($datafiles[$z], "SceneInfo", "SceneSize", -1)
		$navSize = IniRead($datafiles[$z], "SceneInfo", "NavSize", -1)
		$positionCount = IniRead($datafiles[$z], "SceneInfo", "PositionCount", 0)

		Dim $Scene_table_totale[$meshSize + 1][8]
		Dim $NavCell_Table_Totale[$navSize + 1][8]

		If $z = 1 Then
			Dim $Table_position[$positionCount + 1][4]
		Else
			ReDim $Table_position[$count_position + $positionCount + 1][4]
		EndIf

		_log("Loading cell data", $LOG_LEVEL_DEBUG)
		For $i = 0 To $navSize
			$temp = IniRead($datafiles[$z], "CellData", "Cell" & $i, -1)
			If $temp <> -1 Then
				$temp = StringSplit($temp, ",", 2)
				$count_navcell += 1
				$NavCell_Table_Totale[$count_navcell - 1][0] = $temp[0]
				$NavCell_Table_Totale[$count_navcell - 1][1] = $temp[1]
				$NavCell_Table_Totale[$count_navcell - 1][2] = $temp[2]
				$NavCell_Table_Totale[$count_navcell - 1][3] = $temp[3]
				$NavCell_Table_Totale[$count_navcell - 1][4] = $temp[4]
				$NavCell_Table_Totale[$count_navcell - 1][5] = $temp[5]
				$NavCell_Table_Totale[$count_navcell - 1][6] = $temp[6]
				$NavCell_Table_Totale[$count_navcell - 1][7] = $temp[7]
			EndIf
			If Mod($i, 1000) = 0 And $i <> 0 Then
				_log("Loaded : " & $i & "/" & $navSize  & " navCells")
			EndIf
		Next

		_log("Loading mesh data", $LOG_LEVEL_DEBUG)
		For $i = 0 To $meshSize
			$temp = IniRead($datafiles[$z], "MeshData", "Mesh" & $i, -1)
			If $temp <> -1 Then
				$temp = StringSplit($temp, ",", 2)
				If $temp[2] <> 0x00013CB6 And $temp[2] <> 0x00013C2E And $temp[2] <> 0x0000D50F And $temp[2] <> 0x00010A3D Then
					$count_scene += 1
					$Scene_table_totale[$count_scene - 1][0] = $temp[0]
					$Scene_table_totale[$count_scene - 1][1] = $temp[1]
					$Scene_table_totale[$count_scene - 1][2] = $temp[2]
					$Scene_table_totale[$count_scene - 1][3] = $temp[3]
					$Scene_table_totale[$count_scene - 1][4] = $temp[4]
					$Scene_table_totale[$count_scene - 1][5] = $temp[5]
					$Scene_table_totale[$count_scene - 1][6] = $temp[6]
					$Scene_table_totale[$count_scene - 1][7] = $temp[7]
				EndIf
			EndIf
		Next

		If $positionCount > 0 Then
			_log("Loading position data", $LOG_LEVEL_DEBUG)
			For $i = 0 To $positionCount - 1
				$temp = IniRead($datafiles[$z], "Positions", "Position" & $i, -1)
				If $temp <> -1 Then
					$temp = StringSplit($temp, ",", 2)
					$count_position += 1
					$Table_position[$count_position - 1][0] = $temp[1]
					$Table_position[$count_position - 1][1] = $temp[2]
					$Table_position[$count_position - 1][2] = $temp[3]
					$Table_position[$count_position - 1][3] = $temp[0]
				EndIf
			Next
		EndIf

		For $i = 0 To Ubound($Scene_table_totale) - 1
			For $y = 0 To Ubound($NavCell_Table_Totale) - 1
				If $Scene_table_totale[$i][0] = $NavCell_Table_Totale[$y][7] Then
					$vx = ($Scene_table_totale[$i][3] - $buff_MeshMinX) + $NavCell_Table_Totale[$y][0]
					$vy = ($Scene_table_totale[$i][4] - $buff_MeshMinY) + $NavCell_Table_Totale[$y][1]
					$tx = $NavCell_Table_Totale[$y][3] - $NavCell_Table_Totale[$y][0]
					$ty = $NavCell_Table_Totale[$y][4] - $NavCell_Table_Totale[$y][1]
					$flag = $NavCell_Table_Totale[$y][6]
					If $flag = 1 And $DrawNavCellWalkable = "true" Then
						Draw_Nav($vy, $vx, $flag, $ty, $tx)
					ElseIf $flag = 0 And $DrawNavCellUnWalkable = "true" Then
						Draw_Nav($vy, $vx, $flag, $ty, $tx)
					EndIf
				EndIf
			Next
		Next
	Next

	If Not $sequenceFile = False Then
		$file = FileOpen($sequenceFile)
		If $file = -1 Then
			_log("Error openning sequenceFile !", $LOG_LEVEL_ERROR)
			Return
		EndIf

		$count_mtp = 0
		$numLine = 0
		While 1
			$line = FileReadLine($file)
			If @error = -1 Then
				ExitLoop
			 EndIf
			 $numLine += 1
			 If StringInStr($line , "attackrange=") Then
			 	$attackRange = Trim(StringReplace($line, "attackrange=", ""))
			 Else
				 $temp = StringSplit($line, ",", 2)
				 If UBound($temp) = 5 Then
					$count_mtp += 1
					Redim $table_mtp[$count_mtp][6]
					$table_mtp[$count_mtp - 1][0] = $temp[0]
					$table_mtp[$count_mtp - 1][1] = $temp[1]
					$table_mtp[$count_mtp - 1][2] = $temp[2]
					$table_mtp[$count_mtp - 1][3] = $temp[3]
					$table_mtp[$count_mtp - 1][4] = $temp[4]
					$table_mtp[$count_mtp - 1][5] = $numLine
				 EndIf
			 EndIf
		WEnd
		FileClose($file)

		If $count_mtp > 0 Then
			$color_rec = _GDIPlus_PenCreate($MtpColor, 1)
			For $i = 0 To Ubound($Table_mtp) - 1
				Draw_Nav($Table_mtp[$i][1] - $buff_MeshMinY, $Table_mtp[$i][0] - $buff_MeshMinX, 2, 2, 2, $i, $Table_mtp[$i][3] & "|" & $Table_mtp[$i][5])
				If $DrawAttackRange And $Table_mtp[$i][3] = 1 Then
					_GDIPlus_GraphicsDrawEllipse ($hGraphic, $Table_mtp[$i][1] - $buff_MeshMinY - ($attackRange / 2) , $Table_mtp[$i][0] - $buff_MeshMinX - ($attackRange / 2) , $attackRange, $attackRange, $color_rec)
				EndIf
			Next
			_GDIPlus_PenDispose($color_rec)
		EndIF
	EndIf

	If $count_position > 0 Then
		For $i = 0 to $count_position - 1
			Draw_Nav($Table_position[$i][1] - $buff_MeshMinY, $Table_position[$i][0] - $buff_MeshMinX, 11, 8, 8, $i, $Table_position[$i][3])
		Next
	EndIF


	_GDIPlus_ImageSaveToFile($hImage, StringReplace($datafiles[1], ".ini", "_" & @MON &  @MDAY & @HOUR & @MIN & @SEC & ".png"))

	For $i = 0 To Ubound($Scene_table_totale) - 1
		If $DrawScene = "true" Then
			Draw_Nav(($Scene_table_totale[$i][4] - $buff_MeshMinY), ($Scene_table_totale[$i][3] - $buff_MeshMinX), 3, $Scene_table_totale[$i][6] - $Scene_table_totale[$i][4], $Scene_table_totale[$i][5] - $Scene_table_totale[$i][3], 0, -1)
		EndIf
	Next

	_GDIPlus_ImageSaveToFile($hImage, StringReplace($datafiles[1], ".ini", "_" & @MON &  @MDAY & @HOUR & @MIN & @SEC & "_withmesh.png"))

EndFunc

Func Draw_MapData($datafile, $sequenceFile = False)
	$area = IniRead($datafile, "SceneInfo", "AreaId", -1)
	$meshSize = IniRead($datafile, "SceneInfo", "SceneSize", -1)
	$navSize = IniRead($datafile, "SceneInfo", "NavSize", -1)
	$Buff_MeshMinX = IniRead($datafile, "SceneInfo", "MeshMinX", -1)
	$Buff_MeshMaxX = IniRead($datafile, "SceneInfo", "MeshMaxX", -1)
	$Buff_MeshMinY = IniRead($datafile, "SceneInfo", "MeshMinY", -1)
	$Buff_MeshMaxY = IniRead($datafile, "SceneInfo", "MeshMaxY", -1)
	$positionCount = IniRead($datafile, "SceneInfo", "PositionCount", 0)

	If $area = -1 Or $meshSize = -1 or $navSize = -1 Then
		_log("Invalid mapData file ! ", $LOG_LEVEL_ERROR)
	EndIf

	Dim $Scene_table_totale[$meshSize + 1][8]
	Dim $NavCell_Table_Totale[$navSize + 1][8]
	Dim $Table_position[$positionCount + 1][4]
	Local $count_scene = 0
	Local $count_navcell = 0
	Local $count_position = 0

	_log("Loading cell data", $LOG_LEVEL_DEBUG)
	For $i = 0 To $navSize
		$temp = IniRead($datafile, "CellData", "Cell" & $i, -1)
		If $temp <> -1 Then
			$temp = StringSplit($temp, ",", 2)
			$count_navcell += 1
			$NavCell_Table_Totale[$count_navcell - 1][0] = $temp[0]
			$NavCell_Table_Totale[$count_navcell - 1][1] = $temp[1]
			$NavCell_Table_Totale[$count_navcell - 1][2] = $temp[2]
			$NavCell_Table_Totale[$count_navcell - 1][3] = $temp[3]
			$NavCell_Table_Totale[$count_navcell - 1][4] = $temp[4]
			$NavCell_Table_Totale[$count_navcell - 1][5] = $temp[5]
			$NavCell_Table_Totale[$count_navcell - 1][6] = $temp[6]
			$NavCell_Table_Totale[$count_navcell - 1][7] = $temp[7]
		EndIf
		If Mod($i, 1000) = 0 And $i <> 0 Then
			_log("Loaded : " & $i & "/" & $navSize  & " navCells")
		EndIf
	Next

	_log("Loading mesh data", $LOG_LEVEL_DEBUG)
	For $i = 0 To $meshSize
		$temp = IniRead($datafile, "MeshData", "Mesh" & $i, -1)
		If $temp <> -1 Then
			$temp = StringSplit($temp, ",", 2)
			If $temp[2] <> 0x00013CB6 And $temp[2] <> 0x00013C2E And $temp[2] <> 0x0000D50F And $temp[2] <> 0x00010A3D Then
				$count_scene += 1
				$Scene_table_totale[$count_scene - 1][0] = $temp[0]
				$Scene_table_totale[$count_scene - 1][1] = $temp[1]
				$Scene_table_totale[$count_scene - 1][2] = $temp[2]
				$Scene_table_totale[$count_scene - 1][3] = $temp[3]
				$Scene_table_totale[$count_scene - 1][4] = $temp[4]
				$Scene_table_totale[$count_scene - 1][5] = $temp[5]
				$Scene_table_totale[$count_scene - 1][6] = $temp[6]
				$Scene_table_totale[$count_scene - 1][7] = $temp[7]
			EndIf
		EndIf
	Next
	If $positionCount > 0 Then
		_log("Loading position data", $LOG_LEVEL_DEBUG)
		For $i = 0 To $positionCount - 1
			$temp = IniRead($datafile, "Positions", "Position" & $i, -1)
			If $temp <> -1 Then
				$temp = StringSplit($temp, ",", 2)
				$count_position += 1
				$Table_position[$count_position - 1][0] = $temp[1]
				$Table_position[$count_position - 1][1] = $temp[2]
				$Table_position[$count_position - 1][2] = $temp[3]
				$Table_position[$count_position - 1][3] = $temp[0]
			EndIf
		Next
	EndIf

	Initiate_GDIpicture($Buff_MeshMaxY - $Buff_MeshMinY, $Buff_MeshMaxX - $Buff_MeshMinX)

	For $i = 0 To Ubound($Scene_table_totale) - 1
		For $y = 0 To Ubound($NavCell_Table_Totale) - 1
			If $Scene_table_totale[$i][0] = $NavCell_Table_Totale[$y][7] Then
				$vx = ($Scene_table_totale[$i][3] - $buff_MeshMinX) + $NavCell_Table_Totale[$y][0]
				$vy = ($Scene_table_totale[$i][4] - $buff_MeshMinY) + $NavCell_Table_Totale[$y][1]
				$tx = $NavCell_Table_Totale[$y][3] - $NavCell_Table_Totale[$y][0]
				$ty = $NavCell_Table_Totale[$y][4] - $NavCell_Table_Totale[$y][1]
				$flag = $NavCell_Table_Totale[$y][6]
				If $flag = 1 And $DrawNavCellWalkable = "true" Then
					Draw_Nav($vy, $vx, $flag, $ty, $tx)
				ElseIf $flag = 0 And $DrawNavCellUnWalkable = "true" Then
					Draw_Nav($vy, $vx, $flag, $ty, $tx)
				EndIf
			EndIf
		Next
	Next

	If Not $sequenceFile = False Then
		$file = FileOpen($sequenceFile)
		If $file = -1 Then
			_log("Error openning sequenceFile !", $LOG_LEVEL_ERROR)
			Return
		EndIf

		$count_mtp = 0
		$numLine = 0
		While 1
			$line = FileReadLine($file)
			If @error = -1 Then
				ExitLoop
			 EndIf
			 $numLine += 1
			 If StringInStr($line , "attackrange=") Then
			 	$attackRange = Trim(StringReplace($line, "attackrange=", ""))
			 Else
				 $temp = StringSplit($line, ",", 2)
				 If UBound($temp) = 5 Then
					$count_mtp += 1
					Redim $table_mtp[$count_mtp][6]
					$table_mtp[$count_mtp - 1][0] = $temp[0]
					$table_mtp[$count_mtp - 1][1] = $temp[1]
					$table_mtp[$count_mtp - 1][2] = $temp[2]
					$table_mtp[$count_mtp - 1][3] = $temp[3]
					$table_mtp[$count_mtp - 1][4] = $temp[4]
					$table_mtp[$count_mtp - 1][5] = $numLine
				 EndIf
			 EndIf
		WEnd
		FileClose($file)

		If $count_mtp > 0 Then
			$color_rec = _GDIPlus_PenCreate($MtpColor, 1)
			For $i = 0 To Ubound($Table_mtp) - 1
				Draw_Nav($Table_mtp[$i][1] - $buff_MeshMinY, $Table_mtp[$i][0] - $buff_MeshMinX, 2, 2, 2, $i, $Table_mtp[$i][3] & "|" & $Table_mtp[$i][5])
				If $DrawAttackRange And $Table_mtp[$i][3] = 1 Then
					_GDIPlus_GraphicsDrawEllipse ($hGraphic, $Table_mtp[$i][1] - $buff_MeshMinY - ($attackRange / 2) , $Table_mtp[$i][0] - $buff_MeshMinX - ($attackRange / 2) , $attackRange, $attackRange, $color_rec)
				EndIf
			Next
			_GDIPlus_PenDispose($color_rec)
		EndIF
	EndIf

	If $count_position > 0 Then
		For $i = 0 to $count_position - 1
			Draw_Nav($Table_position[$i][1] - $buff_MeshMinY, $Table_position[$i][0] - $buff_MeshMinX, 11, 8, 8, $i, $Table_position[$i][3])
		Next
	EndIF


	_GDIPlus_ImageSaveToFile($hImage, StringReplace($datafile, ".ini", "_" & @MON &  @MDAY & @HOUR & @MIN & @SEC & ".png"))

	For $i = 0 To Ubound($Scene_table_totale) - 1
		If $DrawScene = "true" Then
			Draw_Nav(($Scene_table_totale[$i][4] - $buff_MeshMinY), ($Scene_table_totale[$i][3] - $buff_MeshMinX), 3, $Scene_table_totale[$i][6] - $Scene_table_totale[$i][4], $Scene_table_totale[$i][5] - $Scene_table_totale[$i][3], 0, $Scene_table_totale[$i][2])
		EndIf
	Next

	_GDIPlus_ImageSaveToFile($hImage, StringReplace($datafile, ".ini", "_" & @MON &  @MDAY & @HOUR & @MIN & @SEC & "_withmesh.png"))

EndFunc

Func Draw_Scene()
	$area = GetLevelAreaId()
	$iniFile = @scriptDir & "\sequencer\" & $area & $mapDataIni & ".ini"

	_log("taille du tab Scene-> " & Ubound($Scene_table_totale))
	_log("taille du tab NavCell-> " & Ubound($NavCell_Table_Totale))

	If $SaveSequenceData Then
		IniWrite($iniFile, "SceneInfo", "AreaId", $area)
		IniWrite($iniFile, "SceneInfo", "SceneSize", Ubound($Scene_table_totale))
		IniWrite($iniFile, "SceneInfo", "NavSize", Ubound($NavCell_Table_Totale))
		IniWrite($iniFile, "SceneInfo", "PositionCount", $count_Important)
		IniWrite($iniFile, "SceneInfo", "MeshMinX", $Buff_MeshMinX)
		IniWrite($iniFile, "SceneInfo", "MeshMaxX", $Buff_MeshMaxX)
		IniWrite($iniFile, "SceneInfo", "MeshMinY", $Buff_MeshMinY)
		IniWrite($iniFile, "SceneInfo", "MeshMaxY", $Buff_MeshMaxY)
	EndIf

	If $count_Important > 0 Then
		For $i = 0 to Ubound($Table_Important) - 1
			IniWrite($iniFile, "Positions", "Position" & $i, $Table_Important[$i][3] & "," & $Table_Important[$i][0] & "," & $Table_Important[$i][1] & "," & $Table_Important[$i][2])
		Next
	EndIF

	Initiate_GDIpicture($Buff_MeshMaxY - $Buff_MeshMinY, $Buff_MeshMaxX - $Buff_MeshMinX)

	_log($Buff_MeshMaxY - $Buff_MeshMinY & " - " & $Buff_MeshMaxX - $Buff_MeshMinX)
	_log(" MaxY : " & $Buff_MeshMaxY & " MinY : " & $Buff_MeshMinY & " MaxX : " & $Buff_MeshMaxX & " MinX : " & $Buff_MeshMinX)

	If $DrawNavCellWalkable = "true" And $DrawNavCellUnWalkable = "True" Then
		Dim $Tab_temp = tri_flag()
		Dim $NavCell_Table_Totale = $Tab_temp
	EndIF

	For $i = 0 To Ubound($Scene_table_totale) - 1
		If $SaveSequenceData Then
			IniWrite($iniFile, "MeshData", "Mesh" & $i, $Scene_table_totale[$i][0] & "," & $Scene_table_totale[$i][1] & "," & _
				$Scene_table_totale[$i][2] & "," & $Scene_table_totale[$i][3] & "," & $Scene_table_totale[$i][4] & "," & _
				$Scene_table_totale[$i][5] & "," & $Scene_table_totale[$i][6] & "," & $Scene_table_totale[$i][7])
		EndIf
		For $y = 0 To Ubound($NavCell_Table_Totale) - 1
			If $Scene_table_totale[$i][0] = $NavCell_Table_Totale[$y][7] Then
				$vx = ($Scene_table_totale[$i][3] - $buff_MeshMinX) + $NavCell_Table_Totale[$y][0]
				$vy = ($Scene_table_totale[$i][4] - $buff_MeshMinY) + $NavCell_Table_Totale[$y][1]
				$tx = $NavCell_Table_Totale[$y][3] - $NavCell_Table_Totale[$y][0]
				$ty = $NavCell_Table_Totale[$y][4] - $NavCell_Table_Totale[$y][1]
				$flag = $NavCell_Table_Totale[$y][6]

				If $flag = 1 And $DrawNavCellWalkable = "true" Then
					Draw_Nav($vy, $vx, $flag, $ty, $tx)
				ElseIf $flag = 0 And $DrawNavCellUnWalkable = "true" Then
					Draw_Nav($vy, $vx, $flag, $ty, $tx)
				EndIf
				If $SaveSequenceData Then
					IniWrite($iniFile, "CellData", "Cell" & $y, $NavCell_Table_Totale[$y][0] & "," & $NavCell_Table_Totale[$y][1] & "," & _
						$NavCell_Table_Totale[$y][2] & "," & $NavCell_Table_Totale[$y][3] & "," & $NavCell_Table_Totale[$y][4] & "," & _
						$NavCell_Table_Totale[$y][5] & "," & $NavCell_Table_Totale[$y][6] & "," & $NavCell_Table_Totale[$y][7])
				EndIf
			EndIf
		Next
		If $DrawScene = "true" Then
			Draw_Nav(($Scene_table_totale[$i][4] - $buff_MeshMinY), ($Scene_table_totale[$i][3] - $buff_MeshMinX), 3, $Scene_table_totale[$i][6] - $Scene_table_totale[$i][4], $Scene_table_totale[$i][5] - $Scene_table_totale[$i][3], 0, $i)
		EndIf

		_log(" -> " &  int((100 / Ubound($Scene_table_totale)))*$i & "%")
	Next

	#cs
	If $count_mtp > 1 Then
		For $i=0 To Ubound($table_mtp) - 1
			If NOT $i = Ubound($table_mtp) - 1 Then
				PathFinding_MakePath($table_mtp[$i][0],$table_mtp[$i][1], $table_mtp[$i][2], $table_mtp[$i+1][0], $table_mtp[$i+1][1], $table_mtp[$i+1][2])
			EndIf
		Next
	EndIf
	#ce
	If $count_Important > 0 Then
		For $i = 0 to Ubound($Table_Important) - 1
			Draw_Nav($Table_Important[$i][1] - $buff_MeshMinY, $Table_Important[$i][0] - $buff_MeshMinX, 11, 8, 8, $i, "P" & $i)
		Next
	EndIF

	Save_GDIpicture()

	_log("Map succefully drawn and saved")
	WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
	Exit 0
EndFunc

Func Sequencer_IterateObj()
	If $recordObjectButton <> 0 Then
		GUICtrlSetState($recordObjectButton, $GUI_DISABLE)
	EndIf
	offsetlist()
	$area = GetLevelAreaId()
	_log("Iterate Object Start")
	While 1
		Local $index, $offset, $count, $item[14]
		startIterateObjectsList($index, $offset, $count)
		Dim $item_buff_2D[1][10]
		Local $i = 0
		$compt = 0
		$file = FileOpen( @scriptDir & "\sequencer\" & $area & $nameObjectListTxt & ".txt", 1)

		If $file = -1 Then
			_log("Enabled to open file, Script will shutdown")
			Exit
		EndIf

		$rules_name = "(?i)([a-zA-Z0-9_]*)"

		While iterateObjectsList($index, $offset, $count, $item)
			If StringRegExp($item[1], $rules_name) = 1 Then ;patern declaration ilvl
				$name_item = StringRegExp($item[1], $rules_name, 2)
				$exist = false
				For $i = 0 To Ubound($Iterate_Objet) - 1
					If StringInStr($Iterate_Objet[$i], $name_item[1], 2) Then
					;if $Iterate_Objet[$i] = $name_item[1] Then
						$exist = true
						ExitLoop
					EndIf
				Next

				If $exist = False And $name_item[1] <> "" Then
					$count_table = Ubound($Iterate_Objet)
					ReDim $Iterate_Objet[$count_table+1]
					$Iterate_Objet[$count_table-1] = $name_item[1]
					FileWriteLine($file, $name_item[1])
				EndIf
			EndIf
		WEnd
		FileClose($file)
	WEnd
EndFunc

Func SequencerMarkImportant()
	$currentloc = GetCurrentPos()
	ConsoleWrite("Marking important position : " &  $currentloc[0] & ", " & $currentloc[1] & ", " & $currentloc[2] & @CRLF);
	Redim $table_Important[$count_Important + 1][4]
	$table_Important[$count_Important][0] = $currentloc[0]
	$table_Important[$count_Important][1] = $currentloc[1]
	$table_Important[$count_Important][2] = $currentloc[2]
	$table_Important[$count_Important][3] = "Unknown"
	$count_Important += 1
EndFunc   ;==>SequencerMarkImportant

Func SequencerAddSleep()
	$area = GetLevelAreaId()
	ConsoleWrite("Ajout d'un sleep : Valeur a définir dans la séquence ! " & @CRLF);
	$file = FileOpen( @scriptDir & "\sequencer\" & $area & $nameSequenceTxt & ".txt", 1)
	If $file = -1 Then
		_log("Enabled to open file, Script will shutdown")
		Exit
	EndIf
	FileWriteLine($file, "sleep=1000")
	FileClose($file)
EndFunc   ;==>SequencerAddSleep

Func SequencerAddInteractActor()
	$area = GetLevelAreaId()
	ConsoleWrite("Ajout d'un InteractByActorName : Valeur a définir dans la séquence ! " & @CRLF);
	$file = FileOpen( @scriptDir & "\sequencer\" & $area & $nameSequenceTxt & ".txt", 1)
	If $file = -1 Then
		_log("Enabled to open file, Script will shutdown")
		Exit
	EndIf
	FileWriteLine($file, "InteractByActorName=VALEURADEFINIR")
	FileClose($file)
EndFunc   ;==>SequencerAddInteractActor

Func SequencerAddInteractDoor()
	$area = GetLevelAreaId()
	ConsoleWrite("Ajout d'un InteractWithDoor : Valeur a définir dans la séquence ! " & @CRLF);
	$file = FileOpen( @scriptDir & "\sequencer\" & $area & $nameSequenceTxt & ".txt", 1)
	If $file = -1 Then
		_log("Enabled to open file, Script will shutdown")
		Exit
	EndIf
	FileWriteLine($file, "InteractWithDoor=VALEURADEFINIR")
	FileClose($file)
EndFunc   ;==>SequencerAddInteractDoor

Func SequencerAddInteractPortal()
	$area = GetLevelAreaId()
	ConsoleWrite("Ajout d'un InteractWithPortal : Valeur a définir dans la séquence ! " & @CRLF);
	$file = FileOpen( @scriptDir & "\sequencer\" & $area & $nameSequenceTxt & ".txt", 1)
	If $file = -1 Then
		_log("Enabled to open file, Script will shutdown")
		Exit
	EndIf
	FileWriteLine($file, "InteractWithPortal=VALEURADEFINIR")
	FileWriteLine($file, "offsetlist()")
	FileClose($file)
EndFunc   ;==>SequencerAddInteractPortal

Func SequencerMarkPos()
	$currentloc = GetCurrentPos()
	$area = GetLevelAreaId()
	ConsoleWrite($currentloc[0] & ", " & $currentloc[1] & ", " & $currentloc[2] & ", 1, 25" & @CRLF);
	$file = FileOpen( @scriptDir & "\sequencer\" & $area & $nameSequenceTxt & ".txt", 1)

	If $file = -1 Then
		_log("Enabled to open file, Script will shutdown")
		Exit
	EndIf

	FileWriteLine($file, $currentloc[0] & "," & $currentloc[1] & "," & $currentloc[2] & ", 1, 25")
	FileClose($file)

	Redim $table_mtp[$count_mtp + 1][5]
	$table_mtp[$count_mtp][0] = $currentloc[0]
	$table_mtp[$count_mtp][1] = $currentloc[1]
	$table_mtp[$count_mtp][2] = $currentloc[2]
	$table_mtp[$count_mtp][3] = 1
	$table_mtp[$count_mtp][4] = 25
	$count_mtp += 1
EndFunc   ;==>SequencerMarkPos

Func IndexSNONoLimit($_offset, $_displayInfo = 0)

	;Local $CurrentSnoOffset = 0x0
	$_MainOffset = _MemoryRead($_offset, $d3, 'ptr')
	$_Pointer = _MemoryRead($_MainOffset + $_defptr, $d3, 'ptr')
	$_SnoCount = _MemoryRead($_Pointer + 0x108, $d3, 'int') ;//Doesnt seem to go beyond 256 for some wierd reason

	$_SnoIndex = _MemoryRead($_Pointer + $_deflink, $d3, 'ptr') ;//Moving from the static into the index
	$_SNOName = _MemoryRead($_Pointer, $d3, 'char[64]') ;//Usually something like "Something" + Def
	$TempWindex = $_SnoIndex + 0x10 ;//The header is 0xC in size
	If $_displayInfo = 1 Then _log("-----* Indexing " & $_SNOName & " *-----")
	Dim $_OutPut[$_SnoCount + 1][2] ;//Setting the size of the output array

	For $i = 1 To $_SnoCount Step +1 ;//Iterating through all the elements
		$_CurSnoOffset = _MemoryRead($TempWindex, $d3, 'ptr') ;//Getting the offset for the item
		$_CurSnoID = _MemoryRead($_CurSnoOffset, $d3, 'ptr') ;//Going into the item and grapping the GUID which is located at 0x0
		$_OutPut[$i][0] = $_CurSnoOffset ;//Poping the data into the output array
		$_OutPut[$i][1] = $_CurSnoID
		If $_displayInfo = 1 Then _log($i & " Offset: " & $_CurSnoOffset & " SNOid: " & $_CurSnoID )
		$TempWindex = $TempWindex + 0x14 ;//Next item is located 0x10 later
	Next
	Return $_OutPut
EndFunc   ;==>IndexSNO

Func Read_Scene()

	If $recordSceneButton <> 0 Then
		GUICtrlSetState($recordSceneButton, $GUI_DISABLE)
	EndIf

	_log("Lancement lecture scene")
	$nb_totale_scene_record = 0
	$nb_totale_navcell_record = 0
	$up = False

	Local $first_iteration_NavCell = True

	offsetlist()

	$ObManStoragePtr = _MemoryRead($ofs_objectmanager, $d3, "ptr")
	$offset = $ObManStoragePtr + 0x954
	$sceneCountPtr = _MemoryRead($offset, $d3, "ptr") + 0x108
	$sceneFirstPtr = _MemoryRead($offset, $d3, "ptr") + 0x11c

	While 1
		$countScene = _MemoryRead($sceneCountPtr, $d3, "int")
		;_log("Scene count : " & $countScene)

		Local $count = 0
		Local $New_scene_record = False
		Dim $sceneData[12]
		;################################## ITERATION OBJ SCENE ########################################
		For $i = 0 To $countScene
			$scenePtr = _MemoryRead($sceneFirstPtr, $d3, "ptr") + ($i * 0x2BC)
			$Structobj_scene = DllStructCreate("ptr;byte[4];ptr;byte[218];ptr;byte[16];float;float;byte[112];float;float")
			;id_scene -> 1 | id_world -> 3 | id_sno_scene -> 5 | MeshMinX -> 7 | MeshMinY -> 8 | MeshMaxX -> 10 | MeshMaxY -> 11
			DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $scenePtr, 'ptr', DllStructGetPtr($Structobj_scene), 'int', DllStructGetSize($Structobj_scene), 'int', '')
			$sceneData[1] = DllStructGetData($Structobj_scene, 1)
			$sceneData[3] = DllStructGetData($Structobj_scene, 3)
			$sceneData[5] = DllStructGetData($Structobj_scene, 5)
			$sceneData[7] = DllStructGetData($Structobj_scene, 7)
			$sceneData[8] = DllStructGetData($Structobj_scene, 8)
			$sceneData[10] = DllStructGetData($Structobj_scene, 10)
			$sceneData[11] = DllStructGetData($Structobj_scene, 11)

			If $sceneData[3] = $_MyACDWorld And $sceneData[1] <> 0xFFFFFFFF Then ;id world
				;_log("scene valide N°" & $i & " ACDWorld - > " & DllStructGetData($Structobj_scene, 3) & " Id World -> " &  DllStructGetData($Structobj_scene, 1))
		   		;_log("Id_Sno_Scene : " & DllStructGetData($Structobj_scene, 5))
				;_log("MinX : " & DllStructGetData($Structobj_scene, 7))
				;_log("MinY : " & DllStructGetData($Structobj_scene, 8))
				;_log("MaxX : " & DllStructGetData($Structobj_scene, 10))
				;_log("MaxY : " & DllStructGetData($Structobj_scene, 11))

				For $x = 0 To $nb_totale_scene_record - 1 ;Ubound($Scene_table_totale) - 1
					If $Scene_table_totale[$x][3] = $sceneData[7] And $Scene_table_totale[$x][4] = $sceneData[8] And $Scene_table_totale[$x][2] = $sceneData[5] Then
						ContinueLoop 2
					EndIf
				Next
				If $sceneData[5] = 0x00013CB6 Or $sceneData[5] = 0x00013C2E Or $sceneData[5] = 0x0000D50F Or $sceneData[5] = 0x00010A3D Then
					;_log("Skipping known SNO : " & DllStructGetData($Structobj_scene, 5), $LOG_LEVEL_WARNING )
					ContinueLoop
				EndIf

				ReDim $Scene_table_totale[$nb_totale_scene_record + 1][10]
				$Scene_table_totale[$nb_totale_scene_record][0] = $sceneData[1] ; Id_Scene
				$Scene_table_totale[$nb_totale_scene_record][1] = $sceneData[3] ; Id_World
				$Scene_table_totale[$nb_totale_scene_record][2] = $sceneData[5] ; Id_Sno_Scene
				$Scene_table_totale[$nb_totale_scene_record][3] = $sceneData[7] ; MesMinX
				$Scene_table_totale[$nb_totale_scene_record][4] = $sceneData[8] ; MesMinY
				$Scene_table_totale[$nb_totale_scene_record][5] = $sceneData[10] ; MeshMaxX
				$Scene_table_totale[$nb_totale_scene_record][6] = $sceneData[11] ; MeshMaxY
				$Scene_table_totale[$nb_totale_scene_record][7] = False ;On connais ou pas les NavCell Associer a la Scene

				If $Scene_table_totale[$nb_totale_scene_record][3] < $Buff_MeshMinX Then
					$Buff_MeshMinX = $Scene_table_totale[$nb_totale_scene_record][3]
				EndIf
				If $Scene_table_totale[$nb_totale_scene_record][4] < $Buff_MeshMinY Then
					$Buff_MeshMinY = $Scene_table_totale[$nb_totale_scene_record][4]
				EndIf
				If $Scene_table_totale[$nb_totale_scene_record][5] > $Buff_MeshMaxX Then
					$Buff_MeshMaxX = $Scene_table_totale[$nb_totale_scene_record][5]
				EndIf
				If $Scene_table_totale[$nb_totale_scene_record][6] > $Buff_MeshMaxY Then
					$Buff_MeshMaxY = $Scene_table_totale[$nb_totale_scene_record][6]
				EndIf
				$nb_totale_scene_record += 1
				$New_scene_record = true
			EndIf
		Next
		;################################################################################################
		If $New_scene_record = True Then ;Si Une nouvelle scene à eté enregistrée
			If $drawSceneButton <> 0 Then
				GUICtrlSetState($drawSceneButton, $GUI_DISABLE)
			EndIf
			_log("Scene Recorded : " & $nb_totale_scene_record)
			Dim $list_sno_scene = IndexSNONoLimit(0x1CEF78C, 0)
			;############################## ITERATION DU SNO ###########################################
			$Size = Ubound($list_sno_scene) - 1
			For $i = 1 to $Size
				$correlation = false
				$current_obj_scene = 0

				For $x = 0 To Ubound($Scene_table_totale) - 1
					;_log("Seek : " & $list_sno_scene[$i][1] & " - " & $Scene_table_totale[$x][2] & " / " & $Scene_table_totale[$x][7])
					If $list_sno_scene[$i][1] = $Scene_table_totale[$x][2] And $Scene_table_totale[$x][7] = False Then
						$correlation = True
						$current_scene = $x
						_log("Correlation trouvée pour la scene ->" & $current_scene)
						ExitLoop
					EndIf
				Next

				If $correlation = True Then
					$NavMeshDef = $list_sno_scene[$i][0] + 0x040
					$NavZoneDef = $list_sno_scene[$i][0] + 0x180

					;############## ITERATION DES NAVCELL ################
					$CountNavCell = _memoryRead($NavZoneDef, $d3, "int")
					$NavCellPtr = _memoryRead($NavZoneDef + 0x08, $d3, "ptr")

					;_log("Iteration du Count pour la scene -> " & $current_scene & " nb navcell -> " & $CountNavCell)
					If $CountNavCell <> 0 Then
						If $first_iteration_NavCell Then
							$depart_count = Ubound($NavCell_Table_Totale) - 1
							$first_iteration_NavCell = false
						Else
							$depart_count = Ubound($NavCell_Table_Totale)
						EndIf

						Local $NavCellStruct = DllStructCreate("float;float;float;float;float;float;short")
						Redim $NavCell_Table_Totale[ $depart_count + $CountNavCell ][8]

						For $t = 0 To $CountNavCell - 1
							DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $NavCellPtr + ($t * 0x20), 'ptr', DllStructGetPtr($NavCellStruct), 'int', DllStructGetSize($NavCellStruct), 'int', '')

							If Mod( DllStructGetData($NavCellStruct, 7) , 2) = 1 Then
								$flag = 1
								;$walkable += 1
								;Redim $NavCell_PathFinding[$walkable][4]
								;$NavCell_PathFinding[$walkable-1][0] = $Scene_table_Totale[$current_scene][3] + DllStructGetData($NavCellStruct, 1)  ;MinX reel
								;$NavCell_PathFinding[$walkable-1][1] = $Scene_table_Totale[$current_scene][3] + DllStructGetData($NavCellStruct, 4)  ;MaxX reel
								;$NavCell_PathFinding[$walkable-1][2] = $Scene_table_Totale[$current_scene][4] + DllStructGetData($NavCellStruct, 2)  ;MinX reel
								;$NavCell_PathFinding[$walkable-1][3] = $Scene_table_Totale[$current_scene][4] + DllStructGetData($NavCellStruct, 5)  ;MaxY reel
							Else
								$flag = 0
							EndIf
							;_log($depart_count)
							$NavCell_Table_Totale[$depart_count][0] = DllStructGetData($NavCellStruct, 1) ;MinX
							$NavCell_Table_Totale[$depart_count][1] = DllStructGetData($NavCellStruct, 2) ;MinY
							$NavCell_Table_Totale[$depart_count][2] = DllStructGetData($NavCellStruct, 3) ;MinZ
							$NavCell_Table_Totale[$depart_count][3] = DllStructGetData($NavCellStruct, 4) ;MaxX
							$NavCell_Table_Totale[$depart_count][4] = DllStructGetData($NavCellStruct, 5) ;MaxY
							$NavCell_Table_Totale[$depart_count][5] = DllStructGetData($NavCellStruct, 6) ;MaxZ
							$NavCell_Table_Totale[$depart_count][6] = $flag ;$flag
							$NavCell_Table_Totale[$depart_count][7] = $Scene_table_totale[$current_scene][0]  ;id_scene au moment de l'enregistrement
							$depart_count += 1
						Next
					EndIf
					$Scene_table_Totale[$current_scene][7] = True
				EndIf
			Next
			If $drawSceneButton <> 0 Then
				GUICtrlSetState($drawSceneButton, $GUI_ENABLE)
			EndIf
			_log("Ready to draw scene")
		EndIf
		Sleep(50)
	WEnd
EndFunc