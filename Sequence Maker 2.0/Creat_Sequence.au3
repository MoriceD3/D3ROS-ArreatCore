$_debug = 1
Global $_Myoffset

Global $ProcessID = WinGetProcess("Diablo III", "")
Local $d3 = _MemoryOpen($ProcessID)

Func _log($text, $write = 0)
        ConsoleWrite(@MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & " | " & $text & @CRLF)
EndFunc   ;==>_log

;;--------------------------------------------------------------------------------
;;      OffsetList()
;;--------------------------------------------------------------------------------
Func offsetlist()
        _log("offsetlist")
        ;//FILE DEFS
        ;//FILE DEFS
        Global $ofs_MonsterDef = 0x18EC4C0 ; 0x18CBE70 ;1.0.6 0x15DBE00 ;0x015DCE00 ;0x15DBE00
        Global $ofs_StringListDef = 0x18A2558 ; 0x0158C240 ;0x015E8808 ;0x015E9808
        Global $ofs_ActorDef = 0x18E73F0 ; 0x18C6AD8 ;1.0.6 0x15EC108 ;0x015ED108 ;0x15EC108
        Global $_defptr = 0x10
        Global $_defcount = 0x10C
        Global $_deflink = 0x148
        Global $_ofs_FileMonster_StrucSize = 0x50
        Global $_ofs_FileActor_LinkToMonster = 0x6C
        Global $_ofs_FileMonster_MonsterType = 0x18
        Global $_ofs_FileMonster_MonsterRace = 0x1C
        Global $_ofs_FileMonster_LevelNormal = 0x44
        Global $_ofs_FileMonster_LevelNightmare = 0x48
        Global $_ofs_FileMonster_LevelHell = 0x4c
        Global $_ofs_FileMonster_LevelInferno = 0x50

        ;//GET ACTORATRIB
        Global $ofs_ActorAtrib_Base = 0x1544E54 ;0x15A1EA4 ;0x015A2EA4;0x015A1EA4
        Global $ofs_ActorAtrib_ofs1 = 0x390
        Global $ofs_ActorAtrib_ofs2 = 0x2E8
        Global $ofs_ActorAtrib_ofs3 = 0x148
        Global $ofs_ActorAtrib_Count = 0x108 ; 0x0 0x0
        Global $ofs_ActorAtrib_Indexing_ofs1 = 0x10
        Global $ofs_ActorAtrib_Indexing_ofs2 = 0x8
        Global $ofs_ActorAtrib_Indexing_ofs3 = 0x250
        Global $ofs_ActorAtrib_StrucSize = 0x180
        Global $ofs_LocalPlayer_HPBARB = 0x34
        Global $ofs_LocalPlayer_HPWIZ = 0x38


        ;//GET LOCAL ACTOR STRUC
        Global $ofs_LocalActor_ofs1 = 0x378 ;instead of $ofs_ActorAtrib_ofs2
        Global $ofs_LocalActor_ofs2 = 0x148
        Global $ofs_LocalActor_Count = 0x108
        Global $ofs_LocalActor_atribGUID = 0x120
        Global $ofs_LocalActor_StrucSize = 0x2D0 ; 0x0 0x0


        ;//OBJECT MANAGER
        Global $ofs_objectmanager = 0x18939C4 ;0x1873414 ;0x0186FA3C ;0x1543B9C ;0x15A0BEC ;0x015A1BEC;0x15A0BEC
        Global $ofs__ObjmanagerActorOffsetA = 0x8C8 ;0x8b0
        Global $ofs__ObjmanagerActorCount = 0x108
        Global $ofs__ObjmanagerActorOffsetB = 0x148
        Global $ofs__ObjmanagerActorLinkToCTM = 0x384
        Global $_ObjmanagerStrucSize = 0x42C ;0x428


        ;//CameraDef
        Global $VIewStatic = 0x015A0BEC
        Global $DebugFlags = $VIewStatic + 0x20
        Global $vftableSubA = _MemoryRead($VIewStatic, $d3, 'ptr')
        Global $vftableSubA = _MemoryRead($vftableSubA + 0x928, $d3, 'ptr')
        Global $ViewOffset = $vftableSubA
        Global $Ofs_CameraRotationA = $ViewOffset + 0x4
        Global $Ofs_CameraRotationB = $ViewOffset + 0x8
        Global $Ofs_CameraRotationC = $ViewOffset + 0xC
        Global $Ofs_CameraRotationD = $ViewOffset + 0x10
        Global $Ofs_CameraPosX = $ViewOffset + 0x14
        Global $Ofs_CameraPosY = $ViewOffset + 0x18
        Global $Ofs_CameraPosZ = $ViewOffset + 0x1C
        Global $Ofs_CameraFOV = $ViewOffset + 0x30
        Global $Ofs_CameraFOVB = $ViewOffset + 0x30
        Global $ofs_InteractBase = 0x1543B84 ;0x15A0BD4 ;0x015A1BD4;0x15A0BD4
        Global $ofs__InteractOffsetA = 0xA8
        Global $ofs__InteractOffsetB = 0x58
        Global $ofs__InteractOffsetUNK1 = 0x7F20 ;Set to 777c
        Global $ofs__InteractOffsetUNK2 = 0x7F44 ;Set to 1 for NPC interaction
        Global $ofs__InteractOffsetUNK3 = 0x7F7C ;Set to 7546 for NPC interaction, 7545 for loot interaction
        Global $ofs__InteractOffsetUNK4 = 0x7F80 ;Set to 7546 for NPC interaction, 7545 for loot interaction
        Global $ofs__InteractOffsetMousestate = 0x7F84 ;Mouse state 1 = clicked, 2 = mouse down
        Global $ofs__InteractOffsetGUID = 0x7F88 ;Set to the GUID of the actor you want to interact with
        $FixSpeed = 0x20 ;69736
        $ToggleMove = 0x34
        $MoveToXoffset = 0x40
        $MoveToYoffset = 0x44
        $MoveToZoffset = 0x48
        $CurrentX = 0xA8
        $CurrentY = 0xAc
        $CurrentZ = 0xb0
        $RotationOffset = 0x174
        Global $_ActorAtrib_Base = _MemoryRead($ofs_ActorAtrib_Base, $d3, 'ptr')
        Global $_ActorAtrib_1 = _MemoryRead($_ActorAtrib_Base + $ofs_ActorAtrib_ofs1, $d3, 'ptr')
        Global $_ActorAtrib_2 = _MemoryRead($_ActorAtrib_1 + $ofs_ActorAtrib_ofs2, $d3, 'ptr')
        Global $_ActorAtrib_3 = _MemoryRead($_ActorAtrib_2 + $ofs_ActorAtrib_ofs3, $d3, 'ptr')
        Global $_ActorAtrib_4 = _MemoryRead($_ActorAtrib_3, $d3, 'ptr')
        Global $_ActorAtrib_Count = $_ActorAtrib_2 + $ofs_ActorAtrib_Count
        Global $_LocalActor_1 = _MemoryRead($_ActorAtrib_1 + $ofs_LocalActor_ofs1, $d3, 'ptr')
        Global $_LocalActor_2 = _MemoryRead($_LocalActor_1 + $ofs_LocalActor_ofs2, $d3, 'ptr')
        Global $_LocalActor_3 = _MemoryRead($_LocalActor_2, $d3, 'ptr')
        Global $_LocalActor_Count = $_LocalActor_1 + $ofs_LocalActor_Count
        Global $_itrObjectManagerA = _MemoryRead($ofs_objectmanager, $d3, 'ptr')
        Global $_itrObjectManagerB = _MemoryRead($_itrObjectManagerA + $ofs__ObjmanagerActorOffsetA, $d3, 'ptr')
        Global $_itrObjectManagerCount = $_itrObjectManagerB + $ofs__ObjmanagerActorCount
        Global $_itrObjectManagerC = _MemoryRead($_itrObjectManagerB + $ofs__ObjmanagerActorOffsetB, $d3, 'ptr')
        Global $_itrObjectManagerD = _MemoryRead($_itrObjectManagerC, $d3, 'ptr')
        Global $_itrObjectManagerE = _MemoryRead($_itrObjectManagerD, $d3, 'ptr')
        Global $_itrInteractA = _MemoryRead($ofs_InteractBase, $d3, 'ptr')
        Global $_itrInteractB = _MemoryRead($_itrInteractA, $d3, 'ptr')
        Global $_itrInteractC = _MemoryRead($_itrInteractB, $d3, 'ptr')
        Global $_itrInteractD = _MemoryRead($_itrInteractC + $ofs__InteractOffsetA, $d3, 'ptr')
        Global $_itrInteractE = $_itrInteractD + $ofs__InteractOffsetB



        If LocateMyToon() Then
                Global $ClickToMoveMain = _MemoryRead($_Myoffset + $ofs__ObjmanagerActorLinkToCTM, $d3, 'ptr')
                Global $ClickToMoveRotation = $ClickToMoveMain + $RotationOffset
                Global $ClickToMoveCurX = $ClickToMoveMain + $CurrentX
                Global $ClickToMoveCurY = $ClickToMoveMain + $CurrentY
                Global $ClickToMoveCurZ = $ClickToMoveMain + $CurrentZ
                Global $ClickToMoveToX = $ClickToMoveMain + $MoveToXoffset
                Global $ClickToMoveToY = $ClickToMoveMain + $MoveToYoffset
                Global $ClickToMoveToZ = $ClickToMoveMain + $MoveToZoffset
                Global $ClickToMoveToggle = $ClickToMoveMain + $ToggleMove
                Global $ClickToMoveFix = $ClickToMoveMain + $FixSpeed
                Return True
        Else
                Return False
        EndIf

