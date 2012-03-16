///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2012 LoRd_MuldeR <MuldeR2@GMX.de>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
// http://www.gnu.org/licenses/gpl-2.0.txt
///////////////////////////////////////////////////////////////////////////////

#include "Dialog_MainWindow.h"

//LameXP includes
#include "Global.h"
#include "Resource.h"
#include "Dialog_WorkingBanner.h"
#include "Dialog_MetaInfo.h"
#include "Dialog_About.h"
#include "Dialog_Update.h"
#include "Dialog_DropBox.h"
#include "Dialog_CueImport.h"
#include "Thread_FileAnalyzer.h"
#include "Thread_MessageHandler.h"
#include "Model_MetaInfo.h"
#include "Model_Settings.h"
#include "Model_FileList.h"
#include "Model_FileSystem.h"
#include "WinSevenTaskbar.h"
#include "Registry_Decoder.h"
#include "ShellIntegration.h"

//Qt includes
#include <QMessageBox>
#include <QTimer>
#include <QDesktopWidget>
#include <QDate>
#include <QFileDialog>
#include <QInputDialog>
#include <QFileSystemModel>
#include <QDesktopServices>
#include <QUrl>
#include <QPlastiqueStyle>
#include <QCleanlooksStyle>
#include <QWindowsVistaStyle>
#include <QWindowsStyle>
#include <QSysInfo>
#include <QDragEnterEvent>
#include <QWindowsMime>
#include <QProcess>
#include <QUuid>
#include <QProcessEnvironment>
#include <QCryptographicHash>
#include <QTranslator>
#include <QResource>
#include <QScrollBar>

//System includes
#include <MMSystem.h>
#include <ShellAPI.h>

//Helper macros
#define ABORT_IF_BUSY if(m_banner->isVisible() || m_delayedFileTimer->isActive()) { MessageBeep(MB_ICONEXCLAMATION); return; }
#define SET_TEXT_COLOR(WIDGET,COLOR) { QPalette _palette = WIDGET->palette(); _palette.setColor(QPalette::WindowText, (COLOR)); _palette.setColor(QPalette::Text, (COLOR)); WIDGET->setPalette(_palette); }
#define SET_FONT_BOLD(WIDGET,BOLD) { QFont _font = WIDGET->font(); _font.setBold(BOLD); WIDGET->setFont(_font); }
#define LINK(URL) QString("<a href=\"%1\">%2</a>").arg(URL).arg(QString(URL).replace("-", "&minus;"))
#define FSLINK(PATH) QString("<a href=\"file:///%1\">%2</a>").arg(PATH).arg(QString(PATH).replace("-", "&minus;"))
#define TEMP_HIDE_DROPBOX(CMD) { bool __dropBoxVisible = m_dropBox->isVisible(); if(__dropBoxVisible) m_dropBox->hide(); {CMD}; if(__dropBoxVisible) m_dropBox->show(); }
#define USE_NATIVE_FILE_DIALOG (lamexp_themes_enabled() || ((QSysInfo::windowsVersion() & QSysInfo::WV_NT_based) < QSysInfo::WV_XP))

////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////

