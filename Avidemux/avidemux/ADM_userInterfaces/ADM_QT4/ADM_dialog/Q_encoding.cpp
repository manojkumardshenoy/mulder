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
#include <QtGui/QPushButton>
#include <QtGui/QCloseEvent>

#include "Q_encoding.h"
#include "prefs.h"
#include "DIA_working.h"
#include "DIA_encoding.h"
#include "DIA_coreToolkit.h"
#include "ADM_libraries/ADM_utilities/avidemutils.h"
#include "ADM_video/ADM_vidMisc.h"
#include "../ADM_gui/ADM_qtray.h"
#include "ADM_toolkitQt.h"

extern void UI_iconify(void);
extern void UI_deiconify(void);
extern void UI_purge(void);
static int stopReq=0;

encodingWindow::encodingWindow(QWidget *parent, bool useTray) : QDialog(parent, Qt::WindowTitleHint | Qt::WindowSystemMenuHint | Qt::WindowMinimizeButtonHint)
{
	this->useTray = useTray;
	ui.setupUi(this);

#ifndef __WIN32
	//check for root privileges
	if (getuid() == 0)
	{
		// set priority to normal, regardless of preferences
		ui.comboBoxPriority->setCurrentIndex(2);
	}
#endif

	ui.buttonBox->button(QDialogButtonBox::Cancel)->setText(tr("Pause / Abort"));

	connect(ui.checkBoxShutdown, SIGNAL(stateChanged(int)), this, SLOT(shutdownChanged(int)));
	connect(ui.buttonBox, SIGNAL(rejected()), this, SLOT(buttonPressed()));
	connect(ui.comboBoxPriority, SIGNAL(currentIndexChanged(int)), this, SLOT(priorityChanged(int)));

	// set priority
	uint32_t priority;

	prefs->get(PRIORITY_ENCODING,&priority);	

#ifndef __WIN32
	// check for root privileges
	if (getuid() == 0)
	{
		ui.comboBoxPriority->setCurrentIndex(priority);
	}
#else
	ui.comboBoxPriority->setCurrentIndex(priority);
#endif
 }

void encodingWindow::changeEvent(QEvent *event)
{
	if (event->type() == QEvent::WindowStateChange)
	{
		QDialog *parent = (QDialog*)this->parent();

		if (isMinimized())
		{
			if (useTray)
			{
				hide();
				UI_iconify();
			}
			else
				parent->showMinimized();
		}
		else
		{
			showNormal();
			parent->showNormal();
		}
	}
}

void encodingWindow::closeEvent(QCloseEvent *event)
{
	if (GUI_Alternate((char*)encodingWindow::tr("The encoding is paused. Do you want to resume or abort?").toUtf8().constData(),
		(char*)encodingWindow::tr("Resume").toUtf8().constData(), (char*)encodingWindow::tr("Abort").toUtf8().constData()))
	{
		stopReq = 0;
		event->ignore();
	}
	else
	{
		stopReq = 1;
		event->accept();
	}
}

void encodingWindow::buttonPressed(void)
{
	this->close();
}

void encodingWindow::priorityChanged(int priorityLevel)
{
#ifndef __WIN32
	if (getuid() != 0)
	{
		ui.comboBoxPriority->disconnect(SIGNAL(currentIndexChanged(int)));
		ui.comboBoxPriority->setCurrentIndex(2);
		connect(ui.checkBoxShutdown, SIGNAL(currentIndexChanged(int)), this, SLOT(priorityChanged(int)));

		GUI_Error_HIG(tr("Privileges Required").toUtf8().constData(), tr("Root privileges are required to perform this operation.").toUtf8().constData());

		return;
	}
#endif

	setpriority(PRIO_PROCESS, 0, ADM_getNiceValue(priorityLevel));
}

void encodingWindow::shutdownChanged(int state)
{
#ifndef __WIN32
	if (getuid() != 0)
	{
		ui.checkBoxShutdown->disconnect(SIGNAL(stateChanged(int)));
		ui.checkBoxShutdown->setCheckState(Qt::Unchecked);
		connect(ui.checkBoxShutdown, SIGNAL(stateChanged(int)), this, SLOT(shutdownChanged(int)));

		GUI_Error_HIG(tr("Privileges Required").toUtf8().constData(), tr("Root privileges are required to perform this operation.").toUtf8().constData());
	}
#endif
}

