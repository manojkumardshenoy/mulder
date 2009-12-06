/** *************************************************************************
    \fn 	ADM_dynamicLoading.h
    \brief 	Wrapper for dlopen & friends  
                      
    copyright            : (C) 2008 by Gruntster
    
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 ***************************************************************************/

#ifndef ADM_DYNAMICLOADING_H
#define ADM_DYNAMICLOADING_H

class ADM_LibWrapper
{
	protected:
		void* hinstLib;
		bool initialised;

	#ifdef __WIN32
		virtual char* formatMessage(uint32_t msgCode);
	#endif

		ADM_LibWrapper();
		virtual ~ADM_LibWrapper();		
		virtual bool loadLibrary(const char* path);
		virtual void* getSymbol(const char* name);
		virtual bool getSymbols(int symCount, ...);

	public:
		virtual bool isAvailable();
};

#endif
