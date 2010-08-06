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
#include "config.h"
#undef QT_TR_NOOP

#include <QtCore/QUrl>
#include <QtCore/QDir>
#include <QtGui/QKeyEvent>
#include <QtGui/QGraphicsView>

#include "ADM_default.h"
#include "Q_gui2.h"
#include "ADM_toolkitQt.h"
#include "ADM_qslider.h"
#include "ADM_codecs/ADM_codec.h"
#include "gui_action.hxx"
#include "ADM_editor/ADM_outputfmt.h"
#include "DIA_fileSel.h"
#include "ADM_video/ADM_vidMisc.h"
#include "prefs.h"
#include "avi_vars.h"
#include "gtkgui.h"
#include "DIA_coreToolkit.h"
#include "ADM_userInterfaces/ADM_render/GUI_renderInternal.h"

extern int global_argc;
extern char **global_argv;

extern uint8_t UI_getPhysicalScreenSize(void* window, uint32_t *w,uint32_t *h);
extern int automation(void );
extern void HandleAction(Action a);
extern bool isVideoCodecConfigurable(void);
extern int encoderGetDefaultIndex(void);
extern int encoderGetEncoderCount (void);
extern const char *encoderGetIndexedName (uint32_t i);
uint32_t audioEncoderGetNumberOfEncoders(void);
const char  *audioEncoderGetDisplayName(uint32_t i);
extern void checkCrashFile(void);
extern void UI_QT4VideoWidget(QFrame *frame);
extern void loadTranslator(void);
extern void initTranslator(void);
extern void destroyTranslator(void);
extern ADM_RENDER_TYPE UI_getPreferredRender(void);
extern int A_openAvi(const char *name);
extern int A_appendAvi(const char *name);
extern char *actual_workbench_file;
extern void FileSel_ReadWrite(SELFILE_CB *cb, int rw, const char *name, const char *actual_workbench_file);
extern bool A_parseECMAScript(const char *name);
extern void saveCrashProject(void);

int SliderIsShifted=0;
static void setupMenus(void);
static int shiftKeyHeld=0;
static ADM_QSlider *slider=NULL;
static int _upd_in_progres=0;
static char     *customNames[ADM_MAC_CUSTOM_SCRIPT];
static QAction  *customActions[ADM_MAC_CUSTOM_SCRIPT];
static uint32_t ADM_nbCustom=0;
static int currentFps = 0;
static int frameCount = 0;
static int currentFrame = 0;
ADM_OUT_FORMAT UI_GetCurrentFormat(void);
void UI_setVideoCodec(int i);

#ifdef HAVE_AUDIO
extern uint8_t AVDM_setVolume(int volume);
#endif

#define WIDGET(x)  (((MainWindow *)QuiMainWindows)->ui.x)

#define CONNECT(object,zzz) connect( (ui.object),SIGNAL(triggered()),this,SLOT(buttonPressed()));
#define CONNECT_TB(object,zzz) connect( (ui.object),SIGNAL(clicked(bool)),this,SLOT(toolButtonPressed(bool)));
#define DECLARE_VAR(object,signal_name) {#object,signal_name},

#include "translation_table.h"    
/*
    Declare the table converting widget name to our internal signal           
*/
struct adm_qt4_translation
{
	const char *name;
	Action     action; 
};
const adm_qt4_translation myTranslationTable[]=
{
#define PROCESS DECLARE_VAR
	LIST_OF_OBJECTS
	LIST_OF_BUTTONS
#undef PROCESS
};
static Action searchTranslationTable(const char *name);
#define SIZEOF_MY_TRANSLATION sizeof(myTranslationTable)/sizeof(adm_qt4_translation)

int UI_readCurTime(uint16_t &hh, uint16_t &mm, uint16_t &ss, uint16_t &ms);
void UI_updateFrameCount(uint32_t curFrame);
void UI_updateTimeCount(uint32_t curFrame,uint32_t fps);
extern void UI_purge(void);
/*
    Declare the class that will be our main window

*/

