#ifndef Q_crop_h
#define Q_crop_h
#include "DIA_flyDialog.h"
#include "ui_crop.h"
#include "ADM_image.h"
#include "ADM_videoFilter.h"

#include "DIA_flyDialogQt4.h"
#include "DIA_flyCrop.h"
#include "ADM_vidCrop_param.h"
#if 1
class Ui_cropWindow : public QDialog
{
	Q_OBJECT

protected: 
	int lock;

public:
	flyCrop *myCrop;
	ADM_QCanvas *canvas;
	Ui_cropWindow(QWidget *parent, CROP_PARAMS *param,AVDMGenericVideoStream *in);
	~Ui_cropWindow();
	Ui_cropDialog ui;

public slots:
	void gather(CROP_PARAMS *param);

private slots:
	void sliderUpdate(int foo);
	void valueChanged(int foo);
	void autoCrop(bool f);
	void reset(bool f);
};

#endif	// Q_crop_h
#endif

