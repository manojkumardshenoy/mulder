
/***************************************************************************
                          guiplay.cpp  -  description
                             -------------------

	This file is a part of callback but splitted for readability sake

    begin                : Fri Dec 28 2001
    copyright            : (C) 2001 by mean
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
 
#include <math.h>
#include "prefs.h"
#include "fourcc.h"
#include "avi_vars.h"
#include "ADM_assert.h" 

#include "DIA_fileSel.h"
#include "prototype.h"
#include "ADM_audiodevice/audio_out.h"

#include "DIA_coreToolkit.h"
#include "ADM_audio/aviaudio.hxx"
#include "ADM_audiofilter/audioprocess.hxx"
#include "ADM_videoFilter.h"
#include "ADM_videoFilter_internal.h"
#include "gtkgui.h"
#include "ADM_userInterfaces/ADM_render/GUI_render.h"
#include "ADM_audiofilter/audioeng_buildfilters.h"
#include "ADM_libraries/ADM_utilities/avidemutils.h"
#include "ADM_preview.h"
//___________________________________
#define AUDIO_PRELOAD 150
//___________________________________

static void resetTime(void);
static void ComputePreload(void);
static void FillAudio(void);
extern void UI_purge(void);
#define EVEN(x) (x&0xffffffe)

//___________________________________
uint8_t stop_req;
static int called = 0;
static uint32_t vids = 0, auds = 0, dauds = 0;
static int32_t delta;

static uint16_t audio_available = 0;
static uint32_t one_audio_frame = 0;
static uint32_t one_frame;
static float *wavbuf = NULL;
AUDMAudioFilter *playback = NULL;
extern renderZoom currentZoom;
//static uint8_t Vbuffer[7.0*5.6*3];
//AVDMGenericVideoStream *getFirstVideoFilter( void)
//
//_____________________________________________________________
void GUI_PlayAvi(bool forceStop)
{
    uint32_t  time_e, time_a = 0;
    uint32_t err = 0, acc = 0;
    uint32_t max;

    uint32_t framelen,flags;
    AVDMGenericVideoStream *filter;

    vids = 0, auds = 0, dauds = 0;
    // check we got everything...
    if (!avifileinfo)
	return;
  if((curframe+1)>= avifileinfo->nb_frames-1)
  {
      printf("No frame left\n");
      return;
   }
    if (avifileinfo->fps1000 == 0)
        return;
    if (playing || forceStop)
      {
        stop_req = 1;
        return;
      }

	uint32_t priorityLevel;

	originalPriority = getpriority(PRIO_PROCESS, 0);
	prefs->get(PRIORITY_PLAYBACK,&priorityLevel);
	setpriority(PRIO_PROCESS, 0, ADM_getNiceValue(priorityLevel));

  uint32_t played_frame=0;
  uint32_t remaining=avifileinfo->nb_frames-curframe;

    
    if(getPreviewMode()==ADM_PREVIEW_OUTPUT)
    {
            filter=getLastVideoFilter(curframe,remaining);
    }
    else
    {
            filter=getFirstVideoFilter(curframe,remaining );
    }
    
    max=filter->getInfo()->nb_frames;

    // compute how much a frame lasts in ms
    one_frame = (uint32_t) floor(1000.*1000.*10. / filter->getInfo()->fps1000);
    err = one_frame % 10;
    one_frame /= 10; // Duration of a frame in ms, err =leftover in 1/10 ms
    
    // go to RealTime...    
    printf("One frame : %lu, err=%lu ms\n", one_frame, err);
    
    // prepare 1st frame

    stop_req = 0;
    playing = 1;

#ifdef HAVE_AUDIO
    ComputePreload();
#endif
    
     
     //renderStartPlaying();
// reset timer reference
    resetTime();
    admPreview::deferDisplay(1,curframe);
    admPreview::update(played_frame);
    do
    {
        vids++;
        admPreview::displayNow(played_frame);;
        update_status_bar();
        if (time_a == 0)
            time_a = getTime(0);
        // mark !
        //printf("\n Rendering %lu frame\n",curframe);
        // read frame in chunk

        if((played_frame)>=(max-1))
        {
            printf("\nEnd met (%lu  / %lu )\n",played_frame,max);
            goto abort_play;
         }
        
        admPreview::update(played_frame+1);;
	curframe++;
	played_frame++;

#ifdef HAVE_AUDIO
	  FillAudio();
#endif

	  time_e = getTime(1);
	  acc += err;
	  if (acc > 10)
	    {
		acc -= 10;
		time_a++;
	    }
	  time_a += one_frame;
	  // delta a is next frame time
	  // time is is current time
	  delta = time_a - time_e;
	  if (delta <= 0)
	    {
		//if(delta<-19)  // allow 19 ms late without warning...
		// tick seems to be ~ 18 ms
		//printf("\n Late ....,due : %lu ms / found : %lu \n",
		//                                              time_a,time_e); 
		// a call to whatever sleep function will last at leat 10 ms
		// give some time to GTK                
	
	  } else
	    {
		// a call to whatever sleep function will last at leat 10 ms
		// give some time to GTK                		
		if (delta > 10)
		    GUI_Sleep(delta - 10);
	    }
     	//
            UI_purge();
            if(getPreviewMode()==ADM_PREVIEW_SEPARATE )
            {
              UI_purge();
              UI_purge(); 
            }
      }
    while (!stop_req);

abort_play:
		// ___________________________________
    // Flush buffer   
    // go back to normal display mode
    //____________________________________
    playing = 0;
          
	   getFirstVideoFilter( );

           admPreview::deferDisplay(0,0);
           UI_purge();
           // Updated by expose ? 
           admPreview::update(curframe);
           UI_purge();
     	   update_status_bar();
#ifdef HAVE_AUDIO
    if (currentaudiostream)
      {
	  if (wavbuf)
	      ADM_dealloc(wavbuf);
          deleteAudioFilter(NULL);
	  currentaudiostream->endDecompress();
	  AVDM_AudioClose();

      }
#endif
    // done.

	setpriority(PRIO_PROCESS, 0, originalPriority);
};

// return time in ms
//____________________________________________
void resetTime(void)
{
    called = 0;
}


#ifdef HAVE_AUDIO
//________________________________
//
void FillAudio(void)
//________________________________
{
    uint32_t oaf = 0;
    uint32_t load = 0;
	uint8_t channels;
	uint32_t fq;

    if (!audio_available)
	return;
    if (!currentaudiostream)
	return;			// audio ?


    channels= playback->getInfo()->channels;
    fq=playback->getInfo()->frequency;  
	  double db_vid, db_clock, db_wav;

	  db_vid = vids;
	  db_vid *= 1000.;
          db_vid /= avifileinfo->fps1000;  // In second

          do
          {


          db_clock = getTime(1);
          db_clock /= 1000;  // in seconds

          db_wav = dauds;	// for ms
          db_wav /= fq;

	  delta = (long int) floor(1000. * (db_wav - db_vid));
#if 0
	  printf(" v:%2.2lf   wav:%2.2lf t:%2.2lf delta : %ld  \r",
		 db_vid, db_wav, db_clock, delta);
#endif
          // if delta grows, it means we are pumping
          // too much audio (audio will come too early)
          // if delta is small, it means we are late on audio
          if (delta < AUDIO_PRELOAD)
          {
              AUD_Status status;
                 if (! (oaf = playback->fill(2*one_audio_frame,  (wavbuf + load),&status)))
                 {
                      printf("\n Error reading audio stream...\n");
                      return;
                 }
                dauds += oaf/channels;
                load += oaf;
          }
      }
    while (delta < AUDIO_PRELOAD);
    AVDM_AudioPlay(wavbuf, load);
}


//_______________________________________
//
void ComputePreload(void)
//_______________________________________
{
    uint32_t state,latency, one_sec;
    uint32_t small_;
    uint32_t channels;

    wavbuf = 0;

    if (!currentaudiostream)	// audio ?
      {
	  return;
      }
    // PCM or readable format ?
    if (currentaudiostream->isCompressed())
      {
	  if (!currentaudiostream->isDecompressable())
	    {
		audio_available = 0;
		return;
	    }
      }


    double db;
    // go to the beginning...

    db = curframe * 1000.;	// ms
    db *= 1000.;		// fps is 1000 time too big
    db /= avifileinfo->fps1000;
    printf(".. Offset ...%ld ms\n", (uint32_t) floor(db + 0.49));
    //      currentaudiostream->goToTime( (uint32_t)floor(db+0.49));        

    playback = buildPlaybackFilter(currentaudiostream,(uint32_t) (db + 0.49), 0xffffffff);
    
    channels= playback->getInfo()->channels;
    one_audio_frame = (one_frame * wavinfo->frequency * channels);	// 1000 *nb audio bytes per ms
    one_audio_frame /= 1000; // In elemtary info (float)
    printf("1 audio frame = %lu bytes\n", one_audio_frame);
    // 3 sec buffer..               
    wavbuf =  (float *)  ADM_alloc((3 *  2*channels * wavinfo->frequency*wavinfo->channels));
    ADM_assert(wavbuf);
    // Call it twice to be sure it is properly setup
     state = AVDM_AudioSetup(playback->getInfo()->frequency,  channels );
     AVDM_AudioClose();
     state = AVDM_AudioSetup(playback->getInfo()->frequency,  channels );
     latency=AVDM_GetLayencyMs();
     printf("[Playback] Latency : %d ms\n",latency);
      if (!state)
      {
          GUI_Error_HIG(QT_TR_NOOP("Trouble initializing audio device"), NULL);
          return;
      }
    // compute preload                      
    //_________________
    // we preload 1/4 a second
     currentaudiostream->beginDecompress();
     one_sec = (wavinfo->frequency *  channels)  >> 2;
     one_sec+=(latency*wavinfo->frequency *  channels*2)/1000;
     AUD_Status status;
    uint32_t fill=0;
    while(fill<one_sec)
    {
      if (!(small_ = playback->fill(one_sec-fill, wavbuf,&status)))
      {
        break;
      }
    fill+=small_;
    }
    dauds += fill/channels;  // In sample
    AVDM_AudioPlay(wavbuf, fill);
    // Let audio latency sets in...
    ADM_usleep(latency*1000);
    audio_available = 1;
}


#endif
// EOF
