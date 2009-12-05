!packhdr "exehead.tmp" '"installer\upx.exe" --brute exehead.tmp'

XPStyle on
InstallColors /windows

Name "MPlayer File Associations"
Caption "MPlayer File Associations"

SubCaption 0 " "
SubCaption 1 " "
SubCaption 2 " "
SubCaption 3 " "
SubCaption 4 " "

BrandingText "${__DATE__} / ${__TIME__}"
InstallButtonText "Set now!"
ShowInstDetails show
AutoCloseWindow false

ComponentText "Choose the file types you want to modify:" "" "File Types:"

OutFile "SetFileAssoc.exe"
Icon "${NSISDIR}\Contrib\Graphics\Icons\orange-install-nsis.ico"
CheckBitmap "${NSISDIR}\Contrib\Graphics\Checks\modern.bmp"
ChangeUI all "${NSISDIR}\Contrib\UIs\sdbarker_tiny.exe"

Page custom SetCustomPage ValidateCustomPage
Page components
Page instfiles

Var mode
Var extlist

!include installer\GetParameters.nsh

!macro PrintStatus stext
  SetDetailsPrint textonly
  DetailPrint "${stext}"
  SetDetailsPrint listonly
!macroend

!macro AppendExt new_ext
  StrCmp $extlist "" +2
  StrCpy $extlist "$extlist,"
  StrCpy $extlist "$extlist${new_ext}"
!macroend


!macro ChangeRegValue root_key key_name value_name backup_name new_value
  !define IDX ${__LINE__}

  ReadRegStr $0 ${root_key} "${key_name}" "${value_name}"
  StrCmp $0 "${new_value}" skip_change_value_${IDX}
  
  WriteRegStr ${root_key} "${key_name}" "${value_name}" "${new_value}"
  StrCmp $0 "" +2
  WriteRegStr ${root_key} "${key_name}" "${backup_name}" $0
  DetailPrint "-> Value changed to: ${new_value}"
  Goto change_value_done_${IDX}
  
  skip_change_value_${IDX}:
  DetailPrint "-> Value already set, skipping..."
  
  change_value_done_${IDX}:
  !undef IDX
!macroend

!macro RevertRegValue root_key key_name value_name backup_name check_value
  !define IDX ${__LINE__}

  ReadRegStr $0 ${root_key} "${key_name}" "${value_name}" ;read current value
  ReadRegStr $1 ${root_key} "${key_name}" "${backup_name}" ;read backup value
  DeleteRegValue ${root_key} "${key_name}" "${backup_name}" ;remove backup

  StrCmp $0 "${check_value}" do_restore_value_${IDX} ;restore if associated with MPlayer
  StrCmp $1 "" 0 do_restore_value_${IDX} ;restore if backup is not empty
  Goto skip_restore_value_${IDX} ;no need to restore, skip
  
  do_restore_value_${IDX}:
  StrCmp $1 "" noback_restore_value_${IDX} ;can't restore old value, if no backup exists
  StrCmp $1 "${check_value}" noback_restore_value_${IDX} ;don't restore old value, if backup equals current value
  WriteRegStr ${root_key} "${key_name}" "${value_name}" $1 ;restore old value
  DetailPrint "-> Value was restored to: $1"
  Goto restore_value_done_${IDX}
  
  skip_restore_value_${IDX}:
  DetailPrint "-> Nothing to do, skipping..."
  Goto restore_value_done_${IDX}
  
  noback_restore_value_${IDX}:
  DeleteRegValue ${root_key} "${key_name}" "${value_name}" ;delete value, not restoring backup
  DetailPrint "-> No backup found, value removed!"
  Goto restore_value_done_${IDX}

  restore_value_done_${IDX}:
  !undef IDX
!macroend

