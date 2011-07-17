///////////////////////////////////////////////////////////////////////////////
// wma2wav - Dump WMA files to Wave Audio
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

#include "stdafx.h"

#include "WmaReader.h"
#include "WaveWriter.h"
#include "RawWriter.h"
#include "Utils.h"

#include <Objbase.h>
#include <io.h>
#include <float.h>

using namespace std;

// ----------------------------------------------------------------------------------------------------------

static bool parse_cli(int argc, _TCHAR* argv[], wchar_t **inputFile, wchar_t **outputFile, bool *overwrite, bool *rawOutput, bool *silentMode, bool *aggressiveMode, bool *noCompensation, bool *alternativeMode)
{
	*inputFile = NULL;
	*outputFile = NULL;
	*overwrite = false;
	*rawOutput = false;
	*silentMode = false;
	*aggressiveMode = false;
	*noCompensation = false;
	*alternativeMode = false;
	char *temp = NULL;

	for(int i = 1; i < argc; i++)
	{
		if(!_wcsicmp(argv[i], L"-i"))
		{
			if(i < (argc - 1))
			{
				*inputFile = argv[++i];
				continue;
			}
			else
			{
				if(temp = utf16_to_utf8(argv[i]))
				{
					fprintf(stderr, "Argument missing for command-line option:\n%s\n\n", temp);
					SAFE_DELETE_ARRAY(temp);
				}
				return false;
			}
		}
		if(!_wcsicmp(argv[i], L"-o"))
		{
			if(i < (argc - 1))
			{
				*outputFile = argv[++i];
				continue;
			}
			else
			{
				if(temp = utf16_to_utf8(argv[i]))
				{
					fprintf(stderr, "Argument missing for command-line option:\n%s\n\n", temp);
					SAFE_DELETE_ARRAY(temp);
				}
				return false;
			}
		}
		if(!_wcsicmp(argv[i], L"-f"))
		{
			*overwrite = true;
			continue;
		}
		if(!_wcsicmp(argv[i], L"-r"))
		{
			*rawOutput = true;
			continue;
		}
		if(!_wcsicmp(argv[i], L"-s"))
		{
			*silentMode = true;
			continue;
		}
		if(!_wcsicmp(argv[i], L"-a"))
		{
			*aggressiveMode = true;
			continue;
		}
		if(!_wcsicmp(argv[i], L"-n"))
		{
			*noCompensation = true;
			continue;
		}
		if(!_wcsicmp(argv[i], L"-x"))
		{
			*alternativeMode = true;
			continue;
		}
		
		if(temp = utf16_to_utf8(argv[i]))
		{
			fprintf(stderr, "Unknown command-line option:\n%s\n\n", temp);
			SAFE_DELETE_ARRAY(temp);
		}

		return false;
	}

	if((*noCompensation) && (*aggressiveMode))
	{
		cerr << "Can not use \"-a\" and \"-n\" options at the same time!\n" << endl;
		return false;
	}
	
	if(!((*inputFile) && (*outputFile)))
	{
		cerr << "Input and/or output file not specified!\n" << endl;
		return false;
	}

	if((!_wcsicmp(*outputFile, L"-")) && (!(*rawOutput)))
	{
		cerr << "Output to STDOUT requires \"raw\" mode -> switching to \"raw\" mode!\n" << endl;
		*rawOutput = true;
	}

	return true;
}

// ----------------------------------------------------------------------------------------------------------

