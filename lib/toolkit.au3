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
#include "NomadMemory.au3"  ;THIS IS EXTERNAL, GET IT AT THE AUTOIT WEBSITE

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

	If $SizeWindows = 0 Then
		$SizeWindows = WinGetClientSize("[CLASS:D3 Main Window Class]")
		_log("Size Windows X : " & $SizeWindows[0] & " - Y : " & $SizeWindows[1], $LOG_LEVEL_DEBUG)
		$AspectChange = ($SizeWindows[0] / $SizeWindows[1]) / (800 / 600)
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

	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)
	_log("FindActor : " & $name & " in " & $count & " item(s)", $LOG_LEVEL_DEBUG)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], $name) And $item[9] < $maxRange Then
			Return True
		EndIf
	WEnd

	Return False
EndFunc   ;==>FindActor

Func ClickUI($name, $bucket = -1, $click = 1)
	If $bucket = -1 Then ;no bucket given slow method
		$result = GetOfsUI($name, 1)
	Else ;bucket given, fast method
		$result = GetOfsFastUI($name, $bucket)
	EndIf

	If $result = False Then
		_log("(ClickUI) UI DOESNT EXIT ! -> " & $name & " (" & $bucket  & ")", $LOG_LEVEL_ERROR)
		return false
	EndIf

	Dim $Point = GetPositionUI($result)

	While $Point[0] = 0 And $Point[1] = 0
		$Point = GetPositionUI($result)
		sleep(250)
	WEnd

	Dim $Point2 = GetUIRectangle($Point[0], $Point[1], $Point[2], $Point[3])

	If ($Point2[2] < 0) Then 
		$Point2[2] = 0
	EndIf
	If ($Point2[3] < 0) Then 
		$Point2[3] = 0
	EndIf

	If $click = 0 Then
		MouseMove($Point2[0] + $Point2[2] / 2, $Point2[1] + $Point2[3] / 2)
	Else
		MouseClick("left", $Point2[0] + $Point2[2] / 2, $Point2[1] + $Point2[3] / 2)
	EndIf
EndFunc

Func GetPositionUI($ofs)
	Dim $point[4]
	$point[0] = _MemoryRead($ofs + 0x4D8, $d3, "float")
	$point[1] = _MemoryRead($ofs + 0x4DC, $d3, "float")
	$point[2] = _MemoryRead($ofs + 0x4E0, $d3, "float")
	$point[3] = _MemoryRead($ofs + 0x4E4, $d3, "float")

	;_log("GetPositionUI (" & $ofs & ") x : " & $point[0] & " - y : " & $point[1] & " - r : " & $point[2] & " - b : " & $point[3])
	Return $point
EndFunc

Func GetUIRectangle($x, $y, $r, $b)
	;$size = WinGetClientSize("[CLASS:D3 Main Window Class]")

	$mb = ($SizeWindows[0] - (($SizeWindows[1] / 3.0) * 4.0)) * (600.0 / $SizeWindows[1])
	$sx = ($x + $mb) / (1200.0 / $SizeWindows[1])
	$sr = ($r + $mb) / (1200.0 / $SizeWindows[1])
	$sy = $y * ($SizeWindows[1] / 1200.0)
	$sb = ($b-1) * ($SizeWindows[1] / 1200.0)

	;_log("GetUIRectangle -> sx : " & $sx & " - sy : " & $sy & " - right : " & $sr - $sx & " - bottom : " & $sb - $sy)

	Dim $Point[4] = [$sx, $sy, $sr - $sx, $sb - $sy]
	Return $Point
EndFunc

Func fastcheckuiitemvisible($valuetocheckfor, $visibility, $bucket)
	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")
	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")
	$UiPtr = _memoryread($BuckitOfs + ($bucket * 0x4), $d3, "ptr")

	While $UiPtr <> 0
		$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
		$Visible = BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)
		If $Visibility = 1 And $Visible = 4 Then
			$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
			If StringInStr($name, $valuetocheckfor) Then
				Return True
			EndIf
		ElseIf $Visibility = 0 Then
			$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
			If StringInStr($name, $valuetocheckfor) Then
				Return True
			EndIf
		EndIf

		$UiPtr = _memoryread($UiPtr, $d3, "ptr")
	WEnd
	Return false
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
	_log("fastcheckuiitemactived : " & $valuetocheckfor & " : " & $Enabled)
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

	For $g = 0 To $UiCount - 1
		$UiPtr = _memoryread($BuckitOfs, $d3, "ptr")
		while $UiPtr <> 0
			$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
			$Visible = BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)
			If $Visible = 4 Or $IsVisible = 0 Then
				$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
				If StringInStr($Name, $valuetocheckfor) Then
					Return $nPtr
				Endif
			EndIf
			$UiPtr = _memoryread($UiPtr, $d3, "ptr")
		WEnd
		$BuckitOfs = $BuckitOfs + 0x4
	Next

	Return False
EndFunc

Func CheckTextvalueUI($bucket, $valuetocheckfor, $textcheck)
	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")
	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")

	$UiPtr = _memoryread($BuckitOfs + ($bucket * 0x4), $d3, "ptr")
	While $UiPtr <> 0

		$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
		$Visible = BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)
		If $Visible = 4 Then
			$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
			_log("CheckTextvalueUI : " & $valuetocheckfor & " | Name : " & StringLeft($Name, StringLen($valuetocheckfor))  & " ", $LOG_LEVEL_DEBUG)
			If StringInStr($name, $valuetocheckfor) Then
				$text = BinaryToString(_memoryread(_memoryread($nPtr + $Ofs_UI_Text, $d3, "ptr"),$d3, "byte[1024]"), 4)
				_log("Textcheck : " & $textcheck  & " | Text : " &  StringLeft($text, StringLen($textcheck))  & " ", $LOG_LEVEL_DEBUG)
				If StringInStr($text, $textcheck) Then
					Return true
				Else
					Return false
				EndIF
			Endif
		EndIf
		$UiPtr = _memoryread($UiPtr, $d3, "ptr")
	WEnd
	Return false
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
	;Return fastcheckuiitemvisible("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.PlayGameButton", 1, 1929)
	If GameState() = 5 Then
		Return True
	Else
		Return False
	EndIf
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
	;Return fastcheckuiitemvisible("Root.NormalLayer.minimap_dialog_backgroundScreen.minimap_dialog_pve", 1, 1403)
	If GameState() = 1 Then
		Return True
	Else
		Return False
	EndIf
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
EndFunc ;==>_checkBannerOpen OK

Func _checkParagonOpen()
	Return fastcheckuiitemvisible("Root.NormalLayer.Paragon_main.LayoutRoot", 1, 377)
EndFunc ;==>_checkParagonOpen OK

Func _checkInventoryopen()
	Return fastcheckuiitemvisible("Root.NormalLayer.inventory_dialog_mainPage", 1, 1813)
EndFunc   ;==>_checkInventoryopen OK

Func _checkBountyRewardOpen() 
	Return fastcheckuiitemvisible("Root.NormalLayer.BountyReward_main.LayoutRoot", 1, 1969) 
EndFunc ;==>_checkBountyRewardOpen OK

Func _checkQuestRewardOpen() 
	Return fastcheckuiitemvisible("Root.NormalLayer.questreward_dialog", 1, 1612) 
EndFunc ;==>_checkQuestRewardOpen OK

Func GetLevelAreaId()
	Return _MemoryRead(_MemoryRead($OfsLevelAreaId, $d3, "int") + 0x44, $d3, "int")
EndFunc   ;==>GetLevelAreaId

;;--------------------------------------------------------------------------------
;;     Find which Act we are in
;;--------------------------------------------------------------------------------
Func GetAct()

	$arealist = FileRead("lib\area.txt")
	Local $area = GetLevelAreaId()

	_log("We are in map : " & $area, $LOG_LEVEL_VERBOSE)
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
		ElseIf StringInStr($MyArea, "a5") Then
			$Act = 5
		EndIf

		;set our vendor according to the act we are in as we know it.
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
				Global $RepairVendor = "UniqueVendor_Collector_InTown" ; act 4
				Global $PotionVendor = "UniqueVendor_Collector_InTown"
			Case 5
				Global $RepairVendor = "X1_A5_UniqueVendor_InnKeeper" ; act 5
				Global $PotionVendor = "X1_A5_UniqueVendor_InnKeeper"
		EndSwitch
		_log("Our Current Act is : " & $Act & " ---> So our vendor is : " & $RepairVendor, $LOG_LEVEL_DEBUG)

	EndIf
EndFunc   ;==>GetAct

;;--------------------------------------------------------------------------------
; Function:			TownStateCheck()
; Description:		Check if we are in town or not by comparing distance from stash
;
;;--------------------------------------------------------------------------------
Func _intown()
	$town = findActor('Player_Shared_Stash', 448)
	If $town Then
		_log("_inTown : We are in town ", $LOG_LEVEL_VERBOSE)
		Return True
	Else
		_log("_inTown : We are NOT in town ", $LOG_LEVEL_VERBOSE)
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
	$ptr2 = _memoryread($ptr1 + 0x8a8, $d3, "ptr") ; 2.0.3 : 0x8b8
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
	Return $__ACDACTOR

EndFunc   ;==>IterateBackpack

Func Iteratestuff()
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8a8, $d3, "ptr") ; 2.0.3 : 0x8b8 ;8a0
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
	_log("Starting Load_Attrib_GlobalStuff", $LOG_LEVEL_DEBUG)
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

	$Check_ArmorTotal = GetAttributeSelf($Atrib_Armor_Item_Total)

	_log("$Check_HandLeft_Seed -> " & $Check_HandLeft_Seed, $LOG_LEVEL_DEBUG)
	_log("$Check_HandRight_Seed -> " & $Check_HandRight_Seed, $LOG_LEVEL_DEBUG)
	_log("$Check_RingLeft_Seed -> " & $Check_RingLeft_Seed, $LOG_LEVEL_DEBUG)
	_log("$Check_RingRight_Seed -> " & $Check_RingRight_Seed, $LOG_LEVEL_DEBUG)
	_log("$Check_Amulet_Seed -> " & $Check_Amulet_Seed, $LOG_LEVEL_DEBUG)
	_log("$Check_ArmorTotal -> " & $Check_ArmorTotal, $LOG_LEVEL_DEBUG)
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
		$ArmorTotal = GetAttributeSelf($Atrib_Armor_Item_Total)

		if $HandLeft_Seed <> $Check_HandLeft_Seed Then
			If $HandLeft_Seed = 0 AND $Check_HandLeft_Seed <> 0 Then
				_log("-> Weapon Left Dropped", $LOG_LEVEL_WARNING)
			Else
				_log("-> Weapon Left switched", $LOG_LEVEL_WARNING)
			EndIf
			return False
		ElseIf $HandRight_Seed <> $Check_HandRight_Seed Then
			If $HandRight_Seed = 0 AND $Check_HandRight_Seed <> 0 Then
				_log("-> Weapon Right Dropped", $LOG_LEVEL_WARNING)
			Else
				_log("-> Weapon Right switched", $LOG_LEVEL_WARNING)
			EndIf
			return False
		ElseIf $RingLeft_Seed <> $Check_RingLeft_Seed Then
			If $RingLeft_Seed = 0 AND $Check_RingLeft_Seed <> 0 Then
				_log("-> Ring Left Dropped", $LOG_LEVEL_WARNING)
			Else
				_log("-> Ring Left switched", $LOG_LEVEL_WARNING)
			EndIf
			return False
		ElseIf $RingRight_Seed <> $Check_RingRight_Seed Then
			If $RingRight_Seed = 0 AND $Check_RingRight_Seed <> 0 Then
				_log("-> Ring Right Dropped", $LOG_LEVEL_WARNING)
			Else
				_log("-> Ring Right switched", $LOG_LEVEL_WARNING)
			EndIf
			return False
		ElseIF $ArmorTotal <> $Check_ArmorTotal Then
			_log("-> Armor Total changed", $LOG_LEVEL_WARNING)
			return False
		EndIf

		_log("Checking stuff successful", $LOG_LEVEL_VERBOSE)
		Return true
	Else
		_log("Checking stuff Disable")
		return true
	EndIF
EndFunc

Func antiidle()
	$warnloc = GetCurrentPos()
	$warnarea = GetLevelAreaId()
	_log("Lost detected at : " & $warnloc[0] & ", " & $warnloc[1] & ", " & $warnloc[2], $LOG_LEVEL_ERROR, True);
	_log("Lost area : " & $warnarea, $LOG_LEVEL_ERROR, True);

	If NOT _checkInventoryopen() Then
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

	Local $__ACDACTOR = triBackPack(IterateBackpack(0))
	Local $iMax = UBound($__ACDACTOR)

	If $iMax > 0 Then

		Local $return[$iMax][4]

		Send($KeyCloseWindows) ; make sure we close everything
		Send($KeyInventory) ; open the inventory
		Sleep(100)

		CheckWindowD3Size()

		If Not $Unidentified Then
			Take_BookOfCain()
		EndIf

		For $i = 0 To $iMax - 1 ;c'est ici que l'on parcour (tours a tours) l'ensemble des items contenut dans notres bag

			$ACD = GetACDOffsetByACDGUID($__ACDACTOR[$i][0])
			$CurrentIdAttrib = _memoryread($ACD + 0x120, $d3, "ptr")
			$quality = GetAttribute($CurrentIdAttrib, $Atrib_Item_Quality_Level) ;on definit la quality de l'item traiter ici*

			$itemDestination = CheckItem($__ACDACTOR[$i][0], $__ACDACTOR[$i][1], 1) ;on recupere ici ce que l'on doit faire de l'objet (stash/inventaire/trash)

			If ($quality >= 9) Then
				If Not $PartieSolo Then WriteMe($WRITE_ME_HAVE_LEGENDARY) ; TChat
				$nbLegs += 1 ; on definit les legendaire et on compte les legs id au coffre
			ElseIf ($quality >= 6 And $itemDestination = "Stash") Then
				$nbRares += 1 ; on definit les rares
			EndIf

			$return[$i][0] = $__ACDACTOR[$i][3] ; definit la collone de l'item
			$return[$i][1] = $__ACDACTOR[$i][4] ; definit la ligne de l'item
			$return[$i][2] = $itemDestination ; action
			$return[$i][3] = $quality ; quality

		Next

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
	Global $Table_BannedActors = [0]

	If _ingame() Then
		While $count_locatemytoon <= 100
			$idarea = GetLevelAreaId()
			if $idarea <> -1 Then
				_log("Looking for local player", $LOG_LEVEL_VERBOSE)

				$_Myoffset = "0x" & Hex(GetPlayerOffset(), 8) ; pour convertir valeur
				$_MyGuid = _MemoryRead($_Myoffset + 0x88, $d3, 'ptr')

				$_NAME = _MemoryRead($_Myoffset + 0x4, $d3, 'char[64]')
				$_SNO = _MemoryRead($_Myoffset + 0x8c, $d3, 'ptr')

				$ACD = GetACDOffsetByACDGUID($_MyGuid)

				$name_by_acd = _MemoryRead($ACD + 0x4, $d3, 'char[64]')

				$_MyGuid = _memoryread($ACD + 0x120, $d3, "ptr")
				$My_FastAttributeGroup = GetFAG($_MyGuid)
				$_MyACDWorld = _memoryread($ACD + 0x108, $d3, "ptr")

				If Not trim($_NAME) = ""  Then
					If trim($_NAME) = trim($name_by_acd) Then
						_log("name -> " & $_NAME, $LOG_LEVEL_DEBUG)
						_log("sno -> " & hex($_SNO), $LOG_LEVEL_DEBUG)
						_log("guid -> " & $_MyGuid, $LOG_LEVEL_DEBUG)
						_log("ofs -> " & $_Myoffset, $LOG_LEVEL_DEBUG)

						setChararacter($_NAME)
				 		$_MyCharType = $_NAME

						If $hotkeycheck Then
							If Verif_Attrib_GlobalStuff() Then
								_log("Acd Ofs : " & $ACD, $LOG_LEVEL_DEBUG)
								return True
							Else
								_log("CHANGEMENT DE STUFF ON TOURNE EN ROND (locatemytoon)!!!!!", $LOG_LEVEL_ERROR)
								antiidle()
							EndIf
						Else
							_log("Acd Ofs : " & $ACD, $LOG_LEVEL_DEBUG)
							Return true
						EndIf
					Else
						;_log("Fail LocateMyToon, $_NAME <> $name_by_acd -> " & $count_locatemytoon)
						$count_locatemytoon += 1
					EndIf
				Else
					;_log("Fail LocateMyToon, Empty $_NAME  -> " & $count_locatemytoon)
					$count_locatemytoon += 1
				EndIf
			Else
				;_log("Fail LocateMyToon, Fail AreaId -> " & $idarea)
				$count_locatemytoon += 1
			EndIf
		Sleep(150)
		WEnd
		_log("Error during LocateMyToon", $LOG_LEVEL_WARNING)
	Else
		_log("LocateMyToon not possible since we are not in game", $LOG_LEVEL_WARNING)
	EndIF