void MainWindow::comboChanged(int z)
{
	if (sender() == ui.comboBoxVideo)
	{
		bool b = (ui.comboBoxVideo->currentIndex() != 0);

		ui.pushButtonVideoFilter->setEnabled(b);
		HandleAction (ACT_VideoCodecChanged);

		ui.pushButtonVideoConf->setEnabled(b && isVideoCodecConfigurable());
	}
	else if (sender() == ui.comboBoxAudio)
	{
		bool b = (ui.comboBoxAudio->currentIndex() != 0);

		ui.pushButtonAudioConf->setEnabled(b);
		ui.pushButtonAudioFilter->setEnabled(b);
		HandleAction(ACT_AudioCodecChanged);
	}
	else if (sender() == ui.comboBoxFormat)
	{
		ADM_OUT_FORMAT fmt = UI_GetCurrentFormat();

		if (fmt == ADM_AVI_UNP || fmt == ADM_AVI_PAK)
		{
			ui.comboBoxVideo->setEnabled(false);
			UI_setVideoCodec(0);
		}
		else
		{
			ui.comboBoxVideo->setEnabled(true);

			for (int i = 0; i < ADM_FORMAT_MAX; i++)
			{
				if (ADM_allOutputFormat[i].format == fmt)
				{
					ui.pushButtonMuxerConf->setEnabled((ADM_allOutputFormat[i].muxerConfigure != NULL));

					break;
				}
			}
		}
	}
}

void MainWindow::sliderValueChanged(int u) 
{
	if(!_upd_in_progres)
		HandleAction(ACT_Scale);
}

void MainWindow::sliderMoved(int value)
{
	SliderIsShifted = shiftKeyHeld;
}

void MainWindow::sliderReleased(void)
{
	SliderIsShifted = 0;
}

void MainWindow::thumbSlider_valueEmitted(int value)
{
	if (value > 0)
		nextIntraFrame();
	else
		previousIntraFrame();
}

void MainWindow::volumeChange( int u )
{
#ifdef HAVE_AUDIO
	if (_upd_in_progres || !ui.toolButtonAudioToggle->isChecked())
		return;

	_upd_in_progres++;

	int vol = ui.horizontalSlider_2->value();

	AVDM_setVolume(vol);
	_upd_in_progres--;
#endif
}

void MainWindow::audioToggled(bool checked)
{
#ifdef HAVE_AUDIO
	if (checked)
		AVDM_setVolume(ui.horizontalSlider_2->value());
	else
		AVDM_setVolume(0);
#endif
}

void MainWindow::previewModeChanged(QAction *action)
{
	HandleAction(ACT_PreviewChanged);
}

void MainWindow::timeChangeFinished(void)
{
	this->setFocus(Qt::OtherFocusReason);
}

void MainWindow::currentFrameChanged(void)
{
	HandleAction(ACT_JumpToFrame);

	this->setFocus(Qt::OtherFocusReason);
}

void MainWindow::currentTimeChanged(void)
{
	HandleAction(ACT_JumpToTime);

	this->setFocus(Qt::OtherFocusReason);
}


