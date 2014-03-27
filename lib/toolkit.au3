#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=lib\ico\icon.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;;================================================================================
;;================================================================================
;;      Diablo 3 Au3 ToolKit
;;  Based on Unkn0wned, voxatu & the RE community works
;;
;;  By Opkllhibus, Leo11173, Kickbar
;;================================================================================
;;================================================================================
;;================================================================================
;; PRE FUNCTIONS
;;================================================================================
;;--------------------------------------------------------------------------------
;;      Make sure you are running as admin
;;--------------------------------------------------------------------------------

$Admin = IsAdmin()
If $Admin <> 1 Then
	MsgBox(0x30, "ERROR", "This program require administrative rights you fool!")
	Exit
EndIf

;;--------------------------------------------------------------------------------
;;      Includes
;;--------------------------------------------------------------------------------

#include <math.au3>
#include <String.au3>
#include <Array.au3>
#include "Variables.au3"
#include "constants.au3"
#include "Utils.au3"
#include "ExpTableConst.au3"
#include "NomadMemory.au3"
 ;THIS IS EXTERNAL, GET IT AT THE AUTOIT WEBSITE

;;--------------------------------------------------------------------------------
;;      Initialize MouseCoords
;;--------------------------------------------------------------------------------
Opt("MouseCoordMode", 2) ;1=absolute, 0=relative, 2=client
Opt("MouseClickDownDelay", Random(10, 20))
Opt("SendKeyDownDelay", Random(10, 20))

;;--------------------------------------------------------------------------------
;;      Open the process
;;--------------------------------------------------------------------------------
Opt("WinTitleMatchMode", -1)
SetPrivilege("SeDebugPrivilege", 1)
Global $ProcessID = WinGetProcess("[CLASS:D3 Main Window Class]", "")
Local $d3 = _MemoryOpen($ProcessID)
If @error Then
	WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
	MsgBox(4096, "ERROR", "Failed to open memory for process;" & $ProcessID)
	Exit
EndIf

;OffsetList()

;;================================================================================
;; FUNCTIONS
;;================================================================================

Func CheckWindowD3()
	If WinExists("[CLASS:D3 Main Window Class]") Then
		WinActivate("[CLASS:D3 Main Window Class]")
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 1)
		Sleep(300)
	Else
		MsgBox(0, Default, "Fenêtre Diablo III absente.")
		Terminate()
	EndIf
EndFunc   ;==>CheckWindowD3

Func CheckWindowD3Size()
	$sized3 = WinGetClientSize("[CLASS:D3 Main Window Class]")
	If $sized3[0] <> $SizeWindows[0] Or $sized3[1] <> $SizeWindows[1] Then
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
		MsgBox(0, Default, "Erreur Dimension : Taille changée " & $sized3[0] & " x " & $sized3[1] & " -> " & $SizeWindows[0] & " x " & $SizeWindows[1])
		Terminate()

	EndIf
EndFunc   ;==>CheckWindowD3Size
;;--------------------------------------------------------------------------------
; Function:                     FindActor()
; Description:          Check if an actor is present or not
;
; Note(s):              Return 1 if found in range or 0 if absent
;;--------------------------------------------------------------------------------
Func FindActor($name, $maxRange = 400)

	If _ingame() Then
		While Not offsetlist()
			Sleep(10)
		WEnd
	Else
		offsetlist()
	EndIF

	Local $index, $offset, $count, $item[10]
	startIterateObjectsList($index, $offset, $count)
	_log("FinActor -> number -> " & $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], $name) And $item[9] < $maxRange Then
			Return True
		EndIf
	WEnd

	Return False
EndFunc   ;==>FindActor

Func ClickUI($name, $bucket = -1)
	If $bucket = -1 Then ;no bucket given slow method
		$result = GetOfsUI($name, 1)
	Else ;bucket given, fast method
		$result = GetOfsFastUI($name, $bucket)
	EndIf

	If $result = False Then
		_log("(ClickUI) UI DOESNT EXIT ! -> " & $name & " (" & $bucket  & ")")
		return false
	EndIf

	Dim $Point = GetPositionUI($result)

	While $Point[0] = 0 And $Point[1] = 0
		$Point = GetPositionUI($result)
		sleep(250)
	WEnd

	Dim $Point2 = GetUIRectangle($Point[0], $Point[1], $Point[2], $Point[3])

	MouseClick("left", $Point2[0] + $Point2[2] / 2, $Point2[1] + $Point2[3] / 2)
EndFunc

Func GetUIRectangle($x, $y, $r, $b)
	Dim $Point[4]

	$size = WinGetClientSize("[CLASS:D3 Main Window Class]")
	$resolutionX = $size[0]
	$resolutionY = $size[1]

	$fourthreewidth = ($size[1] / 3.0) * 4.0
	$mbRatio = 600.0 / $size[1]
	$mb = ($size[0] - $fourthreewidth) * $mbRatio
	$sx = ($x + $mb) / (1200.0 / $size[1])
	$sr = ($r + $mb) / (1200.0 / $size[1])
	$sy = $y * ($size[1] / 1200.0)
	$sb = ($b-1) * ($size[1] / 1200.0)

	_log("sx : " & $sx & " - sy : " & $sy & " - right : " & $sr - $sx & " - bottom : " & $sb - $sy)

	Dim $Point[4] = [$sx, $sy, $sr - $sx, $sb - $sy]

	return $Point

EndFunc

Func fastcheckuiitemvisible($valuetocheckfor, $visibility, $bucket)

	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")
	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")

	$UiPtr = _memoryread($BuckitOfs + ($bucket * 0x4), $d3, "ptr")

	while $UiPtr <> 0
		$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
		$Visible = BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)
		if $Visibility = 1 AND $Visible = 4 Then
			$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
			If StringInStr($name, $valuetocheckfor) Then
				return true
			EndIf
		ElseIf $Visibility = 0 Then
			$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
			If StringInStr($name, $valuetocheckfor) Then
				return true
			EndIf
		EndIf

		$UiPtr = _memoryread($UiPtr, $d3, "ptr")
	WEnd
	return false
Endfunc

Func GetOfsFastUI($valuetocheckfor, $bucket)

	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")
	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")

	$UiPtr = _memoryread($BuckitOfs + ($bucket * 0x4), $d3, "ptr")

	while $UiPtr <> 0
		$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
			$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
			If StringInStr($name, $valuetocheckfor) Then
				return $nPtr
			EndIf
		$UiPtr = _memoryread($UiPtr, $d3, "ptr")
	WEnd

	return false
EndFunc

Func fastcheckuiitemactived($valuetocheckfor, $bucket)
	$uiOfs = GetOfsFastUI($valuetocheckfor, $bucket)
	$Enabled = Mod(_memoryread($uiOfs + 0xc5c, $d3, "int"), 2)
	_log($Enabled)
	if $Enabled = 1 Then
		return True
	Else
		return false
	EndIF
	;_log($uiOfs & " - " & _memoryread($uiOfs + 0xc5c, $d3, "ptr") & " - " & $Enabled)
EndFunc

Func GetTextUI($bucket, $valuetocheckfor)
	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")
	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")

	$UiPtr = _memoryread($BuckitOfs + ($bucket * 0x4), $d3, "ptr")
	while $UiPtr <> 0

		$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
		$Visible = BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)

		if $Visible = 4 Then
			$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)

			If StringInStr($name, $valuetocheckfor) Then
				$text = BinaryToString(_memoryread(_memoryread($nPtr + $Ofs_UI_Text, $d3, "ptr"),$d3, "byte[1024]"), 4)
				return $text
			endif

		EndIf

		$UiPtr = _memoryread($UiPtr, $d3, "ptr")
	WEnd

	return false
Endfunc

Func GetOfsUI($valuetocheckfor, $IsVisible=0)

	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")
	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")
	$UiCount = _memoryread($UiPtr3 + $Ofs_UI_D, $d3, "int")


	for $g=0 to $UiCount - 1
		$UiPtr = _memoryread($BuckitOfs, $d3, "ptr")
		while $UiPtr <> 0
			$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
			$Visible = BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)

			if $Visible = 4 OR $IsVisible = 0 Then
				$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
				If StringInStr($Name, $valuetocheckfor) Then
					return $nPtr
				endif
			EndIf

			$UiPtr = _memoryread($UiPtr, $d3, "ptr")
		WEnd
		$BuckitOfs = $BuckitOfs + 0x4
	Next

	return false
EndFunc

Func GetPositionUI($ofs)
	Dim $point[4]

	$point[0] = _MemoryRead($ofs + 0x4D8, $d3, "float")
	$point[1] = _MemoryRead($ofs + 0x4DC, $d3, "float")
	$point[2] = _MemoryRead($ofs + 0x4E0, $d3, "float")
	$point[3] = _MemoryRead($ofs + 0x4E4, $d3, "float")

	_log("x : " & $point[0] & " - y : " & $point[1] & " - r : " & $point[2] & " - b : " & $point[3])

	return $point
EndFunc

Func CheckTextvalueUI($bucket, $valuetocheckfor, $textcheck)
	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")
	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")

	$UiPtr = _memoryread($BuckitOfs + ($bucket * 0x4), $d3, "ptr")
	while $UiPtr <> 0

		$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
		$Visible = BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)
;_log("$Visible : " & $Visible)
		if $Visible = 4 Then

			$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
_log( "$valuetocheckfor : " & $valuetocheckfor)
_log("$Name : " & $Name )
			If StringInStr($name, $valuetocheckfor) Then
				$text = BinaryToString(_memoryread(_memoryread($nPtr + $Ofs_UI_Text, $d3, "ptr"),$d3, "byte[1024]"), 4)
	_log("$text : " & $text )
	_log("$textcheck : " & $textcheck )
				If StringInStr($text, $textcheck) Then
					return true
				Else
					return false
				EndIF
			endif

		EndIf

		$UiPtr = _memoryread($UiPtr, $d3, "ptr")
	WEnd

	return false
EndFunc



Func _playerdead()
	$return = fastcheckuiitemvisible("Root.NormalLayer.deathmenu_dialog", 1, 793)
	If ($return And $DeathCountToggle) Then
		$Death += 1
		$Die2FastCount += 1
		$DeathCountToggle = False
	EndIf
	Return $return
EndFunc   ;==>_playerdead OK

Func _inmenu()
	Return fastcheckuiitemvisible("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.PlayGameButton", 1, 1929)
EndFunc   ;==>_inmenu OK

Func _checkdisconnect()
    Return fastcheckuiitemvisible("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 1, 2022)
EndFunc   ;==>_checkdisconnect OK

Func _checkRepair()
	Return fastcheckuiitemvisible("Root.NormalLayer.DurabilityIndicator", 1, 895)
EndFunc   ;==>_checkRepair OK

Func _onloginscreen()
	Return fastcheckuiitemvisible("Root.NormalLayer.BattleNetLogin_main.LayoutRoot.LoginContainer.unnamed30", 1, 51)
EndFunc   ;==>_onloginscreen OK

Func _escmenu()
	Return fastcheckuiitemvisible("Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame", 1, 1644)
EndFunc   ;==>_escmenu OK

Func _ingame()
	Return fastcheckuiitemvisible("Root.NormalLayer.minimap_dialog_backgroundScreen.minimap_dialog_pve", 1, 1403)
EndFunc   ;==>_ingame OK
Func _checkSalvageopen()
	Return fastcheckuiitemvisible("Root.NormalLayer.vendor_dialog_mainPage.salvage_dialog.salvage_button", 1, 629)
EndFunc   ;==>_checkSalvageopen OK
Func _checkWPopen()
    Return fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot", 1, 2033)
EndFunc   ;==>_checkWPopen OK
Func _checkVendoropen()
	Return fastcheckuiitemvisible("Root.NormalLayer.shop_dialog_mainPage.gold_label", 1, 165)
EndFunc   ;==>_checkVendoropen OK
Func _checkStashopen()
	Return fastcheckuiitemvisible("Root.NormalLayer.stash_dialog_mainPage", 1, 327)
EndFunc   ;==>_checkStashopen OK
Func _checkBannerOpen()
	Return fastcheckuiitemvisible("Root.NormalLayer.BattleNetProfileBannerCustomization_main.LayoutRoot.OverlayContainer.PageHeader", 1, 1697)
EndFunc
Func _checkParagonOpen()
	Return fastcheckuiitemvisible("Root.NormalLayer.Paragon_main.LayoutRoot", 1, 377)
EndFunc
Func _checkInventoryopen()
	Return fastcheckuiitemvisible("Root.NormalLayer.inventory_dialog_mainPage", 1, 1813)
EndFunc   ;==>_checkInventoryopen OK


;;--------------------------------------------------------------------------------
; Function:			IsInArea($area)
; Description:		Check where we are
;
;;--------------------------------------------------------------------------------
Func IsInArea($area)
	$area = GetLevelAreaId()
	_log("Area " & $area)
	Return $area = GetLevelAreaId()
EndFunc   ;==>IsInArea

Func GetLevelAreaId()
	Return _MemoryRead(_MemoryRead($OfsLevelAreaId, $d3, "int") + 0x44, $d3, "int")
EndFunc   ;==>GetLevelAreaId

;;--------------------------------------------------------------------------------
;;     Find which Act we are in
;;--------------------------------------------------------------------------------
Func GetAct()
	If $Act = 0 Then
		$arealist = FileRead("lib\area.txt")
		$area = GetLevelAreaId()

		_log(" We are in map : " & $area)
		Local $pattern = "([\w'-]{5,80})\t\W\t" & $area
		$asResult = StringRegExp($arealist, $pattern, 1)
		If @error == 0 Then
			Global $MyArea = $asResult[0]

			If StringInStr($MyArea, "a1") Then
				$Act = 1
			ElseIf StringInStr($MyArea, "a2") Then
				$Act = 2
			ElseIf StringInStr($MyArea, "a3") Then
				$Act = 3
			ElseIf StringInStr($MyArea, "a4") Then
				$Act = 4
			EndIf
			;  _log("We are in map : " & $area &" " & $asResult[0])

			;set our vendor aaccording to the act we are in as we know it.
			Switch $Act
				Case 1
					Global $RepairVendor = "UniqueVendor_miner_InTown"
					Global $PotionVendor = "UniqueVendor_Collector_InTown"

				Case 2
					Global $RepairVendor = "UniqueVendor_Peddler_InTown" ; act 2 fillette
					Global $PotionVendor = "UniqueVendor_Peddler_InTown"

				Case 3
					Global $RepairVendor = "UniqueVendor_Collector_InTown" ; act 3
					Global $PotionVendor = "UniqueVendor_Collector_InTown"

				Case 4
					Global $RepairVendor = "UniqueVendor_Collector_InTown" ; act 3
					Global $PotionVendor = "UniqueVendor_Collector_InTown"

			EndSwitch
			_log("Our Current Act is : " & $Act & " ---> So our vendor is : " & $RepairVendor)

		EndIf
	EndIf
EndFunc   ;==>GetAct

;;--------------------------------------------------------------------------------
;;     Find MP MF handicap
;;	   Get MF handicap and deduce game MP from it
;;
;;--------------------------------------------------------------------------------
Func GetMonsterPow()
	$MfCap = (IterateActorAtribs($_MyGuid, $Atrib_Magic_Find_Handicap) * 10)
	$MP = Round($MfCap, 0)
	_log("Power monster : " & $MP)
EndFunc   ;==>GetMonsterPow

;;--------------------------------------------------------------------------------
; Function:			TownStateCheck()
; Description:		Check if we are in town or not by comparing distance from stash
;
;;--------------------------------------------------------------------------------
Func _intown()
	_log("-----Checking if In Town------")
	$town = findActor('Player_Shared_Stash', 448)
	If $town Then
		_log("We are in town ")
		Return True
	Else
		_log("We are NOT in town ")
		Return False
	EndIf
EndFunc   ;==>_intown
;==>TownStateCheck

;;--------------------------------------------------------------------------------
;;	Getting Backpack Item Info
;;  Ok with d3 2.0
;;--------------------------------------------------------------------------------
Func IterateBackpack($bag = 0, $rlvl = 0)
	;$bag = 0 for backpack and 15 for stash
	;$rlvl = 1 for actual level requirement of item and 0 for base required level
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8b8, $d3, "ptr")
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "ptr")
	$_Count = _memoryread($ptr3 + 0x108, $d3, "int")
	$CurrentOffset = _memoryread(_memoryread($ptr3 + 0x120, $d3, "ptr") + 0x0, $d3, "ptr");$_LocalActor_3
	Local $__ACDACTOR[$_Count + 1][9]
	;_log(" IterateBackpack 1 ")
	For $i = 0 To $_Count
		Local $iterateItemListStruct = DllStructCreate("ptr;char[64];byte[112];int;byte[92];int;int;int;ptr")

		DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $CurrentOffset, 'ptr', DllStructGetPtr($iterateItemListStruct), 'int', DllStructGetSize($iterateItemListStruct), 'int', '')


		$__ACDACTOR[$i][0] = DllStructGetData($iterateItemListStruct, 1)
		$__ACDACTOR[$i][1] = DllStructGetData($iterateItemListStruct, 2)
		$__ACDACTOR[$i][8] = DllStructGetData($iterateItemListStruct, 4)
		$__ACDACTOR[$i][2] = DllStructGetData($iterateItemListStruct, 6)
		$__ACDACTOR[$i][3] = DllStructGetData($iterateItemListStruct, 7)
		$__ACDACTOR[$i][4] = DllStructGetData($iterateItemListStruct, 8)
		$__ACDACTOR[$i][5] = 0
		$__ACDACTOR[$i][6] = DllStructGetData($iterateItemListStruct, 9)
		$__ACDACTOR[$i][7] = $CurrentOffset
		$CurrentOffset = $CurrentOffset + $ofs_LocalActor_StrucSize
		$iterateItemListStruct = ""

	Next


		For $i = $_Count To 0 Step -1
			If $__ACDACTOR[$i][2] <> $bag Then
				_ArrayDelete($__ACDACTOR, $i)
			EndIf
		Next

	;_Arraydisplay($__ACDACTOR)
	Return $__ACDACTOR

EndFunc   ;==>IterateBackpack

Func Iteratestuff()
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8b8, $d3, "ptr") ;8a0
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "ptr")
	$_Count = _memoryread($ptr3 + 0x108, $d3, "int")

	$count = 0
	$CurrentOffset = _memoryread(_memoryread($ptr3 + 0x120, $d3, "ptr") + 0x0, $d3, "ptr") ;$_LocalActor_3
	Local $__ACDACTOR[1][9]

	For $i = 0 To $_Count
		Local $iterateItemListStruct = DllStructCreate("ptr;char[64];byte[112];int;byte[92];int;int;int;ptr")
		DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $CurrentOffset, 'ptr', DllStructGetPtr($iterateItemListStruct), 'int', DllStructGetSize($iterateItemListStruct), 'int', '')

		if DllStructGetData($iterateItemListStruct, 6) >= 1 AND DllStructGetData($iterateItemListStruct, 6) <= 13 Then

			Redim $__ACDACTOR[$count+1][9]
			$__ACDACTOR[$count][0] = DllStructGetData($iterateItemListStruct, 1)
			$__ACDACTOR[$count][1] = DllStructGetData($iterateItemListStruct, 2)
			$__ACDACTOR[$count][8] = DllStructGetData($iterateItemListStruct, 4)
			$__ACDACTOR[$count][2] = DllStructGetData($iterateItemListStruct, 6)
			$__ACDACTOR[$count][3] = DllStructGetData($iterateItemListStruct, 7)
			$__ACDACTOR[$count][4] = DllStructGetData($iterateItemListStruct, 8)
			$__ACDACTOR[$count][5] = 0
			$__ACDACTOR[$count][6] = DllStructGetData($iterateItemListStruct, 9)
			$__ACDACTOR[$count][7] = $CurrentOffset
			$count += 1
		EndIf

		$CurrentOffset = $CurrentOffset + $ofs_LocalActor_StrucSize
		$iterateItemListStruct = ""

	Next

	Return $__ACDACTOR
EndFunc

Func Load_Attrib_GlobalStuff()

Global $Check_HandLeft_Seed = 0
Global $Check_HandRight_Seed = 0
Global $Check_RingLeft_Seed = 0
Global $Check_RingRight_Seed = 0
Global $Check_Amulet_Seed = 0
Global $Check_ArmorTotal = 0

	$table = Iteratestuff()
		for $i=0 to ubound($table) - 1
			if ($table[$i][2] >= 3 AND $table[$i][2] <= 4) OR $table[$i][2] >= 11 Then
				If $table[$i][2] = 3 Then ;Weapon1
					$Check_HandLeft_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
				ElseIf $table[$i][2] = 4 Then ;Weapon2
					$Check_HandRight_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
				ElseIf $table[$i][2] = 11 Then ;Ring1
					$Check_RingLeft_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
				ElseIf $table[$i][2] = 12 Then ;Ring
					$Check_RingRight_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
				ElseIf $table[$i][2] = 13 Then ;Amulette
					$Check_Amulet_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
				EndIf
			EndIf
		Next
		$Check_ArmorTotal = GetAttribute($_myguid, $Atrib_Armor_Item_Total)

		_log("Load_Attrib_GlobalStuff() Result :")
		_log("$Check_HandLeft_Seed -> " & $Check_HandLeft_Seed)
		_log("$Check_HandRight_Seed -> " & $Check_HandRight_Seed)
		_log("$Check_RingLeft_Seed -> " & $Check_RingLeft_Seed)
		_log("$Check_RingRight_Seed -> " & $Check_RingRight_Seed)
		_log("$Check_Amulet_Seed -> " & $Check_Amulet_Seed)
		_log("$Check_ArmorTotal -> " & $Check_ArmorTotal)

EndFunc

Func Verif_Attrib_GlobalStuff()

	If $InventoryCheck Then

		Local $HandLeft_Seed = 0
		Local $HandRight_Seed = 0
		Local $RingLeft_Seed = 0
		Local $RingRight_Seed = 0
		Local $Amulet_Seed = 0
		Local $ArmorTotal = 0

		$table = Iteratestuff()
			for $i=0 to ubound($table) - 1
				if ($table[$i][2] >= 3 AND $table[$i][2] <= 4) OR $table[$i][2] >= 11 Then
					If $table[$i][2] = 3 Then ;Weapon1
						$HandLeft_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
					ElseIf $table[$i][2] = 4 Then ;Weapon2
						$HandRight_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
					ElseIf $table[$i][2] = 11 Then ;Ring1
						$RingLeft_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
					ElseIf $table[$i][2] = 12 Then ;Ring
						$RingRight_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
					ElseIf $table[$i][2] = 13 Then ;Amulette
						$Amulet_Seed = GetAttribute(_memoryread(GetACDOffsetByACDGUID($table[$i][0]) + 0x120, $d3, "ptr"), $Atrib_Seed)
					EndIf
				EndIf
			Next
			$ArmorTotal = GetAttribute($_myguid, $Atrib_Armor_Item_Total)

			if $HandLeft_Seed <> $Check_HandLeft_Seed Then
				If $HandLeft_Seed = 0 AND $Check_HandLeft_Seed <> 0 Then
					_log("-> Weapon Left Dropped")
				Else
					_log("-> Weapon Left switched")
				EndIf
				return False
			ElseIf $HandRight_Seed <> $Check_HandRight_Seed Then
				If $HandRight_Seed = 0 AND $Check_HandRight_Seed <> 0 Then
					_log("-> Weapon Right Dropped")
				Else
					_log("-> Weapon Right switched")
				EndIf
				return False
			ElseIf $RingLeft_Seed <> $Check_RingLeft_Seed Then
				If $RingLeft_Seed = 0 AND $Check_RingLeft_Seed <> 0 Then
					_log("-> Ring Left Dropped")
				Else
					_log("-> Ring Left switched")
				EndIf
				return False
			ElseIf $RingRight_Seed <> $Check_RingRight_Seed Then
				If $RingRight_Seed = 0 AND $Check_RingRight_Seed <> 0 Then
					_log("-> Ring Right Dropped")
				Else
					_log("-> Ring Right switched")
				EndIf
				return False
			ElseIF $ArmorTotal <> $Check_ArmorTotal Then
					_log("-> Armor Total changed")
				return False
			EndIf

			_log("Checking stuff successful")
			return true

	Else
		_log("Checking stuff Disable")
		return true
	EndIF
EndFunc

Func antiidle()
	$warnloc = GetCurrentPos()
	$warnarea = GetLevelAreaId()
	_log("Lost detected at : " & $warnloc[0] & ", " & $warnloc[1] & ", " & $warnloc[2], True);
	_log("Lost area : " & $warnarea, True);


	If _checkInventoryopen() = False Then
	        Send($KeyInventory)
	        Sleep(150)
	Endif

	Send("{PRINTSCREEN}")
	sleep(150)
	Send($KeyCloseWindows)

	ToolTip("Detection de stuff modifié !" & @CRLF & "Zone : " & $warnarea & @CRLF &  "Position : "  & $warnloc[0] & ", " & $warnloc[1] & ", " & $warnloc[2] & @CRLF & "Un screenshot a été pris, il se situe dans document/diablo 3" , 15, 15)


	While Not _intown()
	    _TownPortalnew()
		sleep(100)
	WEnd

	;idleing
	While 1
	MouseClick($MouseMoveClick, Random(100, 200), Random(100, 200), 1, 6)
	Sleep(Random(40000, 180000))
	MouseClick($MouseMoveClick, Random(600, 700), Random(100, 200), 1, 6)
	Sleep(Random(40000, 180000))
	MouseClick($MouseMoveClick, Random(600, 700), Random(400, 500), 1, 6)
	Sleep(Random(40000, 180000))
	MouseClick($MouseMoveClick, Random(100, 200), Random(400, 500), 1, 6)
	Sleep(Random(40000, 180000))
	Wend

Endfunc

