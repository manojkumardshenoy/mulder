///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2010 LoRd_MuldeR <MuldeR2@GMX.de>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
// http://www.gnu.org/licenses/gpl-2.0.txt
///////////////////////////////////////////////////////////////////////////////

#pragma once

//MSVC
#include "Targetver.h"

//Stdlib
#include <stdio.h>
#include <tchar.h>

//Win32
#include <Windows.h>

//Class declarations
class QString;
class LockedFile;

//LameXP version info
unsigned int lamexp_version_major(void);
unsigned int lamexp_version_minor(void);
unsigned int lamexp_version_build(void);
const char *lamexp_version_date(void);
const char *lamexp_version_release(void);

//Public functions
void lamexp_register_tool(const QString &toolName, LockedFile *file);
void lamexp_finalization(void);
const QString &lamexp_temp_folder(void);

//Auxiliary functions
bool lamexp_clean_folder(const QString folderPath);

//Helper macros
#define LAMEXP_DELETE(PTR) if(PTR) { delete PTR; PTR = NULL; }
#define LAMEXP_CLOSE(HANDLE) if(HANDLE != NULL && HANDLE != INVALID_HANDLE_VALUE) { CloseHandle(HANDLE); HANDLE = NULL; }
#define QWCHAR(STR) reinterpret_cast<const wchar_t*>(STR.utf16())

//Check for debug build
#if defined(_DEBUG) || defined(QT_DEBUG)
#define LAMEXP_CHECK_DEBUG_BUILD \
	qWarning("---------------------------------------------------------\n"); \
	qWarning("DEBUG BUILD: DO NOT RELEASE THIS BINARY TO THE PUBLIC !!!\n"); \
	qWarning("---------------------------------------------------------\n\n")
#else
#define LAMEXP_CHECK_DEBUG_BUILD qDebug("")
#endif
