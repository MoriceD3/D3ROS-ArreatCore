#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=.\debug.exe
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
If Not FileExists(@ScriptDir & ".\log") Then
	DirCreate(@ScriptDir & ".\log")
EndIf
Global $log = @ScriptDir & ".\log\" & "debug_" & @YEAR & "_" & @MON & "_" & @MDAY & "-" & @HOUR & "h" & @MIN & ".txt"
If FileExists($log) Then FileDelete($log)
_FileCreate($log)
FileOpen($log)
$PIDProcess = Run('"' & @ScriptDir & '\main.exe"', @ScriptDir , -1, 2)
Sleep(1000)
Local $posd3 = WinGetPos("[CLASS:D3 Main Window Class]")
$DebugX = $posd3[0] + 5
$DebugY = $posd3[1] + $posd3[3] + 10
While 1
    $line = StdoutRead($PIDProcess)
    If @error Then ExitLoop
    If($line <> "") Then
		FileWrite($log,$line)
		ToolTip($line,$DebugX,$DebugY)
    EndIf
WEnd
FileClose($log)