///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2011 LoRd_MuldeR <MuldeR2@GMX.de>
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

#include "Global.h"

//Qt includes
#include <QApplication>
#include <QMessageBox>
#include <QDir>
#include <QUuid>
#include <QMap>
#include <QDate>
#include <QIcon>
#include <QPlastiqueStyle>
#include <QImageReader>
#include <QSharedMemory>
#include <QSysInfo>
#include <QStringList>
#include <QSystemSemaphore>
#include <QMutex>
#include <QTextCodec>
#include <QLibrary>
#include <QRegExp>
#include <QResource>
#include <QTranslator>

//LameXP includes
#include "Resource.h"
#include "LockedFile.h"

//Windows includes
#include <Windows.h>

//CRT includes
#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <intrin.h>

//Debug only includes
#ifdef _DEBUG
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0501
#endif
#if(_WIN32_WINNT < 0x0501)
#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0501
#endif
#include <Psapi.h>
#endif //_DEBUG

//Static build only macros
#ifdef QT_NODLL
#pragma warning(disable:4101)
#define LAMEXP_INIT_QT_STATIC_PLUGIN(X) Q_IMPORT_PLUGIN(X)
#else
#define LAMEXP_INIT_QT_STATIC_PLUGIN(X)
#endif

///////////////////////////////////////////////////////////////////////////////
// TYPES
///////////////////////////////////////////////////////////////////////////////

typedef struct
{
	unsigned int command;
	unsigned int reserved_1;
	unsigned int reserved_2;
	char parameter[4096];
} lamexp_ipc_t;

///////////////////////////////////////////////////////////////////////////////
// GLOBAL VARS
///////////////////////////////////////////////////////////////////////////////

//Build version
static const struct
{
	unsigned int ver_major;
	unsigned int ver_minor;
	unsigned int ver_build;
	char *ver_release_name;
}
g_lamexp_version =
{
	VER_LAMEXP_MAJOR,
	VER_LAMEXP_MINOR,
	VER_LAMEXP_BUILD,
	VER_LAMEXP_RNAME
};

//Build date
static QDate g_lamexp_version_date;
static const char *g_lamexp_months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
static const char *g_lamexp_version_raw_date = __DATE__;

//Compiler version
#if _MSC_VER == 1400
	static const char *g_lamexp_version_compiler = "MSVC 8.0";
#else
	#if _MSC_VER == 1500
		static const char *g_lamexp_version_compiler = "MSVC 9.0";
	#else
		#if _MSC_VER == 1600
			static const char *g_lamexp_version_compiler = "MSVC 10.0";
		#else
			static const char *g_lamexp_version_compiler = "UNKNOWN";
		#endif
	#endif
#endif

//Tool versions (expected)
static const unsigned int g_lamexp_toolver_neroaac = VER_LAMEXP_TOOL_NEROAAC;

//Special folders
static QString g_lamexp_temp_folder;

//Tools
static QMap<QString, LockedFile*> g_lamexp_tool_registry;
static QMap<QString, unsigned int> g_lamexp_tool_versions;

//Languages
static struct
{
	QMap<QString, QString> files;
	QMap<QString, QString> names;
	QMap<QString, unsigned int> sysid;
}
g_lamexp_translation;

//Translator
static QTranslator *g_lamexp_currentTranslator = NULL;

//Shared memory
static const struct
{
	char *sharedmem;
	char *semaphore_read;
	char *semaphore_write;
}
g_lamexp_ipc_uuid =
{
	"{21A68A42-6923-43bb-9CF6-64BF151942EE}",
	"{7A605549-F58C-4d78-B4E5-06EFC34F405B}",
	"{60AA8D04-F6B8-497d-81EB-0F600F4A65B5}"
};
static struct
{
	QSharedMemory *sharedmem;
	QSystemSemaphore *semaphore_read;
	QSystemSemaphore *semaphore_write;
}
g_lamexp_ipc_ptr =
{
	NULL, NULL, NULL
};

//Image formats
static const char *g_lamexp_imageformats[] = {"png", "gif", "ico", "svg", NULL};

//Global locks
static QMutex g_lamexp_message_mutex;

///////////////////////////////////////////////////////////////////////////////
// GLOBAL FUNCTIONS
///////////////////////////////////////////////////////////////////////////////

/*
 * Version getters
 */
unsigned int lamexp_version_major(void) { return g_lamexp_version.ver_major; }
unsigned int lamexp_version_minor(void) { return g_lamexp_version.ver_minor; }
unsigned int lamexp_version_build(void) { return g_lamexp_version.ver_build; }
const char *lamexp_version_release(void) { return g_lamexp_version.ver_release_name; }
const char *lamexp_version_compiler(void) {return g_lamexp_version_compiler; }
unsigned int lamexp_toolver_neroaac(void) { return g_lamexp_toolver_neroaac; }

bool lamexp_version_demo(void)
{
	return LAMEXP_DEBUG || !(strstr(g_lamexp_version.ver_release_name, "Final") || strstr(g_lamexp_version.ver_release_name, "Hotfix"));
}

QDate lamexp_version_expires(void)
{
	return lamexp_version_date().addDays(30);
}

/*
 * Get build date date
 */
