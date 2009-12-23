;LameXP Installer
;Written by LoRd_MuldeR

;--------------------------------
;Defines
;--------------------------------

;Version Info
!define Version "3.15 Xmas-Edition"
!define Build_Number "80"
!define Build_Date "2009-12-24"

;UUID
!define RegPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{54dcbccb-c905-46dc-b6e6-48563d0e9e55}"

;--------------------------------
;Includes
;--------------------------------

!include "MUI2.nsh"
!include "WinVer.nsh"
!include "GetParameters.nsh"

;--------------------------------
;Pack EXE Header
;--------------------------------

!packhdr "$%TEMP%\exehead.tmp" '"D:\MPUI\Installer\UPX.exe" "$%TEMP%\exehead.tmp"'
;!packhdr "$%TEMP%\exehead.tmp" '"C:\Downloads\kkrunchy_023a2\kkrunchy_k7.exe" --best "$%TEMP%\exehead.tmp"'

;--------------------------------
;Compressor
;--------------------------------

SetCompressor /SOLID LZMA
SetCompressorDictSize 64

;--------------------------------
;Variables
;--------------------------------

Var StartMenuFolder

;--------------------------------
;General
;--------------------------------

;Name and file
Name "LameXP v${Version}"
OutFile "LameXP.${Build_Date}.exe"

;Default installation folder
InstallDir "$PROGRAMFILES\MuldeR\LameXP"
  
;Get installation folder from registry if available
InstallDirRegKey HKLM "${RegPath}" "InstallLocation"

;Request application privileges for Windows Vista
RequestExecutionLevel user

;Branding
BrandingText "LameXP, Build #${Build_Number} (${Build_Date})"

;--------------------------------
;Interface Settings
;--------------------------------

!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${RegPath}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "StartmenuFolder"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION RunApplicationFunction
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION ShowReadmeFunction
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\orange-nsis.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\orange-uninstall-nsis.bmp"
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "LameXP"

;--------------------------------
;Pages
;--------------------------------

!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_PRE ShowIfNotUpdate
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
  
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages
;--------------------------------
 
!insertmacro MUI_LANGUAGE "English" ;first language is the default language
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "SpanishInternational"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "Japanese"
!insertmacro MUI_LANGUAGE "Korean"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "Danish"
!insertmacro MUI_LANGUAGE "Swedish"
!insertmacro MUI_LANGUAGE "Norwegian"
!insertmacro MUI_LANGUAGE "NorwegianNynorsk"
!insertmacro MUI_LANGUAGE "Finnish"
!insertmacro MUI_LANGUAGE "Greek"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Portuguese"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Ukrainian"
!insertmacro MUI_LANGUAGE "Czech"
!insertmacro MUI_LANGUAGE "Slovak"
!insertmacro MUI_LANGUAGE "Croatian"
!insertmacro MUI_LANGUAGE "Bulgarian"
!insertmacro MUI_LANGUAGE "Hungarian"
!insertmacro MUI_LANGUAGE "Thai"
!insertmacro MUI_LANGUAGE "Romanian"
!insertmacro MUI_LANGUAGE "Latvian"
!insertmacro MUI_LANGUAGE "Macedonian"
!insertmacro MUI_LANGUAGE "Estonian"
!insertmacro MUI_LANGUAGE "Turkish"
!insertmacro MUI_LANGUAGE "Lithuanian"
!insertmacro MUI_LANGUAGE "Slovenian"
!insertmacro MUI_LANGUAGE "Serbian"
!insertmacro MUI_LANGUAGE "SerbianLatin"
!insertmacro MUI_LANGUAGE "Arabic"
!insertmacro MUI_LANGUAGE "Farsi"
!insertmacro MUI_LANGUAGE "Hebrew"
!insertmacro MUI_LANGUAGE "Indonesian"
!insertmacro MUI_LANGUAGE "Mongolian"
!insertmacro MUI_LANGUAGE "Luxembourgish"
!insertmacro MUI_LANGUAGE "Albanian"
!insertmacro MUI_LANGUAGE "Breton"
!insertmacro MUI_LANGUAGE "Belarusian"
!insertmacro MUI_LANGUAGE "Icelandic"
!insertmacro MUI_LANGUAGE "Malay"
!insertmacro MUI_LANGUAGE "Bosnian"
!insertmacro MUI_LANGUAGE "Kurdish"
!insertmacro MUI_LANGUAGE "Irish"
!insertmacro MUI_LANGUAGE "Uzbek"
!insertmacro MUI_LANGUAGE "Galician"
!insertmacro MUI_LANGUAGE "Afrikaans"
!insertmacro MUI_LANGUAGE "Catalan"
!insertmacro MUI_LANGUAGE "Esperanto"

