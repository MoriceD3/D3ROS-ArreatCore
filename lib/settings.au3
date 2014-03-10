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


Global $MonsterTri = "True"
Global $MonsterRefresh = "True"
Global $ItemRefresh = "True"
Global $MonsterPriority = "False"
Global $Unidentified = "false"

Global $profilFile = "settings.ini"
Global $a_range = Round(Random(55, 60))
Global $g_range = Round(Random(100, 120))
Global $a_time = 9000
Global $g_time = 7500
Global $SpecialmonsterList = "Goblin|brickhouse_|woodwraith_"
Global $monsterList = "Beast_B|Goatman_M|Goatman_R|WitherMoth|Beast_A|Scavenger|zombie|Corpulent|Skeleton|QuillDemon|FleshPitFlyer|Succubus|Scorpion|azmodanBodyguard|succubus|ThousandPounder|Fallen|GoatMutant|demonFlyer_B|creepMob|Triune_|TriuneVesselActivated_|TriuneVessel|Triune_Summonable_|ConductorProxyMaster|sandWasp|TriuneCultist|SandShark|Lacuni"
Global $BanmonsterList = "treasureGoblin_A_Slave|Skeleton_Archer_A_Unique_Ring_|Skeleton_A_Unique_Ring_|WD_ZombieDog|WD_wallOfZombies|DH_Companion|"
Global $grabListFile = ""
Global $Potions = "healthPotion_Mythic"
Global $repairafterxxgames = Round(Random(4, 8))
Global $maxgamelength = 560000
Global $d3pass = ""
Global $PreBuff1 = ""
Global $ToucheBuff1 = ""
Global $delaiBuff1 = ""
Global $PreBuff2 = ""
Global $ToucheBuff2 = ""
Global $delaiBuff2 = ""
Global $PreBuff3 = ""
Global $ToucheBuff3 = ""
Global $delaiBuff3 = ""
Global $PreBuff4 = ""
Global $ToucheBuff4 = ""
Global $delaiBuff4 = ""
Global $QualityLevel = 9
Global $LifeForPotion = 50
Global $takepot = True
Global $PotionStock = 100
Global $TakeShrines = "false"

Global $MaximumHatred = 125
Global $MaximumDiscipline = 25
Global $MaximumSpirit = 100
Global $MaximumFury = 100
Global $MaximumArcane = 100
Global $MaximumMana = 100

;Global $Act = "3"
Global $Devmode = "true"

Global $UsePath = "false"
Global $ResActivated = "false"
Global $ResLife = "0"
Global $Res_compt = 0
Global $nb_die_t = 0
Global $rdn_die_t = 0

Global $ftpserver=""
Global $ftpusername=""
Global $ftppass=""
Global $ftpfilename=""

Global $File_Sequence = "sequence\sequence.txt"

Global $Key1 = "&"
Global $Key2 = "é"
Global $Key3 = '"'
Global $Key4 = "'"

Global $InventoryCheck = "False"