EndFunc   ;==>offsetlist

Func GetACDOffsetByACDGUID($Guid)
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x868, $d3, "ptr")
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "int")
	$index = BitAND($Guid, 0xFFFF)

	$bitshift = _memoryread($ptr3 + 0x18C, $d3, "int")
	$group1 = 4 * BitShift($index, $bitshift)
	$group2 = BitShift(1, -$bitshift) - 1
	$group3 = _memoryread(_memoryread($ptr3 + 0x148, $d3, "int"), $d3, "int")
	$group4 = 0x2D0 * BitAND($index, $group2)
	Return $group3 + $group1 + $group4
EndFunc   ;==>GetACDOffsetByACDGUID


;;================================================================================
; Function:                     LocateMyToon
; Note(s):                      This function is used by the OffsetList to
;                                               get the current player data.
;==================================================================================
Func LocateMyToon()

        sleep(1000)
        If $_debug Then _log("Looking for local player")
        $_CurOffset = 0
        $_CurOffset = $_itrObjectManagerD
        $_Count = _MemoryRead($_itrObjectManagerCount, $d3, 'int')
        For $i = 0 To $_Count Step +1
                $_GUID = _MemoryRead($_CurOffset + 0x4, $d3, 'ptr')
                $_SNO = _MemoryRead($_CurOffset + 0x88, $d3, 'ptr')
                $_NAME = _MemoryRead($_CurOffset + 0x8, $d3, 'char[64]')
                ;ConsoleWrite("Value : " & $_NAME & @CRLF)
                ;_log($_NAME)
                If $_SNO = 0x126D Or $_SNO = 0x126D Or $_SNO = 0x1271 Or $_SNO = 0x1990 Or $_SNO = 0x197E Or $_SNO = 0xCE5 Or $_SNO = 0xCD5 Or $_SNO = 0x123D2 Or $_SNO = 0x125C7 Or $_SNO = 0x1951 Or $_SNO = 0x1955 Then
                        Global $_Myoffset = $_CurOffset
                        If $_debug Then _log("My toon located at: " & $_Myoffset & ", GUID: " & $_GUID &  ", SNO: " & $_SNO &", NAME: " & $_NAME & @CRLF)
                        Global $_MyGuid = $_GUID
						$ACD = GetACDOffsetByACDGUID($_MyGuid)
						$name_by_acd = _MemoryRead($ACD + 0x4, $d3, 'char[64]')
					
						$_MyGuid = _memoryread($ACD + 0x120, $d3, "ptr")
						Global $_MyACDWorld = _memoryread($ACD + 0x108, $d3, "ptr")
						
                        
                        Return True
                        ExitLoop
                EndIf
                $_CurOffset = $_CurOffset + $_ObjmanagerStrucSize
        Next
        Return False

