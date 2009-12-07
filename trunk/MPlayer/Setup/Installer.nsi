; ////////////////////////////////////////////////////////////////////////////////////////////////
; // MPlayer for Windows - Install Script
; // Written by MuldeR <MuldeR2@GMX.de> - http://mulder.at.gg/
; // Developed and tested with NSIS v2.46, UMUI v1.00b2
; ////////////////////////////////////////////////////////////////////////////////////////////////

!ifndef Compile_Date | Build_Number | Version_MPlayer | Version_MPUI | Version_SMPlayer | Version_Codecs | Version_NSIS | Path_Out
  !echo "$\r$\n-----------------------------------------------------------------------$\r$\nWARNING: Version information not defined (or incomplete)$\r$\nYou must define: Compile_Date, Build_Number, Version_MPlayer, Version_MPUI, Version_SMPlayer, Version_Codecs, Version_NSIS and Path_Out$\r$\n-----------------------------------------------------------------------$\r$\n$\r$\n"
  !error "Aborting!"
!endif

!ifndef Path_Out | Path_Builds
  !echo "$\r$\n-----------------------------------------------------------------------$\r$\nWARNING: Directories not defined (or incomplete)$\r$\nYou must define: Path_Out and Path_Builds$\r$\n-----------------------------------------------------------------------$\r$\n$\r$\n"
  !error "Aborting!"
!endif

!echo "$\r$\n-----------------------------------------------------------------------$\r$\nCompile_Date: ${Compile_Date}$\r$\nBuild_Number: ${Build_Number}$\r$\n$\r$\nVersion_MPlayer: ${Version_MPlayer}$\r$\nVersion_MPUI: ${Version_MPUI}$\r$\nVersion_SMPlayer: ${Version_SMPlayer}$\r$\nVersion_Codecs: ${Version_Codecs}$\r$\nVersion_NSIS: ${Version_NSIS}$\r$\n$\r$\nPath_Out: ${Path_Out}$\r$\nPath_Builds: ${Path_Builds}$\r$\n-----------------------------------------------------------------------$\r$\n$\r$\n"


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; Installer attributes
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Compressor
SetCompressor /SOLID LZMA
SetCompressorDictSize 144

; UAC Support
RequestExecutionLevel user

; UltraModernUI
!include UMUI.nsh

; More Includes
!include installer\GetParameters.nsh

; Pack EXE header
; <FIXME>
;   !packhdr "exehead.tmp" '"installer\upx.exe" exehead.tmp'
;   !packhdr "exehead.tmp" 'upack.exe exehead.tmp -rai -red'
; </FIXME>

; UUID
!define MPlayer_RegPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DB9E4EAB-2717-499F-8D56-4CC8A644AB60}"

; Variables
Var STARTMENU_FOLDER
Var CPU_TYPE
Var CPU_NAME
Var CLOSE_SMPLAYER
Var SETUP_COMPLETED

; Name/Branding
Name "$(MPlayerForWindows) (${Compile_Date})"
BrandingText "$(CompiledAt) ${__DATE__} ${__TIME__} (Build #${Build_Number})"

!ifdef FullPackage
  !define OutFileName "MPUI.${Compile_Date}.Full-Package.exe"
!else
  !define OutFileName "MPUI.${Compile_Date}.Light-Package.exe"
!endif

; Outfile
OutFile "${Path_Out}\${OutFileName}"

; Default Install Dir
InstallDir "$PROGRAMFILES\$(MPlayerForWindows)"
InstallDirRegKey HKLM "${MPlayer_RegPath}" "InstallLocation"

; Reserve Files
ReserveFile "${NSISDIR}\Plugins\UAC.DLL"
ReserveFile "${NSISDIR}\Plugins\System.dll"
ReserveFile "${NSISDIR}\Plugins\NewAdvSplash.dll"
ReserveFile "${NSISDIR}\Plugins\SelfDel.dll"
ReserveFile "${NSISDIR}\Plugins\Banner.dll"
ReserveFile "${NSISDIR}\Plugins\InstallOptionsEx.dll"
ReserveFile "${NSISDIR}\Plugins\UserInfo.dll"
ReserveFile "${NSISDIR}\Plugins\SkinnedControls.dll"
ReserveFile "${NSISDIR}\Plugins\NSISArray.dll"
ReserveFile "${NSISDIR}\Plugins\nsExec.dll"
ReserveFile "${NSISDIR}\Plugins\nsisStartMenu.dll"
ReserveFile "${NSISDIR}\Plugins\Timeout.dll"
ReserveFile "${NSISDIR}\Plugins\AccessControl.dll"
ReserveFile "installer\page_cpu.ini"
ReserveFile "installer\page_tweak.ini"
ReserveFile "installer\splash.gif"
ReserveFile "installer\check.exe"
ReserveFile "installer\cpuinfo.exe"
ReserveFile "installer\upx.exe"

; ---------------------------------------
; Interface Settings
; ---------------------------------------

!define UMUI_SKIN "gray"
!define UMUI_BGSKIN "gray"
!define UMUI_DISABLED_BUTTON_TEXT_COLOR 707070
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install-nsis.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall-nsis.ico"
!define UMUI_LEFTIMAGE_BMP "installer\left_gray.256.bmp"
!define UMUI_HEADERBGIMAGE_BMP "installer\header_gray.256.bmp"
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING
!define UMUI_USE_ALTERNATE_PAGE
!define UMUI_USE_UNALTERNATE_PAGE
!define UMUI_USE_INSTALLOPTIONSEX

;!define UMUI_WELCOMEFINISHABORT_TITLE_FONTSIZE 15
;!define UMUI_CUSTOMFUNCTION_GUIINIT GUI_InitFunction
;!define UMUI_CUSTOMFUNCTION_GUIEND GUI_EndFunction

; <VistaButtonsWorkaround>
; !define UMUI_NO_BUTTONIMAGE
; </VistaButtonsWorkaround>

; ---------------------------------------
; Page Settings
; ---------------------------------------

!define MUI_WELCOMEPAGE_TITLE_3LINES
!define UMUI_PARAMS_REGISTRY_ROOT "HKLM"
!define UMUI_PARAMS_REGISTRY_KEY "${MPlayer_RegPath}"
!define UMUI_LANGUAGE_REGISTRY_VALUENAME "Language"
!define UMUI_LANGUAGE_ALWAYSSHOW
!define UMUI_COMPONENTSPAGE_INSTTYPE_REGISTRY_VALUENAME "insttype"
!define UMUI_COMPONENTSPAGE_REGISTRY_VALUENAME "components"
!define UMUI_SETUPTYPEPAGE_COMPLETE "$(UMUI_TEXT_SETUPTYPE_COMPLETE_TITLE)"
!define UMUI_SETUPTYPEPAGE_COMPLETEBITMAP "installer\install_complete.bmp"
!define UMUI_SETUPTYPEPAGE_CUSTOMBITMAP "installer\install_custom.bmp"
!ifdef FullPackage
  !define UMUI_SETUPTYPEPAGE_COMPLETE_TEXT "$(InstallTypeText_Complete)"
  !define UMUI_SETUPTYPEPAGE_MINIMAL "$(UMUI_TEXT_SETUPTYPE_MINIMAL_TITLE)"
  !define UMUI_SETUPTYPEPAGE_MINIMALBITMAP "installer\install_complete.bmp"
  !define UMUI_SETUPTYPEPAGE_MINIMAL_TEXT "$(InstallTypeText_Minimal)"
!else
  !define UMUI_SETUPTYPEPAGE_COMPLETE_TEXT "$(InstallTypeText_Minimal)"
!endif
!define UMUI_SETUPTYPEPAGE_DEFAULTCHOICE ${UMUI_COMPLETE}
!define UMUI_ALTERNATIVESTARTMENUPAGE_SETSHELLVARCONTEXT
!define UMUI_ALTERNATIVESTARTMENUPAGE_USE_TREEVIEW
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "$(MPlayerForWindows)"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${MPlayer_RegPath}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "StartmenuFolder"
!define UMUI_CONFIRMPAGE_TEXTBOX ConfirmBox
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION RunOnFinish
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\readme.html"
!define MUI_FINISHPAGE_LINK "http://mulder.at.gg/"
!define MUI_FINISHPAGE_LINK_LOCATION "http://mulder.at.gg/"

; ---------------------------------------
; Installer Pages
; ---------------------------------------

!insertmacro UMUI_PAGE_MULTILANGUAGE
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_SHOW InitialSMPlayerClose
!insertmacro MUI_PAGE_LICENSE "installer\License.txt"
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "installer\GPL.txt"
!insertmacro UMUI_PAGE_SETUPTYPE
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_PRE CheckIfUpdate
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_PAGE_CUSTOMFUNCTION_PRE CheckIfUpdate
!insertmacro UMUI_PAGE_ALTERNATIVESTARTMENU startmenupage $STARTMENU_FOLDER
Page custom SetCustom_CPU ValidateCustom_CPU ""
Page custom SetCustom_Tweaks ValidateCustom_Tweaks ""
!insertmacro UMUI_PAGE_CONFIRM
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro UMUI_PAGE_ABORT

; ---------------------------------------
; Un-Installer Pages
; ---------------------------------------

; Page Settings
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_TITLE_3LINES

; Uninstaller Pages
!insertmacro UMUI_UNPAGE_MULTILANGUAGE
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro UMUI_UNPAGE_ABORT

; ---------------------------------------
; Languages
; ---------------------------------------

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "German"
;!insertmacro MUI_LANGUAGE "French"
;!insertmacro MUI_LANGUAGE "Spanish"

; ---------------------------------------
; Misc
; ---------------------------------------

; Install Types
InstType "$(UMUI_TEXT_SETUPTYPE_COMPLETE_TITLE)"
InstType "$(UMUI_TEXT_SETUPTYPE_MINIMAL_TITLE)"

; More Installer Attributes
CheckBitmap "${NSISDIR}\Contrib\Graphics\Checks\colorful.bmp"


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; // Translation
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

LangString MPlayerForWindows ${LANG_ENGLISH} "MPlayer for Windows"
LangString MPlayerForWindows ${LANG_GERMAN} "MPlayer für Windows"

LangString CompiledAt ${LANG_ENGLISH} "Compiled:"
LangString CompiledAt ${LANG_GERMAN} "Kompiliert:"

LangString PackingEXE ${LANG_ENGLISH} "Packing File:"
LangString PackingEXE ${LANG_GERMAN} "Packe Datei:"

LangString DetectingCPUType ${LANG_ENGLISH} "Detecting your CPU Type, please wait..."
LangString DetectingCPUType ${LANG_GERMAN} "Ihr CPU Typ wird ermittelt, bitte warten..."

LangString CPUDetected ${LANG_ENGLISH} "recommended"
LangString CPUDetected ${LANG_GERMAN} "empfohlen"

