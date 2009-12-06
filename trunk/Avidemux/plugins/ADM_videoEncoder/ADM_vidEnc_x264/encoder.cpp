/***************************************************************************
                               x264Encoder.cpp

    begin                : Thu Apr 10 2008
    copyright            : (C) 2008 by gruntster
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <math.h>

#include "config.h"
#include "ADM_inttype.h"
#include "ADM_files.h"
#include "encoder.h"
#include "x264Options.h"

static x264Encoder encoder;
static void* encoders = { &encoder };
static int supportedCsps[] = { ADM_CSP_YV12 };

extern "C"
{
	void *encoders_getPointer(int uiType) { encoder.setUiType(uiType); return &encoders; }
	int x264Encoder_isConfigurable(void) { return encoder.isConfigurable(); }
	int x264Encoder_configure(vidEncConfigParameters *configParameters, vidEncVideoProperties *properties) { return encoder.configure(configParameters, properties); }
	int x264Encoder_getOptions(vidEncOptions *encodeOptions, char *pluginOptions, int bufferSize) { return encoder.getOptions(encodeOptions, pluginOptions, bufferSize); };
	int x264Encoder_setOptions(vidEncOptions *encodeOptions, char *pluginOptions) { return encoder.setOptions(encodeOptions, pluginOptions); };
	int x264Encoder_getPassCount(void) { return encoder.getPassCount(); }
	int x264Encoder_getCurrentPass(void) { return encoder.getCurrentPass(); }
	int x264Encoder_open(vidEncVideoProperties *properties) { return encoder.open(properties); }
	int x264Encoder_beginPass(vidEncPassParameters *passParameters) { return encoder.beginPass(passParameters); }
	int x264Encoder_encodeFrame(vidEncEncodeParameters *encodeParams) { return encoder.encodeFrame(encodeParams); }
	int x264Encoder_finishPass(void) { return encoder.finishPass(); }
	void x264Encoder_close(void) { encoder.close(); }
}

#ifdef __WIN32
extern void convertPathToAnsi(const char *path, char **ansiPath);
#endif

x264Encoder::x264Encoder(void)
{
	_loader = NULL;
	_handle = NULL;
	_opened = false;

	_passCount = 1;
	_currentPass = 0;
	_openPass = false;

	_buffer = NULL;
	_extraData = NULL;
	_extraDataSize = 0;

#if X264_BUILD < 76
	_seiUserData = NULL;
	_seiUserDataLen = 0;
#endif

	_encodeOptions.structSize = sizeof(vidEncOptions);
	_encodeOptions.encodeMode = DEFAULT_ENCODE_MODE;
	_encodeOptions.encodeModeParameter = DEFAULT_ENCODE_MODE_PARAMETER;

	memset(&_param, 0, sizeof(x264_param_t));
}

x264Encoder::~x264Encoder(void)
{
	close();

	if (_loader)
		delete _loader;

	if (_buffer)
		delete [] _buffer;

	if (_param.rc.zones)
		delete [] _param.rc.zones;
}

void x264Encoder::setUiType(int uiType)
{
	_uiType = uiType;
}

int x264Encoder::isConfigurable(void)
{
	return (_uiType == ADM_UI_GTK || _uiType == ADM_UI_QT4);
}

int x264Encoder::configure(vidEncConfigParameters *configParameters, vidEncVideoProperties *properties)
{
	if (_loader == NULL)
	{
		char* pluginPath = ADM_getPluginPath();
		const char* configGuiLibName;

		if (_uiType == ADM_UI_GTK)
			configGuiLibName = GTK_PLUGIN_NAME;
		else
			configGuiLibName = QT_PLUGIN_NAME;

		char* configGuiPath = new char[strlen(pluginPath) + 1 + strlen(PLUGIN_CONFIG_DIR) + 1 + strlen(PLUGIN_PREFIX) + strlen(configGuiLibName) + strlen(PLUGIN_SUFFIX) + 1];

		strcpy(configGuiPath, pluginPath);
		strcat(configGuiPath, PLUGIN_CONFIG_DIR);
		strcat(configGuiPath, "/");
		strcat(configGuiPath, PLUGIN_PREFIX);
		strcat(configGuiPath, configGuiLibName);
		strcat(configGuiPath, PLUGIN_SUFFIX);

		_loader = new configGuiLoader(configGuiPath);

		delete [] pluginPath;
		delete [] configGuiPath;
	}

	if (_loader->isAvailable())
		if (_loader->showX264ConfigDialog(configParameters, properties, &_encodeOptions, &_options))
		{
			updateEncodeParameters(NULL);

			return 1;
		}
	else
		return 0;
}

int x264Encoder::getOptions(vidEncOptions *encodeOptions, char *pluginOptions, int bufferSize)
{
	char* xml = _options.toXml(PLUGIN_XML_INTERNAL);
	int xmlLength = strlen(xml);

	if (bufferSize >= xmlLength)
	{
		memcpy(pluginOptions, xml, xmlLength);
		memcpy(encodeOptions, &_encodeOptions, sizeof(vidEncOptions));
	}
	else if (bufferSize != 0)
		xmlLength = 0;

	delete [] xml;

	return xmlLength;
}

int x264Encoder::setOptions(vidEncOptions *encodeOptions, char *pluginOptions)
{
	if (_opened)
		return ADM_VIDENC_ERR_ALREADY_OPEN;

	bool success = true;

	if (pluginOptions)
	{
		success = _options.fromXml(pluginOptions, PLUGIN_XML_INTERNAL);

		_options.loadPresetConfiguration();
	}

	if (encodeOptions && success)
	{
		memcpy(&_encodeOptions, encodeOptions, sizeof(vidEncOptions));
		updateEncodeParameters(NULL);
	}

	if (success)
		return ADM_VIDENC_ERR_SUCCESS;
	else
		return ADM_VIDENC_ERR_FAILED;
}

int x264Encoder::getCurrentPass(void)
{
	return _currentPass;
}

int x264Encoder::getPassCount(void)
{
	return _passCount;
}

int x264Encoder::open(vidEncVideoProperties *properties)
{
	if (_opened)
		return ADM_VIDENC_ERR_ALREADY_OPEN;

	_opened = true;
	_currentPass = 0;
	_bufferSize = (properties->width * properties->height) + 2 * ((properties->width + 1 >> 1) * (properties->height + 1 >> 1));
	_buffer = new uint8_t[_bufferSize];

	memcpy(&_properties, properties, sizeof(vidEncVideoProperties));
	updateEncodeParameters(&_properties);

	_param.i_width = _properties.width;
	_param.i_height = _properties.height;
	_param.i_fps_num = _properties.fpsNum;
	_param.i_fps_den = _properties.fpsDen;

	if (_options.getSarAsInput())
	{
		_param.vui.i_sar_width = _properties.parWidth;
		_param.vui.i_sar_height = _properties.parHeight;
	}

	if (properties->flags & ADM_VIDENC_FLAG_GLOBAL_HEADER)
		_param.b_repeat_headers = 0;
	else
		_param.b_repeat_headers = 1;

	properties->supportedCspsCount = 1;
	properties->supportedCsps = supportedCsps;

	printParam(&_param);

	return ADM_VIDENC_ERR_SUCCESS;
}

int x264Encoder::beginPass(vidEncPassParameters *passParameters)
{
	if (!_opened)
		return ADM_VIDENC_ERR_CLOSED;

	if (_openPass)
		return ADM_VIDENC_ERR_PASS_ALREADY_OPEN;

	if (_currentPass == _passCount)
		return ADM_VIDENC_ERR_PASS_COUNT_REACHED;

	if (_passCount > 1 && _currentPass == 0 && passParameters->useExistingLogFile)
	{
		_currentPass++;
		return ADM_VIDENC_ERR_PASS_SKIP;
	}

	_openPass = true;
	_currentPass++;
	_currentFrame = 0;

	char *logFileName = NULL;

	printf("[x264] begin pass %d/%d\n", _currentPass, _passCount);

	if (_passCount > 1)
	{
#ifdef __WIN32
		convertPathToAnsi(passParameters->logFileName, &logFileName);
#else
		logFileName = new char[strlen(passParameters->logFileName) + 1];
		strcpy(logFileName, passParameters->logFileName);
#endif

		if (_currentPass == 1)
		{
			_param.rc.b_stat_write = 1;
			_param.rc.b_stat_read = 0;
			_param.rc.psz_stat_out = logFileName;

			printf("[x264] writing to %s\n", logFileName);
		}
		else
		{
			_param.rc.b_stat_write = 0;
			_param.rc.b_stat_read = 1;
			_param.rc.psz_stat_in = logFileName;

			printf("[x264] reading from %s\n", logFileName);
		}
	}
	else
	{
		_param.rc.b_stat_write = 0;
		_param.rc.b_stat_read = 0;
	}

	_handle = x264_encoder_open(&_param);

	if (logFileName)
		delete [] logFileName;

	if (_handle)
	{
		if (!_param.b_repeat_headers)
		{
			if (createHeader())
			{
				passParameters->extraData = _extraData;
				passParameters->extraDataSize = _extraDataSize;
			}
			else
				return ADM_VIDENC_ERR_FAILED;
		}

		return ADM_VIDENC_ERR_SUCCESS;
	}
	else
		return ADM_VIDENC_ERR_FAILED;
}

int x264Encoder::encodeFrame(vidEncEncodeParameters *encodeParams)
{
	if (!_opened)
		return ADM_VIDENC_ERR_CLOSED;

	x264_nal_t *nal;
	int nalCount = 0;
	x264_picture_t picture_out;

	memset(&_picture, 0, sizeof(x264_picture_t));

	if (encodeParams->frameData[0])
	{
		_picture.img.plane[0] = encodeParams->frameData[0];
		_picture.img.plane[1] = encodeParams->frameData[1];
		_picture.img.plane[2] = encodeParams->frameData[2];
		_picture.img.i_stride[0] = encodeParams->frameLineSize[0];
		_picture.img.i_stride[1] = encodeParams->frameLineSize[1];
		_picture.img.i_stride[2] = encodeParams->frameLineSize[2];
		_picture.i_type = X264_TYPE_AUTO;
		_picture.i_pts = _currentFrame;
		_picture.img.i_csp = X264_CSP_YV12;
		_picture.img.i_plane = 3;
	}

#if X264_BUILD > 75
	int size = x264_encoder_encode(_handle, &nal, &nalCount, encodeParams->frameData[0] ? &_picture : NULL, &picture_out);

	if (size > 0)
	{
		memcpy(_buffer, nal->p_payload, size);
	}
	else if (size < 0)
	{
		printf("[x264] Error encoding\n");
		return ADM_VIDENC_ERR_FAILED;
	}

	encodeParams->encodedDataSize = size;
#else
	if (x264_encoder_encode(_handle, &nal, &nalCount, encodeParams->frameData[0] ? &_picture : NULL, &picture_out) < 0)
	{
		printf("[x264] Error encoding\n");
		return ADM_VIDENC_ERR_FAILED;
	}

	int size = 0;
	int currentNal, sizemax;

	for (int i = 0; i < nalCount; i++)
	{
		sizemax = 0xfffffff;

		if (!_param.b_repeat_headers)
			size += 4;

		currentNal = x264_nal_encode(_buffer + size, &sizemax, _param.b_repeat_headers, &nal[i]);

		if (!_param.b_repeat_headers)
		{
			// Need to put size (assuming nal_size=4)
			_buffer[size + 0 - 4] = (currentNal >> 24) & 0xff;
			_buffer[size + 1 - 4] = (currentNal >> 16) & 0xff;
			_buffer[size + 2 - 4] = (currentNal >> 8) & 0xff;
			_buffer[size + 3 - 4] = (currentNal >> 0) & 0xff;
		}

		size += currentNal;
	}

	encodeParams->encodedDataSize = size;
#endif

	_currentFrame++;
	encodeParams->ptsFrame = picture_out.i_pts;	// In fact it is the picture number in out case

	switch (picture_out.i_type)
	{
		case X264_TYPE_IDR:
			encodeParams->frameType = ADM_VIDENC_FRAMETYPE_IDR;
#if X264_BUILD < 76
			if(!_param.b_repeat_headers && _seiUserData && !picture_out.i_pts)
			{
				// Put our SEI front...
				// first a temp location...
				uint8_t tmpBuffer[size];
				memcpy(tmpBuffer, _buffer, size);

				// Put back out SEI and add Size
				_buffer[0] = (_seiUserDataLen >> 24) & 0xff;
				_buffer[1] = (_seiUserDataLen >> 16) & 0xff;
				_buffer[2] = (_seiUserDataLen >> 8) & 0xff;
				_buffer[3] = (_seiUserDataLen >> 0) & 0xff;

				memcpy(_buffer + 4, _seiUserData, _seiUserDataLen);
				memcpy(_buffer + 4 + _seiUserDataLen, tmpBuffer, size);

				size += 4 + _seiUserDataLen;
				encodeParams->encodedDataSize = size; // update total size
			}
#endif

			break;
		case X264_TYPE_I:
		case X264_TYPE_P:
			encodeParams->frameType = ADM_VIDENC_FRAMETYPE_P;
			break;
		case X264_TYPE_B:
		case X264_TYPE_BREF:
			encodeParams->frameType = ADM_VIDENC_FRAMETYPE_B;
			break;
		default:
			encodeParams->frameType = ADM_VIDENC_FRAMETYPE_NULL;
	}

	encodeParams->quantiser = picture_out.i_qpplus1 - 1;
	encodeParams->encodedData = _buffer;

	return ADM_VIDENC_ERR_SUCCESS;
}

bool x264Encoder::createHeader(void)
{
	x264_nal_t *nal;
	int nalCount;

	if (!_handle)
		return false;

	if (_extraData)
		delete _extraData;

#if X264_BUILD > 75
	_extraDataSize = x264_encoder_headers(_handle, &nal, &nalCount);
	_extraData = new uint8_t[_extraDataSize];
	memcpy(_extraData, nal->p_payload, _extraDataSize);
#else
	uint32_t offset = 0;
	uint8_t buffer[X264_MAX_HEADER_SIZE];
	uint8_t picParam[X264_MAX_HEADER_SIZE];
	uint8_t seqParam[X264_MAX_HEADER_SIZE];
	uint8_t sei[X264_MAX_HEADER_SIZE];
	int picParamLen = 0, seqParamLen = 0, seiParamLen = 0, len;
	int sz;

	_extraData = new uint8_t[X264_MAX_HEADER_SIZE];
	_extraDataSize = 0;

	x264_encoder_headers(_handle, &nal, &nalCount);

	printf("[x264] Nal count: %d\n", nalCount);

	// Now encode them
	for (int i = 0; i < nalCount; i++)
	{
		switch (nal[i].i_type)
		{
		case H264_NAL_TYPE_SEQ_PARAM:
			sz = x264_nal_encode(seqParam, &seqParamLen, 0, &nal[i]);
			break;
		case H264_NAL_TYPE_PIC_PARAM:
			sz = x264_nal_encode(picParam, &picParamLen, 0, &nal[i]);
			break;
		case H264_NAL_TYPE_SEI:
			sz = x264_nal_encode(sei, &seiParamLen, 0, &nal[i]);
			break;
		default:
			printf("[x264] Unknown type %d in nal %d\n", nal[i].i_type, i);
			sz = x264_nal_encode(buffer, &len, 0, &nal[i]);
		}

		if (sz <= 0)
		{
			printf("[x264] Cannot encode nal header %d\n", i);

			return false;
		}
	}

	// Now that we got all the nals encoded, time to build the avcC atom
	// Check we have everything we want
	if (!picParamLen || !seqParamLen)
	{
		printf("[x264] Seqparam or PicParam not found\n");
		return false;
	}

	// Fill header
	_extraData[0] = 1;		// Version
	_extraData[1] = seqParam[1];	//0x42; // AVCProfileIndication
	_extraData[2] = seqParam[2];	//0x00; // profile_compatibility
	_extraData[3] = seqParam[3];	//0x0D; // AVCLevelIndication
	_extraData[4] = 0xFC + 3;	// lengthSizeMinusOne 
	_extraData[5] = 0xE0 + 1;	// nonReferenceDegredationPriorityLow

	offset = 6;
	_extraData[offset] = seqParamLen >> 8;
	_extraData[offset + 1] = seqParamLen & 0xff;

	offset += 2;
	memcpy(_extraData + offset, seqParam, seqParamLen);

	offset += seqParamLen;
	_extraData[offset] = 1;	// numOfPictureParameterSets

	offset++;
	_extraData[offset] = picParamLen >> 8;
	_extraData[offset + 1] = picParamLen & 0xff;

	offset += 2;
	memcpy(_extraData + offset, picParam, picParamLen);

	offset += picParamLen;

	// Where x264 stores all its header, save it for later use
	if (seiParamLen) 
	{
		_seiUserDataLen = seiParamLen;
		_seiUserData = new uint8_t[_seiUserDataLen];
		memcpy(_seiUserData, sei, _seiUserDataLen);
	}

	_extraDataSize = offset;
#endif

	printf("[x264] generated %d extra bytes for header\n", _extraDataSize);

	return true;
}

int x264Encoder::finishPass(void)
{
	if (!_opened)
		return ADM_VIDENC_ERR_CLOSED;

	if (_handle)
	{
		x264_encoder_close(_handle);
		_handle = NULL;
	}

	if (_openPass)
		_openPass = false;

	if (_extraData)
	{
		delete [] _extraData;
		_extraData = NULL;
		_extraDataSize = 0;
	}

#if X264_BUILD < 76
	if (_seiUserData)
	{
		delete [] _seiUserData;
		_seiUserData = NULL;
		_seiUserDataLen = 0;
	}
#endif

	return ADM_VIDENC_ERR_SUCCESS;
}

void x264Encoder::close(void)
{
	if (_openPass)
		finishPass();

	_opened = false;
	_currentPass = 0;

	if (_buffer)
	{
		delete [] _buffer;
		_buffer = NULL;
	}
}

void x264Encoder::printParam(x264_param_t *x264Param)
{
	printf("[x264] b_repeat_headers = %d\n", x264Param->b_repeat_headers);
	printf("[x264] i_log_level = %d\n", x264Param->i_log_level);
	printf("[x264] i_threads = %d", x264Param->i_threads);

	if (x264Param->i_threads == 0)
		printf (" (auto)");
	if (x264Param->i_threads == 1)
		printf (" (disabled)");

	printf("\n[x264] i_width = %d, i_height = %d\n", x264Param->i_width, x264Param->i_height);
	printf("[x264] i_csp = %d\n", x264Param->i_csp);	
	printf("[x264] i_fps_num = %d, i_fps_den = %d\n", x264Param->i_fps_num, x264Param->i_fps_den);
	printf("[x264] rc.i_rc_method = %d\n", x264Param->rc.i_rc_method);
	printf("[x264] rc.i_bitrate = %d\n", x264Param->rc.i_bitrate);
	printf("[x264] rc.f_rf_constant = %f\n", x264Param->rc.f_rf_constant);
	printf("[x264] rc.i_qp_constant = %d\n", x264Param->rc.i_qp_constant);	
	printf("[x264] analyse.i_subpel_refine = %d\n", x264Param->analyse.i_subpel_refine);
	printf("[x264] analyse.i_me_method = %d\n", x264Param->analyse.i_me_method);
	printf("[x264] analyse.i_me_range = %d\n", x264Param->analyse.i_me_range);
	printf("[x264] analyse.i_mv_range = %d\n", x264Param->analyse.i_mv_range);
	printf("[x264] analyse.i_mv_range_thread = %d\n", x264Param->analyse.i_mv_range_thread);
	printf("[x264] analyse.i_direct_mv_pred = %d\n", x264Param->analyse.i_direct_mv_pred);
	printf("[x264] analyse.b_weighted_bipred = %d\n", x264Param->analyse.b_weighted_bipred);
	printf("[x264] analyse.b_transform_8x8 = %d\n", x264Param->analyse.b_transform_8x8);
	printf("[x264] analyse.inter = %d\n", x264Param->analyse.inter);
	printf("[x264] b_cabac = %d\n", x264Param->b_cabac);
	printf("[x264] b_interlaced = %d\n", x264Param->b_interlaced);
	printf("[x264] b_deblocking_filter = %d\n", x264Param->b_deblocking_filter);
	printf("[x264] i_deblocking_filter_alphac0 = %d\n", x264Param->i_deblocking_filter_alphac0);
	printf("[x264] i_deblocking_filter_beta = %d\n", x264Param->i_deblocking_filter_beta);
	printf("[x264] i_bframe = %d\n", x264Param->i_bframe);
	printf("[x264] i_bframe_bias = %d\n", x264Param->i_bframe_bias);
	printf("[x264] i_frame_reference = %d\n", x264Param->i_frame_reference);
#if X264_BUILD >= 78
	printf("[x264] i_bframe_pyramid = %d\n", x264Param->i_bframe_pyramid);
#else
	printf("[x264] b_bframe_pyramid = %d\n", x264Param->b_bframe_pyramid);
#endif
	printf("[x264] i_bframe_adaptive = %d\n", x264Param->i_bframe_adaptive);
	printf("[x264] i_keyint_max = %d\n", x264Param->i_keyint_max);
	printf("[x264] i_keyint_min = %d\n", x264Param->i_keyint_min);
	printf("[x264] i_scenecut_threshold = %d\n", x264Param->i_scenecut_threshold);
	printf("[x264] analyse.b_mixed_references = %d\n", x264Param->analyse.b_mixed_references);
	printf("[x264] analyse.b_chroma_me = %d\n", x264Param->analyse.b_chroma_me);
	printf("[x264] analyse.i_trellis = %d\n", x264Param->analyse.i_trellis);
	printf("[x264] analyse.b_fast_pskip = %d\n", x264Param->analyse.b_fast_pskip);
	printf("[x264] analyse.b_dct_decimate = %d\n", x264Param->analyse.b_dct_decimate);
	printf("[x264] analyse.i_noise_reduction = %d\n", x264Param->analyse.i_noise_reduction);
	printf("[x264] analyse.i_luma_deadzone[0] = %d\n", x264Param->analyse.i_luma_deadzone[0]);
	printf("[x264] analyse.i_luma_deadzone[1] = %d\n", x264Param->analyse.i_luma_deadzone[1]);
	printf("[x264] i_cqm_preset = %d\n", x264Param->i_cqm_preset);

	printf("[x264] cqm_4iy = ");
	printCqm(x264Param->cqm_4iy, sizeof(x264Param->cqm_4iy));
	printf("\n[x264] cqm_4ic = ");
	printCqm(x264Param->cqm_4ic, sizeof(x264Param->cqm_4ic));
	printf("\n[x264] cqm_4py = ");
	printCqm(x264Param->cqm_4py, sizeof(x264Param->cqm_4py));
	printf("\n[x264] cqm_4pc = ");
	printCqm(x264Param->cqm_4pc, sizeof(x264Param->cqm_4pc));
	printf("\n[x264] cqm_8iy = ");
	printCqm(x264Param->cqm_8iy, sizeof(x264Param->cqm_8iy));
	printf("\n[x264] cqm_8py = ");
	printCqm(x264Param->cqm_8py, sizeof(x264Param->cqm_8py));

	printf("\n[x264] rc.i_qp_min = %d\n", x264Param->rc.i_qp_min);
	printf("[x264] rc.i_qp_max = %d\n", x264Param->rc.i_qp_max);
	printf("[x264] rc.i_qp_step = %d\n", x264Param->rc.i_qp_step);
	printf("[x264] rc.f_rate_tolerance = %f\n", x264Param->rc.f_rate_tolerance);
	printf("[x264] rc.f_ip_factor = %f\n", x264Param->rc.f_ip_factor);
	printf("[x264] rc.f_pb_factor = %f\n", x264Param->rc.f_pb_factor);
	printf("[x264] analyse.i_chroma_qp_offset = %d\n", x264Param->analyse.i_chroma_qp_offset);
	printf("[x264] rc.f_qcompress = %f\n", x264Param->rc.f_qcompress);
	printf("[x264] rc.f_complexity_blur = %f\n", x264Param->rc.f_complexity_blur);
	printf("[x264] rc.f_qblur = %f\n", x264Param->rc.f_qblur);
	printf("[x264] rc.i_vbv_max_bitrate = %d\n", x264Param->rc.i_vbv_max_bitrate);
	printf("[x264] rc.i_vbv_buffer_size = %d\n", x264Param->rc.i_vbv_buffer_size);
	printf("[x264] rc.f_vbv_buffer_init = %f\n", x264Param->rc.f_vbv_buffer_init);
	printf("[x264] rc.i_zones = %d\n", x264Param->rc.i_zones);

	printf("[x264] i_level_idc = %d\n", x264Param->i_level_idc);
	printf("[x264] i_sps_id = %d\n", x264Param->i_sps_id);
	printf("[x264] b_deterministic = %d\n", x264Param->b_deterministic);
	printf("[x264] b_aud = %d\n", x264Param->b_aud);
	printf("[x264] vui.i_overscan = %d\n", x264Param->vui.i_overscan);
	printf("[x264] vui.i_vidformat = %d\n", x264Param->vui.i_vidformat);
	printf("[x264] vui.i_colorprim = %d\n", x264Param->vui.i_colorprim);
	printf("[x264] vui.i_transfer = %d\n", x264Param->vui.i_transfer);
	printf("[x264] vui.i_colmatrix = %d\n", x264Param->vui.i_colmatrix);
	printf("[x264] vui.i_chroma_loc = %d\n", x264Param->vui.i_chroma_loc);
	printf("[x264] vui.b_fullrange = %d\n", x264Param->vui.b_fullrange);
}

void x264Encoder::printCqm(const uint8_t cqm[], int size)
{
	for (int index = 0; index < size; index++)
		printf("%d ", cqm[index]);
}

void x264Encoder::updateEncodeParameters(vidEncVideoProperties *properties)
{
	x264_param_t *param = _options.getParameters();

	memcpy(&_param, param, sizeof(x264_param_t));
	delete param;

	switch (_encodeOptions.encodeMode)
	{
		case ADM_VIDENC_MODE_CBR:
			_passCount = 1;
			_param.rc.i_rc_method = X264_RC_ABR;
			_param.rc.i_bitrate = _encodeOptions.encodeModeParameter;
			break;
		case ADM_VIDENC_MODE_CQP:
			_passCount = 1;
			_param.rc.i_rc_method = X264_RC_CQP;
			_param.rc.i_qp_constant = _encodeOptions.encodeModeParameter;
			break;
		case ADM_VIDENC_MODE_AQP:
			_passCount = 1;
			_param.rc.i_rc_method = X264_RC_CRF;
			_param.rc.f_rf_constant = _encodeOptions.encodeModeParameter;
			break;
		case ADM_VIDENC_MODE_2PASS_SIZE:
			_passCount = 2;
			_param.rc.i_rc_method = X264_RC_ABR;

			if (properties)
				_param.rc.i_bitrate = calculateBitrate(properties->fpsNum, properties->fpsDen, properties->frameCount, _encodeOptions.encodeModeParameter) / 1000;
			else
				_param.rc.i_bitrate = 1500;

			break;
		case ADM_VIDENC_MODE_2PASS_ABR:
			_passCount = 2;
			_param.rc.i_rc_method = X264_RC_ABR;
			_param.rc.i_bitrate = _encodeOptions.encodeModeParameter;
			break;
	}
}

unsigned int x264Encoder::calculateBitrate(unsigned int fpsNum, unsigned int fpsDen, unsigned int frameCount, unsigned int sizeInMb)
{
	double db, ti;

	db = sizeInMb;
	db = db * 1024. * 1024. * 8.;
	// now db is in bits

	// compute duration
	ti = frameCount;
	ti *= fpsDen;
	ti /= fpsNum;	// nb sec
	db = db / ti;

	return (unsigned int)floor(db);
}
