#include-once

#include "settings.au3"

#RequireAdmin

Global $FILETIME = "dword;dword"    ;Contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC).
Global $SYSTEMTIME = "ushort;ushort;ushort;ushort;ushort;ushort;ushort;ushort"

Const $LOG_LEVEL_NONE = 0
Const $LOG_LEVEL_VERBOSE = 1
Const $LOG_LEVEL_WARNING = 2
Const $LOG_LEVEL_DEBUG = 3
Const $LOG_LEVEL_ERROR = 4

Func _ArraySortRandom(ByRef $aArray, $iMultiplier = 2)

    Local $A, $B, $Temp
    Local $size = UBound($aArray)

    For $i = 1 To $iMultiplier * $size
        $A = Random(0, $size - 1, 1)
        $B = Random(0, $size - 1, 1)
        $Temp = $aArray[$A]
        $aArray[$A] = $aArray[$B]
        $aArray[$B] = $Temp
    Next
EndFunc   ;==>_ArraySortRandom

Func consoleLog($text, $level = 0)
	Switch $level
	    Case $LOG_LEVEL_VERBOSE
	        $start = "+"
	    Case $LOG_LEVEL_WARNING
	        $start = "-"
		Case $LOG_LEVEL_DEBUG
	        $start = ">"
	    Case $LOG_LEVEL_ERROR
	        $start = "!"
	    Case Else
	        $start = " "
	EndSwitch

	ConsoleWrite($start & @HOUR & ":" & @MIN & ":" & @SEC & " | " & $text & @CRLF)
EndFunc   ;==> consoleLog

Func _log($text, $level = $LOG_LEVEL_NONE, $forceDebug = False)
   
   Switch $level
       Case $LOG_LEVEL_VERBOSE
           $start = "+>"
       Case $LOG_LEVEL_WARNING
           $start = "->"
      Case $LOG_LEVEL_DEBUG
           $start = ">>"
       Case $LOG_LEVEL_ERROR
           $start = "!>"
       Case Else
           $start = " >"
   EndSwitch

   $texte_write = $start & @MDAY & "/" & @MON & " " & @HOUR & ":" & @MIN & ":" & @SEC & " | " & $text & @CRLF

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

Func Format_Number($str)
	$str = _StringReverse($str) ; renversement de la chaîne pour la traîtée à l'envers
	$str = StringRegExpReplace($str, "(\d{3})", "$1 ") ; on cherche tous les regroupement de n chiffres pour les remplacer par eux même suivi d'un espace
	$str = _StringReverse($str) ; on remets la chaîne à l'endroit
	$str = StringStripWS($str, 1) ; efface éventuellement l'espace en trop à l'avant , lorsque le nombre est composé d'un nombre multiple de n chiffres
	Return $str
EndFunc;==>Format_Number

Func formatTime($time_milisecond)
	if ($time_milisecond < 60000) Then
		return Round($time_milisecond / 1000, 2) & " s"
	ElseIf ($time_milisecond < 3600000) Then
		$Dummy = Round($time_milisecond / 1000)
		return Int($Dummy / 60) & " m " & Mod($Dummy, 60) & " s"
	Else
		$Dummy = Round($time_milisecond / 1000)
		return Int($Dummy / 3600) & "h " & Mod(Int($Dummy / 60), 60) & "m " & Mod($Dummy, 60) & "s"
	EndIf
EndFunc   ;==>formatTime

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

; #FUNCTION# =====================================================================
; Name...........: __ArrayConcatenate
; Description ...: Concatenate two 1D or 2D arrays
; Syntax.........: __ArrayConcatenate(ByRef $avArrayTarget, Const ByRef $avArraySource)
; Parameters ....: $avArrayTarget - The array to concatenate onto
;             $avArraySource - The array to concatenate from - Must be 1D or 2D to match $avArrayTarget,
;                          and if 2D, then Ubound($avArraySource, 2) <= Ubound($avArrayTarget, 2).
; Return values .: Success - Index of last added item
;             Failure - -1, sets @error to 1 and @extended per failure (see code below)
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

Func FileTimeToNum(ByRef $FT)
   Return BITOr(BitShift(DllStructGetData($FT, 1), 32), DllStructGetData($FT, 2))
EndFunc

