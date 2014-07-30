#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "usePath.au3"

Global $sequence_save = 0
Global $autobuff = False
Global $reverse = 0

Func GetActiveQuest()
	$QuestMan_A = 0x8b8
	$QuestMan_B = 0x1c

	$_itrQuestManA   = _MemoryRead($_itrObjectManagerA + $QuestMan_A, $d3, 'ptr')
	$_Curr_Quest_Ofs = _MemoryRead($_itrQuestManA + $QuestMan_B, $d3, 'ptr')

	While $_Curr_Quest_Ofs <> 0
		$Quest_ID = _MemoryRead($_Curr_Quest_Ofs , $d3, 'int')
		$Quest_State = _MemoryRead($_Curr_Quest_Ofs + 0x14 , $d3, 'int')

		If $Quest_State = 1 And $Quest_ID <> 0x4C46D And StringInStr($BountyQuestIDs, $Quest_ID, 2) Then
			; Check AreaId to trash started unfinished quest
			; Will need refresh until we actually get to the area since bounty may fit under multiple ones
			If (_MemoryRead($_Curr_Quest_Ofs + 0x8 , $d3, 'int') == GetLevelAreaId()) Then
				_log("Active questID : " & $Quest_ID)
				$ActiveQuest = $Quest_ID
			EndIf
		EndIf
		$_Curr_Quest_Ofs = _MemoryRead( $_Curr_Quest_Ofs + 0x168, $d3, 'ptr')
	Wend
EndFunc ;==> GetActiveQuest

Func IsQuestFinished($QuestId)
	If $QuestId = -1 Then
		GetActiveQuest()
		Return False
	EndIf

	$QuestMan_A = 0x8b8
	$QuestMan_B = 0x1c

	$_itrQuestManA   = _MemoryRead($_itrObjectManagerA + $QuestMan_A, $d3, 'ptr')
	$_Curr_Quest_Ofs = _MemoryRead($_itrQuestManA + $QuestMan_B, $d3, 'ptr')

	While $_Curr_Quest_Ofs <> 0
		$Quest_ID = _MemoryRead($_Curr_Quest_Ofs , $d3, 'int')
		$Quest_State = _MemoryRead($_Curr_Quest_Ofs + 0x14 , $d3, 'int')
		If $Quest_State > 1 And $Quest_ID = $QuestId Then
			_log("Quest completed : " & $QuestId & "(" & $Quest_State & ")")
			$ActiveQuest = -1
			Return True
		EndIf
		$_Curr_Quest_Ofs = _MemoryRead( $_Curr_Quest_Ofs + 0x168, $d3, 'ptr')
	Wend
	Return False
EndFunc ;==> IsQuestFinished

Func GetBountySequences($Table_BountyAct)
	If Not IsArray($Table_BountyAct) Then
		Return False
	EndIf
	If UBound($Table_BountyAct) = 0 Then
		Return False
	EndIf

	Local $hTimer = TimerInit()
	While Not offsetlist() And TimerDiff($hTimer) < 60000
		Sleep(40)
	WEnd

	If TimerDiff($hTimer) >= 60000 Then
		Return False
	EndIf

	$snoSequencelist = FileRead("sequence\_sno_sequences.txt")

	$QuestMan_A = 0x8b8
	$QuestMan_B = 0x1c

	$_itrQuestManA   = _MemoryRead($_itrObjectManagerA + $QuestMan_A, $d3, 'ptr')
	$_Curr_Quest_Ofs = _MemoryRead($_itrQuestManA + $QuestMan_B, $d3, 'ptr')
	$SeqList = ""
	$acts = _ArrayToString($Table_BountyAct,"|")

	While $_Curr_Quest_Ofs <> 0
		$Quest_ID = _MemoryRead($_Curr_Quest_Ofs , $d3, 'int')
		$Quest_Area_ID = _MemoryRead($_Curr_Quest_Ofs + 0x8 , $d3, 'int')
		$Quest_State = _MemoryRead($_Curr_Quest_Ofs + 0x14 , $d3, 'int')

		If $Quest_State = 0 And $Quest_ID <> 0x4C46D Then
			Local $pattern = $Quest_ID & "#[\d\w]*#(\d)#([\w_]*)#(.*)"
			$asResult = StringRegExp($snoSequencelist, $pattern, 1)
			If Not @error Then
				If StringInStr($acts, $asResult[0], 2) Then
					If $asResult[2] <> "" And $asResult[2] <> "None" Then
						If $SeqList = "" Then
							$SeqList = $asResult[2]
						Else
							$SeqList = $SeqList & "|" & $asResult[2]
						EndIf
						$BountyQuestIDs = $BountyQuestIDs & "|" & $Quest_ID
						_log("Bounty with sequence : " & $asResult[1] & " -> " & $asResult[2], $LOG_LEVEL_VERBOSE)
					Else
						_log("Bounty without sequence : " & $asResult[1], $LOG_LEVEL_WARNING)
					EndIf
				EndIf
			Else
				_log("Unknown bounty : " & $Quest_ID)
			EndIf
		EndIf
		$_Curr_Quest_Ofs = _MemoryRead( $_Curr_Quest_Ofs + 0x168, $d3, 'ptr')
	Wend

	If $SeqList = "" Then
		If $NoBountyFailbackToAdventure Then
			_log("No supported sequences found !, Loading adventure ones", $LOG_LEVEL_WARNING)
			Return $SequenceFileAdventure
		Else
			_log("No supported sequences found !, Ending run", $LOG_LEVEL_WARNING)
			Return False
		EndIf
	Else
		If $BountyAndSequence And $PauseAfterBounty Then
			Local $TabAdventure = StringSplit($SequenceFileAdventure,"|")
			For $i = 1 To $TabAdventure[0]
			   If StringInStr($SeqList,$TabAdventure[$i],0) = 0 Then
				  $SeqList = $SeqList & "|" & $TabAdventure[$i]
			   EndIf
			Next
		 EndIf
		_log("Sequence generated : " & $Seqlist, $LOG_LEVEL_VERBOSE)
		Return $SeqList
	EndIf
Endfunc ;==> GetBountySequences