LangString InstallFailed ${LANG_ENGLISH} "Setup has failed, MPlayer for Windows not installed !!!"
LangString InstallFailed ${LANG_GERMAN} "Setup ist fehlgeschlagen, MPlayer für Windows wurde nicht installiert !!!"

LangString AskCheckUpdate ${LANG_ENGLISH} "Do you want to check for MPlayer for Windows updates online now?"
LangString AskCheckUpdate ${LANG_GERMAN} "Möchten Sie jetzt online nach MPlayer für Windows Updates suchen?"

; -----------------

LangString InstallTypeText_Complete ${LANG_ENGLISH} "MPlayer with two front-ends (SMPlayer and MPUI) plus Binary Codecs will be installed. Recommended for most users."
LangString InstallTypeText_Complete ${LANG_GERMAN} "MPlayer mit zwei Oberflächen (SMPlayer und MPUI) sowie binäre Codecs werden installiert. Für die meisten Benutzer empfohlen."

LangString InstallTypeText_Minimal ${LANG_ENGLISH} "Only MPlayer with MPUI front-end will be installed."
LangString InstallTypeText_Minimal ${LANG_GERMAN} "Nur MPlayer mit MPUI Oberfläche wird installiert."

; -----------------

LangString ShortCut_MPlayerHomepage ${LANG_ENGLISH} "Official MPlayer Homepage"
LangString ShortCut_MPlayerHomepage ${LANG_GERMAN} "Offizielle MPlayer Homepage"

LangString ShortCut_MPlayerManual ${LANG_ENGLISH} "MPlayer Manual (Commandline Options)"
LangString ShortCut_MPlayerManual ${LANG_GERMAN} "MPlayer Anleitung (Kommandozeilen Options)"

LangString ShortCut_MPlayerWin32 ${LANG_ENGLISH} "MPlayer on Win32"
LangString ShortCut_MPlayerWin32 ${LANG_GERMAN} "MPlayer für Win32"

LangString ShortCut_CelticDruid ${LANG_ENGLISH} "Celtic Druid's Homepage"
LangString ShortCut_CelticDruid ${LANG_GERMAN} "Homepage von Celtic Druid"

LangString ShortCut_SMPlayerHomepage ${LANG_ENGLISH} "SMPlayer Homepage"
LangString ShortCut_SMPlayerHomepage ${LANG_GERMAN} "SMPlayer Homepage"

LangString ShortCut_SMPlayerHelp ${LANG_ENGLISH} "SMPlayer Help (FAQ)"
LangString ShortCut_SMPlayerHelp ${LANG_GERMAN} "SMPlayer Hilfe (FAQ)"

LangString ShortCut_MPUIHomepage ${LANG_ENGLISH} "MPUI Homepage"
LangString ShortCut_MPUIHomepage ${LANG_GERMAN} "MPUI Homepage"

LangString ShortCut_GNULicense ${LANG_ENGLISH} "GNU General Public License"
LangString ShortCut_GNULicense ${LANG_GERMAN} "GNU General Public License"

LangString ShortCut_CheckUpdates ${LANG_ENGLISH} "Check for Updates"
LangString ShortCut_CheckUpdates ${LANG_GERMAN} "Automatisches Update"

LangString ShortCut_Asscos ${LANG_ENGLISH} "Set File Associations"
LangString ShortCut_Asscos ${LANG_GERMAN} "Datei-Typ Verknüpfungen erstellen"

LangString ShortCut_Uninstall ${LANG_ENGLISH} "Uninstall"
LangString ShortCut_Uninstall ${LANG_GERMAN} "Deinstallation"

LangString ShortCut_ResetSMPlayer ${LANG_ENGLISH} "Reset MPlayer configuration"
LangString ShortCut_ResetSMPlayer ${LANG_GERMAN} "MPlayer Konfiguration zurücksetzen"

LangString ShortCut_MPC ${LANG_ENGLISH} "MPC Interface"
LangString ShortCut_MPC ${LANG_GERMAN} "MPC Oberfläche"

LangString ShortCut_Compact ${LANG_ENGLISH} "Compact Interface"
LangString ShortCut_Compact ${LANG_GERMAN} "Kompakte Oberfläche"

; -----------------

LangString AlreadyRunning ${LANG_ENGLISH} "The setup program is already running. Please use the running instance!"
LangString AlreadyRunning ${LANG_GERMAN}  "Das Setp-Programm wird bereits ausgeführt. Bitte benutzen Sie die laufende Instanz!"

LangString NotAllowedToInstall ${LANG_ENGLISH} "You don't have the required access rights to (un)install MPlayer for Windows.$\nPlease log in with an admin account or ask your administartor for help!"
LangString NotAllowedToInstall ${LANG_GERMAN} "Sie haben nicht die benötigten Rechte, um MPlayer für Windows zu (de)installieren.$\nBitte verwenden Sie ein Admin Benutzerkonto oder bitten Sie Ihren Administartor um Hilfe!"

LangString FileExtractError ${LANG_ENGLISH} "Setup failed to extract a required file, please try again!"
LangString FileExtractError ${LANG_GERMAN} "Setup konnte eine benötigte Datei nicht extrahieren, bitte noch einmal versuchen!"

LangString ExecBlockedAbort ${LANG_ENGLISH} "The installer is unable to launch external programs, which means the installer cannot operate properly. This usually indicates that a buggy antivirus software is blocking the installer. Please report the problem to your antivirus company, we cannot do anything to fix this!"
LangString ExecBlockedAbort ${LANG_GERMAN} "Das Installations-Programm kann keine externen Programme aufrufen, d.h. die Installation kann nicht durchgeführt werden. Dieses Problem wird höchstwahrscheinlich von einer fehlerhfaten Antiviren Software verursacht, die den Installer blockiert. Bitte melden Sie das Problem dem Hersteller der Antiviren Software, da wir nichts tun können, um das Problem zu beheben!"

LangString CPUTypeCaption ${LANG_ENGLISH} "CPU Type"
LangString CPUTypeCaption ${LANG_GERMAN} "CPU Typ"

LangString CPUTypeText ${LANG_ENGLISH} "Choose the CPU type that best suits your computer's hardware."
LangString CPUTypeText ${LANG_GERMAN} "Wählen Sie den CPU Typ, der am besten zu Ihrer Hardware passt."

LangString CPUTypePage ${LANG_ENGLISH} "Please select a CPU type:"
LangString CPUTypePage ${LANG_GERMAN} "Bitte CPU Typ auswälen:"

LangString CPUTypeInfo ${LANG_ENGLISH} "Note: The 'Runtime CPU Detection' will work with all CPU types, but performance might be restricted. Choosing the CPU type that best suits your computer's hardware will ensure optimal performance. Unfortunately choosing an incompatible CPU type might lead to crash!"
LangString CPUTypeInfo ${LANG_GERMAN} "Achtung: Die 'Runtime CPU Detection' funktioniert mit allen CPU Typen, kann jedoch die Leistung einschränken. Wählen Sie den CPU Typ, der am besten zur Hardware Ihres Computers passt, um die optimale Leistung zu erhalten. Das Auswählen eines inkompatiblen CPU Typen kann zu Abstürzen führen!"

LangString CPUName ${LANG_ENGLISH} "Detected CPU:"
LangString CPUName ${LANG_GERMAN} "Ermittelte CPU:"

LangString CPUExtensions ${LANG_ENGLISH} "Extensions:"
LangString CPUExtensions ${LANG_GERMAN} "Erweiterungen:"

LangString CPUNotSelected ${LANG_ENGLISH} "Sorry, you must choose your CPU type first!"
LangString CPUNotSelected ${LANG_GERMAN} "Bitte wählen Sie zunächst den CPU Typ aus!"

LangString CPUTypeConfirm ${LANG_ENGLISH} "Selected CPU type:"
LangString CPUTypeConfirm ${LANG_GERMAN} "Ausgewählter CPU Typ:"

LangString TweaksCaption ${LANG_ENGLISH} "MPlayer Tweaks"
LangString TweaksCaption ${LANG_GERMAN} "MPlayer Einstellungen"

LangString TweaksText ${LANG_ENGLISH} "Choose the initial MPlayer configuration that best suits your needs."
LangString TweaksText ${LANG_GERMAN} "Wählen Sie die MPlayer Einstellungen, die Ihren Bedürfnissen am besten gerecht werden."

LangString TweaksPage ${LANG_ENGLISH} "Configure initial MPUI/SMPlayer settings:"
LangString TweaksPage ${LANG_GERMAN} "Initiale MPUI/SMPlayer Einstellungen vornehmen:"

LangString TweaksConfirm ${LANG_ENGLISH} "Selected Tweaks:"
LangString TweaksConfirm ${LANG_GERMAN} "Ausgewählte Einstellungen:"

LangString TweaksCheck_DefaultLang ${LANG_ENGLISH} "Set default language to English"
LangString TweaksCheck_DefaultLang ${LANG_GERMAN} "Standardsprache auf DEUTSCH setzen"

LangString TweaksCheck_SoftwareScale ${LANG_ENGLISH} "Set software scaler to 'Lanczos' method (High Quality)"
LangString TweaksCheck_SoftwareScale ${LANG_GERMAN} "Benutze 'Lanczos' Software Skalierung (Hohe Qualität)"

LangString TweaksCheck_Normalize ${LANG_ENGLISH} "Enable volume normalization"
LangString TweaksCheck_Normalize ${LANG_GERMAN} "Lautstärke Normalisierung aktivieren"

LangString TweaksCheck_Passthrough ${LANG_ENGLISH} "Enable S/PDIF pass-through for AC3/DTS audio"
LangString TweaksCheck_Passthrough ${LANG_GERMAN} "S/PDIF Digital-Ausgabe für AC3/DTS Audio aktivieren"

LangString TweaksCheck_OpenGL ${LANG_ENGLISH} "Use OpenGL renderer instead of Overlay (better, but requires OpenGL 2.0)"
LangString TweaksCheck_OpenGL ${LANG_GERMAN} "OpenGL Renderer anstatt Overlay benutzen (besser, aber benötigt OpenGL 2.0)"

LangString TweaksCheck_SkipDeblock ${LANG_ENGLISH} "Skip H.264 inloop deblocking (faster, but *NOT* recommended!)"
LangString TweaksCheck_SkipDeblock ${LANG_GERMAN} "H.264 Deblock-Filter überspringen (schneller, aber *NICHT* empfohlen!)"

LangString TweaksCheck_DVDMenu ${LANG_ENGLISH} "Enable DVD Menu support (EXPERIMENTAL)"
LangString TweaksCheck_DVDMenu ${LANG_GERMAN} "DVD Menu Unterstützung aktivieren (EXPERIMENTELL)"

LangString TweaksLanguage_MPUI ${LANG_ENGLISH} "en"
LangString TweaksLanguage_MPUI ${LANG_GERMAN} "de"

