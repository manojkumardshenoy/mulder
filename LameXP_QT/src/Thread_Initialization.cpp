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

#include <QFileInfo>
#include <QCoreApplication>
#include <QProcess>
#include <QMap>
#include <QDir>
#include <QLibrary>
#include <QResource>
#include <QTime>

////////////////////////////////////////////////////////////
// TOOLS
////////////////////////////////////////////////////////////

#define CPU_TYPE_X86 0x000001 //x86-32
#define CPU_TYPE_SSE 0x000002 //x86-32 + SSE2 (Intel only!)
#define CPU_TYPE_X64 0x000004 //x86-64

#define CPU_TYPE_GEN (CPU_TYPE_X86|CPU_TYPE_SSE)              //Use for all CPU's, except for x86-64
#define CPU_TYPE_ALL (CPU_TYPE_X86|CPU_TYPE_SSE|CPU_TYPE_X64) //Use for all CPU's, x86-32 and x86-64

static const struct
{
	char *pcHash;
	unsigned int uiCpuType;
	char *pcName;
	unsigned int uiVersion;
}
g_lamexp_tools[] =
{
	{"cd702b111e13e3b6ed71cb0b6e6e9fc6be994296c65ed367c22ba382ab1e147ba126b02b", CPU_TYPE_X86, "aften.i386.exe", 8},
	{"aa81f531c7cf1be38bfce1656113cfd6d682106958ab269dae8dff70abbc3e00615fdf4e", CPU_TYPE_SSE, "aften.sse2.exe", 8},
	{"29da0d3e810bc3e8d2cddb3db452325eefca0d0c1fff1379fa17806ad447752be1b88e2f", CPU_TYPE_X64, "aften.x64.exe",  8},
	{"1cca303fabd889a18fc01c32a7fd861194cfcac60ba63740ea2d7c55d049dbf8f59259fa", CPU_TYPE_ALL, "alac.exe", 20},
	{"72d7ef3ecb727d6eaf64a8cca8bda2b6cc91154178d7d1783144c4acf1a0c1c2547ca324", CPU_TYPE_ALL, "avs2wav.exe", 12},
	{"c6f23fb7ba18a7972802e013b66ec6ce52088bf4fe783774eb1d33dd3401fa8aad76cc8b", CPU_TYPE_ALL, "elevator.exe", UINT_MAX},
	{"b71736a34afbe3259304a5b5dda980dfdbc3bf4fbc06c62a98a3ee4742deda377020d691", CPU_TYPE_ALL, "faad.exe", 27},
	{"446054f9a7f705f1aadc9053ca7b8a86a775499ef159978954ebdea92de056c34f8841f7", CPU_TYPE_ALL, "flac.exe", 121},
	{"dd68d074c5e13a607580f3a24595c0f3882e37211d2ca628f46e6df20fabcc832dad488a", CPU_TYPE_ALL, "gpgv.exe", 1411},
	{"b3fca757b3567dab75c042e62213c231de378ea0fdd7fe29b733417cd5d3d33558452f94", CPU_TYPE_ALL, "gpgv.gpg", UINT_MAX},
	{"9c1c8024d5d75213edbc1dbad7aeaf2535000f57880b445c763ac45da365446b8cfd84c7", CPU_TYPE_ALL, "lame.exe", 3990},
	{"67933924d68ce319795989648f29e7bd1abaac4ec09c26cbb0ff0d15a67a9df17e257933", CPU_TYPE_ALL, "mac.exe", 406},
	{"7c5afaf883b7e2b4be47af2070a756470714af98741173a92d123eb4e0242f69321ccb61", CPU_TYPE_GEN, "mediainfo.i386.exe", 745},
	{"38d1c95e42dcc180b0be2a401ab00f60e91a38342758f5c1927329f378921d75855a56a3", CPU_TYPE_X64, "mediainfo.x64.exe",  745},
	{"a93ec86187025e66fb78026af35555bd3b4e30fe1a40e8d66f600cfd918f07f431f0b2f2", CPU_TYPE_ALL, "mpcdec.exe", 435},
	{"5a89768010efb1ddfd88ccc378a89433ceaecb403a7b1f83f8716f6848d9a05b3d3c6d93", CPU_TYPE_ALL, "mpg123.exe", 1133},
	{"0c781805dda931c529bd16069215f616a7a4c5e5c2dfb6b75fe85d52b20511830693e528", CPU_TYPE_ALL, "oggdec.exe", UINT_MAX},
	{"0c019e13450dc664987e21f4e5489d182be7d6d0d81efbbaaf1c78693dfe3e38e0355b93", CPU_TYPE_X86, "oggenc2.i386.exe", 287603},
	{"693dd6f779df70a047c15c2c79350855db38d5b0cd7e529b6877b7c821cfe6addfdd50a4", CPU_TYPE_SSE, "oggenc2.sse2.exe", 287603},
	{"32cb0b2182488e5e9278ba6b9fc9141214c7546eec67ee02fa895810b0e56900368695be", CPU_TYPE_X64, "oggenc2.x64.exe",  287603},
	{"58c2b8bcff8f27bfa8fab8172b80f5da731221d072c7dba4dd3a3d7d6423490a25dc6760", CPU_TYPE_ALL, "shorten.exe", 361},
	{"abdf9b20a8031a09d0abca9cb10c31c8418f72403b5d1350fd69bfa34041591aca3060ab", CPU_TYPE_ALL, "sox.exe", 1432},
	{"48e7f81c024cd17dac0eaeab253aad6b223e72dc80688f7576276b0563209514ff0bb9c8", CPU_TYPE_ALL, "speexdec.exe", 12},
	{"9b50cf64747d4afbad5d8d9b5a0a2d41c5a58256f47ebdbd8cc920e7e576085dfe1b14ff", CPU_TYPE_ALL, "tta.exe", 21},
	{"875871c942846f6ad163f9e4949bba2f4331bec678ca5aefe58c961b6825bd0d419a078b", CPU_TYPE_ALL, "valdec.exe", 31},
	{"e657331e281840878a37eb4fb357cb79f33d528ddbd5f9b2e2f7d2194bed4720e1af8eaf", CPU_TYPE_ALL, "wget.exe", 1114},
	{"229d677a34885bd4981f7dff9ec2ec71a8bcf207d7337151c6ec0f49a5dc0b14df1bdd11", CPU_TYPE_ALL, "wupdate.exe", UINT_MAX},
	{"6b053b37d47a9c8659ebf2de43ad19dcba17b9cd868b26974b9cc8c27b6167e8bf07a5a2", CPU_TYPE_ALL, "wvunpack.exe", 4601},
	{NULL, NULL, NULL, NULL}
};

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
	unsigned int cpuSupport = m_cpuFeatures.x64 ? CPU_TYPE_X64 : ((m_cpuFeatures.intel && m_cpuFeatures.sse && m_cpuFeatures.sse2) ? CPU_TYPE_SSE : CPU_TYPE_X86);
	
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

	//Look for Nero encoder
	initNeroAac();
	
	//Look for WMA File decoder
	initWmaDec();

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
			qDebug64("Registering translation: %1 = %2 (%3)", qmFile, langName, QString::number(systemId));
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
					neroVersion += min(9, max(0, versionTokens.at(3).toInt()));
					neroVersion += min(9, max(0, versionTokens.at(2).toInt())) * 10;
					neroVersion += min(9, max(0, versionTokens.at(1).toInt())) * 100;
					neroVersion += min(9, max(0, versionTokens.at(0).toInt())) * 1000;
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


