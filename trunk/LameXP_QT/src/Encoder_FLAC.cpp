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

#include "Encoder_FLAC.h"

#include "Global.h"
#include "Model_Settings.h"

#include <QProcess>
#include <QDir>

#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#define IS_UNICODE(STR) (qstricmp(STR.toUtf8().constData(), QString::fromLocal8Bit(STR.toLocal8Bit()).toUtf8().constData()))

FLACEncoder::FLACEncoder(void)
:
	m_binary(lamexp_lookup_tool("flac.exe"))
{
	if(m_binary.isEmpty())
	{
		throw "Error initializing FLAC encoder. Tool 'flac.exe' is not registred!";
	}
}

FLACEncoder::~FLACEncoder(void)
{
}

bool FLACEncoder::encode(const QString &sourceFile, const AudioFileModel &metaInfo, const QString &outputFile, volatile bool *abortFlag)
{
	QProcess process;
	QStringList args;

	args << QString("-%1").arg(QString::number(max(0, min(8, m_configBitrate))));
	qWarning("Year: %u", metaInfo.fileYear());

	if(!metaInfo.fileName().isEmpty()) args << "-T" << QString("title=%1").arg(metaInfo.fileName());
	if(!metaInfo.fileArtist().isEmpty()) args << "-T" << QString("artist=%1").arg(metaInfo.fileArtist());
	if(!metaInfo.fileAlbum().isEmpty()) args << "-T" << QString("album=%1").arg(metaInfo.fileAlbum());
	if(!metaInfo.fileGenre().isEmpty()) args << "-T" << QString("genre=%1").arg(metaInfo.fileGenre());
	if(!metaInfo.fileComment().isEmpty()) args << "-T" << QString("comment=%1").arg(metaInfo.fileComment());
	if(metaInfo.fileYear()) args << "-T" << QString("date=%1").arg(QString::number(metaInfo.fileYear()));
	if(metaInfo.filePosition()) args << "-T" << QString("track=%1").arg(QString::number(metaInfo.filePosition()));
	
	//args << "--tv" << QString().sprintf("Encoder=LameXP v%d.%02d.%04d [%s]", lamexp_version_major(), lamexp_version_minor(), lamexp_version_build(), lamexp_version_release());

	args << "-f" << "-o" << QDir::toNativeSeparators(outputFile);
	args << QDir::toNativeSeparators(sourceFile);

	if(!startProcess(process, m_binary, args))
	{
		return false;
	}

	bool bTimeout = false;
	bool bAborted = false;

	QRegExp regExp("\\s(\\d+)% complete");

	while(process.state() != QProcess::NotRunning)
	{
		if(*abortFlag)
		{
			process.kill();
			bAborted = true;
			emit messageLogged("\nABORTED BY USER !!!");
			break;
		}
		process.waitForReadyRead();
		if(!process.bytesAvailable() && process.state() == QProcess::Running)
		{
			process.kill();
			qWarning("FLAC process timed out <-- killing!");
			bTimeout = true;
			break;
		}
		while(process.bytesAvailable() > 0)
		{
			QByteArray line = process.readLine();
			QString text = QString::fromUtf8(line.constData()).simplified();
			if(regExp.lastIndexIn(text) >= 0)
			{
				bool ok = false;
				int progress = regExp.cap(1).toInt(&ok);
				if(ok) emit statusUpdated(progress);
			}
			else if(!text.isEmpty())
			{
				emit messageLogged(text);
			}
		}
	}

	process.waitForFinished();
	if(process.state() != QProcess::NotRunning)
	{
		process.kill();
		process.waitForFinished(-1);
	}
	
	emit statusUpdated(100);
	emit messageLogged(QString().sprintf("\nExited with code: 0x%04X", process.exitCode()));

	if(bTimeout || bAborted || process.exitStatus() != QProcess::NormalExit)
	{
		return false;
	}
	
	return true;
}

QString FLACEncoder::extension(void)
{
	return "flac";
}

bool FLACEncoder::isFormatSupported(const QString &containerType, const QString &containerProfile, const QString &formatType, const QString &formatProfile, const QString &formatVersion)
{
	if(containerType.compare("Wave", Qt::CaseInsensitive) == 0)
	{
		if(formatType.compare("PCM", Qt::CaseInsensitive) == 0)
		{
			return true;
		}
	}

	return false;
}
