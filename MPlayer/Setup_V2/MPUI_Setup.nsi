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

!ifndef MPLAYER_REVISION
  !error "MPLAYER_REVISION is not defined !!!"
!endif

!ifndef MPLAYER_DATE
  !error "MPLAYER_DATE is not defined !!!"
!endif

!ifndef SMPLAYER_VERSION
  !error "SMPLAYER_VERSION is not defined !!!"
!endif

!ifndef MPUI_VERSION
  !error "MPUI_VERSION is not defined !!!"
!endif

!ifndef CODECS_DATE
  !error "CODECS_DATE is not defined !!!"
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
; INSTALLER ATTRIBUTES
;--------------------------------------------------------------------------------

RequestExecutionLevel admin
ShowInstDetails show
ShowUninstDetails show

Name "MPlayer for Windows ${MPLAYER_DATE} (Build #${MPLAYER_BUILDNO})"
Caption "MPlayer for Windows ${MPLAYER_DATE} (Build #${MPLAYER_BUILDNO})"
BrandingText "MPlayer-Win32 (Build #${MPLAYER_BUILDNO})"
InstallDir "$PROGRAMFILES\MPlayer for Windows"
InstallDirRegKey HKLM "${MPlayerRegPath}" "InstallLocation"
OutFile "${MPLAYER_OUTFILE}"


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
ReserveFile "${NSISDIR}\Plugins\Banner.dll"
ReserveFile "${NSISDIR}\Plugins\CPUFeatures.dll"
ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"
ReserveFile "${NSISDIR}\Plugins\LangDLL.dll"
ReserveFile "${NSISDIR}\Plugins\LockedList.dll"
ReserveFile "${NSISDIR}\Plugins\nsDialogs.dll"
ReserveFile "${NSISDIR}\Plugins\nsExec.dll"
ReserveFile "${NSISDIR}\Plugins\StartMenu.dll"
ReserveFile "${NSISDIR}\Plugins\StdUtils.dll"
ReserveFile "${NSISDIR}\Plugins\System.dll"
ReserveFile "${NSISDIR}\Plugins\UserInfo.dll"
ReserveFile "Dialogs\Page_CPU.ini"
ReserveFile "Resources\Splash.gif"


;--------------------------------------------------------------------------------
; INCLUDES
;--------------------------------------------------------------------------------

!include `MUI2.nsh`
!include `InstallOptions.nsh`
!include `WinVer.nsh`
!include `x64.nsh`
!include `StrFunc.nsh`
!include `StdUtils.nsh`
!include `CPUFeatures.nsh`
!include `MPUI_Common.nsh`

; Enable functions
${StrRep}


;--------------------------------------------------------------------------------
; GLOBAL VARIABLES
;--------------------------------------------------------------------------------

Var StartMenuFolder
Var DetectedCPUType
Var SelectedCPUType


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


;--------------------------------------------------------------------------------
; MUI2 INTERFACE SETTINGS
;--------------------------------------------------------------------------------

!define MUI_ABORTWARNING
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${MPlayerRegPath}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "StartmenuFolder"
!define MUI_LANGDLL_REGISTRY_ROOT HKLM
!define MUI_LANGDLL_REGISTRY_KEY "${MPlayerRegPath}"
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
!define MUI_COMPONENTSPAGE_SMALLDESC


;--------------------------------------------------------------------------------
; MUI2 PAGE SETUP
;--------------------------------------------------------------------------------

; Installer
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "Docs\License.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro  MUI_PAGE_COMPONENTS
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
	StrCpy $SelectedCPUType 0
	StrCpy $DetectedCPUType 0
	InitPluginsDir

	; --------
	
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
	
	${IfCmd} MessageBox MB_TOPMOST|MB_ICONEXCLAMATION|MB_OKCANCEL|MB_DEFBUTTON2 "Note: This is an early pre-release version for test only!" IDCANCEL ${||} Quit ${|}
	
	; --------

	File "/oname=$PLUGINSDIR\Splash.gif" "Resources\Splash.gif"
	newadvsplash::show 3000 1000 500 -1 /NOCANCEL "$PLUGINSDIR\Splash.gif"
	Delete /REBOOTOK "$PLUGINSDIR\Splash.gif"
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
SectionEnd

