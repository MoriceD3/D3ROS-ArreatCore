#include-once

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
;
; Fichier inclus uniquement en mode dev
;

HotKeySet("{F1}", "Testing")
HotKeySet("{F4}", "Testing_IterateObjetcsList")
;HotKeySet("{F6}", "Read_Scene")
;HotKeySet("{F7}", "Drawn")
HotKeySet("{F8}", "DebugMarkPos")
HotKeySet("{F11}", "DebugMonsterListing")

HotKeySet("{F10}", "ShowDebugTools")

Opt("GUIOnEventMode", 1)

Global $debugToolsHandle

Func ShowDebugTools()
	$debugToolsHandle = GUICreate("Debug tools", 200, 400, Default, Default, $WS_BORDER, $WS_EX_TOPMOST)
	If $debugToolsHandle = 0 Then
		_Log("Problem starting debug tools", $LOG_LEVEL_ERROR)
		Return
	EndIf
	GUISetOnEvent($GUI_EVENT_CLOSE, "On_DebugTools_Close")

	$hButton1 = GUICtrlCreateButton("Enregistrer position", 10, 10, 180, 30)
    GUICtrlSetOnEvent(-1, "DebugMarkPos")
    $hButton2 = GUICtrlCreateButton("Afficher liste des monstres", 10, 50, 180, 30)
    GUICtrlSetOnEvent(-1, "DebugMonsterListing")
    $hButton3 = GUICtrlCreateButton("Lister les bountys", 10, 90, 180, 30)
    GUICtrlSetOnEvent(-1, "DebugListBounties")
    $hButton4 = GUICtrlCreateButton("Lister l'UI visible", 10, 130, 180, 30)
    GUICtrlSetOnEvent(-1, "DebugUi")


    GUICtrlCreateLabel("Les résultats sont sauvés dans debug_tools.txt", 10, 340, 180, 30)
	GUISetState()
EndFunc

Func _logDebugTools($line)
  $file = FileOpen(@ScriptDir & "\debug_tools.txt", 1)
  If $file = -1 Then
     ConsoleWrite("!Log file error, can not be opened !")
     Return
  Else
     FileWrite($file, $line & @CRLF)
  EndIf
  FileClose($file)
EndFunc

Func DebugListBounties() 
	ListBounties()
EndFunc

Func DebugMarkPos()
	$currentloc = GetCurrentPos()
	$markpos = $currentloc[0] & ", " & $currentloc[1] & ", " & $currentloc[2] & ", 1, 25"
	_logDebugTools($markpos)
	_log($markpos , $LOG_LEVEL_DEBUG)
EndFunc

Func DebugMonsterListing()
	MonsterListing(True)
EndFunc

Func DebugUi()
	ListUI(1, True)
EndFunc

Func On_DebugTools_Close()
	GUIDelete($debugToolsHandle)
EndFunc