global $tab_aff[60][2]=[ _
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
global $tab_aff2[15][2]=[ _
                                                [5,5], [10,10], [15,10], [10,20], _
                                                [20,10], [10,15], [15,15] , [20,20], _
                                                [25,25], [30,30], [40,40],[50,50], _
                                                [60,60], [70,70], [80,80] _
                                                ]
	global $gestion_affixe="false"
	global $gestion_affixe_loot="false"
	global $range_arcane=25
	global $range_peste=18
	global $range_profa=13
	global $range_lave=13
	global $range_arm=15
	global $range_mine=13
	global $range_explosion=18
	global $range_ice=20
	Global $life_arcane=100
	Global $life_peste=100
	Global $life_profa=100
	Global $life_ice=100
	Global $life_poison=100
	Global $life_explo=100
	Global $life_lave=100
	Global $life_mine=100
	Global $life_arm=100
	Global $life_spore=100
	Global $maff_timer=timerinit()
	global $timer_ignore_reset=timerinit()
	global $energy_mini=0
	global $BanAffixList=""
    dim $ignore_affix[1][2]

	Global $Gest_affixe_ByClass = "false"
global $key_cana=""
global $cana_statut=""
If Not FileExists($profilFile) Then
	writeConfigs()
EndIf

loadConfigs()
Init_grablistFile()
Init_GrabListTab()

Func writeConfigs($profilFile = "settings.ini", $creation = 0)
	IniWrite($profilFile, "Run info", "SequenceFile", $File_Sequence)
	IniWrite($profilFile, "Run info", "UsePath", $UsePath)
	IniWrite($profilFile, "Run info", "ResActivated", $ResActivated)
	IniWrite($profilFile, "Run info", "Reslife", $ResLife)
	IniWrite($profilFile, "Account info", "pass", 0)
	IniWrite($profilFile, "Run info", "monsterList", $monsterList)
	IniWrite($profilFile, "Run info", "specialmonsterList", $SpecialmonsterList)
	IniWrite($profilFile, "Run info", "MonsterTri", $MonsterTri)
	IniWrite($profilFile, "Run info", "MonsterRefresh", $MonsterRefresh)
	IniWrite($profilFile, "Run info", "ItemRefresh", $ItemRefresh)
	IniWrite($profilFile, "Run info", "MonsterPriority", $MonsterPriority)
	IniWrite($profilFile, "Run info", "grabListFile", $grabListFile)
	IniWrite($profilFile, "Run info", "QualiteItem", $QualityLevel)
	IniWrite($profilFile, "Run info", "attackRange", $a_range)
	IniWrite($profilFile, "Run info", "grabRange", $g_range)
	IniWrite($profilFile, "Run info", "attacktimeout", $a_time)
	IniWrite($profilFile, "Run info", "grabtimeout", $g_time)
	IniWrite($profilFile, "Run info", "repairafterxxgames", $repairafterxxgames)
	IniWrite($profilFile, "Run info", "maxgamelength", $maxgamelength)
	IniWrite($profilFile, "Run info", "Potions", $Potions)
	IniWrite($profilFile, "Run info", "PreBuff1", $PreBuff1)
	IniWrite($profilFile, "Run info", "ToucheBuff1", $ToucheBuff1)
	IniWrite($profilFile, "Run info", "delaiBuff1", $delaiBuff1)
	IniWrite($profilFile, "Run info", "PreBuff2", $PreBuff2)
	IniWrite($profilFile, "Run info", "ToucheBuff2", $ToucheBuff2)
	IniWrite($profilFile, "Run info", "delaiBuff2", $delaiBuff2)
	IniWrite($profilFile, "Run info", "PreBuff3", $PreBuff3)
	IniWrite($profilFile, "Run info", "ToucheBuff3", $ToucheBuff3)
	IniWrite($profilFile, "Run info", "delaiBuff3", $delaiBuff3)
	IniWrite($profilFile, "Run info", "PreBuff4", $PreBuff4)
	IniWrite($profilFile, "Run info", "ToucheBuff4", $ToucheBuff4)
	IniWrite($profilFile, "Run info", "delaiBuff4", $delaiBuff4)
	IniWrite($profilFile, "Run info", "LifeForPotion", $LifeForPotion)
	IniWrite($profilFile, "Run info", "PotionStock", $PotionStock)
	IniWrite($profilFile, "Run info", "TakeShrines", $TakeShrines)
	IniWrite($profilFile, "Run info", "Unidentified", $Unidentified)

	IniWrite($profilFile,"Account info","ftpserver", $ftpserver)
	IniWrite($profilFile,"Account info","ftpusername", $ftpusername)
	IniWrite($profilFile,"Account info","ftppass", $ftppass)
	IniWrite($profilFile,"Account info","ftpfilename", $ftpfilename)

;~ 	IniWrite($profilFile, "Run info", "MaximumHatred", $MaximumHatred)
;~ 	IniWrite($profilFile, "Run info", "MaximumDiscipline", $MaximumDiscipline)
;~ 	IniWrite($profilFile, "Run info", "MaximumSpirit", $MaximumSpirit)
;~ 	IniWrite($profilFile, "Run info", "MaximumFury", $MaximumFury)
;~ 	IniWrite($profilFile, "Run info", "MaximumArcane", $MaximumArcane)
;~ 	IniWrite($profilFile, "Run info", "MaximumMana", $MaximumMana)


	IniWrite($profilFile, "Run info", "SpellOnLeft", $Skill_conf1[0])
	IniWrite($profilFile, "Run info", "SpellDelayLeft", $Skill_conf1[1])
	IniWrite($profilFile, "Run info", "SpellTypeLeft", $Skill_conf1[2])
	IniWrite($profilFile, "Run info", "SpellEnergyNeedsLeft", $Skill_conf1[3])
	IniWrite($profilFile, "Run info", "SpellLifeLeft", $Skill_conf1[4])
	IniWrite($profilFile, "Run info", "SpellDistanceLeft", $Skill_conf1[5])

	IniWrite($profilFile, "Run info", "SpellOnRight", $Skill_conf2[0])
	IniWrite($profilFile, "Run info", "SpellDelayRight", $Skill_conf2[1])
	IniWrite($profilFile, "Run info", "SpellTypeRight", $Skill_conf2[2])
	IniWrite($profilFile, "Run info", "SpellEnergyNeedsRight", $Skill_conf2[3])
	IniWrite($profilFile, "Run info", "SpellLifeRight", $Skill_conf2[4])
	IniWrite($profilFile, "Run info", "SpellDistanceRight", $Skill_conf2[5])

	IniWrite($profilFile, "Run info", "SpellOn1", $Skill_conf3[0])
	IniWrite($profilFile, "Run info", "SpellDelay1", $Skill_conf3[1])
	IniWrite($profilFile, "Run info", "SpellType1", $Skill_conf3[2])
	IniWrite($profilFile, "Run info", "SpellEnergyNeeds1", $Skill_conf3[3])
	IniWrite($profilFile, "Run info", "SpellLife1", $Skill_conf3[4])
	IniWrite($profilFile, "Run info", "SpellDistance1", $Skill_conf3[5])

	IniWrite($profilFile, "Run info", "SpellOn4", $Skill_conf4[0])
	IniWrite($profilFile, "Run info", "SpellDelay4", $Skill_conf4[1])
	IniWrite($profilFile, "Run info", "SpellType4", $Skill_conf4[2])
	IniWrite($profilFile, "Run info", "SpellEnergyNeeds4", $Skill_conf4[3])
	IniWrite($profilFile, "Run info", "SpellLife4", $Skill_conf4[4])
	IniWrite($profilFile, "Run info", "SpellDistance4", $Skill_conf4[5])

	IniWrite($profilFile, "Run info", "SpellOn5", $Skill_conf5[0])
	IniWrite($profilFile, "Run info", "SpellDelay5", $Skill_conf5[1])
	IniWrite($profilFile, "Run info", "SpellType5", $Skill_conf5[2])
	IniWrite($profilFile, "Run info", "SpellEnergyNeeds5", $Skill_conf5[3])
	IniWrite($profilFile, "Run info", "SpellLife5", $Skill_conf5[4])
	IniWrite($profilFile, "Run info", "SpellDistance5", $Skill_conf5[5])

	IniWrite($profilFile, "Run info", "SpellOn6", $Skill_conf6[0])
	IniWrite($profilFile, "Run info", "SpellDelay6", $Skill_conf6[1])
	IniWrite($profilFile, "Run info", "SpellType6", $Skill_conf6[2])
	IniWrite($profilFile, "Run info", "SpellEnergyNeeds6", $Skill_conf6[3])
	IniWrite($profilFile, "Run info", "SpellLife6", $Skill_conf6[4])
	IniWrite($profilFile, "Run info", "SpellDistance6", $Skill_conf6[5])

	IniWrite($profilFile, "Run info", "Key1", $Key1)
	IniWrite($profilFile, "Run info", "Key1", $Key2)
	IniWrite($profilFile, "Run info", "Key1", $Key3)
	IniWrite($profilFile, "Run info", "Key1", $Key4)

	IniWrite($profilFile, "Run info", "InventoryCheck", $InventoryCheck)

	iniwrite($profilFile,"Run info","gestion_affixe",$gestion_affixe)
    iniwrite($profilFile,"Run info","gestion_affixe_loot",$gestion_affixe_loot)
    iniwrite($profilFile,"Run info","BanAffixList",$BanAffixList)
    iniwrite($profilFile,"Run info","Life_Arcane",$Life_Arcane)
    iniwrite($profilFile,"Run info","Life_Peste",$Life_Peste)
    iniwrite($profilFile,"Run info","Life_Profa",$Life_Profa)
    iniwrite($profilFile,"Run info","Life_Mine",$Life_Mine)
    iniwrite($profilFile,"Run info","Life_Spore",$Life_Spore)
    iniwrite($profilFile,"Run info","Life_Arm",$Life_Arm)
    iniwrite($profilFile,"Run info","Life_Lave",$Life_Lave)
    iniwrite($profilFile,"Run info","Life_Ice",$Life_Ice)
    iniwrite($profilFile,"Run info","Life_Poison",$Life_Poison)
    iniwrite($profilFile,"Run info","Life_Explo",$Life_Explo)

	iniWrite($profilFile,"Run info","Gest_affixe_ByClass", $Gest_affixe_ByClass)
	;IniWrite($profilFile,"Run info","Act", $Act)
	IniWrite($profilFile, "Run info", "Devmode", $Devmode)
EndFunc   ;==>writeConfigs

Func loadConfigs($profilFile = "settings.ini", $creation = 0)

	;; windows informations
	;$winName			= IniRead($profilFile,"windows info","winName","Diablo III")
	;$gamePath			= IniRead($profilFile,"windows info","gameExecFullPath",0)

	;; Account info
	$d3pass = IniRead($profilFile, "Account info", "pass", 0)

	$ftpserver = IniRead($profilFile, "Account info", "ftpserver", $ftpserver)
	$ftpusername = IniRead($profilFile, "Account info", "ftpusername", $ftpusername)
	$ftppass = IniRead($profilFile, "Account info", "ftppass", $ftppass)
	$ftpfilename = IniRead($profilFile, "Account info", "ftpfilename", $ftpfilename)

	;; Run info
	$monsterList = IniRead($profilFile, "Run info", "monsterList", $monsterList)
	$SpecialmonsterList = IniRead($profilFile, "Run info", "SpecialmonsterList", $SpecialmonsterList)
	$grabListFile = IniRead($profilFile, "Run info", "grabListFile", $grabListFile)
	$QualityLevel = IniRead($profilFile, "Run info", "QualiteItem", $QualityLevel)
	$a_range = IniRead($profilFile, "Run info", "attackRange", $a_range)
	$g_range = IniRead($profilFile, "Run info", "grabRange", $g_range)
	$a_time = IniRead($profilFile, "Run info", "attacktimeout", $a_time)
	$g_time = IniRead($profilFile, "Run info", "grabtimeout", $g_time)
	$repairafterxxgames = IniRead($profilFile, "Run info", "repairafterxxgames", $repairafterxxgames)
	$maxgamelength = IniRead($profilFile, "Run info", "maxgamelength", $maxgamelength)
	$Potions = IniRead($profilFile, "Run info", "Potions", $Potions)
	$PreBuff1 = IniRead($profilFile, "Run info", "PreBuff1", $PreBuff1)
	$ToucheBuff1 = IniRead($profilFile, "Run info", "ToucheBuff1", $ToucheBuff1)
	$delaiBuff1 = IniRead($profilFile, "Run info", "delaiBuff1", $delaiBuff1)
	$PreBuff2 = IniRead($profilFile, "Run info", "PreBuff2", $PreBuff2)
	$ToucheBuff2 = IniRead($profilFile, "Run info", "ToucheBuff2", $ToucheBuff2)
	$delaiBuff2 = IniRead($profilFile, "Run info", "delaiBuff2", $delaiBuff2)
	$PreBuff3 = IniRead($profilFile, "Run info", "PreBuff3", $PreBuff3)
	$ToucheBuff3 = IniRead($profilFile, "Run info", "ToucheBuff3", $ToucheBuff3)
	$delaiBuff3 = IniRead($profilFile, "Run info", "delaiBuff3", $delaiBuff3)
	$PreBuff4 = IniRead($profilFile, "Run info", "PreBuff4", $PreBuff4)
	$ToucheBuff4 = IniRead($profilFile, "Run info", "ToucheBuff4", $ToucheBuff4)
	$delaiBuff4 = IniRead($profilFile, "Run info", "delaiBuff4", $delaiBuff4)
	$LifeForPotion = IniRead($profilFile, "Run info", "LifeForPotion", $LifeForPotion)
	$PotionStock = IniRead($profilFile, "Run info", "PotionStock", $PotionStock)
	$TakeShrines = IniRead($profilFile, "Run info", "TakeShrines", $TakeShrines)
	$MonsterTri = IniRead($profilFile, "Run info", "MonsterTri", $MonsterTri)
	$MonsterRefresh = IniRead($profilFile, "Run info", "MonsterRefresh", $MonsterRefresh)
	$ItemRefresh = IniRead($profilFile, "Run info", "ItemRefresh", $ItemRefresh)
	$MonsterPriority = IniRead($profilFile, "Run info", "MonsterPriority", $MonsterPriority)
	$Unidentified = IniRead($profilFile, "Run info", "Unidentified", $Unidentified)

;~ 	$MaximumHatred = IniRead($profilFile, "Run info", "MaximumHatred", $MaximumHatred)
;~ 	$MaximumDiscipline = IniRead($profilFile, "Run info", "MaximumDiscipline", $MaximumDiscipline)
;~ 	$MaximumSpirit = IniRead($profilFile, "Run info", "MaximumSpirit", $MaximumSpirit)
;~ 	$MaximumFury = IniRead($profilFile, "Run info", "MaximumFury", $MaximumFury)
;~ 	$MaximumArcane = IniRead($profilFile, "Run info", "MaximumArcane", $MaximumArcane)
;~ 	$MaximumMana = IniRead($profilFile, "Run info", "MaximumMana", $MaximumMana)

	$UsePath = StringLower(IniRead($profilFile, "Run info", "UsePath", $UsePath))
	$ResActivated = StringLower(IniRead($profilFile, "Run info", "ResActivated", $ResActivated))
	$ResLife = IniRead($profilFile, "Run info", "ResLife", $ResLife)
	$File_Sequence = IniRead($profilFile, "Run info", "SequenceFile", $File_Sequence)

	$Skill_conf1[0] = IniRead($profilFile, "Run info", "SpellOnLeft", $Skill_conf1[0])
	$Skill_conf1[1] = IniRead($profilFile, "Run info", "SpellDelayLeft", $Skill_conf1[1])
	$Skill_conf1[2] = IniRead($profilFile, "Run info", "SpellTypeLeft", $Skill_conf1[2])
	$Skill_conf1[3] = IniRead($profilFile, "Run info", "SpellEnergyNeedsLeft", $Skill_conf1[3])
	$Skill_conf1[4] = IniRead($profilFile, "Run info", "SpellLifeLeft", $Skill_conf1[4])
	$Skill_conf1[5] = IniRead($profilFile, "Run info", "SpellDistanceLeft", $Skill_conf1[5])


	$Skill_conf2[0] = IniRead($profilFile, "Run info", "SpellOnRight", $Skill_conf2[0])
	$Skill_conf2[1] = IniRead($profilFile, "Run info", "SpellDelayRight", $Skill_conf2[1])
	$Skill_conf2[2] = IniRead($profilFile, "Run info", "SpellTypeRight", $Skill_conf2[2])
	$Skill_conf2[3] = IniRead($profilFile, "Run info", "SpellEnergyNeedsRight", $Skill_conf2[3])
	$Skill_conf2[4] = IniRead($profilFile, "Run info", "SpellLifeRight", $Skill_conf2[4])
	$Skill_conf2[5] = IniRead($profilFile, "Run info", "SpellDistanceRight", $Skill_conf2[5])


	$Skill_conf3[0] = IniRead($profilFile, "Run info", "SpellOn1", $Skill_conf3[0])
	$Skill_conf3[1] = IniRead($profilFile, "Run info", "SpellDelay1", $Skill_conf3[1])
	$Skill_conf3[2] = IniRead($profilFile, "Run info", "SpellType1", $Skill_conf3[2])
	$Skill_conf3[3] = IniRead($profilFile, "Run info", "SpellEnergyNeeds1", $Skill_conf3[3])
	$Skill_conf3[4] = IniRead($profilFile, "Run info", "SpellLife1", $Skill_conf3[4])
	$Skill_conf3[5] = IniRead($profilFile, "Run info", "SpellDistance1", $Skill_conf3[5])


	$Skill_conf4[0] = IniRead($profilFile, "Run info", "SpellOn2", $Skill_conf4[0])
	$Skill_conf4[1] = IniRead($profilFile, "Run info", "SpellDelay2", $Skill_conf4[1])
	$Skill_conf4[2] = IniRead($profilFile, "Run info", "SpellType2", $Skill_conf4[2])
	$Skill_conf4[3] = IniRead($profilFile, "Run info", "SpellEnergyNeeds2", $Skill_conf4[3])
	$Skill_conf4[4] = IniRead($profilFile, "Run info", "SpellLife2", $Skill_conf4[4])
	$Skill_conf4[5] = IniRead($profilFile, "Run info", "SpellDistance2", $Skill_conf4[5])


	$Skill_conf5[0] = IniRead($profilFile, "Run info", "SpellOn3", $Skill_conf5[0])
	$Skill_conf5[1] = IniRead($profilFile, "Run info", "SpellDelay3", $Skill_conf5[1])
	$Skill_conf5[2] = IniRead($profilFile, "Run info", "SpellType3", $Skill_conf5[2])
	$Skill_conf5[3] = IniRead($profilFile, "Run info", "SpellEnergyNeeds3", $Skill_conf5[3])
	$Skill_conf5[4] = IniRead($profilFile, "Run info", "SpellLife3", $Skill_conf5[4])
	$Skill_conf5[5] = IniRead($profilFile, "Run info", "SpellDistance3", $Skill_conf5[5])


	$Skill_conf6[0] = IniRead($profilFile, "Run info", "SpellOn4", $Skill_conf6[0])
	$Skill_conf6[1] = IniRead($profilFile, "Run info", "SpellDelay4", $Skill_conf6[1])
	$Skill_conf6[2] = IniRead($profilFile, "Run info", "SpellType4", $Skill_conf6[2])
	$Skill_conf6[3] = IniRead($profilFile, "Run info", "SpellEnergyNeeds4", $Skill_conf6[3])
	$Skill_conf6[4] = IniRead($profilFile, "Run info", "SpellLife4", $Skill_conf6[4])
	$Skill_conf6[5] = IniRead($profilFile, "Run info", "SpellDistance4", $Skill_conf6[5])

	$Key1 = IniRead($profilFile, "Run info", "Key1", $Key1)
	$Key2 = IniRead($profilFile, "Run info", "Key2", $Key2)
	$Key3 = IniRead($profilFile, "Run info", "Key3", $Key3)
	$Key4 = IniRead($profilFile, "Run info", "Key4", $Key4)

	$BanAffixList=iniread($profilFile,"Run info","BanAffixList",$BanAffixList)
    $gestion_affixe=iniread($profilFile,"Run info","gestion_affixe",$gestion_affixe)
    $gestion_affixe_loot=iniread($profilFile,"Run info","gestion_affixe_loot",$gestion_affixe_loot)
    $Life_Arcane=iniread($profilFile,"Run info","Life_Arcane",$Life_Arcane)
    $Life_Peste=iniread($profilFile,"Run info","Life_Peste",$Life_Peste)
    $Life_Profa=iniread($profilFile,"Run info","Life_Profa",$Life_Profa)
    $Life_Ice=iniread($profilFile,"Run info","Life_Ice",$Life_Ice)
    $Life_Explo=iniread($profilFile,"Run info","Life_Explo",$Life_Explo)
    $Life_Arm=iniread($profilFile,"Run info","Life_Arm",$Life_Arm)
    $Life_Lave=iniread($profilFile,"Run info","Life_Lave",$Life_Lave)
    $Life_Poison=iniread($profilFile,"Run info","Life_Poison",$Life_Poison)
    $Life_Spore=iniread($profilFile,"Run info","Life_Spore",$Life_Spore)
    $Life_Mine=iniread($profilFile,"Run info","Life_Mine",$Life_Mine)

	$Gest_affixe_ByClass=iniread($profilFile,"Run info","Gest_affixe_ByClass",$Gest_affixe_ByClass)

	$InventoryCheck = IniRead($profilFile, "Run info", "InventoryCheck", $InventoryCheck)

	;$Act = IniRead($profilFile,"Run info","Act", $Act)
	$Devmode = IniRead($profilFile, "Run info", "Devmode", $Devmode)

	#cs
	If $RightClickSpellEnergy <> "" And $RightClickSpellEnergy <> "discipline" And $RightClickSpellEnergy <> "hatred" And $RightClickSpellEnergy <> "spirit" And $RightClickSpellEnergy <> "arcane" And $RightClickSpellEnergy <> "mana" And $RightClickSpellEnergy <> "fury" Then
		MsgBox(0, "Erreur non de variable", "La variable '$RightClickSpellEnergy' initialisé dans le setting.ini est mal écrite")
		Terminate()
	EndIf
	If $EnergySpell1 <> "" And $EnergySpell1 <> "discipline" And $EnergySpell1 <> "hatred" And $EnergySpell1 <> "spirit" And $EnergySpell1 <> "arcane" And $EnergySpell1 <> "mana" And $EnergySpell1 <> "fury" Then
		MsgBox(0, "Erreur non de variable", "La variable '$EnergySpell1' initialisé dans le setting.ini est mal écrite")
		Terminate()
	EndIf
	If $EnergySpell2 <> "" And $EnergySpell2 <> "discipline" And $EnergySpell2 <> "hatred" And $EnergySpell2 <> "spirit" And $EnergySpell2 <> "arcane" And $EnergySpell2 <> "mana" And $EnergySpell2 <> "fury" Then
		MsgBox(0, "Erreur non de variable", "La variable '$EnergySpell2' initialisé dans le setting.ini est mal écrite")
		Terminate()
	EndIf
	If $EnergySpell3 <> "" And $EnergySpell3 <> "discipline" And $EnergySpell3 <> "hatred" And $EnergySpell3 <> "spirit" And $EnergySpell3 <> "arcane" And $EnergySpell3 <> "mana" And $EnergySpell3 <> "fury" Then
		MsgBox(0, "Erreur non de variable", "La variable '$EnergySpell3' initialisé dans le setting.ini est mal écrite")
		Terminate()
	EndIf
	If $EnergySpell4 <> "" And $EnergySpell4 <> "discipline" And $EnergySpell4 <> "hatred" And $EnergySpell4 <> "spirit" And $EnergySpell4 <> "arcane" And $EnergySpell4 <> "mana" And $EnergySpell4 <> "fury" Then
		MsgBox(0, "Erreur non de variable", "La variable '$EnergySpell4' initialisé dans le setting.ini est mal écrite")
		Terminate()
	EndIf
	#ce
EndFunc   ;==>loadConfigs

