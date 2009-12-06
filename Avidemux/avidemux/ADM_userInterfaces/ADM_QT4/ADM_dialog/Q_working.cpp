/***************************************************************************
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
#include <math.h>

#include "Q_working.h"
#include "ADM_video/ADM_vidMisc.h"
#include "ADM_toolkitQt.h"

extern void UI_purge(void);

workWindow::workWindow(QWidget *parent, DIA_working *working) : QDialog(parent)
{
	ui.setupUi(this);

	connect(ui.buttonBox, SIGNAL(rejected()), this, SLOT(closeDialog(void)));
	_working = working;
}

void workWindow::closeDialog(void)
{
	_working->closeDialog();
}

//*******************************************

DIA_working::DIA_working( void )
{
  workWindow *wind;
  wind=new workWindow(qtLastRegisteredDialog(), this);
  qtRegisterDialog(wind);
  _priv=(void *)wind;
  postCtor();
}
DIA_working::DIA_working( const char *title )
{
  workWindow *wind;
  wind=new workWindow(qtLastRegisteredDialog(), this);
  qtRegisterDialog(wind);
  _priv=(void *)wind;
  wind->setWindowTitle(QString::fromUtf8(title));
  postCtor();
}
void DIA_working :: postCtor( void )
{
  workWindow *wind=(workWindow *)_priv; ADM_assert(wind);
      wind->show();
      lastper=0;
      _nextUpdate=0;
}
uint8_t DIA_working::update(uint32_t percent)
{
		#define GUI_UPDATE_RATE 1000

        UI_purge();

        if(!_priv) return 1;
        if(!percent) return 0;
        if(percent==lastper)
        {

            return 0;
        }

        elapsed=_clock.getElapsedMS();

        if(elapsed<_nextUpdate) 
        {
          return 0;
        }

        _nextUpdate=elapsed+1000;
        lastper=percent;

		uint32_t hh,mm,ss;
		char string[9];

		ms2time(elapsed,&hh,&mm,&ss);
		sprintf(string,"%02d:%02d:%02d",hh,mm,ss);

        workWindow *wind=(workWindow *)_priv; ADM_assert(wind);
        wind->ui.labelTimeLeft->setText(ms2timedisplay((uint32_t) floor(((elapsed * 100.) / percent) - elapsed)));
		wind->ui.labelElapsed->setText(string);
        wind->ui.progressBar->setValue(percent);
       
        return 0;
}

uint8_t DIA_working::update(uint32_t cur, uint32_t total)
{
        double d,n;
        uint32_t percent;
        UI_purge();
        if(!_priv) return 1;
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
	return _priv != NULL;
}

DIA_working::~DIA_working()
{
    closeDialog();
}

void DIA_working::closeDialog( void )
{
	if (_priv)
	{
		QDialog* dialog = (QDialog*)_priv;

		_priv = NULL;
		dialog->accept();
		qtUnregisterDialog(dialog);
		delete dialog;
	}
}

//********************************************
//EOF