const QDate &lamexp_version_date(void)
{
	if(!g_lamexp_version_date.isValid())
	{
		char temp[32];
		int date[3];

		char *this_token = NULL;
		char *next_token = NULL;

		strcpy_s(temp, 32, g_lamexp_version_raw_date);
		this_token = strtok_s(temp, " ", &next_token);

		for(int i = 0; i < 3; i++)
		{
			date[i] = -1;
			if(this_token)
			{
				for(int j = 0; j < 12; j++)
				{
					if(!_strcmpi(this_token, g_lamexp_months[j]))
					{
						date[i] = j+1;
						break;
					}
				}
				if(date[i] < 0)
				{
					date[i] = atoi(this_token);
				}
				this_token = strtok_s(NULL, " ", &next_token);
			}
		}

		if(date[0] >= 0 && date[1] >= 0 && date[2] >= 0)
		{
			g_lamexp_version_date = QDate(date[2], date[0], date[1]);
		}
	}

	return g_lamexp_version_date;
}

/*
 * Qt message handler
 */
void lamexp_message_handler(QtMsgType type, const char *msg)
{
	static HANDLE hConsole = NULL;
	QMutexLocker lock(&g_lamexp_message_mutex);

	if(!hConsole)
	{
		hConsole = CreateFile(L"CONOUT$", GENERIC_WRITE, FILE_SHARE_WRITE | FILE_SHARE_READ, NULL, OPEN_EXISTING, NULL, NULL);
		if(hConsole == INVALID_HANDLE_VALUE) hConsole = NULL;
	}

	CONSOLE_SCREEN_BUFFER_INFO bufferInfo;
	GetConsoleScreenBufferInfo(hConsole, &bufferInfo);
	SetConsoleOutputCP(CP_UTF8);

	switch(type)
	{
	case QtCriticalMsg:
	case QtFatalMsg:
		fflush(stdout);
		fflush(stderr);
		SetConsoleTextAttribute(hConsole, FOREGROUND_RED | FOREGROUND_INTENSITY);
		fwprintf(stderr, L"\nGURU MEDITATION !!!\n%S\n\n", msg);
		MessageBoxW(NULL, (wchar_t*) QString::fromUtf8(msg).utf16(), L"LameXP - GURU MEDITATION", MB_ICONERROR | MB_TOPMOST | MB_TASKMODAL);
		break;
	case QtWarningMsg:
		SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);
		//MessageBoxW(NULL, (wchar_t*) QString::fromUtf8(msg).utf16(), L"LameXP - GURU MEDITATION", MB_ICONWARNING | MB_TOPMOST | MB_TASKMODAL);
		fwprintf(stderr, L"%S\n", msg);
		fflush(stderr);
		break;
	default:
		SetConsoleTextAttribute(hConsole, FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);
		fwprintf(stderr, L"%S\n", msg);
		fflush(stderr);
		break;
	}

	SetConsoleTextAttribute(hConsole, FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED);

	if(type == QtCriticalMsg || type == QtFatalMsg)
	{
		lock.unlock();
		FatalAppExit(0, L"The application has encountered a critical error and will exit now!");
		TerminateProcess(GetCurrentProcess(), -1);
	}
 }

/*
 * Initialize the console
 */
void lamexp_init_console(int argc, char* argv[])
{
	bool enableConsole = lamexp_version_demo();
	
	for(int i = 0; i < argc; i++)
	{
		if(!_stricmp(argv[i], "--console"))
		{
			enableConsole = true;
		}
		else if(!_stricmp(argv[i], "--no-console"))
		{
			enableConsole = false;
		}
	}

	if(enableConsole)
	{
		if(AllocConsole())
		{
			//-------------------------------------------------------------------
			//See: http://support.microsoft.com/default.aspx?scid=kb;en-us;105305
			//-------------------------------------------------------------------
			int hCrtStdOut = _open_osfhandle((long) GetStdHandle(STD_OUTPUT_HANDLE), _O_TEXT);
			int hCrtStdErr = _open_osfhandle((long) GetStdHandle(STD_ERROR_HANDLE), _O_TEXT);
			FILE *hfStdOut = _fdopen(hCrtStdOut, "w");
			FILE *hfStderr = _fdopen(hCrtStdErr, "w");
			*stdout = *hfStdOut;
			*stderr = *hfStderr;
			setvbuf(stdout, NULL, _IONBF, 0);
			setvbuf(stderr, NULL, _IONBF, 0);
		}

		HMENU hMenu = GetSystemMenu(GetConsoleWindow(), 0);
		EnableMenuItem(hMenu, SC_CLOSE, MF_BYCOMMAND | MF_GRAYED);
		RemoveMenu(hMenu, SC_CLOSE, MF_BYCOMMAND);

		SetConsoleCtrlHandler(NULL, TRUE);
		SetConsoleTitle(L"LameXP - Audio Encoder Front-End | Debug Console");
		SetConsoleOutputCP(CP_UTF8);
	}
}

/*
 * Detect CPU features
 */
