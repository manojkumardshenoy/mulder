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

#include "model_jobList.h"
#include "global.h"
#include "thread_encode.h"
#include "model_options.h"

#include <QIcon>
#include <QFileInfo>

JobListModel::JobListModel(void)
{
}

JobListModel::~JobListModel(void)
{
	while(!m_jobs.isEmpty())
	{
		QUuid id = m_jobs.takeFirst();
		EncodeThread *thread = m_threads.value(id, NULL);
		LogFileModel *logFile = m_logFile.value(id, NULL);
		X264_DELETE(thread);
		X264_DELETE(logFile);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Model interface
///////////////////////////////////////////////////////////////////////////////

int JobListModel::columnCount(const QModelIndex &parent) const
{
	return 4;
}

int JobListModel::rowCount(const QModelIndex &parent) const
{
	return m_jobs.count();
}

QVariant JobListModel::headerData(int section, Qt::Orientation orientation, int role) const 
{
	if((orientation == Qt::Horizontal) && (role == Qt::DisplayRole))
	{
		switch(section)
		{
		case 0:
			return QVariant::fromValue<QString>(tr("Job"));
			break;
		case 1:
			return QVariant::fromValue<QString>(tr("Status"));
			break;
		case 2:
			return QVariant::fromValue<QString>(tr("Progress"));
			break;
		case 3:
			return QVariant::fromValue<QString>(tr("Details"));
			break;
		default:
			return QVariant();
			break;
		}
	}

	return QVariant();
}

QModelIndex JobListModel::index(int row, int column, const QModelIndex &parent) const
{
	return createIndex(row, column, NULL);
}

QModelIndex JobListModel::parent(const QModelIndex &index) const
{
	return QModelIndex();
}

QVariant JobListModel::data(const QModelIndex &index, int role) const
{
	if(role == Qt::DisplayRole)
	{
		if(index.row() >= 0 && index.row() < m_jobs.count())
		{
			switch(index.column())
			{
			case 0:
				return m_name.value(m_jobs.at(index.row()));
				break;
			case 1:
				switch(m_status.value(m_jobs.at(index.row())))
				{
				case EncodeThread::JobStatus_Enqueued:
					return QVariant::fromValue<QString>(tr("Enqueued."));
					break;
				case EncodeThread::JobStatus_Starting:
					return QVariant::fromValue<QString>(tr("Starting..."));
					break;
				case EncodeThread::JobStatus_Indexing:
					return QVariant::fromValue<QString>(tr("Indexing..."));
					break;
				case EncodeThread::JobStatus_Running:
					return QVariant::fromValue<QString>(tr("Running..."));
					break;
				case EncodeThread::JobStatus_Running_Pass1:
					return QVariant::fromValue<QString>(tr("Running... (Pass 1)"));
					break;
				case EncodeThread::JobStatus_Running_Pass2:
					return QVariant::fromValue<QString>(tr("Running... (Pass 2)"));
					break;
				case EncodeThread::JobStatus_Completed:
					return QVariant::fromValue<QString>(tr("Completed."));
					break;
				case EncodeThread::JobStatus_Failed:
					return QVariant::fromValue<QString>(tr("Failed!"));
					break;
				case EncodeThread::JobStatus_Pausing:
					return QVariant::fromValue<QString>(tr("Pausing..."));
					break;
				case EncodeThread::JobStatus_Paused:
					return QVariant::fromValue<QString>(tr("Paused."));
					break;
				case EncodeThread::JobStatus_Resuming:
					return QVariant::fromValue<QString>(tr("Resuming..."));
					break;
				case EncodeThread::JobStatus_Aborting:
					return QVariant::fromValue<QString>(tr("Aborting..."));
					break;
				case EncodeThread::JobStatus_Aborted:
					return QVariant::fromValue<QString>(tr("Aborted!"));
					break;
				default:
					return QVariant::fromValue<QString>(tr("(Unknown)"));
					break;
				}
				break;
			case 2:
				return QString().sprintf("%d%%", m_progress.value(m_jobs.at(index.row())));
				break;
			case 3:
				return m_details.value(m_jobs.at(index.row()));
				break;
			default:
				return QVariant();
				break;
			}
		}
	}
	else if(role == Qt::DecorationRole)
	{
		if(index.row() >= 0 && index.row() < m_jobs.count() && index.column() == 0)
		{
			switch(m_status.value(m_jobs.at(index.row())))
			{
			case EncodeThread::JobStatus_Enqueued:
				return QIcon(":/buttons/hourglass.png");
				break;
			case EncodeThread::JobStatus_Starting:
				return QIcon(":/buttons/lightning.png");
				break;
			case EncodeThread::JobStatus_Indexing:
				return QIcon(":/buttons/find.png");
				break;
			case EncodeThread::JobStatus_Running:
			case EncodeThread::JobStatus_Running_Pass1:
			case EncodeThread::JobStatus_Running_Pass2:
				return QIcon(":/buttons/play.png");
				break;
			case EncodeThread::JobStatus_Completed:
				return QIcon(":/buttons/accept.png");
				break;
			case EncodeThread::JobStatus_Failed:
				return QIcon(":/buttons/exclamation.png");
				break;
			case EncodeThread::JobStatus_Pausing:
				return QIcon(":/buttons/clock_pause.png");
				break;
			case EncodeThread::JobStatus_Paused:
				return QIcon(":/buttons/suspended.png");
				break;
			case EncodeThread::JobStatus_Resuming:
				return QIcon(":/buttons/clock_play.png");
				break;
			case EncodeThread::JobStatus_Aborting:
				return QIcon(":/buttons/clock_stop.png");
				break;
			case EncodeThread::JobStatus_Aborted:
				return QIcon(":/buttons/error.png");
				break;
			default:
				return QVariant();
				break;
			}
		}
	}

	return QVariant();
}

///////////////////////////////////////////////////////////////////////////////
// Public interface
///////////////////////////////////////////////////////////////////////////////

QModelIndex JobListModel::insertJob(EncodeThread *thread)
{
	QUuid id = thread->getId();
	LogFileModel *logFile = NULL;

	if(m_jobs.contains(id))
	{
		return QModelIndex();
	}
	
	QString config = "N/A";

	switch(thread->options()->rcMode())
	{
	case OptionsModel::RCMode_CRF:
		config = QString("CRF@%1").arg(QString::number(thread->options()->quantizer()));
		break;
	case OptionsModel::RCMode_CQ:
		config = QString("CQ@%1").arg(QString::number(qRound(thread->options()->quantizer())));
		break;
	case OptionsModel::RCMode_2Pass:
		config = QString("2Pass@%1").arg(QString::number(thread->options()->bitrate()));
		break;
	case OptionsModel::RCMode_ABR:
		config = QString("ABR@%1").arg(QString::number(thread->options()->bitrate()));
		break;
	}

	int n = 2;
	QString jobName = QString("%1 (%2)").arg(QFileInfo(thread->sourceFileName()).completeBaseName().simplified(), config);

	forever
	{
		bool unique = true;
		for(int i = 0; i < m_jobs.count(); i++)
		{
			if(m_name.value(m_jobs.at(i)).compare(jobName, Qt::CaseInsensitive) == 0)
			{
				unique = false;
				break;
			}
		}
		if(!unique)
		{
			jobName = QString("%1 %2 (%3)").arg(QFileInfo(thread->sourceFileName()).completeBaseName().simplified(), QString::number(n++), config);
			continue;
		}
		break;
	}

	beginInsertRows(QModelIndex(), m_jobs.count(), m_jobs.count());
	m_jobs.append(id);
	m_name.insert(id, jobName);
	m_status.insert(id, EncodeThread::JobStatus_Enqueued);
	m_progress.insert(id, 0);
	m_threads.insert(id, thread);
	m_logFile.insert(id, (logFile = new LogFileModel));
	m_details.insert(id, tr("Not started yet."));
	endInsertRows();

	connect(thread, SIGNAL(statusChanged(QUuid, EncodeThread::JobStatus)), this, SLOT(updateStatus(QUuid, EncodeThread::JobStatus)), Qt::QueuedConnection);
	connect(thread, SIGNAL(progressChanged(QUuid, unsigned int)), this, SLOT(updateProgress(QUuid, unsigned int)), Qt::QueuedConnection);
	connect(thread, SIGNAL(messageLogged(QUuid, QString)), logFile, SLOT(addLogMessage(QUuid, QString)), Qt::QueuedConnection);
	connect(thread, SIGNAL(detailsChanged(QUuid, QString)), this, SLOT(updateDetails(QUuid, QString)), Qt::QueuedConnection);
	
	return createIndex(m_jobs.count() - 1, 0, NULL);
}

bool JobListModel::startJob(const QModelIndex &index)
{
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		QUuid id = m_jobs.at(index.row());
		if(m_status.value(id) == EncodeThread::JobStatus_Enqueued)
		{
			updateStatus(id, EncodeThread::JobStatus_Starting);
			updateDetails(id, tr("Starting up, please wait..."));
			m_threads.value(id)->start();
			return true;
		}
	}

	return false;
}

bool JobListModel::pauseJob(const QModelIndex &index)
{
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		QUuid id = m_jobs.at(index.row());
		EncodeThread::JobStatus status = m_status.value(id);
		if((status == EncodeThread::JobStatus_Indexing) || (status == EncodeThread::JobStatus_Running) ||
			(status == EncodeThread::JobStatus_Running_Pass1) || (status == EncodeThread::JobStatus_Running_Pass2))
		{
			updateStatus(id, EncodeThread::JobStatus_Pausing);
			m_threads.value(id)->pauseJob();
			return true;
		}
	}

	return false;
}

