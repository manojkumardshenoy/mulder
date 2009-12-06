/***************************************************************************
    
    Handle preview mode
    
    It is displayed in 3 layers
    
    
    Engine : Call setPreviewMode and amdPreview depending on the actions
            previewMode is the **current** preview mode
    
    admPreview : 
          Allocate/desallocate ressources
          Build preview window
          Call display properly to display it
          
    GUI_PreviewXXXX
          UI toolkit to actually display the window
          See GUI_ui.h to see them
                 
    
    
    copyright            : (C) 2007 by mean
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

#include "ADM_default.h"


#include "ADM_editor/ADM_edit.hxx"
#include "ADM_videoFilter.h"
#include "ADM_videoFilter_internal.h"
#include "ADM_userInterfaces/ADM_render/GUI_render.h"

#include "ADM_osSupport/ADM_debugID.h"
#define MODULE_NAME MODULE_PREVIEW
#include "ADM_osSupport/ADM_debug.h"
#include "ADM_userInterfaces/ADM_commonUI/GUI_ui.h"
#include "ADM_preview.h"
#define MAX(a,b) ( (a)>(b) ? (a) : (b) )

extern FILTER  videofilters[VF_MAX_FILTER];
extern uint32_t nb_active_filter;

static void previewBlit(ADMImage *from,ADMImage *to,uint32_t startx,uint32_t starty);

static   AVDMGenericVideoStream *preview=NULL;

static ADM_PREVIEW_MODE previewMode=ADM_PREVIEW_NONE;

static uint32_t             defered_display=0;  /* When 1, it means we are in playback mode */
static uint32_t             playbackOffset=0;   /* in playback mode, frame 0 = playbackOffset compared to real beginning of the file */
static renderZoom           zoom=ZOOM_1_1;
static ADMImage             *resized=NULL;
static ADMImageResizer      *resizer=NULL;
static ADMImage             *original=NULL;

/*************************************/
static ADMImage *rdrImage=NULL; /* Unprocessed image */
static ADMImage *previewImage;  /* Processed image if any */

static uint32_t  rdrPhysicalW=0;  /* W*H of the INPUT window */
static uint32_t  rdrPhysicalH=0;

static uint32_t  rdrWindowWUnzoomed=0;  /* W*H of the output window WITHOUT zoom */
static uint32_t  rdrWindowHUnzoomed=0;

static uint32_t  rdrWindowWZoomed=0;    /* Same but with zoom */
static uint32_t  rdrWindowHZoomed=0;


/*************************************/
extern ADM_Composer *video_body;
/**

*/
ADMImage *admPreview::getBuffer(void)
{
    return rdrImage;
}
/**
      \fn admPreview::setMainDimension
      \brief Update width & height of input video
      @param w : width
      @param h : height
*/

void admPreview::setMainDimension(uint32_t w, uint32_t h)
{
  if(rdrImage) delete rdrImage;
  rdrImage=new ADMImage(w,h);
  rdrPhysicalW=w;
  rdrPhysicalH=h;
  
  rdrWindowWZoomed=rdrWindowWUnzoomed=w;
  rdrWindowHZoomed=rdrWindowHUnzoomed=h;
  
  renderResize(w,h,w,h);
  
}


/**
      \fn getPreviewMode
      \brief returns current preview mode
      @return current preview mode

*/

ADM_PREVIEW_MODE getPreviewMode(void)
{
  return previewMode; 
}

void changePreviewZoom(renderZoom nzoom)
{
    admPreview::stop();
    zoom=nzoom;
    admPreview::start();
  
}

/**
      \fn setPreviewMode
      \brief set current preview mode an update UI
      @param mode  new preview mode

*/

 void setPreviewMode(ADM_PREVIEW_MODE mode)
{
  previewMode=mode; 
  UI_setCurrentPreview( (int)mode);
}
/**
      \fn deferDisplay
      \brief Enable or disable defered display. Used by playback mode to have smooth output

*/
void admPreview::deferDisplay(uint32_t onoff,uint32_t startat)
{
      
      if(onoff)
      {
        renderStartPlaying();
        defered_display=1;
        playbackOffset=startat;
      }
      else
      {
        renderStopPlaying();
        defered_display=0;
        playbackOffset=0;
      }
  
}
/**
      \fn admPreview::start
      \brief start preview, reiginite preview with new parameters

*/