LangString TweaksLanguage_SMPlayer ${LANG_ENGLISH} "en_US"
LangString TweaksLanguage_SMPlayer ${LANG_GERMAN} "de"

; -----------------

LangString PleaseWait ${LANG_ENGLISH} "please be patient..."
LangString PleaseWait ${LANG_GERMAN}  "bitte warten..."

LangString KillApps_Failed ${LANG_ENGLISH} "Setup faild to delete the following executable file from MPlayer directory:"
LangString KillApps_Failed ${LANG_GERMAN}  "Setup konnte die folgende Programm-Datei nich aus dem MPlayer Ordner löschen:"

LangString KillApps_Running ${LANG_ENGLISH} "Maybe MPlayer is still running or you don't have the required access rights!"
LangString KillApps_Running ${LANG_GERMAN}  "Möglicherweise wird MPlayer noch ausgeführt oder sie haben nich die notwendigen Rechte!"

LangString KillApps_Detail ${LANG_ENGLISH} "Setup faild to delete the MPlayer executable file!"
LangString KillApps_Detail ${LANG_GERMAN}  "Setup konnte die MPlayer Programm-Datei nicht löschen!"

LangString PackFile_Failed ${LANG_ENGLISH} "Setup faild to pack this file:"
LangString PackFile_Failed ${LANG_GERMAN} "Setup konnte die Datei nicht packen:"

LangString TerminateSMPlayerInstances ${LANG_ENGLISH} "Closing all instances of SMPlayer..."
LangString TerminateSMPlayerInstances ${LANG_GERMAN} "Schließe alle Instanzen von SMPlayer..."

LangString Section_Remove ${LANG_ENGLISH} "Removing installed MPlayer version"
LangString Section_Remove ${LANG_GERMAN} "Entferne installierte MPlayer Version"

LangString Section_Clean ${LANG_ENGLISH} "Cleaning-up obsolete files"
LangString Section_Clean ${LANG_GERMAN} "Entferne veraltete Dateien"

LangString Section_MPlayer ${LANG_ENGLISH} "Installing MPlayer"
LangString Section_MPlayer ${LANG_GERMAN} "Installiere MPlayer"

LangString Section_MPUI ${LANG_ENGLISH} "Installing MPUI"
LangString Section_MPUI ${LANG_GERMAN} "Installiere MPUI"

LangString Section_SMPlayer ${LANG_ENGLISH} "Installing SMPlayer"
LangString Section_SMPlayer ${LANG_GERMAN} "Installiere SMPlayer"

LangString Section_Codecs_Caption ${LANG_ENGLISH} "MPlayer Binary Codecs"
LangString Section_Codecs_Caption ${LANG_GERMAN} "Binäre Codecs für MPlayer"

LangString Section_Codecs_Status ${LANG_ENGLISH} "Installing MPlayer Binary Codecs"
LangString Section_Codecs_Status ${LANG_GERMAN} "Installiere binäre Codecs für MPlayer"

LangString Section_AutoUpdate ${LANG_ENGLISH} "Creating Auto Updater"
LangString Section_AutoUpdate ${LANG_GERMAN} "Programm für automatische Updates wird erstellt"

LangString Section_Uninstaller ${LANG_ENGLISH} "Creating Uninstaller"
LangString Section_Uninstaller ${LANG_GERMAN} "Deinstallations-Programm wird erstellt"

LangString Section_Optimize_Caption ${LANG_ENGLISH} "Optimize executable files (UPX)"
LangString Section_Optimize_Caption ${LANG_GERMAN} "Programmdateien optimieren (UPX)"

LangString Section_Optimize ${LANG_ENGLISH} "Optimizing executable files"
LangString Section_Optimize ${LANG_GERMAN} "Programm-Dateien werden optimiert"

LangString Section_Reset_Caption ${LANG_ENGLISH} "Reset all MPlayer, SMPlayer and MPUI options"
LangString Section_Reset_Caption ${LANG_GERMAN} "MPlayer, SMPlayer und MPUI zurücksetzen"

LangString Section_Reset_Status ${LANG_ENGLISH} "Resetting MPlayer/SMPlayer/MPUI options"
LangString Section_Reset_Status ${LANG_GERMAN} "MPlayer/SMPlayer/MPUI Optionen werden zurück gesetzt"

LangString Section_Tweaks ${LANG_ENGLISH} "Setting up initial configuration"
LangString Section_Tweaks ${LANG_GERMAN} "Initiale Konfiguration wird vorgenommen"

LangString Section_Assocs_Caption ${LANG_ENGLISH} "Set File Associations"
LangString Section_Assocs_Caption ${LANG_GERMAN} "Datei-Typ Zuordnungen setzen"

LangString Section_UpdateReminder_Caption ${LANG_ENGLISH} "Schedule automatic updates"
LangString Section_UpdateReminder_Caption ${LANG_GERMAN} "Automatische Updates planen"

LangString Section_Assocs_Status ${LANG_ENGLISH} "Setting File Associations"
LangString Section_Assocs_Status ${LANG_GERMAN} "Datei-Typ Verknüpfungen werden erstellt"

LangString Section_Shortcuts_Caption ${LANG_ENGLISH} "Create Shortcuts"
LangString Section_Shortcuts_Caption ${LANG_GERMAN} "Verknüpfungen erstellen"

LangString Section_Shortcuts_Staus ${LANG_ENGLISH} "Creating Shortcuts"
LangString Section_Shortcuts_Staus ${LANG_GERMAN} "Verknüpfungen werden erstellt"

LangString Section_Registry ${LANG_ENGLISH} "Updating the Registry"
LangString Section_Registry ${LANG_GERMAN} "Registrierung wird aktualisiert"

LangString Section_Done ${LANG_ENGLISH} "Setup completed successfully :-D"
LangString Section_Done ${LANG_GERMAN} "Setup erfolgreich abgeschlossen :-D"

; -----------------

LangString UnSection_Uninstall ${LANG_ENGLISH} "Uninstalling MPlayer for Windows"
LangString UnSection_Uninstall ${LANG_GERMAN} "MPlayer für Windows wird deinstalliert"

LangString UnSection_RestoreAsscos ${LANG_ENGLISH} "Restoring file associations"
LangString UnSection_RestoreAsscos ${LANG_GERMAN} "Datei-Typ Verknüpfungen werden wiederhergestellt"

LangString UnSection_RemoveShortcuts ${LANG_ENGLISH} "Shortcuts are being removed"
LangString UnSection_RemoveShortcuts ${LANG_GERMAN} "Verknüpfungen werden entfernt"

LangString UnSection_RemoveFiles ${LANG_ENGLISH} "Files are being uninstalled"
LangString UnSection_RemoveFiles ${LANG_GERMAN} "Dateien werden entfernt"

LangString UnSection_Registry ${LANG_ENGLISH} "Cleaning-up the registry"
LangString UnSection_Registry ${LANG_GERMAN} "Registrierung wird aufgeräumt"

LangString UnSection_Done ${LANG_ENGLISH} "MPlayer for Windows has been removed successfully."
LangString UnSection_Done ${LANG_GERMAN} "MPlayer für Windows wurde erfolgreich entfernt."

; -----------------

LangString Description_MPlayer ${LANG_ENGLISH} "The MPlayer core application, no user-interface"
LangString Description_MPlayer ${LANG_GERMAN} "Das MPlayer Hauptprogramm, keine graphische Benutzer-Oberfläche"

LangString Description_MPUI ${LANG_ENGLISH} "The MPUI front-end by Martin Fiedler, a very clean and leightweight user-interface"
LangString Description_MPUI ${LANG_GERMAN} "Die MPUI Benutzer-Oberfläche von Martin Fiedler, eine besonders einfache und kompakte Oberfläche"

LangString Description_SMPlayer ${LANG_ENGLISH} "The SMPlayer front-end by RVM, an advanced user-interface with lots of features"
LangString Description_SMPlayer ${LANG_GERMAN} "Die SMPlayer Benutzer-Oberfläche von RVM, eine 	hochentwickelte Oberfläche mit sehr vielen Funktionen"

LangString Description_Reset ${LANG_ENGLISH} "Reset all MPlayer, SMPlayer and MPUI options - highly recommended in order to avoid conflicts!"
LangString Description_Reset ${LANG_GERMAN} "Setzt alle MPlayer, SMPlayer und MPUI Optionen zurück - wird dringend empfohlen um Konflikte zu vermeiden!"

LangString Description_Codecs ${LANG_ENGLISH} "The Binary Codecs (third-party DLLs) add support for even more A/V formats to MPlayer"
LangString Description_Codecs ${LANG_GERMAN} "Die binären Codecs (DLL Dateien) erlauben es MPlayer noch mehr A/V Formate abzuspielen"

LangString Description_Assocs ${LANG_ENGLISH} "Open all audio and video files with MPlayer for Windows by default"
LangString Description_Assocs ${LANG_GERMAN} "Alle Audio und Video Dateien standardmäßig mit MPlayer für Windows öffnen"

LangString Description_Shortcuts ${LANG_ENGLISH} "Create shortcuts to MPlayer for Windows on the Desktop and in the Quick Launch bar"
LangString Description_Shortcuts ${LANG_GERMAN} "Verknüpfungen mit MPlayer für Windows auf dem Desktop und in der Schnellstart-Leiste erzeugen"

LangString Description_Optimize ${LANG_ENGLISH} "Compress all executable files with UPX in order to safe discspace and minimize the startup delay - this operation may take a few minutes (Recommended)"
LangString Description_Optimize ${LANG_GERMAN} "Alle Programmdateien mit UPX komprimieren, um Speicherplatz zu sparen und den Programmstart zu beschleunigen - dieser Vorgang kann einige Minuten in Anspruch nehmen (Empfohlen)"

LangString Description_UpdateReminder ${LANG_ENGLISH} "Automatically check for new updates online every 14 days (Recommended)"
LangString Description_UpdateReminder ${LANG_GERMAN} "Automatisch alle 14 Tage online nach neuen Updates suchen (Empfohlen)"


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; // Installer Macros
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Includes
!include WinMessages.nsh
!include StrFunc.nsh

${StrTok}
${StrLoc}
${StrCase}

; ---------------------------------------
; Utils
; ---------------------------------------

!macro ExchVarIndex index user_var
  Exch ${index}
  Exch ${user_var}
  Exch ${index}
!macroend

!macro Assert val1 val2 location
  StrCmp '${val1}' '${val2}' +3
  MessageBox MB_ICONSTOP|MB_TOPMOST "Assertion '${val1}' == '${val2}' faild at line ${__LINE__} !!!"
  Call Halt
!macroend

Function Halt 
  System::Call "kernel32::GetCurrentProcess() i.r0"
  System::Call "kernel32::TerminateProcess(i r0, i 1)"