EndFunc   ;==>LocateMyToon

Func startIterateLocalActor(ByRef $index, ByRef $offset, ByRef $count)
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8a8, $d3, "ptr") ; 2.0.3 : 0x8b8
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "ptr")
	$count = _memoryread($ptr3 + 0x108, $d3, "int")
	$index = 0
	$offset = _memoryread(_memoryread($ptr3 + 0x120, $d3, "ptr") + 0x0, $d3, "ptr")
EndFunc   ;==>startIterateLocalActor

Func iterateLocalActorList(ByRef $index, ByRef $offset, ByRef $count, ByRef $item)

	If $index > $count Then
		Return False
	EndIf

	Local $iterateLocalActorListStruct = DllStructCreate("ptr;char[64];byte[" & Int($ofs_LocalActor_atribGUID) - 68 & "];ptr")

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
Func IterateactorAtribs($_GUID, $_REQ)
	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateLocalActor($index, $offset, $count)

	While iterateLocalActorList($index, $offset, $count, $item)
		If $item[0] = $_GUID Then
			$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
			$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
			Return GetAttribute($CurrentIdAttrib, $_REQ)
			ExitLoop
		EndIf
	WEnd
	Return False
EndFunc   ;==>IterateActorAtribs

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

;;--------------------------------------------------------------------------------
;;	OffsetList()
;;--------------------------------------------------------------------------------
Func offsetlist()
	_log("offsetlist", $LOG_LEVEL_VERBOSE)

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
		_log("My toon located at: " & $_Myoffset & ", GUID: " & $_MyGuid & ", NAME: " & $_MyCharType, $LOG_LEVEL_VERBOSE)
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
	
	;Disable costly check
	;CheckWindowD3Size()

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
	$return[0] = ($x + 1) / 2 * $SizeWindows[0]
	$return[1] = (1 - $y) / 2 * $SizeWindows[1]

	$return = Checkclickable($return)

	Return $return
EndFunc   ;==>FromD3toScreenCoords

Func GetCurrentPos()
	Dim $return[3]

	Local $PosPlayerStruct = DllStructCreate("byte[164];float;float;float")
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $_Myoffset, 'ptr', DllStructGetPtr($PosPlayerStruct), 'int', DllStructGetSize($PosPlayerStruct), 'int', '')

	$return[0] = DllStructGetData($PosPlayerStruct, 2) ; X Head
	$return[1] = DllStructGetData($PosPlayerStruct, 3) ; Y Head
	$return[2] = DllStructGetData($PosPlayerStruct, 4) ; Z Head

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

	If _checkBountyRewardOpen() Then
		Send($KeyCloseWindows)
	EndIf

	If _checkQuestRewardOpen() Then
		ClickUI("Root.NormalLayer.questreward_dialog.button_exit", 1607)
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
				_log("Toggle try: " & $toggletry & " Movement Skipped : " & $SkippedMove, $LOG_LEVEL_WARNING)
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
			_log("MoveToPos Timed out ! ! ! ", $LOG_LEVEL_WARNING)
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
	Local $index, $offset, $count, $item[$TableSizeGuidStruct], $foundobject = 0
	Local $maxtry = 0
	startIterateObjectsList($index, $offset, $count)
	If _playerdead() = False Then
		While iterateObjectsList($index, $offset, $count, $item)
			If StringInStr($item[1], $a_name) And $item[9] < $dist Then
				_log("InteractByActorName : " & $item[1] & " distance -> " & $item[9], $LOG_LEVEL_VERBOSE)
				While getDistance($item[2], $item[3], $item[4]) > 40 And $maxtry <= 15
					$Coords = FromD3toScreenCoords($item[2], $item[3], $item[4])
					MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 10)
					$maxtry += 1
					_log('interactbyactor: click x : ' & $Coords[0] & " y : " & $Coords[1], $LOG_LEVEL_VERBOSE)
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
	$curhp = GetAttributeSelf($Atrib_Hitpoints_Cur)
	Return ($curhp / $maxhp)
EndFunc   ;==>GetLifep

Func GetAttribute($idAttrib, $attrib)
	Return _memoryread(GetAttributeOfs($idAttrib, BitOR($attrib[0], 0xFFFFF000)), $d3, $attrib[1])
EndFunc   ;==>GetAttribute

Func GetAttributeSelf($attrib)
	Return _memoryread(GetAttributeOfsSelf($My_FastAttributeGroup, BitOR($attrib[0], 0xFFFFF000)), $d3, $attrib[1])
EndFunc ;==> GetAttributeSelf

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
	$ptr2 = _memoryread($ptr1 + 0x8a8, $d3, "ptr") ; 2.0.3 : 0x8a8
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "int")
	$index = BitAND($Guid, 0xFFFF)

	$bitshift = _memoryread($ptr3 + 0x164, $d3, "int")
	$group1 = 4 * BitShift($index, $bitshift)
	$group2 = BitShift(1, -$bitshift) - 1
	$group3 = _memoryread(_memoryread($ptr3 + 0x120, $d3, "int"), $d3, "int")
	$group4 = 0x2f8 * BitAND($index, $group2)
	Return $group3 + $group1 + $group4
	;_log("index : " & $index& " bitshift : " & $bitshift & " group1 : " & $group1 & " group 2 : " & $group2 & " group 3 : " & $group3 & " group4 : " & $group4)
EndFunc   ;==>GetACDOffsetByACDGUID

Func iterateObjectsList(ByRef $index, ByRef $offset, ByRef $count, ByRef $item)
	If $count = 65535 Then
		Return False
	EndIf

	If $index > $count + 1 Then
		Return False
	EndIf

	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')
	If @Error > 0 Then Return False

	GetItemFromObjectsList($item, $iterateObjectsListStruct, $offset, 0, False)

	$index += 1
	$iterateObjectsListStruct = ""
	$offset = $offset + $_ObjmanagerStrucSize

	Return True
EndFunc   ;==>iterateObjectsList

Func ArrayStruct($tagStruct, $numElements)
    $sizeOfMyStruct = DllStructGetSize(DllStructCreate($tagStruct)) ;assumes end padding is included
    $bytesNeeded = $numElements * $sizeOfMyStruct
    Return DllStructCreate("byte[" & $bytesNeeded & "]")
EndFunc

Func GetElement($Struct, $Element, $tagSTRUCT)
   $result = DllStructCreate($tagSTRUCT, DllStructGetPtr($Struct) + $Element * DllStructGetSize(DllStructCreate($tagStruct)))
   If @Error > 0 Then Return False
   Return $result
EndFunc

Func GetItemFromObjectsList(ByRef $item, ByRef $iterateObjectsListStruct, ByRef $offset, $position, $CurrentPosition = False)

	$iterateObjectsStruct = GetElement($iterateObjectsListStruct, $position, $GuidStruct)
	
	If $iterateObjectsStruct = False Then 
		Return False
	EndIf

	If DllStructGetData($iterateObjectsStruct, 4) <> 0xFFFFFFFF Then
		If @Error > 0 Then Return False
		$item[0] = DllStructGetData($iterateObjectsStruct, 4) ; Guid
		If @Error > 0 Then Return False
		$item[1] = DllStructGetData($iterateObjectsStruct, 2) ; Name
		If @Error > 0 Then Return False
		$item[2] = DllStructGetData($iterateObjectsStruct, 6) ; x
		If @Error > 0 Then Return False
		$item[3] = DllStructGetData($iterateObjectsStruct, 7) ; y
		If @Error > 0 Then Return False
		$item[4] = DllStructGetData($iterateObjectsStruct, 8) ; z
		If @Error > 0 Then Return False
		$item[5] = DllStructGetData($iterateObjectsStruct, 18) ; data 1
		If @Error > 0 Then Return False
		$item[6] = DllStructGetData($iterateObjectsStruct, 16) ; data 2
		If @Error > 0 Then Return False
		$item[7] = DllStructGetData($iterateObjectsStruct, 14) ; data 3
		If @Error > 0 Then Return False
		$item[8] = $offset + $position * DllStructGetSize($iterateObjectsStruct)
		If @Error > 0 Then Return False
		$item[10] = DllStructGetData($iterateObjectsStruct, 10) ; x Foot
		If @Error > 0 Then Return False
		$item[11] = DllStructGetData($iterateObjectsStruct, 11) ; y Foot
		If @Error > 0 Then Return False
		$item[12] = DllStructGetData($iterateObjectsStruct, 12) ; z Foot
		If @Error > 0 Then Return False

		If Not $CurrentPosition Then
			$item[9] = GetDistance($Item[10], $Item[11], $Item[12])
		Else
			$item[9] = GetDistanceWithoutReadPosition($CurrentPosition, $Item[10], $Item[11], $Item[12])
		EndIf
	Else
		Return False
	EndIf

	Return True
EndFunc

Func IterateCACD(ByRef $ItemCRactor)

	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x8a8, $d3, "ptr") ; 2.0.3 ; 0x8b8
	$ptr3 = _memoryread($ptr2 + 0x0, $d3, "ptr")
	$_Count = _memoryread($ptr3 + 0x108, $d3, "int")
	$CurrentOffset = _memoryread(_memoryread($ptr3 + 0x120, $d3, "ptr") + 0x0, $d3, "ptr")
	Local $__ACDACTOR[$_Count + 1][7]

	$iterateACDActorStruct = ArrayStruct($ACDStruct, $_Count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $CurrentOffset, 'ptr', DllStructGetPtr($iterateACDActorStruct), 'int', DllStructGetSize($iterateACDActorStruct), 'int', '')

	For $i = 0 To $_Count
		$ACDActorStruct = GetElement($iterateACDActorStruct, $i, $ACDStruct)

		If DllStructGetData($ACDActorStruct, 1) <> -1 Then
			;_log(DllStructGetData($ACDActorStruct, 2))
			$found = false
			$buff = DllStructGetData($ACDActorStruct, 1) ;ID_ACD

			For $y=0 to Ubound($ItemCRactor) - 1
				;_log($ItemCRactor[$y][0] & " - " & $buff)
				If $ItemCRactor[$y][0] = $buff Then
					$ItemCRactor[$y][10] = $buff ;ID_ACD
					$ItemCRactor[$y][11] = DllStructGetData($ACDActorStruct, 5) ;ID_SNO
					$ItemCRactor[$y][12] = DllStructGetData($ACDActorStruct, 7) ;GB_TYPE
					$ItemCRactor[$y][13] = DllStructGetData($ACDActorStruct, 8) ;ID_GB
					$ItemCRactor[$y][14] = DllStructGetData($ACDActorStruct, 9) ;mobtype
					$ItemCRactor[$y][15] = DllStructGetData($ACDActorStruct, 11) ;Radius
					$ItemCRactor[$y][16] = DllStructGetData($ACDActorStruct, 13) ;ID_ATTRIB
					$ItemCRactor[$y][17] = _memoryread($CurrentOffset + $i * 0x2f8 + 0x180, $d3, "int")
					$ItemCRactor[$y][18] = _memoryread($CurrentOffset + $i * 0x2f8 + 0x184, $d3, "int")
					$ItemCRactor[$y][19] = _memoryread($CurrentOffset + $i * 0x2f8 + 0x188, $d3, "float")
					ExitLoop
				EndIf
			Next
		Endif
		$ACDActorStruct = ""
	Next
	$iterateACDActorStruct = ""
	Return $__ACDACTOR
EndFunc   ;==>IterateBackpack

Func IterateFilterAttackV4($IgnoreList)

	Local $index, $offset, $count
	startIterateObjectsList($index, $offset, $count)

	Dim $item_buff_2D[1][$TableSizeGuidStruct + 1]
	Dim $item[$TableSizeGuidStruct + 1]

	Local $z = 0

	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')
	If @error > 0 Then
		Return False
	EndIf

	$CurrentLoc = GetCurrentPos()

	For $i = 0 To $count

		If GetItemFromObjectsList($item, $iterateObjectsListStruct, $offset, $i, $CurrentLoc) Then
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
					Case Is_Rack($item)
						$handle = True
						$Item[13] = $ITEM_TYPE_RACK
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

Func IterateFilterZoneV2($dist, $n = 2)

	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)

	If $count = 0 Or $count = 65535 Then
		Return False
	EndIf

	Local $z = 0

	$CurrentLoc = GetCurrentPos()
	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')
	If @error > 0 Then
		Return False
	EndIf

	Dim $item[$TableSizeGuidStruct]

	For $i = 0 To $count
		If GetItemFromObjectsList($item, $iterateObjectsListStruct, $offset, $i, $CurrentLoc) Then
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
		EndIf
	Next

	$iterateObjectsListStruct = ""
	Return False
EndFunc

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
		   If Is_Mob($item_temp) Then
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
	Local $temp[$TableSizeGuidStruct]
	For $i = 0 To UBound($item) - 1
		$iterateObjectsListStruct = ArrayStruct($GuidStruct, 1)
		DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $item[$i][8], 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')

		GetItemFromObjectsList($temp, $iterateObjectsListStruct, $item[$i][8], 0, False)

		$item[$i][2] = $temp[2]
		$item[$i][3] = $temp[3]
		$item[$i][4] = $temp[4]
		$item[$i][9] = $temp[9] ; Distance
		$item[$i][10] = $temp[10]
		$item[$i][11] = $temp[11]
		$item[$i][12] = $temp[12]
	Next
	Return $item
EndFunc   ;==>UpdateObjectsList

