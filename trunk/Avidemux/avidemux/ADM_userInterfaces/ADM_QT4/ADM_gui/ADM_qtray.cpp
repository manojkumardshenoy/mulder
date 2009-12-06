/***************************************************************************
                               ADM_qtray.cpp
                               -------------

    begin                : Tue Sep 2 2008
    copyright            : (C) 2008 by gruntster

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

#include <string.h>
#include <stdio.h>
#include <QtGui/QDialog>
#include <QtGui/QMenu>

#include "ADM_default.h"
#include "ADM_qtray.h"

#include "xpm/film1.xpm"
#include "xpm/film3.xpm"
#include "xpm/film5.xpm"
#include "xpm/film7.xpm"
#include "xpm/film9.xpm"
#include "xpm/film11.xpm"
#include "xpm/film13.xpm"
#include "xpm/film15.xpm"
#include "xpm/film17.xpm"
#include "xpm/film19.xpm"
#include "xpm/film21.xpm"
#include "xpm/film23.xpm"

extern void UI_deiconify(void);

void ADM_qtray_signalReceiver::restore(void)
{
	UI_deiconify();
	parent->showNormal();
}

void ADM_qtray_signalReceiver::iconActivated(QSystemTrayIcon::ActivationReason reason)
{
	if (reason == QSystemTrayIcon::DoubleClick)
		restore();
}

ADM_qtray::ADM_qtray(void* parent) : ADM_tray(parent)
{
	_parent = parent;
	lastIcon = 0;
	maxIcons = 12;

	pixmap = new QIcon[maxIcons];
	pixmap[0] = QIcon(QPixmap(xpm_film1));
	pixmap[1] = QIcon(QPixmap(xpm_film3));
	pixmap[2] = QIcon(QPixmap(xpm_film5));
	pixmap[3] = QIcon(QPixmap(xpm_film7));
	pixmap[4] = QIcon(QPixmap(xpm_film9));
	pixmap[5] = QIcon(QPixmap(xpm_film11));
	pixmap[6] = QIcon(QPixmap(xpm_film13));
	pixmap[7] = QIcon(QPixmap(xpm_film15));
	pixmap[8] = QIcon(QPixmap(xpm_film17));
	pixmap[9] = QIcon(QPixmap(xpm_film19));
	pixmap[10] = QIcon(QPixmap(xpm_film21));
	pixmap[11] = QIcon(QPixmap(xpm_film23));

	signalReceiver = new ADM_qtray_signalReceiver();
	signalReceiver->parent = (QDialog*)parent;
	QSystemTrayIcon* trayIcon = new QSystemTrayIcon(pixmap[0], (QObject*)parent);

	sys = trayIcon;

	trayIcon->setToolTip("Avidemux");

	openAction = new QAction(QT_TR_NOOP("Open Avidemux"), (QObject*)parent);
	QObject::connect(openAction, SIGNAL(triggered()), signalReceiver, SLOT(restore()));
	QObject::connect(trayIcon, SIGNAL(activated(QSystemTrayIcon::ActivationReason)), signalReceiver, SLOT(iconActivated(QSystemTrayIcon::ActivationReason)));

	trayIconMenu = new QMenu((QWidget*)parent);
	trayIconMenu->addAction(openAction);

	trayIcon->setContextMenu(trayIconMenu);
	trayIcon->show();
}

ADM_qtray::~ADM_qtray()
{
	delete (QSystemTrayIcon*)sys;
	delete signalReceiver;
	delete pixmap;
}

uint8_t ADM_qtray::setPercent(int percent)
{
	char percentS[40];

	sprintf(percentS, "Avidemux [%d%%]", percent);

	lastIcon++;

	if (lastIcon >= maxIcons)
		lastIcon = 0;

	((QSystemTrayIcon*)sys)->setIcon(pixmap[lastIcon]);
	((QSystemTrayIcon*)sys)->setToolTip(percentS);

	return 1;
}

uint8_t ADM_qtray::setStatus(int working)
{
	return 1;
}
