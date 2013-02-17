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

!ifndef NSIS_UNICODE
  !error "NSIS_UNICODE is undefined, please compile with Unicode NSIS !!!"
!endif

!ifndef MPLAYER_BUILDNO
  !error "MPLAYER_BUILDNO is not defined !!!"
!endif

!ifndef MPLAYER_DATE
  !error "MPLAYER_DATE is not defined !!!"
!endif

!ifndef MPLAYER_OUTFILE
  !error "MPLAYER_OUTFILE is not defined !!!"
!endif

!ifndef UPX_PATH
  !error "UPX_PATH is not defined !!!"
!endif

;UUID
!define MPlayerRegPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{97D341C8-B0D1-4E4A-A49A-C30B52F168E9}"

;Web-Site
!define MPlayerWebSite "http://mplayerhq.hu/"


;--------------------------------------------------------------------------------
; INCLUDES
;--------------------------------------------------------------------------------

!include `MUI2.nsh`
!include `InstallOptions.nsh`
!include `WinVer.nsh`
!include `x64.nsh`
!include `StdUtils.nsh`
!include `MPUI_Common.nsh`


;--------------------------------------------------------------------------------
; INSTALLER ATTRIBUTES
;--------------------------------------------------------------------------------

RequestExecutionLevel admin
ShowInstDetails show
ShowUninstDetails show

Name "MPlayer for Windows (Build #${MPLAYER_BUILDNO})"
OutFile "${MPLAYER_OUTFILE}"
BrandingText "MPlayer-Win32 (Build #${MPLAYER_BUILDNO})"
InstallDir "$PROGRAMFILES\MPlayer for Windows"
InstallDirRegKey HKLM "${MPlayerRegPath}" "InstallLocation"


;--------------------------------------------------------------------------------
; COMPRESSOR
;--------------------------------------------------------------------------------

SetCompressor /SOLID LZMA
SetCompressorDictSize 96

!packhdr "$%TEMP%\exehead.tmp" '"${UPX_PATH}\upx.exe" --brute "$%TEMP%\exehead.tmp"'


;--------------------------------------------------------------------------------
; RESERVE FILES
;--------------------------------------------------------------------------------

ReserveFile "${NSISDIR}\Plugins\Aero.dll"
ReserveFile "${NSISDIR}\Plugins\LangDLL.dll"
ReserveFile "${NSISDIR}\Plugins\LockedList.dll"
ReserveFile "${NSISDIR}\Plugins\nsDialogs.dll"
ReserveFile "${NSISDIR}\Plugins\nsExec.dll"
ReserveFile "${NSISDIR}\Plugins\StartMenu.dll"
ReserveFile "${NSISDIR}\Plugins\StdUtils.dll"
ReserveFile "${NSISDIR}\Plugins\System.dll"
ReserveFile "${NSISDIR}\Plugins\UserInfo.dll"


;--------------------------------------------------------------------------------
; GLOBAL VARIABLES
;--------------------------------------------------------------------------------

Var StartMenuFolder
Var SelectedCPUType


;--------------------------------------------------------------------------------
; VERSION INFO
;--------------------------------------------------------------------------------

!searchreplace PRODUCT_VERSION_DATE "${MPLAYER_DATE}" "-" "."
VIProductVersion "${PRODUCT_VERSION_DATE}.${MPLAYER_BUILDNO}"

VIAddVersionKey "Author" "LoRd_MuldeR <mulder2@gmx.de>"
VIAddVersionKey "Comments" "This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version."
VIAddVersionKey "CompanyName" "Free Software Foundation"
VIAddVersionKey "FileDescription" "LameXP v${LAMEXP_VERSION} ${LAMEXP_INSTTYPE}-${LAMEXP_PATCH} [Build #${LAMEXP_BUILD}]"
VIAddVersionKey "FileVersion" "${PRODUCT_VERSION_DATE}.${LAMEXP_BUILD} (${LAMEXP_VERSION})"
VIAddVersionKey "LegalCopyright" "Copyright 2000-2013 The MPlayer Project"
VIAddVersionKey "LegalTrademarks" "GNU"
VIAddVersionKey "OriginalFilename" "MPUI-Setup.exe"
VIAddVersionKey "ProductName" "MPlayer for Windows"
VIAddVersionKey "ProductVersion" "Build #${MPLAYER_BUILDNO} (${MPLAYER_DATE})"
VIAddVersionKey "Website" "${MPlayerWebSite}"