MainWindow::MainWindow() : QMainWindow()
{
	qtRegisterDialog(this);
	ui.setupUi(this);

	this->setStatusBar(0);
	this->adjustSize();

#if defined(__APPLE__) && defined(USE_SDL)
	ui.actionAbout_avidemux->setMenuRole(QAction::NoRole);
	ui.action_Preferences->setMenuRole(QAction::NoRole);
	ui.actionQuit->setMenuRole(QAction::NoRole);
#endif

	// Preview modes
	QActionGroup *groupPreviewModes = new QActionGroup(this);

	groupPreviewModes->addAction(ui.actionPreviewInput);
	groupPreviewModes->addAction(ui.actionPreviewOutput);
	groupPreviewModes->addAction(ui.actionPreviewSide);
	groupPreviewModes->addAction(ui.actionPreviewTop);
	groupPreviewModes->addAction(ui.actionPreviewSeparate);
	connect(groupPreviewModes, SIGNAL(triggered(QAction*)), this, SLOT(previewModeChanged(QAction*)));

	// Zoom modes
	QActionGroup *groupZoomModes = new QActionGroup(this);

	groupZoomModes->addAction(ui.actionZoom_1_4);
	groupZoomModes->addAction(ui.actionZoom_1_2);
	groupZoomModes->addAction(ui.actionZoom_1_1);
	groupZoomModes->addAction(ui.actionZoom_2_1);

	/*
	Connect our button to buttonPressed
	*/
#define PROCESS CONNECT
	LIST_OF_OBJECTS
#undef PROCESS
#define PROCESS CONNECT_TB
	LIST_OF_BUTTONS
#undef PROCESS

	connect(ui.actionPrevious_intra_frame, SIGNAL(triggered()), this, SLOT(previousIntraFrame()));
	connect(ui.actionNext_intra_frame, SIGNAL(triggered()), this, SLOT(nextIntraFrame()));

	//ACT_VideoCodecChanged
	connect( ui.comboBoxVideo,SIGNAL(currentIndexChanged(int)),this,SLOT(comboChanged(int)));
	connect( ui.comboBoxAudio,SIGNAL(currentIndexChanged(int)),this,SLOT(comboChanged(int)));
	connect(ui.comboBoxFormat, SIGNAL(currentIndexChanged(int)), this, SLOT(comboChanged(int)));

	// Slider
	slider=ui.horizontalSlider;
	slider->setMinimum(0);
	slider->setMaximum(1000000000);
	slider->setPageStep(10000000);
	connect( slider,SIGNAL(valueChanged(int)),this,SLOT(sliderValueChanged(int)));
	connect( slider,SIGNAL(sliderMoved(int)),this,SLOT(sliderMoved(int)));
	connect( slider,SIGNAL(sliderReleased()),this,SLOT(sliderReleased()));

	// Thumb slider
	ui.sliderPlaceHolder->installEventFilter(this);
	thumbSlider = new ThumbSlider(ui.sliderPlaceHolder);
	connect(thumbSlider, SIGNAL(valueEmitted(int)), this, SLOT(thumbSlider_valueEmitted(int)));

	// Volume slider
	QSlider *volSlider=ui.horizontalSlider_2;
	volSlider->setMinimum(0);
	volSlider->setMaximum(100);
	connect(volSlider,SIGNAL(valueChanged(int)),this,SLOT(volumeChange(int)));
	connect(ui.toolButtonAudioToggle,SIGNAL(clicked(bool)),this,SLOT(audioToggled(bool)));

	// default state
	bool b=0;
	ui.pushButtonVideoConf->setEnabled(b);
	ui.pushButtonVideoFilter->setEnabled(b);
	ui.pushButtonAudioConf->setEnabled(b);
	ui.pushButtonAudioFilter->setEnabled(b);

	/* Time Shift */
	connect(ui.checkBox_TimeShift,SIGNAL(stateChanged(int)),this,SLOT(timeChanged(int)));
	connect(ui.spinBox_TimeValue,SIGNAL(valueChanged(int)),this,SLOT(timeChanged(int)));
	connect(ui.spinBox_TimeValue, SIGNAL(editingFinished()), this, SLOT(timeChangeFinished()));

	connect(ui.lineEdit, SIGNAL(editingFinished()), this, SLOT(currentFrameChanged()));

	QIntValidator *frameValidator = new QIntValidator(0, 0x7FFFFFFF, this);
	ui.lineEdit->setValidator(frameValidator);

	connect(ui.lineEdit, SIGNAL(editingFinished()), this, SLOT(currentFrameChanged()));

	QRegExp timeRegExp("^[0-9]{2}:[0-5][0-9]:[0-5][0-9]\\.[0-9]{3}$");
	QRegExpValidator *timeValidator = new QRegExpValidator(timeRegExp, this);
	ui.lineEdit_2->setValidator(timeValidator);
	ui.lineEdit_2->setInputMask("99:99:99.999");

	connect(ui.lineEdit_2, SIGNAL(editingFinished()), this, SLOT(currentTimeChanged()));

	/* Build the custom menu */
	buildCustomMenu();
	buildAutoMenu();

	this->installEventFilter(this);
	slider->installEventFilter(this);
	ui.lineEdit->installEventFilter(this);
	ui.lineEdit_2->installEventFilter(this);

	this->setFocus(Qt::OtherFocusReason);

	setAcceptDrops(true);
}
/**
\fn     custom
\brief  Invoked when one of the custom script has been called
*/
void MainWindow::custom(void)
{
	printf("[Custom] Invoked\n");
	QObject *ptr=sender();
	if(!ptr) return;
	for(int i=0;i<ADM_nbCustom;i++)
	{
		if(customActions[i]==ptr)
		{
			printf("[Custom] %u/%u scripts\n",i,ADM_nbCustom);
			HandleAction( (Action)(ACT_CUSTOM_BASE+i));
			return; 
		}
	}
	printf("[Custom] Not found\n");
}
/**
    Get the custom entry 

*/
const char * GUI_getCustomScript(uint32_t nb)
{
	ADM_assert(nb<ADM_nbCustom);
	return customNames[nb];

}
/**
    \fn timeChanged
    \brief Called whenever timeshift is on/off'ed or value changes
*/
void MainWindow::timeChanged(int)
{
	HandleAction (ACT_TimeShift) ;
}
/*
      We receive a button press event
*/
void MainWindow::buttonPressed(void)
{
	// Receveid a key press Event, look into table..
    QObject *obj=sender();
    if(!obj) return;
    QString me(obj->objectName());
    Action action=searchTranslationTable(qPrintable(me));

	if(action!=ACT_DUMMY)
		HandleAction (action);

}
void MainWindow::toolButtonPressed(bool i)
{
	buttonPressed();
}

