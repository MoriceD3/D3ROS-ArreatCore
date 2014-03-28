#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=lib\ico\icon.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

; Vérification lancement en x86
$checkx64 = @AutoItX64
If $checkx64 = 1 Then
	WinSetOnTop("Diablo III", "", 0)
	MsgBox(0, "Erreur : ", "Script lancé en x64, merci de le lancer en x86 ")
	Terminate()
EndIf


$icon = @ScriptDir & "\lib\ico\icon.ico"
TraySetIcon($icon)

;;--------------------------------------------------------------------------------
;;      Initialize MouseCoords
;;--------------------------------------------------------------------------------"
Opt("MouseCoordMode", 2) ;1=absolute, 0=relative, 2=client

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

; Vérification présence de la fenêtre
CheckWindowD3()

; Lancement du bot
If Not $Devmode Then
	_botting()
EndIf

; Attente en fin de script pour conserver la console ou utiliser les devs tools
While 1
	Sleep(15)
WEnd