Func UpdateObjectsPos($offset)
	Local $obj_pos[7], $item[$TableSizeGuidStruct]

	$iterateObjectsListStruct = ArrayStruct($GuidStruct, 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')

	GetItemFromObjectsList($item, $iterateObjectsListStruct, $offset, 0, False)

	$obj_pos[0] = $item[10]
	$obj_pos[1] = $item[11]
	$obj_pos[2] = $item[12]
	$obj_pos[3] = $item[9] ; Distance
	$obj_pos[4] = $item[2]
	$obj_pos[5] = $item[3]
	$obj_pos[6] = $item[4]
	Return $obj_pos

EndFunc   ;==>UpdateObjectsPos

Func Is_Shrine(ByRef $item)
	Select
		Case Not $TakeShrines
			Return False
		Case $item[9] > $range_shrine
			Return False
		Case (StringInStr($item[1], "shrine") Or StringInStr($item[1], "PoolOfReflection") Or StringInStr($item[1], "Purification_Well_"))
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
		Case (StringInStr($IgnoreList, $item[8]) <> 0) ; Objet ignoré
			Return False
		Case IsBannedActor($item[1]) ; Objet banni
			Return False
		Case IsItemStartInTable($Table_BanItemStartName, $item[1]) ; Banned known items
			Return False
		Case (StringInStr($item[1], "_projectile") <> 0) ; Projectile
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

Func Is_Rack(ByRef $item)
	Select
		Case $item[9] > $range_rack
			Return False
		Case IsItemInTable($Table_Rack, $item[1])
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
	$result = 0
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
	If GetAttribute($CurrentIdAttrib, $Atrib_gizmo_state) <> 1 Then
		$result = Power($item[1], $item[8], $item[0])
		If $result = 0 Then
			_log("Ban power -> " & $item[1], $LOG_LEVEL_DEBUG)
			BanActor($item[1])
		EndIf
	EndIf
	Return $result
EndFunc   ;==>handle_Power

Func handle_Health(ByRef $item)
	$result = 0
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
	If GetAttribute($CurrentIdAttrib, $Atrib_gizmo_state) <> 1 Then
		$result = Health($item[1], $item[8], $item[0])
		If $result = 0 Then
			_log("Ban health -> " & $item[1], $LOG_LEVEL_DEBUG)
			BanActor($item[1])
		EndIf
	EndIf
	Return $result
EndFunc   ;==>handle_Health

Func handle_Coffre(ByRef $item)
	$result = 0
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########

	If StringInStr($item[1],"x1_Global_Chest_CursedChest") then
		_log("Handling cursed chest")
		If GetAttribute($CurrentIdAttrib, $Atrib_gizmo_state) <> 1 Then
			$result = Shrine($item[1], $item[8], $item[0])
			If $result <> 2 Then
				_log("Ban Cursed chest (" & $result & ") -> " & $item[1])
				BanActor($item[1])
			EndIf
			If $result = 1 Then
				Sleep(2000)
				_log("Cursed Chest opened : Waiting 2 s")
			EndIf
		EndIf
	Else
		If GetAttribute($CurrentIdAttrib, $Atrib_Chest_Open) = 0 Then
			$result = Coffre($item) 
			If $result = 0 Then
				_log("Ban coffre -> " & $item[1], $LOG_LEVEL_DEBUG)
				BanActor($item[1])
			EndIf
		EndIf
	EndIf
	Return $result
EndFunc


Func handle_Shrine(ByRef $item)
	$result = 0
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
	If GetAttribute($CurrentIdAttrib, $Atrib_gizmo_state) <> 1 Then
		$result = Shrine($item[1], $item[8], $item[0])
		If $result = 0 Then
			_log("Ban shrine -> " & $item[1], $LOG_LEVEL_DEBUG)
			BanActor($item[1])
		EndIf
	EndIf
	Return $result
EndFunc   ;==>handle_Shrine


Func handle_Mob(ByRef $item, ByRef $IgnoreList, ByRef $test_iterateallobjectslist)
	; we have a monster
	$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
	$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
	Local $result = 0
	;_log("Current Hp -> " & GetAttribute($CurrentIdAttrib, $Atrib_Hitpoints_Cur) & " Is Invulnerable -> " & GetAttribute($CurrentIdAttrib, $Atrib_Invulnerable))
	If GetAttribute($CurrentIdAttrib, $Atrib_Hitpoints_Cur) > 0 And GetAttribute($CurrentIdAttrib, $Atrib_Invulnerable) = 0 Then
		$result = KillMob($item[1], $item[8], $item[0], $test_iterateallobjectslist)
		If $result = 0 Then
			$IgnoreList = $IgnoreList & $item[8]
		EndIf
	Else
		_log('No HP or Invulnerable : Ignoring ' & $item[1], $LOG_LEVEL_NONE)
		$IgnoreList = $IgnoreList & $item[8]
	EndIf
	Return $result
EndFunc   ;==>handle_Mob

Func Checkqual($_GUID)
	; _log("guid: "&$_GUID &" name: "& $_NAME & " qual: "&IterateActorAtribs($_GUID, $Atrib_Item_Quality_Level))
	$ACD = GetACDOffsetByACDGUID($_GUID)
	$CurrentIdAttrib = _memoryread($ACD + 0x120, $d3, "ptr");
	$quality = GetAttribute($CurrentIdAttrib, $Atrib_Item_Quality_Level)
	Return $quality
EndFunc   ;==>Checkqual

Func handle_Loot(ByRef $item, ByRef $IgnoreList, ByRef $test_iterateallobjectslist)
    $grabit = False

	If $gestion_affixe_loot Then
		Dim $item_aff_verif = IterateFilterAffixV2()
	Else
		$item_aff_verif = ""
	EndIf

	$itemDestination = CheckItem($item[0], $item[1])
	$result = 0
	
	If $itemDestination == "Stash" Or $itemDestination == "Salvage" Or $itemDestination == "Sell" Or ($itemDestination == "Inventory" And $takepot = True) Then
		; this loot is interesting
		If IsArray($item_aff_verif) and $gestion_affixe_loot Then
			If is_zone_safe($item[2],$item[3],$item[4],$item_aff_verif) Or Checkqual($item[0]) = 9 Then
				$result = Grabit($item[1], $item[8])
				If $result = 0 Then
					_log("Ban Item -> " & $item[1] & " Reason : Grabit To False (With affix)", $LOG_LEVEL_DEBUG)
					BanActor($item[1])
				EndIf
			Else
				_log("Item : " & $item[1] & " in affix zone, skipping")
				$result = 2
			EndIf
		Else
            $result = Grabit($item[1], $item[8])
            If $result = 0 Then
				_log("Ban Item -> " & $item[1] & " Reason : Grabit To False", $LOG_LEVEL_DEBUG)
				BanActor($item[1])
            EndIf
		EndIf
	Else
		If Not IsItemInTable($Table_Monster, $item[1])Then
			_log("Ban Item -> " & $item[1] & " Reason : not in Table_Monster (With affix)", $LOG_LEVEL_DEBUG)
			BanActor($item[1])
		EndIf
	EndIf
	Return $result
 EndFunc   ;==>handle_Loot

;;--------------------------------------------------------------------------------
;;      Attack()
;;--------------------------------------------------------------------------------
Func Attack()

	If _playerdead_revive() Then
		Return
	EndIf

	If _checkdisconnect() Or _playerdead() Or ($GameFailed And Not $Execute_TownPortalnew) Then
		$GameFailed = 1
		_log("Attack : Return because _playerdead or gamefailed or disconnect", $LOG_LEVEL_WARNING)
		Return
	EndIf

	Local $IgnoreList = ""
	Local $item[$TableSizeGuidStruct + 1]
	Local $OldActor = ""

	Dim $test_iterateallobjectslist = IterateFilterAttackV4($IgnoreList)
	Local $LastResult = 0
	Local $skipped = 0
	Local $totalSkipped = 0
	Local $shouldWait = False
	Local $wasLoot = False

	While IsArray($test_iterateallobjectslist)
		If _playerdead_revive() Then
			_log("Attack : ExitLoop cause of player_revive", $LOG_LEVEL_WARNING)
			ExitLoop
		EndIf

		If _checkdisconnect() Or _playerdead() Or ($GameFailed And Not $Execute_TownPortalnew) Then
			$GameFailed = 1
			_log("Attack : Return because _playerdead or gamefailed or disconnect", $LOG_LEVEL_WARNING)
			ExitLoop
		EndIf

		If _checkBountyRewardOpen() Then
			Send($KeyCloseWindows)
		EndIf

		If _checkQuestRewardOpen() Then
			ClickUI("Root.NormalLayer.questreward_dialog.button_exit", 1607)
		EndIf

		If $LastResult = 2 And $test_iterateallobjectslist[0][1] = $OldActor And UBound($test_iterateallobjectslist) > 1 Then
			_log("Attack : First Item skipped since same as last try", $LOG_LEVEL_DEBUG)
			$skipped += 1
			$totalSkipped += 1
			For $i = 0 To $TableSizeGuidStruct
				$item[$i] = $test_iterateallobjectslist[1][$i]
			Next
			If $WaitForLoot And $wasLoot And $item[13] <> $ITEM_TYPE_MOB Then
				; Last item was a loot skipped for affix, and next action is not a mob so wait a little in case multiple items in affix
				_log("Attack : Small wait because potential multiple item in affix", $LOG_LEVEL_DEBUG)
				Sleep(350)
			EndIf
		ElseIf $LastResult = 2 And $test_iterateallobjectslist[0][1] = $OldActor Then
			$skipped += 1
			$totalSkipped += 1
			_log("Attack : Item was skipped (attempt : " & $skipped & ")", $LOG_LEVEL_DEBUG)
			For $i = 0 To $TableSizeGuidStruct
				$item[$i] = $test_iterateallobjectslist[0][$i]
			Next
		Else
			If $LastResult <> 2 Then
				$totalSkipped = 0
			Else
				$totalSkipped += 1
			EndIf
			For $i = 0 To $TableSizeGuidStruct
				$item[$i] = $test_iterateallobjectslist[0][$i]
			Next
		EndIf

		If ($totalSkipped > 6) Then
			BanActor($item[1])
			_log("Attack : Ban " &  $item[1] & " too many skips", $LOG_LEVEL_DEBUG)
			ExitLoop
		ElseIf ($OldActor = $item[1]) And ($LastResult <> 2 Or $skipped > 2) Then
			BanActor($item[1])
			_log("Attack : Ban " &  $item[1] & " : Second passage", $LOG_LEVEL_DEBUG)
			ExitLoop
		Else
			$OldActor = $item[1]
		EndIf

		$oldResult = $LastResult
		$oldWait = $shouldWait 
		$LastResult = 0
		$shouldWait = False
		$wasLoot = False
		Select
			Case $item[13] = $ITEM_TYPE_LOOT
				$LastResult = handle_Loot($item, $IgnoreList, $test_iterateallobjectslist)
				$wasLoot = True
				If ($LastResult = 2) Then
					$shouldWait = True
				EndIf
			Case $item[13] = $ITEM_TYPE_MOB
				$LastResult = handle_Mob($item, $IgnoreList, $test_iterateallobjectslist)
				$shouldWait = True
			Case $item[13] = $ITEM_TYPE_SHRINE
				$LastResult = handle_Shrine($item)
			Case $item[13] = $ITEM_TYPE_CHEST
				$LastResult = handle_Coffre($item)
				$shouldWait = True
			Case $item[13] = $ITEM_TYPE_RACK
				$LastResult = handle_Coffre($item)
				$shouldWait = True
			Case $item[13] = $ITEM_TYPE_DECOR
				; TODO : Gérer proprement pour un timeout different et pas d'utilisation de gros skills
				$LastResult = handle_Mob($item, $IgnoreList, $test_iterateallobjectslist)
			Case $item[13] = $ITEM_TYPE_HEALTH
				$LastResult = handle_Health($item)
				If ($oldResult = 1 And $oldWait) Then
					$LastResult = 1
					$shouldWait = True
				EndIf
			Case $item[13] = $ITEM_TYPE_POWER
				$LastResult = handle_Power($item)
		EndSelect

		Dim $test_iterateallobjectslist = IterateFilterAttackV4($IgnoreList)

		If $WaitForLoot And $shouldWait And $test_iterateallobjectslist = False And ($LastResult = 1 Or ($wasLoot And $lastResult = 2)) Then
			If $LastResult = 1 Then
  				_log("Attack : No more items and last result = 1 with shouldWait -> Waiting 1 sec and checking for loots")
				Sleep(1000)
			Else
  				_log("Attack : No more items and last loot in retry for affix with shouldWait -> Waiting 1,5 sec and checking for loots")
				Sleep(1500)
			EndIf

			Dim $test_iterateallobjectslist = IterateFilterAttackV4($IgnoreList)
		EndIf
	WEnd

	If _checkBountyRewardOpen() Then
		Send($KeyCloseWindows)
	EndIf

	If _checkQuestRewardOpen() Then
		ClickUI("Root.NormalLayer.questreward_dialog.button_exit", 1607)
	EndIf

EndFunc   ;==>Attack

Func DetectElite($Guid)
	Return _MemoryRead(GetACDOffsetByACDGUID($Guid) + 0xB8, $d3, 'int')
EndFunc   ;==>DetectElite

;;--------------------------------------------------------------------------------
;;      KillMob()
;;--------------------------------------------------------------------------------

Func KillMob($Name, $offset, $Guid, $test_iterateallobjectslist2);pacht 8.2e
    $return = 1
    $begin = TimerInit()

    Dim $pos = UpdateObjectsPos($offset)

    $Coords = FromD3toScreenCoords($pos[4], $pos[5], $pos[6])
    MouseMove($Coords[0], $Coords[1], 3)

    Local $elite = DetectElite($Guid)
    Local $piorityMonster = IsItemInTable($Table_PriorityMonster, $Name)

    Local $killTimeoutValue = $a_time
    Local $noHitTimeout = 3000

    If $piorityMonster Then
    	; Monstre prioritaire on augmente les timeouts
		$killTimeoutValue = $killTimeoutValue * 3
		$noHitTimeout = $noHitTimeout * 2
	ElseIf $elite Then
		$CptElite += 1 ; on compte les elite
		; Monstre elite on augmente les timeouts
		If $elite = 7 Then
			$killTimeoutValue = $killTimeoutValue * 5
		Else
			$killTimeoutValue = $killTimeoutValue * 3
		EndIf
		$noHitTimeout = $noHitTimeout * 1.5
	EndIf

	;loop the attack until the mob is dead
    _log("Attacking : " & $Name & " (Type : " & $elite & ")", $LOG_LEVEL_VERBOSE);

    Local $maxhipi = Round(IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur))
    Local $timerinit = TimerInit()
    Local $timetokill
    Local $dps
    Local $varTemp

    Local $currentTargetHp = IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur)
	Local $timerHit = TimerInit()

	If $currentTargetHp = 0 Then
		_log($Name & " : No life -> skipping", $LOG_LEVEL_DEBUG)
	EndIf

    While $currentTargetHp > 0

        $myposs_aff = GetCurrentPos()

        $targetHp = IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur)

        If $targetHp <> $currentTargetHp Then
        	$timerHit = TimerInit()
        Else
	        If TimerDiff($timerHit) > $noHitTimeout Then
	        	_log($Name & " : Pas de DPS pendant " & Round($noHitTimeout / 1000) & " secondes on passe au mob suivant", $LOG_LEVEL_WARNING)
	        	$return = 2
	            ExitLoop
	        EndIf
        EndIf

		$currentTargetHp = $targetHp

        If _playerdead_revive() Then
            $return = 2
            _log($Name & " : Player was dead", $LOG_LEVEL_WARNING)
            ExitLoop
        EndIf

        If $gestion_affixe Then
        	Dim $pos = UpdateObjectsPos($offset)
        	maffmove($myposs_aff[0], $myposs_aff[1], $myposs_aff[2], $pos[0], $pos[1])
        EndIf

        If ($elite >= 1 And $ChaseElite) Or (IsItemInTable($Table_PriorityMonster, $Name)) Then
        	Dim $pos = UpdateObjectsPos($offset)
        Else
        	If IsArray($test_iterateallobjectslist2) Then
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

		        If UBound($test_iterateallobjectslist2) > 0 Then
			        $dist_verif = GetDistance($test_iterateallobjectslist2[0][10], $test_iterateallobjectslist2[0][11], $test_iterateallobjectslist2[0][12])
			        Dim $pos = UpdateObjectsPos($offset)
					If $pos[3] > $dist_verif + 5 Then
						_log($Name & " : Leave because of Dist Verif : " & $pos[3] & " - " & $dist_verif, $LOG_LEVEL_WARNING)
						$return = 2
						ExitLoop
					EndIf
				EndIf
			EndIf
		EndIf

        $Coords = FromD3toScreenCoords($pos[4], $pos[5], $pos[6])
        MouseMove($Coords[0], $Coords[1], 3)
        GestSpellcast($pos[3], 1, $elite, $Guid, $offset)
        If TimerDiff($begin) > $killTimeoutValue Then
            $killtimeout += 1
            _log($Name & " : Kill timeout (" & Round($killTimeoutValue / 1000) & " secs)", $LOG_LEVEL_WARNING)
            ; after this time, the mob should be dead, otherwise he is probly unkillable
            $return = 0
            ExitLoop
        EndIf
    WEnd

    $varTemp = IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur)

    If (IsNumber($varTemp) And $varTemp > 0) Then
        $maxhipi = $maxhipi - $varTemp
    EndIf

    $timetokill = Round(TimerDiff($timerinit) / 1000, 2)
 	$dps = Round($maxhipi / $timetokill)

 	If $return = 1 Then
    	_Log($Name & " : Killed in " & $timetokill & " secs (Dps : " & Round($dps / 1000) & "k)", $LOG_LEVEL_VERBOSE)
    EndIf

    $AverageDps = Ceiling( ($AverageDps*($NbMobsKilled-1) + $dps ) / $NbMobsKilled)
    $NbMobsKilled += 1

    Return $return
EndFunc   ;==>KillMob

