///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2013 LoRd_MuldeR <MuldeR2@GMX.de>
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
#include "Dialog_Processing.h"
#include "Thread_Initialization.h"
#include "Thread_MessageProducer.h"
#include "Model_Settings.h"
#include "Model_FileList.h"
#include "Model_AudioFile.h"
#include "Encoder_Abstract.h"
#include "WinSevenTaskbar.h"

//Qt includes
#include <QApplication>
#include <QMessageBox>
#include <QDate>
#include <QMutex>
#include <QDir>

//Windows includes
#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

//Forward declaration
LONG WINAPI lamexp_exception_handler(__in struct _EXCEPTION_POINTERS *ExceptionInfo);

///////////////////////////////////////////////////////////////////////////////
// Main function
///////////////////////////////////////////////////////////////////////////////

static int lamexp_main(int argc, char* argv[])
{
	int iResult = -1;
	int iShutdown = shutdownFlag_None;
	bool bAccepted = true;

	//Increase "main" thread priority
	SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_HIGHEST);

	//Get CLI arguments
	const QStringList &arguments = lamexp_arguments();

	//Init console
	lamexp_init_console(arguments);

	//Print version info
	qDebug("LameXP - Audio Encoder Front-End v%d.%02d %s (Build #%03d)", lamexp_version_major(), lamexp_version_minor(), lamexp_version_release(), lamexp_version_build());
	qDebug("Copyright (c) 2004-%04d LoRd_MuldeR <mulder2@gmx.de>. Some rights reserved.", qMax(lamexp_version_date().year(), lamexp_current_date_safe().year()));
	qDebug("Built on %s at %s with %s for Win-%s.\n", lamexp_version_date().toString(Qt::ISODate).toLatin1().constData(), lamexp_version_time(), lamexp_version_compiler(), lamexp_version_arch());
	
	//print license info
	qDebug("This program is free software: you can redistribute it and/or modify");
	qDebug("it under the terms of the GNU General Public License <http://www.gnu.org/>.");
	qDebug("Note that this program is distributed with ABSOLUTELY NO WARRANTY.\n");

	//Print warning, if this is a "debug" build
	if(LAMEXP_DEBUG)
	{
		qWarning("---------------------------------------------------------");
		qWarning("DEBUG BUILD: DO NOT RELEASE THIS BINARY TO THE PUBLIC !!!");
		qWarning("---------------------------------------------------------\n"); 
	}
	
	//Enumerate CLI arguments
	qDebug("Command-Line Arguments:");
	for(int i = 0; i < arguments.count(); i++)
	{
		qDebug("argv[%d]=%s", i, arguments.at(i).toUtf8().constData());
	}
	qDebug("");

	//Detect CPU capabilities
	lamexp_cpu_t cpuFeatures = lamexp_detect_cpu_features(arguments);
	qDebug("   CPU vendor id  :  %s (Intel: %s)", cpuFeatures.vendor, LAMEXP_BOOL2STR(cpuFeatures.intel));
	qDebug("CPU brand string  :  %s", cpuFeatures.brand);
	qDebug("   CPU signature  :  Family: %d, Model: %d, Stepping: %d", cpuFeatures.family, cpuFeatures.model, cpuFeatures.stepping);
	qDebug("CPU capabilities  :  MMX: %s, SSE: %s, SSE2: %s, SSE3: %s, SSSE3: %s, x64: %s", LAMEXP_BOOL2STR(cpuFeatures.mmx), LAMEXP_BOOL2STR(cpuFeatures.sse), LAMEXP_BOOL2STR(cpuFeatures.sse2), LAMEXP_BOOL2STR(cpuFeatures.sse3), LAMEXP_BOOL2STR(cpuFeatures.ssse3), LAMEXP_BOOL2STR(cpuFeatures.x64));
	qDebug(" Number of CPU's  :  %d\n", cpuFeatures.count);

	//Initialize Qt
	if(!lamexp_init_qt(argc, argv))
	{
		return -1;
	}

	//Check for expiration
	if(lamexp_version_demo())
	{
		const QDate currentDate = lamexp_current_date_safe();
		if(currentDate.addDays(1) < lamexp_version_date())
		{
			qFatal("System's date (%s) is before LameXP build date (%s). Huh?", currentDate.toString(Qt::ISODate).toLatin1().constData(), lamexp_version_date().toString(Qt::ISODate).toLatin1().constData());
		}
		qWarning(QString("Note: This demo (pre-release) version of LameXP will expire at %1.\n").arg(lamexp_version_expires().toString(Qt::ISODate)).toLatin1().constData());
	}

	//Check for multiple instances of LameXP
	if((iResult = lamexp_init_ipc()) != 0)
	{
		qDebug("LameXP is already running, connecting to running instance...");
		if(iResult == 1)
		{
			MessageProducerThread *messageProducerThread = new MessageProducerThread();
			messageProducerThread->start();
			if(!messageProducerThread->wait(30000))
			{
				messageProducerThread->terminate();
				QMessageBox messageBox(QMessageBox::Critical, "LameXP", "LameXP is already running, but the running instance doesn't respond!", QMessageBox::NoButton, NULL, Qt::Dialog | Qt::MSWindowsFixedSizeDialogHint | Qt::WindowStaysOnTopHint);
				messageBox.exec();
				messageProducerThread->wait();
				LAMEXP_DELETE(messageProducerThread);
				return -1;
			}
			LAMEXP_DELETE(messageProducerThread);
		}
		return 0;
	}

	//Kill application?
	for(int i = 0; i < argc; i++)
	{
		if(!arguments[i].compare("--kill", Qt::CaseInsensitive) || !arguments[i].compare("--force-kill", Qt::CaseInsensitive))
		{
			return 0;
		}
	}
	
	//Self-test
	if(LAMEXP_DEBUG)
	{
		InitializationThread::selfTest();
	}

	//Taskbar init
	WinSevenTaskbar::init();

	//Create models
	FileListModel *fileListModel = new FileListModel();
	AudioFileModel_MetaInfo *metaInfo = new AudioFileModel_MetaInfo();
	SettingsModel *settingsModel = new SettingsModel();

	//Show splash screen
	InitializationThread *poInitializationThread = new InitializationThread(&cpuFeatures);
	SplashScreen::showSplash(poInitializationThread);
	settingsModel->slowStartup(poInitializationThread->getSlowIndicator());
	LAMEXP_DELETE(poInitializationThread);

	//Validate settings
	settingsModel->validate();

	//Create main window
	MainWindow *poMainWindow = new MainWindow(fileListModel, metaInfo, settingsModel);
	
	//Main application loop
	while(bAccepted && (iShutdown <= shutdownFlag_None))
	{
		//Show main window
		poMainWindow->show();
		iResult = QApplication::instance()->exec();
		bAccepted = poMainWindow->isAccepted();

		//Sync settings
		settingsModel->syncNow();

		//Show processing dialog
		if(bAccepted && (fileListModel->rowCount() > 0))
		{
			ProcessingDialog *processingDialog = new ProcessingDialog(fileListModel, metaInfo, settingsModel);
			processingDialog->exec();
			iShutdown = processingDialog->getShutdownFlag();
			LAMEXP_DELETE(processingDialog);
		}
	}
	
	//Free models
	LAMEXP_DELETE(poMainWindow);
	LAMEXP_DELETE(fileListModel);
	LAMEXP_DELETE(metaInfo);
	LAMEXP_DELETE(settingsModel);

	//Taskbar un-init
	WinSevenTaskbar::uninit();

	//Final clean-up
	qDebug("Shutting down, please wait...\n");

	//Shotdown computer
	if(iShutdown > shutdownFlag_None)
	{
		if(!lamexp_shutdown_computer(QApplication::applicationFilePath(), 12, true, (iShutdown == shutdownFlag_Hibernate)))
		{
			QMessageBox messageBox(QMessageBox::Critical, "LameXP", "Sorry, LameXP was unable to shutdown your computer!", QMessageBox::NoButton, NULL, Qt::Dialog | Qt::MSWindowsFixedSizeDialogHint | Qt::WindowStaysOnTopHint);
		}
	}

	//Terminate
	return iResult;
}