;--------------------------------
;Reserve Files
;--------------------------------

ReserveFile "${NSISDIR}\Plugins\UAC.DLL"
ReserveFile "${NSISDIR}\Plugins\SYSTEM.DLL"
ReserveFile "${NSISDIR}\Plugins\SELFDEL.DLL"
ReserveFile "${NSISDIR}\Plugins\NSDIALOGS.DLL"
ReserveFile "${NSISDIR}\Plugins\STARTMENU.DLL"
ReserveFile "SendMessage.exe"
ReserveFile "LameXP.exe"

;--------------------------------
;Print Macro
;--------------------------------

!macro MyPrintProgress Text
  SetDetailsPrint textonly
  DetailPrint '${Text}, please wait...'
  SetDetailsPrint listonly
  DetailPrint '-- ${Text} --'
  Sleep 1000
!macroend

!macro MyPrintComplete Text
  SetDetailsPrint textonly
  DetailPrint '${Text}.'
  SetDetailsPrint listonly
  DetailPrint '-- ${Text} --'
  Sleep 1000
!macroend

;--------------------------------
;Kill LameXP Macro
;--------------------------------

!macro KillLameXP
  File "/oname=$PLUGINSDIR\SendMessage.exe" "SendMessage.exe"
  UAC::ExecWait '0' '"$PLUGINSDIR\SendMessage.exe" {a5756250-c439-44c0-a158-a066e2438e71}' '' ''
  Pop $0
  Pop $0
  Sleep 2500
  Delete "$PLUGINSDIR\SendMessage.exe"
!macroend

;--------------------------------
;UAC Initialization
;--------------------------------

!macro INIT_UAC prefix
  !define ID ${__LINE__}
  
UAC_Elevate_${ID}:
  UAC::RunElevated 
  StrCmp 1223 $0 UAC_ElevationAborted_${ID} ; UAC dialog aborted by user?
  StrCmp 0 $0 0 UAC_Err_${ID} ; Error?
  StrCmp 1 $1 0 UAC_Success_${ID} ; Are we the real deal or just the wrapper?
  Quit

UAC_Err_${ID}:
  MessageBox MB_ICONEXCLAMATION|MB_TOPMOST "Unable to elevate ${prefix}installer executaion level (Error #$0)."

UAC_ElevationAborted_${ID}:
  MessageBox MB_ICONEXCLAMATION|MB_TOPMOST|MB_OKCANCEL "This ${prefix}installer requires administrator access rights, please try again!" IDOK UAC_Elevate_${ID}
  Abort

UAC_Success_${ID}:
  StrCmp 1 $3 +4 ;Admin?
  StrCmp 3 $1 0 UAC_ElevationAborted_${ID} ;Try again?
  MessageBox MB_ICONEXCLAMATION|MB_TOPMOST|MB_OKCANCEL "This ${prefix}installer requires administrator access rights, please try again!" IDOK UAC_Elevate_${ID}
  Abort

  !undef ID
!macroend

;--------------------------------
;Check for supported OS
;--------------------------------

!macro TEST_OS_VERSION
  !ifndef TEST_OS_VERSION_PLEASE_UPDATE
    !define TEST_OS_VERSION_PLEASE_UPDATE "Please update to a newer version of the Windows operating system!"
  !endif
  
  ${If} ${IsNT}
    Goto TestOsVersion_WinNT
  ${Else}
    MessageBox MB_TOPMOST|MB_ICONSTOP "Sorry, Windows 95, Windows 98 and Windows ME are not supported by this application.$\n${TEST_OS_VERSION_PLEASE_UPDATE}"
    Abort
  ${EndIf}
  
  TestOsVersion_WinNT:
  ${If} ${AtMostWinNT4}
    MessageBox MB_TOPMOST|MB_ICONSTOP "Sorry, Windows NT 4.0 (and older) is not supported by this application.$\n${TEST_OS_VERSION_PLEASE_UPDATE}"
    Abort
  ${EndIf}
