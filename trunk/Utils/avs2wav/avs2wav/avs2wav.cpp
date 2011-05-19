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

static const char* versionTag = "v1.1";

using namespace std;

////////////////////////////////////////////////////
// Application Entry Point
////////////////////////////////////////////////////
int _tmain(int argc, _TCHAR* argv[])
{
	//Print version info and credits
	cerr << "avs2wav " << versionTag << " [" << __DATE__ << "]" << endl;
	cerr << "by Jory Stone <jcsston@toughguy.net>, LoRd_MuldeR <mulder2@gmx.de>" << endl;
	cerr << endl;

	//Init global vars
	memset(&g_aviStreamInfo, 0, sizeof(AVISTREAMINFO));

	//Check arguments
	if(argc < 3)
	{
		cerr << "Usage:" << endl;
		cerr << "  avs2wav.exe <input.avs> <output.wav>" << endl;
		cerr << endl;
		return -1;
	}
		
	//Set input/output files
	_TCHAR *inputFilename = argv[1];
	_TCHAR *outputFilename = argv[2];
	
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

	//Open input file
	if(!avs2wav_openSource(inputFilename))
	{
		cerr << "Failed to open input file. Terminating!" << endl;
		AVIFileExit();
		return -2;
	}

	//Open output file
	if(!avs2wav_openOutput(outputFilename))
	{
		cerr << "Failed to open output file. Terminating!" << endl;
		AVIFileRelease(g_aviFile);
		AVIFileExit();
		return -3;
	}

	//Dump the audio stream
	LONG status = 0;
	LONG iterator = 0;
	cerr << endl;
	while(avs2wav_dumpStream(&status))
	{
		if(!iterator)
		{
			double progress = static_cast<double>(g_currentframeSample) / static_cast<double>(g_streamSampleLength);
			fprintf(stderr, "\rDumping audio data, please wait: %ld/%ld [%d%%]", g_currentframeSample, g_streamSampleLength, static_cast<int>(progress * 100.0));
			cerr << flush;
		}
		iterator = (iterator + 1) % 512;
	}

	if(status)
	{
		cerr << "Failed to dump audio stream. Terminating!" << endl;
		fclose(g_outputFile);
		AVIFileRelease(g_aviFile);
		AVIFileExit();
		return -4;
	}

	//Complete
	fprintf(stderr, "\rDumping audio data, please wait: %ld/%ld [%d%%]\n", g_streamSampleLength, g_streamSampleLength, 100);
	cerr << "All samples have been dumped." << endl;

	//Close output
	avs2wav_closeOutput();
		
	//Final Cleanup
	if(g_wavHeader) delete g_wavHeader;
	if(g_frameBuffer) delete [] g_frameBuffer;
	AVIFileRelease(g_aviFile);
	AVIFileExit();

	return 0;
}

////////////////////////////////////////////////////
// Open input file
////////////////////////////////////////////////////
bool avs2wav_openSource(_TCHAR *inputFilename)
{	
	HRESULT success = 0;
	FILE *readTest = NULL;

	wcerr << "Analyzing input file... " << flush;

	if(_wfopen_s(&readTest,inputFilename, L"r"))
	{
		wcerr << "Failed" << endl;
		wcerr << "File does not exist or cannot be opened for reading:" << endl;
		wcerr << inputFilename << endl << endl;
		return false;
	}
	
	fclose(readTest);
	readTest = NULL;

	//Open AVI file
	success = AVIFileOpen(&g_aviFile, inputFilename, OF_SHARE_DENY_WRITE | OF_READ, 0L);
	if(success != AVIERR_OK)
	{
		wcerr << "Failed" << endl;
		wcerr << "AVIFileOpen failed, unable to open file:" << endl;
		wcerr << inputFilename << endl << endl;
		return false;
	}

	bool foundAudioStream = false;

	//Find audio stream
	for(LONG streamIdx = 0; streamIdx < LONG_MAX; streamIdx++)
	{		
		success = AVIFileGetStream(g_aviFile, &g_aviStream, streamtypeAUDIO, streamIdx);
		if(success != AVIERR_OK)
		{
			if (!streamIdx)
			{
				wcerr << "Failed" << endl;
				wcerr << "AVIFileGetStream failed, unable to get any streams!" << endl;
			}
			break;
		}		

		success = AVIStreamInfo(g_aviStream, &g_aviStreamInfo, sizeof(AVISTREAMINFO));
		if(success != AVIERR_OK)
		{
			wcerr << "Failed" << endl;
			wcerr << "AVIStreamInfo failed, unable to get stream info!" << endl;
			break;
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
				wcerr << "Failed" << endl;
				wcerr << "AVIStreamReadFormat failed!" << endl;
				break;
			}

			foundAudioStream = true;
			g_streamSampleLength = AVIStreamLength(g_aviStream);
			break;
		}
	}

	//Check if audio stream is avialble
	if(!foundAudioStream)
	{
		AVIFileRelease(g_aviFile);
		g_aviFile = NULL;
		wcerr << "Failed" << endl;
		wcerr << "Could not find any Audio Stream in the input!" << endl;
		return false;
	}
	
	wcerr << "Done" << endl;
	return true;
}

