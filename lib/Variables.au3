#include-once
;
;  Définitions des variables utiles au BOT
;

Global $d3
Global $_Myoffset   		  = 0
Global $_MyGuid     		  = 0
Global $My_FastAttributeGroup
Global $_MyACDWorld 		  = 0
Global $_MyCharType 		  = 0
Global $hotkeycheck 		  = False
Global $ZoneCheckTimer 		  = 0

; Variable contenant le stuff actuel
Global $allSNOitems

; Variables pour la gestion de la fenêtre Diablo
Global $SizeWindows = 0
Global $PointFinal[4] = [0,0,0,0]

; Variables pour la detection d'erreurs
Global $Byte_Full_Inventory[2]
Global $Byte_Full_Stash[2]
Global $Byte_Boss_TpDeny[2]
Global $Byte_NoItem_Identify[2]

;Variables gestion grablist
Global $GrabListTab, $List_grablist

; Variable globale pour Automatisation des séquences
Global $Choix_Act_Run,$SequenceFileAct1,$SequenceFileAct2,$SequenceFileAct3,$SequenceFileAct3PtSauve
Global $Sequence_Aleatoire,$Nombre_de_Run,$NombreRun_Encour,$Act_Encour,$fileLog,$numLigneFichier
Global $NombreMiniAct1,$NombreMiniAct2,$NombreMiniAct3,$NombreMaxiAct1,$NombreMaxiAct2,$NombreMaxiAct3,$NombreDeRun
Global $ChainageActe[6][3]=[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
Global $ChainageActeEnCour[3],$ColonneEnCour,$NbreRunChangSeqAlea
Global $SequenceFileAct222,$SequenceFileAct232,$SequenceFileAct283,$SequenceFileAct299
Global $SequenceFileAct333,$SequenceFileAct362,$SequenceFileAct373,$SequenceFileAct374
Global $SequenceFileAct411,$SequenceFileAct442
Global $SequenceFileAdventure

;Gestion des Skills suivant les Héros, de la difficulté et de la puissance des monstres
Global $Heros,$difficulte,$PuisMonstre,$TypedeBot,$TypeDeGrabList

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

; Spell Type
Global Const $SPELL_TYPE_LIFE   		  = 0
Global Const $SPELL_TYPE_ATTACK   		  = 1
Global Const $SPELL_TYPE_PHYSICAL   	  = 2
Global Const $SPELL_TYPE_ELITE   		  = 3
Global Const $SPELL_TYPE_BUFF   	  	  = 4
Global Const $SPELL_TYPE_ZONE   		  = 5
Global Const $SPELL_TYPE_ZONE_AND_BUFF    = 6
Global Const $SPELL_TYPE_MOVE   		  = 7
Global Const $SPELL_TYPE_LIFE_AND_ATTACK  = 8
Global Const $SPELL_TYPE_LIFE_OR_ATTACK   = 9
Global Const $SPELL_TYPE_MOVE_OR_ATTACK   = 10
Global Const $SPELL_TYPE_LIFE_OR_BUFF	  = 11
Global Const $SPELL_TYPE_LIFE_OR_MOVE     = 12
Global Const $SPELL_TYPE_LIFE_AND_BUFF    = 13
Global Const $SPELL_TYPE_ATTACK_OR_BUFF   = 14
Global Const $SPELL_TYPE_ATTACK_AND_BUFF  = 15
Global Const $SPELL_TYPE_LIFE_OR_ELITE    = 16
Global Const $SPELL_TYPE_LIFE_AND_ELITE   = 17
Global Const $SPELL_TYPE_ATTACK_OR_ELITE  = 18
Global Const $SPELL_TYPE_ATTACK_AND_ELITE = 19
Global Const $SPELL_TYPE_ELITE_AND_BUFF   = 20
Global Const $SPELL_TYPE_ELITE_OR_BUFF    = 21
Global Const $SPELL_TYPE_PERMANENT_BUFF   = 22
Global Const $SPELL_TYPE_CHANNELING	      = 23

; Item Type
Global Const $ITEM_TYPE_MOB		= 1
Global Const $ITEM_TYPE_SHRINE  = 2
Global Const $ITEM_TYPE_CHEST   = 3
Global Const $ITEM_TYPE_HEALTH  = 4
Global Const $ITEM_TYPE_POWER   = 5
Global Const $ITEM_TYPE_LOOT    = 6
Global Const $ITEM_TYPE_DECOR   = 7
Global Const $ITEM_TYPE_RACK    = 8

; Range Item
Global $range_shrine = 40
Global $range_health = 35
Global $range_power  = 35
Global $range_decor  = 18
Global $range_chest  = 40
Global $range_rack 	 = 40

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

; fonction en execution
Global $Execute_TownPortalnew 	= False
Global $Execute_TpRepairAndBack = False
Global $Execute_StashAndRepair  = False

Global $PortBack 	   			= False
Global $FailOpen_BookOfCain 	= 0

; Informations sur le personnage
Global $nameCharacter
Global $maxhp

; Acte en cours
Global $Act = 0

; Variables pour le déplacement
Global Const $PI 	= 3.141593
Global $Step 	 	= $PI / 6
Global $SkippedMove = 0

; Timer pour la prise de potions
Global $timeforpotion = 0

; Variables pour compter les erreurs
Global $Try_ResumeGame = 0
Global $Try_Logind3    = 0
Global $grabtimeout    = 0
Global $killtimeout    = 0

; Variables pour réaction d'urgence
Global $NeedRepairCount = 0
Global $Die2FastCount   = 0

; Variables pour la gestion de la durée des games / run
Global $timermaxgamelength   = 0
Global $timedifmaxgamelength = 0
Global $GameOverTime         = False
Global $Paused 			     = False

; Ne pas grab lors d'une attaque quand inventaire est full
Global $Inventory_Is_Full = 0

; Variables pour log & debug
Global $DebugMessage
Global $fichierlog  = "log-" & @YEAR & "_" & @MDAY & "_" & @MON & "_" & @HOUR & "h" & @MIN & ".txt"
Global $fichierstat = "stat_" & @YEAR & "_" & @MON & "_" & @MDAY & "-" & @HOUR & "h" & @MIN & ".txt"

; Listes interne
Global $List_BanItemACDCheckList = "a1_|a3_|a2_|a4_|a5_|Lore_Book_Flippy|D3Arrow|Topaz_|Emeraude_|Rubis_|Amethyste_|Console_PowerGlobe|GoldCoin|GoldSmall|GoldMedium|GoldLarge|healthPotion_Console"
Global $List_BanItemStartName    = "DH_|x1_DemonHunter|D3Arrow|barbarian_|Demonhunter_|Monk_|WitchDoctor_|WD_|Enchantress_|Scoundrel_|Templar_|Wizard_|monsterAffix_|Demonic_|Generic_|fallenShaman_fireBall_impact|demonFlyer_B_clickable_corpse_01|grenadier_proj_trail|x1_promoPet_fallenHound_skeletal|a3dun_crater_st_Demon_ChainPylon_Fire_Azmodan_Blocker|a3dun_crater_st_Demon_ChainPylon_Fire_Azmodan|ZoltunKulle_EnergyTwister|a2dun_Cald_Belial_Room_Gate_A|a2dun_Cald_Belial_Room_A_Breakable_main|AngelWings_common_model|lordOfDespair_bladeGlow_model|a3dun_crater_st_Demon_BloodContainer_A|Azmodan_BSS_soul|Belial_BSS_soul"

; Tables de gestions des listes
Global $Table_Coffre 		      = [0]
Global $Table_Rack 			      = [0]
Global $Table_BanMonster  	      = [0]
Global $Table_Monster  		      = [0]
Global $Table_Decor  		      = [0]
Global $Table_BanAffix            = [0]
Global $Table_SpecialMonster      = [0]
Global $Table_BanItemStartName    = [0]
Global $Table_BanItemACDCheckList = [0]
Global $Table_BannedActors 	      = [0]
Global $Table_PriorityMonster     = [0]
Global $Table_Potions 		      = [0]
Global $Table_Grablist 		      = [0]

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
Global $disconnectcount 	 = 0