bool JobListModel::resumeJob(const QModelIndex &index)
{
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		QUuid id = m_jobs.at(index.row());
		EncodeThread::JobStatus status = m_status.value(id);
		if(status == EncodeThread::JobStatus_Paused)
		{
			updateStatus(id, EncodeThread::JobStatus_Resuming);
			m_threads.value(id)->resumeJob();
			return true;
		}
	}

	return false;
}

bool JobListModel::abortJob(const QModelIndex &index)
{
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		QUuid id = m_jobs.at(index.row());
		if(m_status.value(id) == EncodeThread::JobStatus_Indexing || m_status.value(id) == EncodeThread::JobStatus_Running ||
			m_status.value(id) == EncodeThread::JobStatus_Running_Pass1 || EncodeThread::JobStatus_Running_Pass2)
		{
			updateStatus(id, EncodeThread::JobStatus_Aborting);
			m_threads.value(id)->abortJob();
			return true;
		}
	}

	return false;
}

bool JobListModel::deleteJob(const QModelIndex &index)
{
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		QUuid id = m_jobs.at(index.row());
		if(m_status.value(id) == EncodeThread::JobStatus_Completed || m_status.value(id) == EncodeThread::JobStatus_Failed ||
			m_status.value(id) == EncodeThread::JobStatus_Aborted || m_status.value(id) == EncodeThread::JobStatus_Enqueued)
		{
			int idx = index.row();
			QUuid id = m_jobs.at(idx);
			EncodeThread *thread = m_threads.value(id, NULL);
			LogFileModel *logFile = m_logFile.value(id, NULL);
			if((thread == NULL) || (!thread->isRunning()))
			{
				
				beginRemoveRows(QModelIndex(), idx, idx);
				m_jobs.removeAt(index.row());
				m_name.remove(id);
				m_threads.remove(id);
				m_status.remove(id);
				m_progress.remove(id);
				m_logFile.remove(id);
				m_details.remove(id);
				endRemoveRows();
				X264_DELETE(thread);
				X264_DELETE(logFile);
				return true;
			}
		}
	}

	return false;
}

