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

#include "config.h"
#include "ADM_default.h"

#include "ADM_lavcodec.h"
//#include "ADM_colorspace/colorspace.h"
#include "ADM_image.h"

#include "ADM_codecs/ADM_codec.h"
#include "ADM_codecs/ADM_ffmp43.h"

#include "ADM_toolkit/bitmap.h"
#include "ADM_editor/ADM_edit.hxx"
#include "DIA_coreToolkit.h"
//**********************************
static ADMImage *createImageFromFile_jpeg(const char *filename);
static ADMImage *createImageFromFile_Bmp(const char *filename);
static ADMImage *createImageFromFile_Bmp2(const char *filename);
static ADMImage *createImageFromFile_png(const char *filename);
//***********************************
static uint8_t read8(FILE *fd)
{
	return fgetc(fd);
}
static uint32_t read16(FILE *fd)
{
	uint32_t a,b;
	
	a=fgetc(fd);
	b=fgetc(fd);
	return (a<<8)+b;
		
}
static uint32_t read32(FILE *fd)
{
	uint32_t a,b,c,d;
	
	a=fgetc(fd);
	b=fgetc(fd);
	c=fgetc(fd);
	d=fgetc(fd);
	return (a<<24)+(b<<16)+(c<<8)+d;
		
}

/**
		\fn 	createImageFromFile
		\brief 	Create and returns an ADMImage from a file, only YV12 jpg supported ATM

*/
ADMImage *createImageFromFile(const char *filename)
{
	uint32_t w,h;
	switch(ADM_identidyImageFile(filename,&w,&h))
	{
		case  ADM_IMAGE_UNKNOWN: 
					printf("[imageLoader] Trouble identifying /loading %s\n",filename);
					return NULL;
		case ADM_IMAGE_JPG:
					return createImageFromFile_jpeg(filename);
					break;
		case ADM_IMAGE_PNG:
					return createImageFromFile_png(filename);
					break;
		case ADM_IMAGE_BMP2:
					return createImageFromFile_Bmp2(filename);
					break;
		default:
				ADM_assert(0);
	
	}
	ADM_assert(0);
}
/**
 * 	\fn createImageFromFile_jpeg
 *  \brief Create image from jpeg file
 */
ADMImage *createImageFromFile_jpeg(const char *filename)
{
	
	FILE *fd;
	uint32_t _imgSize;
	uint32_t w = 0, h = 0;
	   

		fd = fopen(filename, "rb");
		fseek(fd, 0, SEEK_END);
		_imgSize = ftell(fd);
		fseek(fd, 0, SEEK_SET);

		//Retrieve width & height
		//_______________________
		    uint16_t tag = 0, off;

		    
		    fseek(fd, 0, SEEK_SET);
		    read16(fd);	// skip jpeg ffd8
		    while (!feof(fd) && tag != 0xFFC0) 
		    {

		    	tag = read16(fd);
		    	if ((tag >> 8) != 0xff) 
		    	{
		    		printf("[imageLoader]invalid jpeg tag found (%x)\n", tag);
					continue;
		    	}
		    	if (tag == 0xFFC0) 
		    	{
		    		read16(fd);	// size
		    		read8(fd);	// precision
		    		h = read16(fd);
		    		w = read16(fd);
	                if(w&1) w++;
	                if(h&1) h++;
					break;
		    	} 
		    	else 
		    	{
		    		off = read16(fd);
		    		if (off < 2) 
		    		{
		    			printf("[imageLoader]Offset too short!\n");
		    		    fclose(fd);
		    		    return NULL;
		    		}
		    		fseek(fd, off - 2, SEEK_CUR);
		    	}
		    }
		    if (tag != 0xffc0) 
		    {
		    	printf("[imageLoader]Cannot find start of frame\n");
				fclose(fd);
				return NULL;
		    }
		    printf("[imageLoader] %lu x %lu.., total Size : %u, offset %u\n", w, h,_imgSize,off);
		    
		// Load the binary coded image
		    uint8_t *data=new uint8_t[_imgSize];
		    fseek(fd, 0, SEEK_SET);
		    fread(data,_imgSize,1,fd);
		    fclose(fd);
		  //
		    
		    ADMImage tmpImage(w,h,1); // It is a reference image
		    // Now unpack it ...
		    decoderFFMJPEG *decoder=new decoderFFMJPEG(w,h);
		    ADMCompressedImage bin;
		    bin.data=data;
		    bin.dataLength=_imgSize; // This is more than actually, but who cares...
		    
		    decoder->uncompress (&bin, &tmpImage);
		    //
		    ADMImage *image=NULL;
		    switch(tmpImage._colorspace)
		    {
		    case ADM_COLOR_YV12:
		    {
		    	printf("[imageLoader] YV12\n");
	    		image=new ADMImage(w,h);
	    		image->duplicate(&tmpImage);
	    		break;
		    }
		    case ADM_COLOR_YUV422:
		    {
		    	printf("[imageLoader] YUY2\n");
		    	image=new ADMImage(w,h);
		    	COL_422_YV12(tmpImage._planes, tmpImage._planeStride,  image->data,w,h);
		    	break;
		    }
		    default:
		    	GUI_Error_HIG(QT_TR_NOOP("Wrong Colorspace"),QT_TR_NOOP("Only YV12/I420 or YUY2/I422 JPegs are supported"));
		    }
		    // Cannot destroy decoder earlier as tmpImage has pointers to its internals
		    delete decoder;
		    decoder=NULL;
		    delete [] data;
		    return image;		
}
/**
 * 	\fn createImageFromFile_jpeg
 *  \brief Create image from Bmp
 */
