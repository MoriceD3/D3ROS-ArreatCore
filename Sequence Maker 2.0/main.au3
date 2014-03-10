#include <math.au3>
#include <String.au3>
#include <Array.au3>

;$RegAsm = "C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe" ; check the path of your version
;RunWait($RegAsm & " /codebase RecastDetourInterop.dll", @ScriptDir, @SW_HIDE) ; register the .net DLL

Global $Scene_table_totale[1][8]
Global $NavCell_table_totale[1][8]

Global $profilFile = "settings.ini"

Global $nameSequenceTxt = "sequence"
Global $PictureScene = "pictureScene"
Global $Picturemtp = "picturemtp"
Global $nameObjectListTxt = "ObjectList"

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

Global $Buff_MeshMinX = 999999
Global $Buff_MeshMinY = 999999
Global $Buff_MeshMaxX = 0
Global $Buff_MeshMaxY = 0

Global $Iterate_Objet[1]

Global $Count_path = 0
Global $Result_Path[1][3]

;Global $Count_Addsquare = 1
;Global $NavCell_PathFinding[1][4]
;Global $obj = ObjCreate("RecastDetourInterop.RecastDetourClass")

#include "Creat_Sequence.au3"
#include "Gdi_Draw.au3"



Func IterateObj()
	offsetlist()
	_log("Iterate Object Start")
	While 1
		Local $index, $offset, $count, $item[10]
			startIterateObjectsList($index, $offset, $count)
			Dim $item_buff_2D[1][10]
			Local $i = 0
			$compt = 0
			$file = FileOpen( @scriptDir & "\"&$nameObjectListTxt&".txt", 1)

			If $file = -1 Then
				_log("Enabled to open file, Script will shutdown")
				Exit
			EndIf
			
			$rules_name = "(?i)([a-zA-Z0-9_]*)"
			
			While iterateObjectsList($index, $offset, $count, $item)
				
				If StringRegExp($item[1], $rules_name) = 1 Then ;patern declaration ilvl
					$name_item = StringRegExp($item[1], $rules_name, 2)
					
					$exist = false
					for $i=0 To Ubound($Iterate_Objet) - 1
						
						if StringInStr($Iterate_Objet[$i], $name_item[1], 2) Then
						;if $Iterate_Objet[$i] = $name_item[1] Then
							$exist = true
							ExitLoop
						EndIf
					Next
					
					if $exist = false Then
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

Func Read_Scene()
	_log("Lancement lecture scene")
	$nb_totale_scene_record = 0
	$nb_totale_navcell_record = 0
	$up = false
	Local $first_iteration_NavCell = true

	offsetlist()

	$ObManStoragePtr = _MemoryRead($ofs_objectmanager, $d3, "ptr")
	$offset = $ObManStoragePtr + 0x794 + 0x178
	$sceneCountPtr = _MemoryRead($offset, $d3, "ptr") + 0x108
	$sceneFirstPtr = _MemoryRead($offset, $d3, "ptr") + 0x148
	;$walkable = 0



	;$obj.Init
	;$obj.SetCellSize(2.5)

While 1
	;mesureStart()

	$countScene = _MemoryRead($sceneCountPtr, $d3, "int")


	Dim $obj_scene[1][10]
	Local $count = 0

	Local $New_scene_record = false


	;_log($sceneFirstPtr)
	;################################## ITERATION OBJ SCENE ########################################
	for $i=0 to $countScene
		
		$scenePtr = _MemoryRead($sceneFirstPtr, $d3, "ptr") + ($i * 0x2A8)

		$Structobj_scene = DllStructCreate("ptr;byte[4];ptr;byte[208];ptr;byte[16];float;float;byte[112];float;float")


		;id_scene -> 1 | id_world -> 3 | id_sno_scene -> 5 | MeshMinX -> 7 | MeshMinY -> 8 | MeshMaxX -> 10 | MeshMaxY -> 11

		DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $scenePtr, 'ptr', DllStructGetPtr($Structobj_scene), 'int', DllStructGetSize($Structobj_scene), 'int', '')

		$correlation = true



		If DllStructGetData($Structobj_scene, 3) = $_MyACDWorld AND DllStructGetData($Structobj_scene, 1) <> 0xFFFFFFFF Then ;id world
			
			;_log("scene valide N°" & $i & " ACDWorld - > " & DllStructGetData($Structobj_scene, 3) & " Id World -> " &  DllStructGetData($Structobj_scene, 1))
			
				

				For $x=0 To Ubound($Scene_table_totale) - 1
					If $Scene_table_totale[$x][3] = DllStructGetData($Structobj_scene, 7) AND $Scene_table_totale[$x][4] = DllStructGetData($Structobj_scene, 8) AND $Scene_table_totale[$x][2] = DllStructGetData($Structobj_scene, 5) Then
						$correlation = false
					EndIf
				Next

				If $correlation = true Then
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
		EndIF

	Next
	;################################################################################################
	;_arraydisplay($Scene_table_totale)
	If $New_scene_record = True Then ;Si Une nouvelle scene à etait enregistrer
		
		;_arraydisplay($Scene_table_totale)
		;exit

		Dim $list_sno_scene = IndexSNO(0x18F0F88,0)
		;_arraydisplay($list_sno_scene)


		;############################## ITERATION DU SNO ###########################################
		for $i=1 to Ubound($list_sno_scene) - 1
			$correlation = false
			$current_obj_scene = 0

				for $x=0 To Ubound($Scene_table_totale)-1
					if $list_sno_scene[$i][1] = $Scene_table_totale[$x][2] AND $Scene_table_totale[$x][7] = false Then
						$correlation = true
						$current_scene = $x
						;_log("Correlation trouver pour la scene ->" & $current_scene)
						exitloop
					EndIf
				Next


			if $correlation = true Then
				$NavMeshDef = $list_sno_scene[$i][0] + 0x040
				$NavZoneDef = $list_sno_scene[$i][0] + 0x280

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

							for $t=0 To $CountNavCell - 1
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
		
		_log("Scene Iterate")
		;PathFinding_Build($NavCell_PathFinding)

	EndIf

		;mesureEnd("Iteration Scene/NavCell")
		;_log("Ready to drawn")
		sleep(200)

