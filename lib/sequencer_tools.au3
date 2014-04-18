#include-once

Global $Table_mtp[1][5]
Global $count_mtp = 0
Global $Scene_table_totale[1][8]
Global $NavCell_table_totale[1][8]
Global $Buff_MeshMinX = 999999
Global $Buff_MeshMinY = 999999
Global $Buff_MeshMaxX = 0
Global $Buff_MeshMaxY = 0

Global $Iterate_Objet[1]

Global $DrawScene="True"
Global $DrawNavCellWalkable="False"
Global $DrawNavCellUnWalkable="True"
Global $DrawArrow="True"
Global $DrawMtp="True"

Global $SceneColor="0xFF000000"
Global $NavcellWalkableColor="0xFF85DB24"
Global $NavcellUnWalkableColor="0xFF83888a"
Global $ArrawColor="0xFF00FFC0"
Global $MtpColor="0xFFFF0000"
Global $nameSequenceTxt = "-sequence-" & @MON &  @MDAY & @HOUR & @MIN & @SEC
Global $PictureScene = "-pictureScene-" & @MON &  @MDAY & @HOUR & @MIN & @SEC
Global $Picturemtp = "-picturemtp-" & @MON &  @MDAY & @HOUR & @MIN & @SEC
Global $nameObjectListTxt = "-ObjectList-" & @MON &  @MDAY & @HOUR & @MIN & @SEC


Global $SequencerToolsHandle
Global $recordSceneButton = 0
Global $recordObjectButton = 0
Global $DrawSceneButton = 0

Func ShowSequencerTools()
	$SequencerToolsHandle = GUICreate("Sequencer tools", 200, 500, Default, Default, $WS_BORDER, $WS_EX_TOPMOST)
	If $SequencerToolsHandle = 0 Then
		_Log("Problem starting debug tools", $LOG_LEVEL_ERROR)
		Return
	EndIf
	GUISetOnEvent($GUI_EVENT_CLOSE, "On_SequencerTools_Close")

	$recordSceneButton = GUICtrlCreateLabel("Enregistrer la scène : F1", 10, 10, 180, 20)
    $recordObjectButton = GUICtrlCreateLabel("Enregistrer les objets : F3", 10, 30, 180, 20)

    $hButton3 = GUICtrlCreateButton("Marquer une position (ù)", 10, 60, 180, 30)
	GUICtrlSetOnEvent($hButton3, "SequencerMarkPos")

    GUICtrlCreateLabel("Bienvenue dans le sequencer :" & @CRLF & @CRLF & "Appuyer sur F1 et ou F3 pour commencer l'enregistrement." & @CRLF  _
    	& @CRLF & "Appuyer sur le ù pour ajouter des points à la séquence." & @CRLF & @CRLF _
    	& "Quand le bouton Dessiner la scene est désactiver, attendre un peu le temps que le bot finisse son scan." & @CRLF & @CRLF _
    	& "Quand tout est fini appuyer sur le bouton Dessiner la scène (ou F2)." & @CRLF  & @CRLF _
    	& "Vérifier le contenu du répertoire sequencer et améliorer les séquences si nécessaire.", 10, 160, 180, 360)
	
    $DrawSceneButton = GUICtrlCreateButton("Dessiner la scene et quitter (F2)", 10, 120, 180, 30)
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

Func Draw_Scene()
	_log("taille du tab Scene-> " & Ubound($Scene_table_totale))
	_log("taille du tab NavCell-> " & Ubound($NavCell_Table_Totale))

	Initiate_GDIpicture($Buff_MeshMaxY - $Buff_MeshMinY, $Buff_MeshMaxX - $Buff_MeshMinX)

	_log($Buff_MeshMaxY - $Buff_MeshMinY & " - " & $Buff_MeshMaxX - $Buff_MeshMinX)
	_log(" MaxY : " & $Buff_MeshMaxY & " MinY : " & $Buff_MeshMinY & " MaxX : " & $Buff_MeshMaxX & " MinX : " & $Buff_MeshMinX)

	If $DrawNavCellWalkable = "true" And $DrawNavCellUnWalkable = "True" Then
		Dim $Tab_temp = tri_flag()
		Dim $NavCell_Table_Totale = $Tab_temp
	EndIF

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

			EndIF
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

	Save_GDIpicture()
	_log("Map succefully drawn")
	exit 0
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

