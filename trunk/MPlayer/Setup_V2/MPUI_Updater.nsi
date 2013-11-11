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


!ifndef MPLAYER_DATE
  !error "MPLAYER_DATE is not defined !!!"
!endif

!ifndef MPLAYER_OUTFILE
  !error "MPLAYER_OUTFILE is not defined !!!"
!endif

!ifndef UPX_PATH
  !error "UPX_PATH is not defined !!!"
!endif

; UUID
!define MPlayerRegPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{97D341C8-B0D1-4E4A-A49A-C30B52F168E9}"

; ----------------------------------------------------------------------------

!define /date BUILD_DATE "%Y%m%d"
!packhdr "exehead.tmp" '"${UPX_PATH}\upx.exe" --brute exehead.tmp'

; ----------------------------------------------------------------------------

XPStyle on
RequestExecutionLevel user
InstallColors /windows
AutoCloseWindow true
ShowInstDetails show
SetCompressor LZMA

; ----------------------------------------------------------------------------

LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\German.nlf"

!include "Language\MPUI_EN.nsh"
!include "Language\MPUI_DE.nsh"

; ----------------------------------------------------------------------------

Name "$(MPLAYER_LANG_MPLAYER_WIN32) $(MPLAYER_LANG_AUTO_UPDATE)"
Caption "$(MPLAYER_LANG_MPLAYER_WIN32) Auto-Update"
BrandingText "MPlayer Update [${MPLAYER_DATE}]"
Icon "Artwork\update.ico"
OutFile "${MPLAYER_OUTFILE}"

; ----------------------------------------------------------------------------

!include "MPUI_Download.nsh"

; ----------------------------------------------------------------------------

Var Update_CurrentBuildNo
Var Update_CurrentPkgDate
Var Update_MirrorURL
Var Update_LatestBuildNo
Var Update_DownloadFileName
Var Update_DownloadTicketId
Var Update_DownloadAddress

; ----------------------------------------------------------------------------

SubCaption 0 " "
SubCaption 1 " "
SubCaption 2 " "
SubCaption 3 " "
SubCaption 4 " "

; ----------------------------------------------------------------------------

ReserveFile "${NSISDIR}\Plugins\Aero.dll"
ReserveFile "${NSISDIR}\Plugins\inetc.dll"
ReserveFile "${NSISDIR}\Plugins\LangDLL.dll"
ReserveFile "${NSISDIR}\Plugins\nsExec.dll"
ReserveFile "${NSISDIR}\Plugins\StdUtils.dll"
ReserveFile "${NSISDIR}\Plugins\System.dll"

; ----------------------------------------------------------------------------

Function .onInit
	; AutoCheck support
	${StdUtils.GetParameter} $0 "AutoCheck" "?"
	${IfNot} "$0" == "?"
		ClearErrors
		ReadRegDWORD $1 HKCU "${MPlayerRegPath}" "LastUpdateCheck"
		${IfNot} ${Errors}
			${StdUtils.GetDays} $2
			IntOp $1 $1 + 30
			${IfThen} $2 < $1 ${|} Quit ${|}
		${EndIf}
	${EndIf}

	; Handle command-line
	${StdUtils.GetParameter} $0 "L" "?"
	${If} "$0" == "${LANG_ENGLISH}"
	${OrIf} "$0" == "${LANG_GERMAN}"
		StrCpy $LANGUAGE "$0"
		Return
	${EndIf}

	; Language selection dialog
	Push ""
	Push ${LANG_ENGLISH}
	Push English
	Push ${LANG_GERMAN}
	Push German
	Push A
	LangDLL::LangDialog "Updater Language" "Please select the language:"
	Pop $LANGUAGE
	${IfThen} $LANGUAGE == "cancel" ${|} Quit ${|}
FunctionEnd

Function .onGuiInit
	StrCpy $0 $HWNDPARENT
	System::Call "user32::SetWindowPos(i r0, i -1, i 0, i 0, i 0, i 0, i 3)"
	Aero::Apply
FunctionEnd

; ----------------------------------------------------------------------------

!define VerfiySignature "!insertmacro _VerfiySignature"