;;--------------------------------------------------------------------------------
;;	Func listquest
;;
;;  Browse available quest
;;
;;  QuestId = id of the quest
;;  Quest_Area_ID = Area id of the quest
;;  Quest_State = Status of the quest (0 : NotReached // 1 : Current // 2 : Finished // 3 : Finished but failed)
;;  Step = no idea
;;  Area id and Quest Id can be found in lib/ area.txt quest.txt
;;
;; !! This is just a Demo function !!
;;--------------------------------------------------------------------------------
Func Listquest()
$arealist = FileRead("lib\area.txt")

$QuestMan_A=0x8b8
$QuestMan_B=0x1c

$_itrQuestManA     = _MemoryRead($_itrObjectManagerA + $QuestMan_A, $d3, 'ptr')
$_Curr_Quest_Ofs = _MemoryRead($_itrQuestManA + $QuestMan_B, $d3, 'ptr')

while $_Curr_Quest_Ofs <> 0

_log("Current Quest Ofs : " & $_Curr_Quest_Ofs)

	$Quest_ID = _MemoryRead($_Curr_Quest_Ofs , $d3, 'int')
_log("Quest ID : " & hex($Quest_ID))
	$Quest_Area_ID = _MemoryRead($_Curr_Quest_Ofs + 0x8 , $d3, 'int')

If $Quest_Area_ID > 0 Then
	Local $pattern = "([\w'-]{5,80})\t\W\t" & $Quest_Area_ID
	$asResult = StringRegExp($arealist, $pattern, 1)

	 If not @error Then
	_log("This Quest is in map : "  & $asResult[0])
Else
	_log("!!!! That Area Need to be determinated in the .txt file !!!!!!")
	EndIf
Endif

_log("Quest Area id : " & $Quest_Area_ID)
	$Quest_State = _MemoryRead($_Curr_Quest_Ofs + 0x14 , $d3, 'int')
_log("Quest State : " & $Quest_State)
	$Quest_Step = _MemoryRead($_Curr_Quest_Ofs + 0x18 , $d3, 'int')
_log("Quest Step : " & $Quest_Step)

_log("=================================")
$_Curr_Quest_Ofs = _MemoryRead( $_Curr_Quest_Ofs + 0x168, $d3, 'ptr')
Wend

Endfunc ;==> Listquest

Func IterateObjectListV2()

	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)
	Dim $item_buff_2D[1][$TableSizeGuidStruct]
	Local $z = 0

	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')

	dim $item[$TableSizeGuidStruct]

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

			$Item[10] = DllStructGetData($iterateObjectsStruct, 10) ; z Foot
			$Item[11] = DllStructGetData($iterateObjectsStruct, 11) ; z Foot
			$Item[12] = DllStructGetData($iterateObjectsStruct, 12) ; z Foot

			$item[9] = GetDistanceWithoutReadPosition($CurrentLoc, $Item[10], $Item[11], $Item[12])

					ReDim $item_buff_2D[$z + 1][$TableSizeGuidStruct]

					For $x = 0 To $TableSizeGuidStruct - 1
						$item_buff_2D[$z][$x] = $item[$x]
					Next
					$z += 1


		EndIf
		$iterateObjectsStruct = ""
		Next

	$iterateObjectsListStruct = ""

	return $item_buff_2D

EndFunc

Func ListBounties()
	Local $hTimer = TimerInit()
	While Not offsetlist() And TimerDiff($hTimer) < 60000 ; 60secondes
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

	While $_Curr_Quest_Ofs <> 0
		$Quest_ID = _MemoryRead($_Curr_Quest_Ofs , $d3, 'int')
		$Quest_Area_ID = _MemoryRead($_Curr_Quest_Ofs + 0x8 , $d3, 'int')
		$Quest_State = _MemoryRead($_Curr_Quest_Ofs + 0x14 , $d3, 'int')

		Local $pattern = $Quest_ID & "#[\d\w]*#(\d)#([\w_]*)#(.*)"
		$asResult = StringRegExp($snoSequencelist, $pattern, 1)
		If Not @error Then
			_Log("Bounty known : " & $Quest_ID & " -> " & $asResult[1] & " in act " & $asResult[0] & " with sequence : " & $asResult[2])
		Else
			_log("Bounty not known : " & $Quest_ID & " (" & Hex($Quest_ID) & ")" ,$LOG_LEVEL_ERROR)
		EndIf
		$_Curr_Quest_Ofs = _MemoryRead( $_Curr_Quest_Ofs + 0x168, $d3, 'ptr')
	Wend
Endfunc ;==> GetBountySequences

Func IsBountyKnown($bountyName)
	$file = FileOpen("sequence/_bounty_sequences.txt", 0)
	$Result = False
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then
			ExitLoop
		 EndIf
		If StringInStr($line, $bountyName) Then
			Return True
		EndIf
	WEnd
	FileClose($file)
	Return $Result
EndFunc


