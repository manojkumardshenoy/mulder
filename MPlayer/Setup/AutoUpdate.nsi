!packhdr "exehead.tmp" '"installer/upx.exe" --brute exehead.tmp'

XPStyle on
InstallColors /windows
RequestExecutionLevel user

Name "MPlayer for Windows - Auto Update"
Caption "MPlayer for Windows - Auto Update"

!include FileFunc.nsh
!include installer\GetParameters.nsh

!define MPlayer_RegPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DB9E4EAB-2717-499F-8D56-4CC8A644AB60}"

SubCaption 0 " "
SubCaption 1 " "
SubCaption 2 " "
SubCaption 3 " "
SubCaption 4 " "

BrandingText "${__DATE__} / ${__TIME__}"
AutoCloseWindow true
ShowInstDetails nevershow

OutFile "AutoUpdate.exe"
Icon "${NSISDIR}\Contrib\Graphics\Icons\orange-install-nsis.ico"
CheckBitmap "${NSISDIR}\Contrib\Graphics\Checks\modern.bmp"

Page instfiles

;--------------------------------

LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\German.nlf"

LangString DownloadAborted ${LANG_ENGLISH} "The download was aborted by user!"
LangString DownloadAborted ${LANG_GERMAN} "Der Download wurde vom Benutzer abgebrochen!"

LangString DownloadFailed ${LANG_ENGLISH} "Download failed:"
LangString DownloadFailed ${LANG_GERMAN} "Download fehlgeschlagen:"

LangString CheckConnection ${LANG_ENGLISH} "Please check your internet connection and try again!"
LangString CheckConnection ${LANG_GERMAN} "Überprüfen Sie Ihre Internet Verbindungen und versuchen Sie es noch einmal!"

LangString VersionInfoMissing ${LANG_ENGLISH} "Cannot continued with update, because version information are missing!"
LangString VersionInfoMissing ${LANG_GERMAN} "Update kann nicht fortgesetzt werden, da Versions Informationen fehlen!"

LangString CheckingUpdates ${LANG_ENGLISH} "Checking for new updates, please wait..."
LangString CheckingUpdates ${LANG_GERMAN} "Suche nach neuen Updates, bitte warten..."

LangString AutoupdateDatMissing ${LANG_ENGLISH} "Cannot check for updates, because file 'AutoUpdate.dat' could not be found!"
LangString AutoupdateDatMissing ${LANG_GERMAN} "Es kann nicht nach Updates gesucht werden, da die Datei 'AutoUpdate.dat' fehlt!"

LangString StillUpToDate ${LANG_ENGLISH} "Your version of MPlayer for Windows is still up-to-date. No update required."
LangString StillUpToDate ${LANG_GERMAN} "Ihre Version von MPlayer für Windows ist noch aktuell. Kein Update notwendig."

LangString UnknownVersion ${LANG_ENGLISH} "Your version of MPlayer for Windows is newer than the lastest release version!"
LangString UnknownVersion ${LANG_GERMAN} "Ihre Version von MPlayer für Windows ist neuer als die neuste offizielle Version!"

LangString UpdateAvailable ${LANG_ENGLISH} "A new version of MPlayer for Windows is available! Download and install now?"
LangString UpdateAvailable ${LANG_GERMAN} "Eine neue Version von MPlayer für Windows ist verfügbar. Jetzt herunterladen und installieren?"

LangString DownloadUpdates ${LANG_ENGLISH} "Updates are being downloaded, please wait..."
LangString DownloadUpdates ${LANG_GERMAN} "Updates werden heruntergeladen, bitte warten..."

LangString InstallUpdates ${LANG_ENGLISH} "Installing new version of MPlayer, please be patient..."
LangString InstallUpdates ${LANG_GERMAN} "Die neue MPlayer Version wird installiert, bitte warten..."