//*******************************************
#define WIDGET(x) (window->ui.x)
#define WRITEM(x,y) window->ui.x->setText(QString::fromUtf8(y))
#define WRITE(x) WRITEM(x,string)
/*************************************/
static char string[80];
static encodingWindow *window=NULL;
extern QDialog *QuiMainWindows;
DIA_encoding::DIA_encoding( uint32_t fps1000 )
{
	uint32_t useTray = 0;

	if (!prefs->get(FEATURE_USE_SYSTRAY, &useTray))
		useTray = 0;

        ADM_assert(window==NULL);
        stopReq=0;
        _lastnb=0;
        _totalSize=0;
        _audioSize=0;
        _videoSize=0;
        _current=0;
        window=new encodingWindow(qtLastRegisteredDialog(), useTray);
		qtRegisterDialog(window);

        setFps(fps1000);
		_originalPriority=getpriority(PRIO_PROCESS, 0);
        _lastTime=0;
        _lastFrame=0;
        _fps_average=0;
        _total=1000;

         window->setModal(TRUE);
		 window->show();

		 if (useTray)
		 {
			 window->hide();
			 UI_iconify();
			 tray = new ADM_qtray(window);
		 }
		 else
			 tray = NULL;
}
/**
    \fn setFps(uint32_t fps)
    \brief Memorize fps, it will be used later for bitrate computation
*/

void DIA_encoding::setFps(uint32_t fps)
{
        _roundup=(uint32_t )floor( (fps+999)/1000);
        _fps1000=fps;
        ADM_assert(_roundup<MAX_BR_SLOT);
        memset(_bitrate,0,sizeof(_bitrate));
        _bitrate_sum=0;
        _average_bitrate=0;
        
}

void DIA_stop( void)
{
        printf("Stop request\n");
        stopReq=1;
}
DIA_encoding::~DIA_encoding( )
{
	bool shutdownRequired = (window->ui.checkBoxShutdown->checkState() == Qt::Checked);

	setpriority(PRIO_PROCESS, 0, _originalPriority);

	qtUnregisterDialog(window);
	delete window;
	window=NULL;
	UI_deiconify();

	if (shutdownRequired && !stopReq)
	{
		DIA_working *work=new DIA_working(encodingWindow::tr("Shutting down").toUtf8().constData());
		bool performShutdown=true;

		for(int i = 0; i <= 30; i++)
		{
			if (work->isAlive())
			{
				GUI_Sleep(1000);
				work->update(i, 30);
			}
			else
			{
				performShutdown=false;
				break;
			}
		}

		if (performShutdown && shutdown())
		{
			GUI_Sleep(5000);
		}

		delete work;
	}
}
/**
    \fn setPhasis(const char *n)
    \brief Display parameters as phasis
*/

void DIA_encoding::setPhasis(const char *n)
{
          ADM_assert(window);
          WRITEM(labelPhasis,n);

}
/**
    \fn setAudioCodec(const char *n)
    \brief Display parameters as audio codec
*/

void DIA_encoding::setAudioCodec(const char *n)
{
          ADM_assert(window);
          WRITEM(labelAudCodec,n);
}
/**
    \fn setCodec(const char *n)
    \brief Display parameters as video codec
*/

void DIA_encoding::setCodec(const char *n)
{
          ADM_assert(window);
          WRITEM(labelVidCodec,n);
}
/**
    \fn setBitrate(uint32_t br,uint32_t globalbr)
    \brief Display parameters as instantaneous bitrate and average bitrate
*/

void DIA_encoding::setBitrate(uint32_t br,uint32_t globalbr)
{
          ADM_assert(window);
          snprintf(string,79,"%lu kB/s",br,globalbr);
          WRITE(labelVidBitrate);

}
/**
    \fn reset(void)
    \brief Reset everything, used for 2pass
*/

void DIA_encoding::reset(void)
{
          ADM_assert(window);
          _totalSize=0;
          _videoSize=0;
          _current=0;
}
/**
    \fn setContainer(const char *container)
    \brief Display parameter as container field
*/

void DIA_encoding::setContainer(const char *container)
{
        ADM_assert(window);
        WRITEM(labelContainer,container);
}
#define  ETA_SAMPLE_PERIOD 60000 //Use last n millis to calculate ETA
#define  GUI_UPDATE_RATE 500  
/**
    \fn setFrame(uint32_t nb,uint32_t size, uint32_t quant,uint32_t total)
    \brief Recompute and update everything concering video
*/

void DIA_encoding::setFrame(uint32_t nb,uint32_t size, uint32_t quant,uint32_t total)
{
          _total=total;
          _videoSize+=size;
          if(nb < _lastnb || _lastnb == 0) // restart ?
           {
                _lastnb = nb;
                clock.reset();
                _lastTime=clock.getElapsedMS();
                _lastFrame=0;
                _fps_average=0;
                _videoSize=size;
    
                _nextUpdate = _lastTime + GUI_UPDATE_RATE;
                _nextSampleStartTime=_lastTime + ETA_SAMPLE_PERIOD;
                _nextSampleStartFrame=0;
          } 
          _lastnb = nb;
          _current=nb%_roundup;
          _bitrate[_current].size=size;
          _bitrate[_current].quant=quant;
}
/**
    \fn updateUI(void)
    \brief Recompute and update all fields, especially ETA
*/