!macroend

;--------------------------------
;Installer Sections
;--------------------------------

Section
  InitPluginsDir
  SetOutPath "$INSTDIR"
  
  ;Kill Running instances
  !insertmacro MyPrintProgress "Killing running instances"
  !insertmacro KillLameXP

  ;Extract files
  !insertmacro MyPrintProgress "Installing new files"
  File "LameXP.exe"
  File "LameXP.exe.sig"
  File "Changelog.htm"
  File "License.txt"
  File "License.txt"
  File "translations\Contributors.txt"  
  File "translations\Howto.html"  
  
  ;Create uninstaller
  !insertmacro MyPrintProgress "Creating uninstaller"
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ;Create shortcuts
  !insertmacro MyPrintProgress "Creating shortcuts"
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    Delete "$SMPROGRAMS\$StartMenuFolder\*.lnk"
    Delete "$SMPROGRAMS\$StartMenuFolder\*.pif"
    Delete "$SMPROGRAMS\$StartMenuFolder\*.url"
    
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\LameXP.lnk"                 "$INSTDIR\LameXP.exe"    "" "$INSTDIR\LameXP.exe"    0
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Changelog.lnk"              "$INSTDIR\Changelog.htm" "" "$INSTDIR\LameXP.exe"    2
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Howto Translate LameXP.lnk" "$INSTDIR\Howto.html"    "" "$INSTDIR\LameXP.exe"    2
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"              "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
    
    WriteINIStr "$SMPROGRAMS\$StartMenuFolder\Web Site.url" "DEFAULT"          "BASEURL"   "http://mulder.dummwiedeutsch.de/"
    WriteINIStr "$SMPROGRAMS\$StartMenuFolder\Web Site.url" "InternetShortcut" "ORIGURL"   "http://mulder.dummwiedeutsch.de/"
    WriteINIStr "$SMPROGRAMS\$StartMenuFolder\Web Site.url" "InternetShortcut" "URL"       "http://mulder.dummwiedeutsch.de/home/?page=home"
    WriteINIStr "$SMPROGRAMS\$StartMenuFolder\Web Site.url" "InternetShortcut" "IconFile"  "$INSTDIR\LameXP.exe"
    WriteINIStr "$SMPROGRAMS\$StartMenuFolder\Web Site.url" "InternetShortcut" "IconIndex" "1"
  !insertmacro MUI_STARTMENU_WRITE_END

  ;Store installation folder & uinstaller
  !insertmacro MyPrintProgress "Updating the regsitry"
  WriteRegStr HKLM "${RegPath}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${RegPath}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "${RegPath}" "DisplayName" "LameXP"
  WriteRegStr HKLM "${RegPath}" "DisplayVersion" "${Version}"
  WriteRegStr HKLM "${RegPath}" "DisplayIcon" "$INSTDIR\LameXP.exe"
  WriteRegStr HKLM "${RegPath}" "Publisher" "LoRd_MuldeR <mulder2@gmx.de>"
  WriteRegStr HKLM "${RegPath}" "URLInfoAbout" "http://mulder.dummwiedeutsch.de/home/?page=projects#lamexp"
  WriteRegStr HKLM "${RegPath}" "URLUpdateInfo" "http://mulder.dummwiedeutsch.de/home/?page=projects#lamexp"
  WriteRegStr HKLM "${RegPath}" "Readme" "$INSTDIR\Changelog.htm"
  WriteRegDWORD HKLM "${RegPath}" "NoModify" 1
  WriteRegDWORD HKLM "${RegPath}" "NoRepair" 1
  
  ;Reset license
  IntFmt $0 "LameXP_%08X" ${Build_Number}
  DeleteINIStr "$APPDATA\MuldeR\LameXP\Settings.ini" "$0" "GNULicenseAgreed"
  
  ;Complete
  !insertmacro MyPrintComplete "Setup completed"
SectionEnd

;--------------------------------
;Initialization
;--------------------------------