Func TraitementSequence(ByRef $arr_sequence, $index, $mvtp = 0)
	If $arr_sequence[$index][0] = 2 And $mvtp = 1 Then
		movetopos($arr_sequence[$index][1], $arr_sequence[$index][2], $arr_sequence[$index][3], $arr_sequence[$index][4], $arr_sequence[$index][5])
		$looking = LookForObjects()
		If Not $looking = False Then
			Return $looking
		EndIf
		If $EndSequenceOnBountyCompletion Then
			If $Choix_Act_Run = -3 Then
				If IsQuestFinished($ActiveQuest) Then
					_log("Bounty completed : Waiting a little for loots then end sequence", $LOG_LEVEL_WARNING)
					Sleep(1000)
					Attack()
					Sleep(1000)
					Attack()
					Return "endsequence()"
				EndIf
			EndIf
		EndIf
	Else
		If $arr_sequence[$index][1] = "sleep" Then
			_log("Sleep : " & $arr_sequence[$index][2])
			Sleep($arr_sequence[$index][2])
		ElseIf $arr_sequence[$index][1] = "InteractWithActor" Then
			_log("Start : InteractWithActor " & $arr_sequence[$index][2], $LOG_LEVEL_DEBUG)
			InteractByActorName($arr_sequence[$index][2])
		ElseIf $arr_sequence[$index][1] = "InteractWithDoor" Then
			_log("Start : InteractWithDoor " & $arr_sequence[$index][2], $LOG_LEVEL_DEBUG)
			InteractWithDoor($arr_sequence[$index][2])
		ElseIf $arr_sequence[$index][1] = "InteractWithPortal" Then
			_log("Start : InteractWithPortal " & $arr_sequence[$index][2], $LOG_LEVEL_DEBUG)
			InteractWithPortal($arr_sequence[$index][2])
			GetActiveQuest()
		ElseIf $arr_sequence[$index][1] = "buffinit" Then
			_log("Buffinit sequence", $LOG_LEVEL_DEBUG)
			BuffInit()
		ElseIf $arr_sequence[$index][1] = "unbuff" Then
			_log("Unbuff sequence", $LOG_LEVEL_DEBUG)
			Unbuff()
		ElseIf $arr_sequence[$index][1] = "send" Then
			_log("Send : " & $arr_sequence[$index][2])
			Send($arr_sequence[$index][2])
		ElseIf $arr_sequence[$index][1] = "closewindows" Then
			_log("Close Windows", $LOG_LEVEL_DEBUG)
			Send($KeyCloseWindows)
		ElseIf $arr_sequence[$index][1] = "closeconfirm" Then
			_log("Close Confirm", $LOG_LEVEL_DEBUG)
			ClickUI("Root.TopLayer.confirmation.subdlg.stack.wrap.button_ok", 2014)
		ElseIf $arr_sequence[$index][1] = "takewp" Then
			_log("Start : TakeWP", $LOG_LEVEL_DEBUG)
			TakeWPV3($arr_sequence[$index][2], 0)
			GetActiveQuest()
		ElseIf $arr_sequence[$index][1] = "takewpadv" Then
			_log("Start : TakeWPADV", $LOG_LEVEL_DEBUG)
			TakeWPV3($arr_sequence[$index][2], 1)
			GetActiveQuest()
		ElseIf $arr_sequence[$index][1] = "_townportal" Then
			_log("Start : TownPortal", $LOG_LEVEL_DEBUG)
			If Not _TownPortalnew() Then
				$GameFailed = 2
				Return False
			EndIf
		ElseIf $arr_sequence[$index][1] = "offsetlist" Then
			While Not offsetlist()
				Sleep(40)
			WEnd
		EndIf
	EndIf
	Return False
EndFunc   ;==>TraitementSequence

Func _playerdead_revive()
	If ($ResActivated) Then
		If $nb_die_t > $rdn_die_t Then ;Si on a deja depassé le nombre de revive autorisé, on renvoie forcement false, pour donner la main au reste du code
			Return False
		EndIf
		$playerdeadlookfor = "NormalLayer.deathmenu_dialog"
		$return = fastcheckuiitemvisible($playerdeadlookfor, 1, 793)
		Return $return
	EndIf
	Return False
EndFunc   ;==>_playerdead_revive

Func init_sequence()
	$nb_die_t = 0
	$rdn_die_t = $ResLife + Random(-1, 1, 1)
	_log("New sequence, max death allowed :" & $rdn_die_t, $LOG_LEVEL_DEBUG)
EndFunc   ;==>init_sequence

Func revive(ByRef $path)

;Return 0 -> Pas Mort
;Return 1 -> Revive At Corp
;Return 2 -> Revive On Last CheckPoint
;Return 3 -> Trop de Res on return ville puis leave

	;VERIFIER QUE LE STUFF EST PAS JAUNE OU ROUGE

	If _playerdead_revive() Then
		MouseUp($MouseMoveClick)
		$nb_die_t = $nb_die_t + 1
		$Res_compt = $Res_compt + 1
		_log("You are dead, max : " & $rdn_die_t - $nb_die_t & " more death allowed", $LOG_LEVEL_WARNING)

		If $ActivateChat Then WriteMe($WRITE_ME_DEATH) ; TChat

		If $nb_die_t <= $rdn_die_t And Not _checkRepair() Then
			Sleep(Random(5000, 6000))
			If Not _checkRepair() Then
				If fastcheckuiitemactived("Root.NormalLayer.deathmenu_dialog.dialog_main.button_revive_at_corpse", 139) Then
					ClickUI("Root.NormalLayer.deathmenu_dialog.dialog_main.button_revive_at_corpse", 139)
					_log("Res At Corp and buffinit", $LOG_LEVEL_VERBOSE)
					Sleep(Random(8000, 8500))
					buffinit()
					Return 1
				Else ;On ne peut pas revive sur le corp
					ClickUI("Root.NormalLayer.deathmenu_dialog.dialog_main.button_revive_at_checkpoint", 820)
					_log("Res At Last CheckPoint", $LOG_LEVEL_VERBOSE)
					Sleep(Random(750, 1000))
					bloc_sequence($path, 1)
					Return 2 ;on res
				EndIf
			EndIF
		Else
			_log("You have reached the max number of revive : " & $rdn_die_t & " Or your stuff is destroyed", $LOG_LEVEL_WARNING)
			Sleep(Random(5000, 6000))
			ClickUI("Root.NormalLayer.deathmenu_dialog.dialog_main.button_revive_in_town", 496)
			Sleep(4000)
			Return 3
		EndIf
	EndIf
	Return 0
EndFunc   ;==>revive

Func reverse_arr(ByRef $arr_MTP)
	_log("Taille de l'array reverse : " & UBound($arr_MTP))
	Dim $arr_reverse[UBound($arr_MTP)][6]
	Local $compt_x = 0
	Local $compt_i = 0

	If $reverse = 1 Then
		Local $reverse_rnd = Random(0, 1, 1)
		If ($reverse_rnd = 1) Then
			_log("Reverse array")
			For $i = UBound($arr_MTP) To 1 Step -1
				For $x = 0 To 5
					$arr_reverse[$compt_i][$compt_x] = $arr_MTP[$i - 1][$x]
					$compt_x += 1
				Next
				$compt_x = 0
				$compt_i += 1
			Next
			$reverse = 0
			Return $arr_reverse
		Else
			$reverse = 0
			Return $arr_MTP
		EndIf
	Else
		$reverse = 0
		Return $arr_MTP
	EndIf
