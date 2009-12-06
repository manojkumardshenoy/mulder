/***************************************************************************
                          ADM_lpcm .cpp  -  description
                             -------------------

	Handle DVD LPCM, i.e. swapped PC PCM
    begin                : Fri May 5 2003
    copyright            : (C) 2003 by mean
    email                : fixounet@free.fr
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include "ADM_default.h"
#include <math.h>


#include "avifmt.h"
#include "avifmt2.h"
#include "ADM_audiocodec/ADM_audiocodec.h"


ADM_AudiocodecWavSwapped::ADM_AudiocodecWavSwapped( uint32_t fourcc ) : ADM_Audiocodec(fourcc)
{
	channelMapping[0] = CHTYP_FRONT_LEFT;
	channelMapping[1] = CHTYP_FRONT_RIGHT;
	channelMapping[2] = CHTYP_FRONT_CENTER;
	channelMapping[3] = CHTYP_LFE;
	channelMapping[4] = CHTYP_REAR_LEFT;
	channelMapping[5] = CHTYP_REAR_RIGHT;
}

ADM_AudiocodecWavSwapped::~ADM_AudiocodecWavSwapped()
{

}

uint8_t ADM_AudiocodecWavSwapped::beginDecompress()
{
         return 1;
}
uint8_t ADM_AudiocodecWavSwapped::endDecompress()
{
       return 1;
}

uint8_t ADM_AudiocodecWavSwapped::isCompressed( void )
{
 	return 1;
}

uint8_t ADM_AudiocodecWavSwapped::isDecompressable( void )
{
 	return 1;
}

uint8_t ADM_AudiocodecWavSwapped::run(uint8_t * inptr, uint32_t nbIn, float *outptr, uint32_t * nbOut)
{
	if (nbIn < 2)
		return 1;

	if (nbIn&1) {
		printf("Error: nbIn (%i) odd in lpcm", nbIn);
		abort();
	}

	int16_t sample;
	*nbOut=nbIn / 2;
	for (int i = 0; i < *nbOut; i++) {
		sample = (*inptr << 8 | *(inptr+1));
		*(outptr++) = (float)sample / 32768;
		inptr += 2;
	}

	return 1;
}