bool MainWindow::eventFilter(QObject* watched, QEvent* event)
{
	QKeyEvent *keyEvent;

	switch (event->type())
	{
		case QEvent::KeyPress:
			keyEvent = (QKeyEvent*)event;

			if (watched == slider)
			{
				switch (keyEvent->key())
				{
					case Qt::Key_Left:
						if (keyEvent->modifiers() == Qt::ShiftModifier)
							HandleAction(ACT_Back25Frames);
						else if (keyEvent->modifiers() == Qt::ControlModifier)
							HandleAction(ACT_Back50Frames);
						else
							HandleAction(ACT_PreviousFrame);

						return true;
					case Qt::Key_Right:
						if (keyEvent->modifiers() == Qt::ShiftModifier)
							HandleAction(ACT_Forward25Frames);
						else if (keyEvent->modifiers() == Qt::ControlModifier)
							HandleAction(ACT_Forward50Frames);
						else
							HandleAction(ACT_NextFrame);

						return true;
					case Qt::Key_Up:
						HandleAction(ACT_NextKFrame);
						return true;
					case Qt::Key_Down:
						HandleAction(ACT_PreviousKFrame);
						return true;
					case Qt::Key_Shift:
						shiftKeyHeld = 1;
						break;
				}
			}
			else if (keyEvent->key() == Qt::Key_Space)
			{
				HandleAction(ACT_PlayAvi);
				return true;
			}

			break;
		case QEvent::KeyRelease:
			keyEvent = (QKeyEvent*)event;

			if (keyEvent->key() == Qt::Key_Shift)
				shiftKeyHeld = 0;

			break;
		case QEvent::FocusOut:
			if (watched == ui.lineEdit)
			{
				QString temp(ui.lineEdit->text());
				int pos = 0;

				if (ui.lineEdit->validator()->validate(temp, pos) != QValidator::Acceptable)
					UI_updateFrameCount(currentFrame);
			}
			else if (watched == ui.lineEdit_2)
			{
				uint16_t hh, mm, ss, ms;

				if (!UI_readCurTime(hh, mm, ss, ms))
					UI_updateTimeCount(currentFrame, currentFps);
			}

			break;
		case QEvent::Resize:
			if (watched == ui.sliderPlaceHolder)
			{
				thumbSlider->resize(ui.sliderPlaceHolder->width(), 16);
				thumbSlider->move(0, (ui.sliderPlaceHolder->height() - thumbSlider->height()) / 2);
			}

			break;
	}

	return QObject::eventFilter(watched, event);
}

void MainWindow::mousePressEvent(QMouseEvent* event)
{
	this->setFocus(Qt::OtherFocusReason);
}

void MainWindow::dragEnterEvent(QDragEnterEvent *event)
{
	if (event->mimeData()->hasFormat("text/uri-list"))
		event->acceptProposedAction();
}

void MainWindow::dropEvent(QDropEvent *event)
{
	QList<QUrl> urlList;
	QString fileName;
	QFileInfo info;

	if (event->mimeData()->hasUrls())
	{
		urlList = event->mimeData()->urls();

		for (int fileIndex = 0; fileIndex < urlList.size(); fileIndex++)
		{
			fileName = urlList[fileIndex].toLocalFile();
			info.setFile(fileName);

			if (info.isFile())
			{
				if (avifileinfo)
					FileSel_ReadWrite(reinterpret_cast <void (*)(const char *)> (A_appendAvi), 0, fileName.toUtf8().data(), actual_workbench_file);
				else
					FileSel_ReadWrite(reinterpret_cast <void (*)(const char *)> (A_openAvi), 0, fileName.toUtf8().data(), actual_workbench_file);
			}
		}
	}

	event->acceptProposedAction();
}

void MainWindow::previousIntraFrame(void)
{
	if (ui.spinBox_TimeValue->hasFocus())
		ui.spinBox_TimeValue->stepDown();
	else
		HandleAction(ACT_PreviousKFrame);
}

void MainWindow::nextIntraFrame(void)
{
	if (ui.spinBox_TimeValue->hasFocus())
		ui.spinBox_TimeValue->stepUp();
	else
		HandleAction(ACT_NextKFrame);
}

void MainWindow::clearCustomMenu(void)
{
	if (ADM_nbCustom)
	{
		for(int i = 0; i < ADM_nbCustom; i++)
		{
			disconnect(customActions[i], SIGNAL(triggered()), this, SLOT(custom()));
			delete customActions[i];
			delete customNames[i];
		}

		ui.menuCustom->clear();
		ADM_nbCustom = 0;
	}
}

