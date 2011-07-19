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

#include "WmaReader.h"
#include "Utils.h"
#include <Wmsdk.h>

using namespace std;

typedef HRESULT (__stdcall *WMCreateSyncReaderProc)(IUnknown* pUnkCert, DWORD dwRights, IWMSyncReader **ppSyncReader);
typedef HRESULT (__stdcall *WMIsContentProtectedProc)(const WCHAR *pwszFileName, BOOL *pfIsProtected);

#define LOAD_LIBRARY_SEARCH_SYSTEM32 0x00000800
#define CHECK_MEDIA_TYPE(S,X,Y,T) if(X == Y) { wcscpy_s(S, size, L##T); }

CWmaReader::CWmaReader(void)
{
	m_isOpen = false;
	m_isAnalyzed = false;
	m_wmvCore = NULL;
	m_reader = NULL;
	m_outputNum = -1;
	m_streamNum = -1;

	m_wmvCore = LoadLibraryExW(L"wmvcore.dll", 0, LOAD_LIBRARY_SEARCH_SYSTEM32);
	if(!(m_wmvCore != NULL))
	{
		throw "Fatal Error: Failed to load WMVCORE.DLL libraray!";
	}
	
	WMCreateSyncReaderProc pWMCreateSyncReader = reinterpret_cast<WMCreateSyncReaderProc>(GetProcAddress(m_wmvCore, "WMCreateSyncReader"));	
	if(!(pWMCreateSyncReader != NULL))
	{
		throw "Fatal Error: Entry point 'WMCreateSyncReader' not be found!";
	}
	
	if(pWMCreateSyncReader(NULL, 0, &m_reader) != S_OK)
	{
		m_reader = NULL;
		throw "Fatal Error: Failed to create IWMSyncReader interface!";
	}
}

CWmaReader::~CWmaReader(void)
{
	if(m_reader)
	{
		m_reader->Release();
		m_reader = NULL;
	}
	if(m_wmvCore)
	{
		FreeLibrary(m_wmvCore);
		m_wmvCore = NULL;
	}
}

bool CWmaReader::isProtected(const wchar_t *filename)
{
	WMIsContentProtectedProc pWMIsContentProtected = reinterpret_cast<WMIsContentProtectedProc>(GetProcAddress(m_wmvCore, "WMIsContentProtected"));	

	if(!(pWMIsContentProtected != NULL))
	{
		return false;
	}

	BOOL flag = FALSE;
	bool isProtected = true;
		
	HRESULT result = pWMIsContentProtected(filename, &flag);

	switch(result)
	{
	case S_FALSE:
		isProtected = false;
		break;
	case S_OK:
		isProtected = (flag == TRUE);
		break;
	default:
		isProtected = false;
		break;
	}

	return isProtected;
}

bool CWmaReader::open(const wchar_t *filename)
{
	if(m_isOpen)
	{
		return false;
	}

	if(m_reader->Open(filename) == S_OK)
	{
		m_isOpen = true;
		m_isAnalyzed = false;
		return true;
	}

	return false;
}

void CWmaReader::close(void)
{
	if(m_isOpen)
	{
		m_reader->Close();
		m_isAnalyzed = false;
		m_isOpen = false;
	}
}

bool CWmaReader::analyze(WAVEFORMATEX *format)
{
	SecureZeroMemory(format, sizeof(WAVEFORMATEX));
	
	if((!m_isOpen) || m_isAnalyzed)
	{
		return false;
	}

	if(_findAudioStream(format))
	{
		DWORD outputNum = 0;
		
		if(m_reader->GetOutputNumberForStream(m_streamNum, &outputNum) == S_OK)
		{
			m_isAnalyzed = true;
			m_outputNum = outputNum;
			return true;
		}
	}

	return false;
}

