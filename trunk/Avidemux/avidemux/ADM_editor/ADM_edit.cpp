/***************************************************************************
                          ADM_edit.cpp  -  description
                             -------------------
    begin                : Thu Feb 28 2002
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

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>

#if defined(__MINGW32__) || defined(ADM_BSD_FAMILY)
#include <sys/stat.h>
#endif

#include "ADM_assert.h"
#include "fourcc.h"
#include "ADM_editor/ADM_edit.hxx"
#include "ADM_inputs/ADM_inpics/ADM_pics.h"
#include "ADM_inputs/ADM_nuv/ADM_nuv.h"
#include "ADM_inputs/ADM_h263/ADM_h263.h"
//#include "ADM_3gp/ADM_3gp.h"
#include "ADM_inputs/ADM_mp4/ADM_mp4.h"
#include "ADM_inputs/ADM_openDML/ADM_openDML.h"
#include "ADM_inputs/ADM_avsproxy/ADM_avsproxy.h"
#include "DIA_coreToolkit.h"
#include "ADM_editor/ADM_edit.hxx"
#include "ADM_videoFilter.h"
//#include "ADM_dialog/DIA_working.h"
#include "ADM_inputs/ADM_ogm/ADM_ogm.h"
#include "ADM_inputs/ADM_mpegdemuxer/dmx_video.h"
#include "ADM_inputs/ADM_mpegdemuxer/dmx_identify.h"
#include "ADM_inputs/ADM_mpegdemuxer/dmx_probe.h"
#include "ADM_inputs/ADM_matroska/ADM_mkv.h"
#include "ADM_inputs/ADM_flv/ADM_flv.h"
#include "ADM_inputs/ADM_amv/ADM_amv.h"
#include "ADM_inputs/ADM_asf/ADM_asf.h"
#include "prefs.h"

#include "ADM_osSupport/ADM_debugID.h"
#define MODULE_NAME MODULE_EDITOR
#include "ADM_osSupport/ADM_debug.h"

#include "ADM_inputs/ADM_mpegdemuxer/dmx_indexer.h"
#include "ADM_outputfmt.h"
//#include "ADM_gui2/GUI_ui.h"
int DIA_mpegIndexer (char **mpegFile, char **indexFile, int *aid,
		     int already = 0);
void DIA_indexerPrefill(char *name);
extern uint8_t indexMpeg (char *mpeg, char *file, uint8_t aid);

extern uint8_t loadVideoCodecConf( const char *name);
extern uint8_t parseScript(char *name);
extern int ADM_open(const char *path, int oflag, int aflag);

uint8_t UI_SetCurrentFormat( ADM_OUT_FORMAT fmt );
const char *VBR_MSG = QT_TR_NOOP("Avidemux detected VBR MP3 audio in this file. For keeping audio/video in sync, time map is needed. Build it now?\n\nYou can do it later with \"Audio -> Build VBR Time Map\".");
//
//

#define TEST_MPEG2DEC

ADM_Composer::ADM_Composer (void)
{
uint32_t type,value;

  _nb_segment = 0;
  _nb_video = 0;
  _total_frames = 0;
  _audioseg = 0;
  _audiooffset = 0;
  _audioSample=0;
  _lastseg = 99;
  _lastframe = 99;
  _nb_clipboard=0;
  _haveMarkers=0; // only edl have markers
  // Initialize a default postprocessing (dummy)
  initPostProc(&_pp,16,16);
  if(!prefs->get(DEFAULT_POSTPROC_TYPE,&type)) type=3;
  if(!prefs->get(DEFAULT_POSTPROC_VALUE,&value)) value=3;

  _pp.postProcType=type;
  _pp.postProcStrength=value;
  _pp.swapuv=0;
  _pp.forcedQuant=0;
  updatePostProc(&_pp);
  _imageBuffer=NULL;    
  _internalFlags=0;
  // Start with a clean base
  memset (_videos, 0, sizeof (_videos));
  max_seg = MAX_SEG;
  _segments = new _SEGMENT[max_seg];
  memset (_segments, 0, sizeof (_segments));
  _scratch=NULL;
  
}
/**
	Remap 1:1 video to segments

*/
uint8_t ADM_Composer::resetSeg( void )
{
	_total_frames=0;
	for(uint32_t i=0;i<_nb_video;i++)
	{
		_segments[i]._reference = i;
  		_segments[i]._audio_size = _videos[i]._audio_size;
  		_segments[i]._audio_start = 0;
  		_segments[i]._start_frame = 0;
		_segments[i]._audio_duration = 0;		
		_segments[i]._nb_frames   =   _videos[i]._nb_video_frames ;
		_total_frames+=_segments[i]._nb_frames  ;
		updateAudioTrack (i);
	}

  	_nb_segment=_nb_video;
  	computeTotalFrames();
	dumpSeg();
	return 1;
}
/**
	Return extra Header info present in avi chunk that are needed to initialize
	the video codec
	It is assumed that there is only one file or can share the same init data
	(huffyuv for example)
*/
uint8_t ADM_Composer::getExtraHeaderData (uint32_t * len, uint8_t ** data)
{
  return _videos[0]._aviheader->getExtraHeaderData (len, data);

}

/**
	Return extra Header info present in avi chunk that are needed to initialize
	the audio codec
	It is assumed that there is only one file or can share the same init data
	Example : WMA
*/
uint8_t ADM_Composer::getAudioExtra (uint32_t * l, uint8_t ** d)
{
  *l = 0;
  *d = NULL;
  if (!_nb_segment)
    return 0;
  if (!_videos[0]._audiostream)
    return 0;
  return _videos[0]._audiostream->extraData (l, d);


}

/**
	Purge all segments
*/
uint8_t ADM_Composer::deleteAllSegments (void)
{


  memset (_segments, 0, sizeof (_segments));
  _nb_segment = 0;
  _total_frames=computeTotalFrames();
  return 1;

}

