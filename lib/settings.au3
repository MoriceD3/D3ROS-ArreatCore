#include-once
#AutoIt3Wrapper_UseX64=n

#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.8.1

	Script Function:
	Setup the settings file if it don't exist, overwise, setup de globals

#ce ----------------------------------------------------------------------------
Global $Skill1[11]
Global $Skill2[11]
Global $Skill3[11]
Global $Skill4[11]
Global $Skill5[11]
Global $Skill6[11]

Global $Skill_conf1[6]
Global $Skill_conf2[6]
Global $Skill_conf3[6]
Global $Skill_conf4[6]
Global $Skill_conf5[6]
Global $Skill_conf6[6]

Global $MonsterTri = True
Global $MonsterRefresh = True
Global $ItemRefresh = True
Global $MonsterPriority = False
Global $Unidentified = False
Global $WaitForLoot = True
Global $ShouldPreBuff = False
Global $TakeGlobeInFight = False
Global $NoEnergyForDecor = True
; gestion items
Global $ItemToKeep[10] = [False, False, False, False, False, False, False, False, False, False]
Global $ItemToSalvage[10] = [False, False, False, False, False, False, False, False, False, False]
Global $ItemToSell[10] = [False, False, False, False, False, False, False, False, False, False]
Global $UnknownItemAction = "Sell"
; fonction pause x games
Global $BreakTime = 360
Global $Breakafterxxgames = Round(Random(4, 8))
Global $TakeABreak = False
;Global $PauseRepas = False
Global $tab_grablist[1][2]
Global $PartieSolo = True

Global $profilFile = "settings/settings.ini"
Global $Follower = False
Global $a_range = Round(Random(55, 60))
Global $g_range = Round(Random(100, 120))
Global $a_time = 9000
Global $g_time = 7500
Global $ChaseElite = False
Global $List_BanAffix = ""
Global $List_SpecialMonster = "Goblin|brickhouse_|WoodWraith_|Siege_wallMonster|DuneDervish_|Ghost_|Lamprey_|SkeletonSummoner_|Uber|x1_SpeedKill_Gluttony"
Global $List_PriorityMonster = "Goblin|Uber"
Global $List_Monster = "Beast_B|Goatman_M|Goatman_R|WitherMoth|Beast_A|Scavenger|zombie|Corpulent|Skeleton|QuillDemon|FleshPitFlyer|Succubus|Scorpion|azmodanBodyguard|succubus|ThousandPounder|Fallen|GoatMutant|demonFlyer_B|creepMob|Triune_|TriuneVesselActivated_|TriuneVessel|Triune_Summonable_|ConductorProxyMaster|sandWasp|TriuneCultist|SandShark|Lacuni"
Global $List_BanMonster = "Fetish_Skeleton_A|treasureGoblin_A_Slave|Skeleton_Archer_A_Unique_Ring_|Skeleton_A_Unique_Ring_|WD_ZombieDog|WD_wallOfZombies|DH_Companion"
Global $List_Decor = "Bone|RockPile|DemonCage|Barrel|crate|barricade|Rock|Log|BonePile"
Global $List_Coffre = "Props_Demonic_Container|Crater_Chest|Chest_Snowy|Chest_Frosty|TrOut_Fields_Chest|TrOut_Highlands_Chest|Cath_chest|Chest_Rare|caOut_StingingWinds_Chest|CaOut_Oasis_Chest|x1_Global_Chest|a3dun_Crater_ST_Chest|Chest_Lift|Hidden_Cache"
Global $List_Rack = "WeaponRack|ArmorRack|Weapon_Rack_trOut_Highlands"
Global $List_Potions = "healthPotion_Console|healthPotion_Legendary"
Global $List_BountyAct = "1|2|3"
Global $NoBountyFailbackToAdventure = True
Global $EndSequenceOnBountyCompletion = True
Global $BountyAndSequence = False
Global $PauseAfterBounty = False
Global $grabListFile = ""
Global $repairafterxxgames = Round(Random(4, 8))
Global $maxgamelength = 560000
Global $d3pass = ""
Global $PreBuff1 = False
Global $delaiBuff1 = ""
Global $PreBuff2 = False
Global $delaiBuff2 = ""
Global $PreBuff3 = False
Global $delaiBuff3 = ""
Global $PreBuff4 = False
Global $delaiBuff4 = ""
Global $QualityLevel = 9
Global $LifeForPotion = 50
Global $LifeForHealth = 50
Global $takepot = True
Global $PotionStock = 100
Global $KeyCloseWindows = "{SPACE}"
Global $KeyInventory = "i"
Global $KeyPotions = "q"
Global $KeyPortal = "t"
Global $TakeShrines = False

;équipement spécial
Global $AllIndestructibleObject = False
Global $LegendaryPotion = False
; PauseToSurviveHC
Global $HCSecurity = False
Global $MinHCLife = 0

; BuyPotion
Global $NbPotionBuy = 0

