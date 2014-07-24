#include-once
#include "Variables.au3"
#cs ----------------------------------------------------------------------------
	Extension permettant de gérer l'intervention du bot via le tchat
#ce ----------------------------------------------------------------------------

Func WriteInChat($str)
	_Log("--------------------> TCHAT : " & $str & @CRLF)
	Send("{ENTER}") ;validation de la fenêtre de tchat sur le groupe
	Send('' & $str & '');Ecriture du message
	Send("{ENTER}") ;Envoie du message et sort de la fenêtre du tchat
EndFunc   ;==>WriteInChat

Func WriteMe($situation)
    ;Temps d'attente en milliseconde pour pouvoir suivre le bot
	Local $Tp = 5000
	Local $NewRun = 2000
	Local $TaweWp = 5000

	Switch $situation
		Case $WRITE_ME_RESTART_GAME	;dans le menu pour recommencer un run
			Switch Random(1, 3, 1)
				Case 1
					WriteInChat("J'attends un peu et je recommence")
				Case 2
					WriteInChat("GO GO GO le Paragon 1000 nous attend ;)")
				Case 3
					WriteInChat("Tu es prêt ? Je relance")
			EndSwitch

		Case $WRITE_ME_WELCOME ;en jeu, début du run
			Switch Random(1, 5, 1)
				Case 1
					WriteInChat("En route pour l'aventure")
				Case 2
					WriteInChat("La chasse aux montres est ouverte")
				Case 3
					WriteInChat("Alors on y va ?")
				Case 4
					WriteInChat("Bonjour c'est parti pour un run")
				Case 5
					WriteInChat("Je vous souhaite la bienvenue")
			EndSwitch
			Sleep($NewRun)

		Case $WRITE_ME_HAVE_LEGENDARY ;on met un légendaire au coffre
			Switch Random(1, 3, 1)
				Case 1
					WriteInChat("Et encore un souffre dans le coffre")
				Case 2
					WriteInChat("YES ! j'ai trouvé un légendaire")
				Case 3
					WriteInChat("Pas moyen d'avoir de bon Leg")
            EndSwitch

		Case $WRITE_ME_QUIT ;le run est terminé le bot quitte
			Switch Random(1, 3, 1)
				Case 1
					WriteInChat("C'est fini on quitte")
				Case 2
					WriteInChat("C'est clean, on en refait une vite fait ?")
				Case 3
					WriteInChat("Je quitte")
			EndSwitch
			Sleep(1000)

		Case $WRITE_ME_INVENTORY_FULL ;inventaire plein ou besoin de réparation
			Switch Random(1, 3, 1)
				Case 1
					WriteInChat("Je suis plein. Je TP et je reviens")
				Case 2
					WriteInChat("Ça ne sera pas long. Je dois aller vider mon inventaire")
				Case 3
					WriteInChat("Hey, je dois aller réparer")
			EndSwitch

	    Case $WRITE_ME_BACK_REPAIR ;revient de vider l'inventaire ou de réparer
			Switch Random(1, 3, 1)
				Case 1
					WriteInChat("J'arrive")
				Case 2
					WriteInChat("J'ai terminé")
				Case 3
					WriteInChat("Ça commence à coûter cher en réparation")
			EndSwitch

		Case $WRITE_ME_TP ;on tp en ville pour changer zone
			Switch Random(1, 3, 1)
				Case 1
					WriteInChat("Je TP en ville")
				Case 2
					WriteInChat("TP")
				Case 3
					WriteInChat("Je retourne en ville")
			EndSwitch
			Sleep($TP)

	    Case $WRITE_ME_SALE	;on vend, répare, recycle
		    Switch Random(1, 3, 1)
	            Case 1
			        WriteInChat("je vends")
	            Case 2
                    WriteInChat("Bof rien à garder comme d'hab")
				Case 3
                    WriteInChat("Bon j'identifie tout ça pour voir")
            EndSwitch

		Case $WRITE_ME_DEATH ;on est mort
			Switch Random(1, 3, 1)
				Case 1
					WriteInChat("Je me suis fait avoir comme un bleu")
				Case 2
					WriteInChat("Ils font mal")
				Case 3
					WriteInChat("ça pique fort")
 			EndSwitch

		Case $WRITE_ME_TAKE_WP ;change de zone par WP
			Switch Random(1, 6, 1)
				Case 1
					WriteInChat("TP sur moi je change de zone")
				Case 2
					WriteInChat("TP sur mon drapeau")
				Case 3
					WriteInChat("Cette map est clean. On change de zone")
				Case 4
					WriteInChat("On passe à la prochaine zone")
				Case 5
					WriteInChat("Next zone")
				Case 6
					WriteInChat("Pas mal clean. On passe à la prochaine zone")
			EndSwitch
			Sleep($TaweWp)

		Case $WRITE_ME_TAKE_BREAK_MENU ;dans le menu et on fait une pause
			Switch Random(1, 3, 1)
				Case 1
					WriteInChat("Je vais attendre")
				Case 2
					WriteInChat("Je vais attendre dans le menu")
				Case 3
					WriteInChat("C'est long xD")
 			EndSwitch
	EndSwitch
EndFunc   ;==>WriteMe