ADMImage *createImageFromFile_Bmp(const char *filename)
{
	
	FILE *fd;
	uint32_t _imgSize;
	uint32_t w = 0, h = 0;
    uint16_t  s16;
    uint32_t s32;

		fd = fopen(filename, "rb");
		fseek(fd, 0, SEEK_END);
		_imgSize = ftell(fd);
		fseek(fd, 0, SEEK_SET);

		//Retrieve width & height
		//_______________________
		   		ADM_BITMAPINFOHEADER bmph;

			    fread(&s16, 2, 1, fd);
			    if (s16 != 0x4D42) 
			    {
			    	printf("[imageLoader] incorrect bmp sig.\n");
			    	fclose(fd);
			    	return NULL;
			    }
			    fread(&s32, 4, 1, fd);
			    fread(&s32, 4, 1, fd);
			    fread(&s32, 4, 1, fd);
			    fread(&bmph, sizeof(bmph), 1, fd);
			    if (bmph.biCompression != 0) 
			    {
			    	printf("[imageLoader]cannot handle compressed bmp\n");
			    	fclose(fd);
			    	return NULL;
			    }
			    
			    w = bmph.biWidth;
			    h = bmph.biHeight;
			    
			    
			    printf("[ImageLoader] BMP %u * %u\n",w,h);

		// Load the binary coded image
		    uint8_t *data=new uint8_t[w*h*3];
		    fread(data,w*h*3,1,fd);
		    fclose(fd);
		    
		  // Colorconversion
		    
		    	ADMImage *image=new ADMImage(w,h);
		    	COL_RGB24_to_YV12( w, h,data,image->data);
		    
		    delete [] data;
		    return image;		
}
/**
 * 	\fn createImageFromFile_bmp2
 *  \brief Create image from Bmp2 (BM6)
 */
ADMImage *createImageFromFile_Bmp2(const char *filename)
{
    
	ADM_BITMAPINFOHEADER bmph;
    uint8_t fcc_tab[4];
    uint32_t offset;
    FILE *fd=NULL;
    uint32_t w,h;

		fd = fopen(filename, "rb");
 	    fseek(fd, 10, SEEK_SET);

 #define MK32() (fcc_tab[0]+(fcc_tab[1]<<8)+(fcc_tab[2]<<16)+ \
 						(fcc_tab[3]<<24))

 	    fread(fcc_tab, 4, 1, fd);
 	    offset = MK32();
 	    // size, width height follow as int32 
 	    fread(&bmph, sizeof(bmph), 1, fd);
 #ifdef ADM_BIG_ENDIAN
 	    Endian_BitMapInfo(&bmph);
 #endif
 	    if (bmph.biCompression != 0) 
 	    {
 	    	printf("[imageLoader] BMP2:Cannot handle compressed bmp\n");
 	    	fclose(fd);
 	    	return NULL;
 	    }
 	    w = bmph.biWidth;
 	    h = bmph.biHeight;
 	    printf("[imageLoader] BMP2 W: %d H: %d offset : %d\n", w, h, offset);
// Load the binary coded image
 	fseek(fd,offset,SEEK_SET);
    uint8_t *data=new uint8_t[w*h*3];
    fread(data,w*h*3,1,fd);
    fclose(fd);
    
  // Colorconversion
    
    	ADMImage *image=new ADMImage(w,h);
    	COL_RGB24_to_YV12_revert( w, h,data,image->data);
    
    	delete [] data;
    	return image;		
}
/**
 * 	\fn createImageFromFile_png
 *  \brief Create image from PNG
 */