lamexp_cpu_t lamexp_detect_cpu_features(void)
{
	typedef BOOL (WINAPI *IsWow64ProcessFun)(__in HANDLE hProcess, __out PBOOL Wow64Process);
	typedef VOID (WINAPI *GetNativeSystemInfoFun)(__out LPSYSTEM_INFO lpSystemInfo);
	
	static IsWow64ProcessFun IsWow64ProcessPtr = NULL;
	static GetNativeSystemInfoFun GetNativeSystemInfoPtr = NULL;

	lamexp_cpu_t features;
	SYSTEM_INFO systemInfo;
	int CPUInfo[4] = {-1};
	char CPUIdentificationString[0x40];
	char CPUBrandString[0x40];

	memset(&features, 0, sizeof(lamexp_cpu_t));
	memset(&systemInfo, 0, sizeof(SYSTEM_INFO));
	memset(CPUIdentificationString, 0, sizeof(CPUIdentificationString));
	memset(CPUBrandString, 0, sizeof(CPUBrandString));
	
	__cpuid(CPUInfo, 0);
	memcpy(CPUIdentificationString, &CPUInfo[1], sizeof(int));
	memcpy(CPUIdentificationString + 4, &CPUInfo[3], sizeof(int));
	memcpy(CPUIdentificationString + 8, &CPUInfo[2], sizeof(int));
	features.intel = (_stricmp(CPUIdentificationString, "GenuineIntel") == 0);
	strcpy_s(features.vendor, 0x40, CPUIdentificationString);

	if(CPUInfo[0] >= 1)
	{
		__cpuid(CPUInfo, 1);
		features.mmx = (CPUInfo[3] & 0x800000) || false;
		features.sse = (CPUInfo[3] & 0x2000000) || false;
		features.sse2 = (CPUInfo[3] & 0x4000000) || false;
		features.ssse3 = (CPUInfo[2] & 0x200) || false;
		features.sse3 = (CPUInfo[2] & 0x1) || false;
		features.ssse3 = (CPUInfo[2] & 0x200) || false;
		features.stepping = CPUInfo[0] & 0xf;
		features.model = ((CPUInfo[0] >> 4) & 0xf) + (((CPUInfo[0] >> 16) & 0xf) << 4);
		features.family = ((CPUInfo[0] >> 8) & 0xf) + ((CPUInfo[0] >> 20) & 0xff);
	}

	__cpuid(CPUInfo, 0x80000000);
	int nExIds = max(min(CPUInfo[0], 0x80000004), 0x80000000);

	for(int i = 0x80000002; i <= nExIds; ++i)
	{
		__cpuid(CPUInfo, i);
		switch(i)
		{
		case 0x80000002:
			memcpy(CPUBrandString, CPUInfo, sizeof(CPUInfo));
			break;
		case 0x80000003:
			memcpy(CPUBrandString + 16, CPUInfo, sizeof(CPUInfo));
			break;
		case 0x80000004:
			memcpy(CPUBrandString + 32, CPUInfo, sizeof(CPUInfo));
			break;
		}
	}

	strcpy_s(features.brand, 0x40, CPUBrandString);

	if(strlen(features.brand) < 1) strcpy_s(features.brand, 0x40, "Unknown");
	if(strlen(features.vendor) < 1) strcpy_s(features.vendor, 0x40, "Unknown");

#if !defined(_M_X64 ) && !defined(_M_IA64)
	if(!IsWow64ProcessPtr || !GetNativeSystemInfoPtr)
	{
		QLibrary Kernel32Lib("kernel32.dll");
		IsWow64ProcessPtr = (IsWow64ProcessFun) Kernel32Lib.resolve("IsWow64Process");
		GetNativeSystemInfoPtr = (GetNativeSystemInfoFun) Kernel32Lib.resolve("GetNativeSystemInfo");
	}
	if(IsWow64ProcessPtr)
	{
		BOOL x64 = FALSE;
		if(IsWow64ProcessPtr(GetCurrentProcess(), &x64))
		{
			features.x64 = x64;
		}
	}
	if(GetNativeSystemInfoPtr)
	{
		GetNativeSystemInfoPtr(&systemInfo);
	}
	else
	{
		GetSystemInfo(&systemInfo);
	}
	features.count = systemInfo.dwNumberOfProcessors;
#else
	GetNativeSystemInfo(&systemInfo);
	features.count = systemInfo.dwNumberOfProcessors;
	features.x64 = true;
#endif

	return features;
}

/*
 * Check for debugger
 */
#if !defined(_DEBUG) || defined(NDEBUG)
void WINAPI lamexp_debug_thread_proc(__in LPVOID lpParameter)
{
	while(!IsDebuggerPresent())
	{
		Sleep(333);
	}
	TerminateProcess(GetCurrentProcess(), -1);
}
HANDLE lamexp_debug_thread_init(void)
{
	if(IsDebuggerPresent())
	{
		FatalAppExit(0, L"Not a debug build. Please unload debugger and try again!");
		TerminateProcess(GetCurrentProcess(), -1);
	}
	return CreateThread(NULL, NULL, reinterpret_cast<LPTHREAD_START_ROUTINE>(&lamexp_debug_thread_proc), NULL, NULL, NULL);
}
static const HANDLE g_debug_thread = lamexp_debug_thread_init();
#endif

/*
 * Check for compatibility mode
 */
static bool lamexp_check_compatibility_mode(const char *exportName)
{
	QLibrary kernel32("kernel32.dll");

	if(exportName != NULL)
	{
		if(kernel32.resolve(exportName) != NULL)
		{
			qFatal("Windows compatibility mode detected. Program will exit!");
			return false;
		}
	}

	return true;
}

/*
 * Check for process elevation
 */
