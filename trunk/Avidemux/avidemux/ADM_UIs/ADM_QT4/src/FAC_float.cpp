/***************************************************************************
  FAC_toggle.cpp
  Handle dialog factory element : Toggle
  (C) 2006 Mean Fixounet@free.fr 
***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/


#include <QtGui/QGridLayout>
#include <QtGui/QLabel>
#include <QtGui/QSpinBox>

#include "ADM_default.h"
#include "DIA_factory.h"
#include "ADM_dialogFactoryQt4.h"

extern const char *shortkey(const char *);

namespace ADM_qt4Factory
{


class diaElemFloat : public diaElem
{
protected:
	int decimals;

public:
  ELEM_TYPE_FLOAT min,max;
  diaElemFloat(ELEM_TYPE_FLOAT *intValue,const char *toggleTitle, ELEM_TYPE_FLOAT min, 
               ELEM_TYPE_FLOAT max,const char *tip=NULL, int decimals = 2);
  virtual ~diaElemFloat() ;
  void setMe(void *dialog, void *opaque,uint32_t line);
  void getMe(void);
  void      enable(uint32_t onoff) ;
  int getRequiredLayout(void);
  void updateMe(void);
};


//********************************************************************
diaElemFloat::diaElemFloat(ELEM_TYPE_FLOAT *intValue,const char *toggleTitle, ELEM_TYPE_FLOAT min, ELEM_TYPE_FLOAT max,const char *tip, int decimals)
  : diaElem(ELEM_TOGGLE)
{
  param=(void *)intValue;
  paramTitle=shortkey(toggleTitle);
  this->min=min;
  this->max=max;
  this->tip=tip;
  this->decimals = decimals;
 }

diaElemFloat::~diaElemFloat()
{
  if(paramTitle)
    delete paramTitle;
}
void diaElemFloat::setMe(void *dialog, void *opaque,uint32_t line)
{
  QDoubleSpinBox *box=new QDoubleSpinBox((QWidget *)dialog);
  QGridLayout *layout=(QGridLayout*) opaque;
  QHBoxLayout *hboxLayout = new QHBoxLayout();
 myWidget=(void *)box; 
   
 box->setMinimum(min);
 box->setMaximum(max);
 box->setDecimals(decimals);
 box->setSingleStep(0.1);
 box->setValue(*(ELEM_TYPE_FLOAT *)param);
 
 QLabel *text=new QLabel( QString::fromUtf8(this->paramTitle),(QWidget *)dialog);
 text->setBuddy(box);

 QSpacerItem *spacer = new QSpacerItem(20, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

 hboxLayout->addWidget(box);
 hboxLayout->addItem(spacer);

 layout->addWidget(text,line,0);
 layout->addLayout(hboxLayout,line,1);
 
}
void diaElemFloat::getMe(void)
{
  double val;
 QDoubleSpinBox *box=(QDoubleSpinBox *)myWidget;
 val=box->value();
 if(val<min) val=min;
 if(val>max) val=max;
 *(ELEM_TYPE_FLOAT *)param=val;
 
}
void diaElemFloat::enable(uint32_t onoff) 
{
   QDoubleSpinBox *box=(QDoubleSpinBox *)myWidget;
  ADM_assert(box);
  if(onoff)
    box->setEnabled(1);
  else
    box->setDisabled(1);
}

int diaElemFloat::getRequiredLayout(void) { return FAC_QT_GRIDLAYOUT; }

void diaElemFloat::updateMe(void)
{
	QDoubleSpinBox *box = (QDoubleSpinBox*)myWidget;

	box->setValue(*(ELEM_TYPE_FLOAT*)param);
}

} // End of namespace
//****************************Hoook*****************

diaElem  *qt4CreateFloat(ELEM_TYPE_FLOAT *intValue,const char *toggleTitle, ELEM_TYPE_FLOAT min,
        ELEM_TYPE_FLOAT max,const char *tip, int decimals)
{
	return new  ADM_qt4Factory::diaElemFloat(intValue,toggleTitle,min,max,tip, decimals);
}
void qt4DestroyFloat(diaElem *e)
{
	ADM_qt4Factory::diaElemFloat *a=(ADM_qt4Factory::diaElemFloat *)e;
	delete a;
}
