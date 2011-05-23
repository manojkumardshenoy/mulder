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

#include "avs2wav.h"

static const char* versionTag = "v1.2";

using namespace std;

////////////////////////////////////////////////////
// Application Entry Point
////////////////////////////////////////////////////
int _tmain(int argc, _TCHAR* argv[])
{
	//Print version info and credits
	cerr << "avs2wav " << versionTag << " [" << __DATE__ << "]" << endl;
	cerr << "by Jory Stone <jcsston@toughguy.net>, updates by LoRd_MuldeR <mulder2@gmx.de>" << endl;
	cerr << endl;

	//Init global vars
	memset(&g_aviStreamInfo, 0, sizeof(AVISTREAMINFO));

	//Check arguments
	if(argc < 3)
	{
		cerr << "Usage:" << endl;
		cerr << "  avs2wav.exe <input.avs> <output.wav>" << endl;
		cerr << endl;
		cerr << "Set the output file name to \"-\" in order to output raw PCM data to STDOUT." << endl;
		cerr << "If you only need the audio info, set the output file name to to \"?\"." << endl;
		cerr << endl;
		return AVS2WAV_ERROR_INVALIDARGS;
	}
		
	//Add Ctrl+C handler
	SetConsoleCtrlHandler(CtrlHandlerRoutine, TRUE);

	//Set input/output files
	_TCHAR *inputFilename = argv[1];
	_TCHAR *outputFilename = _wcsicmp(argv[2], _T("-")) ?  (_wcsicmp(argv[2], _T("?")) ? argv[2] : _wcsdup(infoOnlyName)) : _wcsdup(stdOutName);
	
	//Print input/output files
	if(char *buffer = utf16_to_utf8(inputFilename))
	{
		cerr << "Input: " << buffer << endl;
		delete [] buffer;
	}
	if(char *buffer = utf16_to_utf8(outputFilename))
	{
		cerr << "Output: " << buffer << endl;
		delete [] buffer;
	}
	cerr << endl;

	//Initialize the AVIFile library
	AVIFileInit();

	//Check avisynth support
	if(!avs2wav_checkAvsSupport())
	{
		cerr << "System cannot load Avisynth scripts. Terminating!" << endl;
		AVIFileExit();
		return AVS2WAV_ERROR_AVSINITFAILED;
	}

	//Open input file
	if(!avs2wav_openSource(inputFilename))
	{
		cerr << "Failed to open input file. Terminating!" << endl;
		AVIFileExit();
		return AVS2WAV_ERROR_OPENINPUTFAILED;
	}

	//Open output file
	if(!avs2wav_openOutput(outputFilename))
	{
		cerr << "Failed to open output file. Terminating!" << endl;
		
		AVIStreamRelease(g_aviStream);
		g_aviStream = NULL;
		AVIFileRelease(g_aviFile);
		g_aviFile = NULL;

		if(g_wavHeader)
		{
			delete g_wavHeader;
			g_wavHeader = NULL;
		}

		AVIFileExit();
		return AVS2WAV_ERROR_OPENOUTPUTFAILED;
	}

	//Print stream info
	if(g_wavHeader)
	{
		wcerr << endl << "[Audio Info]" << endl;
		wcerr << "TotalSamples: " << g_streamSampleLength << endl;
		wcerr << "TotalSeconds: " << static_cast<int>(floor((static_cast<double>(g_streamSampleLength) / static_cast<double>(g_wavHeader->nSamplesPerSec)) + 0.5)) << endl;
		wcerr << "SamplesPerSec: " << g_wavHeader->nSamplesPerSec << endl;
		wcerr << "BitsPerSample: " << g_wavHeader->wBitsPerSample << endl;
		wcerr << "Channels: " << g_wavHeader->nChannels << endl;
		wcerr << "AvgBytesPerSec: " << g_wavHeader->nAvgBytesPerSec << endl;
	}

	//Exit right now, if in INFO mode
	if(!g_outputFile)
	{
		cerr << endl;
		cerr << "Info has been printed. Exiting." << endl;

		AVIStreamRelease(g_aviStream);
		g_aviStream = NULL;
		AVIFileRelease(g_aviFile);
		g_aviFile = NULL;
		
		if(g_wavHeader)
		{
			delete g_wavHeader;
			g_wavHeader = NULL;
		}

		AVIFileExit();
		return AVS2WAV_ERROR_SUCCESS;
	}

	LONG status = 0;
	LONG iterator = 0;
	cerr << endl;

	//Print progress
	wcerr << "Dumping audio data, please wait:" << endl;
	fprintf(stderr, "\r%ld/%ld [%d%%]", 0, g_streamSampleLength, 0);

	//Dump the audio stream
	while(avs2wav_dumpStream(&status) && !abortFlag)
	{
		if(!iterator)
		{
			double progress = static_cast<double>(g_currentframeSample) / static_cast<double>(g_streamSampleLength);
			fprintf(stderr, "\r%ld/%ld [%d%%]", g_currentframeSample, g_streamSampleLength, static_cast<int>(progress * 100.0));
			cerr << flush;
		}
		iterator = (iterator + 1) % 256;
	}

	//Check if dump was successfull
	if(status != AVS2WAV_STATUS_COMPLETE)
	{
		if(abortFlag)
		{
			cerr << endl << endl << "The user has requested to abort. Terminating!" << endl;
		}
		else
		{
			cerr << endl << "Failed to dump audio stream (status " << status << "). Terminating!" << endl;
		}
		
		fclose(g_outputFile);
		g_outputFile = NULL;
		
		AVIStreamRelease(g_aviStream);
		g_aviStream = NULL;
		AVIFileRelease(g_aviFile);
		g_aviFile = NULL;
		
		if(g_wavHeader)
		{
			delete g_wavHeader;
			g_wavHeader = NULL;
		}
		if(g_frameBuffer)
		{
			delete [] g_frameBuffer;
			g_frameBuffer = NULL;
		}
		
		AVIFileExit();
		return AVS2WAV_ERROR_DUMPINCOMPLETE;
	}

	//Complete
	fprintf(stderr, "\r%ld/%ld [%d%%]\n\n", g_streamSampleLength, g_streamSampleLength, 100);
	cerr << "All samples have been dumped. Exiting." << endl;

	//Close output
	if(!avs2wav_closeOutput(outputFilename))
	{
		cerr << endl << "Error while closing output wave file!" << endl;
	}
		
	//Close input
	AVIStreamRelease(g_aviStream);
	g_aviStream = NULL;
	AVIFileRelease(g_aviFile);
	g_aviFile = NULL;

	//Free memory
	if(g_wavHeader)
	{
		delete g_wavHeader;
		g_wavHeader = NULL;
	}
	if(g_frameBuffer)
	{
		delete [] g_frameBuffer;
		g_frameBuffer = NULL;
	}

	//Close the AVIFile library
	AVIFileExit();
	return AVS2WAV_ERROR_SUCCESS;
}