LangString NotAllowedToUpdate ${LANG_ENGLISH} "You don't have the required access rights to update MPlayer for Windows.$\nPlease log in with an admin account or ask your administartor for help!"
LangString NotAllowedToUpdate ${LANG_GERMAN} "Sie haben nicht die benötigten Rechte, um MPlayer für Windows zu aktualisieren.$\nBitte verwenden Sie ein Admin Benutzerkonto oder bitten Sie Ihren Administartor um Hilfe!"

LangString BuildInstalled ${LANG_ENGLISH}  "The currently installed build is:"
LangString BuildInstalled ${LANG_GERMAN} "Das derzeit installierte Build ist:"

LangString BuildLatest ${LANG_ENGLISH} "The latest build available is:"
LangString BuildLatest ${LANG_GERMAN} "Das neuste verfügbare Build ist:"

LangString UpdateReminder ${LANG_ENGLISH} "Your version of 'MPlayer for Windows' might be outdated!$\nDo you want to check for new updates online now? (Recommended)"
LangString UpdateReminder ${LANG_GERMAN} "Ihre Version von 'MPlayer für Windows' könnte veraltet sein!$\nMöchten Sie jetzt online nach neuen  Updates suchen? (Empfohlen)"

LangString SigInvalid ${LANG_ENGLISH} "Signature seems to be invalid. Download may be malicious. Aborting!"
LangString SigInvalid ${LANG_GERMAN} "Die Signatur ist ungültig. Der Download könnte bösartig sein. Abbruch!"

;--------------------------------

!macro PrintStatus text
  SetDetailsPrint textonly
  DetailPrint "${text}"
  SetDetailsPrint listonly
!macroend

!macro DownloadFileGet dl_url destfile
  inetc::get /SILENT "${dl_url}" "${destfile}"

  Pop $R0
  StrCmp $R0 "OK" +6
  StrCmp $R0 "Cancelled" 0 +3
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DownloadAborted)"
  Goto +2
  MessageBox MB_OK|MB_ICONSTOP "$(DownloadFailed) $R0$\n$(CheckConnection)"
  Quit
!macroend

!macro DownloadFilePost dl_url dl_post destfile
  inetc::post "${dl_post}" "${dl_url}" "${destfile}"

  Pop $R0
  StrCmp $R0 "OK" +6
  StrCmp $R0 "Cancelled" 0 +3
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DownloadAborted)"
  Goto +2
  MessageBox MB_OK|MB_ICONSTOP "$(DownloadFailed) $R0$\n$(CheckConnection)"
  Quit
!macroend

!macro CheckString str
  StrCmp "${str}" "" 0 +3
  MessageBox MB_ICONSTOP "$(VersionInfoMissing)"
  Quit
!macroend

!macro VerifySignature var_out subject_file sign_file
  File "/oname=$PLUGINSDIR\gpgv.exe" "Installer\gpgv.exe"
  File "/oname=$PLUGINSDIR\myring.gpg" "Installer\pubring.gpg"
  
  nsExec::ExecToLog '"$PLUGINSDIR\gpgv.exe" --homedir "$PLUGINSDIR" --keyring "$PLUGINSDIR\myring.gpg" "${sign_file}" "${subject_file}"'
  Pop ${var_out}
  
  Delete "${sign_file}"
  Delete "$PLUGINSDIR\myring.gpg"
  Delete "$PLUGINSDIR\gpgv.exe"
  
  StrCmp ${var_out} "0" +4
  Delete "${subject_file}"
  MessageBox MB_ICONSTOP|MB_TOPMOST "$(SigInvalid)"
  Quit
!macroend

