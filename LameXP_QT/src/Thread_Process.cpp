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

#include "Thread_Process.h"

#include "Global.h"
#include "Model_AudioFile.h"
#include "Model_Progress.h"
#include "Encoder_Abstract.h"
#include "Decoder_Abstract.h"
#include "Filter_Abstract.h"
#include "Filter_Downmix.h"
#include "Filter_Resample.h"
#include "Registry_Decoder.h"
#include "Model_Settings.h"

#include <QUuid>
#include <QFileInfo>
#include <QDir>
#include <QMutex>
#include <QMutexLocker>
#include <QDate>

#include <limits.h>
#include <time.h>
#include <stdlib.h>

#define DIFF(X,Y) ((X > Y) ? (X-Y) : (Y-X))

QMutex *ProcessThread::m_mutex_genFileName = NULL;

////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////

ProcessThread::ProcessThread(const AudioFileModel &audioFile, const QString &outputDirectory, const QString &tempDirectory, AbstractEncoder *encoder, const bool prependRelativeSourcePath)
:
	m_audioFile(audioFile),
	m_outputDirectory(outputDirectory),
	m_tempDirectory(tempDirectory),
	m_encoder(encoder),
	m_jobId(QUuid::createUuid()),
	m_prependRelativeSourcePath(prependRelativeSourcePath),
	m_aborted(false)
{
	if(m_mutex_genFileName)
	{
		m_mutex_genFileName = new QMutex;
	}

	connect(m_encoder, SIGNAL(statusUpdated(int)), this, SLOT(handleUpdate(int)), Qt::DirectConnection);
	connect(m_encoder, SIGNAL(messageLogged(QString)), this, SLOT(handleMessage(QString)), Qt::DirectConnection);

	m_currentStep = UnknownStep;
}

ProcessThread::~ProcessThread(void)
{
	while(!m_tempFiles.isEmpty())
	{
		lamexp_remove_file(m_tempFiles.takeFirst());
	}

	while(!m_filters.isEmpty())
	{
		delete m_filters.takeFirst();
	}

	LAMEXP_DELETE(m_encoder);
}

////////////////////////////////////////////////////////////
// Thread Entry Point
////////////////////////////////////////////////////////////

void ProcessThread::run()
{
	try
	{
		processFile();
	}
	catch(...)
	{
		fflush(stdout);
		fflush(stderr);
		fprintf(stderr, "\nGURU MEDITATION !!!\n");
		FatalAppExit(0, L"Unhandeled exception error, application will exit!");
		TerminateProcess(GetCurrentProcess(), -1);
	}
}