MainWindow::MainWindow(FileListModel *fileListModel, AudioFileModel *metaInfo, SettingsModel *settingsModel, QWidget *parent)
:
	QMainWindow(parent),
	m_fileListModel(fileListModel),
	m_metaData(metaInfo),
	m_settings(settingsModel),
	m_neroEncoderAvailable(lamexp_check_tool("neroAacEnc.exe") && lamexp_check_tool("neroAacDec.exe") && lamexp_check_tool("neroAacTag.exe")),
	m_fhgEncoderAvailable(lamexp_check_tool("fhgaacenc.exe") && lamexp_check_tool("enc_fhgaac.dll") && lamexp_check_tool("nsutil.dll") && lamexp_check_tool("libmp4v2.dll")),
	m_qaacEncoderAvailable(lamexp_check_tool("qaac.exe") && lamexp_check_tool("libsoxrate.dll")),
	m_accepted(false),
	m_firstTimeShown(true),
	m_OutputFolderViewInitialized(false)
{
	//Init the dialog, from the .ui file
	setupUi(this);
	setWindowFlags(windowFlags() ^ Qt::WindowMaximizeButtonHint);
	
	//Register meta types
	qRegisterMetaType<AudioFileModel>("AudioFileModel");

	//Enabled main buttons
	connect(buttonAbout, SIGNAL(clicked()), this, SLOT(aboutButtonClicked()));
	connect(buttonStart, SIGNAL(clicked()), this, SLOT(encodeButtonClicked()));
	connect(buttonQuit, SIGNAL(clicked()), this, SLOT(closeButtonClicked()));

	//Setup tab widget
	tabWidget->setCurrentIndex(0);
	connect(tabWidget, SIGNAL(currentChanged(int)), this, SLOT(tabPageChanged(int)));

	//Setup "Source" tab
	sourceFileView->setModel(m_fileListModel);
	sourceFileView->verticalHeader()->setResizeMode(QHeaderView::ResizeToContents);
	sourceFileView->horizontalHeader()->setResizeMode(QHeaderView::ResizeToContents);
	sourceFileView->setContextMenuPolicy(Qt::CustomContextMenu);
	sourceFileView->viewport()->installEventFilter(this);
	m_dropNoteLabel = new QLabel(sourceFileView);
	m_dropNoteLabel->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
	SET_FONT_BOLD(m_dropNoteLabel, true);
	SET_TEXT_COLOR(m_dropNoteLabel, Qt::darkGray);
	m_sourceFilesContextMenu = new QMenu();
	m_showDetailsContextAction = m_sourceFilesContextMenu->addAction(QIcon(":/icons/zoom.png"), "N/A");
	m_previewContextAction = m_sourceFilesContextMenu->addAction(QIcon(":/icons/sound.png"), "N/A");
	m_findFileContextAction = m_sourceFilesContextMenu->addAction(QIcon(":/icons/folder_go.png"), "N/A");
	m_sourceFilesContextMenu->addSeparator();
	m_exportCsvContextAction = m_sourceFilesContextMenu->addAction(QIcon(":/icons/table_save.png"), "N/A");
	m_importCsvContextAction = m_sourceFilesContextMenu->addAction(QIcon(":/icons/folder_table.png"), "N/A");
	SET_FONT_BOLD(m_showDetailsContextAction, true);
	connect(buttonAddFiles, SIGNAL(clicked()), this, SLOT(addFilesButtonClicked()));
	connect(buttonRemoveFile, SIGNAL(clicked()), this, SLOT(removeFileButtonClicked()));
	connect(buttonClearFiles, SIGNAL(clicked()), this, SLOT(clearFilesButtonClicked()));
	connect(buttonFileUp, SIGNAL(clicked()), this, SLOT(fileUpButtonClicked()));
	connect(buttonFileDown, SIGNAL(clicked()), this, SLOT(fileDownButtonClicked()));
	connect(buttonShowDetails, SIGNAL(clicked()), this, SLOT(showDetailsButtonClicked()));
	connect(m_fileListModel, SIGNAL(rowsInserted(QModelIndex,int,int)), this, SLOT(sourceModelChanged()));
	connect(m_fileListModel, SIGNAL(rowsRemoved(QModelIndex,int,int)), this, SLOT(sourceModelChanged()));
	connect(m_fileListModel, SIGNAL(modelReset()), this, SLOT(sourceModelChanged()));
	connect(sourceFileView, SIGNAL(customContextMenuRequested(QPoint)), this, SLOT(sourceFilesContextMenu(QPoint)));
	connect(sourceFileView->verticalScrollBar(), SIGNAL(sliderMoved(int)), this, SLOT(sourceFilesScrollbarMoved(int)));
	connect(sourceFileView->verticalScrollBar(), SIGNAL(valueChanged(int)), this, SLOT(sourceFilesScrollbarMoved(int)));
	connect(m_showDetailsContextAction, SIGNAL(triggered(bool)), this, SLOT(showDetailsButtonClicked()));
	connect(m_previewContextAction, SIGNAL(triggered(bool)), this, SLOT(previewContextActionTriggered()));
	connect(m_findFileContextAction, SIGNAL(triggered(bool)), this, SLOT(findFileContextActionTriggered()));
	connect(m_exportCsvContextAction, SIGNAL(triggered(bool)), this, SLOT(exportCsvContextActionTriggered()));
	connect(m_importCsvContextAction, SIGNAL(triggered(bool)), this, SLOT(importCsvContextActionTriggered()));
	

	//Setup "Output" tab
	m_fileSystemModel = new QFileSystemModelEx();
	m_fileSystemModel->installEventFilter(this);
	outputFolderView->setModel(m_fileSystemModel);
	outputFolderView->header()->setStretchLastSection(true);
	outputFolderView->header()->hideSection(1);
	outputFolderView->header()->hideSection(2);
	outputFolderView->header()->hideSection(3);
	outputFolderView->setHeaderHidden(true);
	outputFolderView->setAnimated(false);
	outputFolderView->setMouseTracking(false);
	outputFolderView->setContextMenuPolicy(Qt::CustomContextMenu);
	outputFolderView->installEventFilter(this);
	outputFoldersFovoritesLabel->installEventFilter(this);
	while(saveToSourceFolderCheckBox->isChecked() != m_settings->outputToSourceDir()) saveToSourceFolderCheckBox->click();
	prependRelativePathCheckBox->setChecked(m_settings->prependRelativeSourcePath());
	connect(outputFolderView, SIGNAL(clicked(QModelIndex)), this, SLOT(outputFolderViewClicked(QModelIndex)));
	connect(outputFolderView, SIGNAL(activated(QModelIndex)), this, SLOT(outputFolderViewClicked(QModelIndex)));
	connect(outputFolderView, SIGNAL(pressed(QModelIndex)), this, SLOT(outputFolderViewClicked(QModelIndex)));
	connect(outputFolderView, SIGNAL(entered(QModelIndex)), this, SLOT(outputFolderViewMoved(QModelIndex)));
	connect(buttonMakeFolder, SIGNAL(clicked()), this, SLOT(makeFolderButtonClicked()));
	connect(buttonGotoHome, SIGNAL(clicked()), SLOT(gotoHomeFolderButtonClicked()));
	connect(buttonGotoDesktop, SIGNAL(clicked()), this, SLOT(gotoDesktopButtonClicked()));
	connect(buttonGotoMusic, SIGNAL(clicked()), this, SLOT(gotoMusicFolderButtonClicked()));
	connect(saveToSourceFolderCheckBox, SIGNAL(clicked()), this, SLOT(saveToSourceFolderChanged()));
	connect(prependRelativePathCheckBox, SIGNAL(clicked()), this, SLOT(prependRelativePathChanged()));
	m_outputFolderContextMenu = new QMenu();
	m_showFolderContextAction = m_outputFolderContextMenu->addAction(QIcon(":/icons/zoom.png"), "N/A");
	m_outputFolderFavoritesMenu = new QMenu();
	m_addFavoriteFolderAction = m_outputFolderFavoritesMenu->addAction(QIcon(":/icons/add.png"), "N/A");
	m_outputFolderFavoritesMenu->insertSeparator(m_addFavoriteFolderAction);
	connect(outputFolderView, SIGNAL(customContextMenuRequested(QPoint)), this, SLOT(outputFolderContextMenu(QPoint)));
	connect(m_showFolderContextAction, SIGNAL(triggered(bool)), this, SLOT(showFolderContextActionTriggered()));
	connect(m_addFavoriteFolderAction, SIGNAL(triggered(bool)), this, SLOT(addFavoriteFolderActionTriggered()));
	outputFolderLabel->installEventFilter(this);
	outputFolderView->setCurrentIndex(m_fileSystemModel->index(m_settings->outputDir()));
	outputFolderViewClicked(outputFolderView->currentIndex());
	refreshFavorites();
	
	//Setup "Meta Data" tab
	m_metaInfoModel = new MetaInfoModel(m_metaData, 6);
	m_metaInfoModel->clearData();
	m_metaInfoModel->setData(m_metaInfoModel->index(4, 1), m_settings->metaInfoPosition());
	metaDataView->setModel(m_metaInfoModel);
	metaDataView->verticalHeader()->setResizeMode(QHeaderView::ResizeToContents);
	metaDataView->verticalHeader()->hide();
	metaDataView->horizontalHeader()->setResizeMode(QHeaderView::ResizeToContents);
	while(writeMetaDataCheckBox->isChecked() != m_settings->writeMetaTags()) writeMetaDataCheckBox->click();
	generatePlaylistCheckBox->setChecked(m_settings->createPlaylist());
	connect(buttonEditMeta, SIGNAL(clicked()), this, SLOT(editMetaButtonClicked()));
	connect(buttonClearMeta, SIGNAL(clicked()), this, SLOT(clearMetaButtonClicked()));
	connect(writeMetaDataCheckBox, SIGNAL(clicked()), this, SLOT(metaTagsEnabledChanged()));
	connect(generatePlaylistCheckBox, SIGNAL(clicked()), this, SLOT(playlistEnabledChanged()));

	//Setup "Compression" tab
	m_encoderButtonGroup = new QButtonGroup(this);
	m_encoderButtonGroup->addButton(radioButtonEncoderMP3, SettingsModel::MP3Encoder);
	m_encoderButtonGroup->addButton(radioButtonEncoderVorbis, SettingsModel::VorbisEncoder);
	m_encoderButtonGroup->addButton(radioButtonEncoderAAC, SettingsModel::AACEncoder);
	m_encoderButtonGroup->addButton(radioButtonEncoderAC3, SettingsModel::AC3Encoder);
	m_encoderButtonGroup->addButton(radioButtonEncoderFLAC, SettingsModel::FLACEncoder);
	m_encoderButtonGroup->addButton(radioButtonEncoderDCA, SettingsModel::DCAEncoder);
	m_encoderButtonGroup->addButton(radioButtonEncoderPCM, SettingsModel::PCMEncoder);
	m_modeButtonGroup = new QButtonGroup(this);
	m_modeButtonGroup->addButton(radioButtonModeQuality, SettingsModel::VBRMode);
	m_modeButtonGroup->addButton(radioButtonModeAverageBitrate, SettingsModel::ABRMode);
	m_modeButtonGroup->addButton(radioButtonConstBitrate, SettingsModel::CBRMode);
	radioButtonEncoderAAC->setEnabled(m_neroEncoderAvailable || m_fhgEncoderAvailable || m_qaacEncoderAvailable);
	radioButtonEncoderMP3->setChecked(m_settings->compressionEncoder() == SettingsModel::MP3Encoder);
	radioButtonEncoderVorbis->setChecked(m_settings->compressionEncoder() == SettingsModel::VorbisEncoder);
	radioButtonEncoderAAC->setChecked((m_settings->compressionEncoder() == SettingsModel::AACEncoder) && (m_neroEncoderAvailable || m_fhgEncoderAvailable || m_qaacEncoderAvailable));
	radioButtonEncoderAC3->setChecked(m_settings->compressionEncoder() == SettingsModel::AC3Encoder);
	radioButtonEncoderFLAC->setChecked(m_settings->compressionEncoder() == SettingsModel::FLACEncoder);
	radioButtonEncoderDCA->setChecked(m_settings->compressionEncoder() == SettingsModel::DCAEncoder);
	radioButtonEncoderPCM->setChecked(m_settings->compressionEncoder() == SettingsModel::PCMEncoder);
	radioButtonModeQuality->setChecked(m_settings->compressionRCMode() == SettingsModel::VBRMode);
	radioButtonModeAverageBitrate->setChecked(m_settings->compressionRCMode() == SettingsModel::ABRMode);
	radioButtonConstBitrate->setChecked(m_settings->compressionRCMode() == SettingsModel::CBRMode);
	sliderBitrate->setValue(m_settings->compressionBitrate());
	connect(m_encoderButtonGroup, SIGNAL(buttonClicked(int)), this, SLOT(updateEncoder(int)));
	connect(m_modeButtonGroup, SIGNAL(buttonClicked(int)), this, SLOT(updateRCMode(int)));
	connect(sliderBitrate, SIGNAL(valueChanged(int)), this, SLOT(updateBitrate(int)));
	updateEncoder(m_encoderButtonGroup->checkedId());

	//Setup "Advanced Options" tab
	sliderLameAlgoQuality->setValue(m_settings->lameAlgoQuality());
	if(m_settings->maximumInstances() > 0) sliderMaxInstances->setValue(m_settings->maximumInstances());
	spinBoxBitrateManagementMin->setValue(m_settings->bitrateManagementMinRate());
	spinBoxBitrateManagementMax->setValue(m_settings->bitrateManagementMaxRate());
	spinBoxNormalizationFilter->setValue(static_cast<double>(m_settings->normalizationFilterMaxVolume()) / 100.0);
	spinBoxToneAdjustBass->setValue(static_cast<double>(m_settings->toneAdjustBass()) / 100.0);
	spinBoxToneAdjustTreble->setValue(static_cast<double>(m_settings->toneAdjustTreble()) / 100.0);
	spinBoxAftenSearchSize->setValue(m_settings->aftenExponentSearchSize());
	comboBoxMP3ChannelMode->setCurrentIndex(m_settings->lameChannelMode());
	comboBoxSamplingRate->setCurrentIndex(m_settings->samplingRate());
	comboBoxAACProfile->setCurrentIndex(m_settings->aacEncProfile());
	comboBoxAftenCodingMode->setCurrentIndex(m_settings->aftenAudioCodingMode());
	comboBoxAftenDRCMode->setCurrentIndex(m_settings->aftenDynamicRangeCompression());
	comboBoxNormalizationMode->setCurrentIndex(m_settings->normalizationFilterEqualizationMode());
	while(checkBoxBitrateManagement->isChecked() != m_settings->bitrateManagementEnabled()) checkBoxBitrateManagement->click();
	while(checkBoxNeroAAC2PassMode->isChecked() != m_settings->neroAACEnable2Pass()) checkBoxNeroAAC2PassMode->click();
	while(checkBoxAftenFastAllocation->isChecked() != m_settings->aftenFastBitAllocation()) checkBoxAftenFastAllocation->click();
	while(checkBoxNormalizationFilter->isChecked() != m_settings->normalizationFilterEnabled()) checkBoxNormalizationFilter->click();
	while(checkBoxAutoDetectInstances->isChecked() != (m_settings->maximumInstances() < 1)) checkBoxAutoDetectInstances->click();
	while(checkBoxUseSystemTempFolder->isChecked() == m_settings->customTempPathEnabled()) checkBoxUseSystemTempFolder->click();
	while(checkBoxRenameOutput->isChecked() != m_settings->renameOutputFilesEnabled()) checkBoxRenameOutput->click();
	while(checkBoxForceStereoDownmix->isChecked() != m_settings->forceStereoDownmix()) checkBoxForceStereoDownmix->click();
	checkBoxNeroAAC2PassMode->setEnabled(!(m_fhgEncoderAvailable || m_qaacEncoderAvailable));
	lineEditCustomParamLAME->setText(m_settings->customParametersLAME());
	lineEditCustomParamOggEnc->setText(m_settings->customParametersOggEnc());
	lineEditCustomParamNeroAAC->setText(m_settings->customParametersAacEnc());
	lineEditCustomParamFLAC->setText(m_settings->customParametersFLAC());
	lineEditCustomParamAften->setText(m_settings->customParametersAften());
	lineEditCustomTempFolder->setText(QDir::toNativeSeparators(m_settings->customTempPath()));
	lineEditRenamePattern->setText(m_settings->renameOutputFilesPattern());
	connect(sliderLameAlgoQuality, SIGNAL(valueChanged(int)), this, SLOT(updateLameAlgoQuality(int)));
	connect(checkBoxBitrateManagement, SIGNAL(clicked(bool)), this, SLOT(bitrateManagementEnabledChanged(bool)));
	connect(spinBoxBitrateManagementMin, SIGNAL(valueChanged(int)), this, SLOT(bitrateManagementMinChanged(int)));
	connect(spinBoxBitrateManagementMax, SIGNAL(valueChanged(int)), this, SLOT(bitrateManagementMaxChanged(int)));
	connect(comboBoxMP3ChannelMode, SIGNAL(currentIndexChanged(int)), this, SLOT(channelModeChanged(int)));
	connect(comboBoxSamplingRate, SIGNAL(currentIndexChanged(int)), this, SLOT(samplingRateChanged(int)));
	connect(checkBoxNeroAAC2PassMode, SIGNAL(clicked(bool)), this, SLOT(neroAAC2PassChanged(bool)));
	connect(comboBoxAACProfile, SIGNAL(currentIndexChanged(int)), this, SLOT(neroAACProfileChanged(int)));
	connect(checkBoxNormalizationFilter, SIGNAL(clicked(bool)), this, SLOT(normalizationEnabledChanged(bool)));
	connect(comboBoxAftenCodingMode, SIGNAL(currentIndexChanged(int)), this, SLOT(aftenCodingModeChanged(int)));
	connect(comboBoxAftenDRCMode, SIGNAL(currentIndexChanged(int)), this, SLOT(aftenDRCModeChanged(int)));
	connect(spinBoxAftenSearchSize, SIGNAL(valueChanged(int)), this, SLOT(aftenSearchSizeChanged(int)));
	connect(checkBoxAftenFastAllocation, SIGNAL(clicked(bool)), this, SLOT(aftenFastAllocationChanged(bool)));
	connect(spinBoxNormalizationFilter, SIGNAL(valueChanged(double)), this, SLOT(normalizationMaxVolumeChanged(double)));
	connect(comboBoxNormalizationMode, SIGNAL(currentIndexChanged(int)), this, SLOT(normalizationModeChanged(int)));
	connect(spinBoxToneAdjustBass, SIGNAL(valueChanged(double)), this, SLOT(toneAdjustBassChanged(double)));
	connect(spinBoxToneAdjustTreble, SIGNAL(valueChanged(double)), this, SLOT(toneAdjustTrebleChanged(double)));
	connect(buttonToneAdjustReset, SIGNAL(clicked()), this, SLOT(toneAdjustTrebleReset()));
	connect(lineEditCustomParamLAME, SIGNAL(editingFinished()), this, SLOT(customParamsChanged()));
	connect(lineEditCustomParamOggEnc, SIGNAL(editingFinished()), this, SLOT(customParamsChanged()));
	connect(lineEditCustomParamNeroAAC, SIGNAL(editingFinished()), this, SLOT(customParamsChanged()));
	connect(lineEditCustomParamFLAC, SIGNAL(editingFinished()), this, SLOT(customParamsChanged()));
	connect(lineEditCustomParamAften, SIGNAL(editingFinished()), this, SLOT(customParamsChanged()));
	connect(sliderMaxInstances, SIGNAL(valueChanged(int)), this, SLOT(updateMaximumInstances(int)));
	connect(checkBoxAutoDetectInstances, SIGNAL(clicked(bool)), this, SLOT(autoDetectInstancesChanged(bool)));
	connect(buttonBrowseCustomTempFolder, SIGNAL(clicked()), this, SLOT(browseCustomTempFolderButtonClicked()));
	connect(lineEditCustomTempFolder, SIGNAL(textChanged(QString)), this, SLOT(customTempFolderChanged(QString)));
	connect(checkBoxUseSystemTempFolder, SIGNAL(clicked(bool)), this, SLOT(useCustomTempFolderChanged(bool)));
	connect(buttonResetAdvancedOptions, SIGNAL(clicked()), this, SLOT(resetAdvancedOptionsButtonClicked()));
	connect(checkBoxRenameOutput, SIGNAL(clicked(bool)), this, SLOT(renameOutputEnabledChanged(bool)));
	connect(lineEditRenamePattern, SIGNAL(editingFinished()), this, SLOT(renameOutputPatternChanged()));
	connect(lineEditRenamePattern, SIGNAL(textChanged(QString)), this, SLOT(renameOutputPatternChanged(QString)));
	connect(labelShowRenameMacros, SIGNAL(linkActivated(QString)), this, SLOT(showRenameMacros(QString)));
	connect(checkBoxForceStereoDownmix, SIGNAL(clicked(bool)), this, SLOT(forceStereoDownmixEnabledChanged(bool)));
	updateLameAlgoQuality(sliderLameAlgoQuality->value());
	updateMaximumInstances(sliderMaxInstances->value());
	toneAdjustTrebleChanged(spinBoxToneAdjustTreble->value());
	toneAdjustBassChanged(spinBoxToneAdjustBass->value());
	customParamsChanged();
	
	//Activate file menu actions
	actionOpenFolder->setData(QVariant::fromValue<bool>(false));
	actionOpenFolderRecursively->setData(QVariant::fromValue<bool>(true));
	connect(actionOpenFolder, SIGNAL(triggered()), this, SLOT(openFolderActionActivated()));
	connect(actionOpenFolderRecursively, SIGNAL(triggered()), this, SLOT(openFolderActionActivated()));

	//Activate view menu actions
	m_tabActionGroup = new QActionGroup(this);
	m_tabActionGroup->addAction(actionSourceFiles);
	m_tabActionGroup->addAction(actionOutputDirectory);
	m_tabActionGroup->addAction(actionCompression);
	m_tabActionGroup->addAction(actionMetaData);
	m_tabActionGroup->addAction(actionAdvancedOptions);
	actionSourceFiles->setData(0);
	actionOutputDirectory->setData(1);
	actionMetaData->setData(2);
	actionCompression->setData(3);
	actionAdvancedOptions->setData(4);
	actionSourceFiles->setChecked(true);
	connect(m_tabActionGroup, SIGNAL(triggered(QAction*)), this, SLOT(tabActionActivated(QAction*)));

	//Activate style menu actions
	m_styleActionGroup = new QActionGroup(this);
	m_styleActionGroup->addAction(actionStylePlastique);
	m_styleActionGroup->addAction(actionStyleCleanlooks);
	m_styleActionGroup->addAction(actionStyleWindowsVista);
	m_styleActionGroup->addAction(actionStyleWindowsXP);
	m_styleActionGroup->addAction(actionStyleWindowsClassic);
	actionStylePlastique->setData(0);
	actionStyleCleanlooks->setData(1);
	actionStyleWindowsVista->setData(2);
	actionStyleWindowsXP->setData(3);
	actionStyleWindowsClassic->setData(4);
	actionStylePlastique->setChecked(true);
	actionStyleWindowsXP->setEnabled((QSysInfo::windowsVersion() & QSysInfo::WV_NT_based) >= QSysInfo::WV_XP && lamexp_themes_enabled());
	actionStyleWindowsVista->setEnabled((QSysInfo::windowsVersion() & QSysInfo::WV_NT_based) >= QSysInfo::WV_VISTA && lamexp_themes_enabled());
	connect(m_styleActionGroup, SIGNAL(triggered(QAction*)), this, SLOT(styleActionActivated(QAction*)));
	styleActionActivated(NULL);

	//Populate the language menu
	m_languageActionGroup = new QActionGroup(this);
	QStringList translations = lamexp_query_translations();
	while(!translations.isEmpty())
	{
		QString langId = translations.takeFirst();
		QAction *currentLanguage = new QAction(this);
		currentLanguage->setData(langId);
		currentLanguage->setText(lamexp_translation_name(langId));
		currentLanguage->setIcon(QIcon(QString(":/flags/%1.png").arg(langId)));
		currentLanguage->setCheckable(true);
		m_languageActionGroup->addAction(currentLanguage);
		menuLanguage->insertAction(actionLoadTranslationFromFile, currentLanguage);
	}
	menuLanguage->insertSeparator(actionLoadTranslationFromFile);
	connect(actionLoadTranslationFromFile, SIGNAL(triggered(bool)), this, SLOT(languageFromFileActionActivated(bool)));
	connect(m_languageActionGroup, SIGNAL(triggered(QAction*)), this, SLOT(languageActionActivated(QAction*)));

	//Activate tools menu actions
	actionDisableUpdateReminder->setChecked(!m_settings->autoUpdateEnabled());
	actionDisableSounds->setChecked(!m_settings->soundsEnabled());
	actionDisableNeroAacNotifications->setChecked(!m_settings->neroAacNotificationsEnabled());
	actionDisableSlowStartupNotifications->setChecked(!m_settings->antivirNotificationsEnabled());
	actionDisableShellIntegration->setChecked(!m_settings->shellIntegrationEnabled());
	actionDisableShellIntegration->setDisabled(lamexp_portable_mode() && actionDisableShellIntegration->isChecked());
	actionCheckForBetaUpdates->setChecked(m_settings->autoUpdateCheckBeta() || lamexp_version_demo());
	actionCheckForBetaUpdates->setEnabled(!lamexp_version_demo());
	actionHibernateComputer->setChecked(m_settings->hibernateComputer());
	actionHibernateComputer->setEnabled(lamexp_is_hibernation_supported());
	connect(actionDisableUpdateReminder, SIGNAL(triggered(bool)), this, SLOT(disableUpdateReminderActionTriggered(bool)));
	connect(actionDisableSounds, SIGNAL(triggered(bool)), this, SLOT(disableSoundsActionTriggered(bool)));
	connect(actionDisableNeroAacNotifications, SIGNAL(triggered(bool)), this, SLOT(disableNeroAacNotificationsActionTriggered(bool)));
	connect(actionDisableSlowStartupNotifications, SIGNAL(triggered(bool)), this, SLOT(disableSlowStartupNotificationsActionTriggered(bool)));
	connect(actionDisableShellIntegration, SIGNAL(triggered(bool)), this, SLOT(disableShellIntegrationActionTriggered(bool)));
	connect(actionShowDropBoxWidget, SIGNAL(triggered(bool)), this, SLOT(showDropBoxWidgetActionTriggered(bool)));
	connect(actionHibernateComputer, SIGNAL(triggered(bool)), this, SLOT(hibernateComputerActionTriggered(bool)));
	connect(actionCheckForBetaUpdates, SIGNAL(triggered(bool)), this, SLOT(checkForBetaUpdatesActionTriggered(bool)));
	connect(actionImportCueSheet, SIGNAL(triggered(bool)), this, SLOT(importCueSheetActionTriggered(bool)));
		
	//Activate help menu actions
	actionVisitHomepage->setData(QString::fromLatin1(lamexp_website_url()));
	actionVisitSupport->setData(QString::fromLatin1(lamexp_support_url()));
	actionDocumentFAQ->setData(QString("%1/FAQ.html").arg(QApplication::applicationDirPath()));
	actionDocumentChangelog->setData(QString("%1/Changelog.html").arg(QApplication::applicationDirPath()));
	actionDocumentTranslate->setData(QString("%1/Translate.html").arg(QApplication::applicationDirPath()));
	connect(actionCheckUpdates, SIGNAL(triggered()), this, SLOT(checkUpdatesActionActivated()));
	connect(actionVisitHomepage, SIGNAL(triggered()), this, SLOT(visitHomepageActionActivated()));
	connect(actionVisitSupport, SIGNAL(triggered()), this, SLOT(visitHomepageActionActivated()));
	connect(actionDocumentFAQ, SIGNAL(triggered()), this, SLOT(documentActionActivated()));
	connect(actionDocumentChangelog, SIGNAL(triggered()), this, SLOT(documentActionActivated()));
	connect(actionDocumentTranslate, SIGNAL(triggered()), this, SLOT(documentActionActivated()));
	
	//Center window in screen
	QRect desktopRect = QApplication::desktop()->screenGeometry();
	QRect thisRect = this->geometry();
	move((desktopRect.width() - thisRect.width()) / 2, (desktopRect.height() - thisRect.height()) / 2);
	setMinimumSize(thisRect.width(), thisRect.height());

	//Create banner
	m_banner = new WorkingBanner(this);

	//Create DropBox widget
	m_dropBox = new DropBox(this, m_fileListModel, m_settings);
	connect(m_fileListModel, SIGNAL(modelReset()), m_dropBox, SLOT(modelChanged()));
	connect(m_fileListModel, SIGNAL(rowsInserted(QModelIndex,int,int)), m_dropBox, SLOT(modelChanged()));
	connect(m_fileListModel, SIGNAL(rowsRemoved(QModelIndex,int,int)), m_dropBox, SLOT(modelChanged()));

	//Create message handler thread
	m_messageHandler = new MessageHandlerThread();
	m_delayedFileList = new QStringList();
	m_delayedFileTimer = new QTimer();
	m_delayedFileTimer->setSingleShot(true);
	m_delayedFileTimer->setInterval(5000);
	connect(m_messageHandler, SIGNAL(otherInstanceDetected()), this, SLOT(notifyOtherInstance()), Qt::QueuedConnection);
	connect(m_messageHandler, SIGNAL(fileReceived(QString)), this, SLOT(addFileDelayed(QString)), Qt::QueuedConnection);
	connect(m_messageHandler, SIGNAL(folderReceived(QString, bool)), this, SLOT(addFolderDelayed(QString, bool)), Qt::QueuedConnection);
	connect(m_messageHandler, SIGNAL(killSignalReceived()), this, SLOT(close()), Qt::QueuedConnection);
	connect(m_delayedFileTimer, SIGNAL(timeout()), this, SLOT(handleDelayedFiles()));
	m_messageHandler->start();

	//Load translation file
	QList<QAction*> languageActions = m_languageActionGroup->actions();
	while(!languageActions.isEmpty())
	{
		QAction *currentLanguage = languageActions.takeFirst();
		if(currentLanguage->data().toString().compare(m_settings->currentLanguage(), Qt::CaseInsensitive) == 0)
		{
			currentLanguage->setChecked(true);
			languageActionActivated(currentLanguage);
		}
	}

	//Re-translate (make sure we translate once)
	QEvent languageChangeEvent(QEvent::LanguageChange);
	changeEvent(&languageChangeEvent);

	//Enable Drag & Drop
	this->setAcceptDrops(true);
}