Section ""
  InitPluginsDir
  SetOutPath $PLUGINSDIR

  ;-------------------
  
  !insertmacro PrintStatus "$(CheckingUpdates)"
  
  IfFileExists "$EXEDIR\AutoUpdate.dat" +3
  MessageBox MB_ICONSTOP "$(AutoupdateDatMissing)"
  Quit
  
  ReadINIStr $0 "$EXEDIR\AutoUpdate.dat" "AutoUpdate" "BuildNo"
  !insertmacro CheckString $0
  
  !insertmacro DownloadFileGet "http://mulder.dummwiedeutsch.de/update.ver" "$PLUGINSDIR\update.tmp"
  !insertmacro DownloadFileGet "http://mulder.dummwiedeutsch.de/update.ver.sig" "$PLUGINSDIR\update.tmp.sig"
  !insertmacro VerifySignature $9 "$PLUGINSDIR\update.tmp" "$PLUGINSDIR\update.tmp.sig"

  ReadINIStr $1 "$PLUGINSDIR\update.tmp" "MPlayer for Windows" "BuildNo"
  ReadINIStr $2 "$PLUGINSDIR\update.tmp" "MPlayer for Windows" "DownloadAddress"
  ReadINIStr $3 "$PLUGINSDIR\update.tmp" "MPlayer for Windows" "DownloadFilename"
  ReadINIStr $4 "$PLUGINSDIR\update.tmp" "MPlayer for Windows" "DownloadFilecode"
  Delete "$PLUGINSDIR\update.tmp"

  !insertmacro CheckString $1
  !insertmacro CheckString $2
  !insertmacro CheckString $3
  !insertmacro CheckString $4
  
  GetDay::GetCurrentDay
  Pop $5
  WriteRegDWORD HKCU "${MPlayer_RegPath}" "LastUpdateCheck" $5
  
  IntCmp $0 $1 0 update_available unknown_version
  MessageBox MB_ICONINFORMATION "$(StillUpToDate)"
  Quit  
  
  unknown_version:
  MessageBox MB_ICONSTOP "$(UnknownVersion)$\n$\n$(BuildInstalled) $0$\n$(BuildLatest) $1"
  Quit  
  
  update_available:
  MessageBox MB_ICONEXCLAMATION|MB_YESNO "$(UpdateAvailable)$\n$\n$(BuildInstalled) $0$\n$(BuildLatest) $1" IDYES +2
  Quit

  !insertmacro PrintStatus "$(DownloadUpdates)"
  SetOutPath "$PLUGINSDIR\update"

  !insertmacro DownloadFilePost "$2" "file_name=$3&file_code=$4" "$PLUGINSDIR\update\$3"
  !insertmacro DownloadFilePost "$2" "sign_name=$3" "$PLUGINSDIR\update\$3.sig"
  !insertmacro VerifySignature $9 "$PLUGINSDIR\update\$3" "$PLUGINSDIR\update\$3.sig"
  
  !insertmacro PrintStatus "$(InstallUpdates)"
  Sleep 1000  

  Exec '"$PLUGINSDIR\update\$3" /UPDATE /D=$EXEDIR'
  Delete /REBOOTOK "$PLUGINSDIR\update\$3"
SectionEnd

Function .onInit
  InitPluginsDir

  !insertmacro GetCommandlineParameter "L" "error" $0
  StrCmp $0 "error" ShowLangDialog
  StrCpy $LANGUAGE $0
  Goto LangSelectDone
  
  ShowLangDialog:
  Push ""
  Push ${LANG_ENGLISH}
  Push English
  Push ${LANG_GERMAN}
  Push German
  Push A ; A means auto count languages

  LangDLL::LangDialog "Installer Language" "Please select the language of the installer"
  Pop $LANGUAGE
  StrCmp $LANGUAGE "cancel" 0 +2
  Abort
  
  LangSelectDone:
  !insertmacro GetCommandlineParameter "TASK" "error" $0
  StrCmp $0 "error" NoAutoTask
  GetDay::GetCurrentDay
  Pop $0
  ReadRegDWORD $1 HKCU "${MPlayer_RegPath}" "LastUpdateCheck"
  IntOp $1 $1 + 13
  IntCmp $0 $1 0 0 CheckUpdateRequired
  Quit
  
  CheckUpdateRequired:
  MessageBox MB_TOPMOST|MB_ICONEXCLAMATION|MB_YESNO "$(UpdateReminder)" IDYES NoAutoTask
  IntOp $0 $0 - 13
  WriteRegDWORD HKCU "${MPlayer_RegPath}" "LastUpdateCheck" $0
  Quit
  
  NoAutoTask:
FunctionEnd
