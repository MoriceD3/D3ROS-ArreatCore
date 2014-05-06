#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=lib\ico\ico-checker.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Fileversion=1.2.0.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;;================================================================================
;; PRE CHECKS
;;================================================================================

;;--------------------------------------------------------------------------------
;;      Make sure you are running in x86
;;--------------------------------------------------------------------------------
$checkx64 = @AutoItX64
If $checkx64 = 1 Then
	MsgBox(0, "Erreur : ", "Script lancé en x64, merci de le lancer en x86 ")
	Terminate()
EndIf

;;--------------------------------------------------------------------------------
;;      Set tray icon
;;--------------------------------------------------------------------------------
$icon = @ScriptDir & "\lib\ico\ico-checker.ico"
TraySetIcon($icon)

;;--------------------------------------------------------------------------------
;;      Include some files
;;--------------------------------------------------------------------------------

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "lib\Variables.au3"
#include "lib\Utils.au3"
#include "lib\sequence.au3"
#include "lib\settings.au3"
#include "lib\skills.au3"
#include "lib\toolkit.au3"
#include "lib\botting.au3"
#include "lib\stats.au3"
#include "lib\Affix.au3"
#include "lib\GestionMenu.au3"
#include "lib\GestionChat.au3"
#include "lib\dev_tools.au3"
#include "lib\sequencer_tools.au3"
#include "lib\Gdi_Draw.au3"

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#Region ### START Koda GUI section ### Form=c:\games\d3ros-arreatcore\lib\extra\sequencechecker.kxf
$Form1 = GUICreate("Sequence Checker", 325, 361, 296, 146)
$Label1 = GUICtrlCreateLabel("Bienvenue dans l'outil de validation des séquences :", 8, 8, 245, 17, $SS_CENTER)
$Button1 = GUICtrlCreateButton("Charger des fichiers mapData", 8, 40, 307, 25)
$Button2 = GUICtrlCreateButton("Charger un fichier de séquence", 8, 88, 307, 25)
$Input1 = GUICtrlCreateInput("40", 136, 128, 41, 21)
$Label2 = GUICtrlCreateLabel("Attack range par défaut : ", 8, 128, 125, 17)
$Checkbox1 = GUICtrlCreateCheckbox("Dessiner les zones d'attaques sur la séquence", 8, 160, 305, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Button3 = GUICtrlCreateButton("Générer l'image de validation", 8, 320, 307, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$Checkbox2 = GUICtrlCreateCheckbox("Afficher les noms des points importants", 8, 184, 241, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox3 = GUICtrlCreateCheckbox("Afficher les numéros de lignes de la séquence", 8, 232, 305, 17)
$Label3 = GUICtrlCreateLabel("Afficher numéro tous les :", 8, 256, 123, 17)
$Input2 = GUICtrlCreateInput("3", 136, 261, 65, 21)
$Checkbox4 = GUICtrlCreateCheckbox("Consolider les mapData en une seule image", 8, 288, 305, 17)
$Checkbox5 = GUICtrlCreateCheckbox("Afficher les events de la séquence (Sleep / Interact)", 8, 208, 305, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Opt("GUIOnEventMode", 0)

Local $mapFiles
Local $sequenceFile = False

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
		    Local $sFileOpenDialog = FileOpenDialog("Sélectionner le ou les fichiers mapData", @scriptdir & "\sequencer", "MapData (*.ini)", $FD_FILEMUSTEXIST + $FD_MULTISELECT)
		    If @error Then
		        MsgBox($MB_SYSTEMMODAL, "", "Pas de fichier sélectionné.")
		        FileChangeDir(@ScriptDir)
		    Else
		        FileChangeDir(@ScriptDir)
		        If StringInStr($sFileOpenDialog, "|") Then
		        	$mapFiles = StringSplit($sFileOpenDialog, "|", 2)
		        Else
		        	Dim $mapFiles[1]
		        	$mapFiles[0] = $sFileOpenDialog
		        EndIf
		        GUICtrlSetState($Button3, $GUI_ENABLE)
		    EndIf
		Case $Button2
		    Local $sFileOpenDialog = FileOpenDialog("Sélectionner le fichier séquence", @scriptdir & "\sequence", "Séquence (*.txt)", $FD_FILEMUSTEXIST)
		    If @error Then
		        MsgBox($MB_SYSTEMMODAL, "", "Pas de fichier sélectionné.")
		        FileChangeDir(@ScriptDir)
		    Else
		        FileChangeDir(@ScriptDir)
		        $sequenceFile = $sFileOpenDialog
		    EndIf
   		Case $Button3
   			$attackRange = GUICtrlRead ($Input1)
   			$posNumberMod = GUICtrlRead ($Input2)
   			$DrawAttackRange = (GUICtrlRead ($Checkbox1) = $GUI_CHECKED)
   			$DrawPositionName = (GUICtrlRead ($Checkbox2) = $GUI_CHECKED)
   			$drawLineNumbers = (GUICtrlRead ($Checkbox3) = $GUI_CHECKED)
   			$consolidate = (GUICtrlRead ($Checkbox4) = $GUI_CHECKED)
			$DrawEvents = (GUICtrlRead ($Checkbox5) = $GUI_CHECKED)
   			If UBound($mapFiles) > 1 Then
   				If Not $consolidate Then
		   			For $i = 1 To UBound($mapFiles) - 1
		   				_log("Handling mapFile : " & $mapFiles[0] & "\" & $mapFiles[$i])
		   				Draw_MapData($mapFiles[0]  & "\" & $mapFiles[$i], $sequenceFile)
		   			Next
	   			Else
		   			For $i = 1 To UBound($mapFiles) - 1
		   				$mapFiles[$i] = $mapFiles[0]  & "\" & $mapFiles[$i]
		   			Next
		   			Draw_MultipleMapData($mapFiles, $sequenceFile)
	   			EndIf
	   		Else
   				_log("Handling mapFile : " & $mapFiles[0])
   				Draw_MapData($mapFiles[0], $sequenceFile)
   			EndIf
   			Exit 0
	EndSwitch
WEnd