;;--------------------------------------------------------------------------------
;;      Grabit()
;;--------------------------------------------------------------------------------
Func Grabit($name, $offset)
	Local $OriginalOffsetValue = _MemoryRead($offset + 0x0, $d3, 'ptr')
	$begin = TimerInit()
	$moveTimer = TimerInit()
	Dim $CoordVerif[3]

	_log("Grabbing : " & ($name), $LOG_LEVEL_DEBUG) ;FOR DEBUGGING

	Dim $pos = UpdateObjectsPos($offset)

	If (StringInStr($name, "gold") Or StringInStr($name, "_Console")) Then
		$Coords = FromD3toScreenCoords($pos[4], $pos[5], $pos[6])
		$CoordVerif[0] = $pos[4]
		$CoordVerif[1] = $pos[5]
		$CoordVerif[2] = $pos[6]
		MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 5)
	Else
		If $Inventory_Is_Full Then
			_Log("Grabit : Deactivate because your inventory is full", $LOG_LEVEL_VERBOSE)
			Return 0
		EndIf
		Interact($pos[4], $pos[5], $pos[6])
	EndIf

	Local $dist = $pos[3]

	While _MemoryRead($offset + 0x0, $d3, 'ptr') = $OriginalOffsetValue
		If _MemoryRead($offset + 0x0, $d3, 'ptr') = 0xFFFFFFFF Then
			Return 0
		EndIf

		If _playerdead_revive() Then
			Return 0
		EndIf
		GestSpellcast(0, 2, 0)

		If TimerDiff($begin) > $g_time Then
			$grabtimeout += 1
			; After this time we should already had the item
			Return 0
		EndIf

		Dim $pos = UpdateObjectsPos($offset)

		; TODO : Use MoveToPos to try to find another path !
		If (Round($dist,1) = Round($pos[3],1)) Then
			If TimerDiff($moveTimer) > 1500 Then
				_log("Leaving Grabit() : no move since " & Round(TimerDiff($moveTimer) / 1000, 1) & " secs", $LOG_LEVEL_WARNING)
				Return 2
			EndIf
		Else
			$moveTimer = TimerInit()
		EndIf

		If (StringInStr($name, "gold") Or StringInStr($name, "_Console")) Then
			$Coords = FromD3toScreenCoords($pos[4], $pos[5], $pos[6])
			;Check if the coord X y z havn't changed.
			If ($CoordVerif[0] <> $pos[4] Or $CoordVerif[1] <> $pos[5] Or $CoordVerif[2] <> $pos[6]) Then
				_log("Leaving Grabit() : Fake GOLD")
				Return 0
			Else
				MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 5)
			EndIf
		Else
			Interact($pos[4], $pos[5], $pos[6])

			If Detect_UI_error($MODE_INVENTORY_FULL) And Not $Execute_TpRepairAndBack Then ; $Execute_TpRepairAndBack = 0,car on ne veut pas y rentrer plus d'une fois "correction double tp inventaire plein"
				$Execute_TpRepairAndBack = True
				Unbuff()
				TpRepairAndBack()
				Buffinit()
				$Execute_TpRepairAndBack = False
			EndIf
		EndIf
		Sleep(100)
	WEnd
	Return 1
EndFunc   ;==>Grabit

Func GetIlvlFromACD($_ACDid)
	;_log("$_ACDid -> " & $_ACDid)
	$ACDStructure = DllStructCreate("int;char[128];byte[12];int;byte[32];ptr;ptr")
	$itemsAcdOfs = $_ACDid
	$CurrentIdAttrib = _memoryread($itemsAcdOfs + 0x120, $d3, "ptr"); ###########

	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $itemsAcdOfs, 'ptr', DllStructGetPtr($ACDStructure), 'int', DllStructGetSize($ACDStructure), 'int', '')

	$idsnogball = DllStructGetData($ACDStructure, 6)

	Local $iIndex = _ArraySearch($allSNOitems, $idsnogball, 0, 0, 1, 1)
	;_log($iIndex)
	If Int($iIndex) < UBound($allSNOitems) AND Int($iIndex) >= 0 Then
		;_log("iIndex - > " & $iIndex)
		Return $allSNOitems[$iIndex][1]
	Else
		Return 0
	EndIf

EndFunc   ;==>GetIlvlFromACD

;;================================================================================
; Function:                     CheckItem
; Description:          This will check a single item and tell if we keep it or not
;                       This function will be the core of the item filtering
;
; $_MODE :
; - 0 : On floor
; - 1 : In backpack
;
; Return:                       Trash
;                               Stash
;                               Salvage
;                               Inventory
;								Sell
;==================================================================================
Func CheckItem($_GUID, $_NAME, $_MODE = 0)
	; _log("guid: "&$_GUID &" name: "& $_NAME & " qual: "&IterateActorAtribs($_GUID, $Atrib_Item_Quality_Level))
	_log("CheckItem -> " & $_NAME, $LOG_LEVEL_VERBOSE)

	If IsItemInTable($Table_Potions, $_NAME) Then
		_log("CheckItem : Potion", $LOG_LEVEL_VERBOSE)
		Return "Inventory"
	ElseIf IsItemInTable($Table_grablist, $_NAME) Then
		_log("CheckItem : In grablist", $LOG_LEVEL_VERBOSE)
		Return "Stash"
	EndIf

	If Not IsItemStartInTable($Table_BanItemACDCheckList, $_NAME) Then
		$ACD = GetACDOffsetByACDGUID($_GUID)
		$CurrentIdAttrib = _memoryread($ACD + 0x120, $d3, "ptr");
		$quality = GetAttribute($CurrentIdAttrib, $Atrib_Item_Quality_Level)

		If $ItemToKeep[$quality] Then ; Item to keep
			_log("CheckItem : Quality in keepItem (" & $quality & ")", $LOG_LEVEL_VERBOSE)
			Return "Stash"
		EndIf

		If checkFromtable($GrabListTab, $_NAME, $quality) Then
			If checkIlvlFromtable($GrabListTab, $ACD, $_NAME) Then
				If checkFiltreFromtable($GrabListTab, $_NAME, $CurrentIdAttrib) Then
					_log("CheckItem : Stats are in grablist", $LOG_LEVEL_VERBOSE)
					Return "Stash"
				Endif
			EndIf
		EndIf

		If $ItemToSalvage[$quality] Then ; Item to salvage
			_log("CheckItem : Quality in salvageItem (" & $quality & ")", $LOG_LEVEL_VERBOSE)
			Return "Salvage"
		EndIf

		If $ItemToSell[$quality] Then ; Item to salvage
			_log("CheckItem : Quality in sellItem (" & $quality & ")", $LOG_LEVEL_VERBOSE)
			Return "Sell"
		EndIf
	EndIf

	If ($_MODE = 1) Then
		If $UnknownItemAction = "salvage" Then
			_log("CheckItem : Default action to Salvage", $LOG_LEVEL_VERBOSE)
			Return "Salvage"
		ElseIf $UnknownItemAction = "sell" Then
			_log("CheckItem : Default action to Sell", $LOG_LEVEL_VERBOSE)
			Return "Sell"
		EndIf
	EndIf
	_log("CheckItem : Trash", $LOG_LEVEL_VERBOSE)
	Return "Trash"
EndFunc   ;==>CheckItem

Func InventoryMove($col = 0, $row = 0);pacht 8.2e

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
	If GetLifep() < $LifeForPotion / 100 And TimerDiff($timeforpotion) > 1500 Then
		Send($KeyPotions)
		$timeforpotion = TimerInit()
	EndIf
EndFunc   ;==>checkForPotion

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
				;_log("filtre avant : " & $filtre_buff)
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
	If Not _playerdead() Then
		_log("OpenWp : " & $item[1] & " distance -> " & $item[9], $LOG_LEVEL_VERBOSE)
		While getDistance($item[2], $item[3], $item[4]) > 40 And $maxtry <= 15
			$Coords = FromD3toScreenCoords($item[10], $item[11], $item[12])
			;_log("Dans LE while")
			MouseClick($MouseMoveClick, $Coords[0], $Coords[1], 1, 10)
			$maxtry += 1
			_log('interactbyactor: click x : ' & $Coords[0] & " y : " & $Coords[1], $LOG_LEVEL_DEBUG)
			Sleep(500)
		WEnd
		Interact($item[2], $item[3], $item[4])
		Sleep(500)
	EndIf

EndFunc   ;==>OpenWp

Func GiveBucketWp($num)
	$bucket = ""
	Switch $num
		Case 0
			$bucket = "1363"
		Case 1
			$bucket = "378"
		Case 2
			$bucket = "995"
		Case 3
			$bucket = "1450"
		Case 4
			$bucket = "61"
		Case 5
			$bucket = "1562"
		Case 6
			$bucket = "265"
		Case 7
			$bucket = "1581"
		Case 8
			$bucket = "597"
		Case 9
			$bucket = "1310"
		Case 10
			$bucket = "883"
		Case 11
			$bucket = "612"
		Case 12
			$bucket = "980"
		Case 13
			$bucket = "49"
		Case 14
			$bucket = "1808"
		Case 15
			$bucket = "441"
		Case 16
			$bucket = "4"
		Case 17
			$bucket = "1538"
		Case 18
			$bucket = "1472" ;home act2
		Case 19
			$bucket = "536"
		Case 20
			$bucket = "667"
		Case 21
			$bucket = "1766"
		Case 22
			$bucket = "689"
		Case 23
			$bucket = "501"
		Case 24
			$bucket = "1249"
		Case 25
			$bucket = "28"
		Case 26
			$bucket = "421" ; HOME Act 3
		Case 27
			$bucket = "1745"
		Case 28
			$bucket = "539"
		Case 29
			$bucket = "1711"
		Case 30
			$bucket = "898"
		Case 31
			$bucket = "1317"
		Case 32
			$bucket = "945"
		Case 33
			$bucket = "364"
		Case 34
			$bucket = "923"
		Case 35
			$bucket = "503"
		Case 36
			$bucket = "631"
		Case 37
			$bucket = "613"
		Case 38
			$bucket = "1477"
		Case 39
			$bucket = "565" ;Home Act 4
		Case 40
			$bucket = "1664"
		Case 41
			$bucket = "1697"
		Case 42
			$bucket = "431"
		Case 43
			$bucket = "1045"
		Case 44
			$bucket = "1185"
		Case 45
			$bucket = "61"
		Case 46
			$bucket = "1113" ;Home act 5
		Case 47
			$bucket = "369"
		Case 48
			$bucket = "850"
		Case 49
			$bucket = "1062"
		Case 50
			$bucket = "162"
		Case 51
			$bucket = "348"
		Case 52
			$bucket = "785"
		Case 53
			$bucket = "192"
		Case 54
			$bucket = "820"
		Case 55
			$bucket = "1"
	EndSwitch
	_log("GiveBucketWp : " & $num & " -> " & $bucket, $LOG_LEVEL_DEBUG)
	Return $bucket
EndFunc

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

; $Mode : 0 pour Campagne et 1 pour aventure
Func TakeWPV2($WPNumber = 0, $Mode = 0)
    Local $Curentarea = GetLevelAreaId()
    Local $Newarea = $Curentarea

    Attack()

	If $GameFailed = 1 Then
		Return False
	EndIf

	While Not offsetlist()
		Sleep(10)
	WEnd

	$WayPointFound = False

	Local $index, $offset, $count, $item[$TableSizeGuidStruct], $maxRange = 130
	startIterateObjectsList($index, $offset, $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], "Waypoint") Then
			If $item[9] < $maxRange Then
				_log("WayPoint OK, MaxRange OK", $LOG_LEVEL_VERBOSE)
				$WayPointFound = true
				ExitLoop
			Else
				_log("WayPoint OK, MaxRange FALSE", $LOG_LEVEL_WARNING)
			EndIF
		EndIf
	WEnd

	If $WayPointFound Then
		_Log("WP Found", $LOG_LEVEL_VERBOSE)
		OpenWp($item)

		Sleep(1000)
		Local $wptry = 0
		While Not _checkWPopen() And Not _playerdead()
			If $wptry <= 6 Then
				_log('Fail to open wp', $LOG_LEVEL_WARNING)
				$wptry += 1
				OpenWp($item)
				Sleep(1000)
			EndIf
			If $wptry > 6 Then
				$GameFailed = 1
				_log('Failed to open wp after 6 try', $LOG_LEVEL_ERROR)
				Return False
			EndIf
		WEnd

		If fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.BountyOverlay.Rewards.BagReward", 1, 85) Then
			; We are in adventure mode
			If $mode = 0 Then
				_log("We are in adventure mode and tries to open a campain waypoint !", $LOG_LEVEL_ERROR)
				$GameFailed = 1;
				Return False
			EndIf
			VerifAct($WPNumber)
			$BucketUI = GiveBucketWp($WPNumber)
			$NameUI = "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry " & $WPNumber & ".LayoutRoot.Interest"
		Else
			; We are in campain mode
			If $mode = 1 Then
				_log("We are in campain mode and tries to open an adventure waypoint !", $LOG_LEVEL_ERROR)
				$GameFailed = 1;
				Return False
			EndIf
			$BucketUI = GetBucketForWP($WPNumber)
			If $WPNumber = 0 Then
				$NameUI = "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 0.LayoutRoot.Town"
			Else
				$NameUI = "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry " & $WPNumber & ".LayoutRoot.Name"
			EndIf
		EndIf

		sleep(500)
		_log("clicking wp UI", $LOG_LEVEL_VERBOSE)

		If ($BucketUI = 0) Then
			ClickUI($NameUI)
		Else
			ClickUI($NameUI, $BucketUI)
		EndIf

		Local $areatry = 0
		While $Newarea = $Curentarea And $areatry <= 30 ; on attend d'avoir une nouvelle Area environ 15 sec
			$Newarea = GetLevelAreaId()
			Sleep(500)
			$areatry += 1
		WEnd

		Sleep(500)

		While Not offsetlist()
			Sleep(10)
		WEnd

		$SkippedMove = 0 ;reset our skipped move count cuz we should be in brand new area

		Return True
	Else
		$Res = TakeWpByKey($WPNumber)
		_log("Result : TakeWpByKey " & $Res)
		If $Res = True Then
			Sleep(500)
			While Not offsetlist()
				Sleep(10)
			WEnd
			$SkippedMove = 0 ;reset our skipped move count cuz we should be in brand new area
			Return True
		Else
			_log("WP Not Found", $LOG_LEVEL_ERROR)
			$GameFailed = 1
			_log("$GameFailed = 1 $GameFailed = 1 $GameFailed = 1")
			Return False
		EndIf
	EndIf
	Return False
EndFunc

Func TakeWpByKey($num, $try = 0)

	Local $Curentarea = GetLevelAreaId()
    Local $Newarea = $Curentarea

	If Not $PartieSolo Then WriteMe($WRITE_ME_TP) ; TChat

	If _playerdead() Then
	   Return False
	EndIf

	While $try < 20 And $Newarea = $Curentarea And Not _checkdisconnect()

	   Local $WPopen = 0
	   Local $TPtimer = 0
	   Local $Attacktimer = 0
	   Local $compt_while = 0
	   Local $compt_wait = 0

	   _Log("TakeWpByKey : Enclenche attack during TakeWpByKey")
	   Attack()
	   Sleep(250)

	   If Not _playerdead() Then

		  CheckZoneBeforeTP()

		  Sleep(250)
		  Send("M")
		  Sleep(1000)

		  If _checkWPopen() Then
			 _Log("TakeWpByKey : clicking wp UI")
			 VerifAct($num)
			 ClickUI("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry " & $num & ".LayoutRoot.Interest", GiveBucketWp($num))
			 Sleep(300)
			 $WPopen = 1
		  EndIf

		  If $WPopen Then
			 _Log("TakeWpByKey : enclenchement fastCheckui de la barre de loading")
			 While fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068)
				If $compt_while = 0 Then
				   _log("enclenchement du timer")
				   $TPtimer = timerinit()
				EndIf
				$compt_while += 1

				checkforpotion()

				$Attacktimer = TimerInit()
				Attack()
				Sleep(100)
				TimerDiff($Attacktimer)
			 WEnd
		  EndIf


		  If Not $compt_while And Not _intown() And $WPopen Then
			 $CurrentLoc = getcurrentpos()
			 MoveToPos($CurrentLoc[0] + 5, $CurrentLoc[1] + 5, $CurrentLoc[2], 0, 6)
			 _Log("TakeWpByKey : On se deplace, pas de detection de la barre de TP")
		  Else
		     _Log("TakeWpByKey : compare time to tp -> " & (TimerDiff($TPtimer) - TimerDiff($Attacktimer)) & "> 3700 ")
		  EndIf

		  If (TimerDiff($TPtimer) - TimerDiff($Attacktimer)) > 3700 And $compt_while > 0 Then
			 While GetLevelAreaId() = $Curentarea And $compt_wait < 7
				_Log("on a peut etre reussi a tp, on reste inerte pendant 6sec voir si on arrive en ville, tentative -> " & $compt_wait)
				$compt_wait += 1
				sleep(1000)
			 WEnd
		  EndIf

		  Sleep(500)

		  $Newarea = GetLevelAreaId()
		  If $Newarea <> $Curentarea Then
			 _Log("TakeWpByKey : New area found", $LOG_LEVEL_DEBUG)
			 Sleep(500)
			 ExitLoop
		  Else
		     _Log("TakeWpByKey : New try -> " & $try + 1, $LOG_LEVEL_DEBUG)
			 $try += 1
		  EndIf
	   Else
	      _Log("TakeWpByKey : Vous etes morts lors d'une tentative de teleport !!!", $LOG_LEVEL_WARNING)
		  Return False
	   EndIf
	WEnd

	If $try > 19 Or _checkdisconnect() Then
	   _log("TakeWpByKey : Too many tries or Disconnected", $LOG_LEVEL_ERROR)
	   Return False
	EndIf

 	_Log("TakeWpByKey : On a renvoyer true, quite bien la fonction")
 	Return True
