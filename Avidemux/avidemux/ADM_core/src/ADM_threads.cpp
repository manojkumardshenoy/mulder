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
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ADM_default.h"
#include "ADM_threads.h"

#define THR_CHECK(x) {int r=(x);if(r) {printf("Threading error :%d %s\n", \
                      r,strerror(r));exit(0);}}
//**************** Mutex *******************
admMutex::admMutex(const char *name)
{
  _name=name; // Should always be const, so it is okay to not copy
  THR_CHECK(pthread_mutex_init(&_tex,NULL));
  _locked=0;
}
admMutex::~admMutex()
{
  THR_CHECK(pthread_mutex_destroy(&_tex));
       
}

uint8_t admMutex::lock(void)
{
  int e;
  THR_CHECK(pthread_mutex_lock(&_tex));
  _locked=1;
  return 1;
}
uint8_t admMutex::unlock(void)
{
  _locked=0;      // Just informative, race possible here
  THR_CHECK(pthread_mutex_unlock(&_tex));
  return 1;
}
uint8_t admMutex::isLocked(void)
{
  return _locked;
}

//**************** Cond *******************

admCond::admCond( admMutex *tex )
{
  THR_CHECK(pthread_cond_init(&_cond,NULL));
  _condtex=tex;
  waiting=0;
  aborted=0;
}
admCond::~admCond()
{
  THR_CHECK(pthread_cond_destroy(&_cond));

}
uint8_t admCond::wait(void)
{
  if(aborted) return 0;
        // take sem
  ADM_assert(_condtex->isLocked());
  waiting=1;
  THR_CHECK(pthread_cond_wait(&_cond, &(_condtex->_tex)));
  waiting=0;
  _condtex->unlock();
  return 1;
}
uint8_t admCond::wakeup(void)
{
  THR_CHECK(pthread_cond_signal(&_cond));
  return 1;
}
uint8_t admCond::iswaiting( void)
{
  return waiting;
}
uint8_t admCond::abort( void )
{
  aborted=1;
  if(waiting) wakeup();
  return 1;

}