WEnd

EndFunc

Func PathFinding_Init()

EndFunc

#cs
Func PathFinding_Build($NavCell_Table)
	MesureStart()

		For $i=0 To Ubound($NavCell_Table) - 1
			$obj.AddVertex($NavCell_Table[$i][0] - $buff_MeshMinX, $NavCell_Table[$i][2] - $buff_MeshMinY, 0)
			$obj.AddVertex($NavCell_Table[$i][0] - $buff_MeshMinX, $NavCell_Table[$i][3] - $buff_MeshMinY, 0)
			$obj.AddVertex($NavCell_Table[$i][1] - $buff_MeshMinX, $NavCell_Table[$i][3] - $buff_MeshMinY, 0)
			$obj.AddVertex($NavCell_Table[$i][1] - $buff_MeshMinX, $NavCell_Table[$i][2] - $buff_MeshMinY, 0)
			$obj.AddSquare($Count_Addsquare, $Count_Addsquare + 1, $Count_Addsquare + 2, $Count_Addsquare + 3)
			$Count_Addsquare += 4
		Next

	_log($obj.build)

	MesureEnd("Build de la map")
EndFunc
#ce

#cs
Func PathFinding_MakePath(byref $startX,byref $startY,byref $startZ,byref $endX, byref $endY, byref $endZ)

	Dim $My_point = $obj.Path($startX - $buff_MeshMinX, $startY - $buff_MeshMinY, 0, $endX - $buff_MeshMinX, $endY - $buff_MeshMinY, 0)

	Redim $Result_Path[Ubound($My_point) / 3][3]

	For $i=1 To Ubound($My_point) step 3
		_log($i)
		$Result_Path[$Count_path][0] = $My_point[$i-1]
		$Result_Path[$Count_path][1] = $My_point[$i]
		$Result_Path[$Count_path][2] = $My_point[$i+1]
		$Count_path += 1
	Next

	return $Result_Path
EndFunc
#ce

