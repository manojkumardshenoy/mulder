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

#include "Thread_Initialization.h"

#include "LockedFile.h"
#include "Tools.h"

#include <QFileInfo>
#include <QCoreApplication>
#include <QProcess>
#include <QMap>
#include <QDir>
#include <QLibrary>
#include <QResource>
#include <QTime>

/* helper macros */
#define PRINT_CPU_TYPE(X) case X: qDebug("Selected CPU is: " #X)
static const double g_allowedExtractDelay = 10.0;

////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////

InitializationThread::InitializationThread(const lamexp_cpu_t *cpuFeatures)
{
	m_bSuccess = false;
	memset(&m_cpuFeatures, 0, sizeof(lamexp_cpu_t));
	m_slowIndicator = false;
	
	if(cpuFeatures)
	{
		memcpy(&m_cpuFeatures, cpuFeatures, sizeof(lamexp_cpu_t));
	}
}

////////////////////////////////////////////////////////////
// Thread Main
////////////////////////////////////////////////////////////

void InitializationThread::run()
{
	m_bSuccess = false;
	bool bCustom = false;
	delay();

	//CPU type selection
	unsigned int cpuSupport = 0;
	if(m_cpuFeatures.sse && m_cpuFeatures.sse2 && m_cpuFeatures.intel)
	{
		cpuSupport = m_cpuFeatures.x64 ? CPU_TYPE_X64_SSE : CPU_TYPE_X86_SSE;
	}
	else
	{
		cpuSupport = m_cpuFeatures.x64 ? CPU_TYPE_X64_GEN : CPU_TYPE_X86_GEN;
	}

	//Hack to disable x64 on the Windows 8 Developer Preview
	if(cpuSupport & CPU_TYPE_X64_ALL)
	{
		DWORD osVerNo = lamexp_get_os_version();
		if((HIWORD(osVerNo) == 6) && (LOWORD(osVerNo) == 2))
		{
			qWarning("Windows 8 (x64) developer preview detected. Going to disable all x64 support!\n");
			cpuSupport = (cpuSupport == CPU_TYPE_X64_SSE) ? CPU_TYPE_X86_SSE : CPU_TYPE_X86_GEN;
		}
	}

	//Print selected CPU type
	switch(cpuSupport)
	{
		PRINT_CPU_TYPE(CPU_TYPE_X86_GEN); break;
		PRINT_CPU_TYPE(CPU_TYPE_X86_SSE); break;
		PRINT_CPU_TYPE(CPU_TYPE_X64_GEN); break;
		PRINT_CPU_TYPE(CPU_TYPE_X64_SSE); break;
		default: throw "CPU support undefined!";
	}

	//Allocate maps
	QMap<QString, QString> mapChecksum;
	QMap<QString, unsigned int> mapVersion;
	QMap<QString, unsigned int> mapCpuType;

	//Init properties
	for(int i = 0; i < INT_MAX; i++)
	{
		if(!g_lamexp_tools[i].pcName && !g_lamexp_tools[i].pcHash && !g_lamexp_tools[i].uiVersion)
		{
			break;
		}
		else if(g_lamexp_tools[i].pcName && g_lamexp_tools[i].pcHash && g_lamexp_tools[i].uiVersion)
		{
			const QString currentTool = QString::fromLatin1(g_lamexp_tools[i].pcName);
			mapChecksum.insert(currentTool, QString::fromLatin1(g_lamexp_tools[i].pcHash));
			mapCpuType.insert(currentTool, g_lamexp_tools[i].uiCpuType);
			mapVersion.insert(currentTool, g_lamexp_tools[i].uiVersion);
		}
		else
		{
			qFatal("Inconsistent checksum data detected. Take care!");
		}
	}

	QDir toolsDir(":/tools/");
	QList<QFileInfo> toolsList = toolsDir.entryInfoList(QStringList("*.*"), QDir::Files, QDir::Name);
	QDir appDir = QDir(QCoreApplication::applicationDirPath()).canonicalPath();

	QTime timer;
	timer.start();
	
	//Extract all files
	while(!toolsList.isEmpty())
	{
		try
		{
			QFileInfo currentTool = toolsList.takeFirst();
			QString toolName = currentTool.fileName().toLower();
			QString toolShortName = QString("%1.%2").arg(currentTool.baseName().toLower(), currentTool.suffix().toLower());
			
			QByteArray toolHash = mapChecksum.take(toolName).toLatin1();
			unsigned int toolCpuType = mapCpuType.take(toolName);
			unsigned int toolVersion = mapVersion.take(toolName);
			
			if(toolHash.size() != 72)
			{
				throw "The required checksum is missing, take care!";
			}
			
			if(toolCpuType & cpuSupport)
			{
				QFileInfo customTool(QString("%1/tools/%2/%3").arg(appDir.canonicalPath(), QString::number(lamexp_version_build()), toolShortName));
				if(customTool.exists() && customTool.isFile())
				{
					bCustom = true;
					qDebug("Setting up file: %s <- %s", toolShortName.toLatin1().constData(), appDir.relativeFilePath(customTool.canonicalFilePath()).toLatin1().constData());
					LockedFile *lockedFile = new LockedFile(customTool.canonicalFilePath());
					lamexp_register_tool(toolShortName, lockedFile, UINT_MAX);
				}
				else
				{
					qDebug("Extracting file: %s -> %s", toolName.toLatin1().constData(),  toolShortName.toLatin1().constData());
					LockedFile *lockedFile = new LockedFile(QString(":/tools/%1").arg(toolName), QString("%1/tool_%2").arg(lamexp_temp_folder2(), toolShortName), toolHash);
					lamexp_register_tool(toolShortName, lockedFile, toolVersion);
				}
			}
		}
		catch(char *errorMsg)
		{
			qFatal("At least one of the required tools could not be initialized:\n%s", errorMsg);
			return;
		}
	}
	
	//Make sure all files were extracted
	if(!mapChecksum.isEmpty())
	{
		qFatal("At least one required tool could not be found:\n%s", toolsDir.filePath(mapChecksum.keys().first()).toLatin1().constData());
		return;
	}
	
	qDebug("All extracted.\n");

	//Clean-up
	mapChecksum.clear();
	mapVersion.clear();
	mapCpuType.clear();
	
	//Using any custom tools?
	if(bCustom)
	{
		qWarning("Warning: Using custom tools, you might encounter unexpected problems!\n");
	}

	//Check delay
	double delayExtract = static_cast<double>(timer.elapsed()) / 1000.0;
	if(delayExtract > g_allowedExtractDelay)
	{
		m_slowIndicator = true;
		qWarning("Extracting tools took %.3f seconds -> probably slow realtime virus scanner.", delayExtract);
		qWarning("Please report performance problems to your anti-virus developer !!!\n");
	}

	//Register all translations
	initTranslations();

	//Look for Nero AAC encoder
	initNeroAac();

	//Look for FHG AAC encoder
	initFhgAac();

	delay();
	m_bSuccess = true;
}