Func triBackPack($avArray)

	Dim $tab0[1][8]
	Dim $tab1[1][8]
	Dim $tab2[1][8]
	Dim $tab3[1][8]
	Dim $tab4[1][8]
	Dim $tab5[1][8]

	Dim $tab_final[1][8]

	local $compt5=0, $compt4=0, $compt3=0, $compt2=0, $compt1=0, $compt0=0, $compt_total=0

	_ArraySort($avArray, 0, 0, 0, 4)


	for $i=0 to Ubound($avArray) - 1

		If $avArray[$i][4] = 0 Then
			$compt0 += 1
			Redim $tab0[$compt0][8]
				for $y=0 to 7
					$tab0[$compt0-1][$y] = $avArray[$i][$y]
				Next
		ElseIf $avArray[$i][4] = 1 Then
			$compt1 += 1
			Redim $tab1[$compt1][8]
				for $y=0 to 7
					$tab1[$compt1-1][$y] = $avArray[$i][$y]
				Next
		ElseIf $avArray[$i][4] = 2 Then
			$compt2 += 1
			Redim $tab2[$compt2][8]
				for $y=0 to 7
					$tab2[$compt2-1][$y] = $avArray[$i][$y]
				Next
		ElseIf $avArray[$i][4] = 3 Then
			$compt3 += 1
			Redim $tab3[$compt3][8]
				for $y=0 to 7
					$tab3[$compt3-1][$y] = $avArray[$i][$y]
				Next
		ElseIf $avArray[$i][4] = 4 Then
			$compt4 += 1
			Redim $tab4[$compt4][8]
				for $y=0 to 7
					$tab4[$compt4-1][$y] = $avArray[$i][$y]
				Next
		ElseIf $avArray[$i][4] = 5 Then
			$compt5 += 1
			Redim $tab5[$compt5][8]
				for $y=0 to 7
					$tab5[$compt5-1][$y] = $avArray[$i][$y]
				Next
		EndIf
	Next

	_ArraySort($tab0, 0, 0, 0, 3)
	_ArraySort($tab1, 0, 0, 0, 3)
	_ArraySort($tab2, 0, 0, 0, 3)
	_ArraySort($tab3, 0, 0, 0, 3)
	_ArraySort($tab4, 0, 0, 0, 3)
	_ArraySort($tab5, 0, 0, 0, 3)

	for $i=0 To Ubound($tab0) - 1

		if $tab0[$i][0] <> "" Then
			$compt_total +=1
			Redim $tab_final[$compt_total][8]
			for $y=0 To 7
				 $tab_final[$compt_total-1][$y] = $tab0[$i][$y]
			Next
		EndIf
	Next

	for $i=0 To Ubound($tab1) - 1

		if $tab1[$i][0] <> "" Then
			$compt_total +=1
			Redim $tab_final[$compt_total][8]
			for $y=0 To 7
				 $tab_final[$compt_total-1][$y] = $tab1[$i][$y]
			Next
		EndIf
	Next

	for $i=0 To Ubound($tab2) - 1

		if $tab2[$i][0] <> "" Then
			$compt_total +=1
			Redim $tab_final[$compt_total][8]
			for $y=0 To 7
				 $tab_final[$compt_total-1][$y] = $tab2[$i][$y]
			Next
		EndIf
	Next

	for $i=0 To Ubound($tab3) - 1

		if $tab3[$i][0] <> "" Then
			$compt_total +=1
			Redim $tab_final[$compt_total][8]
			for $y=0 To 7
				 $tab_final[$compt_total-1][$y] = $tab3[$i][$y]
			Next
		EndIf
	Next

	for $i=0 To Ubound($tab4) - 1

		if $tab4[$i][0] <> "" Then
			$compt_total +=1
			Redim $tab_final[$compt_total][8]
			for $y=0 To 7
				 $tab_final[$compt_total-1][$y] = $tab4[$i][$y]
			Next
		EndIf
	Next

	for $i=0 To Ubound($tab5) - 1

		if $tab5[$i][0] <> "" Then
			$compt_total +=1
			Redim $tab_final[$compt_total][8]
			for $y=0 To 7
				 $tab_final[$compt_total-1][$y] = $tab5[$i][$y]
			Next
		EndIf
	Next

	return $tab_final
EndFunc

Func FilterBackpack()

	;;;$Uni_manuel = false ; pacht 1.08
	Local $__ACDACTOR = triBackPack(IterateBackpack(0))
	Local $iMax = UBound($__ACDACTOR)

	If $iMax > 0 Then

		Local $return[$iMax][4]

		Send($KeyCloseWindows) ; make sure we close everything
		Send($KeyInventory) ; open the inventory
		Sleep(100)

		CheckWindowD3Size()
        ;_checkbackpacksize()

		If Not $Unidentified Then
			Take_BookOfCain()
		;;;Else
			;;;$Uni_manuel = true ; pacht 1.08
		EndIf

		For $i = 0 To $iMax - 1 ;c'est ici que l'on parcour (tours a tours) l'ensemble des items contenut dans notres bag

			$ACD = GetACDOffsetByACDGUID($__ACDACTOR[$i][0])
			$CurrentIdAttrib = _memoryread($ACD + 0x120, $d3, "ptr")
			$quality = GetAttribute($CurrentIdAttrib, $Atrib_Item_Quality_Level) ;on definit la quality de l'item traiter ici
			If ($quality = 9) Then
				If Not $PartieSolo Then WriteMe($WRITE_ME_HAVE_LEGENDARY) ; TChat
				$nbLegs += 1 ; on definit les legendaire et on compte les legs id au coffre
			ElseIf ($quality = 6) Then
				$nbRares += 0 ; on definit les rares
			EndIf

			$itemDestination = CheckItem($__ACDACTOR[$i][0], $__ACDACTOR[$i][1], 1) ;on recupere ici ce que l'on doit faire de l'objet (stash/inventaire/trash)

			;;;If $Uni_manuel = true Then ; pacht 1.08
				;;;If $quality >= 6 And _MemoryRead($__ACDACTOR[$i][7] + 0x164, $d3, 'int') > 0 And ($itemDestination <> "Stash" Or trim(StringLower($Unidentified)) = "false") Then ; pacht 1.08
				;Ici on verifie que la qualité est bien superieur a 6 et que l'item as besoin d'etre identifier, si l'item doit aller dans le stash ou si on definit Unidentified a false
				;Il faudra modifier/ajouter quelque chose ici pour gerer les uni sur les oranges et modifier le nom de la variable Unidentified !


	;				InventoryMove($__ACDACTOR[$i][3], $__ACDACTOR[$i][4]) ;met la souris sur l'item

	;				If IterateActorAtribs($__ACDACTOR[$i][0], $Atrib_Item_Quality_Level) > 8 Then ;verifie la quality de l'item pour connaitre le temps necessaire a l'identification de ce dernier
	;					Sleep(Random(250, 400))
	;					MouseClick("Right")
	;					Sleep(Random(4000, 4500))
	;				Else
	;					Sleep(Random(250, 400))
	;					MouseClick("Right")
	;					Sleep(Random(1000, 1500))
	;				EndIf

				;;;EndIf
			;;;EndIf

			$return[$i][0] = $__ACDACTOR[$i][3] ;definit la collone de l'item
			$return[$i][1] = $__ACDACTOR[$i][4] ;definit la ligne de l'item
			$return[$i][3] = $quality

			;;;If $itemDestination = "Stash_Filtre" And trim(StringLower($Unidentified)) = "false" Then ;Si c'est un item à filtrer et que l'on a definit Unidentified sur false (il faudra juste changer le nom de la variable Unidentifier); pacht 1.08
			If $itemDestination = "Stash_Filtre" Then ;Si c'est un item à filtrer
				If checkFiltreFromtable($GrabListTab, $__ACDACTOR[$i][1], $CurrentIdAttrib) Then ;on lance le filtre sur l'item
					_log('valide')
					$return[$i][2] = "Stash"
					$nbRares += 1 ; on conte les rares qu'on met au coffre
				Else
					$return[$i][2] = "Trash"
					_log('invalide')
				EndIf

			Else
				$return[$i][2] = $itemDestination ;row
			EndIf

		Next

		If $Recycle Then
			For $i = 0 To UBound($return) - 1
				If $return[$i][2] = "Trash" And $return[$i][3] < $QualityRecycle Then ; si QualityRecycle = 9 on recycle jaune,bleu,blanc,-si 6 bleu,blanc , -si 3 blanc et on vend le reste
					$return[$i][2] = "Recycle"
				EndIf
			Next
		EndIf


		Send($KeyCloseWindows) ; make sure we close everything



		Return $return
	EndIf
	Return False
EndFunc   ;==>FilterBackpack


Func _filter2attrib($CurrentIdAttrib, $filter2read)
	If StringInStr($filter2read, "DPS") Then
		;_log("Handling special attrib : "& $filter2read)
		$result = GetAttribute($CurrentIdAttrib, $Atrib_Damage_Weapon_Average_Total_All) * GetAttribute($CurrentIdAttrib, $Atrib_Attacks_Per_Second_Item_Total)
		;_log("the value you search is : "& $result)
		Return $result
	Else
		;_log("will find : "& $filter2read)
		$currattrib = Eval($filter2read)
		If IsArray($currattrib) Then
			$result = Round((GetAttribute($CurrentIdAttrib, $currattrib[0])) * $currattrib[1], 2)
			; _log("the value you search is : "& $result)
			Return $result
		Else
			Return 0
		EndIf
	EndIf
EndFunc   ;==>_filter2attrib

;;================================================================================
; Function:                     LocateMyToon
; Note(s):                      This function is used by the OffsetList to
;                                               get the current player data.
;==================================================================================
Func LocateMyToon()
	$count_locatemytoon = 0
	$idarea = 0
	Global $TableBannedActors = [0]

	If _ingame() Then

			While  $count_locatemytoon <= 1000

				$idarea = GetLevelAreaId()

				if $idarea <> -1 Then
					_log("Looking for local player")

					 $_Myoffset = "0x" & Hex(GetPlayerOffset(), 8) ; pour convertir valeur
					 $_MyGuid = _MemoryRead($_Myoffset + 0x88, $d3, 'ptr')

					$_NAME = _MemoryRead($_Myoffset + 0x4, $d3, 'char[64]')
					$_SNO = _MemoryRead($_Myoffset + 0x8c, $d3, 'ptr')


					_log("name -> " & $_NAME)
					_log("sno -> " & hex($_SNO))
					_log("guid -> " & $_MyGuid)
					_log("ofs -> " & $_Myoffset)

					setChararacter($_NAME)


					$ACD = GetACDOffsetByACDGUID($_MyGuid)

					$name_by_acd = _MemoryRead($ACD + 0x4, $d3, 'char[64]')


					$_MyGuid = _memoryread($ACD + 0x120, $d3, "ptr")
					$_MyACDWorld = _memoryread($ACD + 0x108, $d3, "ptr")

					If NOT trim($_NAME) = ""  Then
						If trim($_NAME) = trim($name_by_acd) Then
					 $_MyCharType = $_NAME

							If $hotkeycheck Then
								If Verif_Attrib_GlobalStuff() Then
									_log("Acd Ofs : " & $ACD)
									return true
								Else
									_log("CHANGEMENT DE STUFF ON TOURNE EN ROND (locatemytoon)!!!!!")
									antiidle()
								EndIf
							Else
								_log("Acd Ofs : " & $ACD)
								return true
							EndIf
						else
							;_log("Fail LocateMyToon, $_NAME <> $name_by_acd -> " & $count_locatemytoon)
							$count_locatemytoon += 1
						EndIf
					else
						;_log("Fail LocateMyToon, Empty $_NAME  -> " & $count_locatemytoon)
						$count_locatemytoon += 1
					EndIf

				Else
					;_log("Fail LocateMyToon, Fail AreaId -> " & $idarea)
					$count_locatemytoon += 1
				EndIf

			Sleep(50)
			WEnd
	Else
		_log("LocateMyToon not possible since we are not in game")
	EndIF

EndFunc   ;==>LocateMyToon

;SetItemLootLevel()
;
;Will set the items quality to be looted
Func SetItemLootLevel()
	$QualityLevel = StringSplit($QualityLevel, "|")
	For $i = 1 to UBound($QualityLevel) -1
		_log("Our qualitilevel is: " & $QualityLevel[$i])
	Next
EndFunc	;==>SetItemLootLevel

;SetSalvageLootLevel()
;
;Will set the items qualitys to be salvaged
Func SetSalvageLootLevel()
	$SalvageQualiteItem = StringSplit($SalvageQualiteItem, "|")
	For $i = 1 to UBound($SalvageQualiteItem) -1
		_log("Our salvagelevel is: " & $SalvageQualiteItem[$i])
	Next
EndFunc	;==>SetSalvageLootLevel


Func GetACDByGuid($Guid, $_displayInfo = 0)
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8b8, $d3, "ptr")
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "ptr")
	$_Count = _memoryread($ptr3 + 0x108, $d3, "int")
	$CurrentOffset = _memoryread(_memoryread($ptr3 + 0x148, $d3, "ptr") + 0x0, $d3, "ptr");$_LocalActor_3
	Global $__ACTOR[$_Count + 1][4]
	For $i = 0 To $_Count
		$__ACTOR[$i][1] = _MemoryRead($CurrentOffset, $d3, 'ptr')
		$__ACTOR[$i][2] = _MemoryRead($CurrentOffset + 0x4, $d3, 'char[64]')
		$__ACTOR[$i][3] = _MemoryRead($CurrentOffset + $ofs_LocalActor_atribGUID, $d3, 'ptr')
		$CurrentOffset = $CurrentOffset + $ofs_LocalActor_StrucSize
		If $__ACTOR[$i][1] = $Guid Then
			If $_displayInfo = 1 Then _log('Count : "' & $i & '" ' & $__ACTOR[$i][1] & "' '" & $__ACTOR[$i][2] & "' '" & $__ACTOR[$i][3] & "'" )
			Global $GetACD = $i
			Return True
		EndIf
	Next
	_log("Get ACD By Guid was failed")
EndFunc   ;==>GetACDByGuid

Func startIterateLocalActor(ByRef $index, ByRef $offset, ByRef $count)
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8b8, $d3, "ptr")
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "ptr")
	$count = _memoryread($ptr3 + 0x108, $d3, "int")
	$index = 0
	$offset = _memoryread(_memoryread($ptr3 + 0x120, $d3, "ptr") + 0x0, $d3, "ptr")
EndFunc   ;==>startIterateLocalActor

Func iterateLocalActorList(ByRef $index, ByRef $offset, ByRef $count, ByRef $item)
	Local $iterateLocalActorListStruct = DllStructCreate("ptr;char[64];byte[" & Int($ofs_LocalActor_atribGUID) - 68 & "];ptr")
	If $index > $count Then Return False
	$index += 1
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateLocalActorListStruct), 'int', DllStructGetSize($iterateLocalActorListStruct), 'int', '')
	$item[0] = DllStructGetData($iterateLocalActorListStruct, 1)
	$item[1] = DllStructGetData($iterateLocalActorListStruct, 2)
	$item[2] = DllStructGetData($iterateLocalActorListStruct, 4)

	$item[3] = $offset ; Item Offset
	;_log('kick: ' &$item[0] & " : " & $item[1] & " : " & $item[2] & " : " & $item[3])
	$offset = $offset + $ofs_LocalActor_StrucSize
	Return True
EndFunc   ;==>iterateLocalActorList

;;================================================================================
; Function:			IterateActorAtribs($_GUID,$_REQ)
; Description:		Read the requested attribute data from a actor defined by GUID
; Parameter(s):		$_GUID - The GUID of the object you want the data from
;					$_REQ - The data you want to request (the variable)
;
; Note(s):			You can find a list of all the $_REQ variables in the Constants() function
;					It should be noted that i have not checked them all through
;						so the type ("float" or "int") might be wrong.
;					This function will always return "false" if the requested atribute does not exsist
;==================================================================================
func IterateactorAtribs($_GUID, $_REQ)
	Local $index, $offset, $count, $item[10]
	startIterateLocalActor($index, $offset, $count)

	While iterateLocalActorList($index, $offset, $count, $item)
		if $item[0] = $_GUID Then
			$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
			$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
			return GetAttribute($CurrentIdAttrib, $_REQ)
			ExitLoop
		EndIf
	WEnd
	Return False
EndFunc   ;==>IterateActorAtribs

;;================================================================================
; Function:			LinkActors
; Description:		Read and index data from the specified offset
; Parameter(s):		$_offset - The offset linking to the file def
;								be in hex format (0x00000000).
;					$_displayInfo - Setting this to 1 will make the function spit
;								out the results while running
; Note(s):			This function is used to index data from the MPQ files that
;					that have been loaded into memory.
;					Im not sure why the count doesnt go beyond 256.
;					So for the time being if the count goes beyond 256 the size
;					is set to a specified count and then the array will be scaled
;					after when data will stop being available.
;==================================================================================
Func LinkActors($OBject, $_displayInfo = 0)
	Global $OBject_Mem_Actor = $OBject
	Global $Object_File_Actor = IndexSNO($ofs_ActorDef, 0)
	Global $Object_File_Monster = IndexSNO($ofs_MonsterDef, 0)
	Dim $__outputdata[UBound($OBject_Mem_Actor, 1) - 1][2]
	For $i = 0 To UBound($OBject_Mem_Actor, 1) - 1
		If $OBject_Mem_Actor[$i][9] <> -1 Then
			$ItemIndex = _ArraySearch($Object_File_Actor, $OBject_Mem_Actor[$i][9], 0, 0, 0, 1, 1, 1)
			If $ItemIndex > 0 Then
				$MonsterID = _MemoryRead($Object_File_Actor[$ItemIndex][0] + 0x6c, $d3, 'ptr')
				$ItemIndex = _ArraySearch($Object_File_Monster, $MonsterID, 0, 0, 0, 1, 1, 1)
				If $ItemIndex > 0 Then
					$Type = _MemoryRead($Object_File_Monster[$ItemIndex][0] + $_ofs_FileMonster_MonsterType, $d3, 'int')
					$MonsterType = $_Const_MonsterType[$Type + 1]
					$Race = _MemoryRead($Object_File_Monster[$ItemIndex][0] + $_ofs_FileMonster_MonsterRace, $d3, 'int')
					$MonsterRace = $_Const_MonsterRace[$Race + 1]
					$LevelNormal = _MemoryRead($Object_File_Monster[$ItemIndex][0] + $_ofs_FileMonster_LevelNormal, $d3, 'int') ;//Here are some data you can use if you want,
					$LevelNightmare = _MemoryRead($Object_File_Monster[$ItemIndex][0] + $_ofs_FileMonster_LevelNightmare, $d3, 'int') ;//...it gives info about levels based on dificulty
					$LevelHell = _MemoryRead($Object_File_Monster[$ItemIndex][0] + $_ofs_FileMonster_LevelHell, $d3, 'int')
					$LevelInferno = _MemoryRead($Object_File_Monster[$ItemIndex][0] + $_ofs_FileMonster_LevelInferno, $d3, 'int')
					$OBject_Mem_Actor[$i][11] = $Type
					$OBject_Mem_Actor[$i][12] = $Race
					;if $_displayInfo = 1 Then _log($i & " " & $Object_File_Actor[$ItemIndex][0] & @tab & " " &$MonsterType &@tab & " " & $MonsterRace &@tab & " Level Normal:" & $LevelNormal &@tab & " " & $StringListDB[$Name][1] &" " & @TAB  &$OBject_Mem_Actor[$i][2])
				EndIf
			EndIf
		EndIf
	Next
	Return $OBject_Mem_Actor
EndFunc   ;==>LinkActors

;;================================================================================
; Function:			IndexSNO($_offset[,$_displayInfo = 0])
; Description:		Read and index data from the specified offset
; Parameter(s):		$_offset - The offset linking to the file def
;								be in hex format (0x00000000).
;					$_displayInfo - Setting this to 1 will make the function spit
;								out the results while running
; Note(s):			This function is used to index data from the MPQ files that
;					that have been loaded into memory.
;					Im not sure why the count doesnt go beyond 256.
;					So for the time being if the count goes beyond 256 the size
;					is set to a specified count and then the array will be scaled
;					after when data will stop being available.
;==================================================================================
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

;;================================================================================
; Function:			IndexStringList($_offset)
; Description:		Read and index data from the specified offset
; Parameter(s):		$_offset - The offset linking to the file def
;								  be in hex format (0x00000000).
;					$_displayInfo - Setting this to 1 will make the function spit
;								out the results while running
;
; Note(s):			This function is made specificly to index string lists.
;					This is usefull for getting real localized names from the
;					proxy names you get from the objectmanager strucs.
;					i have only test this on monster names but it should work for all.
;==================================================================================
Func IndexStringList($_offset, $_displayInfo = 0)

	$_offset_FileMonster_StrucSize = 0x50
	$_StringCount = _MemoryRead($_offset + 0xc, $d3, 'int')
	$_CurrentOffset = $_offset + 0x28
	Dim $_OutPut[$_StringCount][2]

	For $i = 0 To $_StringCount - 1
		$_OutPut[$i][0] = _MemoryRead(_MemoryRead($_CurrentOffset, $d3, 'int'), $d3, 'char[32]') ;Proxy Name, like "Priest_Male_B_NoLook"
		$_OutPut[$i][1] = _MemoryRead(_MemoryRead($_CurrentOffset + 0x10, $d3, 'int'), $d3, 'char[34]') ;Localized name, like "Brother Malachi the Healer"
		Assign("__" & $_OutPut[$i][0], $_OutPut[$i][1], 2)

		$_CurrentOffset = $_CurrentOffset + $_offset_FileMonster_StrucSize
		If $_displayInfo = 1 Then _log($_CurrentOffset & " ProxyName: " & $_OutPut[$i][0] & @TAB & " LocalizedName: " & $_OutPut[$i][1])
	Next

	Return $_OutPut
EndFunc   ;==>IndexStringList


;;--------------------------------------------------------------------------------
;;	OffsetList()
;;--------------------------------------------------------------------------------
Func offsetlist()
        _log("offsetlist")

        $vftableSubB            = _MemoryRead($VIewStatic, $d3, 'ptr')
        $vftableSubA            = _MemoryRead($vftableSubB + 0x928, $d3, 'ptr')
        $ViewOffset             = $vftableSubA
        $Ofs_CameraRotationA    = $ViewOffset + 0x4
        $Ofs_CameraRotationB    = $ViewOffset + 0x8
        $Ofs_CameraRotationC    = $ViewOffset + 0xC
        $Ofs_CameraRotationD    = $ViewOffset + 0x10
        $Ofs_CameraPosX         = $ViewOffset + 0x14
        $Ofs_CameraPosY         = $ViewOffset + 0x18
        $Ofs_CameraPosZ         = $ViewOffset + 0x1C
        $Ofs_CameraFOV          = $ViewOffset + 0x30
        $Ofs_CameraFOVB         = $ViewOffset + 0x30



        $_ActorAtrib_Base       = _MemoryRead($ofs_ActorAtrib_Base, $d3, 'ptr')
        $_ActorAtrib_1          = _MemoryRead($_ActorAtrib_Base + $ofs_ActorAtrib_ofs1, $d3, 'ptr')
        $_ActorAtrib_2          = _MemoryRead($_ActorAtrib_1 + $ofs_ActorAtrib_ofs2, $d3, 'ptr')
        $_ActorAtrib_3          = _MemoryRead($_ActorAtrib_2 + $ofs_ActorAtrib_ofs3, $d3, 'ptr')
        $_ActorAtrib_4          = _MemoryRead($_ActorAtrib_3, $d3, 'ptr')
        $_ActorAtrib_Count      = $_ActorAtrib_2 + $ofs_ActorAtrib_Count
        $_LocalActor_1          = _MemoryRead($_ActorAtrib_1 + $ofs_LocalActor_ofs1, $d3, 'ptr')
        $_LocalActor_2          = _MemoryRead($_LocalActor_1 + $ofs_LocalActor_ofs2, $d3, 'ptr')
        $_LocalActor_3          = _MemoryRead($_LocalActor_2, $d3, 'ptr')
        $_LocalActor_Count      = $_LocalActor_1 + $ofs_LocalActor_Count
        $_itrObjectManagerA     = _MemoryRead($ofs_objectmanager, $d3, 'ptr')
        $_itrObjectManagerB     = _MemoryRead($_itrObjectManagerA + $ofs__ObjmanagerActorOffsetA, $d3, 'ptr')
        $_itrObjectManagerCount = $_itrObjectManagerB + $ofs__ObjmanagerActorCount
        $_itrObjectManagerC     = _MemoryRead($_itrObjectManagerB + $ofs__ObjmanagerActorOffsetB, $d3, 'ptr')
        $_itrObjectManagerD     = _MemoryRead($_itrObjectManagerC, $d3, 'ptr')
        $_itrObjectManagerE     = _MemoryRead($_itrObjectManagerD, $d3, 'ptr')
        $_itrInteractA          = _MemoryRead($ofs_InteractBase, $d3, 'ptr')
        $_itrInteractB          = _MemoryRead($_itrInteractA, $d3, 'ptr')
        $_itrInteractC          = _MemoryRead($_itrInteractB, $d3, 'ptr')
        $_itrInteractD          = _MemoryRead($_itrInteractC + $ofs__InteractOffsetA, $d3, 'ptr')
        $_itrInteractE          = $_itrInteractD + $ofs__InteractOffsetB

        If LocateMyToon() Then
                $ClickToMoveMain = _MemoryRead($_Myoffset + $ofs__ObjmanagerActorLinkToCTM, $d3, 'ptr')
                $ClickToMoveRotation = $ClickToMoveMain + $RotationOffset
                $ClickToMoveCurX = $ClickToMoveMain + $CurrentX
                $ClickToMoveCurY = $ClickToMoveMain + $CurrentY
                $ClickToMoveCurZ = $ClickToMoveMain + $CurrentZ
                $ClickToMoveToX = $ClickToMoveMain + $MoveToXoffset
                $ClickToMoveToY = $ClickToMoveMain + $MoveToYoffset
                $ClickToMoveToZ = $ClickToMoveMain + $MoveToZoffset
                $ClickToMoveToggle = $ClickToMoveMain + $ToggleMove
                $ClickToMoveFix = $ClickToMoveMain + $FixSpeed
                _log("My toon located at: " & $_Myoffset & ", GUID: " & $_MyGuid & ", NAME: " & $_MyCharType)
                Return True
        Else
                Return False
        EndIf

EndFunc   ;==>offsetlist

;;--------------------------------------------------------------------------------
;;      Function to iterate all objects()
;;--------------------------------------------------------------------------------
Func startIterateObjectsList(ByRef $index, ByRef $offset, ByRef $count)
	$count = _MemoryRead($_itrObjectManagerCount, $d3, 'int')
	$index = 0
	$offset = $_itrObjectManagerD
	;_log("Actor Count -> " & $count)
EndFunc   ;==>startIterateObjectsList

