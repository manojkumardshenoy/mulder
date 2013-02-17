; ///////////////////////////////////////////////////////////////////////////////
; // MPlayer for Windows - Install Script
; // Copyright (C) 2004-2013 LoRd_MuldeR <MuldeR2@GMX.de>
; //
; // This program is free software; you can redistribute it and/or modify
; // it under the terms of the GNU General Public License as published by
; // the Free Software Foundation; either version 2 of the License, or
; // (at your option) any later version.
; //
; // This program is distributed in the hope that it will be useful,
; // but WITHOUT ANY WARRANTY; without even the implied warranty of
; // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; // GNU General Public License for more details.
; //
; // You should have received a copy of the GNU General Public License along
; // with this program; if not, write to the Free Software Foundation, Inc.,
; // 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
; //
; // http://www.gnu.org/licenses/gpl-2.0.txt
; ///////////////////////////////////////////////////////////////////////////////


;--------------------------------------------------------------------------------
; BASIC DEFINES
;--------------------------------------------------------------------------------

!ifndef MPLAYER_BUILDNO
  !error "MPLAYER_BUILDNO is not defined !!!"
!endif

!ifndef MPLAYER_DATE
  !error "MPLAYER_DATE is not defined !!!"
!endif

!ifndef MPLAYER_OUTFILE
  !error "MPLAYER_OUTPUT_FILE is not defined !!!"
!endif

!ifndef MPLAYER_SRCFILE
  !error "MPLAYER_SOURCE_FILE is not defined !!!"
!endif

!ifndef UPX_PATH
  !error "UPX_PATH is not defined !!!"
!endif

;Web-Site
!define MyWebSite "http://mulder.at.gg/"


;--------------------------------
;Includes
;--------------------------------

!include `LogicLib.nsh`
!include `StdUtils.nsh`


;--------------------------------------------------------------------------------
; INSTALLER ATTRIBUTES
;--------------------------------------------------------------------------------

XPStyle on
RequestExecutionLevel user
InstallColors /windows

Name "MPlayer for Windows (Build #${MPLAYER_BUILDNO})"
OutFile "${MPLAYER_OUTFILE}"
BrandingText "MPlayer-Win32 (Build #${MPLAYER_BUILDNO})"
Icon "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
ChangeUI all "${NSISDIR}\Contrib\UIs\sdbarker_tiny.exe"

ShowInstDetails show
AutoCloseWindow true
InstallDir ""


;--------------------------------
;Page Captions
;--------------------------------

SubCaption 0 " "
SubCaption 1 " "
SubCaption 2 " "
SubCaption 3 " "
SubCaption 4 " "


;--------------------------------------------------------------------------------
; COMPRESSOR
;--------------------------------------------------------------------------------

!packhdr "$%TEMP%\exehead.tmp" '"${UPX_PATH}\upx.exe" --brute "$%TEMP%\exehead.tmp"'


;--------------------------------------------------------------------------------
; RESERVE FILES
;--------------------------------------------------------------------------------

ReserveFile "${NSISDIR}\Plugins\Banner.dll"
ReserveFile "${NSISDIR}\Plugins\LangDLL.dll"
ReserveFile "${NSISDIR}\Plugins\LockedList.dll"
ReserveFile "${NSISDIR}\Plugins\nsDialogs.dll"
ReserveFile "${NSISDIR}\Plugins\nsExec.dll"
ReserveFile "${NSISDIR}\Plugins\StdUtils.dll"
ReserveFile "${NSISDIR}\Plugins\System.dll"
ReserveFile "${NSISDIR}\Plugins\UserInfo.dll"


;--------------------------------------------------------------------------------
; VERSION INFO
;--------------------------------------------------------------------------------

!searchreplace PRODUCT_VERSION_DATE "${MPLAYER_DATE}" "-" "."
VIProductVersion "${PRODUCT_VERSION_DATE}.${MPLAYER_BUILDNO}"

VIAddVersionKey "Author" "LoRd_MuldeR <mulder2@gmx.de>"
VIAddVersionKey "Comments" "This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version."
VIAddVersionKey "CompanyName" "Free Software Foundation"
VIAddVersionKey "FileDescription" "MPlayer for Windows (Build #${MPLAYER_BUILDNO})"
VIAddVersionKey "FileVersion" "${PRODUCT_VERSION_DATE}.${MPLAYER_BUILDNO}"
VIAddVersionKey "LegalCopyright" "Copyright 2000-2013 The MPlayer Project"
VIAddVersionKey "LegalTrademarks" "GNU"
VIAddVersionKey "OriginalFilename" "MPUI-Setup.exe"
VIAddVersionKey "ProductName" "MPlayer for Windows"
VIAddVersionKey "ProductVersion" "Build #${MPLAYER_BUILDNO} (${MPLAYER_DATE})"
VIAddVersionKey "Website" "${MPlayerWebSite}"


;--------------------------------
;Installer initialization
;--------------------------------

Section "-LaunchTheInstaller"
	SetDetailsPrint textonly
	DetailPrint "Launching installer, please stay tuned..."
	SetDetailsPrint listonly
	
	InitPluginsDir
	SetOutPath "$PLUGINSDIR"
	File "/oname=$PLUGINSDIR\MPUI-SETUP-r${MPLAYER_BUILDNO}.exe" "${MPLAYER_SRCFILE}"
	
	; --------

	${StdUtils.GetAllParameters} $R9 0
	${IfThen} "$R9" == "too_long" ${|} StrCpy $R9 "" ${|}

	${IfNot} "$R9" == ""
		DetailPrint "Parameters: $R9"
	${EndIf}

	; --------

	RunTryAgain:
	
	DetailPrint "ExecShellWait: $PLUGINSDIR\MPUI-SETUP-r${MPLAYER_BUILDNO}.exe"
	${StdUtils.ExecShellWait} $R1 "$PLUGINSDIR\MPUI-SETUP-r${MPLAYER_BUILDNO}.exe" "open" '$R9'
	DetailPrint "Result: $R1"
	
	StrCmp $R1 "error" RunFailed
	StrCmp $R1 "no_wait" RunSuccess
	Sleep 333
	HideWindow
	${StdUtils.WaitForProc} $R1
	Goto RunSuccess
	
	; --------

	RunFailed:

	MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "Failed to launch the installer. Please try again!" IDRETRY RunTryAgain

	; --------

	ClearErrors
	ExecShell "open" "$PLUGINSDIR\MPUI-SETUP-r${MPLAYER_BUILDNO}.exe" '$R9' SW_SHOWNORMAL
	IfErrors 0 RunSuccess

	ClearErrors
	ExecShell "" "$PLUGINSDIR\MPUI-SETUP-r${MPLAYER_BUILDNO}.exe" '$R9' SW_SHOWNORMAL
	IfErrors 0 RunSuccess

	; --------

	SetDetailsPrint both
	DetailPrint "Failed to launch installer :-("
	SetDetailsPrint listonly

	Abort "Aborted."

	; --------
	
	RunSuccess:

	Delete /REBOOTOK "$PLUGINSDIR\MPUI-SETUP-r${MPLAYER_BUILDNO}.exe"
SectionEnd