Endfunc ; ==> TakeWpByKey

;;--------------------------------------------------------------------------------
;;      _resumegame()
;;--------------------------------------------------------------------------------
Func _resumegame()
	If Not fastcheckuiitemactived("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.PlayGameButton", 1929) Then
		Sleep(500)
		Return
	EndIf

	$menu_rdy = 0

	If GameState() = 0 Then
		Sleep(500)
		_log("ResumeGame Disabled since we are on loading screen")
		Return False
	EndIf

	If GameState() = 5 Then
		$menu_rdy = 1
	EndIf

	If Not $TeamMate Then
		While Not fastcheckuiitemactived("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.ChangeQuestButton", 270)
			_log("Wait Other Follower")
			sleep(500)
		WEnd
	EndIf

	If $TeamMate Then
		While GameState() = 5
			_log("Wait Party Leader")
			sleep(500)
		WEnd
	Else
		_log("Resume Game")
		Sleep(Random(500, 1000, 1))
		If $Try_ResumeGame > 8 Then
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
		
		ClickUI("Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.PlayGameButton", 1929)
		$Try_ResumeGame += 1
	EndIf

	If GameState() = 0 And $menu_rdy = 1 Then
		While Not GameState() = 1
			Sleep(100)
		WEnd
	EndIf

	Sleep(1000)

EndFunc   ;==>_resumegame 2.0

Func _logind3()

	If $Try_Logind3 > 2 Then
		Local $wait_aftertoomanytry = Random(($Try_Logind3 * 2) * 60000, ($Try_Logind3 * 2) * 120000, 1)
		_log("Sleep after too many _logind3 -> " & $wait_aftertoomanytry, $LOG_LEVEL_VERBOSE)
		Sleep($wait_aftertoomanytry)
	EndIf

	WinActivate("[CLASS:D3 Main Window Class]")

	If Not _checkdisconnect() Then ; le bot ne fait pas la différence entre _checkdisconnect et déconnecter du serveur
		_Log("Login", $LOG_LEVEL_VERBOSE)
		Sleep(1000)
		Send($d3pass)
		Sleep(2000)
		Send("{ENTER}")
		Sleep(Random(5000, 6000, 1))

		$Try_Logind3 += 1
	Else
		_Log("Disconnected to server", $LOG_LEVEL_VERBOSE)
		sleep(2000)
		Send("{ENTER}")
		sleep(2000)
		Send("{ENTER}") ; enter, si jamais on a rentré le mot passe avant que la fenêtre apparaisse
		sleep(2000)
	EndIf
EndFunc   ;==>_logind3

Func ReConnect()

   _log("ReConnect", $LOG_LEVEL_WARNING)

   Local $Try_Connect = 0
   While _checkdisconnect() And $Try_Connect < 3
	  ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022)
	  sleep(1000)
	  $Try_Connect += 1
   WEnd

   While Not (_onloginscreen() Or _inmenu())
	  Sleep(500)
   WEnd

   Sleep(2000)

   Local $Try_Connect = 0
   While _checkdisconnect() And $Try_Connect < 3
	  ClickUI("Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList", 2022)
	  sleep(1000)
	  $Try_Connect += 1
   WEnd

   $disconnectcount += 1

EndFunc ;;==> ReConnect

;;--------------------------------------------------------------------------------
;;      _leavegame()
;;--------------------------------------------------------------------------------
Func _leavegame()
	Local $EScMenu_Is = 0
	Local $EscMenu_OK = 0
	Local $Try_Send_Esc = 0
	Local $Try_Leave = 0

	If _ingame() Then
		If Not $PartieSolo Then WriteMe($WRITE_ME_QUIT) ; TChat

		_log("Leave Game", $LOG_LEVEL_VERBOSE)

		While Not $EscMenu_OK And $Try_Send_Esc < 11
		   _Log("try n° " & $Try_Send_Esc + 1 & " Escape Menu")
		   Sleep(500)
		   Send($KeyCloseWindows) ; to make sure everything is closed
		   sleep(500)
		   Send("{ESCAPE}")
		   Sleep(500)

		   If _escmenu() Then
			  $EScMenu_Is = 1
		   EndIf

		   If $EScMenu_Is Then
			  $EscMenu_OK = 1
		   Else
			  _log("Menu Is Not Open", $LOG_LEVEL_VERBOSE)
			  $Try_Send_Esc += 1
		   EndIf
		WEnd

		If $EscMenu_OK Then
		   While _escmenu() And $Try_Leave < 5 ;après 4 fois on laisse la main au reste du code,car il y a forcément déco
			  ClickUI("Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame", 1644)
			  Sleep(900)
			  $Try_Leave += 1
		   WEnd

		   If $Try_Leave < 5 Then
			  _log("Leave Game Done", $LOG_LEVEL_VERBOSE)
			  Sleep(1000)
		   Else
			  _log("Can Not Leave Game, Because Disconnected", $LOG_LEVEL_WARNING)
			  Sleep(1000)
		   EndIf
	   Else
		  _log("Can Not Leave Game", $LOG_LEVEL_ERROR);elle seras rattraper par le reste du code,mais elle ne devrait plus causer d'error
	   EndIf
	EndIf
EndFunc   ;==>_leavegame



Global $VendorTabRepair = ""
Global $VendorTabSell = 0

;;--------------------------------------------------------------------------------
;;      Repair()
;;--------------------------------------------------------------------------------
Func Repair()
	GetAct()

	MoveTo($MOVETO_REPAIR_VENDOR)

	InteractByActorName($RepairVendor)

	Sleep(700)
	Local $vendortry = 0
	While _checkVendoropen() = False
		If $vendortry <= 4 Then
			_log('Fail to open vendor', $LOG_LEVEL_WARNING)
			$vendortry = $vendortry + 1
			InteractByActorName($RepairVendor)
		EndIf
		If $vendortry > 4 Then
			Send("{PRINTSCREEN}")
			Sleep(200)
			_log('Failed to open Vendor after 4 try', $LOG_LEVEL_ERROR)
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
	If $VendorTabRepair = "" Then ;On a jamais insctancier la recherche des tables
		If fastcheckuiitemvisible("Root.NormalLayer.shop_dialog_mainPage.tab_4", 1, 1984) Then
			$VendorTabRepair = 3
			_log("Definition of Repair Tab to TAB 3", $LOG_LEVEL_DEBUG)
		Else
			$VendorTabRepair = 2
			_log("Definition of Repair Tab to TAB 2", $LOG_LEVEL_DEBUG)
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

Func GameOverTime()
	Global $timedifmaxgamelength = TimerDiff($timermaxgamelength)
	If $timedifmaxgamelength > $maxgamelength Then
		_log('game over time !', $LOG_LEVEL_WARNING)
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

Func RandSleep($min = 5, $max = 45, $chance = 3)
	$randNum = Round(Random(1, 100))
	If $randNum <= $chance Then
		$sleepTime = Random($min * 1000, $max * 1000)
		_log("Sleeping " & $sleepTime & "ms", $LOG_LEVEL_VERBOSE)
		For $c = 0 To 10
			Sleep($sleepTime / 10)
		Next
	EndIf
EndFunc   ;==>RandSleep

;;--------------------------------------------------------------------------------
;;############# Speels by Xoum
;;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
;;      setChararacter()
;;--------------------------------------------------------------------------------

Func setChararacter($nameChar)
	$splitName = StringSplit($nameChar, "_")
	$nameCharacter = Trim($splitName[1])
	If $nameCharacter = "X1" Then
		$nameCharacter = Trim($splitName[2])
	Endif
EndFunc   ;==>setChararacter

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
		_log("I have more than " & $PotionStock & " potions. I will not take more until next check " & "(" & $potinstock & ")", $LOG_LEVEL_VERBOSE)
		$takepot = False
	Else
		_log("I have less than " & $PotionStock & " potions. I will grab them until next check " & "pot:" & "(" & $potinstock & ")", $LOG_LEVEL_VERBOSE)
		$takepot = True
	EndIf
EndFunc   ;==>enoughtPotions

;;--------------------------------------------------------------------------------
; Function:                     Shrine()
; Description:    Take Bonus shrine
;;--------------------------------------------------------------------------------
Func Shrine($name, $offset, $Guid)

	Local $begin = TimerInit()
    Local $moveTimer = TimerInit()
    Local $dist = getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))

	While iterateactoratribs($Guid, $Atrib_gizmo_state) <> 1 And Not _playerdead()
		
		$dist2 = getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
		; TODO : Use MoveToPos to try to find another path !
		If (Round($dist2, 1) = Round($dist, 1)) Then
			If TimerDiff($moveTimer) > 1500 Then
				_log("Leaving Shrine() : no move since " & Round(TimerDiff($moveTimer) / 1000, 1) & " secs", $LOG_LEVEL_WARNING)
				Return 2
			EndIf
		Else
			$moveTimer = TimerInit()
		EndIf

		$dist = $dist2

		If $dist >= 8 Then
			$Coords = FromD3toScreenCoords(_MemoryRead($offset + 0xB4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
			MouseMove($Coords[0], $Coords[1], 3)
		EndIf

		If TimerDiff($begin) > 6000 Then
			_log('Leaving Shrine() : timeout', $LOG_LEVEL_WARNING)
			Return 0
		EndIf
		Interact(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBc, $d3, 'float'))
	WEnd

	$CheckTakeShrineTaken += 1 ;on compte les CheckTakeShrine qu'on prend
	Return 1
EndFunc   ;==>shrine


Func Coffre($item)

	$name = $item[1]
	$offset = $item[8]
	$Guid = $item[0]

    Local $begin = TimerInit()
    Local $moveTimer = TimerInit()
    Local $dist = getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))

    While iterateactoratribs($Guid, $Atrib_Chest_Open) = 0 And Not _playerdead()
		
		$dist2 = getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
		; TODO : Use MoveToPos to try to find another path !
		If (Round($dist2, 1) = Round($dist, 1)) Then
			If TimerDiff($moveTimer) > 1500 Then
				_log("Leaving Coffre() : no move since " & Round(TimerDiff($moveTimer) / 1000, 1) & " secs", $LOG_LEVEL_WARNING)
				Return 2
			EndIf
		Else
			$moveTimer = TimerInit()
		EndIf

		$dist = $dist2
        If $dist >= 8 Then
            $Coords = FromD3toScreenCoords(_MemoryRead($offset + 0xB4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
            MouseMove($Coords[0], $Coords[1], 3)
        EndIf
		If TimerDiff($begin) > 8000 Then
	        _log('Leaving Coffre() : timeout', $LOG_LEVEL_WARNING)
	        Return 0
	    EndIf
        Interact(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBc, $d3, 'float'))
        Sleep(150)
	WEnd

	$CoffreTaken += 1;on compte les coffres qu'on ouvre

	If StringInStr($name , "Global_Chest") Then
		_log("Coffre() : Wait a litle, it's a demonic chest")
		Sleep(1200)
	EndIf

	Return 1
EndFunc   ;==>shrine


Func Health($name, $offset, $Guid)

	$life = GetLifep()
	Local $timeForHealth = TimerInit()
	While iterateactoratribs($Guid, $Atrib_gizmo_state) <> 1 And _playerdead() = False

		Local $distance = getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
		If $distance >= 8 Then
			If $life < ($LifeForHealth / 100) Then
				If TimerDiff($timeForHealth) > 2000 Then
					_log('health is banned because time out', $LOG_LEVEL_WARNING)
					Return 0
				Else
					$Coords = FromD3toScreenCoords(_MemoryRead($offset + 0xB4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
					MouseMove($Coords[0], $Coords[1], 3)
				EndIf
			ElseIf $life = 1 Then
				_log('Health globe ignore (already full life)', $LOG_LEVEL_VERBOSE)
				Return 0
			Endif
		ElseIf $distance < 2 Then
			_log('Health globe taken (distance=' & $distance & ')', $LOG_LEVEL_VERBOSE)
			Return 1
		EndIf

		If TimerDiff($timeForHealth) > 3000 Then
			_log('Fake health', $LOG_LEVEL_WARNING)
			Return 0
		EndIf

		Interact(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBc, $d3, 'float'))
	WEnd
	Return 1
EndFunc   ;==>health

Func Power($name, $offset, $Guid)

	Local $timeForPower = TimerInit()
		While iterateactoratribs($Guid, $Atrib_gizmo_state) <> 1 And _playerdead() = False

		Local $distance = getdistance(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
			If $distance >= 8 Then
				If TimerDiff($timeForPower) > 2000 Then
				_log('Power globe is banned because time out', $LOG_LEVEL_WARNING)
				Return 0
			Else
				$Coords = FromD3toScreenCoords(_MemoryRead($offset + 0xB4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBC, $d3, 'float'))
				MouseMove($Coords[0], $Coords[1], 3)
			EndIf
		ElseIf $distance < 2 Then
			_log('Power globe taken (distance=' & $distance & ')', $LOG_LEVEL_VERBOSE)
			Return 1
		EndIf

		If TimerDiff($timeForPower) > 3000 Then
			_log('Fake power globe', $LOG_LEVEL_WARNING)
			Return 0
		EndIf

		Interact(_MemoryRead($offset + 0xb4, $d3, 'float'), _MemoryRead($offset + 0xB8, $d3, 'float'), _MemoryRead($offset + 0xBc, $d3, 'float'))
	WEnd
	Return 1
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
	$c1 = _memoryread($c + 0x89C, $d3, "ptr") ; 2.0.3 : 0x8ac
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

Func GetAttributeOfsSelf($FAG, $attrib)

	$IndexMask = BitXOR($attrib, BitShift($attrib ,12))
	$ptr1 = _memoryread($FAG + 0x4, $d3, "int")

	$AttribEntry = 0
	If BitAnd($ptr1, 4) = 4 Then
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

EndFunc   ;==>GetAttributeOfsSelf

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
	;Return _memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Buff_Active[0], BitShift($idPower, -12))), $d3, "int") == 1
	;does not exist anymore in ros after 2.0.4
	Return False
EndFunc   ;==>IsBuffActive

Func launch_spell($i)

	Dim $buff_table[11]
	Switch $i
		Case 0
			$buff_table = $Skill1
		Case 1
			$buff_table = $Skill2
		Case 2
			$buff_table = $Skill3
		Case 3
			$buff_table = $Skill4
		Case 4
			$buff_table = $Skill5
		Case 5
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
 		Sleep(10)
	EndIf
EndFunc   ;==>launch_spell