static bool lamexp_check_elevation(void)
{
	typedef enum { lamexp_token_elevationType_class = 18, lamexp_token_elevation_class = 20 } LAMEXP_TOKEN_INFORMATION_CLASS;
	typedef enum { lamexp_elevationType_default = 1, lamexp_elevationType_full, lamexp_elevationType_limited } LAMEXP_TOKEN_ELEVATION_TYPE;

	HANDLE hToken = NULL;
	bool bIsProcessElevated = false;
	
	if(OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken))
	{
		LAMEXP_TOKEN_ELEVATION_TYPE tokenElevationType;
		DWORD returnLength;
		if(GetTokenInformation(hToken, (TOKEN_INFORMATION_CLASS) lamexp_token_elevationType_class, &tokenElevationType, sizeof(LAMEXP_TOKEN_ELEVATION_TYPE), &returnLength))
		{
			if(returnLength == sizeof(LAMEXP_TOKEN_ELEVATION_TYPE))
			{
				switch(tokenElevationType)
				{
				case lamexp_elevationType_default:
					qDebug("Process token elevation type: Default -> UAC is disabled.\n");
					break;
				case lamexp_elevationType_full:
					qWarning("Process token elevation type: Full -> potential security risk!\n");
					bIsProcessElevated = true;
					break;
				case lamexp_elevationType_limited:
					qDebug("Process token elevation type: Limited -> not elevated.\n");
					break;
				}
			}
		}
		CloseHandle(hToken);
	}
	else
	{
		qWarning("Failed to open process token!");
	}

	return !bIsProcessElevated;
}

/*
 * Initialize Qt framework
 */
bool lamexp_init_qt(int argc, char* argv[])
{
	static bool qt_initialized = false;

	//Don't initialized again, if done already
	if(qt_initialized)
	{
		return true;
	}
	
	//Check Qt version
	qDebug("Using Qt Framework v%s, compiled with Qt v%s", qVersion(), QT_VERSION_STR);
	QT_REQUIRE_VERSION(argc, argv, QT_VERSION_STR);
	
	//Check the Windows version
	switch(QSysInfo::windowsVersion() & QSysInfo::WV_NT_based)
	{
	case QSysInfo::WV_2000:
		qDebug("Running on Windows 2000 (not offically supported!).\n");
		lamexp_check_compatibility_mode("GetNativeSystemInfo");
		break;
	case QSysInfo::WV_XP:
		qDebug("Running on Windows XP.\n");
		lamexp_check_compatibility_mode("GetLargePageMinimum");
		break;
	case QSysInfo::WV_2003:
		qDebug("Running on Windows Server 2003 or Windows XP x64-Edition.\n");
		lamexp_check_compatibility_mode("GetLocaleInfoEx");
		break;
	case QSysInfo::WV_VISTA:
		qDebug("Running on Windows Vista or Windows Server 2008.\n");
		lamexp_check_compatibility_mode("CreateRemoteThreadEx");
		break;
	case QSysInfo::WV_WINDOWS7:
		qDebug("Running on Windows 7 or Windows Server 2008 R2.\n");
		lamexp_check_compatibility_mode(NULL);
		break;
	default:
		qFatal("Unsupported OS, only Windows 2000 or later is supported!");
		break;
	}

	//Create Qt application instance and setup version info
	QApplication *application = new QApplication(argc, argv);
	application->setApplicationName("LameXP - Audio Encoder Front-End");
	application->setApplicationVersion(QString().sprintf("%d.%02d.%04d", lamexp_version_major(), lamexp_version_minor(), lamexp_version_build())); 
	application->setOrganizationName("LoRd_MuldeR");
	application->setOrganizationDomain("mulder.dummwiedeutsch.de");
	application->setWindowIcon(QIcon(":/MainIcon.png"));
	
	//Load plugins from application directory
	QCoreApplication::setLibraryPaths(QStringList() << QApplication::applicationDirPath());
	qDebug("Library Path:\n%s\n", QApplication::libraryPaths().first().toUtf8().constData());

	//Init static Qt plugins
	LAMEXP_INIT_QT_STATIC_PLUGIN(qico);
	LAMEXP_INIT_QT_STATIC_PLUGIN(qsvg);

	//Check for supported image formats
	QList<QByteArray> supportedFormats = QImageReader::supportedImageFormats();
	for(int i = 0; g_lamexp_imageformats[i]; i++)
	{
		if(!supportedFormats.contains(g_lamexp_imageformats[i]))
		{
			qFatal("Qt initialization error: At least one image format plugin is missing! (%s)", g_lamexp_imageformats[i]);
			return false;
		}
	}

	//Add default translations
	g_lamexp_translation.files.insert(LAMEXP_DEFAULT_LANGID, "");
	g_lamexp_translation.names.insert(LAMEXP_DEFAULT_LANGID, "English");

	//Init language files
	//lamexp_init_translations();

	//Check for process elevation
	if(!lamexp_check_elevation())
	{
		if(QMessageBox::warning(NULL, "LameXP", "<nobr>LameXP was started with elevated rights. This is a potential security risk!</nobr>", "Quit Program (Recommended)", "Ignore") == 0)
		{
			return false;
		}
	}

	//Done
	qt_initialized = true;
	return true;
}

/*
 * Initialize IPC
 */
