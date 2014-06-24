#include-once
#cs ----------------------------------------------------------------------------
	Extension permettant de gerer les temps de pause
#ce ----------------------------------------------------------------------------

Func PausePlanifier()

	Local $ExecutePause = 0
	Local $RestartsBottingOK = 0
	Local $Heure = @HOUR & ':' & @MIN

	;calcul en milliseconde du temps de pause + Random - 3 a 3 min
 	$tempsPause = (($TempsPauseRepas * 60000) + Random(-180000, 180000, 1))

	;Reinitialisation Des Pauses Une Fois Completer
	If $ExecutePetitDejeuner And $ExecuteDejeuner And $ExecuteGouter And $ExecuteDiner And $ExecuteCollation And $ExecuteStopBotting Then
		If $ExecutePetitDejeuner = 1 And $Heure < $PausePetitDejeuner Then
		   _log('Planification De La Pause Petit Dejeuner a ' & $PausePetitDejeuner)
		   $ExecutePetitDejeuner = 0
		EndIf
		If $ExecuteDejeuner = 1 And $Heure < $PauseDejeuner Then
		   _log('Planification De La Pause Dejeuner a ' & $PauseDejeuner)
		   $ExecuteDejeuner = 0
		EndIf
		If $ExecuteGouter = 1 And $Heure < $PauseGouter Then
		   _log('Planification De La Pause Gouter a ' & $PauseGouter)
		   $ExecuteGouter = 0
		EndIf
		If $ExecuteDiner = 1 And $Heure < $PauseDiner Then
		  _log('Planification De La Pause Diner a ' & $PauseDiner)
		  $ExecuteDiner = 0
		EndIf
		If $ExecuteCollation = 1 And $Heure < $PauseCollation Then
		   _log('Planification De La Pause Collation a ' & $PauseCollation)
		   $ExecuteCollation = 0
		EndIf
		If $ExecuteStopBotting = 1 And $Heure < $StopBotting Then
		   _log('Planification De L`Arret Du Bot a ' & $StopBotting)
		   $ExecuteStopBotting = 0
		EndIf
	EndIf

	If Not $ExecutePetitDejeuner And $Heure > $PausePetitDejeuner Then
	   _log('Execution De La Pause Petit Dejeuner a --> ' & $Heure)
	   $ExecutePetitDejeuner = 1
	   $ExecutePause = 1
	EndIf

	If Not $ExecuteDejeuner And $Heure > $PauseDejeuner Then
	   _log('Execution De La Pause Dejeuner a --> ' & $Heure)
	   $ExecuteDejeuner = 1
	   $ExecutePause = 1
	EndIf

	If Not $ExecuteGouter And $Heure > $PauseGouter Then
	   _log('Execution De La Pause Gouter a --> ' & $Heure)
	   $ExecuteGouter = 1
	   $ExecutePause = 1
	EndIf

	If Not $ExecuteDiner And $Heure > $PauseDiner Then
	   _log('Execution De La Pause Diner a --> ' & $Heure)
	   $ExecuteDiner = 1
	   $ExecutePause = 1
	EndIf

	If Not $ExecuteCollation And $Heure > $PauseCollation Then
	   _log('Execution De La Pause Collation a --> ' & $Heure)
	   $ExecuteCollation = 1
	   $ExecutePause = 1
	EndIf

	;Stop and restarts Botting
	If Not $ExecuteStopBotting And $Heure > $StopBotting Then
	   _log('Execution De L`Arret Du Bot a --> ' & $Heure)
	   If $RestartsBotting Then
		  _log('Redemarage Du Bot Prevue a --> ' & $RestartsBotting)
		  $Pausetimer = TimerInit()
		  While Not $RestartsBottingOK
			 Sleep(10000)
			 $Heure = @HOUR & ':' & @MIN
			 If $Heure = $RestartsBotting Then
				$RestartsBottingOK = 1
			 EndIf
		  WEnd
		  Sleep(Random(60000, 180000, 1))
		  $tempsPause = TimerDiff($Pausetimer)
	   Else
		  ;ToDo creer une fonction qui quite diablo
		  Terminate()
	   EndIf
	   $ExecuteStopBotting = 1
	   $ExecutePause = 1
	EndIf

    ;Pause apres xxgames
	If $Breakafterxxgames Then
	   If Not $ExecutePause And $BreakCounter >= ($Breakafterxxgames + Random(-2, 2, 1)) Then
		  $tempsPause = (($BreakTime * 1000) + Random(60000, 180000, 1))
		  _log('Execution De La Pause Breakafterxxgames')
		  $ExecutePause = 1
	   EndIf
	EndIf

	;Execution des pause
	If $ExecutePause Then
	   If $RestartsBottingOK Then
		  $Heure = @HOUR & ':' & @MIN
		  _log('Redemarage Du Bot a --> ' & $Heure)
	   Else
		  _log('Sleep --> ' & (formatTime($tempsPause)))
		  Sleep($tempsPause)
	   EndIf
	   $BreakCounter = 0 ;on remet le compteur a 0 pour tout les pauses effectuer pour eviter une double pause
	   $BreakTimeCounter += 1 ;on compte les pause effectuer
	   $tempsPauseGame += $tempsPause ;compte le temps de pause
	EndIf

