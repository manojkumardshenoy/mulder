/***************************************************************************
    copyright            : (C) 2006 by mean
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

#include <stdio.h>
#include <stdlib.h>

#include <string.h>

#include <math.h>

#include "ADM_default.h"
#include "ADM_editor/ADM_Video.h"
#include "ADM_assert.h"

#include "fourcc.h"


#include "ADM_mkv.h"

#include "mkv_tags.h"

class entryDesc
{
  public:
          uint32_t     trackNo;
          uint32_t     trackType;
          uint32_t     extraDataLen;

          uint32_t fcc;
          uint32_t w,h,fps;
          uint32_t fq,chan,bpp;
          uint32_t defaultDuration;
          float    trackScale;
          uint8_t *extraData;

          void dump(void);
};
/* Prototypes */
static uint8_t entryWalk(ADM_ebml_file *head,uint32_t headlen,entryDesc *entry);
uint32_t ADM_mkvCodecToFourcc(const char *codec);
/**
    \fn entryDesc::dump
    \brief Dump the track entry
*/
void entryDesc::dump(void)
{
      printf("*** TRACK SUMMARY **\n");
#define PRINT(x) printf(#x" :%u\n",x)
      PRINT(trackNo);
      switch(trackType)
      {
        case 1: // Video
          PRINT(trackType);
          printf("==>Video\n");
          PRINT(extraDataLen);
          PRINT(fcc);
          PRINT(w);
          PRINT(h);
          PRINT(fps);
          break;
        case 2: // Video
          printf("==>Audio\n");
          PRINT(extraDataLen);
          PRINT(fcc);
          PRINT(fq);
          PRINT(chan);
          PRINT(bpp);
          break;
        default:
          printf("Unkown track type (%d)\n",trackType);
      }
}

/**
      \fn analyzeOneTrack
      \brief Grab info about the track (it is a recursive function !)

*/
uint8_t mkvHeader::analyzeOneTrack(void *head,uint32_t headlen)
{

entryDesc entry;
      memset(&entry,0,sizeof(entry));
      /* Set some defaults value */

      entry.chan=2;

      entryWalk(  (ADM_ebml_file *)head,headlen,&entry);
      entry.dump();
      if(entry.trackType==1 &&  !_isvideopresent)
      {
        _isvideopresent=1;
        if(entry.defaultDuration)
        {
            _tracks[0]._defaultFrameDuration=entry.defaultDuration;
            double inv=entry.defaultDuration; // in us
            inv=1/inv;
            inv*=1000.;
            inv*=1000.;
            inv*=1000.;
            _videostream.dwScale=1000;
            _videostream.dwRate=(uint32_t)inv;
        }else
        {
          printf("[MKV] No duration, assuming 25 fps\n");
          _videostream.dwScale=1000;
          _videostream.dwRate=25000;

        }

        _mainaviheader.dwMicroSecPerFrame=(uint32_t)floor(50);;
        _videostream.fccType=fourCC::get((uint8_t *)"vids");
        _video_bih.biBitCount=24;
        _videostream.dwInitialFrames= 0;
        _videostream.dwStart= 0;
        _video_bih.biWidth=_mainaviheader.dwWidth=entry.w;
        _video_bih.biHeight=_mainaviheader.dwHeight=entry.h;
        _videostream.fccHandler=_video_bih.biCompression=entry.fcc;

        // if it is vfw...
        if(fourCC::check(entry.fcc,(uint8_t *)"VFWX") && entry.extraData && entry.extraDataLen>=sizeof(ADM_BITMAPINFOHEADER))
        {
          memcpy(& _video_bih,entry.extraData,sizeof(ADM_BITMAPINFOHEADER));
          delete [] _tracks[0].extraData;
          entry.extraData=NULL;
          entry.extraDataLen=0;

          _videostream.fccHandler=_video_bih.biCompression;
          _mainaviheader.dwWidth=  _video_bih.biWidth;
          _mainaviheader.dwHeight= _video_bih.biHeight;

        } // FIXME there can be real extradata after bitmapinfoheader

        _tracks[0].extraData=entry.extraData;
        _tracks[0].extraDataLen=entry.extraDataLen;
        _tracks[0].streamIndex=entry.trackNo;

        return 1;
      }
      if(entry.trackType==2 && _nbAudioTrack<ADM_MKV_MAX_TRACKS)
      {
         uint32_t  streamIndex;
         mkvTrak *t=&(_tracks[1+_nbAudioTrack]);

         t->wavHeader.encoding=entry.fcc;
         t->wavHeader.channels=entry.chan;
         t->wavHeader.frequency=entry.fq;
         t->wavHeader.bitspersample=16;
         t->wavHeader.byterate=(128000)>>3; //FIXME
         t->streamIndex=entry.trackNo;
         t->extraData=entry.extraData;
         t->extraDataLen=entry.extraDataLen;
         if(entry.defaultDuration)
          t->_defaultFrameDuration=entry.defaultDuration;
         else
           t->_defaultFrameDuration=0;
        _nbAudioTrack++;
        return 1;
      }
      if(entry.extraData) delete [] entry.extraData;
      return 1;

}

/**
    \fn entryWalk
    \brief walk a trackEntry atom and grabs all infos. Store them in entry
*/
uint8_t entryWalk(ADM_ebml_file *head,uint32_t headlen,entryDesc *entry)
{
  ADM_ebml_file father( head,headlen);
   uint64_t id,len;
  ADM_MKV_TYPE type;
  const char *ss;

  while(!father.finished())
  {
      father.readElemId(&id,&len);
      if(!ADM_searchMkvTag( (MKV_ELEM_ID)id,&ss,&type))
      {
        printf("[MKV] Tag 0x%x not found (len %llu)\n",id,len);
        father.skip(len);
        continue;
      }
      switch(id)
      {

        case  MKV_TRACK_NUMBER: entry->trackNo=father.readUnsignedInt(len);break;
        case  MKV_TRACK_TYPE: entry->trackType=father.readUnsignedInt(len);break;

        case  MKV_AUDIO_FREQUENCY: entry->fq=(uint32_t)floor(father.readFloat(len));break;
        //case MKV_AUDIO_OUT_FREQUENCY:entry->fq=(uint32_t)floor(father.readFloat(len));break;
        case  MKV_VIDEO_WIDTH: entry->w=father.readUnsignedInt(len);break;
        case  MKV_VIDEO_HEIGHT: entry->h=father.readUnsignedInt(len);break;
        case  MKV_TRACK_TIMECODESCALE:father.skip(len);break; //FIXME

        case  MKV_FRAME_DEFAULT_DURATION: entry->defaultDuration=father.readUnsignedInt(len)/1000; break; // In us
        case  MKV_CODEC_EXTRADATA:
        {
              uint8_t *data=new uint8_t[len];
                    father.readBin(data,len);
                    entry->extraData=data;
                    entry->extraDataLen=len;
                    break;
        }
        case  MKV_AUDIO_SETTINGS:
        case  MKV_VIDEO_SETTINGS:
                  entryWalk(&father,len,entry);
                  break;
        case MKV_CODEC_ID:
            {
            uint8_t codec[len+1];
                  father.readBin(codec,len);
                  codec[len]=0;
                  entry->fcc=ADM_mkvCodecToFourcc((char *)codec);

            }
                  break;
        default: printf("[MKV]not handled %s\n",ss);
                  father.skip(len);
        }

      }
  return 1;
}//EOF
