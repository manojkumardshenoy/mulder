///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2011 LoRd_MuldeR <MuldeR2@GMX.de>
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

#include "Encoder_Abstract.h"

#include <Windows.h>

AbstractEncoder::AbstractEncoder(void)
{
	m_configBitrate = 0;
	m_configRCMode = 0;
	m_configCustomParams.clear();
}

AbstractEncoder::~AbstractEncoder(void)
{
}

/*
 * Setters
 */

void AbstractEncoder::setBitrate(int bitrate) { m_configBitrate = max(0, bitrate); }
void AbstractEncoder::setRCMode(int mode) { m_configRCMode = max(0, mode); }
void AbstractEncoder::setCustomParams(const QString &customParams) { m_configCustomParams = customParams; }

/*
 * Default implementation
 */
bool AbstractEncoder::requiresDownmix(void)
{
	return false;
}