void ProcessThread::processFile()
{
	m_aborted = false;
	bool bSuccess = true;
		
	qDebug("Process thread %s has started.", m_jobId.toString().toLatin1().constData());
	emit processStateInitialized(m_jobId, QFileInfo(m_audioFile.filePath()).fileName(), tr("Starting..."), ProgressModel::JobRunning);
	handleMessage(QString().sprintf("LameXP v%u.%02u (Build #%u), compiled at %s", lamexp_version_major(), lamexp_version_minor(), lamexp_version_build(), lamexp_version_date().toString(Qt::ISODate).toLatin1().constData()));
	handleMessage("\n-------------------------------\n");

	//Generate output file name
	QString outFileName = generateOutFileName();
	if(outFileName.isEmpty())
	{
		emit processStateChanged(m_jobId, tr("Not found!"), ProgressModel::JobFailed);
		emit processStateFinished(m_jobId, outFileName, false);
		return;
	}

	//Do we need to take of downsampling the input?
	if(m_encoder->requiresDownsample())
	{
		insertDownsampleFilter();
	}

	//Do we need Stereo downmix?
	if(m_audioFile.formatAudioChannels() > 2 && m_encoder->requiresDownmix())
	{
		m_filters.prepend(new DownmixFilter());
	}

	QString sourceFile = m_audioFile.filePath();

	//Decode source file
	if(!m_filters.isEmpty() || !m_encoder->isFormatSupported(m_audioFile.formatContainerType(), m_audioFile.formatContainerProfile(), m_audioFile.formatAudioType(), m_audioFile.formatAudioProfile(), m_audioFile.formatAudioVersion()))
	{
		m_currentStep = DecodingStep;
		AbstractDecoder *decoder = DecoderRegistry::lookup(m_audioFile.formatContainerType(), m_audioFile.formatContainerProfile(), m_audioFile.formatAudioType(), m_audioFile.formatAudioProfile(), m_audioFile.formatAudioVersion());
		
		if(decoder)
		{
			QString tempFile = generateTempFileName();

			connect(decoder, SIGNAL(statusUpdated(int)), this, SLOT(handleUpdate(int)), Qt::DirectConnection);
			connect(decoder, SIGNAL(messageLogged(QString)), this, SLOT(handleMessage(QString)), Qt::DirectConnection);

			bSuccess = decoder->decode(sourceFile, tempFile, &m_aborted);
			LAMEXP_DELETE(decoder);

			if(bSuccess)
			{
				sourceFile = tempFile;
				handleMessage("\n-------------------------------\n");
			}
		}
		else
		{
			handleMessage(QString("%1\n%2\n\n%3\t%4\n%5\t%6").arg(tr("The format of this file is NOT supported:"), m_audioFile.filePath(), tr("Container Format:"), m_audioFile.formatContainerInfo(), tr("Audio Format:"), m_audioFile.formatAudioCompressInfo()));
			emit processStateChanged(m_jobId, tr("Unsupported!"), ProgressModel::JobFailed);
			emit processStateFinished(m_jobId, outFileName, false);
			return;
		}
	}

	//Apply all filters
	while(!m_filters.isEmpty())
	{
		QString tempFile = generateTempFileName();
		AbstractFilter *poFilter = m_filters.takeFirst();

		if(bSuccess)
		{
			connect(poFilter, SIGNAL(statusUpdated(int)), this, SLOT(handleUpdate(int)), Qt::DirectConnection);
			connect(poFilter, SIGNAL(messageLogged(QString)), this, SLOT(handleMessage(QString)), Qt::DirectConnection);

			m_currentStep = FilteringStep;
			bSuccess = poFilter->apply(sourceFile, tempFile, &m_aborted);

			if(bSuccess)
			{
				sourceFile = tempFile;
				handleMessage("\n-------------------------------\n");
			}
		}

		delete poFilter;
	}

	//Encode audio file
	if(bSuccess)
	{
		m_currentStep = EncodingStep;
		bSuccess = m_encoder->encode(sourceFile, m_audioFile, outFileName, &m_aborted);
	}

	//Make sure output file exists
	if(bSuccess)
	{
		QFileInfo fileInfo(outFileName);
		bSuccess = fileInfo.exists() && fileInfo.isFile() && (fileInfo.size() > 0);
	}

	//Report result
	emit processStateChanged(m_jobId, (bSuccess ? tr("Done.") : (m_aborted ? tr("Aborted!") : tr("Failed!"))), (bSuccess ? ProgressModel::JobComplete : ProgressModel::JobFailed));
	emit processStateFinished(m_jobId, outFileName, bSuccess);

	qDebug("Process thread is done.");
}

////////////////////////////////////////////////////////////
// SLOTS
////////////////////////////////////////////////////////////

void ProcessThread::handleUpdate(int progress)
{
	switch(m_currentStep)
	{
	case EncodingStep:
		emit processStateChanged(m_jobId, QString("%1 (%2%)").arg(tr("Encoding"), QString::number(progress)), ProgressModel::JobRunning);
		break;
	case FilteringStep:
		emit processStateChanged(m_jobId, QString("%1 (%2%)").arg(tr("Filtering"), QString::number(progress)), ProgressModel::JobRunning);
		break;
	case DecodingStep:
		emit processStateChanged(m_jobId, QString("%1 (%2%)").arg(tr("Decoding"), QString::number(progress)), ProgressModel::JobRunning);
		break;
	}
}

void ProcessThread::handleMessage(const QString &line)
{
	emit processMessageLogged(m_jobId, line);
}

////////////////////////////////////////////////////////////
// PRIVAE FUNCTIONS
////////////////////////////////////////////////////////////