Func List_Bounties($debug = False) 

	If WinExists("[CLASS:D3 Main Window Class]") Then
		WinActivate("[CLASS:D3 Main Window Class]")
		WinSetOnTop("[CLASS:D3 Main Window Class]", "", 1)
		Sleep(300)
	EndIf

	While Not _checkWPopen() And Not _playerdead() And Not _checkdisconnect()
		Send("M")
		Sleep(100)
	WEnd

	$Table_BountyAct = StringSplit("1|2|3|4|5","|",2)
	$SeqList = ""
	$NameUI = "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.BountyOverlay.BountyContainer.Bounties._content._stackpanel._tilerow0._item"
	_log("Listing unknown bounties : ")
	For $i = 0 To UBound($Table_BountyAct) - 1
		SwitchAct($Table_BountyAct[$i])
		For $z = 0 To 4
			ClickUI($NameUI & $z)
			$bounty = GetTextUI(1251, 'Root.TopLayer.tooltip_dialog_background.tooltip_2.tooltip')
			If $bounty <> False Then
				$temp = StringSplit($bounty, Chr(0), 2)
				$bounty = $temp[0]
				$bounty = StringReplace($bounty, "Bounty: ", "")
				$bounty = StringReplace($bounty, "Prime : ", "") ; Attention le premier espace n'est pas un espace mais 0xC2
				$bounty = $Table_BountyAct[$i] & "#" & $bounty 
				If IsBountyKnown($bounty) = False Then
					ConsoleWrite($bounty & "#None" & @CRLF)
					If $debug Then
						_logDebugTools($bounty & "#None")
					EndIf
				EndIf
			EndIf
		Next
	Next
	_log("End ")
	Send("M")
	Sleep(150)
EndFunc

Func ListUi($Visible = 0 , $debug = False)
	$UiPtr1 = _memoryread($ofs_objectmanager, $d3, "ptr")
	$UiPtr2 = _memoryread($UiPtr1 + $Ofs_UI_A, $d3, "ptr")
	$UiPtr3 = _memoryread($UiPtr2 + $Ofs_UI_B, $d3, "ptr")

	$BuckitOfs = _memoryread($UiPtr3 + $Ofs_UI_C, $d3, "ptr")
	$UiCount = _memoryread($UiPtr3 + $Ofs_UI_D, $d3, "int")

	For $g = 0 To $UiCount - 1
		$UiPtr = _memoryread($BuckitOfs, $d3, "ptr")
		While $UiPtr <> 0
			$nPtr = _memoryread($UiPtr + $Ofs_UI_nPtr, $d3, "ptr")
			$IsVisible =  BitAND(_memoryread($nPtr + $Ofs_UI_Visible, $d3, "ptr"), 0x4)
			If $IsVisible = 4 OR $Visible = 0 Then
				$Name = BinaryToString(_memoryread($nPtr + $Ofs_UI_Name, $d3, "byte[1024]"), 4)
				$temp = StringSplit($Name, Chr(0), 2)
				$Name = $temp[0]
				_log("Buckit : " & $g & " (" & $IsVisible  & ") -> " & $Name, $LOG_LEVEL_DEBUG)
				If $debug Then
					_logDebugTools("Buckit : " & $g & " (" & $IsVisible  & ") -> " & $Name)
				EndIf
			EndIf
			$UiPtr = _memoryread($UiPtr, $d3, "ptr")
		WEnd
		$BuckitOfs = $BuckitOfs + 0x4
	Next
EndFunc

Func MarkPos()
	$currentloc = GetCurrentPos()
	_log($currentloc[0] & ", " & $currentloc[1] & ", " & $currentloc[2] & ", 1, 25");
EndFunc   ;==>MarkPos

Func MonsterListing($debug = False)
	$Object = IterateObjectListV2()
	$foundtarget = 0
	_log("monster listing ===========================", $LOG_LEVEL_WARNING)
	_ArraySort($Object, 0, 0, 0, 9)
	For $i = 0 To UBound($Object, 1) - 1
		If $Object[$i][1] <> -1  Then
			_log($Object[$i][1] & " ("  & $Object[$i][9] & ")", $LOG_LEVEL_DEBUG)
			If $debug Then
				_logDebugTools($Object[$i][1] & " ("  & $Object[$i][9] & ")")
			EndIf
		EndIf
	Next
EndFunc   ;==>MonsterListing

