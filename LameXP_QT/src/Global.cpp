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

///////////////////////////////////////////////////////////////////////////////
// GLOBAL VARS
///////////////////////////////////////////////////////////////////////////////


//Build version
static const unsigned int g_lamexp_version_major = 4;
static const unsigned int g_lamexp_version_minor = 0;
static const unsigned int g_lamexp_version_build = 1;
static const char *g_lamexp_version_release = "Pre-Alpha";

//Build date
static char *g_lamexp_version_date = NULL;
static const char *g_lamexp_months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
static const char *g_lamexp_version_raw_date = __DATE__;

///////////////////////////////////////////////////////////////////////////////
// GLOBAL FUNCTIONS
///////////////////////////////////////////////////////////////////////////////

//Version getters
unsigned int lamexp_version_major(void) { return g_lamexp_version_major; }
unsigned int lamexp_version_minor(void) { return g_lamexp_version_minor; }
unsigned int lamexp_version_build(void) { return g_lamexp_version_build; }
const char *lamexp_version_release(void) { return g_lamexp_version_release; }

//Get build date date
const char *lamexp_version_date(void)
{
	if(!g_lamexp_version_date)
	{
		g_lamexp_version_date = new char[32];
		memset(g_lamexp_version_date, 0, 32);

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
			sprintf_s(g_lamexp_version_date, 32, "%04d-%02d-%02d", date[2], date[0], date[1]);
		}
		else
		{
			strcpy_s(g_lamexp_version_date, 32, g_lamexp_version_raw_date);
		}
	}

	return g_lamexp_version_date;
}