EndFunc   ;==>LocateMyToon

 Func _MemoryOpen($iv_Pid, $iv_DesiredAccess = 0x1F0FFF, $iv_InheritHandle = 1)

        If Not ProcessExists($iv_Pid) Then
                SetError(1)
        Return 0
        EndIf

        Local $ah_Handle[2] = [DllOpen('kernel32.dll')]

        If @Error Then
        SetError(2)
        Return 0
    EndIf

        Local $av_OpenProcess = DllCall($ah_Handle[0], 'int', 'OpenProcess', 'int', $iv_DesiredAccess, 'int', $iv_InheritHandle, 'int', $iv_Pid)

        If @Error Then
        DllClose($ah_Handle[0])
        SetError(3)
        Return 0
    EndIf

        $ah_Handle[1] = $av_OpenProcess[0]

        Return $ah_Handle

EndFunc

;==================================================================================
; Function:                     _MemoryRead($iv_Address, $ah_Handle[, $sv_Type])
; Description:          Reads the value located in the memory address specified.
; Parameter(s):         $iv_Address - The memory address you want to read from. It must
;                                                                 be in hex format (0x00000000).
;                                       $ah_Handle - An array containing the Dll handle and the handle
;                                                                of the open process as returned by _MemoryOpen().
;                                       $sv_Type - (optional) The "Type" of value you intend to read.
;                                                               This is set to 'dword'(32bit(4byte) signed integer)
;                                                               by default.  See the help file for DllStructCreate
;                                                               for all types.  An example: If you want to read a
;                                                               word that is 15 characters in length, you would use
;                                                               'char[16]' since a 'char' is 8 bits (1 byte) in size.
; Return Value(s):      On Success - Returns the value located at the specified address.
;                                       On Failure - Returns 0
;                                       @Error - 0 = No error.
;                                                        1 = Invalid $ah_Handle.
;                                                        2 = $sv_Type was not a string.
;                                                        3 = $sv_Type is an unknown data type.
;                                                        4 = Failed to allocate the memory needed for the DllStructure.
;                                                        5 = Error allocating memory for $sv_Type.
;                                                        6 = Failed to read from the specified process.
; Author(s):            Nomad
; Note(s):                      Values returned are in Decimal format, unless specified as a
;                                       'char' type, then they are returned in ASCII format.  Also note
;                                       that size ('char[size]') for all 'char' types should be 1
;                                       greater than the actual size.
;==================================================================================
Func _MemoryRead($iv_Address, $ah_Handle, $sv_Type = 'dword')

        If Not IsArray($ah_Handle) Then
                SetError(1)
        Return 0
        EndIf

        Local $v_Buffer = DllStructCreate($sv_Type)

        If @Error Then
                SetError(@Error + 1)
                Return 0
        EndIf

        DllCall($ah_Handle[0], 'int', 'ReadProcessMemory', 'int', $ah_Handle[1], 'int', $iv_Address, 'ptr', DllStructGetPtr($v_Buffer), 'int', DllStructGetSize($v_Buffer), 'int', '')

        If Not @Error Then
                Local $v_Value = DllStructGetData($v_Buffer, 1)
                Return $v_Value
        Else
                SetError(6)
        Return 0
        EndIf

