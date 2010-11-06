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

#include "Model_MetaInfo.h"

#define CHECK(STR) (STR.isEmpty() ? "(Unknown)" : STR)

////////////////////////////////////////////////////////////
// Constructor & Destructor
////////////////////////////////////////////////////////////

MetaInfoModel::MetaInfoModel(AudioFileModel *file)
{
	m_audioFile = file;
}

MetaInfoModel::~MetaInfoModel(void)
{
}

////////////////////////////////////////////////////////////
// Public Functions
////////////////////////////////////////////////////////////

int MetaInfoModel::columnCount(const QModelIndex &parent) const
{
	return 2;
}

int MetaInfoModel::rowCount(const QModelIndex &parent) const
{
	return 7;
}

QVariant MetaInfoModel::data(const QModelIndex &index, int role) const
{
	if(role == Qt::DisplayRole)
	{
		switch(index.row())
		{
		case 0:
			return (!index.column()) ? "Full Path" : CHECK(m_audioFile->filePath());
			break;
		case 1:
			return (!index.column()) ? "Title" : CHECK(m_audioFile->fileName());
			break;
		case 2:
			return (!index.column()) ? "Artist" : CHECK(m_audioFile->fileArtist());
			break;
		case 3:
			return (!index.column()) ? "Album" : CHECK(m_audioFile->fileAlbum());
			break;
		case 4:
			return (!index.column()) ? "Genre" : CHECK(m_audioFile->fileGenre());
			break;
		case 5:
			return (!index.column()) ? "Year" : ((m_audioFile->fileYear() > 0) ? QString::number(m_audioFile->fileYear()) : "(Unknown)");
			break;
		case 6:
			return (!index.column()) ? "Comment" : CHECK(m_audioFile->fileComment());
			break;
		default:
			return QVariant();
			break;
		}
	}
	else if(role == Qt::DecorationRole && index.column() == 0)
	{
		switch(index.row())
		{
		case 0:
			return QIcon(":/icons/folder_page.png");
			break;
		case 1:
			return QIcon(":/icons/music.png");
			break;
		case 2:
			return QIcon(":/icons/user.png");
			break;
		case 3:
			return QIcon(":/icons/cd.png");
			break;
		case 4:
			return QIcon(":/icons/star.png");
			break;
		case 5:
			return QIcon(":/icons/calendar.png");
			break;
		case 6:
			return QIcon(":/icons/comment.png");
			break;
		default:
			return QVariant();
			break;
		}
	}
	else if(role == Qt::TextColorRole && index.column() == 1)
	{
		switch(index.row())
		{
		case 0:
			return m_audioFile->filePath().isEmpty() ? Qt::darkGray : QVariant();
			break;
		case 1:
			return m_audioFile->fileName().isEmpty() ? Qt::darkGray : QVariant();
			break;
		case 2:
			return m_audioFile->fileArtist().isEmpty() ? Qt::darkGray : QVariant();
			break;
		case 3:
			return m_audioFile->fileAlbum().isEmpty() ? Qt::darkGray : QVariant();
			break;
		case 4:
			return m_audioFile->fileGenre().isEmpty() ? Qt::darkGray : QVariant();
			break;
		case 5:
			return (m_audioFile->fileYear() == 0) ? Qt::darkGray : QVariant();
			break;
		case 6:
			return m_audioFile->fileComment().isEmpty() ? Qt::darkGray : QVariant();
			break;
		default:
			return QVariant();
			break;
		}
	}
	else
	{
		return QVariant();
	}
}

QVariant MetaInfoModel::headerData(int section, Qt::Orientation orientation, int role) const
{
	if(role == Qt::DisplayRole)
	{
		if(orientation == Qt::Horizontal)
		{
			switch(section)
			{
			case 0:
				return QVariant("Property");
				break;
			case 1:
				return QVariant("Value");
				break;
			default:
				return QVariant();
				break;
			}
		}
		else
		{
			return QVariant();
		}
	}
	else
	{
		return QVariant();
	}
}
