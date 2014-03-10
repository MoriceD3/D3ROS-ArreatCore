#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <winapi.au3>

Global $hImage
Global $hGraphic

Func Initiate_GDIpicture($width, $height)
	_GDIPlus_Startup()
	
	$hImage = _GDIPlus_BitmapCreateFromScan0($width+1, $height+1)
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage)
EndFunc

Func Draw_Nav($x, $y, $type, $sizex, $sizey, $num=0)

	If $type = 2 Then
	
		If StringLower($DrawMtp) = "true" Then
			$color_rec = _GDIPlus_PenCreate($MtpColor, 1)
			_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
			_GDIPlus_PenDispose($color_rec)
		EndIF
		
		if $num <> 0  AND StringLower($DrawArrow) = "true" Then
			$color_rec = _GDIPlus_PenCreate($ArrawColor, 1)
			$iInset = 0.5 
			$hEndCap = _GDIPlus_ArrowCapCreate(2, 4) 
			_GDIPlus_ArrowCapSetMiddleInset ($hEndCap, $iInset) 
			_GDIPlus_PenSetCustomEndCap ($color_rec, $hEndCap) 
			_GDIPlus_GraphicsDrawLine($hGraphic, $Table_mtp[$num-1][1], $Table_mtp[$num-1][0], $x, $y, $color_rec)
			_GDIPlus_PenDispose($color_rec)
		EndIF
	ElseIf $type = 1 Then
		$color_rec = _GDIPlus_PenCreate($NavcellWalkableColor, 1)
		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
	ElseIf $type = 0 Then
		 $color_rec = _GDIPlus_PenCreate($NavcellUnWalkableColor, 1)
		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
	Else
		 $color_rec = _GDIPlus_PenCreate($SceneColor, 1)
		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
	EndIf


EndFunc

Func Save_GDIpicture()
	_GDIPlus_ImageSaveToFile($hImage, @ScriptDir & "\" & $PictureScene & ".png")
	
	If $count_mtp > 1 Then
		for $i=0 to Ubound($Table_mtp) - 1
			Draw_Nav($Table_mtp[$i][1], $Table_mtp[$i][0], 2, 2, 2, $i)
		Next
	EndIF
	
	_GDIPlus_ImageSaveToFile($hImage, @ScriptDir & "\" & $Picturemtp & ".png")
EndFunc


Func _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight, $iStride = 0, $iPixelFormat = 0x0026200A, $pScan0 = 0)
    Local $aResult = DllCall($ghGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", $iWidth, "int", $iHeight, "int", $iStride, "int", $iPixelFormat, "ptr", $pScan0, "int*", 0)
    If @error Then Return SetError(@error, @extended, 0)
    Return $aResult[6]
EndFunc   ;==>_GDIPlus_BitmapCreateFromScan0