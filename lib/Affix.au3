#include-once
#cs ----------------------------------------------------------------------------

 Ce fichier contient les fonction pour ajouter des Affix

#ce ----------------------------------------------------------------------------

Func IterateFilterAffixV2()

	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)
	Dim $item_affix_2D[1][$TableSizeGuidStruct + 1]
	Local $z = 0
	
	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')
	
	$CurrentLoc = GetCurrentPos()
	$pv_affix = getlifep()

	for $i=0 to $count
		$iterateObjectsStruct = GetElement($iterateObjectsListStruct, $i, $GuidStruct)

		If GetItemFromList($item, $iterateObjectsListStruct, $offset, $i, $CurrentLoc) Then
			$range = GetAffixRange($item, $pv_affix)
			If $range <> -1 Then
				ReDim $item_affix_2D[$z + 1][$TableSizeGuidStruct + 1]
				For $x = 0 To ($TableSizeGuidStruct - 1)
					$item_affix_2D[$z][$x] = $item[$x]
				Next

				$item_affix_2D[$z][13] = $range

				$z += 1
			EndIf

		EndIf
		$iterateObjectsStruct = ""
	Next

	$iterateObjectsListStruct = ""

	If $z = 0 Then
		Return False
    Else
		_ArraySort($item_affix_2D, 0, 0, 0, 9)
		Return $item_affix_2D
    EndIf

EndFunc  ;==> IterateFilterAffixV2()

Func GetAffixRange($item, $pv = 0) ; Anciennement Is_Affix
	; TODO : Vérifier les ranges et les vies associées a priori quelques incohérences
	
	Select
		Case $item[9] > 50
			Return -1
		Case IsItemInTable($Table_BanAffix, $item[1])
			Return -1
		Case StringInStr($item[1], "bomb_buildup") And ($pv <= $Life_explo / 100)
			Return $range_ice
		Case (StringInStr($item[1], "Corpulent_") And ($pv <= $Life_explo / 100) And (Trim($nameCharacter) = "demonhunter" Or Trim($nameCharacter) = "witchdoctor" Or Trim($nameCharacter) = "wizard"))
			Return $range_arcane
		Case StringInStr($item[1], "demonmine_C") And ($pv <= $Life_explo / 100)
			Return $range_mine
		Case StringInStr($item[1], "Corpulent_suicide_blood") And ($pv <= $Life_explo / 100)
			Return $range_arcane
		Case StringInStr($item[1], "creepMobArm") And ($pv <= $Life_arm / 100)
			Return $range_arm
		Case StringInStr($item[1], "woodWraith_explosion") And ($pv <= $Life_spore / 100)
			Return $range_ice
		Case StringInStr($item[1], "WoodWraith_sporeCloud_emitter") And ($pv <= $Life_spore / 100)
			Return $range_ice
		Case StringInStr($item[1], "sandwasp_projectile") And ($pv <= $Life_proj / 100)
			Return $range_arcane
		Case StringInStr($item[1], "succubus_bloodStar_projectile") And ($pv <= $Life_proj / 100)
			Return $range_arcane
		Case StringInStr($item[1], "Crater_DemonClawBomb") And ($pv <= $Life_mine / 100)
			Return $range_mine
		Case StringInStr($item[1], "Molten_deathExplosion") And ($pv <= $Life_explo / 100)
			Return $range_ice
		Case StringInStr($item[1], "Molten_deathStart") And ($pv <= $Life_explo / 100)
			Return $range_ice
		Case StringInStr($item[1], "iceClusters") And ($pv <= $Life_ice / 100)
			Return $range_ice
		Case StringInStr($item[1], "Orbiter_Projectile") And ($pv <= $Life_ice / 100)
			Return $range_arcane
		Case StringInStr($item[1], "Thunderstorm_Impact") And ($pv <= $Life_ice / 100)
			Return $range_ice
		Case StringInStr($item[1], "CorpseBomber_projectile") And ($pv <= $Life_proj / 100)
			Return $range_ice
		Case StringInStr($item[1], "CorpseBomber_bomb_start") And ($pv <= $Life_explo / 100)
			Return $range_ice
		Case StringInStr($item[1], "Battlefield_demonic_forge") And ($pv <= $Life_ice / 100)
			Return $range_arcane
		Case StringInStr($item[1], "frozenPulse") And ($pv <= $Life_ice / 100)
			Return $range_arcane
		Case StringInStr($item[1], "spore") And ($pv <= $Life_spore / 100)
			Return $range_peste
		Case StringInStr($item[1], "ArcaneEnchanted_petsweep") And ($pv <= $Life_arcane / 100)
			Return $range_arcane
		Case StringInStr($item[1], "Desecrator") And ($pv <= $Life_profa / 100)
			Return $range_profa
		Case StringInStr($item[1], "Plagued_endCloud") And ($pv <= $Life_peste / 100)
			Return $range_peste
		Case StringInStr($item[1], "Poison") And ($pv <= $Life_poison / 100)
			Return $range_peste
		Case StringInStr($item[1], "molten_trail") And ($pv <= $Life_lave / 100)
			Return $range_lave
		Case Else
			Return -1
	EndSelect

EndFunc ;==>GetAffixRange   ;==>Is_Affix
 