int lamexp_init_ipc(void)
{
	if(g_lamexp_ipc_ptr.sharedmem && g_lamexp_ipc_ptr.semaphore_read && g_lamexp_ipc_ptr.semaphore_write)
	{
		return 0;
	}

	g_lamexp_ipc_ptr.semaphore_read = new QSystemSemaphore(QString(g_lamexp_ipc_uuid.semaphore_read), 0);
	g_lamexp_ipc_ptr.semaphore_write = new QSystemSemaphore(QString(g_lamexp_ipc_uuid.semaphore_write), 0);

	if(g_lamexp_ipc_ptr.semaphore_read->error() != QSystemSemaphore::NoError)
	{
		QString errorMessage = g_lamexp_ipc_ptr.semaphore_read->errorString();
		LAMEXP_DELETE(g_lamexp_ipc_ptr.semaphore_read);
		LAMEXP_DELETE(g_lamexp_ipc_ptr.semaphore_write);
		qFatal("Failed to create system smaphore: %s", errorMessage.toUtf8().constData());
		return -1;
	}
	if(g_lamexp_ipc_ptr.semaphore_write->error() != QSystemSemaphore::NoError)
	{
		QString errorMessage = g_lamexp_ipc_ptr.semaphore_write->errorString();
		LAMEXP_DELETE(g_lamexp_ipc_ptr.semaphore_read);
		LAMEXP_DELETE(g_lamexp_ipc_ptr.semaphore_write);
		qFatal("Failed to create system smaphore: %s", errorMessage.toUtf8().constData());
		return -1;
	}

	g_lamexp_ipc_ptr.sharedmem = new QSharedMemory(QString(g_lamexp_ipc_uuid.sharedmem), NULL);
	
	if(!g_lamexp_ipc_ptr.sharedmem->create(sizeof(lamexp_ipc_t)))
	{
		if(g_lamexp_ipc_ptr.sharedmem->error() == QSharedMemory::AlreadyExists)
		{
			g_lamexp_ipc_ptr.sharedmem->attach();
			if(g_lamexp_ipc_ptr.sharedmem->error() == QSharedMemory::NoError)
			{
				return 1;
			}
			else
			{
				QString errorMessage = g_lamexp_ipc_ptr.sharedmem->errorString();
				qFatal("Failed to attach to shared memory: %s", errorMessage.toUtf8().constData());
				return -1;
			}
		}
		else
		{
			QString errorMessage = g_lamexp_ipc_ptr.sharedmem->errorString();
			qFatal("Failed to create shared memory: %s", errorMessage.toUtf8().constData());
			return -1;
		}
	}

	memset(g_lamexp_ipc_ptr.sharedmem->data(), 0, sizeof(lamexp_ipc_t));
	g_lamexp_ipc_ptr.semaphore_write->release();

	return 0;
}

/*
 * IPC send message
 */
void lamexp_ipc_send(unsigned int command, const char* message)
{
	if(!g_lamexp_ipc_ptr.sharedmem || !g_lamexp_ipc_ptr.semaphore_read || !g_lamexp_ipc_ptr.semaphore_write)
	{
		throw "Shared memory for IPC not initialized yet.";
	}

	lamexp_ipc_t *lamexp_ipc = new lamexp_ipc_t;
	memset(lamexp_ipc, 0, sizeof(lamexp_ipc_t));
	lamexp_ipc->command = command;
	if(message)
	{
		strcpy_s(lamexp_ipc->parameter, 4096, message);
	}

	if(g_lamexp_ipc_ptr.semaphore_write->acquire())
	{
		memcpy(g_lamexp_ipc_ptr.sharedmem->data(), lamexp_ipc, sizeof(lamexp_ipc_t));
		g_lamexp_ipc_ptr.semaphore_read->release();
	}

	LAMEXP_DELETE(lamexp_ipc);
}

/*
 * IPC read message
 */
void lamexp_ipc_read(unsigned int *command, char* message, size_t buffSize)
{
	*command = 0;
	message[0] = '\0';
	
	if(!g_lamexp_ipc_ptr.sharedmem || !g_lamexp_ipc_ptr.semaphore_read || !g_lamexp_ipc_ptr.semaphore_write)
	{
		throw "Shared memory for IPC not initialized yet.";
	}

	lamexp_ipc_t *lamexp_ipc = new lamexp_ipc_t;
	memset(lamexp_ipc, 0, sizeof(lamexp_ipc_t));

	if(g_lamexp_ipc_ptr.semaphore_read->acquire())
	{
		memcpy(lamexp_ipc, g_lamexp_ipc_ptr.sharedmem->data(), sizeof(lamexp_ipc_t));
		g_lamexp_ipc_ptr.semaphore_write->release();

		if(!(lamexp_ipc->reserved_1 || lamexp_ipc->reserved_2))
		{
			*command = lamexp_ipc->command;
			strcpy_s(message, buffSize, lamexp_ipc->parameter);
		}
		else
		{
			qWarning("Malformed IPC message, will be ignored");
		}
	}

	LAMEXP_DELETE(lamexp_ipc);
}

/*
 * Check for LameXP "portable" mode
 */
bool lamexp_portable_mode(void)
{
	QString baseName = QFileInfo(QApplication::applicationFilePath()).completeBaseName();
	return baseName.contains("lamexp", Qt::CaseInsensitive) && baseName.contains("portable", Qt::CaseInsensitive);
}

/*
 * Get a random string
 */
QString lamexp_rand_str(void)
{
	QRegExp regExp("\\{(\\w+)-(\\w+)-(\\w+)-(\\w+)-(\\w+)\\}");
	QString uuid = QUuid::createUuid().toString();

	if(regExp.indexIn(uuid) >= 0)
	{
		return QString().append(regExp.cap(1)).append(regExp.cap(2)).append(regExp.cap(3)).append(regExp.cap(4)).append(regExp.cap(5));
	}

	throw "The RegExp didn't match on the UUID string. This shouldn't happen ;-)";
}

