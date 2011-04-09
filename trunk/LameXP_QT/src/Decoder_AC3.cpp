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

#include "Decoder_AC3.h"

#include "Global.h"

#include <QDir>
#include <QProcess>
#include <QRegExp>

AC3Decoder::AC3Decoder(void)
:
	m_binary(lamexp_lookup_tool("valdec.exe"))
{
	if(m_binary.isEmpty())
	{
		throw "Error initializing Valib decoder. Tool 'valdec.exe' is not registred!";
	}
}

AC3Decoder::~AC3Decoder(void)
{
}

bool AC3Decoder::decode(const QString &sourceFile, const QString &outputFile, volatile bool *abortFlag)
{
	QProcess process;
	QStringList args;

	args << QDir::toNativeSeparators(sourceFile);
	args << "-w" << QDir::toNativeSeparators(outputFile);

	if(!startProcess(process, m_binary, args))
	{
		return false;
	}

	bool bTimeout = false;
	bool bAborted = false;

	QRegExp regExp("\\[(\\s*)(\\d+)\\.(\\d+)%\\]");

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
			qWarning("Valdec process timed out <-- killing!");
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
				int progress = regExp.cap(2).toInt(&ok);
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

	if(bTimeout || bAborted || process.exitStatus() != QProcess::NormalExit || QFileInfo(outputFile).size() == 0)
	{
		return false;
	}
	
	return true;
}

bool AC3Decoder::isFormatSupported(const QString &containerType, const QString &containerProfile, const QString &formatType, const QString &formatProfile, const QString &formatVersion)
{
	if(containerType.compare("AC-3", Qt::CaseInsensitive) == 0)
	{
		if(formatType.compare("AC-3", Qt::CaseInsensitive) == 0)
		{
			return true;
		}
	}
	else if(containerType.compare("DTS", Qt::CaseInsensitive) == 0)
	{
		if(formatType.compare("DTS", Qt::CaseInsensitive) == 0)
		{
			return true;
		}
	}
	else if(containerType.compare("Wave", Qt::CaseInsensitive) == 0)
	{
		if(formatType.compare("AC-3", Qt::CaseInsensitive) == 0 || formatType.compare("DTS", Qt::CaseInsensitive) == 0)
		{
			return true;
		}
	}

	return false;
}

QStringList AC3Decoder::supportedTypes(void)
{
	return QStringList() << "AC-3 / ATSC A/52 (*.ac3 *.wav)" << "Digital Theater System (*.dts)";
}

