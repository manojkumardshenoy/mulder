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

#include "Thread_Initialization.h"

#include "Global.h"
#include "LockedFile.h"

#include <QFileInfo>
#include <QCoreApplication>
#include <QProcess>

////////////////////////////////////////////////////////////
// TOOLS
////////////////////////////////////////////////////////////

struct lamexp_tool_t
{
	char *pcHash;
	char *pcName;
};

static const struct lamexp_tool_t g_lamexp_tools[] =
{
	{"153f4274702f3629093b561a31dbf50e2c146305", "alac.exe"},
	{"09e5a07555a24b8c9d6af880b81eb8ed75be16fd", "faad.exe"},
	{"070bf98f78e572a97e4703ef5720c682567a6a56", "flac.exe"},
	{"cf379081035ae6bfb6f7bc22f13bfb7ac6302ac5", "gpgv.exe"},
	{"e613a1b56a2187edb4cdf3628a5a3e60de2e8cbc", "lame.exe"},
	{"775b260b3f64101beaeb317b74746f9bccdab842", "MAC.exe"},
	{"e770eaa5f2449d0fd6b3f3c02a1f574fc4370b5e", "mediainfo_icl11.exe"},
	{"55c293a80475f7aeccf449ac9487a4626e5139cb", "mpcdec.exe"},
	{"8bbf4a3fffe2ff143eb5ba2cf82ca16d676e865d", "mpg123.exe"},
	{"437a1b193727c3dbdd557b9a58659d1ce7fbec51", "oggdec.exe"},
	{"0fb39d4e0b40ea704d90cf8740a52ceee723e60b", "oggenc2_gen.exe"},
	{"1747ecf0c8b26a56aa319900252c157467714ac1", "oggenc2_p4.exe"},
	{"cd95369051f96b9ca3a997658771c5ea52bc874d", "selfdelete.exe"},
	{"ffeaa70bd6321185eafcb067ab2dc441650038bf", "shorten.exe"},
	{"346ce516281c97e92e1b8957ddeca52edcf2d056", "speexdec.exe"},
	{"8a74b767cfe88bf88c068fdae0de02d65589d25e", "takc.exe"},
	{"1c5cedb56358a0e8c4590a863a97c94d7d7e98b2", "ttaenc.exe"},
	{"7dcf6517aa90ed15737ee8ea50ea00a6dece2d27", "valdec.exe"},
	{"8159f4e824b3e343ece95ba6dbb5e16da9c4866e", "volumax.exe"},
	{"62e2805d1b2eb2a4d86a5ca6e6ea58010d05d2a7", "wget.exe"},
	{"b4c67ae8a1f67971a3092f3d6694d86eef7e3b2e", "wupdate.exe"},
	{"4d018ac7f6a42abd53faacfae5055c2a3c176430", "wvunpack.exe"},
	{NULL, NULL}
};

////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////

InitializationThread::InitializationThread(void)
{
	m_bSuccess = false;
}

////////////////////////////////////////////////////////////
// Thread Main
////////////////////////////////////////////////////////////

void InitializationThread::run()
{
	m_bSuccess = false;
	delay();
	
	//Extract all files
	for(int i = 0; i < INT_MAX; i++)
	{
		if(!g_lamexp_tools[i].pcName || !g_lamexp_tools[i].pcHash)
		{
			break;
		}

		try
		{
			qDebug("Extracting file: %s", g_lamexp_tools[i].pcName);
			QString toolName = QString::fromLatin1(g_lamexp_tools[i].pcName);
			QByteArray toolHash = QString::fromLatin1(g_lamexp_tools[i].pcHash).toLatin1();
			LockedFile *lockedFile = new LockedFile(QString(":/tools/%1").arg(toolName), QString(lamexp_temp_folder()).append(QString("/tool_%1").arg(toolName)), toolHash);
			lamexp_register_tool(toolName, lockedFile);
		}
		catch(char *errorMsg)
		{
			qFatal("At least one required tool could not be extracted:\n%s", errorMsg);
			return;
		}
	}
	
	qDebug("All extracted.\n");

	//Look for Nero encoder
	initNeroAac();
	
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
		msleep(100);
	}

	printf("Done\n\n");
}

void InitializationThread::initNeroAac(void)
{
	QFileInfo neroFileInfo[3];
	neroFileInfo[0] = QFileInfo(QString("%1/neroAacEnc.exe").arg(QCoreApplication::applicationDirPath()));
	neroFileInfo[1] = QFileInfo(QString("%1/neroAacDec.exe").arg(QCoreApplication::applicationDirPath()));
	neroFileInfo[2] = QFileInfo(QString("%1/neroAacTag.exe").arg(QCoreApplication::applicationDirPath()));
	
	bool neroFilesFound = true;
	for(int i = 0; i < 3; i++)	{ if(!neroFileInfo[i].exists()) neroFilesFound = false; }

	//Lock the Nero binaries
	if(!neroFilesFound)
	{
		qDebug("Nero encoder binaries not found -> AAC encoding support will be disabled!\n");
		return;
	}

	qDebug("Found Nero AAC encoder binary:\n%s\n", neroFileInfo[0].absoluteFilePath().toUtf8().constData());

	LockedFile *neroBin[3];
	for(int i = 0; i < 3; i++) neroBin[i] = NULL;

	try
	{
		for(int i = 0; i < 3; i++)
		{
			neroBin[i] = new LockedFile(neroFileInfo[i].absoluteFilePath());
		}
	}
	catch(...)
	{
		for(int i = 0; i < 3; i++) LAMEXP_DELETE(neroBin[i]);
		qWarning("Failed to lock Nero encoder binary -> AAC encoding support will be disabled!");
		return;
	}

	QProcess process;
	process.setProcessChannelMode(QProcess::MergedChannels);
	process.setReadChannel(QProcess::StandardOutput);
	process.start(neroFileInfo[0].absoluteFilePath());

	if(!process.waitForStarted())
	{
		qWarning("Nero process failed to create!");
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

		QByteArray data = process.readLine();
		while(!data.isEmpty())
		{
			QString line = QString::fromUtf8(data.constData()).simplified();
			QStringList tokens = line.split(" ", QString::SkipEmptyParts, Qt::CaseInsensitive);
			int index1 = tokens.indexOf("Package");
			int index2 = tokens.indexOf("version:");
			if(index1 >= 0 && index2 >= 0 && index1 + 1 == index2 && index2 < tokens.count() - 1)
			{
				QStringList versionTokens = tokens.at(index2 + 1).split(".", QString::SkipEmptyParts, Qt::CaseInsensitive);
				if(versionTokens.count() == 4)
				{
					neroVersion = 0;
					neroVersion += versionTokens.at(3).toInt();
					neroVersion += versionTokens.at(2).toInt() * 10;
					neroVersion += versionTokens.at(1).toInt() * 100;
					neroVersion += versionTokens.at(0).toInt() * 1000;
				}
			}
			data = process.readLine();
		}
	}

	if(!(neroVersion > 0))
	{
		qWarning("Nero AAC version could not be determined!", neroVersion);
		for(int i = 0; i < 3; i++) LAMEXP_DELETE(neroBin[i]);
		return;
	}
	
	for(int i = 0; i < 3; i++)
	{
		lamexp_register_tool(neroFileInfo[i].fileName(), neroBin[i], neroVersion);
	}
}

////////////////////////////////////////////////////////////
// EVENTS
////////////////////////////////////////////////////////////

/*NONE*/