Func Testing_IterateObjetcsList()

	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)

	While iterateObjectsList($index, $offset, $count, $item)

		$log = "Object : "
		For $i = 0 To UBound($item) - 1
			$log = $log & $item[$i] & " / "
		Next

		$ACD = GetACDOffsetByACDGUID($item[0])
		$CurrentIdAttrib = _memoryread($ACD + 0x120, $d3, "ptr");
		$quality = GetAttribute($CurrentIdAttrib, $Atrib_Item_Quality_Level)

		$log = $log & " quality : " & $quality
		If $item[2] <> "" Then
			_log($log, $LOG_LEVEL_DEBUG)
		EndIf
	WEnd
EndFunc   ;==>Testing_IterateObjetcsList



Func Testing()

;offsetlist()

;_checkbackpacksize()
#cs
	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)

	GLOBAL $ItemRefresh = false
	Global $gestion_affixe_loot = false
	$banlist = ""
	dim $items
	;_log("count -> " & $count)
	While iterateObjectsList($index, $offset, $count, $item)
			_log("Ofs : " & $item[8]  & " - "  & $item[1] & " - Data 1 : " & $item[5] & " - Data 2 : " & $item[6] & " - Guid : " & $item[0])

			;if is_loot($item) then
			;	handle_loot($item, $banlist, $items)
			;EndIf

	WEnd
	;_log("Actor Ofs -> " & hex(GetPlayerOffset()))
#ce

;GetAct()
;ListUi(0)

;_log($_Myoffset)



;Load_Attrib_GlobalStuff()
;$maxhp = GetAttribute($_MyGuid, $Atrib_Hitpoints_Max_Total) ; dirty placement
;GetMaxResource($_MyGuid, $namecharacter)

;Load_Attrib_GlobalStuff()
;GetMaxResource($_MyGuid, $namecharacter)
;if _playerdead() then
;	_log("mort")
;else
;	_log("en vie")
;endif
;InteractByActorName('Player_Shared_Stash')


;Auto_spell_init()
;GestSpellInit()
;GetMaxResource($_MyGuid, $namecharacter)

;Global $shrinebanlist = ""
;Global $a_range = 999999
;Global $MonsterList = "Beast_B|Goblin|Goatman_M|Goatman_R|WitherMoth|Beast_A|Scavenger|zombie|Corpulent|Skeleton|QuillDemon|FleshPitFlyer|Succubus|Scorpion|azmodanBodyguard|succubus|ThousandPounder|FallenGrunt|FallenChampion|FallenHound|FallenShaman|GoatMutant|demonTrooper_|creepMob|Brickhouse_A|Brickhouse_B|Triune_|TriuneVesselActivated_|TriuneVessel|Triune_Summonable_|ConductorProxyMaster|sandWasp|TriuneCultist|SandShark|Lacuni|Ghoul_|Uber|GoatMutant_Ranged_A|GoatMutant_Melee_A|fastMummy_C|demonFlyer|WoodWraith|TriuneVessel_|snakeMan_|uber_|Uber"
;Attack()


;ListUi(1)

