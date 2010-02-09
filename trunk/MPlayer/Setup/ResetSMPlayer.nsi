# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# // Attributes
# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

!packhdr "exehead.tmp" '"installer\upx.exe" --brute exehead.tmp"'

!include "StrFunc.nsh"
!include "FileFunc.nsh"

!insertmacro GetDrives

!ifndef Path_Builds
  !error "Path_Builds not specified!"
!endif

!ifndef Version_MPlayer
  !error "Version_MPlayer not specified!"
!endif

${StrRep}

XPStyle on
RequestExecutionLevel admin
InstallColors /windows

Name "MPlayer Reset"
Caption "Reset MPlayer Configuration"

SubCaption 0 " "
SubCaption 1 " "
SubCaption 2 " "
SubCaption 3 " "
SubCaption 4 " "

BrandingText "${__DATE__} / ${__TIME__}"
InstallButtonText "Set now!"
ShowInstDetails show

OutFile "ResetSMPlayer.exe"
Icon "${NSISDIR}\Contrib\Graphics\Icons\orange-install-nsis.ico"
CheckBitmap "${NSISDIR}\Contrib\Graphics\Checks\modern.bmp"
ChangeUI all "${NSISDIR}\Contrib\UIs\sdbarker_tiny.exe"

page instfiles

# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# // Macros
# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

!define SMWriteINIStr 'WriteINIStr "$EXEDIR\smplayer.ini"'

!macro SetPreference name value
  ${SMWriteINIStr} "%General" "${name}" "${value}"
!macroend

!macro SetMPlayer name value
  ${SMWriteINIStr} "mplayer_info" "${name}" "${value}"
!macroend

!macro SetAdvanced name value
  ${SMWriteINIStr} "advanced" "${name}" "${value}"
!macroend

!macro SetDirectories name value
  ${SMWriteINIStr} "directories" "${name}" "${value}"
!macroend

!macro SetDefault name value
  ${SMWriteINIStr} "defaults" "${name}" "${value}"
!macroend

!macro SetGUI name value
  ${SMWriteINIStr} "gui" "${name}" "${value}"
!macroend

!macro SetSubtitles name value
  ${SMWriteINIStr} "subtitles" "${name}" "${value}"
!macroend

!macro SetPerformance name value
  ${SMWriteINIStr} "performance" "${name}" "${value}"
!macroend

!macro SetInstances name value
  ${SMWriteINIStr} "instances" "${name}" "${value}"
!macroend

!macro SetDrives name value
  ${SMWriteINIStr} "drives" "${name}" "${value}"
!macroend

!macro ExecTimeout commandline timeout_ms terminate var_result var_exitcode
  Push ${terminate}
  Push ${timeout_ms}
  Push '${commandline}'
  
  Timeout::ExecTimeout

  Pop ${var_result}
  Pop ${var_exitcode}
!macroend

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

!macro GetNumberOfProcessors var_out
  !define ID ${__LINE__}
  SysInfo::GetNumberOfProcessors
  Pop ${var_out}
  IntCmp ${var_out} 1 GetNumberOfProcessorsSuccess_${ID} 0 GetNumberOfProcessorsSuccess_${ID}
  StrCpy ${var_out} 1
  GetNumberOfProcessorsSuccess_${ID}:
  !undef ID
!macroend

# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# // Sections
# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Section
  SetDetailsPrint textonly
  DetailPrint "Resetting MPlayer configuration, please wait..."
  SetDetailsPrint listonly
  
  InitPluginsDir
  
  MessageBox MB_YESNO|MB_ICONEXCLAMATION "Are you sure you want to reset all MPlayer settings now?" /SD IDYES IDYES DoResetMPlayer
  Quit

  ; -------------------------------------------------------------------
  
  DoResetMPlayer:
  
  IfFileExists "$EXEDIR\smplayer_portable.exe" 0 NoTerminateSMPlayer

  DetailPrint "Terminating SMPlayer, please wait..."
  WriteINIStr  "$EXEDIR\smplayer.ini" "instances" "use_single_instance" "true"
  WriteINIStr  "$EXEDIR\smplayer.ini" "instances" "use_autoport" "true"
  !insertmacro ExecTimeout '"$EXEDIR\smplayer_portable.exe" -send-action quit' 5000 1 $0 $1
  Sleep 1000  

  StrCmp $0 "error" 0 +2
  DetailPrint 'Error: Faild to run "$EXEDIR\smplayer_portable.exe"'

  StrCmp $0 "timeout" 0 +2
  DetailPrint "Warning: SMPlayer timed out!"
  
  ; -------------------------------------------------------------------

  NoTerminateSMPlayer:
  
  ClearErrors
  SetOutPath $EXEDIR

  Delete "$EXEDIR\MPUI.ini"
  Delete "$EXEDIR\smplayer.ini"
  Delete "$EXEDIR\mplayer\config"
  Delete "$EXEDIR\mplayer\*.conf"
  Delete "$EXEDIR\styles.ass"
  Delete "$EXEDIR\tv.m3u8"
  Delete "$EXEDIR\radio.m3u8"

  Delete "$APPDATA\mplayer\config"
  Delete "$APPDATA\mplayer\*.conf"
  Delete "$APPDATA\fontconfig\cache\*.*"

  Delete "$LOCALAPPDATA\mplayer\config"
  Delete "$LOCALAPPDATA\mplayer\*.conf"
  Delete "$LOCALAPPDATA\fontconfig\cache\*.*"
  
  Delete "$PROFILE\.smplayer\smplayer.ini"
  Delete "$PROFILE\.smplayer\styles.ass"
  Delete "$PROFILE\.smplayer\tv.m3u8"
  Delete "$PROFILE\.smplayer\radio.m3u8"
  Delete "$PROFILE\mplayer\config"
  Delete "$PROFILE\mplayer\*.conf"
  Delete "$PROFILE\fontconfig\cache\*.*"

  ; -------------------------------------------------------------------
    
  StrCmp $LOCALAPPDATA "" SkipVStoreClean 0
  File /oname=$PLUGINSDIR\cleaner.exe "installer\cleaner.exe"
  nsExec::ExecToLog /TIMEOUT=30000 '"$PLUGINSDIR\cleaner.exe" "$LOCALAPPDATA\VirtualStore" "MPUI.ini:SMPlayer.ini:styles.ass:tv.m3u8:radio.m3u8:config"'
  Delete "$PLUGINSDIR\cleaner.exe"
  
  SkipVStoreClean:
  
  ; -------------------------------------------------------------------

  SetOutPath $EXEDIR
  File "installer\radio.m3u8"
  
  SetOutPath "$EXEDIR\mplayer"
  File "installer\config"
  File "installer\codecs.conf"
  File "${Path_Builds}\rtm\mplayer\input.conf"

  SetFileAttributes "$EXEDIR\mplayer\config" FILE_ATTRIBUTE_READONLY
  SetFileAttributes "$EXEDIR\mplayer\codecs.conf" FILE_ATTRIBUTE_READONLY

  !insertmacro MakeFilePublic "$EXEDIR\MPUI.ini"
  !insertmacro MakeFilePublic "$EXEDIR\mplayer\config"
  !insertmacro MakeFilePublic "$EXEDIR\smplayer.ini"
  !insertmacro MakeFilePublic "$EXEDIR\styles.ass"
  !insertmacro MakeFilePublic "$EXEDIR\tv.m3u8"
  !insertmacro MakeFilePublic "$EXEDIR\radio.m3u8"

  ; -------------------------------------------------------------------

  SetOutPath $EXEDIR
  DetailPrint "Modifying: $EXEDIR\smplayer.ini"

  SetShellVarContext all

  ; -------------------------------------------------------------------

  !insertmacro SetPreference "mplayer_bin" "MPlayer.exe"
  !insertmacro SetPreference "dont_remember_time_pos" "true"
  !insertmacro SetPreference "dont_remember_media_settings" "true"
  !insertmacro SetPreference "use_volume_option" "1"
  !insertmacro SetPreference "dont_change_volume" "false"
  ${StrRep} $0 "$PICTURES" "\" "/"
  !insertmacro SetPreference "screenshot_directory" "$0"
  !insertmacro SetPreference "use_scaletempo" "0"
  !insertmacro SetPreference "osd" "1"
  !insertmacro SetPreference "use_soft_vol" "false"

  ; -------------------------------------------------------------------

  StrCpy $0 "${Version_MPlayer}" 5 5
  !insertmacro SetMPlayer "mplayer_detected_version" "$0"
  !insertmacro SetMPlayer "mplayer_user_supplied_version" "$0"
  
  ; -------------------------------------------------------------------

  !insertmacro SetAdvanced "use_short_pathnames" "true"

  ; -------------------------------------------------------------------

  ${StrRep} $0 "$VIDEOS" "\" "/"
  !insertmacro SetDirectories "latest_dir" "$0"

  ; -------------------------------------------------------------------

  !insertmacro SetDefault "initial_volume" "100"
  !insertmacro SetDefault "initial_volnorm" "false"
  !insertmacro SetDefault "initial_deinterlace" "0"
  !insertmacro SetDefault "initial_postprocessing" "false"
  !insertmacro SetDefault "initial_contrast" "0"
  !insertmacro SetDefault "initial_brightness" "0"
  !insertmacro SetDefault "initial_hue" "0"
  !insertmacro SetDefault "initial_saturation" "0"
  !insertmacro SetDefault "initial_gamma" "0"

  ; -------------------------------------------------------------------

  !insertmacro SetGUI "style" "Plastique"
  !insertmacro SetGUI "iconset" "Oxygen-Refit"
  !insertmacro SetGUI "update_while_seeking" "true"
  !insertmacro SetGUI "report_mplayer_crashes" "false"

  ; -------------------------------------------------------------------

  !insertmacro SetSubtitles "font_name" "Tahoma"
  !insertmacro SetSubtitles "use_fontconfig" "false"
  ${StrRep} $0 "$EXEDIR" "\" "/"
  !insertmacro SetSubtitles "font_file" "$0/mplayer/subfont.ttf"
  
  ; -------------------------------------------------------------------
 
  !insertmacro SetPerformance "frame_drop" "true"
  !insertmacro SetPerformance "hard_frame_drop" "false"
  !insertmacro GetNumberOfProcessors $0
  !insertmacro SetPerformance "threads" "$0"
   
  ; -------------------------------------------------------------------

  !insertmacro SetInstances "use_single_instance" "true"
  !insertmacro SetInstances "connection_port" "8000"
  !insertmacro SetInstances "use_autoport" "true"

  ; -------------------------------------------------------------------

  StrCpy $R0 ""
  ${GetDrives} "CDROM" "GetDrivesCallback"
  StrCmp $R0 "" NoCDRomFound
  
  !insertmacro SetDrives "dvd_device" "$R0"
  !insertmacro SetDrives "cdrom_device" "$R0"

  NoCDRomFound:

  ; -------------------------------------------------------------------

  IfSilent NoUpdateFontCache

  SetDetailsPrint textonly
  DetailPrint "Updating MPlayer font cache, please wait..."
  SetDetailsPrint listonly
  
  DetailPrint 'Exec: "$EXEDIR\MPlayer.exe" -fontconfig -ass -vo null -ao null "$EXEDIR\mplayer\sample.avi"'
  nsExec::Exec /TIMEOUT=30000 '"$EXEDIR\MPlayer.exe" -fontconfig -ass -vo null -ao null "$EXEDIR\mplayer\sample.avi"'

  NoUpdateFontCache:
  
  ; -------------------------------------------------------------------
  
  IfErrors 0 NoErrorsOccurred

  SetDetailsPrint textonly
  DetailPrint "Stopped. Errors have been detected!"
  SetDetailsPrint listonly

  MessageBox MB_ICONSTOP "Error: Faild to reset the MPlayer configuration! Problems might occure..."
  Quit
  
  NoErrorsOccurred:
  
  ; -------------------------------------------------------------------

  SetDetailsPrint textonly
  DetailPrint "MPlayer configuration has been reset!"
  SetDetailsPrint listonly
  
  ;SetAutoClose true
  MessageBox MB_ICONINFORMATION "MPlayer configuration has been reset successfully!" /SD IDOK
SectionEnd

Function GetDrivesCallback
  StrCpy $R0 $9 2
  StrCpy $0 "StopGetDrives"
  Push $0
FunctionEnd
