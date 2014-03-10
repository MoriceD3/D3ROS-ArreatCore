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



$_debug = 1
$Admin = IsAdmin()
If $Admin <> 1 Then
	MsgBox(0x30, "ERROR", "This program require administrative rights you fool!")
	Exit
EndIf

Global $hDll = DllOpen("ntdll.dll")

Func _HighPrecisionSleep($iMicroSeconds)
	Local $hStruct
	$hStruct = DllStructCreate("int64 time;")
	DllStructSetData($hStruct, "time", -1 * ($iMicroSeconds * 10))
	DllCall($hDll, "dword", "ZwDelayExecution", "int", 0, "ptr", DllStructGetPtr($hStruct))
EndFunc   ;==>_HighPrecisionSleep

;;--------------------------------------------------------------------------------
;;      Includes
;;--------------------------------------------------------------------------------
#include "lib\NomadMemory.au3" ;THIS IS EXTERNAL, GET IT AT THE AUTOIT WEBSITE
#include <math.au3>
#include <String.au3>
#include <Array.au3>
#include "lib\constants.au3"
#include "lib\FTP.au3"
#include "lib\ExpTableConst.au3"

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
	Global $sized3 = WinGetClientSize("[CLASS:D3 Main Window Class]")
	If $sized3[0] <> 800 Or $sized3[1] <> 600 Then
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
		MsgBox(0, Default, "Erreur Dimension : Il faut être en 800 x 600 et non pas en " & $sized3[0] & " x " & $sized3[1] & ".")
		Terminate()
	Else
		_log("Setting Window Diablo III OK")
	EndIf
EndFunc   ;==>CheckWindowD3

Func CheckWindowD3Size()
	Global $sized3 = WinGetClientSize("[CLASS:D3 Main Window Class]")
	If $sized3[0] <> 800 Or $sized3[1] <> 600 Then
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
		MsgBox(0, Default, "Erreur Dimension : Il faut être en 800 x 600 et non pas en " & $sized3[0] & " x " & $sized3[1] & ".")
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

mesurestart()
	Local $index, $offset, $count, $item[10], $find = 0
	startIterateObjectsList($index, $offset, $count)
	_log("FinActor -> number -> " & $count)
	While iterateObjectsList($index, $offset, $count, $item)
		If StringInStr($item[1], $name) And $item[9] < $maxRange Then
			$find = 1
			mesureEnd("FindActor trouver")
			Return 1
		EndIf
	WEnd

	Return 0
EndFunc   ;==>FindActor


Global $Ofs_UI_A = 0x994
Global $Ofs_UI_B = 0x0
Global $Ofs_UI_C = 0x10
Global $Ofs_UI_D = 0x0

Global $Ofs_UI_nPtr = 0x10
Global $Ofs_UI_Visible = 0x24
Global $Ofs_UI_Name = 0x38
Global $Ofs_UI_Text = 0xa58


Func ListUi($Visible=0)
	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")

	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")
	$UiCount = _memoryread($UiPtr3 + $Ofs_UI_D, $d3, "int")

	;_log("Ui Count -> " & $UiCount)

	for $g=0 to $UiCount - 1
		$UiPtr = _memoryread($BuckitOfs, $d3, "ptr")
		while $UiPtr <> 0
			$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
			$IsVisible =  BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)
			;$IsVisible = _memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr")

			if $IsVisible = 4 OR $Visible = 0 Then
				$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
				ConsoleWrite(@CRLF & "Buckit N° " & $g & " (" & $IsVisible  & ") -> " & $Name )
			EndIf

			$UiPtr = _memoryread($UiPtr, $d3, "ptr")
		WEnd
		$BuckitOfs = $BuckitOfs + 0x4


	Next

EndFunc

Func ClickUI($name, $bucket=-1)

	if $bucket = -1 Then ;no bucket given slow method
		$result = GetOfsUI($name, 1)
	Else ;bucket given, fast method
		$result = GetOfsFastUI($name, $bucket)
	EndIf


	if $result = false Then
		_log("(ClickUI) UI DOESNT EXIT ! -> " & $name)
		return false
	EndIf

	Dim $Point = GetPositionUI($result)

	while $Point[0] = 0 AND $Point[1] = 0
		$Point = GetPositionUI($result)
		sleep(500)
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

	$playerdeadlookfor = "Root.NormalLayer.deathmenu_dialog"
	$return = fastcheckuiitemvisible($playerdeadlookfor, 1, 793)
	If ($return And $DeathCountToggle) Then
		$Death += 1
		$Die2FastCount += 1
		$DeathCountToggle = False
	EndIf
	Return $return
EndFunc   ;==>_playerdead OK

Func _inmenu()
	$lobbylookfor = "Root.NormalLayer.BattleNetCampaign_main.LayoutRoot.Menu.PlayGameButton"
	Return fastcheckuiitemvisible($lobbylookfor, 1, 1929)
EndFunc   ;==>_inmenu OK

Func _checkdisconnect()
    $disclookfor = "Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Buttons.ButtonList"
    Return fastcheckuiitemvisible($disclookfor, 1, 2022)
EndFunc   ;==>_checkdisconnect OK

Func _checkRepair()
	$replookfor = "Root.NormalLayer.DurabilityIndicator"
	Return fastcheckuiitemvisible($replookfor, 1, 895)
EndFunc   ;==>_checkRepair OK

Func _onloginscreen()
	$loginlookfor = "Root.NormalLayer.BattleNetLogin_main.LayoutRoot.LoginContainer.unnamed30"
	Return fastcheckuiitemvisible($loginlookfor, 1, 51)
EndFunc   ;==>_onloginscreen OK

Func _escmenu()
	$escmenuelookfor = "Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame"
	Return fastcheckuiitemvisible($escmenuelookfor, 1, 1644)
EndFunc   ;==>_escmenu OK

Func _ingame()
	$gamelookfor = "Root.NormalLayer.minimap_dialog_backgroundScreen.minimap_dialog_pve"
	Return fastcheckuiitemvisible($gamelookfor, 1, 1403)
EndFunc   ;==>_ingame OK

Func _checkWPopen()
    $checkWPopenlookfor = "Root.NormalLayer.WaypointMap_main.LayoutRoot"
    Return fastcheckuiitemvisible($checkWPopenlookfor, 1, 2033)
EndFunc   ;==>_checkWPopen OK

Func _checkVendoropen()
	$checkVendorOpenlookfor = "Root.NormalLayer.shop_dialog_mainPage.gold_label"
	Return fastcheckuiitemvisible($checkVendorOpenlookfor, 1, 165)
EndFunc   ;==>_checkVendoropen OK

Func _checkStashopen()
	$_checkStashopenlookfor = "Root.NormalLayer.stash_dialog_mainPage"
	Return fastcheckuiitemvisible($_checkStashopenlookfor, 1, 327)
EndFunc   ;==>_checkStashopen OK

Func _checkInventoryopen()
	$_checkInventoryopenlookfor = "Root.NormalLayer.inventory_dialog_mainPage"
	Return fastcheckuiitemvisible($_checkInventoryopenlookfor, 1, 1813)
EndFunc   ;==>_checkInventoryopen OK


;;--------------------------------------------------------------------------------
; Function:			IsInArea($area)
; Description:		Check where we are
;
;;--------------------------------------------------------------------------------
Func IsInArea($area)
	$area = GetLevelAreaId()
	ConsoleWrite("Area " & $area & @CRLF)
	Return $area = GetLevelAreaId()
EndFunc   ;==>IsInArea

Func GetLevelAreaId()
        Return _MemoryRead(_MemoryRead($OfsLevelAreaId, $d3, "int") + 0x44, $d3, "int")
EndFunc   ;==>GetLevelAreaId

