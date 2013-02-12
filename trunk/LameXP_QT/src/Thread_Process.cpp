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

#include "Thread_Process.h"

#include "Global.h"
#include "Model_AudioFile.h"
#include "Model_Progress.h"
#include "Encoder_Abstract.h"
#include "Decoder_Abstract.h"
#include "Filter_Abstract.h"
#include "Filter_Downmix.h"
#include "Filter_Resample.h"
#include "Tool_WaveProperties.h"
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
#define IS_WAVE(X) ((X.formatContainerType().compare("Wave", Qt::CaseInsensitive) == 0) && (X.formatAudioType().compare("PCM", Qt::CaseInsensitive) == 0))
#define STRDEF(STR,DEF) ((!STR.isEmpty()) ? STR : DEF)

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
	m_renamePattern("<BaseName>"),
	m_overwriteSkipExistingFile(false),
	m_overwriteReplacesExisting(false),
	m_aborted(false),
	m_propDetect(new WaveProperties())
{
	if(m_mutex_genFileName)
	{
		m_mutex_genFileName = new QMutex;
	}

	connect(m_encoder, SIGNAL(statusUpdated(int)), this, SLOT(handleUpdate(int)), Qt::DirectConnection);
	connect(m_encoder, SIGNAL(messageLogged(QString)), this, SLOT(handleMessage(QString)), Qt::DirectConnection);

	connect(m_propDetect, SIGNAL(statusUpdated(int)), this, SLOT(handleUpdate(int)), Qt::DirectConnection);
	connect(m_propDetect, SIGNAL(messageLogged(QString)), this, SLOT(handleMessage(QString)), Qt::DirectConnection);

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
	LAMEXP_DELETE(m_propDetect);
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
		lamexp_fatal_exit(L"Unhandeled exception error, application will exit!");
	}
}

void ProcessThread::processFile()
{
	m_aborted = false;
	bool bSuccess = true;
		
	qDebug("Process thread %s has started.", m_jobId.toString().toLatin1().constData());
	emit processStateInitialized(m_jobId, QFileInfo(m_audioFile.filePath()).fileName(), tr("Starting..."), ProgressModel::JobRunning);
	handleMessage(QString().sprintf("LameXP v%u.%02u (Build #%u), compiled on %s at %s", lamexp_version_major(), lamexp_version_minor(), lamexp_version_build(), lamexp_version_date().toString(Qt::ISODate).toLatin1().constData(), lamexp_version_time()));
	handleMessage("\n-------------------------------\n");

	//Generate output file name
	QString outFileName;
	switch(generateOutFileName(outFileName))
	{
	case 1:
		//File name generated successfully :-)
		break;
	case -1:
		//File name already exists -> skipping!
		emit processStateChanged(m_jobId, tr("Skipped."), ProgressModel::JobSkipped);
		emit processStateFinished(m_jobId, outFileName, -1);
		return;
	default:
		//File name could not be generated
		emit processStateChanged(m_jobId, tr("Not found!"), ProgressModel::JobFailed);
		emit processStateFinished(m_jobId, outFileName, 0);
		return;
	}

	QString sourceFile = m_audioFile.filePath();

	//------------------
	//Decode source file
	//------------------
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
				m_audioFile.setFormatContainerType(QString::fromLatin1("Wave"));
				m_audioFile.setFormatAudioType(QString::fromLatin1("PCM"));

				if(QFileInfo(sourceFile).size() >= 4294967296i64)
				{
					handleMessage(tr("WARNING: Decoded file size exceeds 4 GB, problems might occur!\n"));
				}

				handleMessage("\n-------------------------------\n");
			}
		}
		else
		{
			if(QFileInfo(outFileName).exists() && (QFileInfo(outFileName).size() < 512)) QFile::remove(outFileName);
			handleMessage(QString("%1\n%2\n\n%3\t%4\n%5\t%6").arg(tr("The format of this file is NOT supported:"), m_audioFile.filePath(), tr("Container Format:"), m_audioFile.formatContainerInfo(), tr("Audio Format:"), m_audioFile.formatAudioCompressInfo()));
			emit processStateChanged(m_jobId, tr("Unsupported!"), ProgressModel::JobFailed);
			emit processStateFinished(m_jobId, outFileName, 0);
			return;
		}
	}

	//------------------------------------
	//Update audio properties after decode
	//------------------------------------
	if(bSuccess && !m_aborted && IS_WAVE(m_audioFile))
	{
		if(m_encoder->supportedSamplerates() || m_encoder->supportedBitdepths() || m_encoder->supportedChannelCount() || m_encoder->needsTimingInfo() || !m_filters.isEmpty())
		{
			m_currentStep = AnalyzeStep;
			bSuccess = m_propDetect->detect(sourceFile, &m_audioFile, &m_aborted);

			if(bSuccess)
			{
				handleMessage("\n-------------------------------\n");

				//Do we need to take care if Stereo downmix?
				if(m_encoder->supportedChannelCount())
				{
					insertDownmixFilter();
				}

				//Do we need to take care of downsampling the input?
				if(m_encoder->supportedSamplerates() || m_encoder->supportedBitdepths())
				{
					insertDownsampleFilter();
				}
			}
		}
	}

	//-----------------------
	//Apply all audio filters
	//-----------------------
	if(bSuccess)
	{
		while(!m_filters.isEmpty() && !m_aborted)
		{
			QString tempFile = generateTempFileName();
			AbstractFilter *poFilter = m_filters.takeFirst();
			m_currentStep = FilteringStep;

			connect(poFilter, SIGNAL(statusUpdated(int)), this, SLOT(handleUpdate(int)), Qt::DirectConnection);
			connect(poFilter, SIGNAL(messageLogged(QString)), this, SLOT(handleMessage(QString)), Qt::DirectConnection);

			if(poFilter->apply(sourceFile, tempFile, &m_audioFile, &m_aborted))
			{
				sourceFile = tempFile;
			}

			handleMessage("\n-------------------------------\n");
			delete poFilter;
		}
	}

	//-----------------
	//Encode audio file
	//-----------------
	if(bSuccess && !m_aborted)
	{
		m_currentStep = EncodingStep;
		bSuccess = m_encoder->encode(sourceFile, m_audioFile, outFileName, &m_aborted);
	}

	//Clean-up
	if((!bSuccess) || m_aborted)
	{
		QFileInfo fileInfo(outFileName);
		if(fileInfo.exists() && (fileInfo.size() < 512))
		{
			QFile::remove(outFileName);
		}
	}

	//Make sure output file exists
	if(bSuccess && (!m_aborted))
	{
		QFileInfo fileInfo(outFileName);
		bSuccess = fileInfo.exists() && fileInfo.isFile() && (fileInfo.size() > 0);
	}

	QThread::msleep(125);

	//Report result
	emit processStateChanged(m_jobId, (m_aborted ? tr("Aborted!") : (bSuccess ? tr("Done.") : tr("Failed!"))), ((bSuccess && !m_aborted) ? ProgressModel::JobComplete : ProgressModel::JobFailed));
	emit processStateFinished(m_jobId, outFileName, (bSuccess ? 1 : 0));

	qDebug("Process thread is done.");
}