bool CWmaReader::_findAudioStream(WAVEFORMATEX *format)
{
	bool foundAudioStream = false;
	IWMProfile *pIWMProfile = NULL;

	if(m_reader->QueryInterface(IID_IWMProfile, (void**)&pIWMProfile) == S_OK)
	{
		DWORD streamCount = 0;

		for(WORD i = 1; i < 64; i++)
		{
			IWMStreamConfig *pIWMStreamConfig = NULL;
		
			if(pIWMProfile->GetStreamByNumber(i, &pIWMStreamConfig) == S_OK)
			{
				GUID streamType = WMMEDIATYPE_Text;
				
				if(pIWMStreamConfig->GetStreamType(&streamType) == S_OK)
				{
					if(streamType == WMMEDIATYPE_Audio)
					{
						IWMMediaProps *pIWMMediaProps = NULL;

						if(pIWMStreamConfig->QueryInterface(IID_IWMMediaProps, (void**)&pIWMMediaProps) == S_OK)
						{
							DWORD mediaTypeSize = 0;

							if(pIWMMediaProps->GetMediaType(NULL, &mediaTypeSize) == S_OK)
							{
								char *buffer = new char[mediaTypeSize];
								WM_MEDIA_TYPE *mediaType = reinterpret_cast<WM_MEDIA_TYPE*>(buffer);
				
								if(pIWMMediaProps->GetMediaType(mediaType, &mediaTypeSize) == S_OK)
								{
									if(mediaType->formattype == WMFORMAT_WaveFormatEx)
									{
										m_streamNum = i;
										memcpy(format, mediaType->pbFormat, sizeof(WAVEFORMATEX));
										foundAudioStream = true;
									}
								}

								delete [] buffer;
							}
				
							pIWMMediaProps->Release();
							pIWMMediaProps = NULL;
						}
					}
				}

				pIWMStreamConfig->Release();
				pIWMStreamConfig = NULL;
			}

			if(foundAudioStream) break;
		}

		pIWMProfile->Release();
		pIWMProfile = NULL;
	}

	return foundAudioStream;
}

bool CWmaReader::configureOutput(WAVEFORMATEX *format)
{
	if(!(m_isOpen && m_isAnalyzed))
	{
		return false;
	}
	
	bool success = false;
	IWMOutputMediaProps *pIWMOutputMediaProps = NULL;
			
	if(format->nChannels > 2)
	{
		BOOL discreteOutput = TRUE;
		DWORD speakerCfg = 0x00000000; //DSSPEAKER_DIRECTOUT
		m_reader->SetOutputSetting(m_outputNum, g_wszEnableDiscreteOutput, WMT_TYPE_BOOL, (BYTE*)&discreteOutput, sizeof(BOOL));
		m_reader->SetOutputSetting(m_outputNum, g_wszSpeakerConfig, WMT_TYPE_DWORD, (BYTE*)&speakerCfg, sizeof(BOOL));
	}

	if(m_reader->GetOutputProps(m_outputNum, &pIWMOutputMediaProps) == S_OK)
	{
		DWORD mediaTypeSize = 0;

		if(pIWMOutputMediaProps->GetMediaType(NULL, &mediaTypeSize) == S_OK)
		{
			char *buffer =  new char[mediaTypeSize];
			WM_MEDIA_TYPE *mediaType = reinterpret_cast<WM_MEDIA_TYPE*>(buffer);
				
			if(pIWMOutputMediaProps->GetMediaType(mediaType, &mediaTypeSize) == S_OK)
			{
				if(mediaType->formattype == WMFORMAT_WaveFormatEx)
				{
					memcpy(mediaType->pbFormat, format, sizeof(WAVEFORMATEX));

					if(pIWMOutputMediaProps->SetMediaType(mediaType) == S_OK)
					{
						if(m_reader->SetOutputProps(m_outputNum, pIWMOutputMediaProps) == S_OK)
						{
							success = true;
						}
					}
				}
			}
				
			SAFE_DELETE_ARRAY(buffer)
		}
				
		pIWMOutputMediaProps->Release();
		pIWMOutputMediaProps = NULL;
	}

	return success;
}

bool CWmaReader::getOutputFormat(WAVEFORMATEX *format)
{
	SecureZeroMemory(format, sizeof(WAVEFORMATEX));

	if(!(m_isOpen && m_isAnalyzed))
	{
		return false;
	}

	bool success = false;
	IWMOutputMediaProps *pIWMOutputMediaProps = NULL;
			
	if(m_reader->GetOutputProps(m_outputNum, &pIWMOutputMediaProps) == S_OK)
	{
		DWORD mediaTypeSize = 0;

		if(pIWMOutputMediaProps->GetMediaType(NULL, &mediaTypeSize) == S_OK)
		{
			char *buffer =  new char[mediaTypeSize];
			WM_MEDIA_TYPE *mediaType = reinterpret_cast<WM_MEDIA_TYPE*>(buffer);
				
			if(pIWMOutputMediaProps->GetMediaType(mediaType, &mediaTypeSize) == S_OK)
			{
				if(mediaType->formattype == WMFORMAT_WaveFormatEx)
				{
					memcpy(format, mediaType->pbFormat, sizeof(WAVEFORMATEX));
					success = true;
				}
			}
				
			SAFE_DELETE_ARRAY(buffer)
		}
				
		pIWMOutputMediaProps->Release();
		pIWMOutputMediaProps = NULL;
	}

	return success;
}