EndFunc   ;==>reverse_arr

Func bloc_sequence(ByRef $arr_MTP, $revive = 0)
	If _checkRepair() Then
		unbuff()
		tpRepairAndBack()
		buffinit()
		_log("buffinit post repair")
	EndIf

	If $revive = 1 Then
		Sleep(Random(2500, 3500))
		buffinit()
		_log("buffinit post death")
	EndIf

	$result = False
	If IsArray($arr_MTP) Then
		If $UsePath Then
			$result = UsePath($arr_MTP)
		Else
			For $i = 0 To UBound($arr_MTP, 1) - 1
				If $arr_MTP[$i][0] <> 0 Then
					$result = TraitementSequence($arr_MTP, $i, 1)
					If Not $result = False Then
						Return $result
					EndIf
					If revive($arr_MTP) Then
						Return
					EndIf
				EndIf
			Next
		EndIf
	Else
		_log("Invalid sequence array argument", $LOG_LEVEL_ERROR)
	EndIf
	Return $result
EndFunc   ;==>bloc_sequence

Func SendSequence(ByRef $arr_sequence)
	If $sequence_save = 1 Then
		; ON ENVOIT ICI L'ARRAY A LA FONCTION DE DEPLACEMENT
		$arr_sequence = reverse_arr($arr_sequence)
		;**TEMPORAIRE**
		$result = bloc_sequence($arr_sequence)
		If Not $result = False Then
			_log("Object found or quest completed and command is : " & $result, $LOG_LEVEL_ERROR)
			If StringInStr($result, "loadsequence=", 2) Then
				$temp = StringReplace($result, "loadsequence=", "")
				_log("Lancement de la sequence : " & $temp, $LOG_LEVEL_WARNING)
				Sequence($temp)
			ElseIf StringInStr($result, "endsequence()", 2) Then
				_log("End sequence detected. Stopping current sequence file.", $LOG_LEVEL_WARNING)
			ElseIf StringInStr($result, "terminate()", 2) Then
				_log("Terminate detected. Stopping script!.", $LOG_LEVEL_ERROR)
			Else
				_log("Invalid command found for ifobjectfound")
			EndIf
			Return False
		EndIf
		;**TEMPORAIRE**
		If $autobuff Then
			Sleep(500)
			unbuff()
			_log("Enclenchement auto du unbuff()", $LOG_LEVEL_DEBUG)
		EndIf
	EndIf
	$sequence_save = 0
	Return True
EndFunc   ;==>SendSequence

Func ArrayUp(ByRef $array_sequence)
	If Not $sequence_save = 0 Then
		ReDim $array_sequence[UBound($array_sequence) + 1][6]
	EndIf
	$sequence_save = 1
	Return $array_sequence
EndFunc   ;==>ArrayUp

Func ArrayInit(ByRef $array_sequence)
	Dim $array_sequence[1][6]
	$sequence_save = 0
	Return $array_sequence
EndFunc   ;==>ArrayInit

Func attackRange($String)
    If Not $String = "" Then
        $a_range = Round($String)
        _log("Modification de la valeur attackRange : " & $a_range, $LOG_LEVEL_VERBOSE)
    EndIf
EndFunc ;==>valeur attackRange

Func SpecialML($String)
	If Not $String = "" Then
		$List_SpecialMonster = $String
		_log("Remplacement de la SpecialMonsterlist : " & $List_SpecialMonster, $LOG_LEVEL_VERBOSE)
		LoadTableFromString($Table_SpecialMonster, $List_SpecialMonster) ; Chargement de la nouvelle table
	EndIf
EndFunc   ;==>SpecialMonsterList

Func Trim($String)
	Return StringReplace($String, " ", "", 0, 2)
EndFunc   ;==>Trim

Func MonsterList($String)
	If Not $String = "" Then
		$List_Monster = $String
		_log("Remplacement de la MonsterList : " & $List_Monster, $LOG_LEVEL_VERBOSE)
		LoadTableFromString($Table_Monster, $List_Monster) ; Chargement de la nouvelle table
	EndIf
EndFunc   ;==>MonsterList

Func BanList($String)
	If Not $String = "" Then
		$Temp = $List_BanMonster & "|" & $String
		_log("Ajout d'une nouvelle BanList : " & $Temp, $LOG_LEVEL_VERBOSE)
		LoadTableFromString($Table_BanMonster, $Temp) ; Chargement de la nouvelle table
	EndIf
EndFunc   ;==>BanList

Func ChestList($String)
	If Not $String = "" Then
		$List_Coffre = $String
		_log("Remplacement de la ChestList : " & $List_Coffre, $LOG_LEVEL_VERBOSE)
		LoadTableFromString($Table_Coffre, $List_Coffre) ; Chargement de la nouvelle table
	EndIf
EndFunc   ;==>ChestList

Func RackList($String)
	If Not $String = "" Then
		$List_Rack = $String
		_log("Remplacement de la RackList : " & $List_Rack, $LOG_LEVEL_VERBOSE)
		LoadTableFromString($Table_Rack, $List_Rack) ; Chargement de la nouvelle table
	EndIf
EndFunc   ;==>RackList

Func DecorList($String)
	If Not $String = "" Then
		$List_Decor = $String
		_log("Remplacement de la DecorList : " & $List_Decor, $LOG_LEVEL_VERBOSE)
		LoadTableFromString($Table_Decor, $List_Decor) ; Chargement de la nouvelle table
	EndIf
EndFunc   ;==>DecorList

Func MaxGameLength($String)
	If Not $String = "" Then
		$maxgamelength = $String
		_log("Ajout d'un nouveau MaxGameLength : " & $maxgamelength, $LOG_LEVEL_VERBOSE)
	EndIf
EndFunc   ;==>MaxGameLength

Func Comment($String)
	If StringInStr($String, "//", 2) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>Comment

