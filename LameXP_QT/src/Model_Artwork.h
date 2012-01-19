///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
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

#include <QString>
#include <QMap>
#include <QMutex>

class QFile;

class ArtworkModel
{
public:
	ArtworkModel(void);
	ArtworkModel(const QString &fileName, bool isOwner = true);
	ArtworkModel(const ArtworkModel &model);
	ArtworkModel &operator=(const ArtworkModel &model);
	~ArtworkModel(void);

	const QString &filePath(void) const;
	bool isOwner(void) const;
	void setFilePath(const QString &newPath, bool isOwner = true);
	void clear(void);

private:
	QString m_filePath;
	bool m_isOwner;

	static QMutex m_mutex;
	static QMap<QString, unsigned int> m_refCount;
	static QMap<QString, QFile*> m_fileHandle;
};
