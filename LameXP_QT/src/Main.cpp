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

//LameXP includes
#include "Global.h"
#include "Dialog_SplashScreen.h"
#include "Dialog_MainWindow.h"
#include "Thread_Initialization.h"

//Qt includes
#include <QApplication>
#include <QMessageBox>
#include <QDate>

///////////////////////////////////////////////////////////////////////////////
// Main function
///////////////////////////////////////////////////////////////////////////////

int lamexp_main(int argc, char* argv[])
{
	//Print version info
	SetConsoleTitle(L"LameXP - Audio Encoder Front-End | DO NOT CLOSE CONSOLE !!!");
	qDebug("LameXP - Audio Encoder Front-End\n");
	qDebug("Version %d.%02d %s, Build %d [%s], MSVC compiler v%02d.%02d\n", lamexp_version_major(), lamexp_version_minor(), lamexp_version_release(), lamexp_version_build(), lamexp_version_date().toString(Qt::ISODate).toLatin1().constData(), _MSC_VER / 100, _MSC_VER % 100);
	qDebug("Copyright (C) 2004-2010 LoRd_MuldeR <MuldeR2@GMX.de>\n\n");
	
	//print license info
	qDebug("This program is free software: you can redistribute it and/or modify\n");
    qDebug("it under the terms of the GNU General Public License <http://www.gnu.org/>.\n");
	qDebug("This program comes with ABSOLUTELY NO WARRANTY.\n\n");
	
	//Print warning, if this is a "debug" build
	LAMEXP_CHECK_DEBUG_BUILD;

	//Initialize Qt
	lamexp_init_qt(argc, argv);
	
	//Check for expiration
	if(lamexp_version_demo())
	{
		QDate expireDate = lamexp_version_date().addDays(14);
		qWarning(QString("Note: This demo (pre-release) version of LameXP will expire at %1.\n\n").arg(expireDate.toString(Qt::ISODate)).toLatin1().constData());
		if(QDate::currentDate() >= expireDate)
		{
			QMessageBox::warning(NULL, "LameXP - Expired", QString("This demo (pre-release) version of LameXP has expired at %1.").arg(expireDate.toString()), "Exit Program");
			return 0;
		}
	}

	//Check for multiple instances
	if(!lamexp_check_instances()) return 0;
	
	//Show splash screen
	SplashScreen *poSplashScreen = new SplashScreen();
	InitializationThread *poInitializationThread = new InitializationThread();
	poSplashScreen->showSplash(poInitializationThread);
	LAMEXP_DELETE(poSplashScreen);
	LAMEXP_DELETE(poInitializationThread);

	//Show main window
	MainWindow *poMainWindow = new MainWindow();
	poMainWindow->show();
	int iResult = QApplication::instance()->exec();
	LAMEXP_DELETE(poMainWindow);
	
	//Final clean-up
	qDebug("Shutting down, please wait...\n");
	
	//Terminate
	return iResult;
}

///////////////////////////////////////////////////////////////////////////////
// Message Handler
///////////////////////////////////////////////////////////////////////////////

static void lamexp_message_handler(QtMsgType type, const char *msg)
{
	static HANDLE hConsole = NULL;
	
	if(!hConsole)
	{
		hConsole = CreateFile(L"CONOUT$", GENERIC_WRITE, FILE_SHARE_WRITE | FILE_SHARE_READ, NULL, OPEN_EXISTING, NULL, NULL);
	}

	CONSOLE_SCREEN_BUFFER_INFO bufferInfo;
	GetConsoleScreenBufferInfo(hConsole, &bufferInfo);

	switch(type)
	{
	case QtCriticalMsg:
	case QtFatalMsg:
		fflush(stdout);
		fflush(stderr);
		SetConsoleTextAttribute(hConsole, FOREGROUND_RED | FOREGROUND_INTENSITY);
		fprintf(stderr, "\nCRITICAL ERROR !!!\n%s\n\n", msg);
		MessageBoxA(NULL, msg, "LameXP - CRITICAL ERROR", MB_ICONERROR | MB_TOPMOST | MB_TASKMODAL);
		break;
	case QtWarningMsg:
		SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);
		fprintf(stderr, "%s", msg);
		fflush(stderr);
		break;
	default:
		SetConsoleTextAttribute(hConsole, FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_INTENSITY);
		fprintf(stderr, "%s", msg);
		fflush(stderr);
		break;
	}

	SetConsoleTextAttribute(hConsole, FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED);

	if(type == QtCriticalMsg || type == QtFatalMsg)
	{
		FatalAppExit(0, L"The application has encountered a critical error and will exit now!");
		TerminateProcess(GetCurrentProcess(), -1);
	}
 }


///////////////////////////////////////////////////////////////////////////////
// Applicaton entry point
///////////////////////////////////////////////////////////////////////////////

int main(int argc, char* argv[])
{
	try
	{
		qInstallMsgHandler(lamexp_message_handler);
		int iResult = lamexp_main(argc, argv);
		lamexp_finalization();
		return iResult;
	}
	catch(char *error)
	{
		fflush(stdout);
		fflush(stderr);
		fprintf(stderr, "\nEXCEPTION ERROR: %s\n", error);
		FatalAppExit(0, L"Unhandeled exception error, application will exit!");
		TerminateProcess(GetCurrentProcess(), -1);
	}
	catch(int error)
	{
		fflush(stdout);
		fflush(stderr);
		fprintf(stderr, "\nEXCEPTION ERROR: Error code 0x%X\n", error);
		FatalAppExit(0, L"Unhandeled exception error, application will exit!");
		TerminateProcess(GetCurrentProcess(), -1);
	}
	catch(...)
	{
		fflush(stdout);
		fflush(stderr);
		fprintf(stderr, "\nEXCEPTION ERROR !!!\n");
		FatalAppExit(0, L"Unhandeled exception error, application will exit!");
		TerminateProcess(GetCurrentProcess(), -1);
	}
}