/**
	Purge all videos
*/
void
ADM_Composer::deleteAllVideos (void)
{

  for (uint32_t vid = 0; vid < _nb_video; vid++)
    {

      // purge audio stream
      if (_videos[vid]._audiostream)
	{
	  if (_videos[vid]._audiostream->isDestroyable ())
	    delete _videos[vid]._audiostream;
	}
      // if there is a video decoder...
      if (_videos[vid].decoder)
	delete _videos[vid].decoder;
      if(_videos[vid].color)
        delete _videos[vid].color;
      // prevent from crashing
      _videos[vid]._aviheader->close ();
      delete _videos[vid]._aviheader;
      if(_videos[vid]._videoCache)
      	delete  _videos[vid]._videoCache;
      _videos[vid]._videoCache=NULL;
    }

  memset (_videos, 0, sizeof (_videos));
  
  
  if(_imageBuffer)
  	delete _imageBuffer;
  _imageBuffer=NULL;

}

ADM_Composer::~ADM_Composer ()
{
	deleteAllSegments();
	deleteAllVideos();
	deletePostProc(&_pp);

	if(_segments)
	{
		delete[] _segments;
		_segments=NULL;
	}

	if(_scratch)
	{
		delete _scratch;
		_scratch=NULL;
	}
}

/*
   			Return Magic : 4*4 bytes first

*/