void InitializationThread::initWmaDec(void)
{
	static const char* wmaDecoderComponentPath = "NCH Software/Components/wmawav/wmawav.exe";

	LockedFile *wmaFileBin = NULL;
	QFileInfo wmaFileInfo = QFileInfo(QString("%1/%2").arg(lamexp_known_folder(lamexp_folder_programfiles), wmaDecoderComponentPath));

	if(!(wmaFileInfo.exists() && wmaFileInfo.isFile()))
	{
		wmaFileInfo.setFile(QString("%1/%2").arg(QDir(QCoreApplication::applicationDirPath()).canonicalPath(), "wmawav.exe"));
	}
	if(!(wmaFileInfo.exists() && wmaFileInfo.isFile()))
	{
		qDebug("WMA File Decoder not found -> WMA decoding support will be disabled!\n");
		return;
	}

	try
	{
		wmaFileBin = new LockedFile(wmaFileInfo.canonicalFilePath());
	}
	catch(...)
	{
		qWarning("Failed to get excluive lock to WMA File Decoder binary -> WMA decoding support will be disabled!");
		return;
	}

	QProcess process;
	process.setProcessChannelMode(QProcess::MergedChannels);
	process.setReadChannel(QProcess::StandardOutput);
	process.start(wmaFileInfo.canonicalFilePath(), QStringList());

	if(!process.waitForStarted())
	{
		qWarning("WmaWav process failed to create!");
		qWarning("Error message: \"%s\"\n", process.errorString().toLatin1().constData());
		process.kill();
		process.waitForFinished(-1);
		return;
	}

	bool b_wmaWavFound = false;

	while(process.state() != QProcess::NotRunning)
	{
		if(!process.waitForReadyRead())
		{
			if(process.state() == QProcess::Running)
			{
				qWarning("WmaWav process time out -> killing!");
				process.kill();
				process.waitForFinished(-1);
				return;
			}
		}
		while(process.canReadLine())
		{
			QString line = QString::fromUtf8(process.readLine().constData()).simplified();
			if(line.contains("Usage: wmatowav.exe WMAFileSpec WAVFileSpec", Qt::CaseInsensitive))
			{
				b_wmaWavFound = true;
			}
		}
	}

	if(!b_wmaWavFound)
	{
		qWarning("WmaWav could not be identified -> WMA decoding support will be disabled!\n");
		LAMEXP_DELETE(wmaFileBin);
		return;
	}

	qDebug("Found WMA File Decoder binary:\n%s\n", wmaFileInfo.canonicalFilePath().toUtf8().constData());

	if(wmaFileBin)
	{
		lamexp_register_tool(wmaFileInfo.fileName(), wmaFileBin);
	}
}

////////////////////////////////////////////////////////////
// EVENTS
////////////////////////////////////////////////////////////

/*NONE*/