EndFunc


;==================================================================================
; Function:                     _MemoryClose($ah_Handle)
; Description:          Closes the process handle opened by using _MemoryOpen().
; Parameter(s):         $ah_Handle - An array containing the Dll handle and the handle
;                                                                of the open process as returned by _MemoryOpen().
; Return Value(s):      On Success - Returns 1
;                                       On Failure - Returns 0
;                                       @Error - 0 = No error.
;                                                        1 = Invalid $ah_Handle.
;                                                        2 = Unable to close the process handle.
; Author(s):            Nomad
; Note(s):
;==================================================================================
Func _MemoryClose($ah_Handle)

        If Not IsArray($ah_Handle) Then
                SetError(1)
        Return 0
        EndIf

        DllCall($ah_Handle[0], 'int', 'CloseHandle', 'int', $ah_Handle[1])
        If Not @Error Then
                DllClose($ah_Handle[0])
                Return 1
        Else
                DllClose($ah_Handle[0])
                SetError(2)
        Return 0
        EndIf

EndFunc

;==================================================================================
; Function:                     SetPrivilege( $privilege, $bEnable )
; Description:          Enables (or disables) the $privilege on the current process
;                   (Probably) requires administrator privileges to run
;
; Author(s):            Larry (from autoitscript.com Forum)
; Notes(s):
; http://www.autoitscript.com/forum/index.php?s=&showtopic=31248&view=findpost&p=223999
;==================================================================================