LogFileModel *JobListModel::getLogFile(const QModelIndex &index)
{
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		return m_logFile.value(m_jobs.at(index.row()));
	}

	return NULL;
}

const QString &JobListModel::getJobOutputFile(const QModelIndex &index)
{
	static QString nullStr;
	
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		EncodeThread *thread = m_threads.value(m_jobs.at(index.row()));
		return (thread != NULL) ? thread->outputFileName() : nullStr;
	}

	return nullStr;
}

EncodeThread::JobStatus JobListModel::getJobStatus(const QModelIndex &index)
{
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		return m_status.value(m_jobs.at(index.row()));
	}

	return static_cast<EncodeThread::JobStatus>(-1);
}

unsigned int JobListModel::getJobProgress(const QModelIndex &index)
{
	if(index.isValid() && index.row() >= 0 && index.row() < m_jobs.count())
	{
		return m_progress.value(m_jobs.at(index.row()));
	}

	return 0;
}

QModelIndex JobListModel::getJobIndexById(const QUuid &id)
{
	if(m_jobs.contains(id))
	{
		return createIndex(m_jobs.indexOf(id), 0);
	}

	return QModelIndex();
}

///////////////////////////////////////////////////////////////////////////////
// Slots
///////////////////////////////////////////////////////////////////////////////

void JobListModel::updateStatus(const QUuid &jobId, EncodeThread::JobStatus newStatus)
{
	int index = -1;
	
	if((index = m_jobs.indexOf(jobId)) >= 0)
	{
		m_status.insert(jobId, newStatus);
		emit dataChanged(createIndex(index, 0), createIndex(index, 1));
	}
}

void JobListModel::updateProgress(const QUuid &jobId, unsigned int newProgress)
{
	int index = -1;

	if((index = m_jobs.indexOf(jobId)) >= 0)
	{
		m_progress.insert(jobId, qBound(0U, newProgress, 100U));
		emit dataChanged(createIndex(index, 2), createIndex(index, 2));
	}
}

void JobListModel::updateDetails(const QUuid &jobId, const QString &details)
{
	int index = -1;

	if((index = m_jobs.indexOf(jobId)) >= 0)
	{
		m_details.insert(jobId, details);
		emit dataChanged(createIndex(index, 3), createIndex(index, 3));
	}
}