;--------------------------------------------------------------------------------
; MUI2 INTERFACE SETTINGS
;--------------------------------------------------------------------------------

!define MUI_ABORTWARNING
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${MPlayerWebSite}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "StartmenuFolder"
!define MUI_LANGDLL_REGISTRY_ROOT HKLM
!define MUI_LANGDLL_REGISTRY_KEY "${MPlayerWebSite}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "SetupLanguage"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "MPlayer for Windows"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION RunAppFunction
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION ShowReadmeFunction
!define MUI_FINISHPAGE_LINK ${MPlayerWebSite}
!define MUI_FINISHPAGE_LINK_LOCATION ${MPlayerWebSite}
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "Artwork\wizard.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "Artwork\wizard-un.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "Artwork\header.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "Artwork\header-un.bmp"
!define MUI_LANGDLL_ALLLANGUAGES
!define MUI_CUSTOMFUNCTION_GUIINIT MyGuiInit
!define MUI_CUSTOMFUNCTION_UNGUIINIT un.MyGuiInit
!define MUI_LANGDLL_ALWAYSSHOW


;--------------------------------------------------------------------------------
; MUI2 PAGE SETUP
;--------------------------------------------------------------------------------

; Installer
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "Docs\License.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
Page Custom SelectCPUPage_Show SelectCPUPage_Validate ""
Page Custom LockedListPage_Show
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Un-Installer
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage Custom un.LockedListPage_Show
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH


;--------------------------------------------------------------------------------
; LANGUAGE
;--------------------------------------------------------------------------------
 
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "German"

; Translation files
!include "Language\MPUI_EN.nsh"
!include "Language\MPUI_DE.nsh"


;--------------------------------------------------------------------------------
; INITIALIZATION
;--------------------------------------------------------------------------------

Function .onInit
	InitPluginsDir
	StrCpy $SelectedCPUType 6 ;generic

	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "{B800490C-C100-4B12-9F09-1A54DF063049}") i .r1 ?e'
	Pop $0
	${If} $0 <> 0
		MessageBox MB_ICONSTOP|MB_TOPMOST "Oups, the installer is already running!"
		Quit
	${EndIf}

	; --------
	
	# Running on Windows NT family?
	${IfNot} ${IsNT}
		MessageBox MB_TOPMOST|MB_ICONSTOP "Sorry, this application does *not* support Windows 9x or Windows ME!"
		ExecShell "open" "http://windows.microsoft.com/"
		Quit
	${EndIf}

	# Running on Windows XP or later?
	${If} ${AtMostWin2000}
		MessageBox MB_TOPMOST|MB_ICONSTOP "Sorry, but your operating system is *not* supported anymore.$\nInstallation will be aborted!$\n$\nThe minimum required platform is Windows XP."
		ExecShell "open" "http://windows.microsoft.com/"
		Quit
	${EndIf}

	; --------

	UserInfo::GetAccountType
	Pop $0
	${If} $0 != "Admin"
		MessageBox MB_ICONSTOP|MB_TOPMOST "Your system requires administrative permissions in order to install this software."
		SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
		Quit
	${EndIf}
	
	; --------
	
	!insertmacro MUI_LANGDLL_DISPLAY
	!insertmacro INSTALLOPTIONS_EXTRACT_AS "Dialogs\Page_CPU.ini" "Page_CPU.ini"
FunctionEnd

Function un.onInit
	InitPluginsDir

	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "{B800490C-C100-4B12-9F09-1A54DF063049}") i .r1 ?e'
	Pop $0
	${If} $0 <> 0
		MessageBox MB_ICONSTOP|MB_TOPMOST "Sorry, the un-installer is already running!"
		Quit
	${EndIf}

	; --------

	UserInfo::GetAccountType
	Pop $0
	${If} $0 != "Admin"
		MessageBox MB_ICONSTOP|MB_TOPMOST "Your system requires administrative permissions in order to un-install this software."
		SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
		Quit
	${EndIf}

	; --------
	
	!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd


;--------------------------------------------------------------------------------
; GUI INITIALIZATION
;--------------------------------------------------------------------------------

Function MyGuiInit
	StrCpy $0 $HWNDPARENT
	System::Call "user32::SetWindowPos(i r0, i -1, i 0, i 0, i 0, i 0, i 3)"
	Aero::Apply
FunctionEnd

Function un.MyGuiInit
	StrCpy $0 $HWNDPARENT
	System::Call "user32::SetWindowPos(i r0, i -1, i 0, i 0, i 0, i 0, i 3)"
	Aero::Apply
FunctionEnd


;--------------------------------------------------------------------------------
; INSTALL SECTIONS
;--------------------------------------------------------------------------------

Section "-PreInit"
	SetShellVarContext all
	SetOutPath "$INSTDIR"
SectionEnd

Section "!Install Files"
	!insertmacro PrintProgress "$(MPLAYER_LANG_STATUS_INSTFILES)"
SectionEnd

Section "-Write Uinstaller"
	!insertmacro PrintProgress "$(MPLAYER_LANG_STATUS_MAKEUNINST)"
	WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "-Create Shortcuts"
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
		!insertmacro PrintProgress "$(MPLAYER_LANG_STATUS_SHORTCUTS)"
		CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
		
		SetShellVarContext current
		
		Delete "$SMPROGRAMS\$StartMenuFolder\*.lnk"
		Delete "$SMPROGRAMS\$StartMenuFolder\*.pif"
		Delete "$SMPROGRAMS\$StartMenuFolder\*.url"
		
		SetShellVarContext all
		
		Delete "$SMPROGRAMS\$StartMenuFolder\*.lnk"
		Delete "$SMPROGRAMS\$StartMenuFolder\*.pif"
		Delete "$SMPROGRAMS\$StartMenuFolder\*.url"

		;CreateShortCut "$SMPROGRAMS\$StartMenuFolder\LameXP.lnk" "$INSTDIR\$R0" "" "$INSTDIR\$R0" 0

		;!insertmacro CreateWebLink "$SMPROGRAMS\$StartMenuFolder\Official LameXP Homepage.url" "http://mulder.dummwiedeutsch.de/"

		${If} ${FileExists} "$SMPROGRAMS\$StartMenuFolder\SMPlayer.lnk"
			${StdUtils.InvokeShellVerb} $R1 "$SMPROGRAMS\$StartMenuFolder" "SMPlayer.lnk" ${StdUtils.Const.ISV_PinToTaskbar}
			DetailPrint 'Pin: "$SMPROGRAMS\$StartMenuFolder\LameXP.lnk" -> $R1'
		${EndIf}
	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "-Update Registry"
	!insertmacro PrintProgress "$(LAMEXP_LANG_STATUS_REGISTRY)"

	;WriteRegStr HKLM "${MyRegPath}" "InstallLocation" "$INSTDIR"
	;WriteRegStr HKLM "${MyRegPath}" "ExecutableName" "$R0"
	;WriteRegStr HKLM "${MyRegPath}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
	;WriteRegStr HKLM "${MyRegPath}" "DisplayName" "LameXP"
SectionEnd

Section "-Finished"
	!insertmacro PrintProgress "$(MUI_TEXT_FINISH_TITLE)."
SectionEnd


;--------------------------------------------------------------------------------
; UN-INSTALL SECTIONS
;--------------------------------------------------------------------------------