QString ProcessThread::generateOutFileName(void)
{
	QMutexLocker lock(m_mutex_genFileName);
	
	int n = 1;

	QFileInfo sourceFile(m_audioFile.filePath());
	if(!sourceFile.exists() || !sourceFile.isFile())
	{
		handleMessage(QString("%1\n%2").arg(tr("The source audio file could not be found:"), sourceFile.absoluteFilePath()));
		return QString();
	}

	QFile readTest(sourceFile.canonicalFilePath());
	if(!readTest.open(QIODevice::ReadOnly))
	{
		handleMessage(QString("%1\n%2").arg(tr("The source audio file could not be opened for reading:"), readTest.fileName()));
		return QString();
	}
	else
	{
		readTest.close();
	}

	QString baseName = sourceFile.completeBaseName();
	QDir targetDir(m_outputDirectory.isEmpty() ? sourceFile.canonicalPath() : m_outputDirectory);

	if(m_prependRelativeSourcePath && !m_outputDirectory.isEmpty())
	{
		QDir rootDir = sourceFile.dir();
		while(!rootDir.isRoot())
		{
			if(!rootDir.cdUp()) break;
		}
		targetDir.setPath(QString("%1/%2").arg(targetDir.absolutePath(), QFileInfo(rootDir.relativeFilePath(sourceFile.canonicalFilePath())).path()));
	}
	
	if(!targetDir.exists())
	{
		targetDir.mkpath(".");
		if(!targetDir.exists())
		{
			handleMessage(QString("%1\n%2").arg(tr("The target output directory doesn't exist and could NOT be created:"), targetDir.absolutePath()));
			return QString();
		}
	}
	
	QFile writeTest(QString("%1/.%2").arg(targetDir.canonicalPath(), lamexp_rand_str()));
	if(!writeTest.open(QIODevice::ReadWrite))
	{
		handleMessage(QString("%1\n%2").arg(tr("The target output directory is NOT writable:"), targetDir.absolutePath()));
		return QString();
	}
	else
	{
		writeTest.close();
		writeTest.remove();
	}

	QString outFileName = QString("%1/%2.%3").arg(targetDir.canonicalPath(), baseName, m_encoder->extension());
	while(QFileInfo(outFileName).exists())
	{
		outFileName = QString("%1/%2 (%3).%4").arg(targetDir.canonicalPath(), baseName, QString::number(++n), m_encoder->extension());
	}

	QFile placeholder(outFileName);
	if(placeholder.open(QIODevice::WriteOnly))
	{
		placeholder.close();
	}

	return outFileName;
}

QString ProcessThread::generateTempFileName(void)
{
	QMutexLocker lock(m_mutex_genFileName);
	QString tempFileName = QString("%1/%2.wav").arg(m_tempDirectory, lamexp_rand_str());

	while(QFileInfo(tempFileName).exists())
	{
		tempFileName = QString("%1/%2.wav").arg(m_tempDirectory, lamexp_rand_str());
	}

	QFile file(tempFileName);
	if(file.open(QFile::ReadWrite))
	{
		file.close();
	}

	m_tempFiles << tempFileName;
	return tempFileName;
}

void ProcessThread::insertDownsampleFilter(void)
{
	bool applyDownsampling = true;
		
	//Check if downsampling filter is already in the chain
	for(int i = 0; i < m_filters.count(); i++)
	{
		if(dynamic_cast<ResampleFilter*>(m_filters.at(i)))
		{
			qWarning("Encoder requires downsampling, but user has already set resamling filter!");
			applyDownsampling = false;
		}
	}
		
	//Now add the downsampling filter, if needed
	if(applyDownsampling)
	{
		const unsigned int *supportedRates = m_encoder->requiresDownsample();
		const unsigned int inputRate = m_audioFile.formatAudioSamplerate();
		unsigned int currentDiff = UINT_MAX, minimumDiff = UINT_MAX, bestRate = UINT_MAX;

		//Find the most suitable supported sampling rate
		for(int i = 0; supportedRates[i]; i++)
		{
			currentDiff = DIFF(inputRate, supportedRates[i]);
			if(currentDiff < minimumDiff)
			{
				bestRate = supportedRates[i];
				minimumDiff = currentDiff;
				if(!(minimumDiff > 0)) break;
			}
		}
		
		if(bestRate != inputRate)
		{
			m_filters.prepend(new ResampleFilter((bestRate != UINT_MAX) ? bestRate : supportedRates[0]));
		}
	}
}

////////////////////////////////////////////////////////////
// PUBLIC FUNCTIONS
////////////////////////////////////////////////////////////

void ProcessThread::addFilter(AbstractFilter *filter)
{
	m_filters.append(filter);
}

////////////////////////////////////////////////////////////
// EVENTS
////////////////////////////////////////////////////////////

/*NONE*/
