/*

  Some utilities 

*/
#ifndef ADM_AVIDEMUTIL_H
#define ADM_AVIDEMUTIL_H

#include "ADM_image.h"
uint8_t  ADM_findMpegStartCode(uint8_t *start, uint8_t *end,uint8_t *outstartcode,uint32_t *offset);
uint32_t ADM_computeBitrate(uint32_t fps1000, uint32_t nbFrame, uint32_t sizeInMB);
ADM_ASPECT getAspectRatioFromAR(uint32_t width, uint32_t height,const char **s);
char *ADM_escape(const ADM_filename *incoming);
int32_t ADM_getNiceValue(uint32_t priorityLevel);

#endif
//EOF