/*
 * Get LameXP temp folder
 */
const QString &lamexp_temp_folder(void)
{
	static const char *TEMP_STR = "Temp";

	if(g_lamexp_temp_folder.isEmpty())
	{
		QDir temp = QDir::temp();
		QDir localAppData = QDir(lamexp_known_folder(lamexp_folder_localappdata));

		if(!localAppData.path().isEmpty() && localAppData.exists())
		{
			if(!localAppData.entryList(QDir::AllDirs).contains(TEMP_STR, Qt::CaseInsensitive))
			{
				localAppData.mkdir(TEMP_STR);
			}
			if(localAppData.cd(TEMP_STR))
			{
				temp.setPath(localAppData.absolutePath());
			}
		}

		if(!temp.exists())
		{
			temp.mkpath(".");
			if(!temp.exists())
			{
				qFatal("The system's temporary directory does not exist:\n%s", temp.absolutePath().toUtf8().constData());
				return g_lamexp_temp_folder;
			}
		}

		QString subDir = QString("%1.tmp").arg(lamexp_rand_str());
		if(!temp.mkdir(subDir))
		{
			qFatal("Temporary directory could not be created:\n%s", QString("%1/%2").arg(temp.canonicalPath(), subDir).toUtf8().constData());
			return g_lamexp_temp_folder;
		}
		if(!temp.cd(subDir))
		{
			qFatal("Temporary directory could not be entered:\n%s", QString("%1/%2").arg(temp.canonicalPath(), subDir).toUtf8().constData());
			return g_lamexp_temp_folder;
		}
		
		QFile testFile(QString("%1/.%2").arg(temp.canonicalPath(), lamexp_rand_str()));
		if(!testFile.open(QIODevice::ReadWrite) || testFile.write("LAMEXP_TEST\n") < 12)
		{
			qFatal("Write access to temporary directory has been denied:\n%s", temp.canonicalPath().toUtf8().constData());
			return g_lamexp_temp_folder;
		}

		testFile.close();
		QFile::remove(testFile.fileName());
		
		g_lamexp_temp_folder = temp.canonicalPath();
	}
	
	return g_lamexp_temp_folder;
}

/*
 * Clean folder
 */
bool lamexp_clean_folder(const QString folderPath)
{
	QDir tempFolder(folderPath);
	QFileInfoList entryList = tempFolder.entryInfoList(QDir::AllEntries | QDir::NoDotAndDotDot);

	for(int i = 0; i < entryList.count(); i++)
	{
		if(entryList.at(i).isDir())
		{
			lamexp_clean_folder(entryList.at(i).canonicalFilePath());
		}
		else
		{
			for(int j = 0; j < 3; j++)
			{
				if(lamexp_remove_file(entryList.at(i).canonicalFilePath()))
				{
					break;
				}
			}
		}
	}
	
	tempFolder.rmdir(".");
	return !tempFolder.exists();
}

/*
 * Register tool
 */
void lamexp_register_tool(const QString &toolName, LockedFile *file, unsigned int version)
{
	if(g_lamexp_tool_registry.contains(toolName.toLower()))
	{
		throw "lamexp_register_tool: Tool is already registered!";
	}

	g_lamexp_tool_registry.insert(toolName.toLower(), file);
	g_lamexp_tool_versions.insert(toolName.toLower(), version);
}

/*
 * Check for tool
 */
bool lamexp_check_tool(const QString &toolName)
{
	return g_lamexp_tool_registry.contains(toolName.toLower());
}

/*
 * Lookup tool path
 */
const QString lamexp_lookup_tool(const QString &toolName)
{
	if(g_lamexp_tool_registry.contains(toolName.toLower()))
	{
		return g_lamexp_tool_registry.value(toolName.toLower())->filePath();
	}
	else
	{
		return QString();
	}
}

/*
 * Lookup tool version
 */
unsigned int lamexp_tool_version(const QString &toolName)
{
	if(g_lamexp_tool_versions.contains(toolName.toLower()))
	{
		return g_lamexp_tool_versions.value(toolName.toLower());
	}
	else
	{
		return UINT_MAX;
	}
}

/*
 * Version number to human-readable string
 */
const QString lamexp_version2string(const QString &pattern, unsigned int version, const QString &defaultText)
{
	if(version == UINT_MAX)
	{
		return defaultText;
	}
	
	QString result = pattern;
	int digits = result.count("?", Qt::CaseInsensitive);
	
	if(digits < 1)
	{
		return result;
	}
	
	int pos = 0;
	QString versionStr = QString().sprintf(QString().sprintf("%%0%du", digits).toLatin1().constData(), version);
	int index = result.indexOf("?", Qt::CaseInsensitive);
	
	while(index >= 0 && pos < versionStr.length())
	{
		result[index] = versionStr[pos++];
		index = result.indexOf("?", Qt::CaseInsensitive);
	}

	return result;
}

/*
 * Register a new translation
 */
bool lamexp_translation_register(const QString &langId, const QString &qmFile, const QString &langName, unsigned int &systemId)
{
	if(qmFile.isEmpty() || langName.isEmpty() || systemId < 1)
	{
		return false;
	}

	g_lamexp_translation.files.insert(langId, qmFile);
	g_lamexp_translation.names.insert(langId, langName);
	g_lamexp_translation.sysid.insert(langId, systemId);

	return true;
}

/*
 * Get list of all translations
 */
