#include <math.au3>
#include <String.au3>
#include <Array.au3>

Global $Scene_table_totale[1][10]
Global $NavCell_table_totale[1][10]
Global $Scene_table_id_scene[1]
Global $profilFile = "settings.ini"

Global $nameSequenceTxt = "sequence"
Global $PictureScene = "pictureScene"
Global $Picturemtp = "picturemtp"

Global $DrawScene="True"
Global $DrawNavCellWalkable="True"
Global $DrawNavCellUnWalkable="True"
Global $DrawArrow="True"
Global $DrawMtp="True"

Global $SceneColor="0xFF000000"
Global $NavcellWalkableColor="0xFF85DB24"
Global $NavcellUnWalkableColor="0xFF83888a"
Global $ArrawColor="0xFF00FFC0"
Global $MtpColor="0xFFFF0000"

Global $count_mtp = 0
Global $Table_mtp[1][5]

#include "Creat_Sequence.au3"
#include "Gdi_Draw.au3"

Func Read_Scene()
	_log("Lancement lecture scene")
	$nb_totale_scene_record = 0
	$up = false

	offsetlist()

While 1

	$ObManStoragePtr = _MemoryRead($ofs_objectmanager, $d3, "ptr")
	$offset = $ObManStoragePtr + 0x794 + 0x178
	$sceneCountPtr = _MemoryRead($offset, $d3, "ptr") + 0x108
	$countScene = _MemoryRead($sceneCountPtr, $d3, "int")

	$sceneFirstPtr = _MemoryRead($offset, $d3, "ptr") + 0x148
	Dim $obj_scene[1][10]
	$count = 0

	;################################## ITERATION OBJ SCENE ########################################
	for $i=0 to $countScene
		$scenePtr = _MemoryRead($sceneFirstPtr, $d3, "ptr") + $i * 0x2A8

		$temp_id_world = _MemoryRead ( $scenePtr + 0x008, $d3, "ptr") ;id world
		$temp_id_scene = _MemoryRead ( $scenePtr, $d3, "ptr") ;id world
		$correlation = true



		If $temp_id_world = $_MyACDWorld AND $temp_id_scene <> 0xFFFFFFFF Then;id world

			If $nb_totale_scene_record = 0 Then
				$Scene_table_id_scene[0] = $temp_id_scene
				$nb_totale_scene_record += 1
			Else
				for $a=0 to Ubound($Scene_table_id_scene) - 1
					If $Scene_table_id_scene[$a] = $temp_id_scene Then
						$correlation = false
						ExitLoop
					EndIf
				Next
					If $correlation = true Then
						$Ucount=Ubound($Scene_table_id_scene)
						Redim $Scene_table_id_scene[$Ucount+1]
						$Scene_table_id_scene[$Ucount] = $temp_id_scene
					EndIF
			EndIF

			If $correlation = true Then

				$nb_totale_scene_record += 1
				$count += 1
				ReDim $obj_scene[$count][10]

				$obj_scene[$count-1][0] = $temp_id_scene ;id_scene
				$scenePtr += 0x004
				$obj_scene[$count-1][1] = $temp_id_world ;id world
				$obj_scene[$count-1][2] = _MemoryRead ( $scenePtr + 0x014, $d3, "int") ;sno_levelarea
				$obj_scene[$count-1][3] = _MemoryRead ( $scenePtr + 0x0D8, $d3, "ptr") ;id_sno_scene

				$obj_scene[$count-1][4] = _MemoryRead ( $scenePtr + 0x0EC, $d3, "float") ;Vec2 Meshmin x
				$obj_scene[$count-1][5] = _MemoryRead ( $scenePtr + 0x0F0, $d3, "float") ;Vec2 Meshmin y
				$obj_scene[$count-1][6] = _MemoryRead ( $scenePtr + 0x0F4, $d3, "float") ;Vec2 Meshmin z

				$obj_scene[$count-1][7] = _MemoryRead ( $scenePtr + 0x164, $d3, "float") ;Vec2 Meshmax x
				$obj_scene[$count-1][8] = _MemoryRead ( $scenePtr + 0x168, $d3, "float") ;Vec2 Meshmax y
				$obj_scene[$count-1][9] = _MemoryRead ( $scenePtr + 0x16C, $d3, "float") ;Vec2 Meshmax z


				ReDim $Scene_table_totale[$nb_totale_scene_record][10]

				$Scene_table_totale[$nb_totale_scene_record-1][0] = $obj_scene[$count-1][0]
				$Scene_table_totale[$nb_totale_scene_record-1][1] = $obj_scene[$count-1][1]
				$Scene_table_totale[$nb_totale_scene_record-1][2] = $obj_scene[$count-1][2]
				$Scene_table_totale[$nb_totale_scene_record-1][3] = $obj_scene[$count-1][3]
				$Scene_table_totale[$nb_totale_scene_record-1][4] = $obj_scene[$count-1][4]
				$Scene_table_totale[$nb_totale_scene_record-1][5] = $obj_scene[$count-1][5]
				$Scene_table_totale[$nb_totale_scene_record-1][6] = $obj_scene[$count-1][6]
				$Scene_table_totale[$nb_totale_scene_record-1][7] = $obj_scene[$count-1][7]
				$Scene_table_totale[$nb_totale_scene_record-1][8] = $obj_scene[$count-1][8]
				$Scene_table_totale[$nb_totale_scene_record-1][9] = $obj_scene[$count-1][9]


			EndIf


		EndIf

	Next
	;################################################################################################


	Dim $list_sno_scene = IndexSNO(0x18EDF60,0)


	;############################## ITERATION DU SNO ################################################
	for $i=1 to Ubound($list_sno_scene) - 1
		$correlation = false
		$current_obj_scene = 0

			for $x=0 To Ubound($obj_scene)-1
				if $list_sno_scene[$i][1] = $obj_scene[$x][3] Then
					$correlation = true
					$current_obj_scene = $x
				EndIf
			Next

		if $correlation Then
			$NavMeshDef = $list_sno_scene[$i][0] + 0x040
			$NavZoneDef = $list_sno_scene[$i][0] + 0x280

			;############## ITERATION DES NAVCELL ################
			$CountNavCell = _memoryRead($NavZoneDef, $d3, "int")
			$NavCellPtr = _memoryRead($NavZoneDef + 0x08, $d3, "ptr")

			If $CountNavCell <> 0 Then
				Dim $Navcell_Table[$CountNavCell][9]
				Local $NavCellStruct = DllStructCreate("float;float;float;float;float;float;short;short;int")

				for $t=0 To $CountNavCell - 1

					DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $NavCellPtr + ($t * 0x20), 'ptr', DllStructGetPtr($NavCellStruct), 'int', DllStructGetSize($NavCellStruct), 'int', '')

					If Mod( DllStructGetData($NavCellStruct, 7) , 2) = 1 Then
						$flag = 1
					Else
						$flag = 0
					EndIf

					If Ubound($NavCell_table_totale) - 1 = 0 AND $up = false Then
						$up = true
					Else
						Redim $NavCell_table_totale[Ubound($NavCell_table_totale)+1][10]
					EndIF

					$num = Ubound($NavCell_table_totale)-1
					$NavCell_Table_Totale[$num][0] = DllStructGetData($NavCellStruct, 1)
					$NavCell_Table_Totale[$num][1] = DllStructGetData($NavCellStruct, 2)
					$NavCell_Table_Totale[$num][2] = DllStructGetData($NavCellStruct, 3)
					$NavCell_Table_Totale[$num][3] = DllStructGetData($NavCellStruct, 4)
					$NavCell_Table_Totale[$num][4] = DllStructGetData($NavCellStruct, 5)
					$NavCell_Table_Totale[$num][5] = DllStructGetData($NavCellStruct, 6)
					$NavCell_Table_Totale[$num][6] = $flag
					$NavCell_Table_Totale[$num][7] = DllStructGetData($NavCellStruct, 8)
					$NavCell_Table_Totale[$num][8] = DllStructGetData($NavCellStruct, 9)
					$NavCell_Table_Totale[$num][9] = $obj_scene[$current_obj_scene][0]
				Next
			Else

				For $a=0 to Ubound($Scene_table_id_scene) -1
					If $Scene_table_id_scene[$a] = $obj_scene[$current_obj_scene][0] Then
						_ArrayDelete($Scene_table_id_scene, $a)
						ExitLoop
					EndIF
				Next

				For $a=0 To Ubound($Scene_table_totale) - 1
					If $Scene_table_totale[$a][0] = $obj_scene[$current_obj_scene][0] Then
						_Array2DDelete($Scene_table_totale, $a)
						$nb_totale_scene_record -= 1
						ExitLoop
					EndIf
				Next

			EndIF

		EndIf
	Next

	_log("Ready to drawn")
	sleep(500)