void MainWindow::buildCustomMenu(void)
{
	clearCustomMenu();

	char *customdir = ADM_getCustomDir();

	if (!customdir)
	{
		printf("No custom dir...\n");
		return;
	}

	/* Collect the name */
	if (! buildDirectoryContent(&ADM_nbCustom, customdir, customNames, ADM_MAC_CUSTOM_SCRIPT,".js"))
	{
		printf("Failed to build custom dir content");
		return;
	}

	if(ADM_nbCustom)
	{
		printf("Found %u custom script(s), adding them\n", ADM_nbCustom);

		for(int i=0; i < ADM_nbCustom; i++)
		{
			customActions[i] = new QAction(QString::fromUtf8(ADM_GetFileName(customNames[i])), NULL);
			ui.menuCustom->addAction(customActions[i]);
			connect(customActions[i], SIGNAL(triggered()), this, SLOT(custom()));
		}
	}
	else
		printf("No custom scripts\n");

	printf("Custom menu built\n");
}

void MainWindow::autoMenuHandler(void)
{
	QObject *obj = sender();
	QString filePath = ((QAction*)obj)->text() + ".js";

	while (obj->parent() != ui.menuAuto)
	{
		obj = obj->parent();
		filePath = ((QMenu*)obj)->title() + QDir::separator() + filePath;
	}

	char *scriptDir = ADM_getScriptPath();

	A_parseECMAScript((QString::fromUtf8(scriptDir) + "auto" + QDir::separator() + filePath).toUtf8().constData());

	delete scriptDir;
}

void MainWindow::addDirEntryToMenu(QMenu *parentMenu, QString path)
{
	QFileInfo info(path);

	if (info.isDir())
	{
		QDir dir(info.path() + QDir::separator());

		dir.setSorting(QDir::DirsFirst | QDir::Name);

		QFileInfoList fileList = dir.entryInfoList();

		for (int x = 0; x < fileList.count(); x++)
		{
			if (fileList[x].fileName() != "." && fileList[x].fileName() != "..")
			{
				QMenu *menu = parentMenu;

				if (fileList[x].isDir())
				{
					menu = parentMenu->addMenu(tr(QDir(fileList[x].filePath()).dirName().toUtf8().constData()));

					addDirEntryToMenu(menu, fileList[x].filePath() + QDir::separator());
				}
				else
					addDirEntryToMenu(menu, fileList[x].filePath());
			}
		}
	}
	else
	{
		QAction *action = new QAction(tr(info.completeBaseName().toUtf8().constData()), parentMenu);

		parentMenu->addAction(action);
		connect(action, SIGNAL(triggered()), this, SLOT(autoMenuHandler()));
	}
}

void MainWindow::buildAutoMenu(void)
{
	char *scriptDir = ADM_getScriptPath();
	QFileInfo autoDirInfo = QFileInfo(QString::fromUtf8(scriptDir) + QString("auto") + QDir::separator());

	delete scriptDir;

	if (autoDirInfo.isDir())
		addDirEntryToMenu(ui.menuAuto, autoDirInfo.filePath());

	if (ui.menuAuto->isEmpty())
		ui.menuAuto->setEnabled(false);
}

void MainWindow::closeEvent(QCloseEvent *event)
{
	HandleAction(ACT_Exit);
}

MainWindow::~MainWindow()
{
	delete thumbSlider;
	clearCustomMenu();
	renderDestroy();
}
static const UI_FUNCTIONS_T UI_Hooks=
    {
        ADM_RENDER_API_VERSION_NUMBER,
        UI_purge,
        UI_getWindowInfo,
        UI_updateDrawWindowSize,
        UI_rgbDraw,
        UI_getDrawWidget,
        UI_getPreferredRender
        
    };
int UI_Init(int nargc,char **nargv)
{
	initTranslator();

	global_argc=nargc;
	global_argv=nargv;
	ADM_renderLibInit(&UI_Hooks);
	return 0;
}
QWidget *QuiMainWindows=NULL;
QGraphicsView *drawWindow=NULL;
uint8_t UI_updateRecentMenu( void );
void UI_updateRecentProjectsMenu(void);

void UI_refreshCustomMenu(void)
{
	((MainWindow*)QuiMainWindows)->buildCustomMenu();
}

/**
    \fn UI_getCurrentPreview(void)
    \brief Read previewmode from comboxbox 
*/
int UI_getCurrentPreview(void)
{
	int index;

	if (WIDGET(actionPreviewOutput)->isChecked())
		index = 1;
	else if (WIDGET(actionPreviewSide)->isChecked())
		index = 2;
	else if (WIDGET(actionPreviewTop)->isChecked())
		index = 3;
	else if (WIDGET(actionPreviewSeparate)->isChecked())
		index = 4;
	else
		index = 0;

	return index;
}