Global $MaximumHatred = 125
Global $MaximumDiscipline = 25
Global $MaximumSpirit = 100
Global $MaximumFury = 100
Global $MaximumArcane = 100
Global $MaximumMana = 100
Global $MaximumWrath  = 100

Global $Devmode = True
Global $UsePath = False
Global $ResActivated = False
Global $ResLife = 0
Global $Res_compt = 0
Global $nb_die_t = 0
Global $rdn_die_t = 0

Global $ftpserver = ""
Global $ftpusername = ""
Global $ftppass = ""
Global $ftpfilename = ""

Global $File_Sequence = "sequence\sequence.txt"

Global $Key1 = "&"
Global $Key2 = "é"
Global $Key3 = '"'
Global $Key4 = "'"
Global $MouseMoveClick = "middle"
Global $InventoryCheck = False

Global $tab_aff[60][2]=[ _
                                                [-5,-5],[-5,5],[5,-5],[5,5], _
                                                [-10,-10],[-10,10],[10,-10],[10,10], _
                                                [-15,-10],[-15,10],[15,-10],[15,10], _
                                                [-10,-20],[-10,20],[10,-20],[10,20], _
                                                [-20,-10],[-20,10],[20,-10],[20,10], _
                                                [-10,-15],[-10,15],[10,-15],[10,15], _
                                                [-15,-15],[-15,15],[15,-15],[15,15], _
                                                [-20,-20],[-20,20],[20,-20],[20,20], _
                                                [-25,-25],[-25,25],[25,-25],[25,25], _
                                                [-30,-30],[-30,30],[30,-30],[30,30], _
                                                [-40,-40],[-40,40],[40,-40],[40,40], _
                                                [-50,-50],[-50,50],[50,-50],[50,50], _
                                                [-60,-60],[-60,60],[60,-60],[60,60], _
                                                [-70,-70],[-70,70],[70,-70],[70,70], _
                                                [-80,-80],[-80,80],[80,-80],[80,80] _
                                                ]
Global $tab_aff2[15][2]=[ _
                                                [5,5], [10,10], [15,10], [10,20], _
                                                [20,10], [10,15], [15,15] , [20,20], _
                                                [25,25], [30,30], [40,40],[50,50], _
                                                [60,60], [70,70], [80,80] _
                                                ]
Global $gestion_affixe 		= False
Global $gestion_affixe_loot = False

; Range affix
Global $range_arcane = 25
Global $range_arm = 15
Global $range_explo = 18
Global $range_ice = 20
Global $range_lave = 13
Global $range_lightning = 22
Global $range_mine = 13
Global $range_peste = 18
Global $range_poison = 18
Global $range_profa = 13
Global $range_proj = 25
Global $range_spore = 20

; Life affix
Global $life_arcane = 100
Global $life_arm = 100
Global $life_explo = 100
Global $life_ice = 100
Global $life_lave = 100
Global $life_lightning = 100
Global $life_mine = 100
Global $life_peste = 100
Global $life_poison = 100
Global $life_profa = 100
Global $life_proj = 100
Global $life_spore = 100

Global $maff_timer = timerinit()
Global $timer_ignore_reset = timerinit()
Global $energy_mini = 0
Dim    $ignore_affix[1][2]
Global $debugBot = False

Global $Gest_affixe_ByClass = False

Func InitSettings($configFile = "settings/settings.ini", $grabListPath = "grablist/")
	loadConfigs($configFile)
	Init_grablistFile($grabListPath)
	Init_GrabListTab()
Endfunc

