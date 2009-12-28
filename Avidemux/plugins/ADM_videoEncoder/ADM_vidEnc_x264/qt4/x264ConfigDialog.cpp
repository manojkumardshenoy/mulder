/***************************************************************************
                         Q_x264.cpp  -  description
                         --------------------------

                          GUI for configuring x264

    begin                : Tue May 18 2008
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

#include <math.h>
#include <QtGui/QFileDialog>

#include "../config.h"
#include "x264ConfigDialog.h"
#include "x264CustomMatrixDialog.h"

#include "ADM_inttype.h"
#include "ADM_files.h"
#include "DIA_coreToolkit.h"
#include "DIA_fileSel.h"

// Stay away from ADM_assert.h since it hacks memory functions.
// Duplicating ADM_mkdir declaration here instead.
extern "C" {
extern uint8_t ADM_mkdir(const char *name);
}

x264ConfigDialog::x264ConfigDialog(vidEncConfigParameters *configParameters, vidEncVideoProperties *properties, vidEncOptions *encodeOptions, x264Options *options) :
	QDialog((QWidget*)configParameters->parent, Qt::Dialog)
{
	disableGenericSlots = false;
	static const int _predefinedARs[aspectRatioCount][2] = {{16, 15}, {64, 45}, {8, 9}, {32, 27}};

	// Mappings for x264 array index -> UI combobox index
	static const int8_t _idcLevel[idcLevelCount] = {-1, 10, 11, 12, 13, 20, 21, 22, 30, 31, 32, 40, 41, 42, 50, 51};
	static const uint8_t _videoFormat[videoFormatCount] = {5, 0, 1, 2, 3, 4};
	static const uint8_t _colourPrimaries[colourPrimariesCount] = {2, 1, 4, 5, 6, 7, 8};
	static const uint8_t _transferCharacteristics[transferCharacteristicsCount] = {2, 1, 4, 5, 8, 9, 10, 6, 7};
	static const uint8_t _colourMatrix[colourMatrixCount] = {2, 1, 4, 5, 6, 7, 0, 8};

	memcpy(predefinedARs, _predefinedARs, sizeof(predefinedARs));
	memcpy(idcLevel, _idcLevel, sizeof(idcLevel));
	memcpy(videoFormat, _videoFormat, sizeof(videoFormat));
	memcpy(colourPrimaries, _colourPrimaries, sizeof(colourPrimaries));
	memcpy(transferCharacteristics, _transferCharacteristics, sizeof(transferCharacteristics));	
	memcpy(colourMatrix, _colourMatrix, sizeof(colourMatrix));	

	ui.setupUi(this);

	connect(ui.configurationComboBox, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationComboBox_currentIndexChanged(int)));
	connect(ui.saveAsButton, SIGNAL(pressed()), this, SLOT(saveAsButton_pressed()));
	connect(ui.deleteButton, SIGNAL(pressed()), this, SLOT(deleteButton_pressed()));

	// General tab
	lastBitrate = 1500;
	lastVideoSize = 700;

	connect(ui.encodingModeComboBox, SIGNAL(currentIndexChanged(int)), this, SLOT(encodingModeComboBox_currentIndexChanged(int)));
	connect(ui.quantiserSlider, SIGNAL(valueChanged(int)), this, SLOT(quantiserSlider_valueChanged(int)));
	connect(ui.quantiserSpinBox, SIGNAL(valueChanged(int)), this, SLOT(quantiserSpinBox_valueChanged(int)));
	connect(ui.targetRateControlSpinBox, SIGNAL(valueChanged(int)), this, SLOT(targetRateControlSpinBox_valueChanged(int)));

#if X264_BUILD >= 69
	connect(ui.mbTreeCheckBox, SIGNAL(toggled(bool)), this, SLOT(mbTreeCheckBox_toggled(bool)));
#else
	ui.mbTreeCheckBox->setVisible(false);
	ui.lblLookahead->setVisible(false);
	ui.lookaheadSpinBox->setVisible(false);
	ui.lblLookaheadFrames->setVisible(false);
#endif

#if X264_BUILD < 75
	ui.threadedLookaheadCheckBox->setVisible(false);
	ui.threadedLookaheadSpinBox->setVisible(false);
	ui.lblThreadedFrames->setVisible(false);
#endif

	ui.sarAsInputLabel->setText(QString("%1:%2").arg(properties->parWidth).arg(properties->parHeight));

	// Motion Estimation tab
	connect(ui.meSlider, SIGNAL(valueChanged(int)), this, SLOT(meSlider_valueChanged(int)));
	connect(ui.meSpinBox, SIGNAL(valueChanged(int)), this, SLOT(meSpinBox_valueChanged(int)));
	connect(ui.dct8x8CheckBox, SIGNAL(toggled(bool)), this, SLOT(dct8x8CheckBox_toggled(bool)));
	connect(ui.p8x8CheckBox, SIGNAL(toggled(bool)), this, SLOT(p8x8CheckBox_toggled(bool)));

	ui.scenecutDetectionCheckBox->setVisible(false);

#if X264_BUILD < 79
	ui.lblWeightedPPredict->setVisible(false);
	ui.weightedPPredictComboBox->setVisible(false);
#endif

	// Frame tab
	connect(ui.loopFilterCheckBox, SIGNAL(toggled(bool)), this, SLOT(loopFilterCheckBox_toggled(bool)));
	connect(ui.cabacCheckBox, SIGNAL(toggled(bool)), this, SLOT(cabacCheckBox_toggled(bool)));

#if X264_BUILD < 77
	ui.constrainedIntraCheckBox->setVisible(false);
#endif

#if X264_BUILD < 78
	ui.bFrameRefComboBox->clear();
	ui.bFrameRefComboBox->addItem(QT_TR_NOOP("Disabled"));
	ui.bFrameRefComboBox->addItem(QT_TR_NOOP("Enabled"));
#endif

	// Analysis tab
	connect(ui.trellisCheckBox, SIGNAL(toggled(bool)), this, SLOT(trellisCheckBox_toggled(bool)));
	connect(ui.matrixCustomEditButton, SIGNAL(pressed()), this, SLOT(matrixCustomEditButton_pressed()));

	// Quantiser tab
#if X264_BUILD >= 69
	connect(ui.aqVarianceCheckBox, SIGNAL(toggled(bool)), this, SLOT(aqVarianceCheckBox_toggled(bool)));
#endif

	// Advanced tab
	ui.zoneTableView->sortByColumn(0, Qt::AscendingOrder);
	ui.zoneTableView->setModel(&zoneTableModel);
	ui.zoneTableView->setItemDelegate(&zoneTableDelegate);

	ui.zoneTableView->setColumnWidth(0, 80);
	ui.zoneTableView->setColumnWidth(1, 80);
	ui.zoneTableView->setColumnWidth(2, 100);
	ui.zoneTableView->setColumnWidth(3, 80);

	connect(ui.zoneAddButton, SIGNAL(pressed()), this, SLOT(zoneAddButton_pressed()));
	connect(ui.zoneEditButton, SIGNAL(pressed()), this, SLOT(zoneEditButton_pressed()));
	connect(ui.zoneDeleteButton, SIGNAL(pressed()), this, SLOT(zoneDeleteButton_pressed()));

#if X264_BUILD < 73
	ui.slicingGroupBox->setEnabled(false);
#endif

	QWidgetList widgetList = QApplication::allWidgets();

	for (int widgetIndex = 0; widgetIndex < widgetList.size(); widgetIndex++)
	{
		QWidget *widget = widgetList.at(widgetIndex);

		if (widget->parentWidget() != NULL && widget->parentWidget()->parentWidget() != NULL && 
			widget->parentWidget()->parentWidget()->parentWidget() != NULL &&
			widget->parentWidget()->parentWidget()->parentWidget()->parentWidget() == ui.tabWidget)
		{
			if (widget->inherits("QComboBox"))
				connect(widget, SIGNAL(currentIndexChanged(int)), this, SLOT(generic_currentIndexChanged(int)));
			else if (widget->inherits("QSpinBox"))
				connect(widget, SIGNAL(valueChanged(int)), this, SLOT(generic_valueChanged(int)));
			else if (widget->inherits("QDoubleSpinBox"))
				connect(widget, SIGNAL(valueChanged(double)), this, SLOT(generic_valueChanged(double)));
			else if (widget->inherits("QCheckBox"))
				connect(widget, SIGNAL(pressed()), this, SLOT(generic_pressed()));
			else if (widget->inherits("QRadioButton"))
				connect(widget, SIGNAL(pressed()), this, SLOT(generic_pressed()));
			else if (widget->inherits("QLineEdit"))
				connect(widget, SIGNAL(textEdited(QString)), this, SLOT(generic_textEdited(QString)));
		}
	}

	fillConfigurationComboBox();

	if (!loadPresetSettings(encodeOptions, options))
		loadSettings(encodeOptions, options);
}

void x264ConfigDialog::fillConfigurationComboBox(void)
{
	bool origDisableGenericSlots = disableGenericSlots;
	QMap<QString, int> configs;
	QStringList filter("*.xml");
	x264Options options;
	char* configDir = options.getUserConfigDirectory();
	QStringList list = QDir(configDir).entryList(filter, QDir::Files | QDir::Readable);

	delete [] configDir;
	disableGenericSlots = true;

	for (int item = 0; item < list.size(); item++)
		configs.insert(QFileInfo(list[item]).completeBaseName(), PLUGIN_CONFIG_USER);

	configDir = options.getSystemConfigDirectory();
	list = QDir(configDir).entryList(filter, QDir::Files | QDir::Readable);

	delete [] configDir;

	for (int item = 0; item < list.size(); item++)
		configs.insert(QFileInfo(list[item]).completeBaseName(), PLUGIN_CONFIG_SYSTEM);

	ui.configurationComboBox->clear();
	ui.configurationComboBox->addItem(QT_TR_NOOP("<default>"), PLUGIN_CONFIG_DEFAULT);
	ui.configurationComboBox->addItem(QT_TR_NOOP("<custom>"), PLUGIN_CONFIG_CUSTOM);

	QMap<QString, int>::const_iterator mapIterator = configs.constBegin();

	while (mapIterator != configs.constEnd())
	{
		ui.configurationComboBox->addItem(mapIterator.key(), mapIterator.value());
		mapIterator++;
	}

	disableGenericSlots = origDisableGenericSlots;
}

bool x264ConfigDialog::selectConfiguration(QString *selectFile, PluginConfigType configurationType)
{
	bool success = false;
	bool origDisableGenericSlots = disableGenericSlots;

	disableGenericSlots = true;

	if (configurationType == PLUGIN_CONFIG_DEFAULT)
	{
		ui.configurationComboBox->setCurrentIndex(0);
		success = true;
	}
	else
	{
		for (int index = 0; index < ui.configurationComboBox->count(); index++)
		{
			if (ui.configurationComboBox->itemText(index) == selectFile && ui.configurationComboBox->itemData(index).toInt() == configurationType)
			{
				ui.configurationComboBox->setCurrentIndex(index);
				success = true;
				break;
			}
		}

		if (!success)
			ui.configurationComboBox->setCurrentIndex(1);
	}

	disableGenericSlots = origDisableGenericSlots;

	return success;
}

void x264ConfigDialog::generic_currentIndexChanged(int index)
{
	if (!disableGenericSlots)
		ui.configurationComboBox->setCurrentIndex(1);
}

void x264ConfigDialog::generic_valueChanged(int value)
{
	if (!disableGenericSlots)
		ui.configurationComboBox->setCurrentIndex(1);
}

void x264ConfigDialog::generic_valueChanged(double value)
{
	if (!disableGenericSlots)
		ui.configurationComboBox->setCurrentIndex(1);
}

void x264ConfigDialog::generic_pressed(void)
{
	if (!disableGenericSlots)
		ui.configurationComboBox->setCurrentIndex(1);
}

void x264ConfigDialog::generic_textEdited(QString text)
{
	if (!disableGenericSlots)
		ui.configurationComboBox->setCurrentIndex(1);
}

void x264ConfigDialog::configurationComboBox_currentIndexChanged(int index)
{
	bool origDisableGenericSlots = disableGenericSlots;

	disableGenericSlots = true;

	if (index == 0)		// default
	{
		ui.deleteButton->setEnabled(false);

		x264Options defaultOptions;
		vidEncOptions *defaultEncodeOptions = defaultOptions.getEncodeOptions();

		loadSettings(defaultEncodeOptions, &defaultOptions);

		delete defaultEncodeOptions;
	}
	else if (index == 1)	// custom
		ui.deleteButton->setEnabled(false);
	else
	{
		PluginConfigType configType = (PluginConfigType)ui.configurationComboBox->itemData(index).toInt();

		ui.deleteButton->setEnabled(configType == PLUGIN_CONFIG_USER);

		x264Options options;
		vidEncOptions *encodeOptions;

		options.setPresetConfiguration(ui.configurationComboBox->itemText(index).toUtf8().constData(), configType);

		if (options.loadPresetConfiguration())
		{
			encodeOptions = options.getEncodeOptions();

			loadSettings(encodeOptions, &options);

			delete encodeOptions;
		}
		else
			ui.configurationComboBox->setCurrentIndex(0);
	}

	disableGenericSlots = origDisableGenericSlots;
}

void x264ConfigDialog::saveAsButton_pressed(void)
{
	char *configDirectory = ADM_getHomeRelativePath("x264");

	ADM_mkdir(configDirectory);

	QString configFileName = QFileDialog::getSaveFileName(this, QT_TR_NOOP("Save As"), configDirectory, QT_TR_NOOP("x264 Configuration File (*.xml)"));

	if (!configFileName.isNull())
	{
		QFile configFile(configFileName);
		vidEncOptions encodeOptions;
		x264Options options;

		configFile.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text);
		saveSettings(&encodeOptions, &options);
		options.setEncodeOptions(&encodeOptions);

		char* xml = options.toXml(PLUGIN_XML_EXTERNAL);

		configFile.write(xml, strlen(xml));
		configFile.close();

		delete [] xml;

		fillConfigurationComboBox();
		selectConfiguration(&QFileInfo(configFileName).completeBaseName(), PLUGIN_CONFIG_USER);
	}

	delete [] configDirectory;
}

void x264ConfigDialog::deleteButton_pressed(void)
{
	x264Options options;
	char *configDir = options.getUserConfigDirectory();
	QString configFileName = QFileInfo(QString(configDir), ui.configurationComboBox->currentText() + ".xml").filePath();
	QFile configFile(configFileName);

	delete [] configDir;

	if (GUI_Question(QT_TR_NOOP("Are you sure you wish to delete the selected configuration?")) && configFile.exists())
	{
		disableGenericSlots = true;
		configFile.remove();
		ui.configurationComboBox->removeItem(ui.configurationComboBox->currentIndex());
		disableGenericSlots = false;
		ui.configurationComboBox->setCurrentIndex(0);	// default
	}
}

// General tab
void x264ConfigDialog::encodingModeComboBox_currentIndexChanged(int index)
{
	bool enable = false;

	switch (index)
	{
		case 0:
			ui.targetRateControlLabel1->setText(QT_TR_NOOP("Target Bitrate:"));
			ui.targetRateControlLabel2->setText(QT_TR_NOOP("kbit/s"));
			ui.targetRateControlSpinBox->setValue(lastBitrate);
			break;
		case 1: // Constant Quality - 1 pass
			ui.quantiserLabel2->setText(QT_TR_NOOP("Quantiser:"));
			enable = true;
			break;
		case 2: // Average Quantiser - 1 pass
			ui.quantiserLabel2->setText(QT_TR_NOOP("Quality:"));
			enable = true;
			break;
		case 3: // Video Size - 2 pass
			ui.targetRateControlLabel1->setText(QT_TR_NOOP("Target Video Size:"));
			ui.targetRateControlLabel2->setText(QT_TR_NOOP("MB"));
			ui.targetRateControlSpinBox->setValue(lastVideoSize);
			break;
		case 4: // Average Bitrate - 2 pass
			ui.targetRateControlLabel1->setText(QT_TR_NOOP("Average Bitrate:"));
			ui.targetRateControlLabel2->setText(QT_TR_NOOP("kbit/s"));
			ui.targetRateControlSpinBox->setValue(lastBitrate);
			break;
	}

	ui.quantiserLabel1->setEnabled(enable);
	ui.quantiserLabel2->setEnabled(enable);
	ui.quantiserLabel3->setEnabled(enable);
	ui.quantiserSlider->setEnabled(enable);
	ui.quantiserSpinBox->setEnabled(enable);

	ui.targetRateControlLabel1->setEnabled(!enable);
	ui.targetRateControlLabel2->setEnabled(!enable);
	ui.targetRateControlSpinBox->setEnabled(!enable);
}

void x264ConfigDialog::quantiserSlider_valueChanged(int value)
{
	ui.quantiserSpinBox->setValue(value);
}

void x264ConfigDialog::quantiserSpinBox_valueChanged(int value)
{
	ui.quantiserSlider->setValue(value);
}

void x264ConfigDialog::targetRateControlSpinBox_valueChanged(int value)
{
	if (ui.encodingModeComboBox->currentIndex() == 3)	// Video Size - 2 pass
		lastVideoSize = value;
	else
		lastBitrate = value;
}

#if X264_BUILD >= 69
void x264ConfigDialog::mbTreeCheckBox_toggled(bool checked)
{
	if (!disableGenericSlots && checked && !ui.aqVarianceCheckBox->isChecked())
		if (GUI_Question(QT_TR_NOOP("Macroblock-Tree optimisation requires Variance Adaptive Quantisation to be enabled.  Variance Adaptive Quantisation will automatically be enabled.\n\nDo you wish to continue?")))
			ui.aqVarianceCheckBox->setChecked(true);
		else
			ui.mbTreeCheckBox->setChecked(false);
}
#endif

// Motion Estimation tab
void x264ConfigDialog::meSlider_valueChanged(int value)
{
	ui.meSpinBox->setValue(value);
}

void x264ConfigDialog::meSpinBox_valueChanged(int value)
{
	ui.meSlider->setValue(value);
}

void x264ConfigDialog::dct8x8CheckBox_toggled(bool checked)
{
	if (!checked)
	{
		ui.i8x8CheckBox->setChecked(false);
		ui.i8x8CheckBox->setEnabled(false);
	}
}

void x264ConfigDialog::p8x8CheckBox_toggled(bool checked)
{
	if (!checked)
		ui.p4x4CheckBox->setChecked(false);
}

// Frame tab
void x264ConfigDialog::loopFilterCheckBox_toggled(bool checked)
{
	if (!checked)
	{
		ui.alphaC0SpinBox->setValue(0);
		ui.betaSpinBox->setValue(0);
	}
}

void x264ConfigDialog::cabacCheckBox_toggled(bool checked)
{
	if (!disableGenericSlots && !checked && ui.trellisCheckBox->isChecked())
		if (GUI_Question(QT_TR_NOOP("Trellis optimisation isn't possible without CABAC coding enabled.  Trellis optimisation will automatically be disabled.\n\n Do you wish to continue?")))
			ui.trellisCheckBox->setChecked(false);
		else
			ui.cabacCheckBox->setChecked(true);
}

// Analysis tab
void x264ConfigDialog::trellisCheckBox_toggled(bool checked)
{
	if (!disableGenericSlots && checked && !ui.cabacCheckBox->isChecked())
		if (GUI_Question(QT_TR_NOOP("Trellis optimisation requires CABAC coding to be enabled.  CABAC coding will automatically be enabled.\n\nDo you wish to continue?")))
			ui.cabacCheckBox->setChecked(true);
		else
			ui.trellisCheckBox->setChecked(false);
}

void x264ConfigDialog::matrixCustomEditButton_pressed()
{
	x264CustomMatrixDialog dialog(this, intra4x4Luma, intraChroma, inter4x4Luma, interChroma, intra8x8Luma, inter8x8Luma);

	if (dialog.exec() == QDialog::Accepted)
	{
		dialog.getMatrix(intra4x4Luma, intraChroma, inter4x4Luma, interChroma, intra8x8Luma, inter8x8Luma);
		ui.configurationComboBox->setCurrentIndex(1);
	}
}

// Quantiser tab
#if X264_BUILD >= 69
void x264ConfigDialog::aqVarianceCheckBox_toggled(bool checked)
{
	if (!disableGenericSlots && !checked && ui.mbTreeCheckBox->isChecked())
		if (GUI_Question(QT_TR_NOOP("Macroblock-Tree optimisation requires Variance Adaptive Quantisation to be enabled.  Macroblock-Tree optimisation will automatically be disabled.\n\nDo you wish to continue?")))
			ui.mbTreeCheckBox->setChecked(false);
		else
			ui.aqVarianceCheckBox->setChecked(true);
}
#endif

// Advanced tab
void x264ConfigDialog::zoneAddButton_pressed()
{
	zoneTableModel.insertRows(0, 1, QModelIndex());
	ui.zoneTableView->selectRow(0);
	ui.zoneTableView->edit(ui.zoneTableView->currentIndex());
	ui.configurationComboBox->setCurrentIndex(1);
}

void x264ConfigDialog::zoneEditButton_pressed()
{
	ui.zoneTableView->edit(ui.zoneTableView->currentIndex());
	ui.configurationComboBox->setCurrentIndex(1);
}

void x264ConfigDialog::zoneDeleteButton_pressed()
{
	if (ui.zoneTableView->currentIndex().row() >= 0 && GUI_Question(QT_TR_NOOP("Are you sure you wish to delete the selected zone?")))
	{
		zoneTableModel.removeRows(ui.zoneTableView->currentIndex().row(), 1, QModelIndex());
		ui.configurationComboBox->setCurrentIndex(1);
	}
}

int x264ConfigDialog::getValueIndexInArray(uint8_t value, const uint8_t valueArray[], int elementCount)
{
	int valueIndex = -1;

	for (int index = 0; index < elementCount; index++)
	{
		if (valueArray[index] == value)
		{
			valueIndex = index;
			break;
		}
	}

	return valueIndex;
}

int x264ConfigDialog::getValueIndexInArray(int8_t value, const int8_t valueArray[], int elementCount)
{
	int valueIndex = -1;

	for (int index = 0; index < elementCount; index++)
	{
		if (valueArray[index] == value)
		{
			valueIndex = index;
			break;
		}
	}

	return valueIndex;
}

bool x264ConfigDialog::loadPresetSettings(vidEncOptions *encodeOptions, x264Options *options)
{
	bool origDisableGenericSlots = disableGenericSlots;
	char *configurationName;
	PluginConfigType configurationType;

	disableGenericSlots = true;
	options->getPresetConfiguration(&configurationName, &configurationType);

	bool foundConfig = selectConfiguration(&QString(configurationName), configurationType);

	if (!foundConfig)
		printf("Configuration %s (type %d) could not be found.  Using snapshot.\n", configurationName, configurationType);

	if (configurationName)
		delete [] configurationName;

	disableGenericSlots = origDisableGenericSlots;

	return (foundConfig && configurationType != PLUGIN_CONFIG_CUSTOM);
}

void x264ConfigDialog::loadSettings(vidEncOptions *encodeOptions, x264Options *options)
{
	bool origDisableGenericSlots = disableGenericSlots;

	disableGenericSlots = true;

	// General tab
	switch (encodeOptions->encodeMode)
	{
		case ADM_VIDENC_MODE_CBR:	// Constant Bitrate (Single Pass)
			ui.encodingModeComboBox->setCurrentIndex(0);
			ui.targetRateControlSpinBox->setValue(encodeOptions->encodeModeParameter);
			break;
		case ADM_VIDENC_MODE_CQP:	// Constant Quality (Single Pass)
			ui.encodingModeComboBox->setCurrentIndex(1);
			ui.quantiserSpinBox->setValue(encodeOptions->encodeModeParameter);
			break;
		case ADM_VIDENC_MODE_AQP:	// Average Quantizer (Single Pass)
			ui.encodingModeComboBox->setCurrentIndex(2);
			ui.quantiserSpinBox->setValue(encodeOptions->encodeModeParameter);
			break;
		case ADM_VIDENC_MODE_2PASS_SIZE:	// Video Size (Two Pass)
			ui.encodingModeComboBox->setCurrentIndex(3);
			ui.targetRateControlSpinBox->setValue(encodeOptions->encodeModeParameter);
			break;
		case ADM_VIDENC_MODE_2PASS_ABR:	// Average Bitrate (Two Pass)
			ui.encodingModeComboBox->setCurrentIndex(4);
			ui.targetRateControlSpinBox->setValue(encodeOptions->encodeModeParameter);
			break;
	}

#if X264_BUILD >= 69
	ui.mbTreeCheckBox->setChecked(options->getMbTree());
	ui.lookaheadSpinBox->setValue(options->getFrametypeLookahead());
#endif

	if (options->getSarAsInput())
		ui.sarAsInputRadioButton->setChecked(true);
	else
	{
		bool predefined = false;

		for (int ratioIndex = 0; ratioIndex < aspectRatioCount; ratioIndex++)
		{
			if (options->getSarWidth() == predefinedARs[ratioIndex][0] && options->getSarHeight() == predefinedARs[ratioIndex][1])
			{
				ui.sarPredefinedRadioButton->setChecked(true);
				ui.sarPredefinedComboBox->setCurrentIndex(ratioIndex);
				predefined = true;
				break;
			}
		}

		if (!predefined)
		{
			ui.sarCustomRadioButton->setChecked(true);
			ui.sarCustomSpinBox1->setValue(options->getSarWidth());
			ui.sarCustomSpinBox2->setValue(options->getSarHeight());
		}
	}

	switch (options->getThreads())
	{
		case 0:
			ui.threadAutoDetectRadioButton->setChecked(true);
			break;
		case 1:
			ui.threadDisableRadioButton->setChecked(true);
			break;
		default:
			ui.threadCustomRadioButton->setChecked(true);
			ui.threadCustomSpinBox->setValue(options->getThreads());
	}

#if X264_BUILD >= 75
	int threadedLookahead = options->getThreadedLookahead();

	ui.threadedLookaheadCheckBox->setChecked(threadedLookahead > -1);

	if (threadedLookahead > -1)
		ui.threadedLookaheadSpinBox->setValue(threadedLookahead);
#endif

	// Motion Estimation tab
	ui.meSpinBox->setValue(options->getSubpixelRefinement());
	ui.meMethodComboBox->setCurrentIndex(options->getMotionEstimationMethod());
	ui.mvRangeSpinBox->setValue(options->getMotionVectorSearchRange());

	if (options->getMotionVectorLength() == -1)
		ui.mvLengthCheckBox->setChecked(false);
	else
	{
		ui.mvLengthCheckBox->setChecked(true);
		ui.mvLengthSpinBox->setValue(options->getMotionVectorLength());
	}

	if (options->getMotionVectorThreadBuffer() == -1)
		ui.minThreadBufferCheckBox->setChecked(false);
	else
	{
		ui.minThreadBufferCheckBox->setChecked(true);
		ui.minThreadBufferSpinBox->setValue(options->getMotionVectorThreadBuffer());
	}

	ui.predictModeComboBox->setCurrentIndex(options->getDirectPredictionMode());

#if X264_BUILD >= 79
	ui.weightedPPredictComboBox->setCurrentIndex(options->getWeightedPredictionPFrames());
#endif

	ui.weightedPredictCheckBox->setChecked(options->getWeightedPrediction());

	// Partition tab
	ui.p8x8CheckBox->setChecked(options->getPartitionP8x8());
	ui.b8x8CheckBox->setChecked(options->getPartitionB8x8());
	ui.p4x4CheckBox->setChecked(options->getPartitionP4x4());
	ui.i8x8CheckBox->setChecked(options->getPartitionI8x8());
	ui.i4x4CheckBox->setChecked(options->getPartitionI4x4());
	ui.dct8x8CheckBox->setChecked(options->getDct8x8());
	dct8x8CheckBox_toggled(options->getDct8x8());

	// Frame tab
	ui.cabacCheckBox->setChecked(options->getCabac());
	ui.interlacedCheckBox->setChecked(options->getInterlaced());

#if X264_BUILD >= 77
	ui.constrainedIntraCheckBox->setChecked(options->getConstrainedIntraPrediction());
#endif

	ui.loopFilterCheckBox->setChecked(options->getLoopFilter());
	ui.alphaC0SpinBox->setValue(options->getLoopFilterAlphaC0());
	ui.betaSpinBox->setValue(options->getLoopFilterBeta());
	ui.maxBFramesSpinBox->setValue(options->getBFrames());
	ui.BFrameBiasSpinBox->setValue(options->getBFrameBias());
	ui.refFramesSpinBox->setValue(options->getReferenceFrames());
	ui.bFrameRefComboBox->setCurrentIndex(options->getBFrameReferences());
	ui.adaptiveBFrameComboBox->setCurrentIndex(options->getAdaptiveBFrameDecision());
	ui.maxGopSizeSpinBox->setValue(options->getGopMaximumSize());
	ui.minGopSizeSpinBox->setValue(options->getGopMinimumSize());
	ui.IFrameThresholdSpinBox->setValue(options->getScenecutThreshold());

	// Analysis tab
	ui.mixedRefsCheckBox->setChecked(options->getMixedReferences());
	ui.chromaMotionEstCheckBox->setChecked(options->getChromaMotionEstimation());

	if (options->getTrellis() && options->getCabac())
	{
		ui.trellisCheckBox->setChecked(true);
		ui.trellisComboBox->setCurrentIndex(options->getTrellis() - 1);
	}
	else
		ui.trellisCheckBox->setChecked(false);

	ui.fastPSkipCheckBox->setChecked(options->getFastPSkip());
	ui.dctDecimateCheckBox->setChecked(options->getDctDecimate());
	ui.psychoRdoSpinBox->setValue(options->getPsychoRdo());

	ui.noiseReductionSpinBox->setValue(options->getNoiseReduction());
	ui.interLumaSpinBox->setValue(options->getInterLumaDeadzone());
	ui.intraLumaSpinBox->setValue(options->getIntraLumaDeadzone());

	switch (options->getCqmPreset())
	{
		case 0:
			ui.matrixFlatRadioButton->setChecked(true);
			break;
		case 1:
			ui.matrixJvtRadioButton->setChecked(true);
			break;
		case 2:
			ui.matrixCustomRadioButton->setChecked(true);
			break;
	}

	memcpy(intra4x4Luma, options->getIntra4x4Luma(), sizeof(intra4x4Luma));
	memcpy(intraChroma, options->getIntraChroma(), sizeof(intraChroma));
	memcpy(inter4x4Luma, options->getInter4x4Luma(), sizeof(inter4x4Luma));
	memcpy(interChroma, options->getInterChroma(), sizeof(interChroma));
	memcpy(intra8x8Luma, options->getIntra8x8Luma(), sizeof(intra8x8Luma));
	memcpy(inter8x8Luma, options->getInter8x8Luma(), sizeof(inter8x8Luma));

	// Quantiser tab
	ui.quantiserMinSpinBox->setValue(options->getQuantiserMinimum());
	ui.quantiserMaxSpinBox->setValue(options->getQuantiserMaximum());
	ui.quantiserMaxStepSpinBox->setValue(options->getQuantiserStep());
	ui.avgBitrateToleranceSpinBox->setValue((int)floor(options->getAverageBitrateTolerance() * 100 + .5));
	ui.quantiserIpRatioSpinBox->setValue(options->getIpFrameQuantiser());
	ui.quantiserPbRatioSpinBox->setValue(options->getPbFrameQuantiser());
	ui.chromaLumaOffsetSpinBox->setValue(options->getChromaLumaQuantiserDifference());
	ui.quantiserCurveCompressSpinBox->setValue((int)floor(options->getQuantiserCurveCompression() * 100 + .5));
	ui.quantiserBeforeCompressSpinBox->setValue(options->getReduceFluxBeforeCurveCompression());
	ui.quantiserAfterCompressSpinBox->setValue(options->getReduceFluxAfterCurveCompression());
	ui.aqVarianceCheckBox->setChecked(options->getAdaptiveQuantiserMode() == X264_AQ_VARIANCE);
	ui.aqStrengthSpinBox->setValue(options->getAdaptiveQuantiserStrength());

	// Advanced tab
	ui.vbvMaxBitrateSpinBox->setValue(options->getVbvMaximumBitrate());
	ui.vbvBufferSizeSpinBox->setValue(options->getVbvBufferSize());
	ui.vbvBufferOccupancySpinBox->setValue((int)floor(options->getVbvInitialOccupancy() * 100 + .5));

#if X264_BUILD >= 73
	ui.maxSliceSizeSpinBox->setValue(options->getSliceMaxSize());
	ui.maxSliceMbSpinBox->setValue(options->getSliceMaxMacroblocks());
	ui.slicesPerFrameSpinBox->setValue(options->getSliceCount());
#endif

	zoneTableModel.removeRows();

	int zoneCount = options->getZoneCount();

	if (zoneCount)
	{
		x264ZoneOptions** zoneOptions = options->getZones();

		zoneTableModel.insertRows(0, zoneCount, QModelIndex(), zoneOptions);

		delete [] zoneOptions;
	}

	// Output tab
	if (!options->getIdcLevel())
		options->setIdcLevel(51);

	ui.idcLevelComboBox->setCurrentIndex(getValueIndexInArray(options->getIdcLevel(), idcLevel, idcLevelCount));

	QString strSpsId;

	strSpsId.setNum(options->getSpsIdentifier());
	ui.spsiComboBox->setCurrentIndex(ui.spsiComboBox->findText(strSpsId));
	ui.repeatabilityCheckBox->setChecked(options->getDeterministic());
	ui.accessUnitCheckBox->setChecked(options->getAccessUnitDelimiters());
	ui.overscanComboBox->setCurrentIndex(options->getOverscan());
	ui.videoFormatComboBox->setCurrentIndex(getValueIndexInArray(options->getVideoFormat(), videoFormat, videoFormatCount));
	ui.colourPrimariesComboBox->setCurrentIndex(getValueIndexInArray(options->getColorPrimaries(), colourPrimaries, colourPrimariesCount));
	ui.transferCharacteristicsComboBox->setCurrentIndex(getValueIndexInArray(options->getTransfer(), transferCharacteristics, transferCharacteristicsCount));
	ui.colourMatrixComboBox->setCurrentIndex(getValueIndexInArray(options->getColorMatrix(), colourMatrix, colourMatrixCount));
	ui.chromaSampleSpinBox->setValue(options->getChromaSampleLocation());
	ui.fullRangeSamplesCheckBox->setChecked(options->getFullRangeSamples());

	disableGenericSlots = origDisableGenericSlots;
}

void x264ConfigDialog::saveSettings(vidEncOptions *encodeOptions, x264Options *options)
{
	encodeOptions->structSize = sizeof(vidEncOptions);

	// General tab
	switch (ui.encodingModeComboBox->currentIndex())
	{
		case 0:	// Constant Bitrate (Single Pass)
			encodeOptions->encodeMode = ADM_VIDENC_MODE_CBR;
			encodeOptions->encodeModeParameter = ui.targetRateControlSpinBox->value();
			break;
		case 1: // Constant Quality (Single Pass)
			encodeOptions->encodeMode = ADM_VIDENC_MODE_CQP;
			encodeOptions->encodeModeParameter = ui.quantiserSpinBox->value();
			break;
		case 2: // Average Quantizer (Single Pass)
			encodeOptions->encodeMode = ADM_VIDENC_MODE_AQP;
			encodeOptions->encodeModeParameter = ui.quantiserSpinBox->value();
			break;
		case 3: // Video Size (Two Pass)
			encodeOptions->encodeMode = ADM_VIDENC_MODE_2PASS_SIZE;
			encodeOptions->encodeModeParameter = ui.targetRateControlSpinBox->value();
			break;
		case 4: // Average Bitrate (Two Pass)
			encodeOptions->encodeMode = ADM_VIDENC_MODE_2PASS_ABR;
			encodeOptions->encodeModeParameter = ui.targetRateControlSpinBox->value();
			break;
	}

	PluginConfigType configurationType = (PluginConfigType)ui.configurationComboBox->itemData(ui.configurationComboBox->currentIndex()).toInt();

	options->setPresetConfiguration(ui.configurationComboBox->currentText().toUtf8().constData(), configurationType);

#if X264_BUILD >= 69
	options->setMbTree(ui.mbTreeCheckBox->isChecked());
	options->setFrametypeLookahead(ui.lookaheadSpinBox->value());
#endif

	options->setSarAsInput(ui.sarAsInputRadioButton->isChecked());

	if (ui.sarCustomRadioButton->isChecked())
	{
		options->setSarWidth(ui.sarCustomSpinBox1->value());
		options->setSarHeight(ui.sarCustomSpinBox2->value());
	}
	else if (ui.sarPredefinedRadioButton->isChecked())
	{
		options->setSarWidth(predefinedARs[ui.sarPredefinedComboBox->currentIndex()][0]);
		options->setSarHeight(predefinedARs[ui.sarPredefinedComboBox->currentIndex()][1]);
	}
	else
	{
		// clear variables
		options->setSarWidth(1);
		options->setSarHeight(1);
	}

	if (ui.threadAutoDetectRadioButton->isChecked())
		options->setThreads(0);
	else if (ui.threadDisableRadioButton->isChecked())
		options->setThreads(1);
	else
		options->setThreads(ui.threadCustomSpinBox->value());

#if X264_BUILD >= 75
	if (ui.threadedLookaheadCheckBox->isChecked())
		options->setThreadedLookahead(ui.threadedLookaheadSpinBox->value());
	else
		options->setThreadedLookahead(-1);
#endif

	// Motion Estimation tab
	options->setSubpixelRefinement(ui.meSpinBox->value());
	options->setMotionEstimationMethod(ui.meMethodComboBox->currentIndex());
	options->setMotionVectorSearchRange(ui.mvRangeSpinBox->value());
	
	if (ui.mvLengthCheckBox->isChecked())
		options->setMotionVectorLength(ui.mvLengthSpinBox->value());
	else
		options->setMotionVectorLength(-1);

	if (ui.minThreadBufferCheckBox->isChecked())
		options->setMotionVectorThreadBuffer(ui.minThreadBufferSpinBox->value());
	else
		options->setMotionVectorThreadBuffer(-1);

	options->setDirectPredictionMode(ui.predictModeComboBox->currentIndex());

#if X264_BUILD >= 79
	options->setWeightedPredictionPFrames(ui.weightedPPredictComboBox->currentIndex());
#endif

	options->setWeightedPrediction(ui.weightedPredictCheckBox->isChecked());
	options->setDct8x8(ui.dct8x8CheckBox->isChecked());
	options->setPartitionP8x8(ui.p8x8CheckBox->isChecked());
	options->setPartitionB8x8(ui.b8x8CheckBox->isChecked());
	options->setPartitionP4x4(ui.p4x4CheckBox->isChecked());
	options->setPartitionI8x8(ui.i8x8CheckBox->isChecked());
	options->setPartitionI4x4(ui.i4x4CheckBox->isChecked());

	// Frame tab
	options->setCabac(ui.cabacCheckBox->isChecked());
	options->setInterlaced(ui.interlacedCheckBox->isChecked());

#if X264_BUILD >= 77
	options->setConstrainedIntraPrediction(ui.constrainedIntraCheckBox->isChecked());
#endif

	options->setLoopFilter(ui.loopFilterCheckBox->isChecked());
	options->setLoopFilterAlphaC0(ui.alphaC0SpinBox->value());
	options->setLoopFilterBeta(ui.betaSpinBox->value());
	options->setBFrames(ui.maxBFramesSpinBox->value());
	options->setBFrameBias(ui.BFrameBiasSpinBox->value());
	options->setReferenceFrames(ui.refFramesSpinBox->value());
	options->setBFrameReferences(ui.bFrameRefComboBox->currentIndex());
	options->setAdaptiveBFrameDecision(ui.adaptiveBFrameComboBox->currentIndex());
	options->setGopMaximumSize(ui.maxGopSizeSpinBox->value());
	options->setGopMinimumSize(ui.minGopSizeSpinBox->value());
	options->setScenecutThreshold(ui.IFrameThresholdSpinBox->value());

	// Analysis tab
	options->setMixedReferences(ui.mixedRefsCheckBox->isChecked());
	options->setChromaMotionEstimation(ui.chromaMotionEstCheckBox->isChecked());

	if (ui.trellisCheckBox->isChecked())
		options->setTrellis(ui.trellisComboBox->currentIndex() + 1);
	else
		options->setTrellis(0);

	options->setFastPSkip(ui.fastPSkipCheckBox->isChecked());
	options->setDctDecimate(ui.dctDecimateCheckBox->isChecked());
	options->setPsychoRdo(ui.psychoRdoSpinBox->value());
	options->setNoiseReduction(ui.noiseReductionSpinBox->value());
	options->setInterLumaDeadzone(ui.interLumaSpinBox->value());
	options->setIntraLumaDeadzone(ui.intraLumaSpinBox->value());

	if (ui.matrixCustomRadioButton->isChecked())
	{
		options->setCqmPreset(2);

		options->setIntra4x4Luma(intra4x4Luma);
		options->setIntraChroma(intraChroma);
		options->setInter4x4Luma(inter4x4Luma);
		options->setInterChroma(interChroma);
		options->setIntra8x8Luma(intra8x8Luma);
		options->setInter8x8Luma(inter8x8Luma);
	}
	else if (ui.matrixJvtRadioButton->isChecked())
		options->setCqmPreset(1);
	else
		options->setCqmPreset(0);

	// Quantiser tab
	options->setQuantiserMinimum(ui.quantiserMinSpinBox->value());
	options->setQuantiserMaximum(ui.quantiserMaxSpinBox->value());
	options->setQuantiserStep(ui.quantiserMaxStepSpinBox->value());
	options->setAverageBitrateTolerance((float)ui.avgBitrateToleranceSpinBox->value() / 100);
	options->setIpFrameQuantiser(ui.quantiserIpRatioSpinBox->value());
	options->setPbFrameQuantiser(ui.quantiserPbRatioSpinBox->value());
	options->setChromaLumaQuantiserDifference(ui.chromaLumaOffsetSpinBox->value());
	options->setQuantiserCurveCompression((float)ui.quantiserCurveCompressSpinBox->value() / 100);
	options->setReduceFluxBeforeCurveCompression(ui.quantiserBeforeCompressSpinBox->value());
	options->setReduceFluxAfterCurveCompression(ui.quantiserAfterCompressSpinBox->value());

	if (ui.aqVarianceCheckBox->isChecked())
		options->setAdaptiveQuantiserMode(X264_AQ_VARIANCE);
	else
		options->setAdaptiveQuantiserMode(X264_AQ_NONE);

	options->setAdaptiveQuantiserStrength(ui.aqStrengthSpinBox->value());

	// Advanced tab
	options->setVbvMaximumBitrate(ui.vbvMaxBitrateSpinBox->value());
	options->setVbvBufferSize(ui.vbvBufferSizeSpinBox->value());
	options->setVbvInitialOccupancy((float)ui.vbvBufferOccupancySpinBox->value() / 100);

#if X264_BUILD >= 73
	options->setSliceMaxSize(ui.maxSliceSizeSpinBox->value());
	options->setSliceMaxMacroblocks(ui.maxSliceMbSpinBox->value());
	options->setSliceCount(ui.slicesPerFrameSpinBox->value());
#endif

	options->clearZones();

	QList<x264ZoneOptions*> zoneOptions = zoneTableModel.getList();

	for (int zone = 0; zone < zoneOptions.count(); zone++)
		options->addZone(zoneOptions[zone]);

	// Output tab
	options->setIdcLevel(idcLevel[ui.idcLevelComboBox->currentIndex()]);
	options->setSpsIdentifier(ui.spsiComboBox->currentText().toInt());
	options->setDeterministic(ui.repeatabilityCheckBox->isChecked());
	options->setAccessUnitDelimiters(ui.accessUnitCheckBox->isChecked());
	options->setOverscan(ui.overscanComboBox->currentIndex());
	options->setVideoFormat(videoFormat[ui.videoFormatComboBox->currentIndex()]);
	options->setColorPrimaries(colourPrimaries[ui.colourPrimariesComboBox->currentIndex()]);
	options->setTransfer(transferCharacteristics[ui.transferCharacteristicsComboBox->currentIndex()]);
	options->setColorMatrix(colourMatrix[ui.colourMatrixComboBox->currentIndex()]);
	options->setChromaSampleLocation(ui.chromaSampleSpinBox->value());
	options->setFullRangeSamples(ui.fullRangeSamplesCheckBox->isChecked());
}

extern "C" int showX264ConfigDialog(vidEncConfigParameters *configParameters, vidEncVideoProperties *properties, vidEncOptions *encodeOptions, x264Options *options)
{
	x264ConfigDialog dialog(configParameters, properties, encodeOptions, options);

	if (dialog.exec() == QDialog::Accepted)
	{
		dialog.saveSettings(encodeOptions, options);

		return 1;
	}

	return 0;
}
