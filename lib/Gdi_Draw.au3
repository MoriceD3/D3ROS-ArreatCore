#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <winapi.au3>

Global $hImage
Global $hGraphic

Global $hFormat = _GDIPlus_StringFormatCreate()
Global $hFamily = _GDIPlus_FontFamilyCreate("Arial")
Global $hFontxx = _GDIPlus_FontCreate($hFamily, 11, 2)
Global $hBrush = _GDIPlus_BrushCreateSolid(0x00000000)

Func Initiate_GDIpicture($width, $height)
	_GDIPlus_Startup()

	$hImage = _GDIPlus_BitmapCreateFromScan0($width+1, $height+1)
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage)
EndFunc ;==> Initiate_GDIpicture

Func Draw_Nav($x, $y, $type, $sizex, $sizey, $num=0, $count="L")

	If $type = 2 Then
		If StringLower($DrawMtp) = "true" Then
			$color_rec = _GDIPlus_PenCreate($MtpColor, 1)
			_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
			_GDIPlus_PenDispose($color_rec)
		EndIf
		If $num <> 0  And StringLower($DrawArrow) = "true" Then
			$temp = StringSplit($count,"|",2)
			If $temp[0] = 1 Then
				$color_rec = _GDIPlus_PenCreate($ArrowColor, 1)
			Else
				$color_rec = _GDIPlus_PenCreate($ArrowColorNoAttack, 1)
			EndIf
			$iInset = 0.5
			$hEndCap = _GDIPlus_ArrowCapCreate(2, 4)
			_GDIPlus_ArrowCapSetMiddleInset ($hEndCap, $iInset)
			_GDIPlus_PenSetCustomEndCap ($color_rec, $hEndCap)
			_GDIPlus_GraphicsDrawLine($hGraphic, $Table_mtp[$num-1][1] - $buff_MeshMinY, $Table_mtp[$num-1][0] - $buff_MeshMinX, $x, $y, $color_rec)
			_GDIPlus_PenDispose($color_rec)
			If $Temp[1] <> -1 And $drawLineNumbers Then
				If Mod($num, $posNumberMod) = 0 Then
					_GDIPlus_GraphicsDrawString($hGraphic, $Temp[1], $x, $y)
				EndIf
			EndIf
		EndIF
		_log("dessine une pos")
	ElseIf $type = 11 Then
		$color_rec = _GDIPlus_BrushCreateSolid(0xFF7A4DE4)
		_GDIPlus_GraphicsFillEllipse ($hGraphic, $x - $sizex / 2, $y - $sizey / 2, $sizex, $sizey, $color_rec)
		If $DrawPositionName Then
			_GDIPlus_GraphicsDrawString($hGraphic, $count, $x, $y)
		EndIf
		_GDIPlus_BrushDispose($color_rec)
		_log('dessine un emplacement important')
	ElseIf $type = 12 Then
		$color_rec = _GDIPlus_BrushCreateSolid(0xFF237C9E)
		_GDIPlus_GraphicsFillEllipse ($hGraphic, $x - $sizex / 2, $y - $sizey / 2, $sizex, $sizey, $color_rec)

		_GDIPlus_BrushDispose($color_rec)
		$temp = StringSplit($count,"|",2)
		If $temp[1] = -1 Then
			_GDIPlus_GraphicsDrawString($hGraphic, $temp[0], $x, $y - 15)
		Else
			_GDIPlus_GraphicsDrawString($hGraphic, $temp[0], $x, $y)
		EndIf

		_log('dessine un event')
	ElseIf $type = 10 Then
		$color_rec = _GDIPlus_PenCreate(0xFFFF03FC, 1)
		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
		_log('dessine une reso de chemin')
	ElseIf $type = 1 Then
		$color_rec = _GDIPlus_PenCreate($NavcellWalkableColor, 1)
		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
	ElseIf $type = 0 Then
		 $color_rec = _GDIPlus_BrushCreateSolid($NavcellUnWalkableColor) ;color format AARRGGBB (hex) ; _GDIPlus_PenCreate($NavcellUnWalkableColor, 1)
		_GDIPlus_GraphicsFillRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec) ; _GDIPlus_GraphicsDrawRect
		 _GDIPlus_BrushDispose($color_rec) ; _GDIPlus_PenDispose
	Else
		$color_rec = _GDIPlus_PenCreate($SceneColor, 1)
		;Msgbox(1, "", "Dessinage de la scene n�" & $count)

		_log("dessine $count -> " & $count)
		If $count >= 0 Then
		;Msgbox(1, "", "On dessine")
		_GDIPlus_GraphicsDrawString($hGraphic, $count, $x, $y )
		EndIf

		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
	EndIf

EndFunc ;==> Draw_Nav

Func Save_GDIpicture()
	$area = GetLevelAreaId()
	_GDIPlus_ImageSaveToFile($hImage, @ScriptDir & "\sequencer\" & $area & $PictureScene & ".png")

	;_arraydisplay($Table_mtp)
	If $count_mtp > 0 Then
		for $i=0 to Ubound($Table_mtp) - 1
			Draw_Nav($Table_mtp[$i][1] - $buff_MeshMinY, $Table_mtp[$i][0] - $buff_MeshMinX, 2, 2, 2, $i, $Table_mtp[$i][3] & "|-1")
		Next
	EndIF

	#cs
	If $Count_path >= 1 Then
		for $i=0 to Ubound($Result_Path) - 1
			Draw_Nav($Result_Path[$i][1], $Result_Path[$i][0], 10, 2, 2, $i)
		Next
	EndIf
	#ce

	_GDIPlus_ImageSaveToFile($hImage, @ScriptDir & "\sequencer\" & $area & $Picturemtp & ".png")
EndFunc ;==> Save_GDIpicture


;Func _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight, $iStride = 0, $iPixelFormat = 0x0026200A, $pScan0 = 0)
;    Local $aResult = DllCall($ghGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", $iWidth, "int", $iHeight, "int", $iStride, "int", $iPixelFormat, "ptr", $pScan0, "int*", 0)
;    If @error Then Return SetError(@error, @extended, 0)
;    Return $aResult[6]
;EndFunc   ;==>_GDIPlus_BitmapCreateFromScan0