Func SetPrivilege( $privilege, $bEnable )

;    Const $TOKEN_ADJUST_PRIVILEGES = 0x0020
; ;   Const $TOKEN_QUERY = 0x0008
;    Const $SE_PRIVILEGE_ENABLED = 0x0002
    Local $hToken, $SP_auxret, $SP_ret, $hCurrProcess, $nTokens, $nTokenIndex, $priv
    $nTokens = 1
    $LUID = DLLStructCreate("dword;int")
    If IsArray($privilege) Then    $nTokens = UBound($privilege)
    $TOKEN_PRIVILEGES = DLLStructCreate("dword;dword[" & (3 * $nTokens) & "]")
    $NEWTOKEN_PRIVILEGES = DLLStructCreate("dword;dword[" & (3 * $nTokens) & "]")
    $hCurrProcess = DLLCall("kernel32.dll","hwnd","GetCurrentProcess")
    $SP_auxret = DLLCall("advapi32.dll","int","OpenProcessToken","hwnd",$hCurrProcess[0],   _
            "int",BitOR(0x0020,0x0008),"int_ptr",0)
    If $SP_auxret[0] Then
        $hToken = $SP_auxret[3]
        DLLStructSetData($TOKEN_PRIVILEGES,1,1)
        $nTokenIndex = 1
        While $nTokenIndex <= $nTokens
            If IsArray($privilege) Then
                $priv = $privilege[$nTokenIndex-1]
            Else
                $priv = $privilege
            EndIf
            $ret = DLLCall("advapi32.dll","int","LookupPrivilegeValue","str","","str",$priv,   _
                    "ptr",DLLStructGetPtr($LUID))
            If $ret[0] Then
                If $bEnable Then
                    DLLStructSetData($TOKEN_PRIVILEGES,2,0x0002,(3 * $nTokenIndex))
                Else
                    DLLStructSetData($TOKEN_PRIVILEGES,2,0,(3 * $nTokenIndex))
                EndIf
                DLLStructSetData($TOKEN_PRIVILEGES,2,DllStructGetData($LUID,1),(3 * ($nTokenIndex-1)) + 1)
                DLLStructSetData($TOKEN_PRIVILEGES,2,DllStructGetData($LUID,2),(3 * ($nTokenIndex-1)) + 2)
                DLLStructSetData($LUID,1,0)
                DLLStructSetData($LUID,2,0)
            EndIf
            $nTokenIndex += 1
        WEnd
        $ret = DLLCall("advapi32.dll","int","AdjustTokenPrivileges","hwnd",$hToken,"int",0,   _
                "ptr",DllStructGetPtr($TOKEN_PRIVILEGES),"int",DllStructGetSize($NEWTOKEN_PRIVILEGES),   _
                "ptr",DllStructGetPtr($NEWTOKEN_PRIVILEGES),"int_ptr",0)
        $f = DLLCall("kernel32.dll","int","GetLastError")
    EndIf
    $NEWTOKEN_PRIVILEGES=0
    $TOKEN_PRIVILEGES=0
    $LUID=0
    If $SP_auxret[0] = 0 Then Return 0
    $SP_auxret = DLLCall("kernel32.dll","int","CloseHandle","hwnd",$hToken)
    If Not $ret[0] And Not $SP_auxret[0] Then Return 0
    return $ret[0]
 EndFunc   ;==>SetPrivilege

 Func IndexSNO($_offset, $_displayInfo = 0)

	Local $CurrentSnoOffset = 0x0
	$_MainOffset = _MemoryRead($_offset, $d3, 'ptr')
	$_Pointer = _MemoryRead($_MainOffset + $_defptr, $d3, 'ptr')
	$_SnoCount = _MemoryRead($_Pointer + $_defcount, $d3, 'ptr') ;//Doesnt seem to go beyond 256 for some wierd reason
	If $_SnoCount >= 256 Then ;//So incase it goes beyond...
		$ignoreSNOcount = 1 ;//This enables a redim after the for loop
		$_SnoCount = 4056 ;//We put a limit to avoid overflow here
	Else
		$ignoreSNOcount = 0
	EndIf

	$_SnoIndex = _MemoryRead($_Pointer + $_deflink, $d3, 'ptr') ;//Moving from the static into the index
	$_SNOName = _MemoryRead($_Pointer, $d3, 'char[64]') ;//Usually something like "Something" + Def
	$TempWindex = $_SnoIndex + 0xC ;//The header is 0xC in size
	If $_displayInfo = 1 Then ConsoleWrite("-----* Indexing " & $_SNOName & " *-----" & @CRLF)
	Dim $_OutPut[$_SnoCount + 1][2] ;//Setting the size of the output array

	For $i = 1 To $_SnoCount Step +1 ;//Iterating through all the elements
		$_CurSnoOffset = _MemoryRead($TempWindex, $d3, 'ptr') ;//Getting the offset for the item
		$_CurSnoID = _MemoryRead($_CurSnoOffset, $d3, 'ptr') ;//Going into the item and grapping the GUID which is located at 0x0
		If $ignoreSNOcount = 1 And $_CurSnoOffset = 0x00000000 And $_CurSnoID = 0x00000000 Then ExitLoop ;//Untill i find a way to get the real count we do this instead.
		If $ignoreSNOcount = 1 Then $CurIndex = $i
		$_OutPut[$i][0] = $_CurSnoOffset ;//Poping the data into the output array
		$_OutPut[$i][1] = $_CurSnoID
		If $_displayInfo = 1 Then ConsoleWrite($i & " Offset: " & $_CurSnoOffset & " SNOid: " & $_CurSnoID & @CRLF)
		$TempWindex = $TempWindex + 0x10 ;//Next item is located 0x10 later
	Next

	If $ignoreSNOcount = 1 Then ReDim $_OutPut[$CurIndex][2] ;//Here we do the resizing of the array, to minimize memory footprint!?.

	Return $_OutPut