////////////////////////////////////////////////////////////
// Destructor
////////////////////////////////////////////////////////////

MainWindow::~MainWindow(void)
{
	//Stop message handler thread
	if(m_messageHandler && m_messageHandler->isRunning())
	{
		m_messageHandler->stop();
		if(!m_messageHandler->wait(2500))
		{
			m_messageHandler->terminate();
			m_messageHandler->wait();
		}
	}

	//Unset models
	sourceFileView->setModel(NULL);
	metaDataView->setModel(NULL);

	//Free memory
	LAMEXP_DELETE(m_tabActionGroup);
	LAMEXP_DELETE(m_styleActionGroup);
	LAMEXP_DELETE(m_languageActionGroup);
	LAMEXP_DELETE(m_banner);
	LAMEXP_DELETE(m_fileSystemModel);
	LAMEXP_DELETE(m_messageHandler);
	LAMEXP_DELETE(m_delayedFileList);
	LAMEXP_DELETE(m_delayedFileTimer);
	LAMEXP_DELETE(m_metaInfoModel);
	LAMEXP_DELETE(m_encoderButtonGroup);
	LAMEXP_DELETE(m_encoderButtonGroup);
	LAMEXP_DELETE(m_sourceFilesContextMenu);
	LAMEXP_DELETE(m_outputFolderFavoritesMenu);
	LAMEXP_DELETE(m_dropBox);
}

////////////////////////////////////////////////////////////
// PRIVATE FUNCTIONS
////////////////////////////////////////////////////////////

/*
 * Add file to source list
 */
void MainWindow::addFiles(const QStringList &files)
{
	if(files.isEmpty())
	{
		return;
	}

	tabWidget->setCurrentIndex(0);

	FileAnalyzer *analyzer = new FileAnalyzer(files);
	connect(analyzer, SIGNAL(fileSelected(QString)), m_banner, SLOT(setText(QString)), Qt::QueuedConnection);
	connect(analyzer, SIGNAL(fileAnalyzed(AudioFileModel)), m_fileListModel, SLOT(addFile(AudioFileModel)), Qt::QueuedConnection);
	connect(m_banner, SIGNAL(userAbort()), analyzer, SLOT(abortProcess()), Qt::DirectConnection);

	m_banner->show(tr("Adding file(s), please wait..."), analyzer);

	if(analyzer->filesDenied())
	{
		QMessageBox::warning(this, tr("Access Denied"), QString("%1<br>%2").arg(NOBR(tr("%1 file(s) have been rejected, because read access was not granted!").arg(analyzer->filesDenied())), NOBR(tr("This usually means the file is locked by another process."))));
	}
	if(analyzer->filesDummyCDDA())
	{
		QMessageBox::warning(this, tr("CDDA Files"), QString("%1<br><br>%2<br>%3").arg(NOBR(tr("%1 file(s) have been rejected, because they are dummy CDDA files!").arg(analyzer->filesDummyCDDA())), NOBR(tr("Sorry, LameXP cannot extract audio tracks from an Audio-CD at present.")), NOBR(tr("We recommend using %1 for that purpose.").arg("<a href=\"http://www.exactaudiocopy.de/\">Exact Audio Copy</a>"))));
	}
	if(analyzer->filesCueSheet())
	{
		QMessageBox::warning(this, tr("Cue Sheet"), QString("%1<br>%2").arg(NOBR(tr("%1 file(s) have been rejected, because they appear to be Cue Sheet images!").arg(analyzer->filesCueSheet())), NOBR(tr("Please use LameXP's Cue Sheet wizard for importing Cue Sheet files."))));
	}
	if(analyzer->filesRejected())
	{
		QMessageBox::warning(this, tr("Files Rejected"), QString("%1<br>%2").arg(NOBR(tr("%1 file(s) have been rejected, because the file format could not be recognized!").arg(analyzer->filesRejected())), NOBR(tr("This usually means the file is damaged or the file format is not supported."))));
	}

	LAMEXP_DELETE(analyzer);
	sourceFileView->scrollToBottom();
	m_banner->close();
}

/*
 * Add folder to source list
 */
void MainWindow::addFolder(const QString &path, bool recursive, bool delayed)
{
	QFileInfoList folderInfoList;
	folderInfoList << QFileInfo(path);
	QStringList fileList;
	
	m_banner->show(tr("Scanning folder(s) for files, please wait..."));
	
	QApplication::processEvents();
	GetAsyncKeyState(VK_ESCAPE);

	while(!folderInfoList.isEmpty())
	{
		if(GetAsyncKeyState(VK_ESCAPE) & 0x0001)
		{
			MessageBeep(MB_ICONERROR);
			qWarning("Operation cancelled by user!");
			fileList.clear();
			break;
		}
		
		QDir currentDir(folderInfoList.takeFirst().canonicalFilePath());
		QFileInfoList fileInfoList = currentDir.entryInfoList(QDir::Files | QDir::NoSymLinks);

		while(!fileInfoList.isEmpty())
		{
			fileList << fileInfoList.takeFirst().canonicalFilePath();
		}

		QApplication::processEvents();

		if(recursive)
		{
			folderInfoList.append(currentDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoSymLinks));
			QApplication::processEvents();
		}
	}
	
	m_banner->close();
	QApplication::processEvents();

	if(!fileList.isEmpty())
	{
		if(delayed)
		{
			addFilesDelayed(fileList);
		}
		else
		{
			addFiles(fileList);
		}
	}
}

/*
 * Check for updates
 */
bool MainWindow::checkForUpdates(void)
{
	bool bReadyToInstall = false;
	
	UpdateDialog *updateDialog = new UpdateDialog(m_settings, this);
	updateDialog->exec();

	if(updateDialog->getSuccess())
	{
		m_settings->autoUpdateLastCheck(QDate::currentDate().toString(Qt::ISODate));
		bReadyToInstall = updateDialog->updateReadyToInstall();
	}

	LAMEXP_DELETE(updateDialog);
	return bReadyToInstall;
}

void MainWindow::refreshFavorites(void)
{
	QList<QAction*> folderList = m_outputFolderFavoritesMenu->actions();
	QStringList favorites = m_settings->favoriteOutputFolders().split("|", QString::SkipEmptyParts);
	while(favorites.count() > 6) favorites.removeFirst();

	while(!folderList.isEmpty())
	{
		QAction *currentItem = folderList.takeFirst();
		if(currentItem->isSeparator()) break;
		m_outputFolderFavoritesMenu->removeAction(currentItem);
		LAMEXP_DELETE(currentItem);
	}

	QAction *lastItem = m_outputFolderFavoritesMenu->actions().first();

	while(!favorites.isEmpty())
	{
		QString path = favorites.takeLast();
		if(QDir(path).exists())
		{
			QAction *action = new QAction(QIcon(":/icons/folder_go.png"), QDir::toNativeSeparators(path), this);
			action->setData(path);
			m_outputFolderFavoritesMenu->insertAction(lastItem, action);
			connect(action, SIGNAL(triggered(bool)), this, SLOT(gotoFavoriteFolder()));
			lastItem = action;
		}
	}
}

////////////////////////////////////////////////////////////
// EVENTS
////////////////////////////////////////////////////////////

/*
 * Window is about to be shown
 */
void MainWindow::showEvent(QShowEvent *event)
{
	m_accepted = false;
	m_dropNoteLabel->setGeometry(0, 0, sourceFileView->width(), sourceFileView->height());
	sourceModelChanged();
	
	if(!event->spontaneous())
	{
		tabWidget->setCurrentIndex(0);
	}

	if(m_firstTimeShown)
	{
		m_firstTimeShown = false;
		QTimer::singleShot(0, this, SLOT(windowShown()));
	}
	else
	{
		if(m_settings->dropBoxWidgetEnabled())
		{
			m_dropBox->setVisible(true);
		}
	}
}

/*
 * Re-translate the UI
 */
void MainWindow::changeEvent(QEvent *e)
{
	if(e->type() == QEvent::LanguageChange)
	{
		int comboBoxIndex[6];
		
		//Backup combobox indices, as retranslateUi() resets
		comboBoxIndex[0] = comboBoxMP3ChannelMode->currentIndex();
		comboBoxIndex[1] = comboBoxSamplingRate->currentIndex();
		comboBoxIndex[2] = comboBoxAACProfile->currentIndex();
		comboBoxIndex[3] = comboBoxAftenCodingMode->currentIndex();
		comboBoxIndex[4] = comboBoxAftenDRCMode->currentIndex();
		comboBoxIndex[5] = comboBoxNormalizationMode->currentIndex();
		
		//Re-translate from UIC
		Ui::MainWindow::retranslateUi(this);

		//Restore combobox indices
		comboBoxMP3ChannelMode->setCurrentIndex(comboBoxIndex[0]);
		comboBoxSamplingRate->setCurrentIndex(comboBoxIndex[1]);
		comboBoxAACProfile->setCurrentIndex(comboBoxIndex[2]);
		comboBoxAftenCodingMode->setCurrentIndex(comboBoxIndex[3]);
		comboBoxAftenDRCMode->setCurrentIndex(comboBoxIndex[4]);
		comboBoxNormalizationMode->setCurrentIndex(comboBoxIndex[5]);

		//Update the window title
		if(LAMEXP_DEBUG)
		{
			setWindowTitle(QString("%1 [!!! DEBUG BUILD !!!]").arg(windowTitle()));
		}
		else if(lamexp_version_demo())
		{
			setWindowTitle(QString("%1 [%2]").arg(windowTitle(), tr("DEMO VERSION")));
		}

		//Manually re-translate widgets that UIC doesn't handle
		m_dropNoteLabel->setText(QString("� %1 �").arg(tr("You can drop in audio files here!")));
		m_showDetailsContextAction->setText(tr("Show Details"));
		m_previewContextAction->setText(tr("Open File in External Application"));
		m_findFileContextAction->setText(tr("Browse File Location"));
		m_showFolderContextAction->setText(tr("Browse Selected Folder"));
		m_addFavoriteFolderAction->setText(tr("Bookmark Current Output Folder"));
		m_exportCsvContextAction->setText(tr("Export Meta Tags to CSV File"));
		m_importCsvContextAction->setText(tr("Import Meta Tags from CSV File"));

		//Force GUI update
		m_metaInfoModel->clearData();
		m_metaInfoModel->setData(m_metaInfoModel->index(4, 1), m_settings->metaInfoPosition());
		updateEncoder(m_settings->compressionEncoder());
		updateLameAlgoQuality(sliderLameAlgoQuality->value());
		updateMaximumInstances(sliderMaxInstances->value());
		renameOutputPatternChanged(lineEditRenamePattern->text());

		//Re-install shell integration
		if(m_settings->shellIntegrationEnabled())
		{
			ShellIntegration::install();
		}

		//Force resize, if needed
		tabPageChanged(tabWidget->currentIndex());
	}
}

/*
 * File dragged over window
 */
void MainWindow::dragEnterEvent(QDragEnterEvent *event)
{
	QStringList formats = event->mimeData()->formats();
	
	if(formats.contains("application/x-qt-windows-mime;value=\"FileNameW\"", Qt::CaseInsensitive) && formats.contains("text/uri-list", Qt::CaseInsensitive))
	{
		event->acceptProposedAction();
	}
}

/*
 * File dropped onto window
 */
void MainWindow::dropEvent(QDropEvent *event)
{
	ABORT_IF_BUSY;

	QStringList droppedFiles;
	QList<QUrl> urls = event->mimeData()->urls();

	while(!urls.isEmpty())
	{
		QUrl currentUrl = urls.takeFirst();
		QFileInfo file(currentUrl.toLocalFile());
		if(!file.exists())
		{
			continue;
		}
		if(file.isFile())
		{
			qDebug("Dropped File: %s", file.canonicalFilePath().toUtf8().constData());
			droppedFiles << file.canonicalFilePath();
			continue;
		}
		if(file.isDir())
		{
			qDebug("Dropped Folder: %s", file.canonicalFilePath().toUtf8().constData());
			QList<QFileInfo> list = QDir(file.canonicalFilePath()).entryInfoList(QDir::Files | QDir::NoSymLinks);
			if(list.count() > 0)
			{
				for(int j = 0; j < list.count(); j++)
				{
					droppedFiles << list.at(j).canonicalFilePath();
				}
			}
			else
			{
				list = QDir(file.canonicalFilePath()).entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoSymLinks);
				for(int j = 0; j < list.count(); j++)
				{
					qDebug("Descending to Folder: %s", list.at(j).canonicalFilePath().toUtf8().constData());
					urls.prepend(QUrl::fromLocalFile(list.at(j).canonicalFilePath()));
				}
			}
		}
	}
	
	if(!droppedFiles.isEmpty())
	{
		addFilesDelayed(droppedFiles, true);
	}
}

/*
 * Window tries to close
 */
void MainWindow::closeEvent(QCloseEvent *event)
{
	if(m_banner->isVisible() || m_delayedFileTimer->isActive())
	{
		MessageBeep(MB_ICONEXCLAMATION);
		event->ignore();
	}
	
	if(m_dropBox)
	{
		m_dropBox->hide();
	}
}

/*
 * Window was resized
 */
void MainWindow::resizeEvent(QResizeEvent *event)
{
	QMainWindow::resizeEvent(event);
	m_dropNoteLabel->setGeometry(0, 0, sourceFileView->width(), sourceFileView->height());
}

/*
 * Event filter
 */
bool MainWindow::eventFilter(QObject *obj, QEvent *event)
{
	if(obj == m_fileSystemModel)
	{
		if(QApplication::overrideCursor() == NULL)
		{
			QApplication::setOverrideCursor(QCursor(Qt::WaitCursor));
			QTimer::singleShot(250, this, SLOT(restoreCursor()));
		}
	}
	else if(obj == outputFolderView)
	{
		switch(event->type())
		{
		case QEvent::Enter:
		case QEvent::Leave:
		case QEvent::KeyPress:
		case QEvent::KeyRelease:
		case QEvent::FocusIn:
		case QEvent::FocusOut:
		case QEvent::TouchEnd:
			outputFolderViewClicked(outputFolderView->currentIndex());
			break;
		}
	}
	else if(obj == outputFolderLabel)
	{
		switch(event->type())
		{
		case QEvent::MouseButtonPress:
			if(dynamic_cast<QMouseEvent*>(event)->button() == Qt::LeftButton)
			{
				QString path = outputFolderLabel->text();
				if(!path.endsWith(QDir::separator())) path.append(QDir::separator());
				ShellExecuteW(this->winId(), L"explore", QWCHAR(path), NULL, NULL, SW_SHOW);
			}
			break;
		case QEvent::Enter:
			outputFolderLabel->setForegroundRole(QPalette::Link);
			break;
		case QEvent::Leave:
			outputFolderLabel->setForegroundRole(QPalette::WindowText);
			break;
		}
	}
	else if(obj == outputFoldersFovoritesLabel)
	{
		QMouseEvent *mouseEvent = dynamic_cast<QMouseEvent*>(event);
		QPoint pos = (mouseEvent != NULL) ? mouseEvent->pos() : QPoint();
		QWidget *sender = dynamic_cast<QLabel*>(obj);

		switch(event->type())
		{
		case QEvent::Enter:
			outputFoldersFovoritesLabel->setFrameShadow(QFrame::Raised);
			break;
		case QEvent::MouseButtonPress:
			outputFoldersFovoritesLabel->setFrameShadow(QFrame::Sunken);
			break;
		case QEvent::MouseButtonRelease:
			outputFoldersFovoritesLabel->setFrameShadow(QFrame::Raised);
			if(sender && mouseEvent)
			{
				if(pos.x() <= sender->width() && pos.y() <= sender->height() && pos.x() >= 0 && pos.y() >= 0 && mouseEvent->button() != Qt::MidButton)
				{
					m_outputFolderFavoritesMenu->popup(sender->mapToGlobal(pos));
				}
			}
			break;
		case QEvent::Leave:
			outputFoldersFovoritesLabel->setFrameShadow(QFrame::Plain);
			break;
		}
	}

	return QMainWindow::eventFilter(obj, event);
}