Func Drawn()
		_log("taille du tab Scene-> " & Ubound($Scene_table_totale))
		_log("taille du tab NavCell-> " & Ubound($NavCell_Table_Totale))

	Initiate_GDIpicture($Buff_MeshMaxY - $Buff_MeshMinY, $Buff_MeshMaxX - $Buff_MeshMinX)

	_log($Buff_MeshMaxY - $Buff_MeshMinY & " - " & $Buff_MeshMaxX - $Buff_MeshMinX)
	_log(" MaxY : " & $Buff_MeshMaxY & " MinY : " & $Buff_MeshMinY & " MaxX : " & $Buff_MeshMaxX & " MinX : " & $Buff_MeshMinX)

	if StringLower($DrawNavCellWalkable) = "true" AND StringLower($DrawNavCellUnWalkable) = "true" Then
		Dim $Tab_temp = tri_flag()
		Dim $NavCell_Table_Totale = $Tab_temp
	EndIF

	for $i=0 To Ubound($Scene_table_totale) - 1
		
		for $y=0 To Ubound($NavCell_Table_Totale) - 1

			If $Scene_table_totale[$i][0] = $NavCell_Table_Totale[$y][7] Then

				$vx = ($Scene_table_totale[$i][3] - $buff_MeshMinX) + $NavCell_Table_Totale[$y][0]
				$vy = ($Scene_table_totale[$i][4] - $buff_MeshMinY) + $NavCell_Table_Totale[$y][1]


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

	dim $table_Walkable[1][8]
	dim $table_UnWalkable[1][8]
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
	for $i=0 to Ubound($table_Walkable) - 1
		$NavCell_Table_Totale[$i][0] = $table_Walkable[$i][0]
		$NavCell_Table_Totale[$i][1] = $table_Walkable[$i][1]
		$NavCell_Table_Totale[$i][2] = $table_Walkable[$i][2]
		$NavCell_Table_Totale[$i][3] = $table_Walkable[$i][3]
		$NavCell_Table_Totale[$i][4] = $table_Walkable[$i][4]
		$NavCell_Table_Totale[$i][5] = $table_Walkable[$i][5]
		$NavCell_Table_Totale[$i][6] = $table_Walkable[$i][6]
		$NavCell_Table_Totale[$i][7] = $table_Walkable[$i][7]
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
	Next

	return $NavCell_Table_Totale
EndFunc

Func Terminate()
	Exit
EndFunc

Func mesureStart()
	Global $mesuredebug = TimerInit() ;;;;;;;;;;;;;;
	$init = TimerInit()
EndFunc   ;==>mesureStart

Func mesureEnd($nom)
	Local $difmesuredebug = TimerDiff($mesuredebug) ;;;;;;;;;;;;;
	ConsoleWrite("Mesure " & $nom & " : " & $difmesuredebug & @CRLF) ;FOR DEBUGGING;;;;;;;;;;;;
EndFunc   ;==>mesureEnd

$oMyError = ObjEvent("AutoIt.Error","MyErrFunc")    ; Initialize a COM error handler
; This is my custom defined error handler
Func MyErrFunc()
  Msgbox(0,"AutoItCOM Test","We intercepted a COM Error !"    & @CRLF  & @CRLF & _
             "err.description is: " & @TAB & $oMyError.description  & @CRLF & _
             "err.windescription:"   & @TAB & $oMyError.windescription & @CRLF & _
             "err.number is: "       & @TAB & hex($oMyError.number,8)  & @CRLF & _
             "err.lastdllerror is: "   & @TAB & $oMyError.lastdllerror   & @CRLF & _
             "err.scriptline is: "   & @TAB & $oMyError.scriptline   & @CRLF & _
             "err.source is: "       & @TAB & $oMyError.source       & @CRLF & _
             "err.helpfile is: "       & @TAB & $oMyError.helpfile     & @CRLF & _
             "err.helpcontext is: " & @TAB & $oMyError.helpcontext _
            )
Endfunc

HotKeySet("{F1}", "Read_Scene")
HotKeySet("{F2}", "Drawn")
HotKeySet("{F3}", "IterateObj")
HotKeySet("{F4}", "Terminate")
HotKeySet("{ù}", "MarkPos")

 Load_Configs()


while 1
	Sleep(50)
Wend