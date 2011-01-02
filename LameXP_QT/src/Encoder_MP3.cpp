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

#include "Encoder_MP3.h"

#include "Global.h"
#include "Model_Settings.h"

#include <QProcess>
#include <QDir>

#define IS_UNICODE(STR) (qstricmp(STR.toUtf8().constData(), QString::fromLocal8Bit(STR.toLocal8Bit()).toUtf8().constData()))

MP3Encoder::MP3Encoder(void)
:
	m_binary(lamexp_lookup_tool("lame.exe"))
{
	if(m_binary.isEmpty())
	{
		throw "Error initializing MP3 encoder. Tool 'lame.exe' is not registred!";
	}
}

MP3Encoder::~MP3Encoder(void)
{
}

bool MP3Encoder::encode(const QString &sourceFile, const AudioFileModel &metaInfo, const QString &outputFile, volatile bool *abortFlag)
{
	QProcess process;
	QStringList args;

	args << "--nohist";
	args << "-h";
		
	switch(m_configRCMode)
	{
	case SettingsModel::VBRMode:
		args << "-V" << QString::number(9 - min(9, m_configBitrate));
		break;
	case SettingsModel::ABRMode:
		args << "--abr" << QString::number(SettingsModel::mp3Bitrates[min(13, m_configBitrate)]);
		break;
	case SettingsModel::CBRMode:
		args << "--cbr";
		args << "-b" << QString::number(SettingsModel::mp3Bitrates[min(13, m_configBitrate)]);
		break;
	default:
		throw "Bad rate-control mode!";
		break;
	}

	if(!metaInfo.fileName().isEmpty()) args << (IS_UNICODE(metaInfo.fileName()) ? "--uTitle" : "--lTitle") << metaInfo.fileName();
	if(!metaInfo.fileArtist().isEmpty()) args << (IS_UNICODE(metaInfo.fileArtist()) ? "--uArtist" : "--lArtist") << metaInfo.fileArtist();
	if(!metaInfo.fileAlbum().isEmpty()) args << (IS_UNICODE(metaInfo.fileAlbum()) ? "--uAlbum" : "--lAlbum") << metaInfo.fileAlbum();
	if(!metaInfo.fileGenre().isEmpty()) args << (IS_UNICODE(metaInfo.fileGenre()) ? "--uGenre" : "--lGenre") << metaInfo.fileGenre();
	if(!metaInfo.fileComment().isEmpty()) args << (IS_UNICODE(metaInfo.fileComment()) ? "--uComment" : "--lComment") << metaInfo.fileComment();
	if(metaInfo.fileYear()) args << "--ty" << QString::number(metaInfo.fileYear());
	if(metaInfo.filePosition()) args << "--tn" << QString::number(metaInfo.filePosition());
	
	//args << "--tv" << QString().sprintf("Encoder=LameXP v%d.%02d.%04d [%s]", lamexp_version_major(), lamexp_version_minor(), lamexp_version_build(), lamexp_version_release());

	args << QDir::toNativeSeparators(sourceFile);
	args << QDir::toNativeSeparators(outputFile);

	if(!startProcess(process, m_binary, args))
	{
		return false;
	}

	bool bTimeout = false;
	bool bAborted = false;

	QRegExp regExp("\\(.*(\\d+)%\\)\\|");

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
			qWarning("LAME process timed out <-- killing!");
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

QString MP3Encoder::extension(void)
{
	return "mp3";
}

bool MP3Encoder::isFormatSupported(const QString &containerType, const QString &containerProfile, const QString &formatType, const QString &formatProfile, const QString &formatVersion)
{
	if(containerType.compare("Wave", Qt::CaseInsensitive) == 0)
	{
		if(formatType.compare("PCM", Qt::CaseInsensitive) == 0)
		{
			return true;
		}
	}
	else if(containerType.compare("MPEG Audio", Qt::CaseInsensitive) == 0)
	{
		if(formatType.compare("MPEG Audio", Qt::CaseInsensitive) == 0)
		{
			if(formatProfile.compare("Layer 3", Qt::CaseInsensitive) == 0 || formatProfile.compare("Layer 2", Qt::CaseInsensitive) == 0)
			{
				if(formatVersion.compare("Version 1", Qt::CaseInsensitive) == 0 || formatVersion.compare("Version 2", Qt::CaseInsensitive) == 0)
				{
					return true;
				}
			}
		}
	}

	return false;
}

bool MP3Encoder::requiresDownmix(void)
{
	return true;
}