EndFunc   ;==>IndexSNO

Func _Array2DDelete(ByRef $ARRAY, $iDEL, $bCOL = False)
	If (Not IsArray($ARRAY)) Then Return SetError(1, 0, 1)
	Local $UBound2nd = UBound($ARRAY, 2), $k
	If $bCOL Then
		If $UBound2nd = 0 Then Return SetError(2, 0, 1)
		If ($iDEL < 0) Or ($iDEL > $UBound2nd - 1) Then Return SetError(3, 0, 1)
	Else
		If ($iDEL < 0) Or ($iDEL > UBound($ARRAY) - 1) Then Return SetError(3, 0, 1)
	EndIf
	If $UBound2nd = 0 Then
		Local $arTmp[UBound($ARRAY) - 1]
		$k = 0
		For $i = 0 To UBound($ARRAY) - 1
			If $i <> $iDEL Then
				$arTmp[$k] = $ARRAY[$i]
				$k += 1
			EndIf
		Next
	Else
		If $bCOL Then
			Local $arTmp[UBound($ARRAY)][$UBound2nd - 1]
			For $i = 0 To UBound($ARRAY) - 1
				$k = 0
				For $l = 0 To $UBound2nd - 1
					If $l <> $iDEL Then
						$arTmp[$i][$k] = $ARRAY[$i][$l]
						$k += 1
					EndIf
				Next
			Next
		Else
			Local $arTmp[UBound($ARRAY) - 1][$UBound2nd]
			$k = 0
			For $i = 0 To UBound($ARRAY) - 1
				If $i <> $iDEL Then
					For $l = 0 To $UBound2nd - 1
						$arTmp[$k][$l] = $ARRAY[$i][$l]
					Next
					$k += 1
				EndIf
			Next
		EndIf
	EndIf
	$ARRAY = $arTmp
	Return $ARRAY
EndFunc   ;==>_Array2DDelete

Func Trim($String)
	Return StringReplace($String, " ", "", 0, 2)
