///////////////////////////////////////////////////////////////////////////////
// Simple x264 Launcher
// Copyright (C) 2004-2012 LoRd_MuldeR <MuldeR2@GMX.de>
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

#include "thread_encode.h"

#include "global.h"
#include "model_options.h"
#include "version.h"

#include <QDate>
#include <QTime>
#include <QDateTime>
#include <QFileInfo>
#include <QDir>
#include <QProcess>
#include <QMutex>
#include <QTextCodec>
#include <QLocale>

/*
 * Static vars
 */
QMutex EncodeThread::m_mutex_startProcess;

/*
 * Macros
 */
#define CHECK_STATUS(ABORT_FLAG, OK_FLAG) \
{ \
	if(ABORT_FLAG) \
	{ \
		log("\nPROCESS ABORTED BY USER !!!"); \
		setStatus(JobStatus_Aborted); \
		if(QFileInfo(indexFile).exists()) QFile::remove(indexFile); \
		if(QFileInfo(m_outputFileName).exists() && (QFileInfo(m_outputFileName).size() == 0)) QFile::remove(m_outputFileName); \
		return; \
	} \
	else if(!(OK_FLAG)) \
	{ \
		setStatus(JobStatus_Failed); \
		if(QFileInfo(indexFile).exists()) QFile::remove(indexFile); \
		if(QFileInfo(m_outputFileName).exists() && (QFileInfo(m_outputFileName).size() == 0)) QFile::remove(m_outputFileName); \
		return; \
	} \
}

#define APPEND_AND_CLEAR(LIST, STR) \
{ \
	if(!((STR).isEmpty())) \
	{ \
		(LIST) << (STR); \
		(STR).clear(); \
	} \
}

/*
 * Static vars
 */
static const unsigned int REV_MULT = 10000;

///////////////////////////////////////////////////////////////////////////////
// Constructor & Destructor
///////////////////////////////////////////////////////////////////////////////

EncodeThread::EncodeThread(const QString &sourceFileName, const QString &outputFileName, const OptionsModel *options, const QString &binDir, bool x264_x64, bool avs2yuv_x64)
:
	m_jobId(QUuid::createUuid()),
	m_sourceFileName(sourceFileName),
	m_outputFileName(outputFileName),
	m_options(new OptionsModel(*options)),
	m_binDir(binDir),
	m_x264_x64(x264_x64),
	m_avs2yuv_x64(avs2yuv_x64),
	m_handle_jobObject(NULL),
	m_semaphorePaused(0)
{
	m_abort = false;
	m_pause = false;
}