////////////////////////////////////////////////////
// Open input file
////////////////////////////////////////////////////
bool avs2wav_openSource(_TCHAR *inputFilename)
{	
	HRESULT success = 0;
	_TCHAR shortInputFilename[4096] = {L'\0'};

	wcerr << "Analyzing input file... " << flush;

	//Make sure the file exists
	if(_waccess_s(inputFilename, 4))
	{
		wcerr << "Failed" << endl;
		wcerr << "--> File does not exist or cannot be opened for reading!" << endl;
		return false;
	}

	//Try to get short name
	DWORD length = GetShortPathName(inputFilename, shortInputFilename, 4096);
	if(!((length > 0) && (length < 4096)))
	{
		shortInputFilename[0] = L'\0';
	}

	//Open AVI file
	success = AVIFileOpen(&g_aviFile, ((wcslen(shortInputFilename) > 0) ? shortInputFilename : inputFilename), OF_SHARE_DENY_WRITE | OF_READ, 0L);
	if(success != AVIERR_OK)
	{
		wcerr << "Failed" << endl;
		wcerr << "--> AVIFileOpen failed, unable to open file!" << endl;
		return false;
	}

	int skippedStreams = 0;
	bool foundAudioStream = false;

	//Find audio stream
	for(LONG streamIdx = 0; streamIdx < LONG_MAX; streamIdx++)
	{		
		success = AVIFileGetStream(g_aviFile, &g_aviStream, 0, streamIdx);
		if(success != AVIERR_OK)
		{
			if (!streamIdx)
			{
				AVIFileRelease(g_aviFile);
				g_aviFile = NULL;
				wcerr << "Failed" << endl;
				wcerr << "--> AVIFileGetStream failed, unable to get any streams!" << endl;
				return false;
			}
			break;
		}		

		success = AVIStreamInfo(g_aviStream, &g_aviStreamInfo, sizeof(AVISTREAMINFO));
		if(success != AVIERR_OK)
		{
			AVIStreamRelease(g_aviStream);
			g_aviStream = NULL;
			skippedStreams++;
			continue;
		}

		if(g_aviStreamInfo.fccType == streamtypeAUDIO)
		{			
			g_wavHeader = (WAVEFORMATEX*) malloc(sizeof(WAVEFORMATEX));
			LONG cbACM = sizeof(WAVEFORMATEX);
			ZeroMemory(g_wavHeader, sizeof(WAVEFORMATEX));

			success = AVIStreamReadFormat(g_aviStream, 0, g_wavHeader, &cbACM);
			if(success != AVIERR_OK)
			{
				delete g_wavHeader;
				g_wavHeader = NULL;
				AVIStreamRelease(g_aviStream);
				g_aviStream = NULL;
				skippedStreams++;
				continue;
			}

			g_streamSampleLength = AVIStreamLength(g_aviStream);
			if(g_streamSampleLength <= 0)
			{
				delete g_wavHeader;
				g_wavHeader = NULL;
				AVIStreamRelease(g_aviStream);
				g_aviStream = NULL;
				skippedStreams++;
				continue;
			}

			foundAudioStream = true;
			break;
		}

		skippedStreams++;
		AVIStreamRelease(g_aviStream);
		g_aviStream = NULL;
	}

	//Check if audio stream is avialble
	if(!foundAudioStream )
	{
		AVIFileRelease(g_aviFile);
		g_aviFile = NULL;
		wcerr << "Failed" << endl;
		wcerr << "--> Could not find any Audio Stream in the input! (skipped " << skippedStreams << " streams)" << endl;
		return false;
	}
	
	wcerr << "Done" << endl;
	return true;
}