Func loadConfigs($profilFile = "settings/settings.ini", $creation = 0)

	;; windows informations
	;$winName			= IniRead($profilFile,"windows info","winName","Diablo III")
	;$gamePath			= IniRead($profilFile,"windows info","gameExecFullPath",0)

	;; Account info
	$d3pass = IniRead($profilFile, "Account info", "pass", 0)
	$ftpserver = IniRead($profilFile, "Account info", "ftpserver", $ftpserver)
	$ftpusername = IniRead($profilFile, "Account info", "ftpusername", $ftpusername)
	$ftppass = IniRead($profilFile, "Account info", "ftppass", $ftppass)
	$ftpfilename = IniRead($profilFile, "Account info", "ftpfilename", $ftpfilename)

	;; Key Info
	$KeyCloseWindows = IniRead($profilFile, "Key info", "CloseWindows", $KeyCloseWindows)
	$KeyInventory = IniRead($profilFile, "Key info", "Inventory", $KeyInventory)
	$KeyPotions = IniRead($profilFile, "Key info", "Potions", $KeyPotions)
	$KeyPortal = IniRead($profilFile, "Key info", "Portal", $KeyPortal)
	$Key1 = IniRead($profilFile, "Key info", "Key1", $Key1)
	$Key2 = IniRead($profilFile, "Key info", "Key2", $Key2)
	$Key3 = IniRead($profilFile, "Key info", "Key3", $Key3)
	$Key4 = IniRead($profilFile, "Key info", "Key4", $Key4)
	$MouseMoveClick = IniRead($profilFile, "Key info", "MouseMove", $MouseMoveClick)
	;; Run info

	;; Ajout config run
	$Choix_Act_Run = IniRead($profilFile, "Run info", "Choix_Act_Run", $Choix_Act_Run)

	$SequenceFileAdventure = IniRead($profilFile, "Run info", "SequenceFileAdventure", $SequenceFileAdventure)

	Switch $Choix_Act_Run
		Case 0
			$File_Sequence = IniRead($profilFile, "Run info", "SequenceFile", $File_Sequence)

		Case 1
			$SequenceFileAct1 = IniRead($profilFile, "Run info", "SequenceFileAct1", $SequenceFileAct1)

		Case 2
			$SequenceFileAct2 = IniRead($profilFile, "Run info", "SequenceFileAct2", $SequenceFileAct2)

		Case 3
			$SequenceFileAct3 = IniRead($profilFile, "Run info", "SequenceFileAct3", $SequenceFileAct3)
			$SequenceFileAct3PtSauve = IniRead($profilFile, "Run info", "SequenceFileAct3PtSauve", $SequenceFileAct3PtSauve)

		Case 222 ; Act 2 quête 2 sous quête 2 --> tuez Lieutenent Vachem
			$SequenceFileAct222 = IniRead($profilFile, "Run info", "SequenceFileAct222", $SequenceFileAct222)

		Case 232 ; Act 2 quête 3 sous quête 2 --> tuez Maghda
			$SequenceFileAct232 = IniRead($profilFile, "Run info", "SequenceFileAct232", $SequenceFileAct232)

		Case 283 ; Act 2 quête 8 sous quête 3 --> Tuer Zoltun Kulle
			$SequenceFileAct283 = IniRead($profilFile, "Run info", "SequenceFileAct283", $SequenceFileAct283)

		Case 299 ; Act 2 quête 10 sous quête 1 --> Tuer Belial
			$SequenceFileAct299 = IniRead($profilFile, "Run info", "SequenceFileAct299", $SequenceFileAct299)

		Case 333 ; Act 3 quête 3 sous quête 3 --> tuez Ghom
			$SequenceFileAct333 = IniRead($profilFile, "Run info", "SequenceFileAct333", $SequenceFileAct333)

		Case 362 ; Act 3 quête 6 sous quête 2 --> Tuez le briseur de siège
			$SequenceFileAct362 = IniRead($profilFile, "Run info", "SequenceFileAct362", $SequenceFileAct362)

		Case 373 ; Act 3 quête 7 sous quête 3 --> Terrasez Asmodam
			$SequenceFileAct373 = IniRead($profilFile, "Run info", "SequenceFileAct373", $SequenceFileAct373)

		Case 374 ; Act 3 quête 7 sous quête 3 --> Terrasez Asmodam, Iskatu et Rakanoth
			$SequenceFileAct374 = IniRead($profilFile, "Run info", "SequenceFileAct374", $SequenceFileAct374)

		Case 411 ; Act 4 quête 1 sous quête 1 --> Terrasez Iskatu et Rakanoth
			$SequenceFileAct411 = IniRead($profilFile, "Run info", "SequenceFileAct411", $SequenceFileAct411)

		Case 442 ; Act 4 quête 4 sous quête 2 --> Terrasez Diablo
			$SequenceFileAct442 = IniRead($profilFile, "Run info", "SequenceFileAct442", $SequenceFileAct442)

		Case -1
			$SequenceFileAct1 = IniRead($profilFile, "Run info", "SequenceFileAct1", $SequenceFileAct1)
			$SequenceFileAct2 = IniRead($profilFile, "Run info", "SequenceFileAct2", $SequenceFileAct2)
			$SequenceFileAct3 = IniRead($profilFile, "Run info", "SequenceFileAct3", $SequenceFileAct3)
			$SequenceFileAct3PtSauve = IniRead($profilFile, "Run info", "SequenceFileAct3PtSauve", $SequenceFileAct3PtSauve)
			$Dummy = IniRead($profilFile, "Run info", "Sequence_Aleatoire", $Sequence_Aleatoire)
			$Sequence_Aleatoire = Trim(StringLower($Dummy)) == "true"
			$NbreRunChangSeqAlea = IniRead($profilFile, "Run info", "NbreRunChangSeqAlea", $NbreRunChangSeqAlea)
			$Nombre_de_Run = IniRead($profilFile, "Run info", "Nombre_de_Run", $Nombre_de_Run)
			$NombreMiniAct1 = IniRead($profilFile, "Run info", "NombreMiniAct1", $NombreMiniAct1)
			$NombreMiniAct2 = IniRead($profilFile, "Run info", "NombreMiniAct2", $NombreMiniAct2)
			$NombreMiniAct3 = IniRead($profilFile, "Run info", "NombreMiniAct3", $NombreMiniAct3)
			$NombreMaxiAct1 = IniRead($profilFile, "Run info", "NombreMaxiAct1", $NombreMaxiAct1)
			$NombreMaxiAct2 = IniRead($profilFile, "Run info", "NombreMaxiAct2", $NombreMaxiAct2)
			$NombreMaxiAct3 = IniRead($profilFile, "Run info", "NombreMaxiAct3", $NombreMaxiAct3)
	EndSwitch

	$List_BountyAct = IniRead($profilFile, "Run info", "BountyAct", $List_BountyAct)
	;; Fin d'ajout config run

	$List_Monster = IniRead($profilFile, "Run info", "monsterList", $List_Monster)
	$List_Decor = IniRead($profilFile, "Run info", "decorList", $List_Decor)
	$List_Coffre = IniRead($profilFile, "Run info", "chestList", $List_Coffre)
	$List_Rack = IniRead($profilFile, "Run info", "rackList", $List_Rack)
	$List_SpecialMonster = IniRead($profilFile, "Run info", "SpecialmonsterList", $List_SpecialMonster)
	$List_PriorityMonster = IniRead($profilFile, "Run info", "PriorityMonsterList", $List_PriorityMonster)
	$Dummy = IniRead($profilFile, "Run info", "ChaseElite", $ChaseElite)
	$ChaseElite = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($profilFile, "Run info", "WaitForLoot", $WaitForLoot)
	$WaitForLoot = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($profilFile, "Run info", "Follower", $Follower)
	$Follower = Trim(StringLower($Dummy)) == "true"

	;Selection de la difficulte et du pm des monstres
	$difficulte = IniRead($profilFile, "Run info", "difficulte", $difficulte)
	$PuisMonstre = IniRead($profilFile, "Run info", "PuisMonstre", $PuisMonstre)

	;Selection du type de graliste pour le mode arma
	$TypeDeGrabList = IniRead($profilFile, "Run info", "TypeDeGrabList", $TypeDeGrabList)

	;Selection de la GrabListe suivant la difficulté
	Switch $TypeDeGrabList
		Case 1 ; Grablist difficulté
			Switch $difficulte
				Case 1
					$grabListFile = IniRead($profilFile, "Run info", "grablistNormal", $grabListFile)
				Case 2
					$grabListFile = IniRead($profilFile, "Run info", "grablistDifficile", $grabListFile)
				Case 3
					$grabListFile = IniRead($profilFile, "Run info", "grablistExpert", $grabListFile)
				Case 4
					$grabListFile = IniRead($profilFile, "Run info", "grablistCalvaire", $grabListFile)
				Case 5
					$grabListFile = IniRead($profilFile, "Run info", "grabListTourment", $grabListFile)
			EndSwitch
		Case 2 ; Grablist XP
			$grabListFile = IniRead($profilFile, "Run info", "grabListXP", $grabListFile)
	EndSwitch

	$Dummy = IniRead($profilFile, "Run info", "QualiteItemKeep", "9")
	$Dummy = StringSplit($Dummy, "|")
	For $i = 1 To UBound($Dummy) - 1
		If IsNumber(Int($Dummy[$i])) Then
			If Int($Dummy[$i]) > 0 And Int($Dummy[$i]) < 10 Then
				$ItemToKeep[Int($Dummy[$i])] = True
			EndIf
		EndIf
	Next
	$Dummy = IniRead($profilFile, "Run info", "QualiteItemSalvage", "")
	$Dummy = StringSplit($Dummy, "|")
	For $i = 1 To UBound($Dummy) - 1
		If IsNumber(Int($Dummy[$i])) Then
			If Int($Dummy[$i]) > 0 And Int($Dummy[$i]) < 10 Then
				$ItemToSalvage[Int($Dummy[$i])] = True
			EndIf
		EndIf
	Next
	$Dummy = IniRead($profilFile, "Run info", "QualiteItemSell", "")
	$Dummy = StringSplit($Dummy, "|")
	For $i = 1 To UBound($Dummy) - 1
		If IsNumber(Int($Dummy[$i])) Then
			If Int($Dummy[$i]) > 0 And Int($Dummy[$i]) < 10 Then
				$ItemToSell[Int($Dummy[$i])] = True
			EndIf
		EndIf
	Next

	$UnknownItemAction = IniRead($profilFile, "Run info", "UnknownItemAction", $UnknownItemAction)
	$Dummy = IniRead($profilFile, "Run info", "Unidentified", $Unidentified)
	$Unidentified = Trim(StringLower($Dummy)) == "true"

	; fonction pause x games
	$BreakTime = IniRead($profilFile, "Run info", "BreakTime", $BreakTime)
	$Breakafterxxgames = IniRead($profilFile, "Run info", "Breakafterxxgames", $Breakafterxxgames)
	$Dummy = IniRead($profilFile, "Run info", "TakeABreak", $TakeABreak)
	$TakeABreak = Trim(StringLower($Dummy)) == "true"
	;$Dummy = IniRead($profilFile, "Run info", "PauseRepas", $PauseRepas)
	;$PauseRepas = Trim(StringLower($Dummy)) == "true"

	;choix du type de bot
	$TypedeBot = IniRead($profilFile, "Run info", "TypeDeBot", $TypedeBot)
	$Dummy = IniRead($profilFile, "Run info", "PartieSolo", $PartieSolo)
	$PartieSolo = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($profilFile, "Run info", "NoBountyFailbackToAdventure", $NoBountyFailbackToAdventure)
	$NoBountyFailbackToAdventure = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($profilFile, "Run info", "EndSequenceOnBountyCompletion", $EndSequenceOnBountyCompletion)
	$EndSequenceOnBountyCompletion = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($profilFile, "Run info", "BountyAndSequence", $BountyAndSequence)
	$BountyAndSequence = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($profilFile, "Run info", "PauseAfterBounty", $PauseAfterBounty)
	$PauseAfterBounty = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($profilFile, "Run info", "debug", $debugBot)
	$debugBot = Trim(StringLower($Dummy)) == "true"
	;$Act = IniRead($profilFile,"Run info","Act", $Act)
	$Dummy = IniRead($profilFile, "Run info", "Devmode", $Devmode)
	$Devmode = Trim(StringLower($Dummy)) == "true"

	;Fonction Iniatialisation du Skill suivant le Héros
	$Heros = IniRead($profilFile, "Run info", "Heros", $Heros)

	InitSkillHeros("settings/settingsHero" & $Heros & ".ini")

	;Chargement des tables
	LoadTableFromString($Table_Coffre, $List_Coffre)
	LoadTableFromString($Table_Rack, $List_Rack)
	LoadTableFromString($Table_BanMonster, $List_BanMonster, False)
	LoadTableFromString($Table_Monster, $List_Monster)
	LoadTableFromString($Table_SpecialMonster, $List_SpecialMonster)
	LoadTableFromString($Table_BanItemStartName, $List_BanItemStartName)
	LoadTableFromString($Table_BanItemACDCheckList, $List_BanItemACDCheckList)
	LoadTableFromString($Table_Decor, $List_Decor)
	LoadTableFromString($Table_BanAffix, $List_BanAffix)
	LoadTableFromString($Table_PriorityMonster, $List_PriorityMonster)
	LoadTableFromString($Table_Potions, $List_Potions)