Section "Uninstall"
	SetOutPath "$INSTDIR"
	!insertmacro PrintProgress "$(MPLAYER_LANG_STATUS_UNINSTALL)"

	; --------------
	; Startmenu
	; --------------
	
	; !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	; ${IfNot} "$StartMenuFolder" == ""
		; SetShellVarContext current
		; ${If} ${FileExists} "$SMPROGRAMS\$StartMenuFolder\LameXP.lnk"
			; ${StdUtils.InvokeShellVerb} $R1 "$SMPROGRAMS\$StartMenuFolder" "LameXP.lnk" ${StdUtils.Const.ISV_UnpinFromTaskbar}
			; DetailPrint 'Unpin: "$SMPROGRAMS\$StartMenuFolder\LameXP.lnk" -> $R1'
		; ${EndIf}
		; ${If} ${FileExists} "$SMPROGRAMS\$StartMenuFolder\*.*"
			; Delete /REBOOTOK "$SMPROGRAMS\$StartMenuFolder\*.lnk"
			; Delete /REBOOTOK "$SMPROGRAMS\$StartMenuFolder\*.url"
			; RMDir "$SMPROGRAMS\$StartMenuFolder"
		; ${EndIf}
		
		; SetShellVarContext all
		; ${If} ${FileExists} "$SMPROGRAMS\$StartMenuFolder\LameXP.lnk"
			; ${StdUtils.InvokeShellVerb} $R1 "$SMPROGRAMS\$StartMenuFolder" "LameXP.lnk" ${StdUtils.Const.ISV_UnpinFromTaskbar}
			; DetailPrint 'Unpin: "$SMPROGRAMS\$StartMenuFolder\LameXP.lnk" -> $R1'
		; ${EndIf}
		; ${If} ${FileExists} "$SMPROGRAMS\$StartMenuFolder\*.*"
			; Delete /REBOOTOK "$SMPROGRAMS\$StartMenuFolder\*.lnk"
			; Delete /REBOOTOK "$SMPROGRAMS\$StartMenuFolder\*.url"
			; RMDir "$SMPROGRAMS\$StartMenuFolder"
		; ${EndIf}
	; ${EndIf}

	; --------------
	; Files
	; --------------

	; ReadRegStr $R0 HKLM "${MyRegPath}" "ExecutableName"
	; ${IfThen} "$R0" == "" ${|} StrCpy $R0 "LameXP.exe" ${|}

	; Delete /REBOOTOK "$INSTDIR\LameXP.exe"
	; Delete /REBOOTOK "$INSTDIR\$R0"
	; Delete /REBOOTOK "$INSTDIR\LameXP-Portable.exe"
	; Delete /REBOOTOK "$INSTDIR\LameXP.exe.sig"
	; Delete /REBOOTOK "$INSTDIR\LameXP*"
	
	; Delete /REBOOTOK "$INSTDIR\Changelog.htm"
	; Delete /REBOOTOK "$INSTDIR\Changelog.html"
	; Delete /REBOOTOK "$INSTDIR\Contributors.txt"
	; Delete /REBOOTOK "$INSTDIR\Copying.txt"
	; Delete /REBOOTOK "$INSTDIR\FAQ.html"
	; Delete /REBOOTOK "$INSTDIR\Howto.html"
	; Delete /REBOOTOK "$INSTDIR\LameEnc.sys"
	; Delete /REBOOTOK "$INSTDIR\License.txt"
	; Delete /REBOOTOK "$INSTDIR\Manual.html"
	; Delete /REBOOTOK "$INSTDIR\Readme.htm"
	; Delete /REBOOTOK "$INSTDIR\ReadMe.txt"
	; Delete /REBOOTOK "$INSTDIR\PRE_RELEASE_INFO.txt"
	; Delete /REBOOTOK "$INSTDIR\Settings.cfg"
	; Delete /REBOOTOK "$INSTDIR\Translate.html"
	; Delete /REBOOTOK "$INSTDIR\Uninstall.exe"

	; RMDir "$INSTDIR"

	; --------------
	; Registry
	; --------------
	
	; DeleteRegValue HKLM "${MyRegPath}" "InstallLocation"
	; DeleteRegValue HKLM "${MyRegPath}" "ExecutableName"
	; DeleteRegValue HKLM "${MyRegPath}" "UninstallString"
	; DeleteRegValue HKLM "${MyRegPath}" "DisplayName"
	; DeleteRegValue HKLM "${MyRegPath}" "StartmenuFolder"
	; DeleteRegValue HKLM "${MyRegPath}" "SetupLanguage"
	
	; MessageBox MB_YESNO|MB_TOPMOST "$(LAMEXP_LANG_UNINST_PERSONAL)" IDNO +3
	; Delete "$LOCALAPPDATA\LoRd_MuldeR\LameXP - Audio Encoder Front-End\config.ini"
	; Delete "$INSTDIR\*.ini"

	!insertmacro PrintProgress "$(MUI_UNTEXT_FINISH_TITLE)."