////////////////////////////////////////////////////////////
// SLOTS
////////////////////////////////////////////////////////////

void ProcessThread::handleUpdate(int progress)
{
	//printf("Progress: %d\n", progress);
	
	switch(m_currentStep)
	{
	case EncodingStep:
		emit processStateChanged(m_jobId, QString("%1 (%2%)").arg(tr("Encoding"), QString::number(progress)), ProgressModel::JobRunning);
		break;
	case AnalyzeStep:
		emit processStateChanged(m_jobId, QString("%1 (%2%)").arg(tr("Analyzing"), QString::number(progress)), ProgressModel::JobRunning);
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

int ProcessThread::generateOutFileName(QString &outFileName)
{
	outFileName.clear();

	QMutexLocker lock(m_mutex_genFileName);

	//Make sure the source file exists
	QFileInfo sourceFile(m_audioFile.filePath());
	if(!sourceFile.exists() || !sourceFile.isFile())
	{
		handleMessage(QString("%1\n%2").arg(tr("The source audio file could not be found:"), sourceFile.absoluteFilePath()));
		return 0;
	}

	//Make sure the source file readable
	QFile readTest(sourceFile.canonicalFilePath());
	if(!readTest.open(QIODevice::ReadOnly))
	{
		handleMessage(QString("%1\n%2").arg(tr("The source audio file could not be opened for reading:"), QDir::toNativeSeparators(readTest.fileName())));
		return 0;
	}
	else
	{
		readTest.close();
	}

	QString baseName = sourceFile.completeBaseName();
	QDir targetDir(m_outputDirectory.isEmpty() ? sourceFile.canonicalPath() : m_outputDirectory);

	//Prepend relative source file path?
	if(m_prependRelativeSourcePath && !m_outputDirectory.isEmpty())
	{
		QDir rootDir = sourceFile.dir();
		while(!rootDir.isRoot())
		{
			if(!rootDir.cdUp()) break;
		}
		targetDir.setPath(QString("%1/%2").arg(targetDir.absolutePath(), QFileInfo(rootDir.relativeFilePath(sourceFile.canonicalFilePath())).path()));
	}
	
	//Make sure output directory does exist
	if(!targetDir.exists())
	{
		targetDir.mkpath(".");
		if(!targetDir.exists())
		{
			handleMessage(QString("%1\n%2").arg(tr("The target output directory doesn't exist and could NOT be created:"), QDir::toNativeSeparators(targetDir.absolutePath())));
			return 0;
		}
	}
	
	//Make sure that the output dir is writable
	QFile writeTest(QString("%1/.%2").arg(targetDir.canonicalPath(), lamexp_rand_str()));
	if(!writeTest.open(QIODevice::ReadWrite))
	{
		handleMessage(QString("%1\n%2").arg(tr("The target output directory is NOT writable:"), QDir::toNativeSeparators(targetDir.absolutePath())));
		return 0;
	}
	else
	{
		writeTest.close();
		writeTest.remove();
	}

	//Apply rename pattern
	QString fileName = m_renamePattern;
	fileName.replace("<BaseName>", STRDEF(baseName, tr("Unknown File Name")), Qt::CaseInsensitive);
	fileName.replace("<TrackNo>", QString().sprintf("%02d", m_audioFile.filePosition()), Qt::CaseInsensitive);
	fileName.replace("<Title>", STRDEF(m_audioFile.fileName(), tr("Unknown Title")) , Qt::CaseInsensitive);
	fileName.replace("<Artist>", STRDEF(m_audioFile.fileArtist(), tr("Unknown Artist")), Qt::CaseInsensitive);
	fileName.replace("<Album>", STRDEF(m_audioFile.fileAlbum(), tr("Unknown Album")), Qt::CaseInsensitive);
	fileName.replace("<Year>", QString().sprintf("%04d", m_audioFile.fileYear()), Qt::CaseInsensitive);
	fileName.replace("<Comment>", STRDEF(m_audioFile.fileComment(), tr("Unknown Comment")), Qt::CaseInsensitive);
	fileName = lamexp_clean_filename(fileName).simplified();

	//Generate full output path
	outFileName = QString("%1/%2.%3").arg(targetDir.canonicalPath(), fileName, m_encoder->extension());

	//Skip file, if target file exists (optional!)
	if(m_overwriteSkipExistingFile && QFileInfo(outFileName).exists())
	{
		handleMessage(QString("%1\n%2\n").arg(tr("Target output file already exists, going to skip this file:"), QDir::toNativeSeparators(outFileName)));
		handleMessage(tr("If you don't want existing files to be skipped, please change the overwrite mode!"));
		return -1;
	}

	//Delete file, if target file exists (optional!)
	if(m_overwriteReplacesExisting && QFileInfo(outFileName).exists())
	{
		handleMessage(QString("%1\n%2\n").arg(tr("Target output file already exists, going to delete existing file:"), QDir::toNativeSeparators(outFileName)));
		bool bOkay = false;
		for(int i = 0; i < 16; i++)
		{
			bOkay = QFile::remove(outFileName);
			if(bOkay) break;
			QThread::msleep(125);
		}
		if(QFileInfo(outFileName).exists() || (!bOkay))
		{
			handleMessage(QString("%1\n").arg(tr("Failed to delete existing target file, will save to another file name!")));
		}
	}

	int n = 1;

	//Generate final name
	while(QFileInfo(outFileName).exists())
	{
		outFileName = QString("%1/%2 (%3).%4").arg(targetDir.canonicalPath(), fileName, QString::number(++n), m_encoder->extension());
	}

	//Create placeholder
	QFile placeholder(outFileName);
	if(placeholder.open(QIODevice::WriteOnly))
	{
		placeholder.close();
	}

	return 1;
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
	int targetSampleRate = 0;
	int targetBitDepth = 0;
	
	/* Adjust sample rate */
	if(m_encoder->supportedSamplerates() && m_audioFile.formatAudioSamplerate())
	{
		bool applyDownsampling = true;
	
		//Check if downsampling filter is already in the chain
		for(int i = 0; i < m_filters.count(); i++)
		{
			if(dynamic_cast<ResampleFilter*>(m_filters.at(i)))
			{
				qWarning("Encoder requires downsampling, but user has already set resamling filter!");
				handleMessage("WARNING: Encoder may need resampling, but already using resample filter. Encoding *may* fail!\n");
				applyDownsampling = false;
			}
		}
		
		//Now determine the target sample rate, if required
		if(applyDownsampling)
		{
			const unsigned int *supportedRates = m_encoder->supportedSamplerates();
			const unsigned int inputRate = m_audioFile.formatAudioSamplerate();
			unsigned int currentDiff = UINT_MAX, minimumDiff = UINT_MAX, bestRate = UINT_MAX;

			//Find the most suitable supported sampling rate
			for(int i = 0; supportedRates[i]; i++)
			{
				currentDiff = DIFF(inputRate, supportedRates[i]);
				if((currentDiff < minimumDiff) || ((currentDiff == minimumDiff) && (bestRate < supportedRates[i])))
				{
					bestRate = supportedRates[i];
					minimumDiff = currentDiff;
					if(!(minimumDiff > 0)) break;
				}
			}
		
			if(bestRate != inputRate)
			{
				targetSampleRate = (bestRate != UINT_MAX) ? bestRate : supportedRates[0];
			}
		}
	}

	/* Adjust bit depth (word size) */
	if(m_encoder->supportedBitdepths() && m_audioFile.formatAudioBitdepth())
	{
		const unsigned int inputBPS = m_audioFile.formatAudioBitdepth();
		const unsigned int *supportedBPS = m_encoder->supportedBitdepths();

		bool bAdjustBitdepth = true;

		//Is the input bit depth supported exactly? (inclduing IEEE Float)
		for(int i = 0; supportedBPS[i]; i++)
		{
			if(supportedBPS[i] == inputBPS) bAdjustBitdepth = false;
		}
		
		if(bAdjustBitdepth)
		{
			unsigned int currentDiff = UINT_MAX, minimumDiff = UINT_MAX, bestBPS = UINT_MAX;
			const unsigned int originalBPS = (inputBPS == AudioFileModel::BITDEPTH_IEEE_FLOAT32) ? 32 : inputBPS;

			//Find the most suitable supported bit depth
			for(int i = 0; supportedBPS[i]; i++)
			{
				if(supportedBPS[i] == AudioFileModel::BITDEPTH_IEEE_FLOAT32) continue;
				
				currentDiff = DIFF(originalBPS, supportedBPS[i]);
				if((currentDiff < minimumDiff) || ((currentDiff == minimumDiff) && (bestBPS < supportedBPS[i])))
				{
					bestBPS = supportedBPS[i];
					minimumDiff = currentDiff;
					if(!(minimumDiff > 0)) break;
				}
			}

			if(bestBPS != originalBPS)
			{
				targetBitDepth = (bestBPS != UINT_MAX) ? bestBPS : supportedBPS[0];
			}
		}
	}

	/* Insert the filter */
	if(targetSampleRate || targetBitDepth)
	{
		m_filters.append(new ResampleFilter(targetSampleRate, targetBitDepth));
	}
}

void ProcessThread::insertDownmixFilter(void)
{
	bool applyDownmixing = true;
		
	//Check if downmixing filter is already in the chain
	for(int i = 0; i < m_filters.count(); i++)
	{
		if(dynamic_cast<DownmixFilter*>(m_filters.at(i)))
		{
			qWarning("Encoder requires Stereo downmix, but user has already forced downmix!");
			handleMessage("WARNING: Encoder may need downmixning, but already using downmixning filter. Encoding *may* fail!\n");
			applyDownmixing = false;
		}
	}

	//Now add the downmixing filter, if needed
	if(applyDownmixing)
	{
		bool requiresDownmix = true;
		const unsigned int *supportedChannels = m_encoder->supportedChannelCount();
		unsigned int channels = m_audioFile.formatAudioChannels();

		for(int i = 0; supportedChannels[i]; i++)
		{
			if(supportedChannels[i] == channels)
			{
				requiresDownmix = false;
				break;
			}
		}

		if(requiresDownmix)
		{
			m_filters.append(new DownmixFilter());
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

void ProcessThread::setRenamePattern(const QString &pattern)
{
	QString newPattern = pattern.simplified();
	if(!newPattern.isEmpty()) m_renamePattern = newPattern;
}

void ProcessThread::setOverwriteMode(const bool bSkipExistingFile, const bool bReplacesExisting)
{
	if(bSkipExistingFile && bReplacesExisting)
	{
		qWarning("Inconsistent overwrite flags, reverting to default!");
		m_overwriteSkipExistingFile = false;
		m_overwriteReplacesExisting = false;
	}

	m_overwriteSkipExistingFile = bSkipExistingFile;
	m_overwriteReplacesExisting = bReplacesExisting;
}

////////////////////////////////////////////////////////////
// EVENTS
////////////////////////////////////////////////////////////

/*NONE*/