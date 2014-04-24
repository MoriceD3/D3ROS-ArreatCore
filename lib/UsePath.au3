#include-once

#include "constants.au3"
#include "settings.au3"
;;--------------------------------------------------------------------------------
; Function:                     UsePath(ByRef $path)
; Description:
;;--------------------------------------------------------------------------------
Func UsePath(ByRef $path)

	Local $posIndex = getNextIndex($path, 0)

	Local $lastIndexPos = 0
	For $i = 0 To UBound($path, 1) - 1
		If $path[$i][0] = 2 Then $lastIndexPos = $i
	Next

	Local $TimeOut = TimerInit()
	Local $toggletry = 0
	$grabtimeout = 0
	$killtimeout = 0

	$Coords = FromD3toScreenCoords($path[$posIndex][1], $path[$posIndex][2], $path[$posIndex][3])
	MouseMove($Coords[0], $Coords[1], 3)
	$LastCP = GetCurrentPos()
	MouseDown($MouseMoveClick)
	Sleep(10)
	While 1

		$res = revive($path)
		If $res = 2 Then
			Return
		ElseIf $res = 3 Then
			$GameFailed = 1
		EndIF

		GestSpellcast(0, 0, 0)

		If _playerdead() Or $GameOverTime = True Or $GameFailed = 1 Or $SkippedMove > 6 Then
			$GameFailed = 1
			ExitLoop
		EndIf

		If TimerDiff($TimeOut) > 175000 Then
			_log("UsePath Timed out ! ! ! ")
			$GameFailed = 1
			ExitLoop
		EndIf

		GameOverTime()

		If $GameOverTime = True Then
			ExitLoop
		EndIf

		$looking = LookForObjects()
		If Not $looking = False Then
			MouseUp($MouseMoveClick)
			Return $looking
		EndIf

		If $EndSequenceOnBountyCompletion Then
			If $Choix_Act_Run = -3 And IsQuestFinished($ActiveQuest) Then
				MouseUp($MouseMoveClick)
				_log("Bounty completed : Waiting a little for loots then end sequence", $LOG_LEVEL_WARNING)
				Sleep(1000)
				Attack()
				Sleep(1000)
				Attack()
				Return "endsequence()"
			EndIf
		EndIf


		$Distance = GetDistance($path[$posIndex][1], $path[$posIndex][2], $path[$posIndex][3])
		If $Distance < $path[$posIndex][5] Then
			If ($posIndex = $lastIndexPos) Then ExitLoop
			$posIndex = getNextIndex($path, $posIndex + 1)
			$TimeOut = TimerInit()
			$toggletry = 0
			$grabtimeout = 0
			$killtimeout = 0
		EndIf
		;If _MemoryRead($ClickToMoveToggle, $d3, 'float') = 0 Then ExitLoop
		Local $angle = 1
		Local $Radius = 25
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		While _MemoryRead($ClickToMoveToggle, $d3, 'float') = 0
			;_log("Togglemove : " & _MemoryRead($ClickToMoveToggle, $d3, 'float'))

			MouseUp($MouseMoveClick)
			Attack()
			MouseDown($MouseMoveClick)

			$Coords = FromD3toScreenCoords($path[$posIndex][1], $path[$posIndex][2], $path[$posIndex][3])
			$angle += $Step
			$Radius += 45

			;MouseMove($Coords[0] - (Cos($angle) * $Radius), $Coords[1] - (Sin($angle) * $Radius), 3)
			; ci desssous du dirty code pour eviter de cliquer n'importe ou hos de la fenetre du jeu
			$Coords[0] = $Coords[0] - (Cos($angle) * $Radius)
			$Coords[1] = $Coords[1] - (Sin($angle) * $Radius)

			$Coords = Checkclickable($Coords)

			Dim $Coords_Rnd[2]
			$Coords_Rnd[0] = Random($Coords[0] - 20, $Coords[0] + 20)
			$Coords_Rnd[1] = Random($Coords[1] - 20, $Coords[1] + 15)

			$Coords_Rnd = Checkclickable($Coords_Rnd)

			MouseMove($Coords_Rnd[0], $Coords_Rnd[1], 3)
			
			$toggletry += 1
			;_log("Tryin move :" & " x:" & $_x & " y:" & $_y & "coords: " & $Coords[0] & "-" & $Coords[1] & " angle: " & $angle & " Toggle try: " & $toggletry)
			If $angle >= 2.0 * $PI Or $toggletry > 9 Or _playerdead() Then
				$SkippedMove += 1
				_log("Toggle try: " & $toggletry & " Movement Skipped : " & $SkippedMove & " Pos Skipped : " & $posIndex)

				If ($posIndex = $lastIndexPos) Then ExitLoop 2
				$newIndex = getNextPosIndex($path, $posIndex + 1)
				If ($newIndex <> $posIndex) Then
					_log("MoveToPos pos " & $posIndex & " to pos " & $newIndex)
					$posIndex = $newIndex
					$TimeOut = TimerInit()
					$toggletry = 0
					$grabtimeout = 0
					$killtimeout = 0
				EndIf

				ExitLoop
			EndIf
			Sleep(10)
		WEnd
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		Sleep(10)

		;ConsoleWrite("currentloc: " & $_Myoffset & " - "&$CurrentLoc[0] & " : " & $CurrentLoc[1] & " : " & $CurrentLoc[2] &@CRLF)
		;ConsoleWrite("distance/m range: " & $Distance & " : " & $pos[4] & @CRLF)
		If $path[$posIndex][4] = 1 And GetDistance($LastCP[0], $LastCP[1], $LastCP[2]) >= $a_range / 2 Then
			MouseUp($MouseMoveClick)
			$LastCP = GetCurrentPos()
			Attack()
			MouseDown($MouseMoveClick)
			;ConsoleWrite("Last check: " & $Distance & @CRLF)
		EndIf
		$newIndex = getNextIndex($path, $posIndex)
		If ($newIndex <> $posIndex) Then
			_log("MoveToPos pos " & $posIndex & " to pos " & $newIndex)
			$posIndex = $newIndex
			$TimeOut = TimerInit()
			$toggletry = 0
			$grabtimeout = 0
			$killtimeout = 0
		EndIf
		$Coords = FromD3toScreenCoords($path[$posIndex][1], $path[$posIndex][2], $path[$posIndex][3])

		dim $Coords_Rnd[2]
		$Coords_Rnd[0] = Random($Coords[0] - 20, $Coords[0] + 20)
		$Coords_Rnd[1] = Random($Coords[1] - 20, $Coords[1] + 15)

		$Coords_Rnd = Checkclickable($Coords_Rnd)

		MouseMove($Coords_Rnd[0], $Coords_Rnd[1], 3) ;little randomisation
		MouseDown($MouseMoveClick)

	WEnd

	For $i = $posIndex To UBound($path, 1) - 1
		TraitementSequence($path, $i)
	Next
	MouseUp($MouseMoveClick)
	Return False
