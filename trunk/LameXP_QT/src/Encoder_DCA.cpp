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

#include "Encoder_DCA.h"

#include "Global.h"
#include "Model_Settings.h"

#include <QProcess>
#include <QDir>
#include <limits.h>

static int index2bitrate(const int index)
{
	return (index < 8) ? ((index + 1) * 32) : ((index < 12) ? ((index - 3) * 64) : ((index < 24) ? (index - 7) * 128 : (index - 15) * 256));
}

///////////////////////////////////////////////////////////////////////////////
// Encoder Info
///////////////////////////////////////////////////////////////////////////////

class DCAEncoderInfo : public AbstractEncoderInfo
{
	virtual bool isModeSupported(int mode) const
	{
		switch(mode)
		{
		case SettingsModel::VBRMode:
		case SettingsModel::ABRMode:
			return false;
			break;
		case SettingsModel::CBRMode:
			return true;
			break;
		default:
			THROW("Bad RC mode specified!");
		}
	}

	virtual int valueCount(int mode) const
	{
		switch(mode)
		{
		case SettingsModel::VBRMode:
		case SettingsModel::ABRMode:
			return 0;
			break;
		case SettingsModel::CBRMode:
			return 32;
			break;
		default:
			THROW("Bad RC mode specified!");
		}
	}

	virtual int valueAt(int mode, int index) const
	{
		switch(mode)
		{
		case SettingsModel::VBRMode:
		case SettingsModel::ABRMode:
			return 0;
			break;
		case SettingsModel::CBRMode:
			return qBound(32, index2bitrate(index), 4096);
			break;
		default:
			THROW("Bad RC mode specified!");
		}
	}

	virtual int valueType(int mode) const
	{
		switch(mode)
		{
		case SettingsModel::VBRMode:
			return TYPE_QUALITY_LEVEL_INT;
			break;
		case SettingsModel::ABRMode:
		case SettingsModel::CBRMode:
			return TYPE_BITRATE;
			break;
		default:
			THROW("Bad RC mode specified!");
		}
	}

	virtual const char *description(void) const
	{
		static const char* s_description = "dcaenc-2 by Alexander E. Patrakov";
		return s_description;
	}
}
static const g_dcaEncoderInfo;

///////////////////////////////////////////////////////////////////////////////
// Encoder implementation
///////////////////////////////////////////////////////////////////////////////

DCAEncoder::DCAEncoder(void)
:
	m_binary(lamexp_lookup_tool("dcaenc.exe"))
{
	if(m_binary.isEmpty())
	{
		THROW("Error initializing DCA encoder. Tool 'dcaenc.exe' is not registred!");
	}
}

DCAEncoder::~DCAEncoder(void)
{
}

bool DCAEncoder::encode(const QString &sourceFile, const AudioFileModel_MetaInfo &metaInfo, const unsigned int duration, const QString &outputFile, volatile bool *abortFlag)
{
	QProcess process;
	QStringList args;

	args << "-i" << QDir::toNativeSeparators(sourceFile);
	args << "-o" << QDir::toNativeSeparators(outputFile);
	args << "-b" << QString::number(qBound(32, index2bitrate(m_configBitrate), 4096));

	if(!startProcess(process, m_binary, args))
	{
		return false;
	}

	bool bTimeout = false;
	bool bAborted = false;
	int prevProgress = -1;

	QRegExp regExp("\\[(\\d+)\\.(\\d+)%\\]");

	while(process.state() != QProcess::NotRunning)
	{
		if(*abortFlag)
		{
			process.kill();
			bAborted = true;
			emit messageLogged("\nABORTED BY USER !!!");
			break;
		}
		process.waitForReadyRead(m_processTimeoutInterval);
		if(!process.bytesAvailable() && process.state() == QProcess::Running)
		{
			process.kill();
			qWarning("DCAENC process timed out <-- killing!");
			emit messageLogged("\nPROCESS TIMEOUT !!!");
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
				if(ok && (progress > prevProgress))
				{
					emit statusUpdated(progress);
					prevProgress = qMin(progress + 2, 99);
				}
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

	if(bTimeout || bAborted || process.exitCode() != EXIT_SUCCESS)
	{
		return false;
	}
	
	return true;
}

QString DCAEncoder::extension(void)
{
	return "dts";
}

bool DCAEncoder::isFormatSupported(const QString &containerType, const QString &containerProfile, const QString &formatType, const QString &formatProfile, const QString &formatVersion)
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

const unsigned int *DCAEncoder::supportedChannelCount(void)
{
	static const unsigned int supportedChannels[] = {1, 2, 4, 5, 6, NULL};
	return supportedChannels;
}

const unsigned int *DCAEncoder::supportedSamplerates(void)
{
	static const unsigned int supportedRates[] = {48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, NULL};
	return supportedRates;
}

const unsigned int *DCAEncoder::supportedBitdepths(void)
{
	static const unsigned int supportedBPS[] = {16, 32, NULL};
	return supportedBPS;
}

const AbstractEncoderInfo *DCAEncoder::getEncoderInfo(void)
{
	return &g_dcaEncoderInfo;
}
