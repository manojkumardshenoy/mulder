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

//Qt includes
#include <QApplication>
#include <QMessageBox>
#include <QPlastiqueStyle>

//LameXP includes
#include "Global.h"
#include "Dialog_SplashScreen.h"
#include "Dialog_MainWindow.h"
#include "Thread_Initialization.h"

///////////////////////////////////////////////////////////////////////////////
// Main function
///////////////////////////////////////////////////////////////////////////////

int lamexp_main(int argc, char* argv[])
{
	//Print version info
	SetConsoleTitle(L"LameXP - Audio Encoder Front-End | DO NOT CLOSE CONSOLE !!!");
	qDebug("LameXP - Audio Encoder Front-End\n");
	qDebug("Copyright (C) 2004-2010 LoRd_MuldeR <MuldeR2@GMX.de>\n");
	qDebug("Version %d.%02d %s, Build %d [%s]\n\n", lamexp_version_major(), lamexp_version_minor(), lamexp_version_release(), lamexp_version_build(), lamexp_version_date());
	
	//print license info
	qDebug("This program is free software: you can redistribute it and/or modify\n");
    qDebug("it under the terms of the GNU General Public License <http://www.gnu.org/>.\n");
	qDebug("This program comes with ABSOLUTELY NO WARRANTY.\n\n");
	
	//Print warning, if this is a "debug" build
	LAMEXP_CHECK_DEBUG_BUILD;

	//Check Qt version
	qDebug("Using Qt Framework v%s, compiled with Qt v%s\n\n", qVersion(), QT_VERSION_STR);
	QT_REQUIRE_VERSION(argc, argv, QT_VERSION_STR);
	
	//Create Qt application instance and setup version info
	QApplication application(argc, argv);
	application.setApplicationName("LameXP - Audio Encoder Front-End");
	application.setApplicationVersion(QString().sprintf("%d.%02d.%04d", lamexp_version_major(), lamexp_version_minor(), lamexp_version_build())); 
	application.setOrganizationName("LoRd_MuldeR");
	application.setOrganizationDomain("mulder.dummwiedeutsch.de");
	application.setWindowIcon(QIcon(":/MainIcon.ico"));

	//Show splash screen
	SplashScreen *poSplashScreen = new SplashScreen();
	InitializationThread *poInitializationThread = new InitializationThread();
	poSplashScreen->showSplash(poInitializationThread);
	LAMEXP_DELETE(poSplashScreen);
	LAMEXP_DELETE(poInitializationThread);

	//Change application look
	QApplication::setStyle(new QPlastiqueStyle());

	//Show main window
	MainWindow *poMainWindow = new MainWindow();
	poMainWindow->show();
	int iResult = application.exec();
	LAMEXP_DELETE(poMainWindow);
	
	//Final clean-up
	qDebug("Shutting down, please wait...");
	lamexp_finalization();
	
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

	switch (type)
	{
	case QtCriticalMsg:
	case QtFatalMsg:
		fflush(stdout);
		fflush(stderr);
		SetConsoleTextAttribute(hConsole, FOREGROUND_RED | FOREGROUND_INTENSITY);
		fprintf(stderr, "\nCRITICAL ERROR !!!\n%s\n\n", msg);
		MessageBoxA(NULL, msg, "LameXP - CRITICAL ERROR", MB_ICONERROR | MB_TOPMOST | MB_TASKMODAL);
		FatalAppExit(0, L"The application has encountered a critical error and will exit now!");
		TerminateProcess(GetCurrentProcess(), -1);
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
 }


///////////////////////////////////////////////////////////////////////////////
// Applicaton entry point
///////////////////////////////////////////////////////////////////////////////

int main(int argc, char* argv[])
{
	try
	{
		qInstallMsgHandler(lamexp_message_handler);
		return lamexp_main(argc, argv);
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