EndFunc   ;==>LoadConfigs

Func InitSkillHeros($skillHeros)
	; pre-buff
	$Dummy = IniRead($skillHeros, "Run info", "SpellPreBuff1", $PreBuff1)
	$PreBuff1 = Trim(StringLower($Dummy)) == "true"
	$delaiBuff1 = IniRead($skillHeros, "Run info", "SpellPreBuffDelay1", $delaiBuff1)

	$Dummy = IniRead($skillHeros, "Run info", "SpellPreBuff2", $PreBuff2)
	$PreBuff2 = Trim(StringLower($Dummy)) == "true"
	$delaiBuff2 = IniRead($skillHeros, "Run info", "SpellPreBuffDelay2", $delaiBuff2)

	$Dummy = IniRead($skillHeros, "Run info", "SpellPreBuff3", $PreBuff3)
	$PreBuff3 = Trim(StringLower($Dummy)) == "true"
	$delaiBuff3 = IniRead($skillHeros, "Run info", "SpellPreBuffDelay3", $delaiBuff3)

	$Dummy = IniRead($skillHeros, "Run info", "SpellPreBuff4", $PreBuff4)
	$PreBuff4 = Trim(StringLower($Dummy)) == "true"
	$delaiBuff4 = IniRead($skillHeros, "Run info", "SpellPreBuffDelay4", $delaiBuff4)

	If $PreBuff1 Or $PreBuff2 Or $PreBuff3 Or $PreBuff4 Then
		$ShouldPreBuff = True
	EndIf

	;; Spells
	$Skill_conf1[0] = IniRead($skillHeros, "Run info", "SpellOnLeft", $Skill_conf1[0])
	$Skill_conf1[1] = IniRead($skillHeros, "Run info", "SpellDelayLeft", $Skill_conf1[1])
	$Skill_conf1[2] = IniRead($skillHeros, "Run info", "SpellTypeLeft", $Skill_conf1[2])
	$Skill_conf1[3] = IniRead($skillHeros, "Run info", "SpellEnergyNeedsLeft", $Skill_conf1[3])
	$Skill_conf1[4] = IniRead($skillHeros, "Run info", "SpellLifeLeft", $Skill_conf1[4])
	$Skill_conf1[5] = IniRead($skillHeros, "Run info", "SpellDistanceLeft", $Skill_conf1[5])

	$Skill_conf2[0] = IniRead($skillHeros, "Run info", "SpellOnRight", $Skill_conf2[0])
	$Skill_conf2[1] = IniRead($skillHeros, "Run info", "SpellDelayRight", $Skill_conf2[1])
	$Skill_conf2[2] = IniRead($skillHeros, "Run info", "SpellTypeRight", $Skill_conf2[2])
	$Skill_conf2[3] = IniRead($skillHeros, "Run info", "SpellEnergyNeedsRight", $Skill_conf2[3])
	$Skill_conf2[4] = IniRead($skillHeros, "Run info", "SpellLifeRight", $Skill_conf2[4])
	$Skill_conf2[5] = IniRead($skillHeros, "Run info", "SpellDistanceRight", $Skill_conf2[5])

	$Skill_conf3[0] = IniRead($skillHeros, "Run info", "SpellOn1", $Skill_conf3[0])
	$Skill_conf3[1] = IniRead($skillHeros, "Run info", "SpellDelay1", $Skill_conf3[1])
	$Skill_conf3[2] = IniRead($skillHeros, "Run info", "SpellType1", $Skill_conf3[2])
	$Skill_conf3[3] = IniRead($skillHeros, "Run info", "SpellEnergyNeeds1", $Skill_conf3[3])
	$Skill_conf3[4] = IniRead($skillHeros, "Run info", "SpellLife1", $Skill_conf3[4])
	$Skill_conf3[5] = IniRead($skillHeros, "Run info", "SpellDistance1", $Skill_conf3[5])

	$Skill_conf4[0] = IniRead($skillHeros, "Run info", "SpellOn2", $Skill_conf4[0])
	$Skill_conf4[1] = IniRead($skillHeros, "Run info", "SpellDelay2", $Skill_conf4[1])
	$Skill_conf4[2] = IniRead($skillHeros, "Run info", "SpellType2", $Skill_conf4[2])
	$Skill_conf4[3] = IniRead($skillHeros, "Run info", "SpellEnergyNeeds2", $Skill_conf4[3])
	$Skill_conf4[4] = IniRead($skillHeros, "Run info", "SpellLife2", $Skill_conf4[4])
	$Skill_conf4[5] = IniRead($skillHeros, "Run info", "SpellDistance2", $Skill_conf4[5])

	$Skill_conf5[0] = IniRead($skillHeros, "Run info", "SpellOn3", $Skill_conf5[0])
	$Skill_conf5[1] = IniRead($skillHeros, "Run info", "SpellDelay3", $Skill_conf5[1])
	$Skill_conf5[2] = IniRead($skillHeros, "Run info", "SpellType3", $Skill_conf5[2])
	$Skill_conf5[3] = IniRead($skillHeros, "Run info", "SpellEnergyNeeds3", $Skill_conf5[3])
	$Skill_conf5[4] = IniRead($skillHeros, "Run info", "SpellLife3", $Skill_conf5[4])
	$Skill_conf5[5] = IniRead($skillHeros, "Run info", "SpellDistance3", $Skill_conf5[5])

	$Skill_conf6[0] = IniRead($skillHeros, "Run info", "SpellOn4", $Skill_conf6[0])
	$Skill_conf6[1] = IniRead($skillHeros, "Run info", "SpellDelay4", $Skill_conf6[1])
	$Skill_conf6[2] = IniRead($skillHeros, "Run info", "SpellType4", $Skill_conf6[2])
	$Skill_conf6[3] = IniRead($skillHeros, "Run info", "SpellEnergyNeeds4", $Skill_conf6[3])
	$Skill_conf6[4] = IniRead($skillHeros, "Run info", "SpellLife4", $Skill_conf6[4])
	$Skill_conf6[5] = IniRead($skillHeros, "Run info", "SpellDistance4", $Skill_conf6[5])

	; Routines
	$LifeForPotion = IniRead($skillHeros, "Run info", "LifeForPotion", $LifeForPotion)
	$Dummy = IniRead($skillHeros, "Run info", "LegendaryPotion", $LegendaryPotion)
	$LegendaryPotion = Trim(StringLower($Dummy)) == "true"
	$PotionStock = IniRead($skillHeros, "Run info", "PotionStock", $PotionStock)
	$LifeForHealth = IniRead($skillHeros, "Run info", "LifeForHealth", $LifeForHealth)

	; BuyPotion
	$NbPotionBuy = IniRead($skillHeros, "Run info", "NbPotionBuy", $NbPotionBuy)

	$Dummy = IniRead($skillHeros, "Run info", "TakeShrines", $TakeShrines)
	$TakeShrines = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($skillHeros, "Run info", "NoEnergyForDecor", $NoEnergyForDecor)
	$NoEnergyForDecor = Trim(StringLower($Dummy)) == "true"

	$repairafterxxgames = IniRead($skillHeros, "Run info", "repairafterxxgames", $repairafterxxgames)
	$Dummy = IniRead($skillHeros, "Run info", "AllIndestructibleObject", $AllIndestructibleObject)
	$AllIndestructibleObject = Trim(StringLower($Dummy)) == "true"

	$maxgamelength = IniRead($skillHeros, "Run info", "maxgamelength", $maxgamelength)
	$a_range = IniRead($skillHeros, "Run info", "attackRange", $a_range)
	$g_range = IniRead($skillHeros, "Run info", "grabRange", $g_range)

	$Dummy = IniRead($skillHeros, "Run info", "MonsterTri", $MonsterTri)
	$MonsterTri = Trim(StringLower($Dummy)) == "true"
	$Dummy = IniRead($skillHeros, "Run info", "MonsterRefresh", $MonsterRefresh)
	$MonsterRefresh = Trim(StringLower($Dummy)) == "true"
	$Dummy = IniRead($skillHeros, "Run info", "ItemRefresh", $ItemRefresh)
	$ItemRefresh = Trim(StringLower($Dummy)) == "true"
	$Dummy = IniRead($skillHeros, "Run info", "MonsterPriority", $MonsterPriority)
	$MonsterPriority = Trim(StringLower($Dummy)) == "true"
	$Dummy = IniRead($skillHeros, "Run info", "InventoryCheck", $InventoryCheck)
	$InventoryCheck = Trim(StringLower($Dummy)) == "true"

	$Dummy = IniRead($skillHeros, "Run info", "TakeGlobeInFight", $TakeGlobeInFight)
	$TakeGlobeInFight = Trim(StringLower($Dummy)) == "true"

	$a_time = IniRead($skillHeros, "Run info", "attacktimeout", $a_time)
	$g_time = IniRead($skillHeros, "Run info", "grabtimeout", $g_time)

	$Dummy = IniRead($skillHeros, "Run info", "gestion_affixe", $gestion_affixe)
	$gestion_affixe = Trim(StringLower($Dummy)) == "true"
	$Dummy = IniRead($skillHeros, "Run info", "gestion_affixe_loot", $gestion_affixe_loot)
	$gestion_affixe_loot = Trim(StringLower($Dummy)) == "true"
	$List_BanAffix = IniRead($skillHeros, "Run info", "BanAffixList", $List_BanAffix)
	If $List_BanAffix = "" Then
		$List_BanAffix = "poison_humanoid"
	Else
		$List_BanAffix = "poison_humanoid|" &  $List_BanAffix
	EndIf

	$Dummy = IniRead($skillHeros, "Run info", "Gest_affixe_ByClass", $Gest_affixe_ByClass)
	$Gest_affixe_ByClass = Trim(StringLower($Dummy)) == "true"

	$life_arcane = IniRead($skillHeros, "Run info", "Life_Arcane", $life_arcane)
	$life_arm = IniRead($skillHeros, "Run info", "Life_Arm", $life_arm)
	$life_explo = IniRead($skillHeros, "Run info", "Life_Explo", $life_explo)
	$life_ice = IniRead($skillHeros, "Run info", "Life_Ice", $life_ice)
	$life_lave = IniRead($skillHeros, "Run info", "Life_Lave", $life_lave)
	$life_lightning = IniRead($skillHeros, "Run info", "Life_Lightning", $life_lightning)
	$life_mine = IniRead($skillHeros, "Run info", "Life_Mine", $life_mine)
	$life_peste = IniRead($skillHeros, "Run info", "Life_Peste", $life_peste)
	$life_poison = IniRead($skillHeros, "Run info", "Life_Poison", $life_poison)
	$life_profa = IniRead($skillHeros, "Run info", "Life_Profa", $life_profa)
	$life_proj = IniRead($skillHeros, "Run info", "Life_Proj", $life_proj)
	$life_spore = IniRead($skillHeros, "Run info", "Life_Spore", $life_spore)

	$Dummy = StringLower(IniRead($skillHeros, "Run info", "UsePath", $UsePath))
	$UsePath = Trim(StringLower($Dummy)) == "true"
	$Dummy = StringLower(IniRead($skillHeros, "Run info", "ResActivated", $ResActivated))
	$ResActivated = Trim(StringLower($Dummy)) == "true"
	$ResLife = IniRead($skillHeros, "Run info", "ResLife", $ResLife)

	;PauseToSurviveHC
	$Dummy = IniRead($skillHeros, "Run info", "HCSecurity", $HCSecurity)
	$HCSecurity = Trim(StringLower($Dummy)) == "true"
	$MinHCLife = IniRead($skillHeros, "Run info", "MinHCLife", $MinHCLife)