Func traitement_read_str($txt)
	Dim $txt_arr[1]
	Dim $txt_arr_final[1]
	Local $compt = 0

	ReDim $txt_arr[UBound(StringSplit($txt, "|", 2))]
	$txt_arr = StringSplit($txt, "|", 2)

	For $i = 0 To UBound($txt_arr) - 1

		If StringRegExp($txt_arr[$i], '\[([0-9]{1,3})/([0-9]{1,3})\]') = 1 Then ;patern random chance
			$arr_traitement_random_inclut = StringRegExp($txt_arr[$i], '\[([0-9]{1,3})/([0-9]{1,3})\]', 2)
			$num = Random(1, $arr_traitement_random_inclut[2], 1)
			If $num <= $arr_traitement_random_inclut[1] Then
				$txt_arr[$i] = StringReplace($txt_arr[$i], $arr_traitement_random_inclut[0], "", 0, 2)
			Else
				$txt_arr[$i] = ""
			EndIf
		EndIf

		If StringRegExp($txt_arr[$i], '\[([0-9]{1,3})-([0-9]{1,3})\]') = 1 Then ;patern random number
			$arr_traitement_num = StringRegExp($txt_arr[$i], '\[([0-9]{1,3})-([0-9]{1,3})\]', 2)
			$num = Random($arr_traitement_num[1], $arr_traitement_num[2], 1)
			$txt_arr[$i] = StringReplace($txt_arr[$i], $arr_traitement_num[0], "", 0, 2) & $num
		EndIf

		If Not $txt_arr[$i] = "" Then
			$compt += 1
			ReDim $txt_arr_final[$compt]
			$txt_arr_final[$compt - 1] = $txt_arr[$i]
		EndIf

	Next

	Return $txt_arr_final
EndFunc   ;==>traitement_read_str


Func LookForObjects()
	If Not $SearchForObject Then
		Return False
	EndIf

	Local $index, $offset, $count
	startIterateObjectsList($index, $offset, $count)

	Dim $item[$TableSizeGuidStruct + 1]

	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')
	If @error > 0 Then
		Return False
	EndIf

	$CurrentLoc = GetCurrentPos()
	$SearchCount = UBound($Table_SearchObject) - 1
	For $i = 0 To $count
		If GetItemFromObjectsList($item, $iterateObjectsListStruct, $offset, $i, $CurrentLoc) Then
			For $z = 0 To $SearchCount
				If $item[9] > $Table_SearchObject[$z][1] Then
					ContinueLoop
				EndIf
				If StringInStr($item[1], $Table_SearchObject[$z][0], 2) Then
					Return $Table_SearchObject[$z][2]
				EndIf
			Next
		EndIf
	Next

	Return False
EndFunc


