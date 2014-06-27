#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=lib\ico\icon.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Fileversion=1.9.0.0
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
	WinSetOnTop("Diablo III", "", 0)
	MsgBox(0, "Erreur : ", "Script lancé en x64, merci de le lancer en x86 ")
	Terminate()
EndIf

;;--------------------------------------------------------------------------------
;;      Make sure you are running as admin
;;--------------------------------------------------------------------------------

$Admin = IsAdmin()
If $Admin <> 1 Then
	MsgBox(0x30, "ERROR", "This program require administrative rights you fool!")
	Exit
EndIf

;;--------------------------------------------------------------------------------
;;      Open the process
;;--------------------------------------------------------------------------------
Opt("WinTitleMatchMode", -1)
SetPrivilege("SeDebugPrivilege", 1)
Global $ProcessID = WinGetProcess("[CLASS:D3 Main Window Class]", "")
$d3 = _MemoryOpen($ProcessID)
If @error Then
	WinSetOnTop("[CLASS:D3 Main Window Class]", "", 0)
	MsgBox(4096, "ERROR", "Failed to open memory for process;" & $ProcessID)
	Exit
EndIf

;;--------------------------------------------------------------------------------
;;      Initialize MouseCoords
;;--------------------------------------------------------------------------------
Opt("MouseCoordMode", 2) ;1=absolute, 0=relative, 2=client
Opt("MouseClickDownDelay", Random(10, 20))
Opt("SendKeyDownDelay", Random(10, 20))

;;--------------------------------------------------------------------------------
;;      Set tray icon
;;--------------------------------------------------------------------------------
$icon = @ScriptDir & "\lib\ico\icon.ico"
TraySetIcon($icon)

;;--------------------------------------------------------------------------------
;;      Include some files
;;--------------------------------------------------------------------------------
#include "lib\Variables.au3"
#include "lib\Utils.au3"
#include "lib\sequence.au3"
#include "lib\settings.au3"
#include "lib\skills.au3"
#include "lib\toolkit.au3"
#include "lib\botting.au3"
#include "lib\stats.au3"
#include "lib\Affix.au3"
;Automatisation des séquences
#include "lib\GestionMenu.au3"
;Gestion des pauses
#include "lib\GestionPause.au3"
; TChat
#include "lib\GestionChat.au3"
#include "lib\dev_tools.au3"

;;================================================================================
;; Set Some Hotkey
;;================================================================================
HotKeySet("{F2}", "Terminate")
HotKeySet("{F3}", "TogglePause")
HotKeySet("{F5}", "StashAndRepairTerminate")

;;--------------------------------------------------------------------------------
;;      Initialize the data and offsets
;;--------------------------------------------------------------------------------
offsetlist()
LoadingSNOExtended()
InitSettings()
InitSettingsHeros()
InitPauses()

; Vérification présence de la fenêtre
CheckWindowD3()

; Lancement du bot
If Not $Devmode Then
	_botting()
Else
	CheckAndDefineSize()
	_log("Dev mode ready", $LOG_LEVEL_WARNING)
	ShowDebugTools()
EndIf

; Attente en fin de script pour conserver la console ou utiliser les devs tools
While 1
	Sleep(15)
WEnd