Func LevelAreaConstants()
	Global $A1_C6_SpiderCave_01_Entrance = 0xE3A6
	Global $A1_C6_SpiderCave_01_Main = 0x132EC
	Global $A1_C6_SpiderCave_01_Queen = 0xF506
	Global $A1_Dun_Crypt_Dev_Hell = 0x36581
	Global $A1_Fields_Cave_SwordOfJustice_Level01 = 0x1D455
	Global $A1_Fields_Den = 0x21045
	Global $A1_Fields_Den_Level02 = 0x2F6b8
	Global $A1_Fields_RandomDRLG_CaveA_Level01 = 0x141C4
	Global $A1_Fields_RandomDRLG_CaveA_Level02 = 0x141C5
	Global $A1_Fields_RandomDRLG_ScavengerDenA_Level01 = 0x13D0D
	Global $A1_Fields_RandomDRLG_ScavengerDenA_Level02 = 0x13D17
	Global $A1_Fields_Vendor_Tinker_Exterior = 0x2bC0C
	Global $A1_Highlands_RandomDRLG_GoatmanCaveA_Level01 = 0x14286
	Global $A1_Highlands_RandomDRLG_GoatmanCaveA_Level02 = 0x14287
	Global $A1_Highlands_RandomDRLG_WestTower_Level01 = 0x14196
	Global $A1_Highlands_RandomDRLG_WestTower_Level02 = 0x14197
	Global $A1_Random_Level01 = 0x33A17
	Global $A1_trDun_Blacksmith_Cellar = 0x144A6
	Global $A1_trDun_ButchersLair_02 = 0x16301
	Global $A1_trDun_Cain_Intro = 0xED2A
	Global $A1_trDun_Cave_Highlands_Random01_VendorRescue = 0x21310
	Global $A1_trdun_Cave_Nephalem_01 = 0xEBEC
	Global $A1_trdun_Cave_Nephalem_02 = 0xEBED
	Global $A1_trdun_Cave_Nephalem_03 = 0xEBEE
	Global $A1_trDun_Cave_Old_Ruins_Random01 = 0x278AC
	Global $A1_trDun_CrownRoom = 0x18FDA
	Global $A1_trDun_Crypt_Event_Tower_Of_Power = 0x138F4
	Global $A1_trDun_Crypt_Flooded_Memories_Level01 = 0x18F9c
	Global $A1_trDun_Crypt_Flooded_Memories_Level02 = 0x287A6
	Global $A1_trdun_Crypt_Special_00 = 0x25BDC
	Global $A1_trdun_Crypt_Special_01 = 0xECB9
	Global $A1_trDun_Event_JarOfSouls = 0x2371E
	Global $A1_trDun_FalseSecretPassage_01 = 0x14540
	Global $A1_trDun_FalseSecretPassage_02 = 0x14541
	Global $A1_trDun_FalseSecretPassage_03 = 0x14542
	Global $A1_trDun_Jail_Level01 = 0x171d0
	Global $A1_trDun_Jail_Level01_Cells = 0x1783D
	Global $A1_trDun_Leoric01 = 0x4D3E
	Global $A1_trDun_Leoric02 = 0x4D3F
	Global $A1_trDun_Leoric03 = 0x4D40
	Global $A1_trDun_Level01 = 0x4D44
	Global $A1_trDun_Level04 = 0x4D47
	Global $A1_trDun_Level05_Templar = 0x15763
	Global $A1_trDun_Level06 = 0x4D49
	Global $A1_trDun_Level07B = 0x4D4B
	Global $A1_trDun_Level07D = 0x4D4D
	Global $A1_trDun_Tyrael_Level09 = 0x1CAA3
	Global $A1_trDun_TyraelJail = 0x24447
	Global $A1_trOut_AdriasCellar = 0xF5F8
	Global $A1_trOUT_AdriasHut = 0x4DD9
	Global $A1_trOut_BatesFarmCellar = 0x248A5
	Global $A1_trOUT_Church = 0x4DDD
	Global $A1_trOut_Fields_Vendor_Curios = 0x1A3B7
	Global $A1_trOut_Fields_Vendor_Curios_Exterior = 0x2BE7B
	Global $A1_trOUT_FishingVillage = 0x4DDF
	Global $A1_trOUT_FishingVillageHeights = 0x1FB03
	Global $A1_trOut_ForlornFarm = 0x20B72
	Global $A1_trOUT_Graveyard = 0x4DE2
	Global $A1_trOUT_Highlands = 0x4DE4
	Global $A1_trOUT_Highlands_Bridge = 0x16DC0
	Global $A1_trOut_Highlands_DunExterior_A = 0x15718
	Global $A1_trOUT_Highlands_ServantHouse_Cellar_Vendor = 0x29CD1
	Global $A1_trOUT_Highlands_Sub240_GoatmanGraveyard = 0x1F95F
	Global $A1_trOUT_Highlands2 = 0x4DE5
	Global $A1_trOUT_Highlands3 = 0x4AF
	Global $A1_trOut_Leoric_Manor_Int = 0x189F6
	Global $A1_trOUT_LeoricsManor = 0x4DE7
	Global $A1_trOut_MysticWagon = 0x20F08
	Global $A1_trOUT_NewTristram = 0x4DEB
	Global $A1_trOUT_NewTristram_AttackArea = 0x316CE
	Global $A1_trOUT_NewTristramOverlook = 0x26186
	Global $A1_trOut_Old_Tristram = 0x163FD
	Global $A1_trOut_Old_Tristram_Road = 0x164BC
	Global $A1_trOut_Old_Tristram_Road_Cath = 0x18BE7
	Global $A1_trOut_OldTristram_Cellar = 0x1A22B
	Global $A1_trOut_OldTristram_Cellar_1 = 0x1A104
	Global $A1_trOut_OldTristram_Cellar_2 = 0x1A105
	Global $A1_trOut_OldTristram_Cellar_3 = 0x19322
	Global $A1_trOut_oldTristram_TreeCave = 0x19C87
	Global $A1_trOut_Scoundrel_Event_Old_Mill_2 = 0x35556
	Global $A1_trOut_TownAttack_ChapelCellar = 0x1D43E
	Global $A1_trOut_Tristram_CainsHouse = 0x1FC73
	Global $A1_trOut_Tristram_Inn = 0x1AB91
	Global $A1_trOut_Tristram_LeahsRoom = 0x15349
	Global $A1_trOut_TristramFields_A = 0x4DF0
	Global $A1_trOut_TristramFields_B = 0x4DF1
	Global $A1_trOut_TristramFields_ExitA = 0xF085
	Global $A1_trOut_TristramFields_Forsaken_Grounds = 0x2BD6F
	Global $A1_trOut_TristramFields_Secluded_Grove = 0x2BD6E
	Global $A1_trOut_TristramWilderness = 0x4DF2
	Global $A1_trOut_TristramWilderness_SubScenes = 0x236AA
	Global $A1_trOut_Vendor_Tinker_Room = 0x19821
	Global $A1_trOut_Wilderness_BurialGrounds = 0x11C08
	Global $A1_trOut_Wilderness_CorpseHouse = 0x30ADF
	Global $A1_trOut_Wilderness_Sub80_FamilyTree = 0x236A1
	Global $A2_Belial_Room_01 = 0xED55
	Global $A2_Belial_Room_Intro = 0x13D1A
	Global $A2_c1Dun_Swr_Caldeum_01 = 0x4D4F
	Global $A2_c2dun_Zolt_TreasureHunter = 0x4D53
	Global $A2_c3Dun_Aqd_Oasis_Level01 = 0xE069
	Global $A2_cadun_Zolt_Timed01_Level01 = 0x4D52
	Global $A2_cadun_Zolt_Timed01_Level02 = 0x29108
	Global $A2_Caldeum = 0x19234
	Global $A2_Caldeum_Uprising = 0x33613
	Global $A2_caOut_Alcarnus_RandomCellar_1 = 0x245A7
	Global $A2_caOut_Alcarnus_RandomCellar_2 = 0x245A8
	Global $A2_caOut_Alcarnus_RandomCellar_3 = 0x245A9
	Global $A2_caOUT_Boneyard_01 = 0xD24A
	Global $A2_caOUT_Borderlands_Khamsin_Mine = 0xEE8A
	Global $A2_caOUT_BorderlandsKhamsin = 0xF8B2
	Global $A2_caOut_Cellar_Alcarnus_Main = 0x2FAC4
	Global $A2_caOut_CT_RefugeeCamp = 0xD811
	Global $A2_caOut_CT_RefugeeCamp_Gates = 0x318FD
	Global $A2_caOut_CT_RefugeeCamp_Hub = 0x2917A
	Global $A2_caOut_Hub_Inn = 0x2AA00
	Global $A2_caOut_Interior_C_DogBite = 0x2D7BB
	Global $A2_caOut_Interior_H_RockWorm = 0x232F5
	Global $A2_caOut_Mine_Abandoned_Cellar = 0x4D81
	Global $A2_caOut_Oasis = 0xE051
	Global $A2_caOut_Oasis_Exit = 0x2ACE2
	Global $A2_caOut_Oasis_Exit_A = 0x2AD07
	Global $A2_caOut_Oasis_Rakanishu = 0x33BDD
	Global $A2_caOut_Oasis_RandomCellar_1 = 0x27099
	Global $A2_caOut_Oasis_RandomCellar_2 = 0x2709A
	Global $A2_caOut_Oasis_RandomCellar_3 = 0x2709B
	Global $A2_caOut_Oasis_RandomCellar_4 = 0x27bE7
	Global $A2_caOut_Oasis1_Water = 0xE664
	Global $A2_caOut_Oasis2 = 0xE058
	Global $A2_caOut_OasisCellars = 0x1B100
	Global $A2_caOUT_StingingWinds = 0x4D7F
	Global $A2_caOUT_StingingWinds_Alcarnus_Tier1 = 0x4D71
	Global $A2_caOUT_StingingWinds_Alcarnus_Tier2 = 0x4D72
	Global $A2_caOUT_StingingWinds_Bridge = 0x29886
	Global $A2_caOUT_StingingWinds_Canyon = 0x4D7C
	Global $A2_caOUT_StingingWinds_FallenCamp01 = 0x288EF
	Global $A2_caOUT_StingingWinds_PostBridge = 0x4D7E
	Global $A2_caOUT_StingingWinds_PreAlcarnus = 0x4D7B
	Global $A2_caOUT_StingingWinds_PreBridge = 0x4D7D
	Global $A2_caOut_Stranded2 = 0x1DA4A
	Global $A2_caOut_ZakarwaMerchantCellar = 0x1BEBB
	Global $A2_Cave_Random01 = 0x26F64
	Global $A2_Cave_Random01_Level02 = 0x35E85
	Global $A2_CultistCellarEast = 0x19218
	Global $A2_CultistCellarWest = 0x19214
	Global $A2_dun_Aqd_Control_A = 0xF9F3
	Global $A2_dun_Aqd_Control_B = 0xF9F4
	Global $A2_dun_Aqd_Oasis_RandomFacePuzzle_Large = 0x26B82
	Global $A2_dun_Aqd_Oasis_RandomFacePuzzle_Small = 0x26AB0
	Global $A2_dun_Aqd_Special_01 = 0xF520
	Global $A2_dun_Aqd_Special_A = 0xF53A
	Global $A2_dun_Aqd_Special_B = 0xF53C
	Global $A2_Dun_Aqd_Swr_to_Oasis_Level01 = 0x23D96
	Global $A2_dun_Cave_BloodVial_01 = 0x31F55
	Global $A2_dun_Cave_BloodVial_02 = 0x31F83
	Global $A2_dun_Oasis_Cave_MapDungeon = 0x29616
	Global $A2_dun_Oasis_Cave_MapDungeon_Level02 = 0x2F6bF
	Global $A2_dun_PortalRoulette_A = 0x1B37F
	Global $A2_Dun_Swr_Adria_Level01 = 0xE47E
	Global $A2_Dun_Swr_Caldeum_Sewers_01 = 0x1B205
	Global $A2_dun_Zolt_Blood02_Level01_Part1 = 0x1E12E
	Global $A2_dun_Zolt_Blood02_Level01_Part2 = 0x25872
	Global $A2_Dun_Zolt_BossFight_Level04 = 0xEB22
	Global $A2_dun_Zolt_Head_Random01 = 0xF0C0
	Global $A2_Dun_Zolt_Level01 = 0x4D55
	Global $A2_Dun_Zolt_Level02 = 0x4D56
	Global $A2_Dun_Zolt_Level03 = 0x4D57
	Global $A2_Dun_Zolt_Lobby = 0x4D58
	Global $A2_Dun_Zolt_LobbyCenter = 0x2AFBA
	Global $A2_Dun_Zolt_Random_Level01 = 0x4D59
	Global $A2_Dun_Zolt_Random_Level02 = 0x36571
	Global $A2_dun_Zolt_Random_PortalRoulette_02 = 0x2FDCF
	Global $A2_Dun_Zolt_ShadowRealm_Level01 = 0x13AD0
	Global $A2_Event_DyingManMine = 0x2270B
	Global $A2_Event_PriceOfMercy_Cellar = 0x2FD9E
	Global $A2_Rockworm_Cellar_Cave = 0x2FE81
	Global $A2_trDun_Boneyard_Spider_Cave_01 = 0x1B437
	Global $A2_trDun_Boneyard_Spider_Cave_02 = 0x35758
	Global $A2_trDun_Boneyard_Worm_Cave_01 = 0x1B433
	Global $A2_trDun_Boneyard_Worm_Cave_02 = 0x35759
	Global $A2_trDun_Cave_Oasis_Random01 = 0xF46F
	Global $A2_trDun_Cave_Oasis_Random01_Level02 = 0x2F6C2
	Global $A2_trDun_Cave_Oasis_Random02 = 0xF46E
	Global $A2_trDun_Cave_Oasis_Random02_Level02 = 0x27551
	Global $A2_dun_Aqd_Oasis_Level00 = 0x2F0B6
	Global $A2_dun_Aqd_Oasis_Level01 = 0x2F0B1
	Global $A3_AzmodanFight = 0x1B39C
	Global $A3_Battlefield_A = 0x1B7A4
	Global $A3_Battlefield_B = 0x1B7B5
	Global $A3_Battlefield_C = 0x1B7C4
	Global $A3_Bridge_01 = 0x10F80
	Global $A3_Bridge_Choke_A = 0x25DA8
	Global $A3_Dun_Battlefield_Gate = 0x25C14
	Global $A3_dun_Bridge_Interior_Random01 = 0x224ad
	Global $A3_dun_Bridge_Interior_Random02 = 0x32270
	Global $A3_Dun_Crater_Level_01 = 0x15040
	Global $A3_Dun_Crater_Level_02 = 0x1d209
	Global $A3_Dun_Crater_Level_03 = 0x1d20a
	Global $A3_dun_Crater_ST_Level01 = 0x13b97
	Global $A3_dun_Crater_ST_Level01B = 0x1d365
	Global $A3_dun_Crater_ST_Level02 = 0x13b98
	Global $A3_dun_Crater_ST_Level02B = 0x2200a
	Global $A3_dun_Crater_ST_Level04 = 0x14cd2
	Global $A3_dun_Crater_ST_Level04B = 0x1d368
	Global $A3_dun_IceCaves_Random_01 = 0x2e3a1
	Global $A3_dun_IceCaves_Random_01_Level_02 = 0x36206
	Global $A3_dun_IceCaves_Timed_01 = 0x2ea66
	Global $A3_dun_IceCaves_Timed_01_Level_02 = 0x36207
	Global $A3_Dun_Keep_Hub = 0x16b11
	Global $A3_Dun_Keep_Hub_Inn = 0x2d38c
	Global $A3_Dun_Keep_Level03 = 0x126ac
	Global $A3_Dun_Keep_Level04 = 0x16baf
	Global $A3_Dun_Keep_Level05 = 0x21500
	Global $A3_Dun_Keep_Random_01 = 0x2aa4a
	Global $A3_Dun_Keep_Random_01_Level_02 = 0x36238
	Global $A3_Dun_Keep_Random_02 = 0x2c7f2
	Global $A3_Dun_Keep_Random_02_Level_02 = 0x36239
	Global $A3_Dun_Keep_Random_03 = 0x2c802
	Global $A3_Dun_Keep_Random_03_Level_02 = 0x3623a
	Global $A3_Dun_Keep_Random_04 = 0x2c8e6
	Global $A3_Dun_Keep_Random_04_Level_02 = 0x36241
	Global $A3_Dun_Keep_Random_Cellar_01 = 0x35ee9
	Global $A3_Dun_Keep_Random_Cellar_02 = 0x35ee8
	Global $A3_Dun_Keep_Random_Cellar_03 = 0x303f7
	Global $A3_Dun_Keep_TheBreach_Level04 = 0x3558f
	Global $A3_dun_rmpt_Level01 = 0x16b20
	Global $A3_dun_rmpt_Level02 = 0x16bf5
	Global $A3_Gluttony_Boss = 0x1b280
	Global $A3_dun_Hub_Adria_Tower = 0x31222
	Global $A3_dun_hub_AdriaTower_Intro_01 = 0x3253e
	Global $A4_dun_Diablo_Arena = 0x1abfb
	Global $A4_dun_Diablo_Arena_Phase3 = 0x348c3
	Global $A4_dun_Garden_of_Hope_01 = 0x1abca
	Global $A4_dun_Garden_of_Hope_02 = 0x1abcc
	Global $A4_dun_Garden3_SpireEntrance = 0x1d44a
	Global $A4_dun_Heaven_1000_Monsters_Fight = 0x1aa5d
	Global $A4_dun_Heaven_1000_Monsters_Fight_Entrance = 0x2f169
	Global $A4_dun_Hell_Portal_01 = 0x1abd6
	Global $A4_dun_Hell_Portal_02 = 0x1abdb
	Global $A4_Dun_Keep_Hub = 0x301ed
	Global $A4_dun_LibraryOfFate = 0x23120
	Global $A4_dun_Spire_00 = 0x307a4
	Global $A4_dun_Spire_01 = 0x1abe2
	Global $A4_dun_Spire_02 = 0x1abe4
	Global $A4_dun_Spire_03 = 0x1abe6
	Global $A4_dun_Spire_04 = 0x33728
	Global $A4_dun_Spire_SigilRoom_A = 0x313c4
	Global $A4_dun_Spire_SigilRoom_B = 0x2ae7a
	Global $A4_dun_Spire_SigilRoom_C = 0x313c6
	Global $A4_dun_Spire_SigilRoom_D = 0x313c7
	Global $A4_dun_Diablo_ShadowRealm_01 = 0x25845
	Global $A4_dun_spire_DiabloEntrance = 0x3227a
	Global $A4_dun_spire_exterior = 0x34964
	Global $Axe_Bad_Data = 0x4d60
	Global $PvP_Maze_01 = 0x4da2
	Global $PvP_Octogon_01 = 0x4da3
	Global $PvP_Pillar_01 = 0x4da4
	Global $PvP_Stairs_01 = 0x4da5
	Global $PvP_Test_BlueTeam = 0x4da6
	Global $PvP_Test_Neutral = 0x4da7
	Global $PvP_Test_RedTeam = 0x4da8
	Global $PvPArena = 0x4d9c
EndFunc   ;==>LevelAreaConstants



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

				Case 2
					Global $RepairVendor = "UniqueVendor_Peddler_InTown" ; act 2 fillette

				Case 3
					Global $RepairVendor = "UniqueVendor_Collector_InTown" ; act 3

				Case 4
					Global $RepairVendor = "UniqueVendor_Collector_InTown" ; act 3

			EndSwitch
			_log("Our Current Act is : " & $Act & " ---> So our vendor is : " & $RepairVendor)

		EndIf
	EndIf
EndFunc   ;==>GetAct

;;--------------------------------------------------------------------------------
;;     Adapt repair tab aaccording to MP act and diff
;;--------------------------------------------------------------------------------
#cs
Func GetRepairTab()
	GetMonsterPow2()
	GetDifficulty()
	GetAct()

	If $MP > 0 And $GameDifficulty = 4 Then
		Switch $Act
			Case 1
				Global $RepairTab = 2
			Case 2 To 4
				Global $RepairTab = 3
		EndSwitch
	Else
		Switch $Act
			Case 1
				Global $RepairTab = 2
			Case 2 To 4
				Global $RepairTab = 3
		EndSwitch

	EndIf
	_log("RepairTab : " & $RepairTab & " ---> MP : " & $MP & " GameDiff : " & $GameDifficulty)

EndFunc   ;==>GetRepairTab
#ce

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
;;     Find MonsterPower
;;	   Get it Via UI element
;;
;;--------------------------------------------------------------------------------
#cs
Func GetMonsterPow2()

	$GetMonsterPow2 = fastCheckuiValue('Root.NormalLayer.minimap_dialog_backgroundScreen.minimap_dialog_pve.clock', 1, 28)
	$asMpResult = StringRegExp($GetMonsterPow2, '(\()([0-9]{1,2})(\))', 1)
	If @error == 0 Then
		$MP = Number($asMpResult[1])
	Else
		$MP = 0
	EndIf
	_log("Power monster : " & $MP)
	;_log("Power monster : " & $GetMonsterPow2)
EndFunc   ;==>GetMonsterPow2
#ce

;;--------------------------------------------------------------------------------
;;     Find Difficulty from vendor
;;	   Get vendor Level and deduce game difficulty from it
;;		$GameDifficulty = not yet determined, 1 = Norm, 2 = Nm, 3 = Hell, 4 = Inferno
;;--------------------------------------------------------------------------------
Func GetDifficulty()
	If $GameDifficulty = 0 Then

		Local $index, $offset, $count, $item[4]
		startIterateLocalActor($index, $offset, $count)
		While iterateLocalActorList($index, $offset, $count, $item)
			If StringInStr($item[1], $RepairVendor) Then
				Global $npclevel = IterateActorAtribs($item[0], $Atrib_Level)

				Switch $npclevel
					Case 1 To 59
						Global $GameDifficulty = 1
					Case 60 To 70
						Global $GameDifficulty = 4
				EndSwitch

				ExitLoop
			EndIf
		WEnd
		_log("Game Difficulty is : " & $GameDifficulty)
	EndIf
EndFunc   ;==>GetDifficulty


;;--------------------------------------------------------------------------------
; Function:			TownStateCheck()
; Description:		Check if we are in town or not by comparing distance from stash
;
;;--------------------------------------------------------------------------------
Func _intown()
	If $_debug Then _log("-----Checking if In Town------")
	$town = findActor('Player_Shared_Stash', 448)
	If $town = 1 Then
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

	If Trim(StringLower($InventoryCheck)) = "true" Then

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
global $shrinebanlist = 0
$warnloc = GetCurrentPos()
$warnarea = GetLevelAreaId()
_log("Lost detected at : " & $warnloc[0] & ", " & $warnloc[1] & ", " & $warnloc[2],1);
_log("Lost area : " & $warnarea,1);


If _checkInventoryopen() = False Then
        Send("i")
        Sleep(150)
Endif

Send("{PRINTSCREEN}")
sleep(150)
Send("{SPACE}")

ToolTip("Detection de stuff modifié !" & @CRLF & "Zone : " & $warnarea & @CRLF &  "Position : "  & $warnloc[0] & ", " & $warnloc[1] & ", " & $warnloc[2] & @CRLF & "Un screenshot a été pris, il se situe dans document/diablo 3" , 15, 15)


While Not _intown()
    _TownPortalnew()
	sleep(100)
WEnd

;idleing
While 1
MouseClick("middle", Random(100, 200), Random(100, 200), 1, 6)
Sleep(Random(40000, 180000))
MouseClick("middle", Random(600, 700), Random(100, 200), 1, 6)
Sleep(Random(40000, 180000))
MouseClick("middle", Random(600, 700), Random(400, 500), 1, 6)
Sleep(Random(40000, 180000))
MouseClick("middle", Random(100, 200), Random(400, 500), 1, 6)
Sleep(Random(40000, 180000))
Wend

Endfunc
;;--------------------------------------------------------------------------------
; Function:			GetPackItemLevel($ACD, $_REQ)
;;--------------------------------------------------------------------------------
Func GetPackItemLevel($ACD, $_REQ)
	;IterateLocalActor()
	;$ACDIndex = _ArraySearch($__ACTOR, "0x" & Hex($_guid), 0, 0, 0, 1, 1, 1) ;this bitch is slow as hell
	If $ACD = -1 Then Return False
	$_Count = _MemoryRead($_ActorAtrib_Count, $d3, 'int')
	If $_Count > 500 Then
		_log("Attention la valeur de Count était de " & $_Count)
		$_Count = 500
	EndIf

	$CurrentOffset = $_ActorAtrib_4
	Dim $ACTORatrib
	For $i = 0 To $_Count
		$ACTORatrib = _MemoryRead($CurrentOffset, $d3, 'ptr')
		If $ACTORatrib = $ACD Then
			$test = _MemoryRead($CurrentOffset + 0x10, $d3, 'ptr')
			$CurretOffset = $test
			For $i = 0 To 825
				$data = _MemoryRead($CurretOffset, $d3, 'ptr')
				$CurretOffset = $CurretOffset + 0x4
				If $data <> 0x0 Then
					$AtribData = _MemoryRead($data + 0x4, $d3, 'ptr')
					If StringLeft($AtribData, 7) = "0x0003B" Then
						;ConsoleWrite("Debug :" &$data+0x4 & " : " & _MemoryRead($data+0x4, $d3, 'int') &@crlf) ;FOR DEBUGGING
						If "0x" & StringRight($AtribData, 3) = $_REQ[0] Then
							Return _MemoryRead($data + 0x8, $d3, $_REQ[1])
						EndIf
					EndIf
					If StringLeft($AtribData, 7) = "0xFFFFF" Then
						;ConsoleWrite("Debug :" &$data+0x4 & " : " & _MemoryRead($data+0x4, $d3, 'int') &@crlf) ;FOR DEBUGGING
						If "0x" & StringRight($AtribData, 3) = $_REQ[0] Then
							Return _MemoryRead($data + 0x8, $d3, $_REQ[1])
						EndIf
					EndIf
				EndIf
			Next
			Return False
		EndIf
		$CurrentOffset = $CurrentOffset + $ofs_ActorAtrib_StrucSize
	Next
	Return False