EndFunc   ;==>Trim

Func GetCurrentPos()
	;	Local $mesurepos = TimerInit() ;;;;;;;;;;;;;;
	Dim $return[3]

	$return[0] = _MemoryRead($_Myoffset + 0x0A0, $d3, 'float')
	$return[1] = _MemoryRead($_Myoffset + 0x0A4, $d3, 'float')
	$return[2] = _MemoryRead($_Myoffset + 0x0A8, $d3, 'float')

	$Current_Hero_X = $return[0]
	$Current_Hero_Y = $return[1]
	$Current_Hero_Z = $return[2]

	;		Local $difmesurepos = TimerDiff($mesurepos) ;;;;;;;;;;;;;
	;ConsoleWrite("Mesure getcurrentpos :" & $difmesurepos &@crlf) ;FOR DEBUGGING;;;;;;;;;;;;
	Return $return
EndFunc   ;==>GetCurrentPos

Func Load_Configs()
	$nameSequenceTxt = IniRead($profilFile, "file info", "nameSequenceTxt", $nameSequenceTxt)
	$PictureScene = IniRead($profilFile, "file info", "PictureScene", $PictureScene)
	$Picturemtp = IniRead($profilFile, "file info", "Picturemtp", $Picturemtp)
	$nameObjectListTxt = IniRead($profilFile, "file info", "nameObjectListTxt", $nameObjectListTxt)
	
	$DrawScene = IniRead($profilFile, "draw info", "DrawScene", $DrawScene)
	$DrawNavCellWalkable = IniRead($profilFile, "draw info", "DrawNavCellWalkable", $DrawNavCellWalkable)
	$DrawNavCellUnWalkable = IniRead($profilFile, "draw info", "DrawNavCellUnWalkable", $DrawNavCellUnWalkable)
	$DrawArrow = IniRead($profilFile, "draw info", "DrawArrow", $DrawArrow)
	$DrawMtp = IniRead($profilFile, "draw info", "DrawMtp", $DrawMtp)
	
	$SceneColor = IniRead($profilFile, "draw info", "SceneColor", $SceneColor)
	$NavcellWalkableColor = IniRead($profilFile, "draw info", "NavcellWalkableColor", $NavcellWalkableColor)
	$NavcellUnWalkableColor = IniRead($profilFile, "draw info", "NavcellUnWalkableColor", $NavcellUnWalkableColor)
	$ArrawColor = IniRead($profilFile, "draw info", "ArrawColor", $ArrawColor)
	$MtpColor = IniRead($profilFile, "draw info", "MtpColor", $MtpColor)
EndFunc

Func startIterateObjectsList(ByRef $index, ByRef $offset, ByRef $count)
	$count = _MemoryRead($_itrObjectManagerCount, $d3, 'int')
	$index = 0
	$offset = $_itrObjectManagerD
EndFunc   ;==>startIterateObjectsList


Func iterateObjectsList(ByRef $index, ByRef $offset, ByRef $count, ByRef $item)
	If $index > $count Then
		Return False
	EndIf
	$index += 1
	Local $iterateObjectsListStruct = DllStructCreate("byte[4];ptr;char[64];byte[104];float;float;float;byte[264];int;byte[8];int;byte[44];int")
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')
	$item[0] = DllStructGetData($iterateObjectsListStruct, 2) ; Guid
	$item[1] = DllStructGetData($iterateObjectsListStruct, 3) ; Name
	$item[2] = DllStructGetData($iterateObjectsListStruct, 5) ; x
	$item[3] = DllStructGetData($iterateObjectsListStruct, 6) ; y
	$item[4] = DllStructGetData($iterateObjectsListStruct, 7) ; z
	$item[5] = DllStructGetData($iterateObjectsListStruct, 13) ; data 1
	$item[6] = DllStructGetData($iterateObjectsListStruct, 11) ; data 2
	$item[7] = DllStructGetData($iterateObjectsListStruct, 9) ; data 3
	$item[8] = $offset
	;$item[9] = getDistance($item[2], $item[3], $item[4]) ; Distance
	$iterateObjectsListStruct = ""
	$offset = $offset + $_ObjmanagerStrucSize

	Return True

EndFunc   ;==>iterateObjectsList