WEnd

EndFunc


Func Drawn()
		_log("taille du tab Scene-> " & Ubound($Scene_table_totale))
		_log("taille du tab NavCell-> " & Ubound($NavCell_Table_Totale))
		;_ArrayDisplay($Scene_table_id_scene)
		Dim $buffMax[2] = [0, 0]
		Dim $buffMin[2] = [999999999, 99999999]
		Dim $indexMax[2] = [0, 0] ; 0 -> Index MeshMax X le plus grand | 1 -> Index MEshMax Y le plus grand
		Dim $indexMin[2] = [999999999, 99999999]

		For $i=0 To Ubound($Scene_table_totale) - 1
			if $buffMax[0] < $Scene_table_totale[$i][7] Then
				$buffMax[0] = $Scene_table_totale[$i][7]
				$indexMax[0] = $i
			EndIF

			if $buffMin[0] > $Scene_table_totale[$i][4] Then
				$buffMin[0] = $Scene_table_totale[$i][4]
				$indexMin[0] = $i
			EndIf


			If $buffMax[1] < $Scene_table_totale[$i][8] Then
				$buffMax[1] = $Scene_table_totale[$i][8]
				$indexMax[1] = $i
			EndIf

			if $buffMin[1] > $Scene_table_totale[$i][5] Then
				$buffMin[1] = $Scene_table_totale[$i][5]
				$indexMin[1] = $i
			EndIf
		Next

	Initiate_GDIpicture($Scene_table_totale[$indexMax[1]][8] - $Scene_table_totale[$indexMin[1]][5], $Scene_table_totale[$indexMax[0]][7] - $Scene_table_totale[$indexMin[0]][4])


	if StringLower($DrawNavCellWalkable) = "true" AND StringLower($DrawNavCellUnWalkable) = "true" Then
		Dim $Tab_temp = tri_flag()
		Dim $NavCell_Table_Totale = $Tab_temp
	EndIF

	for $i=0 To Ubound($Scene_table_totale) - 1
		for $y=0 To Ubound($NavCell_Table_Totale) - 1

			If $Scene_table_totale[$i][0] = $NavCell_Table_Totale[$y][9] Then

				$vx = ($Scene_table_totale[$i][4] - $Scene_table_totale[$indexMin[0]][4]) + $NavCell_Table_Totale[$y][0]
				$vy = ($Scene_table_totale[$i][5] - $Scene_table_totale[$indexMin[1]][5]) + $NavCell_Table_Totale[$y][1]


				$tx = $NavCell_Table_Totale[$y][3] - $NavCell_Table_Totale[$y][0]
				$ty = $NavCell_Table_Totale[$y][4] - $NavCell_Table_Totale[$y][1]
				$flag = $NavCell_Table_Totale[$y][6]

				if $flag = 1 AND StringLower($DrawNavCellWalkable) = "true" Then
					Draw_Nav($vy, $vx, $flag, $ty, $tx)
				ElseIf $flag = 0 AND StringLower($DrawNavCellUnWalkable) = "true" Then
					Draw_Nav($vy, $vx, $flag, $ty, $tx)
				EndIf


			EndIF
		Next

		If StringLower($DrawScene) = "true" Then
			Draw_Nav(($Scene_table_totale[$i][5] - $Scene_table_totale[$indexMin[1]][5]), ($Scene_table_totale[$i][4] - $Scene_table_totale[$indexMin[0]][4]), 3, $Scene_table_totale[$i][8] - $Scene_table_totale[$i][5], $Scene_table_totale[$i][7] - $Scene_table_totale[$i][4])
		EndIf
	Next

	Save_GDIpicture()
	_log("Map succefully drawn")
	exit 0