bool MainWindow::event(QEvent *e)
{
	switch(e->type())
	{
	case lamexp_event_queryendsession:
		qWarning("System is shutting down, main window prepares to close...");
		if(m_banner->isVisible()) m_banner->close();
		if(m_delayedFileTimer->isActive()) m_delayedFileTimer->stop();
		return true;
	case lamexp_event_endsession:
		qWarning("System is shutting down, main window will close now...");
		if(isVisible())
		{
			while(!close())
			{
				QApplication::processEvents(QEventLoop::WaitForMoreEvents & QEventLoop::ExcludeUserInputEvents);
			}
		}
		m_fileListModel->clearFiles();
		return true;
	default:
		return QMainWindow::event(e);
	}
}

bool MainWindow::winEvent(MSG *message, long *result)
{
	return WinSevenTaskbar::handleWinEvent(message, result);
}

////////////////////////////////////////////////////////////
// Slots
////////////////////////////////////////////////////////////

// =========================================================
// Show window slots
// =========================================================

/*
 * Window shown
 */
void MainWindow::windowShown(void)
{
	QStringList arguments = QApplication::arguments();

	//First run?
	bool firstRun = false;
	for(int i = 0; i < arguments.count(); i++)
	{
		if(!arguments[i].compare("--first-run", Qt::CaseInsensitive)) firstRun = true;
	}

	//Check license
	if((m_settings->licenseAccepted() <= 0) || firstRun)
	{
		int iAccepted = -1;

		if((m_settings->licenseAccepted() == 0) || firstRun)
		{
			AboutDialog *about = new AboutDialog(m_settings, this, true);
			iAccepted = about->exec();
			LAMEXP_DELETE(about);
		}

		if(iAccepted <= 0)
		{
			m_settings->licenseAccepted(-1);
			QApplication::processEvents();
			PlaySound(MAKEINTRESOURCE(IDR_WAVE_WHAMMY), GetModuleHandle(NULL), SND_RESOURCE | SND_SYNC);
			QMessageBox::critical(this, tr("License Declined"), tr("You have declined the license. Consequently the application will exit now!"), tr("Goodbye!"));
			QFileInfo uninstallerInfo = QFileInfo(QString("%1/Uninstall.exe").arg(QApplication::applicationDirPath()));
			if(uninstallerInfo.exists())
			{
				QString uninstallerDir = uninstallerInfo.canonicalPath();
				QString uninstallerPath = uninstallerInfo.canonicalFilePath();
				for(int i = 0; i < 3; i++)
				{
					HINSTANCE res = ShellExecuteW(this->winId(), L"open", QWCHAR(QDir::toNativeSeparators(uninstallerPath)), L"/Force", QWCHAR(QDir::toNativeSeparators(uninstallerDir)), SW_SHOWNORMAL);
					if(reinterpret_cast<int>(res) > 32) break;
				}
			}
			else
			{
				MoveFileEx(QWCHAR(QDir::toNativeSeparators(QFileInfo(QApplication::applicationFilePath()).canonicalFilePath())), NULL, MOVEFILE_DELAY_UNTIL_REBOOT | MOVEFILE_REPLACE_EXISTING);
			}
			QApplication::quit();
			return;
		}
		
		PlaySound(MAKEINTRESOURCE(IDR_WAVE_WOOHOO), GetModuleHandle(NULL), SND_RESOURCE | SND_SYNC);
		m_settings->licenseAccepted(1);
		if(lamexp_version_demo()) showAnnounceBox();
	}
	
	//Check for expiration
	if(lamexp_version_demo())
	{
		if(QDate::currentDate() >= lamexp_version_expires())
		{
			qWarning("Binary has expired !!!");
			PlaySound(MAKEINTRESOURCE(IDR_WAVE_WHAMMY), GetModuleHandle(NULL), SND_RESOURCE | SND_SYNC);
			if(QMessageBox::warning(this, tr("LameXP - Expired"), QString("%1<br>%2").arg(NOBR(tr("This demo (pre-release) version of LameXP has expired at %1.").arg(lamexp_version_expires().toString(Qt::ISODate))), NOBR(tr("LameXP is free software and release versions won't expire."))), tr("Check for Updates"), tr("Exit Program")) == 0)
			{
				checkForUpdates();
			}
			QApplication::quit();
			return;
		}
	}

	//Slow startup indicator
	if(m_settings->slowStartup() && m_settings->antivirNotificationsEnabled())
	{
		QString message;
		message += NOBR(tr("It seems that a bogus anti-virus software is slowing down the startup of LameXP.")).append("<br>");
		message += NOBR(tr("Please refer to the %1 document for details and solutions!")).arg("<a href=\"http://lamexp.git.sourceforge.net/git/gitweb.cgi?p=lamexp/lamexp;a=blob_plain;f=doc/FAQ.html;hb=HEAD#df406578\">F.A.Q.</a>").append("<br>");
		if(QMessageBox::warning(this, tr("Slow Startup"), message, tr("Discard"), tr("Don't Show Again")) == 1)
		{
			m_settings->antivirNotificationsEnabled(false);
			actionDisableSlowStartupNotifications->setChecked(!m_settings->antivirNotificationsEnabled());
		}
	}

	//Update reminder
	if(QDate::currentDate() >= lamexp_version_date().addYears(1))
	{
		qWarning("Binary is more than a year old, time to update!");
		int ret = QMessageBox::warning(this, tr("Urgent Update"), NOBR(tr("Your version of LameXP is more than a year old. Time for an update!")), tr("Check for Updates"), tr("Exit Program"), tr("Ignore"));
		switch(ret)
		{
		case 0:
			if(checkForUpdates())
			{
				QApplication::quit();
				return;
			}
			break;
		case 1:
			QApplication::quit();
			return;
		default:
			QEventLoop loop; QTimer::singleShot(7000, &loop, SLOT(quit()));
			PlaySound(MAKEINTRESOURCE(IDR_WAVE_WAITING), GetModuleHandle(NULL), SND_RESOURCE | SND_ASYNC);
			m_banner->show(tr("Skipping update check this time, please be patient..."), &loop);
			break;
		}
	}
	else if(m_settings->autoUpdateEnabled())
	{
		QDate lastUpdateCheck = QDate::fromString(m_settings->autoUpdateLastCheck(), Qt::ISODate);
		if(!firstRun && (!lastUpdateCheck.isValid() || QDate::currentDate() >= lastUpdateCheck.addDays(14)))
		{
			if(QMessageBox::information(this, tr("Update Reminder"), NOBR(lastUpdateCheck.isValid() ? tr("Your last update check was more than 14 days ago. Check for updates now?") : tr("Your did not check for LameXP updates yet. Check for updates now?")), tr("Check for Updates"), tr("Postpone")) == 0)
			{
				if(checkForUpdates())
				{
					QApplication::quit();
					return;
				}
			}
		}
	}

	//Check for AAC support
	if(m_neroEncoderAvailable)
	{
		if(m_settings->neroAacNotificationsEnabled())
		{
			if(lamexp_tool_version("neroAacEnc.exe") < lamexp_toolver_neroaac())
			{
				QString messageText;
				messageText += NOBR(tr("LameXP detected that your version of the Nero AAC encoder is outdated!")).append("<br>");
				messageText += NOBR(tr("The current version available is %1 (or later), but you still have version %2 installed.").arg(lamexp_version2string("?.?.?.?", lamexp_toolver_neroaac(), tr("n/a")), lamexp_version2string("?.?.?.?", lamexp_tool_version("neroAacEnc.exe"), tr("n/a")))).append("<br><br>");
				messageText += NOBR(tr("You can download the latest version of the Nero AAC encoder from the Nero website at:")).append("<br>");
				messageText += "<nobr><tt>" + LINK(AboutDialog::neroAacUrl) + "</tt></nobr><br><br>";
				messageText += NOBR(tr("(Hint: Please ignore the name of the downloaded ZIP file and check the included 'changelog.txt' instead!)")).append("<br>");
				QMessageBox::information(this, tr("AAC Encoder Outdated"), messageText);
			}
		}
	}
	else
	{
		if(m_settings->neroAacNotificationsEnabled() && (!(m_fhgEncoderAvailable || m_qaacEncoderAvailable)))
		{
			QString appPath = QDir(QCoreApplication::applicationDirPath()).canonicalPath();
			if(appPath.isEmpty()) appPath = QCoreApplication::applicationDirPath();
			QString messageText;
			messageText += NOBR(tr("The Nero AAC encoder could not be found. AAC encoding support will be disabled.")).append("<br>");
			messageText += NOBR(tr("Please put 'neroAacEnc.exe', 'neroAacDec.exe' and 'neroAacTag.exe' into the LameXP directory!")).append("<br><br>");
			messageText += NOBR(tr("Your LameXP directory is located here:")).append("<br>");
			messageText += QString("<nobr><tt>%1</tt></nobr><br><br>").arg(FSLINK(QDir::toNativeSeparators(appPath)));
			messageText += NOBR(tr("You can download the Nero AAC encoder for free from the official Nero website at:")).append("<br>");
			messageText += "<nobr><tt>" + LINK(AboutDialog::neroAacUrl) + "</tt></nobr><br>";
			if(QMessageBox::information(this, tr("AAC Support Disabled"), messageText, tr("Discard"), tr("Don't Show Again")) == 1)
			{
				m_settings->neroAacNotificationsEnabled(false);
				actionDisableNeroAacNotifications->setChecked(!m_settings->neroAacNotificationsEnabled());
			}
		}
	}

	//Add files from the command-line
	for(int i = 0; i < arguments.count() - 1; i++)
	{
		QStringList addedFiles;
		if(!arguments[i].compare("--add", Qt::CaseInsensitive))
		{
			QFileInfo currentFile(arguments[++i].trimmed());
			qDebug("Adding file from CLI: %s", currentFile.absoluteFilePath().toUtf8().constData());
			addedFiles.append(currentFile.absoluteFilePath());
		}
		if(!addedFiles.isEmpty())
		{
			addFilesDelayed(addedFiles);
		}
	}

	//Add folders from the command-line
	for(int i = 0; i < arguments.count() - 1; i++)
	{
		if(!arguments[i].compare("--add-folder", Qt::CaseInsensitive))
		{
			QFileInfo currentFile(arguments[++i].trimmed());
			qDebug("Adding folder from CLI: %s", currentFile.absoluteFilePath().toUtf8().constData());
			addFolder(currentFile.absoluteFilePath(), false, true);
		}
		if(!arguments[i].compare("--add-recursive", Qt::CaseInsensitive))
		{
			QFileInfo currentFile(arguments[++i].trimmed());
			qDebug("Adding folder recursively from CLI: %s", currentFile.absoluteFilePath().toUtf8().constData());
			addFolder(currentFile.absoluteFilePath(), true, true);
		}
	}

	//Enable shell integration
	if(m_settings->shellIntegrationEnabled())
	{
		ShellIntegration::install();
	}

	//Make DropBox visible
	if(m_settings->dropBoxWidgetEnabled())
	{
		m_dropBox->setVisible(true);
	}
}

/*
 * Show announce box
 */
void MainWindow::showAnnounceBox(void)
{
	const unsigned int timeout = 8U;

	const QString announceText = QString("%1<br><br>%2<br><nobr><tt>%3</tt></nobr><br>").arg
	(
		NOBR("We are still looking for LameXP translators!"),
		NOBR("If you are willing to translate LameXP to your language or to complete an existing translation, please refer to:"),
		LINK("http://mulder.brhack.net/public/doc/lamexp_translate.html")
	);

	QMessageBox *announceBox = new QMessageBox(QMessageBox::Warning, "We want you!", announceText, QMessageBox::NoButton, this);
	announceBox->setWindowFlags(Qt::Window | Qt::WindowTitleHint | Qt::CustomizeWindowHint);
	announceBox->setIconPixmap(QIcon(":/images/Announcement.png").pixmap(64,79));
	
	QTimer *timers[timeout+1];
	QPushButton *buttons[timeout+1];

	for(unsigned int i = 0; i <= timeout; i++)
	{
		QString text = (i > 0) ? QString("%1 (%2)").arg(tr("Discard"), QString::number(i)) : tr("Discard");
		buttons[i] = announceBox->addButton(text, (i > 0) ? QMessageBox::NoRole : QMessageBox::AcceptRole);
	}

	for(unsigned int i = 0; i <= timeout; i++)
	{
		buttons[i]->setEnabled(i == 0);
		buttons[i]->setVisible(i == timeout);
	}

	for(unsigned int i = 0; i < timeout; i++)
	{
		timers[i] = new QTimer(this);
		timers[i]->setSingleShot(true);
		timers[i]->setInterval(1000);
		connect(timers[i], SIGNAL(timeout()), buttons[i+1], SLOT(hide()));
		connect(timers[i], SIGNAL(timeout()), buttons[i], SLOT(show()));
		if(i > 0)
		{
			connect(timers[i], SIGNAL(timeout()), timers[i-1], SLOT(start()));
		}
	}

	timers[timeout-1]->start();
	announceBox->exec();

	for(unsigned int i = 0; i < timeout; i++)
	{
		timers[i]->stop();
		LAMEXP_DELETE(timers[i]);
	}

	LAMEXP_DELETE(announceBox);
}

// =========================================================
// Main button solots
// =========================================================

/*
 * Encode button
 */
void MainWindow::encodeButtonClicked(void)
{
	static const unsigned __int64 oneGigabyte = 1073741824ui64; 
	static const unsigned __int64 minimumFreeDiskspaceMultiplier = 2ui64;
	static const char *writeTestBuffer = "LAMEXP_WRITE_TEST";
	
	ABORT_IF_BUSY;

	if(m_fileListModel->rowCount() < 1)
	{
		QMessageBox::warning(this, tr("LameXP"), NOBR(tr("You must add at least one file to the list before proceeding!")));
		tabWidget->setCurrentIndex(0);
		return;
	}
	
	QString tempFolder = m_settings->customTempPathEnabled() ? m_settings->customTempPath() : lamexp_temp_folder2();
	if(!QFileInfo(tempFolder).exists() || !QFileInfo(tempFolder).isDir())
	{
		if(QMessageBox::warning(this, tr("Not Found"), QString("%1<br><tt>%2</tt>").arg(NOBR(tr("Your currently selected TEMP folder does not exist anymore:")), NOBR(QDir::toNativeSeparators(tempFolder))), tr("Restore Default"), tr("Cancel")) == 0)
		{
			while(checkBoxUseSystemTempFolder->isChecked() == m_settings->customTempPathEnabledDefault()) checkBoxUseSystemTempFolder->click();
		}
		return;
	}

	bool ok = false;
	unsigned __int64 currentFreeDiskspace = lamexp_free_diskspace(tempFolder, &ok);

	if(ok && (currentFreeDiskspace < (oneGigabyte * minimumFreeDiskspaceMultiplier)))
	{
		QStringList tempFolderParts = tempFolder.split("/", QString::SkipEmptyParts, Qt::CaseInsensitive);
		tempFolderParts.takeLast();
		if(m_settings->soundsEnabled()) PlaySound(MAKEINTRESOURCE(IDR_WAVE_WHAMMY), GetModuleHandle(NULL), SND_RESOURCE | SND_SYNC);
		QString lowDiskspaceMsg = QString("%1<br>%2<br><br>%3<br>%4<br>").arg
		(
			NOBR(tr("There are less than %1 GB of free diskspace available on your system's TEMP folder.").arg(QString::number(minimumFreeDiskspaceMultiplier))),
			NOBR(tr("It is highly recommend to free up more diskspace before proceeding with the encode!")),
			NOBR(tr("Your TEMP folder is located at:")),
			QString("<nobr><tt>%1</tt></nobr>").arg(FSLINK(tempFolderParts.join("\\")))
		);
		switch(QMessageBox::warning(this, tr("Low Diskspace Warning"), lowDiskspaceMsg, tr("Abort Encoding Process"), tr("Clean Disk Now"), tr("Ignore")))
		{
		case 1:
			QProcess::startDetached(QString("%1/cleanmgr.exe").arg(lamexp_known_folder(lamexp_folder_systemfolder)), QStringList() << "/D" << tempFolderParts.first());
		case 0:
			return;
			break;
		default:
			QMessageBox::warning(this, tr("Low Diskspace"), tr("You are proceeding with low diskspace. Problems might occur!"));
			break;
		}
	}

	switch(m_settings->compressionEncoder())
	{
	case SettingsModel::MP3Encoder:
	case SettingsModel::VorbisEncoder:
	case SettingsModel::AACEncoder:
	case SettingsModel::AC3Encoder:
	case SettingsModel::FLACEncoder:
	case SettingsModel::DCAEncoder:
	case SettingsModel::PCMEncoder:
		break;
	default:
		QMessageBox::warning(this, tr("LameXP"), tr("Sorry, an unsupported encoder has been chosen!"));
		tabWidget->setCurrentIndex(3);
		return;
	}

	if(!m_settings->outputToSourceDir())
	{
		QFile writeTest(QString("%1/~%2.txt").arg(m_settings->outputDir(), lamexp_rand_str()));
		if(!(writeTest.open(QIODevice::ReadWrite) && (writeTest.write(writeTestBuffer) == strlen(writeTestBuffer))))
		{
			QMessageBox::warning(this, tr("LameXP"), QString("%1<br><nobr>%2</nobr><br><br>%3").arg(tr("Cannot write to the selected output directory."), m_settings->outputDir(), tr("Please choose a different directory!")));
			tabWidget->setCurrentIndex(1);
			return;
		}
		else
		{
			writeTest.close();
			writeTest.remove();
		}
	}
		
	m_accepted = true;
	close();
}