!macro _VerfiySignature filename
	DetailPrint "$(MPLAYER_LANG_UPD_VERIFYING) ${filename}"

	File "/oname=$PLUGINSDIR\gpgv.exe"    "Resources\GnuPG.exe"
	File "/oname=$PLUGINSDIR\pubring.gpg" "Resources\GnuPG.gpg"

	SetOutPath $PLUGINSDIR
	nsExec::ExecToLog '"$PLUGINSDIR\gpgv.exe" --homedir . --keyring pubring.gpg "${filename}.sig" "${filename}"'
	Pop $9

	Delete "$PLUGINSDIR\pubring.gpg"
	Delete "$PLUGINSDIR\${filename}.sig"
	Delete "$PLUGINSDIR\gpgv.exe"

	${If} "$9" == "error"
	${OrIf} "$9" == "timeout"
		Delete "$PLUGINSDIR\$1"
		${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_FAILED)"
		MessageBox MB_ICONSTOP|MB_TOPMOST "$(MPLAYER_LANG_UPD_ERR_GNUPG)"
		Abort "Failed to verify signature!"
	${EndIf}
	
	${IfNot} "$9" == "0"
		Delete "$PLUGINSDIR\$1"
		${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_FAILED)"
		MessageBox MB_ICONSTOP|MB_TOPMOST "$(MPLAYER_LANG_UPD_ERR_VERIFY)"
		Abort "Failed to verify signature!"
	${EndIf}
!macroend

; ----------------------------------------------------------------------------

Section "-Read Version Info"
	${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_VERINFO)"
	InitPluginsDir
	SetOutPath "$EXEDIR"
	
	ClearErrors
	ReadINIStr $Update_CurrentBuildNo "$EXEDIR\version.tag" "mplayer_version" "build_no"
	ReadINIStr $Update_CurrentPkgDate "$EXEDIR\version.tag" "mplayer_version" "pkg_date"
	
	${If} ${Errors}
		${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_FAILED)"
		MessageBox MB_TOPMOST|MB_ICONSTOP|MB_OK "$(MPLAYER_LANG_UPD_ERR_VERINFO)"
		Abort
	${EndIf}
	
	DetailPrint "$(MPLAYER_LANG_UPD_INSTALLED_VER) $Update_CurrentPkgDate (Build #$Update_CurrentBuildNo)"
SectionEnd

Section "-Select Mirror"
	${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_MIRROR)"
	StrCpy $Update_MirrorURL "http://www.example.com/"

	; Randomize some more
	${For} $1 1 42
		${StdUtils.RandMax} $0 12
	${Next}

	; Select the mirror now!
	${Select} $0
		${Case} "0"
			StrCpy $Update_MirrorURL "http://muldersoft.com/"
		${Case} "1"
			StrCpy $Update_MirrorURL "http://mulder.bplaced.net/"
		${Case} "2"
			StrCpy $Update_MirrorURL "http://mulder.cwsurf.de/"
		${Case} "3"
			StrCpy $Update_MirrorURL "http://mulder.6te.net/"
		${Case} "4"
			StrCpy $Update_MirrorURL "http://mulder.webuda.com/"
		${Case} "5"
			StrCpy $Update_MirrorURL "http://mulder.byethost13.com/"
		${Case} "6"
			StrCpy $Update_MirrorURL "http://muldersoft.kilu.de/"
		${Case} "7"
			StrCpy $Update_MirrorURL "http://muldersoft.zxq.net/"
		${Case} "8"
			StrCpy $Update_MirrorURL "http://lamexp.sourceforge.net/"
		${Case} "9"
			StrCpy $Update_MirrorURL "http://lamexp.berlios.de/"
		${Case} "10"
			StrCpy $Update_MirrorURL "http://lordmulder.github.com/LameXP/"
		${Case} "11"
			StrCpy $Update_MirrorURL "http://lord_mulder.bitbucket.org/"
		${Case} "12"
			StrCpy $Update_MirrorURL "http://www.tricksoft.de/"
		${CaseElse}
			Abort "This is not supposed to happen!"
	${EndSelect}
	
	DetailPrint "$(MPLAYER_LANG_UPD_MIRROR) $Update_MirrorURL"
SectionEnd

