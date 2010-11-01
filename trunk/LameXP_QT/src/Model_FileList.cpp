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

#include "Model_FileList.h"

#include <QFileInfo>

////////////////////////////////////////////////////////////
// Constructor & Destructor
////////////////////////////////////////////////////////////

FileListModel::FileListModel(void)
	: m_fileIcon(":/icons/page_white_cd.png")
{
	m_fileList.append(AudioFileModel("G:/Mp3z/More MP3z/Walter Trout - Common Ground (2010)/01 May Be A Fool.mp3", "May Be A Fool"));
}

FileListModel::~FileListModel(void)
{
}

////////////////////////////////////////////////////////////
// Public Functions
////////////////////////////////////////////////////////////

int FileListModel::columnCount(const QModelIndex &parent) const
{
	return 2;
}

int FileListModel::rowCount(const QModelIndex &parent) const
{
	return m_fileList.count();
}

QVariant FileListModel::data(const QModelIndex &index, int role) const
{
	if(role == Qt::DisplayRole && index.row() < m_fileList.count() && index.row() >= 0)
	{
		switch(index.column())
		{
		case 0:
			return m_fileList.at(index.row()).fileName();
			break;
		case 1:
			return m_fileList.at(index.row()).filePath();
			break;
		default:
			return QVariant();
			break;
		}		
	}
	else if(role == Qt::DecorationRole && index.column() == 0)
	{
		return m_fileIcon;
	}
	else
	{
		return QVariant();
	}
}

QVariant FileListModel::headerData(int section, Qt::Orientation orientation, int role) const
{
	if(role == Qt::DisplayRole)
	{
		if(orientation == Qt::Horizontal)
		{
			switch(section)
			{
			case 0:
				return QVariant("File Name");
				break;
			case 1:
				return QVariant("Full Path");
				break;
			default:
				return QVariant();
				break;
			}
		}
		else
		{
			if(m_fileList.count() < 10)
			{
				return QVariant(QString().sprintf("%d", section + 1));
			}
			else if(m_fileList.count() < 100)
			{
				return QVariant(QString().sprintf("%02d", section + 1));
			}
			else
			{
				return QVariant(QString().sprintf("%03d", section + 1));
			}
		}
	}
	else
	{
		return QVariant();
	}
}

bool FileListModel::addFile(const QString &filePath)
{
	QFileInfo fileInfo(filePath);

	for(int i = 0; i < m_fileList.count(); i++)
	{
		if(m_fileList.at(i).filePath().compare(fileInfo.absoluteFilePath(), Qt::CaseInsensitive) == 0)
		{
			return false;
		}
	}
	
	beginResetModel();
	m_fileList.append(AudioFileModel(fileInfo.absoluteFilePath(), fileInfo.baseName()));
	endResetModel();

	return true;
}

bool FileListModel::removeFile(const QModelIndex &index)
{
	if(index.row() >= 0 && index.row() < m_fileList.count())
	{
		beginResetModel();
		m_fileList.removeAt(index.row());
		endResetModel();
		return true;
	}
	else
	{
		return false;
	}
}

void FileListModel::clearFiles(void)
{
	beginResetModel();
	m_fileList.clear();
	endResetModel();
}
