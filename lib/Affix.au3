#include-once
#cs ----------------------------------------------------------------------------

 Ce fichier contient les fonction pour ajouté des Affix

#ce ----------------------------------------------------------------------------

Func IterateFilterAffixV2()

	Local $index, $offset, $count, $item[$TableSizeGuidStruct]
	startIterateObjectsList($index, $offset, $count)
	Dim $item_affix_2D[1][$TableSizeGuidStruct+1]
	Local $z = 0
	
	$iterateObjectsListStruct = ArrayStruct($GuidStruct, $count + 1)
	DllCall($d3[0], 'int', 'ReadProcessMemory', 'int', $d3[1], 'int', $offset, 'ptr', DllStructGetPtr($iterateObjectsListStruct), 'int', DllStructGetSize($iterateObjectsListStruct), 'int', '')
	
	$CurrentLoc = GetCurrentPos()
	$pv_affix=getlifep()

	for $i=0 to $count
		$iterateObjectsStruct = GetElement($iterateObjectsListStruct, $i, $GuidStruct)

		If DllStructGetData($iterateObjectsStruct, 4) <> 0xFFFFFFFF Then
			$item[0] = DllStructGetData($iterateObjectsStruct, 4) ; Guid
			$item[1] = DllStructGetData($iterateObjectsStruct, 2) ; Name
			$item[2] = DllStructGetData($iterateObjectsStruct, 6) ; x
			$item[3] = DllStructGetData($iterateObjectsStruct, 7) ; y
			$item[4] = DllStructGetData($iterateObjectsStruct, 8) ; z
			$item[5] = DllStructGetData($iterateObjectsStruct, 18) ; data 1
			$item[6] = DllStructGetData($iterateObjectsStruct, 16) ; data 2
			$item[7] = DllStructGetData($iterateObjectsStruct, 14) ; data 3
			$item[8] = $offset + $i*DllStructGetSize($iterateObjectsStruct)

			$Item[10] = DllStructGetData($iterateObjectsStruct, 10) ; z Foot
			$Item[11] = DllStructGetData($iterateObjectsStruct, 11) ; z Foot
			$Item[12] = DllStructGetData($iterateObjectsStruct, 12) ; z Foot

			$item[9] = GetDistanceWithoutReadPosition($CurrentLoc, $Item[10], $Item[11], $Item[12])

			If Is_Affix($item, $pv_affix) Then
				ReDim $item_affix_2D[$z + 1][$TableSizeGuidStruct+1]
				For $x = 0 To 9
					$item_affix_2D[$z][$x] = $item[$x]
				Next

					If (StringInStr($item[1],"woodWraith_explosion") Or StringInStr($item[1],"WoodWraith_sporeCloud_emitter")) Then  $item_affix_2D[$z][13] = $range_ice
				    If (StringInStr($item[1],"sandwasp_projectile") Or StringInStr($item[1],"succubus_bloodStar_projectile")) Then $item_affix_2D[$z][13] = $range_arcane
			        If StringInStr($item[1],"molten_trail") Then $item_affix_2D[$z][13] = $range_lave
			        If (StringInStr($item[1],"Corpulent_") And (StringLower(Trim($nameCharacter)) = "demonhunter" Or StringLower(Trim($nameCharacter)) = "witchdoctor" Or StringLower(Trim($nameCharacter)) = "wizard")) Then $item_affix_2D[$z][13] = $range_arcane
                    If StringInStr($item[1],"Corpulent_suicide_blood") Then $item_affix_2D[$z][13] = $range_arcane
			        If StringInStr($item[1],"Desecrator") Then $item_affix_2D[$z][13] = $range_profa
			        If (StringInStr($item[1],"bomb_buildup") Or StringInStr($item[1],"iceClusters") Or stringinstr($item[1],"Molten_deathExplosion") Or stringinstr($item[1],"Molten_deathStart")) Then  $item_affix_2D[$z][13] = $range_ice
			        If StringInStr($item[1],"frozenPulse") Then $item_affix_2D[$z][13] = $range_arcane
					If StringInStr($item[1],"Orbiter_Projectile") Then $item_affix_2D[$z][13] = $range_arcane
			        If StringInStr($item[1],"Battlefield_demonic_forge") Then $item_affix_2D[$z][13] = $range_arcane
			        If (StringInStr($item[1],"CorpseBomber_projectile") Or StringInStr($item[1],"CorpseBomber_bomb_start")) Then $item_affix_2D[$z][13] = $range_ice
			        If StringInStr($item[1],"Thunderstorm_Impact") Then $item_affix_2D[$z][13] = $range_ice
			        If (StringInStr($item[1],"demonmine_C") Or StringInStr($item[1],"Crater_DemonClawBomb")) Then $item_affix_2D[$z][13] = $range_mine
			        If StringInStr($item[1],"creepMobArm") Then $item_affix_2D[$z][13] = $range_arm
			        If (StringInStr($item[1],"spore") Or StringInStr($item[1],"Plagued_endCloud") Or StringInStr($item[1],"Poison")) Then $item_affix_2D[$z][13] = $range_peste
			        If StringInStr($item[1],"ArcaneEnchanted_petsweep") Then $item_affix_2D[$z][13] = $range_arcane


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

 Func Is_Affix($item,$pv=0)
	If $item[9]<50 then
                 If ((StringInStr($item[1],"bomb_buildup") And $pv<=$Life_explo/100 ) Or _
					(StringInStr($item[1],"Corpulent_") And $pv<=$Life_explo/100 ) Or _
					(StringInStr($item[1],"demonmine_C") And $pv<=$Life_mine/100) Or _
					(StringInStr($item[1],"creepMobArm") And $pv<=$Life_arm/100 ) Or _
					(StringInStr($item[1],"woodWraith_explosion") And $pv<=$Life_spore/100)  Or _
				    (StringInStr($item[1],"WoodWraith_sporeCloud_emitter") and $pv<=$Life_spore/100 ) Or _
				    (StringInStr($item[1],"sandwasp_projectile") And $pv<=$Life_proj/100 ) Or _
					(StringInStr($item[1],"succubus_bloodStar_projectile") And $pv<=$Life_proj/100 ) Or _
					(StringInStr($item[1],"Crater_DemonClawBomb") And $pv<=$Life_mine/100 ) Or _
					(stringinstr($item[1],"Molten_deathExplosion") And $pv<=$Life_explo/100 ) Or _
					(stringinstr($item[1],"Molten_deathStart") And $pv<=$Life_explo/100 ) Or _
					(StringInStr($item[1],"icecluster") And $pv<=$Life_ice/100 ) Or _
					(StringInStr($item[1],"Orbiter_Projectile") And $pv<=$Life_ice/100 ) Or _
					(StringInStr($item[1],"Thunderstorm") And $pv<=$Life_ice/100 ) Or _
					(StringInStr($item[1],"CorpseBomber_projectile") And $pv<=$Life_proj/100 ) Or _
					(StringInStr($item[1],"CorpseBomber_bomb_start") And $pv<=$Life_explo/100 ) Or _
					(StringInStr($item[1],"Battlefield_demonic_forge") And $pv<=$Life_ice/100 ) Or _
                    (StringInStr($item[1],"frozenPulse") And $pv<=$Life_ice/100 ) Or _
					(StringInStr($item[1],"spore") And $pv<=$Life_spore/100 ) Or _
					(StringInStr($item[1],"ArcaneEnchanted_petsweep") And $pv<=$Life_arcane/100 ) Or _
					(StringInStr($item[1],"desecrator") And $pv<=$Life_profa/100 ) Or _
					(StringInStr($item[1],"Plagued_endCloud") And $pv<=$Life_peste/100 ) Or _
					(StringInStr($item[1],"poison") And $pv<=$Life_poison/100 ) Or _
					(StringInStr($item[1],"molten_trail") And $pv<=$Life_lave/100 )) _
					And checkfromlist($BanAffixList, $item[1]) = 0 Then
					 
					 Return True				  
				  Else
					 Return False
				  EndIf
    EndIf

 EndFunc   ;==>Is_Affix
 