EndFunc   ;==>GetPackItemLevel
;;--------------------------------------------------------------------------------
;;	Getting Backpack Item Info, extended to show some more info
;;  $bag = 0 for backpack and 15 for stash
;;--------------------------------------------------------------------------------
Func IterateBackpackExtendedWithLvl($bag = 0)
	$list = IndexSNO($gameBalance)
	$armorOffs = 0
	$weaponOffs = 0
	$otherOffs = 0
	For $j = 0 To UBound($list) - 1
		;19750 = armor, 19754 = weapon, 1953 = other
		If ($list[$j][1] = 19750) Then
			$armorOffs = $list[$j][0]
		EndIf
		If ($list[$j][1] = 19754) Then
			$weaponOffs = $list[$j][0]
		EndIf
		If ($list[$j][1] = 19753) Then
			$otherOffs = $list[$j][0]
		EndIf
	Next
	Local $armorItems = GetLevels($armorOffs)
	Local $weaponItems = GetLevels($weaponOffs)
	Local $otherItems = GetLevels($otherOffs)
	Local $data = IterateBackpack($bag)
	Local $armorItemsWithLvl = MapItemWithLvl($data, $armorItems, 8)
	Local $weaponItemsWithLvl = MapItemWithLvl($data, $weaponItems, 8)
	Local $otherItemsWithLvl = MapItemWithLvl($data, $otherItems, 8)
	Local $allItems[UBound($armorItemsWithLvl, 1)][UBound($armorItemsWithLvl, 2)]
	For $i = 0 To UBound($allItems) - 1 Step 1
		If $armorItemsWithLvl[$i][9] <> "" Then
			;copy from $armorItemsWithLvl to all items
			For $j = 0 To UBound($armorItemsWithLvl, 2) - 1 Step 1
				$allItems[$i][$j] = $armorItemsWithLvl[$i][$j]
			Next
		ElseIf $weaponItemsWithLvl[$i][9] <> "" Then
			;copy from $weaponItemsWithLvl to all items
			For $j = 0 To UBound($weaponItemsWithLvl, 2) - 1 Step 1
				$allItems[$i][$j] = $weaponItemsWithLvl[$i][$j]
			Next
		ElseIf $otherItemsWithLvl[$i][9] <> "" Then
			;copy from $otherItemsWithLvl to all items
			For $j = 0 To UBound($otherItemsWithLvl, 2) - 1 Step 1
				$allItems[$i][$j] = $otherItemsWithLvl[$i][$j]
			Next
		EndIf
	Next
	Return $allItems
EndFunc   ;==>IterateBackpackExtendedWithLvl

;;--------------------------------------------------------------------------------
;;	Maps snos containg a lvl to the item with that snoid
;;--------------------------------------------------------------------------------
Func MapItemWithLvl($items, $snowithlvl, $indexForBGID)
	Local $newItems = $items
	ReDim $newItems[UBound($items, 1)][UBound($items, 2) + UBound($snowithlvl, 2) + 9] ;add size for some new variables
	For $i = 0 To UBound($items) - 1 Step 1
		For $j = 0 To UBound($snowithlvl) - 1 Step 1
			If $snowithlvl[$j][0] = $items[$i][$indexForBGID] Then
				$newItems[$i][$indexForBGID + 1] = $snowithlvl[$j][1] ;ilvl
				$newItems[$i][$indexForBGID + 2] = $snowithlvl[$j][2] ;min dmg
				$newItems[$i][$indexForBGID + 3] = $snowithlvl[$j][3] ;;max dmg
				$newItems[$i][$indexForBGID + 4] = $snowithlvl[$j][4] ;;min armor
				$newItems[$i][$indexForBGID + 5] = $snowithlvl[$j][5] ;max armor
				$newItems[$i][$indexForBGID + 6] = $snowithlvl[$j][6] ;min dmg modifier
				$newItems[$i][$indexForBGID + 7] = $snowithlvl[$j][7] ;max dmg modifier
				$newItems[$i][$indexForBGID + 8] = $snowithlvl[$j][8] ;gold
				$newItems[$i][$indexForBGID + 9] = $snowithlvl[$j][9] ;weapon speed
				;;some extra attributes
				$newItems[$i][$indexForBGID + 10] = IterateActorAtribs($newItems[$i][0], $Atrib_Item_Quality_Level) ;quality lvl
				$newItems[$i][$indexForBGID + 11] = IterateActorAtribs($newItems[$i][0], $Atrib_Strength_Item) ;str
				$newItems[$i][$indexForBGID + 12] = IterateActorAtribs($newItems[$i][0], $Atrib_Vitality_Item) ;vit
				$newItems[$i][$indexForBGID + 12] = IterateActorAtribs($newItems[$i][0], $Atrib_Intelligence_Item) ;int
				$newItems[$i][$indexForBGID + 13] = IterateActorAtribs($newItems[$i][0], $Atrib_Dexterity_Item) ;dex
				$newItems[$i][$indexForBGID + 15] = IterateActorAtribs($newItems[$i][0], $Atrib_Resistance_All) ;all res
				$newItems[$i][$indexForBGID + 16] = Round(IterateActorAtribs($newItems[$i][0], $Atrib_Gold_Find) * 100) ;gf in %
				$newItems[$i][$indexForBGID + 17] = Round(IterateActorAtribs($newItems[$i][0], $Atrib_Magic_Find) * 100) ;mf in %
				$newItems[$i][$indexForBGID + 18] = Round(IterateActorAtribs($newItems[$i][0], $Atrib_Hitpoints_Max_Percent_Bonus_Item) * 100) ;life %
				$newItems[$i][$indexForBGID + 19] = _MemoryRead($newItems[$i][7] + 0x164, $d3, 'int') > 0 ;0ffset + 164 ;true=unid, false=identified
				ExitLoop
			EndIf
		Next
	Next
	Return $newItems
EndFunc   ;==>MapItemWithLvl

;;--------------------------------------------------------------------------------
;;	Gets levels from Gamebalance file, returns a list with snoid and lvl
;;--------------------------------------------------------------------------------
Func GetLevels($offset)
	If $offset <> 0 Then
		$ofs = $offset + 0x218;
		$read = _MemoryRead($ofs, $d3, 'int')
		While $read = 0
			$ofs += 0x4
			$read = _MemoryRead($ofs, $d3, 'int')
		WEnd
		$size = _MemoryRead($ofs + 0x4, $d3, 'int')
		$size -= 0x5F8
		$ofs = $offset + _MemoryRead($ofs, $d3, 'int')
		$nr = $size / 0x5F8
		Local $snoItems[$nr + 1][10]
		$j = 0
		For $i = 0 To $size Step 0x5F8
			$ofs_address = $ofs + $i
			$snoItems[$j][0] = _MemoryRead($ofs_address, $d3, 'ptr')
			$snoItems[$j][1] = _MemoryRead($ofs_address + 0x114, $d3, 'int') ;lvl
			$snoItems[$j][2] = _MemoryRead($ofs_address + 0x1C8, $d3, 'float') ;min dmg
			$snoItems[$j][3] = $snoItems[$j][2] + _MemoryRead($ofs_address + 0x1CC, $d3, 'float') ;max dmg
			$snoItems[$j][4] = _MemoryRead($ofs_address + 0x224, $d3, 'float') ;min armor
			$snoItems[$j][5] = $snoItems[$j][4] + _MemoryRead($ofs_address + 0x228, $d3, 'float') ;max armor
			$snoItems[$j][6] = _MemoryRead($ofs_address + 0x32C, $d3, 'float') ;min dmg modifier
			$snoItems[$j][7] = $snoItems[$j][4] + _MemoryRead($ofs_address + 0x330, $d3, 'float') ;max dmg modifier
			$snoItems[$j][8] = _MemoryRead($ofs_address + 0x12C, $d3, 'int') ;gold price
			$snoItems[$j][9] = _MemoryRead($ofs_address + 0x2D4, $d3, 'float') ;wpn speed
			$j += 1
		Next
	EndIf
	Return $snoItems
EndFunc   ;==>GetLevels



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

	$Uni_manuel = false
	Local $__ACDACTOR = triBackPack(IterateBackpack(0))
	Local $iMax = UBound($__ACDACTOR)

	If $iMax > 0 Then

		Local $return[$iMax][4]

		Send("{SPACE}") ; make sure we close everything
		Send("i") ; open the inventory
		Sleep(100)

		CheckWindowD3Size()
        _checkbackpacksize()

		if trim(StringLower($Unidentified)) = "false" Then
			Take_BookOfCain()
		Else
			$Uni_manuel = true
		EndIF

		For $i = 0 To $iMax - 1 ;c'est ici que l'on parcour (tours a tours) l'ensemble des items contenut dans notres bag

			$ACD = GetACDOffsetByACDGUID($__ACDACTOR[$i][0])
			$CurrentIdAttrib = _memoryread($ACD + 0x120, $d3, "ptr")
			$quality = GetAttribute($CurrentIdAttrib, $Atrib_Item_Quality_Level) ;on definit la quality de l'item traiter ici

			$itemDestination = CheckItem($__ACDACTOR[$i][0], $__ACDACTOR[$i][1], 1) ;on recupere ici ce que l'on doit faire de l'objet (stash/inventaire/trash)

			If $Uni_manuel = true Then
				If $quality >= 6 And _MemoryRead($__ACDACTOR[$i][7] + 0x164, $d3, 'int') > 0 And ($itemDestination <> "Stash" Or trim(StringLower($Unidentified)) = "false") Then
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

				EndIf
			EndIf

			$return[$i][0] = $__ACDACTOR[$i][3] ;definit la collone de l'item
			$return[$i][1] = $__ACDACTOR[$i][4] ;definit la ligne de l'item
			$return[$i][3] = $quality

			If $itemDestination = "Stash_Filtre" And trim(StringLower($Unidentified)) = "false" Then ;Si c'est un item à filtrer et que l'on a definit Unidentified sur false (il faudra juste changer le nom de la variable Unidentifier)
				If checkFiltreFromtable($GrabListTab, $__ACDACTOR[$i][1], $CurrentIdAttrib) Then ;on lance le filtre sur l'item
					_log('valide', 1)
					_log(' - ', 1)
					$return[$i][2] = "Stash"
				Else
					$return[$i][2] = "Trash"
					_log('invalide', 1)
					_log(' - ', 1)
				EndIf

			Else
				$return[$i][2] = $itemDestination ;row
			EndIf

		Next

		Send("{SPACE}") ; make sure we close everything



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

;;--------------------------------------------------------------------------------
;;      Stop()
;;--------------------------------------------------------------------------------
Func Stop()
	Exit
EndFunc   ;==>Stop



;;================================================================================
; Function:                     LocateMyToon
; Note(s):                      This function is used by the OffsetList to
;                                               get the current player data.
;==================================================================================
Func LocateMyToon()
	$count_locatemytoon = 0
	$idarea = 0

	Global $_Myoffset = 0
	Global $_MyGuid = 0
	Global $_MyACDWorld = 0
	Global $_MyCharType = 0


	If _ingame() Then

			While  $count_locatemytoon <= 1000

				$idarea = GetLevelAreaId()

				if $idarea <> -1 Then
					If $_debug Then _log("Looking for local player")

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

							If $hotkeycheck = 1 Then
								If Verif_Attrib_GlobalStuff() Then
									return true
								Else
									_log("CHANGEMENT DE STUFF ON TOURNE EN ROND (locatemytoon)!!!!!")
									antiidle()
								EndIf
							Else
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
			If $_displayInfo = 1 Then ConsoleWrite('Count : "' & $i & '" ' & $__ACTOR[$i][1] & "' '" & $__ACTOR[$i][2] & "' '" & $__ACTOR[$i][3] & "'" & @CRLF)
			Global $GetACD = $i
			Return True
		EndIf
	Next
	ConsoleWrite("Get ACD By Guid was failed" & @CRLF)
EndFunc   ;==>GetACDByGuid

;;================================================================================
; Function:			IterateLocalActor
; Note(s):			Iterates through all the local actors.
;						Used by IterateActorAtribs
;					This is bad use of variables, should be fixed!
;==================================================================================
Func IterateLocalActor()
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
		;_log($__ACTOR[$i][1] & " : " & $__ACTOR[$i][2] & " : " & $__ACTOR[$i][3])
		$CurrentOffset = $CurrentOffset + $ofs_LocalActor_StrucSize
	Next
EndFunc   ;==>IterateLocalActor
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
Func IterateActorAtribs($_GUID, $_REQ)
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
					;if $_displayInfo = 1 Then ConsoleWrite($i & " " & $Object_File_Actor[$ItemIndex][0] & @tab & " " &$MonsterType &@tab & " " & $MonsterRace &@tab & " Level Normal:" & $LevelNormal &@tab & " " & $StringListDB[$Name][1] &" " & @TAB  &$OBject_Mem_Actor[$i][2] &@crlf)
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
		If $_displayInfo = 1 Then ConsoleWrite($_CurrentOffset & " ProxyName: " & $_OutPut[$i][0] & @TAB & " LocalizedName: " & $_OutPut[$i][1] & @CRLF)
	Next

	Return $_OutPut
EndFunc   ;==>IndexStringList


;;--------------------------------------------------------------------------------
;;	OffsetList()
;;--------------------------------------------------------------------------------
Func offsetlist()
	_log("offsetlist")
	;//FILE DEFS
	Global $ofs_MonsterDef = 0x18EC4C0 ; 0x18CBE70 ;1.0.6 0x15DBE00 ;0x015DCE00 ;0x15DBE00
	Global $ofs_StringListDef = 0x17E4EE8 ;ou alors 0x17f8568;0x18DD188;0x18DC188;0x18A2558 ; 0x0158C240 ;0x015E8808 ;0x015E9808
	Global $ofs_ActorDef = 0x18E73F0 ; 0x18C6AD8 ;1.0.6 0x15EC108 ;0x015ED108 ;0x15EC108
	Global $_defptr = 0x10
	Global $_defcount = 0x10C
	Global $_deflink = 0x11C
	Global $_ofs_FileMonster_StrucSize = 0x50
	Global $_ofs_FileActor_LinkToMonster = 0x6C
	Global $_ofs_FileMonster_MonsterType = 0x18
	Global $_ofs_FileMonster_MonsterRace = 0x1C
	Global $_ofs_FileMonster_LevelNormal = 0x44
	Global $_ofs_FileMonster_LevelNightmare = 0x48
	Global $_ofs_FileMonster_LevelHell = 0x4c
	Global $_ofs_FileMonster_LevelInferno = 0x50



	;//GET ACTORATRIB
	Global $ofs_ActorAtrib_Base = 0x0196644C ;0x1544E54 ;0x15A1EA4 ;0x015A2EA4;0x015A1EA4
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
	Global $ofs_LocalActor_StrucSize = 0x2F8 ;0x2D0 ; 0x0 0x0


	;//OBJECT MANAGER
	Global $ofs_objectmanager = 0x1CD63EC ;0x1cd7a04;0x18CE394;0x018CD394 ;0x18939C4 ;0x1873414 ;0x0186FA3C ;0x1543B9C ;0x15A0BEC ;0x015A1BEC;0x15A0BEC
	Global $ofs__ObjmanagerActorOffsetA = 0x920 ;0x8C8 ;0x8b0 ;2.0
	Global $ofs__ObjmanagerActorCount = 0x108
	Global $ofs__ObjmanagerActorOffsetB = 0x120 ;0x148 ;0x148



	Global $ofs__ObjmanagerActorLinkToCTM = 0x1a8 ;0x384


	Global $_ObjmanagerStrucSize = 0x44c ;0x42C ;0x42C ;0x428


	;//CameraDef
	Global $VIewStatic = 0x015A0BEC
	Global $DebugFlags = $VIewStatic + 0x20
	Global $vftableSubB = _MemoryRead($VIewStatic, $d3, 'ptr')
	Global $vftableSubA = _MemoryRead($vftableSubB + 0x928, $d3, 'ptr')
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
	Global $ofs_InteractBase = 0x18CD364 ;0x1543B84 ;0x15A0BD4 ;0x015A1BD4;0x15A0BD4
	Global $ofs__InteractOffsetA =  0xC4 ;0xA8
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
		If $_debug Then _log("My toon located at: " & $_Myoffset & ", GUID: " & $_MyGuid & ", NAME: " & $_MyCharType & @CRLF)
		Return True
	Else
		Return False
	EndIf

EndFunc   ;==>offsetlist