Section "-Clean Up"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_INST_CLEAN)"
	
	Delete "$INSTDIR\*.exe"
	Delete "$INSTDIR\*.dll"
	Delete "$INSTDIR\*.ini"
	Delete "$INSTDIR\*.txt"
	Delete "$INSTDIR\*.html"
	Delete "$INSTDIR\*.htm"
	Delete "$INSTDIR\*.ass"
	Delete "$INSTDIR\*.m3u8"
	Delete "$INSTDIR\mplayer\config"
	Delete "$INSTDIR\mplayer\*.conf"
	
	; Now deal with Virtual Store
	StrCpy $0 "$INSTDIR" "" 3
	StrCpy $0 "$LOCALAPPDATA\VirtualStore\$0"
	Delete "$0\*.ini"
	Delete "$0\*.ass"
	Delete "$0\*.m3u8"
	Delete "$0\mplayer\config"
	Delete "$0\mplayer\*.conf"
	
	; Make sure MPlayer isn't running
	${Do}
		Delete "$INSTDIR\MPlayer.exe"
		Delete "$INSTDIR\SMPlayer.exe"
		Delete "$INSTDIR\MPUI.exe"
		${If} ${FileExists} "$INSTDIR\MPlayer.exe"
		${OrIf} ${FileExists} "$INSTDIR\SMPlayer.exe"
		${OrIf} ${FileExists} "$INSTDIR\MPUI.exe"
			${IfCmd} MessageBox MB_TOPMOST|MB_ICONEXCLAMATION|MB_OKCANCEL "$(MPLAYER_LANG_STILL_RUNNING)" IDCANCEL ${||} Abort ${|}
		${Else}
			${Break}
		${EndIf}
	${Loop}
SectionEnd

Section "!MPlayer r${MPLAYER_REVISION}"
	SectionIn RO
	${PrintProgress} "$(MPLAYER_LANG_STATUS_INST_MPLAYER)"
	SetOutPath "$INSTDIR"
	
	; MPlayer.exe
	${If} $SelectedCPUType == 2
		DetailPrint "$(MPLAYER_LANG_SELECTED_TYPE): core2"
		File "Builds\MPlayer-core2\MPlayer.exe"
	${EndIf}
	${If} $SelectedCPUType == 3
		DetailPrint "$(MPLAYER_LANG_SELECTED_TYPE): corei7"
		File "Builds\MPlayer-corei7\MPlayer.exe"
	${EndIf}
	${If} $SelectedCPUType == 4
		DetailPrint "$(MPLAYER_LANG_SELECTED_TYPE): k8-sse3"
		File "Builds\MPlayer-k8-sse3\MPlayer.exe"
	${EndIf}
	${If} $SelectedCPUType == 5
		DetailPrint "$(MPLAYER_LANG_SELECTED_TYPE): bdver1"
		File "Builds\MPlayer-bdver1\MPlayer.exe"
	${EndIf}
	${If} $SelectedCPUType == 6
		DetailPrint "$(MPLAYER_LANG_SELECTED_TYPE): generic"
		File "Builds\MPlayer-generic\MPlayer.exe"
	${EndIf}
	
	; Other MPlayer-related files
	File "Builds\MPlayer-generic\dsnative.dll"
	File "/oname=Manual.html" "Builds\MPlayer-generic\MPlayer.man.html"
	File "Docs\Readme.html"
	SetOutPath "$INSTDIR\mplayer"
	File "Builds\MPlayer-generic\mplayer\config"
	SetOutPath "$INSTDIR\fonts"
	File "Builds\MPlayer-generic\fonts\fonts.conf"
	SetOutPath "$INSTDIR\fonts\conf.d"
	File "Builds\MPlayer-generic\fonts\conf.d\*.conf"
	
	; Set file access rights
	${MakeFilePublic} "$INSTDIR\mplayer\config"
	${MakeFilePublic} "$INSTDIR\fonts\fonts.conf"
SectionEnd

Section "!MPUI $(MPLAYER_LANG_FRONT_END) v${MPUI_VERSION}"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_INST_CODECS)"
	
	; Extract files
	SetOutPath "$INSTDIR"
	File "MPUI\MPUI.exe"

	; Set file access rights
	${MakeFilePublic} "$INSTDIR\MPUI.ini"
SectionEnd