/*
 * About button
 */
void MainWindow::aboutButtonClicked(void)
{
	ABORT_IF_BUSY;

	TEMP_HIDE_DROPBOX
	(
		AboutDialog *aboutBox = new AboutDialog(m_settings, this);
		aboutBox->exec();
		LAMEXP_DELETE(aboutBox);
	)
}

/*
 * Close button
 */
void MainWindow::closeButtonClicked(void)
{
	ABORT_IF_BUSY;
	close();
}

// =========================================================
// Tab widget slots
// =========================================================

/*
 * Tab page changed
 */
void MainWindow::tabPageChanged(int idx)
{
	QList<QAction*> actions = m_tabActionGroup->actions();
	for(int i = 0; i < actions.count(); i++)
	{
		bool ok = false;
		int actionIndex = actions.at(i)->data().toInt(&ok);
		if(ok && actionIndex == idx)
		{
			actions.at(i)->setChecked(true);
		}
	}

	int initialWidth = this->width();
	int maximumWidth = QApplication::desktop()->width();

	if(this->isVisible())
	{
		while(tabWidget->width() < tabWidget->sizeHint().width())
		{
			int previousWidth = this->width();
			this->resize(this->width() + 1, this->height());
			if(this->frameGeometry().width() >= maximumWidth) break;
			if(this->width() <= previousWidth) break;
		}
	}

	if(idx == tabWidget->indexOf(tabOptions) && scrollArea->widget() && this->isVisible())
	{
		for(int i = 0; i < 2; i++)
		{
			QApplication::processEvents();
			while(scrollArea->viewport()->width() < scrollArea->widget()->width())
			{
				int previousWidth = this->width();
				this->resize(this->width() + 1, this->height());
				if(this->frameGeometry().width() >= maximumWidth) break;
				if(this->width() <= previousWidth) break;
			}
		}
	}
	else if(idx == tabWidget->indexOf(tabSourceFiles))
	{
		m_dropNoteLabel->setGeometry(0, 0, sourceFileView->width(), sourceFileView->height());
	}
	else if(idx == tabWidget->indexOf(tabOutputDir))
	{
		if(!m_OutputFolderViewInitialized)
		{
			QTimer::singleShot(0, this, SLOT(initOutputFolderModel()));
		}
	}

	if(initialWidth < this->width())
	{
		QPoint prevPos = this->pos();
		int delta = (this->width() - initialWidth) >> 2;
		move(prevPos.x() - delta, prevPos.y());
	}
}

/*
 * Tab action triggered
 */
void MainWindow::tabActionActivated(QAction *action)
{
	if(action && action->data().isValid())
	{
		bool ok = false;
		int index = action->data().toInt(&ok);
		if(ok)
		{
			tabWidget->setCurrentIndex(index);
		}
	}
}

// =========================================================
// View menu slots
// =========================================================

/*
 * Style action triggered
 */
void MainWindow::styleActionActivated(QAction *action)
{
	//Change style setting
	if(action && action->data().isValid())
	{
		bool ok = false;
		int actionIndex = action->data().toInt(&ok);
		if(ok)
		{
			m_settings->interfaceStyle(actionIndex);
		}
	}

	//Set up the new style
	switch(m_settings->interfaceStyle())
	{
	case 1:
		if(actionStyleCleanlooks->isEnabled())
		{
			actionStyleCleanlooks->setChecked(true);
			QApplication::setStyle(new QCleanlooksStyle());
			break;
		}
	case 2:
		if(actionStyleWindowsVista->isEnabled())
		{
			actionStyleWindowsVista->setChecked(true);
			QApplication::setStyle(new QWindowsVistaStyle());
			break;
		}
	case 3:
		if(actionStyleWindowsXP->isEnabled())
		{
			actionStyleWindowsXP->setChecked(true);
			QApplication::setStyle(new QWindowsXPStyle());
			break;
		}
	case 4:
		if(actionStyleWindowsClassic->isEnabled())
		{
			actionStyleWindowsClassic->setChecked(true);
			QApplication::setStyle(new QWindowsStyle());
			break;
		}
	default:
		actionStylePlastique->setChecked(true);
		QApplication::setStyle(new QPlastiqueStyle());
		break;
	}

	//Force re-translate after style change
	changeEvent(new QEvent(QEvent::LanguageChange));
}

/*
 * Language action triggered
 */
void MainWindow::languageActionActivated(QAction *action)
{
	if(action->data().type() == QVariant::String)
	{
		QString langId = action->data().toString();

		if(lamexp_install_translator(langId))
		{
			action->setChecked(true);
			m_settings->currentLanguage(langId);
		}
	}
}

/*
 * Load language from file action triggered
 */
void MainWindow::languageFromFileActionActivated(bool checked)
{
	QFileDialog dialog(this, tr("Load Translation"));
	dialog.setFileMode(QFileDialog::ExistingFile);
	dialog.setNameFilter(QString("%1 (*.qm)").arg(tr("Translation Files")));

	if(dialog.exec())
	{
		QStringList selectedFiles = dialog.selectedFiles();
		if(lamexp_install_translator_from_file(selectedFiles.first()))
		{
			QList<QAction*> actions = m_languageActionGroup->actions();
			while(!actions.isEmpty())
			{
				actions.takeFirst()->setChecked(false);
			}
		}
		else
		{
			languageActionActivated(m_languageActionGroup->actions().first());
		}
	}
}

// =========================================================
// Tools menu slots
// =========================================================

/*
 * Disable update reminder action
 */
void MainWindow::disableUpdateReminderActionTriggered(bool checked)
{
	if(checked)
	{
		if(0 == QMessageBox::question(this, tr("Disable Update Reminder"), NOBR(tr("Do you really want to disable the update reminder?")), tr("Yes"), tr("No"), QString(), 1))
		{
			QMessageBox::information(this, tr("Update Reminder"), QString("%1<br>%2").arg(NOBR(tr("The update reminder has been disabled.")), NOBR(tr("Please remember to check for updates at regular intervals!"))));
			m_settings->autoUpdateEnabled(false);
		}
		else
		{
			m_settings->autoUpdateEnabled(true);
		}
	}
	else
	{
			QMessageBox::information(this, tr("Update Reminder"), NOBR(tr("The update reminder has been re-enabled.")));
			m_settings->autoUpdateEnabled(true);
	}

	actionDisableUpdateReminder->setChecked(!m_settings->autoUpdateEnabled());
}

/*
 * Disable sound effects action
 */
void MainWindow::disableSoundsActionTriggered(bool checked)
{
	if(checked)
	{
		if(0 == QMessageBox::question(this, tr("Disable Sound Effects"), NOBR(tr("Do you really want to disable all sound effects?")), tr("Yes"), tr("No"), QString(), 1))
		{
			QMessageBox::information(this, tr("Sound Effects"), NOBR(tr("All sound effects have been disabled.")));
			m_settings->soundsEnabled(false);
		}
		else
		{
			m_settings->soundsEnabled(true);
		}
	}
	else
	{
			QMessageBox::information(this, tr("Sound Effects"), NOBR(tr("The sound effects have been re-enabled.")));
			m_settings->soundsEnabled(true);
	}

	actionDisableSounds->setChecked(!m_settings->soundsEnabled());
}

/*
 * Disable Nero AAC encoder action
 */
void MainWindow::disableNeroAacNotificationsActionTriggered(bool checked)
{
	if(checked)
	{
		if(0 == QMessageBox::question(this, tr("Nero AAC Notifications"), NOBR(tr("Do you really want to disable all Nero AAC Encoder notifications?")), tr("Yes"), tr("No"), QString(), 1))
		{
			QMessageBox::information(this, tr("Nero AAC Notifications"), NOBR(tr("All Nero AAC Encoder notifications have been disabled.")));
			m_settings->neroAacNotificationsEnabled(false);
		}
		else
		{
			m_settings->neroAacNotificationsEnabled(true);
		}
	}
	else
	{
			QMessageBox::information(this, tr("Nero AAC Notifications"), NOBR(tr("The Nero AAC Encoder notifications have been re-enabled.")));
			m_settings->neroAacNotificationsEnabled(true);
	}

	actionDisableNeroAacNotifications->setChecked(!m_settings->neroAacNotificationsEnabled());
}

/*
 * Disable slow startup action
 */
void MainWindow::disableSlowStartupNotificationsActionTriggered(bool checked)
{
	if(checked)
	{
		if(0 == QMessageBox::question(this, tr("Slow Startup Notifications"), NOBR(tr("Do you really want to disable the slow startup notifications?")), tr("Yes"), tr("No"), QString(), 1))
		{
			QMessageBox::information(this, tr("Slow Startup Notifications"), NOBR(tr("The slow startup notifications have been disabled.")));
			m_settings->antivirNotificationsEnabled(false);
		}
		else
		{
			m_settings->antivirNotificationsEnabled(true);
		}
	}
	else
	{
			QMessageBox::information(this, tr("Slow Startup Notifications"), NOBR(tr("The slow startup notifications have been re-enabled.")));
			m_settings->antivirNotificationsEnabled(true);
	}

	actionDisableSlowStartupNotifications->setChecked(!m_settings->antivirNotificationsEnabled());
}

/*
 * Import a Cue Sheet file
 */
void MainWindow::importCueSheetActionTriggered(bool checked)
{
	ABORT_IF_BUSY;
	
	TEMP_HIDE_DROPBOX
	(
		while(true)
		{
			int result = 0;
			QString selectedCueFile;

			if(USE_NATIVE_FILE_DIALOG)
			{
				selectedCueFile = QFileDialog::getOpenFileName(this, tr("Open Cue Sheet"), m_settings->mostRecentInputPath(), QString("%1 (*.cue)").arg(tr("Cue Sheet File")));
			}
			else
			{
				QFileDialog dialog(this, tr("Open Cue Sheet"));
				dialog.setFileMode(QFileDialog::ExistingFile);
				dialog.setNameFilter(QString("%1 (*.cue)").arg(tr("Cue Sheet File")));
				dialog.setDirectory(m_settings->mostRecentInputPath());
				if(dialog.exec())
				{
					selectedCueFile = dialog.selectedFiles().first();
				}
			}

			if(!selectedCueFile.isEmpty())
			{
				m_settings->mostRecentInputPath(QFileInfo(selectedCueFile).canonicalPath());
				CueImportDialog *cueImporter  = new CueImportDialog(this, m_fileListModel, selectedCueFile);
				result = cueImporter->exec();
				LAMEXP_DELETE(cueImporter);
			}

			if(result != (-1)) break;
		}
	)
}

/*
 * Show the "drop box" widget
 */
void MainWindow::showDropBoxWidgetActionTriggered(bool checked)
{
	m_settings->dropBoxWidgetEnabled(true);
	
	if(!m_dropBox->isVisible())
	{
		m_dropBox->show();
	}
	
	lamexp_blink_window(m_dropBox);
}

/*
 * Check for beta (pre-release) updates
 */
void MainWindow::checkForBetaUpdatesActionTriggered(bool checked)
{	
	bool checkUpdatesNow = false;
	
	if(checked)
	{
		if(0 == QMessageBox::question(this, tr("Beta Updates"), NOBR(tr("Do you really want LameXP to check for Beta (pre-release) updates?")), tr("Yes"), tr("No"), QString(), 1))
		{
			if(0 == QMessageBox::information(this, tr("Beta Updates"), NOBR(tr("LameXP will check for Beta (pre-release) updates from now on.")), tr("Check Now"), tr("Discard")))
			{
				checkUpdatesNow = true;
			}
			m_settings->autoUpdateCheckBeta(true);
		}
		else
		{
			m_settings->autoUpdateCheckBeta(false);
		}
	}
	else
	{
			QMessageBox::information(this, tr("Beta Updates"), NOBR(tr("LameXP will <i>not</i> check for Beta (pre-release) updates from now on.")));
			m_settings->autoUpdateCheckBeta(false);
	}

	actionCheckForBetaUpdates->setChecked(m_settings->autoUpdateCheckBeta());

	if(checkUpdatesNow)
	{
		if(checkForUpdates())
		{
			QApplication::quit();
		}
	}
}

/*
 * Hibernate computer action
 */
void MainWindow::hibernateComputerActionTriggered(bool checked)
{
	if(checked)
	{
		if(0 == QMessageBox::question(this, tr("Hibernate Computer"), NOBR(tr("Do you really want the computer to be hibernated on shutdown?")), tr("Yes"), tr("No"), QString(), 1))
		{
			QMessageBox::information(this, tr("Hibernate Computer"), NOBR(tr("LameXP will hibernate the computer on shutdown from now on.")));
			m_settings->hibernateComputer(true);
		}
		else
		{
			m_settings->hibernateComputer(false);
		}
	}
	else
	{
			QMessageBox::information(this, tr("Hibernate Computer"), NOBR(tr("LameXP will <i>not</i> hibernate the computer on shutdown from now on.")));
			m_settings->hibernateComputer(false);
	}

	actionHibernateComputer->setChecked(m_settings->hibernateComputer());
}

/*
 * Disable shell integration action
 */
void MainWindow::disableShellIntegrationActionTriggered(bool checked)
{
	if(checked)
	{
		if(0 == QMessageBox::question(this, tr("Shell Integration"), NOBR(tr("Do you really want to disable the LameXP shell integration?")), tr("Yes"), tr("No"), QString(), 1))
		{
			ShellIntegration::remove();
			QMessageBox::information(this, tr("Shell Integration"), NOBR(tr("The LameXP shell integration has been disabled.")));
			m_settings->shellIntegrationEnabled(false);
		}
		else
		{
			m_settings->shellIntegrationEnabled(true);
		}
	}
	else
	{
			ShellIntegration::install();
			QMessageBox::information(this, tr("Shell Integration"), NOBR(tr("The LameXP shell integration has been re-enabled.")));
			m_settings->shellIntegrationEnabled(true);
	}

	actionDisableShellIntegration->setChecked(!m_settings->shellIntegrationEnabled());
	
	if(lamexp_portable_mode() && actionDisableShellIntegration->isChecked())
	{
		actionDisableShellIntegration->setEnabled(false);
	}
}

// =========================================================
// Help menu slots
// =========================================================

/*
 * Visit homepage action
 */
void MainWindow::visitHomepageActionActivated(void)
{
	if(QAction *action = dynamic_cast<QAction*>(QObject::sender()))
	{
		if(action->data().isValid() && (action->data().type() == QVariant::String))
		{
			QDesktopServices::openUrl(QUrl(action->data().toString()));
		}
	}
}

/*
 * Show document
 */
void MainWindow::documentActionActivated(void)
{
	if(QAction *action = dynamic_cast<QAction*>(QObject::sender()))
	{
		if(action->data().isValid() && (action->data().type() == QVariant::String))
		{
			QFileInfo document(action->data().toString());
			QFileInfo resource(QString(":/doc/%1.html").arg(document.baseName()));
			if(document.exists() && document.isFile() && (document.size() == resource.size()))
			{
				QDesktopServices::openUrl(QUrl::fromLocalFile(document.canonicalFilePath()));
			}
			else
			{
				QFile source(resource.filePath());
				QFile output(QString("%1/%2.%3.html").arg(lamexp_temp_folder2(), document.baseName(), lamexp_rand_str().left(8)));
				if(source.open(QIODevice::ReadOnly) && output.open(QIODevice::ReadWrite))
				{
					output.write(source.readAll());
					action->setData(output.fileName());
					source.close();
					output.close();
					QDesktopServices::openUrl(QUrl::fromLocalFile(output.fileName()));
				}
			}
		}
	}
}