Func OpenProcess($pid = @AutoItPID)
    Local $PROCESS_QUERY_INFORMATION = 0x0400
    Local $PROCESS_VM_READ = 0x0010
    $Process = DLLCall("kernel32.dll","int","OpenProcess","int", _
            BitOR($PROCESS_QUERY_INFORMATION,$PROCESS_VM_READ),"int",0,"int", $pid)
    If $Process[0] = 0 Then Return SetError(1, 0, 0)
   Return $Process[0]
EndFunc

Func _HighPrecisionSleep($iMicroSeconds)
   Local $hStruct
   $hDll = DllOpen("ntdll.dll")
   $hStruct = DllStructCreate("int64 time;")
   DllStructSetData($hStruct, "time", -1 * ($iMicroSeconds * 10))
   DllCall($hDll, "dword", "ZwDelayExecution", "int", 0, "ptr", DllStructGetPtr($hStruct))
EndFunc   ;==>_HighPrecisionSleep

Func GetProcessTimes(ByRef $hProcess, ByRef $t1, ByRef $t2, ByRef $t3, ByRef $t4)
;BOOL WINAPI GetProcessTimes(
;  HANDLE hProcess,
;  LPFILETIME lpCreationTime,
;  LPFILETIME lpExitTime,
;  LPFILETIME lpKernelTime,
;  LPFILETIME lpUserTime
; )
;
   Local $p1 = DllStructGetPtr($t1)
   Local $p2 = DllStructGetPtr($t2)
   Local $p3 = DllStructGetPtr($t3)
   Local $p4 = DllStructGetPtr($t4)
   Local $ret = dllcall("kernel32.dll","int", "GetProcessTimes","int",$hProcess ,  "ptr", $p1, "ptr", $p2, "ptr", $p3, "ptr", $p4)
   If $ret[0] = 0 Then
      ConsoleWrite("(" & @ScriptLineNumber & ") : = Error in GetProcessTimes call" & @LF)
      SetError(1, 0 , $ret[0])
   EndIf
   Return $ret[0]
EndFunc

Func ProfileInit()
   Local $process = OpenProcess(@AutoItPID)
   if @error then
      ConsoleWrite("!OpenProcess failed terminating" & @LF)
      Exit
   EndIf
   Local $ret[4]
   $ret[0] = 2
   Local $t1 = DllStructCreate($FILETIME)
   Local $t2 = DllStructCreate($FILETIME)
   Local $t3 = DllStructCreate($FILETIME)
   Local $t4 = DllStructCreate($FILETIME)
   If GetProcessTimes($process, $t1, $t2, $t3, $t4) Then
      $ret[$ret[0] + 1] = $process
      $ret[1] = FileTimeToNum($t3)
      $ret[2] = FileTimeToNum($t4)
   Else
      ConsoleWrite("(" & @ScriptLineNumber & ") := @error:=" & @error & ", @extended:?" & @extended & @LF)
      SetError(@error, @extended, 0)
   EndIf
   ;ArrayDump($ret, "ProfileInit Out")
   Return $ret
EndFunc

Func ProfileDiff(ByRef $init)
   Local $ret[3]
   $ret[0] = 2
   ;ArrayDump($init, "ProfileDiff($init)")
   Local $t1 = DllStructCreate($FILETIME)
   Local $t2 = DllStructCreate($FILETIME)
   Local $t3 = DllStructCreate($FILETIME)
   Local $t4 = DllStructCreate($FILETIME)
   Local $n1, $n2
   If GetProcessTimes($init[$init[0] + 1], $t1, $t2, $t3, $t4) Then
      $ret[1] = FileTimeToNum($t3) - $init[1]
      $ret[2] = FileTimeToNum($t4) - $init[2]
   Else
      ConsoleWrite("(" & @ScriptLineNumber & ") := @error:=" & @error & ", @extended:=" & @extended & @LF)
      SetError(@error, 0 , 0)
   EndIf
   Return $ret
EndFunc

Func startProfiling()
	return ProfileInit()
EndFunc

Func endProfiling($profilestart, $functionName = "default")
	$pd = ProfileDiff($profilestart)
 	$uk = Round(($pd[1] + $pd[2])/10000, 0) ;User and kernel time
 	consoleLog(StringFormat("Profiler : %s took : %#.6g ms", $functionName, $uk), $LOG_LEVEL_DEBUG)
EndFunc