Func GetResource($idAttrib, $resource)
	If $resource <> "" Then
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
			Case "wrath"
				$MaximumSource = $MaximumWrath
				$source = 0x7000
			Case Else
				$source = -1
		EndSwitch
		If $source = -1 Then
			Return 1
		Else
			Return _memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Cur[0], $source)), $d3, "float") / $MaximumSource
		EndIf
	Else
		Return 1
	EndIf
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
			Case 0
				$buff_table = $Skill1
			Case 1
				$buff_table = $Skill2
			Case 2
				$buff_table = $Skill3
			Case 3
				$buff_table = $Skill4
			Case 4
				$buff_table = $Skill5
			Case 5
				$buff_table = $Skill6
		EndSwitch

		Switch $buff_table[5]
			Case "spirit"
				$MaximumSource = $MaximumSpirit
			Case "fury"
				$MaximumSource = $MaximumFury
			Case "arcane"
				$MaximumSource = $MaximumArcane
			Case "mana"
				$MaximumSource = $MaximumMana
			Case "hatred"
				$MaximumSource = $MaximumHatred
			Case "discipline"
				$MaximumSource = $MaximumDiscipline
			Case "wrath"
				$MaximumSource = $MaximumWrath
			Case Else
				$MaximumSource = 15000
		EndSwitch

		$source = GetResource($_MyGuid, $buff_table[5])

		If $buff_table[0] And ($source > $buff_table[4] / $MaximumSource Or $buff_table[5] = "") And (TimerDiff($buff_table[10]) > $buff_table[2] or $buff_table[2] = "") Then ;skill Activé
			Switch $action_spell
   				Case 0 ; movetopos
    				Switch $buff_table[3]
						Case $SPELL_TYPE_LIFE
							If GetLifep() <= $buff_table[7] / 100 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_MOVE
							If Not IsBuffActive($_MyGuid, $buff_table[9]) Then
								;~ 	$timer_buff = TimerInit()
								;If $nameCharacter = "DemonHunter" Then
								;	If IsBuffActive($_MyGuid,$DemonHunter_Chakram )=False then
								;		Send("1")
								;	Endif
								;Endif
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_OR_ATTACK
							If GetLifep() <= $buff_table[7] / 100 Or ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_MOVE_OR_ATTACK
							If ($Distance <= $buff_table[8] Or $buff_table[8] = "") Or $action_spell <> 1 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_OR_BUFF
							If IsBuffActive($_MyGuid, $buff_table[9]) = False Or GetLifep() <= $buff_table[7] / 100 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_OR_MOVE
							If IsBuffActive($_MyGuid, $buff_table[9]) = False Or GetLifep() <= $buff_table[7] / 100 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_OR_ELITE
							If GetLifep() <= $buff_table[7] / 100 Or $elite > 0 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_PERMANENT_BUFF
							launch_spell($i)
							$buff_table[10] = TimerInit()
					EndSwitch
				Case 1 ; attack
					Switch $buff_table[3]
						Case $SPELL_TYPE_LIFE
							If GetLifep() <= $buff_table[7] / 100 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							 EndIf
						Case $SPELL_TYPE_ATTACK
							If $Distance <= $buff_table[8] Or $buff_table[8] = "" Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_PHYSICAL
							launch_spell($i)
						Case $SPELL_TYPE_ELITE
						  	If $elite > 0  then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							 Endif
						Case $SPELL_TYPE_BUFF
							If Not IsBuffActive($_MyGuid, $buff_table[9]) Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_ZONE
							If $buff_table[8] = "" Then ; TODO : Check that ! 
							   $dist = 20
							Else
							   $dist = $buff_table[8]
							EndIf
							If TimerDiff($ZoneCheckTimer) > 500 Then
								If IterateFilterZoneV2($dist) Then
									launch_spell($i)
									$buff_table[10] = TimerInit()
								EndIf
								$ZoneCheckTimer = TimerInit()
							EndIf
						Case $SPELL_TYPE_ZONE_AND_BUFF
							If IsBuffActive($_MyGuid, $buff_table[9]) = False then
								If $buff_table[8] = "" Then ; TODO : Check that ! 
								   $dist = 20
								Else
								   $dist = $buff_table[8]
								EndIf
								If TimerDiff($ZoneCheckTimer) > 500 Then
									If IterateFilterZoneV2($dist) Then
										launch_spell($i)
										$buff_table[10] = TimerInit()
									EndIf
									$ZoneCheckTimer = TimerInit()
								EndIf
						 	Endif
						Case $SPELL_TYPE_LIFE_AND_ATTACK
							If GetLifep() <= $buff_table[7] / 100 And ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_OR_ATTACK 
							If GetLifep() <= $buff_table[7] / 100 Or ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_MOVE_OR_ATTACK 
							If $Distance <= $buff_table[8] Or $buff_table[8] = "" Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_OR_BUFF
							If IsBuffActive($_MyGuid, $buff_table[9]) = False Or GetLifep() <= $buff_table[7] / 100 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_OR_MOVE
							If GetLifep() <= $buff_table[7] / 100 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							 EndIf
						Case $SPELL_TYPE_LIFE_AND_BUFF
							If IsBuffActive($_MyGuid, $buff_table[9]) = False And GetLifep() <= $buff_table[7] / 100 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_ATTACK_OR_BUFF
							If IsBuffActive($_MyGuid, $buff_table[9]) = False Or ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_ATTACK_AND_BUFF
							If IsBuffActive($_MyGuid, $buff_table[9]) = False And ($Distance <= $buff_table[8] Or $buff_table[8] = "") Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_OR_ELITE
							If GetLifep() <= $buff_table[7] / 100 Or $elite > 0 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_LIFE_AND_ELITE
							If GetLifep() <= $buff_table[7] / 100 And $elite > 0 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_ATTACK_OR_ELITE
							If ($Distance <= $buff_table[8] Or $buff_table[8] = "") Or $elite > 0 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_ATTACK_AND_ELITE
							If ($Distance <= $buff_table[8] Or $buff_table[8] = "") And $elite > 0 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_ELITE_AND_BUFF
							If IsBuffActive($_MyGuid, $buff_table[9]) = False And $elite > 0 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						case $SPELL_TYPE_ELITE_OR_BUFF
							If IsBuffActive($_MyGuid, $buff_table[9]) = False Or $elite > 0 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							 EndIf
						Case $SPELL_TYPE_PERMANENT_BUFF
							launch_spell($i)
							$buff_table[10] = TimerInit()
						Case $SPELL_TYPE_CHANNELING	
							; See in unused  Removed_GestSpellcast! 
							; TODO : Handle this
					Endswitch
				Case 2 ; grab
					Switch $buff_table[3]
						Case $SPELL_TYPE_LIFE
							If GetLifep() <= $buff_table[7] / 100 Then
								launch_spell($i)
								$buff_table[10] = TimerInit()
							EndIf
						Case $SPELL_TYPE_PERMANENT_BUFF
							launch_spell($i)
							$buff_table[10] = TimerInit()
						Case $SPELL_TYPE_MOVE 
							If Not IsBuffActive($_MyGuid, $buff_table[9]) Then
								$timer_buff = TimerInit()
								;if IsBuffActive($_MyGuid,$DemonHunter_Chakram )=False then
								;   If $nameCharacter = "DemonHunter" Then Send("1")
								;endif
			 					launch_spell($i)
			 					;Send("{" & $buff_table[6] & " down}")
			 					;While Not IsBuffActive($_MyGuid, $buff_table[9])
			 					;	If TimerDiff($timer_buff) > 350 Then ExitLoop
			 					;	Sleep(50)
			 					;WEnd
			 					;Send("{" & $buff_table[6] & " up}")
								$buff_table[10] = TimerInit()
							EndIf
					EndSwitch
			EndSwitch
		EndIf

		Switch $i
			Case 0
				$Skill1 = $buff_table
			Case 1
				$Skill2 = $buff_table
			Case 2
				$Skill3 = $buff_table
			Case 3
				$Skill4 = $buff_table
			Case 4
				$Skill5 = $buff_table
			Case 5
				$Skill6 = $buff_table
		EndSwitch
	Next
EndFunc   ;==>GestSpellcast

Func GestSpellInit()
	_log("Starting GestSpellInit",$LOG_LEVEL_DEBUG)
	For $i = 0 To 5

		Dim $buff_table[11]
		Dim $buff_conf_table[6]

		Switch $i
			Case 0 
				$buff_conf_table = $Skill_conf1
				$buff_table = $Skill1
			Case 1
				$buff_conf_table = $Skill_conf2
				$buff_table = $Skill2
			Case 2
				$buff_conf_table = $Skill_conf3
				$buff_table = $Skill3
			Case 3
				$buff_conf_table = $Skill_conf4
				$buff_table = $Skill4
			Case 4
				$buff_conf_table = $Skill_conf5
				$buff_table = $Skill5
			Case 5
				$buff_conf_table = $Skill_conf6
				$buff_table = $Skill6
		EndSwitch

		If Not $buff_conf_table[0] Or $buff_conf_table[0] = "false" Then
			$buff_table[0] = False
		Else
			$buff_table[0] = True
		EndIf

		If $buff_table[0] Then ;Si skill actived
			If Not trim($buff_conf_table[1]) = "" Then ;Delay
				$buff_table[2] = $buff_conf_table[1]
			EndIf
			If Not trim($buff_conf_table[2]) = "" Then ;Type
				$buff_table[3] = $buff_conf_table[2]
			EndIf
			If Not trim($buff_conf_table[3]) = "" Then ;EnergyNeeds
				$buff_table[4] = $buff_conf_table[3]
			EndIf
			If Not trim($buff_conf_table[4]) = "" Then ;Trigger Life
				$buff_table[7] = $buff_conf_table[4]
			EndIf
			If Not trim($buff_conf_table[5]) = "" Then ;Trigger Distance
				$buff_table[8] = $buff_conf_table[5]
			EndIf
		EndIF

		Local $type = 1
		Select
			Case $buff_table[3] = "life"
				$type = $SPELL_TYPE_LIFE
			Case $buff_table[3] = "attack"
				$type = $SPELL_TYPE_ATTACK
			Case $buff_table[3] = "physical"
				$type = $SPELL_TYPE_PHYSICAL
			Case $buff_table[3] = "elite"
				$type = $SPELL_TYPE_ELITE
			Case $buff_table[3] = "buff"
				$type = $SPELL_TYPE_BUFF
			Case $buff_table[3] = "zone"
				$type = $SPELL_TYPE_ZONE
			Case StringInStr($buff_table[3], "zone") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "buff")
				$type = $SPELL_TYPE_ZONE_AND_BUFF
			Case $buff_table[3] = "move"
				$type = $SPELL_TYPE_MOVE
			Case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "attack")
				$type = $SPELL_TYPE_LIFE_AND_ATTACK
			Case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "attack")
				$type = $SPELL_TYPE_LIFE_OR_ATTACK
			Case StringInStr($buff_table[3], "move") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "attack")
				$type = $SPELL_TYPE_MOVE_OR_ATTACK
			Case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "buff")
				$type = $SPELL_TYPE_LIFE_OR_BUFF
			Case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "move")
				$type = $SPELL_TYPE_LIFE_OR_MOVE
			Case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "buff")
				$type = $SPELL_TYPE_LIFE_AND_BUFF
			Case StringInStr($buff_table[3], "attack") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "buff")
				$type = $SPELL_TYPE_ATTACK_OR_BUFF
			Case StringInStr($buff_table[3], "attack") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "buff")
				$type = $SPELL_TYPE_ATTACK_AND_BUFF
			Case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "elite")
				$type = $SPELL_TYPE_LIFE_OR_ELITE
			Case StringInStr($buff_table[3], "life") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "elite")
				$type = $SPELL_TYPE_LIFE_AND_ELITE
			Case StringInStr($buff_table[3], "attack") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "elite")
				$type = $SPELL_TYPE_ATTACK_OR_ELITE
			Case StringInStr($buff_table[3], "attack") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "elite")
				$type = $SPELL_TYPE_ATTACK_AND_ELITE
			Case StringInStr($buff_table[3], "elite") And StringInStr($buff_table[3], "&") And StringInStr($buff_table[3], "buff")
				$type = $SPELL_TYPE_ELITE_AND_BUFF
			Case StringInStr($buff_table[3], "elite") And StringInStr($buff_table[3], "|") And StringInStr($buff_table[3], "buff")
				$type = $SPELL_TYPE_ELITE_OR_BUFF
			Case $buff_table[3] = "buff_permanent"
				$type = $SPELL_TYPE_PERMANENT_BUFF
			Case $buff_table[3] = "canalisation"
				$type = $SPELL_TYPE_CHANNELING
		EndSelect

		$buff_table[3] = $type

		Switch $i
			Case 0
				$Skill1 = $buff_table
			Case 1
				$Skill2 = $buff_table
			Case 2
				$Skill3 = $buff_table
			Case 3
				$Skill4 = $buff_table
			Case 4
				$Skill5 = $buff_table
			Case 5
				$Skill6 = $buff_table
		EndSwitch
	Next
EndFunc   ;==>GestSpellInit

;;================================================================================
; Function:                     GetPlayerOffset
; Note(s):
;==================================================================================
Func GetPlayerOffset()
	$ptr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2 = _memoryread($ptr1 + 0x994, $d3, "ptr")  ; 2.0.3 : 0x9a4    ;0x96c
	$index = _memoryread($ptr2 + 0x0, $d3, "int")

	$ptr1bis = _memoryread($ofs_objectmanager, $d3, "ptr")
	$ptr2bis = _memoryread($ptr1 + 0x87c, $d3, "ptr") ; 2.0.3 : 0x88c    ;0x874
	$id = _memoryread($ptr2bis + 0x5c + $index * 0xD138, $d3, "int")

	Return GetActorFromId($id)
EndFunc   ;==>GetPlayerOffset

;;================================================================================
; Function:                     GetActorFromId
; Note(s):
;==================================================================================
Func GetActorFromId($id, $maxtry = 0)
	$maxtry += 1
	If $maxtry >= 1000 Then ;Recursivity Protection, Max 1000
		Return 0
	EndIf

	Local $index, $offset, $count, $item[10]
	startIterateObjectsList($index, $offset, $count)

	If $count > 500 Then
		Sleep(200)
		Return GetActorFromId($id, $maxtry)
	EndIf

	Dim $TableActor = IterateObjectListV2()

	For $i = 0 to UBound($TableActor) - 1
		If $TableActor[$i][0] = $id then
			Return $TableActor[$i][8]
		EndIf
	Next
	Return 0
EndFunc   ;==>GetActorFromId