!macro CreateType type name
  !define ID ${__LINE__}

  StrCmp $mode "smplayer" do_type_smplayer_${ID}
  StrCmp $mode "mpui" do_type_mpui_${ID}
  StrCmp $mode "revert" do_type_done_${ID}

  Abort

  
  ;--------------------------------------------
  do_type_mpui_${ID}:
  ;--------------------------------------------

  DetailPrint "Creating file type: ${type}"
  DetailPrint "-> Target application: MPUI.exe"

  DeleteRegKey HKCR "${type}"

  WriteRegStr HKCR "${type}" "" "${name}"
  WriteRegStr HKCR "${type}\DefaultIcon" "" "$EXEDIR\MPUI.exe,0"
  WriteRegStr HKCR "${type}\shell" "" "open"
  WriteRegStr HKCR "${type}\shell\open" "FriendlyAppName" "MPlayer for Windows (MPUI)"
  WriteRegStr HKCR "${type}\shell\open\command" "" '"$EXEDIR\MPUI.exe" "%1"'
  WriteRegStr HKCR "${type}\shell\enqueue" "" "Enqueue in MPUI"
  WriteRegStr HKCR "${type}\shell\enqueue\command" "" '"$EXEDIR\MPUI.exe" -enqueue "%1"'

  Goto do_type_done_${ID}

  
  ;--------------------------------------------
  do_type_smplayer_${ID}:
  ;--------------------------------------------

  DetailPrint "Creating file type: ${type}"
  DetailPrint "-> Target application: smplayer_portable.exe"

  DeleteRegKey HKCR "${type}"

  WriteRegStr HKCR "${type}" "" "${name}"
  WriteRegStr HKCR "${type}\DefaultIcon" "" "$EXEDIR\smplayer_portable.exe,1"
  WriteRegStr HKCR "${type}\shell" "" "open"
  WriteRegStr HKCR "${type}\shell\open" "FriendlyAppName" "MPlayer for Windows (SMPlayer)"
  WriteRegStr HKCR "${type}\shell\open\command" "" '"$EXEDIR\smplayer_portable.exe" "%1"'
  WriteRegStr HKCR "${type}\shell\enqueue" "" "Enqueue in SMPlayer"
  WriteRegStr HKCR "${type}\shell\enqueue\command" "" '"$EXEDIR\smplayer_portable.exe" -add-to-playlist "%1"'

  Goto do_type_done_${ID}
  
  
  ;--------------------------------------------
  do_type_done_${ID}:
  ;--------------------------------------------

  !undef ID
!macroend

!macro Associate extension type
  !define ID ${__LINE__}

  StrCmp $mode "smplayer" associate_create_${ID}
  StrCmp $mode "mpui" associate_create_${ID}
  StrCmp $mode "revert" associate_revert_${ID}
  
  Abort
  
  ;--------------------------------------------------------------------------------------
  associate_create_${ID}:
  ;--------------------------------------------------------------------------------------
  
  DetailPrint "Creating asscociation for: ${extension}"

  DeleteRegKey HKCR ".${extension}\OpenWithList"
  DeleteRegKey HKCR ".${extension}\OpenWithProgids"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.${extension}\OpenWithList"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.${extension}\OpenWithProgids"

  !insertmacro ChangeRegValue HKCR ".${extension}" "" "MPlayer_Backup" "${type}"
  !insertmacro ChangeRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.${extension}" "Progid" "MPlayer_Backup_Progid" "${type}"
  !insertmacro ChangeRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.${extension}" "Application" "MPlayer_Backup_Application" "MPlayer.exe"

  !insertmacro AppendExt ${extension}
  Goto associate_complete_${ID}

  ;--------------------------------------------------------------------------------------
  associate_revert_${ID}:
  ;--------------------------------------------------------------------------------------

  DetailPrint "Restoring asscociation for: ${extension}"

  DeleteRegKey HKCR ".${extension}\OpenWithList"
  DeleteRegKey HKCR ".${extension}\OpenWithProgids"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.${extension}\OpenWithList"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.${extension}\OpenWithProgids"

  !insertmacro RevertRegValue HKCR ".${extension}" "" "MPlayer_Backup" "${type}"
  !insertmacro RevertRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.${extension}" "Progid" "MPlayer_Backup_Progid" "${type}"
  !insertmacro RevertRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.${extension}" "Application" "MPlayer_Backup_Application" "MPlayer.exe"

  Goto associate_complete_${ID}

  ;--------------------------------------------------------------------------------------
  associate_complete_${ID}:
  ;--------------------------------------------------------------------------------------
  
  System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'
  !undef ID
!macroend

Section
  StrCpy $extlist ""
  
  StrCpy $mode "smplayer"
  ReadINIStr $0 "$PLUGINSDIR\page_ext.ini" "Field 2" "State"
  StrCmp $0 "1" mode_select_done

  StrCpy $mode "mpui"
  ReadINIStr $0 "$PLUGINSDIR\page_ext.ini" "Field 3" "State"
  StrCmp $0 "1" mode_select_done
  
  StrCpy $mode "revert"
  ReadINIStr $0 "$PLUGINSDIR\page_ext.ini" "Field 4" "State"
  StrCmp $0 "1" mode_select_done

  Abort
  
  mode_select_done:
