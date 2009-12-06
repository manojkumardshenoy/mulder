/***************************************************************************
                          ADM_Video.cpp  -  description
                             -------------------
    begin                : Fri Apr 19 2002
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
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ADM_assert.h"
#include "config.h"
#include "ADM_editor/ADM_Video.h"
vidHeader::~vidHeader ()
{
  if (_name)
    delete[]_name;
  _name = NULL;
  if (_videoExtraLen)
    {
      delete[]_videoExtraData;
      _videoExtraData = NULL;
      _videoExtraLen = 0;
    }
  _name = NULL;

}

uint8_t vidHeader::getExtraHeaderData (uint32_t * len, uint8_t ** data)
{
  *len = _videoExtraLen;
  if (*len)
    {
      *data = _videoExtraData;
    }
  else
    *data = NULL;
  return 1;
}

vidHeader::vidHeader (void)
{
  _name = NULL;
  _videoExtraData = NULL;
  _videoExtraLen = 0;
// Clear headers
#define ADM_BZERO(x) memset(&x,0,sizeof(x));
    ADM_BZERO(_mainaviheader);
    ADM_BZERO(_audiostream);
    ADM_BZERO(_videostream);
}
uint32_t             vidHeader::ptsDtsDelta(uint32_t framenum)
{
  ADM_assert(0);
  return 0; 
}
uint32_t vidHeader::getTime (uint32_t frame)
{

  double
    one;
  one = 1. / _videostream.dwRate;
  one *= 1000;
  one *= _videostream.dwScale;
  one *= frame;

  return (uint32_t) floor (one);
}

//_______________________________________
// Get simplified information for gui
//
//_____________________________________
uint8_t vidHeader::getVideoInfo (aviInfo * info)
{
  double
    u,
    d;
  if (!_isvideopresent)
    return 0;

  info->width = _video_bih.biWidth;
  info->height = _video_bih.biHeight;
  info->nb_frames = _mainaviheader.dwTotalFrames;
  info->fcc = _videostream.fccHandler;
  info->bpp = _video_bih.biBitCount;
  u = _videostream.dwRate;
  u *= 1000.F;
  d = _videostream.dwScale;
  if (_videostream.dwScale)
    info->fps1000 = (uint32_t) floor (u / d);
  else
    info->fps1000 = 0;



  return 1;
}

uint8_t vidHeader::setMyName (const char *name)
{
  _name = new char[strlen (name) + 1];
  ADM_assert (_name);
  strcpy (_name, name);
  return 1;

}

char *
vidHeader::getMyName (void)
{
  return _name;
}

uint8_t vidHeader::getFrameSize (uint32_t frame, uint32_t * size)
{
  UNUSED_ARG (frame);
  UNUSED_ARG (size);
  return 0;
}

uint8_t vidHeader::getRawStart (uint8_t * ptr, uint32_t * len)
{
  UNUSED_ARG (ptr);
  *len = 0;
  return 1;
}
uint8_t                 vidHeader::getAudioStreamsInfo(uint32_t *nbStreams, audioInfo **infos)
{
WAVHeader *wav;

        *infos=NULL;
        *nbStreams=0;
        wav=getAudioInfo( );
        if(!wav) return 1;
        *nbStreams=1;
        *infos=new audioInfo[1];
        WAV2AudioInfo(wav,*infos);
        (*infos)->av_sync=0;
        return 1;

}
// By default we don't do that dave.
uint8_t                 vidHeader::changeAudioStream(uint32_t newstream)
{
        return 0;
}
//