FunctionEnd

; ---------------------------------------
; File
; ---------------------------------------

!macro FileEx switches name
  SetOverwrite try
  ClearErrors
  File ${switches} "${name}"
  IfErrors 0 +4
  MessageBox MB_ICONEXCLAMATION|MB_OKCANCEL "$(FileExtractError)" IDOK -3
  MessageBox MB_ICONSTOP "$(InstallFailed)"
  Abort "$(InstallFailed)"
  SetOverwrite on
!macroend

; ---------------------------------------
; Details Print
; ---------------------------------------

!macro PrintStatus text
  SetDetailsPrint textonly
  DetailPrint "${text}"
  SetDetailsPrint listonly
  DetailPrint "--- ${text} ---"
!macroend

!macro PrintStatusWait text
  SetDetailsPrint textonly
  DetailPrint "${text}, $(PleaseWait)"
  SetDetailsPrint listonly
  DetailPrint "--- ${text} ---"
  Sleep 250
!macroend

; ---------------------------------------
; UAC Initialization
; ---------------------------------------

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
  MessageBox MB_ICONSTOP|MB_TOPMOST "$(NotAllowedToInstall)"
  Abort

UAC_Success_${ID}:
  StrCmp 1 $3 +4 ;Admin?
  StrCmp 3 $1 0 UAC_ElevationAborted_${ID} ;Try again?
  MessageBox MB_ICONEXCLAMATION|MB_TOPMOST "$(NotAllowedToInstall)"
  Goto UAC_Elevate_${ID}

  !undef ID
!macroend

; ---------------------------------------
; Create HTML redirector
; ---------------------------------------

!macro CreateRedirHTML filename targeturl
  FileOpen $R0 "${filename}" w
  FileWrite $R0 '<html><head><meta http-equiv="refresh" content="0; URL=${targeturl}"></head>'
  FileWrite $R0 '<body><h1>Redirecting...</h1>'
  FileWrite $R0 '<body>You will be redirected to <a href="${targeturl}">${targeturl}</a>, please wait...</body></html>'
  FileWrite $R0 '</body></html>'
  FileClose $R0
!macroend

; ---------------------------------------
; Make Shortcuts
; ---------------------------------------

!macro MakeShortcut linkfile targetfile
  IfFileExists "${targetfile}" 0 +2
  CreateShortCut "${linkfile}" "${targetfile}"
!macroend

!macro MakeStartmenuEntry folder linkname targetfile params
  IfFileExists "${targetfile}" 0 +4
  CreateShortCut "$SMPROGRAMS\${folder}\${linkname}.lnk" "${targetfile}" "${params}" "${targetfile}" 0 SW_SHOWNORMAL "" "${linkname}"
  nsisStartMenu::RegenerateFolder "${folder}"
  Pop $9
!macroend

; ---------------------------------------
; Kill Applications
; ---------------------------------------

!macro _KillExecutable filename
  !ifndef ID
    !error "ID not defined!"
  !endif
  
  StrCpy $0 "${filename}"
  ClearErrors
  Delete "${filename}"
  IfErrors FaildToDelete_${ID}
!macroend

!macro KillApps
  !define ID ${__LINE__}

  CheckInstances_${ID}:
  !insertmacro _KillExecutable "$INSTDIR\MPlayer.exe"
  !insertmacro _KillExecutable "$INSTDIR\mplayer\MPlayer.exe"
  !insertmacro _KillExecutable "$INSTDIR\MPUI.exe"
  !insertmacro _KillExecutable "$INSTDIR\smplayer_portable.exe"
  !insertmacro _KillExecutable "$INSTDIR\SMPlayer.exe"
  !insertmacro _KillExecutable "$INSTDIR\AutoUpdate.exe"
  !insertmacro _KillExecutable "$INSTDIR\ResetSMPlayer.exe"
  !insertmacro _KillExecutable "$INSTDIR\SetFileAssoc.exe"
  !insertmacro _KillExecutable "$INSTDIR\Uninstall.exe"

  Goto ProcNotRunning_${ID}
  
  FaildToDelete_${ID}:
  MessageBox MB_ICONSTOP|MB_RETRYCANCEL "$(KillApps_Failed)$\n$0$\n$\n$(KillApps_Running)" IDRETRY CheckInstances_${ID}
  !insertmacro PrintStatus "$(KillApps_Detail)"
  Abort
  
  ProcNotRunning_${ID}:
  !undef ID
!macroend

; ---------------------------------------
; Text File Creator
; ---------------------------------------

!macro TextFileAppend desthandle string
  FileWrite ${desthandle} '${string}$\r$\n'
!macroend

!macro TextFileCopy desthandle filename
  !define ID ${__LINE__}

  ClearErrors
  FileOpen $1 "${filename}" r
  IfErrors FaildCopy_${ID}
  
  ReadCopy_${ID}:
  FileRead $1 $2
  IfErrors EOFCopy_${ID}
  FileWrite ${desthandle} $2
  IfErrors EOFCopy_${ID}
  Goto ReadCopy_${ID}
  
  EOFCopy_${ID}:
  FileClose $1

  FaildCopy_${ID}:
  !undef ID
!macroend

; ---------------------------------------
; Extract file conditionally
; ---------------------------------------

!macro FileConditionally var value filename label
  !define ID ${__LINE__}
  
  StrCmp ${var} "${value}" 0 SkipFile_${ID}
  !insertmacro FileEx "" "${filename}"

  !if ${label} != ""
    Goto ${label}
  !endif  
  
  SkipFile_${ID}:
  !undef ID
!macroend

; ---------------------------------------
; Enable/Disable Buttons
; ---------------------------------------

!macro SetNextButtonEnabled flag
  Push $0
  Push $1

  !if ${flag} == 0
    StrCpy $1 0
  !else
    StrCpy $1 1
  !endif

  GetDlgItem $0 $HWNDPARENT 1
  EnableWindow $0 $1
  GetDlgItem $0 $HWNDPARENT 2
  EnableWindow $0 $1
  GetDlgItem $0 $HWNDPARENT 3
  EnableWindow $0 $1

  Pop $1
  Pop $0
!macroend

; ---------------------------------------
; ExecTimeout
; ---------------------------------------

!macro ExecTimeout commandline timeout_ms terminate var_exitcode
  Timeout::ExecTimeout '${commandline}' '${timeout_ms}' '${terminate}'
  Pop ${var_exitcode}
!macroend

; ---------------------------------------
; Terminate SMPlayer
; ---------------------------------------

Function TerminateSMPlayer
  Push $0
  IfFileExists "$INSTDIR\smplayer_portable.exe" 0 SkipTerminate

  WriteINIStr  "$INSTDIR\smplayer.ini" "instances" "use_single_instance" "true"
  WriteINIStr  "$INSTDIR\smplayer.ini" "instances" "use_autoport" "true"

  !insertmacro ExecTimeout '"$INSTDIR\smplayer_portable.exe" -send-action quit' 5000 1 $0
    
  SkipTerminate:
  Pop $0
FunctionEnd

; ---------------------------------------
; Search Files
; ---------------------------------------

!ifdef FullPackage
  !macro SearchFiles filter
    Push "${filter}"
    Call _SearchFiles
  !macroend

  Function _SearchFiles
    Exch $0
    Push $1
  
    Push "?" ; signal end of list
    Exch 2
    Exch
  
    FindFirst $0 $1 "$0"
  
    Loop:
    IfErrors Done
    Push $1  
    Exch 2
    Exch
    ClearErrors
    FindNext $0 $1
    Goto Loop
  
    Done:
    Pop $1
    Pop $0
  FunctionEnd
!endif

; ---------------------------------------
; Pack Files (UPX)
; ---------------------------------------

!macro PackFile filename
  Push "${filename}"
  Call _PackFile
!macroend

Function _PackFile
  Exch $0
  Push $1
  IfFileExists "$0" 0 PackSuccess

  DetailPrint "$(PackingEXE) $0"
  nsExec::ExecToLog '"$PLUGINSDIR\upx.exe" --compress-icons=0 "$0"'
  Pop $1

  StrCmp $1 "error" 0 PackSuccess
  DetailPrint "$(PackFile_Failed) $0"
  MessageBox MB_ICONSTOP "$(PackFile_Failed) $0"
  Abort "$(InstallFailed)"
  
  PackSuccess:
  Pop $1
  Pop $0
FunctionEnd


!ifdef FullPackage
  !macro PackAll basedir filter
    Push "${basedir}"
    Push "${filter}"
    Call _PackAll
  !macroend

  Function _PackAll
    Exch $0
    Exch
    Exch $1
  
    !insertmacro SearchFiles "$1\*.$0"
  
    Loop:
    Pop $0
    StrCmp $0 "?" Done
    !insertmacro PackFile "$1\$0"
    Goto Loop
  
    Done:
    Pop $1
    Pop $0
  FunctionEnd
!endif

; ---------------------------------------
; Check Instances
; ---------------------------------------

!define MUTEX "{df7864b5-3bad-42f5-bff2-cb9a57b824ab}"

!macro CheckInstances skip
  !define ID ${__LINE__}
  Push $0
  
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${MUTEX}") i .r1 ?e'
  Pop $0

  !if ${skip} == "true"
    Goto InstallerNotRunningYet_${ID}
  !else
    StrCmp $0 0 InstallerNotRunningYet_${ID}
  !endif

  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(AlreadyRunning)"
  Quit
   
  InstallerNotRunningYet_${ID}:
  Pop $0
  !undef ID
!macroend

; ---------------------------------------
; Trim String
; ---------------------------------------

!macro TrimString output input
  Push ${input}
  Call _TrimFunction
  Pop ${output}
!macroend

Function _TrimFunction
  Exch $R1 ; Original string
  Push $R2
 
  Loop:
  StrCpy $R2 "$R1" 1
  StrCmp "$R2" " " TrimLeft
  StrCmp "$R2" "$\r" TrimLeft
  StrCmp "$R2" "$\n" TrimLeft
  StrCmp "$R2" "$\t" TrimLeft
  Goto Loop2

  TrimLeft:	
  StrCpy $R1 "$R1" "" 1
  Goto Loop
 
  Loop2:
  StrCpy $R2 "$R1" 1 -1
  StrCmp "$R2" " " TrimRight
  StrCmp "$R2" "$\r" TrimRight
  StrCmp "$R2" "$\n" TrimRight
  StrCmp "$R2" "$\t" TrimRight
  Goto Done

  TrimRight:
  StrCpy $R1 "$R1" -1
  Goto Loop2
 
  Done:
  Pop $R2
  Exch $R1
FunctionEnd

; ---------------------------------------
; RemoveMultiSpaces
; ---------------------------------------

!macro RemoveMultiSpaces var_out var_in
  Push ${var_in}
  Call _RemoveMultiSpaces
  Pop ${var_out}
!macroend