#cs
_log( "2 : "  & GetTextUI(1540, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 2.LayoutRoot.Name"))
_log("3 : "  &GetTextUI(375, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 3.LayoutRoot.Name"))
_log("4 : "  &GetTextUI(646, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 4.LayoutRoot.Name"))
_log("5 : "  &GetTextUI(302, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 5.LayoutRoot.Name"))
_log("6 : "  &GetTextUI(579, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 6.LayoutRoot.Name"))
_log("7 : "  &GetTextUI(1898, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 7.LayoutRoot.Name"))
_log("8 : "  &GetTextUI(176, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 8.LayoutRoot.Name"))
_log("9 : "  &GetTextUI(502, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 9.LayoutRoot.Name"))
_log("10 : "  &GetTextUI(1270, "Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 10.LayoutRoot.Name"))
#ce


;TakeWPV2(0)

#cs
$result = GetOfsUI("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.POI.entry 1.LayoutRoot.Name", 1)
_log($result)
Dim $Point = GetPositionUI($result)
Dim $Point2 = GetUIRectangle($Point[0], $Point[1], $Point[2], $Point[3])

MouseMove($Point2[0] + $Point2[2] / 2, $Point2[1] + $Point2[3] / 2, 1)
#ce

;TakeWPV2(0)i

;Detect_Str_full_inventory()
;listui(1)

;Repair()
;Detect_Str_full_inventory()

;StashAndRepair()
;_log(fastcheckuiitemvisible("Root.NormalLayer.shop_dialog_mainPage.repair_dialog.RepairEquipped", 1, 124))

;enoughtPotions()
;ClickOnStashTab(1)

;offsetlist()
;_log("ETAT TP -> " &  _memoryRead( _memoryRead($_Myoffset + 0x1a4, $d3, "ptr") + 0x18, $d3, "int"))

;_log(fastcheckuiitemactived("Root.NormalLayer.deathmenu_dialog.dialog_main.button_revive_at_corpse", 139))
;ClickUI("Root.NormalLayer.deathmenu_dialog.dialog_main.button_revive_in_town", 496)
;_log("c'est partit !")
;While NOT fastcheckuiitemvisible("Root.NormalLayer.gamemenu_dialog.gamemenu_bkgrnd.ButtonStackContainer.button_leaveGame", 1, 1644)
			;sleep(200)
		;WEnd
;_log("trouvé")

;Global $a_range=70
;Global $SpecialmonsterList="Uber_|uber_"
;Global $monsterList="Ghoul_|Beast_B|Goatman_M|Goatman_R|WitherMoth|Beast_A|Goblin|Scavenger|Corpulent|Skeleton|QuillDemon|FleshPitFlyer|Succubus|Scorpion|azmodanBodyguard|succubus|ThousandPounder|FallenGrunt|FallenChampion|FallenHound|FallenShaman|GoatMutant|demonFlyer_B|demonTrooper_|creepMob|Brickhouse_A|Brickhouse_B|Triune_|TriuneVesselActivated_|TriuneVessel|Triune_Summonable_|ConductorProxyMaster|goblin|sandWasp|TriuneCultist|SandShark|Lacuni|Uber_|uber_"
;$IgnoreList = ""
;Dim $test_iterateallobjectslist = IterateFilterAttackV4($IgnoreList)
;If IsArray($test_iterateallobjectslist) Then;;
;
;		for $i=0 to Ubound($test_iterateallobjectslist) - 1
;			_log("")
;			for $y=0 to $TableSizeGuidStruct - 1
;				_log( $i & ") (" & $y  & ") " & $test_iterateallobjectslist[$i][$y] )
;			Next
;			_log("")
;		Next
;EndIf

;_log("Finish")

;_log("Bounty : " & fastcheckuiitemvisible("Root.NormalLayer.WaypointMap_main.LayoutRoot.OverlayContainer.BountyOverlay.Rewards.BagReward",1,85))
;ListUi(1)

;ClickUi("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.AdventureModeButton" , 1581)
;Sleep(5000)
;ClickUi("Root.NormalLayer.BattleNetGameSettings_main.LayoutRoot.StoryModeButton" , 199)
;GetMyStats()


;_log("Ready : " & IsPowerReady($_MyGuid, $DemonHunter_Sentry))
;_log("Ready : " & IsPowerReady($_MyGuid, $DemonHunter_Vault))

;$Table_BountyAct = StringSplit("1|2|3","|",2)
;$temp = GetBountySequences($Table_BountyAct)

;list_bounties()

;ShowDebugTools() 
;$items = FilterBackpack()
;_ArrayDisplay($items)
;consoleLog("Disconnect : " & _checkDisconnect())
ListBounties()
;consoleLog(GetTextUI(1346,"Root.TopLayer.BattleNetModalNotifications_main.ModalNotification.Content.List.Title"))
EndFunc   ;==>Testing ##*******##*******##*******##*******##*******##*******##*******##*******##*******##*******##*******##*******###

;;--------------------------------------------------------------------------------
;;	IterateObjectList()
; TODO : Correct or remove
;;--------------------------------------------------------------------------------
Func IterateObjectList($_displayInfo = 0)
	;	Local $mesureobj = TimerInit() ;;;;;;;;;;;;;;
	If $_displayInfo = 1 Then _log("-----Iterating through Actors------")
	If $_displayInfo = 1 Then _log("First Actor located at: " & $_itrObjectManagerD )
	$_CurOffset = $_itrObjectManagerD
	$_Count = _MemoryRead($_itrObjectManagerCount, $d3, 'int')
	Dim $OBJ[$_Count + 1][13]
	If $_displayInfo = 1 Then _log("Number of Actors : " & $_Count)
	;$init = TimerInit()
	For $i = 0 To $_Count Step +1
		$_GUID = _MemoryRead($_CurOffset + 0x0, $d3, 'ptr')
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
			$_PROXY_NAME = _MemoryRead($_CurOffset + 0x4, $d3, 'char[64]')
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
			If $_displayInfo = 1 Then _log($i & @TAB & " : " & $_CurOffset & " " & $_GUID & " " & $_ACTORLINK & " : " & $_DATA & " " & $_DATA2 & " " & @TAB & $_POS_X & " " & $_POS_Y & " " & $_POS_Z & @TAB & $_REAL_NAME)
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
	;_log("Mesure iterOBJ :" & $difmesureobj) ;FOR DEBUGGING;;;;;;;;;;;;
	Return $OBJ
EndFunc   ;==>IterateObjectList
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
;###########################################################################
;###########################################################################
;###########################################################################
;###########################################################################
;###########################################################################
;###########################################################################


;Global $Scene_table_totale[1][10]
;Global $NavCell_table_totale[1][10]
;Global $Scene_table_id_scene[1]
#cs
Func Read_Scene()

	$nb_totale_scene_record = 0
	$up = False

	While 1

		$ObManStoragePtr = _MemoryRead($ofs_objectmanager, $d3, "ptr")
		$offset = $ObManStoragePtr + 0x794 + 0x178
		$sceneCountPtr = _MemoryRead($offset, $d3, "ptr") + 0x108
		$countScene = _MemoryRead($sceneCountPtr, $d3, "int")

		$sceneFirstPtr = _MemoryRead($offset, $d3, "ptr") + 0x148
		Dim $obj_scene[1][10]
		$count = 0

		;################################## ITERATION OBJ SCENE ########################################
		For $i = 0 To $countScene
			$scenePtr = _MemoryRead($sceneFirstPtr, $d3, "ptr") + $i * 0x2A8

			$temp_id_world = _MemoryRead($scenePtr + 0x008, $d3, "ptr") ;id world
			$temp_id_scene = _MemoryRead($scenePtr, $d3, "ptr") ;id world
			$correlation = True



			If $temp_id_world = $_MyACDWorld And $temp_id_scene <> 0xFFFFFFFF Then;id world

				If $nb_totale_scene_record = 0 Then
					$Scene_table_id_scene[0] = $temp_id_scene
					$nb_totale_scene_record += 1
				Else
					For $a = 0 To UBound($Scene_table_id_scene) - 1
						If $Scene_table_id_scene[$a] = $temp_id_scene Then
							$correlation = False
							ExitLoop
						EndIf
					Next
					If $correlation = True Then
						$Ucount = UBound($Scene_table_id_scene)
						ReDim $Scene_table_id_scene[$Ucount + 1]
						$Scene_table_id_scene[$Ucount] = $temp_id_scene
					EndIf
				EndIf

				If $correlation = True Then

					$nb_totale_scene_record += 1
					$count += 1
					ReDim $obj_scene[$count][10]

					$obj_scene[$count - 1][0] = $temp_id_scene ;id_scene
					$scenePtr += 0x004
					$obj_scene[$count - 1][1] = $temp_id_world ;id world
					$obj_scene[$count - 1][2] = _MemoryRead($scenePtr + 0x014, $d3, "int") ;sno_levelarea
					$obj_scene[$count - 1][3] = _MemoryRead($scenePtr + 0x0D8, $d3, "ptr") ;id_sno_scene

					$obj_scene[$count - 1][4] = _MemoryRead($scenePtr + 0x0EC, $d3, "float") ;Vec2 Meshmin x
					$obj_scene[$count - 1][5] = _MemoryRead($scenePtr + 0x0F0, $d3, "float") ;Vec2 Meshmin y
					$obj_scene[$count - 1][6] = _MemoryRead($scenePtr + 0x0F4, $d3, "float") ;Vec2 Meshmin z

					$obj_scene[$count - 1][7] = _MemoryRead($scenePtr + 0x164, $d3, "float") ;Vec2 Meshmax x
					$obj_scene[$count - 1][8] = _MemoryRead($scenePtr + 0x168, $d3, "float") ;Vec2 Meshmax y
					$obj_scene[$count - 1][9] = _MemoryRead($scenePtr + 0x16C, $d3, "float") ;Vec2 Meshmax z


					ReDim $Scene_table_totale[$nb_totale_scene_record][10]

					$Scene_table_totale[$nb_totale_scene_record - 1][0] = $obj_scene[$count - 1][0]
					$Scene_table_totale[$nb_totale_scene_record - 1][1] = $obj_scene[$count - 1][1]
					$Scene_table_totale[$nb_totale_scene_record - 1][2] = $obj_scene[$count - 1][2]
					$Scene_table_totale[$nb_totale_scene_record - 1][3] = $obj_scene[$count - 1][3]
					$Scene_table_totale[$nb_totale_scene_record - 1][4] = $obj_scene[$count - 1][4]
					$Scene_table_totale[$nb_totale_scene_record - 1][5] = $obj_scene[$count - 1][5]
					$Scene_table_totale[$nb_totale_scene_record - 1][6] = $obj_scene[$count - 1][6]
					$Scene_table_totale[$nb_totale_scene_record - 1][7] = $obj_scene[$count - 1][7]
					$Scene_table_totale[$nb_totale_scene_record - 1][8] = $obj_scene[$count - 1][8]
					$Scene_table_totale[$nb_totale_scene_record - 1][9] = $obj_scene[$count - 1][9]


				EndIf


			EndIf

		Next
		;################################################################################################


		Dim $list_sno_scene = IndexSNO(0x18EDF60, 0)


		;############################## ITERATION DU SNO ################################################
		For $i = 1 To UBound($list_sno_scene) - 1
			$correlation = False
			$current_obj_scene = 0

			For $x = 0 To UBound($obj_scene) - 1
				If $list_sno_scene[$i][1] = $obj_scene[$x][3] Then
					$correlation = True
					$current_obj_scene = $x
				EndIf
			Next

			If $correlation Then
				$NavMeshDef = $list_sno_scene[$i][0] + 0x040
				$NavZoneDef = $list_sno_scene[$i][0] + 0x280

				;############## ITERATION DES NAVCELL ################
				$CountNavCell = _memoryRead($NavZoneDef, $d3, "int")
				$NavCellPtr = _memoryRead($NavZoneDef + 0x08, $d3, "ptr")

				If $CountNavCell <> 0 Then
					Dim $Navcell_Table[$CountNavCell][9]
					Local $NavCellStruct = DllStructCreate("float;float;float;float;float;float;short;short;int")

					For $t = 0 To $CountNavCell - 1

						DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $NavCellPtr + ($t * 0x20), 'ptr', DllStructGetPtr($NavCellStruct), 'int', DllStructGetSize($NavCellStruct), 'int', '')

						If Mod(DllStructGetData($NavCellStruct, 7), 2) = 1 Then
							$flag = 1
						Else
							$flag = 0
						EndIf

						If UBound($NavCell_table_totale) - 1 = 0 And $up = False Then
							$up = True
						Else
							ReDim $NavCell_table_totale[UBound($NavCell_table_totale) + 1][10]
						EndIf

						$num = UBound($NavCell_table_totale) - 1
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

					For $a = 0 To UBound($Scene_table_id_scene) - 1
						If $Scene_table_id_scene[$a] = $obj_scene[$current_obj_scene][0] Then
							_ArrayDelete($Scene_table_id_scene, $a)
							ExitLoop
						EndIf
					Next

					For $a = 0 To UBound($Scene_table_totale) - 1
						If $Scene_table_totale[$a][0] = $obj_scene[$current_obj_scene][0] Then
							_Array2DDelete($Scene_table_totale, $a)
							$nb_totale_scene_record -= 1
							ExitLoop
						EndIf
					Next

				EndIf

			EndIf
		Next

		_log("fin Iteration")
		Sleep(500)
	WEnd

EndFunc   ;==>Read_Scene
#ce

#cs
Func Drawn()
	_log("taille du tab Scene-> " & UBound($Scene_table_totale))
	_log("taille du tab NavCell-> " & UBound($NavCell_Table_Totale))
	;_ArrayDisplay($Scene_table_id_scene)
	Dim $buffMax[2] = [0, 0]
	Dim $buffMin[2] = [999999999, 99999999]
	Dim $indexMax[2] = [0, 0] ; 0 -> Index MeshMax X le plus grand | 1 -> Index MEshMax Y le plus grand
	Dim $indexMin[2] = [999999999, 99999999]

	For $i = 0 To UBound($Scene_table_totale) - 1
		If $buffMax[0] < $Scene_table_totale[$i][7] Then
			$buffMax[0] = $Scene_table_totale[$i][7]
			$indexMax[0] = $i
		EndIf

		If $buffMin[0] > $Scene_table_totale[$i][4] Then
			$buffMin[0] = $Scene_table_totale[$i][4]
			$indexMin[0] = $i
		EndIf


		If $buffMax[1] < $Scene_table_totale[$i][8] Then
			$buffMax[1] = $Scene_table_totale[$i][8]
			$indexMax[1] = $i
		EndIf

		If $buffMin[1] > $Scene_table_totale[$i][5] Then
			$buffMin[1] = $Scene_table_totale[$i][5]
			$indexMin[1] = $i
		EndIf
	Next

	Initiate_GDIpicture($Scene_table_totale[$indexMax[1]][8] - $Scene_table_totale[$indexMin[1]][5], $Scene_table_totale[$indexMax[0]][7] - $Scene_table_totale[$indexMin[0]][4])



	For $i = 0 To UBound($Scene_table_totale) - 1
		For $y = 0 To UBound($NavCell_Table_Totale) - 1

			If $Scene_table_totale[$i][0] = $NavCell_Table_Totale[$y][9] Then

				;_arraydisplay($NavCell_Table_Totale)

				$vx = ($Scene_table_totale[$i][4] - $Scene_table_totale[$indexMin[0]][4]) + $NavCell_Table_Totale[$y][0]
				$vy = ($Scene_table_totale[$i][5] - $Scene_table_totale[$indexMin[1]][5]) + $NavCell_Table_Totale[$y][1]

				;_log($i & "-" &  $y)
				;_arraydisplay($NavCell_Table_Totale)
				$tx = $NavCell_Table_Totale[$y][3] - $NavCell_Table_Totale[$y][0]
				$ty = $NavCell_Table_Totale[$y][4] - $NavCell_Table_Totale[$y][1]
				$flag = $NavCell_Table_Totale[$y][6]

				;_log($vx & " - " & $vy)
				;_log($tx & " - " & $ty)

				Draw_Nav($vy, $vx, $flag, $ty, $tx)

			EndIf
		Next

		;Draw_Nav(($Scene_table_totale[$i][5] - $Scene_table_totale[$indexMin[1]][5]), ($Scene_table_totale[$i][4] - $Scene_table_totale[$indexMin[0]][4]), 3, $Scene_table_totale[$i][8] - $Scene_table_totale[$i][5], $Scene_table_totale[$i][7] - $Scene_table_totale[$i][4])
	Next

	Save_GDIpicture()
	Load_GDIpicture()
EndFunc   ;==>Drawn
#ce