/**
    \fn UI_setCurrentPreview(int ne)
    \brief Update comboxbox with previewmode
*/
void UI_setCurrentPreview(int ne)
{
	switch (ne)
	{
		case 1:
			WIDGET(actionPreviewOutput)->setChecked(true);
			break;
		case 2:
			WIDGET(actionPreviewSide)->setChecked(true);
			break;
		case 3:
			WIDGET(actionPreviewTop)->setChecked(true);
			break;
		case 4:
			WIDGET(actionPreviewSeparate)->setChecked(true);
			break;
		default:
			WIDGET(actionPreviewInput)->setChecked(true);
	}
}

static void FatalFunctionQt(const char *title, const char *info)
{
	GUI_Info_HIG(ADM_LOG_IMPORTANT, title, info);
}

/**
    \fn UI_RunApp(void)
    \brief Main entry point for the GUI application
*/
int UI_RunApp(void)
{
	Q_INIT_RESOURCE(avidemux);
	Q_INIT_RESOURCE(filter);

	QApplication a(global_argc, global_argv);
	a.connect(&a, SIGNAL(lastWindowClosed()), &a, SLOT(quit()));

	loadTranslator();

	MainWindow *mw = new MainWindow();
	mw->show();

	QuiMainWindows = (QWidget*)mw;

	uint32_t w, h;

	UI_getPhysicalScreenSize(QuiMainWindows, &w,&h);
	printf("The screen seems to be %u x %u px\n",w,h);

	UI_QT4VideoWidget(mw->ui.frame_video);  // Add the widget that will handle video display
	UI_updateRecentMenu();
	UI_updateRecentProjectsMenu();
	setupMenus();
	ADM_setCrashHook(&saveCrashProject, &FatalFunctionQt);
	checkCrashFile();

	if (global_argc >= 2)
		automation();

	a.exec();

	destroyTranslator();
}
/**
    \fn searchTranslationTable(const char *name))
    \brief return the action corresponding to a give button. The translation table is in translation_table.h
*/
Action searchTranslationTable(const char *name)
{
	for(int i=0;i< SIZEOF_MY_TRANSLATION;i++)
	{
		if(!strcmp(name, myTranslationTable[i].name))
		{
			return  myTranslationTable[i].action;
		}
	}
	printf("WARNING: Signal not found in translation table %s\n",name);
	return ACT_DUMMY;
}
/**
    \fn     UI_updateRecentMenu( void )
    \brief  Update the recent submenu with the latest files loaded
*/
uint8_t UI_updateRecentMenu( void )
{
	const char **names;
	uint32_t nb_item=0;
	QAction *actions[6]={WIDGET(actionRecent0),WIDGET(actionRecent1),WIDGET(actionRecent2),WIDGET(actionRecent3),WIDGET(actionRecent4),WIDGET(actionRecent5)};
	names=prefs->get_lastfiles();

	// hide them all
	for(int i=0;i<6;i++) actions[i]->setVisible(0);
	// Redraw..
	for( nb_item=0;nb_item<6;nb_item++)
	{
		if(!names[nb_item]) 
		{
			return 1;
		}
		else
		{
			//actions[nb_item]->setVisible(1);
			// Replace widget ?
			actions[nb_item]->setText(QString::fromUtf8(names[nb_item]));
			actions[nb_item]->setVisible(1);
		}
		// Update name
	}
	return 1;
}

void UI_updateRecentProjectsMenu(void)
{
	const char **names = prefs->getLastProjects();
	QAction *actions[6] = {WIDGET(actionRecentProject0), WIDGET(actionRecentProject1), WIDGET(actionRecentProject2),
		WIDGET(actionRecentProject3), WIDGET(actionRecentProject4), WIDGET(actionRecentProject5)};

	for(int index = 0; index < 6; index++)
		actions[index]->setVisible(false);

	for (int index = 0; index < 6; index++)
	{
		if (!names[index])
			break;
		else
		{
			actions[index]->setText(QString::fromUtf8(names[index]));
			actions[index]->setVisible(true);
		}
	}
}

/** 
  \fn    setupMenus(void)
  \brief Fill in video & audio co
*/
void setupMenus(void)
{
	uint32_t nbVid;
	const char *name;

	nbVid=encoderGetEncoderCount();
	printf("Found %d video encoder(s)\n",nbVid);
	for(uint32_t i=1;i<nbVid;i++)
	{
		name=encoderGetIndexedName(i);
		WIDGET(comboBoxVideo)->addItem(name);
	}

	if (encoderGetDefaultIndex() > -1)
		UI_setVideoCodec(encoderGetDefaultIndex());

	// And A codec

	uint32_t nbAud;

    nbAud=audioEncoderGetNumberOfEncoders();
	printf("Found %d audio encoder(s)\n",nbAud);		       
	for(uint32_t i=1;i<nbAud;i++)
	{
		name=audioEncoderGetDisplayName(i);
		WIDGET(comboBoxAudio)->addItem(name);
	}

	/*   Fill in output format window */
	uint32_t nbFormat;

	nbFormat=sizeof(ADM_allOutputFormat)/sizeof(ADM_FORMAT_DESC);
	printf("Found %d format(s)\n",nbFormat);
	for(uint32_t i=0;i<nbFormat;i++)
	{
		WIDGET(comboBoxFormat)->addItem(QString::fromUtf8(ADM_allOutputFormat[i].text));	
	}

}
/*
    Return % of scale (between 0 and 1)
*/
double 	UI_readScale( void )
{
	double v;
	if(!slider) v=0;
	v= (double)(slider->value());
	v/=10000000;
	return v;
}
void UI_setScale( double val )
{
	if(_upd_in_progres) return;
	_upd_in_progres++;
	slider->setValue( (int)(val * 10000000));
	_upd_in_progres--;
}

