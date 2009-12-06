/***************************************************************************
                          DIA_working.cpp  -  description
                             -------------------
    begin                : Thu Apr 21 2003
    copyright            : (C) 2003 by mean
    email                : fixounet@free.fr

	This class deals with the working window

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

#include "ADM_default.h"

#include "ADM_osSupport/ADM_debugID.h"
#define MODULE_NAME MODULE_CLOCKnTIMELEFT
#include "ADM_osSupport/ADM_debug.h"

# include "config.h"
#include "DIA_working.h"


DIA_working::DIA_working( void )
{

}
DIA_working::DIA_working( const char *title )
{
}
void DIA_working :: postCtor( void )
{

		lastper=0;
		_nextUpdate=0;
}
uint8_t DIA_working::update(uint32_t percent)
{
	#define  GUI_UPDATE_RATE 1000

                if(!percent) return 0;
                if(percent==lastper)
                {

                   return 0;
                }
                aprintf("DIA_working::update(%lu) called\n", percent);
                elapsed=_clock.getElapsedMS();
                if(elapsed<_nextUpdate) 
                {

                  return 0;
                }
                _nextUpdate=elapsed+1000;
                lastper=percent;
  
        
		//
		// 100/totalMS=percent/elapsed
		// totalM=100*elapsed/percent

		double f;
		f=100.;
		f*=elapsed;
		f/=percent;

		f-=elapsed;
		f/=1000;

		uint32_t sectogo=(uint32_t)floor(f);

	char b[300];
   		int  mm,ss;
    			mm=sectogo/60;
      			ss=sectogo%60;
    			printf(" %d m %d s left ", mm,ss);

		double p;
			p=percent;
			p=p/100.;
                        printf("%% done : %f\n",p);
		return 0;


}
uint8_t DIA_working::update(uint32_t cur, uint32_t total)
{
		double d,n;
		uint32_t percent;

		aprintf("DIA_working::update(uint32_t %lu,uint32_t %lu) called\n", cur, total);
		if(!total) return 0;

		d=total;
		n=cur;
		n=n*100.;

		n=n/d;

		percent=(uint32_t )floor(n);
		return update(percent);

}

uint8_t DIA_working::isAlive (void )
{
	return 1;
}

DIA_working::~DIA_working()
{
	closeDialog();
        
}

void DIA_working::closeDialog( void )
{
	


}
