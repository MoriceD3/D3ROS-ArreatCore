#include-once
#cs ----------------------------------------------------------------------------

 Ce fichier contient les fonctions de gestion des Affix

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


Func reset_timer_ignore()
	If timerdiff($timer_ignore_reset) > 120000 Then
		Redim $ignore_affix[1][2]
		$timer_ignore_reset = timerinit()
	EndIf
Endfunc

Func check_ignore_affix($_x_verif,$_y_verif)
	For $a = 0 To ubound($ignore_affix) - 1
		If $_x_verif = $ignore_affix[$a][0] And $_y_verif = $ignore_affix[$a][1] Then
			Return False
		EndIf
	Next
	Return True
EndFunc

Func is_zone_safe($x_perso,$y_perso,$z_test,$item_safe)
	For $aa = 0 To ubound($item_safe) - 1
		$distance_centre_affixe = sqrt(($item_safe[$aa][2] - $x_perso)^2 + ($item_safe[$aa][3] - $y_perso)^2)
		If $distance_centre_affixe < $item_safe[$aa][13] Then
			Return False
		EndIf
	Next

	Return True
EndFunc

Func zone_safe($x_perso,$y_perso,$item_verif,$z_test,$x_mob,$y_mob)
	Dim $safe_array[1][3]
	$bb = -1
	If $x_mob - $x_perso > 0 Then
		$ord = 1
	Else
		$ord = -1
	EndIf

	If $y_mob - $y_perso > 0 Then
		$abs = 1
	Else
		$abs = -1
	EndIf

	For $b = 0 To ubound($tab_aff2) - 1
		$x_test = $x_perso + $ord * $tab_aff2[$b][0]
		$y_test = $y_perso + $abs * $tab_aff2[$b][1]
		If is_zone_safe($x_test,$y_test,$z_test,$item_verif) And check_ignore_affix($x_test,$y_test) Then
			$bb = $bb + 1
			ReDim $safe_array[$bb + 1][3]
			$distance_safe = getdistance($x_test,$y_test,0)
			$safe_array[$bb][0] = $distance_safe
			$safe_array[$bb][1] = $x_test
			$safe_array[$bb][2] = $y_test
		EndIf

		$x_test = $x_perso - $ord * $tab_aff2[$b][0]
		$y_test = $y_perso - $abs * $tab_aff2[$b][1]
		If is_zone_safe($x_test,$y_test,$z_test,$item_verif) And check_ignore_affix($x_test,$y_test) Then
			$bb = $bb + 1
			ReDim $safe_array[$bb + 1][3]
			$distance_safe = getdistance($x_test,$y_test,0)
			$safe_array[$bb][0] = $distance_safe
			$safe_array[$bb][1] = $x_test
			$safe_array[$bb][2] = $y_test
		EndIf

		$x_test = $x_perso + $ord * $tab_aff2[$b][0]
		$y_test = $y_perso - $abs * $tab_aff2[$b][1]
		If is_zone_safe($x_test,$y_test,$z_test,$item_verif) And check_ignore_affix($x_test,$y_test) Then
			$bb = $bb + 1
			ReDim $safe_array[$bb + 1][3]
			$distance_safe = getdistance($x_test,$y_test,0)
			$safe_array[$bb][0]=$distance_safe
			$safe_array[$bb][1]=$x_test
			$safe_array[$bb][2]=$y_test
		EndIf

		$x_test = $x_perso - $ord * $tab_aff2[$b][0]
		$y_test = $y_perso + $abs * $tab_aff2[$b][1]
		If is_zone_safe($x_test,$y_test,$z_test,$item_verif) And check_ignore_affix($x_test,$y_test) Then
			$bb = $bb + 1
			ReDim $safe_array[$bb + 1][3]		
			$distance_safe = getdistance($x_test,$y_test,0)
			$safe_array[$bb][0] = $distance_safe
			$safe_array[$bb][1] = $x_test
			$safe_array[$bb][2] = $y_test
		EndIf
	Next
	Dim $move_aff[2]
	If $safe_array[0][0] <> 0 then
		_ArraySort($safe_array)
		$move_aff[0] = $safe_array[0][1]
		$move_aff[1] = $safe_array[0][2]
	Else
		$move_aff[0] = $x_test
		$move_aff[1] = $y_test
	EndIf

	Return $move_aff
EndFunc

Func maffmove($_x_aff,$_y_aff,$_z_aff,$x_mob,$y_mob)
	reset_timer_ignore()
	If timerdiff($maff_timer) > 500 then
		Dim $item_maff_move = IterateFilterAffixV2()
		If IsArray($item_maff_move) Then
			$a = 0
			While $a <= ubound($item_maff_move) - 1
				checkforpotion()
				mouseup('left')
				;~ 			   $dist_aff=sqrt(($_x_aff-$item_maff_move[$a][2])*($_x_aff-$item_maff_move[$a][2]) + ($_y_aff-$item_maff_move[$a][3])*($_y_aff-$item_maff_move[$a][3]) + ($_z_aff-$item_maff_move[$a][4])*($_z_aff-$item_maff_move[$a][4]))
				If $item_maff_move[$a][9] < $item_maff_move[$a][13] And _playerdead() = False Then
					Dim $move_coords[2]
					$move_coords = zone_safe($_x_aff,$_y_aff,$item_maff_move,$_z_aff,$x_mob,$y_mob)
					$Coords_affixe = FromD3toScreenCoords($move_coords[0],$move_coords[1],$_z_aff)
					Mousemove($Coords_affixe[0], $Coords_affixe[1], 3)
					GestSpellcast(0, 0, 0)
					MouseClick($MouseMoveClick)
					$ignore_timer = timerinit()
					While _MemoryRead($ClickToMoveToggle,$d3,"float") <> 0
						; GestSpellcast(0, 2, 0)
						If timerdiff($ignore_timer) > 10000 Then 
							ExitLoop
						EndIf
						Sleep(10)
					Wend
					If timerdiff($ignore_timer) < 30 Then
						$nbr_ignore = ubound($ignore_affix)
						Redim $ignore_affix[$nbr_ignore+1][2]
						$ignore_affix[$nbr_ignore][0]=$move_coords[0]
						$ignore_affix[$nbr_ignore][1]=$move_coords[1]
					EndIf
					$maff_timer = timerinit()
					ExitLoop
				EndIf
				$a += 1
			Wend
		EndIf
	EndIf
EndFunc  ;maffmove