/**
    \fn addFile
    \brief	Load or append a file.	The file type is determined automatically and the ad-hoc video decoder is spawned
    
    @param name: filename
    @param mode: 0 open, 1 append
    @param forcedType : if !=Unknown_FileType, it enables to force the file type

    @return 1 on success, 0 on failure
        

*/
uint8_t ADM_Composer::addFile (const char *name, uint8_t mode,fileType forcedType)
{
  uint8_t    ret =    0;
  aviInfo    info;
  WAVHeader *    _wavinfo;
//  aviHeader *    tmp;
  fileType    type =    forcedType;

UNUSED_ARG(mode);
	_haveMarkers=0; // by default no markers are present
  ADM_assert (_nb_segment < max_seg);
  ADM_assert (_nb_video < MAX_VIDEO);

  // Autodetect file type ?
  if(Unknown_FileType==type)
  {
      if (!identify (name, &type))
        return 0;
  }


#define OPEN_AS(x,y) case x:\
						_videos[_nb_video]._aviheader=new y; \
						 ret = _videos[_nb_video]._aviheader->open(name); \
						break;
  switch (type)
    {
      case VCodec_FileType:
      		loadVideoCodecConf(name);      		
		return ADM_IGN; // we do it but it wil fail, no problem with that
      		break;
      OPEN_AS (Mp4_FileType, mp4Header);
      OPEN_AS (H263_FileType, h263Header);
      
      case ASF_FileType:
              _videos[_nb_video]._aviheader=new asfHeader; 
              ret = _videos[_nb_video]._aviheader->open(name); 
              if(!ret)
              {
                delete _videos[_nb_video]._aviheader;
                printf("Trying mpeg\n"); 
                goto thisIsMpeg; 
              }
              break;
      OPEN_AS (NewMpeg_FileType,dmxHeader);
      // For AVI we first try top open it as openDML
      case AVI_FileType:
      			_videos[_nb_video]._aviheader=new OpenDMLHeader; 
			 ret = _videos[_nb_video]._aviheader->open(name); 			
			break;
      
    case Nuppel_FileType:
	{ // look if the idx exists
	  char *tmpname = (char*)ADM_alloc(strlen(name)+strlen(".idx")+1);
		ADM_assert(tmpname);
		sprintf(tmpname,"%s.idx",name);
		if(addFile(tmpname))
		{
			return 1; // Memleak ?
		}
		ADM_dealloc(tmpname);
		// open .nuv file
		_videos[_nb_video]._aviheader=new nuvHeader;
		ret = _videos[_nb_video]._aviheader->open(name);
		// we store the native .nuv file in the edl
		// the next load of the edl will open .idx instead
		break;
	}
      OPEN_AS (BMP_FileType, picHeader);
      OPEN_AS (Matroska_FileType, mkvHeader);
      OPEN_AS (FLV_FileType, flvHeader);
      OPEN_AS (AvsProxy_FileType, avsHeader);
      OPEN_AS (_3GPP_FileType, MP4Header);
      OPEN_AS (Ogg_FileType, oggHeader);
      OPEN_AS (AMV_FileType, amvHeader);

    case Mpeg_FileType:
thisIsMpeg:
    	// look if the idx exists
	char tmpname[256];
	ADM_assert(strlen(name)+5<256);
	strcpy(tmpname,name);
	strcat(tmpname,".idx");
        if(ADM_fileExist(tmpname))
        {
	       return addFile(tmpname);
        }
	/* check for "Read-only file system" */
	{
                int fd = ADM_open(tmpname,O_CREAT|O_EXCL|O_WRONLY,S_IRUSR|S_IWUSR);
                if( fd >= 0 )
                {
                    close(fd);
                    unlink(tmpname);
                    printf("Filesystem is writable\n");
		}else if( errno == EROFS ){
		  char *tmpdir = getenv("TMPDIR");
#ifdef __WIN32
                        printf("Filesystem is not writable, looking for somewhere else\n");
			if( !tmpdir )
				tmpdir = "c:";
			snprintf(tmpname,256,"%s%s.idx",tmpdir,strrchr(name,'\\'));
#else
			if( !tmpdir )
				tmpdir = "/tmp";
			snprintf(tmpname,256,"%s%s.idx",tmpdir,strrchr(name,'/'));
#endif
			tmpname[255] = 0;
                        printf("Storing index in %s\n",tmpname);
                    if(ADM_fileExist(tmpname))
                    {
                        printf("Index present, loading it\n");
                        return addFile(tmpname);
                    }
                }
        }
        if(tryIndexing(name,tmpname))
        {
                return addFile (tmpname);
        }
        return 0;
      break;
	case WorkBench_FileType:

  		return loadWorbench(name);
#if 0
        case Script_FileType:
                return parseScript(name);
#endif
	case ECMAScript_FileType:
                printf("****** This is an ecmascript, run it with avidemux2 --run yourscript *******\n");
                printf("****** This is an ecmascript, run it with avidemux2 --run yourscript *******\n");
                printf("****** This is an ecmascript, run it with avidemux2 --run yourscript *******\n");
                return 0;
		
                
    default:
      if (type == Unknown_FileType)
	{
	  printf ("\n not identified ...\n");
	}
      else
        GUI_Error_HIG(QT_TR_NOOP("File type identified but no loader support detected..."),
                      QT_TR_NOOP("May be related to an old index file."));
      return 0;
    }

   // check opening was successful
   if (ret == 0) {
     char str[512+1];
     snprintf(str,512,QT_TR_NOOP("Attempt to open %s failed!"), name);
      str[512] = '\0';
      GUI_Error_HIG(str,NULL);
      delete _videos[_nb_video]._aviheader;
      return 0;
   }

   /* check for resolution */
   if( _nb_video ){
      /* append operation */
      aviInfo info0, infox;
      _videos[   0     ]._aviheader->getVideoInfo (&info0);
      _videos[_nb_video]._aviheader->getVideoInfo (&infox);

      if(info0.width != infox.width || info0.height != infox.height)
	  {
         GUI_Error_HIG(QT_TR_NOOP("Video dimensions don't match."), QT_TR_NOOP("You cannot mix different video dimensions yet. Using the partial video filter later will not work around this problem. The workaround is:\n\n1) \"Resize\" / \"Add Border\" / \"Crop\" each stream to the same resolution\n2) Concatenate them together"));
		 delete _videos[_nb_video]._aviheader;
         return 0;
      }
   }
 
  // else update info
  _videos[_nb_video]._aviheader->getVideoInfo (&info);
  _videos[_nb_video]._aviheader->setMyName (name);
  
  // Printf some info about extradata
  {
    uint32_t l=0;
    uint8_t *d=NULL;
    _videos[_nb_video]._aviheader->getExtraHeaderData(&l,&d);
    if(l && d)
    {
        printf("The video codec has some extradata (%d bytes)\n",l);
        mixDump(d,l);
        printf("\n");
    }
  }
  // 1st if it is our first video we update postproc
 if(!_nb_video)
 {
        uint32_t type,value;

        if(!prefs->get(DEFAULT_POSTPROC_TYPE,&type)) type=3;
        if(!prefs->get(DEFAULT_POSTPROC_VALUE,&value)) value=3; 	

	deletePostProc(&_pp );
 	initPostProc(&_pp,info.width,info.height);
	_pp.postProcType=type;
	_pp.postProcStrength=value;
	_pp.forcedQuant=0;
	updatePostProc(&_pp);

	if(_imageBuffer) delete _imageBuffer;
	_imageBuffer=new ADMImage(info.width,info.height);
 	_imageBuffer->_qSize= ((info.width+15)>>4)*((info.height+15)>>4);
	_imageBuffer->quant=new uint8_t[_imageBuffer->_qSize];
	_imageBuffer->_qStride=(info.width+15)>>4;
 }
    
 
//    fourCC::print( info.fcc );
  _total_frames += info.nb_frames;
  _videos[_nb_video]._nb_video_frames = info.nb_frames;


  // and update audio info
  //_________________________
  _wavinfo = _videos[_nb_video]._aviheader->getAudioInfo ();	//wavinfo); // will be null if no audio
  if (!_wavinfo)
    {
      printf ("\n *** NO AUDIO ***\n");
      _videos[_nb_video]._audiostream = NULL;
    }
  else
    {
float duration;
      _videos[_nb_video]._aviheader->getAudioStream (&_videos[_nb_video].
						     _audiostream);
      _videos[_nb_video]._audio_size =_videos[_nb_video]._audiostream->getLength ();
     
      
	
	duration=_videos[_nb_video]._nb_video_frames;
	duration/=info.fps1000;
	duration*=1000;			// duration in seconds
	duration*=_wavinfo->frequency;  	// In sample
	_videos[_nb_video]._audio_duration=(uint64_t)floor(duration);
        printf("[Editor] Duration in seconds: %"LLU", in samples: %"LLU"\n",_videos[_nb_video]._audio_duration/_wavinfo->frequency,_videos[_nb_video]._audio_duration);

    }

  printf ("\n Decoder FCC: ");
  fourCC::print (info.fcc);
  // ugly hack
  if (info.fps1000 > 2000 * 1000)
    {
      printf (" FPS too high, switching to 25 fps hardcoded\n");
      info.fps1000 = 25 * 1000;
      updateVideoInfo (&info);
    }
  uint32_t    	l;
  uint8_t 	*d;
  _videos[_nb_video]._aviheader->getExtraHeaderData (&l, &d);
  _videos[_nb_video].decoder = getDecoder (info.fcc,
					   info.width, info.height, l, d,info.bpp);

  _videos[_nb_video]._videoCache   =   new EditorCache(10,info.width,info.height) ;
  //
  //  And automatically create the segment
  //
  _segments[_nb_segment]._reference = _nb_video;
  _segments[_nb_segment]._audio_size = _videos[_nb_video]._audio_size;
  _segments[_nb_segment]._audio_duration =_videos[_nb_video]._audio_duration;
  _segments[_nb_segment]._audio_start = 0;
  _segments[_nb_segment]._start_frame = 0;
  _segments[_nb_segment]._nb_frames   =   _videos[_nb_video]._nb_video_frames ;

  _videos[_nb_video]._isAudioVbr=0;
//****************************
   

  // next one please
        if(_wavinfo)
        if(_wavinfo->encoding==WAV_MP3 && _wavinfo->blockalign==1152)
        {
          uint32_t autovbr=0;
          prefs->get(FEATURE_AUTO_BUILDMAP,&autovbr);
          if(autovbr || GUI_Confirmation_HIG(QT_TR_NOOP("Build Time Map"),QT_TR_NOOP( "Build VBR time map?"), VBR_MSG))
                {
                _videos[_nb_video]._isAudioVbr=_videos[_nb_video]._audiostream->buildAudioTimeLine ();
                }
        }

	_nb_video++;
	_nb_segment++;

//______________________________________
// 1-  check for B _ frame  existence
// 2- check  for consistency with reported flags
//______________________________________
	uint8_t count=0;
TryAgain:	
	_VIDEOS 	*vid;
	uint32_t err=0;

		vid= &(_videos[_nb_video-1]);
		vid->_reorderReady=0;
                vid->_unpackReady=0;
		// we only try if we got everything needed...
		if(!vid->decoder)
		{
			printf("\n no decoder to check for B- frame\n");
			return 1;
		}
		if(!vid->decoder->bFramePossible())
		{
			printf("\n no  B- frame with that codec \n");
			return 1;
		}
                if(isH264Compatible(info.fcc))
                {
                  if(getEnv(ENV_EDITOR_X264) || GUI_Confirmation_HIG(QT_TR_NOOP("Use safe mode"),QT_TR_NOOP("H.264 detected"),QT_TR_NOOP("If the file is using B-frames as reference it can lead to a crash or stuttering.\nAvidemux can use another mode which is safe but YOU WILL LOSE FRAME ACCURACY.\nDo you want to use that mode?")))
                    {
                              printf("Switching to non low delay codec\n");
                              _videos[_nb_video-1].decoder = getDecoderH264noLogic (info.fcc,  info.width, info.height, l, d);
                              return 1;
                    }


                }
		printf("\n checking for B-Frames...\n");
		if( vid->_nb_video_frames > 12)
		{
				uint8_t 		*bufferin;
				uint32_t 		len,flags;
				uint8_t 		bframe=0, bconsistency=1;
				uint32_t		scanned;
                                ADMImage                *buffer=NULL;

				if(vid->_nb_video_frames > (info.fps1000 * 5) / 1000)
					scanned = (info.fps1000 * 5) / 1000;
				else				scanned=vid->_nb_video_frames;

				printf(" scanning %lu frames\n", scanned);
				
				bufferin=new uint8_t [info.width* info.height*2];
                                if(vid->decoder->dontcopy())
                                        buffer=new ADMImage(info.width,info.height,1);
                                else
				        buffer=new ADMImage(info.width,info.height);

                                ADMCompressedImage img;
                                img.data=bufferin;
				for(uint32_t i=0;i<scanned;i++)  //10
				{
					flags=0;
  					vid->_aviheader->getFrameNoAlloc (i,&img);
                                        if(!img.dataLength) continue;
					if(!vid->decoder->uncompress( &img,buffer ))
					{
						err++;
						printf("\n ***oops***\n");
					}

					if(i<5) continue; // ignore the first frames
					
					// check if it is a b-frame
					//printf(" %lu : %lu \n",i,flag2);
					if(buffer->flags & AVI_B_FRAME)
					{
						printf(" * ");
					 	bframe=1;
						vid->_aviheader->getFlags(i,&flags);
						if(!(flags & AVI_B_FRAME))
                                                {
                                                        printf("Frame %lu is A B frame, flag not ok\n",i);
							bconsistency=0;
                                                }
						else
							printf("# ");
					}
					if((i%16)==15) printf("\n");
				}
                                printf("\n");
				delete  buffer;
				delete [] bufferin;
				if(getEnv(ENV_EDITOR_BFRAME))
				{
					printf("Forcing Bframe present and incorrect\n");
					bframe=1;
					bconsistency=0;
					
				}
                                uint32_t ffcheck=vid->decoder->isDivxPacked ();
                                if(ffcheck)
                                {
                                  printf("[Editor] Decoder says it is vop packed\n");
                                }
				if(bframe || ffcheck)
				{
					printf("\n Mmm this appear to have b-frame...\n");
					if(bconsistency )
					{
						printf("\n And the index is ok\n");

						//uint8_t [720*576*3];
						vid->_reorderReady=vid->_aviheader->reorder();
						if(vid->_reorderReady)
						{
							printf("\n Frames re-ordered, B-frame friendly now :)\n");
							aprintf(" we had :%lu",info.nb_frames);
							// update nb frame in case we dropped some
							_total_frames -= info.nb_frames;
							_videos[_nb_video-1]._aviheader->getVideoInfo (&info);
							aprintf(" we have now  :%lu",info.nb_frames);
							_total_frames += info.nb_frames;
  							_videos[_nb_video-1]._nb_video_frames = info.nb_frames;
						}
						else
						{
							printf("\n Frames not  re-ordered, expect problem with b-frames\n");
						}

					}
					else
					{
						printf("\n But the  index is not up to date \n");
						uint32_t ispacked=0;
                                                
                                                uint32_t ff=vid->decoder->isDivxPacked ();
                                                if(ff)
                                                {
                                                  printf("[Editor] Decoder says it is vop packed\n");
                                                }
                                                
						// If it is Divx 5.0.xxx use divx decoder
						if(isMpeg4Compatible(info.fcc))
						{


							//if(vid->decoder->isDivxPacked())
							uint8_t forced= getEnv(ENV_EDITOR_PVOP);
							if(ff ||forced)
							{
								
								// can only unpack avi
								if(!count && type==AVI_FileType)
								{
                                                                  uint32_t autounpack=0;
                                                                  prefs->get(FEATURE_AUTO_UNPACK,&autounpack);
									if( forced || autounpack || GUI_YesNo(
                                                                                QT_TR_NOOP("Packed Bitstream detected"),
                                                                        QT_TR_NOOP("Do you want me to unpack it ?")))
									{
									OpenDMLHeader *dml=NULL;
									count++;	
									dml=(OpenDMLHeader *)vid->_aviheader;
									// Can we repack it ?
									if(dml->unpackPacked())
									{
                                                                                // Set ouput to avi vop
                                                                                UI_SetCurrentFormat(ADM_AVI_UNP);
                                                                                // Create a new decoder
                                                                                // As the current one have already decoded
                                                                                // some pics
                                                                                delete  _videos[_nb_video-1].decoder;
                                                                                _videos[_nb_video-1].decoder=NULL;
                                                                                printf("Creating fresh decoder\n");
                                                                                 _videos[_nb_video-1].decoder = getDecoder (info.fcc,
                                           info.width, info.height, l, d);
										goto TryAgain;
									}
                                                                        GUI_Error_HIG(QT_TR_NOOP("Could not unpack the video"),QT_TR_NOOP( "Using backup decoder - not frame accurate."));
									}
								}
                                                                if(count)
                                                                        GUI_Info_HIG(ADM_LOG_IMPORTANT,QT_TR_NOOP("Weird"),QT_TR_NOOP( "The unpacking succeedeed but the index is still not up to date."));
								printf("\n Switching codec...\n");
								delete vid->decoder;
								vid->decoder=getDecoderVopPacked(info.fcc, info.width,info.height,0,NULL);
								ispacked=1;
							}

						}
						// else warn user
						if(!ispacked)
                                                {
                                                   uint32_t reindex=0;
                                                  prefs->get(FEATURE_AUTO_REBUILDINDEX,&reindex);
                                                  if(reindex || GUI_YesNo(QT_TR_NOOP("Index is not up to date"),QT_TR_NOOP("You should use Tool->Rebuild frame. Do it now ?")))
                                                        {
                                                                rebuildFrameType();
							}
                                                }
					}
				}
				else
				{
					printf("Seems it does not contain B-frames...\n");
				}
		printf(" End of B-frame check\n");
		}
  return 1;
}
/**
	Send a re-order order to all video if
		- They may need it
		- It is not already done.
*/
uint8_t ADM_Composer::reorder (void)
{
_VIDEOS *vid;
	for(uint32_t i=0;i<_nb_video;i++)
	{
		vid=&_videos[i];
		if(!vid->_reorderReady) // not already reordered ?
		{
				if(vid->decoder->bFramePossible()) // can be re-ordered ?
				{
						if((vid->_reorderReady=vid->_aviheader->reorder()))
						{
							aviInfo    info;
							_videos[i]._aviheader->getVideoInfo (&info);
                                                        
							printf(" Video %lu has been reordered\n",i);
						}

				}
		}
	}
	return 1;
}
/*
        If one of the videos has VBR audio we handle the whole editor audio has VBR
        If it is CBR, it is not harmful 
        and it avoid loosing the VBR info in case we do VBR time map upon loading
*/
uint8_t ADM_Composer::hasVBRVideos(void)
{
        for(int i=0;i<_nb_video;i++)
                if(_videos[i]._isAudioVbr) return 1;
        return 0;
}

