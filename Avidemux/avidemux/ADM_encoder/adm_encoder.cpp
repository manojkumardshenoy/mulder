/***************************************************************************
                          adm_encoder.cpp  -  description
                             -------------------
    begin                : Sun Jul 14 2002
    copyright            : (C) 2002 by mean
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
#include "config.h"

#include <time.h>
#include <sys/time.h>

#include "DIA_uiTypes.h"
#include "gui_action.hxx"
#ifdef USE_FFMPEG
#include "ADM_lavcodec.h"
#endif

#include "fourcc.h"
#include "avi_vars.h"

#include "ADM_assert.h"

#include "ADM_encoder/ADM_vidEncode.hxx"

#include "ADM_videoFilter.h"
#include "ADM_encoder/adm_encoder.h"

#ifdef USE_FFMPEG
#include "ADM_codecs/ADM_ffmpeg.h"
#include "ADM_encoder/adm_encffmpeg.h"
#endif

#ifdef USE_FFMPEG
#include "ADM_codecs/ADM_mjpegEncode.h"
#include "ADM_encoder/adm_encmjpeg.h"
#endif

#include "ADM_encoder/adm_encCopy.h"


static uint8_t nb_encoder = 0;



//----------------------------------
Encoder::~Encoder (void)
{
#define CLEAN(x) if(x) { delete [] x;x=NULL;}

  //CLEAN(_vbuffer);
  if (_vbuffer)
    delete _vbuffer;
  _vbuffer = NULL;
  CLEAN (entries);

}
//---------------------------------
void
register_Encoders (void)
{
  printf ("\n Registering Encoders\n");
  printf ("*********************\n");

#ifdef USE_FFMPEG
  nb_encoder++;
  printf ("MJPEG encoder registered\n");
#endif

#ifdef USE_FFMPEG
  nb_encoder++;
  printf ("FFmpeg encoder registered\n");
#endif

  printf ("\n%d encoder(s) registered\n", nb_encoder);
}