;;--------------------------------------------------------------------------------
;;      FromD3toScreenCoords()
;;--------------------------------------------------------------------------------
Func FromD3toScreenCoords($_x, $_y, $_z)
	Dim $return[2]
	$size = WinGetClientSize("[CLASS:D3 Main Window Class]")

	if NOT $size[0] = $SizeWindows[0] OR NOT $size[1] = $SizeWindows[1] Then
		_log("!Windows Size Changed")
		Terminate()
	EndIF

	$resolutionX = $size[0]
	$resolutionY = $size[1]
	$aspectChange = ($resolutionX / $resolutionY) / (800 / 600)
	$CurrentLoc = GetCurrentPos()
	$xd = $_x - $CurrentLoc[0]
	$yd = $_y - $CurrentLoc[1]
	$zd = $_z - $CurrentLoc[2]
	$w = -0.515 * $xd + - 0.514 * $yd + - 0.686 * $zd + 97.985
	$x = (-1.682 * $xd + 1.683 * $yd + 0 * $zd + 7.045E-3) / $w
	$y = (-1.54 * $xd + - 1.539 * $yd + 2.307 * $zd + 6.161) / $w
	$Z = (-0.515 * $xd + - 0.514 * $yd + - 0.686 * $zd + 97.002) / $w
	$x /= $aspectChange
	While Abs($x) >= 1 Or Abs($y) >= 0.7 Or $Z <= 0
		; specified point is not on screen
		$xd = $xd / 2
		$yd = $yd / 2
		$zd = $zd / 2
		$w = -0.515 * $xd + - 0.514 * $yd + - 0.686 * $zd + 97.985
		$x = (-1.682 * $xd + 1.683 * $yd + 0 * $zd + 7.045E-3) / $w
		$y = (-1.54 * $xd + - 1.539 * $yd + 2.307 * $zd + 6.161) / $w
		$Z = (-0.515 * $xd + - 0.514 * $yd + - 0.686 * $zd + 97.002) / $w
		$x /= $aspectChange
	WEnd
	$return[0] = ($x + 1) / 2 * $resolutionX
	$return[1] = (1 - $y) / 2 * $resolutionY

	$return = Checkclickable($return)

	Return $return
EndFunc   ;==>FromD3toScreenCoords


;;--------------------------------------------------------------------------------
;;      UiRatio()
;;--------------------------------------------------------------------------------
Func UiRatio($_x, $_y)
	Dim $return[2]
	$size = WinGetClientSize("[CLASS:D3 Main Window Class]")
	$return[0] = $size[1] * ($_x / 600)
	$return[1] = $size[1] * ($_y / 600)
	Return $return
EndFunc   ;==>UiRatio

Func GetCurrentPos()
	Dim $return[3]

	Local $PosPlayerStruct = DllStructCreate("byte[164];float;float;float")
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $_Myoffset, 'ptr', DllStructGetPtr($PosPlayerStruct), 'int', DllStructGetSize($PosPlayerStruct), 'int', '')

		$return[0] = DllStructGetData($PosPlayerStruct, 2) ; X Head
		$return[1] = DllStructGetData($PosPlayerStruct, 3) ; Y Head
		$return[2] = DllStructGetData($PosPlayerStruct, 4) ; Z Head

		$Current_Hero_X = $return[0]
		$Current_Hero_Y = $return[1]
		$Current_Hero_Z = $return[2]

		Return $return
EndFunc  ;==>GetCurrentPos

;;--------------------------------------------------------------------------------
;;      MoveToPos()
;;--------------------------------------------------------------------------------
Func MoveToPos($_x, $_y, $_z, $_a, $m_range)
	Local $TimeOut = TimerInit()
	$grabtimeout = 0
	$killtimeout = 0

	If Not $Execute_StashAndRepair Then
	   If _playerdead() Or $GameOverTime = True Or $GameFailed = 1 Or $SkippedMove > 6 Then
			$GameFailed = 1
			Return
	   EndIf
	EndIf

	Local $toggletry = 0
	Global $lastwp_x = $_x
	Global $lastwp_y = $_y
	Global $lastwp_z = $_z
	If $_a = 1 Then Attack()
	$Coords = FromD3toScreenCoords($_x, $_y, $_z)
	MouseMove($Coords[0], $Coords[1], 3)
	$LastCP = GetCurrentPos()
	MouseDown($MouseMoveClick)
	Sleep(10)
	While 1

		GameOverTime()
		If $GameOverTime = True Then
			ExitLoop
		EndIf

		If Not $Execute_StashAndRepair Then
		   GestSpellcast(0, 0, 0)
		EndIf

		$CurrentLoc = GetCurrentPos()
		$xd = $lastwp_x - $CurrentLoc[0]
		$yd = $lastwp_y - $CurrentLoc[1]
		$zd = $lastwp_z - $CurrentLoc[2]
		$Distance = Sqrt($xd * $xd + $yd * $yd + $zd * $zd)
		If $Distance < $m_range Then ExitLoop
		;If _MemoryRead($ClickToMoveToggle, $d3, 'float') = 0 Then ExitLoop
		Local $angle = 1
		Local $Radius = 25
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		While _MemoryRead($ClickToMoveToggle, $d3, 'float') = 0
			;_log("Togglemove : " & _MemoryRead($ClickToMoveToggle, $d3, 'float'))
			$Coords = FromD3toScreenCoords($_x, $_y, $_z)
			$angle += $Step
			$Radius += 45


			;MouseMove($Coords[0] - (Cos($angle) * $Radius), $Coords[1] - (Sin($angle) * $Radius), 3)
			; ci desssous du dirty code pour eviter de cliquer n'importe ou hos de la fenetre du jeu
			$Coords[0] = $Coords[0] - (Cos($angle) * $Radius)
			$Coords[1] = $Coords[1] - (Sin($angle) * $Radius)

			$Coords = Checkclickable($Coords)

			MouseMove($Coords[0], $Coords[1], 3)
			$toggletry += 1
			;_log("Tryin move :" & " x:" & $_x & " y:" & $_y & "coords: " & $Coords[0] & "-" & $Coords[1] & " angle: " & $angle & " Toggle try: " & $toggletry)

			If _playerdead_revive() Then
				ExitLoop 2
			EndIf

			If $angle >= 2.0 * $PI Or $toggletry > 9 Or _playerdead() Then
				$SkippedMove += 1
				_log("Toggle try: " & $toggletry & " Movement Skipped : " & $SkippedMove)
				ExitLoop 2 ; le 2 signifie que l'on quitte 2 loop
			EndIf
			Sleep(10)
		WEnd
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		Sleep(10)
		$Coords = FromD3toScreenCoords($lastwp_x, $lastwp_y, $lastwp_z)
		;_log("currentloc: " & $_Myoffset & " - "&$CurrentLoc[0] & " : " & $CurrentLoc[1] & " : " & $CurrentLoc[2])
		;_log("distance/m range: " & $Distance & " : " & $m_range)
		If $_a = 1 And GetDistance($LastCP[0], $LastCP[1], $LastCP[2]) >= $a_range / 2 Then
			MouseUp($MouseMoveClick)
			$LastCP = GetCurrentPos()
			If $_a = 1 Then Attack()

			dim $Coords_Rnd[2]
			$Coords_Rnd[0] = Random($Coords[0] - 20, $Coords[0] + 20)
			$Coords_Rnd[1] = Random($Coords[1] - 20, $Coords[1] + 15)

			$Coords_Rnd = Checkclickable($Coords_Rnd)

			MouseMove($Coords_Rnd[0], $Coords_Rnd[1], 3) ;little randomisation

			MouseDown($MouseMoveClick)
		EndIf
		MouseMove($Coords[0], $Coords[1], 3)
		If TimerDiff($TimeOut) > 75000 Then
			_log("MoveToPos Timed out ! ! ! ")
			If _checkdisconnect() Then
				$GameFailed = 1
			EndIf

			ExitLoop
		EndIf
	WEnd
	MouseUp($MouseMoveClick)
	;;
	;Sleep(100)
EndFunc   ;==>MoveToPos

;;--------------------------------------------------------------------------------
;;      Interact()
;;--------------------------------------------------------------------------------
Func Interact($_x, $_y, $_z)
	; MoveToPos($_x, $_y, $_z, 0, 25)
	$Coords = FromD3toScreenCoords($_x, $_y, $_z)
	MouseClick("left", $Coords[0], $Coords[1], 1, 2)
	;While _MemoryRead($_itrInteractE + $ofs__InteractOffsetUNK2, $d3, 'int') = 1
	;	Sleep(50)
	;WEnd
EndFunc   ;==>Interact

;;--------------------------------------------------------------------------------
;;   InteractByActorName()
;;--------------------------------------------------------------------------------
Func InteractByActorName($a_name, $dist = 300)
	Local $index, $offset, $count, $item[10], $foundobject = 0
	Local $maxtry = 0
	startIterateObjectsList($index, $offset, $count)
	If _playerdead() = False Then
		While iterateObjectsList($index, $offset, $count, $item)
			If StringInStr($item[1], $a_name) And $item[9] < $dist Then
				_log($item[1] & " distance : " & $item[9])
				While getDistance($item[2], $item[3], $item[4]) > 40 And $maxtry <= 15
					$Coords = FromD3toScreenCoords($item[2], $item[3], $item[4])
					MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 10)
					$maxtry += 1
					_log('interactbyactor: click x : ' & $Coords[0] & " y : " & $Coords[1])
					Sleep(800)
				WEnd
				Sleep(800)
				Interact($item[2], $item[3], $item[4])
				$foundobject = 1
				Sleep(100)
				ExitLoop
			EndIf
		WEnd
	EndIf
	Return $foundobject
EndFunc   ;==>InteractByActorName


;;--------------------------------------------------------------------------------
;;      GetLifep()
;;--------------------------------------------------------------------------------
Func GetLifep()
	$curhp = GetAttribute($_MyGuid, $Atrib_Hitpoints_Cur)
	Return ($curhp / $maxhp)
EndFunc   ;==>GetLifep

Func GetAttribute($idAttrib, $attrib)
	Return _memoryread(GetAttributeOfs($idAttrib, BitOR($attrib[0], 0xFFFFF000)), $d3, $attrib[1])
EndFunc   ;==>GetAttribute

Func Resistance($idAttrib, $resistance)
	Return _memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resistance[0], BitShift($resistance, -12))), $d3, "float")
	;0 : physical
	;1 : fire
	;2 : lightning
	;3 : cold
	;4 : poison
	;5 : arcane
	;6 : holy
EndFunc   ;==>Resistance

Func GetACDOffsetByACDGUID($Guid)
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8b8, $d3, "ptr")
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "int")
	$index = BitAND($Guid, 0xFFFF)

	$bitshift = _memoryread($ptr3 + 0x164, $d3, "int")
	$group1 = 4 * BitShift($index, $bitshift)
	$group2 = BitShift(1, -$bitshift) - 1
	$group3 = _memoryread(_memoryread($ptr3 + 0x120, $d3, "int"), $d3, "int")
	$group4 = 0x2f8 * BitAND($index, $group2)
	Return $group3 + $group1 + $group4
	_log("index : " & $index& " bitshift : " & $bitshift & " group1 : " & $group1 & " group 2 : " & $group2 & " group 3 : " & $group3 & " group4 : " & $group4)
EndFunc   ;==>GetACDOffsetByACDGUID

Func iterateObjectsList(ByRef $index, ByRef $offset, ByRef $count, ByRef $item)

	If $index > $count + 1 Then
		Return False
	EndIf

	$index += 1
	$error = 0

	Do
		Local $iterateObjectsListStruct = DllStructCreate("int;char[128];byte[4];ptr;byte[40];float;float;float;byte[276];int;byte[88];int;byte[44];int")
		;Local $iterateObjectsListStruct = DllStructCreate("int;char[128];byte[4];ptr;byte[24];float;float;float;byte[292];int;byte[88];int;byte[44];int")
		DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')

		$item[0] = DllStructGetData($iterateObjectsListStruct, 4) ; Guid
		$item[1] = DllStructGetData($iterateObjectsListStruct, 2) ; Name
		$item[2] = DllStructGetData($iterateObjectsListStruct, 6) ; x
		$item[3] = DllStructGetData($iterateObjectsListStruct, 7) ; y
		$item[4] = DllStructGetData($iterateObjectsListStruct, 8) ; z
		$item[5] = DllStructGetData($iterateObjectsListStruct, 14) ; data 1
		$item[6] = DllStructGetData($iterateObjectsListStruct, 12) ; data 2
		$item[7] = DllStructGetData($iterateObjectsListStruct, 10) ; data 3
		$item[8] = $offset
		$item[9] = getDistance($item[2], $item[3], $item[4]) ; Distance
		$iterateObjectsListStruct = ""
		$offset = $offset + $_ObjmanagerStrucSize
		;_log("Ofs : " & $item[8]  & " - "  & $item[1] & " - Data 1 : " & $item[5] & " - Data 2 : " & $item[6] & " - Guid : " & $item[0])

	Until $error = 0

		Return True
EndFunc   ;==>iterateObjectsList

Func ArrayStruct($tagStruct, $numElements)
    $sizeOfMyStruct = DllStructGetSize(DllStructCreate($tagStruct)) ;assumes end padding is included
    $bytesNeeded = $numElements * $sizeOfMyStruct
    return DllStructCreate("byte[" & $bytesNeeded & "]")
EndFunc

Func GetElement($Struct, $Element, $tagSTRUCT)
   return DllStructCreate($tagSTRUCT, DllStructGetPtr($Struct) + $Element * DllStructGetSize(DllStructCreate($tagStruct)))
EndFunc

Func IterateCACD(ByRef $ItemCRactor)

	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8b8, $d3, "ptr")
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "ptr")
	$_Count = _memoryread($ptr3 + 0x108, $d3, "int")
	$CurrentOffset = _memoryread(_memoryread($ptr3 + 0x120, $d3, "ptr") + 0x0, $d3, "ptr")
	Local $__ACDACTOR[$_Count + 1][7]

	$iterateACDActorStruct = ArrayStruct($ACDStruct, $_Count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $CurrentOffset, 'ptr', DllStructGetPtr($iterateACDActorStruct), 'int', DllStructGetSize($iterateACDActorStruct), 'int', '')

	For $i = 0 To $_Count
		$ACDActorStruct = GetElement($iterateACDActorStruct, $i, $ACDStruct)

		if DllStructGetData($ACDActorStruct, 1) <> -1 Then

			;_log(DllStructGetData($ACDActorStruct, 2))
			$found = false
			$buff = DllStructGetData($ACDActorStruct, 1) ;ID_ACD


			for $y=0 to Ubound($ItemCRactor) - 1
				;_log($ItemCRactor[$y][0] & " - " & $buff)
				if $ItemCRactor[$y][0] = $buff Then
					$ItemCRactor[$y][10] = $buff ;ID_ACD
					$ItemCRactor[$y][11] = DllStructGetData($ACDActorStruct, 5) ;ID_SNO
					$ItemCRactor[$y][12] = DllStructGetData($ACDActorStruct, 7) ;GB_TYPE
					$ItemCRactor[$y][13] = DllStructGetData($ACDActorStruct, 8) ;ID_GB
					$ItemCRactor[$y][14] = DllStructGetData($ACDActorStruct, 9) ;mobtype
					$ItemCRactor[$y][15] = DllStructGetData($ACDActorStruct, 11) ;Radius
					$ItemCRactor[$y][16] = DllStructGetData($ACDActorStruct, 13) ;ID_ATTRIB
					ExitLoop
				EndIf
			Next

		endif
		$ACDActorStruct = ""
	Next
	$iterateACDActorStruct = ""
return $__ACDACTOR
EndFunc   ;==>IterateBackpack


Func IterateFilterAttackV4($IgnoreList)

	Local $index, $offset, $count
	startIterateObjectsList($index, $offset, $count)

	Dim $item_buff_2D[1][$TableSizeGuidStruct + 1]
	Dim $item[$TableSizeGuidStruct + 1]

	Local $z = 0

	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')

	$CurrentLoc = GetCurrentPos()

	for $i=0 to $count
		$iterateObjectsStruct = GetElement($iterateObjectsListStruct, $i, $GuidStruct)

		If DllStructGetData($iterateObjectsStruct, 4) <> 0xFFFFFFFF Then
			$item[0] = DllStructGetData($iterateObjectsStruct, 4) ; Guid
			$item[1] = DllStructGetData($iterateObjectsStruct, 2) ; Name
			$item[2] = DllStructGetData($iterateObjectsStruct, 6) ; x Head
			$item[3] = DllStructGetData($iterateObjectsStruct, 7) ; y Head
			$item[4] = DllStructGetData($iterateObjectsStruct, 8) ; z Head
			$item[5] = DllStructGetData($iterateObjectsStruct, 18) ; data 1
			$item[6] = DllStructGetData($iterateObjectsStruct, 16) ; data 2
			$item[7] = DllStructGetData($iterateObjectsStruct, 14) ; data 3
			$item[8] = $offset + $i*DllStructGetSize($iterateObjectsStruct)

			$Item[10] = DllStructGetData($iterateObjectsStruct, 10) ; x Foot
			$Item[11] = DllStructGetData($iterateObjectsStruct, 11) ; y Foot
			$Item[12] = DllStructGetData($iterateObjectsStruct, 12) ; z Foot

			$item[9] = GetDistanceWithoutReadPosition($CurrentLoc, $Item[10], $Item[11], $Item[12])

			$handle = False

			If Is_Interact($item, $IgnoreList) Then
				Select
					Case Is_Shrine($item) 
						$handle = True
						$Item[13] = $ITEM_TYPE_SHRINE
					Case Is_Mob($item)
						$handle = True
						$Item[13] = $ITEM_TYPE_MOB
					Case Is_Loot($item)
						$handle = True
						$Item[13] = $ITEM_TYPE_LOOT
					Case Is_Coffre($item)
						$handle = True
						$Item[13] = $ITEM_TYPE_CHEST
					Case Is_Health($item)
						$handle = True
						$Item[13] = $ITEM_TYPE_HEALTH
					Case Is_Power($item)
						$handle = True
						$Item[13] = $ITEM_TYPE_POWER
					Case Is_Decor_Breakable($item)
						$handle = True
						$Item[13] = $ITEM_TYPE_DECOR
				EndSelect
			EndIf

			If $handle Then
				ReDim $item_buff_2D[$z + 1][$TableSizeGuidStruct + 1]
				For $x = 0 To $TableSizeGuidStruct
					$item_buff_2D[$z][$x] = $item[$x]
				Next
				$z += 1
			EndIf

		EndIf
		$iterateObjectsStruct = ""
	Next

	$iterateObjectsListStruct = ""

	If $z = 0 Then
		Return False
	Else
		If $MonsterTri Then
			_ArraySort($item_buff_2D, 0, 0, 0, 9)
		EndIf

		If $MonsterPriority Then
			Dim $item_buff_2D_buff = TriObjectMonster($item_buff_2D)
			Dim $item_buff_2D = $item_buff_2D_buff
		EndIf

		Return $item_buff_2D
	 EndIf
EndFunc

Func IterateFilterZoneV2($dist, $n=2)

	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)
	Local $z = 0

	$CurrentLoc = GetCurrentPos()
	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')

	dim $item[$TableSizeGuidStruct]

	For $i=0 To $count
		$iterateObjectsStruct = GetElement($iterateObjectsListStruct, $i, $GuidStruct)
		$item[0] = DllStructGetData($iterateObjectsStruct, 4) ; Guid
		$item[1] = DllStructGetData($iterateObjectsStruct, 2) ; Name
		$item[2] = DllStructGetData($iterateObjectsStruct, 6) ; x
		$item[3] = DllStructGetData($iterateObjectsStruct, 7) ; y
		$item[4] = DllStructGetData($iterateObjectsStruct, 8) ; z
		$item[5] = DllStructGetData($iterateObjectsStruct, 18) ; data 1
		$item[6] = DllStructGetData($iterateObjectsStruct, 16) ; data 2
		$item[7] = DllStructGetData($iterateObjectsStruct, 14) ; data 3
		$item[8] = $offset + $i*DllStructGetSize($iterateObjectsStruct)

		$Item[10] = DllStructGetData($iterateObjectsStruct, 10) ; x Foot
		$Item[11] = DllStructGetData($iterateObjectsStruct, 11) ; y Foot
		$Item[12] = DllStructGetData($iterateObjectsStruct, 12) ; z Foot

		$item[9] = GetDistanceWithoutReadPosition($CurrentLoc, $Item[10], $Item[11], $Item[12])

		$iterateObjectsStruct = ""
		If Is_Interact($item, "") Then
			If $item[9] < $dist Then
				If Is_Mob($item) Then
					$z += 1
					If $z >= $n Then
						$iterateObjectsListStruct = ""
						Return True
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	$iterateObjectsListStruct = ""
	Return False
EndFunc

Func IterateFilterAffixV2()

	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)
	Dim $item_affix_2D[1][$TableSizeGuidStruct+1]
	Local $z = 0
	
	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')
	
	$CurrentLoc = GetCurrentPos()
	$pv_affix=getlifep()

	for $i=0 to $count
		$iterateObjectsStruct = GetElement($iterateObjectsListStruct, $i, $GuidStruct)

		If DllStructGetData($iterateObjectsStruct, 4) <> 0xFFFFFFFF Then
			$item[0] = DllStructGetData($iterateObjectsStruct, 4) ; Guid
			$item[1] = DllStructGetData($iterateObjectsStruct, 2) ; Name
			$item[2] = DllStructGetData($iterateObjectsStruct, 6) ; x
			$item[3] = DllStructGetData($iterateObjectsStruct, 7) ; y
			$item[4] = DllStructGetData($iterateObjectsStruct, 8) ; z
			$item[5] = DllStructGetData($iterateObjectsStruct, 18) ; data 1
			$item[6] = DllStructGetData($iterateObjectsStruct, 16) ; data 2
			$item[7] = DllStructGetData($iterateObjectsStruct, 14) ; data 3
			$item[8] = $offset + $i*DllStructGetSize($iterateObjectsStruct)

			$Item[10] = DllStructGetData($iterateObjectsStruct, 10) ; z Foot
			$Item[11] = DllStructGetData($iterateObjectsStruct, 11) ; z Foot
			$Item[12] = DllStructGetData($iterateObjectsStruct, 12) ; z Foot

			$item[9] = GetDistanceWithoutReadPosition($CurrentLoc, $Item[10], $Item[11], $Item[12])

			If Is_Affix($item, $pv_affix) Then
				ReDim $item_affix_2D[$z + 1][$TableSizeGuidStruct+1]
				For $x = 0 To 9
					$item_affix_2D[$z][$x] = $item[$x]
				Next

					if (StringInStr($item[1],"woodWraith_explosion") or StringInStr($item[1],"WoodWraith_sporeCloud_emitter")) then  $item_affix_2D[$z][13] = $range_ice
				    if (StringInStr($item[1],"sandwasp_projectile") or StringInStr($item[1],"succubus_bloodStar_projectile")) then $item_affix_2D[$z][13] = $range_arcane
			        if StringInStr($item[1],"molten_trail") then $item_affix_2D[$z][13] = $range_lave
			        if (StringInStr($item[1],"Corpulent_") and (StringLower(Trim($nameCharacter)) = "demonhunter" or StringLower(Trim($nameCharacter)) = "witchdoctor" or StringLower(Trim($nameCharacter)) = "wizard")) then $item_affix_2D[$z][13] = $range_arcane
                    if StringInStr($item[1],"Corpulent_suicide_blood") then $item_affix_2D[$z][13] = $range_arcane
			        if StringInStr($item[1],"Desecrator") then $item_affix_2D[$z][13] = $range_profa
			        if (StringInStr($item[1],"bomb_buildup") or StringInStr($item[1],"iceClusters") or stringinstr($item[1],"Molten_deathExplosion") or stringinstr($item[1],"Molten_deathStart")) then  $item_affix_2D[$z][13] = $range_ice
			        if StringInStr($item[1],"frozenPulse") then $item_affix_2D[$z][13] = $range_arcane
					if StringInStr($item[1],"Orbiter_Projectile") then $item_affix_2D[$z][13] = $range_arcane
			        if StringInStr($item[1],"Battlefield_demonic_forge") then $item_affix_2D[$z][13] = $range_arcane
			        if (StringInStr($item[1],"CorpseBomber_projectile") or StringInStr($item[1],"CorpseBomber_bomb_start")) then $item_affix_2D[$z][13] = $range_ice
			        if StringInStr($item[1],"Thunderstorm_Impact") then $item_affix_2D[$z][13] = $range_ice
			        if (StringInStr($item[1],"demonmine_C") or StringInStr($item[1],"Crater_DemonClawBomb")) then $item_affix_2D[$z][13] = $range_mine
			        if StringInStr($item[1],"creepMobArm") then $item_affix_2D[$z][13] = $range_arm
			        if (StringInStr($item[1],"spore") or StringInStr($item[1],"Plagued_endCloud") or StringInStr($item[1],"Poison")) then $item_affix_2D[$z][13] = $range_peste
			        if StringInStr($item[1],"ArcaneEnchanted_petsweep") then $item_affix_2D[$z][13] = $range_arcane


				$z += 1
			EndIf


		EndIf
		$iterateObjectsStruct = ""
		Next

	$iterateObjectsListStruct = ""

	If $z = 0 Then
                Return False
        Else

                _ArraySort($item_affix_2D, 0, 0, 0, 9)

                Return $item_affix_2D
        EndIf
EndFunc

Func UpdateArrayAttack($array_obj, $IgnoreList, $update_attrib = 0)

	If UBound($array_obj) <= 1 Or Not IsArray($array_obj) Then
		Return False
	EndIf


	If $update_attrib = 0 Then
		Return UpdateObjectsList(_Array2DDelete($array_obj, 0))
	Else

		Local $buff2 = IterateFilterAttackV4($IgnoreList)
		If $MonsterTri Then
			_ArraySort($buff2, 0, 0, 0, 9)
		EndIf

		If $MonsterPriority Then
			Dim $buff2_buff = TriObjectMonster($buff2)
			Dim $buff2 = $buff2_buff
		EndIf

		Return $buff2
	EndIf
EndFunc   ;==>UpdateArrayAttack

global $decorlist=""
global $bandecorlist=""