;;--------------------------------------------------------------------------------
;;      IterateAllObjectList()
;; 		Description:		Iterate object even if they dont have guid, also provide true names
;;--------------------------------------------------------------------------------
Func IterateAllObjectList($_displayInfo)
	If $_displayInfo = 1 Then ConsoleWrite("-----Iterating through Actors------" & @CRLF)
	If $_displayInfo = 1 Then ConsoleWrite("First Actor located at: " & $_itrObjectManagerD & @CRLF)
	$_CurOffset = $_itrObjectManagerD
	$_Count = _MemoryRead($_itrObjectManagerCount, $d3, 'int')
	Dim $OBJ[$_Count + 1][10]
	If $_displayInfo = 1 Then ConsoleWrite("Number of Actors : " & $_Count & @CRLF)
	For $i = 0 To $_Count Step +1
		$_GUID = _MemoryRead($_CurOffset + 0x4, $d3, 'ptr')
		$_NAME = _MemoryRead($_CurOffset + 0x8, $d3, 'char[64]')
		$_POS_X = _MemoryRead($_CurOffset + 0xB0, $d3, 'float')
		$_POS_Y = _MemoryRead($_CurOffset + 0xB4, $d3, 'float')
		$_POS_Z = _MemoryRead($_CurOffset + 0xB8, $d3, 'float')
		$_DATA = _MemoryRead($_CurOffset + 0x200, $d3, 'int')
		$_DATA2 = _MemoryRead($_CurOffset + 0x1D0, $d3, 'int')
		$_DATA3 = _MemoryRead($_CurOffset + 0x1C4, $d3, 'int')
		$CurrentLoc = GetCurrentPos()
		$xd = $_POS_X - $CurrentLoc[0]
		$yd = $_POS_Y - $CurrentLoc[1]
		$zd = $_POS_Z - $CurrentLoc[2]
		$Distance = Sqrt($xd * $xd + $yd * $yd + $zd * $zd)
		$OBJ[$i][0] = $i
		$OBJ[$i][1] = $_GUID
		$OBJ[$i][2] = $_NAME
		$OBJ[$i][3] = $_POS_X
		$OBJ[$i][4] = $_POS_Y
		$OBJ[$i][5] = $_POS_Z
		$OBJ[$i][6] = $_DATA
		$OBJ[$i][7] = $_DATA2
		$OBJ[$i][8] = $Distance
		$OBJ[$i][9] = $_CurOffset
		If $_displayInfo = 1 Then ConsoleWrite($i & @TAB & " : " & $_CurOffset & " " & $_GUID & " : " & $_DATA & " " & $_DATA2 & " " & @TAB & $_POS_X & " " & $_POS_Y & " " & $_POS_Z & " Dist: " & $Distance & @TAB & $_NAME & " data3: " & $_DATA3 & @CRLF)
		;if $_displayINFO = 1 then ConsoleWrite($i & @TAB&" : " & $_POS_X & @TAB& $_POS_Y & @TAB & $_POS_Z & @TAB& $_NAME & @crlf)
		$_CurOffset = $_CurOffset + $_ObjmanagerStrucSize
	Next
	Return $OBJ
EndFunc   ;==>IterateAllObjectList


;;--------------------------------------------------------------------------------
;;	IterateObjectList()
;;--------------------------------------------------------------------------------
Func IterateObjectList($_displayInfo = 0)
	;	Local $mesureobj = TimerInit() ;;;;;;;;;;;;;;
	If $_displayInfo = 1 Then ConsoleWrite("-----Iterating through Actors------" & @CRLF)
	If $_displayInfo = 1 Then ConsoleWrite("First Actor located at: " & $_itrObjectManagerD & @CRLF)
	$_CurOffset = $_itrObjectManagerD
	$_Count = _MemoryRead($_itrObjectManagerCount, $d3, 'int')
	Dim $OBJ[$_Count + 1][13]
	If $_displayInfo = 1 Then ConsoleWrite("Number of Actors : " & $_Count & @CRLF)
	;$init = TimerInit()
	For $i = 0 To $_Count Step +1
		$_GUID = _MemoryRead($_CurOffset + 0x4, $d3, 'ptr')
		If $_GUID = 0xffffffff Then ;no need to go through objects without a GUID!
			$_PROXY_NAME = -1
			$_REAL_NAME = -1
			$_ACTORLINK = -1
			$_POS_X = -1
			$_POS_Y = -1
			$_POS_Z = -1
			$_DATA = -1
			$_DATA2 = -1
		Else
			$_PROXY_NAME = _MemoryRead($_CurOffset + 0x8, $d3, 'char[64]')
			$TmpString = StringSplit($_PROXY_NAME, "-")
			If IsDeclared("__" & $TmpString[1]) Then
				$_REAL_NAME = Eval("__" & $TmpString[1])
			Else
				$_REAL_NAME = $_PROXY_NAME
			EndIf
			$_ACTORLINK = _MemoryRead($_CurOffset + 0x88, $d3, 'ptr')
			$_POS_X = _MemoryRead($_CurOffset + 0xB0, $d3, 'float')
			$_POS_Y = _MemoryRead($_CurOffset + 0xB4, $d3, 'float')
			$_POS_Z = _MemoryRead($_CurOffset + 0xB8, $d3, 'float')
			$_DATA = _MemoryRead($_CurOffset + 0x200, $d3, 'int')
			$_DATA2 = _MemoryRead($_CurOffset + 0x1D0, $d3, 'int')
			If $_displayInfo = 1 Then ConsoleWrite($i & @TAB & " : " & $_CurOffset & " " & $_GUID & " " & $_ACTORLINK & " : " & $_DATA & " " & $_DATA2 & " " & @TAB & $_POS_X & " " & $_POS_Y & " " & $_POS_Z & @TAB & $_REAL_NAME & @CRLF)
		EndIf

		;Im too lazy to do this but the following code needs cleanup and restructure more than anything.
		;You want to include all the data into this one structure rather than having it at multiple locations
		;and the useless things should be removed.
		$CurrentLoc = GetCurrentPos()
		$xd = $_POS_X - $CurrentLoc[0]
		$yd = $_POS_Y - $CurrentLoc[1]
		$zd = $_POS_Z - $CurrentLoc[2]
		$Distance = Sqrt($xd * $xd + $yd * $yd + $zd * $zd)
		$OBJ[$i][0] = $_CurOffset
		$OBJ[$i][1] = $_GUID
		$OBJ[$i][2] = $_PROXY_NAME
		$OBJ[$i][3] = $_POS_X
		$OBJ[$i][4] = $_POS_Y
		$OBJ[$i][5] = $_POS_Z
		$OBJ[$i][6] = $_DATA
		$OBJ[$i][7] = $_DATA2
		$OBJ[$i][8] = $Distance
		$OBJ[$i][9] = $_ACTORLINK
		$OBJ[$i][10] = $_REAL_NAME
		$OBJ[$i][11] = -1
		$OBJ[$i][12] = -1
		$_CurOffset = $_CurOffset + $_ObjmanagerStrucSize
	Next
	;$OBJv2 = LinkActors($OBJ) ;//Would be a waste to do this in the main operation so we add more data to the object here after the main operation.
	IterateLocalActor()
	;	Local $difmesureobj = TimerDiff($mesureobj) ;;;;;;;;;;;;;
	;ConsoleWrite("Mesure iterOBJ :" & $difmesureobj &@crlf) ;FOR DEBUGGING;;;;;;;;;;;;
	Return $OBJ
EndFunc   ;==>IterateObjectList


;;--------------------------------------------------------------------------------
;;      Function to iterate all objects()
;;--------------------------------------------------------------------------------
Func startIterateObjectsList(ByRef $index, ByRef $offset, ByRef $count)
	$count = _MemoryRead($_itrObjectManagerCount, $d3, 'int')
	$index = 0
	$offset = $_itrObjectManagerD
EndFunc   ;==>startIterateObjectsList

;;--------------------------------------------------------------------------------
;;      FromD3toScreenCoords()
;;--------------------------------------------------------------------------------
Func FromD3toScreenCoords($_x, $_y, $_z)
	Dim $return[2]
	$size = WinGetClientSize("[CLASS:D3 Main Window Class]")
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
	If $return[0] > 790 Then
		$return[0] = 790
	ElseIf $return[0] < 40 Then ;car on a pas l'envie de cliquer dans les icone du chat
		$return[0] = 40
	EndIf
	If $return[1] > 540 Then ;car on a pas l'envie de cliquer dans la bare des skills
		$return[1] = 540
	ElseIf $return[1] < 10 Then
		$return[1] = 10
	EndIf
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


;;--------------------------------------------------------------------------------
;;      GetCurrentPos()
;;--------------------------------------------------------------------------------
Func GetCurrentPos()
	;	Local $mesurepos = TimerInit() ;;;;;;;;;;;;;;
	Dim $return[3]

	$return[0] = _MemoryRead($_Myoffset + 0x0A4, $d3, 'float')
	$return[1] = _MemoryRead($_Myoffset + 0x0A8, $d3, 'float')
	$return[2] = _MemoryRead($_Myoffset + 0x0AC, $d3, 'float')

	$Current_Hero_X = $return[0]
	$Current_Hero_Y = $return[1]
	$Current_Hero_Z = $return[2]

	;		Local $difmesurepos = TimerDiff($mesurepos) ;;;;;;;;;;;;;
	;ConsoleWrite("Mesure getcurrentpos :" & $difmesurepos &@crlf) ;FOR DEBUGGING;;;;;;;;;;;;
	Return $return
EndFunc   ;==>GetCurrentPos



;;--------------------------------------------------------------------------------
;;      MoveToPos()
;;--------------------------------------------------------------------------------
Func MoveToPos($_x, $_y, $_z, $_a, $m_range)
	Local $TimeOut = TimerInit()
	$grabtimeout = 0
	$killtimeout = 0
	If _playerdead() Or $GameOverTime = True Or $GameFailed = 1 Or $SkippedMove > 6 Then
		$GameFailed = 1
		Return
	EndIf
	Local $toggletry = 0
	Global $lastwp_x = $_x
	Global $lastwp_y = $_y
	Global $lastwp_z = $_z
	If $_a = 1 Then Attack()
	$Coords = FromD3toScreenCoords($_x, $_y, $_z)
	MouseMove($Coords[0], $Coords[1], 3)
	$LastCP = GetCurrentPos()
	MouseDown("middle")
	Sleep(10)
	While 1

		GameOverTime()
		If $GameOverTime = True Then
			ExitLoop
		EndIf

		GestSpellcast(0, 0, 0)

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
			If $Coords[0] > 790 Then
				$Coords[0] = 790
			ElseIf $Coords[0] < 40 Then ;car on a pas l'envie de cliquer dans les icone du chat
				$Coords[0] = 40
			EndIf
			If $Coords[1] > 540 Then ;car on a pas l'envie de cliquer dans la bare des skills
				$Coords[1] = 540
			ElseIf $Coords[1] < 10 Then
				$Coords[1] = 10
			EndIf
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
		;ConsoleWrite("currentloc: " & $_Myoffset & " - "&$CurrentLoc[0] & " : " & $CurrentLoc[1] & " : " & $CurrentLoc[2] &@CRLF)
		;ConsoleWrite("distance/m range: " & $Distance & " : " & $m_range & @CRLF)
		If $_a = 1 And GetDistance($LastCP[0], $LastCP[1], $LastCP[2]) >= $a_range / 2 Then
			MouseUp("middle")
			$LastCP = GetCurrentPos()
			If $_a = 1 Then Attack()
			;ConsoleWrite("Last check: " & $Distance & @CRLF)
			;MouseMove($Coords[0], $Coords[1], 3)

			$Coords_RndX = Random($Coords[0] - 20, $Coords[0] + 20)
			$Coords_RndY = Random($Coords[1] - 20, $Coords[1] + 15)

			If $Coords_RndX < 40 Then
				$Coords_RndX = 40
			ElseIf $Coords_RndX > 790 Then
				$Coords_RndX = 790
			EndIf

			If $Coords_RndY < 10 Then
				$Coords_RndY = 10
			ElseIf $Coords_RndY > 540 Then
				$Coords_RndY = 540
			EndIf


			MouseMove($Coords_RndX, $Coords_RndY, 3) ;little randomisation
			MouseDown("middle")
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
	MouseUp("middle")
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
;;      Approach() Approach a NPC without left clicking
;;--------------------------------------------------------------------------------
Func Approach($_x, $_y, $_z)
	; MoveToPos($_x, $_y, $_z, 0, 25)
	;While _MemoryRead($_itrInteractE + $ofs__InteractOffsetUNK2, $d3, 'int') = 1
	;	Sleep(50)
	;WEnd
EndFunc   ;==>Approach

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
					MouseClick("middle", $Coords[0], $Coords[1], 1, 10)
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

;----------------------------------------------------------------------------------------------------------------------
;   Fuction         _Array2DDelete(ByRef $ARRAY, $iDEL, $bCOL=False)
;
;   Description     Delete one row on a given index in an 1D/2D -Array
;
;   Parameter       $ARRAY      the array, where one row will deleted
;                   $iDEL       Row(Column)-Index to delete
;                   $bCOL       If True, delete column instead of row (default False)
;
;   Return          Succes      0   ByRef $ARRAY
;                   Failure     1   set @error = 1; given array are not array
;                                   set @error = 2; want delete column, but not 2D-array
;                                   set @error = 3; index is out of range
;
; Author            BugFix (bugfix@autoit.de)
;----------------------------------------------------------------------------------------------------------------------
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


Func iterateObjectsList(ByRef $index, ByRef $offset, ByRef $count, ByRef $item)

	If $index > $count + 1 Then
		Return False
	EndIf

	$index += 1
	$error = 0

	; 0x1d4 -> Data 3
	; 0x230 -> Data 2
	; 0x260 -> Data 1


	;if $index > $count Then
	;	return true
	;EndIF

	Do
	Local $iterateObjectsListStruct = DllStructCreate("int;char[128];byte[4];ptr;byte[40];float;float;float;byte[276];int;byte[88];int;byte[44];int")
	;Local $iterateObjectsListStruct = DllStructCreate("int;char[128];byte[4];ptr;byte[24];float;float;float;byte[292];int;byte[88];int;byte[44];int")
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')


#cs
		if DllStructGetData($iterateObjectsListStruct, 1)  = -1 OR DllStructGetData($iterateObjectsListStruct, 4) = -1 Then
			$error = 1
			$index += 1
			$offset = $offset + $_ObjmanagerStrucSize

			$iterateObjectsListStruct = ""
			if $index > $count + 1 Then
				return false
			EndIF


			ContinueLoop
		Else
			if $index > $count + 1 Then
				return false
			EndIF

			$error = 0
		EndIF
#ce

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




Func IterateFilterAttack($IgnoreList)
	Local $index, $offset, $count, $item[10]
	startIterateObjectsList($index, $offset, $count)
	Dim $item_buff_2D[1][10]
	Local $i = 0

	$compt = 0

	While iterateObjectsList($index, $offset, $count, $item)
		$compt += 1
		If Is_Interact($item, $IgnoreList) Then
			If Is_Shrine($item) Or Is_Mob($item) Or Is_Loot($item) or Is_Decor_Breakable($item) or Is_Coffre($item) Then
				ReDim $item_buff_2D[$i + 1][10]
				For $x = 0 To 9
					$item_buff_2D[$i][$x] = $item[$x]
				Next
				$i += 1
			EndIf

		EndIf
	WEnd

	If $i = 0 Then
		Return False
	Else

		If trim(StringLower($MonsterTri)) = "true" Then
			_ArraySort($item_buff_2D, 0, 0, 0, 9)
		EndIf

		If trim(StringLower($MonsterPriority)) = "true" Then
			Dim $item_buff_2D_buff = TriObjectMonster($item_buff_2D)
			Dim $item_buff_2D = $item_buff_2D_buff
		EndIf
		Return $item_buff_2D
	 EndIf

EndFunc   ;==>IterateFilterAttack

Func IterateFilterZone($dist,$n=2)
	Local $index, $offset, $count, $item[10]
	startIterateObjectsList($index, $offset, $count)
;~ 	Dim $item_buff_2D[1][10]
	Local $i = 0
$my_pos_zone=getcurrentpos()
	$compt = 0

	While iterateObjectsList($index, $offset, $count, $item)
		$compt += 1
		If Is_Interact($item, "") Then
			If Is_Mob($item) and sqrt(($item[2]-$my_pos_zone[0])^2 + ($item[3]-$my_pos_zone[1])^2 ) < $dist and $item[4]<10 Then
;~ 				ReDim $item_buff_2D[$i + 1][10]
;~ 				For $x = 0 To 9
;~ 					$item_buff_2D[$i][$x] = $item[$x]
;~ 				Next
				$i += 1
			EndIf

		EndIf
	WEnd
;= 0 or ubound($item_buff_2D)
	If $i <2 Then
;~ 	   _log("pas assez de mob proche")
		Return False
	Else
;~ 		 _log("nombre : " & $i)
		return True

	EndIf
EndFunc   ;==>IterateFilterAttack

Func UpdateArrayAttack($array_obj, $IgnoreList, $update_attrib = 0)

	If UBound($array_obj) <= 1 Or Not IsArray($array_obj) Then
		Return False
	EndIf


	If $update_attrib = 0 Then
		Return UpdateObjectsList(_Array2DDelete($array_obj, 0))
	Else

		Local $buff2 = IterateFilterAttack($IgnoreList)
		If trim(StringLower($MonsterTri)) = "true" Then
			_ArraySort($buff2, 0, 0, 0, 9)
		EndIf

		If trim(StringLower($MonsterPriority)) = "true" Then
			Dim $buff2_buff = TriObjectMonster($buff2)
			Dim $buff2 = $buff2_buff
		EndIf

		Return $buff2
	EndIf
EndFunc   ;==>UpdateArrayAttack