Func GoToTown()

    _log("start loop _onloginscreen() = False And _intown() = False And _playerdead() = False")

	If _checkdisconnect() Then
	   _log("Disconnected dc1.a", $LOG_LEVEL_ERROR)
	   ReConnect()
	   Return False
    EndIf

	Local $nbTriesTownPortal = 0
	While Not _intown() And Not _inmenu()
		$nbTriesTownPortal += 1

		If $nbTriesTownPortal < 3 Then
			If NOT _TownPortalnew(10) Then
				$nbTriesTownPortal = 3
			EndIf
		Else
			Attack()
			_leaveGame()
			$nbTriesTownPortal = 0
			Sleep(10000)
			While Not _inmenu()
				Sleep(10)
			WEnd
			ExitLoop
		EndIf

		If _checkdisconnect() Then
			_log("Disconnected dc1.b", $LOG_LEVEL_ERROR)
			ReConnect()
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
		If Not _TownPortalnew() Then
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
		_log("ERROR Impossible to open this tab from stash", $LOG_LEVEL_ERROR)
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

	getAct()

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
				_log('Fail to open Stash', $LOG_LEVEL_WARNING)
				$stashtry += 1
				InteractByActorName("Player_Shared_Stash")
				Sleep(Random(100, 200))
			Else
				Send("{PRINTSCREEN}")
				Sleep(200)
				_log('Failed to open Stash after 4 try', $LOG_LEVEL_ERROR)
				WinSetOnTop("Diablo III", "", 0)
				MsgBox(0, "Impossible d'ouvrir le stash :", "SVP, veuillez reporter ce problème sur le forum. Erreur : s001 ")
				Terminate()
			EndIf
		WEnd
		$tabfull = 0
		CheckWindowD3Size()

		For $i = 0 To UBound($ToStash) - 1
			_log("Move backpack : " & $items[$ToStash[$i]][0] & "/" & $items[$ToStash[$i]][1] & " to stash")

			Sleep(Random(100, 200))
			InventoryMove($items[$ToStash[$i]][0], $items[$ToStash[$i]][1])
			Sleep(Random(100, 500))

			MouseClick('Right')
			Sleep(Random(50, 200))
			If Detect_UI_error($MODE_STASH_FULL) Then
				_log('Tab is full : Switching tab', $LOG_LEVEL_WARNING)
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
					_log('Stash is full : Botting stopped', $LOG_LEVEL_ERROR)
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
			_log("CHANGEMENT DE STUFF ON TOURNE EN ROND (Stash and Repair - Stash)!!!!!", $LOG_LEVEL_ERROR)
			antiidle()
		EndIf
		;****************************************************************

	EndIf

	Sleep(Random(100, 200))
	Send($KeyCloseWindows)
	Sleep(Random(100, 200))
	Sleep(Random(500, 1000))

    ;recyclage
	$ToRecycle = _ArrayFindAll($items, "Salvage", 0, 0, 0, 1, 2)
	If $ToRecycle <> -1 Then ; si item a recyclé

	   MoveTo($MOVETO_SMITH)

	   InteractByActorName("PT_Blacksmith_RepairShortcut")
	   Sleep(700)

	   Local $BlacksmithTry = 0
	   While _checkSalvageopen() = False
		  If $BlacksmithTry <= 4 Then
			 _log('Fail to open Salvage', $LOG_LEVEL_WARNING)
			 $BlacksmithTry += 1

			 InteractByActorName("PT_Blacksmith_RepairShortcut")
			 Sleep(500)
		  EndIf

		  If $BlacksmithTry > 4 Then
			 Send("{PRINTSCREEN}")
			 Sleep(200)
			 _log('Failed to open Salvage after 4 try', $LOG_LEVEL_ERROR)
			 WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
			 MsgBox(0, "Impossible d'ouvrir le Forgeron :", "SVP, veuillez reporter ce problème sur le forum. Erreur : v001 ")
			 Terminate()
			 ExitLoop
		  EndIf
	   WEnd

	   $ToTrash = _ArrayFindAll($items, "Trash", 0, 0, 0, 1, 2)
	   $ToSell = _ArrayFindAll($items, "Sell", 0, 0, 0, 1, 2)
	   If $ToTrash = -1 And $ToSell = -1 Then ; si pas items a aller vendre on répare au forgeron
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
		  _log("CHANGEMENT DE STUFF ON TOURNE EN ROND (Stash and Repair - Forgeron)!!!!!", $LOG_LEVEL_ERROR)
		  antiidle()
	   EndIf
	   ;****************************************************************

	   Sleep(Random(100, 200))
	   Send($KeyCloseWindows)
	   Sleep(Random(100, 200))
	   Sleep(Random(500, 1000))

	   MoveTo($MOVETO_SMITH)

    EndIf ; fin recyclage

	Local $GoldBeforeBuyPotion = GetGold();on mesure l'or avant l' achats de potion
	BuyPotion()
	Local $GoldAfterBuyPotion = GetGold();on mesure l'or apres
	$GoldByRepaire += $GoldBeforeBuyPotion - $GoldAfterBuyPotion ;on compte le cout des potion inclus da la stast GoldByRepaire

    If Not $Repair Then

		Local $GoldBeforeRepaire = GetGold();on mesure l'or avant la reparation et achats de potion
		Repair()
		Local $GoldAfterRepaire = GetGold();on mesure l'or apres
		$GoldByRepaire += $GoldBeforeRepaire - $GoldAfterRepaire;on compte le cout de la reparation et potion

		;Trash
		$ToTrash = _ArrayFindAll($items, "Trash", 0, 0, 0, 1, 2)
		$ToSell = _ArrayFindAll($items, "Sell", 0, 0, 0, 1, 2)

	    If $ToTrash <> -1 Or $ToSell <> -1 Then

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
   		   For $i = 0 To UBound($ToSell) - 1
			  InventoryMove($items[$ToSell[$i]][0], $items[$ToSell[$i]][1])
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
			  _log("CHANGEMENT DE STUFF ON TOURNE EN ROND (Stash and Repair - vendeur)!!!!!", $LOG_LEVEL_ERROR)
			  antiidle()
		   EndIf
		   ;****************************************************************
	    EndIf

		MoveTo($MOVETO_REPAIR_VENDOR)
    EndIf

    Sleep(Random(100, 200))
    Send($KeyCloseWindows)
    Sleep(Random(100, 200))

	MoveTo($MOVETO_PORTAL)

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
	_log("LoadingSNO", $LOG_LEVEL_NONE)

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

	_log("GB SNO loaded", $LOG_LEVEL_NONE)

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

	While $tpcheck = 0 And $tptry < 5
		_log("try n°" & $tptry + 1 & " hearthPortal")
		InteractByActorName('hearthPortal')
		$Newarea = GetLevelAreaId()

		Local $areatry = 0

		While $Newarea = $Curentarea And $areatry <= 30
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

	MoveTo($MOVETO_PORTAL)

	Local $HearthPortalTry = 0
	Local $NewAreaOk = 0

	While $NewAreaOk = 0 And $HearthPortalTry < 5
		_Log("try n°" & $HearthPortalTry + 1 & " hearthPortal")
		InteractByActorName('hearthPortal')
		$Newarea = GetLevelAreaId()

		Local $areatry = 0
		While $Newarea = $Curentarea And $areatry <= 30
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
		_log('We failed to teleport back', $LOG_LEVEL_ERROR)
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
                	_log("The UI element we are looking for is invisible", $LOG_LEVEL_WARNING)
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
		If $Point[0] <> 0 Then
			$sizecheck = 1
		Endif
    WEnd

    If $Point[0] = 1026 And $Point[1] = 622 And $Point[2] = 1586 And $Point[3] = 954 Then
		_log("UI Size check OK : " & $Point[0] & ":" & $Point[1] & ":" & $Point[2] & ":" & $Point[3])
		Return True
    Else
		If $Point[0] = False Then
			_log("UI Size check failed for unknow reason : " & $Point[0] & ":" & $Point[1] & ":" & $Point[2] & ":" & $Point[3], $LOG_LEVEL_ERROR)
		Else
			_log("UI Size check failed cuz windows is wrong size : " & $Point[0] & ":" & $Point[1] & ":" & $Point[2] & ":" & $Point[3], $LOG_LEVEL_ERROR)
		Endif
		antiidle()
    EndIf

EndFunc   ;==>_checkbackpacksize

Func Auto_spell_init()
	_log("Starting Auto_spell_init", $LOG_LEVEL_DEBUG)
	If $nameCharacter = "monk" Then
		Dim $tab_skill_temp = $Monk_skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = False
			$Gestion_affixe = False
			_log("Monk detected, Gest Affix disabled", $LOG_LEVEL_VERBOSE)
		EndIf
	ElseIf $nameCharacter = "barbarian" Then
		Dim $tab_skill_temp = $Barbarian_Skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = False
			$Gestion_affixe = False
			_log("Barbarian detected, Gest Affix disabled", $LOG_LEVEL_VERBOSE)
		EndIf
	ElseIf $nameCharacter = "witchdoctor" Then
		Dim $tab_skill_temp = $WitchDoctor_Skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = True
			$Gestion_affixe = True
			_log("WitchDoctor detected, Gest Affix Enabled", $LOG_LEVEL_VERBOSE)
		EndIf
	ElseIf $nameCharacter = "demonhunter" Then
		Dim $tab_skill_temp = $DemonHunter_skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = True
			$Gestion_affixe = True
			_log("DemonHunter detected, Gest Affix Enabled", $LOG_LEVEL_VERBOSE)
		EndIf
	ElseIf $nameCharacter = "wizard" Then
		Dim $tab_skill_temp = $Wizard_skill_Table
		if $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = True
			$Gestion_affixe = True
			_log("Wizard detected, Gest Affix Enabled", $LOG_LEVEL_VERBOSE)
		EndIf
	ElseIf $nameCharacter = "crusader" Then
		Dim $tab_skill_temp = $Crusader_skill_Table
		If $Gest_affixe_ByClass Then
			$Gestion_affixe_loot = True
			$Gestion_affixe = True
			_log("Crusader detected, Gest Affix Enabled", $LOG_LEVEL_VERBOSE)
			If $List_BanAffix = "" Then
				_log("No ban list, banning sucubbus projectile by default", $LOG_LEVEL_VERBOSE)
				$List_BanAffix = "succubus_bloodStar_projectile"
				LoadTableFromString($Table_BanAffix, $List_BanAffix)
			EndIf
 		EndIf
	Else
		_log("PAS DE CLASS DETECT", $LOG_LEVEL_ERROR)
	EndIf

	For $i = -1 To 4
		For $y = 0 To Ubound($tab_skill_temp) - 1
			If GetActivePlayerSkill($i) = $tab_skill_temp[$y][0] Then
				Switch $i
					Case -1
						$Skill1 = assoc_skill($y, "left", $tab_skill_temp)
						_log("Skill Associed Left Click -> " & $Skill1[1], $LOG_LEVEL_DEBUG)
					Case 0
						$skill2 = assoc_skill($y, "right", $tab_skill_temp)
						_log("Skill Associed Right Click -> " & $Skill2[1], $LOG_LEVEL_DEBUG)
					Case 1
						$skill3 = assoc_skill($y, $Key1, $tab_skill_temp)
						_log("Skill Associed '" & $Key1 & "' Key -> " & $Skill3[1], $LOG_LEVEL_DEBUG)
					Case 2
						$skill4 = assoc_skill($y, $Key2, $tab_skill_temp)
						_log("Skill Associed '" & $Key2 & "' Key -> " & $Skill4[1], $LOG_LEVEL_DEBUG)
					Case 3
						$skill5 = assoc_skill($y, $Key3, $tab_skill_temp)
						_log("Skill Associed '" & $Key3 & "' Key -> " & $Skill5[1], $LOG_LEVEL_DEBUG)
					Case 4
						$skill6 = assoc_skill($y, $Key4, $tab_skill_temp)
						_log("Skill Associed '" & $Key4 & "' Key -> " & $Skill6[1], $LOG_LEVEL_DEBUG)
				EndSwitch
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

Func Detect_UI_error($mode = 0)
	;$mode=0 -> Detection inventory full
	;$mode=1 -> Detection Stash full
	;$mode=2 -> Detection Deny Boss tp
	;$mode=3 -> Detection No item IDentify

	$bucket = 731
	$valuetocheckfor = "Root.TopLayer.error_notify.error_text"
	$Visibility = 1

	If $mode = $MODE_INVENTORY_FULL Then
		If CheckTextvalueUI($bucket, $valuetocheckfor, $Byte_Full_Inventory[0]) Then
			_log("ERROR DETECT -> INVENTORY FULL", $LOG_LEVEL_DEBUG)
			Return True
		Else
			Return False
		EndIf
	ElseIf $mode = $MODE_STASH_FULL Then
		If CheckTextvalueUI($bucket, $valuetocheckfor, $Byte_Full_Stash[0]) Then
			_log("ERROR DETECT -> STACH FULL", $LOG_LEVEL_DEBUG)
			Return True
		Else
			Return False
		EndIf
	ElseIf $mode = $MODE_BOSS_TP_DENIED Then
		If CheckTextvalueUI($bucket, $valuetocheckfor, $Byte_Boss_TpDeny[0]) Then
			_log("ERROR DETECT -> CAN'T TP IN BOSS ROOM", $LOG_LEVEL_DEBUG)
			Return True
		Else
			Return False
		EndIf
	ElseIf $mode = $MODE_NO_IDENTIFIED_ITEM Then
		_log("$Byte_NoItem_Identify[0] : " & $Byte_NoItem_Identify[0])
		If CheckTextvalueUI($bucket, $valuetocheckfor, $Byte_NoItem_Identify[0]) Then
			_log("ERROR DETECT -> NO ITEM IDENTIFY", $LOG_LEVEL_DEBUG)
			Return True
		Else
			Return False
		EndIf
	EndIf

	_log("ERROR DETECT -> NO ERROR DETECT", $LOG_LEVEL_DEBUG)
EndFunc


Func Detect_Str_full_inventory()
	Local $stringread = GetTextUI(731,'Root.TopLayer.error_notify.error_text')
	$stringreference = StringLeft ( $stringread, 15 )
	$stringreferencefromfile = ""
	_log("Stringreference : " & $stringreference, $LOG_LEVEL_DEBUG)

	If FileExists ("lib/extra/langdetect") Then
		_log("Loading string file")
		$Byte_Full_Inventory[0] = FileReadLine("lib/extra/langdetect", 1)
		$Byte_Full_Stash[0] = FileReadLine("lib/extra/langdetect", 2)
		$Byte_Boss_TpDeny[0] = FileReadLine("lib/extra/langdetect", 3)
		$Byte_NoItem_Identify[0] = FileReadLine("lib/extra/langdetect", 4)
		$stringreferencefromfile = FileReadLine("lib/extra/langdetect", 5)
	Endif

	_log("Comparing string : " & $stringreferencefromfile  & " / " & $stringreference )
	If $stringreference = $stringreferencefromfile Then
		_log("Lang loaded detected", $LOG_LEVEL_DEBUG)
		_log("Ui full -> " & $Byte_Full_Inventory[0], $LOG_LEVEL_DEBUG)
		_log("Ui Stash -> " & $Byte_Full_Stash[0], $LOG_LEVEL_DEBUG)
		_log("Ui TP -> " & $Byte_Boss_TpDeny[0], $LOG_LEVEL_DEBUG)
		_log("Ui Id -> " & $Byte_NoItem_Identify[0], $LOG_LEVEL_DEBUG)
	Else
		_log("Game Lang different from langdetect file")
		FileDelete ("lib/extra/langdetect")

		_log("Please Wait, initialising UI language detection", $LOG_LEVEL_VERBOSE)

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

		While (_memoryread($ofs_Full_Inventory, $d3, "byte") = 0)
			$ofs_Full_Inventory += 0x1
		WEnd

		While (_memoryread($ofs_Not_Enough_Room, $d3, "byte") = 0)
			$ofs_Not_Enough_Room += 0x1
		WEnd

		While (_memoryread($ofs_Power_Unusable_During_Boss_Encouter, $d3, "byte") = 0)
			$ofs_Power_Unusable_During_Boss_Encouter += 0x1
		WEnd

		While (_memoryread($ofs_Identify_All_Item, $d3, "byte") = 0)
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

		_log($ofs_Full_Inventory & " -> " & $Byte_Full_Inventory[0], $LOG_LEVEL_DEBUG)
		_log($ofs_Not_Enough_Room & " -> " & $Byte_Full_Stash[0], $LOG_LEVEL_DEBUG)
		_log($ofs_Power_Unusable_During_Boss_Encouter & " -> " & $Byte_Boss_TpDeny[0], $LOG_LEVEL_DEBUG)
		_log($ofs_Identify_All_Item & " -> " & $Byte_NoItem_Identify[0], $LOG_LEVEL_DEBUG)
		FileWrite ("lib/extra/langdetect", $Byte_Full_Inventory[0] & @CRLF & $Byte_Full_Stash[0] & @CRLF & $Byte_Boss_TpDeny[0] & @CRLF & $Byte_NoItem_Identify[0]& @CRLF & $stringreference)
	EndIf
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
    For $i = 0 To stringlen($mask)-1
        $BufferPattern = StringLeft($pattern,2)
        $pattern = StringRight($pattern,StringLen($pattern)-2)
        $BufferMask = StringLeft($mask,1)
        $mask = StringRight($mask,StringLen($mask)-1)
        If $BufferMask = "?" Then $BufferPattern = ".."
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

Func CheckZoneBeforeTP()

	Local $try = 0

	Dim $Item_Affix_Verify = IterateFilterAffixV2()
	If IsArray($Item_Affix_Verify) Then
	   _Log("Affix detecter, on verifie si l'on est trop pres avant de TP", $LOG_LEVEL_DEBUG)

	   Local $CurrentLoc = getcurrentpos()
	   while Not is_zone_safe($CurrentLoc[0], $CurrentLoc[1], $CurrentLoc[2], $Item_Affix_Verify) and $try < 15 ; try < 15 si jamais on bloque dans la map
		  $CurrentLoc = getcurrentpos()
		  Dim $pos = UpdateObjectsPos($Item_Affix_Verify)
		  maffmove($CurrentLoc[0], $CurrentLoc[1], $CurrentLoc[2], $pos[0], $pos[1])
		  Sleep(50)
		  $try += 1
	   WEnd
    Else
	   _Log("La zone est sure, on peut TP", $LOG_LEVEL_DEBUG)
    EndIf

EndFunc ; ==> CheckZoneBeforeTP()

