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

#include "Thread_FileAnalyzer.h"

#include "Global.h"
#include "LockedFile.h"

#include <QFileInfo>
#include <QProcess>

////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////

FileAnalyzer::FileAnalyzer(const QStringList &inputFiles)
	: m_inputFiles(inputFiles)
{
	m_bSuccess = false;
	m_mediaInfoBin = lamexp_lookup_tool("mediainfo_icl11.exe");
	
	if(m_mediaInfoBin.isEmpty())
	{
		qFatal("Invalid path to MediaInfo binary. Tool not initialized properly.");
	}
}

////////////////////////////////////////////////////////////
// Thread Main
////////////////////////////////////////////////////////////

void FileAnalyzer::run()
{
	m_bSuccess = false;
	m_inputFiles.sort();

	while(!m_inputFiles.isEmpty())
	{
		QString currentFile = m_inputFiles.takeFirst();
		qDebug("Adding: %s", currentFile.toLatin1().constData());
		emit fileSelected(QFileInfo(currentFile).fileName());
		AudioFileModel file = analyzeFile(currentFile);
		emit fileAnalyzed(file);
	}

	qDebug("All files added.\n");
	m_bSuccess = true;
}

////////////////////////////////////////////////////////////
// Public Functions
////////////////////////////////////////////////////////////

const AudioFileModel FileAnalyzer::analyzeFile(const QString &filePath)
{
	AudioFileModel audioFile(filePath, QFileInfo(filePath).fileName());
	m_currentSection = sectionOther;

	QProcess process;
	process.setProcessChannelMode(QProcess::MergedChannels);
	process.setReadChannel(QProcess::StandardOutput);
	process.start(m_mediaInfoBin, QStringList() << filePath);

	while(process.state() != QProcess::NotRunning)
	{
		process.waitForReadyRead(1000);
		QByteArray data = process.readLine().constData();
		while(data.size() > 0)
		{
			QString line = QString::fromUtf8(data).trimmed();
			if(!line.isEmpty())
			{
				int index = line.indexOf(':');
				if(index > 0)
				{
					QString key = line.left(index-1).trimmed();
					QString val = line.mid(index+1).trimmed();
					if(!key.isEmpty() && !val.isEmpty())
					{
						updateInfo(audioFile, key, val);
					}
				}
				else
				{
					updateSection(line);
				}
			}
			data = process.readLine().constData();
		}
	}

	return AudioFileModel(audioFile);
}

void FileAnalyzer::updateSection(const QString &section)
{
	if(section.startsWith("General", Qt::CaseInsensitive))
	{
		m_currentSection = sectionGeneral;
	}
	else if(!section.compare("Audio", Qt::CaseInsensitive) || section.startsWith("Audio #1", Qt::CaseInsensitive))
	{
		m_currentSection = sectionAudio;
	}
	else if(section.startsWith("Audio", Qt::CaseInsensitive) || section.startsWith("Video", Qt::CaseInsensitive) || section.startsWith("Text", Qt::CaseInsensitive) ||
		section.startsWith("Menu", Qt::CaseInsensitive) || section.startsWith("Image", Qt::CaseInsensitive) || section.startsWith("Chapters", Qt::CaseInsensitive))
	{
		m_currentSection = sectionOther;
	}
	else
	{
		qWarning("Unknown section: %s", section.toLatin1().constData());
	}
}

void FileAnalyzer::updateInfo(AudioFileModel &audioFile, const QString &key, const QString &value)
{
	switch(m_currentSection)
	{
	case sectionGeneral:
		if(!key.compare("Title", Qt::CaseInsensitive) || !key.compare("Track", Qt::CaseInsensitive) || !key.compare("Track Name", Qt::CaseInsensitive))
		{
			audioFile.setFileName(value);
		}
		/* !!! TODO !!! */
		break;
	case sectionAudio:
		/* !!! TODO !!! */
		break;
	}
}

////////////////////////////////////////////////////////////
// EVENTS
////////////////////////////////////////////////////////////

/*NONE*/