Func sequence($sequence_list)

	Dim $filetoarray[1]
	Local $load_file = ""
	Local $end_game = False

	;	If (StringInStr($File_Sequence, "|", 2)) Then
	;		ReDim $filetoarray[UBound(StringSplit($File_Sequence, "|", 2))]
	;		$filetoarray = StringSplit($File_Sequence, "|", 2)
	;	Else
	;		$filetoarray[1] = $File_Sequence
	;	EndIf

	$filetoarray = traitement_read_str($sequence_list)

	For $z = 0 To UBound($filetoarray) - 1

		Local $noblocline = 0
		Local $old_ResActivated = $ResActivated
		Local $old_UsePath = $UsePath
		Local $old_TakeShrines = $TakeShrines
		Local $old_Attackrange = $a_range
		Local $old_Table_SpecialMonster = $Table_SpecialMonster
		Local $old_Table_Decor = $Table_Decor
		Local $old_Table_Coffre = $Table_Coffre
		Local $old_Table_Rack = $Table_Rack

		init_sequence()

		$autobuff = $ShouldPreBuff

		Local $compt_line = 0
		Dim $txttoarray[1]

		If StringInStr($filetoarray[$z], "[CMD]", 2) = 1 Then ;Detection d'une commande
			$txttoarray[0] = trim(StringLower(StringReplace($filetoarray[$z], "[CMD]", "", 0, 2)))
		Else
			$load_file = "sequence\" & $filetoarray[$z] & ".txt"
			_log("File loaded : " & $load_file, $LOG_LEVEL_VERBOSE)

			Local $file = FileOpen($load_file, 0)
			If $file = -1 Then
				MsgBox(0, "Error", "Unable to open file : " & $load_file)
				Exit
			EndIf

			While 1 ;Boucle de traitement de lecture du fichier txt
				$line = FileReadLine($file)
				If @error = -1 Then ExitLoop

				If $line <> "" Then
					$line = trim(StringLower($line))
					ReDim $txttoarray[$compt_line + 1]
					$txttoarray[$compt_line] = $line
					$compt_line += 1
				EndIf
			WEnd
			FileClose($file)
		EndIf

		Dim $array_sequence[1][6]
		$sequence_save = 0
		Local $end_sequence = False
		$SearchForObject = False
		$Table_SearchObject = False
		$TotalSequences += 1

		For $i = 0 To UBound($txttoarray) - 1
			If $GameFailed > 1 Then
				$FailedSequences += 1
				_log("Game failed exiting sequence()", $LOG_LEVEL_WARNING)
				If $GameFailed = 2 Then
					_log("Game failure maybe recoverable, continuing to next sequence.", $LOG_LEVEL_WARNING)
					_log("Name sequence failed : " & $load_file, $LOG_LEVEL_WARNING)
					$GameFailed = 0
				EndIf
				ExitLoop
			EndIf

			If $end_sequence Then
				_log("End sequence activated", $LOG_LEVEL_WARNING)
				ExitLoop
			EndIf

			$error = 0
			$definition = 0
			$block = 0

			$line = $txttoarray[$i]

			If Not Comment($line) And Not $line = "" Then
				;***************************************CMD BLOQUANTE*****************************************
				If StringInStr($line, "takewp=", 2) Then; TakeWP detected
					If $ActivateChat Then WriteMe($WRITE_ME_TAKE_WP) ; TChat
					If $autobuff Then ; Buff avant de prendre le WP
					   Sleep(500)
					   buffinit()
					   _log("Enclenchement auto du buffinit() takewp", $LOG_LEVEL_DEBUG)
					EndIf
					$line = StringReplace($line, "takewp=", "", 0, 2)
					$table_wp = $line
					If $noblocline = 0 Then ;Pas de Detection precedente de nobloc() on met donc dans l'array la cmd suivante
						If SendSequence($array_sequence) Then
							$array_sequence = ArrayInit($array_sequence)
							_log("Enclenchement d'un TakeWP(" & $table_wp & ") line : " & $i + 1, $LOG_LEVEL_DEBUG)
							TakeWPV3($table_wp, 0)
							If $BanlistChange Then
								$Table_BanMonster = $old_Table_BanMonster
								$BanlistChange = 0
							EndIf
							$line = ""
						Else
							$end_sequence = True
							$line = ""
						EndIf
					Else
						_log("Mise en array d'un TakeWP(" & $table_wp & ") line : " & $i + 1, $LOG_LEVEL_DEBUG)
						$array_sequence = ArrayUp($array_sequence)
						$array_sequence[UBound($array_sequence) - 1][0] = 1
						$array_sequence[UBound($array_sequence) - 1][1] = "takewp"
						$array_sequence[UBound($array_sequence) - 1][2] = $table_wp
						$noblocline = 0
						$line = ""
					EndIf
				ElseIf StringInStr($line, "takewpadv=", 2) Then; TakeWP detected
					If $ActivateChat Then WriteMe($WRITE_ME_TAKE_WP) ; TChat
					If $autobuff Then ; Buff avant de prendre le WP
					   Sleep(500)
					   buffinit()
					   _log("Enclenchement auto du buffinit() takewpadv", $LOG_LEVEL_DEBUG)
					EndIf
					$line = StringReplace($line, "takewpadv=", "", 0, 2)
					$table_wp = $line
					If $noblocline = 0 Then ;Pas de Detection precedente de nobloc() on met donc dans l'array la cmd suivante
						If SendSequence($array_sequence) Then
							$array_sequence = ArrayInit($array_sequence)
							_log("Enclenchement d'un TakeWPAdv(" & $table_wp & ") line : " & $i + 1, $LOG_LEVEL_DEBUG)
							TakeWPV3($table_wp, 1)
							GetActiveQuest()
							If $BanlistChange Then
								$Table_BanMonster = $old_Table_BanMonster
								$BanlistChange = 0
							EndIf
							$line = ""
						Else
							$end_sequence = True
							$line = ""
						EndIf
					Else
						_log("Mise en array d'un TakeWPAdv(" & $table_wp & ") line : " & $i + 1, $LOG_LEVEL_DEBUG)
						$array_sequence = ArrayUp($array_sequence)
						$array_sequence[UBound($array_sequence) - 1][0] = 1
						$array_sequence[UBound($array_sequence) - 1][1] = "takewpadv"
						$array_sequence[UBound($array_sequence) - 1][2] = $table_wp
						$noblocline = 0
						$line = ""
					EndIf
				ElseIf StringInStr($line, "_townportal()", 2) Then; _townportal() detected
					If $noblocline = 0 Then ;Pas de Detection precedente de nobloc() on met donc dans l'array la cmd suivante
						If SendSequence($array_sequence) Then
							$array_sequence = ArrayInit($array_sequence)
							_log("Enclenchement d'un _townportal() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							If Not _checkdisconnect() Then
							   If Not _TownPortalnew() Then
								  $GameFailed = 2
								  Return False
							   EndIf
							Else
							   $GameFailed = 1
							   Return False
							EndIf
							$line = ""
						Else
							$end_sequence = True
							$line = ""
						EndIf
					Else
						_log("Mise en array d'un _townportal() line : " & $i + 1, $LOG_LEVEL_DEBUG)
						$array_sequence = ArrayUp($array_sequence)
						$array_sequence[UBound($array_sequence) - 1][0] = 1
						$array_sequence[UBound($array_sequence) - 1][1] = "_townportal"
						$noblocline = 0
						$line = ""
					EndIf
				ElseIf StringInStr($line, "safeportback()", 2) Then; safeportback() detected
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						SafePortBack()
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr($line, "safeportstart()", 2) Then; safeportstart() detected
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						Sleep(500)
						buffinit() ; on Buff avant de prendre le portal
						SafePortStart()
						If $BanlistChange Then
							$Table_BanMonster = $old_Table_BanMonster
							$BanlistChange = 0
						EndIf
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr(StringLeft($line,14), "loadsequence=", 2) Then
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						$end_sequence = True
						$line = StringReplace($line, "loadsequence=", "")
						_log("Lancement de la sequence : " & $line & " et arrêt de la séquence en cours")
						Sequence($line)
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr(StringLeft($line,12), "ifposition=", 2) Then
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						$pos = GetCurrentPos()
						$line = StringReplace($line, "ifposition=", "", 0, 2)
						$temp = StringSplit($line, ":", 2)
						$checkpos = StringSplit($temp[0], ",", 2)
						$PositionRange = $checkpos[3]
						_log("Testing current position with range : " & $PositionRange)
						If (Abs($pos[0] - $checkpos[0]) <= $PositionRange) And (Abs($pos[1] - $checkpos[1]) <= $PositionRange) And (Abs($pos[1] - $checkpos[1]) <= $PositionRange) Then
							_log("Position found ! ", $LOG_LEVEL_VERBOSE)
							If StringInStr($temp[1], "loadsequence=", 2) Then
								$end_sequence = True
								$temp = StringReplace($temp[1], "loadsequence=", "")
								_log("[If] Lancement de la sequence : " & $temp, $LOG_LEVEL_WARNING)
								Sequence($temp)
							ElseIf StringInStr($temp[1], "endsequence()", 2) Then
								_log("[If] End sequence detected. Stopping current sequence file.", $LOG_LEVEL_WARNING)
								$end_sequence = True
							ElseIf StringInStr($temp[1], "endgame()", 2) Then
								_log("[If] End game detected. Stopping current run!.", $LOG_LEVEL_WARNING)
								$end_sequence = True
								$end_game = True
							Else
								_log("Invalid command found for ifposition")
							EndIf
						Else
							_log("Position not found !", $LOG_LEVEL_WARNING)
						EndIf
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr(StringLeft($line,16), "ifscenepresent=", 2) Then
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						$pos = GetCurrentPos()
						$line = StringReplace($line, "ifscenepresent=", "", 0, 2)
						$temp = StringSplit($line, ":", 2)
						$scenes = StringSplit($temp[0], ",", 2)
						$found = True
						$count = UBound($scenes) -1

						_log("Checking scenes presences")
						For $scenespos = 0 To $count
							If Not isScenePresent($scenes[$scenespos]) Then
								$found = False
								ExitLoop
							EndIf
						Next

						If $found Then
							_log("All scenes found ! ", $LOG_LEVEL_VERBOSE)
							If StringInStr($temp[1], "loadsequence=", 2) Then
								$end_sequence = True
								$temp = StringReplace($temp[1], "loadsequence=", "")
								_log("[Scenes] Lancement de la sequence : " & $temp, $LOG_LEVEL_WARNING)
								Sequence($temp)
							ElseIf StringInStr($temp[1], "endsequence()", 2) Then
								_log("[Scenes] End sequence detected. Stopping current sequence file.", $LOG_LEVEL_WARNING)
								$end_sequence = True
							ElseIf StringInStr($temp[1], "endgame()", 2) Then
								_log("[Scenes] End game detected. Stopping current run!.", $LOG_LEVEL_WARNING)
								$end_sequence = True
								$end_game = True
							Else
								_log("Invalid command found for ifscenepresent")
							EndIf
						Else
							_log("Scenes not found !", $LOG_LEVEL_WARNING)
						EndIf
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr($line, "attackrange=", 2) Then; Définition de l'attackRange
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						$line = StringReplace($line, "attackrange=", "", 0, 2)
						_log("Modification de l'attackRange line : " & $i + 1, $LOG_LEVEL_DEBUG)
						attackRange($line)
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr(StringLeft($line,12), "terminate()", 2) Then
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						_log("Terminate detected. Ending script !", $LOG_LEVEL_ERROR)
						Terminate()
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr(StringLeft($line,10), "endgame()", 2) Then
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						$end_sequence = True
						$end_game = True
						_log("End game detected. Stopping current run !", $LOG_LEVEL_WARNING)
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr(StringLeft($line,14), "endsequence()", 2) Then
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						$end_sequence = True
						_log("End sequence detected. Stopping current sequence file", $LOG_LEVEL_WARNING)
						$line = ""
					Else
						$end_sequence = True
						$line = ""
					EndIf
				ElseIf StringInStr($line, "endsave()", 2) Then; endsave() detected
					If SendSequence($array_sequence) Then
						$array_sequence = ArrayInit($array_sequence)
						$line = ""
						_log("Enclenchement d'un endsave() line : " & $i + 1, $LOG_LEVEL_DEBUG)
					Else
						$end_sequence = True
						$line = ""
					EndIf
				EndIf
				;*********************************************************************************************
				;******************************CMD DE DEFINITION**********************************************
				If StringInStr($line, "monsterlist=", 2) Then; MonsterList detected
					$line = StringReplace($line, "monsterlist=", "", 0, 2)
					_log("Enclenchement d'un monsterlist line : " & $i + 1, $LOG_LEVEL_DEBUG)
					MonsterList($line)
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "specialml=", 2) Then; SpecialMonsterList detected
					$line = StringReplace($line, "specialml=", "", 0, 2)
					_log("Enclenchement d'un SpecialMonsterList line : " & $i + 1, $LOG_LEVEL_DEBUG)
					SpecialML($line)
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "BanList=", 2) Then; BanList detected
					$old_Table_BanMonster = $Table_BanMonster
					$BanlistChange = 1
					$line = StringReplace($line, "banlist=", "", 0, 2)
					_log("Enclenchement d'un Banlist() line : " & $i + 1, $LOG_LEVEL_DEBUG)
					BanList($line)
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "decorlist=", 2) Then; Decorlist detected
					$line = StringReplace($line, "decorlist=", "", 0, 2)
					_log("Enclenchement d'un Decorlist() line : " & $i + 1, $LOG_LEVEL_DEBUG)
					DecorList($line)
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "chestlist=", 2) Then; Chestlist detected
					$line = StringReplace($line, "chestlist=", "", 0, 2)
					_log("Enclenchement d'un Chestlist() line : " & $i + 1, $LOG_LEVEL_DEBUG)
					ChestList($line)
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "RackList=", 2) Then; Racklist detected
					$line = StringReplace($line, "racklist=", "", 0, 2)
					_log("Enclenchement d'un Racklist() line : " & $i + 1, $LOG_LEVEL_DEBUG)
					RackList($line)
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "maxgamelength=", 2) Then
					$line = StringReplace($line, "maxgamelength=", "", 0, 2)
					MaxGameLength($line)
					_log("Enclenchement d'un MaxGameLength() Line : " & $i + 1, $LOG_LEVEL_DEBUG)
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "autobuff=", 2) Then
					$line = StringReplace($line, "autobuff=", "", 0, 2)
					If $line = "true" Then
						$autobuff = True
						_log("Autobuff definit sur true line : " & $i + 1, $LOG_LEVEL_DEBUG)
					Else
						$autobuff = False
						_log("Autobuff definit sur false line : " & $i + 1, $LOG_LEVEL_DEBUG)
					EndIf
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "reverse=", 2) Then
					$line = StringReplace($line, "reverse=", "", 0, 2)
					If $line = "true" Then
						$reverse = 1
						_log("Reverse mod line : " & $i + 1, $LOG_LEVEL_DEBUG)
					EndIf
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "ifobjectfound=", 2) Then
					$line = StringReplace($line, "ifobjectfound=", "", 0, 2)
					$temp = StringSplit($line, ":", 2)
					$temp2 = StringSplit($temp[0] , ",", 2)
					If $Table_SearchObject = False Then
						Dim $Table_SearchObject[1][3]
						$Table_SearchObject[0][0] = $temp2[0]
						$Table_SearchObject[0][1] = $temp2[1]
						$Table_SearchObject[0][2] = $temp[1]
					Else
						$size = Ubound($Table_SearchObject)
						Redim $Table_SearchObject[$size + 1][3]
						$Table_SearchObject[$size][0] = $temp2[0]
						$Table_SearchObject[$size][1] = $temp2[1]
						$Table_SearchObject[$size][2] = $temp[1]
					EndIf
					_log("Ajout d'un objet a rechercher : " & $temp2[0] & " (Range : " & $temp2[1] & "). Action : " & $temp[1], $LOG_LEVEL_DEBUG)
					$SearchForObject = True
					$line = ""
					$definition = 1
				ElseIf StringInStr($line, "revive=", 2) Then
					$line = StringReplace($line, "revive=", "", 0, 2)
					If $old_ResActivated Then
						If $line = "true" Then
							$ResActivated = True
							_log("Turn revive mod to On line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							$ResActivated = False
							_log("Turn revive mod to Off line", $LOG_LEVEL_DEBUG)
						EndIf
						$line = ""
						$definition = 1
					EndIf
				ElseIf StringInStr($line, "usepath=", 2) Then
					$line = StringReplace($line, "usepath=", "", 0, 2)
					If $old_UsePath Then
						If $line = "true" Then
							$UsePath = True
							_log("Turn UsePath mod to On line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							$UsePath = False
							_log("Turn UsePath mod to Off line", $LOG_LEVEL_DEBUG)
						EndIf
						$line = ""
						$definition = 1
					EndIf
				ElseIf StringInStr($line, "takeshrines=", 2) Then
					$line = StringReplace($line, "takeshrines=", "", 0, 2)
					If $old_TakeShrines Then
						If $line = "true" Then
							$TakeShrines = True
							_log("Turn TakeShrines mod to On line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							$TakeShrines = False
							_log("Turn TakeShrines mod to Off line", $LOG_LEVEL_DEBUG)
						EndIf
						$line = ""
						$definition = 1
					EndIf
				EndIf
				;*********************************************************************************************

				If Not $error = 1 Or $definition = 1 Or $line = "" Then
					If StringInStr($line, "sleep=", 2) Then ;sleep detected
						$line = StringReplace($line, "sleep=", "", 0, 2)
						If $sequence_save = 0 Then
							Sleep($line)
							_log("Enclenchement d'un sleep direct line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un sleep line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "sleep"
							$array_sequence[UBound($array_sequence) - 1][2] = $line
						EndIf
					ElseIf StringInStr($line, "offsetlist()", 2) Then; _townportal() detected
						If $sequence_save = 0 Then
							While Not offsetlist()
								Sleep(40)
							WEnd
							_log("Enclenchement d'un offsetlist line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un offsetlist line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][2] = $line
							$array_sequence[UBound($array_sequence) - 1][1] = "offsetlist"
						EndIf
					ElseIf StringInStr($line, "nobloc()", 2) Then ;nobloc detected
						$noblocline = 1
					ElseIf StringInStr($line, "InteractWithActor=", 2) Then ;InteractWithActor detected
						$line = StringReplace($line, "InteractWithActor=", "", 0, 2)
						If $sequence_save = 0 Then
							InteractByActorName($line)
							_log("Enclenchement d'un InteractWithActor direct line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un InteractWithActor() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "InteractWithActor"
							$array_sequence[UBound($array_sequence) - 1][2] = $line
						EndIf
					ElseIf StringInStr($line, "InteractWithDoor=", 2) Then ;InteractWithDoor
						$line = StringReplace($line, "InteractWithDoor=", "", 0, 2)
						If $sequence_save = 0 Then
							InteractWithDoor($line)
							_log("Enclenchement d'un InteractWithDoor direct line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un InteractWithDoor() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "InteractWithDoor"
							$array_sequence[UBound($array_sequence) - 1][2] = $line
						EndIf
					ElseIf StringInStr($line, "InteractWithPortal=", 2) Then ;InteractWithPortal detected
						$line = StringReplace($line, "InteractWithPortal=", "", 0, 2)
						If $sequence_save = 0 Then
							_log("Enclenchement d'un InteractWithPortal direct line : " & $i + 1, $LOG_LEVEL_DEBUG)
							InteractWithPortal($line)
							GetActiveQuest()
						Else
							_log("Mise en array d'un InteractWithPortal() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "InteractWithPortal"
							$array_sequence[UBound($array_sequence) - 1][2] = $line
						EndIf
					ElseIf StringInStr($line, "buffinit()", 2) Then ;buffinit detected
						If $sequence_save = 0 Then
							buffinit()
							_log("Enclenchement d'un buffinit() line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un buffinit() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "buffinit"
						EndIf
					ElseIf StringInStr($line, "unbuff()", 2) Then ;unbuff detected
						If $sequence_save = 0 Then
							unbuff()
							_log("Enclenchement d'un unbuf() line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un unbuf() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "unbuff"
						EndIf
					ElseIf StringInStr($line, "closewindows()", 2) Then ;closewindows detected
						If $sequence_save = 0 Then
							Send($KeyCloseWindows)
							_log("Enclenchement d'un closewindows() line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un closewindows() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "closewindows"
						EndIf
					ElseIf StringInStr($line, "closeconfirm()", 2) Then ;closcloseconfirmwindows detected
						If $sequence_save = 0 Then
							ClickUI("Root.TopLayer.confirmation.subdlg.stack.wrap.button_ok", 2014)
							_log("Enclenchement d'un closeconfirm() line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un closeconfirm() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "closeconfirm"
						EndIf
					ElseIf StringInStr($line, "send=", 2) Then ;send detected
						$line = StringReplace($line, "send=", "", 0, 2)
						If $sequence_save = 0 Then
							Send($line)
							_log("Enclenchement d'un send direct line : " & $i + 1, $LOG_LEVEL_DEBUG)
						Else
							_log("Mise en array d'un send() line : " & $i + 1, $LOG_LEVEL_DEBUG)
							$array_sequence = ArrayUp($array_sequence)
							$array_sequence[UBound($array_sequence) - 1][0] = 1
							$array_sequence[UBound($array_sequence) - 1][1] = "send"
							$array_sequence[UBound($array_sequence) - 1][2] = $line
						EndIf
					Else ;no specific command detected, so we guess movetopos
						If Not $line = "" Then ;Si ligne PAS vide
							$table_mtp = StringSplit($line, ",", 2)
							If UBound($table_mtp, 1) = 5 Then
								$array_sequence = ArrayUp($array_sequence)
								$array_sequence[UBound($array_sequence) - 1][0] = 2
								$array_sequence[UBound($array_sequence) - 1][1] = $table_mtp[0]
								$array_sequence[UBound($array_sequence) - 1][2] = $table_mtp[1]
								$array_sequence[UBound($array_sequence) - 1][3] = $table_mtp[2]
								$array_sequence[UBound($array_sequence) - 1][4] = $table_mtp[3]
								$array_sequence[UBound($array_sequence) - 1][5] = $table_mtp[4]
							Else
								_log("Unknow or invalide cmd on line : " & $i + 1 & " -> " & $line, $LOG_LEVEL_ERROR)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If UBound($txttoarray) = $i + 1 Then
				If SendSequence($array_sequence) = False Then
					$end_sequence = True
				EndIf
			EndIf

		Next

		$reverse = 0
		$sequence_save = 0
		$autobuff = False
		$ResActivated = $old_ResActivated
		$UsePath = $old_UsePath
		$TakeShrines = $old_TakeShrines
		$a_range = $old_Attackrange
		$Table_SpecialMonster = $old_Table_SpecialMonster
		$Table_Decor = $old_Table_Decor
		$Table_Coffre = $old_Table_Coffre
		$Table_Rack = $old_Table_Rack
		unbuff()
		If $GameFailed = 1 Or $end_game Then
			ExitLoop
		EndIf
	Next
EndFunc   ;==>sequence

Func InteractWithDoor($NameDoor, $dist = 30)
	Local $index, $offset, $count, $item[$TableSizeGuidStruct], $foundobject = 0
	Local $maxtry = 0
	startIterateObjectsList($index, $offset, $count)
	If Not _playerdead() Then
		While iterateObjectsList($index, $offset, $count, $item)
			If StringInStr($item[1], $NameDoor, 2) And $item[9] < $dist Then
				_log("InteractWithDoor : " & $item[1] & " distance -> " & $item[9], $LOG_LEVEL_VERBOSE)
				While getDistance($item[2], $item[3], $item[4]) > 15 And $maxtry <= 15
					$Coords = FromD3toScreenCoords($item[2], $item[3], $item[4])
					MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 10)
					$maxtry += 1
					_log('InteractWithDoor : Move click x : ' & $Coords[0] & " y : " & $Coords[1], $LOG_LEVEL_VERBOSE)
					Sleep(450)
				WEnd
				Interact($item[2], $item[3], $item[4])
				; TODO : Check gizmo state for open door ?
				$foundobject = 1
				Sleep(450)
				ExitLoop
			EndIf
		WEnd
	EndIf
	Return $foundobject
EndFunc   ;==> InteractWithDoor

Func InteractWithPortal($NamePortal)

	Local $Curentarea = GetLevelAreaId()
	Local $Newarea = $Curentarea
	Local $PortalTry = 0
	Local $AreaWait = 20

	While $PortalTry < 5
		If GetLevelAreaId() = $Curentarea Then
			If Not _checkBossJoinParty() And Not _checkBossEnter() Then
				InteractByActorName($NamePortal, 30)
				_log("Try n°" & $PortalTry + 1 & " Portal", $LOG_LEVEL_DEBUG)
			Else
				If _checkBossJoinParty() Then
					ClickUi("Root.NormalLayer.boss_join_party_main.stack.wrapper.Accept", 300)
					Sleep(500)
				EndIf
				If _checkBossEnter() Then
					ClickUi("Root.NormalLayer.boss_enter_main.stack.wrapper.Accept", 204)
					Sleep(500)
					$AreaWait = 240
				EndIf
			EndIf
		EndIf

		Local $areatry = 0
		While $Newarea = $Curentarea And $areatry < $AreaWait
			If _checkBossEnter() Or _checkBossJoinParty() Then ExitLoop
			If Not _checkBossWarningMessage() Then
			   $Newarea = GetLevelAreaId()
			   Sleep(250)
			   $areatry += 1
			Else
			   _log("Player Declined The Event", $LOG_LEVEL_DEBUG)
			   ClickUI("Root.TopLayer.confirmation.subdlg.stack.wrap.button_ok", 2014)
			   Sleep(1000)
			   ContinueLoop
			EndIf
		WEnd

		If $Newarea <> $Curentarea Then
			ExitLoop
		Else
			$PortalTry += 1
			$AreaWait = 20
		EndIf
	WEnd

	If $Newarea <> $Curentarea Then
		_log('Succesfully Portal Try', $LOG_LEVEL_VERBOSE)
	Else
		_log('We failed Portal Try', $LOG_LEVEL_ERROR)
		$GameFailed = 2
	EndIf
EndFunc   ;==> InteractWithPortal

;***************** CMD ************
;
; Toute ligne contenant // est desactivé, les lignes vierge sont detectées parfois comme étant des lignes erronée et donc reporté dans les logs !
;
; CMD BLOQUANTE                 (les cmd dite bloquantes, forcent l'envoi de l'array, elles definissent donc un point de sauvegarde pour le code si revive on)
; -> _townportal()              (force un tp en ville, si précédée de nobloc() ne force pas l'envoi de l'array)
; -> takewp=X            		(prend un teleporteur mode campagne, si précédée de nobloc() ne force pas l'envoi de l'array)
; -> takewpadv=X            	(prend un teleporteur mode aventure, si précédée de nobloc() ne force pas l'envoi de l'array)
; -> endsave()                  (force l'envoie de l'array, et donc definit un point de sauvegarde si revive on)
; -> attackrange=				(definition d'un nouvel attackrange)
; -> loadsequence=				(Arrête la séquence en cours et charge la séquence indiquée)
; -> endsequence()				(Arrête la séquence en cours et passe à la suivante)
; -> endgame()					(Arrête la game en cours)
; -> terminate()				(Arrête le script !)
; -> ifposition=				(Vérifie la position en cours et lance la commande indiquée si l'on s'y trouve : ifposition=x,y,z,range:Commande)
;								(Commandes supportées : loadsequence=xxx / endsequence() / endgame())
; -> ifscenepresent=			(Vérifie les scènes en cours et lance la commande indiquée si elles sont toutes présentes : ifscenepresent=a,b,c,d,...:Commande)
;								(Remarque : il faut le sno en hexa complet des scènes : 0x0000D1DD)
;								(Commandes supportées : loadsequence=xxx / endsequence() / endgame())
;
; CMD DEFINITION
; -> maxgamelength=				(definition d'un nouveau maxgamelength)
; -> monsterlist=               (definition des monstres à tuer)
; -> specialml=					(definition de la special monsterlist)
; -> banlist=                   (banlist)
; -> racklist=					(liste des racks a ouvrir)
; -> chestlist=					(liste des coffres a ouvrir)
; -> decorlist=					(liste des objets de décor a casser)
; -> ifobjectfound=				(Définie une recherche active d'object (comme un portail) a une distance maximale et lance une commande)
;								(Commandes supportées : loadsequence=XXX / endsequence() / terminate())
;								(Ex : ifobjectfound=g_Portal_Circle_Blue,25:loadsequence=lasequencedelacave)
; -> autobuff=true/false        (active ou desactive la gestion des buffs automatiquement lors du passage d'un array)
; -> revive=true/false          (active ou desactive la fonction revive, si ResActivated est definit sur false dans le setting.ini, la commande n'a aucun effet)
; -> usepath=true/false         (active ou desactive la fonction usepath, si UsePath est definit sur false dans le setting.ini, la commande n'a aucun effet)
;
; CMD PASSIVE
; -> sleep=                     (definition d'un sleep)
; -> offsetlist()               (rafraichissement de la memoire)
; -> nobloc()                   (Rend la prochaine commande bloquante passive, cette fonction n'est a appeler qu'au dessus d'un takewp ou d'un _townportal())
; -> InteractWithActor=       (Interagit avec un npc / porte / objet)
; -> InteractWithDoor=          (Interagit avec porte / grille )
; -> InteractWithPortal= 		(Interagit avec un portail : Attention détection de changement de zone ne pas utiliser pour une simple porte)
; -> buffinit()                 (Force l'initialisation des buffs)
; -> unbuff()                   (force l'unbuff)
; -> send=                      (Envoie une Key)
; -> closewindows()			 	(Ferme toutes les fenêtres ouvertes)
; -> closeconfirm()				(Click ok dans les dialogues de confirmation (Par Ex : Annulation de vidéo))
; -> x, y, z, w, y              (movetopos, composé de 5 argument)
;
; L'array renvoyé par la fonction SendSequence() (array[X][6])
;
; array[x][0] -> 1 ou 2 (Si 1, l'enregistrement suivant contient une commande, si 2, les autres "case" contiennent )
; array[x][1] -> Si commande, contient le nom de la commande, les cases suivante contiennent la/les valeurs associé