////////////////////////////////////////////////////////////
// PUBLIC FUNCTIONS
////////////////////////////////////////////////////////////

void InitializationThread::delay(void)
{
	const char *temp = "|/-\\";
	printf("Thread is doing something important... ?\b", temp[4]);

	for(int i = 0; i < 20; i++)
	{
		printf("%c\b", temp[i%4]);
		msleep(25);
	}

	printf("Done\n\n");
}

void InitializationThread::initTranslations(void)
{
	//Search for language files
	QStringList qmFiles = QDir(":/localization").entryList(QStringList() << "LameXP_??.qm", QDir::Files, QDir::Name);

	//Make sure we found at least one translation
	if(qmFiles.count() < 1)
	{
		qFatal("Could not find any translation files!");
		return;
	}

	//Add all available translations
	while(!qmFiles.isEmpty())
	{
		QString langId, langName;
		unsigned int systemId = 0;
		QString qmFile = qmFiles.takeFirst();
		
		QRegExp langIdExp("LameXP_(\\w\\w)\\.qm", Qt::CaseInsensitive);
		if(langIdExp.indexIn(qmFile) >= 0)
		{
			langId = langIdExp.cap(1).toLower();
		}

		QResource langRes = (QString(":/localization/%1.txt").arg(qmFile));
		if(langRes.isValid() && langRes.size() > 0)
		{
			QStringList langInfo = QString::fromUtf8(reinterpret_cast<const char*>(langRes.data()), langRes.size()).simplified().split(",", QString::SkipEmptyParts);
			if(langInfo.count() == 2)
			{
				systemId = langInfo.at(0).toUInt();
				langName = langInfo.at(1);
			}
		}
		
		if(lamexp_translation_register(langId, qmFile, langName, systemId))
		{
			qDebug("Registering translation: %s = %s (%u)", qmFile.toUtf8().constData(), langName.toUtf8().constData(), systemId);
		}
		else
		{
			qWarning("Failed to register: %s", qmFile.toLatin1().constData());
		}
	}

	qDebug("All registered.\n");
}