Section "!SMPlayer $(MPLAYER_LANG_FRONT_END) v${SMPLAYER_VERSION}"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_INST_CODECS)"

	; Extract files
	SetOutPath "$INSTDIR"
	File "SMPlayer\SMPlayer.exe"
	File "SMPlayer\libgcc_s_dw2-1.dll"
	File "SMPlayer\mingwm10.dll"
	File "SMPlayer\QtCore4.dll"
	File "SMPlayer\QtGui4.dll"
	File "SMPlayer\QtNetwork4.dll"
	File "SMPlayer\QtXml4.dll"
	File "SMPlayer\zlib1.dll"

	; Set file access rights
	${MakeFilePublic} "$INSTDIR\SMPlayer.ini"
	${MakeFilePublic} "$INSTDIR\favorites.m3u8"
	${MakeFilePublic} "$INSTDIR\radio.m3u8"
	${MakeFilePublic} "$INSTDIR\tv.m3u8"
	${MakeFilePublic} "$INSTDIR\styles.ass"
	
	; Setup initial config
	${StrRep} $0 "$INSTDIR\MPlayer.exe" "\" "/"
	WriteINIStr "$INSTDIR\SMPlayer.ini" "%General" "mplayer_bin" "$0"
	WriteINIStr "$INSTDIR\SMPlayer.ini" "%General" "driver\vo" "direct3d"
	WriteINIStr "$INSTDIR\SMPlayer.ini" "gui" "style" "Plastique"
SectionEnd

Section "!$(MPLAYER_LANG_BIN_CODECS) (${CODECS_DATE})"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_INST_CODECS)"
	SetOutPath "$INSTDIR\codecs"
	
	File "Codecs\*.0"
	File "Codecs\*.acm"
	File "Codecs\*.ax"
	File "Codecs\*.dll"
	File "Codecs\*.qtx"
	File "Codecs\*.so"
	File "Codecs\*.vwp"
	File "Codecs\*.xa"
SectionEnd

Section "-Write Uninstaller"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_MAKEUNINST)"
	WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "-Create Shortcuts"
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
		${PrintProgress} "$(MPLAYER_LANG_STATUS_SHORTCUTS)"
		CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
		
		SetShellVarContext current
		Delete "$SMPROGRAMS\$StartMenuFolder\*.lnk"
		Delete "$SMPROGRAMS\$StartMenuFolder\*.pif"
		Delete "$SMPROGRAMS\$StartMenuFolder\*.url"
		
		SetShellVarContext all
		Delete "$SMPROGRAMS\$StartMenuFolder\*.lnk"
		Delete "$SMPROGRAMS\$StartMenuFolder\*.pif"
		Delete "$SMPROGRAMS\$StartMenuFolder\*.url"

		${If} ${FileExists} "$INSTDIR\MPUI.exe"
			CreateShortCut "$SMPROGRAMS\$StartMenuFolder\MPUI.lnk" "$INSTDIR\MPUI.exe"
		${EndIf}
		${If} ${FileExists} "$INSTDIR\SMPlayer.exe"
			CreateShortCut "$SMPROGRAMS\$StartMenuFolder\SMPlayer.lnk" "$INSTDIR\SMPlayer.exe"
		${EndIf}

		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Readme.lnk" "$INSTDIR\Readme.html"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Manual.lnk" "$INSTDIR\Manual.html"
		
		${CreateWebLink} "$SMPROGRAMS\$StartMenuFolder\MPlayer Web-Site.url" "http://www.mplayerhq.hu/"
		${CreateWebLink} "$SMPROGRAMS\$StartMenuFolder\MuldeR's Web-Site.url" "http://www.mulder.at.gg/"

		${If} ${FileExists} "$SMPROGRAMS\$StartMenuFolder\SMPlayer.lnk"
			${StdUtils.InvokeShellVerb} $R1 "$SMPROGRAMS\$StartMenuFolder" "SMPlayer.lnk" ${StdUtils.Const.ISV_PinToTaskbar}
			DetailPrint 'Pin: "$SMPROGRAMS\$StartMenuFolder\SMPlayer.lnk" -> $R1'
		${EndIf}
	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "$(MPLAYER_LANG_COMPRESS_FILES)"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_INST_COMPRESS)"
	
	File "/oname=$PLUGINSDIR\UPX.exe" "Utils\UPX.exe"
	
	${PackAll} "$INSTDIR" "*.exe"
	${PackAll} "$INSTDIR" "*.dll"
	${PackAll} "$INSTDIR\codecs" "*.acm"
	${PackAll} "$INSTDIR\codecs" "*.ax"
	${PackAll} "$INSTDIR\codecs" "*.dll"
	${PackAll} "$INSTDIR\codecs" "*.qtx"

	Delete "$PLUGINSDIR\UPX.exe"
SectionEnd