EndFunc

Func MarkPos()
	$currentloc = GetCurrentPos()
	ConsoleWrite($currentloc[0] & ", " & $currentloc[1] & ", " & $currentloc[2] & ",1,25" & @CRLF);
	$file = FileOpen( @scriptDir & "\" & $nameSequenceTxt & ".txt", 1)

	If $file = -1 Then
		_log("Enabled to open file, Script will shutdown")
		Exit
	EndIf
	$count_mtp+= 1

	FileWriteLine ($file, $currentloc[0] & "," & $currentloc[1] & "," & $currentloc[2] & ",1,25")
	FileClose($file)

	Redim $table_mtp[$count_mtp][5]
	$table_mtp[$count_mtp-1][0] = $currentloc[0]
	$table_mtp[$count_mtp-1][1] = $currentloc[1]
	$table_mtp[$count_mtp-1][2] = $currentloc[2]
	$table_mtp[$count_mtp-1][3] = 1
	$table_mtp[$count_mtp-1][4] = 25
EndFunc   ;==>MarkPos

Func tri_flag()

	dim $table_Walkable[1][10]
	dim $table_UnWalkable[1][10]
	local $count_walkable = 0
	local $count_Unwalkable = 0

	for $i=0 To Ubound($NavCell_Table_Totale) - 1
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
				$table_Walkable[$count_walkable-1][8] = $NavCell_Table_Totale[$i][8]
				$table_Walkable[$count_walkable-1][9] = $NavCell_Table_Totale[$i][9]
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
				$table_UnWalkable[$count_Unwalkable-1][8] = $NavCell_Table_Totale[$i][8]
				$table_UnWalkable[$count_Unwalkable-1][9] = $NavCell_Table_Totale[$i][9]
			EndIf
	Next
	for $i=0 to Ubound($table_Walkable) - 1
		$NavCell_Table_Totale[$i][0] = $table_Walkable[$i][0]
		$NavCell_Table_Totale[$i][1] = $table_Walkable[$i][1]
		$NavCell_Table_Totale[$i][2] = $table_Walkable[$i][2]
		$NavCell_Table_Totale[$i][3] = $table_Walkable[$i][3]
		$NavCell_Table_Totale[$i][4] = $table_Walkable[$i][4]
		$NavCell_Table_Totale[$i][5] = $table_Walkable[$i][5]
		$NavCell_Table_Totale[$i][6] = $table_Walkable[$i][6]
		$NavCell_Table_Totale[$i][7] = $table_Walkable[$i][7]
		$NavCell_Table_Totale[$i][8] = $table_Walkable[$i][8]
		$NavCell_Table_Totale[$i][9] = $table_Walkable[$i][9]
	Next
	for $i=0 To Ubound($table_UnWalkable) - 1
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][0] = $table_UnWalkable[$i][0]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][1] = $table_UnWalkable[$i][1]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][2] = $table_UnWalkable[$i][2]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][3] = $table_UnWalkable[$i][3]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][4] = $table_UnWalkable[$i][4]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][5] = $table_UnWalkable[$i][5]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][6] = $table_UnWalkable[$i][6]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][7] = $table_UnWalkable[$i][7]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][8] = $table_UnWalkable[$i][8]
		$NavCell_Table_Totale[Ubound($table_Walkable) + $i][9] = $table_UnWalkable[$i][9]
	Next

	return $NavCell_Table_Totale
EndFunc

HotKeySet("{F1}", "Read_Scene")
HotKeySet("{F2}", "Drawn")
HotKeySet("{ù}", "MarkPos")

 Load_Configs()


while 1
	Sleep(50)
Wend