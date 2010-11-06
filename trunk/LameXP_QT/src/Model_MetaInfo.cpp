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

#define CHECK1(STR) (STR.isEmpty() ? "(Unknown)" : STR)
#define CHECK2(VAL) ((VAL > 0) ? QString::number(VAL) : "(Unknown)")
#define CHECK3(STR) (STR.isEmpty() ? Qt::darkGray : QVariant())
#define CHECK4(VAL) ((VAL == 0) ? Qt::darkGray : QVariant())

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
	return 12;
}

QVariant MetaInfoModel::data(const QModelIndex &index, int role) const
{
	if(role == Qt::DisplayRole)
	{
		switch(index.row())
		{
		case 0:
			return (!index.column()) ? "Full Path" : CHECK1(m_audioFile->filePath());
			break;
		case 1:
			return (!index.column()) ? "Format" : CHECK1(m_audioFile->formatAudioBaseInfo());
			break;
		case 2:
			return (!index.column()) ? "Container" : CHECK1(m_audioFile->formatContainerInfo());
			break;
		case 3:
			return (!index.column()) ? "Compression" : CHECK1(m_audioFile->formatAudioCompressInfo());
			break;
		case 4:
			return (!index.column()) ? "Duration" : CHECK1(m_audioFile->fileDurationInfo());
			break;
		case 5:
			return (!index.column()) ? "Title" : CHECK1(m_audioFile->fileName());
			break;
		case 6:
			return (!index.column()) ? "Artist" : CHECK1(m_audioFile->fileArtist());
			break;
		case 7:
			return (!index.column()) ? "Album" : CHECK1(m_audioFile->fileAlbum());
			break;
		case 8:
			return (!index.column()) ? "Genre" : CHECK1(m_audioFile->fileGenre());
			break;
		case 9:
			return (!index.column()) ? "Year" : CHECK2(m_audioFile->fileYear());
			break;
		case 10:
			return (!index.column()) ? "Position" : CHECK2(m_audioFile->filePosition());
			break;
		case 11:
			return (!index.column()) ? "Comment" : CHECK1(m_audioFile->fileComment());
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
			return QIcon(":/icons/sound.png");
			break;
		case 2:
			return QIcon(":/icons/package.png");
			break;
		case 3:
			return QIcon(":/icons/compress.png");
			break;
		case 4:
			return QIcon(":/icons/clock_play.png");
			break;
		case 5:
			return QIcon(":/icons/music.png");
			break;
		case 6:
			return QIcon(":/icons/user.png");
			break;
		case 7:
			return QIcon(":/icons/cd.png");
			break;
		case 8:
			return QIcon(":/icons/star.png");
			break;
		case 9:
			return QIcon(":/icons/date.png");
			break;
		case 10:
			return QIcon(":/icons/timeline_marker.png");
			break;
		case 11:
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
			return CHECK3(m_audioFile->filePath());
			break;
		case 1:
			return CHECK3(m_audioFile->formatAudioBaseInfo());
			break;
		case 2:
			return CHECK3(m_audioFile->formatContainerInfo());
			break;
		case 3:
			return CHECK3(m_audioFile->formatAudioCompressInfo());
			break;
		case 4:
			return CHECK4(m_audioFile->fileDurationInfo());
			break;
		case 5:
			return CHECK3(m_audioFile->fileName());
			break;
		case 6:
			return CHECK3(m_audioFile->fileArtist());
			break;
		case 7:
			return CHECK3(m_audioFile->fileAlbum());
			break;
		case 8:
			return CHECK3(m_audioFile->fileGenre());
			break;
		case 9:
			return CHECK4(m_audioFile->fileYear());
			break;
		case 10:
			return CHECK4(m_audioFile->filePosition());
			break;
		case 11:
			return CHECK3(m_audioFile->fileComment());
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