void 	admPreview::start( void )
{
            aprintf("--killing\n");
            renderLock();
            getFirstVideoFilter();
            
            preview=videofilters[  nb_active_filter-1].filter;
            aprintf("--spawning\n");
            ADM_assert(!previewImage)
                
            previewImage=new ADMImage(preview->getInfo()->width,preview->getInfo()->height);
            
            ADM_assert(!original);
            switch(previewMode)
            {
              case  ADM_PREVIEW_SEPARATE:
                  DIA_previewInit(preview->getInfo()->width,preview->getInfo()->height);
                  
                  /* no break here, not a mistake */
              case  ADM_PREVIEW_NONE:
              
                  rdrWindowWUnzoomed=rdrPhysicalW;
                  rdrWindowHUnzoomed=rdrPhysicalH;
                  break;
              case  ADM_PREVIEW_OUTPUT:
                  rdrWindowWUnzoomed=preview->getInfo()->width;
                  rdrWindowHUnzoomed=preview->getInfo()->height;
                  break;
              case  ADM_PREVIEW_SIDE:
              {
                  rdrWindowWUnzoomed=rdrPhysicalW+preview->getInfo()->width;
                  rdrWindowHUnzoomed=MAX(rdrPhysicalH,preview->getInfo()->height);
                  original=new ADMImage(rdrWindowWUnzoomed,rdrWindowHUnzoomed);
                  break;
              }
              case  ADM_PREVIEW_TOP:
              {
                  
                  rdrWindowWUnzoomed=MAX(rdrPhysicalW,preview->getInfo()->width);
                  rdrWindowHUnzoomed=rdrPhysicalH+preview->getInfo()->height;
                  original=new ADMImage(rdrWindowWUnzoomed,rdrWindowHUnzoomed);
                  break;
              }
              default: ADM_assert(0);
            }
        if(zoom!=ZOOM_1_1)
        {
            int mul;
            switch(zoom)
            {
                    case ZOOM_1_4: mul=1;break;
                    case ZOOM_1_2: mul=2;break;
                    case ZOOM_1_1: mul=4;break;
                    case ZOOM_2:   mul=8;break;
                    case ZOOM_4:   mul=16;break;
                    default : ADM_assert(0);
    
            }
            rdrWindowWZoomed=(rdrWindowWUnzoomed*mul+3)/4;
            rdrWindowHZoomed=(rdrWindowHUnzoomed*mul+3)/4;
            
    
            if(rdrWindowWZoomed&1) rdrWindowWZoomed++;
            if(rdrWindowHZoomed&1) rdrWindowHZoomed++;
            ADM_assert(!resized);
            resized=new ADMImage(rdrWindowWZoomed,rdrWindowHZoomed);
            ADM_assert(!resizer);
            resizer=new  ADMImageResizer(rdrWindowWUnzoomed,rdrWindowHUnzoomed,rdrWindowWZoomed,rdrWindowHZoomed);
            renderResize(rdrWindowWZoomed,rdrWindowHZoomed,rdrWindowWUnzoomed,rdrWindowHUnzoomed);
        }else
        {
             renderResize(rdrWindowWUnzoomed,rdrWindowHUnzoomed,rdrWindowWUnzoomed,rdrWindowHUnzoomed);
        }
        renderUnlock();
}
/**
      \fn admPreview::stop
      \brief kill preview  and associated datas
*/