SectionEnd

Section "Video Files (AVI, MPEG, MP4, etc.)"
  !insertmacro PrintStatus "Setting asscociations for Video files..."
  
  !insertmacro CreateType "MPlayerFileVideo" "MPlayer Video File"
  
  !insertmacro Associate "26l" "MPlayerFileVideo"
  !insertmacro Associate "3gp" "MPlayerFileVideo"
  !insertmacro Associate "asf" "MPlayerFileVideo"
  !insertmacro Associate "avi" "MPlayerFileVideo"
  !insertmacro Associate "bin" "MPlayerFileVideo"
  !insertmacro Associate "dat" "MPlayerFileVideo"
  !insertmacro Associate "divx" "MPlayerFileVideo"
  !insertmacro Associate "dv" "MPlayerFileVideo"
  !insertmacro Associate "evo" "MPlayerFileVideo"
  !insertmacro Associate "flv" "MPlayerFileVideo"
  !insertmacro Associate "iso" "MPlayerFileVideo"
  !insertmacro Associate "jsv" "MPlayerFileVideo"
  !insertmacro Associate "m1v" "MPlayerFileVideo"
  !insertmacro Associate "m2p" "MPlayerFileVideo"
  !insertmacro Associate "m2v" "MPlayerFileVideo"
  !insertmacro Associate "m4v" "MPlayerFileVideo"
  !insertmacro Associate "mkv" "MPlayerFileVideo"
  !insertmacro Associate "mov" "MPlayerFileVideo"
  !insertmacro Associate "mp4" "MPlayerFileVideo"
  !insertmacro Associate "mpe" "MPlayerFileVideo"
  !insertmacro Associate "mpeg" "MPlayerFileVideo"
  !insertmacro Associate "mpg" "MPlayerFileVideo"
  !insertmacro Associate "mpv" "MPlayerFileVideo"
  !insertmacro Associate "mqv" "MPlayerFileVideo"
  !insertmacro Associate "nsv" "MPlayerFileVideo"
  !insertmacro Associate "ogm" "MPlayerFileVideo"
  !insertmacro Associate "pva" "MPlayerFileVideo"
  !insertmacro Associate "qt" "MPlayerFileVideo"
  !insertmacro Associate "ra" "MPlayerFileVideo"
  !insertmacro Associate "ram" "MPlayerFileVideo"
  !insertmacro Associate "rm" "MPlayerFileVideo"
  !insertmacro Associate "rmvb" "MPlayerFileVideo"
  !insertmacro Associate "ts" "MPlayerFileVideo"
  !insertmacro Associate "vcd" "MPlayerFileVideo"
  !insertmacro Associate "vfw" "MPlayerFileVideo"
  !insertmacro Associate "vob" "MPlayerFileVideo"
  !insertmacro Associate "wmv" "MPlayerFileVideo"
SectionEnd

Section "Audio Files (MP3, WAV, WMA, etc.)"
  !insertmacro PrintStatus "Setting asscociations for Audio files..."
  
  !insertmacro CreateType "MPlayerFileAudio" "MPlayer Audio File"

  !insertmacro Associate "aac" "MPlayerFileAudio"
  !insertmacro Associate "ac3" "MPlayerFileAudio"
  !insertmacro Associate "aiff" "MPlayerFileAudio"
  !insertmacro Associate "ape" "MPlayerFileAudio"
  !insertmacro Associate "fla" "MPlayerFileAudio"
  !insertmacro Associate "flac" "MPlayerFileAudio"
  !insertmacro Associate "m4a" "MPlayerFileAudio"
  !insertmacro Associate "mka" "MPlayerFileAudio"
  !insertmacro Associate "mp1" "MPlayerFileAudio"
  !insertmacro Associate "mp2" "MPlayerFileAudio"
  !insertmacro Associate "mp3" "MPlayerFileAudio"
  !insertmacro Associate "mp+" "MPlayerFileAudio"
  !insertmacro Associate "mpa" "MPlayerFileAudio"
  !insertmacro Associate "mpc" "MPlayerFileAudio"
  !insertmacro Associate "mpp" "MPlayerFileAudio"
  !insertmacro Associate "nsa" "MPlayerFileAudio"
  !insertmacro Associate "ogg" "MPlayerFileAudio"
  !insertmacro Associate "spx" "MPlayerFileAudio"
  !insertmacro Associate "wav" "MPlayerFileAudio"
  !insertmacro Associate "wma" "MPlayerFileAudio"
  !insertmacro Associate "wv" "MPlayerFileAudio"