Function .onInit
  !insertmacro TEST_OS_VERSION

  ; If running in update mode, self-delete
  !insertmacro GetCommandlineParameter "Update" "error" $0
  StrCmp $0 "error" +2
  SelfDel::del

  !insertmacro INIT_UAC ""
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function un.onInit
  !insertmacro INIT_UAC "un"
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

;--------------------------------
;Finalization
;--------------------------------

Function .onInstFailed
  UAC::Unload ;Must call unload!
FunctionEnd
 
Function .onInstSuccess
  UAC::Unload ;Must call unload!
FunctionEnd

Function un.onUninstFailed
  UAC::Unload ;Must call unload!
FunctionEnd

Function un.onUninstSuccess
  UAC::Unload ;Must call unload!
FunctionEnd

;--------------------------------
;Callbacks
;--------------------------------

Function ShowReadmeFunction
  UAC::ShellExec '' '' '"$INSTDIR\Changelog.htm"' '' ''
  UAC::ShellExec '' '' '"$INSTDIR\Howto.html"' '' ''
FunctionEnd

Function RunApplicationFunction
  UAC::Exec '' '"$INSTDIR\LameXP.exe"' '' ''
FunctionEnd

Function ShowIfNotUpdate
  !insertmacro GetCommandlineParameter "Update" "error" $0
  StrCmp $0 "error" DoNotSkipPage
  Abort
  DoNotSkipPage:
FunctionEnd

;--------------------------------
;Uninstaller Section
;--------------------------------

Section "Uninstall"
  InitPluginsDir
  SetOutPath "$INSTDIR"

  ;Kill running instances
  !insertmacro MyPrintProgress "Killing running instances"
  !insertmacro KillLameXP

  ;Remove file extensions
  !insertmacro MyPrintProgress "Removing file association"
  IfFileExists "$INSTDIR\LameXP.exe" 0 TryDelete
  ExecWait '"$INSTDIR\LameXP.exe" --uninstall'
  Sleep 2500
  
TryDelete:

  ;Delete executable
  !insertmacro MyPrintProgress "Uninstalling files"
  Delete "$INSTDIR\LameXP.exe"
  IfFileExists "$INSTDIR\LameXP.exe" 0 DeletedExeSuccessfully
  MessageBox MB_TOPMOST|MB_ICONEXCLAMATION|MB_RETRYCANCEL "Failed to delete program file. Is LameXP still running?" IDCANCEL DeletedExeSuccessfully
  Sleep 2500
  Goto TryDelete
  
DeletedExeSuccessfully:

  ;Uninstall files
  Delete /REBOOTOK "$INSTDIR\LameXP.exe"
  Delete /REBOOTOK "$INSTDIR\Changelog.htm"
  Delete /REBOOTOK "$INSTDIR\License.txt"
  Delete /REBOOTOK "$INSTDIR\Uninstall.exe"

  ;Delete personal settings
  MessageBox MB_TOPMOST|MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Do you want me to delete your personal LameXP settings too?" IDNO NoDeletePersonal
  Delete /REBOOTOK "$APPDATA\MuldeR\LameXP\Settings.ini"
  Delete /REBOOTOK "$APPDATA\MuldeR\LameXP\Debug.log"
  RMDir "$APPDATA\MuldeR\LameXP"
  RMDir "$APPDATA\MuldeR"

NoDeletePersonal:
  
  ;Remove install directory
  !insertmacro MyPrintProgress "Removing directory"
  RMDir "$INSTDIR"
  
  ;Remove shortcuts
  !insertmacro MyPrintProgress "Removing shortcuts"
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  IfFileExists "$SMPROGRAMS\$StartMenuFolder\*.*" 0 NoStartmenu
  Delete /REBOOTOK "$SMPROGRAMS\$StartMenuFolder\LameXP.lnk"
  Delete /REBOOTOK "$SMPROGRAMS\$StartMenuFolder\Changelog.lnk"
  Delete /REBOOTOK "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"

NoStartmenu:

  ;Clean registry
  !insertmacro MyPrintProgress "Cleaning the registry"
  DeleteRegKey HKLM "${RegPath}"
  
  ;Complete
  !insertmacro MyPrintComplete "Uninstall completed"
SectionEnd

;--------------------------------
;EOF
;--------------------------------