void admPreview::stop( void )
{
  renderLock();
      if(previewMode==ADM_PREVIEW_SEPARATE)
                DIA_previewEnd();
      if(  previewMode==ADM_PREVIEW_SIDE || previewMode==ADM_PREVIEW_TOP)
      {
        ADM_assert(original);
        delete original;
        original=NULL; 
      }
      renderResize(rdrWindowWUnzoomed,rdrWindowHUnzoomed,rdrWindowWUnzoomed,rdrWindowHUnzoomed);
      if(previewImage)
      {
        delete  previewImage; 
        previewImage=NULL;
      }
      if(zoom!=ZOOM_1_1)
      {
          
          
          if(resized) delete resized;
          if(resizer) delete resizer;
          resized=NULL;
          resizer=NULL;
      }
      renderUnlock();
}
/**
      \fn admPreview::updateFilters
      \brief Signal from filter that the filter chain has been updated
      @param w : width
      @param h : height
*/

void admPreview::updateFilters(AVDMGenericVideoStream *first,AVDMGenericVideoStream *last)
{
   switch(previewMode)
            {
              case  ADM_PREVIEW_SEPARATE:
                  preview=last;
                  break;
              case  ADM_PREVIEW_NONE:
                  break;
              case  ADM_PREVIEW_OUTPUT:
                preview=last;
                break;
              case  ADM_PREVIEW_SIDE:
              {
                  
                  preview=last;
                  break;
              }
              case  ADM_PREVIEW_TOP:
              {
                  
                  preview=last;
                  break;
              }
              default: ADM_assert(0);
            }
  
}

/**
      \fn admPreview::update
      \brief display data associated with framenum image
      @param image : current main image (input)
      @param framenum, framenumber
*/

uint8_t admPreview::update(uint32_t framenum)
{
    uint32_t fl,len,flags;	

    switch(previewMode)
    {
      case ADM_PREVIEW_NONE:
       {
        if( !video_body->getUncompressedFrame(framenum+playbackOffset,rdrImage,&flags))
        {
          return 0; 
        }
            UI_setFrameType(  rdrImage->flags,rdrImage->_Qp);

            if(zoom==ZOOM_1_1 || renderHasAccelZoom() )
            {
               if(!defered_display) 
                  renderUpdateImage(rdrImage->data,zoom);
            }else
            {
                ADM_assert(resizer);
                ADM_assert(resized);
                resizer->resize(rdrImage,resized);
                if(!defered_display) 
                  renderUpdateImage(resized->data,ZOOM_1_1);
            }
        }
        break;
      case ADM_PREVIEW_OUTPUT:
            if(framenum<=preview->getInfo()->nb_frames-1)
                  {
                          if(!preview->getFrameNumberNoAlloc(framenum,&len,previewImage,&fl)) return 0;
                          if(zoom==ZOOM_1_1 || renderHasAccelZoom() )
                          {
                            if(!defered_display) renderUpdateImage(previewImage->data,zoom);
                          }
                          else
                          {
                             resizer->resize(previewImage,resized);
                             if(!defered_display) 
                                  renderUpdateImage(resized->data,ZOOM_1_1);
                          }
                  }
            break;
      case ADM_PREVIEW_SEPARATE:
            ADM_assert(preview);
            ADM_assert(previewImage);

              if( !video_body->getUncompressedFrame(framenum+playbackOffset,rdrImage,&flags))
              {
                  return 0; 
              }
              UI_setFrameType(  rdrImage->flags,rdrImage->_Qp);

            if(zoom==ZOOM_1_1 || renderHasAccelZoom()  )
            {
              if(!defered_display) 
				  renderUpdateImage(rdrImage->data,zoom);
            }
			else
            {
                ADM_assert(resizer);
                ADM_assert(resized);
                resizer->resize(rdrImage,resized);
                if(!defered_display) 
                  renderUpdateImage(resized->data,zoom);
            }
          if( DIA_previewStillAlive())
          {
                  aprintf("Preview: Ask for frame %lu\n",framenum);
                  if(framenum<=preview->getInfo()->nb_frames-1)
                  {
                          preview->getFrameNumberNoAlloc(framenum,&len,previewImage,&fl);
                          if(!defered_display) DIA_previewUpdate(previewImage->data);
                  }
          }
          break;
      case ADM_PREVIEW_SIDE:
              ADM_assert(preview);
              ADM_assert(previewImage);
              ADM_assert(original);
              
              if( !video_body->getUncompressedFrame(framenum+playbackOffset,rdrImage,&flags))
              {
                  return 0; 
              }
              UI_setFrameType(  rdrImage->flags,rdrImage->_Qp);
              previewBlit(rdrImage,original,0,0);
              
              if(preview->getFrameNumberNoAlloc(framenum,&len,previewImage,&fl))
              {
                previewBlit(previewImage,original,rdrPhysicalW,0);
              }
              else printf("Cannot get frame %u\n",framenum);
              if(zoom==ZOOM_1_1  || renderHasAccelZoom() )
              {
                if(!defered_display)
                  renderUpdateImage(original->data,zoom);
              }else
              {
                resizer->resize(original,resized);
                if(!defered_display) 
                  renderUpdateImage(resized->data,ZOOM_1_1);
              }
              break;
        
      case ADM_PREVIEW_TOP:
              ADM_assert(preview);
              ADM_assert(previewImage);
              ADM_assert(original);
              
              if( !video_body->getUncompressedFrame(framenum+playbackOffset,rdrImage,&flags))
              {
                  return 0; 
              }
              UI_setFrameType(  rdrImage->flags,rdrImage->_Qp);
              previewBlit(rdrImage,original,0,0);
              if(preview->getFrameNumberNoAlloc(framenum,&len,previewImage,&fl))
              {
                previewBlit(previewImage,original,0,rdrPhysicalH);
              }
              else printf("Cannot get frame %u\n",framenum);
              if(zoom==ZOOM_1_1 || renderHasAccelZoom() )
              {
                if(!defered_display)
                  renderUpdateImage(original->data,zoom);
              }else
              {
                resizer->resize(original,resized);
                if(!defered_display) 
                  renderUpdateImage(resized->data,ZOOM_1_1);
              }
              break;
      default: ADM_assert(0);
    }
}
/**
      \fn previewBlit(ADMImage *from,ADMImage *to,uint32_t startx,uint32_t starty)
      \brief Blit "from" to "to" at position startx,starty
*/

