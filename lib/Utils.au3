#include-once

#RequireAdmin

Global $FILETIME = "dword;dword"    ;Contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC).
Global $SYSTEMTIME = "ushort;ushort;ushort;ushort;ushort;ushort;ushort;ushort"

Const $LOG_LEVEL_NONE = 0
Const $LOG_LEVEL_VERBOSE = 1
Const $LOG_LEVEL_WARNING = 2
Const $LOG_LEVEL_DEBUG = 3
Const $LOG_LEVEL_ERROR = 4

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