///////////////////////////////////////////////////////////////////////////////
// Applicaton entry point
///////////////////////////////////////////////////////////////////////////////

static int _main(int argc, char* argv[])
{
	if(LAMEXP_DEBUG)
	{
		int iResult = -1;
		qInstallMsgHandler(lamexp_message_handler);
		iResult = lamexp_main(argc, argv);
		lamexp_finalization();
		return iResult;
	}
	else
	{
		int iResult = -1;
		try
		{
			qInstallMsgHandler(lamexp_message_handler);
			iResult = lamexp_main(argc, argv);
			lamexp_finalization();
		}
		catch(char *error)
		{
			fflush(stdout);
			fflush(stderr);
			fprintf(stderr, "\nGURU MEDITATION !!!\n\nException error message: %s\n", error);
			lamexp_fatal_exit(L"Unhandeled C++ exception error, application will exit!");
		}
		catch(int error)
		{
			fflush(stdout);
			fflush(stderr);
			fprintf(stderr, "\nGURU MEDITATION !!!\n\nException error code: 0x%X\n", error);
			lamexp_fatal_exit(L"Unhandeled C++ exception error, application will exit!");
		}
		catch(...)
		{
			fflush(stdout);
			fflush(stderr);
			fprintf(stderr, "\nGURU MEDITATION !!!\n");
			lamexp_fatal_exit(L"Unhandeled C++ exception error, application will exit!");
		}
		return iResult;
	}
}

int main(int argc, char* argv[])
{
	if(LAMEXP_DEBUG)
	{
		int exit_code = -1;
		LAMEXP_MEMORY_CHECK(_main, exit_code, argc, argv);
		return exit_code;
	}
	else
	{
		__try
		{
			SetUnhandledExceptionFilter(lamexp_exception_handler);
			_set_invalid_parameter_handler(lamexp_invalid_param_handler);
			return _main(argc, argv);
		}
		__except(1)
		{
			fflush(stdout);
			fflush(stderr);
			fprintf(stderr, "\nGURU MEDITATION !!!\n\nUnhandeled structured exception error! [code: 0x%X]\n", GetExceptionCode());
			lamexp_fatal_exit(L"Unhandeled structured exception error, application will exit!");
		}
	}
}