////////////////////////////////////////////////////
// Check for Avisynth support
////////////////////////////////////////////////////
bool avs2wav_checkAvsSupport(void)
{
	FILE *tmpFile = NULL;
	PAVIFILE aviFile = NULL;
	size_t size = 0;

	_TCHAR tempName[4096] = {L'\0'};
	_TCHAR tempPath[2048] = {L'\0'};
	_TCHAR tempPart[2048] = {L'\0'};
	_TCHAR tmpShort[4096] = {L'\0'};

	wcerr << "Checking Avisynth... " << flush;
	
	//Get temp folder
	if(_wgetenv_s(&size, tempPath, 2048, _T("TMP")) || (wcslen(tempPath) < 1))
	{
		if(_wgetenv_s(&size, tempPath, 2048, _T("TEMP")) || (wcslen(tempPath) < 1))
		{
			wcscpy_s(tempPath, 2048, _T("."));
		}
	}

	//Generate temp file name
	if(_wtmpnam_s(tempPart, 2048))
	{
		wcerr << "Skipped" << endl;
		wcerr << "--> Unable to generate temporary file name!" << endl;
		return true;
	}
	_stprintf_s(tempName, 4096, _T("%s%savs"), tempPath, tempPart);

	//Open temp file
	if(_wfopen_s(&tmpFile, tempName, _T("w+")))
	{
		wcerr << "Skipped" << endl;
		wcerr << "FOpen failed, unable to open temporary file:" << endl;
		wcerr << tempName << endl << endl;
		return true;
	}

	//Write simple AVS script
	static const char *avsText = "Version()\n";
	if(fprintf(tmpFile, "%s", avsText) < static_cast<int>(strlen(avsText)))
	{
		wcerr << "Skipped" << endl;
		wcerr << "fprintf failed, unable to write to temporary file:" << endl;
		wcerr << tempName << endl << endl;
		fclose(tmpFile);
		return true;
	}
	
	fclose(tmpFile);

	//Try to get short name
	DWORD length = GetShortPathName(tempName, tmpShort, 4096);
	if(!((length > 0) && (length < 4096)))
	{
		tmpShort[0] = L'\0';
	}

	//Try to open AVI file
	HRESULT success = AVIFileOpen(&aviFile, ((wcslen(tmpShort) > 0) ? tmpShort : tempName), OF_SHARE_DENY_WRITE | OF_READ, 0L);
	if(success != AVIERR_OK)
	{
		_tremove(tempName);
		wcerr << "Failed" << endl;
		wcerr << "--> AVIFileOpen failed, unable to load Avisynth script!" << endl;
		return false;
	}

	AVIFileRelease(aviFile);
	aviFile = NULL;
	_tremove(tempName);

	wcerr << "Done" << endl;
	return true;
}