static int wma2wav(int argc, _TCHAR* argv[])
{
	cerr << "wma2wav - Dump WMA/WMV files to Wave Audio [" __DATE__ "]" << endl;
	cerr << "Copyright (c) 2011 LoRd_MuldeR <mulder2@gmx.de>. Some rights reserved." << endl;
	cerr << "Released under the terms of the GNU General Public License.\n" << endl;

	CAbstractSink *sink = NULL;
	CWmaReader *wmaReader = NULL;
	WAVEFORMATEX format;
	SecureZeroMemory(&format, sizeof(WAVEFORMATEX));
	double duration = -1.0;
	BYTE *buffer = NULL;
	size_t bufferLen = 0;
	size_t sampleLen = 0;
	double currentTime = 0.0;
	short indicator = 0;
	wchar_t *inputFile = NULL;
	wchar_t *outputFile = NULL;
	bool overwriteFlag = false;
	bool rawOutput = false;
	bool silentMode = false;
	bool aggressiveMode = false;
	bool noCompensation = false;
	bool alternativeMode = false;
	char *temp = NULL;

	if(!parse_cli(argc, argv, &inputFile, &outputFile, &overwriteFlag, &rawOutput, &silentMode, &aggressiveMode, &noCompensation, &alternativeMode))
	{
		cerr << "Usage:" << endl;
		cerr << "  wma2wav.exe [options] -i <input> -o <output>\n" << endl;
		cerr << "Options:" << endl;
		cerr << "  -i <input>   Select input ASF (WMA/WMV) file to read from" << endl;
		cerr << "  -o <output>  Select output Wave file to write to, specify \"-\" for STDOUT" << endl;
		cerr << "  -f           Force overwrite of output file (if already exists)" << endl;
		cerr << "  -r           Output \"raw\" PCM data to file instead of Wave/RIFF file" << endl;
		cerr << "  -s           Silent mode, do not display progress indicator" << endl;
		cerr << "  -a           Enable the \"aggressive\" gap compensation/padding mode" << endl;
		cerr << "  -n           No gap compensation/padding (can not use with \"-a\")" << endl;
		cerr << "  -x           Use alternative timestamp calculation mode (experimental)\n" << endl;
		return 1;
	}

	const double maxGapSize = noCompensation ? numeric_limits<double>::infinity() : (aggressiveMode ? 0.00000001 : 0.00100001);

	if(CoInitializeEx(NULL, COINIT_MULTITHREADED) != S_OK)
	{
		cerr << "Fatal Error: COM initialization has failed unexpectedly!" << endl;
		_exit(-1);
	}
	
	if(temp = utf16_to_utf8(inputFile))
	{
		fprintf(stderr, "Input file: %s\n", temp);
		SAFE_DELETE_ARRAY(temp);
	}
	if(temp = utf16_to_utf8(outputFile))
	{
		fprintf(stderr, "Output file: %s\n\n", temp);
		SAFE_DELETE_ARRAY(temp);
	}
	
	if(_waccess(inputFile, 4))
	{
		cerr << "Input file could not be found or access denied!" << endl;
		return 2;
	}
	if(_wcsicmp(outputFile, L"-") && (!overwriteFlag))
	{
		if(!_waccess(outputFile, 4))
		{
			cerr << "Output file already exists, will NOT overwrite!" << endl;
			return 3;
		}
	}

	wmaReader = new CWmaReader();
	cerr << "Opening input file... " << flush;

	if(!wmaReader->open(inputFile))
	{
		cerr << "Failed\n\nMake sure that the input file is a valid ASF (WMA/WMV) file!" << endl;
		SAFE_DELETE(wmaReader);
		return 4;
	}
	
	cerr << "OK\nAnalyzing input file... " << flush;

	if(!wmaReader->analyze())
	{
		cerr << "Failed\n\nThis usually indicates that the ASF file contains no suitable audio stream." << endl;
		SAFE_DELETE(wmaReader);
		return 5;
	}
		
	if(!wmaReader->getFormat(&format))
	{
		cerr << "Internal error, aborting! (0x01)" << endl;
		_exit(-1);
	}

	cerr << "OK\n\n[Audio Properties]" << endl;
	cerr << "wFormatTag: " << hex << format.wFormatTag << dec << endl;
	cerr << "nChannels: " << format.nChannels << endl;
	cerr << "nSamplesPerSec: " << format.nSamplesPerSec << endl;
	cerr << "wBitsPerSample: " << format.wBitsPerSample << endl;

	if((duration = wmaReader->getDuration()) > 0.0)
	{
		double duration_minutes, duration_seconds;
		seconds_to_minutes(duration, &duration_minutes, &duration_seconds);
		fprintf(stderr, "fDuration: %.0f:%04.1f\n", duration_minutes, duration_seconds);
	}
	
	if((bufferLen = wmaReader->getSampleSize()) < 1)
	{
		cerr << "\nFailed to detect maximum sample size!" << endl;
		SAFE_DELETE(wmaReader);
		return 6;
	}
	
	cerr << "nMaxSampleSize: " << bufferLen << endl;
	cerr << "\nOpening output file... " << flush;

	sink = (!rawOutput) ? dynamic_cast<CAbstractSink*>(new CWaveWriter()) : dynamic_cast<CAbstractSink*>(new CRawWriter());

	if(!sink->open(outputFile, &format))
	{
		cerr << "Failed" << endl;
		SAFE_DELETE(wmaReader);
		return 7;
	}

	cerr << "OK\n" << endl;

	if(silentMode)
	{
		cerr << "Dumping audio samples to file, please be patient..." << flush;
	}

	bufferLen = ((bufferLen / 4096) + 1) * 4096;
	buffer = new BYTE[bufferLen];
	SecureZeroMemory(buffer, bufferLen);

	while(true)
	{
		if((!indicator) && (!silentMode))
		{
			if(duration > 0.0)
			{
				double completed = min((currentTime / duration) * 100.0, 100.0);
				double currentTime_minutes, currentTime_seconds, duration_minutes, duration_seconds;
				seconds_to_minutes(currentTime, &currentTime_minutes, &currentTime_seconds);
				seconds_to_minutes(duration, &duration_minutes, &duration_seconds);
				fprintf(stderr, "\r[%3.1f%%] %.0f:%04.1f of %.0f:%04.1f completed, please wait...", completed, currentTime_minutes, currentTime_seconds, duration_minutes, duration_seconds);
			}
			else
			{
				double currentTime_minutes, currentTime_seconds;
				seconds_to_minutes(currentTime, &currentTime_minutes, &currentTime_seconds);
				fprintf(stderr, "\r%.0f:%04.1f seconds completed so far...", currentTime_minutes, currentTime_seconds);
			}
		}
		
		indicator = (indicator + 1 ) % 10;
		
		double sampleDuration = -1.0;
		double sampleTimestamp = -1.0;

		if(!wmaReader->getNextSample(buffer, &sampleLen, &sampleTimestamp, &sampleDuration))
		{
			cerr << "\n\nFailed to read sample from input file!" << endl;
			SAFE_DELETE(sink);
			SAFE_DELETE(wmaReader);
			SAFE_DELETE_ARRAY(buffer);
			return 8;
		}
		
		if(!(sampleLen > 0))
		{
			if(!silentMode)
			{
				double currentTime_minutes, currentTime_seconds;
				seconds_to_minutes(currentTime, &currentTime_minutes, &currentTime_seconds);
				fprintf(stderr, "\r[%3.1f%%] %.0f:%04.1f of %.0f:%04.1f completed, please wait...", 100.0, currentTime_minutes, currentTime_seconds, currentTime_minutes, currentTime_seconds);
			}
			break;
		}

		if((sampleTimestamp >= 0.0) && (abs(sampleTimestamp - currentTime) > maxGapSize))
		{
			if(!silentMode)
			{
				fprintf(stderr, "\rInconsistent timestamps: expected %10.8f, but got %10.8f.\n", currentTime, sampleTimestamp);
			}

			if(sampleTimestamp > currentTime)
			{
				size_t paddingBytes = static_cast<size_t>(floor((sampleTimestamp - currentTime) * static_cast<double>(format.nSamplesPerSec))) * (format.wBitsPerSample / 8) * format.nChannels;
				
				if(paddingBytes > 0)
				{
					BYTE zeroBuffer[1024];
					SecureZeroMemory(zeroBuffer, 1024);

					if(!silentMode)
					{
						fprintf(stderr, "There is a \"gap\" of %10.8f seconds, padding %I64u zero bytes!\n\n", (sampleTimestamp - currentTime), static_cast<unsigned __int64>(paddingBytes));
					}

					currentTime += (static_cast<double>(paddingBytes / (format.wBitsPerSample / 8) / format.nChannels) / static_cast<double>(format.nSamplesPerSec));

					while(paddingBytes > 0)
					{
						size_t currentSize = min(paddingBytes, 1024);
						if(!sink->write(currentSize, zeroBuffer))
						{
							cerr << "\n\nFailed to write sample to output file!" << endl;
							SAFE_DELETE(sink);
							SAFE_DELETE(wmaReader);
							SAFE_DELETE_ARRAY(buffer);
							return 9;
						}
						paddingBytes -= currentSize;
					}
				}
			}
			else
			{
				if(!silentMode)
				{
					fprintf(stderr, "The samples \"overlap\" for %10.8f seconds, can't correct!\n\n", (currentTime - sampleTimestamp));
				}

				currentTime -= (currentTime - sampleTimestamp);
			}
		}

		if(!sink->write(sampleLen, buffer))
		{
			cerr << "\n\nFailed to write sample to output file!" << endl;
			SAFE_DELETE(sink);
			SAFE_DELETE(wmaReader);
			SAFE_DELETE_ARRAY(buffer);
			return 9;
		}

		if(sampleDuration >= 0.0)
		{
			if((sampleTimestamp >= 0.0) && (!alternativeMode))
			{
				currentTime = sampleTimestamp + sampleDuration;
			}
			else 
			{
				currentTime += sampleDuration;
			}
		}
	}

	if(!sink->close())
	{
		cerr << "\n\nError: Failed to properly close output file!" << endl;
		SAFE_DELETE(wmaReader);
		SAFE_DELETE(sink);
		SAFE_DELETE_ARRAY(buffer);
		return 10;
	}

	cerr << "\n\nAll done." << endl;

	SAFE_DELETE(wmaReader);
	SAFE_DELETE(sink);
	SAFE_DELETE_ARRAY(buffer);

	return 0;
}

// ----------------------------------------------------------------------------------------------------------

static int wmain2(int argc, _TCHAR* argv[])
{
	try
	{
		return wma2wav(argc, argv);
	}
	catch(std::bad_alloc err)
	{
		fprintf(stderr, "\nMemory allocation has failed, application will exit!\n");
		return -1;
	}
	catch(char *err)
	{
		fprintf(stderr, "\n%s\n", err);
		return -1;
	}
	catch(...)
	{
		fprintf(stderr, "\nUnhandeled exception error, application will exit!\n");
		return -1;
	}
}

int wmain(int argc, _TCHAR* argv[])
{
	__try
	{
		repair_standard_streams();
		int result = wmain2(argc, argv);
		CoUninitialize();
		restore_previous_codepage();
		return result;
	}
	__except(1)
	{
		fprintf(stderr, "\nUnhandeled system exception, application will exit!\n");
		TerminateProcess(GetCurrentProcess(), -1);
		return -1;
	}
}