Function _RemoveMultiSpaces
  Exch $0
  Push $1
  Push $2
  Push $3
  
  StrCpy $1 0
  StrCpy $3 ""
  
  Loop:
  ${StrTok} $2 "$0" " " "$1" "1"
  StrCmp $2 "" Skip
  IntOp $1 $1 + 1
  StrCmp $3 "" +2
  StrCpy $3 "$3 "
  StrCpy $3 "$3$2"
  Goto Loop
  
  Skip:
  StrCpy $0 $3
  
  Pop $3
  Pop $2
  Pop $1
  Exch $0
FunctionEnd

; ---------------------------------------
; Detect CPU Type
; ---------------------------------------

; CPUTypes supported are
; [2] Athlon
; [3] Pentium III
; [4] Pentium 4
; [5] Runtime Detection (Unknown)
  
!macro DetectCPUType var_type var_name var_exts
  Call _DetectCPUType
  Pop ${var_name}
  Pop ${var_type}
  Pop ${var_exts}
!macroend

!macro CheckCPUExt list ext label_found
  ${StrLoc} $0 "${list}" " ${ext} " ">"
  StrCmp $0 "" 0 ${label_found}
!macroend

Function _DetectCPUType
  Push "CPU_EXTS_DUMMY"
  Push "CPU_TYPE_DUMMY"
  Push "CPU_NAME_DUMMY"

  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5

  ; --------------------------

  StrCpy $4 5 #RTM

  IfSilent +2
  Banner::show /NOUNLOAD "$(DetectingCPUType)"

  File /oname=$PLUGINSDIR\cpuinfo.exe "installer\cpuinfo.exe"
  nsExec::ExecToStack '"$PLUGINSDIR\cpuinfo.exe"'
  
  Pop $0
  Pop $1

  ; -------------- DEBUG --------------
  ;StrLen $2 $1
  ;MessageBox MB_ICONEXCLAMATION "Length of STDOUT data: $2"
  ; -------------- DEBUG --------------

  Delete "$PLUGINSDIR\cpuinfo.exe"
  StrCmp $0 "error" CPU_DETECTION_DONE

  StrLen $0 $1
  IntOp $0 ${NSIS_MAX_STRLEN} - $0
  IntCmp $0 1 0 0 CPU_STRLEN_GOOD
  MessageBox MB_TOPMOST|MB_ICONSTOP "Error: CPU detection apparently ran out of buffer, this shouldn't happen. Skipping!"
  Goto CPU_DETECTION_DONE
  
  ; ------------------------------

  CPU_STRLEN_GOOD:
  ${StrTok} $5 "$1" "$\n$\r$\t:" "13" "1"
  ${StrTok} $1 "$1" "$\n$\r$\t:" "9" "1"
  ${StrCase} $1 "$1" "U"
 
  ; ------------------------------

  StrCpy $0 "0"
  StrCpy $2 " "
  
  CPU_LOOP:
  ${StrTok} $3 $1 " " "$0" "1"
  IntOp $0 $0 + 1
  StrCmp $3 "" CPU_LOOP_END
  StrCmp $3 "MMX" CPU_LOOP_FOUND
  StrCmp $3 "MMX2" CPU_LOOP_FOUND
  StrCmp $3 "MMXEXT" CPU_LOOP_FOUND
  StrCmp $3 "3DNOW" CPU_LOOP_FOUND
  StrCmp $3 "3DNOW2" CPU_LOOP_FOUND
  StrCmp $3 "3DNOWEXT" CPU_LOOP_FOUND
  StrCmp $3 "SSE" CPU_LOOP_FOUND
  StrCmp $3 "SSE2" CPU_LOOP_FOUND
  StrCmp $3 "SSE3" CPU_LOOP_FOUND
  StrCmp $3 "SSSE3" CPU_LOOP_FOUND
  Goto CPU_LOOP
  
  CPU_LOOP_FOUND:
  StrCpy $2 "$2$3 "
  Goto CPU_LOOP
  
  CPU_LOOP_END:
  
  ; ------------------------------
  
  !insertmacro CheckCPUExt "$2" "MMX" HAS_MMX
  Goto CPU_DETECTION_DONE

  HAS_MMX:
  !insertmacro CheckCPUExt "$2" "SSE2" HAS_SSE2
  !insertmacro CheckCPUExt "$2" "SSE" HAS_SSE
  !insertmacro CheckCPUExt "$2" "MMX2" HAS_MMX2
  !insertmacro CheckCPUExt "$2" "MMXEXT" HAS_MMX2
  Goto CPU_DETECTION_DONE
  
  HAS_MMX2:
  !insertmacro CheckCPUExt "$2" "3DNOWEXT" HAS_3DNOWEXT
  Goto CPU_DETECTION_DONE

  HAS_3DNOWEXT:
  StrCpy $4 2 #Athlon
  Goto CPU_DETECTION_DONE

  HAS_SSE:
  StrCpy $4 3 #P3
  !insertmacro CheckCPUExt "$2" "3DNOWEXT" HAS_3DNOWEXT
  Goto CPU_DETECTION_DONE

  HAS_SSE2:
  StrCpy $4 4 #P4
  Goto CPU_DETECTION_DONE
  
  ; --------------------------
  
  CPU_DETECTION_DONE:
  !insertmacro ExchVarIndex 6 $5
  !insertmacro ExchVarIndex 7 $4
  !insertmacro ExchVarIndex 8 $2
  !insertmacro Assert $5 "CPU_NAME_DUMMY" "CPU Detection"
  !insertmacro Assert $4 "CPU_TYPE_DUMMY" "CPU Detection"
  !insertmacro Assert $2 "CPU_EXTS_DUMMY" "CPU Detection"
  
  IfSilent +2
  Banner::destroy
  
  ; --------------------------

  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd

; ---------------------------------------
; Access Control
; ---------------------------------------

!macro MakeFilePublic filename
  !define ID ${__LINE__}
  IfFileExists "${filename}" FileAlreadyExists_${ID}
  
  Push $R0
  FileOpen $R0 "${filename}" w
  FileClose $R0
  Pop $R0
  
  FileAlreadyExists_${ID}:
  AccessControl::GrantOnFile "${filename}" "(S-1-5-32-545)" "FullAccess"
  !undef ID
!macroend


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; // Installer Sections
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Section "-KillMPlayer"
  !insertmacro PrintStatusWait "$(Section_Remove)" 
  
  DetailPrint "$(TerminateSMPlayerInstances)"
  Call TerminateSMPlayer
  Sleep 1500
  
  !insertmacro KillApps
SectionEnd

Section "-CleanUp"
  !insertmacro PrintStatusWait "$(Section_Clean)"

  SetOutPath $INSTDIR
  Delete "$INSTDIR\*.exe"
  Delete "$INSTDIR\*.dll"
  Delete "CheckUpdate.html"
SectionEnd

; ---------------------------------------
; Install MPlayer
; ---------------------------------------

