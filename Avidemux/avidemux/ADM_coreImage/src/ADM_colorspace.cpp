/***************************************************************************
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


#include "ADM_default.h"
#include "ADM_colorspace.h"


extern "C" {
#include "libavcodec/avcodec.h"
#include "libavutil/avutil.h"
#include "libswscale/swscale.h"
}

#include "ADM_rgb.h" 
#include "ADM_colorspace.h"

#ifdef ADM_CPU_X86
		#define ADD(x,y) if( CpuCaps::has##x()) flags|=SWS_CPU_CAPS_##y;
#define FLAGS()		ADD(MMX,MMX);				ADD(3DNOW,3DNOW);		ADD(MMXEXT,MMX2)	flags|=SWS_SPLINE;
#else
#ifdef ADM_CPU_ALTIVEC
#define FLAGS() flags|=SWS_CPU_CAPS_ALTIVEC | SWS_BICUBLIN;
#else
#define FLAGS() flags|=SWS_BICUBLIN;
#endif
#endif

#define CONTEXT (SwsContext *)context

/**
    \fn ADMColor2LAVColor
    \brief Convert ADM colorspace type swscale/lavcodec colorspace name

*/
static PixelFormat ADMColor2LAVColor(ADM_colorspace fromColor)
{
  switch(fromColor)
  {
    case ADM_COLOR_YV12: return PIX_FMT_YUV420P;
    case ADM_COLOR_YUV422P: return PIX_FMT_YUV422P;
    default : ADM_assert(0); 
  }
  return PIX_FMT_YUV420P;
}
/**
      \fn getStrideAndPointers
      \brief Fill in strides etc.. needed by libswscale
*/
uint8_t ADMColorspace::getStrideAndPointers(uint8_t  *from,ADM_colorspace fromColor,uint8_t **srcData,int *srcStride)
{
  switch(fromColor)
  {
    case  ADM_COLOR_YV12:
            srcData[0]=from;
            srcData[1]=from+width*height;
            srcData[2]=from+((5*width*height)>>2);
            srcStride[0]=width;
            srcStride[1]=width>>1;
            srcStride[2]=width>>1;
            break;
    case  ADM_COLOR_YUV422P:
            srcData[0]=from;
            srcData[1]=from+width*height;
            srcData[2]=from+((3*width*height)>>1);
            srcStride[0]=width;
            srcStride[1]=width>>1;
            srcStride[2]=width>>1;
            break;

    default:
        ADM_assert(0);
  }
  return 1;
}
/**
    \fn  convert
    \brief Do the color conversion
  @param from Source image
  @param to Target image
*/

uint8_t ADMColorspace::convert(uint8_t  *from, uint8_t *to)
{
  uint8_t *srcData[3];
  uint8_t *dstData[3];
  int srcStride[3];
  int dstStride[3];
  
  getStrideAndPointers(from,fromColor,srcData,srcStride);
  getStrideAndPointers(to,toColor,dstData,dstStride);
  sws_scale(CONTEXT,(const uint8_t**)srcData,srcStride,0,height,dstData,dstStride);
  return 1;
  
}

/**
    \fn  ADMColorspace
    \brief Constructor
  @param w width
  @param h height
  @param from colorspace to convert from
  @param to colorspace to concert to
*/

ADMColorspace::ADMColorspace(uint32_t w, uint32_t h, ADM_colorspace from,ADM_colorspace to)
{
  int flags;
  FLAGS();
  
    width=w;
    height=h;
    fromColor=from;
    toColor=to;
    PixelFormat lavFrom=ADMColor2LAVColor(fromColor);
    PixelFormat lavTo=ADMColor2LAVColor(toColor);
    
    context=(void *)sws_getContext(
                      width,height,
                      lavFrom ,
                      width,height,
                      lavTo,
                      flags, NULL, NULL,NULL);

}
/**
    \fn  ~ADMColorspace
    \brief Destructor
*/
ADMColorspace::~ADMColorspace()
{
  if(context)
  {
     sws_freeContext(CONTEXT);
     context=NULL;
  }
}
 
//EOF