QStringList lamexp_query_translations(void)
{
	return g_lamexp_translation.files.keys();
}

/*
 * Get translation name
 */
QString lamexp_translation_name(const QString &langId)
{
	return g_lamexp_translation.names.value(langId.toLower(), QString());
}

/*
 * Get translation system id
 */
unsigned int lamexp_translation_sysid(const QString &langId)
{
	return g_lamexp_translation.sysid.value(langId.toLower(), 0);
}

/*
 * Install a new translator
 */
bool lamexp_install_translator(const QString &langId)
{
	bool success = false;

	if(langId.isEmpty() || langId.toLower().compare(LAMEXP_DEFAULT_LANGID) == 0)
	{
		success = lamexp_install_translator_from_file(QString());
	}
	else
	{
		QString qmFile = g_lamexp_translation.files.value(langId.toLower(), QString());
		if(!qmFile.isEmpty())
		{
			success = lamexp_install_translator_from_file(QString(":/localization/%1").arg(qmFile));
		}
		else
		{
			qWarning("Translation '%s' not available!", langId.toLatin1().constData());
		}
	}

	return success;
}

/*
 * Install a new translator from file
 */
bool lamexp_install_translator_from_file(const QString &qmFile)
{
	bool success = false;

	if(!g_lamexp_currentTranslator)
	{
		g_lamexp_currentTranslator = new QTranslator();
	}

	if(!qmFile.isEmpty())
	{
		QString qmPath = QFileInfo(qmFile).canonicalFilePath();
		QApplication::removeTranslator(g_lamexp_currentTranslator);
		success = g_lamexp_currentTranslator->load(qmPath);
		QApplication::installTranslator(g_lamexp_currentTranslator);
		if(!success)
		{
			qWarning("Failed to load translation:\n\"%s\"", qmPath.toLatin1().constData());
		}
	}
	else
	{
		QApplication::removeTranslator(g_lamexp_currentTranslator);
		success = true;
	}

	return success;
}

/*
 * Locate known folder on local system
 */
QString lamexp_known_folder(lamexp_known_folder_t folder_id)
{
	typedef HRESULT (WINAPI *SHGetKnownFolderPathFun)(__in const GUID &rfid, __in DWORD dwFlags, __in HANDLE hToken, __out PWSTR *ppszPath);
	typedef HRESULT (WINAPI *SHGetFolderPathFun)(__in HWND hwndOwner, __in int nFolder, __in HANDLE hToken, __in DWORD dwFlags, __out LPWSTR pszPath);

	static const int CSIDL_LOCAL_APPDATA = 0x001c;
	static const int CSIDL_PROGRAM_FILES = 0x0026;
	static const int CSIDL_SYSTEM_FOLDER = 0x0025;
	static const GUID GUID_LOCAL_APPDATA = {0xF1B32785,0x6FBA,0x4FCF,{0x9D,0x55,0x7B,0x8E,0x7F,0x15,0x70,0x91}};
	static const GUID GUID_LOCAL_APPDATA_LOW = {0xA520A1A4,0x1780,0x4FF6,{0xBD,0x18,0x16,0x73,0x43,0xC5,0xAF,0x16}};
	static const GUID GUID_PROGRAM_FILES = {0x905e63b6,0xc1bf,0x494e,{0xb2,0x9c,0x65,0xb7,0x32,0xd3,0xd2,0x1a}};
	static const GUID GUID_SYSTEM_FOLDER = {0x1AC14E77,0x02E7,0x4E5D,{0xB7,0x44,0x2E,0xB1,0xAE,0x51,0x98,0xB7}};

	static QLibrary *Kernel32Lib = NULL;
	static SHGetKnownFolderPathFun SHGetKnownFolderPathPtr = NULL;
	static SHGetFolderPathFun SHGetFolderPathPtr = NULL;

	if((!SHGetKnownFolderPathPtr) && (!SHGetFolderPathPtr))
	{
		if(!Kernel32Lib) Kernel32Lib = new QLibrary("shell32.dll");
		SHGetKnownFolderPathPtr = (SHGetKnownFolderPathFun) Kernel32Lib->resolve("SHGetKnownFolderPath");
		SHGetFolderPathPtr = (SHGetFolderPathFun) Kernel32Lib->resolve("SHGetFolderPathW");
	}

	int folderCSIDL = -1;
	GUID folderGUID = {0x0000,0x0000,0x0000,{0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}};

	switch(folder_id)
	{
	case lamexp_folder_localappdata:
		folderCSIDL = CSIDL_LOCAL_APPDATA;
		folderGUID = GUID_LOCAL_APPDATA;
		break;
	case lamexp_folder_programfiles:
		folderCSIDL = CSIDL_PROGRAM_FILES;
		folderGUID = GUID_PROGRAM_FILES;
		break;
	case lamexp_folder_systemfolder:
		folderCSIDL = CSIDL_SYSTEM_FOLDER;
		folderGUID = GUID_SYSTEM_FOLDER;
		break;
	default:
		return QString();
		break;
	}

	QString folder;

	if(SHGetKnownFolderPathPtr)
	{
		WCHAR *path = NULL;
		if(SHGetKnownFolderPathPtr(folderGUID, 0x00008000, NULL, &path) == S_OK)
		{
			//MessageBoxW(0, path, L"SHGetKnownFolderPath", MB_TOPMOST);
			QDir folderTemp = QDir(QDir::fromNativeSeparators(QString::fromUtf16(reinterpret_cast<const unsigned short*>(path))));
			if(!folderTemp.exists())
			{
				folderTemp.mkpath(".");
			}
			if(folderTemp.exists())
			{
				folder = folderTemp.canonicalPath();
			}
			CoTaskMemFree(path);
		}
	}
	else if(SHGetFolderPathPtr)
	{
		WCHAR *path = new WCHAR[4096];
		if(SHGetFolderPathPtr(NULL, folderCSIDL, NULL, NULL, path) == S_OK)
		{
			//MessageBoxW(0, path, L"SHGetFolderPathW", MB_TOPMOST);
			QDir folderTemp = QDir(QDir::fromNativeSeparators(QString::fromUtf16(reinterpret_cast<const unsigned short*>(path))));
			if(!folderTemp.exists())
			{
				folderTemp.mkpath(".");
			}
			if(folderTemp.exists())
			{
				folder = folderTemp.canonicalPath();
			}
		}
		delete [] path;
	}

	return folder;
}