/*

*/
uint32_t ADM_Composer::getPARWidth()
{
  if (_nb_video)
  {
    return _videos[0].decoder->getPARWidth();
  }
  return 1;

}

uint32_t ADM_Composer::getPARHeight()
{
  if (_nb_video)
  {
    return _videos[0].decoder->getPARHeight();
  }
  return 1;

}

/**
	Set decoder settings (post process/swap u&v...)
	for the segment referred by frame

*/
uint8_t ADM_Composer::setDecodeParam (uint32_t frame)
{
uint32_t seg,relframe,ref;
  if (_nb_video)
  {
   if (!convFrame2Seg (frame, &seg, &relframe))
    {
      printf ("\n Conversion failed !\n");
      return 0;
    }
    // Search source
     ref = _segments[seg]._reference;
    _videos[ref].decoder->setParam ();        
  }
  return 1;

}

/**
	Free all allocated memory and destroy all editors object


*/
uint8_t ADM_Composer::cleanup (void)
{
  deleteAllSegments ();
  deleteAllVideos ();
  _nb_segment = 0;
  _nb_video = 0;
  _total_frames = 0;

	if(_scratch)
	{
		delete _scratch;
		_scratch=NULL;
	}

  return 1;
}
/*
        param:
                source : source #
                start : start frame in source #
                nb    : nb frame to copy into segment
*/
uint8_t ADM_Composer::addSegment(uint32_t source,uint32_t start, uint32_t nb)
{
        // do some sanity check
        if(_nb_segment==max_seg-1)
	{
	   _SEGMENT *s;
            max_seg += MAX_SEG;
            s = new _SEGMENT[max_seg];
            memset (s, 0, sizeof(_SEGMENT)*max_seg);
            memcpy(s,_segments,sizeof(_SEGMENT)*(max_seg-MAX_SEG));
            delete _segments;
            _segments = s;
        }
        if(_nb_video<=source)
        {
                printf("[editor]: No such source %d/%d\n",source,_nb_video);
                 return 0;
        }
        if(_videos[source]._nb_video_frames<=start)
        {
                printf("[editor]:start out of bound %d/%d\n",start,_videos[source]._nb_video_frames);
                 return 0;
        }
        if(_videos[source]._nb_video_frames<start+nb)
        {
                printf("[editor]:end out of bound %d/%d\n",start+nb,_videos[source]._nb_video_frames);
                 return 0;
        }
        // ok, let's go
        _SEGMENT *seg=&(_segments[_nb_segment]);
        seg->_reference=source;
        seg->_start_frame=start;
        seg->_nb_frames=nb;
        _nb_segment++;
        updateAudioTrack (_nb_segment-1);
        _total_frames=computeTotalFrames();

        return 1;
}
/**
______________________________________________________
//  Remove frames , the frame are given as seen by GUI
//  We remove from start to end -1
// [start,end[
//______________________________________________________
*/
uint8_t ADM_Composer::removeFrames (uint32_t start, uint32_t end)
{

  uint32_t
    seg1,
    seg2,
    rel1,
    rel2;
  uint8_t
    lastone =
    0;

  if (end == _total_frames - 1)
    lastone = 1;

  // sanity check
  if (start > end)
    return 0;
  //if((1+start)==end) return 0;

  // convert frame to block, relative frame
  if (!convFrame2Seg (start, &seg1, &rel1) ||
      !convFrame2Seg (end, &seg2, &rel2))
    {
      ADM_assert (0);
    }
  // if seg1 != seg2 we can just modify seg1 and seg2
  if (seg1 != seg2)
    {
      // remove end of seg1

      removeFrom (rel1, seg1, 1);
      //  delete in between seg
      for (uint32_t seg = seg1 + 1; seg < (seg2); seg++)
	_segments[seg]._nb_frames = 0;
      // remove beginning of seg2
      removeTo (rel2, seg2, lastone);
    }
  else
    {
      // it is in the same segment, split it...
      // complete seg ?
      if ((rel1 == _segments[seg1]._start_frame)
	  && (rel2 ==
	      (_segments[seg1]._start_frame +
	       _segments[seg1]._nb_frames - 1)))
	{
	  _segments[seg1]._nb_frames = 0;
	}
      else
	{
	  // split in between.... duh !
	  duplicateSegment (seg1);
	  //
	  removeFrom (rel1, seg1, 1);
	  removeTo (rel2, seg1 + 1, lastone);
	}
    }

  // Crunch
  crunch ();
  sanityCheck ();
  // Compute total nb of frame
  _total_frames = computeTotalFrames ();
  printf ("\n %lu frames ", _total_frames);
  return 1;

}
//******************************
// Select audio track
//
//******************************
uint8_t ADM_Composer::getAudioStreamsInfo(uint32_t frame,uint32_t *nbStreams, audioInfo **infos)
{
uint32_t seg,rel,reference;

        if (!convFrame2Seg (frame, &seg, &rel))
        {
                printf("Editor : frame2seg failed (%u)\n",frame);
                return 0;
        }
        reference=_segments[seg]._reference;
        return _videos[reference]._aviheader->getAudioStreamsInfo(nbStreams,infos);
}
/*
        Change the audio track for the source video attached to the "frame" frame

*/
uint32_t ADM_Composer::getCurrentAudioStreamNumber(uint32_t frame)
{
uint32_t   seg,rel,reference;

        if (!convFrame2Seg (frame, &seg, &rel))
        {
                printf("Editor : frame2seg failed (%u)\n",frame);
                return 0;
        }
        reference=_segments[seg]._reference;
        return _videos[reference]._aviheader->getCurrentAudioStreamNumber();
}
uint8_t ADM_Composer::changeAudioStream(uint32_t frame,uint32_t newstream)
{
uint32_t   seg,rel,reference;
double     duration;
WAVHeader *wav;
aviInfo    info;

        if (!convFrame2Seg (frame, &seg, &rel))
        {
                printf("Editor : frame2seg failed (%u)\n",frame);
                return 0;
        }
        reference=_segments[seg]._reference;
        if(!_videos[reference]._aviheader->changeAudioStream(newstream))
        {
                printf("Editor : stream change failed for frame %u seg %u stream %u\n",frame,seg,newstream);
                return 0;
        }
        // Now update audio tracks infos
        wav = _videos[reference]._aviheader->getAudioInfo ();
        if(!wav)
        {
                ADM_assert(0); // Cannot change to a non existing track!
        }
        _videos[reference]._aviheader->getVideoInfo (&info);
        _videos[reference]._aviheader->getAudioStream (&_videos[reference]._audiostream);
        _videos[reference]._audio_size =_videos[reference]._audiostream->getLength ();
        duration=_videos[reference]._nb_video_frames;
        duration/=info.fps1000;
        duration*=1000;                 // duration in seconds
        duration*=wav->frequency;          // In sample
        _videos[reference]._audio_duration=(uint64_t)floor(duration);
        for(uint32_t i=0;i<_nb_segment;i++)
                updateAudioTrack(i);
        return 1;
}