Func _TownPortalnew($mode=0)

	If Not $PartieSolo Then WriteMe($WRITE_ME_TP) ; TChat

	If _playerdead() Then
	   Return False
	EndIf

	Local $compt = 0

	While Not _intown() And _ingame() And Not _checkdisconnect()

		$Execute_TownPortalnew = True

		Local $try = 0
		Local $TPtimer = 0
		Local $compt_while = 0
		Local $Attacktimer = 0

		$compt += 1

		_Log("_TownPortalnew : Tour de boucle IsInTown Mode : " & $mode & " -- tentative de TP " & $compt)

		If $mode <> 0 And $compt > $mode Then
			_Log("_TownPortalnew : Too Much TP try !!!", $LOG_LEVEL_ERROR)
			ExitLoop
		EndIf

		If Detect_UI_error($MODE_INVENTORY_FULL) Then
		   $Inventory_Is_Full = 1
		EndIf

		_Log("_TownPortalnew : Enclenche attack during TownPortalnew")
	    Attack()
		Sleep(100)

		If Not _playerdead() Then

			CheckZoneBeforeTP()

			_Log("_TownPortalnew : on enclenche le TP")
			Sleep(250)
			Send($KeyPortal)
			Sleep(250)

			If ($Choix_Act_Run < 100 And $Choix_Act_Run > -2) AND NOT _intown() And Detect_UI_error($MODE_BOSS_TP_DENIED) Then
				_Log('_TownPortalnew : Detection Asmo room', $LOG_LEVEL_WARNING)
				$Execute_TownPortalnew = False
				Return False
			EndIf

			$Current_area = GetLevelAreaId()

			_Log("_TownPortalnew : enclenchement fastCheckui de la barre de loading")
			While fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068)
			   If $compt_while = 0 Then
				  _Log("_TownPortalnew : enclenchement du timer")
				  $TPtimer = TimerInit()
			   EndIf
			   $compt_while += 1

			   checkforpotion()

			   $Attacktimer = TimerInit()
			   Attack()
			   Sleep(100)
			   TimerDiff($Attacktimer)
			WEnd

			If Not $compt_while And Not _intown() Then ; si pas de detection de la barre de TP
			    $CurrentLoc = getcurrentpos()
				MoveToPos($CurrentLoc[0] + 5, $CurrentLoc[1] + 5, $CurrentLoc[2], 0, 6)
				_Log("_TownPortalnew : On se deplace, pas de detection de la barre de TP")
			Else
			    _Log("_TownPortalnew : compare time to tp -> " & (TimerDiff($TPtimer) - TimerDiff($Attacktimer)) & "> 3700 ") ; valeur test de 3600 a 4000
			EndIf

			If (TimerDiff($TPtimer) - TimerDiff($Attacktimer)) > 3700 And $compt_while > 0 Then
				While Not _intown() And $try < 7
					 _Log("_TownPortalnew : on a peut etre reussi a tp, on reste inerte pendant 6sec voir si on arrive en ville, tentative -> " & $try)
					 $try += 1
					 Sleep(1000)
				WEnd
			EndIf

			Sleep(500)

			If $Current_area <> GetLevelAreaId() Then
				_Log("_TownPortalnew :  Changement d'area, on quite la boucle")
				ExitLoop
			EndIf

		Else
			_Log("_TownPortalnew : Vous etes morts lors d'une tentative de teleport !!!", $LOG_LEVEL_WARNING)
			$Inventory_Is_Full = 0
			$Execute_TownPortalnew = False
			Return False
		EndIf

		Sleep(100)
	WEnd

	If _checkdisconnect() Then
	   _Log("_TownPortalnew : Vous avez ete disconnecter", $LOG_LEVEL_WARNING)
	   $Inventory_Is_Full = 0
	   $Execute_TownPortalnew = False
	   Return False
	EndIf

	Local $hTimer = TimerInit()
	While Not offsetlist() And TimerDiff($hTimer) < 30000 ; 30secondes
		Sleep(40)
	WEnd

	If TimerDiff($hTimer) >= 30000 Then
		_Log('_TownPortalnew : Fail to use offselList', $LOG_LEVEL_ERROR)
		$Inventory_Is_Full = 0
		$Execute_TownPortalnew = False
		Return False
	EndIf

	If _intown() Then
	   $PortBack = True
	EndIf

	_Log("_TownPortalnew : On a renvoyer true, quite bien la fonction")

	$Inventory_Is_Full = 0
	$Execute_TownPortalnew = False
	Return True
EndFunc   ;==>_TownPortalnew


Func GetMaxResource($idAttrib, $classe)
	Switch $classe
		Case "monk"
			$source = 0x3000
			$MaximumSpirit=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
			_log("Ressource Maximum : " & $MaximumSpirit, $LOG_LEVEL_VERBOSE)
		Case "barbarian"
			$source = 0x2000
			$MaximumFury=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
			_log("Ressource Maximum : " & $MaximumFury, $LOG_LEVEL_VERBOSE)
		Case "wizard"
			$source = 0x1000
			$MaximumArcane=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
			_log("Ressource Maximum : " & $MaximumArcane, $LOG_LEVEL_VERBOSE)
		Case "witchdoctor"
			$source = 0
			$MaximumMana=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
			_log("Ressource Maximum : " & $MaximumMana, $LOG_LEVEL_VERBOSE)
		Case "demonhunter"
			$source = 0x5000
			$MaximumHatred=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
			$source = 0x6000
			$MaximumDiscipline=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
			_log("Ressource Maximum : " & $MaximumHatred, $LOG_LEVEL_VERBOSE)
			_log("Ressource Maximum : " & $MaximumDiscipline, $LOG_LEVEL_VERBOSE)
		Case "crusader"
			$source = 0x7000
			$MaximumWrath=_memoryread(GetAttributeOfs($idAttrib, BitOR($Atrib_Resource_Max_Total[0], $source)), $d3, "float")
			_log("Ressource Maximum : " & $MaximumWrath, $LOG_LEVEL_VERBOSE)
	EndSwitch
EndFunc ;==>GetMaxResource

Func Take_BookOfCain()

	Send($KeyCloseWindows)
	sleep(200)
	Send($KeyCloseWindows)
	sleep(50)

	MoveTo($MOVETO_BOOKOFCAIN)

	InteractByActorName("All_Book_Of_Cain")

	While Not fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068) And Not Detect_UI_error($MODE_NO_IDENTIFIED_ITEM)
		_log("Tour boucle : Take_BookOfCain")
		If Not fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068) Then
			If Not _checkdisconnect() Then
				InteractByActorName("All_Book_Of_Cain")
			Else
				_Log("Failed to open Book Of Cain", $LOG_LEVEL_ERROR)
				$FailOpen_BookOfCain = 1
				Return False
			EndIf
		EndIf
	WEnd
	While fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068)
		sleep(50)
	Wend

	MoveTo($MOVETO_BOOKOFCAIN)
EndFunc

Func MoveTo($BeforeInteract) ; placer notre perso au point voulu dans chaque act avant d'interagir
    GetAct()

	If _checkInventoryopen() Then
		Send($KeyInventory)
		Sleep(150)
	EndIf

	Switch $BeforeInteract
		Case $MOVETO_SMITH ; Smith
			Switch $Act
			    Case 1
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(2965.33325195313, 2822.7978515625, 24.0453224182129, 0, 60)
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(387.610260009766, 537.2958984375, 24.0453281402588, 0, 60)
					EndSwitch
				Case 2 To 4
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 ;do nothing act 2, 3 and 4
						 Case $PLAYING_MODE_ADVENTURE
							 ;do nothing act 2, 3 and 4
					EndSwitch
				Case 5
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(578.169067382813, 503.704925537109, 2.62076425552368, 0, 60)
							 Sleep(Random(100, 200))
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(578.169067382813, 503.704925537109, 2.62076425552368, 0, 60)
							 Sleep(Random(100, 200))
					EndSwitch
			EndSwitch
		Case $MOVETO_POTION_VENDOR ; Potion_Vendor
			Switch $Act
				Case 1
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(3013.36865234375, 2797.88452148438, 24.0453281402588, 0, 60)
							 Sleep(300)
							 MoveToPos(3013.36865234375, 2797.88452148438, 24.0453281402588, 0, 60)
							 Sleep(300)
							 MoveToPos(3013.36865234375, 2797.88452148438, 24.0453281402588, 0, 60)
							 Sleep(300)
							 MoveToPos(3013.36865234375, 2797.88452148438, 24.0453281402588, 0, 60)
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(441.150238037109, 515.829345703125, 24.0453224182129, 0, 60)
							 Sleep(300)
							 MoveToPos(441.150238037109, 515.829345703125, 24.0453224182129, 0, 60)
							 Sleep(300)
							 MoveToPos(441.150238037109, 515.829345703125, 24.0453224182129, 0, 60)
							 Sleep(300)
							 MoveToPos(441.150238037109, 515.829345703125, 24.0453224182129, 0, 60)
					EndSwitch
				Case 2 to 5
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 ;do nothing act 2, 3, 4 and 5
						 Case $PLAYING_MODE_ADVENTURE
							 ;do nothing act 2, 3, 4 and 5
					EndSwitch
			EndSwitch
		Case $MOVETO_REPAIR_VENDOR
			Switch $Act
				 Case 1
	                Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(2914.19946289063, 2802.09716796875, 24.0453300476074, 0, 60)
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(320.372528076172, 522.431640625, 24.0453319549561, 0, 60)
					EndSwitch
				 Case 2 To 5
	                Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 ;do nothing act 2, 3, 4 and 5
						 Case $PLAYING_MODE_ADVENTURE
							 ;do nothing act 2, 3, 4 and 5
					EndSwitch
	        EndSwitch
	    Case $MOVETO_BOOKOFCAIN
	    	Switch $Act
				 Case 1
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(2955.8681640625, 2803.51489257813, 24.0453319549561, 0, 60)
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(372.583282470703, 520.788818359375, 24.0453300476074, 0, 60)
					EndSwitch
				 Case 2
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 ;do nothing act 2
						 Case $PLAYING_MODE_ADVENTURE
							 ;do nothing act 2
					EndSwitch
				 Case 3 To 4
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(395.930847167969, 390.577362060547, 0.408410131931305, 0, 60)
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(395.930847167969, 390.577362060547, 0.408410131931305, 0, 60)
				    EndSwitch
				 Case 5
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(498.356781005859, 528.380126953125, 2.66207718849182, 0, 60)
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(498.356781005859, 528.380126953125, 2.66207718849182, 0, 60)
				    EndSwitch
			EndSwitch
	    Case $MOVETO_PORTAL
	    	Switch $Act
				 Case 1 ; act 1
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(2922.02783203125, 2791.189453125, 24.0453262329102, 0, 60)
							 MoveToPos(2945.61547851563, 2800.7109375, 24.0453319549561, 0, 60)
							 MoveToPos(2973.68774414063, 2800.90869140625, 24.0453262329102, 0, 60)
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(354.920471191406, 524.129821777344, 24.0453243255615, 0, 60)
							 MoveToPos(367.810638427734, 525.292724609375, 24.0453281402588, 0, 60)
							 MoveToPos(387.610260009766, 537.2958984375, 24.0453281402588, 0, 60)
				    EndSwitch
				 Case 2 ; act 2
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 ;mtp a definir
						 Case $PLAYING_MODE_ADVENTURE
							 ;mtp a definir
					EndSwitch
				 Case 3 To 4; act 3-4
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 MoveToPos(427.152893066406, 345.048858642578, 0.10000141710043, 0, 60)
							 MoveToPos(400.490386962891, 380.362884521484, 0.332595944404602, 0, 60)
							 MoveToPos(390.630401611328, 399.380554199219, 0.55376011133194, 0, 60)
						 Case $PLAYING_MODE_ADVENTURE
							 MoveToPos(427.152893066406, 345.048858642578, 0.10000141710043, 0, 60)
							 MoveToPos(400.490386962891, 380.362884521484, 0.332595944404602, 0, 60)
							 MoveToPos(390.630401611328, 399.380554199219, 0.55376011133194, 0, 60)
					EndSwitch
				Case 5 ; act 5
					Switch $ModePlaying
						 Case $PLAYING_MODE_STORY
							 ;mtp a definir
						 Case $PLAYING_MODE_ADVENTURE
							 ;mtp a definir
					EndSwitch
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

	If $NbPotionBuy > 0 Then ; NbPotionBuy = 0 on déactive la fonction

    	Local $potinstock = Number(GetTextUI(221,'Root.NormalLayer.game_dialog_backgroundScreenPC.game_potion.text')) ; récupéré les potions en stock
		Local $ClickPotion = Round($NbPotionBuy / 5) ; nombre de clic

		If $potinstock <= ($PotionStock + 10) Then

		  MoveTo($MOVETO_POTION_VENDOR) ; on se positionne

		  InteractByActorName($PotionVendor)
		  Sleep(700)

		  Local $vendortry = 0
		  While _checkVendoropen() = False ; si la fenêtre n'y est pas
			   If $vendortry <= 4 Then ; on essaye 5 fois
				  _Log('Fail to open vendor', $LOG_LEVEL_WARNING)
				  $vendortry += 1
				  InteractByActorName($PotionVendor)
			   Else
				  _Log('Failed to open Vendor after 4 try', $LOG_LEVEL_ERROR)
				  MoveTo($MOVETO_POTION_VENDOR) ; on se repositionne
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

		  MoveTo($MOVETO_POTION_VENDOR) ; on se repositionne
	   Else
		  _Log('Vous avez assez potion')
	   EndIf
    Else
	   _Log('Fonction BuyPotion désactivée')
    EndIf

EndFunc    ;==>BuyPotion

Func VerifAct($num)
	$CurrentAct = GetNumActByWPUI()
	$ActRequired = GetNumActByWPNumber($num)

	If $CurrentAct = $ActRequired Then
		Return True
	Else
		SwitchAct($ActRequired)
	EndIf
EndFunc

Func SwitchAct($num)
	Switch $num
		Case 1
			$bucket = 725
		Case 2
			$bucket = 407
		Case 3
			$bucket = 844
		Case 4
			$bucket = 817
		Case 5
			$bucket = 1713
	EndSwitch
	ClickUI("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.Zoom.ZoomOut", 942)
	Sleep(500)
	ClickUI("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.WorldMap.Act" & $num & "Open.LayoutRoot.Name", $bucket)
	Sleep(500)
EndFunc

Func GetNumActByWPUI()
	If fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 0.LayoutRoot.Interest", 1, 1363) Then
		_log("Act1 Detected")
		Return 1
	ElseIf fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 18.LayoutRoot.Interest", 1, 1472) Then
		_log("Act2 Detected")
		Return 2
	ElseIf fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 26.LayoutRoot.Interest", 1, 421) Then
		_log("Act3 Detected")
		Return 3
	ElseIf fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 39.LayoutRoot.Interest", 1, 565) Then
		_log("Act4 Detected")
		Return 4
	ElseIf fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 46.LayoutRoot.Interest", 1, 1113) Then
		_log("Act5 Detected")
		Return 5
	EndIf
EndFunc

Func GetNumActByWPNumber($num)
	if $num <= 17 Then
		_log("Act1 Required")
		Return 1
	ElseIf $num <= 25 Then
		_log("Act2 Required")
		Return 2
	ElseIf $num <= 38 Then
		_log("Act3 Required")
		Return 3
	ElseIf $num <= 45 Then
		_log("Act4 Required")
		Return 4
	Else
		_log("Act5 Required")
		Return 5
	EndIf
EndFunc

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

Func GameState()
	; 1 // In Game
	; 0 // Loading Screen
	; 5 // Menu
	return _memoryRead(_memoryRead($ofs_objectmanager ,$d3, "ptr") + 0x8f0, $d3, "ptr") ; 2.0.3 : 0x900
Endfunc

Func BanActor($actor)
	$Table_BannedActors[0] += 1
	ReDim $Table_BannedActors[$Table_BannedActors[0] + 1]
	$Table_BannedActors[$Table_BannedActors[0]] = $actor
EndFunc

Func IsBannedActor($actor)
	For $i = 1 To $Table_BannedActors[0]
		If $Table_BannedActors[$i] = $actor Then
			return True
		EndIf
	Next
	Return False
EndFunc

Func LoadTableFromString(ByRef $Table, ByRef $string, $cleanup = True)
	$Table = StringSplit($string, "|")
	If $cleanup Then
		$string = ""
	EndIf
EndFunc

Func AddItemToTable(ByRef $table, $item)
	$table[0] += 1
	ReDim $table[$table[0] + 1]
	$table[$table[0]] = $item
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

Func GetLocalPlayer()
	;Global $ObjManStorage = 0x7CC ;0x794
	$v0 = _MemoryRead(_MemoryRead($ofs_objectmanager, $d3, 'int') + 0x994, $d3, 'int') ; 2.0.3 : 0x9a4 ;0x94C/934
	$v1 = _MemoryRead(_MemoryRead($ofs_objectmanager, $d3, 'int') + 0x87c, $d3, 'int') ; 2.0.3 : 0x88c

	If $v0 <> 0 And _MemoryRead($v0, $d3, 'int') <> -1 And $v1 <> 0 Then
		Return 0xD138 * _MemoryRead($v0, $d3, 'int') + $v1 + 0x58
	Else
		Return 0
	EndIf
EndFunc

Func GetActivePlayerSkill($index)
	$Local_player = GetLocalPlayer()
	If $local_player <> 0 Then
		Return _MemoryRead($local_player + (0xBC + $index * 0x10), $d3, 'int')
	Else
		Return 0
	EndIf
EndFunc