int UI_readCurFrame(void)
{
	bool ok;
	
	return WIDGET(lineEdit)->text().toInt(&ok);
}

int UI_readCurTime(uint16_t &hh, uint16_t &mm, uint16_t &ss, uint16_t &ms)
{
	int success = 0;

	QString timeText = WIDGET(lineEdit_2)->text();
	int pos;

	if (WIDGET(lineEdit_2)->validator()->validate(timeText, pos) == QValidator::Acceptable)
	{
		uint32_t frame;

		hh = (uint16_t)timeText.left(2).toUInt();
		mm = (uint16_t)timeText.mid(3, 2).toUInt();
		ss = (uint16_t)timeText.mid(6, 2).toUInt();
		ms = (uint16_t)timeText.right(3).toUInt();

		time2frame(&frame, currentFps, hh, mm, ss, ms);

		if (frame <= frameCount)
			success = 1;
	}

	return success;
}

void UI_iconify( void )
{
	QuiMainWindows->hide();
}
void UI_deiconify( void )
{
	QuiMainWindows->showNormal();
}

void UI_purge( void )
{
	QCoreApplication::processEvents ();
}


//*******************************************

/**
    \fn UI_setTitle(char *name)
    \brief Set the main window title, usually name if the file being edited
*/
void UI_setTitle(const char *name)
{
	char *title;
	const char* defaultTitle = "Avidemux";

	if (name && strlen(name) > 0)
	{
		title = new char[strlen(defaultTitle) + strlen(name) + 3 + 1];

		strcpy(title, name);
		strcat(title, " - ");
		strcat(title, defaultTitle);
	}
	else
	{
		title = new char[strlen(defaultTitle) + 1];

		strcpy(title, defaultTitle);
	}

	QuiMainWindows->setWindowTitle(QString::fromUtf8(title));
	delete [] title;
}

/**
    \fn     UI_setFrameType( uint32_t frametype,uint32_t qp)
    \brief  Display frametype (I/P/B) and associated quantizer
*/

void UI_setFrameType( uint32_t frametype,uint32_t qp)
{
	char string[100];
	char	c='?';
	switch(frametype)
	{
	case AVI_KEY_FRAME: c='I';break;
	case AVI_B_FRAME: c='B';break;
	case 0: c='P';break;
	default:c='?';break;

	}

	WIDGET(label_8)->setText(MainWindow::tr("%1 (%2)").arg(c).arg(qp, 2, 10, QLatin1Char('0')));
}

/**
    \fn     UI_updateFrameCount(uint32_t curFrame)
    \brief  Display the current displayed frame #
*/
void UI_updateFrameCount(uint32_t curFrame)
{
	char string[30];
	sprintf(string,"%lu",curFrame);
	WIDGET(lineEdit)->setText(string);

	currentFrame = curFrame;
}

/**
    \fn      UI_setFrameCount(uint32_t curFrame,uint32_t total)
    \brief  Display the current displayed frame # and total frame #
*/
void UI_setFrameCount(uint32_t curFrame,uint32_t total)
{
	char text[80]; 
	if (total) total--; // We display from 0 to X  

	UI_updateFrameCount(curFrame);

	sprintf(text, "/ %lu", total);
	WIDGET(label_2)->setText(text);

	((QIntValidator*)(WIDGET(lineEdit)->validator()))->setTop(total);
	frameCount = total;
}

/**
    \fn     UI_updateTimeCount(uint32_t curFrame,uint32_t fps)
    \brief  Display the time corresponding to current frame according to fps (fps1000)
*/
void UI_updateTimeCount(uint32_t curFrame,uint32_t fps)
{
	char text[80];   
	uint16_t mm,hh,ss,ms;

	frame2time(curFrame,fps, &hh, &mm, &ss, &ms);
	sprintf(text, "%02d:%02d:%02d.%03d", hh, mm, ss, ms);
	WIDGET(lineEdit_2)->setText(text);
}