////////////////////////////////////////////////////
// Open output file
////////////////////////////////////////////////////
bool avs2wav_openOutput(_TCHAR *outputFilename)
{
	wcerr << "Opening output file... " << flush;
	
	//Check for info mode
	if(!_wcsicmp(outputFilename, infoOnlyName))
	{
		g_dataSize = 0;
		g_outputFile = NULL;
		wcerr << "Done" << endl;
		return true;
	}
	
	//Check if output file was opened
	if(_wcsicmp(outputFilename, stdOutName))
	{
		if(_wfopen_s(&g_outputFile, outputFilename, _T("wb+")))
		{
			wcerr << "Failed" << endl;
			wcerr << "--> FOpen failed, unable to open output file!" << endl;
			return false;
		}
	}
	else
	{
		if(!(g_outputFile = _fdopen(_open_osfhandle((long) GetStdHandle(STD_OUTPUT_HANDLE), _O_BINARY), "wb+")))
		{
			wcerr << "Failed" << endl;
			wcerr << "_fdopen failed, unable to open standard output handle!" << endl << endl;
			return false;
		}
		g_dataSize = 0;
		wcerr << "Done" << endl;
		return true;
	}

	//Init local vars
	WAVEFORMATEX wavHeader;
	bool writeError = false;
	DWORD dwTemp = 0;
	WORD wTemp = 0;
	BYTE bTemp = 0;;
	
	//Copy header
	memcpy(&wavHeader, g_wavHeader, sizeof(WAVEFORMATEX));
	wavHeader.cbSize = 0;

	//Write the RIFF base header
	fwrite_checked("RIFF", 4, g_outputFile, &writeError);
	dwTemp = (-1);
	fwrite_checked(&dwTemp, 4, g_outputFile, &writeError);
	fwrite_checked("WAVE", 4, g_outputFile, &writeError);

	//Format chunk header
	fwrite_checked("fmt ", 4, g_outputFile, &writeError);
	dwTemp = 0x10;
	fwrite_checked(&dwTemp, 4, g_outputFile, &writeError);
	wTemp = g_wavHeader->wFormatTag;
	fwrite_checked(&wTemp, 2, g_outputFile, &writeError);
	wTemp = g_wavHeader->nChannels;
	fwrite_checked(&wTemp, 2, g_outputFile, &writeError);
	dwTemp = g_wavHeader->nSamplesPerSec;
	fwrite_checked(&dwTemp, 4, g_outputFile, &writeError);
	dwTemp = g_wavHeader->nAvgBytesPerSec;
	fwrite_checked(&dwTemp, 4, g_outputFile, &writeError);
	wTemp = g_wavHeader->nBlockAlign;
	fwrite_checked(&wTemp, 2, g_outputFile, &writeError);
	wTemp = g_wavHeader->wBitsPerSample;
	fwrite_checked(&wTemp, 2, g_outputFile, &writeError);

	//Data chunk header
	fwrite_checked("data", 4, g_outputFile, &writeError);
	dwTemp = (-1);
	fwrite_checked(&dwTemp, 4, g_outputFile, &writeError);
	
	//Make sure header was written correctly
	if(writeError || (ftell(g_outputFile) != 44L))
	{
		wcerr << "Failed" << endl;
		wcerr << "fwrite failed, unable to write wave header!" << endl << endl;
		fclose(g_outputFile);
		g_outputFile = NULL;
		return false;
	}

	g_dataSize = 0;
	wcerr << "Done" << endl;
	return true;
};

////////////////////////////////////////////////////
// Close output file
////////////////////////////////////////////////////
bool avs2wav_closeOutput(_TCHAR *outputFilename)
{
	if(!g_outputFile)
	{
		return false;
	}
	
	//Return if output file is STDOUT
	if(!_wcsicmp(outputFilename, stdOutName))
	{
		fclose(g_outputFile);
		g_outputFile = NULL;
		return true;
	}

	//Seek to end of file
	if(fseek(g_outputFile, 0, SEEK_END))
	{
		fclose(g_outputFile);
		g_outputFile = NULL;
		return false;
	}
	
	//Query file size
	__int64 fileSize = _ftelli64(g_outputFile);

	//Make sure data fits in 4GB RIFF/Wave file
	if(fileSize > 0xffffffffi64)
	{
		fclose(g_outputFile);
		g_outputFile = NULL;
		return false;
	}

	//Calculate RIFF chunk size
	DWORD riffSize = static_cast<DWORD>(fileSize - 8i64);
	DWORD dataSize = static_cast<DWORD>(fileSize - 44i64);

	//Seek to end of file
	if(fseek(g_outputFile, 0, SEEK_END))
	{
		fclose(g_outputFile);
		g_outputFile = NULL;
		return false;
	}

	//Check data size
	if(dataSize != g_dataSize)
	{
		fclose(g_outputFile);
		g_outputFile = NULL;
		return false;
	}

	bool riffSizeUpdated = false;
	bool dataSizeUpdated = false;

	//Update chunk sizes
	if(!fseek(g_outputFile, 4, SEEK_SET))
	{
		if(fwrite(&riffSize, 1, 4, g_outputFile) == 4)
		{
			riffSizeUpdated = true;
		}
	}
	if(!fseek(g_outputFile, 40, SEEK_SET))
	{
		if(fwrite(&dataSize, 1, 4, g_outputFile) == 4)
		{
			dataSizeUpdated = true;
		}
	}

	//Close file
	fclose(g_outputFile);
	g_outputFile = NULL;
	
	//Check if update was successful
	return (riffSizeUpdated && dataSizeUpdated);
}