/*
 * Check for updates action
 */
void MainWindow::checkUpdatesActionActivated(void)
{
	ABORT_IF_BUSY;
	bool bFlag = false;

	TEMP_HIDE_DROPBOX
	(
		bFlag = checkForUpdates();
	)
	
	if(bFlag)
	{
		QApplication::quit();
	}
}

// =========================================================
// Source file slots
// =========================================================

/*
 * Add file(s) button
 */
void MainWindow::addFilesButtonClicked(void)
{
	ABORT_IF_BUSY;

	TEMP_HIDE_DROPBOX
	(
		if(USE_NATIVE_FILE_DIALOG)
		{
			QStringList fileTypeFilters = DecoderRegistry::getSupportedTypes();
			QStringList selectedFiles = QFileDialog::getOpenFileNames(this, tr("Add file(s)"), m_settings->mostRecentInputPath(), fileTypeFilters.join(";;"));
			if(!selectedFiles.isEmpty())
			{
				m_settings->mostRecentInputPath(QFileInfo(selectedFiles.first()).canonicalPath());
				addFiles(selectedFiles);
			}
		}
		else
		{
			QFileDialog dialog(this, tr("Add file(s)"));
			QStringList fileTypeFilters = DecoderRegistry::getSupportedTypes();
			dialog.setFileMode(QFileDialog::ExistingFiles);
			dialog.setNameFilter(fileTypeFilters.join(";;"));
			dialog.setDirectory(m_settings->mostRecentInputPath());
			if(dialog.exec())
			{
				QStringList selectedFiles = dialog.selectedFiles();
				if(!selectedFiles.isEmpty())
				{
					m_settings->mostRecentInputPath(QFileInfo(selectedFiles.first()).canonicalPath());
					addFiles(selectedFiles);
				}
			}
		}
	)
}

/*
 * Open folder action
 */
void MainWindow::openFolderActionActivated(void)
{
	ABORT_IF_BUSY;
	QString selectedFolder;
	
	if(QAction *action = dynamic_cast<QAction*>(QObject::sender()))
	{
		TEMP_HIDE_DROPBOX
		(
			if(USE_NATIVE_FILE_DIALOG)
			{
				selectedFolder = QFileDialog::getExistingDirectory(this, tr("Add Folder"), m_settings->mostRecentInputPath());
			}
			else
			{
				QFileDialog dialog(this, tr("Add Folder"));
				dialog.setFileMode(QFileDialog::DirectoryOnly);
				dialog.setDirectory(m_settings->mostRecentInputPath());
				if(dialog.exec())
				{
					selectedFolder = dialog.selectedFiles().first();
				}
			}
			
			if(!selectedFolder.isEmpty())
			{
				m_settings->mostRecentInputPath(QDir(selectedFolder).canonicalPath());
				addFolder(selectedFolder, action->data().toBool());
			}
		)
	}
}

/*
 * Remove file button
 */
void MainWindow::removeFileButtonClicked(void)
{
	if(sourceFileView->currentIndex().isValid())
	{
		int iRow = sourceFileView->currentIndex().row();
		m_fileListModel->removeFile(sourceFileView->currentIndex());
		sourceFileView->selectRow(iRow < m_fileListModel->rowCount() ? iRow : m_fileListModel->rowCount()-1);
	}
}

/*
 * Clear files button
 */
void MainWindow::clearFilesButtonClicked(void)
{
	m_fileListModel->clearFiles();
}

/*
 * Move file up button
 */
void MainWindow::fileUpButtonClicked(void)
{
	if(sourceFileView->currentIndex().isValid())
	{
		int iRow = sourceFileView->currentIndex().row() - 1;
		m_fileListModel->moveFile(sourceFileView->currentIndex(), -1);
		sourceFileView->selectRow(iRow >= 0 ? iRow : 0);
	}
}

/*
 * Move file down button
 */
void MainWindow::fileDownButtonClicked(void)
{
	if(sourceFileView->currentIndex().isValid())
	{
		int iRow = sourceFileView->currentIndex().row() + 1;
		m_fileListModel->moveFile(sourceFileView->currentIndex(), 1);
		sourceFileView->selectRow(iRow < m_fileListModel->rowCount() ? iRow : m_fileListModel->rowCount()-1);
	}
}

/*
 * Show details button
 */
void MainWindow::showDetailsButtonClicked(void)
{
	ABORT_IF_BUSY;

	int iResult = 0;
	MetaInfoDialog *metaInfoDialog = new MetaInfoDialog(this);
	QModelIndex index = sourceFileView->currentIndex();

	while(index.isValid())
	{
		if(iResult > 0)
		{
			index = m_fileListModel->index(index.row() + 1, index.column()); 
			sourceFileView->selectRow(index.row());
		}
		if(iResult < 0)
		{
			index = m_fileListModel->index(index.row() - 1, index.column()); 
			sourceFileView->selectRow(index.row());
		}

		AudioFileModel &file = (*m_fileListModel)[index];
		TEMP_HIDE_DROPBOX
		(
			iResult = metaInfoDialog->exec(file, index.row() > 0, index.row() < m_fileListModel->rowCount() - 1);
		)
		
		if(iResult == INT_MAX)
		{
			m_metaInfoModel->assignInfoFrom(file);
			tabWidget->setCurrentIndex(tabWidget->indexOf(tabMetaData));
			break;
		}

		if(!iResult) break;
	}

	LAMEXP_DELETE(metaInfoDialog);
	QApplication::processEvents(QEventLoop::ExcludeUserInputEvents);
	sourceFilesScrollbarMoved(0);
}

/*
 * Show context menu for source files
 */
void MainWindow::sourceFilesContextMenu(const QPoint &pos)
{
	QAbstractScrollArea *scrollArea = dynamic_cast<QAbstractScrollArea*>(QObject::sender());
	QWidget *sender = scrollArea ? scrollArea->viewport() : dynamic_cast<QWidget*>(QObject::sender());

	if(sender)
	{
		if(pos.x() <= sender->width() && pos.y() <= sender->height() && pos.x() >= 0 && pos.y() >= 0)
		{
			m_sourceFilesContextMenu->popup(sender->mapToGlobal(pos));
		}
	}
}

/*
 * Scrollbar of source files moved
 */
void MainWindow::sourceFilesScrollbarMoved(int)
{
	sourceFileView->resizeColumnToContents(0);
}

/*
 * Open selected file in external player
 */
void MainWindow::previewContextActionTriggered(void)
{
	const static char *appNames[3] = {"smplayer_portable.exe", "smplayer.exe", "mplayer.exe"};
	const static wchar_t *registryKey = L"SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\{DB9E4EAB-2717-499F-8D56-4CC8A644AB60}";
	
	QModelIndex index = sourceFileView->currentIndex();
	if(!index.isValid())
	{
		return;
	}

	QString mplayerPath;
	HKEY registryKeyHandle;

	if(RegOpenKeyExW(HKEY_LOCAL_MACHINE, registryKey, 0, KEY_READ, &registryKeyHandle) == ERROR_SUCCESS)
	{
		wchar_t Buffer[4096];
		DWORD BuffSize = sizeof(wchar_t*) * 4096;
		if(RegQueryValueExW(registryKeyHandle, L"InstallLocation", 0, 0, reinterpret_cast<BYTE*>(Buffer), &BuffSize) == ERROR_SUCCESS)
		{
			mplayerPath = QString::fromUtf16(reinterpret_cast<const unsigned short*>(Buffer));
		}
	}

	if(!mplayerPath.isEmpty())
	{
		QDir mplayerDir(mplayerPath);
		if(mplayerDir.exists())
		{
			for(int i = 0; i < 3; i++)
			{
				if(mplayerDir.exists(appNames[i]))
				{
					QProcess::startDetached(mplayerDir.absoluteFilePath(appNames[i]), QStringList() << QDir::toNativeSeparators(m_fileListModel->getFile(index).filePath()));
					return;
				}
			}
		}
	}
	
	QDesktopServices::openUrl(QString("file:///").append(m_fileListModel->getFile(index).filePath()));
}

/*
 * Find selected file in explorer
 */
void MainWindow::findFileContextActionTriggered(void)
{
	QModelIndex index = sourceFileView->currentIndex();
	if(index.isValid())
	{
		QString systemRootPath;

		QDir systemRoot(lamexp_known_folder(lamexp_folder_systemfolder));
		if(systemRoot.exists() && systemRoot.cdUp())
		{
			systemRootPath = systemRoot.canonicalPath();
		}

		if(!systemRootPath.isEmpty())
		{
			QFileInfo explorer(QString("%1/explorer.exe").arg(systemRootPath));
			if(explorer.exists() && explorer.isFile())
			{
				QProcess::execute(explorer.canonicalFilePath(), QStringList() << "/select," << QDir::toNativeSeparators(m_fileListModel->getFile(index).filePath()));
				return;
			}
		}
		else
		{
			qWarning("SystemRoot directory could not be detected!");
		}
	}
}

/*
 * Add all pending files
 */
void MainWindow::handleDelayedFiles(void)
{
	m_delayedFileTimer->stop();

	if(m_delayedFileList->isEmpty())
	{
		return;
	}

	if(m_banner->isVisible())
	{
		m_delayedFileTimer->start(5000);
		return;
	}

	QStringList selectedFiles;
	tabWidget->setCurrentIndex(0);

	while(!m_delayedFileList->isEmpty())
	{
		QFileInfo currentFile = QFileInfo(m_delayedFileList->takeFirst());
		if(!currentFile.exists() || !currentFile.isFile())
		{
			continue;
		}
		selectedFiles << currentFile.canonicalFilePath();
	}
	
	addFiles(selectedFiles);
}

/*
 * Export Meta tags to CSV file
 */
void MainWindow::exportCsvContextActionTriggered(void)
{
	TEMP_HIDE_DROPBOX
	(
		QString selectedCsvFile;
	
		if(USE_NATIVE_FILE_DIALOG)
		{
			selectedCsvFile = QFileDialog::getSaveFileName(this, tr("Save CSV file"), m_settings->mostRecentInputPath(), QString("%1 (*.csv)").arg(tr("CSV File")));
		}
		else
		{
			QFileDialog dialog(this, tr("Save CSV file"));
			dialog.setFileMode(QFileDialog::AnyFile);
			dialog.setAcceptMode(QFileDialog::AcceptSave);
			dialog.setNameFilter(QString("%1 (*.csv)").arg(tr("CSV File")));
			dialog.setDirectory(m_settings->mostRecentInputPath());
			if(dialog.exec())
			{
				selectedCsvFile = dialog.selectedFiles().first();
			}
		}

		if(!selectedCsvFile.isEmpty())
		{
			m_settings->mostRecentInputPath(QFileInfo(selectedCsvFile).canonicalPath());
			switch(m_fileListModel->exportToCsv(selectedCsvFile))
			{
			case FileListModel::CsvError_NoTags:
				QMessageBox::critical(this, tr("CSV Export"), NOBR(tr("Sorry, there are no meta tags that can be exported!")));
				break;
			case FileListModel::CsvError_FileOpen:
				QMessageBox::critical(this, tr("CSV Export"), NOBR(tr("Sorry, failed to open CSV file for writing!")));
				break;
			case FileListModel::CsvError_FileWrite:
				QMessageBox::critical(this, tr("CSV Export"), NOBR(tr("Sorry, failed to write to the CSV file!")));
				break;
			case FileListModel::CsvError_OK:
				QMessageBox::information(this, tr("CSV Export"), NOBR(tr("The CSV files was created successfully!")));
				break;
			default:
				qWarning("exportToCsv: Unknown return code!");
			}
		}
	)
}


/*
 * Import Meta tags from CSV file
 */
void MainWindow::importCsvContextActionTriggered(void)
{
	TEMP_HIDE_DROPBOX
	(
		QString selectedCsvFile;
	
		if(USE_NATIVE_FILE_DIALOG)
		{
			selectedCsvFile = QFileDialog::getOpenFileName(this, tr("Open CSV file"), m_settings->mostRecentInputPath(), QString("%1 (*.csv)").arg(tr("CSV File")));
		}
		else
		{
			QFileDialog dialog(this, tr("Open CSV file"));
			dialog.setFileMode(QFileDialog::ExistingFile);
			dialog.setNameFilter(QString("%1 (*.csv)").arg(tr("CSV File")));
			dialog.setDirectory(m_settings->mostRecentInputPath());
			if(dialog.exec())
			{
				selectedCsvFile = dialog.selectedFiles().first();
			}
		}

		if(!selectedCsvFile.isEmpty())
		{
			m_settings->mostRecentInputPath(QFileInfo(selectedCsvFile).canonicalPath());
			switch(m_fileListModel->importFromCsv(this, selectedCsvFile))
			{
			case FileListModel::CsvError_FileOpen:
				QMessageBox::critical(this, tr("CSV Import"), NOBR(tr("Sorry, failed to open CSV file for reading!")));
				break;
			case FileListModel::CsvError_FileRead:
				QMessageBox::critical(this, tr("CSV Import"), NOBR(tr("Sorry, failed to read from the CSV file!")));
				break;
			case FileListModel::CsvError_NoTags:
				QMessageBox::critical(this, tr("CSV Import"), NOBR(tr("Sorry, the CSV file does not contain any known fields!")));
				break;
			case FileListModel::CsvError_Incomplete:
				QMessageBox::warning(this, tr("CSV Import"), NOBR(tr("CSV file is incomplete. Not all files were updated!")));
				break;
			case FileListModel::CsvError_OK:
				QMessageBox::information(this, tr("CSV Import"), NOBR(tr("The CSV files was imported successfully!")));
				break;
			case FileListModel::CsvError_Aborted:
				/* User aborted, ignore! */
				break;
			default:
				qWarning("exportToCsv: Unknown return code!");
			}
		}
	)
}

/*
 * Show or hide Drag'n'Drop notice after model reset
 */
void MainWindow::sourceModelChanged(void)
{
	m_dropNoteLabel->setVisible(m_fileListModel->rowCount() <= 0);
}

// =========================================================
// Output folder slots
// =========================================================

/*
 * Output folder changed (mouse clicked)
 */
void MainWindow::outputFolderViewClicked(const QModelIndex &index)
{
	if(outputFolderView->currentIndex() != index)
	{
		outputFolderView->setCurrentIndex(index);
	}
	QString selectedDir = m_fileSystemModel->filePath(index);
	if(selectedDir.length() < 3) selectedDir.append(QDir::separator());
	outputFolderLabel->setText(QDir::toNativeSeparators(selectedDir));
	m_settings->outputDir(selectedDir);
}

/*
 * Output folder changed (mouse moved)
 */
void MainWindow::outputFolderViewMoved(const QModelIndex &index)
{
	if(QApplication::mouseButtons() & Qt::LeftButton)
	{
		outputFolderViewClicked(index);
	}
}

/*
 * Goto desktop button
 */
void MainWindow::gotoDesktopButtonClicked(void)
{
	QString desktopPath = QDesktopServices::storageLocation(QDesktopServices::DesktopLocation);
	
	if(!desktopPath.isEmpty() && QDir(desktopPath).exists())
	{
		outputFolderView->setCurrentIndex(m_fileSystemModel->index(desktopPath));
		outputFolderViewClicked(outputFolderView->currentIndex());
		outputFolderView->setFocus();
	}
	else
	{
		buttonGotoDesktop->setEnabled(false);
	}
}

/*
 * Goto home folder button
 */
void MainWindow::gotoHomeFolderButtonClicked(void)
{
	QString homePath = QDesktopServices::storageLocation(QDesktopServices::HomeLocation);
	
	if(!homePath.isEmpty() && QDir(homePath).exists())
	{
		outputFolderView->setCurrentIndex(m_fileSystemModel->index(homePath));
		outputFolderViewClicked(outputFolderView->currentIndex());
		outputFolderView->setFocus();
	}
	else
	{
		buttonGotoHome->setEnabled(false);
	}
}

/*
 * Goto music folder button
 */
void MainWindow::gotoMusicFolderButtonClicked(void)
{
	QString musicPath = QDesktopServices::storageLocation(QDesktopServices::MusicLocation);
	
	if(!musicPath.isEmpty() && QDir(musicPath).exists())
	{
		outputFolderView->setCurrentIndex(m_fileSystemModel->index(musicPath));
		outputFolderViewClicked(outputFolderView->currentIndex());
		outputFolderView->setFocus();
	}
	else
	{
		buttonGotoMusic->setEnabled(false);
	}
}