void DIA_encoding::updateUI(void)
{
uint32_t tim;

	   ADM_assert(window);
     	   //
           //	nb/total=timestart/totaltime -> total time =timestart*total/nb
           //
           //
           
           UI_purge();
          if(!_lastnb) return;
          
          tim=clock.getElapsedMS();
          if(_lastTime > tim) return;
          if( tim < _nextUpdate) return ; 
          _nextUpdate = tim+GUI_UPDATE_RATE;
  
          snprintf(string,79,"%lu",_lastnb);
          WIDGET(labelFrame)->setText(string);

          snprintf(string,79,"%lu",_total);
          WIDGET(labelTotalFrame)->setText(string);

		  snprintf(string,79,"%lu",_total);
          WIDGET(labelTotalFrame)->setText(string);

          // Average bitrate  on the last second
          uint32_t sum=0,aquant=0,gsum;
          for(int i=0;i<_roundup;i++)
          {
            sum+=_bitrate[i].size;
            aquant+=_bitrate[i].quant;
          }
          
          aquant/=_roundup;

          sum=(sum*8)/1000;

          // Now compute global average bitrate
          float whole=_videoSize,second;
            second=_lastnb;
            second/=_fps1000;
            second*=1000;
           
          whole/=second;
          whole/=1000;
          whole*=8;
      
          gsum=(uint32_t)whole;

          setBitrate(sum,gsum);
          setQuantIn(aquant);

          // compute fps
          uint32_t deltaFrame, deltaTime;
          deltaTime=tim-_lastTime;
          deltaFrame=_lastnb-_lastFrame;

          _fps_average    =(float)( deltaFrame*1000.0F / deltaTime ); 

          snprintf(string,79,"%.2f",_fps_average);
          WIDGET(labelFps)->setText(string);
  
          uint32_t   hh,mm,ss;
  
            double framesLeft=(_total-_lastnb);

			ms2time(tim,&hh,&mm,&ss);
			snprintf(string,79,"%02d:%02d:%02d",hh,mm,ss);
			WIDGET(labelElapsed)->setText(string);

            WIDGET(labelETA)->setText(ms2timedisplay((uint32_t) floor(0.5 + deltaTime * framesLeft / deltaFrame)));
  
           // Check if we should move on to the next sample period
          if (tim >= _nextSampleStartTime + ETA_SAMPLE_PERIOD ) {
            _lastTime=_nextSampleStartTime;
            _lastFrame=_nextSampleStartFrame;
            _nextSampleStartTime=tim;
            _nextSampleStartFrame=0;
          } else if (tim >= _nextSampleStartTime && _nextSampleStartFrame == 0 ) {
            // Store current point for use later as the next sample period.
            //
            _nextSampleStartTime=tim;
            _nextSampleStartFrame=_lastnb;
          }
          // update progress bar
            float f=_lastnb*100;
            f=f/_total;
            WIDGET(progressBar)->setValue((int)f);

			if(tray)
				tray->setPercent((int)f);
          
        _totalSize=_audioSize+_videoSize;
        setSize(_totalSize>>20);
        setAudioSizeIn((_audioSize>>20));
        setVideoSizeIn((_videoSize>>20));
        UI_purge();

}
/**
    \fn setQuantIn(int size)
    \brief display parameter as quantizer
*/

void DIA_encoding::setQuantIn(int size)
{
          ADM_assert(window);
          sprintf(string,"%lu",size);
          WRITE(labelQz);

}
/**
    \fn setSize(int size)
    \brief display parameter as total size
*/

void DIA_encoding::setSize(int size)
{
          ADM_assert(window);
          sprintf(string,"%lu MB",size);
          WRITE(labelTotalSize);

}
/**
    \fn setAudioSizeIn(int size)
    \brief display parameter as audio size
*/

void DIA_encoding::setAudioSizeIn(int size)
{
          ADM_assert(window);
          sprintf(string,"%lu MB",size);
          WRITE(labelAudioSize);

}
/**
    \fn setVideoSizeIn(int size)
    \brief display parameter as video size
*/

void DIA_encoding::setVideoSizeIn(int size)
{
          ADM_assert(window);
          sprintf(string,"%lu MB",size);
          WRITE(labelVideoSize);

}
/**
    \fn setAudioSize( uint32_t size)
    \brief set the total audio size as per parameter
*/

void DIA_encoding::setAudioSize(uint32_t size)
{
      _audioSize=size;
}
/**
    \fn isAlive( void )
    \brief return 0 if the window was killed or cancel button press, 1 otherwisearchForward
*/
uint8_t DIA_encoding::isAlive( void )
{
	if (!stopReq)
		updateUI();

	return !stopReq;
}

//********************************************
//EOF