EncodeThread::~EncodeThread(void)
{
	X264_DELETE(m_options);
	
	if(m_handle_jobObject)
	{
		CloseHandle(m_handle_jobObject);
		m_handle_jobObject = NULL;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Thread entry point
///////////////////////////////////////////////////////////////////////////////

void EncodeThread::run(void)
{
	__try
	{
		checkedRun();
	}
	__except(1)
	{
		qWarning("STRUCTURED EXCEPTION ERROR IN ENCODE THREAD !!!");
	}

	if(m_handle_jobObject)
	{
		TerminateJobObject(m_handle_jobObject, 42);
		m_handle_jobObject = NULL;
	}
}

void EncodeThread::checkedRun(void)
{
	m_progress = 0;
	m_status = JobStatus_Starting;

	try
	{
		try
		{
			encode();
		}
		catch(char *msg)
		{
			log(tr("EXCEPTION ERROR IN THREAD: ").append(QString::fromLatin1(msg)));
			setStatus(JobStatus_Failed);
		}
		catch(...)
		{
			log(tr("UNHANDLED EXCEPTION ERROR IN THREAD !!!"));
			setStatus(JobStatus_Failed);
		}
	}
	catch(...)
	{
		RaiseException(EXCEPTION_ACCESS_VIOLATION, 0, 0, NULL);
	}
}

void EncodeThread::start(Priority priority)
{
	qDebug("Thread starting...");

	m_abort = false;
	m_pause = false;

	while(m_semaphorePaused.tryAcquire(1, 0));
	QThread::start(priority);
}

///////////////////////////////////////////////////////////////////////////////
// Encode functions
///////////////////////////////////////////////////////////////////////////////

void EncodeThread::encode(void)
{
	QDateTime startTime = QDateTime::currentDateTime();

	//Print some basic info
	log(tr("Job started at %1, %2.\n").arg(QDate::currentDate().toString(Qt::ISODate), QTime::currentTime().toString( Qt::ISODate)));
	log(tr("Source file: %1").arg(m_sourceFileName));
	log(tr("Output file: %1").arg(m_outputFileName));
	
	//Print encoder settings
	log(tr("\n--- SETTINGS ---\n"));
	log(tr("RC Mode: %1").arg(OptionsModel::rcMode2String(m_options->rcMode())));
	log(tr("Preset:  %1").arg(m_options->preset()));
	log(tr("Tuning:  %1").arg(m_options->tune()));
	log(tr("Profile: %1").arg(m_options->profile()));
	log(tr("Custom:  %1").arg(m_options->customX264().isEmpty() ? tr("(None)") : m_options->customX264()));
	
	bool ok = false;
	unsigned int frames = 0;

	//Use Avisynth?
	const bool usePipe = (QFileInfo(m_sourceFileName).suffix().compare("avs", Qt::CaseInsensitive) == 0);
	const QString indexFile = QString("%1/%2.ffindex").arg(QDir::tempPath(), m_jobId.toString());

	//Checking x264 version
	log(tr("\n--- CHECK VERSION ---\n"));
	unsigned int revision_x264 = UINT_MAX;
	bool x264_modified = false;
	ok = ((revision_x264 = checkVersionX264(m_x264_x64, x264_modified)) != UINT_MAX);
	CHECK_STATUS(m_abort, ok);
	
	//Checking avs2yuv version
	unsigned int revision_avs2yuv = UINT_MAX;
	if(usePipe)
	{
		ok = ((revision_avs2yuv = checkVersionAvs2yuv(m_avs2yuv_x64)) != UINT_MAX);
		CHECK_STATUS(m_abort, ok);
	}

	//Print versions
	log(tr("\nx264 revision: %1 (core #%2)").arg(QString::number(revision_x264 % REV_MULT), QString::number(revision_x264 / REV_MULT)).append(x264_modified ? tr(" - with custom patches!") : QString()));
	if(revision_avs2yuv != UINT_MAX) log(tr("Avs2YUV version: %1.%2.%3").arg(QString::number(revision_avs2yuv / REV_MULT), QString::number((revision_avs2yuv % REV_MULT) / 10),QString::number((revision_avs2yuv % REV_MULT) % 10)));

	//Is x264 revision supported?
	if((revision_x264 % REV_MULT) < (VER_X264_MINIMUM_REV))
	{
		log(tr("\nERROR: Your revision of x264 is too old! (Minimum required revision is %2)").arg(QString::number(VER_X264_MINIMUM_REV)));
		setStatus(JobStatus_Failed);
		return;
	}
	if((revision_x264 / REV_MULT) != (VER_X264_CURRENT_API))
	{
		log(tr("\nWARNING: Your revision of x264 uses an unsupported core (API) version, take care!"));
		log(tr("This application works best with x264 core (API) version %2.").arg(QString::number(VER_X264_CURRENT_API)));
	}
	if((revision_avs2yuv != UINT_MAX) && ((revision_avs2yuv % REV_MULT) != (VER_X264_AVS2YUV_VER)))
	{
		log(tr("\nERROR: Your version of avs2yuv is unsupported (Required version: v0.24 BugMaster's mod 2)"));
		log(tr("You can find the required version at: http://komisar.gin.by/tools/avs2yuv/"));
		setStatus(JobStatus_Failed);
		return;
	}

	//Detect source info
	if(usePipe)
	{
		log(tr("\n--- AVS INFO ---\n"));
		ok = checkProperties(m_avs2yuv_x64, frames);
		CHECK_STATUS(m_abort, ok);
	}

	//Run encoding passes
	if(m_options->rcMode() == OptionsModel::RCMode_2Pass)
	{
		QFileInfo info(m_outputFileName);
		QString passLogFile = QString("%1/%2.stats").arg(info.path(), info.completeBaseName());

		if(QFileInfo(passLogFile).exists())
		{
			int n = 2;
			while(QFileInfo(passLogFile).exists())
			{
				passLogFile = QString("%1/%2.%3.stats").arg(info.path(), info.completeBaseName(), QString::number(n++));
			}
		}
		
		log(tr("\n--- PASS 1 ---\n"));
		ok = runEncodingPass(m_x264_x64, m_avs2yuv_x64, usePipe, frames, indexFile, 1, passLogFile);
		CHECK_STATUS(m_abort, ok);

		log(tr("\n--- PASS 2 ---\n"));
		ok = runEncodingPass(m_x264_x64, m_avs2yuv_x64, usePipe, frames, indexFile, 2, passLogFile);
		CHECK_STATUS(m_abort, ok);
	}
	else
	{
		log(tr("\n--- ENCODING ---\n"));
		ok = runEncodingPass(m_x264_x64, m_avs2yuv_x64, usePipe, frames, indexFile);
		CHECK_STATUS(m_abort, ok);
	}

	log(tr("\n--- DONE ---\n"));
	if(QFileInfo(indexFile).exists()) QFile::remove(indexFile);
	int timePassed = startTime.secsTo(QDateTime::currentDateTime());
	log(tr("Job finished at %1, %2. Process took %3 minutes, %4 seconds.").arg(QDate::currentDate().toString(Qt::ISODate), QTime::currentTime().toString( Qt::ISODate), QString::number(timePassed / 60), QString::number(timePassed % 60)));
	setStatus(JobStatus_Completed);
}

bool EncodeThread::runEncodingPass(bool x264_x64, bool avs2yuv_x64, bool usePipe, unsigned int frames, const QString &indexFile, int pass, const QString &passLogFile)
{
	QProcess processEncode, processAvisynth;
	
	if(usePipe)
	{
		QStringList cmdLine_Avisynth;
		if(!m_options->customAvs2YUV().isEmpty())
		{
			cmdLine_Avisynth.append(splitParams(m_options->customAvs2YUV()));
		}
		cmdLine_Avisynth << pathToLocal(QDir::toNativeSeparators(m_sourceFileName));
		cmdLine_Avisynth << "-";
		processAvisynth.setStandardOutputProcess(&processEncode);

		log("Creating Avisynth process:");
		if(!startProcess(processAvisynth, QString("%1/%2.exe").arg(m_binDir, avs2yuv_x64 ? "avs2yuv_x64" : "avs2yuv"), cmdLine_Avisynth, false))
		{
			return false;
		}
	}

	QStringList cmdLine_Encode = buildCommandLine(usePipe, frames, indexFile, pass, passLogFile);

	log("Creating x264 process:");
	if(!startProcess(processEncode, QString("%1/%2.exe").arg(m_binDir, x264_x64 ? "x264_x64" : "x264"), cmdLine_Encode))
	{
		return false;
	}

	QRegExp regExpIndexing("indexing.+\\[(\\d+)\\.(\\d+)%\\]");
	QRegExp regExpProgress("\\[(\\d+)\\.(\\d+)%\\].+frames");
	QRegExp regExpFrameCnt("^(\\d+) frames:");
	
	QTextCodec *localCodec = QTextCodec::codecForName("System");

	bool bTimeout = false;
	bool bAborted = false;

	unsigned int last_progress = UINT_MAX;
	unsigned int last_indexing = UINT_MAX;
	qint64 size_estimate = 0I64;

	//Main processing loop
	while(processEncode.state() != QProcess::NotRunning)
	{
		unsigned int waitCounter = 0;

		//Wait until new output is available
		forever
		{
			if(m_abort)
			{
				processEncode.kill();
				processAvisynth.kill();
				bAborted = true;
				break;
			}
			if(m_pause && (processEncode.state() == QProcess::Running))
			{
				JobStatus previousStatus = m_status;
				setStatus(JobStatus_Paused);
				log(tr("Job paused by user at %1, %2.").arg(QDate::currentDate().toString(Qt::ISODate), QTime::currentTime().toString( Qt::ISODate)));
				bool ok[2] = {false, false};
				Q_PID pid[2] = {processEncode.pid(), processAvisynth.pid()};
				if(pid[0]) { ok[0] = (SuspendThread(pid[0]->hThread) != (DWORD)(-1)); }
				if(pid[1]) { ok[1] = (SuspendThread(pid[1]->hThread) != (DWORD)(-1)); }
				while(m_pause) m_semaphorePaused.acquire();
				while(m_semaphorePaused.tryAcquire(1, 0));
				if(pid[0]) { if(ok[0]) ResumeThread(pid[0]->hThread); }
				if(pid[1]) { if(ok[1]) ResumeThread(pid[1]->hThread); }
				if(!m_abort) setStatus(previousStatus);
				log(tr("Job resumed by user at %1, %2.").arg(QDate::currentDate().toString(Qt::ISODate), QTime::currentTime().toString( Qt::ISODate)));
				waitCounter = 0;
				continue;
			}
			if(!processEncode.waitForReadyRead(m_processTimeoutInterval))
			{
				if(processEncode.state() == QProcess::Running)
				{
					if(waitCounter++ > m_processTimeoutMaxCounter)
					{
						processEncode.kill();
						qWarning("x264 process timed out <-- killing!");
						log("\nPROCESS TIMEOUT !!!");
						bTimeout = true;
						break;
					}
					else if(waitCounter == m_processTimeoutWarning)
					{
						unsigned int timeOut = (waitCounter * m_processTimeoutInterval) / 1000U;
						log(tr("Warning: x264 did not respond for %1 seconds, potential deadlock...").arg(QString::number(timeOut)));
					}
					continue;
				}
			}
			if(m_abort || (m_pause && (processEncode.state() == QProcess::Running)))
			{
				continue;
			}
			break;
		}
		
		//Exit main processing loop now?
		if(bAborted || bTimeout)
		{
			break;
		}

		//Process all output
		while(processEncode.bytesAvailable() > 0)
		{
			QList<QByteArray> lines = processEncode.readLine().split('\r');
			while(!lines.isEmpty())
			{
				QString text = localCodec->toUnicode(lines.takeFirst().constData()).simplified();
				int offset = -1;
				if((offset = regExpProgress.lastIndexIn(text)) >= 0)
				{
					bool ok = false;
					unsigned int progress = regExpProgress.cap(1).toUInt(&ok);
					setStatus((pass == 2) ? JobStatus_Running_Pass2 : ((pass == 1) ? JobStatus_Running_Pass1 : JobStatus_Running));
					if(ok && ((progress > last_progress) || (last_progress == UINT_MAX)))
					{
						setProgress(progress);
						size_estimate = estimateSize(progress);
						last_progress = progress;
					}
					setDetails(tr("%1, est. file size %2").arg(text.mid(offset).trimmed(), sizeToString(size_estimate)));
					last_indexing = UINT_MAX;
				}
				else if((offset = regExpIndexing.lastIndexIn(text)) >= 0)
				{
					bool ok = false;
					unsigned int progress = regExpIndexing.cap(1).toUInt(&ok);
					setStatus(JobStatus_Indexing);
					if(ok && ((progress > last_indexing) || (last_indexing == UINT_MAX)))
					{
						setProgress(progress);
						last_indexing = progress;
					}
					setDetails(text.mid(offset).trimmed());
					last_progress = UINT_MAX;
				}
				else if((offset = regExpFrameCnt.lastIndexIn(text)) >= 0)
				{
					last_progress = last_indexing = UINT_MAX;
					setStatus((pass == 2) ? JobStatus_Running_Pass2 : ((pass == 1) ? JobStatus_Running_Pass1 : JobStatus_Running));
					setDetails(text.mid(offset).trimmed());
				}
				else if(!text.isEmpty())
				{
					last_progress = last_indexing = UINT_MAX;
					log(text);
				}
			}
		}
	}

	processEncode.waitForFinished(5000);
	if(processEncode.state() != QProcess::NotRunning)
	{
		qWarning("x264 process still running, going to kill it!");
		processEncode.kill();
		processEncode.waitForFinished(-1);
	}
	
	processAvisynth.waitForFinished(5000);
	if(processAvisynth.state() != QProcess::NotRunning)
	{
		qWarning("Avisynth process still running, going to kill it!");
		processAvisynth.kill();
		processAvisynth.waitForFinished(-1);
	}

	if(!(bTimeout || bAborted))
	{
		while(processAvisynth.bytesAvailable() > 0)
		{
			log(tr("av2y [info]: %1").arg(QString::fromUtf8(processAvisynth.readLine()).simplified()));
		}
	}

	if(usePipe && (processAvisynth.exitCode() != EXIT_SUCCESS))
	{
		if(!(bTimeout || bAborted))
		{
			log(tr("\nWARNING: Avisynth process exited with error code: %1").arg(QString::number(processAvisynth.exitCode())));
		}
	}

	if(bTimeout || bAborted || processEncode.exitCode() != EXIT_SUCCESS)
	{
		if(!(bTimeout || bAborted))
		{
			log(tr("\nPROCESS EXITED WITH ERROR CODE: %1").arg(QString::number(processEncode.exitCode())));
		}
		processEncode.close();
		processAvisynth.close();
		return false;
	}

	QThread::yieldCurrentThread();

	const qint64 finalSize = QFileInfo(m_outputFileName).size();
	QLocale locale(QLocale::English);
	log(tr("Final file size is %1 bytes.").arg(locale.toString(finalSize)));

	switch(pass)
	{
	case 1:
		setStatus(JobStatus_Running_Pass1);
		setDetails(tr("First pass completed. Preparing for second pass..."));
		break;
	case 2:
		setStatus(JobStatus_Running_Pass2);
		setDetails(tr("Second pass completed successfully. Final size is %1.").arg(sizeToString(finalSize)));
		break;
	default:
		setStatus(JobStatus_Running);
		setDetails(tr("Encode completed successfully. Final size is %1.").arg(sizeToString(finalSize)));
		break;
	}

	setProgress(100);
	processEncode.close();
	processAvisynth.close();
	return true;
}

QStringList EncodeThread::buildCommandLine(bool usePipe, unsigned int frames, const QString &indexFile, int pass, const QString &passLogFile)
{
	QStringList cmdLine;
	double crf_int = 0.0, crf_frc = 0.0;

	switch(m_options->rcMode())
	{
	case OptionsModel::RCMode_CQ:
		cmdLine << "--qp" << QString::number(qRound(m_options->quantizer()));
		break;
	case OptionsModel::RCMode_CRF:
		crf_frc = modf(m_options->quantizer(), &crf_int);
		cmdLine << "--crf" << QString("%1.%2").arg(QString::number(qRound(crf_int)), QString::number(qRound(crf_frc * 10.0)));
		break;
	case OptionsModel::RCMode_2Pass:
	case OptionsModel::RCMode_ABR:
		cmdLine << "--bitrate" << QString::number(m_options->bitrate());
		break;
	default:
		throw "Bad rate-control mode !!!";
		break;
	}
	
	if((pass == 1) || (pass == 2))
	{
		cmdLine << "--pass" << QString::number(pass);
		cmdLine << "--stats" << pathToLocal(QDir::toNativeSeparators(passLogFile), true);
	}

	cmdLine << "--preset" << m_options->preset().toLower();

	if(m_options->tune().compare("none", Qt::CaseInsensitive))
	{
		cmdLine << "--tune" << m_options->tune().toLower();
	}

	if(m_options->profile().compare("auto", Qt::CaseInsensitive))
	{
		cmdLine << "--profile" << m_options->profile().toLower();
	}

	if(!m_options->customX264().isEmpty())
	{
		cmdLine.append(splitParams(m_options->customX264()));
	}

	cmdLine << "--output" << pathToLocal(QDir::toNativeSeparators(m_outputFileName), true);
	
	if(usePipe)
	{
		if(frames < 1) throw "Frames not set!";
		cmdLine << "--frames" << QString::number(frames);
		cmdLine << "--demuxer" << "y4m";
		cmdLine << "--stdin" << "y4m" << "-";
	}
	else
	{
		cmdLine << "--index" << pathToLocal(QDir::toNativeSeparators(indexFile), true, false);
		cmdLine << pathToLocal(QDir::toNativeSeparators(m_sourceFileName));
	}

	return cmdLine;
}

unsigned int EncodeThread::checkVersionX264(bool x64, bool &modified)
{
	QProcess process;
	QStringList cmdLine = QStringList() << "--version";

	log("Creating process:");
	if(!startProcess(process, QString("%1/%2.exe").arg(m_binDir, x64 ? "x264_x64" : "x264"), cmdLine))
	{
		return false;;
	}

	QRegExp regExpVersion("\\bx264\\s(\\d)\\.(\\d+)\\.(\\d+)\\s([a-f0-9]{7})", Qt::CaseInsensitive);
	QRegExp regExpVersionMod("\\bx264 (\\d)\\.(\\d+)\\.(\\d+)", Qt::CaseInsensitive);
	
	bool bTimeout = false;
	bool bAborted = false;

	unsigned int revision = UINT_MAX;
	unsigned int coreVers = UINT_MAX;
	modified = false;

	while(process.state() != QProcess::NotRunning)
	{
		if(m_abort)
		{
			process.kill();
			bAborted = true;
			break;
		}
		if(!process.waitForReadyRead())
		{
			if(process.state() == QProcess::Running)
			{
				process.kill();
				qWarning("x264 process timed out <-- killing!");
				log("\nPROCESS TIMEOUT !!!");
				bTimeout = true;
				break;
			}
		}
		while(process.bytesAvailable() > 0)
		{
			QList<QByteArray> lines = process.readLine().split('\r');
			while(!lines.isEmpty())
			{
				QString text = QString::fromUtf8(lines.takeFirst().constData()).simplified();
				int offset = -1;
				if((offset = regExpVersion.lastIndexIn(text)) >= 0)
				{
					bool ok1 = false, ok2 = false;
					unsigned int temp1 = regExpVersion.cap(2).toUInt(&ok1);
					unsigned int temp2 = regExpVersion.cap(3).toUInt(&ok2);
					if(ok1) coreVers = temp1;
					if(ok2) revision = temp2;
				}
				else if((offset = regExpVersionMod.lastIndexIn(text)) >= 0)
				{
					bool ok1 = false, ok2 = false;
					unsigned int temp1 = regExpVersionMod.cap(2).toUInt(&ok1);
					unsigned int temp2 = regExpVersionMod.cap(3).toUInt(&ok2);
					if(ok1) coreVers = temp1;
					if(ok2) revision = temp2;
					modified = true;
				}
				if(!text.isEmpty())
				{
					log(text);
				}
			}
		}
	}

	process.waitForFinished();
	if(process.state() != QProcess::NotRunning)
	{
		process.kill();
		process.waitForFinished(-1);
	}

	if(bTimeout || bAborted || process.exitCode() != EXIT_SUCCESS)
	{
		if(!(bTimeout || bAborted))
		{
			log(tr("\nPROCESS EXITED WITH ERROR CODE: %1").arg(QString::number(process.exitCode())));
		}
		return UINT_MAX;
	}

	if((revision == UINT_MAX) || (coreVers == UINT_MAX))
	{
		log(tr("\nFAILED TO DETERMINE X264 VERSION !!!"));
		return UINT_MAX;
	}
	
	return (coreVers * REV_MULT) + (revision % REV_MULT);
}

unsigned int EncodeThread::checkVersionAvs2yuv(bool x64)
{
	QProcess process;

	log("\nCreating process:");
	if(!startProcess(process, QString("%1/%2.exe").arg(m_binDir, x64 ? "avs2yuv_x64" : "avs2yuv"), QStringList()))
	{
		return false;;
	}

	QRegExp regExpVersionMod("\\bAvs2YUV (\\d+).(\\d+)bm(\\d)\\b", Qt::CaseInsensitive);
	QRegExp regExpVersionOld("\\bAvs2YUV (\\d+).(\\d+)\\b", Qt::CaseInsensitive);
	
	bool bTimeout = false;
	bool bAborted = false;

	unsigned int ver_maj = UINT_MAX;
	unsigned int ver_min = UINT_MAX;
	unsigned int ver_mod = 0;

	while(process.state() != QProcess::NotRunning)
	{
		if(m_abort)
		{
			process.kill();
			bAborted = true;
			break;
		}
		if(!process.waitForReadyRead())
		{
			if(process.state() == QProcess::Running)
			{
				process.kill();
				qWarning("Avs2YUV process timed out <-- killing!");
				log("\nPROCESS TIMEOUT !!!");
				bTimeout = true;
				break;
			}
		}
		while(process.bytesAvailable() > 0)
		{
			QList<QByteArray> lines = process.readLine().split('\r');
			while(!lines.isEmpty())
			{
				QString text = QString::fromUtf8(lines.takeFirst().constData()).simplified();
				int offset = -1;
				if((ver_maj == UINT_MAX) || (ver_min == UINT_MAX) || (ver_mod == UINT_MAX))
				{
					if(!text.isEmpty())
					{
						log(text);
					}
				}
				if((offset = regExpVersionMod.lastIndexIn(text)) >= 0)
				{
					bool ok1 = false, ok2 = false, ok3 = false;
					unsigned int temp1 = regExpVersionMod.cap(1).toUInt(&ok1);
					unsigned int temp2 = regExpVersionMod.cap(2).toUInt(&ok2);
					unsigned int temp3 = regExpVersionMod.cap(3).toUInt(&ok3);
					if(ok1) ver_maj = temp1;
					if(ok2) ver_min = temp2;
					if(ok3) ver_mod = temp3;
				}
				else if((offset = regExpVersionOld.lastIndexIn(text)) >= 0)
				{
					bool ok1 = false, ok2 = false;
					unsigned int temp1 = regExpVersionOld.cap(1).toUInt(&ok1);
					unsigned int temp2 = regExpVersionOld.cap(2).toUInt(&ok2);
					if(ok1) ver_maj = temp1;
					if(ok2) ver_min = temp2;
				}
			}
		}
	}

	process.waitForFinished();
	if(process.state() != QProcess::NotRunning)
	{
		process.kill();
		process.waitForFinished(-1);
	}

	if(bTimeout || bAborted || ((process.exitCode() != EXIT_SUCCESS) && (process.exitCode() != 2)))
	{
		if(!(bTimeout || bAborted))
		{
			log(tr("\nPROCESS EXITED WITH ERROR CODE: %1").arg(QString::number(process.exitCode())));
		}
		return UINT_MAX;
	}

	if((ver_maj == UINT_MAX) || (ver_min == UINT_MAX))
	{
		log(tr("\nFAILED TO DETERMINE AVS2YUV VERSION !!!"));
		return UINT_MAX;
	}
	
	return (ver_maj * REV_MULT) + ((ver_min % REV_MULT) * 10) + (ver_mod % 10);
}

bool EncodeThread::checkProperties(bool x64, unsigned int &frames)
{
	QProcess process;
	QStringList cmdLine;

	if(!m_options->customAvs2YUV().isEmpty())
	{
		cmdLine.append(splitParams(m_options->customAvs2YUV()));
	}

	cmdLine << "-frames" << "1";
	cmdLine << pathToLocal(QDir::toNativeSeparators(m_sourceFileName)) << "NUL";

	log("Creating process:");
	if(!startProcess(process, QString("%1/%2.exe").arg(m_binDir, x64 ? "avs2yuv_x64" : "avs2yuv"), cmdLine))
	{
		return false;;
	}

	QRegExp regExpInt(": (\\d+)x(\\d+), (\\d+) fps, (\\d+) frames");
	QRegExp regExpFrc(": (\\d+)x(\\d+), (\\d+)/(\\d+) fps, (\\d+) frames");
	
	QTextCodec *localCodec = QTextCodec::codecForName("System");

	bool bTimeout = false;
	bool bAborted = false;

	frames = 0;
	
	unsigned int fpsNom = 0;
	unsigned int fpsDen = 0;
	unsigned int fSizeW = 0;
	unsigned int fSizeH = 0;
	
	unsigned int waitCounter = 0;

	while(process.state() != QProcess::NotRunning)
	{
		if(m_abort)
		{
			process.kill();
			bAborted = true;
			break;
		}
		if(!process.waitForReadyRead(m_processTimeoutInterval))
		{
			if(process.state() == QProcess::Running)
			{
				if(waitCounter++ > m_processTimeoutMaxCounter)
				{
					process.kill();
					qWarning("Avs2YUV process timed out <-- killing!");
					log("\nPROCESS TIMEOUT !!!");
					log("\nAvisynth has encountered a deadlock or your script takes EXTREMELY long to initialize!");
					bTimeout = true;
					break;
				}
				else if(waitCounter == m_processTimeoutWarning)
				{
					unsigned int timeOut = (waitCounter * m_processTimeoutInterval) / 1000U;
					log(tr("Warning: Avisynth did not respond for %1 seconds, potential deadlock...").arg(QString::number(timeOut)));
				}
			}
			continue;
		}
		
		waitCounter = 0;
		
		while(process.bytesAvailable() > 0)
		{
			QList<QByteArray> lines = process.readLine().split('\r');
			while(!lines.isEmpty())
			{
				QString text = localCodec->toUnicode(lines.takeFirst().constData()).simplified();
				int offset = -1;
				if((offset = regExpInt.lastIndexIn(text)) >= 0)
				{
					bool ok1 = false, ok2 = false;
					bool ok3 = false, ok4 = false;
					unsigned int temp1 = regExpInt.cap(1).toUInt(&ok1);
					unsigned int temp2 = regExpInt.cap(2).toUInt(&ok2);
					unsigned int temp3 = regExpInt.cap(3).toUInt(&ok3);
					unsigned int temp4 = regExpInt.cap(4).toUInt(&ok4);
					if(ok1) fSizeW = temp1;
					if(ok2) fSizeH = temp2;
					if(ok3) fpsNom = temp3;
					if(ok4) frames = temp4;
				}
				else if((offset = regExpFrc.lastIndexIn(text)) >= 0)
				{
					bool ok1 = false, ok2 = false;
					bool ok3 = false, ok4 = false, ok5 = false;
					unsigned int temp1 = regExpFrc.cap(1).toUInt(&ok1);
					unsigned int temp2 = regExpFrc.cap(2).toUInt(&ok2);
					unsigned int temp3 = regExpFrc.cap(3).toUInt(&ok3);
					unsigned int temp4 = regExpFrc.cap(4).toUInt(&ok4);
					unsigned int temp5 = regExpFrc.cap(5).toUInt(&ok5);
					if(ok1) fSizeW = temp1;
					if(ok2) fSizeH = temp2;
					if(ok3) fpsNom = temp3;
					if(ok4) fpsDen = temp4;
					if(ok5) frames = temp5;
				}
				if(!text.isEmpty())
				{
					log(text);
				}
				if(text.contains("failed to load avisynth.dll", Qt::CaseInsensitive))
				{
					log(tr("\nWarning: It seems that %1-Bit Avisynth is not currently installed !!!").arg(x64 ? "64" : "32"));
				}
				if(text.contains(QRegExp("couldn't convert input clip to (YV16|YV24)", Qt::CaseInsensitive)))
				{
					log(tr("\nWarning: YV16 (4:2:2) and YV24 (4:4:4) color-spaces only supported in Avisynth 2.6 !!!"));
				}
			}
		}
	}

	process.waitForFinished();
	if(process.state() != QProcess::NotRunning)
	{
		process.kill();
		process.waitForFinished(-1);
	}

	if(bTimeout || bAborted || process.exitCode() != EXIT_SUCCESS)
	{
		if(!(bTimeout || bAborted))
		{
			log(tr("\nPROCESS EXITED WITH ERROR CODE: %1").arg(QString::number(process.exitCode())));
		}
		return false;
	}

	if(frames == 0)
	{
		log(tr("\nFAILED TO DETERMINE AVS PROPERTIES !!!"));
		return false;
	}
	
	log("");

	if((fSizeW > 0) && (fSizeH > 0))
	{
		log(tr("Resolution: %1x%2").arg(QString::number(fSizeW), QString::number(fSizeH)));
	}
	if((fpsNom > 0) && (fpsDen > 0))
	{
		log(tr("Frame Rate: %1/%2").arg(QString::number(fpsNom), QString::number(fpsDen)));
	}
	if((fpsNom > 0) && (fpsDen == 0))
	{
		log(tr("Frame Rate: %1").arg(QString::number(fpsNom)));
	}
	if(frames > 0)
	{
		log(tr("No. Frames: %1").arg(QString::number(frames)));
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Misc functions
///////////////////////////////////////////////////////////////////////////////

void EncodeThread::setStatus(JobStatus newStatus)
{
	if(m_status != newStatus)
	{
		if((newStatus != JobStatus_Completed) && (newStatus != JobStatus_Failed) && (newStatus != JobStatus_Aborted) && (newStatus != JobStatus_Paused))
		{
			if(m_status != JobStatus_Paused) setProgress(0);
		}
		if(newStatus == JobStatus_Failed)
		{
			setDetails("The job has failed. See log for details!");
		}
		if(newStatus == JobStatus_Aborted)
		{
			setDetails("The job was aborted by the user!");
		}
		m_status = newStatus;
		emit statusChanged(m_jobId, newStatus);
	}
}

void EncodeThread::setProgress(unsigned int newProgress)
{
	if(m_progress != newProgress)
	{
		m_progress = newProgress;
		emit progressChanged(m_jobId, m_progress);
	}
}

void EncodeThread::setDetails(const QString &text)
{
	emit detailsChanged(m_jobId, text);
}

QString EncodeThread::pathToLocal(const QString &longPath, bool create, bool keep)
{
	QTextCodec *localCodec = QTextCodec::codecForName("System");
	
	//Do NOT convert to short, if path can be represented in local Codepage
	if(localCodec->toUnicode(localCodec->fromUnicode(longPath)).compare(longPath, Qt::CaseInsensitive) == 0)
	{
		return longPath;
	}
	
	//Create dummy file, if required (only existing files can have a short path!)
	QFile tempFile;
	if((!QFileInfo(longPath).exists()) && create)
	{
		tempFile.setFileName(longPath);
		tempFile.open(QIODevice::WriteOnly);
	}
	
	QString shortPath;
	DWORD buffSize = GetShortPathNameW(reinterpret_cast<const wchar_t*>(longPath.utf16()), NULL, NULL);
	
	if(buffSize > 0)
	{
		wchar_t *buffer = new wchar_t[buffSize];
		DWORD result = GetShortPathNameW(reinterpret_cast<const wchar_t*>(longPath.utf16()), buffer, buffSize);

		if(result > 0 && result < buffSize)
		{
			shortPath = QString::fromUtf16(reinterpret_cast<const unsigned short*>(buffer));
		}

		delete[] buffer;
		buffer = NULL;
	}

	//Remove the dummy file now (FFMS2 fails, if index file does exist but is empty!)
	if(tempFile.isOpen())
	{
		if(!keep) tempFile.remove();
		tempFile.close();
	}

	if(shortPath.isEmpty())
	{
		log(tr("Warning: Failed to convert path \"%1\" to short!\n").arg(longPath));
	}

	return (shortPath.isEmpty() ? longPath : shortPath);
}

bool EncodeThread::startProcess(QProcess &process, const QString &program, const QStringList &args, bool mergeChannels)
{
	QMutexLocker lock(&m_mutex_startProcess);
	log(commandline2string(program, args) + "\n");

	//Create a new job object, if not done yet
	if(!m_handle_jobObject)
	{
		m_handle_jobObject = CreateJobObject(NULL, NULL);
		if(m_handle_jobObject == INVALID_HANDLE_VALUE)
		{
			m_handle_jobObject = NULL;
		}
		if(m_handle_jobObject)
		{
			JOBOBJECT_EXTENDED_LIMIT_INFORMATION jobExtendedLimitInfo;
			memset(&jobExtendedLimitInfo, 0, sizeof(JOBOBJECT_EXTENDED_LIMIT_INFORMATION));
			jobExtendedLimitInfo.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE | JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION;
			SetInformationJobObject(m_handle_jobObject, JobObjectExtendedLimitInformation, &jobExtendedLimitInfo, sizeof(JOBOBJECT_EXTENDED_LIMIT_INFORMATION));
		}
	}

	if(mergeChannels)
	{
		process.setProcessChannelMode(QProcess::MergedChannels);
		process.setReadChannel(QProcess::StandardOutput);
	}
	else
	{
		process.setProcessChannelMode(QProcess::SeparateChannels);
		process.setReadChannel(QProcess::StandardError);
	}

	process.start(program, args);
	
	if(process.waitForStarted())
	{
		Q_PID pid = process.pid();
		AssignProcessToJobObject(m_handle_jobObject, process.pid()->hProcess);
		if(pid != NULL)
		{
			if(!SetPriorityClass(process.pid()->hProcess, BELOW_NORMAL_PRIORITY_CLASS))
			{
				SetPriorityClass(process.pid()->hProcess, IDLE_PRIORITY_CLASS);
			}
		}
		
		lock.unlock();
		return true;
	}

	log("Process creation has failed :-(");
	QString errorMsg= process.errorString().trimmed();
	if(!errorMsg.isEmpty()) log(errorMsg);

	process.kill();
	process.waitForFinished(-1);
	return false;
}

QString EncodeThread::commandline2string(const QString &program, const QStringList &arguments)
{
	QString commandline = (program.contains(' ') ? QString("\"%1\"").arg(program) : program);
	
	for(int i = 0; i < arguments.count(); i++)
	{
		commandline += (arguments.at(i).contains(' ') ? QString(" \"%1\"").arg(arguments.at(i)) : QString(" %1").arg(arguments.at(i)));
	}

	return commandline;
}

QStringList EncodeThread::splitParams(const QString &params)
{
	QStringList list; 
	bool ignoreWhitespaces = false;
	QString temp;

	for(int i = 0; i < params.length(); i++)
	{
		const QChar c = params.at(i);

		if(c == QChar::fromLatin1('"'))
		{
			ignoreWhitespaces = (!ignoreWhitespaces);
			continue;
		}
		else if((!ignoreWhitespaces) && (c == QChar::fromLatin1(' ')))
		{
			APPEND_AND_CLEAR(list, temp);
			continue;
		}
		
		temp.append(c);
	}
	
	APPEND_AND_CLEAR(list, temp);

	list.replaceInStrings("$(INPUT)", QDir::toNativeSeparators(m_sourceFileName), Qt::CaseInsensitive);
	list.replaceInStrings("$(OUTPUT)", QDir::toNativeSeparators(m_outputFileName), Qt::CaseInsensitive);

	return list;
}

qint64 EncodeThread::estimateSize(int progress)
{
	if(progress >= 3)
	{
		qint64 currentSize = QFileInfo(m_outputFileName).size();
		qint64 estimatedSize = (currentSize * 100I64) / static_cast<qint64>(progress);
		return estimatedSize;
	}

	return 0I64;
}

QString EncodeThread::sizeToString(qint64 size)
{
	static char *prefix[5] = {"Byte", "KB", "MB", "GB", "TB"};

	if(size > 1024I64)
	{
		qint64 estimatedSize = size;
		qint64 remainderSize = 0I64;

		int prefixIdx = 0;
		while((estimatedSize > 1024I64) && (prefixIdx < 4))
		{
			remainderSize = estimatedSize % 1024I64;
			estimatedSize = estimatedSize / 1024I64;
			prefixIdx++;
		}
			
		double value = static_cast<double>(estimatedSize) + (static_cast<double>(remainderSize) / 1024.0);
		return QString().sprintf((value < 10.0) ? "%.2f %s" : "%.1f %s", value, prefix[prefixIdx]);
	}

	return tr("N/A");
}
