/***************************************************************************
                          gui_savenew.cpp  -  description
                             -------------------
    begin                : Fri May 3 2002
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

#include "ADM_default.h"
#include "ADM_threads.h"

#include "avi_vars.h"
#include "prototype.h"
#include "DIA_coreToolkit.h"
#include "DIA_enter.h"
#include "ADM_audio/aviaudio.hxx"
#include "ADM_audiofilter/audioprocess.hxx"

#include "ADM_videoFilter.h"
#include "ADM_videoFilter_internal.h"
#include "ADM_encoder/ADM_vidEncode.hxx"

#include "ADM_outputs/oplug_avi/op_aviwrite.hxx"
#include "ADM_outputs/oplug_avi/op_avisave.h"
#include "ADM_outputs/oplug_avi/op_savecopy.h"
#include "ADM_outputs/oplug_mp4/oplug_mp4.h"
#include "ADM_outputs/oplug_flv/oplug_flv.h"
#include "ADM_encoder/adm_encoder.h"

#include "ADM_outputs/oplug_avi/op_saveprocess.h"
#include "ADM_outputs/oplug_avi/op_savesmart.hxx"

#include "DIA_enter.h"

#include "DIA_fileSel.h"
#include "ADM_userInterfaces/ADM_commonUI/GUI_ui.h"
#include "ADM_outputs/oplug_mpegFF/oplug_vcdff.h"

static uint8_t  A_SaveAudioNVideo(const char *name);
 extern int A_SaveUnpackedVop(const char *name);
 extern uint8_t oplug_dummy(const char *name);
 extern int A_SavePackedVop(const char *name);
 extern uint8_t ogmSave(const char *name);
 extern uint8_t ADM_saveRaw(const char *name);
 uint8_t A_SaveAudioDualAudio(const char *name);
 extern uint8_t mpeg_passthrough(const char *name,ADM_OUT_FORMAT format);

int A_Save(const char *name)
{
uint32_t end;
int ret=0;
	// depending on the type we save a avi, a mpeg or a XVCD
	CodecFamilty family;
	family= videoCodecGetFamily();
	// in case of copy mode, we stick to avi file format
	if(!videoProcessMode())
	{
		family=CodecFamilyAVI;
		if( UI_GetCurrentFormat()==ADM_PS ||UI_GetCurrentFormat()==ADM_TS )  // exception
		{
			family=CodecFamilyMpeg;
		}
                        
	}
        else
        {
                if(UI_GetCurrentFormat()==ADM_AVI_DUAL)
                {
                  GUI_Error_HIG(QT_TR_NOOP("Dual audio can only be used in copy mode"),QT_TR_NOOP( "Select Copy as the video codec."));
                        return 0;
                }
        }
	printf("**saving:**\n");
	// Check if we need to do a sanity B frame check
	if(!videoProcessMode())
	{	
		uint32_t pb;
		end=avifileinfo->nb_frames;
		// if the last frame is the last frame (!)
		// we add one to keep it, else we systematically skip
		// the last frame
#if 0					
		if(frameEnd==end-1) end=frameEnd+1;
		else
			end=frameEnd;

		if(!video_body->sanityCheckRef(frameStart,end,&pb))
		{
			if(pb)
			{
				GUI_Error_HIG("Cannot save the file", "The video starts/ends with a lonely B-frame. Please remove it.");
				return 0;
			}
			if(!GUI_Question("Warning !\n Bframe has lost its reference frame\nContinue ?"))
				return 0;
		}
#endif
		// Alter frameEnd so that it is not a B frame	
		// as frameEnd -1 position	
		uint32_t tgt=frameEnd;;
		uint32_t flag=0,found=0;
		
		// need to do something ?
		if(frameEnd>frameStart)
		{
			tgt=frameEnd;
			if(tgt==end-1) tgt++;
			video_body->getFlags(tgt-1,&flag);
			if((frameEnd&AVI_B_FRAME))
			{
				printf("Last frame is a B frame, choosing better candidate\n");
				 // The last real one is not a I/P Frame
				 // Go forward or rewind
				 if(tgt<end-1)
				{	// Try next if possible
					video_body->getFlags(tgt,&flag);
					if(!(flag&AVI_B_FRAME))
					{
						printf("Taking next frame as last frame %lu\n",tgt+1);
				 		frameEnd=tgt+1;
				 		found=1;
					}
				}
				if(!found) // next frame not possible, rewind
				{
					if(tgt>=end-2) tgt=end-2;
					while(tgt>frameStart)
					{
						printf("Trying :%lu\n",tgt);
						video_body->getFlags(tgt,&flag);
						if(!(flag&AVI_B_FRAME))
						{
							printf("Taking previous frame as last frame %lu\n",tgt+1);
				 			frameEnd=tgt+1;
				 			found=1;
							break;
						}
						else tgt--;
					}
				}
				ADM_assert(found);
			}
		}
		
		
		
	}
        printf("Output format:%d\n",UI_GetCurrentFormat());
		char *path = ADM_fixupPath(name);

	switch(family)
	{
		case CodecFamilyAVI:
					printf(" AVI family\n");
					switch(UI_GetCurrentFormat())
					{
						case ADM_DUMMY:
					                            			ret=oplug_dummy(path);
					                            			break;
						case ADM_FLV:
                            			ret=oplug_flv(path);
                            			break;
                        case ADM_MP4:
                        case ADM_PSP:
                        case ADM_MATROSKA:
                        
                                                    ret=oplug_mp4(path,UI_GetCurrentFormat());
                                                    break;
						case ADM_AVI:
								ret=A_SaveAudioNVideo(path);
								break;
						case ADM_OGM:
								ret=ogmSave(path);
								break;
						case ADM_ES:
								ret=ADM_saveRaw(path);
								break;
						case ADM_AVI_DUAL:
								ret=A_SaveAudioDualAudio(path);
								break;
                                                case ADM_AVI_PAK:
								ret=A_SavePackedVop(path);
								break;

						case ADM_AVI_UNP:
								ret=A_SaveUnpackedVop(path);
								break;
						default:
                                                  GUI_Error_HIG(QT_TR_NOOP("Incompatible output format"), NULL);
					}
					break;
		case CodecFamilyMpeg:
					printf(" MPEG family\n");
					if(!videoProcessMode())
					{
						
						printf("Using pass through\n");
                                                switch(UI_GetCurrentFormat())
                                                {
                                                  case ADM_PS:
                                                  case ADM_TS:
						          ret=mpeg_passthrough(path,UI_GetCurrentFormat());
                                                          break;
                                                  default:
                                                    GUI_Error_HIG(QT_TR_NOOP("Incompatible output format"), NULL);
                                                }
                                                break;
                                        } // THERE IS NO BREAK HERE, NOT A MISTAKE!
		case CodecFamilyXVCD:
                    switch(UI_GetCurrentFormat())
                    {
                        case ADM_TS:
                        case ADM_PS:
                        case ADM_ES:
                                ret=oplug_mpegff(path,UI_GetCurrentFormat());;
                                break;
                        default:
                          GUI_Error_HIG(QT_TR_NOOP("Incompatible output format"), NULL);
                    }
                    break;
                default:
                            ADM_assert(0);
							delete [] path;
							return 0;
        }
        getFirstVideoFilter(0,avifileinfo->nb_frames);
		delete [] path;

        return ret;
}
uint8_t  A_SaveAudioDualAudio(const char *inname)
{
GenericAviSaveCopyDualAudio *nw;
const char *name;
uint8_t ret=0;

		if(! secondaudiostream)
		{
                  GUI_Error_HIG(QT_TR_NOOP("There is no second track"), QT_TR_NOOP("Select a second audio track in the Audio menu."));
				  	return 0;
		}
		if(!inname)
                  GUI_FileSelWrite(QT_TR_NOOP("Select dual audio AVI to write"), (char**)& name);
		else
			name=inname;
			
		if(!name) return 0;

     		nw=new   GenericAviSaveCopyDualAudio(secondaudiostream);
		ret=nw->saveAvi(name);
       		delete nw;
                return ret;

}
//___________________________________
int A_SaveUnpackedVop(const char *name)
{
  aviInfo info;
GenericAviSave	*nw;
int ret;

	video_body->getVideoInfo(&info);
	if( !isMpeg4Compatible(  info.fcc))
	{
          GUI_Error_HIG(QT_TR_NOOP("This cannot have packed VOP"),QT_TR_NOOP( "It is not MPEG-4 video. File will not be saved."));
		return 0;
        }
	//
	nw=new   GenericAviSaveCopyUnpack();
	ret=nw->saveAvi(name);
	delete nw;
	return ret;
}
int A_SavePackedVop(const char *name)
{
  aviInfo info;
GenericAviSave	*nw;
int ret;

	video_body->getVideoInfo(&info);
	if( !isMpeg4Compatible(  info.fcc))
	{
          GUI_Error_HIG(QT_TR_NOOP("This cannot have packed VOP"),QT_TR_NOOP( "It is not MPEG-4 video. File will not be saved."));
		return 0;
        }
	//
	nw=new   GenericAviSaveCopyPack();
	ret=nw->saveAvi(name);
	delete nw;
	return ret;
}
//___________________________________
uint8_t  A_SaveAudioNVideo(const char *name)
{
     uint32_t needSmart=0,fl;
     GenericAviSave	*nw=NULL;
     aviInfo info;
     uint8_t ret=0;

     video_body->getVideoInfo(&info);

     printf("\n video process mode : %d",videoProcessMode());
     if (!videoProcessMode())
     {
          if(video_body->isMultiSeg()) needSmart=1;
                  video_body->getFlags(frameStart,&fl);
          if(!(fl&AVI_KEY_FRAME)) needSmart=1;

          if(needSmart) printf("\n probably need smart copy mode\n");
      
          if( !isMpeg4Compatible(  info.fcc)
                && !isMSMpeg4Compatible(info.fcc))
             {
                    printf("\n not encodable, cancelling smart mode\n");
                    needSmart=0;
               }


               int value=video_body->getEnv(ENV_EDITOR_SMART);
               nw=NULL;
               if(needSmart)
               {
                  if(value)
                  {
                     nw=new   GenericAviSaveSmart(3);
                  }
                  else
                  {
                    if (GUI_Question(QT_TR_NOOP("You may need smart copy.\nEnable it?")))
                    {
                        value=4;
                        if (!DIA_GetIntegerValue(&value, 2, 31, QT_TR_NOOP("Smart Copy"), QT_TR_NOOP("_Q factor (set 4):")))
							return 0;
                        nw=new   GenericAviSaveSmart(value);
                    }
                }
               }
              if(!nw)
                    nw=new   GenericAviSaveCopy;
               
       }
       else
       {

              printf("\n Process mode\n");
              nw=new   GenericAviSaveProcess;
        }
     ret=nw->saveAvi(name);
     delete nw;

return ret;
}