/**
______________________________________________________
//
//	Copy the start/eng seg  to clipboard
//______________________________________________________
*/
uint8_t ADM_Composer::copyToClipBoard (uint32_t start, uint32_t end)
{

  uint32_t	    seg1,    seg2,    rel1,    rel2;
  uint8_t    lastone =    0;
uint32_t seg=0xfff;

  if (end == _total_frames - 1)
    lastone = 1;

  // sanity check
  if (start > end)
  {
    printf("End < Start \n");
    return 0;
   }
  //if((1+start)==end) return 0;

  // convert frame to block, relative frame
  if (!convFrame2Seg (start, &seg1, &rel1) ||
      !convFrame2Seg (end, &seg2, &rel2))
    {
      ADM_assert (0);
    }
    _nb_clipboard=0;
  // if seg1 != seg2 we can just modify seg1 and seg2
  if (seg1 != seg2)
    {
    aprintf("Diff  seg: %lu /%lu from %lu to %lu \n",seg1,seg2,rel1,rel2);
      // remove end of seg1
	_clipboard[_nb_clipboard]._reference=_segments[seg1]._reference;
	_clipboard[_nb_clipboard]._start_frame=rel1;
 	_clipboard[_nb_clipboard]._nb_frames =_segments[seg]._nb_frames- (rel1 - _segments[seg]._start_frame);
	_nb_clipboard++;
      // copy  in between seg
      for ( seg = seg1 + 1; seg <=seg2; seg++)
		memcpy(&_clipboard[_nb_clipboard++], &_segments[seg],sizeof(_segments[0]));
      // Adjust nb frame for last seg
      uint32_t l;
      l=_nb_clipboard-1;
	_clipboard[l]._nb_frames=rel2-_segments[seg2]._start_frame;
    }
  else
    {
      // it is in the same segment, split it...
      // complete seg ?
      if ((rel1 == _segments[seg1]._start_frame)
	  && (rel2 ==
	      (_segments[seg1]._start_frame +
	       _segments[seg1]._nb_frames - 1)))
	{
	  aprintf("Full seg: %lu from %lu to %lu \n",seg1,rel1,rel2);
		memcpy(&_clipboard[_nb_clipboard++], &_segments[seg1],sizeof(_segments[0]));
	}
      else
	{
	  // we just take a part of one chunk
	  aprintf("Same seg: %lu from %lu to %lu \n",seg1,rel1,rel2);
	  memcpy(&_clipboard[_nb_clipboard], &_segments[seg1],sizeof(_segments[0]));
	  _clipboard[_nb_clipboard]._start_frame=rel1;
	  _clipboard[_nb_clipboard]._nb_frames=rel2-rel1;
	_nb_clipboard++;
	aprintf("clipboard: %lu \n",_nb_clipboard);
	}
    }
	dumpSeg();
  return 1;

}
uint8_t ADM_Composer::pasteFromClipBoard (uint32_t whereto)
{
uint32_t rel,seg;

	if (!convFrame2Seg (whereto, &seg, &rel) )
    	{
      		ADM_assert (0);
    	}
	dumpSeg();

	// past at frame 0
	if(	seg==0 && rel==_segments[0]._start_frame)
	{
		aprintf("Pasting at frame 0\n");
		for(uint32_t i=0;i<_nb_clipboard;i++)
			duplicateSegment(seg);
		memcpy(&_segments[0],&_clipboard[0],_nb_clipboard*sizeof(_clipboard[0]));
	}
	else
	if(rel==_segments[seg]._start_frame+_segments[seg]._nb_frames )
	{
		aprintf("\n setting at the end of seg %lu\n",seg);
		// we put it after OLD insert OLD+1
		for(uint32_t i=0;i<_nb_clipboard;i++)
			duplicateSegment(seg);
		memcpy(&_segments[seg+1],&_clipboard[0],_nb_clipboard*sizeof(_clipboard[0]));

	}
	else // need to split it
	{
		for(uint32_t i=0;i<_nb_clipboard+1;i++)
			duplicateSegment(seg);
		memcpy(&_segments[seg+1],&_clipboard[0],_nb_clipboard*sizeof(_clipboard[0]));

		// and the last one
		_segments[seg+_nb_clipboard+1]._nb_frames=(_segments[seg]._start_frame+_segments[seg]._nb_frames)-rel;
		_segments[seg+_nb_clipboard+1]._start_frame=rel;
		// adjust the current one
		_segments[seg]._nb_frames=rel-_segments[seg]._start_frame;
	}
	 _total_frames = computeTotalFrames ();
	for(uint32_t i=0;i<_nb_segment;i++)
 		updateAudioTrack(i);
  dumpSeg();
  return 1;

}