EndFunc   ;==>PausePlanifier

Func InitPauses()
    ;0 = a executer
	;1 = a ne pas executer immediatement
	;2 = deactiver
	Local $Heure = @HOUR & ':' & @MIN

	If $TakeABreak Then
	   _log('Initialisation Des Pauses', $LOG_LEVEL_DEBUG)
	   If $PausePetitDejeuner Then
		  _log('Pause Petit Dejeuner Planifier a --> ' & $PausePetitDejeuner)
		  If $Heure > $PausePetitDejeuner Then
			 $ExecutePetitDejeuner = 1
		  EndIf
	   Else
		  $ExecutePetitDejeuner = 2
	   EndIf
	   If $PauseDejeuner Then
		  _log('Pause Dejeuner Planifier a --------> ' & $PauseDejeuner)
		  If $Heure > $PauseDejeuner Then
			$ExecuteDejeuner = 1
		  EndIf
	   Else
		  $ExecuteDejeuner = 2
	   EndIf
	   If $PauseGouter Then
		  _log('Pause Gouter Planifier a ----------> ' & $PauseGouter)
		  If $Heure > $PauseGouter Then
			 $ExecuteGouter = 1
		  EndIf
	   Else
		  $ExecuteGouter = 2
	   EndIf
	   If $PauseDiner Then
		  _log('Pause Diner Planifier a -----------> ' & $PauseDiner)
		  If $Heure > $PauseDiner Then
			 $ExecuteDiner = 1
		  EndIf
	   Else
		  $ExecuteDiner = 2
	   EndIf
	   If $PauseCollation Then
		  _log('Pause Collation Planifier a -------> ' & $PauseCollation)
		  If $Heure > $PauseCollation Then
			 $ExecuteCollation = 1
		  EndIf
	   Else
		  $ExecuteCollation = 2
	   EndIf
	   If $StopBotting Then
		  If $StopBotting And Not $RestartsBotting Then
			 _log('Arret Complet Du Bot Planifier a --> ' & $StopBotting)
		  Else
			 _log('Arret Du Bot Planifier a ----------> ' & $StopBotting)
		  EndIf
		  If $RestartsBotting Then
			 _log('Redemarage Du Bot Planifier a -----> ' & $RestartsBotting)
		  EndIf
		  If $Heure > $StopBotting Then
			 $ExecuteStopBotting = 1
		  EndIf
	   Else
		  $ExecuteStopBotting = 2
	   EndIf
	   If $Breakafterxxgames Then
		  _log('Pause Breakafterxxgames Planifier A Tout Les ' & $Breakafterxxgames & ' Games')
	   EndIf
	Else
	   _log('Pauses Deactiver')
	EndIf
EndFunc ; ==> InitPauses