ADMImage *createImageFromFile_png(const char *filename)
{
    
	ADM_BITMAPINFOHEADER bmph;
    uint8_t fcc_tab[4];
    uint32_t offset,size;
    FILE *fd=NULL;
    uint32_t w,h;

		fd = fopen(filename, "rb");
 	    fseek(fd, 0, SEEK_END);
 	    size=ftell(fd);
 	   fseek(fd, 0, SEEK_SET);
 	   read32(fd);
 	   read32(fd);
 	   read32(fd);
 	   read32(fd);
 	   w=read32(fd);
 	   h=read32(fd);
 	   fseek(fd,0,SEEK_SET);
 	   uint8_t *data=new uint8_t[size];
 	   fread(data,size,1,fd);
 	   fclose(fd);
    
  
    
 	   ADMImage tmpImage(w,h,1);
    	// Decode PNG
    	decoderFFPng decoder(w,h);
    	ADMCompressedImage bin;
    	bin.data=data;
    	bin.dataLength=size; // This is more than actually, but who cares...
    			    
    	decoder.uncompress (&bin, &tmpImage);
    	
    	ADMImage *image=new ADMImage(w,h);

		COL_Generic2YV12 *convert = new COL_Generic2YV12(tmpImage._width, tmpImage._height, tmpImage._colorspace);

		convert->transform(tmpImage._planes, tmpImage._planeStride, image->data);

    	delete convert;
    	delete [] data;

    	return image;		
}
/**
 * 		\fn ADM_identidyImageFile
 * 		\brief Identidy image type, returns type and width/height
 */
ADM_IMAGE_TYPE ADM_identidyImageFile(const char *filename,uint32_t *w,uint32_t *h)
{
			uint32_t *fcc;
		    uint8_t fcc_tab[4];
		    FILE *fd;
		    uint32_t off,tag=0,count,size;

		    // 1- identity the file type
		    //
		    fcc = (uint32_t *) fcc_tab;
		    fd = fopen(filename, "rb");
		    if (!fd) 
		    {
		    	printf("[imageIdentify] Cannot open that file!\n");
		    	return ADM_IMAGE_UNKNOWN;
		    }
		    fread(fcc_tab, 4, 1, fd);
		    fcc = (uint32_t *) fcc_tab;
		    // 2- JPEG ?
		    if (fcc_tab[0] == 0xff && fcc_tab[1] == 0xd8) 
		    {
		    			// JPEG
		    	  			fseek(fd, 0, SEEK_SET);
		    			    read16(fd);	// skip jpeg ffd8
		    			    count=0;
		    			    while (count < 10 && tag != 0xFFC0) 
		    			    {

		    			    	tag = read16(fd);
		    			    	if ((tag >> 8) != 0xff) 
		    			    	{
		    			    		printf("[imageIdentify]invalid jpeg tag found (%x)\n", tag);
		    			    	}
		    			    	if (tag == 0xFFC0) 
		    			    	{
		    			    		read16(fd);	// size
		    			    		read8(fd);	// precision
		    			    		*h = read16(fd);
		    			    		*w = read16(fd);
		    		                if(*w&1) *w++;
		    		                if(*h&1) *h++;
		    			    	} 
		    			    	else 
		    			    	{
		    			    		off = read16(fd);
		    			    		if (off < 2) 
		    			    		{
		    			    			printf("[imageIdentify]Offset too short!\n");
		    			    		    fclose(fd);
		    			    		    return ADM_IMAGE_UNKNOWN;
		    			    		}
		    			    		fseek(fd, off - 2, SEEK_CUR);
		    			    	}
		    				count++;
		    			    }
		    			    fclose(fd);
		    			    if(count>=10) return ADM_IMAGE_UNKNOWN;
		    			    return ADM_IMAGE_JPG;
		    }
		    // PNG ?
		    if (fcc_tab[1] == 'P' && fcc_tab[2] == 'N' && fcc_tab[3] == 'G') 
			    {
		     	    fseek(fd, 0, SEEK_SET);
		     	    read32(fd);
		     	    read32(fd);
		     	    read32(fd);
		     	    read32(fd);
		     	    *w=read32(fd);
		     	    *h=read32(fd);	
		     	    fclose(fd);
		     	    return ADM_IMAGE_PNG;
			    }
		    // BMP2?
		    if (fcc_tab[0] == 'B' && fcc_tab[1] == 'M') 
		    {
		    	    ADM_BITMAPINFOHEADER bmph;

		     	    fseek(fd, 10, SEEK_SET);
		     	    fread(fcc_tab, 4, 1, fd);
		     	    // size, width height follow as int32 
		     	    fread(&bmph, sizeof(bmph), 1, fd);
		     #ifdef ADM_BIG_ENDIAN
		     	    Endian_BitMapInfo(&bmph);
		     #endif
		     	    if (bmph.biCompression != 0) 
		     	    {
		     	    	printf("[imageIdentify] BMP2:Cannot handle compressed bmp\n");
		     	    	fclose(fd);
		     	    	return ADM_IMAGE_UNKNOWN;
		     	    }
		     	    *w = bmph.biWidth;
		     	    *h = bmph.biHeight;
	     	    	fclose(fd);
	     	    	return ADM_IMAGE_BMP2;
		    }
		    // Unknown filetype...
		    fclose(fd);
		    return ADM_IMAGE_UNKNOWN;
}
//EOF