////////////////////////////////////////////////////
// Dump audio stream to file
////////////////////////////////////////////////////
bool avs2wav_dumpStream(LONG *status)
{
	LONG bytesRead = 0;
	LONG samplesRead = 0;

	//Any samples left to dump?
	if(g_currentframeSample >= g_streamSampleLength)
	{
		*status = AVS2WAV_STATUS_COMPLETE;
		return false;
	}

	//Detect buffer size
	HRESULT result = AVIStreamRead(g_aviStream, g_currentframeSample, AVISTREAMREAD_CONVENIENT, NULL, NULL, &bytesRead, &samplesRead);

	//Adjust buffer size, if required
	if (g_frameBufferSize < bytesRead)
	{
		try
		{
			bytesRead += 2;
			if(g_frameBuffer) delete g_frameBuffer;
			g_frameBuffer = new BYTE[bytesRead];
			g_frameBufferSize = bytesRead;
		}
		catch(...)
		{
			wcerr << endl << endl << "Memory allocation has failed!" << endl;
			g_frameBuffer = NULL;
			*status = AVS2WAV_STATUS_MALLOCFAILED;
			return false;
		}
	}				

	//Fetch the data
	result = AVIStreamRead(g_aviStream, g_currentframeSample, AVISTREAMREAD_CONVENIENT, g_frameBuffer, g_frameBufferSize, &bytesRead, &samplesRead);

	//Check if successfull
	if (result != AVIERR_OK)
	{
		wcerr << endl << endl << "AVIStreamRead returned error!" << endl;
		*status = AVS2WAV_STATUS_AVIREADERROR;
		return false;
	}

	//Increase sample position
	if(samplesRead > 0)
	{
		g_currentframeSample += samplesRead;
		g_noSamplesCounter = 0;
	}
	else
	{
		g_noSamplesCounter++;
		if(g_noSamplesCounter >= AVS2WAV_MAXRETRYCOUNT)
		{
			wcerr << endl << endl << "AVIStreamRead succeeded, but did not return any samples!" << endl;
			*status = AVS2WAV_STATUS_NOSAMPLES;
			return false;
		}
	}

	//Write to output file
	if(bytesRead > 0)
	{
		if(size_t size = fwrite(g_frameBuffer, 1, bytesRead, g_outputFile))
		{
			g_dataSize += size;
			if(size < static_cast<size_t>(bytesRead))
			{
				wcerr << endl << endl << "Not all data was written to output file!" << endl;
				*status = AVS2WAV_STATUS_WAVWRITERROR;
				return false;
			}
		}
		else
		{
			wcerr << endl << endl << "Faild to write data to output file!" << endl;
			*status = AVS2WAV_STATUS_WAVWRITERROR;
			return false;
		}
	}

	*status = AVS2WAV_STATUS_MOREDATA;
	return true;
}

////////////////////////////////////////////////////
// Convert UTF-16 to UTF-8
////////////////////////////////////////////////////
char *utf16_to_utf8(const wchar_t *input)
{
	char *Buffer;
	int BuffSize, Result;

	BuffSize = WideCharToMultiByte(CP_UTF8, 0, input, -1, NULL, 0, NULL, NULL);
	Buffer = (char*) malloc(sizeof(char) * BuffSize);
	
	if(!Buffer)
	{
		fprintf(stderr, "Error in utf16_to_utf8: Memory allocation failed!\n");
		return NULL;
	}

	Result = WideCharToMultiByte(CP_UTF8, 0, input, -1, Buffer, BuffSize, NULL, NULL);
	return ((Result > 0) && (Result <= BuffSize)) ? Buffer : NULL;
}

////////////////////////////////////////////////////
// Checked fwrite
////////////////////////////////////////////////////
static void fwrite_checked(const void *data, size_t size, FILE* file, bool *errorFlag)
{
	if(fwrite(data, 1, size, file) != size)
	{
		*errorFlag = true;
	}
}

////////////////////////////////////////////////////
// Ctrl+C Handler
////////////////////////////////////////////////////
BOOL WINAPI CtrlHandlerRoutine(DWORD dwCtrlType)
{
	abortFlag = true;
	return TRUE;
}
