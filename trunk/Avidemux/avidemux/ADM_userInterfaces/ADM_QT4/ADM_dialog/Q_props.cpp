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

#include "Q_props.h"
#include "avi_vars.h"
#include "avidemutils.h"
#include "ADM_video/ADM_vidMisc.h"
#include "ADM_toolkitQt.h"

static const char *yesno[2]={QT_TR_NOOP("No"),QT_TR_NOOP("Yes")};
extern const char *getStrFromAudioCodec( uint32_t codec);

propWindow::propWindow(QWidget *parent) : QDialog(parent)
 {
     ui.setupUi(this);
     uint8_t gmc, qpel,vop;
 uint32_t info=0;
 uint32_t war,har;
 uint16_t hh, mm, ss, ms;
 char text[80];
 const char *s;
  
    text[0] = 0;
    if (!avifileinfo)
        return;
  
        // Fetch info
        info=video_body->getSpecificMpeg4Info();
        vop=!!(info & ADM_VOP_ON);
        qpel=!!(info & ADM_QPEL_ON);
        gmc=!!(info & ADM_GMC_ON);

#define FILLTEXT(a,b,c) {snprintf(text,79,b,c);ui.a->setText(QString::fromUtf8(text));}
#define FILLTEXT4(a,b,c,d) {snprintf(text,79,b,c,d);ui.a->setText(QString::fromUtf8(text));}
#define FILLTEXT5(a,b,c,d,e) {snprintf(text,79,b,c,d,e);ui.a->setText(QString::fromUtf8(text));}
        
        FILLTEXT4(labeImageSize,QT_TR_NOOP("%lu x %lu"), avifileinfo->width,avifileinfo->height);
        FILLTEXT(labelFrameRate, QT_TR_NOOP("%2.3f fps"), (float) avifileinfo->fps1000 / 1000.F);
        FILLTEXT(labelNbOfFrames,QT_TR_NOOP("%ld frames"), avifileinfo->nb_frames);
        FILLTEXT(label4CC, "%s",      fourCC::tostring(avifileinfo->fcc));
        if (avifileinfo->nb_frames)
          {
                frame2time(avifileinfo->nb_frames, avifileinfo->fps1000,
                          &hh, &mm, &ss, &ms);
                snprintf(text,79, QT_TR_NOOP("%02d:%02d:%02d.%03d"), hh, mm, ss, ms);
                ui.labelVideoDuration->setText(QString::fromUtf8(text));
          }
        war=video_body->getPARWidth();
        har=video_body->getPARHeight();
        getAspectRatioFromAR(war,har, &s);
		FILLTEXT5(LabelAspectRatio,QT_TR_NOOP("%s (%u:%u)"), s,war,har);
#define SET_YES(a,b) ui.a->setText(QString::fromUtf8(yesno[b]))
#define FILLQT_TR_NOOP(q) ui.q->setText(QString::fromUtf8(text));
        SET_YES(LabelPackedBitstream,vop);
        SET_YES(LabelQuarterPixel,qpel);
        SET_YES(LabelGMC,gmc);
        
         WAVHeader *wavinfo=NULL;
        if (currentaudiostream) wavinfo=currentaudiostream->getInfo();
          if(wavinfo)
          {
              
              switch (wavinfo->channels)
                {
                case 1:
		  sprintf(text, "%s", QT_TR_NOOP("Mono"));
                    break;
                case 2:
                    sprintf(text, "%s", QT_TR_NOOP("Stereo"));
                    break;
                default:
                    sprintf(text, "%d",wavinfo->channels);
                    break;
                }

                FILLQT_TR_NOOP(labelChannels);
                FILLTEXT(labelFrequency, QT_TR_NOOP("%lu Hz"), wavinfo->frequency);
                FILLTEXT4(labelBitrate, QT_TR_NOOP("%lu Bps / %lu kbps"), wavinfo->byterate,wavinfo->byterate * 8 / 1000);
                
                sprintf(text, "%s", getStrFromAudioCodec(wavinfo->encoding));
                FILLQT_TR_NOOP(labelACodec);

                // Duration in seconds too
                if(currentaudiostream && wavinfo->byterate>1)
                {
                        uint32_t l=currentaudiostream->getLength();
                        double du;
                        du=l;
                        du*=1000;
                        du/=wavinfo->byterate;
                        ms2time((uint32_t)floor(du), &hh, &mm, &ss, &ms);

						sprintf(text, QT_TR_NOOP("%02d:%02d:%02d.%03d"), hh, mm, ss, ms);
						FILLQT_TR_NOOP(labelAudioDuration);

						sprintf(text, QT_TR_NOOP("%.2f MB"), l / 1048576.F);
						FILLQT_TR_NOOP(labelFileSize);
                }

                SET_YES(labelVBR,currentaudiostream->isVBR());
        } else
          {
			  ui.groupBoxAudio->setEnabled(false);
          }
 }
/**
    \fn DIA_properties
    \brief Display dialog with file information (size, codec, duration etc....)
*/
void DIA_properties( void )
{

      if (playing)
        return;
      if (!avifileinfo)
        return;
     // Fetch info
     propWindow propwindow(qtLastRegisteredDialog());
	 qtRegisterDialog(&propwindow);
     propwindow.exec();
	 qtUnregisterDialog(&propwindow);
}  
//********************************************
//EOF