/*
 * Safely remove a file
 */
bool lamexp_remove_file(const QString &filename)
{
	if(!QFileInfo(filename).exists() || !QFileInfo(filename).isFile())
	{
		return true;
	}
	else
	{
		if(!QFile::remove(filename))
		{
			DWORD attributes = GetFileAttributesW(reinterpret_cast<const wchar_t*>(filename.utf16()));
			SetFileAttributesW(reinterpret_cast<const wchar_t*>(filename.utf16()), (attributes & (~FILE_ATTRIBUTE_READONLY)));
			if(!QFile::remove(filename))
			{
				qWarning("Could not delete \"%s\"", filename.toLatin1().constData());
				return false;
			}
			else
			{
				return true;
			}
		}
		else
		{
			return true;
		}
	}
}

/*
 * Check if visual themes are enabled (WinXP and later)
 */
bool lamexp_themes_enabled(void)
{
	typedef int (WINAPI *IsAppThemedFun)(void);
	
	bool isAppThemed = false;
	QLibrary uxTheme(QString("%1/UxTheme.dll").arg(lamexp_known_folder(lamexp_folder_systemfolder)));
	IsAppThemedFun IsAppThemedPtr = (IsAppThemedFun) uxTheme.resolve("IsAppThemed");

	if(IsAppThemedPtr)
	{
		isAppThemed = IsAppThemedPtr();
		if(!isAppThemed)
		{
			qWarning("Theme support is disabled for this process!");
		}
	}

	return isAppThemed;
}

/*
 * Get number of free bytes on disk
 */
__int64 lamexp_free_diskspace(const QString &path)
{
	ULARGE_INTEGER freeBytesAvailable, totalNumberOfBytes, totalNumberOfFreeBytes;
	if(GetDiskFreeSpaceExW(reinterpret_cast<const wchar_t*>(QDir::toNativeSeparators(path).utf16()), &freeBytesAvailable, &totalNumberOfBytes, &totalNumberOfFreeBytes))
	{
		return freeBytesAvailable.QuadPart;
	}
	else
	{
		return 0;
	}
}

/*
 * Finalization function (final clean-up)
 */
void lamexp_finalization(void)
{
	//Free all tools
	if(!g_lamexp_tool_registry.isEmpty())
	{
		QStringList keys = g_lamexp_tool_registry.keys();
		for(int i = 0; i < keys.count(); i++)
		{
			LAMEXP_DELETE(g_lamexp_tool_registry[keys.at(i)]);
		}
		g_lamexp_tool_registry.clear();
		g_lamexp_tool_versions.clear();
	}
	
	//Delete temporary files
	if(!g_lamexp_temp_folder.isEmpty())
	{
		for(int i = 0; i < 100; i++)
		{
			if(lamexp_clean_folder(g_lamexp_temp_folder))
			{
				break;
			}
			Sleep(125);
		}
		g_lamexp_temp_folder.clear();
	}

	//Clear languages
	if(g_lamexp_currentTranslator)
	{
		QApplication::removeTranslator(g_lamexp_currentTranslator);
		LAMEXP_DELETE(g_lamexp_currentTranslator);
	}
	g_lamexp_translation.files.clear();
	g_lamexp_translation.names.clear();

	//Destroy Qt application object
	QApplication *application = dynamic_cast<QApplication*>(QApplication::instance());
	LAMEXP_DELETE(application);

	//Detach from shared memory
	if(g_lamexp_ipc_ptr.sharedmem) g_lamexp_ipc_ptr.sharedmem->detach();
	LAMEXP_DELETE(g_lamexp_ipc_ptr.sharedmem);
	LAMEXP_DELETE(g_lamexp_ipc_ptr.semaphore_read);
	LAMEXP_DELETE(g_lamexp_ipc_ptr.semaphore_write);
}

/*
 * Get number private bytes [debug only]
 */
SIZE_T lamexp_dbg_private_bytes(void)
{
#ifdef _DEBUG
	PROCESS_MEMORY_COUNTERS_EX memoryCounters;
	memoryCounters.cb = sizeof(PROCESS_MEMORY_COUNTERS_EX);
	GetProcessMemoryInfo(GetCurrentProcess(), (PPROCESS_MEMORY_COUNTERS) &memoryCounters, sizeof(PROCESS_MEMORY_COUNTERS_EX));
	return memoryCounters.PrivateUsage;
#else
	throw "Cannot call this function in a non-debug build!";
#endif //_DEBUG
}
