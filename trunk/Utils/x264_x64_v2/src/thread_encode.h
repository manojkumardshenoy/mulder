///////////////////////////////////////////////////////////////////////////////
// Simple x264 Launcher
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

#pragma once

#include "model_status.h"

#include <QThread>
#include <QUuid>
#include <QMutex>
#include <QStringList>
#include <QSemaphore>

class OptionsModel;
class QProcess;
class JobObject;

class EncodeThread : public QThread
{
	Q_OBJECT

public:
	EncodeThread(const QString &sourceFileName, const QString &outputFileName, const OptionsModel *options, const QString &binDir, const QString &vpsDir, const bool &x264_x64, const bool &x264_10bit, const bool &avs2yuv_x64, const bool &skipVersionTest, const int &processPriroity, const bool &abortOnTimeout);
	~EncodeThread(void);

	QUuid getId(void) { return this->m_jobId; };
	const QString &sourceFileName(void) { return this->m_sourceFileName; }
	const QString &outputFileName(void) { return this->m_outputFileName; }
	const OptionsModel *options(void) { return m_options; }
	
	void pauseJob(void)
	{
		m_pause = true;
	}
	void resumeJob(void)
	{
		m_pause = false;
		m_semaphorePaused.release();
	}
	void abortJob(void)
	{
		m_abort = true;
		m_pause = false;
		m_semaphorePaused.release();
	}

protected:
	static QMutex m_mutex_startProcess;
	static const unsigned int m_processTimeoutInterval = 2500;
	static const unsigned int m_processTimeoutMaxCounter = 120;
	static const unsigned int m_processTimeoutWarning = 24;

	//Constants
	const QUuid m_jobId;
	const QString m_sourceFileName;
	const QString m_outputFileName;
	const OptionsModel *m_options;
	const QString m_binDir;
	const QString m_vpsDir;
	const bool m_x264_x64;
	const bool m_x264_10bit;
	const bool m_avs2yuv_x64;
	const bool m_skipVersionTest;
	const int m_processPriority;
	const bool m_abortOnTimeout;

	//Types
	enum inputType_t
	{
		INPUT_NATIVE = 0,
		INPUT_AVISYN = 1,
		INPUT_VAPOUR = 2
	};

	//Flags
	volatile bool m_abort;
	volatile bool m_pause;
	
	//Synchronization
	QSemaphore m_semaphorePaused;

	//Job Object
	JobObject *m_jobObject;

	//Internal status values
	JobStatus m_status;
	unsigned int m_progress;

	//Entry point
	virtual void run(void);
	virtual void checkedRun(void);
	
	//Encode functions
	void encode(void);
	bool runEncodingPass(bool x264_x64, bool x264_10bit, bool avs2yuv_x64, int inputType, unsigned int frames, const QString &indexFile, int pass = 0, const QString &passLogFile = QString());
	QStringList buildCommandLine(bool usePipe, bool use10Bit, unsigned int frames, const QString &indexFile, int pass = 0, const QString &passLogFile = QString());
	unsigned int checkVersionX264(bool use_x64, bool use_10bit, bool &modified);
	unsigned int checkVersionAvs2yuv(bool x64);
	bool checkVersionVapoursynth(void);
	bool checkPropertiesAvisynth(bool x64, unsigned int &frames);
	bool checkPropertiesVapoursynth(unsigned int &frames);

	//Auxiallary Stuff
	void log(const QString &text) { emit messageLogged(m_jobId, text); }
	inline void setStatus(JobStatus newStatus);
	inline void setProgress(unsigned int newProgress);
	inline void setDetails(const QString &text);
	bool startProcess(QProcess &process, const QString &program, const QStringList &args, bool mergeChannels = true);
	QStringList splitParams(const QString &params);
	qint64 estimateSize(int progress);

	//Static functions
	static QString commandline2string(const QString &program, const QStringList &arguments);
	static QString sizeToString(qint64 size);
	static int getInputType(const QString &fileExt);
	static QString stringToHash(const QString &string);

signals:
	void statusChanged(const QUuid &jobId, JobStatus newStatus);
	void progressChanged(const QUuid &jobId, unsigned int newProgress);
	void messageLogged(const QUuid &jobId, const QString &text);
	void detailsChanged(const QUuid &jobId, const QString &details);

public slots:
	void start(Priority priority = InheritPriority);
};