SectionEnd


;--------------------------------------------------------------------------------
; LOCKED-LIST PLUGIN
;--------------------------------------------------------------------------------

Function LockedListPage_Show
	; !insertmacro MUI_HEADER_TEXT "$(LAMEXP_LANG_LOCKEDLIST_HEADER)" "$(LAMEXP_LANG_LOCKEDLIST_TEXT)"
	; !insertmacro GetExecutableName $R0
	; LockedList::AddModule "\$R0"
	; LockedList::AddModule "\Uninstall.exe"
	; LockedList::AddModule "\Au_.exe"
	; LockedList::Dialog /autonext /heading "$(LAMEXP_LANG_LOCKEDLIST_HEADING)" /noprograms "$(LAMEXP_LANG_LOCKEDLIST_NOPROG)" /searching  "$(LAMEXP_LANG_LOCKEDLIST_SEARCH)" /colheadings "$(LAMEXP_LANG_LOCKEDLIST_COLHDR1)" "$(LAMEXP_LANG_LOCKEDLIST_COLHDR2)"
	; Pop $R0
FunctionEnd

Function un.LockedListPage_Show
	; !insertmacro MUI_HEADER_TEXT "$(LAMEXP_LANG_LOCKEDLIST_HEADER)" "$(LAMEXP_LANG_LOCKEDLIST_TEXT)"
	; LockedList::AddModule "\LameXP.exe"
	; LockedList::AddModule "\Uninstall.exe"
	; LockedList::Dialog /autonext /heading "$(LAMEXP_LANG_LOCKEDLIST_HEADING)" /noprograms "$(LAMEXP_LANG_LOCKEDLIST_NOPROG)" /searching  "$(LAMEXP_LANG_LOCKEDLIST_SEARCH)" /colheadings "$(LAMEXP_LANG_LOCKEDLIST_COLHDR1)" "$(LAMEXP_LANG_LOCKEDLIST_COLHDR2)"
	; Pop $R0
FunctionEnd


;--------------------------------------------------------------------------------
; CUSTOME PAGE: CPU SELECTOR
;--------------------------------------------------------------------------------

Function SelectCPUPage_Show
	${IfThen} $SelectedCPUType < 2 ${|} StrCpy $SelectedCPUType 6 ${|}
	${IfThen} $SelectedCPUType > 6 ${|} StrCpy $SelectedCPUType 6 ${|}

	${For} $0 2 6
		${If} $0 == $SelectedCPUType
			WriteINIStr "$PLUGINSDIR\Page_CPU.ini" "Field $0" "State" "1"
		${Else}
			WriteINIStr "$PLUGINSDIR\Page_CPU.ini" "Field $0" "State" "0"
		${EndIf}
	${Next}

	!insertmacro INSTALLOPTIONS_DISPLAY "Page_CPU.ini"
FunctionEnd

Function SelectCPUPage_Validate
FunctionEnd


;--------------------------------------------------------------------------------
; FINISHED
;--------------------------------------------------------------------------------

Function RunAppFunction
	!insertmacro DisableNextButton $R0
	;!insertmacro GetExecutableName $R0
	;${StdUtils.ExecShellAsUser} $R1 "$INSTDIR" "explore" ""
	;${StdUtils.ExecShellAsUser} $R1 "$INSTDIR\$R0" "open" "--first-run"
FunctionEnd

Function ShowReadmeFunction
	!insertmacro DisableNextButton $R0
	;${StdUtils.ExecShellAsUser} $R1 "$INSTDIR\FAQ.html" "open" ""
FunctionEnd


### EOF ###
