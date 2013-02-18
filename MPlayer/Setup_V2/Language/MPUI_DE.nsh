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

LangString MPLAYER_LANG_BIN_CODECS               ${LANG_GERMAN} "Bin�re Codecs"
LangString MPLAYER_LANG_FRONT_END                ${LANG_GERMAN} "Oberfl�che"
LangString MPLAYER_LANG_COMPRESS_FILES           ${LANG_GERMAN} "Programmdateien optimieren"
LangString MPLAYER_LANG_DETECTING                ${LANG_GERMAN} "CPU-Typ wird ermittelt..."
LangString MPLAYER_LANG_SELECT_CPU_HEAD          ${LANG_GERMAN} "CPU-Type Auswahl"
LangString MPLAYER_LANG_SELECT_CPU_TEXT          ${LANG_GERMAN} "W�hlen Sie das optimal MPlayer-Build f�r Ihr System um die Wiedergabe-Leistung zu verbessern!"
LangString MPLAYER_LANG_SELECT_CPU_TYPE          ${LANG_GERMAN} "W�hlen Sie Ihren CPU-Typ aus:"
LangString MPLAYER_LANG_SELECT_CPU_HINT          ${LANG_GERMAN} "Hinweis: Ein inkompatibler CPU-Typ kann zum Absturz auf Ihrem Computer f�hren. W�hlen Sie bitte den 'Generic' Typ aus, falls Sie sich unsicher sind!"
LangString MPLAYER_LANG_TWEAKS_HEAD              ${LANG_GERMAN} "MPlayer Anpassungen"
LangString MPLAYER_LANG_TWEAKS_TEXT              ${LANG_GERMAN} "Legen Sie die initiale MPlayer-Konfiguration hier fest!"
LangString MPLAYER_LANG_TWEAKS_HINT              ${LANG_GERMAN} "Anpassungen ausw�hlen:"
LangString MPLAYER_LANG_TWEAKS_SKINNEDUI         ${LANG_GERMAN} "Aktiviere die neue 'Skin' Benutzeroberfl�che (nur SMPlayer)"
LangString MPLAYER_LANG_TWEAKS_OPENGL            ${LANG_GERMAN} "Aktiviere den OpenGL-basierten Video-Renderer, anstatt Direct3D"
LangString MPLAYER_LANG_TWEAKS_VOLNORM           ${LANG_GERMAN} "Aktiviere die Lautst�rke-Normalisierung standardm��ig"
LangString MPLAYER_LANG_COMPRESSING              ${LANG_GERMAN} "Komprimiere"
LangString MPLAYER_LANG_WRITING_REGISTRY         ${LANG_GERMAN} "Registrierungs-Informationen werden aktualisiert..."
LangString MPLAYER_LANG_APPLYING_TWEAKS          ${LANG_GERMAN} "Anpassungen werden gerade �bernommen..."
LangString MPLAYER_LANG_STATUS_WAIT              ${LANG_GERMAN} "bitte warten"
LangString MPLAYER_LANG_STATUS_INST_CLEAN        ${LANG_GERMAN} "Entferne alte Dateien"
LangString MPLAYER_LANG_STATUS_INST_MPLAYER      ${LANG_GERMAN} "Installiere MPlayer"
LangString MPLAYER_LANG_STATUS_INST_SMPLAYER     ${LANG_GERMAN} "Installiere SMPlayer"
LangString MPLAYER_LANG_STATUS_INST_MPUI         ${LANG_GERMAN} "Installiere MPUI"
LangString MPLAYER_LANG_STATUS_INST_CODECS       ${LANG_GERMAN} "Installiere bin�re Codecs"
LangString MPLAYER_LANG_STATUS_MAKEUNINST        ${LANG_GERMAN} "Schreibe Deinstallationsprogramm"
LangString MPLAYER_LANG_STATUS_INST_FONTCACHE    ${LANG_GERMAN} "Aktualisiere Font-Cache"
LangString MPLAYER_LANG_STATUS_INST_COMPRESS     ${LANG_GERMAN} "Optimiere Programmdateien"
LangString MPLAYER_LANG_STATUS_REGISTRY          ${LANG_GERMAN} "Registrierung wird aktualisiert"
LangString MPLAYER_LANG_STATUS_TWEAKS            ${LANG_GERMAN} "�bernehme Anpassungen"
LangString MPLAYER_LANG_STATUS_SHORTCUTS         ${LANG_GERMAN} "Erzeuge Verkn�pfungen"
LangString MPLAYER_LANG_STATUS_UNINSTALL         ${LANG_GERMAN} "Deinstalliere MPlayer"
LangString MPLAYER_LANG_SELECTED_TYPE            ${LANG_GERMAN} "Ausgew�hlter CPU-Typ"
LangString MPLAYER_LANG_UPDATING_FONTCACHE       ${LANG_GERMAN} "Der Font-Cache wird gerade aktualisiert..."
LangString MPLAYER_LANG_STILL_RUNNING            ${LANG_GERMAN} "MPlayer konnte nicht gel�scht werden. L�uft MPlayer noch?$\nBitte MPlayer schlie�en und erneut versuchen!"
LangString MPLAYER_LANG_LOCKEDLIST_HEADER        ${LANG_GERMAN} "Laufende Instanzen"
LangString MPLAYER_LANG_LOCKEDLIST_TEXT          ${LANG_GERMAN} "Suche nach laufenden Instanzen von MPlayer."
LangString MPLAYER_LANG_LOCKEDLIST_HEADING       ${LANG_GERMAN} "Bitte schlie�en Sie die folgenden Programme um fortfahren zu k�nnen..."
LangString MPLAYER_LANG_LOCKEDLIST_NOPROG        ${LANG_GERMAN} "Es m�ssen keine Programme geschlossen werden."
LangString MPLAYER_LANG_LOCKEDLIST_SEARCH        ${LANG_GERMAN} "Suche, bitte warten..."
LangString MPLAYER_LANG_LOCKEDLIST_COLHDR1       ${LANG_GERMAN} "Application"
LangString MPLAYER_LANG_LOCKEDLIST_COLHDR2       ${LANG_GERMAN} "Process"
LangString MPLAYER_LANG_SHORTCUT_README          ${LANG_GERMAN} "Liesmich Datei"
LangString MPLAYER_LANG_SHORTCUT_MANUAL          ${LANG_GERMAN} "Anleitung"
LangString MPLAYER_LANG_SHORTCUT_SITE_MULDERS    ${LANG_GERMAN} "MuldeR's Web-Seite"
LangString MPLAYER_LANG_SHORTCUT_SITE_MPWIN32    ${LANG_GERMAN} "MPlayer f�r Win32 Web-Seite"
LangString MPLAYER_LANG_SHORTCUT_SITE_MPLAYER    ${LANG_GERMAN} "Offizielle MPlayer Web-Seite"
LangString MPLAYER_LANG_INSTTYPE_COMPLETE        ${LANG_GERMAN} "Vollst�ndige Installation"
LangString MPLAYER_LANG_INSTTYPE_MINIMAL         ${LANG_GERMAN} "Minimale Installation"
LangString MPLAYER_LANG_SELCHANGE                ${LANG_GERMAN} "Sie m�ssen entweder MPUI oder SMPlayer ausw�hlen!"
