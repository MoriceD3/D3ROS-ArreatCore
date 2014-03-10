#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <winapi.au3>

Global $hImage
Global $hGraphic
Global $Gwidth
Global $Gheight

Func Initiate_GDIpicture($width, $height)
	$Gwidth=$width
	$Gheight=$height
	
	_GDIPlus_Startup()
	
	;$hGUI = GUICreate("Show PNG", $Gwidth, $Gheight)
	;GUISetState()
	;$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	
	$hImage = _GDIPlus_BitmapCreateFromScan0($width, $height)
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage)
EndFunc

Func Draw_Nav($x, $y, $type, $sizex, $sizey)

	If $type = 1 Then
		$color_rec = _GDIPlus_PenCreate(0xFF85DB24, 1)
		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
	ElseIf $type = 0 Then
		 $color_rec = _GDIPlus_PenCreate(0xF0000000, 1)
		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
	Else
		 $color_rec = _GDIPlus_PenCreate(0xF0000000, 2)
		_GDIPlus_GraphicsDrawRect($hGraphic, $x, $y, $sizex, $sizey, $color_rec)
		_GDIPlus_PenDispose($color_rec)
	EndIf


EndFunc

Func Save_GDIpicture()
	_GDIPlus_ImageSaveToFile($hImage, @ScriptDir & "\TEST.PNG")
EndFunc

Func Load_GDIpicture()
	$hGUI = GUICreate("Show PNG", $Gwidth, $Gheight)
	GUISetState()
	$hImage   = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\TEST.PNG")
	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, 0, 0)
EndFunc

Func _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight, $iStride = 0, $iPixelFormat = 0x0026200A, $pScan0 = 0)
    Local $aResult = DllCall($ghGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", $iWidth, "int", $iHeight, "int", $iStride, "int", $iPixelFormat, "ptr", $pScan0, "int*", 0)
    If @error Then Return SetError(@error, @extended, 0)
    Return $aResult[6]
EndFunc   ;==>_GDIPlus_BitmapCreateFromScan0