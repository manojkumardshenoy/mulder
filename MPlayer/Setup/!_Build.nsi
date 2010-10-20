; ////////////////////////////////////////////////////////////////
; // MPlayer for Windows - Install Script
; // Written by MuldeR <MuldeR2@GMX.de> - http://mulder.at.gg/
; // Developed and tested with NSIS v2.46
; ////////////////////////////////////////////////////////////////

!define BUILD_NO "81"
!define COMPILE_DATE "2010-10-17"
!define VER_MPLAYER "SVN-r32492 (2010-10-14)"
!define VER_SMPLAYER "v0.6.9 (SVN-r3584)"
!define VER_MPUI "v1.2-pre3 (Build 38)"
!define VER_NSIS "v2.46"
!define VER_CODECS "(2007-10-07)"

; ----------------------------------------------------------------------------------------------

!define PATH_OUT "E:\MPUI\upload\MPUI.${COMPILE_DATE}.Build-${BUILD_NO}"
!define PATH_BUILDS "E:\MPUI\builds"

!system 'md "${PATH_OUT}"'

; ----------------------------------------------------------------------------------------------

!echo "SteLen: ${NSIS_MAX_STRLEN}"

SilentInstall silent
OutFile "${Path_Out}\Dummy.exe"

Section
  ExecShell explore "$EXEDIR"
SectionEnd

; ----------------------------------------------------------------------------------------------

!system '"${PATH_BUILDS}\rtm\mplayer.exe" -vo gl "installer\sample.avi"' = 0
!system '"${PATH_BUILDS}\athlon\mplayer.exe" -vo gl "installer\sample.avi"' = 0
!system '"${PATH_BUILDS}\p3\mplayer.exe" -vo gl "installer\sample.avi"' = 0
!system '"${PATH_BUILDS}\p4\mplayer.exe" -vo gl "installer\sample.avi"' = 0

; ----------------------------------------------------------------------------------------------

!system '"${NSISDIR}\makensis.exe" /DPath_Builds="${PATH_BUILDS}" /DVersion_MPlayer="${VER_MPLAYER}" ResetSMPlayer.nsi' = 0
!system '"${NSISDIR}\makensis.exe" SetFileAssoc.nsi' = 0
!system '"${NSISDIR}\makensis.exe" AutoUpdate.nsi' = 0

; ----------------------------------------------------------------------------------------------

!define PARAMETERS '/DBuild_Number=${BUILD_NO} /DCompile_Date="${COMPILE_DATE}" /DVersion_MPlayer="${VER_MPLAYER}" /DVersion_MPUI="${VER_MPUI}" /DVersion_SMPlayer="${VER_SMPLAYER}" /DVersion_Codecs="${VER_CODECS}" /DVersion_NSIS="${VER_NSIS}" /DPath_Out="${PATH_OUT}" /DPath_Builds="${PATH_BUILDS}"'

!system '"${NSISDIR}\makensis.exe" ${PARAMETERS} Installer.nsi' = 0
!system '"${NSISDIR}\makensis.exe" ${PARAMETERS} /DFullPackage Installer.nsi' = 0

; ----------------------------------------------------------------------------------------------
