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

#pragma once

#include "thread_encode.h"
#include "model_logFile.h"

#include "QAbstractItemModel"
#include <QUuid>
#include <QList>
#include <QMap>

class JobListModel : public QAbstractItemModel
{
	Q_OBJECT
		
public:
	JobListModel(void);
	~JobListModel(void);

	virtual int columnCount(const QModelIndex &parent) const;
	virtual int rowCount(const QModelIndex &parent) const;
	virtual QVariant headerData(int section, Qt::Orientation orientation, int role) const;
	virtual QModelIndex index(int row, int column, const QModelIndex &parent) const;
	virtual QModelIndex parent (const QModelIndex &index) const;
	virtual QVariant data(const QModelIndex &index, int role) const;

	QModelIndex insertJob(EncodeThread *thread);
	bool startJob(const QModelIndex &index);
	bool pauseJob(const QModelIndex &index);
	bool resumeJob(const QModelIndex &index);
	bool abortJob(const QModelIndex &index);
	bool deleteJob(const QModelIndex &index);
	LogFileModel *getLogFile(const QModelIndex &index);
	const QString &getJobSourceFile(const QModelIndex &index);
	const QString &getJobOutputFile(const QModelIndex &index);
	EncodeThread::JobStatus getJobStatus(const QModelIndex &index);
	unsigned int getJobProgress(const QModelIndex &index);
	const OptionsModel *getJobOptions(const QModelIndex &index);
	QModelIndex getJobIndexById(const QUuid &id);

protected:
	QList<QUuid> m_jobs;
	QMap<QUuid, QString> m_name;
	QMap<QUuid, EncodeThread*> m_threads;
	QMap<QUuid, EncodeThread::JobStatus> m_status;
	QMap<QUuid, unsigned int> m_progress;
	QMap<QUuid, LogFileModel*> m_logFile;
	QMap<QUuid, QString> m_details;

public slots:
	void updateStatus(const QUuid &jobId, EncodeThread::JobStatus newStatus);
	void updateProgress(const QUuid &jobId, unsigned int newProgress);
	void updateDetails(const QUuid &jobId, const QString &details);
};