void InitializationThread::initNeroAac(void)
{
	const QString appPath = QDir(QCoreApplication::applicationDirPath()).canonicalPath();
	
	QFileInfo neroFileInfo[3];
	neroFileInfo[0] = QFileInfo(QString("%1/neroAacEnc.exe").arg(appPath));
	neroFileInfo[1] = QFileInfo(QString("%1/neroAacDec.exe").arg(appPath));
	neroFileInfo[2] = QFileInfo(QString("%1/neroAacTag.exe").arg(appPath));
	
	bool neroFilesFound = true;
	for(int i = 0; i < 3; i++)	{ if(!neroFileInfo[i].exists()) neroFilesFound = false; }

	//Lock the Nero binaries
	if(!neroFilesFound)
	{
		qDebug("Nero encoder binaries not found -> AAC encoding support will be disabled!\n");
		return;
	}

	qDebug("Found Nero AAC encoder binary:\n%s\n", neroFileInfo[0].canonicalFilePath().toUtf8().constData());

	LockedFile *neroBin[3];
	for(int i = 0; i < 3; i++) neroBin[i] = NULL;

	try
	{
		for(int i = 0; i < 3; i++)
		{
			neroBin[i] = new LockedFile(neroFileInfo[i].canonicalFilePath());
		}
	}
	catch(...)
	{
		for(int i = 0; i < 3; i++) LAMEXP_DELETE(neroBin[i]);
		qWarning("Failed to get excluive lock to Nero encoder binary -> AAC encoding support will be disabled!");
		return;
	}

	QProcess process;
	process.setProcessChannelMode(QProcess::MergedChannels);
	process.setReadChannel(QProcess::StandardOutput);
	process.start(neroFileInfo[0].canonicalFilePath(), QStringList() << "-help");

	if(!process.waitForStarted())
	{
		qWarning("Nero process failed to create!");
		qWarning("Error message: \"%s\"\n", process.errorString().toLatin1().constData());
		process.kill();
		process.waitForFinished(-1);
		for(int i = 0; i < 3; i++) LAMEXP_DELETE(neroBin[i]);
		return;
	}

	unsigned int neroVersion = 0;

	while(process.state() != QProcess::NotRunning)
	{
		if(!process.waitForReadyRead())
		{
			if(process.state() == QProcess::Running)
			{
				qWarning("Nero process time out -> killing!");
				process.kill();
				process.waitForFinished(-1);
				for(int i = 0; i < 3; i++) LAMEXP_DELETE(neroBin[i]);
				return;
			}
		}

		while(process.canReadLine())
		{
			QString line = QString::fromUtf8(process.readLine().constData()).simplified();
			QStringList tokens = line.split(" ", QString::SkipEmptyParts, Qt::CaseInsensitive);
			int index1 = tokens.indexOf("Package");
			int index2 = tokens.indexOf("version:");
			if(index1 >= 0 && index2 >= 0 && index1 + 1 == index2 && index2 < tokens.count() - 1)
			{
				QStringList versionTokens = tokens.at(index2 + 1).split(".", QString::SkipEmptyParts, Qt::CaseInsensitive);
				if(versionTokens.count() == 4)
				{
					neroVersion = 0;
					neroVersion += qMin(9, qMax(0, versionTokens.at(3).toInt()));
					neroVersion += qMin(9, qMax(0, versionTokens.at(2).toInt())) * 10;
					neroVersion += qMin(9, qMax(0, versionTokens.at(1).toInt())) * 100;
					neroVersion += qMin(9, qMax(0, versionTokens.at(0).toInt())) * 1000;
				}
			}
		}
	}

	if(!(neroVersion > 0))
	{
		qWarning("Nero AAC version could not be determined -> AAC encoding support will be disabled!");
		for(int i = 0; i < 3; i++) LAMEXP_DELETE(neroBin[i]);
		return;
	}
	
	for(int i = 0; i < 3; i++)
	{
		lamexp_register_tool(neroFileInfo[i].fileName(), neroBin[i], neroVersion);
	}
}