Section "!MPlayer ${Version_MPlayer}" SectionMPlayer
  SectionIn 1 2 RO
  
  ; Compensate for multiple MPlayer builds (we'll extract only one)
  AddSize -40960
  
  !insertmacro PrintStatusWait "$(Section_MPlayer) ${Version_MPlayer}"

  SetOutPath $INSTDIR

  !insertmacro FileEx "" "mplayer.html"
  !insertmacro FileEx "/oname=License.txt" "installer\GPL.txt"
  !insertmacro FileEx "" "ResetSMPlayer.exe"

  StrCmp $CPU_TYPE "" 0 CPUAlreadDetected
  !insertmacro DetectCPUType $CPU_TYPE $CPU_NAME $0
  
  ; --------------------------
  
  CPUAlreadDetected:
  DetailPrint "$(CPUTypeConfirm) $CPU_NAME"

  !insertmacro FileConditionally $CPU_TYPE "2" "${Path_Builds}\athlon\MPlayer.exe" MPlayerExtracted
  !insertmacro FileConditionally $CPU_TYPE "3" "${Path_Builds}\p3\MPlayer.exe" MPlayerExtracted
  !insertmacro FileConditionally $CPU_TYPE "4" "${Path_Builds}\p4\MPlayer.exe" MPlayerExtracted
  !insertmacro FileConditionally $CPU_TYPE "5" "${Path_Builds}\rtm\MPlayer.exe" MPlayerExtracted
  Abort "$(InstallFailed)"
  
  ; --------------------------

  MPlayerExtracted:
  SetOutPath "$INSTDIR\mplayer"

  !insertmacro FileEx "" "installer\config"
  !insertmacro FileEx "/oname=mplayer.exe" "installer\dummy.exe"
  !insertmacro FileEx "" "${Path_Builds}\rtm\mplayer\input.conf"
  !insertmacro FileEx "" "${Path_Builds}\rtm\mplayer\subfont.ttf"
  !insertmacro MakeFilePublic "$INSTDIR\mplayer\config"
  !insertmacro MakeFilePublic "$INSTDIR\mplayer\input.conf"
  
  SetOutPath "$INSTDIR\fonts"
  !insertmacro FileEx "" "${Path_Builds}\rtm\fonts\*.*"

  CreateDirectory "$INSTDIR\codecs"
  
  SetOutPath "$INSTDIR"
  !insertmacro CreateRedirHTML "$INSTDIR\MPlayerHQ.html" "http://www.mplayerhq.hu/"
  !insertmacro CreateRedirHTML "$INSTDIR\MPlayerWin32.html" "http://oss.netfarm.it/mplayer-win32.php"
  !insertmacro CreateRedirHTML "$INSTDIR\CelticDruid.html" "http://celticdruid.no-ip.com/xvid/"
SectionEnd

; ---------------------------------------
; Create Readme File
; ---------------------------------------

Section "-MPlayer Readme"
  !insertmacro FileEx "/oname=$PLUGINSDIR\mplayer_license.txt" "installer\License.txt"
  !insertmacro FileEx "/oname=$PLUGINSDIR\mplayer_copyright.txt" "installer\Copyright.txt"
  !insertmacro FileEx "/oname=$PLUGINSDIR\mplayer_changelog.txt" "installer\Changelog.txt"
  
  ClearErrors
  FileOpen $0 "$INSTDIR\readme.html" w
  IfErrors FaildReadme
  
  !include "installer\readme.nsh"
  FileClose $0

  FaildReadme:
SectionEnd

; ---------------------------------------
; Install MPUI front-end
; ---------------------------------------

Section "!MPUI ${Version_MPUI}" SectionMPUI
  SectionIn 1 2 RO
  !insertmacro PrintStatusWait "$(Section_MPUI) ${Version_MPUI}"

  SetOutPath $INSTDIR
  !insertmacro FileEx "" "MPUI.exe"
  !insertmacro FileEx "" "SetFileAssoc.exe"
  !insertmacro MakeFilePublic "$INSTDIR\MPUI.ini"

  SetOutPath "$INSTDIR\locale"
  !insertmacro FileEx "" "locale\*.txt"

  !insertmacro CreateRedirHTML "$INSTDIR\MPUI.html" "http://mpui.sourceforge.net/"
SectionEnd

; ---------------------------------------
; Full Package Only Stuff
; ---------------------------------------

!ifdef FullPackage

  ; ---------------------------------------
  ; Install SMPlayer
  ; ---------------------------------------
  
  Section "!SMPlayer ${Version_SMPlayer}" SectionSMPlayer
    SectionIn 1

    !insertmacro PrintStatusWait "$(Section_SMPlayer) ${Version_SMPlayer}"

    SetOutPath $INSTDIR
    !insertmacro FileEx "/oname=smplayer_portable.exe" "SMPlayer.exe"
    !insertmacro FileEx "" "mingwm10.dll"
    !insertmacro FileEx "" "QtCore4.dll"
    !insertmacro FileEx "" "QtGui4.dll"
    !insertmacro FileEx "" "QtNetwork4.dll"
    !insertmacro FileEx "" "QtXml4.dll"
    !insertmacro FileEx "" "QxtCore.dll"
    !insertmacro FileEx "" "libgcc_s_dw2-1.dll"

    SetOutPath "$INSTDIR\shortcuts"
    !insertmacro FileEx "" "shortcuts\*.keys"

    SetOutPath "$INSTDIR\themes"
    !insertmacro FileEx "/r" "themes\*.*"

    SetOutPath "$INSTDIR\translations"
    !insertmacro FileEx "" "translations\*.qm"

    SetOutPath "$INSTDIR\docs"
    !insertmacro FileEx "/r" "docs\*.*"
 
    !insertmacro CreateRedirHTML "$INSTDIR\SMPlayer.html" "http://smplayer.sourceforge.net/"

    DetailPrint "Modifying: $INSTDIR\smplayer.ini"
    WriteINIStr "$INSTDIR\smplayer.ini" "%General" "mplayer_bin" "MPlayer.exe"
    StrCpy $R0 "${Version_MPlayer}" 5 5
    WriteINIStr "$INSTDIR\smplayer.ini" "mplayer_info" "mplayer_detected_version" "$R0"
    WriteINIStr "$INSTDIR\smplayer.ini" "mplayer_info" "mplayer_user_supplied_version" "$R0"

    !insertmacro MakeFilePublic "$INSTDIR\smplayer.ini"
  SectionEnd

  ; ---------------------------------------
  ; Install Codecs
  ; ---------------------------------------

  Section "!$(Section_Codecs_Caption) ${Version_Codecs}" SectionCodecs
    SectionIn 1

    !insertmacro PrintStatusWait "$(Section_Codecs_Status) ${Version_Codecs}"

    SetOutPath "$INSTDIR\codecs"
    !insertmacro FileEx "" "codecs\*.*"
  SectionEnd
  
!endif

; ---------------------------------------
; Create Auto Updater
; ---------------------------------------

Section "-Auto Update"
  !insertmacro PrintStatusWait "$(Section_AutoUpdate)"

  SetOutPath $INSTDIR
  Delete "$INSTDIR\AutoUpdate.exe"
  Delete "$INSTDIR\AutoUpdate.dat"
  
  ClearErrors
  WriteINIStr "$INSTDIR\AutoUpdate.dat" "AutoUpdate" "BuildNo" "${Build_Number}"
  SetFileAttributes "$INSTDIR\AutoUpdate.dat" FILE_ATTRIBUTE_READONLY

  IfErrors 0 +2
  Abort "$(InstallFailed)"
  
  !insertmacro FileEx "" "AutoUpdate.exe"
SectionEnd

; ---------------------------------------
; Create Uninstaller
; ---------------------------------------

Section "-Uninstaller"
  !insertmacro PrintStatusWait "$(Section_Uninstaller)"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

; ---------------------------------------
; Pack EXE files
; ---------------------------------------

Section "-DummyAddSize"
  !ifdef FullPackage
    AddSize 51200
  !else
    AddSize 25600
  !endif
SectionEnd

Section "$(Section_Optimize_Caption)" SectionOptimize
  SectionIn 1 2

  !ifdef FullPackage
    AddSize -51200
  !else
    AddSize -25600
  !endif
  
  !insertmacro GetCommandlineParameter "NOPACK" "error" $0
  StrCmp $0 "error" 0 SkipPackFiles

  !insertmacro PrintStatusWait "$(Section_Optimize)"
  
  !insertmacro FileEx "/oname=$PLUGINSDIR\upx.exe" "installer\upx.exe"
  FileOpen $0 "$PLUGINSDIR\upx.exe" r
  
  ; ---------------------------------------
  
  !insertmacro PackFile "$INSTDIR\MPlayer.exe"
  !insertmacro PackFile "$INSTDIR\MPUI.exe"
  !insertmacro PackFile "$INSTDIR\smplayer_portable.exe"
  !insertmacro PackFile "$INSTDIR\mingwm10.dll"
  !insertmacro PackFile "$INSTDIR\QtCore4.dll"
  !insertmacro PackFile "$INSTDIR\QtGui4.dll"
  !insertmacro PackFile "$INSTDIR\QtNetwork4.dll"
  !insertmacro PackFile "$INSTDIR\QtXml4.dll"
  !insertmacro PackFile "$INSTDIR\QxtCore.dll"
  !insertmacro PackFile "$INSTDIR\libgcc_s_dw2-1.dll"
  
  !ifdef FullPackage
    !insertmacro PackAll "$INSTDIR\codecs" "acm"
    !insertmacro PackAll "$INSTDIR\codecs" "ax"
    !insertmacro PackAll "$INSTDIR\codecs" "dll"
    !insertmacro PackAll "$INSTDIR\codecs" "drv"
    !insertmacro PackAll "$INSTDIR\codecs" "qts"
    !insertmacro PackAll "$INSTDIR\codecs" "qtx"
    !insertmacro PackAll "$INSTDIR\codecs" "vwp"
  !endif

  ; ---------------------------------------
  
  FileClose $0
  Delete /REBOOTOK "$PLUGINSDIR\upx.exe"

  SkipPackFiles:
SectionEnd

; ---------------------------------------
; Reset all settings
; ---------------------------------------

Section "$(Section_Reset_Caption)" SectionReset
  SectionIn 1 2
  !insertmacro PrintStatusWait "$(Section_Reset_Status)"
  
  ExecWait '"$INSTDIR\ResetSMPlayer.exe" /S'
SectionEnd

; ---------------------------------------
; Apply Tweaks
; ---------------------------------------

Section "-Tweaks"
  !insertmacro PrintStatusWait "$(Section_Tweaks)"

  DetailPrint "Modifying: $INSTDIR\MPUI.ini"
  DetailPrint "Modifying: $INSTDIR\smplayer.ini"

  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field 2" "State"
  StrCmp $R0 0 +3
  WriteINIStr "$INSTDIR\MPUI.ini" "MPUI" "Locale" "$(TweaksLanguage_MPUI)"
  WriteINIStr "$INSTDIR\smplayer.ini" "gui" "language" "$(TweaksLanguage_SMPlayer)"

  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field 3" "State"
  StrCmp $R0 0 +5
  ReadINIStr $R1 "$INSTDIR\MPUI.ini" "MPUI" "Params"
  WriteINIStr "$INSTDIR\MPUI.ini" "MPUI" "Params" "$R1 -sws 9"
  ReadINIStr $R1 "$INSTDIR\smplayer.ini" "advanced" "mplayer_additional_options"
  WriteINIStr "$INSTDIR\smplayer.ini" "advanced" "mplayer_additional_options" "$R1 -sws 9"

  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field 4" "State"
  StrCmp $R0 0 +4
  ReadINIStr $R1 "$INSTDIR\MPUI.ini" "MPUI" "Params"
  WriteINIStr "$INSTDIR\MPUI.ini" "MPUI" "Params" "$R1 -af volnorm=2"
  WriteINIStr "$INSTDIR\smplayer.ini" "defaults" "initial_volnorm" "true"

  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field 5" "State"
  StrCmp $R0 0 +4
  ReadINIStr $R1 "$INSTDIR\MPUI.ini" "MPUI" "Params"
  WriteINIStr "$INSTDIR\MPUI.ini" "MPUI" "Params" "$R1 -ac hwac3,hwdts,"
  WriteINIStr "$INSTDIR\smplayer.ini" "%General" "use_hwac3" "true"

  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field 6" "State"
  StrCmp $R0 0 +4
  ReadINIStr $R1 "$INSTDIR\MPUI.ini" "MPUI" "Params"
  WriteINIStr "$INSTDIR\MPUI.ini" "MPUI" "Params" "$R1 -vo gl:yuv=2"
  WriteINIStr "$INSTDIR\smplayer.ini" "%General" "driver\vo" "gl:yuv=2"
  
  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field 7" "State"
  StrCmp $R0 0 +4
  ReadINIStr $R1 "$INSTDIR\MPUI.ini" "MPUI" "Params"
  WriteINIStr "$INSTDIR\MPUI.ini" "MPUI" "Params" "$R1 -lavdopts skiploopfilter=all"
  WriteINIStr "$INSTDIR\smplayer.ini" "performance" "h264_skip_loop_filter" "0"

  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field 8" "State"
  StrCmp $R0 0 +3
  WriteINIStr "$INSTDIR\smplayer.ini" "gui" "mouse_left_click_function" "dvdnav_mouse"
  WriteINIStr "$INSTDIR\smplayer.ini" "drives" "use_dvdnav" "true"
SectionEnd

; ---------------------------------------
; File Assiciations
; ---------------------------------------

Section "$(Section_Assocs_Caption)" SectionAssocs
  SectionIn 1 2
  !insertmacro PrintStatusWait "$(Section_Assocs_Status)"

  ExecWait '"$INSTDIR\SetFileAssoc.exe" /S'
SectionEnd

; ---------------------------------------
; Shortcuts
; ---------------------------------------

Section "-Create Startmenu"
  !insertmacro PrintStatusWait "$(Section_Shortcuts_Staus)"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN startmenupage
    SetOutPath $INSTDIR

    SetShellVarContext current
    RMDir /r "$SMPROGRAMS\$STARTMENU_FOLDER"
    SetShellVarContext all
    RMDir /r "$SMPROGRAMS\$STARTMENU_FOLDER"

    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER" "SMPlayer" "$INSTDIR\smplayer_portable.exe" "-defaultgui"
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER" "SMPlayer ($(ShortCut_Compact))" "$INSTDIR\smplayer_portable.exe" "-minigui"
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER" "SMPlayer ($(ShortCut_MPC))" "$INSTDIR\smplayer_portable.exe" "-mpcgui"
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER" "MPUI" "$INSTDIR\MPUI.exe" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER" "Readme" "$INSTDIR\readme.html" ""

    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER\Docs & Links"
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Docs & Links" "$(ShortCut_MPlayerHomepage)" "$INSTDIR\MPlayerHQ.html" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Docs & Links" "$(ShortCut_MPlayerManual)" "$INSTDIR\mplayer.html" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Docs & Links" "$(ShortCut_MPlayerWin32)" "$INSTDIR\MPlayerWin32.html" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Docs & Links" "$(ShortCut_CelticDruid)" "$INSTDIR\CelticDruid.html" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Docs & Links" "$(ShortCut_SMPlayerHomepage)" "$INSTDIR\SMPlayer.html" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Docs & Links" "$(ShortCut_SMPlayerHelp)" "$INSTDIR\docs\en\faq.html" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Docs & Links" "$(ShortCut_MPUIHomepage)" "$INSTDIR\MPUI.html" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Docs & Links" "$(ShortCut_GNULicense)" "$INSTDIR\docs\en\GPL.html" ""

    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER\Tools"
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Tools" "$(ShortCut_CheckUpdates)" "$INSTDIR\AutoUpdate.exe" "/L=$LANGUAGE"
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Tools" "$(ShortCut_Asscos)" "$INSTDIR\SetFileAssoc.exe" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Tools" "$(ShortCut_ResetSMPlayer)" "$INSTDIR\ResetSMPlayer.exe" ""
    !insertmacro MakeStartmenuEntry "$STARTMENU_FOLDER\Tools" "$(ShortCut_Uninstall)" "$INSTDIR\Uninstall.exe" ""
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "$(Section_Shortcuts_Caption)" SectionShortcuts
  SectionIn 1 2
  SetShellVarContext all
  SetOutPath $INSTDIR

  !insertmacro MakeShortcut "$DESKTOP\SMPlayer.lnk" "$INSTDIR\smplayer_portable.exe"
  !insertmacro MakeShortcut "$DESKTOP\MPUI.lnk" "$INSTDIR\MPUI.exe"
  !insertmacro MakeShortcut "$QUICKLAUNCH\SMPlayer.lnk" "$INSTDIR\smplayer_portable.exe"
  !insertmacro MakeShortcut "$QUICKLAUNCH\MPUI.lnk" "$INSTDIR\MPUI.exe"
SectionEnd

; ---------------------------------------
; Registry Tweaks
; ---------------------------------------

Section "-Regsitry"
  !insertmacro PrintStatusWait "$(Section_Registry)"

  WriteRegStr HKLM ${MPlayer_RegPath} "DisplayName" "$(MPlayerForWindows) (Full Package)"
  WriteRegStr HKLM ${MPlayer_RegPath} "DisplayIcon" "$INSTDIR\MPlayer.exe,0"
  WriteRegStr HKLM ${MPlayer_RegPath} "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM ${MPlayer_RegPath} "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM ${MPlayer_RegPath} "URLInfoAbout" "http://mulder.at.gg/"
  WriteRegStr HKLM ${MPlayer_RegPath} "URLUpdateInfo" "http://mulder.at.gg/"
  WriteRegStr HKLM ${MPlayer_RegPath} "HelpLink" "http://forum.doom9.org/showthread.php?t=138725"
  WriteRegStr HKLM ${MPlayer_RegPath} "Publisher" "LoRd MuldeR"
  WriteRegStr HKLM ${MPlayer_RegPath} "Publisher" "LoRd MuldeR"
  WriteRegDWORD HKLM ${MPlayer_RegPath} "NoModify" 1
  WriteRegDWORD HKLM ${MPlayer_RegPath} "NoRepair" 1
  WriteRegDWORD HKCU ${MPlayer_RegPath} "LastUpdateCheck" 0
  DeleteRegValue HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "MPlayerForWindows_UpdateReminder"
SectionEnd

; ---------------------------------------
; Update Reminder
; ---------------------------------------

Section "$(Section_UpdateReminder_Caption)" SectionUpdateReminder
  SectionIn 1 2
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "MPlayerForWindows_UpdateReminder" '"$INSTDIR\AutoUpdate.exe" /L=$LANGUAGE /TASK'
SectionEnd

; ---------------------------------------
; Done!
; ---------------------------------------

Section "-Completed"
  !insertmacro PrintStatus "$(Section_Done)"
  StrCpy $SETUP_COMPLETED "YES"
SectionEnd


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; // Un-installer sections
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Section "Uninstall"
  !insertmacro PrintStatusWait "$(UnSection_Uninstall)" 
  !insertmacro KillApps
  
  SetShellVarContext all

  ;----------------------------------------------

  !insertmacro PrintStatusWait "$(UnSection_RestoreAsscos)" 

  SetOutPath "$PLUGINSDIR\UnFileAssoc"
  !insertmacro FileEx "" "SetFileAssoc.exe"
  ExecWait '"$PLUGINSDIR\UnFileAssoc\SetFileAssoc.exe" /MODE=RESTORE /S'
  Sleep 1000

  ;----------------------------------------------

  !insertmacro PrintStatusWait "$(UnSection_RemoveShortcuts)" 
  
  SetShellVarContext current
  Delete "$DESKTOP\MPUI.lnk"
  Delete "$QUICKLAUNCH\MPUI.lnk"
  Delete "$DESKTOP\SMPlayer.lnk"
  Delete "$QUICKLAUNCH\SMPlayer.lnk"
  
  SetShellVarContext all
  Delete "$DESKTOP\MPUI.lnk"
  Delete "$QUICKLAUNCH\MPUI.lnk"
  Delete "$DESKTOP\SMPlayer.lnk"
  Delete "$QUICKLAUNCH\SMPlayer.lnk"

  ;----------------------------------------------

  !insertmacro MUI_STARTMENU_GETFOLDER startmenupage $R0

  StrCmp $R0 "" SkipRemoveStartmenu
  StrCmp $R0 ">" SkipRemoveStartmenu
 
  SetShellVarContext current
  RMDir /r "$SMPROGRAMS\$R0"
  SetShellVarContext all
  RMDir /r "$SMPROGRAMS\$R0"

  SkipRemoveStartmenu:

  ;----------------------------------------------

  !insertmacro PrintStatusWait "$(UnSection_RemoveFiles)" 

  SetOutPath $DESKTOP
  Delete "$INSTDIR\*.*"
  RMDir /r /REBOOTOK $INSTDIR

  ;----------------------------------------------
  
  !insertmacro PrintStatusWait "$(UnSection_Registry)" 

  DeleteRegValue HKLM ${MPlayer_RegPath} "DisplayName"
  DeleteRegValue HKLM ${MPlayer_RegPath} "DisplayIcon"
  DeleteRegValue HKLM ${MPlayer_RegPath} "InstallLocation"
  DeleteRegValue HKLM ${MPlayer_RegPath} "UninstallString"
  DeleteRegValue HKLM ${MPlayer_RegPath} "URLInfoAbout"
  DeleteRegValue HKLM ${MPlayer_RegPath} "URLUpdateInfo"
  DeleteRegValue HKLM ${MPlayer_RegPath} "HelpLink"
  DeleteRegValue HKLM ${MPlayer_RegPath} "Publisher"
  DeleteRegValue HKLM ${MPlayer_RegPath} "Publisher"
  DeleteRegValue HKLM ${MPlayer_RegPath} "NoModify"
  DeleteRegValue HKLM ${MPlayer_RegPath} "NoRepair"
  DeleteRegValue HKLM ${MPlayer_RegPath} "StartmenuFolder"
  DeleteRegValue HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "MPlayerForWindows_UpdateReminder"

  ;----------------------------------------------

  SetDetailsPrint textonly
  DetailPrint "$(UnSection_Done)"
  SetDetailsPrint listonly
SectionEnd


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; // Section Descriptions
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionMPlayer} "$(Description_MPlayer)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionMPUI} "$(Description_MPUI)"
  !ifdef FullPackage
    !insertmacro MUI_DESCRIPTION_TEXT ${SectionSMPlayer} "$(Description_SMPlayer)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SectionCodecs} "$(Description_Codecs)"
  !endif
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionOptimize} "$(Description_Optimize)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionReset} "$(Description_Reset)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionAssocs} "$(Description_Assocs)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionShortcuts} "$(Description_Shortcuts)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionUpdateReminder} "$(Description_UpdateReminder)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