Func TriObjectMonster($item)

	Dim $tab_monster[1][$TableSizeGuidStruct+1]
	Dim $tab_other[1][$TableSizeGuidStruct+1]
	Dim $tab_mixte[1][$TableSizeGuidStruct+1]
	Dim $tab_elite[1][$TableSizeGuidStruct+1]
	Dim $item_temp[$TableSizeGuidStruct+1]
	$compt_monster = 0
	$compt_other = 0
	$compt_elite = 0
	$compt_mixte = 0

	For $i = 0 To UBound($item) - 1

		For $z = 0 to $TableSizeGuidStruct
			$item_temp[$z] = $item[$i][$z]
		Next


;~
;~ 		If DetectElite($item[$i][0]) then

;~ 			If UBound($tab_elite) > 1 Or $compt_elite <> 0 Then
;~ 				ReDim $tab_elite[UBound($tab_elite) + 1][10]
;~ 			EndIf
;~ 			For $y = 0 To 9
;~ 				$tab_elite[UBound($tab_elite) - 1][$y] = $item[$i][$y]
;~ 			Next
;~ 			$compt_elite += 1

;~ 		Else
		   if Is_Mob($item_temp) Then

			If UBound($tab_monster) > 1 Or $compt_monster <> 0 Then
				ReDim $tab_monster[UBound($tab_monster) + 1][$TableSizeGuidStruct+1]
			EndIf
			For $y = 0 To $TableSizeGuidStruct
				$tab_monster[UBound($tab_monster) - 1][$y] = $item[$i][$y]
			Next
			$compt_monster += 1

		Else

			If UBound($tab_other) > 1 Or $compt_other <> 0 Then
				ReDim $tab_other[UBound($tab_other) + 1][$TableSizeGuidStruct+1]
			EndIf
			For $y = 0 To $TableSizeGuidStruct
				$tab_other[UBound($tab_other) - 1][$y] = $item[$i][$y]
			Next
			$compt_other += 1
		EndIf

	Next

;~ 	For $i = 0 To UBound($tab_elite) - 1

;~ 		If UBound($tab_mixte) > 1 Or $compt_mixte <> 0 Then
;~ 			ReDim $tab_mixte[UBound($tab_mixte) + 1][10]
;~ 		EndIf
;~ 		For $y = 0 To 9
;~ 			$tab_mixte[UBound($tab_mixte) - 1][$y] = $tab_elite[$i][$y]
;~ 		Next
;~ 		$compt_mixte += 1
;~ 	Next


	For $i = 0 To UBound($tab_monster) - 1

		If UBound($tab_mixte) > 1 Or $compt_mixte <> 0 Then
			ReDim $tab_mixte[UBound($tab_mixte) + 1][$TableSizeGuidStruct+1]
		EndIf
		For $y = 0 To $TableSizeGuidStruct
			$tab_mixte[UBound($tab_mixte) - 1][$y] = $tab_monster[$i][$y]
		Next
		$compt_mixte += 1
	Next

	For $i = 0 To UBound($tab_other) - 1

		If UBound($tab_mixte) > 1 Or $compt_mixte <> 0 Then
			ReDim $tab_mixte[UBound($tab_mixte) + 1][$TableSizeGuidStruct+1]
		EndIf
		For $y = 0 To $TableSizeGuidStruct
			$tab_mixte[UBound($tab_mixte) - 1][$y] = $tab_other[$i][$y]
		Next
		$compt_mixte += 1
	Next

	Return $tab_mixte

EndFunc   ;==>TriObjectMonster

Func UpdateObjectsList($item)
	For $i = 0 To UBound($item) - 1
		Dim $buff_item[4]
		Local $pos = DllStructCreate("byte[180];float;float;float;byte[4];float;float;float") ;b4 Vec3 Pos1 Struct CRActor
		DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $item[$i][8], 'ptr', DllStructGetPtr($pos), 'int', DllStructGetSize($pos), 'int', '')
		$item[$i][2] = DllStructGetData($pos, 6)
		$item[$i][3] = DllStructGetData($pos, 7)
		$item[$i][4] = DllStructGetData($pos, 8)
		$item[$i][9] = getDistance($item[$i][2], $item[$i][3], $item[$i][4]) ; Distance
		$pos = ""
	Next
	Return $item
EndFunc   ;==>UpdateObjectsList

Func UpdateObjectsPos($offset)
	Local $obj_pos[4]

	Local $pos = DllStructCreate("byte[180];float;float;float;byte[4];float;float;float") ;b4 Vec3 Pos1 Struct CRActor
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($pos), 'int', DllStructGetSize($pos), 'int', '')
	$obj_pos[0] = DllStructGetData($pos, 6)
	$obj_pos[1] = DllStructGetData($pos, 7)
	$obj_pos[2] = DllStructGetData($pos, 8)
	$obj_pos[3] = getDistance($obj_pos[0], $obj_pos[1], $obj_pos[2]) ; Distance
	$pos = ""
	Return $obj_pos
EndFunc   ;==>UpdateObjectsPos

Func Is_Shrine(ByRef $item)
	Select 
		Case Not $TakeShrines
			Return False
		Case $item[9] > $range_shrine
			Return False
		Case (StringInStr($item[1], "shrine") Or StringInStr($item[1], "PoolOfReflection"))
			Return True
		Case Else
			Return False
	EndSelect
EndFunc   ;==>Is_Shrine

Func Is_Mob(ByRef $item)
	Select 
		Case $item[9] > $a_range
			Return False
		Case IsItemInTable($Table_BanMonster, $item[1])
			Return False
		Case (IsItemInTable($Table_Monster, $item[1]) And $item[6] <> -1)
			Return True
		Case IsItemInTable($Table_SpecialMonster, $item[1])
			Return True
		Case Else
			Return False
	EndSelect
EndFunc   ;==>Is_Mob

Func Is_Decor_Breakable(ByRef $item)
	Select 
		Case $item[9] > $range_decor
			Return False
		Case $item[6] = -1
			Return False
		Case IsItemInTable($Table_Decor, $item[1])
			Return True
		Case Else
			Return False
	EndSelect
EndFunc   ;==>Is_Decor_Breakable

Func Is_Loot(ByRef $item)
	Select 
		Case $item[9] > $g_range
			Return False
		Case ($item[5] = 2 And $item[6] = -1)
			Return True
		Case (StringInStr($item[1], "unique") And (StringInStr($item[1], "orb") Or StringInStr($item[1], "Spear")))
			Return True
		Case Else
			Return False
	EndSelect
EndFunc   ;==>Is_Loot

Func Is_Interact(ByRef $item, $IgnoreList)
	Select 
		Case (($item[0] = 0xFFFFFFFF) Or ($item[0] = "")) ; Mauvais Item
			Return False
		Case ($item[9] > $g_range And $item[9] > $a_range) ; Trop loin
			Return False
		Case Abs($Current_Hero_Z - $item[12]) > $Hero_Axe_Z ; Mauvaise axe Z
			Return False
		Case (StringInStr($IgnoreList, $item[8]) <> 0) ; Objet ignoré
			Return False
		Case IsBannedActor($item[1]) ; Objet banni
			Return False
		Case IsItemStartInTable($Table_BanItemStartName, $item[1]) ; Banned known items
			Return False
		Case (StringRegExp($item[1], "(?i)_projectile$") = 1) ; Projectile
			Return False
		Case Else
			Return True
	EndSelect
EndFunc   ;==>Is_Interact

Func Is_Coffre(ByRef $item)
	Select 
		Case $item[9] > $range_chest
			Return False
		Case IsItemInTable($Table_Coffre, $item[1])
			Return True
		Case Else
			Return False
	EndSelect
EndFunc

Func Is_Health(ByRef $item)
	Select 
		Case $item[9] > $range_health
			Return False
		Case (StringInStr($item[1], "HealthWell") Or StringInStr($item[1], "HealthGlobe"))
			Return True
		Case Else
			Return False
	EndSelect
EndFunc   ;==>Is_Health

Func Is_Power(ByRef $item)
	Select 
		Case $item[9] > $range_power
			Return False
		Case StringInStr($item[1], "PowerGlobe")
			Return True
		Case Else
			Return False
	EndSelect
EndFunc   ;==>Is_Power

Func handle_Power(ByRef $item)
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
	If GetAttribute($CurrentIdAttrib, $Atrib_gizmo_state) <> 1 Then
		If Power($item[1], $item[8], $item[0]) = False Then
			_log("Ban power -> " & $item[1])
			BanActor($item[1])
		EndIf
	EndIf
EndFunc   ;==>handle_Power

Func handle_Health(ByRef $item)
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
	If GetAttribute($CurrentIdAttrib, $Atrib_gizmo_state) <> 1 Then
		If Health($item[1], $item[8], $item[0]) = False Then
			_log("Ban health -> " & $item[1])
			BanActor($item[1])
		EndIf
	EndIf
EndFunc   ;==>handle_Health

Func handle_Coffre(ByRef $item)
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
	If GetAttribute($CurrentIdAttrib, $Atrib_Chest_Open) = 0 Then
		If Coffre($item) = False Then
			_log("Ban coffre -> " & $item[1])
			BanActor($item[1])
		EndIf
	EndIf
EndFunc


Func handle_Shrine(ByRef $item)
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
	If GetAttribute($CurrentIdAttrib, $Atrib_gizmo_state) <> 1 Then
		If shrine($item[1], $item[8], $item[0]) = False Then
			_log("Ban shrine -> " & $item[1])
			BanActor($item[1])
		EndIf
	EndIf
EndFunc   ;==>handle_Shrine


Func handle_Mob(ByRef $item, ByRef $IgnoreList, ByRef $test_iterateallobjectslist)
	; we have a monster
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########

	;_log("Current Hp -> " & GetAttribute($CurrentIdAttrib, $Atrib_Hitpoints_Cur) & " Is Invulnerable -> " & GetAttribute($CurrentIdAttrib, $Atrib_Invulnerable))

	If GetAttribute($CurrentIdAttrib, $Atrib_Hitpoints_Cur) > 0 And GetAttribute($CurrentIdAttrib, $Atrib_Invulnerable) = 0 Then

		$foundobject = 1
		If KillMob($item[1], $item[8], $item[0],$test_iterateallobjectslist) = False Then
			;_log("Ban monster -> " & $item[1])
			$IgnoreList = $IgnoreList & $item[8] ; BanActor($item[1])

			If $killtimeout > 2 Or $grabtimeout > 2 Then
				_log("_checkdisconnect Cuz :If $killtimeout > 2 or $grabtimeout > 2 Then")
				If _checkdisconnect() Or _playerdead() Then
					$GameFailed = 1
				EndIf
			EndIf
		EndIf
		;If $MonsterRefresh Then
		;	Dim $buff_array = UpdateArrayAttack($test_iterateallobjectslist, $IgnoreList, 1)
		;	$test_iterateallobjectslist = $buff_array
		;EndIf
	Else
		_log('ignoring ' & $item[1])
		; TODO : Check if should BanActor
		$IgnoreList = $IgnoreList & $item[8]
		;_log("Grabtimeout : " & $grabtimeout & " killtimeout: "& $killtimeout)
		If $killtimeout > 2 Or $grabtimeout > 2 Then
			If _checkdisconnect() Or _playerdead() Then
				$GameFailed = 1
			EndIf
		EndIf
	EndIf
EndFunc   ;==>handle_Mob

 Func Checkqual($_GUID)
    ; _log("guid: "&$_GUID &" name: "& $_NAME & " qual: "&IterateActorAtribs($_GUID, $Atrib_Item_Quality_Level))
    $ACD = GetACDOffsetByACDGUID($_GUID)
    $CurrentIdAttrib = _memoryread($ACD + 0x120, $d3, "ptr");
    $quality = GetAttribute($CurrentIdAttrib, $Atrib_Item_Quality_Level)
    Return $quality
EndFunc   ;==>CheckItem
Func handle_Loot(ByRef $item, ByRef $IgnoreList, ByRef $test_iterateallobjectslist)
        $grabit = False

                _log("Checking " & $item[1])

				If $gestion_affixe_loot Then
					Dim $item_aff_verif = IterateFilterAffixV2()
				Else
					$item_aff_verif = ""
				EndIf



			If IsArray($item_aff_verif) and $gestion_affixe_loot Then
			   if is_zone_safe($item[2],$item[3],$item[4],$item_aff_verif) or Checkqual($item[0])=9 then
							$itemDestination = CheckItem($item[0], $item[1])
							If $itemDestination == "Stash" Or $itemDestination == "Salvage" Or ($itemDestination == "Inventory" And $takepot = True) Then
									; this loot is interesting
									$foundobject = 1
									If Grabit($item[1], $item[8]) = False Then
											_log("Ban Item -> " & $item[1] & " Reason Grabit To False (With affix)")
											BanActor($item[1])

											;_log('ignoring ' & $item[1])
											;$IgnoreList = $IgnoreList & $item[8]
											;handle_banlist($item[2]&"-"&$item[3]&"-"&$item[4])


											;_log("Grabtimeout : " & $grabtimeout & " killtimeout: "& $killtimeout)
											If $killtimeout > 2 Or $grabtimeout > 2 Then
													If _checkdisconnect() Or _playerdead() Then
															_log('_checkdisconnect A or player D')
															$GameFailed = 1
													EndIf
											EndIf

									EndIf

									If $ItemRefresh Then
											Dim $buff_array = UpdateArrayAttack($test_iterateallobjectslist, $IgnoreList, 1)
											$test_iterateallobjectslist = $buff_array
									EndIf
							Else
									If checkFromList($List_Monster, $item[1]) = False Then
											_log("Ban Item -> " & $item[1] & " Reason checkFromList To False (With affix)")
											BanActor($item[1])
											;$IgnoreItemList = $IgnoreItemList & $item[1] & "-"

											;_log('ignoring ' & $item[8] & " : " & $item[1] & " :::::" &$IgnoreItemList)
									EndIf
							 EndIf
			   EndIf
		   Else

				$itemDestination = CheckItem($item[0], $item[1])



                If $itemDestination == "Stash" Or $itemDestination == "Salvage" Or ($itemDestination == "Inventory" And $takepot = True) Then
                        ; this loot is interesting
                        $foundobject = 1



                        If Grabit($item[1], $item[8]) = False Then
								_log("Ban Item -> " & $item[1] & " Reason Grabit To False")
								BanActor($item[1])

								;_log("Grabtimeout : " & $grabtimeout & " killtimeout: "& $killtimeout)

                                ;_log("Grabtimeout : " & $grabtimeout & " killtimeout: "& $killtimeout)
                                If $killtimeout > 2 Or $grabtimeout > 2 Then
                                        If _checkdisconnect() Or _playerdead() Then
                                                _log('_checkdisconnect A or player D')
                                                $GameFailed = 1
                                        EndIf
                                EndIf

                        EndIf

                        If $ItemRefresh Then
                                Dim $buff_array = UpdateArrayAttack($test_iterateallobjectslist, $IgnoreList, 1)
                                $test_iterateallobjectslist = $buff_array
                        EndIf
                Else
                        If checkFromList($List_Monster, $item[1]) = False Then
								_log("Ban Item -> " & $item[1] & " Reason checkFromList To False")
								BanActor($item[1])

								;$IgnoreItemList = $IgnoreItemList & $item[1] & "-"

                                ;_log('ignoring ' & $item[8] & " : " & $item[1] & " :::::" &$IgnoreItemList)
                        EndIf
                EndIf
          EndIf

 EndFunc   ;==>handle_Loot

;;--------------------------------------------------------------------------------
;;      Attack()
;;--------------------------------------------------------------------------------
Func Attack()
	If _playerdead_revive() Then
		Return
	EndIf

	If _playerdead() Or ($GameFailed = 1) Then
		$GameFailed = 1
		_log("Return Cuz : If _playerdead or gamefailed ")
		Return
	EndIf

	Local $IgnoreList = ""
	Local $item[$TableSizeGuidStruct + 1]
	Local $OldActor = ""

	Dim $test_iterateallobjectslist = IterateFilterAttackV4($IgnoreList)

	While IsArray($test_iterateallobjectslist)
		If _playerdead_revive() Then
			_log("ExitLoop cause of player_revive")
			ExitLoop
		EndIf
		If _playerdead() Or ($GameFailed = 1) Then
			$GameFailed = 1
			_log("Return Cuz : If _playerdead or gamefailed ")
			ExitLoop
		EndIf

		For $i = 0 To $TableSizeGuidStruct
			$item[$i] = $test_iterateallobjectslist[0][$i]
		Next

		If $OldActor = $item[1] Then
			BanActor($item[1])
			_log("Ban Actor Cause of second passage")
			ExitLoop
		Else
			$OldActor  = $item[1]
		EndIF

		Select
			   Case $item[13] = $ITEM_TYPE_LOOT
				 handle_Loot($item, $IgnoreList, $test_iterateallobjectslist)
			   Case $item[13] = $ITEM_TYPE_MOB
				 handle_Mob($item, $IgnoreList, $test_iterateallobjectslist)
			   Case $item[13] = $ITEM_TYPE_SHRINE
				 handle_Shrine($item)
			   Case $item[13] = $ITEM_TYPE_CHEST
				 handle_Coffre($item)
			   Case $item[13] = $ITEM_TYPE_DECOR
			   	 ; TODO : Gérer proprement pour un timeout different et pas d'utilisation de gros skills
				 handle_Mob($item, $IgnoreList, $test_iterateallobjectslist)
			   Case $item[13] = $ITEM_TYPE_HEALTH
				 handle_Health($item)
			   Case $item[13] = $ITEM_TYPE_POWER
				 handle_Power($item)
		EndSelect

		Dim $test_iterateallobjectslist = IterateFilterAttackV4($IgnoreList)

	WEnd

EndFunc   ;==>Attack

Func DetectElite($Guid)
	Return _MemoryRead(GetACDOffsetByACDGUID($Guid) + 0xB8, $d3, 'int')
EndFunc   ;==>DetectElite

;;--------------------------------------------------------------------------------
;;      KillMob()
;;--------------------------------------------------------------------------------

Func KillMob($Name, $offset, $Guid, $test_iterateallobjectslist2);pacht 8.2e
        $return = True
        $begin = TimerInit()


        Dim $pos = UpdateObjectsPos($offset)

        $Coords = FromD3toScreenCoords($pos[0], $pos[1], $pos[2])
        MouseMove($Coords[0], $Coords[1], 3)

        $elite = DetectElite($Guid)
        ;loop the attack until the mob is dead

		If $elite Then $CptElite += 1;on compte les elite

        _log("Attacking : " & $Name & "; Type : " & $elite);


        Local $maxhipi = Round(IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur))
        Local $timerinit = TimerInit()
        Local $timetokill
        Local $dps
        Local $varTemp

        While IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur) > 0



                $myposs_aff = GetCurrentPos()

                If _playerdead_revive() Then
                        $return = False
                        ExitLoop
                EndIf
                Dim $pos = UpdateObjectsPos($offset)

                If $gestion_affixe Then maffmove($myposs_aff[0], $myposs_aff[1], $myposs_aff[2], $pos[0], $pos[1])
                For $a = 0 To UBound($test_iterateallobjectslist2) - 1

                        $CurrentACD = GetACDOffsetByACDGUID($test_iterateallobjectslist2[$a][0]); ###########
                        $CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########

                        If GetAttribute($CurrentIdAttrib, $Atrib_Hitpoints_Cur) > 0 Then
                                Dim $dist_maj = UpdateObjectsPos($test_iterateallobjectslist2[$a][8])
                                $test_iterateallobjectslist2[$a][9] = $dist_maj[3]
                        Else
                                $test_iterateallobjectslist2[$a][9] = 10000
                        EndIf
                Next

                _ArraySort($test_iterateallobjectslist2, 0, 0, 0, 9)

                $dist_verif = GetDistance($test_iterateallobjectslist2[0][2], $test_iterateallobjectslist2[0][3], $test_iterateallobjectslist2[0][4])
                Dim $pos = UpdateObjectsPos($offset)

				If $pos[3] > $dist_verif + 5 Then
					_log("Leave KillMob Cause of Dist Verif : " & $pos[3] & " - " & $dist_verif)
					ExitLoop
				EndIf
				;If $Pos[3] > $Hero_Axe_Z Then ExitLoop

                $Coords = FromD3toScreenCoords($pos[0], $pos[1], $pos[2])
                MouseMove($Coords[0], $Coords[1], 3)
                GestSpellcast($pos[3], 1, $elite, $Guid, $offset)
                If TimerDiff($begin) > $a_time Then
                        $killtimeout += 1
                        ; after this time, the mob should be dead, otherwise he is probly unkillable
                        $return = False
                        ExitLoop
                EndIf
        WEnd

        $varTemp=IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur)

        If (IsNumber($varTemp) And $varTemp>0) Then
                        $maxhipi = $maxhipi - $varTemp
        EndIf

        $timetokill = Round(TimerDiff($timerinit) / 1000, 2)
        $dps = Round($maxhipi / $timetokill)
        $AverageDps=Ceiling( ($AverageDps*($NbMobsKilled-1) + $dps ) / $NbMobsKilled)
        $NbMobsKilled+=1

        Return $return
EndFunc   ;==>KillMob

;;--------------------------------------------------------------------------------
;;      Grabit()
;;--------------------------------------------------------------------------------
Func Grabit($name, $offset)
	Local $OriginalOffsetValue = _MemoryRead($offset + 0x0, $d3, 'ptr')
	$begin = TimerInit()
	Dim $CoordVerif[3]


	_log("Grabbing :" & ($name)) ;FOR DEBUGGING

	Dim $pos = UpdateObjectsPos($offset)

	If (StringInStr($name, "gold")) Then
		$Coords = FromD3toScreenCoords($pos[0], $pos[1], $pos[2])
		$CoordVerif[0] = $pos[0]
		$CoordVerif[1] = $pos[1]
		$CoordVerif[2] = $pos[2]
		MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 5)
	Else
		Interact($pos[0], $pos[1], $pos[2])
	EndIf
	While _MemoryRead($offset + 0x0, $d3, 'ptr') = $OriginalOffsetValue
		If _MemoryRead($offset + 0x0, $d3, 'ptr') = 0xFFFFFFFF Then
			ExitLoop
		EndIf

		If _playerdead_revive() Then
			$return = False
			ExitLoop
		EndIf
		GestSpellcast(0, 2, 0)

		If TimerDiff($begin) > $g_time Then
			$grabtimeout += 1
			; After this time we should already had the item
			Return False
		EndIf

		If $grabskip = 1 Then
			Return False
			ExitLoop
		EndIf

		Dim $pos = UpdateObjectsPos($offset)

		If (StringInStr($name, "gold")) Then


			$Coords = FromD3toScreenCoords($pos[0], $pos[1], $pos[2])

			;Check if the coord X y z havn't changed.
			If ($CoordVerif[0] <> $pos[0] Or $CoordVerif[1] <> $pos[1] Or $CoordVerif[2] <> $pos[2]) Then
				_log("Fake GOLD")
				Return False
			Else
				MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 5)
			EndIf
		Else

			;_log($pos[0] & " - " & $pos[1] & " - " & $pos[2])
			Interact($pos[0], $pos[1], $pos[2])


			;If _inventoryfull() Then
			If Detect_UI_error(0) And $Tp_Repair_And_Back = 0 Then ; $Tp_Repair_And_Back = 0,car on ne veut pas y rentrer plus d'une fois "correction double tp inventaire plein"
				$Tp_Repair_And_Back = 1
				Unbuff()
					TpRepairAndBack()
				Buffinit()
				$Tp_Repair_And_Back = 0
			EndIf

		EndIf
		Sleep(50)
	WEnd
	Return True
EndFunc   ;==>Grabit

Func GetIlvlFromACD($_ACDid)
	_log("$_ACDid -> " & $_ACDid)
	$ACDStructure = DllStructCreate("int;char[128];byte[12];int;byte[32];ptr;ptr")
	$itemsAcdOfs = $_ACDid
	$CurrentIdAttrib = _memoryread($itemsAcdOfs + 0x120, $d3, "ptr"); ###########

	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $itemsAcdOfs, 'ptr', DllStructGetPtr($ACDStructure), 'int', DllStructGetSize($ACDStructure), 'int', '')

	$idsnogball = DllStructGetData($ACDStructure, 6)


	Local $iIndex = _ArraySearch($allSNOitems, $idsnogball, 0, 0, 1, 1)
	;_log($iIndex)
	If Int($iIndex) < UBound($allSNOitems) AND Int($iIndex) >= 0 Then
		_log("iIndex - > " & $iIndex)
		Return $allSNOitems[$iIndex][1]
	Else
		Return 0
	EndIf

EndFunc   ;==>GetIlvlFromACD

;;================================================================================
; Function:                     CheckItem
; Description:          This will check a single item and tell if we keep it or not
;                                       This function will be the core of the item filtering
;
; Return:                       Trash
;                                       Stash
;                                       Salvage
;                                       Inventory
;==================================================================================
Func CheckItem($_GUID, $_NAME, $_MODE = 0)
	; _log("guid: "&$_GUID &" name: "& $_NAME & " qual: "&IterateActorAtribs($_GUID, $Atrib_Item_Quality_Level))
	_log("checkitem -> " & $_NAME)

	If checkFromList($Potions, $_NAME) Then
		_log($_NAME & " ==> It's a pot")
		Return "Inventory"
	ElseIf checkFromList($grablist, $_NAME) Then
		Return "Stash"
	EndIf


	If Not Checkstartlist_regex($Ban_ItemACDCheckList, $_NAME) Then

		;_log("Pas Trash")

		$ACD = GetACDOffsetByACDGUID($_GUID)
		$CurrentIdAttrib = _memoryread($ACD + 0x120, $d3, "ptr");
		$quality = GetAttribute($CurrentIdAttrib, $Atrib_Item_Quality_Level)


		If $quality >= $QualityLevel Then ;filter the magic and higher
			_log($_NAME & " ==> It's the quality level >" & $QualityLevel)
			Return "Stash"
		EndIf


		If checkFromtable($GrabListTab, $_NAME, $quality) Then
			If checkIlvlFromtable($GrabListTab, $ACD, $_NAME) Then

				If $_MODE = 0 Then
				   If Not $FilterItemGround Then ; si true applique le filtre sur les item au sol,false on applique pas
					  _Log($_NAME & " ==> It's a rare in our list ")
					  Return "Stash"
				   Else
					  _log($_NAME & " ==> It's a rare in our list We have to check the stats")

					  If checkFiltreFromtable($GrabListTab, $_NAME, $CurrentIdAttrib) Then
						 Return "Stash"
					  Endif
				   EndIf

				Else
					_log($_NAME & " ==> It's a rare in our list for filterbackpack")
					Return "Stash_filtre"
				EndIf

			EndIf
		EndIf
	EndIf

	_log($_NAME & " ==> Trash item")
	Return "Trash"
