#include-once
#cs ----------------------------------------------------------------------------
	Extension permettant de gerer les temps de pause avec déconnection
#ce ----------------------------------------------------------------------------

;~ ;-----------------note-----------------------
;~ ; a ajouter dans la fonction resume
;~ If $TryResumeGame = 0 And $PauseRepas Then; $TryResumeGame = 0 car on veut pas faire une pause en plein jeu
;~ 		PauseRepas($Totalruns)
;~ EndIf
;~ ;-----------------------------------------------	 

Func PauseRepas($nbRun)

	Local $petitDejeuner = "08:00"
	Local $dejeuner = "12:20"
	Local $gouter = "16:30"
	Local $diner = "19:30"
	Local $collation = "23:00"

	; temps de pause en minute
	;Local $tempsPause=20
	$tempsPause = 20

	;Recuperation de l'heure et minute
	Local $Heure = @HOUR & ':' & @MIN

	;calcul en milliseconde du temps de pause
	$tempsPause = $tempsPause * 60000

	;Initialisation des variables à la mise en route du BOT
	If ($nbRun = 1) Then
		_Log('Initialisation au lancement du bot' & @CRLF)
		If $Heure > $petitDejeuner Then
			$petitDejeunerOK = 1
		EndIf
		If $Heure > $dejeuner Then
			$dejeunerOK = 1
		EndIf
		If $Heure > $gouter Then
			$gouterOK = 1
		EndIf
		If $Heure > $diner Then
			$dinerOK = 1
		EndIf
		If $Heure > $collation Then
			$collationOK = 1
		EndIf
	EndIf

	;Initialisation des variable entre 00:00 et 01:00 du matin
	If ($nbRun > 1) And ($Heure > "00:00" And $Heure < "01:00") Then
		_Log('Initialisation entre 00:00 et 01:00' & @CRLF)
		$petitDejeunerOK = 0
		$dejeunerOK = 0
		$gouterOK = 0
		$dinerOK = 0
		$collationOK = 0
	EndIf

	If $Heure > $petitDejeuner And $petitDejeunerOK = 0 Then
		$petitDejeunerOK = 1
		_Log('Pause à ' & $Heure & ' --> petit dejeuner' & @CRLF)
		Disconnect()
		Sleep($tempsPause)
		Connection()
	EndIf

	If $Heure > $dejeuner And $dejeunerOK = 0 Then
		_Log('Pause à ' & $Heure & ' --> dejeuner' & @CRLF)
		$dejeunerOK = 1
		Disconnect()
		Sleep($tempsPause)
		Connection()
	EndIf

	If $Heure > $gouter And $gouterOK = 0 Then
		_Log('Pause à ' & $Heure & ' --> gouter' & @CRLF)
		$gouterOK = 1
		Disconnect()
		Sleep($tempsPause)
		Connection()
	EndIf

	If $Heure > $diner And $dinerOK = 0 Then
		_Log('Pause à ' & $Heure & ' --> diner' & @CRLF)
		$dinerOK = 1
		Disconnect()
		Sleep($tempsPause)
		Connection()
	EndIf

	If $Heure > $collation And $collationOK = 0 Then
		_Log('Pause à ' & $Heure & ' --> collation' & @CRLF)
		$collationOK = 1
		Disconnect()
		Sleep($tempsPause)
		Connection()
	EndIf

EndFunc   ;==>PauseRepas

Func Disconnect()
	Send("{ESCAPE}")
	MouseMove(Random(315, 478, 1), Random(348, 362, 1), Random(12, 14, 1))
	MouseClick("left")
EndFunc   ;==>Disconnect

Func Connection()
	If IsOnLoginScreen() Then
		_Log("LOGIN")
		LoginD3()
		Local $Random = Random(60000, 120000, 1)
		Sleep($Random)
		$PauseRepasCounter += 1;on compte les pause repas effectuer
		$tempsPauserepas += ($tempsPause + $Random);on compte le temps de pause repas
		$TryLoginD3 = 0
	EndIf
EndFunc   ;==>Connection


