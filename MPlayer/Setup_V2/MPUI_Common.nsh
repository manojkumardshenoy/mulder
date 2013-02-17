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

!macro PrintProgress Text
	SetDetailsPrint textonly
	DetailPrint '${Text}'
	SetDetailsPrint listonly
	Sleep 1000
!macroend

!macro CreateWebLink ShortcutFile TargetURL
	Push $0
	Push $1
	StrCpy $0 "${ShortcutFile}"
	StrCpy $1 "${TargetURL}"
	Call _CreateWebLink
	Pop $1
	Pop $0
!macroend

Function _CreateWebLink
	FlushINI "$0"
	SetFileAttributes "$0" FILE_ATTRIBUTE_NORMAL
	DeleteINISec "$0" "DEFAULT"
	DeleteINISec "$0" "InternetShortcut"
	WriteINIStr "$0" "DEFAULT" "BASEURL" "$1"
	WriteINIStr "$0" "InternetShortcut" "ORIGURL" "$1"
	WriteINIStr "$0" "InternetShortcut" "URL" "$1"
	WriteINIStr "$0" "InternetShortcut" "IconFile" "$SYSDIR\SHELL32.dll"
	WriteINIStr "$0" "InternetShortcut" "IconIndex" "150"
	FlushINI "$0"
	SetFileAttributes "$0" FILE_ATTRIBUTE_READONLY
FunctionEnd

!macro DisableNextButton TmpVar
	GetDlgItem ${TmpVar} $HWNDPARENT 1
	EnableWindow ${TmpVar} 0
!macroend