EndFunc   ;==>CheckItem

Func InventoryMove($col = 0, $row = 0);pacht 8.2e

	;$Coords = UiRatio(530 + ($col * 27), 338 + ($row * 27))
	;MouseMove($Coords[0], $Coords[1], 2)
	;MouseClick("right", $XCoordinate, $YCoordinate)


	$result = GetOfsFastUI("Root.NormalLayer.inventory_dialog_mainPage.timer slot 0 x0 y0", 1509)
	Dim $Point = GetPositionUI($result)
	Dim $Point2 = GetUIRectangle($Point[0], $Point[1], $Point[2], $Point[3])

	$FirstCaseX = $Point2[0] + $Point2[2] / 2
	$FirstCaseY = $Point2[1] + $Point2[3] / 2

	$SizeCaseX =  $Point2[2]
	$SizeCaseY =  $Point2[3]

	$XCoordinate = $FirstCaseX + $col * $SizeCaseX
	$YCoordinate = $FirstCaseY + $row * $SizeCaseY

	MouseMove($XCoordinate, $YCoordinate, 2)


EndFunc   ;==>InventoryMove

;;--------------------------------------------------------------------------------
;;      checkForPotion()
;;--------------------------------------------------------------------------------
Func checkForPotion()

	$life = GetLifep()
	$diff = TimerDiff($timeforpotion)
	If $life < $LifeForPotion / 100 And $diff > 1500 Then
		Send($KeyPotions)
		$timeforpotion = TimerInit()
	EndIf

EndFunc   ;==>checkForPotion

;;--------------------------------------------------------------------------------
;;      checkFromList()
;;--------------------------------------------------------------------------------
Func checkFromList($list, $compare, $delimiter = '|')
	Local $arrayList = StringSplit($list, $delimiter)
	For $i = 1 To $arrayList[0]
		If StringInStr($compare, $arrayList[$i]) Then
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>checkFromList


Func Checkstartlist_regex($compare, $_NAME)
	Dim $tab_temp = StringSplit($compare, "|", 2)
	$count = UBound($tab_temp)
	For $i = 0 To $count - 1
		If StringRegExp($_NAME, "(?i)^" & $tab_temp[$i] & "") = 1 Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>Checkstartlist_regex

Func Checkendlist_regex($compare, $_NAME)
	Dim $tab_temp = StringSplit($compare, "|", 2)
	$count = UBound($tab_temp)
	For $i = 0 To $count - 1
		If StringRegExp($_NAME, "(?i)" & $tab_temp[$i] & "$") = 1 Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>Checkendlist_regex


Func Checkendstr_regex($compare, $_NAME)
	If StringRegExp($_NAME, "(?i)$" & $compare & "$") = 1 Then
		Return True
	EndIf
EndFunc   ;==>Checkendstr_regex

Func Checkstartstr_regex($compare, $_NAME)
	If StringRegExp($_NAME, "(?i)^" & $compare & "") = 1 Then
		Return True
	EndIf
EndFunc   ;==>Checkstartstr_regex


Func checkFromTable($table, $compare, $quality)
	For $i = 0 To UBound($table) - 1
		If StringRegExp($compare, "(?i)^" & $table[$i][0] & "") = 1 And $quality >= $table[$i][2] Then
			;If StringInStr($compare, $table[$i][0]) And $quality >= $table[$i][2] Then
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>checkFromTable

Func checkIlvlFromTable($table, $ACD, $compare)
	For $i = 0 To UBound($table) - 1
		If StringRegExp($compare, "(?i)^" & $table[$i][0] & "") = 1 Then
			;If StringInStr($compare, $table[$i][0]) Then
			If $table[$i][1] > 0 Then
				$ilvl = GetILvlFromACD($ACD)
				If $ilvl >= $table[$i][1] Then
					Return 1
				EndIf
			Else
				Return 1
			EndIf
		EndIf
	Next
	Return 0
EndFunc   ;==>checkIlvlFromTable

Func checkFiltreFromtable($table, $name, $CurrentIdAttrib)
	For $i = 0 To UBound($table) - 1
		If StringRegExp($name, "(?i)^" & $table[$i][0] & "") = 1 Then
			If Not $table[$i][3] = 0 Then
				$filtre_buff = $table[$i][3]
				$tab_filter = StringSplit($table[$i][4], "|", 2)
				;_log("filtre avant : " & $filtre_buff, True)
				For $y = 0 To UBound($tab_filter) - 1
					$const_result = _filter2attrib($CurrentIdAttrib, $tab_filter[$y])
					$filtre_buff = StringReplace($filtre_buff, $tab_filter[$y], $const_result, 0, 2)
					$filtre_buff = StringReplace($filtre_buff, ":", ">=", 0, 2)
				Next
				;_log("filtre apres : " & $filtre_buff)
				If Execute($filtre_buff) Then
					;_log("execute donne true")
					Return True
				Else
					;_log("execute donne false")
					Return False
				EndIf
			EndIf
		EndIf
	Next

EndFunc   ;==>checkFiltreFromtable

Func OpenWp(ByRef $item)
	Local $maxtry = 0
	If NOT _playerdead() Then
		_log($item[1] & " distance : " & $item[9])
		While getDistance($item[2], $item[3], $item[4]) > 40 And $maxtry <= 15
			$Coords = FromD3toScreenCoords($item[2], $item[3], $item[4])
			;_log("Dans LE while")
			MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 10)
			$maxtry += 1
			_log('interactbyactor: click x : ' & $Coords[0] & " y : " & $Coords[1])
			Sleep(500)
		WEnd
		Interact($item[2], $item[3], $item[4])
		Sleep(100)
	EndIf

EndFunc   ;==>OpenWp

Func GetBucketForWP($WPNumber)
	Switch $WPNumber
		Case 0
			Return 212
		Case 1
			Return 305
		Case 2
			Return 1540
		Case 3
			Return 375
		Case 4
			Return 646
		Case 5
			Return 302
		Case 6
			Return 579
		Case 7
			Return 1898
		Case 8
			Return 176
		Case 9
			Return 502
		Case 10
			Return 1270
		Case 11
			Return 1509
		Case 12
			Return 1578
		Case 13
			Return 404
		Case 14
			Return 246
		Case 15
			Return 373
		Case Else
			Return 0
	EndSwitch
EndFunc

Func TakeWPV2($WPNumber = 0)
    Local $Curentarea = GetLevelAreaId()
    Local $Newarea = $Curentarea

	If $GameFailed = 1 Then 
		Return False
	EndIf

	While Not offsetlist()
		Sleep(10)
	WEnd

	Local $BucketUI = GetBucketForWP($WPNumber)

	If $WPNumber = 0 Then
		$NameUI = "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 0.LayoutRoot.Town"
	Else
		$NameUI = "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry " & $WPNumber & ".LayoutRoot.Name"
	EndIf

	$WayPointEntity = "Waypoint"
	$WayPointFound = False

	Local $index, $offset, $count, $item[10], $maxRange = 80
		startIterateObjectsList($index, $offset, $count)
		While iterateObjectsList($index, $offset, $count, $item)

			If StringInStr($item[1], $WayPointEntity) Then
				_log("WayPoint Found, Try with MaxRange")
				If $item[9] < $maxRange Then
					_log("WayPoint OK, MaxRange OK")
					$WayPointFound = true
					ExitLoop
				Else
					_log("WayPoint OK, MaxRange FALSE")
				EndIF
			EndIf

		WEnd

		If $WayPointFound Then
			_Log("WP Found")
			OpenWp($item)
			Sleep(750)
			Local $wptry = 0
			While _checkWPopen() = False And _playerdead() = False
				If $wptry <= 6 Then
					_log('Fail to open wp')
					$wptry += 1
					OpenWp($item)
					Sleep(500)
				EndIf
				If $wptry > 6 Then
					$GameFailed = 1
					_log('Failed to open wp after 6 try')
					return false
				EndIf
			WEnd

			sleep(500)
			_log("clicking wp UI")

			If ($BucketUI = 0) Then
				ClickUI($NameUI)
			Else
				ClickUI($NameUI, $BucketUI)
			EndIf

			Local $areatry = 0
			While $Newarea = $Curentarea And $areatry < 13 ; on attend d'avoir une nouvelle Area environ 6 sec
				$Newarea = GetLevelAreaId()
				Sleep(500)
				$areatry += 1
			WEnd

			Sleep(500)

			While Not offsetlist()
				Sleep(10)
			WEnd

			$SkippedMove = 0 ;reset ouur skipped move count cuz we should be in brand new area

			return true
		Else
			_log("WP Not Found")
			$GameFailed = 1
			_log("$GameFailed = 1 $GameFailed = 1 $GameFailed = 1")
			return False
		EndIF
EndFunc

;;--------------------------------------------------------------------------------
;;      _resumegame()
;;--------------------------------------------------------------------------------
Func _resumegame()
	_log("Resume Game")
	Sleep(Random(500, 1000, 1));pacht 8.2e
	If $Try_ResumeGame > 2 Then
		Local $wait_aftertoomanytry = Random(($Try_ResumeGame * 2) * 60000, ($Try_ResumeGame * 2) * 120000, 1)
		_log("Sleep after too many _resumegame -> " & $wait_aftertoomanytry)
		Sleep($wait_aftertoomanytry)
	EndIf

	If $Try_ResumeGame = 0 And $BreakCounter >= ($Breakafterxxgames + Random(-2, 2, 1)) And $TakeABreak Then;$TryResumeGame = 0 car on veut pas faire une pause en plein jeu
		Local $wait_BreakTimeafterxxgames = (($BreakTime * 1000) + Random(60000, 180000, 1))
		_Log("Break Time after xx games -> Sleep " & (formatTime($wait_BreakTimeafterxxgames)))
		Sleep($wait_BreakTimeafterxxgames)
		$BreakCounter = 0;on remet le compteur a 0
		$BreakTimeCounter += 1;on compte les pause effectuer
		$tempsPauseGame += $wait_BreakTimeafterxxgames;  compte le temps de pause
	EndIf


	;_randomclick(135, 285)
	ClickUI("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.PlayGameButton")


	$Try_ResumeGame += 1
	Sleep(7000)
EndFunc   ;==>_resumegame 2.0

Func _logind3()

	If $Try_Logind3 > 2 Then
		Local $wait_aftertoomanytry = Random(($Try_Logind3 * 2) * 60000, ($Try_Logind3 * 2) * 120000, 1)
		_log("Sleep after too many _logind3 -> " & $wait_aftertoomanytry)
		Sleep($wait_aftertoomanytry)
	EndIf

	WinActivate("[CLASS:D3 Main Window Class]")

	If Not _checkdisconnect() Then ; le bot ne fait pas la différence entre _checkdisconnect et déconnecter du serveur
		_Log("Login")
		Sleep(1000)
		Send($d3pass)
		Sleep(2000)
		Send("{ENTER}")
		Sleep(Random(5000, 6000, 1))

		$Try_Logind3 += 1
	Else
		_Log("Disconnected to server")
		sleep(2000)
		Send("{ENTER}")
		sleep(2000)
		Send("{ENTER}") ; enter, si jamais on a rentré le mot passe avant que la fenêtre apparaisse
		sleep(2000)
	EndIf
EndFunc   ;==>_logind3


;;--------------------------------------------------------------------------------
;;      _leavegame()
;;--------------------------------------------------------------------------------
Func _leavegame()
	If _ingame() Then
		If Not $PartieSolo Then WriteMe($WRITE_ME_QUIT) ; TChat
		_log("Leave Game")
		Send($KeyCloseWindows) ; to make sure everything is closed
		sleep(100)
		Send("{ESCAPE}")
		Sleep(Random(200, 300, 1))
		While _escmenu() = False
			Send("{ESCAPE}")
			Sleep(Random(200, 300, 1))
		WEnd
		;_randomclick(134, 264)

		While NOT fastcheckuiitemvisible("Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame", 1, 1644);tant que boton exit nest pas la
			Send("{ESCAPE}")
			Sleep(500)
			_log("Menu Open but btn leaveGame Doesnt Exit yet")
		WEnd

		Local $TryLeave = 0
		While fastcheckuiitemvisible("Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame", 1, 1644) And $TryLeave < 5 ;après 4 fois on laisse la main au reste du code,car il y a forcément déco
			ClickUI("Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame", 1644)
			Sleep(Random(600, 1200, 1))
			$TryLeave += 1
		WEnd

		Sleep(Random(500, 1000, 1))
		_log("Leave Game Done")
	EndIf
EndFunc   ;==>_leavegame



Global $VendorTabRepair = ""
Global $VendorTabSell = 0

;;--------------------------------------------------------------------------------
;;      Repair()
;;--------------------------------------------------------------------------------
Func Repair()
	GetAct()

	Switch $Act
	        Case 1
	                MoveToPos(2914.19946289063, 2802.09716796875, 24.0453300476074,1,25)
	        Case 2
	                ;do nothing act 2
	        Case 3 To 4
	                ;do nothing act 3-4
	EndSwitch

	InteractByActorName($RepairVendor)

	Sleep(700)
	Local $vendortry = 0
	While _checkVendoropen() = False
		If $vendortry <= 4 Then
			_log('Fail to open vendor')
			$vendortry = $vendortry + 1

			InteractByActorName($RepairVendor)

		EndIf
		If $vendortry > 4 Then
			Send("{PRINTSCREEN}")
			Sleep(200)
			_log('Failed to open Vendor after 4 try')
			WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
			MsgBox(0, "Impossible d'ouvrir le vendeur :", "SVP, veuillez reporter ce problème sur le forum. Erreur : v001 ")
			Terminate()
			ExitLoop
		EndIf
	WEnd

	DefineVendorTab()

	ClickUI("Root.NormalLayer.shop_dialog_mainPage.tab_" & $VendorTabRepair)
	Sleep(100)
	ClickUI("Root.NormalLayer.shop_dialog_mainPage.repair_dialog.RepairEquipped")
	Sleep(100)
EndFunc   ;==>Repair



Func DefineVendorTab()

	if $VendorTabRepair = "" Then ;On a jamais insctancier la recherche des tables

		if fastcheckuiitemvisible("Root.NormalLayer.shop_dialog_mainPage.tab_4", 1, 1984) Then
			$VendorTabRepair = 3
			_log("Definition of Repair Tab to TAB 3")
		Else
			$VendorTabRepair = 2
			_log("Definition of Repair Tab to TAB 2")
		EndIf

	EndIf

EndFunc

;;================================================================================
; Function:			GetDistance($_x,$_y,$_z)
; Description:		Check distance between you and a desired position.
; Parameter(s):		$_x,$_y and $_z - the target position
;
; Note(s):			Returns a distance in float
;==================================================================================
Func GetDistance($_x, $_y, $_z)
	$CurrentLoc = GetCurrentPos()
	$xd = $_x - $CurrentLoc[0]
	$yd = $_y - $CurrentLoc[1]
	$zd = $_z - $CurrentLoc[2]
	$Distance = Sqrt($xd * $xd + $yd * $yd + $zd * $zd)
	Return $Distance
EndFunc   ;==>GetDistance

Func GetDistanceWithoutReadPosition($CurrentLoc, $x, $y, $z)
	$xd = $x - $CurrentLoc[0]
	$yd = $y - $CurrentLoc[1]
	$zd = $z - $CurrentLoc[2]
	$Distance = Sqrt($xd * $xd + $yd * $yd + $zd * $zd)
	Return $Distance
Endfunc

;;================================================================================
; Function:			GetDistance($_x,$_y,$_z)
; Description:		Check distance between you and a desired position.
; Parameter(s):		$_x,$_y and $_z - the target position
;
; Note(s):			Returns a distance in float
;==================================================================================
Func GetMyStats()
	Local $index, $offset, $count, $item[4]
	startIterateLocalActor($index, $offset, $count)
	While iterateLocalActorList($index, $offset, $count, $item)
		If StringInStr($item[2], "GoldCoin-") Then
			_log("Current GOLD: " & IterateActorAtribs($item[1], $Atrib_ItemStackQuantityLo))
			ExitLoop
		EndIf
	WEnd
	_log("Power Disabled: " & IterateActorAtribs($_MyGuid, $Atrib_Magic_Find_Handicap))
	_log("Difficulty: " & IterateActorAtribs($_MyGuid, $Atrib_Difficulty))
	_log("Act: " & IterateActorAtribs($_MyGuid, $Atrib_Act))
	_log("Current Level: " & IterateActorAtribs($_MyGuid, $Atrib_Level))
	_log("Strength: " & IterateActorAtribs($_MyGuid, $Atrib_Strength_Total))
	_log("Dexterity: " & IterateActorAtribs($_MyGuid, $Atrib_Dexterity_Total))
	_log("Inteligence: " & IterateActorAtribs($_MyGuid, $Atrib_Intelligence_Total))
	_log("Vitality: " & IterateActorAtribs($_MyGuid, $Atrib_Vitality_Total))
	_log("Gold find: " & IterateActorAtribs($_MyGuid, $Atrib_Gold_Find))
	_log("Magic find: " & IterateActorAtribs($_MyGuid, $Atrib_Magic_Find))
	_log("Pickup Radius : " & IterateActorAtribs($_MyGuid, $Atrib_Gold_PickUp_Radius))
	_log("Movement speed : " & IterateActorAtribs($_MyGuid, $Atrib_Movement_Scalar_Capped_Total))

EndFunc   ;==>GetMyStats
Func GameOverTime()
	Global $timedifmaxgamelength = TimerDiff($timermaxgamelength)
	If $timedifmaxgamelength > $maxgamelength Then
		_log('game over time !')
		Global $GameOverTime = True
	EndIf
EndFunc   ;==>GameOverTime

Func Terminate()
	_MemoryClose($d3)
	If $checkx64 = 1 Then
		MouseUp($MouseMoveClick)
		MouseUp("left")
		Send("{SHIFTUP}")
		Exit 0
	Else
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
		If Not FileExists(@ScriptDir & ".\stats") Then
			DirCreate(@ScriptDir & ".\stats")
		EndIf
		$file = FileOpen(@ScriptDir & ".\stats\" & $fichierstat, 1)
		FileWriteLine($file, $DebugMessage)
		FileClose($file)
		extendedstats()
		MouseUp($MouseMoveClick)
		MouseUp("left")
		Send("{SHIFTUP}")
		Exit 0
	EndIf
EndFunc   ;==>Terminate

Func StashAndRepairTerminate()

   GoToTown()
   StashAndRepair()
   _leavegame()
   Sleep(6000)
   Terminate()

EndFunc  ;==>StashAndRepairTerminate

Func TogglePause()
	$Paused = Not $Paused
	If $Paused Then
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
		While $Paused
			Sleep(100)
			TrayTip("", 'Script is "Paused"', 5)
		WEnd
	EndIf
	CheckWindowD3()
	CheckWindowD3Size()
EndFunc   ;==>TogglePause

Func _log($text, $forceDebug = False)
	$texte_write = @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & " | " & $text & @CRLF
	If $forceDebug or $debugBot Then
		$file = FileOpen(@ScriptDir & "\log\" & $fichierlog, 1)
		If $file = -1 Then
			ConsoleWrite("!Log file error, can not be opened !")
		Else
			FileWrite($file, $texte_write)
		EndIf
		FileClose($file)
	EndIf
	ConsoleWrite($texte_write)
EndFunc   ;==>_log

Func RandSleep($min = 5, $max = 45, $chance = 3)
	$randNum = Round(Random(1, 100))
	If $randNum <= $chance Then
		$sleepTime = Random($min * 1000, $max * 1000)
		_log("Sleeping " & $sleepTime & "ms")
		For $c = 0 To 10
			Sleep($sleepTime / 10)
		Next
	EndIf
EndFunc   ;==>RandSleep

Func _randomclick($x, $y, $button = "left")
	$coord = UiRatio($x, $y)
	MouseClick($button, Random($coord[0] - 3, $coord[0] + 3), Random($coord[1] - 3, $coord[1] + 3))
EndFunc   ;==>_randomclick

;;--------------------------------------------------------------------------------
;;############# Speels by Xoum
;;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
;;      setChararacter()
;;--------------------------------------------------------------------------------

Func setChararacter($nameChar)
	$splitName = StringSplit($nameChar, "_")
	$nameCharacter = $splitName[1]
	;_log($nameCharacter)
EndFunc   ;==>setChararacter

;;--------------------------------------------------------------------------------
;;      Getfury()
;;--------------------------------------------------------------------------------
Func GetFury()
	Local $index, $offset, $count, $item[10], $foundobject = 0
	startIterateObjectsList($index, $offset, $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], "furyBall_liquid") Then
			Return _MemoryRead($item[8] + 0x40C, $d3, 'float')
		EndIf
	WEnd
EndFunc   ;==>GetFury
;;

;--------------------------------------------------------------------------------
;;      Gethatred()
;;--------------------------------------------------------------------------------
Func GetHatred()
	Local $index, $offset, $count, $item[10], $foundobject = 0
	startIterateObjectsList($index, $offset, $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], "hatred") Then
			Return _MemoryRead($item[8] + 0x40C, $d3, 'float')
		EndIf
	WEnd
EndFunc   ;==>GetHatred
;;

;--------------------------------------------------------------------------------
;;      Getdisc()
;;--------------------------------------------------------------------------------
Func GetDisc()
	Local $index, $offset, $count, $item[10], $foundobject = 0
	startIterateObjectsList($index, $offset, $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], "discipline") Then
			Return _MemoryRead($item[8] + 0x40C, $d3, 'float')
		EndIf
	WEnd
EndFunc   ;==>GetDisc
;;

;--------------------------------------------------------------------------------
;;      Getspirit()
;;--------------------------------------------------------------------------------
Func GetSpirit()
	Local $index, $offset, $count, $item[10], $foundobject = 0
	startIterateObjectsList($index, $offset, $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], "Monk_Spirit") Then
			Return _MemoryRead($item[8] + 0x40C, $d3, 'float')
		EndIf
	WEnd
EndFunc   ;==>GetSpirit
;;

;--------------------------------------------------------------------------------
;;      Getmana()
;;--------------------------------------------------------------------------------
Func GetMana()
	Local $index, $offset, $count, $item[10], $foundobject = 0
	startIterateObjectsList($index, $offset, $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], "mana") Then
			Return _MemoryRead($item[8] + 0x40C, $d3, 'float')
		EndIf
	WEnd
EndFunc   ;==>GetMana
;;

;--------------------------------------------------------------------------------
;;      Getarcane()
;;--------------------------------------------------------------------------------
Func GetArcane()
	Local $index, $offset, $count, $item[10], $foundobject = 0
	startIterateObjectsList($index, $offset, $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], "instability") Then
			Return _MemoryRead($item[8] + 0x40C, $d3, 'float')
		EndIf
	WEnd
EndFunc   ;==>GetArcane

;;--------------------------------------------------------------------------------
; Function:                     EmergencyStopCheck()
; Description:          Check for dangerous behavior and stop bot if needed to prevent problems
;
; Note(s):
;;--------------------------------------------------------------------------------
Func EmergencyStopCheck()

	If $Die2FastCount > 6 Then
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
		MsgBox(4096, "Arret d'urgence", "Nombre de mort : " & $Death)
		Terminate()
	EndIf

	If $NeedRepairCount > 4 Then
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
		MsgBox(4096, "Arret d'urgence", "Nombre de tentatives de repair a la suite : " & $NeedRepairCount)
		Terminate()
	EndIf

EndFunc   ;==>EmergencyStopCheck

;;--------------------------------------------------------------------------------
; Function:                     enoughtPotions()
; Description:    Read amount of pot in inv. Compare with Potionstock and set takepot to true of false.
;
;
;;--------------------------------------------------------------------------------
Func enoughtPotions() ; ok pour 2.0
	Local $potinstock = Number(GetTextUI(221,'Root.NormalLayer.game_dialog_backgroundScreenPC.game_potion.text'))
	If $potinstock > $PotionStock Then
		_log("I have more than " & $PotionStock & " potions. I will not take more until next check " & "(" & $potinstock & ")")
		$takepot = False
	Else
		_log("I have less than " & $PotionStock & " potions. I will grab them until next check " & "pot:" & "(" & $potinstock & ")")
		$takepot = True
	EndIf
EndFunc   ;==>enoughtPotions