!insertmacro UMUI_DECLARECOMPONENTS_BEGIN
  !insertmacro UMUI_COMPONENT SectionMPlayer
  !insertmacro UMUI_COMPONENT SectionMPUI
  !ifdef FullPackage
    !insertmacro UMUI_COMPONENT SectionSMPlayer
    !insertmacro UMUI_COMPONENT SectionCodecs
  !endif
  !insertmacro UMUI_COMPONENT SectionOptimize
  !insertmacro UMUI_COMPONENT SectionReset
  !insertmacro UMUI_COMPONENT SectionAssocs
  !insertmacro UMUI_COMPONENT SectionShortcuts
!insertmacro UMUI_DECLARECOMPONENTS_END


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; Functions
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; ---------------------------------------
; Init Functions
; ---------------------------------------

Function .onInit
  !insertmacro INIT_UAC ""

  StrCpy $CPU_TYPE ""
  StrCpy $CLOSE_SMPLAYER ""
  StrCpy $SETUP_COMPLETED ""
  
  InitPluginsDir
  !insertmacro UMUI_MULTILANG_GET

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "installer\page_cpu.ini" "page_cpu.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "installer\page_tweak.ini" "page_tweak.ini"
  
  !insertmacro GetCommandlineParameter "L" "error" $0
  StrCmp $0 "error" 0 SkipSplashScreen
  !insertmacro CheckInstances "false"
  IfSilent SkipSplashScreen

  File /oname=$PLUGINSDIR\splash.gif "installer\splash.gif"
  newadvsplash::show 3000 1000 500 -1 /NOCANCEL "$PLUGINSDIR\splash.gif"
  Delete /REBOOTOK "$PLUGINSDIR\splash.gif"

  SkipSplashScreen:
  !insertmacro CheckInstances "true"
  
  ; If running in update mode, self-delete installer
  !insertmacro GetCommandlineParameter "UPDATE" "error" $0
  StrCmp $0 "error" +2
  SelfDel::del
  
  ; make sure we aren't blockey by buggy A/V software
  File /oname=$PLUGINSDIR\check.exe "installer\check.exe"
  nsExec::Exec /TIMEOUT=2500 "$PLUGINSDIR\check.exe"
  Pop $0
  StrCmp $0 42 ExecIsNotBlocked
  MessageBox MB_ICONSTOP|MB_TOPMOST|MB_OK "$(ExecBlockedAbort)$\n$\nCode: $0"
  Quit
  ExecIsNotBlocked:
FunctionEnd

