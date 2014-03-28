#include-once
;
;  Définitions des variables utiles au BOT
;

Global $d3, $a_range, $ResActivated, $nb_die_t, $rdn_die_t, $File_Sequence

Global $_Myoffset   = 0
Global $_MyGuid     = 0
Global $_MyACDWorld = 0
Global $_MyCharType = 0

Global  $GrabListTab, $allSNOitems, $grablist

; Variable global pour Automatisation des séquences
Global  $Choix_Act_Run,$SequenceFileAct1,$SequenceFileAct2,$SequenceFileAct3,$Act1_Hero_Axe_Z,$Act2_Hero_Axe_Z
Global	$Act3_Hero_Axe_Z,$Sequence_Aleatoire,$Nombre_de_Run,$NombreRun_Encour,$Act_Encour,$fileLog,$numLigneFichier
Global	$NombreMiniAct1,$NombreMiniAct2,$NombreMiniAct3,$NombreMaxiAct1,$NombreMaxiAct2,$NombreMaxiAct3,$NombreDeRun
Global	$ChainageActe[6][3]=[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
Global	$ChainageActeEnCour[3],$ColonneEnCour,$NbreRunChangSeqAlea,$SequenceFileAct3PtSauve,$SequenceFileAct333,$SequenceFileAct362,$SequenceFileAct373

;Gestion des Skills suivant les Héros, de la difficulté et de la puissance des monstres
Global	$Heros,$difficulte,$PuisMonstre,$TypedeBot,$TypeDeGrabList

; check ui error
Global Const $MODE_INVENTORY_FULL 		= 0
Global Const $MODE_STASH_FULL	  		= 1
Global Const $MODE_BOSS_TP_DENIED 		= 2
Global Const $MODE_NO_IDENTIFIED_ITEM 	= 3

; GestionChat
Global Const $WRITE_ME_RESTART_GAME		= 1
Global Const $WRITE_ME_WELCOME			= 2
Global Const $WRITE_ME_HAVE_LEGENDARY	= 3
Global Const $WRITE_ME_QUIT				= 4
Global Const $WRITE_ME_INVENTORY_FULL	= 5
Global Const $WRITE_ME_BACK_REPAIR		= 6
Global Const $WRITE_ME_TP				= 7
Global Const $WRITE_ME_SALE				= 8
Global Const $WRITE_ME_DEATH			= 9
Global Const $WRITE_ME_TAKE_WP			= 10
Global Const $WRITE_ME_TAKE_BREAK_MENU	= 11

; Item Type
Global Const $ITEM_TYPE_MOB		= 1
Global Const $ITEM_TYPE_SHRINE  = 2
Global Const $ITEM_TYPE_CHEST   = 3
Global Const $ITEM_TYPE_HEALTH  = 4
Global Const $ITEM_TYPE_POWER   = 5
Global Const $ITEM_TYPE_LOOT    = 6
Global Const $ITEM_TYPE_DECOR   = 7
Global Const $ITEM_TYPE_RACK    = 8


Global $range_shrine = 50
Global $range_health = 35
Global $range_power  = 35
Global $range_decor  = 18
Global $range_chest  = 50
Global $range_rack  = 50

; MoveTo
Global Const $MOVETO_SMITH 		   = 1
Global Const $MOVETO_POTION_VENDOR = 2
Global Const $MOVETO_REPAIR_VENDOR = 3
Global Const $MOVETO_BOOKOFCAIN    = 4
Global Const $MOVETO_PORTAL	       = 5

; global pour prendre des pause
Global $BreakCounter 	  = 0
Global $BreakTimeCounter  = 0
Global $PauseRepasCounter = 0
Global $tempsPauseGame 	  = 0
Global $tempsPauserepas   = 0

Global $Execute_TpRepairAndBack = False ; correction double tp inventaire plein
Global $Execute_StashAndRepair  = False
Global $PortBack 	   			= False
Global $FailOpen_BookOfCain 	= 0

Global $Hero_Axe_Z = 10
Global $TableBannedActors = [0]
Global $Count_ACD = 0
Global $GetACD
Global $nameCharacter
Global $timeforRightclick = 0
Global $timeForSpell1 = 0
Global $timeForSpell2 = 0
Global $timeForSpell3 = 0
Global $timeForSpell4 = 0
Global Const $PI = 3.141593
Global $Step = $PI / 6

Global $Try_ResumeGame = 0
Global $Try_Logind3 = 0
Global $disconnectcount = 0
Global $NeedRepairCount = 0
Global $Die2FastCount = 0
Global $timeforpotion = 0
Global $timeforclick = 0
Global $timeforskill = 0
Global $timedifmaxgamelength = 0
Global $timermaxgamelength = 0
Global $hotkeycheck = False
Global $area = 0
Global $act = 0
Global $GameDifficulty = 0
Global $MP
Global $RepairTab = 0
Global $Paused
Global $GameOverTime = False
Global $DebugMessage
Global $fichierlog = "log-" & @YEAR & "_" & @MDAY & "_" & @MON & "_" & @HOUR & "h" & @MIN & ".txt"
Global $fichierstat = "stat_" & @YEAR & "_" & @MON & "_" & @MDAY & "-" & @HOUR & "h" & @MIN & ".txt"
Global $dif_timer_stat_moyen = 0
Global $Current_Hero_Z = 0

Global $grabskip = 0
Global $maxhp

Global $elite = 0
Global $Ban_endstrItemList = "_projectile"
Global $Ban_ItemACDCheckList = "a1_|a3_|a2_|a4_|Lore_Book_Flippy|Topaz_|Emeraude_|Rubis_|Amethyste_|Console_PowerGlobe|GoldCoins|GoldSmall|GoldMedium|GoldLarge|healthPotion_Console"

Global $Table_Coffre = [0]
Global $Table_Rack = [0]
Global $Table_BanMonster  = [0]
Global $Table_Monster  = [0]
Global $Table_Decor  = [0]
Global $Table_SpecialMonster  = [0]
Global $List_BanItemStartName = "barbarian_|Demonhunter_|Monk_|WitchDoctor_|WD_|Enchantress_|Scoundrel_|Templar_|Wizard_|monsterAffix_|Demonic_|Generic_|fallenShaman_fireBall_impact|demonFlyer_B_clickable_corpse_01|grenadier_proj_trail|x1_promoPet_fallenHound_skeletal"
Global $Table_BanItemStartName = [0]

Global $Byte_Full_Inventory[2]
Global $Byte_Full_Stash[2]
Global $Byte_Boss_TpDeny[2]
Global $Byte_NoItem_Identify[2]

Global $SalvageQualiteItem

Global $grabtimeout = 0
Global $killtimeout = 0
Global $SkippedMove = 0

Global $SizeWindows = 0
Global $PointFinal[4] = [0,0,0,0]


;statistique
Global $CheckTakeShrineTaken = 0
Global $CptElite 			 = 0
Global $ItemToRecycle 		 = 0
Global $nbLegs 				 = 0
Global $nbRares 			 = 0
Global $GoldByRepaire 		 = 0
Global $GoldBySale 			 = 0
Global $GOLDMOYbyHgame 		 = 0
Global $Xp_Moy_HrsPerte		 = 0
Global $Xp_Moy_Hrsgame 		 = 0
Global $dif_timer_stat_game  = 0
Global $dif_timer_stat_pause = 0
Global $AverageDps 			 = 0
Global $NbMobsKilled 		 = 1
Global $Xp_Total 			 = 0
Global $Expencours 			 = 0
Global $NiveauParagon 		 = 0
Global $ExperienceNextLevel  = 0
Global $GOLDMOYbyH 			 = 0
Global $dif_timer_stat 		 = 0
Global $begin_timer_stat	 = 0
Global $timer_stat_total 	 = 0
Global $timer_stat_run_moyen = 0
Global $successratio		 = 1
Global $success 			 = 0
Global $Totalruns			 = 1
Global $Death 				 = 0
Global $DeathCountToggle	 = True
Global $RepairORsell		 = 0
Global $ItemToStash			 = 0
Global $ItemToSell 			 = 0
Global $GOLDInthepocket		 = 0
Global $GOLDINI				 = 0
Global $GOLD 				 = 0
Global $GOLDMOY 			 = 0
Global $GF 					 = 0
Global $MF 					 = 0
Global $PR 					 = 0
Global $MS 					 = 0
Global $EBP 				 = 0
Global $GameFailed  		 = 0
Global $Xp_Moy_Hrs 			 = 0
Global $games 				 = 1
Global $gamecounter  	     = 0
Global $CoffreTaken 		 = 0