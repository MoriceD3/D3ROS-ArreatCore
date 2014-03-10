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
 $timer=timerinit()
for $i=1 to 200000
 
   next
   _log( timerdiff($timer))