Func TriObjectMonster($item)

	Dim $tab_monster[1][10]
	Dim $tab_other[1][10]
	Dim $tab_mixte[1][10]
	Dim $tab_elite[1][10]
	Dim $item_temp[10]
	$compt_monster = 0
	$compt_other = 0
	$compt_elite = 0
	$compt_mixte = 0

	For $i = 0 To UBound($item) - 1

		For $z = 0 to 9
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
				ReDim $tab_monster[UBound($tab_monster) + 1][10]
			EndIf
			For $y = 0 To 9
				$tab_monster[UBound($tab_monster) - 1][$y] = $item[$i][$y]
			Next
			$compt_monster += 1

		Else

			If UBound($tab_other) > 1 Or $compt_other <> 0 Then
				ReDim $tab_other[UBound($tab_other) + 1][10]
			EndIf
			For $y = 0 To 9
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
			ReDim $tab_mixte[UBound($tab_mixte) + 1][10]
		EndIf
		For $y = 0 To 9
			$tab_mixte[UBound($tab_mixte) - 1][$y] = $tab_monster[$i][$y]
		Next
		$compt_mixte += 1
	Next

	For $i = 0 To UBound($tab_other) - 1

		If UBound($tab_mixte) > 1 Or $compt_mixte <> 0 Then
			ReDim $tab_mixte[UBound($tab_mixte) + 1][10]
		EndIf
		For $y = 0 To 9
			$tab_mixte[UBound($tab_mixte) - 1][$y] = $tab_other[$i][$y]
		Next
		$compt_mixte += 1
	Next

	Return $tab_mixte

EndFunc   ;==>TriObjectMonster

Func UpdateObjectsList($item)
	For $i = 0 To UBound($item) - 1
		Dim $buff_item[4]
		Local $pos = DllStructCreate("byte[180];float;float;float") ;b4 Vec3 Pos1 Struct CRActor
		DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $item[$i][8], 'ptr', DllStructGetPtr($pos), 'int', DllStructGetSize($pos), 'int', '')
		$item[$i][2] = DllStructGetData($pos, 2)
		$item[$i][3] = DllStructGetData($pos, 3)
		$item[$i][4] = DllStructGetData($pos, 4)
		$item[$i][9] = getDistance($item[$i][2], $item[$i][3], $item[$i][4]) ; Distance
		$pos = ""
	Next
	Return $item
EndFunc   ;==>UpdateObjectsList

Func UpdateObjectsPos($offset)
	Local $obj_pos[4]

	Local $pos = DllStructCreate("byte[180];float;float;float") ;b4 Vec3 Pos1 Struct CRActor
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($pos), 'int', DllStructGetSize($pos), 'int', '')
	$obj_pos[0] = DllStructGetData($pos, 2)
	$obj_pos[1] = DllStructGetData($pos, 3)
	$obj_pos[2] = DllStructGetData($pos, 4)
	$obj_pos[3] = getDistance($obj_pos[0], $obj_pos[1], $obj_pos[2]) ; Distance
	$pos = ""
	Return $obj_pos
EndFunc   ;==>UpdateObjectsPos

Func Is_Shrine($item)
	If (StringInStr($item[1], "shrine") or StringInStr($item[1], "PoolOfReflection")) and $item[9] < 35 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>Is_Shrine

Func Is_Mob($item)
	If checkfromlist($BanmonsterList, $item[1]) = 0 And checkFromList($monsterList, $item[1]) And $item[6] <> -1 And $item[9] < $a_range Or checkFromList($SpecialmonsterList, $item[1]) And $item[9] < $a_range Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>Is_Mob

global $decorlist=""
global $bandecorlist=""

Func Is_Decor_Breakable($item)
	If checkfromlist($BandecorList, $item[1]) = 0 And checkFromList($decorList, $item[1]) And $item[6] <> -1 And $item[9] < 18  Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>Is_Mob

Func Is_Loot($item)

	If ($item[5] = 2 And $item[6] = -1) Or (StringInStr($item[1], "orb") And StringInStr($item[1], "unique")) Or (StringInStr($item[1], "Spear") And StringInStr($item[1], "unique")) Then
		;_log("Is_Loot de l'item -> " & $item[0] & "-" & $item[1] & "-" & $item[2] & " - " & $item[3] & " - " & $item[4] & " - " & $item[5] & " - " & $item[6] & " - " & $item[8] & " - " & $item[9])
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>Is_Loot



Func Is_Interact($item, $IgnoreList)
	If $item[0] <> "" And $item[0] <> 0xFFFFFFFF And ($item[9] < $g_range Or $item[9] < $a_range) And StringInStr($IgnoreList, $item[8]) == 0 And StringInStr($handle_banlistdef, $item[2]&"-"&$item[3]&"-"&$item[4]) == 0 And StringInStr($IgnoreItemList, $item[1]) = 0 And checkfromlist($shrinebanlist, $item[8]) = 0 And Abs($Current_Hero_Z - $item[4]) <= 10 Then
		If Not Checkstartlist_regex($Ban_startstrItemList, $item[1]) And Not Checkendlist_regex("_projectile", $item[1]) Then
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf
EndFunc   ;==>Is_Interact

Func Is_Coffre($item)
	if checkfromlist("Props_Demonic_Container|Crater_Chest|Chest_Snowy|Chest_Frosty", $item[1]) AND $item[9] < 50 Then
		return True
	Else
		return False
	EndIF
EndFunc

Func handle_Coffre(ByRef $item)
		$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
		$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
		If GetAttribute($CurrentIdAttrib, $Atrib_Chest_Open) = 0 Then
			If Coffre($item) = False Then
				$shrinebanlist = $shrinebanlist & "|" & $item[8]
			EndIf
		EndIf
EndFunc


Func handle_Shrine(ByRef $item)
	If $TakeShrines = "True" Then
		$CurrentACD = GetACDOffsetByACDGUID($item[0]); ###########
		$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########
		If GetAttribute($CurrentIdAttrib, $Atrib_gizmo_state) <> 1 Then
			If shrine($item[1], $item[8], $item[0]) = False Then
				$shrinebanlist = $shrinebanlist & "|" & $item[8]
			EndIf
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
			_log('ignoring ' & $item[1])
			$IgnoreList = $IgnoreList & $item[8]

			If $killtimeout > 2 Or $grabtimeout > 2 Then
				_log("_checkdisconnect Cuz :If $killtimeout > 2 or $grabtimeout > 2 Then")
				If _checkdisconnect() Or _playerdead() Then
					$GameFailed = 1
				EndIf
			EndIf
		EndIf
		If trim(StringLower($MonsterRefresh)) = "true" Then
			Dim $buff_array = UpdateArrayAttack($test_iterateallobjectslist, $IgnoreList, 1)
			$test_iterateallobjectslist = $buff_array
		EndIf
	Else
		_log('ignoring ' & $item[1])
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
    If _MemoryRead($item[8] + 0x0, $d3, 'ptr') <> 0xFFFFFFFF Then
                ConsoleWrite("Checking " & $item[1] & @CRLF)

				If $gestion_affixe_loot="true" Then
					Dim $item_aff_verif = IterateFilterAffix()
				Else
					$item_aff_verif = ""
				EndIf



			If IsArray($item_aff_verif) and $gestion_affixe_loot="true" Then
			   if is_zone_safe($item[2],$item[3],$item[4],$item_aff_verif) or Checkqual($item[0])=9 then
							$itemDestination = CheckItem($item[0], $item[1])
							If $itemDestination == "Stash" Or $itemDestination == "Salvage" Or ($itemDestination == "Inventory" And $takepot = True) Then
									; this loot is interesting
									$foundobject = 1
									If Grabit($item[1], $item[8]) = False Then
											_log('ignoring ' & $item[1])
											$IgnoreList = $IgnoreList & $item[8]
											handle_banlist($item[2]&"-"&$item[3]&"-"&$item[4])
											;_log("Grabtimeout : " & $grabtimeout & " killtimeout: "& $killtimeout)
											If $killtimeout > 2 Or $grabtimeout > 2 Then
													If _checkdisconnect() Or _playerdead() Then
															_log('_checkdisconnect A or player D')
															$GameFailed = 1
													EndIf
											EndIf

									EndIf

									If Trim(StringLower($ItemRefresh)) = "true" Then
											Dim $buff_array = UpdateArrayAttack($test_iterateallobjectslist, $IgnoreList, 1)
											$test_iterateallobjectslist = $buff_array
									EndIf
							Else
									If checkFromList($monsterList, $item[1]) = False Then
											$IgnoreItemList = $IgnoreItemList & $item[1] & "-"
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
                                _log('ignoring ' & $item[1])
                                $IgnoreList = $IgnoreList & $item[8]
                                handle_banlist($item[2]&"-"&$item[3]&"-"&$item[4])
                                ;_log("Grabtimeout : " & $grabtimeout & " killtimeout: "& $killtimeout)
                                If $killtimeout > 2 Or $grabtimeout > 2 Then
                                        If _checkdisconnect() Or _playerdead() Then
                                                _log('_checkdisconnect A or player D')
                                                $GameFailed = 1
                                        EndIf
                                EndIf

                        EndIf

                        If Trim(StringLower($ItemRefresh)) = "true" Then
                                Dim $buff_array = UpdateArrayAttack($test_iterateallobjectslist, $IgnoreList, 1)
                                $test_iterateallobjectslist = $buff_array
                        EndIf
                Else
                        If checkFromList($monsterList, $item[1]) = False Then
                                $IgnoreItemList = $IgnoreItemList & $item[1] & "-"
                                ;_log('ignoring ' & $item[8] & " : " & $item[1] & " :::::" &$IgnoreItemList)
                        EndIf
                EndIf
          EndIf
    EndIf
 EndFunc   ;==>handle_Loot

Func handle_banlist($coords_ban)
	If StringInStr($handle_banlist1, $coords_ban) = false Then
		_log("banlist 1 -> " & $coords_ban)
		$handle_banlist1 = $handle_banlist1 & "|" & $coords_ban
	ElseIf StringInStr($handle_banlist1, $coords_ban)  And StringInStr($handle_banlist2, $coords_ban) = false Then
		_log("banlist 2 -> " & $coords_ban)
		$handle_banlist2 = $handle_banlist2 & "|" & $coords_ban
	ElseIf StringInStr($handle_banlist2, $coords_ban)  Then
		_log("banlist def -> " & $coords_ban)
		$handle_banlistdef = $handle_banlistdef & "|" & $coords_ban
	 EndIf
	 				_log("banlist 1 -> " & $handle_banlist1)

				_log("banlist 2 -> " & $handle_banlist2)

			_log("banlist def -> " & $handle_banlistdef)

EndFunc   ;==>handle_banlist

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
	Local $item[10]
	Dim $test_iterateallobjectslist = IterateFilterAttack($IgnoreList)
	If IsArray($test_iterateallobjectslist) Then
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
			For $i = 0 To 9
				$item[$i] = $test_iterateallobjectslist[0][$i]
			Next
			If Is_Interact($item, $IgnoreList) Then
				If Is_Shrine($item) Then
					handle_Shrine($item)
				ElseIf Is_Mob($item) or Is_Decor_Breakable($item) Then
					;_log("ON LANCE HANDLE_MOB")
					handle_Mob($item, $IgnoreList, $test_iterateallobjectslist)
				ElseIf Is_Loot($item) Then
					handle_Loot($item, $IgnoreList, $test_iterateallobjectslist)
				ElseIf Is_Coffre($item) Then
					handle_Coffre($item)
				EndIf
			EndIf
			Dim $buff_array = UpdateArrayAttack($test_iterateallobjectslist, $IgnoreList)
			Dim $test_iterateallobjectslist = $buff_array

		WEnd

	EndIf
EndFunc   ;==>Attack

Func DetectElite($Guid)
	Return _MemoryRead(GetACDOffsetByACDGUID($Guid) + 0xB8, $d3, 'int')
EndFunc   ;==>DetectElite

;;--------------------------------------------------------------------------------
;;      KillMob()
;;--------------------------------------------------------------------------------
Func KillMob($name, $offset, $Guid, $test_iterateallobjectslist2)
        $return = True
        $begin = TimerInit()


        Dim $pos = UpdateObjectsPos($offset)

        $Coords = FromD3toScreenCoords($pos[0], $pos[1], $pos[2])
        MouseMove($Coords[0], $Coords[1], 3)

        $elite = DetectElite($Guid)
        ;loop the attack until the mob is dead

        _log("Attacking : " & $name & "; Type : " & $elite);



        While IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur) > 0

			;_log(IterateActorAtribs($Guid, $Atrib_Hitpoints_Cur))

			$myposs_aff = getcurrentpos()

                If _playerdead_revive() Then
                        $return = False
                        ExitLoop
                EndIf
			Dim $pos = UpdateObjectsPos($offset)

                 if $gestion_affixe="true" then maffmove($myposs_aff[0],$myposs_aff[1],$myposs_aff[2],$pos[0],$pos[1])
			for $a=0 to ubound($test_iterateallobjectslist2)-1

				$CurrentACD = GetACDOffsetByACDGUID($test_iterateallobjectslist2[$a][0]); ###########
				$CurrentIdAttrib = _memoryread($CurrentACD + 0x120, $d3, "ptr"); ###########

				If GetAttribute($CurrentIdAttrib, $Atrib_Hitpoints_Cur) > 0 then
					dim $dist_maj=UpdateObjectsPos($test_iterateallobjectslist2[$a][8])
					$test_iterateallobjectslist2[$a][9]=$dist_maj[3]
				Else
					$test_iterateallobjectslist2[$a][9]=10000
				endif
			Next

			_ArraySort($test_iterateallobjectslist2, 0, 0, 0, 9)

			$dist_verif= getDistance($test_iterateallobjectslist2[0][2], $test_iterateallobjectslist2[0][3], $test_iterateallobjectslist2[0][4])
			Dim $pos = UpdateObjectsPos($offset)
			if $pos[3]>$dist_verif+5 then exitloop

;if getDistance($pos[0], $pos[1], $pos[2])>20 and IterateFilterZone(30,1) then exitloop


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
        Return $return
EndFunc   ;==>KillMob


;;--------------------------------------------------------------------------------
;;      Grabit()
;;--------------------------------------------------------------------------------
Func Grabit($name, $offset)
	Local $OriginalOffsetValue = _MemoryRead($offset + 0x4, $d3, 'ptr')
	$begin = TimerInit()
	Dim $CoordVerif[3]


	ConsoleWrite("Grabbing :" & ($name) & @CRLF) ;FOR DEBUGGING

	Dim $pos = UpdateObjectsPos($offset)

	If (StringInStr($name, "gold")) Then
		$Coords = FromD3toScreenCoords($pos[0], $pos[1], $pos[2])
		$CoordVerif[0] = $pos[0]
		$CoordVerif[1] = $pos[1]
		$CoordVerif[2] = $pos[2]
		MouseClick("middle", $Coords[0], $Coords[1], 1, 5)
	Else
		Interact($pos[0], $pos[1], $pos[2])
	EndIf
	While _MemoryRead($offset + 0x4, $d3, 'ptr') = $OriginalOffsetValue
		If _MemoryRead($offset + 0x4, $d3, 'ptr') = 0xFFFFFFFF Then
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
				MouseClick("middle", $Coords[0], $Coords[1], 1, 5)
			EndIf
		Else

			;_log($pos[0] & " - " & $pos[1] & " - " & $pos[2])
			Interact($pos[0], $pos[1], $pos[2])


			;If _inventoryfull() Then
			If Detect_UI_error(0) Then
				Unbuff()
					TpRepairAndBack()
				Buffinit()
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
					_log($_NAME & " ==> It's a rare in our list We have to check the stats")

					if checkFiltreFromtable($GrabListTab, $_NAME, $CurrentIdAttrib) Then
						return "Stash"
					endif

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

Func InventoryMove($col = 0, $row = 0)
	$Coords = UiRatio(530 + ($col * 27), 338 + ($row * 27))
	MouseMove($Coords[0], $Coords[1], 2)
EndFunc   ;==>InventoryMove

;;--------------------------------------------------------------------------------
;;      checkForPotion()
;;--------------------------------------------------------------------------------
Func checkForPotion()

	$life = GetLifep()
	$diff = TimerDiff($timeforpotion)
	If $life < $LifeForPotion / 100 And $diff > 1500 Then
		Send("q")
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

Global $Ban_startstrItemList = "barbarian_|Demonhunter_|Monk_|WitchDoctor_|WD_|Enchantress_|Scoundrel_|Templar_|Wizard_|monsterAffix_|Demonic_|Generic_|fallenShaman_fireBall_impact|demonFlyer_B_clickable_corpse_01|grenadier_proj_trail"
Global $Ban_endstrItemList = "_projectile"
Global $Ban_ItemACDCheckList = "a1_|a3_|a2_|a4_|Lore_Book_Flippy|Topaz_|Emeraude_|Rubis_|Amethyste_|Console_PowerGlobe|GoldCoins|GoldSmall|GoldMedium|GoldLarge|healthPotion_Console"

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
				;_log("filtre avant : " & $filtre_buff, 1)
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

;;--------------------------------------------------------------------------------
;;      SkipDialog()
;;--------------------------------------------------------------------------------
Func SkipDialog($_Count)
	For $i = 1 To $_Count
		Send("{SPACE}")
		Sleep(100)
	Next
EndFunc   ;==>SkipDialog