EndFunc   ;==>InitSkillHeros

 Func Init_GrabListTab()

	Dim $tab_temp = StringSplit($List_grablist, "|", 2)

	Local $rules_ilvl = '(?i)\[ilvl:([0-9]{1,2})\]'
	Local $rules_quality = '(?i)\[q:([0-9]{1,2})\]'
	Local $rules_filtre = '(?i)\(([[:ascii:]+]+)\)' ;enleve les "(" de premier niveau

	Local $i = 0, $detect = 0
	Global $GrabListTab[UBound($tab_temp)][5]
	For $y = 0 To UBound($tab_temp) - 1
		$tab_buff = StringLower(trim($tab_temp[$y]))

		If StringRegExp($tab_buff, $rules_ilvl) = 1 Then ;patern declaration ilvl
			$tab_RegExp = StringRegExp($tab_buff, $rules_ilvl, 2)
			$tab_buff = StringReplace($tab_buff, $tab_RegExp[0], "", 0, 2)

			$curr_ilvl = $tab_RegExp[1]
		Else
			$curr_ilvl = 0
		EndIf


		If StringRegExp($tab_buff, $rules_quality) = 1 Then ;patern declaration quality
			$tab_RegExp = StringRegExp($tab_buff, $rules_quality, 2)
			$tab_buff = StringReplace($tab_buff, $tab_RegExp[0], "", 0, 2)
			$curr_quality = $tab_RegExp[1]
		Else
			$curr_quality = 0
		EndIf


		If StringRegExp($tab_buff, $rules_filtre) = 1 Then ;patern declaration filtre
			$tab_RegExp = StringRegExp($tab_buff, $rules_filtre, 2)
			$tab_buff = StringReplace($tab_buff, $tab_RegExp[0], "", 0, 2)
			;$tab_RegExp[1] = StringReplace($tab_RegExp[1], "and", " and ", 0, 2)
			;$tab_RegExp[1] = StringReplace($tab_RegExp[1], "or", " or ", 0, 2)

			For $x = 0 To UBound($tab_grablist) - 1
				If StringInStr($tab_RegExp[1], $tab_grablist[$x][0], 0) Then
					$tab_RegExp[1] = StringReplace($tab_RegExp[1], $tab_grablist[$x][0], $tab_grablist[$x][1], 0, 2)
				EndIf
			Next

			$curr_filtre = $tab_RegExp[1]
			$curr_filtre_str = give_str_from_filter($tab_RegExp[1])
		Else
			$curr_filtre = 0
			$curr_filtre_str = ""
		EndIf

		For $x = 0 To UBound($tab_grablist) - 1
			If StringInStr($tab_buff, $tab_grablist[$x][0], 0) Then
				$tab = StringSplit($tab_grablist[$x][1], "|", 2)
				For $Z = 0 To UBound($tab) - 1

					If $Z > 0 Then
						ReDim $GrabListTab[UBound($GrabListTab) + 1][5]
					EndIf

					$GrabListTab[$i][0] = $tab[$Z]
					$GrabListTab[$i][1] = $curr_ilvl
					$GrabListTab[$i][2] = $curr_quality
					$GrabListTab[$i][3] = $curr_filtre
					$GrabListTab[$i][4] = $curr_filtre_str

					$i += 1
				Next
				$detect = 1
			EndIf
		Next

		If $detect = 0 Then
			$GrabListTab[$i][0] = $tab_buff
			$GrabListTab[$i][1] = $curr_ilvl
			$GrabListTab[$i][2] = $curr_quality
			$GrabListTab[$i][3] = $curr_filtre
			$GrabListTab[$i][4] = $curr_filtre_str
			$i += 1
		EndIf
		$detect = 0
	Next