Section "-Update Font Cache"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_INST_FONTCACHE)"
	
	SetShellVarContext current
	Delete "$APPDATA\fontconfig\cache\*.*"
	Delete "$LOCALAPPDATA\fontconfig\cache\*.*"
	
	SetShellVarContext all
	Delete "$APPDATA\fontconfig\cache\*.*"
	Delete "$LOCALAPPDATA\fontconfig\cache\*.*"

	File "/oname=$PLUGINSDIR\Sample.avi" "Resources\Sample.avi"
	DetailPrint "$(MPLAYER_LANG_UPDATING_FONTCACHE)"
	NsExec::Exec '"$INSTDIR\MPlayer.exe" -fontconfig -ass -vo null -ao null "$PLUGINSDIR\Sample.avi"'
	Delete "Resources\Sample.avi"
SectionEnd

Section "-Update Registry"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_REGISTRY)"
	
	WriteRegStr HKLM "${MPlayerRegPath}" "InstallLocation" "$INSTDIR"
	WriteRegStr HKLM "${MPlayerRegPath}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
	WriteRegStr HKLM "${MPlayerRegPath}" "DisplayName" "MPlayer for Windows"
	WriteRegStr HKLM "${MPlayerRegPath}" "URLInfoAbout" "http://mulder.at.gg/"
	WriteRegStr HKLM "${MPlayerRegPath}" "URLUpdateInfo" "http://mulder.at.gg/"
	WriteRegDWORD HKLM "${MPlayerRegPath}" "NoModify" 1
	WriteRegDWORD HKLM "${MPlayerRegPath}" "NoRepair" 1
SectionEnd

Section "-Finished"
	${PrintStatus} "$(MUI_TEXT_FINISH_TITLE)"
SectionEnd


;--------------------------------------------------------------------------------
; UN-INSTALL SECTIONS
;--------------------------------------------------------------------------------

Section "Uninstall"
	SetOutPath "$INSTDIR"
	${PrintProgress} "$(MPLAYER_LANG_STATUS_UNINSTALL)"

	MessageBox MB_TOPMOST|MB_ICONSTOP "Uninstall not implemented yet, sorry :-("
	Abort
	
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
	
	; MessageBox MB_YESNO|MB_TOPMOST "$(MPLAYER_LANG_UNINST_PERSONAL)" IDNO +3
	; Delete "$LOCALAPPDATA\LoRd_MuldeR\LameXP - Audio Encoder Front-End\config.ini"
	; Delete "$INSTDIR\*.ini"

	${PrintStatus} "$(MUI_UNTEXT_FINISH_TITLE)"
SectionEnd


;--------------------------------------------------------------------------------
; LOCKED-LIST PLUGIN
;--------------------------------------------------------------------------------

Function LockedListPage_Show
	; !insertmacro MUI_HEADER_TEXT "$(MPLAYER_LANG_LOCKEDLIST_HEADER)" "$(MPLAYER_LANG_LOCKEDLIST_TEXT)"
	; !insertmacro GetExecutableName $R0
	; LockedList::AddModule "\$R0"
	; LockedList::AddModule "\Uninstall.exe"
	; LockedList::AddModule "\Au_.exe"
	; LockedList::Dialog /autonext /heading "$(MPLAYER_LANG_LOCKEDLIST_HEADING)" /noprograms "$(MPLAYER_LANG_LOCKEDLIST_NOPROG)" /searching  "$(MPLAYER_LANG_LOCKEDLIST_SEARCH)" /colheadings "$(MPLAYER_LANG_LOCKEDLIST_COLHDR1)" "$(MPLAYER_LANG_LOCKEDLIST_COLHDR2)"
	; Pop $R0
FunctionEnd

Function un.LockedListPage_Show
	; !insertmacro MUI_HEADER_TEXT "$(MPLAYER_LANG_LOCKEDLIST_HEADER)" "$(MPLAYER_LANG_LOCKEDLIST_TEXT)"
	; LockedList::AddModule "\LameXP.exe"
	; LockedList::AddModule "\Uninstall.exe"
	; LockedList::Dialog /autonext /heading "$(MPLAYER_LANG_LOCKEDLIST_HEADING)" /noprograms "$(MPLAYER_LANG_LOCKEDLIST_NOPROG)" /searching  "$(MPLAYER_LANG_LOCKEDLIST_SEARCH)" /colheadings "$(MPLAYER_LANG_LOCKEDLIST_COLHDR1)" "$(MPLAYER_LANG_LOCKEDLIST_COLHDR2)"
	; Pop $R0
FunctionEnd


;--------------------------------------------------------------------------------
; CUSTOME PAGE: CPU SELECTOR
;--------------------------------------------------------------------------------