/*
 * Goto music favorite output folder
 */
void MainWindow::gotoFavoriteFolder(void)
{
	QAction *item = dynamic_cast<QAction*>(QObject::sender());
	
	if(item)
	{
		QDir path(item->data().toString());
		if(path.exists())
		{
			outputFolderView->setCurrentIndex(m_fileSystemModel->index(path.canonicalPath()));
			outputFolderViewClicked(outputFolderView->currentIndex());
			outputFolderView->setFocus();
		}
		else
		{
			MessageBeep(MB_ICONERROR);
			m_outputFolderFavoritesMenu->removeAction(item);
			item->deleteLater();
		}
	}
}

/*
 * Make folder button
 */
void MainWindow::makeFolderButtonClicked(void)
{
	ABORT_IF_BUSY;

	QDir basePath(m_fileSystemModel->fileInfo(outputFolderView->currentIndex()).absoluteFilePath());
	QString suggestedName = tr("New Folder");

	if(!m_metaData->fileArtist().isEmpty() && !m_metaData->fileAlbum().isEmpty())
	{
		suggestedName = QString("%1 - %2").arg(m_metaData->fileArtist(), m_metaData->fileAlbum());
	}
	else if(!m_metaData->fileArtist().isEmpty())
	{
		suggestedName = m_metaData->fileArtist();
	}
	else if(!m_metaData->fileAlbum().isEmpty())
	{
		suggestedName = m_metaData->fileAlbum();
	}
	else
	{
		for(int i = 0; i < m_fileListModel->rowCount(); i++)
		{
			AudioFileModel audioFile = m_fileListModel->getFile(m_fileListModel->index(i, 0));
			if(!audioFile.fileAlbum().isEmpty() || !audioFile.fileArtist().isEmpty())
			{
				if(!audioFile.fileArtist().isEmpty() && !audioFile.fileAlbum().isEmpty())
				{
					suggestedName = QString("%1 - %2").arg(audioFile.fileArtist(), audioFile.fileAlbum());
				}
				else if(!audioFile.fileArtist().isEmpty())
				{
					suggestedName = audioFile.fileArtist();
				}
				else if(!audioFile.fileAlbum().isEmpty())
				{
					suggestedName = audioFile.fileAlbum();
				}
				break;
			}
		}
	}
	
	suggestedName = lamexp_clean_filename(suggestedName);

	while(true)
	{
		bool bApplied = false;
		QString folderName = QInputDialog::getText(this, tr("New Folder"), tr("Enter the name of the new folder:").leftJustified(96, ' '), QLineEdit::Normal, suggestedName, &bApplied, Qt::WindowStaysOnTopHint).simplified();

		if(bApplied)
		{
			folderName = lamexp_clean_filepath(folderName.simplified());

			if(folderName.isEmpty())
			{
				MessageBeep(MB_ICONERROR);
				continue;
			}

			int i = 1;
			QString newFolder = folderName;

			while(basePath.exists(newFolder))
			{
				newFolder = QString(folderName).append(QString().sprintf(" (%d)", ++i));
			}
			
			if(basePath.mkpath(newFolder))
			{
				QDir createdDir = basePath;
				if(createdDir.cd(newFolder))
				{
					outputFolderView->setCurrentIndex(m_fileSystemModel->index(createdDir.canonicalPath()));
					outputFolderViewClicked(outputFolderView->currentIndex());
					outputFolderView->setFocus();
				}
			}
			else
			{
				QMessageBox::warning(this, tr("Failed to create folder"), QString("%1<br><nobr>%2</nobr><br><br>%3").arg(tr("The new folder could not be created:"), basePath.absoluteFilePath(newFolder), tr("Drive is read-only or insufficient access rights!")));
			}
		}
		break;
	}
}

/*
 * Output to source dir changed
 */
void MainWindow::saveToSourceFolderChanged(void)
{
	m_settings->outputToSourceDir(saveToSourceFolderCheckBox->isChecked());
}

/*
 * Prepend relative source file path to output file name changed
 */
void MainWindow::prependRelativePathChanged(void)
{
	m_settings->prependRelativeSourcePath(prependRelativePathCheckBox->isChecked());
}

/*
 * Show context menu for output folder
 */
void MainWindow::outputFolderContextMenu(const QPoint &pos)
{
	QAbstractScrollArea *scrollArea = dynamic_cast<QAbstractScrollArea*>(QObject::sender());
	QWidget *sender = scrollArea ? scrollArea->viewport() : dynamic_cast<QWidget*>(QObject::sender());	

	if(pos.x() <= sender->width() && pos.y() <= sender->height() && pos.x() >= 0 && pos.y() >= 0)
	{
		m_outputFolderContextMenu->popup(sender->mapToGlobal(pos));
	}
}

/*
 * Show selected folder in explorer
 */
void MainWindow::showFolderContextActionTriggered(void)
{
	QString path = QDir::toNativeSeparators(m_fileSystemModel->filePath(outputFolderView->currentIndex()));
	if(!path.endsWith(QDir::separator())) path.append(QDir::separator());
	ShellExecuteW(this->winId(), L"explore", QWCHAR(path), NULL, NULL, SW_SHOW);
}

/*
 * Add current folder to favorites
 */
void MainWindow::addFavoriteFolderActionTriggered(void)
{
	QString path = m_fileSystemModel->filePath(outputFolderView->currentIndex());
	QStringList favorites = m_settings->favoriteOutputFolders().split("|", QString::SkipEmptyParts);

	if(!favorites.contains(path, Qt::CaseInsensitive))
	{
		favorites.append(path);
		while(favorites.count() > 6) favorites.removeFirst();
	}
	else
	{
		MessageBeep(MB_ICONWARNING);
	}

	m_settings->favoriteOutputFolders(favorites.join("|"));
	refreshFavorites();
}

/*
 * Initialize file system model
 */
void MainWindow::initOutputFolderModel(void)
{
	QModelIndex previousIndex = outputFolderView->currentIndex();
	m_fileSystemModel->setRootPath(m_fileSystemModel->rootPath());
	QApplication::processEvents();
	outputFolderView->reset();
	outputFolderView->setCurrentIndex(previousIndex);
	m_OutputFolderViewInitialized = true;
}

// =========================================================
// Metadata tab slots
// =========================================================

/*
 * Edit meta button clicked
 */
void MainWindow::editMetaButtonClicked(void)
{
	ABORT_IF_BUSY;

	const QModelIndex index = metaDataView->currentIndex();

	if(index.isValid())
	{
		m_metaInfoModel->editItem(index, this);
	
		if(index.row() == 4)
		{
			m_settings->metaInfoPosition(m_metaData->filePosition());
		}
	}
}

/*
 * Reset meta button clicked
 */
void MainWindow::clearMetaButtonClicked(void)
{
	ABORT_IF_BUSY;
	m_metaInfoModel->clearData();
}

/*
 * Meta tags enabled changed
 */
void MainWindow::metaTagsEnabledChanged(void)
{
	m_settings->writeMetaTags(writeMetaDataCheckBox->isChecked());
}

/*
 * Playlist enabled changed
 */
void MainWindow::playlistEnabledChanged(void)
{
	m_settings->createPlaylist(generatePlaylistCheckBox->isChecked());
}

// =========================================================
// Compression tab slots
// =========================================================

/*
 * Update encoder
 */
void MainWindow::updateEncoder(int id)
{
	m_settings->compressionEncoder(id);

	switch(m_settings->compressionEncoder())
	{
	case SettingsModel::VorbisEncoder:
		radioButtonModeQuality->setEnabled(true);
		radioButtonModeAverageBitrate->setEnabled(true);
		radioButtonConstBitrate->setEnabled(false);
		if(radioButtonConstBitrate->isChecked()) radioButtonModeQuality->setChecked(true);
		sliderBitrate->setEnabled(true);
		break;
	case SettingsModel::AC3Encoder:
		radioButtonModeQuality->setEnabled(true);
		radioButtonModeQuality->setChecked(true);
		radioButtonModeAverageBitrate->setEnabled(false);
		radioButtonConstBitrate->setEnabled(true);
		sliderBitrate->setEnabled(true);
		break;
	case SettingsModel::FLACEncoder:
		radioButtonModeQuality->setEnabled(false);
		radioButtonModeQuality->setChecked(true);
		radioButtonModeAverageBitrate->setEnabled(false);
		radioButtonConstBitrate->setEnabled(false);
		sliderBitrate->setEnabled(true);
		break;
	case SettingsModel::PCMEncoder:
		radioButtonModeQuality->setEnabled(false);
		radioButtonModeQuality->setChecked(true);
		radioButtonModeAverageBitrate->setEnabled(false);
		radioButtonConstBitrate->setEnabled(false);
		sliderBitrate->setEnabled(false);
		break;
	case SettingsModel::AACEncoder:
		radioButtonModeQuality->setEnabled(true);
		radioButtonModeAverageBitrate->setEnabled(!m_fhgEncoderAvailable);
		if(m_fhgEncoderAvailable && radioButtonModeAverageBitrate->isChecked()) radioButtonConstBitrate->setChecked(true);
		radioButtonConstBitrate->setEnabled(true);
		sliderBitrate->setEnabled(true);
		break;
	case SettingsModel::DCAEncoder:
		radioButtonModeQuality->setEnabled(false);
		radioButtonModeAverageBitrate->setEnabled(false);
		radioButtonConstBitrate->setEnabled(true);
		radioButtonConstBitrate->setChecked(true);
		sliderBitrate->setEnabled(true);
		break;
	default:
		radioButtonModeQuality->setEnabled(true);
		radioButtonModeAverageBitrate->setEnabled(true);
		radioButtonConstBitrate->setEnabled(true);
		sliderBitrate->setEnabled(true);
		break;
	}

	if(m_settings->compressionEncoder() == SettingsModel::AACEncoder)
	{
		const QString encoderName = m_qaacEncoderAvailable ? tr("QAAC (Apple)") : (m_fhgEncoderAvailable ? tr("FHG AAC (Winamp)") : (m_neroEncoderAvailable ? tr("Nero AAC") : tr("Not available!")));
		labelEncoderInfo->setVisible(true);
		labelEncoderInfo->setText(tr("Current AAC Encoder: %1").arg(encoderName));
	}
	else
	{
		labelEncoderInfo->setVisible(false);
	}

	updateRCMode(m_modeButtonGroup->checkedId());
}

/*
 * Update rate-control mode
 */
void MainWindow::updateRCMode(int id)
{
	m_settings->compressionRCMode(id);

	switch(m_settings->compressionEncoder())
	{
	case SettingsModel::MP3Encoder:
		switch(m_settings->compressionRCMode())
		{
		case SettingsModel::VBRMode:
			sliderBitrate->setMinimum(0);
			sliderBitrate->setMaximum(9);
			break;
		default:
			sliderBitrate->setMinimum(0);
			sliderBitrate->setMaximum(13);
			break;
		}
		break;
	case SettingsModel::VorbisEncoder:
		switch(m_settings->compressionRCMode())
		{
		case SettingsModel::VBRMode:
			sliderBitrate->setMinimum(-2);
			sliderBitrate->setMaximum(10);
			break;
		default:
			sliderBitrate->setMinimum(4);
			sliderBitrate->setMaximum(63);
			break;
		}
		break;
	case SettingsModel::AC3Encoder:
		switch(m_settings->compressionRCMode())
		{
		case SettingsModel::VBRMode:
			sliderBitrate->setMinimum(0);
			sliderBitrate->setMaximum(16);
			break;
		default:
			sliderBitrate->setMinimum(0);
			sliderBitrate->setMaximum(18);
			break;
		}
		break;
	case SettingsModel::AACEncoder:
		switch(m_settings->compressionRCMode())
		{
		case SettingsModel::VBRMode:
			sliderBitrate->setMinimum(0);
			sliderBitrate->setMaximum(20);
			break;
		default:
			sliderBitrate->setMinimum(4);
			sliderBitrate->setMaximum(63);
			break;
		}
		break;
	case SettingsModel::FLACEncoder:
		sliderBitrate->setMinimum(0);
		sliderBitrate->setMaximum(8);
		break;
	case SettingsModel::DCAEncoder:
		sliderBitrate->setMinimum(1);
		sliderBitrate->setMaximum(128);
		break;
	case SettingsModel::PCMEncoder:
		sliderBitrate->setMinimum(0);
		sliderBitrate->setMaximum(2);
		sliderBitrate->setValue(1);
		break;
	default:
		sliderBitrate->setMinimum(0);
		sliderBitrate->setMaximum(0);
		break;
	}

	updateBitrate(sliderBitrate->value());
}

/*
 * Update bitrate
 */
void MainWindow::updateBitrate(int value)
{
	m_settings->compressionBitrate(value);
	
	switch(m_settings->compressionRCMode())
	{
	case SettingsModel::VBRMode:
		switch(m_settings->compressionEncoder())
		{
		case SettingsModel::MP3Encoder:
			labelBitrate->setText(tr("Quality Level %1").arg(9 - value));
			break;
		case SettingsModel::VorbisEncoder:
			labelBitrate->setText(tr("Quality Level %1").arg(value));
			break;
		case SettingsModel::AACEncoder:
			labelBitrate->setText(tr("Quality Level %1").arg(QString().sprintf("%.2f", static_cast<double>(value * 5) / 100.0)));
			break;
		case SettingsModel::FLACEncoder:
			labelBitrate->setText(tr("Compression %1").arg(value));
			break;
		case SettingsModel::AC3Encoder:
			labelBitrate->setText(tr("Quality Level %1").arg(qMin(1024, qMax(0, value * 64))));
			break;
		case SettingsModel::PCMEncoder:
			labelBitrate->setText(tr("Uncompressed"));
			break;
		default:
			labelBitrate->setText(QString::number(value));
			break;
		}
		break;
	case SettingsModel::ABRMode:
		switch(m_settings->compressionEncoder())
		{
		case SettingsModel::MP3Encoder:
			labelBitrate->setText(QString("&asymp; %1 kbps").arg(SettingsModel::mp3Bitrates[value]));
			break;
		case SettingsModel::FLACEncoder:
			labelBitrate->setText(tr("Compression %1").arg(value));
			break;
		case SettingsModel::AC3Encoder:
			labelBitrate->setText(QString("&asymp; %1 kbps").arg(SettingsModel::ac3Bitrates[value]));
			break;
		case SettingsModel::PCMEncoder:
			labelBitrate->setText(tr("Uncompressed"));
			break;
		default:
			labelBitrate->setText(QString("&asymp; %1 kbps").arg(qMin(500, value * 8)));
			break;
		}
		break;
	default:
		switch(m_settings->compressionEncoder())
		{
		case SettingsModel::MP3Encoder:
			labelBitrate->setText(QString("%1 kbps").arg(SettingsModel::mp3Bitrates[value]));
			break;
		case SettingsModel::FLACEncoder:
			labelBitrate->setText(tr("Compression %1").arg(value));
			break;
		case SettingsModel::AC3Encoder:
			labelBitrate->setText(QString("%1 kbps").arg(SettingsModel::ac3Bitrates[value]));
			break;
		case SettingsModel::DCAEncoder:
			labelBitrate->setText(QString("%1 kbps").arg(value * 32));
			break;
		case SettingsModel::PCMEncoder:
			labelBitrate->setText(tr("Uncompressed"));
			break;
		default:
			labelBitrate->setText(QString("%1 kbps").arg(qMin(500, value * 8)));
			break;
		}
		break;
	}
}

// =========================================================
// Advanced option slots
// =========================================================

/*
 * Lame algorithm quality changed
 */
void MainWindow::updateLameAlgoQuality(int value)
{
	QString text;

	switch(value)
	{
	case 4:
		text = tr("Best Quality (Very Slow)");
		break;
	case 3:
		text = tr("High Quality (Recommended)");
		break;
	case 2:
		text = tr("Average Quality (Default)");
		break;
	case 1:
		text = tr("Low Quality (Fast)");
		break;
	case 0:
		text = tr("Poor Quality (Very Fast)");
		break;
	}

	if(!text.isEmpty())
	{
		m_settings->lameAlgoQuality(value);
		labelLameAlgoQuality->setText(text);
	}

	bool warning = (value == 0), notice = (value == 4);
	labelLameAlgoQualityWarning->setVisible(warning);
	labelLameAlgoQualityWarningIcon->setVisible(warning);
	labelLameAlgoQualityNotice->setVisible(notice);
	labelLameAlgoQualityNoticeIcon->setVisible(notice);
	labelLameAlgoQualitySpacer->setVisible(warning || notice);
}

/*
 * Bitrate management endabled/disabled
 */