EndFunc   ;==>Init_GrabListTab

Func Init_grablistFile($grabListPath = "grablist/")
	Dim $txttoarray[1]
	Local $compt_line = 0

	_log("Loading grablist : " & $grabListPath &  $grabListFile)
	Local $file = FileOpen($grabListPath &  $grabListFile, 0)
	If $file = -1 Then
		MsgBox(0, "Error", "Unable to open file : " & $grabListFile)
		Exit
	EndIf

	While 1 ;Boucle de traitement de lecture du fichier txt
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop

		If $line <> "" Then
			$line = StringLower($line)
			ReDim $txttoarray[$compt_line + 1]
			$txttoarray[$compt_line] = $line
			$compt_line += 1
		EndIf
	WEnd

	FileClose($file)

	$List_grablist = ""
	Local $compt = 0

	For $i = 0 To UBound($txttoarray) - 1
		If StringInStr($txttoarray[$i], "=", 0) Then
			$var_temp = StringSplit($txttoarray[$i], "=", 2)
			$var_temp[0] = trim($var_temp[0])
			ReDim $tab_grablist[$compt + 1][2]
			$tab_grablist[$compt][0] = $var_temp[0]
			$tab_grablist[$compt][1] = $var_temp[1]
			;Assign("_filter_" & $var_temp[0], $var_temp[1], 2)
			$compt += 1
		Else
			If $List_grablist = "" Then
				$List_grablist = $txttoarray[$i]
			Else
				$List_grablist = $List_grablist & "|" & $txttoarray[$i]
			EndIf
		EndIf
	Next

	LoadTableFromString($Table_Grablist, $List_grablist, False)

EndFunc   ;==>Init_grablistFile