void InitializationThread::initFhgAac(void)
{
	const QString appPath = QDir(QCoreApplication::applicationDirPath()).canonicalPath();
	
	QFileInfo fhgFileInfo[4];
	fhgFileInfo[0] = QFileInfo(QString("%1/fhgaacenc.exe").arg(appPath));
	fhgFileInfo[1] = QFileInfo(QString("%1/enc_fhgaac.dll").arg(appPath));
	fhgFileInfo[2] = QFileInfo(QString("%1/nsutil.dll").arg(appPath));
	fhgFileInfo[3] = QFileInfo(QString("%1/libmp4v2.dll").arg(appPath));
	
	bool fhgFilesFound = true;
	for(int i = 0; i < 4; i++)	{ if(!fhgFileInfo[i].exists()) fhgFilesFound = false; }

	//Lock the FhgAacEnc binaries
	if(!fhgFilesFound)
	{
		qDebug("FhgAacEnc binaries not found -> FhgAacEnc support will be disabled!\n");
		return;
	}

	qDebug("Found FhgAacEnc cli_exe:\n%s\n", fhgFileInfo[0].canonicalFilePath().toUtf8().constData());
	qDebug("Found FhgAacEnc enc_dll:\n%s\n", fhgFileInfo[1].canonicalFilePath().toUtf8().constData());

	LockedFile *fhgBin[4];
	for(int i = 0; i < 4; i++) fhgBin[i] = NULL;

	try
	{
		for(int i = 0; i < 4; i++)
		{
			fhgBin[i] = new LockedFile(fhgFileInfo[i].canonicalFilePath());
		}
	}
	catch(...)
	{
		for(int i = 0; i < 4; i++) LAMEXP_DELETE(fhgBin[i]);
		qWarning("Failed to get excluive lock to FhgAacEnc binary -> FhgAacEnc support will be disabled!");
		return;
	}

	QProcess process;
	process.setProcessChannelMode(QProcess::MergedChannels);
	process.setReadChannel(QProcess::StandardOutput);
	process.start(fhgFileInfo[0].canonicalFilePath(), QStringList() << "--version");

	if(!process.waitForStarted())
	{
		qWarning("FhgAacEnc process failed to create!");
		qWarning("Error message: \"%s\"\n", process.errorString().toLatin1().constData());
		process.kill();
		process.waitForFinished(-1);
		for(int i = 0; i < 4; i++) LAMEXP_DELETE(fhgBin[i]);
		return;
	}

	QRegExp fhgAacEncSig("fhgaacenc version (\\d+) by tmkk", Qt::CaseInsensitive);
	unsigned int fhgVersion = 0;

	while(process.state() != QProcess::NotRunning)
	{
		process.waitForReadyRead();
		if(!process.bytesAvailable() && process.state() == QProcess::Running)
		{
			qWarning("FhgAacEnc process time out -> killing!");
			process.kill();
			process.waitForFinished(-1);
			for(int i = 0; i < 4; i++) LAMEXP_DELETE(fhgBin[i]);
			return;
		}
		while(process.bytesAvailable() > 0)
		{
			QString line = QString::fromUtf8(process.readLine().constData()).simplified();
			if(fhgAacEncSig.lastIndexIn(line) >= 0)
			{
				bool ok = false;
				unsigned int temp = fhgAacEncSig.cap(1).toUInt(&ok);
				if(ok) fhgVersion = temp;
			}
		}
	}

	if(!(fhgVersion > 0))
	{
		qWarning("FhgAacEnc version couldn't be determined -> FhgAacEnc support will be disabled!");
		for(int i = 0; i < 4; i++) LAMEXP_DELETE(fhgBin[i]);
		return;
	}
	else if(fhgVersion < lamexp_toolver_fhgaacenc())
	{
		qWarning("FhgAacEnc version is too much outdated -> FhgAacEnc support will be disabled!");
		for(int i = 0; i < 4; i++) LAMEXP_DELETE(fhgBin[i]);
		return;
	}
	
	for(int i = 0; i < 4; i++)
	{
		lamexp_register_tool(fhgFileInfo[i].fileName(), fhgBin[i], fhgVersion);
	}
}

void InitializationThread::selfTest(void)
{
	const unsigned int cpu[4] = {CPU_TYPE_X86_GEN, CPU_TYPE_X86_SSE, CPU_TYPE_X64_GEN, CPU_TYPE_X64_SSE};

	for(size_t k = 0; k < 4; k++)
	{
		qDebug("[TEST]");
		switch(cpu[k])
		{
			PRINT_CPU_TYPE(CPU_TYPE_X86_GEN); break;
			PRINT_CPU_TYPE(CPU_TYPE_X86_SSE); break;
			PRINT_CPU_TYPE(CPU_TYPE_X64_GEN); break;
			PRINT_CPU_TYPE(CPU_TYPE_X64_SSE); break;
			default: throw "CPU support undefined!";
		}
		int n = 0;
		for(int i = 0; i < INT_MAX; i++)
		{
			if(!g_lamexp_tools[i].pcName && !g_lamexp_tools[i].pcHash && !g_lamexp_tools[i].uiVersion)
			{
				break;
			}
			if(g_lamexp_tools[i].uiCpuType & cpu[k])
			{
				qDebug("%02i -> %s", ++n, g_lamexp_tools[i].pcName);
			}
		}
		if(n != 24)
		{
			qFatal("Tool count mismatch !!!");
		}
		qDebug("Done.\n");
	}
}

////////////////////////////////////////////////////////////
// EVENTS
////////////////////////////////////////////////////////////

/*NONE*/