void previewBlit(ADMImage *from,ADMImage *to,uint32_t startx,uint32_t starty)
{
  
  from->copyTo(to,startx,starty);
  
}
/**
      \fn     displayNow
      \brief  display on screen immediately. The image has been calculated previously by update
*/

void admPreview::displayNow(uint32_t framenum)
{

    uint32_t fl,len;	
    
    switch(previewMode)
    {
      case ADM_PREVIEW_NONE:
           
           if(zoom==ZOOM_1_1 || renderHasAccelZoom() )
            {
                renderUpdateImage(rdrImage->data,zoom);
            }else
            {
                ADM_assert(resized);
                renderUpdateImage(resized->data,zoom);
            }
        break;
      case ADM_PREVIEW_OUTPUT:
            if(zoom==ZOOM_1_1 || renderHasAccelZoom() )
            {
                renderUpdateImage(previewImage->data,zoom);
            }else
            {
                ADM_assert(resized);
                renderUpdateImage(resized->data,zoom);
            }
            break;
      case ADM_PREVIEW_SEPARATE:
            if(zoom==ZOOM_1_1 || renderHasAccelZoom()  )
            {
                renderUpdateImage(rdrImage->data,zoom);
            }else{
                ADM_assert(resized);
                renderUpdateImage(resized->data,zoom);
            }
            if( DIA_previewStillAlive())
            {
                DIA_previewUpdate(previewImage->data);
            }
          break;
      case ADM_PREVIEW_SIDE:
      case ADM_PREVIEW_TOP:
            if(zoom==ZOOM_1_1|| renderHasAccelZoom() )
            {
               renderUpdateImage(original->data,zoom);
            }else
            {
              ADM_assert(resized);
              renderUpdateImage(resized->data,zoom);
            }
              break;
      default: ADM_assert(0);
    }
}

void admPreview::cleanUp(void)
{
	admPreview::stop();

	if(rdrImage)
	{
		delete rdrImage;
		rdrImage = NULL;
	}

	if(original)
    {
		delete original;
		original=NULL;
	}

	if(previewImage)
	{
		delete previewImage; 
		previewImage=NULL;
	}
}
// EOF
