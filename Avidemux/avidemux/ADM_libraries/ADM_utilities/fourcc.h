/***************************************************************************
                          fourcc.h  -  description
                             -------------------
    begin                : Fri Nov 2 2001
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
#ifndef __FOUR_CC__
#define __FOUR_CC__
#include "ADM_default.h"
class fourCC
{
public:
    static int  		    check(uint8_t *,uint8_t *);
	static void 			print(uint32_t four);
	static void 			printBE(uint32_t four);
	static int  			check(uint32_t in,const uint8_t *cc);
	static int  			check(const uint8_t *cc,uint32_t in);
	static  uint32_t 	    get(uint8_t *in)   ;
	static char 		    *tostring(uint32_t fourcc);
    static char            *tostringBE(uint32_t fourcc);

};
void mixDump(uint8_t *ptr, uint32_t len);
#endif