//____________________________________
//      Duplicate a segment
//____________________________________

uint8_t ADM_Composer::duplicateSegment (uint32_t segno)
{

  for (uint32_t i = _nb_segment; i > segno; i--)
    {

      memcpy (&_segments[i], &_segments[i - 1], sizeof (_SEGMENT));

    }
  _nb_segment++;
  return 1;


}

//____________________________________
//      Remove empty segments
//____________________________________
uint8_t ADM_Composer::crunch (void)
{
  uint32_t
    seg =
    0;
  while (seg < _nb_segment)
    {
      if (_segments[seg]._nb_frames == 0)
	{
	  //

	  for (uint32_t c = seg + 1; c < _nb_segment; c++)
	    {
	      memcpy (&_segments[c - 1], &_segments[c], sizeof (_SEGMENT));
	    }
	  _nb_segment--;

	}
      else
	{
	  seg++;
	}
    }
  // Remove last seg if there is only one frame in it
  if (_nb_segment)
    {
      if (_segments[_nb_segment - 1]._nb_frames == 1)
	{
	  _nb_segment--;
	}
    }
  return 1;

}

//____________________________________
//      Remove empty segments
//____________________________________
uint32_t ADM_Composer::computeTotalFrames (void)
{
  uint32_t
    seg,
    tf =
    0;
  for (seg = 0; seg < _nb_segment; seg++)
    {
      tf += _segments[seg]._nb_frames;

    }

  return tf;
}