;;--------------------------------------------------------------------------------
; Function:                     Shrine()
; Description:    Take Bonus shrine
;;--------------------------------------------------------------------------------
Func shrine($name, $offset, $Guid)

        Local $begin = TimerInit()
        While iterateactoratribs($Guid, $Atrib_gizmo_state) <> 1 And _playerdead() = False

                If getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float')) >= 8 Then
                        If TimerDiff($begin) > 4000 Then
                                _log('shrine is banned because time out')
                                Return False
                                ExitLoop
                        Else
                                $Coords = FromD3toScreenCoords(_MemoryRead($offset + 0xB4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
                                MouseMove($Coords[0], $Coords[1], 3)
                        EndIf
                EndIf
	    If TimerDiff($begin) > 6000 Then
            _log('Fake shrine')
            Return false
        EndIf
                Interact(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBc, $d3, 'float'))
        WEnd

		$CheckTakeShrineTaken += 1;on compte les CheckTakeShrine qu'on prend

	EndFunc   ;==>shrine


Func Coffre($item)

		$name = $item[1]
		$offset = $item[8]
		$Guid = $item[0]

        Local $begin = TimerInit()
        While iterateactoratribs($Guid, $Atrib_Chest_Open) = 0 And _playerdead() = False

                If getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float')) >= 8 Then
                        If TimerDiff($begin) > 6000 Then
                                _log('Coffre is banned because time out')
                                Return False
                                ExitLoop
                        Else
                                $Coords = FromD3toScreenCoords(_MemoryRead($offset + 0xB4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
                                MouseMove($Coords[0], $Coords[1], 3)
                        EndIf
                EndIf
If TimerDiff($begin) > 80000 Then
            _log('Fake Actionnable')
            Return false
        EndIf
                Interact(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBc, $d3, 'float'))
		WEnd

			$CoffreTaken += 1;on compte les coffres qu'on ouvre
	; TODO : Do that correctly !
	sleep(800)
EndFunc   ;==>shrine


Func Health($name, $offset, $Guid)

         $life = GetLifep()
         Local $timeForHealth = TimerInit()
         While iterateactoratribs($Guid, $Atrib_gizmo_state) <> 1 And _playerdead() = False

                 Local $distance = getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
                 If $distance >= 8 Then
                         If $life < ($LifeForHealth / 100) Then
                                 If TimerDiff($timeForHealth) > 2000 Then
                                         _log('health is banned because time out')
                                 Return False
                         Else
                                 $Coords = FromD3toScreenCoords(_MemoryRead($offset + 0xB4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
                                 MouseMove($Coords[0], $Coords[1], 3)
                                 EndIf
                         ElseIf $life = 1 Then
                                 _log('Health globe ignore (already full life)')
                                 Return True
                         Endif
                 ElseIf $distance < 3 Then
                         _log('Health globe taken (distance=' & $distance & ')')
                         Return True
                 EndIf

                 If TimerDiff($timeForHealth) > 3000 Then
                         _log('Fake health')
                         Return False
                 EndIf

                 Interact(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBc, $d3, 'float'))
         WEnd

 EndFunc   ;==>health

 Func Power($name, $offset, $Guid)

         Local $timeForPower = TimerInit()
         While iterateactoratribs($Guid, $Atrib_gizmo_state) <> 1 And _playerdead() = False

                 Local $distance = getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
                 If $distance >= 8 Then
                           If TimerDiff($timeForPower) > 2000 Then
                                  _log('Power globe is banned because time out')
                                  Return False
                           Else
                                  $Coords = FromD3toScreenCoords(_MemoryRead($offset + 0xB4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
                                  MouseMove($Coords[0], $Coords[1], 3)
                           EndIf
                 ElseIf $distance < 3 Then
                    _log('Power globe taken (distance=' & $distance & ')')
                    Return True
                 EndIf

                 If TimerDiff($timeForPower) > 3000 Then
                    _log('Fake power globe')
                    Return False
                 EndIf

                 Interact(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBc, $d3, 'float'))
         WEnd

 EndFunc   ;==>power

;;--------------------------------------------------------------------------------
; Function:                     Die2Fast()
; Description:    Cette fonction est appelée toute les 20 min.
;
; Note(s): Permet de detecter un nombre de mort a la suite trop important
;;--------------------------------------------------------------------------------
Func Die2Fast()
	$Die2FastCount = 0
EndFunc   ;==>Die2Fast

;;--------------------------------------------------------------------------------
; Functions:                     Attrib STUFF
; Description:    Read Atrib without dll
;;--------------------------------------------------------------------------------

Func GetFAG($idAttrib)
	$c = _memoryread($ofs_objectmanager, $d3, "ptr")
	$c1 = _memoryread($c + 0x8ac, $d3, "ptr")
	$c2 = _memoryread($c1 + 0x54, $d3, "ptr")
	$id = BitAND($idAttrib, 0xFFFF)
	$bitshift = _memoryread($c2 + 0x164, $d3, "int")
	$group1 = _memoryread(_memoryread($c2 + 0x120, $d3, "ptr"), $d3, "int")
	$group2 = 4 * BitShift($id, $bitshift)
	$group3 = BitShift(1, -$bitshift) - 1
	$group4 = 0x9c8 * BitAND($id, $group3)
	Return $group2 + $group4 + $group1
EndFunc   ;==>GetFAG

Func GetAttributeOfs($idAttrib, $attrib)
	$FAG = GetFAG($idAttrib)


	$IndexMask = BitXOR($attrib, BitShift($attrib ,12))
	$ptr1 = _memoryread($FAG + 0x4, $d3, "int")

	$AttribEntry = 0
	if BitAnd($ptr1, 4) = 4 Then
		$AttribFormula = _memoryread($FAG + 0xc, $d3, "ptr")
		$ArrayBasePtr =  _memoryread($AttribFormula + 0x10, $d3, "int")
		$Limit = _memoryread($AttribFormula, $d3, "int")
		$AttribEntry = _memoryread($ArrayBasePtr + 4 * BitAND($IndexMask, $Limit), $d3, "int")
	Else
		$AttribEntry = _memoryread($FAG + 0x20 + 4 * BitAND($IndexMask + 3, 0xFF), $d3, "int") ; Ou 2c et pas de +3
	EndIF

	If $AttribEntry <> 0 Then

		While _memoryread($AttribEntry + 0x4, $d3, "ptr") <> $attrib
			$AttribEntry = _memoryread($AttribEntry, $d3, "ptr")
			If $AttribEntry = 0 Then
				;_log("AttribEntry = 0")
				Return -1
			EndIf
		WEnd

		Return $AttribEntry + 8
	EndIf

	Return -1

EndFunc   ;==>GetAttributeOfs

Func GetAttributeInt($idAttrib, $attrib)
	Return _memoryread(GetAttributeOfs($idAttrib, BitOR($attrib, 0xFFFFF000)), $d3, "int")
EndFunc   ;==>GetAttributeInt

Func GetAttributeFloat($idAttrib, $attrib)
	Return _memoryread(GetAttributeOfs($idAttrib, BitOR($attrib, 0xFFFFF000)), $d3, "float")
EndFunc   ;==>GetAttributeFloat


Func IsPowerReady($idAttrib, $idPower)
	Return _memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Power_Cooldown[0], BitShift($idPower, -12))), $d3, "int") <= 0
EndFunc   ;==>IsPowerReady

Func IsBuffActive($idAttrib, $idPower)
	Return _memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Buff_Active[0], BitShift($idPower, -12))), $d3, "int") == 1
EndFunc   ;==>IsBuffActive


Func _inventoryfull()

	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 2420, $d3, "ptr")
	$ptr3 = _memoryread($ptr2 + 0, $d3, "ptr")
	$ofs_uielements = _memoryread($ptr3 + 8, $d3, "ptr")
	$uielementpointer = _memoryread($ofs_uielements + 4 * 1185, $d3, "ptr")

	While $uielementpointer <> 0
		$npnt = _memoryread($uielementpointer + 528, $d3, "ptr")
		$name = BinaryToString(_memoryread($npnt + 56, $d3, "byte[256]"), 4)
		If StringInStr($name, "Root.TopLayer.error_notify.error_text") Then
			If _memoryread($npnt + 40, $d3, "int") = 1 Then
				$uitextptr = _memoryread($npnt + 0xAE0, $d3, "ptr")
				$uitext = BinaryToString(_memoryread($uitextptr, $d3, "byte[1024]"), 4)
;~                                 _log(@CRLF & $uitext)
				If StringInStr($uitext, 'nulle part') Or StringInStr($uitext, 'inventaire') Or StringInStr($uitext, 'no place') Or StringInStr($uitext, 'enough inventory') Then
					_log(@CRLF & $uitext, True)
					Return True
				EndIf

			Else
;~                                 _log($valuetocheckfor & " is invisible")
				Return False
			EndIf
		EndIf
		$uielementpointer = _memoryread($uielementpointer, $d3, "ptr")
	WEnd
;~         _log($valuetocheckfor & " not found")
	Return False
EndFunc   ;==>_inventoryfull

Func launch_spell($i)

	Dim $buff_table[11]
		Switch $i

	case 0
		$buff_table = $Skill1
	case 1
		$buff_table = $Skill2
	case 2
		$buff_table = $Skill3
	case 3
		$buff_table = $Skill4
	case 4
		$buff_table = $Skill5
	case 5
		$buff_table = $Skill6
	Endswitch

	If $buff_table[1] = False Then
		Switch $buff_table[6]
			Case "right"
				MouseClick("right")
			Case "left"
				MouseClick("left")
			Case Else
				Send($buff_table[6])
		EndSwitch
		Sleep(10)

   ElseIf $buff_table[1] and IsPowerReady($_MyGuid, $buff_table[9]) Then
		Switch $buff_table[6]
	 Case "right"
				MouseClick("right")
			Case "left"
				MouseClick("left")
			 Case Else

				Send($buff_table[6])

		EndSwitch
;~ 		Sleep(10)

	EndIf

EndFunc   ;==>launch_spell

Func GetResource($idAttrib, $resource)
   if $resource<>"" then
   Switch $resource
			Case "spirit"
				$source = 0x3000
				$MaximumSource = $MaximumSpirit
			Case "fury"
				$source = 0x2000
				$MaximumSource = $MaximumFury
			Case "arcane"
				$source = 0x1000
				$MaximumSource = $MaximumArcane
			Case "mana"
				$source = 0
				$MaximumSource = $MaximumMana
			Case "hatred"
				$source = 0x5000
				$MaximumSource = $MaximumHatred
			Case "discipline"
				$MaximumSource = $MaximumDiscipline
				$source = 0x6000
		EndSwitch
Return _memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Cur[0], $source)), $d3, "float")/$MaximumSource
else
   return 1
   endif
EndFunc ;==>GetResource

Func GestSpellcast($Distance, $action_spell, $elite, $Guid=0, $Offset=0)

	; $action_spell = 0 -> movetopos
	; $action_spell = 1 -> attack
	; $action_spell = 2 -> grab

	checkForPotion()

	PauseToSurviveHC() ; pause HCSecurity

	For $i = 0 To 5

		Dim $buff_table[11]

			Switch $i

	case 0
		$buff_table = $Skill1
	case 1
		$buff_table = $Skill2
	case 2
		$buff_table = $Skill3
	case 3
		$buff_table = $Skill4
	case 4
		$buff_table = $Skill5
	case 5
		$buff_table = $Skill6
	Endswitch



		Switch $buff_table[5]
			Case "spirit"
;~ 				$source = 0x3000
				$MaximumSource = $MaximumSpirit
			Case "fury"
;~ 				$source = 0x2000
				$MaximumSource = $MaximumFury
			Case "arcane"
;~ 				$source = 0x1000
				$MaximumSource = $MaximumArcane
			Case "mana"
;~ 				$source = 0
				$MaximumSource = $MaximumMana
			Case "hatred"
;~ 				$source = 0x5000
				$MaximumSource = $MaximumHatred
			Case "discipline"
				$MaximumSource = $MaximumDiscipline
;~ 				$source = 0x6000
			Case Else
				$MaximumSource = 15000
;~ 				$source = 5000
		EndSwitch

$source= GetResource( $_MyGuid, $buff_table[5])

		If $buff_table[0] And ($source > $buff_table[4] / $MaximumSource Or $buff_table[5] = "") And (TimerDiff($buff_table[10]) > $buff_table[2] or $buff_table[2]="") Then ;skill Activé

switch $action_spell

   case 0
    Switch $buff_table[3]
			case  0
				If GetLifep() <= $buff_table[7] / 100 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case  7
				If Not IsBuffActive($_MyGuid, $buff_table[9]) Then
;~ 					$timer_buff = TimerInit()
	  If $nameCharacter = "DemonHunter" Then
						 if IsBuffActive($_MyGuid,$DemonHunter_Chakram )=False then

							  Send("1")

 endif
 endif
 					launch_spell($i)

					$buff_table[10] = TimerInit()
				EndIf


			case 9
			   If GetLifep() <= $buff_table[7] / 100 Or ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				 EndIf

			case 10
				If ($Distance <= $buff_table[8] Or $buff_table[8] = "") or $action_spell <> 1 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 11
				If IsBuffActive($_MyGuid, $buff_table[9]) = False Or GetLifep() <= $buff_table[7] / 100 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 12
				If IsBuffActive($_MyGuid, $buff_table[9]) = False Or GetLifep() <= $buff_table[7] / 100 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf


			case 16
				If GetLifep() <= $buff_table[7] / 100 Or $elite > 0 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				 EndIf

			case 22
				launch_spell($i)
				$buff_table[10] = TimerInit()


			endswitch

		case 1


		 Switch $buff_table[3]
		 case  0
				If GetLifep() <= $buff_table[7] / 100 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				 EndIf

			case  1
				If $Distance <= $buff_table[8] Or $buff_table[8] = "" Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf


			case  2
				launch_spell($i)

			case  3
			  if $elite > 0  then
				launch_spell($i)
				$buff_table[10] = TimerInit()

				  endif

			case  4
				If Not IsBuffActive($_MyGuid, $buff_table[9]) And $action_spell = 1 Then

					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf


			case  5
;~ 			    local $IgnoreList=""
				;Not IsBuffActive($_MyGuid, $buff_table[9]) And
				if $buff_table[8]="" Then
				   $dist=20
				Else
				   $dist=$buff_table[8]
				EndIf

				If  $action_spell = 1  and IterateFilterZoneV2($dist) Then
				   _log("mauvais click droit")
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf


			case 6
;~ 			    local $IgnoreList=""
				if IsBuffActive($_MyGuid, $buff_table[9])=false then
				if $buff_table[8]="" Then
				   $dist=20
				Else
				   $dist=$buff_table[8]
				EndIf
				If  IterateFilterZoneV2($dist) Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf
			 endif


			case 8
				If GetLifep() <= $buff_table[7] / 100 And ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf
			case 11
				If IsBuffActive($_MyGuid, $buff_table[9]) = False Or GetLifep() <= $buff_table[7] / 100 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 13
				If IsBuffActive($_MyGuid, $buff_table[9]) = False And GetLifep() <= $buff_table[7] / 100 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 14
				If IsBuffActive($_MyGuid, $buff_table[9]) = False Or ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 15
				If IsBuffActive($_MyGuid, $buff_table[9]) = False And ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf


			case 17
				If GetLifep() <= $buff_table[7] / 100 And $elite > 0 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 18
				If ($Distance <= $buff_table[8] Or $buff_table[8] = "") Or $elite > 0 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 19
				If ($Distance <= $buff_table[8] Or $buff_table[8] = "") And $elite > 0 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 20
				If IsBuffActive($_MyGuid, $buff_table[9]) = False And $elite > 0 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf

			case 21
				If IsBuffActive($_MyGuid, $buff_table[9]) = False Or $elite > 0 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				 EndIf

			case 22
				launch_spell($i)
				$buff_table[10] = TimerInit()

;~ 			case 23
;~ 			   ;or ($buff_table[1] and IsPowerReady($_MyGuid, $buff_table[9]))
;~ If $buff_table[1] <> False  Then
;~   Switch $buff_table[6]
;~ 	  Case "right"
;~ 		  MouseDown("right")
;~ 	  Case "left"
;~ 		  MouseDown("left")
;~ 	  Case Else
;~ 	   Send("{" & $buff_table[6] & " down}")
;~    EndSwitch
;~ send("{shiftdown}")
;~  $check_source=GetResource( $_MyGuid, $buff_table[5])
;~     $vie=getlifep()
;~    if IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur) > 0 and $check_source>$buff_table[4]/$MaximumSource and $vie>$buff_table[7]/100 then
;~ 	  $cana=true
;~    Else
;~ 	  $cana=False
;~ 	  EndIf

;~ while $cana=true
;~    Dim $pos = UpdateObjectsPos($offset)
;~    $Coords = FromD3toScreenCoords($pos[0], $pos[1], $pos[2])
;~    MouseMove($Coords[0], $Coords[1], 3)
;~    sleep(10)
;~    $check_source=GetResource( $_MyGuid, $buff_table[5])
;~    $vie=getlifep()
;~    if IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur) > 0 and $check_source>$buff_table[4]/$MaximumSource and $vie>$buff_table[7]/100 then
;~ 	  $cana=true
;~    Else
;~ 	  $cana=False
;~    EndIf
;~
;~    	For $ii = 0 To 5

;~ 		Dim $buff_table2[11]

;~ 			Switch $ii

;~ 	case 0
;~ 		$buff_table2 = $Skill1
;~ 	case 1
;~ 		$buff_table2 = $Skill2
;~ 	case 2
;~ 		$buff_table2 = $Skill3
;~ 	case 3
;~ 		$buff_table2 = $Skill4
;~ 	case 4
;~ 		$buff_table2 = $Skill5
;~ 	case 5
;~ 		$buff_table2 = $Skill6
;~ 	Endswitch
;~ 	If $buff_table2[3]=4 and IsBuffActive($_MyGuid, $buff_table2[9])=false  Then
;~ 	   $cana=false
;~ 	   endif
;~  Next
;~
;~    if _playerdead() Then
;~ 	  send("{shiftup}")
;~ 	   Switch $buff_table[6]
;~ 	  Case "right"
;~ 		  mouseup("right")
;~ 	  Case "left"
;~ 		  mouseup("left")
;~ 	  Case Else
;~ 		 Send("{" & $buff_table[6] & " up}")
;~    endswitch
;~    exitloop
;~ endif
;~ WEnd
;~  send("{shiftup}")
;~    Switch $buff_table[6]
;~ 	  Case "right"
;~ 		  mouseup("right")
;~ 	  Case "left"
;~ 		  mouseup("left")
;~ 	  Case Else
;~ 		 Send("{" & $buff_table[6] & " up}")
;~    endswitch
;~

;~ 				$buff_table[10] = TimerInit()

			Endswitch

		 case 2
			 Switch $buff_table[3]
case  0
				If GetLifep() <= $buff_table[7] / 100 Then
					launch_spell($i)
					$buff_table[10] = TimerInit()
				EndIf
			case 22
				launch_spell($i)
				$buff_table[10] = TimerInit()

			case  7
				If Not IsBuffActive($_MyGuid, $buff_table[9]) Then
					$timer_buff = TimerInit()
						 if IsBuffActive($_MyGuid,$DemonHunter_Chakram )=False then

   If $nameCharacter = "DemonHunter" Then Send("1")

 endif
 					launch_spell($i)

;~ 					Send("{" & $buff_table[6] & " down}")
;~ 					While Not IsBuffActive($_MyGuid, $buff_table[9])
;~ 						If TimerDiff($timer_buff) > 350 Then ExitLoop
;~ 						Sleep(50)
;~ 					WEnd
;~ 					Send("{" & $buff_table[6] & " up}")
					$buff_table[10] = TimerInit()
				EndIf

EndSwitch
endswitch


		EndIf

		If $i = 0 Then
			$Skill1 = $buff_table
		ElseIf $i = 1 Then
			$Skill2 = $buff_table
		ElseIf $i = 2 Then
			$Skill3 = $buff_table
		ElseIf $i = 3 Then
			$Skill4 = $buff_table
		ElseIf $i = 4 Then
			$Skill5 = $buff_table
		ElseIf $i = 5 Then
			$Skill6 = $buff_table
		EndIf

	Next

EndFunc   ;==>GestSpellcast

Func GestSpellInit()

		For $i = 0 To 5

			Dim $buff_table[11]
			Dim $buff_conf_table[6]

			If $i = 0 Then
				$buff_conf_table = $Skill_conf1
				$buff_table = $Skill1
			ElseIf $i = 1 Then
				$buff_conf_table = $Skill_conf2
				$buff_table = $Skill2
			ElseIf $i = 2 Then
				$buff_conf_table = $Skill_conf3
				$buff_table = $Skill3
			ElseIf $i = 3 Then
				$buff_conf_table = $Skill_conf4
				$buff_table = $Skill4
			ElseIf $i = 4 Then
				$buff_conf_table = $Skill_conf5
				$buff_table = $Skill5
			ElseIf $i = 5 Then
				$buff_conf_table = $Skill_conf6
				$buff_table = $Skill6
			EndIf


			If Not $buff_conf_table[0] Or $buff_conf_table[0] = "false" Then
				$buff_table[0] = False
			Else
				$buff_table[0] = True
			EndIf

			If $buff_table[0] Then ;Si skill actived

				if NOT trim($buff_conf_table[1]) = "" Then ;Delay
					$buff_table[2] = $buff_conf_table[1]
				EndIf

				if NOT trim($buff_conf_table[2]) = "" Then ;Type
					$buff_table[3] = $buff_conf_table[2]
				EndIf

				if NOT trim($buff_conf_table[3]) = "" Then ;EnergyNeeds
					$buff_table[4] = $buff_conf_table[3]
				EndIf

				if NOT trim($buff_conf_table[4]) = "" Then ;Trigger Life
					$buff_table[7] = $buff_conf_table[4]
				EndIf

				if NOT trim($buff_conf_table[5]) = "" Then ;Trigger Distance
					$buff_table[8] = $buff_conf_table[5]
				EndIf

			EndIF

   Select

		case $buff_table[3] = "life"
				$type=0

			case $buff_table[3] = "attack"
				$type=1


			case $buff_table[3] = "physical"
				$type=2

			case $buff_table[3] = "elite"
				$type=3



			case $buff_table[3] = "buff"
				$type=4


			case $buff_table[3] = "zone"
			   $type=5


			case StringInStr($buff_table[3], "zone") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "buff")
			   $type=6

			case $buff_table[3] = "move"
				$type=7

			case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "attack")
				$type=8

			case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "attack")
				$type=9

			case StringInStr($buff_table[3], "move") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "attack")
				$type=10

			case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "buff")
				$type=11

			case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "move")
				$type=12

			case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "buff")
				$type=13

			case StringInStr($buff_table[3], "attack") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "buff")
				$type=14

			case StringInStr($buff_table[3], "attack") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "buff")
				$type=15

			case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "elite")
				$type=16

			case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "elite")
				$type=17

			case StringInStr($buff_table[3], "attack") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "elite")
				$type=18

			case StringInStr($buff_table[3], "attack") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "elite")
				$type=19

			case StringInStr($buff_table[3], "elite") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "buff")
				$type=20

			case StringInStr($buff_table[3], "elite") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "buff")
				$type=21

			case $buff_table[3]="buff_permanent"
				$type=22

			case $buff_table[3]="canalisation"
				$type=23
			Endselect

		$buff_table[3]=$type

			If $i = 0 Then
				$Skill1 = $buff_table
			ElseIf $i = 1 Then
				$Skill2 = $buff_table
			ElseIf $i = 2 Then
				$Skill3 = $buff_table
			ElseIf $i = 3 Then
				$Skill4 = $buff_table
			ElseIf $i = 4 Then
				$Skill5 = $buff_table
			ElseIf $i = 5 Then
				$Skill6 = $buff_table
			EndIf
		Next

EndFunc   ;==>GestSpellInit

;;================================================================================
; Function:                     GetPlayerOffset
; Note(s):
;==================================================================================
Func GetPlayerOffset()
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x9a4, $d3, "ptr")      ;0x96c
	$index = _memoryread($ptr2 + 0x0, $d3, "int")

	$ptr1bis = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2bis = _memoryread($ptr1 + 0x88c, $d3, "ptr")    ;0x874
	$id = _memoryread($ptr2bis + 0x5c + $index * 0xD138, $d3, "int")

	Return GetActorFromId($id)
EndFunc   ;==>GetPlayerOffset


;;================================================================================
; Function:                     GetActorFromId
; Note(s):
;==================================================================================
Func GetActorFromId($id)

	#cs
		$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
		$ptr2 = _memoryread($ptr1 + 0x920, $d3, "int")
		$sid = BitAND($id, 0xFFFF)

		$bitshift = _memoryread($ptr2 + 0x164, $d3, "int") ;0x18c
		$group1 = 4 * BitShift($sid, $bitshift)
		$group2 = BitShift(1, -$bitshift) - 1
		$group3 = _memoryread(_memoryread($ptr2 + 0x120, $d3, "int"), $d3, "int") ;Ofs de la liste des actors
		$group4 = 0x44c * BitAND($sid, $group2) ;0x42c

		Return $group3 + $group1 + $group4
	#ce

	Local $index, $offset, $count, $item[10]
	startIterateObjectsList($index, $offset, $count)
	While iterateObjectsList($index, $offset, $count, $item)
			;_log("Ofs : " & $item[8]  & " - "  & $item[1] & " - Data 1 : " & $item[5] & " - Data 2 : " & $item[6] & " - Guid : " & $item[0])
			if $item[0] = $id then
				Return $item[8]
			EndIf
	WEnd

EndFunc   ;==>GetActorFromId

Func GoToTown()

		_log("start loop _onloginscreen() = False And _intown() = False And _playerdead() = False")

	Local $nbTriesTownPortal = 0
	While (_intown() = False And _inmenu() = False)
		$nbTriesTownPortal += 1

		If $nbTriesTownPortal < 3 Then
			if NOT _TownPortalnew(10) Then
				$nbTriesTownPortal = 3
			EndIf
		Else
			_leaveGame()
			$nbTriesTownPortal = 0
			Sleep(10000)
			While _inmenu() = False
				Sleep(10)
			WEnd
			ExitLoop
		EndIf

		If _checkdisconnect() Then
			_log("Disconnected dc1")
			$disconnectcount += 1
			Sleep(1000)
			ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022);pacht 8.2e
			sleep(50)
			ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022);pacht 8.2e
			Sleep(1000)
			While Not (_onloginscreen() Or _inmenu())
				Sleep(Random(80000, 15000))
			WEnd
			ExitLoop
		EndIf
	WEnd

	RandSleep()
EndFunc   ;==>GoToTown

Func NeedRepair()
	TpRepairAndBack()
EndFunc   ;==>NeedRepair

Func TpRepairAndBack()

    If Not $PartieSolo Then WriteMe($WRITE_ME_INVENTORY_FULL) ; TChat

	While Not _intown()
		if Not _TownPortalnew() Then
			$GameFailed=1
			Return False
		EndIf

	WEnd

	StashAndRepair()

	If $PortBack Then

		If Not $PartieSolo Then WriteMe($WRITE_ME_BACK_REPAIR) ; TChat
		SafePortBack()

		While Not offsetlist()
			Sleep(10)
		WEnd
	EndIf

	$games = 0
	$PortBack = False

EndFunc

Func ClickOnStashTab($num)
	if $num > 4 OR $num < 2 Then
		_log("ERROR Impossible to open this tab from stash")
		return false
	Endif

	if $num = 2 Then
		ClickUI("Root.NormalLayer.stash_dialog_mainPage.tab_2", 218)
	elseif $num = 3 Then
		ClickUI("Root.NormalLayer.stash_dialog_mainPage.tab_3", 344)
	elseif $num = 4 Then
		ClickUI("Root.NormalLayer.stash_dialog_mainPage.tab_4", 1054)
	EndIf
EndFunc