EndFunc   ;==>UsePath


Func getNextIndex(ByRef $arr, $index)
	Local $resultIndexPoint = getNextPosIndex($arr, $index)
	For $i = $index To $resultIndexPoint
		TraitementSequence($arr, $i)
	Next
	Return $resultIndexPoint
EndFunc   ;==>getNextIndex

;;--------------------------------------------------------------------------------
; Function:                     getNextPosIndex(ByRef $arr, $index)
; Description:          Return the nearest point with the good direction
;
; Note(s):              http://www.exaflop.org/docs/cgafaq/cga1.html
;;--------------------------------------------------------------------------------
Func getNextPosIndex(ByRef $arr, $index)
	Local $size = UBound($arr, 1)
	If $index >= $size - 1 Then Return $index
	While ($index < $size And $arr[$index][0] <> 2)
		$index += 1
		If $index = $size - 1 Then Return $index
	WEnd

	Local $indexPoint = $index + 1
	If ($indexPoint > $size - 1) Then Return $index

	Local $resultIndexPoint = $index
	Local $DistanceMin = getDistance($arr[$resultIndexPoint][1], $arr[$resultIndexPoint][2], $arr[$resultIndexPoint][3])
	Local $CurrentLoc = GetCurrentPos()

	While $indexPoint < $size
		If $arr[$indexPoint][0] = 2 Then
			$Distance = getDistance($arr[$indexPoint][1], $arr[$indexPoint][2], $arr[$indexPoint][3])

			If $Distance > $DistanceMin Then
				Local $Ax = $arr[$resultIndexPoint][1]
				Local $Ay = $arr[$resultIndexPoint][2]
				Local $Bx = $arr[$indexPoint][1]
				Local $By = $arr[$indexPoint][2]
				Local $T = ($Ay - $CurrentLoc[1]) * ($Ay - $By) - ($Ax - $CurrentLoc[0]) * ($Bx - $Ax)
				Local $L = Sqrt(($Bx - $Ax) * ($Bx - $Ax) + ($By - $Ay) * ($By - $Ay))

				Local $R = $T / ($L * $L);
				If ($R > 0 And $R < 1) Then
					$resultIndexPoint = $indexPoint
				EndIf
				ExitLoop
			EndIf
			$DistanceMin = $Distance
			$resultIndexPoint = $indexPoint
		EndIf
		$indexPoint += 1
	WEnd
	Return $resultIndexPoint
EndFunc   ;==>getNextPosIndex


Func max($val1, $val2)
	If ($val1 > $val2) Then Return $val1
	Return $val2
EndFunc   ;==>max

Func min($val1, $val2)
	If ($val1 < $val2) Then Return $val1
	Return $val2
EndFunc   ;==>min