; ////////////////////////////////////////////////////////////////
; // MPlayer for Windows - Install Script
; // Written by MuldeR <MuldeR2@GMX.de> - http://mulder.at.gg/
; // Developed and tested with NSIS v2.46
; ////////////////////////////////////////////////////////////////

!define BUILD_NO "66"
!define COMPILE_DATE "2009-12-27"
!define VER_MPLAYER "SVN-r30075 (2009-12-20)"
!define VER_SMPLAYER "v0.6.8 (SVN-r3355)"
!define VER_MPUI "v1.2-pre3 (Build 38)"
!define VER_NSIS "v2.46"
!define VER_CODECS "(2007-10-07)"

; ----------------------------------------------------------------------------------------------

!define PATH_OUT "D:\MPUI\upload\MPUI.${COMPILE_DATE}.Build-${BUILD_NO}"
!define PATH_BUILDS "D:\MPUI\builds"

!system 'md "${PATH_OUT}"'

; ----------------------------------------------------------------------------------------------

SilentInstall silent
OutFile "${Path_Out}\Dummy.exe"

Section
  ExecShell explore "$EXEDIR"
SectionEnd

; ----------------------------------------------------------------------------------------------

!system '"${NSISDIR}\makensis.exe" /DPath_Builds="${PATH_BUILDS}" /DVersion_MPlayer="${VER_MPLAYER}" ResetSMPlayer.nsi' = 0
!system '"${NSISDIR}\makensis.exe" SetFileAssoc.nsi' = 0
!system '"${NSISDIR}\makensis.exe" AutoUpdate.nsi' = 0

; ----------------------------------------------------------------------------------------------

!define PARAMETERS '/DBuild_Number=${BUILD_NO} /DCompile_Date="${COMPILE_DATE}" /DVersion_MPlayer="${VER_MPLAYER}" /DVersion_MPUI="${VER_MPUI}" /DVersion_SMPlayer="${VER_SMPLAYER}" /DVersion_Codecs="${VER_CODECS}" /DVersion_NSIS="${VER_NSIS}" /DPath_Out="${PATH_OUT}" /DPath_Builds="${PATH_BUILDS}"'

!system '"${NSISDIR}\makensis.exe" ${PARAMETERS} Installer.nsi' = 0
!system '"${NSISDIR}\makensis.exe" ${PARAMETERS} /DFullPackage Installer.nsi' = 0

; ----------------------------------------------------------------------------------------------