Func StashAndRepair()

	_log("Func StashAndRepair")
	
	Local $Repair = 0
	$Execute_StashAndRepair = True
	$FailOpen_BookOfCain = 0
	$SkippedMove = 0
	
	$RepairORsell += 1
	$item_to_stash = 0

	If Not $PartieSolo Then WriteMe($WRITE_ME_SALE) ; TChat

	While _checkInventoryopen() = False
		Send($KeyInventory)
		Sleep(Random(200, 300))
	WEnd

	While Not offsetlist()
		Sleep(10)
	WEnd

	Sleep(Random(500, 1000))

	_log('Filter Backpack')
	$items = FilterBackpack()
	$ToStash = _ArrayFindAll($items, "Stash", 0, 0, 0, 1, 2)

	If $FailOpen_BookOfCain Then
 		$GameFailed = 1
 		Return False
 	EndIf

	If $ToStash <> -1 Then
		Send($KeyCloseWindows)
		Sleep(500)
		InteractByActorName('Player_Shared_Stash')
		Sleep(700)
		
		Local $stashtry = 0
		While _checkStashopen() = False
			If $stashtry <= 4 Then
				_log('Fail to open Stash')
				$stashtry += 1
				InteractByActorName("Player_Shared_Stash")
				Sleep(Random(100, 200))

			Else
				Send("{PRINTSCREEN}")
				Sleep(200)
				Log('Failed to open Stash after 4 try')
				WinSetOnTop("Diablo III", "", 0)
				MsgBox(0, "Impossible d'ouvrir le stash :", "SVP, veuillez reporter ce problème sur le forum. Erreur : s001 ")
				Terminate()

			EndIf
		WEnd
		$tabfull = 0
		CheckWindowD3Size()

		For $i = 0 To UBound($ToStash) - 1
			_log($items[$ToStash[$i]][0] & " stash : " & $items[$ToStash[$i]][1])

			Sleep(Random(100, 200))
			InventoryMove($items[$ToStash[$i]][0], $items[$ToStash[$i]][1])
			Sleep(Random(100, 500))

			MouseClick('Right')
			Sleep(Random(50, 200))
			If Detect_UI_error(1) Then
				_log('Tab is full : Switching tab')
				CheckWindowD3Size()
				$i = $i - 1
				If $tabfull = 0 Then
					ClickOnStashTab(2)
					$tabfull = 1
				ElseIf $tabfull = 1 Then
					ClickOnStashTab(3)
					$tabfull = 2
				ElseIf $tabfull = 2 Then
					ClickOnStashTab(4)
					$tabfull = 3
				ElseIf $tabfull = 3 Then
					_log('Stash is full : Botting stopped')
					Terminate()
				EndIf
				Sleep(5000)
			Else
				$ItemToStash += 1
			EndIf
		Next


		Sleep(Random(50, 100))
		Send($KeyCloseWindows)
		Sleep(Random(100, 150))

		;****************************************************************
		If NOT Verif_Attrib_GlobalStuff() Then
			_log("CHANGEMENT DE STUFF ON TOURNE EN ROND (Stash and Repair - Stash)!!!!!")
			antiidle()
		EndIf
		;****************************************************************

	EndIf

	Sleep(Random(100, 200))
	Send($KeyCloseWindows)
	Sleep(Random(100, 200))
	Sleep(Random(500, 1000))

    ;recyclage
	$ToRecycle = _ArrayFindAll($items, "Recycle", 0, 0, 0, 1, 2)
	If $ToRecycle <> -1 Then ; si item a recyclé

	   MoveTo($Smith)

	   InteractByActorName("PT_Blacksmith_RepairShortcut")
	   Sleep(700)

	   Local $BlacksmithTry = 0
	   While _checkSalvageopen() = False
		  If $BlacksmithTry <= 4 Then
			 _log('Fail to open Salvage')
			 $BlacksmithTry += 1

			 InteractByActorName("PT_Blacksmith_RepairShortcut")
			 Sleep(500)
		  EndIf

		  If $BlacksmithTry > 4 Then
			 Send("{PRINTSCREEN}")
			 Sleep(200)
			 _log('Failed to open Salvage after 4 try')
			 WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
			 MsgBox(0, "Impossible d'ouvrir le Forgeron :", "SVP, veuillez reporter ce problème sur le forum. Erreur : v001 ")
			 Terminate()
			 ExitLoop
		  EndIf
	   WEnd

	   $ToTrash = _ArrayFindAll($items, "Trash", 0, 0, 0, 1, 2)
	   If $ToTrash = -1 Then ; si pas items a aller vendre on répare au forgeron
		  Local $GoldBeforeRepaire = GetGold();on mesure l'or avant la reparation

		  ClickUI("Root.NormalLayer.vendor_dialog_mainPage.tab_3")
		  Sleep(100)
		  ClickUI("Root.NormalLayer.vendor_dialog_mainPage.repair_dialog.RepairEquipped")
		  Sleep(100)
		  $Repair = 1

		  Local $GoldAfterRepaire = GetGold();on mesure l'or apres
		  $GoldByRepaire += $GoldBeforeRepaire - $GoldAfterRepaire;on compte le cout de la reparation
	   EndIf


	   ClickUI("Root.NormalLayer.vendor_dialog_mainPage.tab_2")
	   Sleep(100)
	   ClickUI("Root.NormalLayer.vendor_dialog_mainPage.salvage_dialog.salvage_button")

	   CheckWindowD3Size()

	   For $i = 0 To UBound($ToRecycle) - 1
		  InventoryMove($items[$ToRecycle[$i]][0], $items[$ToRecycle[$i]][1])
		  Sleep(Random(100, 500))
		  $ItemToRecycle += 1
		  MouseClick('left')
		  Sleep(Random(100, 200))
	   Next

	   Sleep(Random(100, 200))
	   Send($KeyCloseWindows)
	   Sleep(Random(100, 200))

	   ;***************************************************************
	   If NOT Verif_Attrib_GlobalStuff() Then
		  _log("CHANGEMENT DE STUFF ON TOURNE EN ROND (Stash and Repair - Forgeron)!!!!!")
		  antiidle()
	   EndIf
	   ;****************************************************************

	   Sleep(Random(100, 200))
	   Send($KeyCloseWindows)
	   Sleep(Random(100, 200))
	   Sleep(Random(500, 1000))

	   If $ToTrash <> -1 Then  ;si item a vendre
		  MoveTo($Smith)
	   EndIf

    EndIf ; fin recyclage

	Local $GoldBeforeRepaire = GetGold();on mesure l'or avant la reparation et achats de potion
	BuyPotion()

    If Not $Repair Then
	   Repair()
    EndIf

	Local $GoldAfterRepaire = GetGold();on mesure l'or apres
	$GoldByRepaire += $GoldBeforeRepaire - $GoldAfterRepaire;on compte le cout de la reparation et potion

	;Trash
    $ToTrash = _ArrayFindAll($items, "Trash", 0, 0, 0, 1, 2)

    If not @error Then

	   Local $GoldBeforeSell = GetGold();on mesure l'or avant la vente d'objets

	   ClickUI("Root.NormalLayer.shop_dialog_mainPage.tab_0")

	   CheckWindowD3Size()

	   For $i = 0 To UBound($ToTrash) - 1
		  InventoryMove($items[$ToTrash[$i]][0], $items[$ToTrash[$i]][1])
		  Sleep(Random(100, 500))
		  $ItemToSell = $ItemToSell + 1
		  MouseClick('Right')
		  Sleep(Random(100, 200))
	   Next

	   Sleep(Random(100, 200))
	   Send($KeyCloseWindows)
	   Sleep(Random(100, 200))

	   Local $GoldAfterSell = GetGold(); on mesure l'or apres
	   $GoldBySale += $GoldAfterSell - $GoldBeforeSell;on compte l'or par vent

	   ;****************************************************************
	   If NOT Verif_Attrib_GlobalStuff() Then
		  _log("CHANGEMENT DE STUFF ON TOURNE EN ROND (Stash and Repair - vendeur)!!!!!")
		  antiidle()
	   EndIf
	   ;****************************************************************
    EndIf

    Sleep(Random(100, 200))
    Send($KeyCloseWindows)
    Sleep(Random(100, 200))

	$Execute_StashAndRepair = False

EndFunc   ;==>StashAndRepair

;;--------------------------------------------------------------------------------
;;	Gets levels from Gamebalance file, returns a list with snoid and lvl
;;--------------------------------------------------------------------------------
Func GetLevelsAdvanced($offset)

	$snoItems = 0
	$SizeStruct = 0x740

	If $offset <> 0 Then
		$ofs = $offset + 0x28 ;0x218
		$read = _MemoryRead($ofs, $d3, 'int')

		;While $read = 0
		;	$ofs += 0x4
		;	$read = _MemoryRead($ofs, $d3, 'int')
		;WEnd

		$size = _MemoryRead($ofs + 0x4, $d3, 'int')
		$size -= $SizeStruct ;0x5F8
		$ofs = $offset + _MemoryRead($ofs, $d3, 'int')
		$nr = $size / $SizeStruct ;0x5F8

		Local $snoItems[1][4]

		if $nr > 0 Then
			Local $snoItems[$nr + 1][4]
			$j = 0
			For $i = 0 To $size Step $SizeStruct
				$ofs_address = $ofs + $i

				$snoItems[$j][0] = _MemoryRead($ofs_address + 0x100, $d3, 'ptr')
				$snoItems[$j][3] = _MemoryRead($ofs_address, $d3, 'char[256]')
				$snoItems[$j][2] = Abs(_MemoryRead($ofs_address + 0x110, $d3, 'int')) ;item_type_hash
				$snoItems[$j][1] = _MemoryRead($ofs_address + 0x118, $d3, 'int') ;lvl //0x11c
				$j += 1
			Next
		EndIf

	EndIf

	Return $snoItems

EndFunc   ;==>GetLevelsAdvanced

;;--------------------------------------------------------------------------------
;;  LoadingSNOExtended
;;--------------------------------------------------------------------------------
Func LoadingSNOExtended()
	_log("LoadingSNO")

	$list = IndexSNO($gameBalance)

	$armorOffs = 0
	$weaponOffs = 0
	$otherOffs = 0

	For $j = 0 To UBound($list) - 1

		If ($list[$j][1] = 19750) Then
			$armorOffs = $list[$j][0]
		EndIf
		If ($list[$j][1] = 19754) Then
			$weaponOffs = $list[$j][0]
		EndIf
		If ($list[$j][1] = 19753) Then
			$otherOffs = $list[$j][0]
		EndIf

		If ($list[$j][1] = 170627) Then
			$legarmorOffs = $list[$j][0]
		EndIf
		If ($list[$j][1] = 19752) Then
			$legweaponOffs = $list[$j][0]
		EndIf
		If ($list[$j][1] = 1189) Then
			$legotherOffs = $list[$j][0]
		EndIf
	Next

	Global $armorItems = GetLevelsAdvanced($armorOffs)
	Global $weaponItems = GetLevelsAdvanced($weaponOffs)
	Global $otherItems = GetLevelsAdvanced($otherOffs)
	Global $legarmorItems = GetLevelsAdvanced($legarmorOffs)
	Global $legweaponItems = GetLevelsAdvanced($legweaponOffs)
	Global $legotherItems = GetLevelsAdvanced($legotherOffs)

	Global $allSNOitems = $armorItems
	__ArrayConcatenate($allSNOitems, $weaponItems)
	__ArrayConcatenate($allSNOitems, $otherItems)
	__ArrayConcatenate($allSNOitems, $legarmorItems)
	__ArrayConcatenate($allSNOitems, $legweaponOffs)
	__ArrayConcatenate($allSNOitems, $legotherOffs)

	_log("GB SNO loaded")

	Return True
EndFunc   ;==>LoadingSNOExtended


Func give_str_from_filter($str)
	Local $result = ""
	$str = StringReplace($str, "and", " ", 0, 2)
	$str = StringReplace($str, "or", " ", 0, 2)

	While StringRegExp($str, '(?i)([a-z]+)') = 1
		$list = StringRegExp($str, '(?i)([a-z]+)', 2)
		If $result = "" Then
			$result = $list[1]
		Else
			$result = $result & "|" & $list[1]
		EndIf
		$str = StringReplace($str, $list[1], " ", 0, 2)
		;msgbox(1, "", $str)
	WEnd

	Return $result
EndFunc   ;==>give_str_from_filter

Func SafePortStart()
	$Curentarea = GetLevelAreaId()
	;fix offset list
	While $Curentarea = -1
		While Not offsetlist()
			Sleep(10)
		WEnd
		$Curentarea = GetLevelAreaId()

	WEnd
	_log('cur area :' & $Curentarea)

	$tptry = 0
	$tpcheck = 0

	While $tpcheck = 0 And $tptry <= 1
		_log("try n°" & $tptry + 1 & " hearthPortal")
		InteractByActorName('hearthPortal')
		$Newarea = GetLevelAreaId()

		Local $areatry = 0

		While $Newarea = $Curentarea And $areatry <= 10
			$Newarea = GetLevelAreaId()
			Sleep(500)
			$areatry = $areatry + 1
		WEnd

		If $Newarea <> $Curentarea Then
			$tpcheck = 1
		Else
			$tptry += 1
		EndIf

	WEnd

	If $Newarea <> $Curentarea Then
		_log('succesfully teleported back : ' & $Curentarea & ":" & $Newarea)
		While Not offsetlist()
			Sleep(10)
		WEnd
	Else
		$GameFailed = 1
	EndIf

EndFunc   ;==>SafePortStart

Func SafePortBack()
	$Curentarea = GetLevelAreaId()
	_log('cur area :' & $Curentarea)
	;Go to center according to act
	Switch $Act
		Case 1 ; act 1
			MoveToPos(2922.02783203125, 2791.189453125, 24.0453262329102, 0, 25)
			MoveToPos(2945.61547851563, 2800.7109375, 24.0453319549561, 0, 25)
			MoveToPos(2973.68774414063, 2800.90869140625, 24.0453262329102, 0, 25)

		Case 2 ; act 2
			;mtp a definir


		Case 3 ; act 3
			MoveToPos(427.152893066406, 345.048858642578, 0.10000141710043, 0, 25)
			MoveToPos(400.490386962891, 380.362884521484, 0.332595944404602, 0, 25)
			MoveToPos(390.630401611328, 399.380554199219, 0.55376011133194, 0, 25)

		Case 4 ; act 4
			MoveToPos(427.152893066406, 345.048858642578, 0.10000141710043, 0, 25)
			MoveToPos(400.490386962891, 380.362884521484, 0.332595944404602, 0, 25)
			MoveToPos(390.630401611328, 399.380554199219, 0.55376011133194, 0, 25)

	EndSwitch

	Local $HearthPortalTry = 0
	Local $NewAreaOk = 0

	While $NewAreaOk = 0 And $HearthPortalTry <= 2 ; on tente 3 fois de prendre le portal
		_Log("try n°" & $HearthPortalTry + 1 & " hearthPortal")
		InteractByActorName('hearthPortal')
		$Newarea = GetLevelAreaId()

		Local $areatry = 0
		While $Newarea = $Curentarea And $areatry <= 10
			$Newarea = GetLevelAreaId()
			Sleep(500)
			$areatry += 1
		WEnd

		If $Newarea <> $Curentarea Then
			$NewAreaOk = 1
		Else
			$HearthPortalTry += 1
		EndIf
	WEnd

	If $Newarea <> $Curentarea Then
		_log('succesfully teleported back : ' & $Curentarea & ":" & $Newarea)
		Local $hTimer = TimerInit()
		While Not offsetlist() And TimerDiff($hTimer) < 30000 ; 30secondes
			Sleep(10)
		WEnd

		If TimerDiff($hTimer) >= 30000 Then
			_Log('Fail to use OffsetList - SafePortBack')
		EndIf
	Else
		_log('We failed to teleport back')
		$GameFailed = 1
	EndIf
EndFunc   ;==>SafePortBack

Func fastcheckuiitemvisiblesize($valuetocheckfor, $visibility, $bucket)
        Global $itemsize[4]
        $ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
        $ptr2 = _memoryread($ptr1 + 2420, $d3, "ptr")
        $ptr3 = _memoryread($ptr2 + 0, $d3, "ptr")
        $ofs_uielements = _memoryread($ptr3 + 8, $d3, "ptr")
        $uielementpointer = _memoryread($ofs_uielements + 4 * $bucket, $d3, "ptr")
        While $uielementpointer <> 0
                $npnt = _memoryread($uielementpointer + 528, $d3, "ptr")
                $name = BinaryToString(_memoryread($npnt + 56, $d3, "byte[256]"), 4)
                If StringInStr($name, $valuetocheckfor) Then
                        If _memoryread($npnt + 40, $d3, "int") = $visibility Then


                                $x = _memoryread($npnt + 0x508, $d3, "float") ;left
                                $y = _memoryread($npnt + 0x50C, $d3, "float") ;top
                                $r = _memoryread($npnt + 0x510, $d3, "float") ;right
                                $B = _memoryread($npnt + 0x514, $d3, "float") ;bot
                                _log(" x :" & $x & " y :" & $y & " R :" & $r & " B:" & $B)


                                Dim $itemsize[4] = [$x, $y, $r, $B]



                                Return $itemsize
                        Else
                                _log("The UI element we are looking for is invisible")
                                Return False
                        EndIf
                EndIf
                $uielementpointer = _memoryread($uielementpointer, $d3, "ptr")
        WEnd
        Return False
EndFunc   ;==>fastcheckuiitemvisiblesize


Func _checkbackpacksize() ;ok pour v 2.0

        $count_fastcheckuiitemvisiblesize = 0
        $sizecheck = 0
        While $count_fastcheckuiitemvisiblesize <= 100 And $sizecheck = 0
         $NameUI ="Root.NormalLayer.inventory_dialog_mainPage.inventory_button_backpack"
		Dim $Point = GetPositionUI(GetOfsUI($NameUI, 1))
                if $Point[0] <> 0 Then
                $sizecheck = 1
                Endif
        WEnd

        If $Point[0] = 1026 And $Point[1] = 622 And $Point[2] = 1586 And $Point[3] = 954 Then
                _log("UI Size check OK : " & $Point[0] & ":" & $Point[1] & ":" & $Point[2] & ":" & $Point[3])
                Return True
        Else

                If $Point[0] = False Then
                _log("UI Size check failed for unknow reason : " & $Point[0] & ":" & $Point[1] & ":" & $Point[2] & ":" & $Point[3])
                else
                _log("UI Size check failed cuz windows is wrong size : " & $Point[0] & ":" & $Point[1] & ":" & $Point[2] & ":" & $Point[3])
                Endif
                antiidle()
        EndIf

EndFunc   ;==>_checkbackpacksize

Func Auto_spell_init()
	If StringLower(Trim($nameCharacter)) = "monk" Then
		Dim $tab_skill_temp = $Monk_skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = False
			$Gestion_affixe = False
			_log("Monk detected, Gest Affix disabled")
		EndIf
	ElseIf StringLower(Trim($nameCharacter)) = "barbarian" Then
		Dim $tab_skill_temp = $Barbarian_Skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = False
			$Gestion_affixe = False
			_log("Barbarian detected, Gest Affix disabled")
		EndIf
	ElseIf StringLower(Trim($nameCharacter)) = "witchdoctor" Then
		Dim $tab_skill_temp = $WitchDoctor_Skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = True
			$Gestion_affixe = True
			_log("WitchDoctor detected, Gest Affix Enabled")
		EndIf
	ElseIf StringLower(Trim($nameCharacter)) = "demonhunter" Then
		Dim $tab_skill_temp = $DemonHunter_skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = True
			$Gestion_affixe = True
			_log("DemonHunter detected, Gest Affix Enabled")
		EndIf
	ElseIf StringLower(Trim($nameCharacter)) = "wizard" Then
		Dim $tab_skill_temp = $Wizard_skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = True
			$Gestion_affixe = True
			_log("Wizard detected, Gest Affix Enabled")
		EndIf
	Else
		_log("PAS DE CLASS DETECT")
	EndIf

	for $i=-1 to 4
		For $y=0 to Ubound($tab_skill_temp) - 1

			if GetActivePlayerSkill($i) = $tab_skill_temp[$y][0] Then
				If $i= -1 Then
					$Skill1 = assoc_skill($y, "left", $tab_skill_temp)
					_log("Skill Associed Left Click -> " & $Skill1[1])
				Elseif $i=0 Then
					$skill2 = assoc_skill($y, "right", $tab_skill_temp)
					_log("Skill Associed Right Click -> " & $Skill2[1])
				ElseIf $i=1 Then
					$skill3 = assoc_skill($y, $Key1, $tab_skill_temp)
					_log("Skill Associed '" & $Key1 & "' Key -> " & $Skill3[1])
				ElseIf $i=2 Then
					$skill4 = assoc_skill($y, $Key2, $tab_skill_temp)
					_log("Skill Associed '" & $Key2 & "' Key -> " & $Skill4[1])
				ElseIf $i=3 Then
					$skill5 = assoc_skill($y, $Key3, $tab_skill_temp)
					_log("Skill Associed '" & $Key3 & "' Key -> " & $Skill5[1])
				ElseIf $i=4 Then
					$skill6 = assoc_skill($y, $Key4, $tab_skill_temp)
					_log("Skill Associed '" & $Key4 & "' Key -> " & $Skill6[1])
				EndIf
				Exitloop
			EndIF

		Next
	Next
EndFunc

Func assoc_skill($y, $key, $tab_skill_temp)
	Dim $tab[11]
	$tab[0] = True
	$tab[1] = $tab_skill_temp[$y][1]
	$tab[2] = $tab_skill_temp[$y][2]
	$tab[3] = $tab_skill_temp[$y][3]
	$tab[4] = $tab_skill_temp[$y][4]
	$tab[5] = $tab_skill_temp[$y][5]
	$tab[6] = $key
	$tab[7] = $tab_skill_temp[$y][6]
	$tab[8] = $tab_skill_temp[$y][7]
	$tab[9] = $tab_skill_temp[$y][0]
	$tab[10] = ""
	return $tab
EndFunc



Func Detect_UI_error($mode=0)

        ;$mode=0 -> Detection inventory full
        ;$mode=1 -> Detection Stash full
        ;$mode=2 -> Detection Deny Boss tp
        ;$mode=3 -> Detection No item IDentify

        $bucket = 731
        $valuetocheckfor = "Root.TopLayer.error_notify.error_text"
        $Visibility = 1



		if $mode = 0 Then
			if CheckTextvalueUI($bucket, $valuetocheckfor, $Byte_Full_Inventory[0]) Then
				_log("ERROR DETECT -> INVENTORY FULL")
				return true
			Else
				return false
			EndIf
		ElseIf $mode = 1 Then
			if CheckTextvalueUI($bucket, $valuetocheckfor, $Byte_Full_Stash[0]) Then
				_log("ERROR DETECT -> STACH FULL")
				return true
			Else
				return false
			EndIf
		ElseIf $mode = 2 Then
			if CheckTextvalueUI($bucket, $valuetocheckfor, $Byte_Boss_TpDeny[0]) Then
				_log("ERROR DETECT -> CAN'T TP IN BOSS ROOM")
				return true
			Else
				return false
			EndIf
		ElseIf $mode = 3 Then
			_log("$Byte_NoItem_Identify[0] : " & $Byte_NoItem_Identify[0])
			if CheckTextvalueUI($bucket, $valuetocheckfor, $Byte_NoItem_Identify[0]) Then
				_log("ERROR DETECT -> NO ITEM IDENTIFY")
				return true
			Else
				return false
			EndIf
		EndIf

	_log("ERROR DETECT -> NO ERROR DETECT")

EndFunc


Func Detect_Str_full_inventory()

	_log("Please Wait, initialising UI language detection")

	$pattern_Full_Inventory = "\x50\x69\x63\x6B\x75\x70\x5F\x4E\x6F\x53\x75\x69\x74\x61\x62\x6C\x65\x53\x6C\x6F\x74" ;Pickup_NoSuitableSlot
	$Mask_Full_Inventory = "xxxxxxxxxxxxxxxxxxxxx"

	$pattern_Not_Enough_Room = "49\x41\x52\x5F\x4E\x6F\x74\x45\x6E\x6F\x75\x67\x68\x52\x6F\x6F\x6D" ;IAR_NotEnoughRoom
	$Mask_Not_Enough_Room = "xxxxxxxxxxxxxxxxx"

	$pattern_Power_Unusable_During_Boss_Encounter = "\x50\x6F\x77\x65\x72\x55\x6E\x75\x73\x61\x62\x6C\x65\x44\x75\x72\x69\x6E\x67\x42\x6F\x73\x73\x45\x6E\x63\x6F\x75\x6E\x74\x65\x72" ;PowerUnusableDuringBossEncounter
	$Mask_Power_Unusable_During_Boss_Encounter = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	$pattern_Identify_All_Item = "\x49\x64\x65\x6E\x74\x69\x66\x79\x41\x6C\x6C\x4E\x6F\x49\x74\x65\x6D\x73" ;IdentifyAllNoItems
	$Mask_Identify_All_Item = "xxxxxxxxxxxxxxxxxx"

	$ofs_Full_Inventory = _MemoryScanEx($d3, $pattern_Full_Inventory, $Mask_Full_Inventory, true, 0x02000000, 0x2fffffff)

	$ofs_decal_min = $ofs_Full_Inventory - 0x2710
	$ofs_decal_max = $ofs_Full_Inventory + 0x2710

	$ofs_Not_Enough_Room = _MemoryScanEx($d3, $pattern_Not_Enough_Room, $Mask_Not_Enough_Room, true, $ofs_decal_min, $ofs_decal_max)
	$ofs_Power_Unusable_During_Boss_Encouter = _MemoryScanEx($d3, $pattern_Power_Unusable_During_Boss_Encounter, $Mask_Power_Unusable_During_Boss_Encounter, true, $ofs_decal_min, $ofs_decal_max)
	$ofs_Identify_All_Item = _MemoryScanEx($d3, $pattern_Identify_All_Item, $Mask_Identify_All_Item, true, $ofs_decal_min, $ofs_decal_max)


	while(_memoryread($ofs_Full_Inventory, $d3, "byte") = 0)
		$ofs_Full_Inventory += 0x1
	WEnd

	while(_memoryread($ofs_Not_Enough_Room, $d3, "byte") = 0)
		$ofs_Not_Enough_Room += 0x1
	WEnd

	while(_memoryread($ofs_Power_Unusable_During_Boss_Encouter, $d3, "byte") = 0)
		$ofs_Power_Unusable_During_Boss_Encouter += 0x1
	WEnd

	while(_memoryread($ofs_Identify_All_Item, $d3, "byte") = 0)
		$ofs_Identify_All_Item += 0x1
	WEnd

	$BuffStr = _MemoryRead($ofs_Full_Inventory, $d3, "char[255]")
	$Byte_Full_Inventory[0] = BinaryToString($BuffStr, 4)
	$Byte_Full_Inventory[1] = stringLen($BuffStr)

	$BuffStr = _MemoryRead($ofs_Not_Enough_Room, $d3, "char[255]")
	$Byte_Full_Stash[0] = BinaryToString($BuffStr, 4)
	$Byte_Full_Stash[1] = stringLen($BuffStr)

	$BuffStr = _MemoryRead($ofs_Power_Unusable_During_Boss_Encouter, $d3, "char[255]")
	$Byte_Boss_TpDeny[0] = BinaryToString($BuffStr, 4)
	$Byte_Boss_TpDeny[1] = stringLen($BuffStr)

	$BuffStr = _MemoryRead($ofs_Identify_All_Item, $d3, "char[255]")
	$Byte_NoItem_Identify[0] = BinaryToString($BuffStr,4)
	$Byte_NoItem_Identify[1] = stringLen($BuffStr)


	_log($ofs_Full_Inventory & " -> " & $Byte_Full_Inventory[0])
	_log($ofs_Not_Enough_Room & " -> " & $Byte_Full_Stash[0])
	_log($ofs_Power_Unusable_During_Boss_Encouter & " -> " & $Byte_Boss_TpDeny[0])
	_log($ofs_Identify_All_Item & " -> " & $Byte_NoItem_Identify[0])