double CWmaReader::getDuration(void)
{
	double duration = -1.0;

	if(!(m_isOpen && m_isAnalyzed))
	{
		return duration;
	}
	
	IWMHeaderInfo* pHdrInfo = NULL;
	
	if(m_reader->QueryInterface(IID_IWMHeaderInfo,(void**)&pHdrInfo) == S_OK)
	{
		WMT_ATTR_DATATYPE dType;
		WORD size = 0;
		WORD stream = 0; //m_streamNum

		if(pHdrInfo->GetAttributeByName(&stream, g_wszWMDuration, &dType, NULL, &size) == S_OK)
		{
			if((dType == WMT_TYPE_QWORD) && (size == sizeof(QWORD)))
			{
				BYTE pValue[sizeof(QWORD)];

				if(pHdrInfo->GetAttributeByName(&stream, g_wszWMDuration, &dType, (BYTE*)&pValue, &size) == S_OK)
				{
					duration = static_cast<double>((*reinterpret_cast<QWORD*>(pValue)) / 1000) / 10000.0;
				}
			}
		}
		
		pHdrInfo->Release();
		pHdrInfo = NULL;
	}

	return duration;
}

bool CWmaReader::getCodecInfo(wchar_t *codecName, wchar_t *codecInfo, size_t size)
{
	wcscpy_s(codecName, size, L"Unknown");
	wcscpy_s(codecInfo, size, L"Unknown");
	
	if(!(m_isOpen && m_isAnalyzed))
	{
		return false;
	}

	wchar_t *temp = NULL;
	IWMHeaderInfo2* pHdrInfo = NULL;
	bool foundInfo = false;
	
	if(m_reader->QueryInterface(IID_IWMHeaderInfo2,(void**)&pHdrInfo) == S_OK)
	{
		DWORD codecCount = 0;

		if(pHdrInfo->GetCodecInfoCount(&codecCount) == S_OK)
		{
			for(DWORD i = 0; i < codecCount; i++)
			{
				WORD sizeName = 0;
				WORD sizeDesc = 0;
				WORD sizeInfo = 0;
				WMT_CODEC_INFO_TYPE codecInfoType;

				if(pHdrInfo->GetCodecInfo(i, &sizeName, NULL, &sizeDesc, NULL, &codecInfoType, &sizeInfo, NULL) == S_OK)
				{
					if(codecInfoType == WMT_CODECINFO_AUDIO)
					{
						wchar_t *buffName = new wchar_t[sizeName];
						wchar_t *buffDesc = new wchar_t[sizeDesc];
						BYTE *buffInfo = new BYTE[sizeInfo];

						if(pHdrInfo->GetCodecInfo(i, &sizeName, buffName, &sizeDesc, buffDesc, &codecInfoType, &sizeInfo, buffInfo) == S_OK)
						{
							if(wcslen(buffName) > 0) wcscpy_s(codecName, size, buffName);
							if(wcslen(buffDesc) > 0) wcscpy_s(codecInfo, size, buffDesc);
							foundInfo = true;
						}

						SAFE_DELETE_ARRAY(buffName);
						SAFE_DELETE_ARRAY(buffDesc);
						SAFE_DELETE_ARRAY(buffInfo);
					}
				}
			}
		}
		
		pHdrInfo->Release();
		pHdrInfo = NULL;
	}

	return foundInfo;
}

bool CWmaReader::getTitle(wchar_t *title, size_t size)
{
	wcscpy_s(title, size, L"Unknown");
	
	if(!(m_isOpen && m_isAnalyzed))
	{
		return false;
	}
	
	IWMHeaderInfo* pHdrInfo = NULL;
	bool foundInfo = false;
	
	if(m_reader->QueryInterface(IID_IWMHeaderInfo,(void**)&pHdrInfo) == S_OK)
	{
		WMT_ATTR_DATATYPE dType;
		WORD attrSize = 0;
		WORD stream = 0; //m_streamNum;
		
		if(pHdrInfo->GetAttributeByName(&stream, g_wszWMTitle, &dType, NULL, &attrSize) == S_OK)
		{
			if((dType == WMT_TYPE_STRING))
			{
				size_t strLen = (attrSize / sizeof(wchar_t));
				
				if(strLen > 1)
				{
					wchar_t *temp = new wchar_t[strLen];
				
					if(pHdrInfo->GetAttributeByName(&stream, g_wszWMTitle, &dType, reinterpret_cast<BYTE*>(temp), &attrSize) == S_OK)
					{
						wcscpy_s(title, size, temp);
						foundInfo = true;
					}

					SAFE_DELETE_ARRAY(temp);
				}
			}
		}
		
		pHdrInfo->Release();
		pHdrInfo = NULL;
	}

	return foundInfo;
}