Section "-Download Update Info"
	${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_UPDINFO)"
	
	${DownloadFile.Get} "$(MPLAYER_LANG_UPD_STATUS_UPDINFO)" "$Update_MirrorURL/update.ver"     "$PLUGINSDIR\update.ver"
	${DownloadFile.Get} "$(MPLAYER_LANG_UPD_STATUS_UPDINFO)" "$Update_MirrorURL/update.ver.sig" "$PLUGINSDIR\update.ver.sig"
	
	${VerfiySignature} "update.ver"
	
	ClearErrors
	ReadINIStr $Update_LatestBuildNo    "$PLUGINSDIR\update.ver" "MPlayer for Windows" "BuildNo"
	ReadINIStr $Update_DownloadFileName "$PLUGINSDIR\update.ver" "MPlayer for Windows" "DownloadFilename"
	ReadINIStr $Update_DownloadTicketId "$PLUGINSDIR\update.ver" "MPlayer for Windows" "DownloadFilecode"
	ReadINIStr $Update_DownloadAddress  "$PLUGINSDIR\update.ver" "MPlayer for Windows" "DownloadAddress"
	
	${If} ${Errors}
		Delete "$PLUGINSDIR\update.ver"
		${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_FAILED)"
		MessageBox MB_TOPMOST|MB_ICONSTOP|MB_OK "$(MPLAYER_LANG_UPD_ERR_UPDINFO)"
		Abort
	${EndIf}
	
	Delete "$PLUGINSDIR\update.ver"
	DetailPrint "$(MPLAYER_LANG_UPD_LATEST_VER) Build #$Update_LatestBuildNo"
SectionEnd

Section "-Check Update Required"
	${If} $Update_CurrentBuildNo >= $Update_LatestBuildNo
		${StdUtils.GetDays} $0
		WriteRegDWORD HKCU "${MPlayerRegPath}" "LastUpdateCheck" $0
		MessageBox MB_TOPMOST|MB_ICONINFORMATION "$(MPLAYER_LANG_UPD_NO_UPDATES)"
		Quit
	${EndIf}
SectionEnd

Section "-Download Update"
	${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_DOWNLOAD)"
	
	${DownloadFile.Post} "file_name=$Update_DownloadFileName&file_code=$Update_DownloadTicketId" "$(MPLAYER_LANG_UPD_STATUS_DOWNLOAD)" "$Update_DownloadAddress" "$PLUGINSDIR\$Update_DownloadFileName"
	${DownloadFile.Post} "sign_name=$Update_DownloadFileName"                                    "$(MPLAYER_LANG_UPD_STATUS_DOWNLOAD)" "$Update_DownloadAddress" "$PLUGINSDIR\$Update_DownloadFileName.sig"

	${VerfiySignature} "$Update_DownloadFileName"
SectionEnd

Section "-Install Update Now"
	${StdUtils.GetDays} $0
	WriteRegDWORD HKCU "${MPlayerRegPath}" "LastUpdateCheck" $0

	StrCpy $5 '/Update /D=$EXEDIR'

	${SetStatus} "$(MPLAYER_LANG_UPD_STATUS_INSTALL)"
	${Do}
		ClearErrors
		ExecShell "open" "$PLUGINSDIR\$Update_DownloadFileName" '$5' SW_SHOWNORMAL
		${IfNotThen} ${Errors} ${|} ${Break} ${|}

		ClearErrors
		ExecShell "" "$PLUGINSDIR\$Update_DownloadFileName" '$5' SW_SHOWNORMAL
		${IfNotThen} ${Errors} ${|} ${Break} ${|}

		ClearErrors
		Exec '"$PLUGINSDIR\$Update_DownloadFileName" $5'
		${IfNotThen} ${Errors} ${|} ${Break} ${|}

		${IfCmd} MessageBox MB_ICONSTOP|MB_TOPMOST|MB_RETRYCANCEL "$(MPLAYER_LANG_UPD_ERR_LAUNCH)$\n$PLUGINSDIR\$Update_DownloadFileName$\n$\n$(MPLAYER_LANG_UPD_ACCESS_RIGHTS)" IDCANCEL ${||} ${Break} ${|}
	${Loop}

	Delete /REBOOTOK "$PLUGINSDIR\$Update_DownloadFileName"
SectionEnd

; ----------------------------------------------------------------------------

Function .onInstFailed
	${IfCmd} MessageBox MB_ICONQUESTION|MB_TOPMOST|MB_YESNO "$(MPLAYER_LANG_UPD_FAILED)" IDYES ${||} Exec `"$EXEPATH" /L=$LANGUAGE` ${|}
FunctionEnd