Function un.onInit
  !insertmacro INIT_UAC "un"
  InitPluginsDir
  !insertmacro UMUI_MULTILANG_GET
FunctionEnd

; ---------------------------------------
; Check If Update
; ---------------------------------------
;
Function CheckIfUpdate
  !insertmacro GetCommandlineParameter "UPDATE" "error" $0
  StrCmp $0 "error" +2
  Abort
FunctionEnd

; ---------------------------------------
; Close SMPlayer at startup
; ---------------------------------------
  
Function InitialSMPlayerClose
  !insertmacro UMUI_ABORT_IF_INSTALLFLAG_IS ${UMUI_CANCELLED}
  
  IfSilent SkipSMPlayerQuit
  StrCmp $CLOSE_SMPLAYER "" 0 SkipSMPlayerQuit

  !insertmacro SetNextButtonEnabled 0
  Banner::show /NOUNLOAD "$(TerminateSMPlayerInstances)"
  Call TerminateSMPlayer
  StrCpy $CLOSE_SMPLAYER "DONE"
  Banner::destroy
  !insertmacro SetNextButtonEnabled 1
  
  SkipSMPlayerQuit:
FunctionEnd
  
; ---------------------------------------
; Custom Page Functions
; ---------------------------------------

Function SetCustom_CPU
  !insertmacro UMUI_ABORT_IF_INSTALLFLAG_IS ${UMUI_CANCELLED}
  !insertmacro SetNextButtonEnabled 0
  !insertmacro MUI_HEADER_TEXT "$(CPUTypeCaption)" "$(CPUTypeText)"

  StrCmp $CPU_TYPE "" 0 SkipCPUDetection

  ;-------------------------------
  
  !insertmacro DetectCPUType $CPU_TYPE $CPU_NAME $1
  
  !insertmacro TrimString $CPU_NAME $CPU_NAME
  !insertmacro RemoveMultiSpaces $CPU_NAME $CPU_NAME
  !insertmacro TrimString $1 $1
  !insertmacro RemoveMultiSpaces $1 $1

  ;-------------------------------

  WriteINIStr "$PLUGINSDIR\page_cpu.ini" "Field $CPU_TYPE" "State" "1"
  ReadINIStr $0 "$PLUGINSDIR\page_cpu.ini" "Field $CPU_TYPE" "Text"
  WriteINIStr "$PLUGINSDIR\page_cpu.ini" "Field $CPU_TYPE" "Text" "$0   <--   $(CPUDetected)"

  WriteINIStr "$PLUGINSDIR\page_cpu.ini" "Field 1" "Text" '"$(CPUTypePage)"'
  WriteINIStr "$PLUGINSDIR\page_cpu.ini" "Field 6" "Text" '"$(CPUTypeInfo)\n\n\n$(CPUName) $CPU_NAME\n$(CPUExtensions) $1"'

  ;-------------------------------

  SkipCPUDetection:
  
  !insertmacro SetNextButtonEnabled 1
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "page_cpu.ini"
FunctionEnd

!macro CheckProcessorSection sec_id target
  StrCpy $CPU_TYPE "${sec_id}"
  ReadINIStr $CPU_NAME "$PLUGINSDIR\page_cpu.ini" "Field $CPU_TYPE" "Text"
  ${StrTok} $CPU_NAME "$CPU_NAME" "<" "0" "1"
  !insertmacro TrimString $CPU_NAME $CPU_NAME
  ReadINIStr $R0 "$PLUGINSDIR\page_cpu.ini" "Field $CPU_TYPE" "State"
  StrCmp $R0 1 ${target}
!macroend

Function ValidateCustom_CPU
  !insertmacro UMUI_IF_INSTALLFLAG_IS ${UMUI_CANCELLED}
    Goto SKIP_CPU_VALIDATION
  !insertmacro UMUI_ENDIF_INSTALLFLAG

  !insertmacro CheckProcessorSection 2 CPU_WAS_SELECTED
  !insertmacro CheckProcessorSection 3 CPU_WAS_SELECTED
  !insertmacro CheckProcessorSection 4 CPU_WAS_SELECTED
  !insertmacro CheckProcessorSection 5 CPU_WAS_SELECTED

  MessageBox MB_ICONEXCLAMATION|MB_OK "$(CPUNotSelected)"
  Abort

  CPU_WAS_SELECTED:
  WriteRegStr HKLM "${MPlayer_RegPath}" "ProcessorType" "$CPU_TYPE"

  SKIP_CPU_VALIDATION:
FunctionEnd

; ---------------------------------------

!macro WriteTweakToReg sek_id
  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field ${sek_id}" "State"
  WriteRegStr HKLM "${MPlayer_RegPath}" "Tweak${sek_id}" $R0
!macroend

!macro ReadTweakFromReg sek_id
  !define ID ${__LINE__}

  ReadRegStr $R0 HKLM "${MPlayer_RegPath}" "Tweak${sek_id}"
  StrCmp $R0 "0" TweakFound_${ID}
  StrCmp $R0 "1" TweakFound_${ID}
  Goto TweakSkip_${ID}
  
  TweakFound_${ID}:
  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field ${sek_id}" "State" $R0
  
  TweakSkip_${ID}:
  !undef ID
!macroend

Function SetCustom_Tweaks
  !insertmacro UMUI_ABORT_IF_INSTALLFLAG_IS ${UMUI_CANCELLED}

  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field 1" "Text" '"$(TweaksPage)"'
  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field 2" "Text" '"$(TweaksCheck_DefaultLang)"'
  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field 3" "Text" '"$(TweaksCheck_SoftwareScale)"'
  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field 4" "Text" '"$(TweaksCheck_Normalize)"'
  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field 5" "Text" '"$(TweaksCheck_Passthrough)"'
  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field 6" "Text" '"$(TweaksCheck_OpenGL)"'
  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field 7" "Text" '"$(TweaksCheck_SkipDeblock)"'
  WriteINIStr "$PLUGINSDIR\page_tweak.ini" "Field 8" "Text" '"$(TweaksCheck_DVDMenu)"'

  !insertmacro ReadTweakFromReg 2
  !insertmacro ReadTweakFromReg 3
  !insertmacro ReadTweakFromReg 4
  !insertmacro ReadTweakFromReg 5
  !insertmacro ReadTweakFromReg 6
  !insertmacro ReadTweakFromReg 7
  !insertmacro ReadTweakFromReg 8

  !insertmacro MUI_HEADER_TEXT "$(TweaksCaption)" "$(TweaksText)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "page_tweak.ini"
FunctionEnd

Function ValidateCustom_Tweaks
  !insertmacro UMUI_IF_INSTALLFLAG_IS ${UMUI_CANCELLED}
    Goto SKIP_TWEAK_VALIDATION
  !insertmacro UMUI_ENDIF_INSTALLFLAG

  !insertmacro WriteTweakToReg 2
  !insertmacro WriteTweakToReg 3
  !insertmacro WriteTweakToReg 4
  !insertmacro WriteTweakToReg 5
  !insertmacro WriteTweakToReg 6
  !insertmacro WriteTweakToReg 7
  !insertmacro WriteTweakToReg 8
  
  SKIP_TWEAK_VALIDATION:
FunctionEnd

; ---------------------------------------
; Confirm Box
; ---------------------------------------

!macro CheckTweakChecked sek_id
  !define ID ${__LINE__}

  ReadINIStr $R0 "$PLUGINSDIR\page_tweak.ini" "Field ${sek_id}" "State"
  ReadINIStr $R1 "$PLUGINSDIR\page_tweak.ini" "Field ${sek_id}" "Text"
  StrCmp $R0 "1" 0 CheckTweakCheckedSkip_${ID}
  !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE "  ·$R1"
  
  CheckTweakCheckedSkip_${ID}:
  !undef ID
!macroend

Function ConfirmBox
  !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE "$(UMUI_TEXT_INSTCONFIRM_TEXTBOX_DESTINATION_LOCATION)"
  !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE "  '$INSTDIR'"
  !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE ""

  StrCpy $0 0
  StrCpy $1 ""
  StrCpy $2 ""
  StrCpy $3 ""
  
  Loop:
  StrCpy $1 $2
  StrCpy $2 $3
  ${StrTok} $3 "$SMPROGRAMS" "\/:" "$0" "1"
  IntOp $0 $0 + 1
  StrCmp $3 "" 0 Loop

  !insertmacro MUI_STARTMENU_WRITE_BEGIN startmenupage
    !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE "$(UMUI_TEXT_INSTCONFIRM_TEXTBOX_START_MENU_FOLDER)"
    !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE "  '$1\$2\$STARTMENU_FOLDER'"
    !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE ""
  !insertmacro MUI_STARTMENU_WRITE_END

  !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE "$(CPUTypeConfirm)"
  !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE "  ·$CPU_NAME"
  !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE ""

  !insertmacro UMUI_CONFIRMPAGE_TEXTBOX_ADDLINE "$(TweaksConfirm)"
  !insertmacro CheckTweakChecked 2
  !insertmacro CheckTweakChecked 3
  !insertmacro CheckTweakChecked 4
  !insertmacro CheckTweakChecked 5
  !insertmacro CheckTweakChecked 6
  !insertmacro CheckTweakChecked 7
  !insertmacro CheckTweakChecked 8
FunctionEnd

; ---------------------------------------
; Finish Page
; ---------------------------------------

!define Play_URL "http://extreme-high.rautemusik.fm/"

Function RunOnFinish
  IfFileExists "$INSTDIR\smplayer_portable.exe" 0 +3
  UAC::Exec '' '"$INSTDIR\smplayer_portable.exe" -actions pl_repeat "${Play_URL}"' '' ''
  Goto DoNotRunMPlayer

  IfFileExists "$INSTDIR\MPUI.exe" 0 +3
  UAC::Exec '' '"$INSTDIR\MPUI.exe" "${Play_URL}"' '' ''
  Goto DoNotRunMPlayer

  UAC::Exec '' '"$INSTDIR\MPlayer.exe" "${Play_URL}"' '' ''
  DoNotRunMPlayer:
FunctionEnd

Function OnSuccessFunc
  StrCmp $SETUP_COMPLETED "YES" 0 +3
  MessageBox MB_YESNO|MB_TOPMOST|MB_ICONQUESTION "$(AskCheckUpdate)" /SD IDNO IDNO +2
  Exec '"$INSTDIR\AutoUpdate.exe" /L=$LANGUAGE'
FunctionEnd


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; Finalization functions
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function .onInstSuccess
  Call OnSuccessFunc
  UAC::Unload ;Must call unload!
FunctionEnd

Function .onInstFailed
  UAC::Unload ;Must call unload!
FunctionEnd

Function un.onUninstSuccess
  UAC::Unload ;Must call unload!
FunctionEnd

Function un.onUninstFailed
  UAC::Unload ;Must call unload!
FunctionEnd


; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; EOF
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