/**
    \fn     UI_updateTimeCount(uint32_t curFrame,uint32_t fps)
    \brief  Display the time corresponding to current frame according to fps (fps1000) and total duration
*/
void UI_setTimeCount(uint32_t curFrame,uint32_t total, uint32_t fps)
{
	char text[80];   
	uint16_t mm,hh,ss,ms;

	if(total) total--; // We display from 0 to X

	UI_updateTimeCount(curFrame,fps);
	frame2time(total,fps, &hh, &mm, &ss, &ms);
	sprintf(text, "/ %02d:%02d:%02d.%03d", hh, mm, ss, ms);
	WIDGET(label_7)->setText(text);

	slider->setFrameCount(total);

	currentFps = fps;	
}

/**
    \fn     UI_setMarkers(uint32_t a, uint32_t b )
    \brief  Display frame # for marker A & B
*/
void UI_setMarkers(uint32_t a, uint32_t b)
{
	char text[80];

	snprintf(text,79,"%06lu",a);
	WIDGET(pushButtonJumpToMarkerA)->setText(text);

	snprintf(text,79,"%06lu",b);
	WIDGET(pushButtonJumpToMarkerB)->setText(text);

	slider->setMarkers(a, b);
}

/**
    \fn     UI_getCurrentVCodec(void)
    \brief  Returns the current selected video code in menu, i.e its number (0 being the first)
*/
int 	UI_getCurrentVCodec(void)
{
	int i=WIDGET(comboBoxVideo)->currentIndex();
	if(i<0) i=0;
	return i; 
}
/**
    \fn     UI_setVideoCodec( int i)
    \brief  Select the video codec which is # x in pulldown menu (starts at zero :copy)
*/

void UI_setVideoCodec( int i)
{
	WIDGET(comboBoxVideo)->setCurrentIndex(i);
}
/**
    \fn     UI_getCurrentACodec(void)
    \brief  Returns the current selected audio code in menu, i.e its number (0 being the first)
*/

int 	UI_getCurrentACodec(void)
{
	int i=WIDGET(comboBoxAudio)->currentIndex();
	if(i<0) i=0;
	return i; 
}
/**
    \fn     UI_setAudioCodec( int i)
    \brief  Select the audio codec which is # x in pulldown menu (starts at zero :copy)
*/

void UI_setAudioCodec( int i)
{ int b=!!i;
WIDGET(comboBoxAudio)->setCurrentIndex(i);
WIDGET(pushButtonAudioConf)->setEnabled(b);
WIDGET(pushButtonAudioFilter)->setEnabled(b);
}
/**
    \fn     UI_GetCurrentFormat(void)
    \brief  Returns the current selected output format
*/

ADM_OUT_FORMAT 	UI_GetCurrentFormat( void )
{
	int i=WIDGET(comboBoxFormat)->currentIndex();
	if(i<0) i=0;
	return (ADM_OUT_FORMAT)i; 
}
/**
    \fn     UI_SetCurrentFormat( ADM_OUT_FORMAT fmt )
    \brief  Select  output format
*/
uint8_t 	UI_SetCurrentFormat( ADM_OUT_FORMAT fmt )
{
	WIDGET(comboBoxFormat)->setCurrentIndex((int)fmt);
}

/**
      \fn UI_getTimeShift
      \brief get state (on/off) and value for time Shift
*/
uint8_t UI_getTimeShift(int *onoff,int *value)
{
	if(WIDGET(checkBox_TimeShift)->checkState()==Qt::Checked)
		*onoff=1;
	else
		*onoff=0;
	*value=WIDGET(spinBox_TimeValue)->value();
	return 1;
}
/**
      \fn UI_setTimeShift
      \brief get state (on/off) and value for time Shift
*/

uint8_t UI_setTimeShift(int onoff,int value)
{
	if (onoff && value)
		WIDGET(checkBox_TimeShift)->setCheckState(Qt::Checked);
	else
		WIDGET(checkBox_TimeShift)->setCheckState(Qt::Unchecked);
	WIDGET(spinBox_TimeValue)->setValue(value);
	return 1;
}

void UI_setZoomMode(renderZoom zoom)
{
	switch (zoom)
	{
		case ZOOM_1_4:
			WIDGET(actionZoom_1_4)->setChecked(true);
			break;
		case ZOOM_1_2:
			WIDGET(actionZoom_1_2)->setChecked(true);
			break;
		case ZOOM_1_1:
			WIDGET(actionZoom_1_1)->setChecked(true);
			break;
		case ZOOM_2:
			WIDGET(actionZoom_2_1)->setChecked(true);
			break;
	}
}

//********************************************
//EOF