void MainWindow::bitrateManagementEnabledChanged(bool checked)
{
	m_settings->bitrateManagementEnabled(checked);
}

/*
 * Minimum bitrate has changed
 */
void MainWindow::bitrateManagementMinChanged(int value)
{
	if(value > spinBoxBitrateManagementMax->value())
	{
		spinBoxBitrateManagementMin->setValue(spinBoxBitrateManagementMax->value());
		m_settings->bitrateManagementMinRate(spinBoxBitrateManagementMax->value());
	}
	else
	{
		m_settings->bitrateManagementMinRate(value);
	}
}

/*
 * Maximum bitrate has changed
 */
void MainWindow::bitrateManagementMaxChanged(int value)
{
	if(value < spinBoxBitrateManagementMin->value())
	{
		spinBoxBitrateManagementMax->setValue(spinBoxBitrateManagementMin->value());
		m_settings->bitrateManagementMaxRate(spinBoxBitrateManagementMin->value());
	}
	else
	{
		m_settings->bitrateManagementMaxRate(value);
	}
}

/*
 * Channel mode has changed
 */
void MainWindow::channelModeChanged(int value)
{
	if(value >= 0) m_settings->lameChannelMode(value);
}

/*
 * Sampling rate has changed
 */
void MainWindow::samplingRateChanged(int value)
{
	if(value >= 0) m_settings->samplingRate(value);
}

/*
 * Nero AAC 2-Pass mode changed
 */
void MainWindow::neroAAC2PassChanged(bool checked)
{
	m_settings->neroAACEnable2Pass(checked);
}

/*
 * Nero AAC profile mode changed
 */
void MainWindow::neroAACProfileChanged(int value)
{
	if(value >= 0) m_settings->aacEncProfile(value);
}

/*
 * Aften audio coding mode changed
 */
void MainWindow::aftenCodingModeChanged(int value)
{
	if(value >= 0) m_settings->aftenAudioCodingMode(value);
}

/*
 * Aften DRC mode changed
 */
void MainWindow::aftenDRCModeChanged(int value)
{
	if(value >= 0) m_settings->aftenDynamicRangeCompression(value);
}

/*
 * Aften exponent search size changed
 */
void MainWindow::aftenSearchSizeChanged(int value)
{
	if(value >= 0) m_settings->aftenExponentSearchSize(value);
}

/*
 * Aften fast bit allocation changed
 */
void MainWindow::aftenFastAllocationChanged(bool checked)
{
	m_settings->aftenFastBitAllocation(checked);
}

/*
 * Normalization filter enabled changed
 */
void MainWindow::normalizationEnabledChanged(bool checked)
{
	m_settings->normalizationFilterEnabled(checked);
}

/*
 * Normalization max. volume changed
 */
void MainWindow::normalizationMaxVolumeChanged(double value)
{
	m_settings->normalizationFilterMaxVolume(static_cast<int>(value * 100.0));
}

/*
 * Normalization equalization mode changed
 */
void MainWindow::normalizationModeChanged(int mode)
{
	m_settings->normalizationFilterEqualizationMode(mode);
}

/*
 * Tone adjustment has changed (Bass)
 */
void MainWindow::toneAdjustBassChanged(double value)
{
	m_settings->toneAdjustBass(static_cast<int>(value * 100.0));
	spinBoxToneAdjustBass->setPrefix((value > 0) ? "+" : QString());
}

/*
 * Tone adjustment has changed (Treble)
 */
void MainWindow::toneAdjustTrebleChanged(double value)
{
	m_settings->toneAdjustTreble(static_cast<int>(value * 100.0));
	spinBoxToneAdjustTreble->setPrefix((value > 0) ? "+" : QString());
}

/*
 * Tone adjustment has been reset
 */
void MainWindow::toneAdjustTrebleReset(void)
{
	spinBoxToneAdjustBass->setValue(m_settings->toneAdjustBassDefault());
	spinBoxToneAdjustTreble->setValue(m_settings->toneAdjustTrebleDefault());
	toneAdjustBassChanged(spinBoxToneAdjustBass->value());
	toneAdjustTrebleChanged(spinBoxToneAdjustTreble->value());
}

/*
 * Custom encoder parameters changed
 */
void MainWindow::customParamsChanged(void)
{
	lineEditCustomParamLAME->setText(lineEditCustomParamLAME->text().simplified());
	lineEditCustomParamOggEnc->setText(lineEditCustomParamOggEnc->text().simplified());
	lineEditCustomParamNeroAAC->setText(lineEditCustomParamNeroAAC->text().simplified());
	lineEditCustomParamFLAC->setText(lineEditCustomParamFLAC->text().simplified());
	lineEditCustomParamAften->setText(lineEditCustomParamAften->text().simplified());

	bool customParamsUsed = false;
	if(!lineEditCustomParamLAME->text().isEmpty()) customParamsUsed = true;
	if(!lineEditCustomParamOggEnc->text().isEmpty()) customParamsUsed = true;
	if(!lineEditCustomParamNeroAAC->text().isEmpty()) customParamsUsed = true;
	if(!lineEditCustomParamFLAC->text().isEmpty()) customParamsUsed = true;
	if(!lineEditCustomParamAften->text().isEmpty()) customParamsUsed = true;

	labelCustomParamsIcon->setVisible(customParamsUsed);
	labelCustomParamsText->setVisible(customParamsUsed);
	labelCustomParamsSpacer->setVisible(customParamsUsed);

	m_settings->customParametersLAME(lineEditCustomParamLAME->text());
	m_settings->customParametersOggEnc(lineEditCustomParamOggEnc->text());
	m_settings->customParametersAacEnc(lineEditCustomParamNeroAAC->text());
	m_settings->customParametersFLAC(lineEditCustomParamFLAC->text());
	m_settings->customParametersAften(lineEditCustomParamAften->text());
}


/*
 * Rename output files enabled changed
 */
void MainWindow::renameOutputEnabledChanged(bool checked)
{
	m_settings->renameOutputFilesEnabled(checked);
}

/*
 * Rename output files patterm changed
 */
void MainWindow::renameOutputPatternChanged(void)
{
	QString temp = lineEditRenamePattern->text().simplified();
	lineEditRenamePattern->setText(temp.isEmpty() ? m_settings->renameOutputFilesPatternDefault() : temp);
	m_settings->renameOutputFilesPattern(lineEditRenamePattern->text());
}

/*
 * Rename output files patterm changed
 */
void MainWindow::renameOutputPatternChanged(const QString &text)
{
	QString pattern(text.simplified());
	
	pattern.replace("<BaseName>", "The_White_Stripes_-_Fell_In_Love_With_A_Girl", Qt::CaseInsensitive);
	pattern.replace("<TrackNo>", "04", Qt::CaseInsensitive);
	pattern.replace("<Title>", "Fell In Love With A Girl", Qt::CaseInsensitive);
	pattern.replace("<Artist>", "The White Stripes", Qt::CaseInsensitive);
	pattern.replace("<Album>", "White Blood Cells", Qt::CaseInsensitive);
	pattern.replace("<Year>", "2001", Qt::CaseInsensitive);
	pattern.replace("<Comment>", "Encoded by LameXP", Qt::CaseInsensitive);

	if(pattern.compare(lamexp_clean_filename(pattern)))
	{
		if(lineEditRenamePattern->palette().color(QPalette::Text) != Qt::red)
		{
			MessageBeep(MB_ICONERROR);
			SET_TEXT_COLOR(lineEditRenamePattern, Qt::red);
		}
	}
	else
	{
		if(lineEditRenamePattern->palette().color(QPalette::Text) != Qt::black)
		{
			MessageBeep(MB_ICONINFORMATION);
			SET_TEXT_COLOR(lineEditRenamePattern, Qt::black);
		}
	}

	labelRanameExample->setText(lamexp_clean_filename(pattern));
}

/*
 * Show list of rename macros
 */
void MainWindow::showRenameMacros(const QString &text)
{
	if(text.compare("reset", Qt::CaseInsensitive) == 0)
	{
		lineEditRenamePattern->setText(m_settings->renameOutputFilesPatternDefault());
		return;
	}

	const QString format = QString("<tr><td><tt>&lt;%1&gt;</tt></td><td>&nbsp;&nbsp;</td><td>%2</td></tr>");

	QString message = QString("<table>");
	message += QString(format).arg("BaseName", tr("File name without extension"));
	message += QString(format).arg("TrackNo", tr("Track number with leading zero"));
	message += QString(format).arg("Title", tr("Track title"));
	message += QString(format).arg("Artist", tr("Artist name"));
	message += QString(format).arg("Album", tr("Album name"));
	message += QString(format).arg("Year", tr("Year with (at least) four digits"));
	message += QString(format).arg("Comment", tr("Comment"));
	message += "</table><br><br>";
	message += QString("%1<br>").arg(tr("Characters forbidden in file names:"));
	message += "<b><tt>\\ / : * ? &lt; &gt; |<br>";
	
	QMessageBox::information(this, tr("Rename Macros"), message, tr("Discard"));
}

void MainWindow::forceStereoDownmixEnabledChanged(bool checked)
{
	m_settings->forceStereoDownmix(checked);
}

/*
 * Maximum number of instances changed
 */
void MainWindow::updateMaximumInstances(int value)
{
	labelMaxInstances->setText(tr("%1 Instance(s)").arg(QString::number(value)));
	m_settings->maximumInstances(checkBoxAutoDetectInstances->isChecked() ? NULL : value);
}

/*
 * Auto-detect number of instances
 */
void MainWindow::autoDetectInstancesChanged(bool checked)
{
	m_settings->maximumInstances(checked ? NULL : sliderMaxInstances->value());
}

/*
 * Browse for custom TEMP folder button clicked
 */
void MainWindow::browseCustomTempFolderButtonClicked(void)
{
	QString newTempFolder;

	if(USE_NATIVE_FILE_DIALOG)
	{
		newTempFolder = QFileDialog::getExistingDirectory(this, QString(), m_settings->customTempPath());
	}
	else
	{
		QFileDialog dialog(this);
		dialog.setFileMode(QFileDialog::DirectoryOnly);
		dialog.setDirectory(m_settings->customTempPath());
		if(dialog.exec())
		{
			newTempFolder = dialog.selectedFiles().first();
		}
	}

	if(!newTempFolder.isEmpty())
	{
		QFile writeTest(QString("%1/~%2.tmp").arg(newTempFolder, lamexp_rand_str()));
		if(writeTest.open(QIODevice::ReadWrite))
		{
			writeTest.remove();
			lineEditCustomTempFolder->setText(QDir::toNativeSeparators(newTempFolder));
		}
		else
		{
			QMessageBox::warning(this, tr("Access Denied"), tr("Cannot write to the selected directory. Please choose another directory!"));
		}
	}
}

/*
 * Custom TEMP folder changed
 */
void MainWindow::customTempFolderChanged(const QString &text)
{
	m_settings->customTempPath(QDir::fromNativeSeparators(text));
}

/*
 * Use custom TEMP folder option changed
 */
void MainWindow::useCustomTempFolderChanged(bool checked)
{
	m_settings->customTempPathEnabled(!checked);
}

/*
 * Reset all advanced options to their defaults
 */
void MainWindow::resetAdvancedOptionsButtonClicked(void)
{
	sliderLameAlgoQuality->setValue(m_settings->lameAlgoQualityDefault());
	spinBoxBitrateManagementMin->setValue(m_settings->bitrateManagementMinRateDefault());
	spinBoxBitrateManagementMax->setValue(m_settings->bitrateManagementMaxRateDefault());
	spinBoxNormalizationFilter->setValue(static_cast<double>(m_settings->normalizationFilterMaxVolumeDefault()) / 100.0);
	spinBoxToneAdjustBass->setValue(static_cast<double>(m_settings->toneAdjustBassDefault()) / 100.0);
	spinBoxToneAdjustTreble->setValue(static_cast<double>(m_settings->toneAdjustTrebleDefault()) / 100.0);
	spinBoxAftenSearchSize->setValue(m_settings->aftenExponentSearchSizeDefault());
	comboBoxMP3ChannelMode->setCurrentIndex(m_settings->lameChannelModeDefault());
	comboBoxSamplingRate->setCurrentIndex(m_settings->samplingRateDefault());
	comboBoxAACProfile->setCurrentIndex(m_settings->aacEncProfileDefault());
	comboBoxAftenCodingMode->setCurrentIndex(m_settings->aftenAudioCodingModeDefault());
	comboBoxAftenDRCMode->setCurrentIndex(m_settings->aftenDynamicRangeCompressionDefault());
	comboBoxNormalizationMode->setCurrentIndex(m_settings->normalizationFilterEqualizationModeDefault());
	while(checkBoxBitrateManagement->isChecked() != m_settings->bitrateManagementEnabledDefault()) checkBoxBitrateManagement->click();
	while(checkBoxNeroAAC2PassMode->isChecked() != m_settings->neroAACEnable2PassDefault()) checkBoxNeroAAC2PassMode->click();
	while(checkBoxNormalizationFilter->isChecked() != m_settings->normalizationFilterEnabledDefault()) checkBoxNormalizationFilter->click();
	while(checkBoxAutoDetectInstances->isChecked() != (m_settings->maximumInstancesDefault() < 1)) checkBoxAutoDetectInstances->click();
	while(checkBoxUseSystemTempFolder->isChecked() == m_settings->customTempPathEnabledDefault()) checkBoxUseSystemTempFolder->click();
	while(checkBoxAftenFastAllocation->isChecked() != m_settings->aftenFastBitAllocationDefault()) checkBoxAftenFastAllocation->click();
	while(checkBoxRenameOutput->isChecked() != m_settings->renameOutputFilesEnabledDefault()) checkBoxRenameOutput->click();
	while(checkBoxForceStereoDownmix->isChecked() != m_settings->forceStereoDownmixDefault()) checkBoxForceStereoDownmix->click();
	lineEditCustomParamLAME->setText(m_settings->customParametersLAMEDefault());
	lineEditCustomParamOggEnc->setText(m_settings->customParametersOggEncDefault());
	lineEditCustomParamNeroAAC->setText(m_settings->customParametersAacEncDefault());
	lineEditCustomParamFLAC->setText(m_settings->customParametersFLACDefault());
	lineEditCustomTempFolder->setText(QDir::toNativeSeparators(m_settings->customTempPathDefault()));
	lineEditRenamePattern->setText(m_settings->renameOutputFilesPatternDefault());
	customParamsChanged();
	scrollArea->verticalScrollBar()->setValue(0);
}

// =========================================================
// Multi-instance handling slots
// =========================================================

/*
 * Other instance detected
 */
void MainWindow::notifyOtherInstance(void)
{
	if(!m_banner->isVisible())
	{
		QMessageBox msgBox(QMessageBox::Warning, tr("Already Running"), tr("LameXP is already running, please use the running instance!"), QMessageBox::NoButton, this, Qt::Dialog | Qt::MSWindowsFixedSizeDialogHint | Qt::WindowStaysOnTopHint);
		msgBox.exec();
	}
}

/*
 * Add file from another instance
 */
void MainWindow::addFileDelayed(const QString &filePath, bool tryASAP)
{
	if(tryASAP && !m_delayedFileTimer->isActive())
	{
		qDebug("Received file: %s", filePath.toUtf8().constData());
		m_delayedFileList->append(filePath);
		QTimer::singleShot(0, this, SLOT(handleDelayedFiles()));
	}
	
	m_delayedFileTimer->stop();
	qDebug("Received file: %s", filePath.toUtf8().constData());
	m_delayedFileList->append(filePath);
	m_delayedFileTimer->start(5000);
}

/*
 * Add files from another instance
 */
void MainWindow::addFilesDelayed(const QStringList &filePaths, bool tryASAP)
{
	if(tryASAP && !m_delayedFileTimer->isActive())
	{
		qDebug("Received %d file(s).", filePaths.count());
		m_delayedFileList->append(filePaths);
		QTimer::singleShot(0, this, SLOT(handleDelayedFiles()));
	}
	else
	{
		m_delayedFileTimer->stop();
		qDebug("Received %d file(s).", filePaths.count());
		m_delayedFileList->append(filePaths);
		m_delayedFileTimer->start(5000);
	}
}

/*
 * Add folder from another instance
 */
void MainWindow::addFolderDelayed(const QString &folderPath, bool recursive)
{
	if(!m_banner->isVisible())
	{
		addFolder(folderPath, recursive, true);
	}
}

// =========================================================
// Misc slots
// =========================================================

/*
 * Restore the override cursor
 */
void MainWindow::restoreCursor(void)
{
	QApplication::restoreOverrideCursor();
}