//____________________________________
//      Remove empty segments
//____________________________________
void
ADM_Composer::dumpSeg (void)
{
  uint32_t seg;
  printf ("\n________Video______________");
  for (seg = 0; seg < _nb_video; seg++)
    {
      printf ("\n Video : %lu, nb video  :%lu, audio size:%lu  audioDuration:%lu",
	      seg, _videos[seg]._nb_video_frames, _videos[seg]._audio_size,_videos[seg]._audio_duration);

    }

  printf ("\n______________________");
  for (seg = 0; seg < _nb_segment; seg++)
    {
      printf
	("\n Seg : %lu, ref: %lu start :%lu, size:%lu audio size : %lu audio start : %lu duration:%lu",
	 seg, _segments[seg]._reference, _segments[seg]._start_frame,
	 _segments[seg]._nb_frames, _segments[seg]._audio_size,
	 _segments[seg]._audio_start,
	  _segments[seg]._audio_duration
	 );

    }
  printf ("\n_________Clipboard_____________");
  for (seg = 0; seg < _nb_clipboard; seg++)
    {
      printf
	("\n Seg : %lu, ref: %lu start :%lu, size:%lu audio size : %lu audio start : %lu  duration:%lu\n",
	 seg, _clipboard[seg]._reference, _clipboard[seg]._start_frame,
	 _clipboard[seg]._nb_frames, _clipboard[seg]._audio_size,
	 _clipboard[seg]._audio_start,
	 _segments[seg]._audio_duration);

    }


}

// Clear from position to/from
//
// 0------To------end
//  xxxxxx removed

uint8_t ADM_Composer::removeTo (uint32_t to, uint32_t seg, uint8_t included)
{
  uint32_t
    ref;

  ADM_assert (checkInSeg (seg, to));
  ref = _segments[seg]._start_frame;
  _segments[seg]._start_frame = to;
  if (included)
    _segments[seg]._start_frame++;
  _segments[seg]._nb_frames -= (_segments[seg]._start_frame - ref);


  updateAudioTrack (seg);

//---------------------------------------



  return 1;
}

//
// 0------From------end
//            xxxxxx removed

uint8_t
  ADM_Composer::removeFrom (uint32_t from, uint32_t seg, uint8_t included)
{
  ADM_assert (checkInSeg (seg, from));
  _segments[seg]._nb_frames = (from - _segments[seg]._start_frame);

  if (!included)
    _segments[seg]._nb_frames++;

  updateAudioTrack (seg);
  return 1;
}

//
//      Update the real size of audio track by computing the
// delta between sync @end and sync@begin
// We also upate the duration of the selected part
//