Function SelectCPUPage_Show
	; Detect CPU type, if not detected yet
	${If} $DetectedCPUType < 2
	${OrIf} $DetectedCPUType > 6
		Call DetectCPUType
		ReadINIStr $0 "$PLUGINSDIR\Page_CPU.ini" "Field $DetectedCPUType" "Text"
		WriteINIStr "$PLUGINSDIR\Page_CPU.ini" "Field $DetectedCPUType" "Text" "$0 <---"
	${EndIf}

	; Make sure the current selection is valid
	${IfThen} $SelectedCPUType < 2 ${|} StrCpy $SelectedCPUType $DetectedCPUType ${|}
	${IfThen} $SelectedCPUType > 6 ${|} StrCpy $SelectedCPUType $DetectedCPUType ${|}

	; Translate
	WriteINIStr "$PLUGINSDIR\Page_CPU.ini" "Field 1" "Text" "$(MPLAYER_LANG_SELECT_CPU_TYPE)"
	WriteINIStr "$PLUGINSDIR\Page_CPU.ini" "Field 7" "Text" "$(MPLAYER_LANG_SELECT_CPU_HINT)"
	
	; Apply current selection to dialog
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
	StrCpy $SelectedCPUType 0
	
	; Read new selection from dialog
	${For} $0 2 6
		ReadINIStr $1 "$PLUGINSDIR\Page_CPU.ini" "Field $0" "State"
		${IfThen} $1 == 1 ${|} StrCpy $SelectedCPUType $0 ${|}
	${Next}
	
	${If} $SelectedCPUType < 2
	${OrIf} $SelectedCPUType > 6
		MessageBox MB_ICONSTOP "Invalid selection!"
		Abort
	${EndIf}
FunctionEnd

Function DetectCPUType
	StrCpy $DetectedCPUType 6 ;generic
	Banner::show /NOUNLOAD "$(MPLAYER_LANG_DETECTING)"
	
	; Check supported features
	${CPUFeatures.GetVendor} $0
	${CPUFeatures.CheckFeature} "MMX1"   $1
	${CPUFeatures.CheckFeature} "SSE3"   $2
	${CPUFeatures.CheckFeature} "SSSE3"  $3
	${CPUFeatures.CheckFeature} "SSE4.2" $4
	${CPUFeatures.CheckFeature} "AVX1"   $5
	${CPUFeatures.CheckFeature} "FMA4"   $6
	
	!ifdef CPU_DETECT_DEBUG
		MessageBox MB_TOPMOST `Vendor = $0`
		MessageBox MB_TOPMOST `"MMX1" = $1`
		MessageBox MB_TOPMOST `"SSE3" = $2`
		MessageBox MB_TOPMOST `"SSSE3" = $3`
		MessageBox MB_TOPMOST `"SSE4.2" = $4`
		MessageBox MB_TOPMOST `""AVX1" = $5`
		MessageBox MB_TOPMOST `"FMA4" = $6`
	!endif
	
	; Make sure we have at least MMX
	${IfThen} $1 != "yes" ${|} Return ${|}

	; Select the "best" model for Intel's
	${If} $0 == "Intel"
		${If} $2 == "yes" 
		${AndIf} $3 == "yes" 
			StrCpy $DetectedCPUType 2 ;Core2
			${IfThen} $4 == "yes" ${|} StrCpy $DetectedCPUType 3 ${|} ;Nehalem
		${EndIf}
	${EndIf}

	; Select the "best" model for AMD's
	${If} $0 == "AMD"
		${If} $2 == "yes" 
			StrCpy $DetectedCPUType 4 ;K8+SSE3
			${If} $3 == "yes" 
			${AndIf} $4 == "yes" 
			${AndIf} $5 == "yes" 
			${AndIf} $6 == "yes" 
				StrCpy $DetectedCPUType 5 ;Bulldozer
			${EndIf}
		${EndIf}
	${EndIf}
	
	Banner::destroy
FunctionEnd


;--------------------------------------------------------------------------------
; FINISHED
;--------------------------------------------------------------------------------

Function RunAppFunction
	!insertmacro DisableNextButton $R0
	${If} ${FileExists} "$INSTDIR\SMPlayer.exe"
		${StdUtils.ExecShellAsUser} $R0 "$INSTDIR\SMPlayer.exe" "open" "http://lounge-office.rautemusik.fm/"
	${Else}
		${StdUtils.ExecShellAsUser} $R0 "$INSTDIR\MPUI.exe" "open" "http://lounge-office.rautemusik.fm/"
	${EndIf}
FunctionEnd

Function ShowReadmeFunction
	!insertmacro DisableNextButton $R0
	${StdUtils.ExecShellAsUser} $R0 "$INSTDIR\Readme.html" "open" ""
FunctionEnd


### EOF ###