Func OpenWp(ByRef $item)
	Local $maxtry = 0
	If NOT _playerdead() Then
		_log($item[1] & " distance : " & $item[9])
		While getDistance($item[2], $item[3], $item[4]) > 40 And $maxtry <= 15
			$Coords = FromD3toScreenCoords($item[2], $item[3], $item[4])
			;_log("Dans LE while")
			MouseClick("middle", $Coords[0], $Coords[1], 1, 10)
			$maxtry += 1
			_log('interactbyactor: click x : ' & $Coords[0] & " y : " & $Coords[1])
			Sleep(500)
		WEnd
		Interact($item[2], $item[3], $item[4])
		Sleep(100)
	EndIf

EndFunc   ;==>OpenWp

Func TakeWPV2($WPNumber=0)

	if $GameFailed = 1 Then return False
	While Not offsetlist()
		Sleep(10)
	WEnd

	if $WPNumber = 0 Then
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



		if $WayPointFound Then
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
			Dim $Point = GetPositionUI(GetOfsUI($NameUI, 1))
			Dim $Point2 = GetUIRectangle($Point[0], $Point[1], $Point[2], $Point[3])

			MouseClick("left", $Point2[0] + $Point2[2] / 2, $Point2[1] + $Point2[3] / 2)
			;MouseMove($Point2[0] + $Point2[2] / 2, $Point2[1] + $Point2[3] / 2, 1)

			sleep(2000)
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
;;   TakeWP()
;;--------------------------------------------------------------------------------
Func TakeWP($tarChapter, $tarNum, $curChapter, $curNum)
	If $GameFailed = 0 Then
		Local $Waypoint = ""
		While Not offsetlist()
			Sleep(10)
		WEnd

		;*******************************************************
		Local $index, $offset, $count, $item[10], $maxRange = 80
		startIterateObjectsList($index, $offset, $count)
		While iterateObjectsList($index, $offset, $count, $item)
			If (StringInStr($item[1], "waypoint_arrival_ribbonGeo") And $item[9] < $maxRange) Or (StringInStr($item[1], "waypoint_neutral_ringGlow") And $item[9] < $maxRange) Or (StringInStr($item[1], "waypoint_neutral_ringGlow") And $item[9] < $maxRange) Then
				If StringInStr($item[1], "waypoint_arrival_ribbonGeo") Then
					$Waypoint = "waypoint_arrival_ribbonGeo"
				ElseIf StringInStr($item[1], "waypoint_neutral_ringGlow") Then
					$Waypoint = "waypoint_neutral_ringGlow"
				Else
					$Waypoint = "Waypoint_Town"
				EndIf
				ExitLoop
			EndIf
		WEnd

		If $Waypoint = "" Then
			$Waypoint = "waypoint"
		EndIf
		;******************************************************

		;******************************************************

		If $Waypoint = "waypoint" Then ;WAYPOINT PAR DEFAUT ON a PAS TROUVER ITEM
			_log("enclenchement Old waypoint")
			InteractByActorName($Waypoint)
			Sleep(350)
			Local $wptry = 0
			While _checkWPopen() = False And _playerdead() = False
				If $wptry <= 6 Then
					_log('Fail to open wp')
					$wptry = $wptry + 1
					InteractByActorName($Waypoint)
				EndIf
				If $wptry > 6 Then
					$GameFailed = 1
					_log('Failed to open wp after 6 try')
					ExitLoop
				EndIf
			WEnd

		Else ;WAYPOINT DEFINIT, ON A ITEM
			_log("enclechement new waypoint")
			OpenWp($item)
			Sleep(350)
			Local $wptry = 0
			While _checkWPopen() = False And _playerdead() = False
				If $wptry <= 6 Then
					_log('Fail to open wp')
					$wptry = $wptry + 1
					OpenWp($item)
				EndIf
				If $wptry > 6 Then
					$GameFailed = 1
					_log('Failed to open wp after 6 try')
					ExitLoop
				EndIf
			WEnd

		EndIf


		If $tarChapter <> $curChapter Or ($tarChapter = $curChapter And $tarChapter < $curChapter) Then
			For $i = 0 To $tarChapter - 1
				$coord = UiRatio(35, 100 + ($i * 12.5))
				MouseClick("left", $coord[0], $coord[1], 1, 3) ; Close chapters
			Next
			$coord = UiRatio(145, 100 + ($tarChapter * 12.5) + 23 + ($tarNum * 32))
			MouseClick("left", $coord[0], $coord[1], 1, 3) ; Click wp
		EndIf
		If $tarChapter = $curChapter And $tarChapter > $curChapter Then
			For $i = 0 To $tarChapter - 1
				$coord = UiRatio(35, 100 + ($i * 12.5))
				MouseClick("left", $coord[0], $coord[1], 1, 3) ; Close chapters
			Next
			$coord = UiRatio(145, 100 + ($tarChapter * 12.5) + 23 + 12 + ($tarNum * 32))
			MouseClick("left", $coord[0], $coord[1], 1, 3) ; Click wp
		EndIf
		Sleep(1500)

		While Not offsetlist()
			Sleep(10)
		WEnd
		$SkippedMove = 0 ;reset ouur skipped move count cuz we should be in brand new area
	EndIf
EndFunc   ;==>TakeWP


;;--------------------------------------------------------------------------------
;;      _resumegame()
;;--------------------------------------------------------------------------------
Func _resumegame()
	_log("Resume Game")
	Sleep(Random(500, 1000, 1))
	If $Try_ResumeGame > 2 Then
		Local $wait_aftertoomanytry = Random(($Try_ResumeGame * 2) * 60000, ($Try_ResumeGame * 2) * 120000, 1)
		_log("Sleep after too many _resumegame -> " & $wait_aftertoomanytry)
		Sleep($wait_aftertoomanytry)
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
	_log("Login")
	Sleep(20)
	Send($d3pass)
	Sleep(2000)
	Send("{ENTER}")
	Sleep(Random(5000, 6000, 1))

	$Try_Logind3 += 1
EndFunc   ;==>_logind3


;;--------------------------------------------------------------------------------
;;      _leavegame()
;;--------------------------------------------------------------------------------
Func _leavegame()
	If _ingame() Then
		_log("Leave Game")
		Send("{SPACE}") ; to make sure everything is closed
		sleep(100)
		Send("{ESCAPE}")
		Sleep(Random(200, 300, 1))
		While _escmenu() = False
			Send("{ESCAPE}")
			Sleep(Random(200, 300, 1))
		WEnd
		;_randomclick(134, 264)

		While NOT fastcheckuiitemvisible("Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame", 1, 1644)
			sleep(50)
			_log("Menu Open but btn leaveGame Doesnt Exit yet")
		WEnd

		ClickUI("Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame", 1644)

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
		MouseUp("middle")
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
		MouseUp("middle")
		MouseUp("left")
		Send("{SHIFTUP}")
		Exit 0
	EndIf
EndFunc   ;==>Terminate

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
EndFunc   ;==>TogglePause