uint8_t ADM_Composer::updateAudioTrack (uint32_t seg)
{
  // audio sync
  uint32_t
    pos_start,
    pos_end,
    off,
    tf;
  uint32_t
    reference;

  reference = _segments[seg]._reference;
  // Mika
  if (!_videos[reference]._audiostream)
    return 1;
  // Compute the resulting duration
  // Of the segment
  double duration;
  aviInfo info;
  	_videos[reference]._aviheader->getVideoInfo(&info);
  	duration= _segments[seg]._nb_frames;
	ADM_assert(info.fps1000);
	duration/=info.fps1000;
	duration*=1000*_videos[reference]._audiostream->getInfo()->frequency;
	
  _segments[seg]._audio_duration = (uint64_t)floor(duration);

  // If we cannot go to sync point start --> no need to continue
  // It can happen if audio track is shorter than video
  if (!audioGoToFn (seg, _segments[seg]._start_frame, &off))
    {
      _segments[seg]._audio_size = 0;
      printf (" cannot seek audio tp frame : %lu\n", seg);
      return 1;

    }
  pos_start = _videos[reference]._audiostream->getPos ();

  // Now try to go to the end...
  // if it fails, try previous frame stamp
  tf = _segments[seg]._start_frame + _segments[seg]._nb_frames;	//-1;

  while ((!audioGoToFn (seg, tf, &off)
	  && ((tf - 1) > _segments[seg]._start_frame)))
    {
      printf (" trying to sync on frame %lu\n", tf);
      tf--;
    }

  pos_end = _videos[reference]._audiostream->getPos ();

  _segments[seg]._audio_size = pos_end - pos_start;
  _segments[seg]._audio_start = pos_start;
  
  printf (" Audio start : %lu end : %lu size : %lu\n", pos_start, pos_end,
	  _segments[seg]._audio_size);

  return 1;

#warning FIXME, does not work if audio track is shorter

}
uint8_t WAV2AudioInfo(WAVHeader *hdr,audioInfo *info)
{
    info->bitrate=(hdr->byterate*8)/1000;
    info->channels=hdr->channels;
    info->encoding=hdr->encoding;
    info->frequency=hdr->frequency;
    info->av_sync=0;
    return 1;
}


//__________________________________________________
// check that the given frame is inside the segment
//__________________________________________________
uint8_t ADM_Composer::checkInSeg (uint32_t seg, uint32_t frame)
{
  if (frame < _segments[seg]._start_frame)
    return 0;
  if (frame > (_segments[seg]._nb_frames + _segments[seg]._start_frame))
    return 0;
  return 1;

}
uint8_t	ADM_Composer::isIndexable( void)
{
	if(!_nb_video) ADM_assert(0);
	return _videos[0].decoder->isIndexable();

}

uint8_t ADM_Composer::sanityCheck (void)
{
  uint32_t
    ref,
    seg;

  for (seg = 0; seg < _nb_segment; seg++)
    {
      ref = _segments[seg]._start_frame + _segments[seg]._nb_frames - 1;

    }
  return 1;


}

/**
	Propagate VBR building to underlying segment

*/
void
ADM_Composer::propagateBuildMap (void)
{
uint8_t need_update=0;
  if (_nb_video)
    {
    for(uint32_t i=0;i<_nb_video;i++)
    	{
    		if(! _videos[i]._isAudioVbr)
		{
			if((    		_videos[i]._isAudioVbr=_videos[i]._audiostream->buildAudioTimeLine ()))
			{
				need_update=1;
			}
		}
	}
    }

}
//_________________________________________
uint8_t		ADM_Composer::setEnv(_ENV_EDITOR_FLAGS newflag)
{
	_internalFlags|=newflag;
	return 1;

}
//_________________________________________
//	Return 1 if the flag was set
//		The flag is reset in all cases!!!!!!!!!!!!!
uint8_t		ADM_Composer::getEnv(_ENV_EDITOR_FLAGS newflag)
{
uint8_t r=0;
		if(_internalFlags&newflag) r=1;
		_internalFlags&=~newflag;
		if(r) { printf("Env override %d used\n",newflag);}
		return r;

}
//_________________________________________
//    Try indexing the file, return 1 if file successfully indexed 
//              0 else
//_________________________________________
//
uint8_t         ADM_Composer::tryIndexing(const char *name, const char *idxname)
{
 unsigned int autoidx = 0;
      prefs->get(FEATURE_TRYAUTOIDX,&autoidx);
      if (!autoidx)
        {
          if (!GUI_Question (QT_TR_NOOP("This looks like mpeg\n Do you want to index it?")))
            {
                return 0;
            }
		}  
          char      *idx;
          DMX_TYPE  type;
          uint32_t  nbTrack=0,audioTrack=0;
          MPEG_TRACK *tracks=NULL;
          uint8_t r=1;

                if(!dmx_probe(name,&type,&nbTrack,&tracks))
                {
                        printf("This is not mpeg\n");
                        return 0;
                }

          
                if(type==DMX_MPG_PS || type==DMX_MPG_TS || type==DMX_MPG_TS2)
                {
                       if(nbTrack>2)
		       if(autoidx)
			{
				printf("Using autoindex\n");
			}
/*                        else
		       {
                           
                        if(!DIA_dmx(name,type,nbTrack,tracks,&audioTrack))
                        {
                                delete [] tracks;
                                return 0;
                        }
		       }
*/
                        audioTrack=0;
                }
		if( idxname ){
			idx=new char[strlen(idxname)];
			strcpy(idx,idxname);
		}else{
                	idx=new char[strlen(name)+5];
                	strcpy(idx,name);
                	strcat(idx,".idx");
		}

                r=dmx_indexer(name,idx,audioTrack,0,nbTrack,tracks);

                if(tracks)
                        delete [] tracks;
                delete [] idx;

                if(!r) GUI_Error_HIG(QT_TR_NOOP("Indexing failed"), NULL); 
                return r;
}
/**
      If a parameter has changed, rebuild the duration of the streams
      It can happen, for example in case of SBR audio such as AAC
      The demuxer says it is xx kHz, but the codec updates it to 2*xx kHz
*/
uint8_t ADM_Composer::rebuildDuration(void)
{
  double duration;
  WAVHeader *wav ;
  aviInfo    info;
  printf("[Editor] updating soundtracks duration\n");
  _videos[   0     ]._aviheader->getVideoInfo (&info);
  for(int i=0;i<_nb_video;i++)
  {
    wav= _videos[i]._aviheader->getAudioInfo ();
      if(wav)
      {
          duration=_videos[i]._nb_video_frames;
          duration/=info.fps1000;
          duration*=1000;                 // duration in seconds
          duration*=wav->frequency;          // In sample
          _videos[i]._audio_duration=(uint64_t)floor(duration);
      }
  }
  for(int i=0;i<_nb_segment;i++)
    updateAudioTrack(i);
  return 1;
}
//
//