////////////////////////////////////////////////////
// Open output file
////////////////////////////////////////////////////
bool avs2wav_openOutput(_TCHAR *outputFilename)
{
	wcerr << "Opening output file... " << flush;
	
	//Check if output file was opened
	if(_wfopen_s(&g_outputFile, outputFilename, L"wb+"))
	{
		wcerr << "Failed" << endl;
		wcerr << "FOpen failed, unable to open output file:" << endl;
		wcerr << outputFilename << endl << endl;
		return false;
	}

	// Init local vars
	WAVEFORMATEX wavHeader;
	DWORD dwTemp = 0;
	WORD wTemp = 0;
	BYTE bTemp = 0;;
	
	// Copy header
	memcpy(&wavHeader, g_wavHeader, sizeof(WAVEFORMATEX));
	wavHeader.cbSize = 0;

	// Write the base header
	fwrite("RIFF", 1, 4, g_outputFile);
	dwTemp = g_streamSampleLength * wavHeader.nBlockAlign + 450;
	fwrite(&dwTemp, 1, 4, g_outputFile);
	fwrite("WAVE", 1, 4, g_outputFile);

	// Format chunk header
	fwrite("fmt ", 1, 4, g_outputFile);
	// Size of the chunk
	dwTemp = 0x10;
	fwrite(&dwTemp, 1, 4, g_outputFile);
	// Format Tag
	wTemp = g_wavHeader->wFormatTag;
	fwrite(&wTemp, 1, 2, g_outputFile);
	// Channel count
	wTemp = g_wavHeader->nChannels;
	fwrite(&wTemp, 1, 2, g_outputFile);
	// Sample Rate
	dwTemp = g_wavHeader->nSamplesPerSec;
	fwrite(&dwTemp, 1, 4, g_outputFile);
	// Bytes Per Second
	dwTemp = g_wavHeader->nAvgBytesPerSec;
	fwrite(&dwTemp, 1, 4, g_outputFile);
	// Bytes Per Sample (all chanels)
	wTemp = g_wavHeader->nBlockAlign;
	fwrite(&wTemp, 1, 2, g_outputFile);
	// Bits Per Sample (per channel)
	wTemp = g_wavHeader->wBitsPerSample;
	fwrite(&wTemp, 1, 2, g_outputFile);

	fwrite("data", 1, 4, g_outputFile);
	g_dataSizePos = ftell(g_outputFile);
	dwTemp = g_dataSizePos * wavHeader.nBlockAlign;
	fwrite(&dwTemp, 1, 4, g_outputFile);
	
	// Reserve space for the data chunk size
	// fwrite("    ", 1, 4, m_OutputFile);
	
	wcerr << "Done" << endl;
	return true;
};

////////////////////////////////////////////////////
// Close output file
////////////////////////////////////////////////////
bool avs2wav_closeOutput(void)
{
	if(!g_outputFile)
	{
		return false;
	}

	fseek(g_outputFile, g_dataSizePos, SEEK_SET);
	fwrite(&g_dataSize, 1, 4, g_outputFile);
	g_dataSize += g_dataSizePos - 8;
	fseek(g_outputFile, 4, SEEK_SET);
	fwrite(&g_dataSize, 1, 4, g_outputFile);
	
	fclose(g_outputFile);
	g_outputFile = NULL;
	
	return true;
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
		*status = 0;
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
			wcerr << endl << "Memory allocation has failed!" << endl;
			g_frameBuffer = NULL;
			*status = -2;
			return false;
		}
	}				

	//Fetch the data
	result = AVIStreamRead(g_aviStream, g_currentframeSample, AVISTREAMREAD_CONVENIENT, g_frameBuffer, g_frameBufferSize, &bytesRead, &samplesRead);

	//Check if successfull
	if (result != AVIERR_OK)
	{
		wcerr << endl << "AVIStreamRead returned error!" << endl;
		*status = -1;
		return false;
	}
	
	//Increase sample position
	if(samplesRead > 0)
	{
		g_currentframeSample += samplesRead;
	}

	//Write to output file
	if(bytesRead > 0)
	{
		if(size_t size = fwrite(g_frameBuffer, 1, bytesRead, g_outputFile))
		{
			g_dataSize += size;
		}
	}

	*status = 1;
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