size_t CWmaReader::getSampleSize(void)
{
	DWORD streamMax = 0;
	DWORD outputMax = 0;
	
	if(m_reader->GetMaxOutputSampleSize(m_outputNum, &outputMax) == S_OK)
	{
		if(m_reader->GetMaxStreamSampleSize(m_streamNum, &streamMax) == S_OK)
		{
			return max(outputMax, streamMax);
		}
	}
	
	return 0;
}

bool CWmaReader::getNextSample(BYTE *output, size_t *length, double *timeStamp, double *sampleDuration)
{
	*length = 0;
	if(timeStamp) *timeStamp = -1.0;
	if(sampleDuration) *sampleDuration = -1.0;

	if(!(m_isOpen && m_isAnalyzed))
	{
		return false;
	}

	INSSBuffer *buffer = 0;
	QWORD time = 0;
	QWORD duration = 0;
	DWORD flags = 0;
	DWORD sampleOutputNo = 0;
	WORD sampleStreamNo = 0;
	DWORD bufferLen = 0;
	BYTE *bufferPtr;
	HRESULT result = 0;

	if((result = m_reader->GetNextSample(m_streamNum, &buffer, &time, &duration, &flags, &sampleOutputNo, &sampleStreamNo)) != S_OK)
	{
		return (result == NS_E_NO_MORE_SAMPLES) ? true : false;
	}

	if(buffer->GetLength(&bufferLen) != S_OK)
	{
		buffer->Release();
		return false;
	}

	if(buffer->GetBuffer(&bufferPtr) != S_OK)
	{
		buffer->Release();
		return false;
	}

	memcpy(output, bufferPtr, bufferLen);
	*length = bufferLen;
	
	if(timeStamp) *timeStamp = static_cast<double>(time / 1000) / 10000.0;
	if(sampleDuration) *sampleDuration = static_cast<double>(duration / 1000) / 10000.0;
	
	buffer->Release();
	buffer = NULL;
	
	return true;
}


	//DWORD outputCount = 0;

	//if(m_reader->GetOutputCount(&outputCount) != S_OK)
	//{
	//	return false;
	//}

	//bool foundAudioStream = false;

	//for(DWORD i = 0; i < outputCount; i++)
	//{
	//	if(foundAudioStream)
	//	{
	//		break;
	//	}
	//	
	//	IWMOutputMediaProps *props = NULL;
	//	
	//	if(m_reader->GetOutputProps(i, &props) == S_OK)
	//	{
	//		DWORD size = 0;

	//		if(props->GetMediaType(NULL, &size) == S_OK)
	//		{
	//			char *buffer =  new char[size];
	//			WM_MEDIA_TYPE *mediaType = reinterpret_cast<WM_MEDIA_TYPE*>(buffer);
	//			
	//			if(props->GetMediaType(mediaType, &size) == S_OK)
	//			{
	//				if(mediaType->formattype == WMFORMAT_WaveFormatEx)
	//				{
	//					WORD streamNum = -1;
	//					
	//					if(m_reader->GetStreamNumberForOutput(i, &streamNum) == S_OK)
	//					{
	//						if(m_reader->SetReadStreamSamples(streamNum, FALSE) == S_OK)
	//						{
	//							BOOL isCompressed = TRUE;
	//						
	//							if(m_reader->GetReadStreamSamples(streamNum, &isCompressed) == S_OK)
	//							{
	//								if(isCompressed == FALSE)
	//								{
	//									m_format = new WAVEFORMATEX;
	//									memcpy(m_format, mediaType->pbFormat, sizeof(WAVEFORMATEX));
	//									m_outputNum = i;
	//									m_streamNum = streamNum;
	//									memcpy(&m_mediaSubType, &(mediaType->subtype), sizeof(GUID));
	//									foundAudioStream = true;
	//								}
	//							}
	//						}
	//					}
	//				}
	//			}
	//			
	//			delete [] buffer;
	//		}

	//		props->Release();
	//		props = NULL;
	//	}
	//}

	//if(foundAudioStream)
	//{
	//	m_isAnalyzed = true;
	//}