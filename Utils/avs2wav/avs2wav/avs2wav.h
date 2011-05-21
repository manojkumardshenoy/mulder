///////////////////////////////////////////////////////////////////////////////
// avs2wav - Avisynth to Wave converter
// by Jory Stone <jcsston@toughguy.net>, LoRd_MuldeR <mulder2@gmx.de>
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

#include "stdafx.h"

//Const
static const _TCHAR *stdOutName = _T("<stdout>");

//Vars
static PAVIFILE g_aviFile = NULL;
static PAVISTREAM g_aviStream = NULL;
static AVISTREAMINFO g_aviStreamInfo;
static WAVEFORMATEX *g_wavHeader = NULL;
static LONG g_streamSampleLength = 0;
static LONG g_currentframeSample = 0;
static BYTE *g_frameBuffer = NULL;
static LONG g_frameBufferSize = 0;
static FILE *g_outputFile = NULL;
static DWORD g_dataSizePos = NULL;
static DWORD g_dataSize = NULL;
static LONG g_noSamplesCounter = 0;
static volatile bool abortFlag = false;

//Functions
static bool avs2wav_checkAvsSupport(void);
static bool avs2wav_openSource(_TCHAR *inputFilename);
static bool avs2wav_openOutput(_TCHAR *outputFilename);
static bool avs2wav_dumpStream(LONG *status);
static bool avs2wav_closeOutput(void);

//Helper
static char *utf16_to_utf8(const wchar_t *input);
static BOOL WINAPI CtrlHandlerRoutine(DWORD dwCtrlType);