Func _log($text, $write = 0)

	$texte_write = @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & " | " & $text

	If $write == 1 Then
		$file = FileOpen(@ScriptDir & "\log\" & $fichierlog, 1)
		If $file = -1 Then
			_log("Log file error, cant be open")
		Else
			FileWrite($file, $texte_write & @CRLF)
		EndIf
		FileClose($file)
	EndIf

	ConsoleWrite(@MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & " | " & $text & @CRLF)
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
;;      checkForSpell()
;;--------------------------------------------------------------------------------
#cs
Func checkForSpell()
	checkForPotion()
	;Local $mesurepot = TimerInit() ;;;;;;;;;;;;;;
	Local $source
	Local $MaximumSource
	Switch $nameCharacter
		Case "DemonHunter"
			$discipline = GetDisc()
			$hatred = GetHatred()
			$life = GetLifep()

			$diffRightClick = TimerDiff($timeforRightclick)
			If $RightClickSpell = "True" And $life <= $LifeForRightClickSpell / 100 And $diffRightClick > $RightClickSpellDelay Then
				If $RightClickSpellEnergy <> "" Then
					If $RightClickSpellEnergy = "hatred" Then
						If $hatred > $RightClickSpellEnergyNeeds / $MaximumHatred Then
							MouseClick("right")
							$timeforRightclick = TimerInit()
						EndIf
					Else
						If $discipline > $RightClickSpellEnergyNeeds / $MaximumDiscipline Then
							MouseClick("right")
							$timeforRightclick = TimerInit()
						EndIf
					EndIf
				Else
					MouseClick("right")
					$timeforRightclick = TimerInit()
				EndIf
			EndIf


			$discipline = GetDisc()
			$hatred = GetHatred()
			$life = GetLifep()

			$diffSpell1 = TimerDiff($timeforSpell1)
			If $Spell1Activated = "True" And $life <= $LifeForSpell1 / 100 And $diffSpell1 > $DefayForSpell1 Then
				If $EnergySpell1 <> "" Then
					If $EnergySpell1 = "hatred" Then
						If $hatred > $EnergyNeedsSpell1 / $MaximumHatred Then
							Send($KeyForSpell1)
							$timeforSpell1 = TimerInit()
						EndIf
					Else
						If $discipline > $EnergyNeedsSpell1 / $MaximumDiscipline Then
							Send($KeyForSpell1)
							$timeforSpell1 = TimerInit()
						EndIf
					EndIf
				Else
					Send($KeyForSpell1)
					$timeforSpell1 = TimerInit()
				EndIf
			EndIf

			$discipline = GetDisc()
			$hatred = GetHatred()
			$life = GetLifep()

			$diffSpell2 = TimerDiff($timeforSpell2)
			If $Spell2Activated = "True" And $life <= $LifeForSpell2 / 100 And $diffSpell2 > $DefayForSpell2 Then
				If $EnergySpell2 <> "" Then
					If $EnergySpell2 = "hatred" Then
						If $hatred > $EnergyNeedsSpell2 / $MaximumHatred Then
							Send($KeyForSpell2)
							$timeforSpell2 = TimerInit()
						EndIf
					Else
						If $discipline > $EnergyNeedsSpell2 / $MaximumDiscipline Then
							Send($KeyForSpell2)
							$timeforSpell2 = TimerInit()
						EndIf
					EndIf
				Else
					Send($KeyForSpell2)
					$timeforSpell2 = TimerInit()
				EndIf
			EndIf

			$discipline = GetDisc()
			$hatred = GetHatred()
			$life = GetLifep()

			$diffSpell3 = TimerDiff($timeforSpell3)
			If $Spell3Activated = "True" And $life <= $LifeForSpell3 / 100 And $diffSpell3 > $DefayForSpell3 Then
				If $EnergySpell3 <> "" Then
					If $EnergySpell3 = "hatred" Then
						If $hatred > $EnergyNeedsSpell3 / $MaximumHatred Then
							Send($KeyForSpell3)
							$timeforSpell3 = TimerInit()
						EndIf
					Else
						If $discipline > $EnergyNeedsSpell3 / $MaximumDiscipline Then
							Send($KeyForSpell3)
							$timeforSpell3 = TimerInit()
						EndIf
					EndIf
				Else
					Send($KeyForSpell3)
					$timeforSpell3 = TimerInit()
				EndIf
			EndIf

			$discipline = GetDisc()
			$hatred = GetHatred()
			$life = GetLifep()

			$diffSpell4 = TimerDiff($timeforSpell4)
			If $Spell4Activated = "True" And $life <= $LifeForSpell4 / 100 And $diffSpell4 > $DefayForSpell4 Then
				If $EnergySpell4 <> "" Then
					If $EnergySpell4 = "hatred" Then
						If $hatred > $EnergyNeedsSpell4 / $MaximumHatred Then
							Send($KeyForSpell4)
							$timeforSpell4 = TimerInit()
						EndIf
					Else
						If $discipline > $EnergyNeedsSpell4 / $MaximumDiscipline Then
							Send($KeyForSpell4)
							$timeforSpell4 = TimerInit()
						EndIf
					EndIf
				Else
					Send($KeyForSpell4)
					$timeforSpell4 = TimerInit()
				EndIf
			EndIf


		Case "Monk"
			$MaximumSource = $MaximumSpirit
			actionForSpell($MaximumSource)
		Case "Barbarian"
			$MaximumSource = $MaximumFury
			actionForSpell($MaximumSource)
		Case "wizard"
			$MaximumSource = $MaximumArcane
			actionForSpell($MaximumSource)
		Case "WitchDoctor"
			$MaximumSource = $MaximumMana
			actionForSpell($MaximumSource)
	EndSwitch

EndFunc   ;==>checkForSpell


Func actionForSpell($MaximumSource)

	$life = GetLifep()
	Switch $nameCharacter
		Case "Monk"
			$source = GetSpirit()
		Case "Barbarian"
			$source = GetFury()
		Case "wizard"
			$source = GetArcane()
		Case "WitchDoctor"
			$source = GetMana()
	EndSwitch
	$diffRightClick = TimerDiff($timeforRightclick)
	If $RightClickSpell = "True" And $life <= $LifeForRightClickSpell / 100 And $diffRightClick > $RightClickSpellDelay Then
		If $RightClickSpellEnergy <> "" Then
			If $source > $RightClickSpellEnergyNeeds / $MaximumSource Then
				MouseClick("right")
				$timeforRightclick = TimerInit()
			EndIf
		Else
			MouseClick("right")
			$timeforRightclick = TimerInit()
		EndIf
	EndIf

	$life = GetLifep()
	Switch $nameCharacter
		Case "Monk"
			$source = GetSpirit()
		Case "Barbarian"
			$source = GetFury()
		Case "wizard"
			$source = GetArcane()
		Case "WitchDoctor"
			$source = GetMana()
	EndSwitch

	$diffSpell1 = TimerDiff($timeforSpell1)
	If $Spell1Activated = "True" And $life <= $LifeForSpell1 / 100 And $diffSpell1 > $DefayForSpell1 Then
		If $EnergySpell1 <> "" Then
			If $source > $EnergyNeedsSpell1 / $MaximumSource Then
				Send($KeyForSpell1)
				$timeforSpell1 = TimerInit()
			EndIf
		Else
			Send($KeyForSpell1)
			$timeforSpell1 = TimerInit()
		EndIf
	EndIf

	$life = GetLifep()
	Switch $nameCharacter
		Case "Monk"
			$source = GetSpirit()
		Case "Barbarian"
			$source = GetFury()
		Case "wizard"
			$source = GetArcane()
		Case "WitchDoctor"
			$source = GetMana()
	EndSwitch

	$diffSpell2 = TimerDiff($timeforSpell2)
	If $Spell2Activated = "True" And $life <= $LifeForSpell2 / 100 And $diffSpell2 > $DefayForSpell2 Then
		If $EnergySpell2 <> "" Then
			If $source > $EnergyNeedsSpell2 / $MaximumSource Then
				Send($KeyForSpell2)
				$timeforSpell2 = TimerInit()
			EndIf
		Else
			Send($KeyForSpell2)
			$timeforSpell2 = TimerInit()
		EndIf
	EndIf

	$life = GetLifep()
	Switch $nameCharacter
		Case "Monk"
			$source = GetSpirit()
		Case "Barbarian"
			$source = GetFury()
		Case "wizard"
			$source = GetArcane()
		Case "WitchDoctor"
			$source = GetMana()
	EndSwitch

	$diffSpell3 = TimerDiff($timeforSpell3)
	If $Spell3Activated = "True" And $life <= $LifeForSpell3 / 100 And $diffSpell3 > $DefayForSpell3 Then
		If $EnergySpell3 <> "" Then
			If $source > $EnergyNeedsSpell3 / $MaximumSource Then
				Send($KeyForSpell3)
				$timeforSpell3 = TimerInit()
			EndIf
		Else
			Send($KeyForSpell3)
			$timeforSpell3 = TimerInit()
		EndIf
	EndIf

	$life = GetLifep()
	Switch $nameCharacter
		Case "Monk"
			$source = GetSpirit()
		Case "Barbarian"
			$source = GetFury()
		Case "wizard"
			$source = GetArcane()
		Case "WitchDoctor"
			$source = GetMana()
	EndSwitch

	$diffSpell4 = TimerDiff($timeforSpell4)
	If $Spell4Activated = "True" And $life <= $LifeForSpell4 / 100 And $diffSpell4 > $DefayForSpell4 Then
		If $EnergySpell4 <> "" Then
			If $source > $EnergyNeedsSpell4 / $MaximumSource Then
				Send($KeyForSpell4)
				$timeforSpell4 = TimerInit()
			EndIf
		Else
			Send($KeyForSpell4)
			$timeforSpell4 = TimerInit()
		EndIf
	EndIf

EndFunc   ;==>actionForSpell
#ce
;;--------------------------------------------------------------------------------
;;############# Stats by YoPens
;;--------------------------------------------------------------------------------
Func FormatNumber($StringToFormat)
	Local $StringFormatted = ""
	Local $ArrayStringToFormat = StringSplit($StringToFormat, "")
	Local $counterForSeparator = 1
	For $i = $ArrayStringToFormat[0] To 1 Step -1
		If $counterForSeparator = 3 Then
			$StringFormatted = " " & $ArrayStringToFormat[$i] & $StringFormatted
			$counterForSeparator = 0
		Else
			$StringFormatted = $ArrayStringToFormat[$i] & $StringFormatted
		EndIf
		$counterForSeparator += 1
	Next
	Return $StringFormatted
EndFunc   ;==>FormatNumber


Func StatsDisplay()

        Local $index, $offset, $count, $item[4]
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
                $GF = Ceiling(GetAttribute($_MyGuid, $Atrib_Gold_Find) * 100)
                $MF = Ceiling(GetAttribute($_MyGuid, $Atrib_Magic_Find) * 100)
                $PR = GetAttribute($_MyGuid, $Atrib_Gold_PickUp_Radius)
                $MS = (GetAttribute($_MyGuid, $Atrib_Movement_Scalar_Capped_Total) - 1) * 100
        Else
                $GOLDInthepocket = $GOLD - $GOLDINI
                $GOLDMOY = $GOLDInthepocket / ($Totalruns - 1)
                $dif_timer_stat = TimerDiff($begin_timer_stat)
                $GOLDMOYbyH = $GOLDInthepocket * 3600000 / $dif_timer_stat


        EndIf

        ;stat XP

        ;Xp nécessaire pour passer un niveau de paragon


        If $Totalruns = 1 Then

                $NiveauParagon = GetAttribute($_MyGuid, $Atrib_Alt_Level)
                $ExperienceNextLevel = GetAttribute($_MyGuid, $Atrib_Alt_Experience_Next_Lo)
                $Expencours = $level[$NiveauParagon + 1] - $ExperienceNextLevel
                $Xp_Run = 0
                $Xp_Total = 0
                $Xp_Moy_Run = 0
                $Xp_Moy_Hrs = 0
                $time_Xp = 0
                _format_time($time_Xp)

        Else



                ;calcul de l'xp du run
                If $NiveauParagon = GetAttribute($_MyGuid, $Atrib_Alt_Level) Then; verification de level up (égalité => pas de level up

                        $Xp_Run = ($level[GetAttribute($_MyGuid, $Atrib_Alt_Level) + 1] - GetAttribute($_MyGuid, $Atrib_Alt_Experience_Next_Lo)) - $Expencours;experience run n - experience run n-1

                EndIf

                $Expencours = $level[GetAttribute($_MyGuid, $Atrib_Alt_Level) + 1] - GetAttribute($_MyGuid, $Atrib_Alt_Experience_Next_Lo)

                If $NiveauParagon <> GetAttribute($_MyGuid, $Atrib_Alt_Level) Then

                        $Xp_Run = $ExperienceNextLevel + $Expencours

                EndIf


                $Xp_Total = $Xp_Total + $Xp_Run
                $Xp_Moy_Run = $Xp_Total / ($Totalruns - 1)
                $Xp_Moy_Hrs = $Xp_Total * 3600000 / $dif_timer_stat
                $NiveauParagon = GetAttribute($_MyGuid, $Atrib_Alt_Level)
                $ExperienceNextLevel = GetAttribute($_MyGuid, $Atrib_Alt_Experience_Next_Lo)

                ;calcul temps avant prochain niveau
                $Xp_Moy_Sec = $Xp_Total * 1000 / $dif_timer_stat
                $time_Xp = Int($ExperienceNextLevel / $Xp_Moy_Sec) * 1000
                _format_time($time_Xp)
                $time_Xp = $dif_timer_stat_formater

        EndIf
        ;########

        _format_time($dif_timer_stat)
        $timer_stat_total = $dif_timer_stat_formater

        If $Totalruns = 1 Then
                $timer_stat_run_moyen = 0
                ;Lv_stat=lv
                ;Xp_next_stat=Xp_next
                ;Xprun=0
                ;Xptotal=0
                ;Xpmoyen=0
        Else
                $dif_timer_stat_moyen = $dif_timer_stat / ($Totalruns - 1)
                _format_time($dif_timer_stat_moyen)
                $timer_stat_run_moyen = $dif_timer_stat_formater
        EndIf



        $DebugMessage = "Nombre de Runs : " & $Totalruns & @CRLF
        $DebugMessage = $DebugMessage & "Nombre de Mort : " & $Death & @CRLF
        $DebugMessage = $DebugMessage & "Nombre de resurrection: " & $Res_compt & @CRLF
        $DebugMessage = $DebugMessage & "Nombre de Réparation/Vente : " & $RepairORsell & @CRLF
        $DebugMessage = $DebugMessage & "Nombre d'objet stocké dans le Coffre : " & $ItemToStash & @CRLF
        $DebugMessage = $DebugMessage & "Nombre d'objet Vendu : " & $ItemToSell & @CRLF
        $DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
        $DebugMessage = $DebugMessage & "GOLD Obtenu : " & formatNumber(Ceiling($GOLDInthepocket)) & @CRLF
        $DebugMessage = $DebugMessage & "GOLD Moyen par run : " & formatNumber(Ceiling($GOLDMOY)) & @CRLF
        $DebugMessage = $DebugMessage & "GOLD Moyen par heure : " & formatNumber(Ceiling($GOLDMOYbyH)) & @CRLF

        ;stats XP
        $DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF

        If ($Xp_Total < 1000000) Then ;afficher en "K"
                $DebugMessage = $DebugMessage & "XP Obtenu : " & Int($Xp_Total / 1000) & " K" & @CRLF
        EndIf
        If ($Xp_Total > 999999) Then ;afficher en "M"
                $DebugMessage = $DebugMessage & "XP Obtenu : " & Int($Xp_Total / 1000) / 1000 & " M" & @CRLF
        EndIf

        If ($Xp_Moy_Run < 1000000) Then ;afficher en "K"
                $DebugMessage = $DebugMessage & "XP Moyen par run : " & Int($Xp_Moy_Run / 1000) & " K" & @CRLF
        EndIf
        If ($Xp_Moy_Run > 999999) Then ;afficher en "M"
                $DebugMessage = $DebugMessage & "XP Moyen par run : " & Int($Xp_Moy_Run / 1000) / 1000 & " M" & @CRLF
        EndIf

        If ($Xp_Moy_Hrs < 1000000) Then ;afficher en "K"
                $DebugMessage = $DebugMessage & "XP Moyen par heure : " & Int($Xp_Moy_Hrs / 1000) & " K" & @CRLF
        EndIf
        If ($Xp_Moy_Hrs > 999999) Then ;afficher en "M"
                $DebugMessage = $DebugMessage & "XP Moyen par heure : " & Int($Xp_Moy_Hrs / 1000) / 1000 & " M" & @CRLF
        EndIf
        ;$DebugMessage = $DebugMessage & "temps avant prochain niveau : " $ExperienceNextLevel/ & " M" & @CRLF
        $DebugMessage = $DebugMessage & "temps avant prochain niveau : " & $time_Xp & @CRLF
        $DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
        ;$DebugMessage = $DebugMessage & "XP Moyen par heure : " & $Xp_Moy_Hrs & @CRLF
        ;$DebugMessage = $DebugMessage & "XP avant prochain niveau : " & int($ExperienceNextLevel/1000)/1000 &" M" & @CRLF
        ;$DebugMessage = $DebugMessage & "niveau paragon actuel : " & $NiveauParagon & @CRLF

        ;$DebugMessage = $DebugMessage & "#################################"& @CRLF

        ;$DebugMessage = $DebugMessage & "test 1 : " & $level[$NiveauParagon+1] & @CRLF
        ;$DebugMessage = $DebugMessage & "exp en cours : " & int($Expencours/1000)/1000 &" M" &@CRLF
        ;$DebugMessage = $DebugMessage & "Xp_Run : " & int($Xp_Run/1000)/1000 &" M" &@CRLF
        ;$DebugMessage = $DebugMessage & "#################################"& @CRLF
        ;#########


        $DebugMessage = $DebugMessage & "Durée Total : " & $timer_stat_total & @CRLF
        $DebugMessage = $DebugMessage & "Durée moyenne d'un run : " & $timer_stat_run_moyen & @CRLF
        $DebugMessage = $DebugMessage & "success ratio : " & $successratio & @CRLF
        $DebugMessage = $DebugMessage & "Nombre de déconnections : " & $disconnectcount & @CRLF
        $DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
        $DebugMessage = $DebugMessage & "Statistique du Personnage : " & @CRLF
        $DebugMessage = $DebugMessage & "Gold Find (Hors Paragon & Compagnon) : " & $GF & " %" & @CRLF
        $DebugMessage = $DebugMessage & "Magic Find (Hors Paragon & Compagnon) : " & $MF & " %" & @CRLF
        $DebugMessage = $DebugMessage & "PickUp Radius : " & $PR & @CRLF
        $DebugMessage = $DebugMessage & "Movement Speed : " & $MS & " %" & @CRLF
		$DebugMessage = $DebugMessage & "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF
	    $DebugMessage = $DebugMessage & "Heure début run: " & @HOUR & ":" & @MIN & @CRLF

        $MESSAGE = $DebugMessage
        ToolTip($MESSAGE, $DebugX, $DebugY)

        $Totalruns = $Totalruns + 1 ;compte le nombre de run

EndFunc   ;==>StatsDisplay

;;--------------------------------------------------------------------------------
;;############# END ########### of Stats by YoPens
;;--------------------------------------------------------------------------------
Func _format_time($time_milisecond)
	Local $seconde_arrondi
	Local $minute
	Local $seconde
	Local $heure
	If ($time_milisecond < 60000) Then
		$dif_timer_stat_formater = Round(($time_milisecond / 1000), 2) & " secondes"
	ElseIf (($time_milisecond >= 60000) And ($time_milisecond < 3600000)) Then
		$seconde_arrondi = Int($time_milisecond / 1000)
		$minute = Int($seconde_arrondi / 60)
		$seconde = Round((($time_milisecond / 1000) - $minute * 60), 0)
		$dif_timer_stat_formater = $minute & " min " & $seconde & " sec"
	Else
		$seconde_arrondi = Int($time_milisecond / 1000)
		$heure = Int($seconde_arrondi / 3600)
		$minute = Int((($seconde_arrondi - $heure * 3600) / 60))
		$seconde = Round((($time_milisecond / 1000) - $heure * 3600 - $minute * 60), 0)
		$dif_timer_stat_formater = $heure & "h " & $minute & "m " & $seconde & "s"
	EndIf
	Return $dif_timer_stat_formater
EndFunc   ;==>_format_time

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
EndFunc   ;==>shrine



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
; Functions:                     mesurestart() mesureend()
; Description:    Mesurer...
;;--------------------------------------------------------------------------------
Func mesureStart()
	Global $mesuredebug = TimerInit() ;;;;;;;;;;;;;;
	$init = TimerInit()
EndFunc   ;==>mesureStart

Func mesureEnd($nom)
	Local $difmesuredebug = TimerDiff($mesuredebug) ;;;;;;;;;;;;;
	ConsoleWrite("Mesure " & $nom & " : " & $difmesuredebug & @CRLF) ;FOR DEBUGGING;;;;;;;;;;;;
EndFunc   ;==>mesureEnd



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
;~                                 ConsoleWrite(@CRLF & $uitext)
				If StringInStr($uitext, 'nulle part') Or StringInStr($uitext, 'inventaire') Or StringInStr($uitext, 'no place') Or StringInStr($uitext, 'enough inventory') Then
					ConsoleWrite(@CRLF & $uitext)
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

				If  $action_spell = 1  and IterateFilterZone($dist) Then
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
				If  IterateFilterZone($dist) Then
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

#cs
Func offset_spell_search($str)
	$var = ""
	If $str = "" Then
		$var = "false"
	Else

		$var = Eval($str)
		If $var = "" Then
			$var = "wrong"
		EndIf
	EndIf
	;_log("search :" & $var)
	Return $var

EndFunc   ;==>offset_spell_search
#ce

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
			_randomclick(398, 349)
			_randomclick(398, 349)
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

	$PortBack = False


	While Not _intown()
		if Not _TownPortalnew() Then
			$GameFailed=1
			Return False
		EndIf

	WEnd

	$PortBack = true


	StashAndRepair()

	If $PortBack Then
		SafePortBack()

		While Not offsetlist()
			Sleep(10)
		WEnd
	EndIf

	$games = 0

EndFunc

Func ClickOnStashTab($num)
	if $num > 3 OR $num < 1 Then
		_log("ERROR Impossible to open this tab from stash")
		$num = 1
	Endif

	if $num = 1 Then
		ClickUI("Root.NormalLayer.stash_dialog_mainPage.tab_1")
	elseif $num = 2 Then
		ClickUI("Root.NormalLayer.stash_dialog_mainPage.tab_1")
	else
		ClickUI("Root.NormalLayer.stash_dialog_mainPage.tab_1")
	EndIf
EndFunc

Func StashAndRepair()

	_log("Func StashAndRepair")
	$RepairORsell += 1
	$item_to_stash = 0
	$SkippedMove = 0

	While _checkInventoryopen() = False
		Send("i")
		Sleep(Random(200, 300))
	WEnd

	While Not offsetlist()
		Sleep(10)
	WEnd

	Sleep(Random(500, 1000))

	_log('Filter Backpack')
	$items = FilterBackpack()
	$ToStash = _ArrayFindAll($items, "Stash", 0, 0, 0, 1, 2)

	If $ToStash <> -1 Then
		Send("{SPACE}")
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
					_log('Stash is full : Botting stopped')
					Terminate()
				EndIf

				Sleep(5000)

			Else
				$ItemToStash = $ItemToStash + 1
			EndIf
		Next


		Sleep(Random(50, 100))
		Send("{SPACE}")
		Sleep(Random(100, 150))

		;****************************************************************
		If NOT Verif_Attrib_GlobalStuff() Then
			_log("CHANGEMENT DE STUFF ON TOURNE EN ROND (Stash and Repair - Stash)!!!!!")
			antiidle()
		EndIf
		;****************************************************************

	EndIf


	Sleep(Random(100, 200))
	Send("{SPACE}")
	Sleep(Random(100, 200))
	Sleep(Random(500, 1000))

	Repair()




	;Trash
	$ToTrash = _ArrayFindAll($items, "Trash", 0, 0, 0, 1, 2)

	If not @error Then

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
		Send("{SPACE}")
		Sleep(Random(100, 200))

		;****************************************************************
		If NOT Verif_Attrib_GlobalStuff() Then
			_log("CHANGEMENT DE STUFF ON TOURNE EN ROND (Stash and Repair - vendeur)!!!!!")
			antiidle()
		EndIf
		;****************************************************************
	EndIf

	Sleep(Random(100, 200))
	Send("{SPACE}")
	Sleep(Random(100, 200))

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



; #FUNCTION# =====================================================================
; Name...........: __ArrayConcatenate
; Description ...: Concatenate two 1D or 2D arrays
; Syntax.........: __ArrayConcatenate(ByRef $avArrayTarget, Const ByRef $avArraySource)
; Parameters ....: $avArrayTarget - The array to concatenate onto
;				  $avArraySource - The array to concatenate from - Must be 1D or 2D to match $avArrayTarget,
;								   and if 2D, then Ubound($avArraySource, 2) <= Ubound($avArrayTarget, 2).
; Return values .: Success - Index of last added item
;				  Failure - -1, sets @error to 1 and @extended per failure (see code below)
; Author ........: Ultima
; Modified.......: PsaltyDS - 1D/2D version, changed return value and @error/@extended to be consistent with __ArrayAdd()
; Remarks .......:
; Related .......: __ArrayAdd, _ArrayPush
; Link ..........;
; Example .......; Yes
; ===============================================================================
Func __ArrayConcatenate(ByRef $avArrayTarget, Const ByRef $avArraySource)
	If Not IsArray($avArrayTarget) Then Return SetError(1, 1, -1); $avArrayTarget is not an array
	If Not IsArray($avArraySource) Then Return SetError(1, 2, -1); $avArraySource is not an array

	Local $iUBoundTarget0 = UBound($avArrayTarget, 0), $iUBoundSource0 = UBound($avArraySource, 0)
	If $iUBoundTarget0 <> $iUBoundSource0 Then Return SetError(1, 3, -1); 1D/2D dimensionality did not match
	If $iUBoundTarget0 > 2 Then Return SetError(1, 4, -1); At least one array was 3D or more

	Local $iUBoundTarget1 = UBound($avArrayTarget, 1), $iUBoundSource1 = UBound($avArraySource, 1)

	Local $iNewSize = $iUBoundTarget1 + $iUBoundSource1
	If $iUBoundTarget0 = 1 Then
		; 1D arrays
		ReDim $avArrayTarget[$iNewSize]
		For $i = 0 To $iUBoundSource1 - 1
			$avArrayTarget[$iUBoundTarget1 + $i] = $avArraySource[$i]
		Next
	Else
		; 2D arrays
		Local $iUBoundTarget2 = UBound($avArrayTarget, 2), $iUBoundSource2 = UBound($avArraySource, 2)
		If $iUBoundSource2 > $iUBoundTarget2 Then Return SetError(1, 5, -1); 2D boundry of source too large for target
		ReDim $avArrayTarget[$iNewSize][$iUBoundTarget2]
		For $r = 0 To $iUBoundSource1 - 1
			For $c = 0 To $iUBoundSource2 - 1
				$avArrayTarget[$iUBoundTarget1 + $r][$c] = $avArraySource[$r][$c]
			Next
		Next
	EndIf

	Return $iNewSize - 1
EndFunc   ;==>__ArrayConcatenate

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

	Return "true"
EndFunc   ;==>LoadingSNOExtended


Func Init_grablistFile()
	Dim $txttoarray[1]
	;local $load_file = ""
	Local $compt_line = 0

	Local $file = FileOpen($grabListFile, 0)
	If $file = -1 Then
		MsgBox(0, "Error", "Unable to open file : " & $grabListFile)
		Exit
	EndIf

	While 1 ;Boucle de traitement de lecture du fichier txt
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop

		If $line <> "" Then
			$line = StringLower($line)
			ReDim $txttoarray[$compt_line + 1]
			$txttoarray[$compt_line] = $line
			$compt_line += 1
		EndIf
	WEnd

	FileClose($file)

	Global $tab_grablist[1][2]
	Global $grablist = ""
	Local $compt = 0

	For $i = 0 To UBound($txttoarray) - 1
		If StringInStr($txttoarray[$i], "=", 0) Then
			$var_temp = StringSplit($txttoarray[$i], "=", 2)

			$var_temp[0] = trim($var_temp[0])

			ReDim $tab_grablist[$compt + 1][2]

			$tab_grablist[$compt][0] = $var_temp[0]
			$tab_grablist[$compt][1] = $var_temp[1]

			Assign($var_temp[0], $var_temp[1], 2)
			$compt += 1
		Else

			If $grablist = "" Then
				$grablist = $txttoarray[$i]
			Else
				$grablist = $grablist & "|" & $txttoarray[$i]
			EndIf

		EndIf
	Next

EndFunc   ;==>Init_grablistFile

Func Init_GrabListTab()

	Dim $tab_temp = StringSplit($grablist, "|", 2)

	Local $rules_ilvl = '(?i)\[ilvl:([0-9]{1,2})\]'
	Local $rules_quality = '(?i)\[q:([0-9]{1,2})\]'
	Local $rules_filtre = '(?i)\(([[:ascii:]+]+)\)' ;enleve les "(" de premier niveau

	Local $i = 0, $detect = 0
	Global $GrabListTab[UBound($tab_temp)][5]
	For $y = 0 To UBound($tab_temp) - 1
		$tab_buff = StringLower(trim($tab_temp[$y]))

		If StringRegExp($tab_buff, $rules_ilvl) = 1 Then ;patern declaration ilvl
			$tab_RegExp = StringRegExp($tab_buff, $rules_ilvl, 2)
			$tab_buff = StringReplace($tab_buff, $tab_RegExp[0], "", 0, 2)

			$curr_ilvl = $tab_RegExp[1]
		Else
			$curr_ilvl = 0
		EndIf


		If StringRegExp($tab_buff, $rules_quality) = 1 Then ;patern declaration quality
			$tab_RegExp = StringRegExp($tab_buff, $rules_quality, 2)
			$tab_buff = StringReplace($tab_buff, $tab_RegExp[0], "", 0, 2)
			$curr_quality = $tab_RegExp[1]
		Else
			$curr_quality = 0
		EndIf


		If StringRegExp($tab_buff, $rules_filtre) = 1 Then ;patern declaration filtre
			$tab_RegExp = StringRegExp($tab_buff, $rules_filtre, 2)
			$tab_buff = StringReplace($tab_buff, $tab_RegExp[0], "", 0, 2)
			$tab_RegExp[1] = StringReplace($tab_RegExp[1], "and", " and ", 0, 2)
			$tab_RegExp[1] = StringReplace($tab_RegExp[1], "or", " or ", 0, 2)

			For $x = 0 To UBound($tab_grablist) - 1
				If StringInStr($tab_RegExp[1], $tab_grablist[$x][0], 0) Then
					$tab_RegExp[1] = StringReplace($tab_RegExp[1], $tab_grablist[$x][0], $tab_grablist[$x][1], 0, 2)
				EndIf
			Next

			$curr_filtre = $tab_RegExp[1]
			$curr_filtre_str = give_str_from_filter($tab_RegExp[1])
		Else
			$curr_filtre = 0
			$curr_filtre_str = ""
		EndIf

		For $x = 0 To UBound($tab_grablist) - 1
			If StringInStr($tab_buff, $tab_grablist[$x][0], 0) Then
				$tab = StringSplit($tab_grablist[$x][1], "|", 2)
				For $Z = 0 To UBound($tab) - 1

					If $Z > 0 Then
						ReDim $GrabListTab[UBound($GrabListTab) + 1][5]
					EndIf

					$GrabListTab[$i][0] = $tab[$Z]
					$GrabListTab[$i][1] = $curr_ilvl
					$GrabListTab[$i][2] = $curr_quality
					$GrabListTab[$i][3] = $curr_filtre
					$GrabListTab[$i][4] = $curr_filtre_str

					$i += 1
				Next
				$detect = 1
			EndIf
		Next

		If $detect = 0 Then
			$GrabListTab[$i][0] = $tab_buff
			$GrabListTab[$i][1] = $curr_ilvl
			$GrabListTab[$i][2] = $curr_quality
			$GrabListTab[$i][3] = $curr_filtre
			$GrabListTab[$i][4] = $curr_filtre_str
			$i += 1
		EndIf

		$detect = 0
	Next
EndFunc   ;==>Init_GrabListTab

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

	InteractByActorName('hearthPortal')
	$Newarea = GetLevelAreaId()

	Local $areatry = 0
	While $Newarea = $Curentarea And $areatry <= 10
		$Newarea = GetLevelAreaId()
		Sleep(500)
		$areatry = $areatry + 1
	WEnd

	If $Newarea <> $Curentarea Then
		_log('succesfully teleported back : ' & $Curentarea & ":" & $Newarea)
		While Not offsetlist()
			Sleep(10)
		WEnd
	Else
		_log('We failed to teleport back')
	EndIf
EndFunc   ;==>SafePortBack

Func xml_to_item($name, $stats)
	$rules_name = "(?i){c:[a-z0-9]*}([a-z0-9éèêëîïìâàäûüùöôòÿ" & @CRLF & " \+ \% \- \’ \' ]*){/c}"
	$rules_stats = "(?i){c:[a-z0-9]*}([a-z0-9éèêëîïìâàäûüùöôòÿ" & @CRLF & " \+ \% \- \’ \' ]*){/c}"
	;$rules_stat = "(?i){c:[a-z1-9]*}(.*){/c}"
	$str = "<item>" & @CRLF
	If StringRegExp($name, $rules_name) = 1 Then ;patern declaration ilvl
		$name_item = StringRegExp($name, $rules_name, 2)
		;MsgBox(1, "", $name_item[1])
		$name = "<name>" & $name_item[1] & "</name>" & @CRLF
	EndIf

	If StringRegExp($stats, $rules_stats) = 1 Then
		$stats_item = StringRegExp($stats, $rules_stats, 3)
		;_ArrayDisplay($stats_item)
		$temp_stats = ""
		For $i = 0 To UBound($stats_item) - 1
			$temp_stats = $temp_stats & "<stats>- " & $stats_item[$i] & "</stats>" & @CRLF

		Next
	EndIf
	$str = $str & $name & $temp_stats & "</item>" & @CRLF & @CRLF
	Return $str
EndFunc   ;==>xml_to_item

Func Xml_To_Str($str, $load_file)
	Local $file = FileOpen($load_file, 1)
	If $file = -1 Then
		MsgBox(0, "Error", "Unable to open xml file : " & $load_file)
		Exit

	EndIf
	FileWrite($file, $str)
	FileClose($file)
EndFunc   ;==>Xml_To_Str


Func Ftp_Upload_To_Xml($file)
	If Not $ftpserver = "" And Not $ftpusername = "" And Not $ftppass = "" Then
		$Open = _FTPOpen('MyFTP Control')
		$Conn = _FTPConnect($Open, $ftpserver, $ftpusername, $ftppass)
		$Ftpp = _FtpPutFile($Conn, $file, "statistique_D3/" & $file)
		$Ftpc = _FTPClose($Open)
	EndIf
EndFunc   ;==>Ftp_Upload_To_Xml


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
		if $Gest_affixe_ByClass = "true" Then
			$Gestion_affixe_loot = "false"
			$Gestion_affixe = "false"
			_log("Monk detected, Gest Affix disabled")
		EndIf
	ElseIf StringLower(Trim($nameCharacter)) = "barbarian" Then
		Dim $tab_skill_temp = $Barbarian_Skill_Table
		if $Gest_affixe_ByClass = "true" Then
			$Gestion_affixe_loot = "false"
			$Gestion_affixe = "false"
			_log("Barbarian detected, Gest Affix disabled")
		EndIf
	ElseIf StringLower(Trim($nameCharacter)) = "witchdoctor" Then
		Dim $tab_skill_temp = $WitchDoctor_Skill_Table
		if $Gest_affixe_ByClass = "true" Then
			$Gestion_affixe_loot = "true"
			$Gestion_affixe = "true"
			_log("WitchDoctor detected, Gest Affix Enabled")
		EndIf
	ElseIf StringLower(Trim($nameCharacter)) = "demonhunter" Then
		Dim $tab_skill_temp = $DemonHunter_skill_Table
		if $Gest_affixe_ByClass = "true" Then
			$Gestion_affixe_loot = "true"
			$Gestion_affixe = "true"
			_log("DemonHunter detected, Gest Affix Enabled")
		EndIf
	ElseIf StringLower(Trim($nameCharacter)) = "wizard" Then
		Dim $tab_skill_temp = $Wizard_skill_Table
		if $Gest_affixe_ByClass = "true" Then
			$Gestion_affixe_loot = "true"
			$Gestion_affixe = "true"
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

	Global $Byte_Full_Inventory[2]
	Global $Byte_Full_Stash[2]
	Global $Byte_Boss_TpDeny[2]
	Global $Byte_NoItem_Identify[2]

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

#cs
Func GetLocalPlayer()
	Global $ObjManStorage = 0x7CC ;0x794
	$v0 = _MemoryRead(_MemoryRead($ofs_objectmanager, $d3, 'int') + 0x984, $d3, 'int') ;0x94C/934
	$v1 = _MemoryRead(_MemoryRead($ofs_objectmanager, $d3, 'int') + $ObjManStorage + 0xA8, $d3, 'int')

	if $v0 <> 0 AND _MemoryRead($v0, $d3, 'int') <> -1 AND $v1 <> 0 Then
		return 0x8008 * _MemoryRead($v0, $d3, 'int') + $v1 + 0x58
	Else
		return 0
	EndIf
EndFunc
#ce

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


Func _TownPortalnew($mode=0)

$compt=0

	While Not _intown()

		_log("tour de boucle _intown")

		$compt += 1
		$compt_while = 0
		$timer = 0
		$try = 0

		if $mode<>0 AND $compt > $mode Then
			_log("Too Much TP try !!!")
			ExitLoop
		EndIF

		_log("enclenche attack")
		$grabskip = 1
			Attack()
		$grabskip = 0

		Sleep(100)

		$CurrentLoc = getcurrentpos()
		MoveToPos($CurrentLoc[0] + 5, $CurrentLoc[1] + 5, $CurrentLoc[2], 0, 6)


		If _playerdead() = False Then

			sleep(250)
				send("t")
			sleep(250)

			If Detect_UI_error(2) AND NOT _intown() Then
				_log('Detection Asmo room')
				Return False
			EndIf

			$Current_area = GetLevelAreaId()

			_log("enclenchement fastCheckui de la barre de loading")

			while fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068)
				if $compt_while = 0 Then
					_log("enclenchement du timer")
					$timer = timerinit()
				EndIF

				sleep(100)
				$compt_while += 1
			WEnd

			_log("compare time to tp -> " & TimerDiff($timer) & "> 3700")
			if TimerDiff($timer) > 3700 Then
				while NOT _intown() AND $try < 6
					_log("on a peut etre reussi a tp, on reste inerte pendant 6sec voir si on arrive en ville, tentative -> " & $try)
					$try += 1
					sleep(1000)
				WEnd
			EndIf

				Sleep(500)


				if $Current_area <> GetLevelAreaId() Then
					_log("Changement d'arreat, on quite la boucle")
					ExitLoop
				EndIf

		Else
			_log("Vous etes morts lors d'une tentative de teleporte !!!")
			Return False
		EndIf

		sleep(100)
		$PortBack = True
	WEnd

	_log("on a renvoyer true, quite bien la fonction")
	While Not offsetlist()
		Sleep(10)
	WEnd

	return true
EndFunc


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
                 if $distance_centre_affixe<$item_safe[$aa][10] then
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
        Dim $item_maff_move = IterateFilterAffix()
        If IsArray($item_maff_move) Then
           $a=0
			while $a<=ubound($item_maff_move)-1
			   checkforpotion()
			   mouseup('left')
;~ 			   $dist_aff=sqrt(($_x_aff-$item_maff_move[$a][2])*($_x_aff-$item_maff_move[$a][2]) + ($_y_aff-$item_maff_move[$a][3])*($_y_aff-$item_maff_move[$a][3]) + ($_z_aff-$item_maff_move[$a][4])*($_z_aff-$item_maff_move[$a][4]))
			   if $item_maff_move[$a][9]<$item_maff_move[$a][10] and _playerdead()=false then
				  dim $move_coords[2]
				  $move_coords=zone_safe($_x_aff,$_y_aff,$item_maff_move,$_z_aff,$x_mob,$y_mob)
				  $Coords_affixe = FromD3toScreenCoords($move_coords[0],$move_coords[1],$_z_aff)
				  Mousemove($Coords_affixe[0], $Coords_affixe[1], 3)
				  GestSpellcast(0, 0, 0)
				  MouseClick("middle")
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

Func IterateFilterAffix()
        Local $index, $offset, $count, $item[10]
        startIterateObjectsList($index, $offset, $count)
        Dim $item_affix_2D[1][11]
        Local $i = 0
	    $pv_affix=getlifep()
        $compt = 0
;~ 		 $ii=0
        While iterateObjectsList($index, $offset, $count, $item)
			$compt += 1
			If Is_Affix($item,$pv_affix)  Then
			   ReDim $item_affix_2D[$i + 1][11]
			   For $x = 0 To 9
				  $item_affix_2D[$i][$x] = $item[$x]
			   Next

			   if StringInStr($item[1],"molten_trail") then $item_affix_2D[$i][10] = $range_lave
			   if StringInStr($item[1],"Desecrator") then $item_affix_2D[$i][10] = $range_profa
			   if (StringInStr($item[1],"bomb_buildup") or StringInStr($item[1],"Icecluster") or stringinstr($item[1],"Molten_deathExplosion") or stringinstr($item[1],"Molten_deathStart")) then  $item_affix_2D[$i][10] = $range_ice
			   if (StringInStr($item[1],"demonmine_C") or StringInStr($item[1],"Crater_DemonClawBomb")) then $item_affix_2D[$i][10] = $range_mine
			   if StringInStr($item[1],"creepMobArm") then $item_affix_2D[$i][10] = $range_arm
			   if (StringInStr($item[1],"spore") or StringInStr($item[1],"Plagued_endCloud") or StringInStr($item[1],"Poison")) then $item_affix_2D[$i][10] = $range_peste
			   if StringInStr($item[1],"ArcaneEnchanted_petsweep") then $item_affix_2D[$i][10] = $range_arcane

;~ 			   if $item_affix_2D[$i][10]-$item_affix_2D[$i][9]>0 then $ii=$ii+1

			   $i += 1
			EndIf
        WEnd
;~  or $ii=0
        If $i = 0 Then
                Return False
        Else

                _ArraySort($item_affix_2D, 0, 0, 0, 9)

                Return $item_affix_2D
        EndIf
 EndFunc   ;==>IterateFilterAffix

$BanAffixList="poison_humanoid|"&$BanAffixList

 Func Is_Affix($item,$pv=0)
	if $item[9]<50 then
                 if ((StringInStr($item[1],"bomb_buildup") and $pv<=$Life_explo/100 ) or _
					(StringInStr($item[1],"demonmine_C") and $pv<=$Life_mine/100)  or _
					(StringInStr($item[1],"creepMobArm") and $pv<=$Life_arm/100 )  or _
					(StringInStr($item[1],"Crater_DemonClawBomb") and $pv<=$Life_mine/100 )  or _
					(stringinstr($item[1],"Molten_deathExplosion") and $pv<=$Life_explo/100 ) or _
					(stringinstr($item[1],"Molten_deathStart") and $pv<=$Life_explo/100 )   or _
					(StringInStr($item[1],"icecluster") and $pv<=$Life_ice/100 )   or _
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

	Send("{SPACE}")
	sleep(200)
	Send("{SPACE}")
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
                if NOT fastcheckuiitemvisible("Root.NormalLayer.game_dialog_backgroundScreen.loopinganimmeter", 1, 1068) Then
                        InteractByActorName("All_Book_Of_Cain")
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

Func GameState()
	;1 // In Game
	;0 // Loading Screen
	;5 // Menu
	;return _memoryRead(_memoryRead($ObjManStorage ,$d3, "ptr") + 0x900, $d3, "ptr")
Endfunc