EndFunc

Func _MemoryScanEx($ah_Handle, $pattern, $mask , $after = False, $iv_addrStart = 0x00400000, $iv_addrEnd = 0x00FFFFFF, $step = 51200)
    If Not IsArray($ah_Handle) Then
        SetError(1)
        Return -1
    EndIf
    $pattern = StringRegExpReplace($pattern, "[^0123456789ABCDEFabcdef.]", "")
    If StringLen($pattern) = 0 Then
        SetError(2)
        Return -2
    EndIf
    If Stringlen($pattern)/2 <> Stringlen($mask) Then
        SetError(4)
        Return -4
    EndIf
    Local $formatedpattern=""
    Local $BufferPattern
    Local $BufferMask
    for $i = 0 to stringlen($mask)-1
        $BufferPattern = StringLeft($pattern,2)
        $pattern = StringRight($pattern,StringLen($pattern)-2)
        $BufferMask = StringLeft($mask,1)
        $mask = StringRight($mask,StringLen($mask)-1)
        if $BufferMask = "?" then $BufferPattern = ".."
        $formatedpattern = $formatedpattern&$BufferPattern
    Next
    $pattern = $formatedpattern
    For $addr = $iv_addrStart To $iv_addrEnd Step $step - (StringLen($pattern) / 2)
        StringRegExp(_MemoryRead($addr, $ah_Handle, "byte[" & $step & "]"), $pattern, 1, 2)
        If Not @error Then
            If $after Then
                Return StringFormat("0x%.8X", $addr + ((@extended - 2) / 2))
            Else
                Return StringFormat("0x%.8X", $addr + ((@extended - StringLen($pattern) - 2) / 2))
            EndIf
        EndIf
    Next
    Return -3
EndFunc   ;==>_MemoryScanEx


Func GetLocalPlayer()
	;Global $ObjManStorage = 0x7CC ;0x794
	$v0 = _MemoryRead(_MemoryRead($ofs_objectmanager, $d3, 'int') + 0x9a4, $d3, 'int') ;0x94C/934
	$v1 = _MemoryRead(_MemoryRead($ofs_objectmanager, $d3, 'int') + 0x88c, $d3, 'int')

	if $v0 <> 0 AND _MemoryRead($v0, $d3, 'int') <> -1 AND $v1 <> 0 Then
		return 0xD0D0 * _MemoryRead($v0, $d3, 'int') + $v1 + 0x58
	Else
		return 0
	EndIf
EndFunc

Func GetActivePlayerSkill($index)
	$Local_player = GetLocalPlayer()
	If $local_player <> 0 Then
		return _MemoryRead($local_player + (0xBC + $index * 0x10), $d3, 'int')
	Else
		return 0
	EndIf
EndFunc

Func GoToTown_Portal()


EndFunc

Func CheckZoneBeforeTP()

	local $try = 0

	Dim $Item_Affix_Verify = IterateFilterAffixV2()
	If IsArray($Item_Affix_Verify) Then
	   _Log("Affix detecter, on verifie si l'on est trop pres avant de TP")

	   Local $CurrentLoc = getcurrentpos()
	   while Not is_zone_safe($CurrentLoc[0], $CurrentLoc[1], $CurrentLoc[2], $Item_Affix_Verify) and $try < 15 ; try < 15 si jamais on bloque dans la map
		  $CurrentLoc = getcurrentpos()
		  Dim $pos = UpdateObjectsPos($Item_Affix_Verify)
		  maffmove($CurrentLoc[0], $CurrentLoc[1], $CurrentLoc[2], $pos[0], $pos[1])
		  Sleep(50)
		  $try += 1
	   WEnd
    Else
	   _Log("La zone est sure, on peut TP")
    EndIf

EndFunc ; ==> CheckZoneBeforeTP()

Func _TownPortalnew($mode=0)

    If Not $PartieSolo Then WriteMe($WRITE_ME_TP) ; TChat

	Local $compt = 0

	While Not _intown() And _ingame() And Not _playerdead() ; "playerdead" quand on meurt, je les vue souvent vouloir tp

		Local $try = 0
		Local $TPtimer = 0
		Local $compt_while = 0
		Local $Attacktimer = 0

		$compt += 1

		_Log("Tour de boucle IsInTown Mode : " & $mode & " -- tentative de TP " & $compt)

		If $mode <> 0 And $compt > $mode Then
			_Log("Too Much TP try !!!")
			ExitLoop
		EndIf

		_Log("enclenche attack")
		$grabskip = 1
		Attack()
		$grabskip = 0

		Sleep(100)

		If _playerdead() = False Then

			CheckZoneBeforeTP();toujours en test pour les affix

			_Log("on enclenche le TP")
			Sleep(250)
			Send($KeyPortal)
			Sleep(250)

			If $Choix_Act_Run < 100 And Detect_UI_error(2) AND NOT _intown() Then
				_Log('Detection Asmo room')
				Return False
			EndIf

			$Current_area = GetLevelAreaId()

			If Detect_UI_error(0) = False And $GameFailed = 0 Then
				_Log("enclenchement fastCheckui de la barre de loading")

			    While fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068)
				    If $compt_while = 0 Then
					   _Log("enclenchement du timer")
					   $TPtimer = TimerInit()
					EndIf
					$compt_while += 1

					checkforpotion()

					$Attacktimer = TimerInit()
					Attack()
					Sleep(100)
					TimerDiff($Attacktimer)

					If _playerdead() = True Or $GameFailed = 1 Then
						ExitLoop
					EndIf
			    WEnd
			Else ; si INVENTORY FULL ou GameFailed
				_Log("enclenchement fastCheckui de la barre de loading, INVENTORY FULL Or GAMEFAILED")

				While fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068)
					If $compt_while = 0 Then
					  _Log("enclenchement du timer")
					  $TPtimer = Timerinit()
				    EndIF
				    $compt_while += 1

				    $Attacktimer = TimerInit()
				    Sleep(100)
				    TimerDiff($Attacktimer)
				WEnd
			EndIf

			If $compt_while = 0 Then ; si pas de detection de la barre de TP
			    $CurrentLoc = getcurrentpos()
				MoveToPos($CurrentLoc[0] + 5, $CurrentLoc[1] + 5, $CurrentLoc[2], 0, 6)
				_Log("On se deplace, pas de detection de la barre de TP")
			Else
			    _Log("compare time to tp -> " & (TimerDiff($TPtimer) - TimerDiff($Attacktimer)) & "> 3700 ") ; valeur test de 3600 a 4000
			EndIf

			If (TimerDiff($TPtimer) - TimerDiff($Attacktimer)) > 3700 And $compt_while > 0 Then
				While Not _intown() And $try < 6
					 _Log("on a peut etre reussi a tp, on reste inerte pendant 6sec voir si on arrive en ville, tentative -> " & $try)
					 $try += 1
					 Sleep(1000)
				WEnd
			EndIf

			Sleep(500)


			If $Current_area <> GetLevelAreaId() Then
				_Log("Changement d'arreat, on quite la boucle")
				ExitLoop
			EndIf

		Else
			_Log("Vous etes morts lors d'une tentative de teleporte !!!")
			Return False
		EndIf

		Sleep(100)
	WEnd

	Local $hTimer = TimerInit()
	While Not offsetlist() And TimerDiff($hTimer) < 30000 ; 30secondes
		Sleep(40)
	WEnd

	If TimerDiff($hTimer) >= 30000 Then
		_Log('Fail to use offselList - TownPortalnew')
		Return False
	EndIf

	_Log("On a renvoyer true, quite bien la fonction")

	$PortBack = True
	Return True
EndFunc   ;==>_TownPortalnew


Func GetMaxResource($idAttrib, $classe)

   Switch $classe
   Case "monk"
    $source = 0x3000
    $MaximumSpirit=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
    _log("Ressource Maximum : " & $MaximumSpirit)
   Case "barbarian"
    $source = 0x2000
    $MaximumFury=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
    _log("Ressource Maximum : " & $MaximumFury)
   Case "wizard"
    $source = 0x1000
    $MaximumArcane=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
    _log("Ressource Maximum : " & $MaximumArcane)
   Case "witchdoctor"
    $source = 0
    $MaximumMana=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
    _log("Ressource Maximum : " & $MaximumMana)
   Case "demonhunter"
    $source = 0x5000
    $MaximumHatred=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
       $source = 0x6000
    $MaximumDiscipline=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
      _log("Ressource Maximum : " & $MaximumHatred)
      _log("Ressource Maximum : " & $MaximumDiscipline)

  EndSwitch

EndFunc ;==>GetMaxResource



func reset_timer_ignore()
   if timerdiff($timer_ignore_reset)>120000 Then

 redim  $ignore_affix[1][2]
 $timer_ignore_reset=timerinit()
EndIf
endfunc

func check_ignore_affix($_x_verif,$_y_verif)
   for $a=0 to ubound($ignore_affix)-1
	  if $_x_verif=$ignore_affix[$a][0] and $_y_verif=$ignore_affix[$a][1] Then
		 return False
		 $a=ubound($ignore_affix)-1
	  Else
		 return True
	  EndIf
   Next

EndFunc



func is_zone_safe($x_perso,$y_perso,$z_test,$item_safe)
   $condition_affixe=0
          for $aa=0 to ubound($item_safe)-1

                 $distance_centre_affixe=sqrt(($item_safe[$aa][2]-$x_perso)^2 + ($item_safe[$aa][3]-$y_perso)^2)
                 if $distance_centre_affixe<$item_safe[$aa][13] then
					$condition_affixe=$condition_affixe+1
;~ 					$aa=ubound($item_safe)-1
				 EndIf

          next

          if $condition_affixe=0 Then

                 return true
          Else
                 return false
          EndIf

EndFunc

func zone_safe($x_perso,$y_perso,$item_verif,$z_test,$x_mob,$y_mob)
      dim $safe_array[1][3]
          $bb=-1
		  if $x_mob-$x_perso>0 then
			 $ord=1
		  else
			 $ord=-1
		  EndIf

		  if $y_mob-$y_perso>0 then
			 $abs=1
		  else
			 $abs=-1
		  EndIf

   for $b=0 to ubound($tab_aff2)-1
		$x_test=$x_perso+$ord*$tab_aff2[$b][0]
		$y_test=$y_perso+$abs*$tab_aff2[$b][1]
		if is_zone_safe($x_test,$y_test,$z_test,$item_verif)  and check_ignore_affix($x_test,$y_test) Then
			ReDim $safe_array[$bb+2][3]
			$bb=$bb+1
			$distance_safe=getdistance($x_test,$y_test,0)
			$safe_array[$bb][1]=$x_test
			$safe_array[$bb][2]=$y_test
			$safe_array[$bb][0]=$distance_safe
;~ 			$safe_array[$bb+1][1]=$x_test
;~ 			$safe_array[$bb+1][2]=$y_test
;~ 			$safe_array[$bb+1][0]=$distance_safe
;~ 		   $b= ubound($tab_aff2)-1
		EndIf

	    $x_test=$x_perso-$ord*$tab_aff2[$b][0]
		$y_test=$y_perso-$abs*$tab_aff2[$b][1]
		if is_zone_safe($x_test,$y_test,$z_test,$item_verif)  and check_ignore_affix($x_test,$y_test) Then
			ReDim $safe_array[$bb+2][3]
			$bb=$bb+1
			$distance_safe=getdistance($x_test,$y_test,0)
			$safe_array[$bb][1]=$x_test
			$safe_array[$bb][2]=$y_test
			$safe_array[$bb][0]=$distance_safe
;~ 			$safe_array[$bb+1][1]=$x_test
;~ 			$safe_array[$bb+1][2]=$y_test
;~ 			$safe_array[$bb+1][0]=$distance_safe
;~ 		   $b= ubound($tab_aff2)-1
		EndIf

	    $x_test=$x_perso+$ord*$tab_aff2[$b][0]
		$y_test=$y_perso-$abs*$tab_aff2[$b][1]
		if is_zone_safe($x_test,$y_test,$z_test,$item_verif)  and check_ignore_affix($x_test,$y_test) Then
			ReDim $safe_array[$bb+2][3]
			$bb=$bb+1
			$distance_safe=getdistance($x_test,$y_test,0)
			$safe_array[$bb][1]=$x_test
			$safe_array[$bb][2]=$y_test
			$safe_array[$bb][0]=$distance_safe
;~ 			$safe_array[$bb+1][1]=$x_test
;~ 			$safe_array[$bb+1][2]=$y_test
;~ 			$safe_array[$bb+1][0]=$distance_safe
;~ 		   $b= ubound($tab_aff2)-1
		EndIf

	    $x_test=$x_perso-$ord*$tab_aff2[$b][0]
		$y_test=$y_perso+$abs*$tab_aff2[$b][1]
		if is_zone_safe($x_test,$y_test,$z_test,$item_verif)  and check_ignore_affix($x_test,$y_test) Then
			ReDim $safe_array[$bb+2][3]
			$bb=$bb+1
			$distance_safe=getdistance($x_test,$y_test,0)
			$safe_array[$bb][1]=$x_test
			$safe_array[$bb][2]=$y_test
			$safe_array[$bb][0]=$distance_safe
;~ 			$safe_array[$bb+1][1]=$x_test
;~ 			$safe_array[$bb+1][2]=$y_test
;~ 			$safe_array[$bb+1][0]=$distance_safe
;~ 		   $b= ubound($tab_aff2)-1
		EndIf
   Next
   if $safe_array[0][0]<>0 then
          _ArraySort($safe_array)
          dim $move_aff[2]
          $move_aff[0]=$safe_array[0][1]
          $move_aff[1]=$safe_array[0][2]

   Else
          $move_aff[0]=$x_test
          $move_aff[1]=$y_test

   EndIf
return $move_aff

EndFunc

Func maffmove($_x_aff,$_y_aff,$_z_aff,$x_mob,$y_mob)
   reset_timer_ignore()
   if timerdiff($maff_timer)>500 then
        Dim $item_maff_move = IterateFilterAffixV2()
        If IsArray($item_maff_move) Then
           $a=0
			while $a<=ubound($item_maff_move)-1
			   checkforpotion()
			   mouseup('left')
;~ 			   $dist_aff=sqrt(($_x_aff-$item_maff_move[$a][2])*($_x_aff-$item_maff_move[$a][2]) + ($_y_aff-$item_maff_move[$a][3])*($_y_aff-$item_maff_move[$a][3]) + ($_z_aff-$item_maff_move[$a][4])*($_z_aff-$item_maff_move[$a][4]))
			   if $item_maff_move[$a][9]<$item_maff_move[$a][13] and _playerdead()=false then
				  dim $move_coords[2]
				  $move_coords=zone_safe($_x_aff,$_y_aff,$item_maff_move,$_z_aff,$x_mob,$y_mob)
				  $Coords_affixe = FromD3toScreenCoords($move_coords[0],$move_coords[1],$_z_aff)
				  Mousemove($Coords_affixe[0], $Coords_affixe[1], 3)
				  GestSpellcast(0, 0, 0)
				  MouseClick($MouseMoveClick)
				  $ignore_timer=timerinit()
				  while _MemoryRead($ClickToMoveToggle,$d3,"float")<>0
;~ 					 GestSpellcast(0, 2, 0)
					 if timerdiff($ignore_timer)>10000 then exitloop
					 sleep(10)

				  wend
				  if timerdiff($ignore_timer)<30 Then
					 $nbr_ignore=ubound($ignore_affix)
					 redim $ignore_affix[$nbr_ignore+1][2]
					 $ignore_affix[$nbr_ignore][0]=$move_coords[0]
					 $ignore_affix[$nbr_ignore][1]=$move_coords[1]
				  endif

				  $maff_timer=timerinit()
				  exitloop

			   endif
			   $a +=1
			wend
		 endif

   endif
EndFunc  ;maffmove

$BanAffixList="poison_humanoid|"&$BanAffixList

 Func Is_Affix($item,$pv=0)
	if $item[9]<50 then
                 if ((StringInStr($item[1],"bomb_buildup") and $pv<=$Life_explo/100 ) or _
					(StringInStr($item[1],"Corpulent_") and $pv<=$Life_explo/100 ) or _
					(StringInStr($item[1],"demonmine_C") and $pv<=$Life_mine/100)  or _
					(StringInStr($item[1],"creepMobArm") and $pv<=$Life_arm/100 )  or _
					(StringInStr($item[1],"woodWraith_explosion") and $pv<=$Life_spore/100)  or _
				    (StringInStr($item[1],"WoodWraith_sporeCloud_emitter") and $pv<=$Life_spore/100 )  or _
				    (StringInStr($item[1],"sandwasp_projectile") and $pv<=$Life_proj/100 )  or _
					(StringInStr($item[1],"succubus_bloodStar_projectile") and $pv<=$Life_proj/100 )  or _
					(StringInStr($item[1],"Crater_DemonClawBomb") and $pv<=$Life_mine/100 )  or _
					(stringinstr($item[1],"Molten_deathExplosion") and $pv<=$Life_explo/100 ) or _
					(stringinstr($item[1],"Molten_deathStart") and $pv<=$Life_explo/100 )   or _
					(StringInStr($item[1],"icecluster") and $pv<=$Life_ice/100 )   or _
					(StringInStr($item[1],"Orbiter_Projectile") and $pv<=$Life_ice/100 )   or _
					(StringInStr($item[1],"Thunderstorm") and $pv<=$Life_ice/100 )   or _
					(StringInStr($item[1],"CorpseBomber_projectile") and $pv<=$Life_proj/100 )   or _
					(StringInStr($item[1],"CorpseBomber_bomb_start") and $pv<=$Life_explo/100 )   or _
					(StringInStr($item[1],"Battlefield_demonic_forge") and $pv<=$Life_ice/100 )   or _
                    (StringInStr($item[1],"frozenPulse") and $pv<=$Life_ice/100 )   or _
					(StringInStr($item[1],"spore") and $pv<=$Life_spore/100 )  or _
					(StringInStr($item[1],"ArcaneEnchanted_petsweep") and $pv<=$Life_arcane/100 ) or _
					(StringInStr($item[1],"desecrator") and $pv<=$Life_profa/100 ) or _
					(StringInStr($item[1],"Plagued_endCloud") and $pv<=$Life_peste/100 )  or _
					(StringInStr($item[1],"poison") and $pv<=$Life_poison/100 ) or _
					(StringInStr($item[1],"molten_trail") and $pv<=$Life_lave/100 )) _
					and checkfromlist($BanAffixList, $item[1]) = 0 then
                Return True
        Else
                Return False
		 EndIf
   EndIf

 EndFunc   ;==>Is_Affix


 Func Take_BookOfCain()

	Send($KeyCloseWindows)
	sleep(200)
	Send($KeyCloseWindows)
	sleep(50)

	Switch $Act
			Case 1
				MoveToPos(2955.8681640625, 2803.51489257813, 24.0453319549561,0,20)
			Case 2
				;do nothing act 2
			Case 3 To 4
				MoveToPos(395.930847167969, 390.577362060547, 0.408410131931305,0,20)
	EndSwitch


        InteractByActorName("All_Book_Of_Cain")

        While NOT fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068) AND NOT Detect_UI_error(3)
                ;_log("Ui : " & fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1512) & " Error : " &  fastcheckuiitemvisible("Root.TopLayer.error_notify.error_text", 1, 1185))
                _log("tour boucle")
                If NOT fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068) Then
				   If Not _checkdisconnect() Then
					  InteractByActorName("All_Book_Of_Cain")
				   Else
				      _Log("Failed to open Book Of Cain")
					  $FailOpen_BookOfCain = 1
					  Return False
				   EndIf
                EndIf
        WEnd
        While fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068)
                sleep(50)
        Wend
	EndFunc

Func IsTeleport()
	if _memoryRead( _memoryRead($_Myoffset + 0x1a4, $d3, "ptr") + 0x18, $d3, "int") = 31 Then
		return true
	EndIf

	return false
EndFunc

Func MoveTo($BeforeInteract) ; placer notre perso au point voulu dans chaque act avant d'interagir
    GetAct()

	If _checkInventoryopen() = True Then
		Send($KeyInventory)
		Sleep(150)
	EndIf

	Switch $BeforeInteract

		 Case 1 ; Smith
			Switch $Act
			   Case 1
					 MoveToPos(2965.33325195313, 2822.7978515625, 24.0453224182129,1,25)
			   Case 2
					 ;do nothing act 2
			   Case 3 To 4
					 ;do nothing act 3 and 4
			EndSwitch
		 Case 2 ; Potion_Vendor
			Switch $Act
				  Case 1
						MoveToPos(3007.27221679688, 2820.4560546875, 24.0453319549561,1,25)
				  Case 2 to 4
						;do nothing act 2, 3 and 4
			EndSwitch

	EndSwitch

	Sleep(100)
EndFunc   ;==>MoveTo

Func getGold()
    Local $index, $offset, $count, $item[4]

    Sleep(500)
	startIterateLocalActor($index, $offset, $count)
    While iterateLocalActorList($index, $offset, $count, $item)
	   If StringInStr($item[1], "GoldCoin-") Then
		  Return IterateActorAtribs($item[0], $Atrib_ItemStackQuantityLo)
		  ExitLoop
	   EndIf
    WEnd

EndFunc	;==>getGold

Func BuyPotion()

	Local $potinstock = Number(GetTextUI(221,'Root.NormalLayer.game_dialog_backgroundScreenPC.game_potion.text')) ; récupéré les potions en stock
	Local $ClickPotion = Round($NbPotionBuy / 5) ; nombre de clic

	If $NbPotionBuy > 0 Then ; NbPotionBuy = 0 on déactive la fonction
	   If $potinstock <= ($PotionStock + 10) Then

		  MoveTo($Potion_Vendor) ; on se positionne

		  InteractByActorName($PotionVendor)
		  Sleep(700)

		  Local $vendortry = 0
		  While _checkVendoropen() = False ; si la fenêtre n'y est pas
			   If $vendortry <= 4 Then ; on essaye 5 fois
				  _Log('Fail to open vendor')
				  $vendortry += 1
				  InteractByActorName($PotionVendor)
			   Else
				  _Log('Failed to open Vendor after 4 try')
				  MoveTo($Potion_Vendor) ; on se repositionne
				  $GameFailed = 1
				  Return False  ; si pas fenêtre on sort de la fonction
			   EndIf
		  WEnd

		  _Log('Achat de ' & $NbPotionBuy & ' potions')

		  ClickUI("Root.NormalLayer.shop_dialog_mainPage.tab_2") ; potion tap
		  Sleep(200)
		  ClickUI("Root.NormalLayer.shop_dialog_mainPage.shop_item_region.item 0 0"); potion Button
		  Sleep(200)
		  ClickUI("Root.NormalLayer.shop_dialog_mainPage.shop_item_region.item 0 0"); potion Button
		  Sleep(200)
		  Send("{SHIFTDOWN}") ; pour acheter en paquet 5
		  Sleep(100)

		  Local $Click = 0
		  While $Click <> $ClickPotion ; tant qu'on n'a pas atteint le nombre de clic
			   MouseClick('right')
			   Sleep(Random(150, 200))
			   $Click += 1
		  WEnd

		  Sleep(200)
		  Send("{SHIFTUP}")
		  Sleep(100)
		  Send($KeyCloseWindows); ferme l'inventaire
		  Sleep(500)

		  MoveTo($Potion_Vendor) ; on se repositionne
	   Else
		  _Log('Vous avez asser potion')
	   EndIf
    Else
	   _Log('Fonction BuyPotion déactivée')
    EndIf

EndFunc    ;==>BuyPotion

Func PauseToSurviveHC() ; fonction qui permet de mettre le jeu en Pause lorsque la vie de votre personnage descend en dessous d'un seuil fixé

	If $HCSecurity And GetLifep() <= $MinHCLife/100 Then
		Send("{ESCAPE}")
		While 1
			Send("{ESCAPE}")
			Sleep(100 + random(0, 50))
			Send("{ESCAPE}")
			Sleep(600000 + Random(-60000, 60000))
		Wend
	EndIf

EndFunc    ;==>PauseToSurviveHC

Func BanActor($actor)
	$TableBannedActors[0] += 1
	ReDim $TableBannedActors[$TableBannedActors[0] + 1]
	$TableBannedActors[$TableBannedActors[0]] = $actor
EndFunc

Func IsBannedActor($actor)
	For $i = 1 To $TableBannedActors[0]
		If $TableBannedActors[$i] = $actor Then
			return True
		EndIf
	Next
	Return False
EndFunc

Func LoadTableFromString(ByRef $Table, ByRef $string) 
	$Table = StringSplit($string, "|")
EndFunc

Func IsItemInTable(ByRef $table, ByRef $itemName)
	For $i = 1 To $table[0]
		If StringInStr($itemName, $table[$i]) Then
			return True
		EndIf
	Next
	Return False
EndFunc

Func IsItemStartInTable(ByRef $table, ByRef $itemName)
	For $i = 1 To $table[0]
		If StringRegExp($itemName, "(?i)^" & $table[$i]) = 1 Then
			Return True
		EndIf
	Next
	Return False
EndFunc
