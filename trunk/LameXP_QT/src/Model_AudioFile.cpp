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

#include "Model_AudioFile.h"

////////////////////////////////////////////////////////////
// Constructor & Destructor
////////////////////////////////////////////////////////////

AudioFileModel::AudioFileModel(const QString &path, const QString &name)
{
	m_filePath = path;
	m_fileName = name;
}

AudioFileModel::~AudioFileModel(void)
{
}

////////////////////////////////////////////////////////////
// Public Functions
////////////////////////////////////////////////////////////

const QString &AudioFileModel::filePath(void) const
{
	return m_filePath;
}

const QString &AudioFileModel::fileName(void) const
{
	return m_fileName;
}

void AudioFileModel::setFilePath(const QString &path)
{
	m_filePath = path;
}

void AudioFileModel::setFileName(const QString &name)
{
	m_fileName = name;
}