Func SequencerMarkPos()
	$currentloc = GetCurrentPos()
	$area = GetLevelAreaId()
	ConsoleWrite($currentloc[0] & ", " & $currentloc[1] & ", " & $currentloc[2] & ", 1, 25" & @CRLF);
	$file = FileOpen( @scriptDir & "\sequencer\" & $area & $nameSequenceTxt & ".txt", 1)

	If $file = -1 Then
		_log("Enabled to open file, Script will shutdown")
		Exit
	EndIf
	$count_mtp += 1

	FileWriteLine($file, $currentloc[0] & "," & $currentloc[1] & "," & $currentloc[2] & ", 1, 25")
	FileClose($file)

	Redim $table_mtp[$count_mtp][5]
	$table_mtp[$count_mtp-1][0] = $currentloc[0]
	$table_mtp[$count_mtp-1][1] = $currentloc[1]
	$table_mtp[$count_mtp-1][2] = $currentloc[2]
	$table_mtp[$count_mtp-1][3] = 1
	$table_mtp[$count_mtp-1][4] = 25
EndFunc   ;==>MarkPos

Func IndexSNONoLimit($_offset, $_displayInfo = 0)

	Local $CurrentSnoOffset = 0x0
	$_MainOffset = _MemoryRead($_offset, $d3, 'ptr')
	$_Pointer = _MemoryRead($_MainOffset + $_defptr, $d3, 'ptr')
	$_SnoCount = _MemoryRead($_Pointer + 0x108, $d3, 'int') ;//Doesnt seem to go beyond 256 for some wierd reason
	$ignoreSNOcount = 0

	$_SnoIndex = _MemoryRead($_Pointer + $_deflink, $d3, 'ptr') ;//Moving from the static into the index
	$_SNOName = _MemoryRead($_Pointer, $d3, 'char[64]') ;//Usually something like "Something" + Def
	$TempWindex = $_SnoIndex + 0x10 ;//The header is 0xC in size
	If $_displayInfo = 1 Then _log("-----* Indexing " & $_SNOName & " *-----")
	Dim $_OutPut[$_SnoCount + 1][2] ;//Setting the size of the output array

	For $i = 1 To $_SnoCount Step +1 ;//Iterating through all the elements
		$_CurSnoOffset = _MemoryRead($TempWindex, $d3, 'ptr') ;//Getting the offset for the item
		$_CurSnoID = _MemoryRead($_CurSnoOffset, $d3, 'ptr') ;//Going into the item and grapping the GUID which is located at 0x0
		If $ignoreSNOcount = 1 And $_CurSnoOffset = 0x00000000 And $_CurSnoID = 0x00000000 Then ExitLoop ;//Untill i find a way to get the real count we do this instead.
		If $ignoreSNOcount = 1 Then $CurIndex = $i
		$_OutPut[$i][0] = $_CurSnoOffset ;//Poping the data into the output array
		$_OutPut[$i][1] = $_CurSnoID
		If $_displayInfo = 1 Then _log($i & " Offset: " & $_CurSnoOffset & " SNOid: " & $_CurSnoID )
		$TempWindex = $TempWindex + 0x14 ;//Next item is located 0x10 later
	Next

	If $ignoreSNOcount = 1 Then ReDim $_OutPut[$CurIndex][2] ;//Here we do the resizing of the array, to minimize memory footprint!?.

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

		Dim $obj_scene[1][10]
		Local $count = 0

		Local $New_scene_record = False

		;################################## ITERATION OBJ SCENE ########################################
		For $i=0 To $countScene
			$scenePtr = _MemoryRead($sceneFirstPtr, $d3, "ptr") + ($i * 0x2BC)
			$Structobj_scene = DllStructCreate("ptr;byte[4];ptr;byte[218];ptr;byte[16];float;float;byte[112];float;float")
			;id_scene -> 1 | id_world -> 3 | id_sno_scene -> 5 | MeshMinX -> 7 | MeshMinY -> 8 | MeshMaxX -> 10 | MeshMaxY -> 11
			DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $scenePtr, 'ptr', DllStructGetPtr($Structobj_scene), 'int', DllStructGetSize($Structobj_scene), 'int', '')
			$correlation = true

			If DllStructGetData($Structobj_scene, 3) = $_MyACDWorld And DllStructGetData($Structobj_scene, 1) <> 0xFFFFFFFF Then ;id world
				;_log("scene valide N°" & $i & " ACDWorld - > " & DllStructGetData($Structobj_scene, 3) & " Id World -> " &  DllStructGetData($Structobj_scene, 1))
		   		;_log("Id_Sno_Scene : " & DllStructGetData($Structobj_scene, 5))
				;_log("MinX : " & DllStructGetData($Structobj_scene, 7))
				;_log("MinY : " & DllStructGetData($Structobj_scene, 8))
				;_log("MaxX : " & DllStructGetData($Structobj_scene, 10))
				;_log("MaxY : " & DllStructGetData($Structobj_scene, 11))

				For $x = 0 To Ubound($Scene_table_totale) - 1
					If $Scene_table_totale[$x][3] = DllStructGetData($Structobj_scene, 7) And $Scene_table_totale[$x][4] = DllStructGetData($Structobj_scene, 8) AND $Scene_table_totale[$x][2] = DllStructGetData($Structobj_scene, 5) Then
						$correlation = false
					EndIf
				Next

				If $correlation = True Then
					$nb_totale_scene_record += 1
					ReDim $Scene_table_totale[$nb_totale_scene_record][10]
					$Scene_table_totale[$nb_totale_scene_record-1][0] = DllStructGetData($Structobj_scene, 1) ; Id_Scene
					$Scene_table_totale[$nb_totale_scene_record-1][1] = DllStructGetData($Structobj_scene, 3) ; Id_World
					$Scene_table_totale[$nb_totale_scene_record-1][2] = DllStructGetData($Structobj_scene, 5) ; Id_Sno_Scene
					$Scene_table_totale[$nb_totale_scene_record-1][3] = DllStructGetData($Structobj_scene, 7) ; MesMinX
					$Scene_table_totale[$nb_totale_scene_record-1][4] = DllStructGetData($Structobj_scene, 8) ; MesMinY
					$Scene_table_totale[$nb_totale_scene_record-1][5] = DllStructGetData($Structobj_scene, 10) ; MeshMaxX
					$Scene_table_totale[$nb_totale_scene_record-1][6] = DllStructGetData($Structobj_scene, 11) ; MeshMaxY
					$Scene_table_totale[$nb_totale_scene_record-1][7] = false ;On connais ou pas les NavCell Associer a la Scene

					If $Scene_table_totale[$nb_totale_scene_record-1][3] < $Buff_MeshMinX Then
						$Buff_MeshMinX = $Scene_table_totale[$nb_totale_scene_record-1][3]
					EndIf

					If $Scene_table_totale[$nb_totale_scene_record-1][4] < $Buff_MeshMinY Then
						$Buff_MeshMinY = $Scene_table_totale[$nb_totale_scene_record-1][4]
					EndIf

					If $Scene_table_totale[$nb_totale_scene_record-1][5] > $Buff_MeshMaxX Then
						$Buff_MeshMaxX = $Scene_table_totale[$nb_totale_scene_record-1][5]
					EndIf

					If $Scene_table_totale[$nb_totale_scene_record-1][6] > $Buff_MeshMaxY Then
						$Buff_MeshMaxY = $Scene_table_totale[$nb_totale_scene_record-1][6]
					EndIf

					$New_scene_record = true
				EndIf
				;_log("scene incorrect N°" & $i & " ACDWorld - > " & DllStructGetData($Structobj_scene, 3) & " Id World -> " &  DllStructGetData($Structobj_scene, 1))
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
			For $i = 1 to Ubound($list_sno_scene) - 1
				$correlation = false
				$current_obj_scene = 0

				For $x = 0 To Ubound($Scene_table_totale)-1
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
					$Scene_table_Totale[$current_scene][7] = true
				EndIf
			Next
			If $drawSceneButton <> 0 Then
				GUICtrlSetState($drawSceneButton, $GUI_ENABLE)
			EndIf
			_log("Ready to draw scene")
		EndIf
		
		Sleep(200)
	WEnd
EndFunc