SectionEnd

Section "Playlist Files (M3U, PLS, ASX, etc.)"
  !insertmacro PrintStatus "Setting asscociations for Playlist files..."

  !insertmacro CreateType "MPlayerFileList" "MPlayer Playlist File"

  !insertmacro Associate "asx" "MPlayerFileList"
  !insertmacro Associate "fpl" "MPlayerFileList"
  !insertmacro Associate "m3u" "MPlayerFileList"
  !insertmacro Associate "mpcpl" "MPlayerFileList"
  !insertmacro Associate "pls" "MPlayerFileList"
  !insertmacro Associate "pls" "MPlayerFileList"
  !insertmacro Associate "ram" "MPlayerFileList"
  !insertmacro Associate "wpl" "MPlayerFileList"
SectionEnd

Section
  StrCmp $mode "mpui" success_changed
  StrCmp $mode "smplayer" success_changed
  StrCmp $mode "revert" success_reverted
  
  success_changed:
  !insertmacro PrintStatus "File asscociations have been changed successfully!"
  Goto success_done
  
  success_reverted:
  !insertmacro PrintStatus "File asscociations have been reverted successfully!"
  Goto success_done

  success_done:
  WriteINIStr "$EXEDIR\smplayer.ini" "associations" "extensions" '"$extlist"'
  System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'
SectionEnd

Function SetCustomPage
  InstallOptions::dialog "$PLUGINSDIR\page_ext.ini"
FunctionEnd

Function ValidateCustomPage
  ReadINIStr $0 "$PLUGINSDIR\page_ext.ini" "Field 2" "State"
  StrCmp $0 "1" check_for_smplayer
  ReadINIStr $0 "$PLUGINSDIR\page_ext.ini" "Field 3" "State"
  StrCmp $0 "1" check_for_mpui
  ReadINIStr $0 "$PLUGINSDIR\page_ext.ini" "Field 4" "State"
  StrCmp $0 "1" check_for_done
  Abort

  check_for_smplayer:
  IfFileExists "$EXEDIR\smplayer_portable.exe" check_for_done
  MessageBox MB_ICONSTOP "Sorry, the file 'smplayer_portable.exe' cannot be found in current directory!"
  Abort

  check_for_mpui:
  IfFileExists "$EXEDIR\MPUI.exe" check_for_done
  MessageBox MB_ICONSTOP "Sorry, the file 'MPUI.exe' cannot be found in current directory!"
  Abort
  
  check_for_done:
FunctionEnd

Function .onInit
  InitPluginsDir
  File /oname=$PLUGINSDIR\page_ext.ini "installer\page_ext.ini"

  !insertmacro GetCommandlineParameter "MODE" "error" $0
  StrCmp $0 "smplayer" set_mode_smplayer
  StrCmp $0 "mpui" set_mode_mpui
  StrCmp $0 "restore" set_mode_restore
  
  IfFileExists "$EXEDIR\smplayer_portable.exe" set_mode_smplayer
  IfFileExists "$EXEDIR\MPUI.exe" set_mode_mpui
  Goto set_mode_restore

  set_mode_restore:
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 2" "State" "0"
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 3" "State" "0"
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 4" "State" "1"
  Goto set_mode_done

  set_mode_mpui:
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 2" "State" "0"
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 3" "State" "1"
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 4" "State" "0"
  Goto set_mode_done

  set_mode_smplayer:
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 2" "State" "1"
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 3" "State" "0"
  WriteINIStr "$PLUGINSDIR\page_ext.ini" "Field 4" "State" "0"
  Goto set_mode_done
  
  set_mode_done:
FunctionEnd

Function .onInstSuccess
  StrCmp $mode "revert" +2
  MessageBox MB_OK|MB_ICONINFORMATION|MB_SETFOREGROUND "Note: You can run this tool again in order to restore your old file associations!" /SD IDOK
FunctionEnd
