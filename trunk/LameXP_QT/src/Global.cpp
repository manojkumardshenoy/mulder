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

#include "Global.h"

//Qt includes
#include <QString>
#include <QDir>
#include <QUuid>
#include <QMap>
#include <QDate>

//LameXP includes
#include "LockedFile.h"


///////////////////////////////////////////////////////////////////////////////
// GLOBAL VARS
///////////////////////////////////////////////////////////////////////////////

//Build version
static const unsigned int g_lamexp_version_major = 4;
static const unsigned int g_lamexp_version_minor = 0;
static const unsigned int g_lamexp_version_build = 1;
static const char *g_lamexp_version_release = "Pre-Alpha";

//Build date
static QDate g_lamexp_version_date;
static const char *g_lamexp_months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
static const char *g_lamexp_version_raw_date = __DATE__;

//Special folders
static QString g_lamexp_temp_folder;

//Tools
static QMap<QString, LockedFile*> g_lamexp_tool_registry;

///////////////////////////////////////////////////////////////////////////////
// GLOBAL FUNCTIONS
///////////////////////////////////////////////////////////////////////////////

/*
 * Version getters
 */
unsigned int lamexp_version_major(void) { return g_lamexp_version_major; }
unsigned int lamexp_version_minor(void) { return g_lamexp_version_minor; }
unsigned int lamexp_version_build(void) { return g_lamexp_version_build; }
const char *lamexp_version_release(void) { return g_lamexp_version_release; }

/*
 * Get build date date
 */
const QDate &lamexp_version_date(void)
{
	if(!g_lamexp_version_date.isValid())
	{
		char temp[32];
		int date[3];

		char *this_token = NULL;
		char *next_token = NULL;

		strcpy_s(temp, 32, g_lamexp_version_raw_date);
		this_token = strtok_s(temp, " ", &next_token);

		for(int i = 0; i < 3; i++)
		{
			date[i] = -1;
			if(this_token)
			{
				for(int j = 0; j < 12; j++)
				{
					if(!_strcmpi(this_token, g_lamexp_months[j]))
					{
						date[i] = j+1;
						break;
					}
				}
				if(date[i] < 0)
				{
					date[i] = atoi(this_token);
				}
				this_token = strtok_s(NULL, " ", &next_token);
			}
		}

		if(date[0] >= 0 && date[1] >= 0 && date[2] >= 0)
		{
			g_lamexp_version_date = QDate(date[2], date[0], date[1]);
		}
	}

	return g_lamexp_version_date;
}

/*
 * Get LameXP temp folder
 */
const QString &lamexp_temp_folder(void)
{
	if(g_lamexp_temp_folder.isEmpty())
	{
		QDir tempFolder(QDir::tempPath());
		QString uuid = QUuid::createUuid().toString();
		tempFolder.mkdir(uuid);
		
		if(tempFolder.cd(uuid))
		{
			g_lamexp_temp_folder = tempFolder.absolutePath();
		}
		else
		{
			g_lamexp_temp_folder = QDir::tempPath();
		}
	}
	
	return g_lamexp_temp_folder;
}

/*
 * Clean folder
 */
bool lamexp_clean_folder(const QString folderPath)
{
	QDir tempFolder(folderPath);
	QFileInfoList entryList = tempFolder.entryInfoList();
	
	for(int i = 0; i < entryList.count(); i++)
	{
		if(entryList.at(i).fileName().compare(".") == 0 || entryList.at(i).fileName().compare("..") == 0)
		{
			continue;
		}
		
		if(entryList.at(i).isDir())
		{
			lamexp_clean_folder(entryList.at(i).absoluteFilePath());
		}
		else
		{
			QFile::remove(entryList.at(i).absoluteFilePath());
		}
	}
	
	tempFolder.rmdir(".");
	return !tempFolder.exists();
}

/*
 * Finalization function (Clean-up)
 */
void lamexp_finalization(void)
{
	//Free all tools
	while(!g_lamexp_tool_registry.isEmpty())
	{
		QStringList keys = g_lamexp_tool_registry.keys();
		for(int i = 0; i < keys.count(); i++)
		{
			delete g_lamexp_tool_registry.take(keys.at(i));
		}
	}
	
	//Delete temporary files
	if(!g_lamexp_temp_folder.isEmpty())
	{
		for(int i = 0; i < 100; i++)
		{
			if(lamexp_clean_folder(g_lamexp_temp_folder)) break;
			Sleep(125);
		}
		g_lamexp_temp_folder.clear();
	}
}

/*
 * Register tool
 */
void lamexp_register_tool(const QString &toolName, LockedFile *file)
{
	if(g_lamexp_tool_registry.contains(toolName))
	{
		throw "lamexp_register_tool: Tool is already registered!";
	}

	g_lamexp_tool_registry.insert(toolName, file);
}