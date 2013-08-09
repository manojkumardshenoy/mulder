///////////////////////////////////////////////////////////////////////////////
// Simple x264 Launcher
// Copyright (C) 2004-2013 LoRd_MuldeR <MuldeR2@GMX.de>
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

#include "win_addJob.h"

#include "global.h"
#include "model_options.h"
#include "model_recently.h"
#include "win_help.h"
#include "win_editor.h"

#include <QDate>
#include <QTimer>
#include <QCloseEvent>
#include <QMessageBox>
#include <QFileDialog>
#include <QDesktopServices>
#include <QValidator>
#include <QDir>
#include <QInputDialog>
#include <QSettings>
#include <QUrl>
#include <QAction>
#include <QClipboard>
#include <QToolTip>

#define ARRAY_SIZE(ARRAY) (sizeof((ARRAY))/sizeof((ARRAY[0])))
#define VALID_DIR(PATH) ((!(PATH).isEmpty()) && QFileInfo(PATH).exists() && QFileInfo(PATH).isDir())

#define REMOVE_USAFED_ITEM \
{ \
	for(int i = 0; i < cbxTemplate->count(); i++) \
	{ \
		OptionsModel* temp = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(i).value<void*>()); \
		if(temp == NULL) \
		{ \
			cbxTemplate->blockSignals(true); \
			cbxTemplate->removeItem(i); \
			cbxTemplate->blockSignals(false); \
			break; \
		} \
	} \
}

#define ADD_CONTEXTMENU_ACTION(WIDGET, ICON, TEXT, SLOTNAME) \
{ \
	QAction *_action = new QAction((ICON), (TEXT), this); \
	_action->setData(QVariant::fromValue<void*>(WIDGET)); \
	WIDGET->addAction(_action); \
	connect(_action, SIGNAL(triggered(bool)), this, SLOT(SLOTNAME())); \
}

#define ADD_CONTEXTMENU_SEPARATOR(WIDGET) \
{ \
	QAction *_action = new QAction(this); \
	_action->setSeparator(true); \
	WIDGET->addAction(_action); \
} 

///////////////////////////////////////////////////////////////////////////////
// Validator
///////////////////////////////////////////////////////////////////////////////

class StringValidator : public QValidator
{
public:
	StringValidator(QLabel *notifier, QLabel *icon)
	:
		m_notifier(notifier), m_icon(icon)
	{
		m_notifier->hide();
		m_icon->hide();
	}
	
	virtual State validate(QString &input, int &pos) const = 0;

	virtual void fixup(QString &input) const
	{
		input = input.simplified();
	}

protected:
	QLabel *const m_notifier, *const m_icon;

	bool checkParam(const QString &input, const QString &param, const bool doubleMinus) const
	{
		static const char c[20] = {' ', '*', '?', '<', '>', '/', '\\', '"', '\'', '!', '+', '#', '&', '%', '=', ',', ';', '.', '�', '`'};
		const QString prefix = doubleMinus ? QLatin1String("--") : QLatin1String("-");
		
		bool flag = false;
		if(param.length() > 1)
		{
			flag = flag || input.endsWith(QString("%1%2").arg(prefix, param), Qt::CaseInsensitive);
			for(size_t i = 0; i < sizeof(c); i++)
			{
				flag = flag || input.contains(QString("%1%2%3").arg(prefix, param, QChar::fromLatin1(c[i])), Qt::CaseInsensitive);
			}
		}
		else
		{
			flag = flag || input.startsWith(QString("-%1").arg(param));
			for(size_t i = 0; i < sizeof(c); i++)
			{
				flag = flag || input.contains(QString("%1-%2").arg(QChar::fromLatin1(c[i]), param), Qt::CaseSensitive);
			}
		}
		if((flag) && (m_notifier))
		{
			m_notifier->setText(tr("Invalid parameter: %1").arg((param.length() > 1) ? QString("%1%2").arg(prefix, param) : QString("-%1").arg(param)));
		}
		return flag;
	}

	const bool &setStatus(const bool &flag, const QString &toolName) const
	{
		if(flag)
		{
			if(m_notifier)
			{
				if(m_notifier->isHidden()) m_notifier->show();
				if(m_icon) { if(m_icon->isHidden()) m_icon->show(); }
				if(QWidget *w = m_notifier->topLevelWidget()->focusWidget())
				{
					QToolTip::showText(static_cast<QWidget*>(w->parent())->mapToGlobal(w->pos()), QString("<nobr>%1</nobr>").arg(tr("<b>Warning:</b> You entered a parameter that is incomaptible with using %1 from a GUI.<br>Please note that the GUI will automatically set <i>this</i> parameter for you (if required).").arg(toolName)), m_notifier, QRect());
				}
			}
		}
		else
		{
			if(m_notifier)
			{
				if(m_notifier->isVisible()) m_notifier->hide();
				if(m_icon) { if(m_icon->isVisible()) m_icon->hide(); }
				QToolTip::hideText();
			}
		}
		return flag;
	}
};

class StringValidatorX264 : public StringValidator
{
public:
	StringValidatorX264(QLabel *notifier, QLabel *icon) : StringValidator(notifier, icon) {}

	virtual State validate(QString &input, int &pos) const
	{
		static const char* p[] = {"B", "o", "h", "p", "q", /*"fps", "frames",*/ "preset", "tune", "profile",
			"stdin", "crf", "bitrate", "qp", "pass", "stats", "output", "help","quiet", NULL};

		bool invalid = false;

		for(size_t i = 0; p[i] && (!invalid); i++)
		{
			invalid = invalid || checkParam(input, QString::fromLatin1(p[i]), true);
		}

		return setStatus(invalid, "x264") ? QValidator::Intermediate : QValidator::Acceptable;
	}
};

class StringValidatorAvs2YUV : public StringValidator
{
public:
	StringValidatorAvs2YUV(QLabel *notifier, QLabel *icon) : StringValidator(notifier, icon) {}

	virtual State validate(QString &input, int &pos) const
	{
		static const char* p[] = {"o", "frames", "seek", "raw", "hfyu", "slave", NULL};

		bool invalid = false;

		for(size_t i = 0; p[i] && (!invalid); i++)
		{
			invalid = invalid || checkParam(input, QString::fromLatin1(p[i]), false);
		}
		
		return setStatus(invalid, "Avs2YUV") ? QValidator::Intermediate : QValidator::Acceptable;
	}
};

///////////////////////////////////////////////////////////////////////////////
// Constructor & Destructor
///////////////////////////////////////////////////////////////////////////////

AddJobDialog::AddJobDialog(QWidget *parent, OptionsModel *options, RecentlyUsed *recentlyUsed, bool x64supported, bool use10BitEncoding, bool saveToSourceFolder)
:
	QDialog(parent),
	m_defaults(new OptionsModel()),
	m_options(options),
	m_x64supported(x64supported),
	m_use10BitEncoding(use10BitEncoding),
	m_saveToSourceFolder(saveToSourceFolder),
	m_recentlyUsed(recentlyUsed)
{
	//Init the dialog, from the .ui file
	setupUi(this);
	setWindowFlags(windowFlags() & (~Qt::WindowContextHelpButtonHint));
	
	//Fix dialog size
	buttonSaveTemplate->setMaximumHeight(20);
	buttonDeleteTemplate->setMaximumHeight(20);
	resize(width(), minimumHeight());
	setMinimumSize(size());
	setMaximumHeight(height());

	//Hide optional controls
	checkBoxApplyToAll->setVisible(false);

	//Monitor RC mode combobox
	connect(cbxRateControlMode, SIGNAL(currentIndexChanged(int)), this, SLOT(modeIndexChanged(int)));

	//Activate buttons
	connect(buttonBrowseSource, SIGNAL(clicked()), this, SLOT(browseButtonClicked()));
	connect(buttonBrowseOutput, SIGNAL(clicked()), this, SLOT(browseButtonClicked()));
	connect(buttonSaveTemplate, SIGNAL(clicked()), this, SLOT(saveTemplateButtonClicked()));
	connect(buttonDeleteTemplate, SIGNAL(clicked()), this, SLOT(deleteTemplateButtonClicked()));

	//Setup validator
	editCustomX264Params->installEventFilter(this);
	editCustomX264Params->setValidator(new StringValidatorX264(labelNotificationX264, iconNotificationX264));
	editCustomX264Params->clear();
	editCustomAvs2YUVParams->installEventFilter(this);
	editCustomAvs2YUVParams->setValidator(new StringValidatorAvs2YUV(labelNotificationAvs2YUV, iconNotificationAvs2YUV));
	editCustomAvs2YUVParams->clear();

	//Install event filter
	labelHelpScreenX264->installEventFilter(this);
	labelHelpScreenAvs2YUV->installEventFilter(this);

	//Monitor for options changes
	connect(cbxRateControlMode, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationChanged()));
	connect(spinQuantizer, SIGNAL(valueChanged(double)), this, SLOT(configurationChanged()));
	connect(spinBitrate, SIGNAL(valueChanged(int)), this, SLOT(configurationChanged()));
	connect(cbxPreset, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationChanged()));
	connect(cbxTuning, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationChanged()));
	connect(cbxProfile, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationChanged()));
	connect(editCustomX264Params, SIGNAL(textChanged(QString)), this, SLOT(configurationChanged()));
	connect(editCustomAvs2YUVParams, SIGNAL(textChanged(QString)), this, SLOT(configurationChanged()));

	//Create context menus
	ADD_CONTEXTMENU_ACTION(editCustomX264Params, QIcon(":/buttons/page_edit.png"), tr("Open the Text-Editor"), editorActionTriggered);
	ADD_CONTEXTMENU_ACTION(editCustomAvs2YUVParams, QIcon(":/buttons/page_edit.png"), tr("Open the Text-Editor"), editorActionTriggered);
	ADD_CONTEXTMENU_SEPARATOR(editCustomX264Params);
	ADD_CONTEXTMENU_SEPARATOR(editCustomAvs2YUVParams);
	ADD_CONTEXTMENU_ACTION(editCustomX264Params, QIcon(":/buttons/page_copy.png"), tr("Copy to Clipboard"), copyActionTriggered);
	ADD_CONTEXTMENU_ACTION(editCustomAvs2YUVParams, QIcon(":/buttons/page_copy.png"), tr("Copy to Clipboard"), copyActionTriggered);
	ADD_CONTEXTMENU_ACTION(editCustomX264Params, QIcon(":/buttons/page_paste.png"), tr("Paste from Clipboard"), pasteActionTriggered);
	ADD_CONTEXTMENU_ACTION(editCustomAvs2YUVParams, QIcon(":/buttons/page_paste.png"), tr("Paste from Clipboard"), pasteActionTriggered);

	//Setup template selector
	loadTemplateList();
	connect(cbxTemplate, SIGNAL(currentIndexChanged(int)), this, SLOT(templateSelected()));
}

AddJobDialog::~AddJobDialog(void)
{
	//Free templates
	for(int i = 0; i < cbxTemplate->model()->rowCount(); i++)
	{
		if(cbxTemplate->itemText(i).startsWith("<") || cbxTemplate->itemText(i).endsWith(">"))
		{
			continue;
		}
		OptionsModel *item = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(i).value<void*>());
		cbxTemplate->setItemData(i, QVariant::fromValue<void*>(NULL));
		X264_DELETE(item);
	}

	//Free validators
	if(const QValidator *tmp = editCustomX264Params->validator())
	{
		editCustomX264Params->setValidator(NULL);
		X264_DELETE(tmp);
	}
	if(const QValidator *tmp = editCustomAvs2YUVParams->validator())
	{
		editCustomAvs2YUVParams->setValidator(NULL);
		X264_DELETE(tmp);
	}

	X264_DELETE(m_defaults);
}

///////////////////////////////////////////////////////////////////////////////
// Events
///////////////////////////////////////////////////////////////////////////////

void AddJobDialog::showEvent(QShowEvent *event)
{
	QDialog::showEvent(event);
	templateSelected();

	if((!editSource->text().isEmpty()) && editOutput->text().isEmpty())
	{
		QString outPath = generateOutputFileName(QDir::fromNativeSeparators(editSource->text()), m_recentlyUsed->outputDirectory(), m_recentlyUsed->filterIndex(), m_saveToSourceFolder);
		editOutput->setText(QDir::toNativeSeparators(outPath));
		buttonAccept->setFocus();
	}

	labelNotificationX264->hide();
	iconNotificationX264->hide();
	labelNotificationAvs2YUV->hide();
	iconNotificationAvs2YUV->hide();

	//Enable drag&drop support for this window, required for Qt v4.8.4+
	setAcceptDrops(true);
}

bool AddJobDialog::eventFilter(QObject *o, QEvent *e)
{
	if((o == labelHelpScreenX264) && (e->type() == QEvent::MouseButtonPress))
	{
		HelpDialog *helpScreen = new HelpDialog(this, false, m_x64supported, m_use10BitEncoding);
		helpScreen->exec();
		X264_DELETE(helpScreen);
	}
	else if((o == labelHelpScreenAvs2YUV) && (e->type() == QEvent::MouseButtonPress))
	{
		HelpDialog *helpScreen = new HelpDialog(this, true, m_x64supported, m_use10BitEncoding);
		helpScreen->exec();
		X264_DELETE(helpScreen);
	}
	else if((o == editCustomX264Params) && (e->type() == QEvent::FocusOut))
	{
		editCustomX264Params->setText(editCustomX264Params->text().simplified());
	}
	else if((o == editCustomAvs2YUVParams) && (e->type() == QEvent::FocusOut))
	{
		editCustomAvs2YUVParams->setText(editCustomAvs2YUVParams->text().simplified());
	}
	return false;
}

void AddJobDialog::dragEnterEvent(QDragEnterEvent *event)
{
	bool accept[2] = {false, false};

	foreach(const QString &fmt, event->mimeData()->formats())
	{
		accept[0] = accept[0] || fmt.contains("text/uri-list", Qt::CaseInsensitive);
		accept[1] = accept[1] || fmt.contains("FileNameW", Qt::CaseInsensitive);
	}

	if(accept[0] && accept[1])
	{
		event->acceptProposedAction();
	}
}

void AddJobDialog::dropEvent(QDropEvent *event)
{
	QString droppedFile;
	QList<QUrl> urls = event->mimeData()->urls();

	if(urls.count() > 1)
	{
		QDragEnterEvent dragEvent(event->pos(), event->proposedAction(), event->mimeData(), Qt::NoButton, Qt::NoModifier);
		if(qApp->notify(parent(), &dragEvent))
		{
			qApp->notify(parent(), event);
			reject(); return;
		}
	}

	while((!urls.isEmpty()) && droppedFile.isEmpty())
	{
		QUrl currentUrl = urls.takeFirst();
		QFileInfo file(currentUrl.toLocalFile());
		if(file.exists() && file.isFile())
		{
			qDebug("AddJobDialog::dropEvent: %s", file.canonicalFilePath().toUtf8().constData());
			droppedFile = file.canonicalFilePath();
		}
	}
	
	if(!droppedFile.isEmpty())
	{
		const QString outFileName = generateOutputFileName(droppedFile, currentOutputPath(), currentOutputIndx(), m_saveToSourceFolder);
		editSource->setText(QDir::toNativeSeparators(droppedFile));
		editOutput->setText(QDir::toNativeSeparators(outFileName));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Slots
///////////////////////////////////////////////////////////////////////////////

void AddJobDialog::modeIndexChanged(int index)
{
	spinQuantizer->setEnabled(index == 0 || index == 1);
	spinBitrate->setEnabled(index == 2 || index == 3);
}

void AddJobDialog::accept(void)
{
	//Selection complete?
	if(editSource->text().trimmed().isEmpty())
	{
		QMessageBox::warning(this, tr("Not Found!"), tr("Please select a valid source file first!"));
		return;
	}
	if(editOutput->text().trimmed().isEmpty())
	{
		QMessageBox::warning(this, tr("Not Selected!"), tr("<nobr>Please select a valid output file first!</nobr>"));
		return;
	}

	//Does source exist?
	QFileInfo sourceFile = QFileInfo(this->sourceFile());
	if(!(sourceFile.exists() && sourceFile.isFile()))
	{
		QMessageBox::warning(this, tr("Not Found!"), tr("<nobr>The selected source file could not be found!</nobr>"));
		return;
	}

	//Does output file already exist?
	QFileInfo outputFile = QFileInfo(this->outputFile());
	if(outputFile.exists() && outputFile.isFile())
	{
		int ret = QMessageBox::question(this, tr("Already Exists!"), tr("<nobr>Output file already exists! Overwrite?</nobr>"), QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
		if(ret != QMessageBox::Yes) return;
	}
	if(outputFile.exists() && (!outputFile.isFile()))
	{
		QMessageBox::warning(this, tr("Not a File!"), tr("<nobr>Selected output file does not appear to be a valid file!</nobr>"));
		return;
	}

	//Is destination dir writable?
	QFileInfo outputDir = QFileInfo(outputFile.absolutePath());
	if(!(outputDir.exists() && outputDir.isDir() && outputDir.isWritable()))
	{
		QMessageBox::warning(this, tr("Not Writable!"), tr("<nobr>Output directory does not exist or is not writable!</nobr>"));
		return;
	}

	//Custom parameters okay?
	if(!editCustomX264Params->hasAcceptableInput())
	{
		int ret = QMessageBox::warning(this, tr("Invalid Params"), tr("<nobr>Your custom parameters are invalid and will be discarded!</nobr>"), QMessageBox::Ignore | QMessageBox::Cancel, QMessageBox::Cancel);
		if(ret != QMessageBox::Ignore) return;
	}

	//Update recently used
	m_recentlyUsed->setFilterIndex(currentOutputIndx());
	m_recentlyUsed->setSourceDirectory(currentSourcePath());
	m_recentlyUsed->setOutputDirectory(currentOutputPath());
	RecentlyUsed::saveRecentlyUsed(m_recentlyUsed);

	//Save options
	saveOptions(m_options);
	QDialog::accept();
}

void AddJobDialog::browseButtonClicked(void)
{
	if(QObject::sender() == buttonBrowseSource)
	{
		QString filePath = QFileDialog::getOpenFileName(this, tr("Open Source File"), currentSourcePath(true), getInputFilterLst(), NULL, QFileDialog::DontUseNativeDialog);
		if(!(filePath.isNull() || filePath.isEmpty()))
		{
			QString destFile = generateOutputFileName(filePath, currentOutputPath(), currentOutputIndx(), m_saveToSourceFolder);
			editSource->setText(QDir::toNativeSeparators(filePath));
			editOutput->setText(QDir::toNativeSeparators(destFile));
		}
	}
	else if(QObject::sender() == buttonBrowseOutput)
	{
		QString selectedType = getFilterStr(currentOutputIndx());
		QString filePath = QFileDialog::getSaveFileName(this, tr("Choose Output File"), currentOutputPath(true), getFilterLst(), &selectedType, QFileDialog::DontUseNativeDialog | QFileDialog::DontConfirmOverwrite);

		if(!(filePath.isNull() || filePath.isEmpty()))
		{
			if(getFilterIdx(QFileInfo(filePath).suffix()) < 0)
			{
				int tempIndex = -1;
				QRegExp regExp("\\(\\*\\.(\\w+)\\)");
				if(regExp.lastIndexIn(selectedType) >= 0)
				{
					tempIndex = getFilterIdx(regExp.cap(1));
				}
				if(tempIndex < 0)
				{
					tempIndex = m_recentlyUsed->filterIndex();
				}
				filePath = QString("%1.%2").arg(filePath, getFilterExt(tempIndex));
			}
			editOutput->setText(QDir::toNativeSeparators(filePath));
		}
	}
}

void AddJobDialog::configurationChanged(void)
{
	OptionsModel* options = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(cbxTemplate->currentIndex()).value<void*>());
	if(options)
	{
		cbxTemplate->blockSignals(true);
		cbxTemplate->insertItem(0, tr("<Unsaved Configuration>"), QVariant::fromValue<void*>(NULL));
		cbxTemplate->setCurrentIndex(0);
		cbxTemplate->blockSignals(false);
	}
}

void AddJobDialog::templateSelected(void)
{
	OptionsModel* options = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(cbxTemplate->currentIndex()).value<void*>());
	if(options)
	{
		qDebug("Loading options!");
		REMOVE_USAFED_ITEM;
		restoreOptions(options);
	}

	modeIndexChanged(cbxRateControlMode->currentIndex());
}

void AddJobDialog::saveTemplateButtonClicked(void)
{
	qDebug("Saving template");
	QString name = tr("New Template");
	int n = 2;

	while(OptionsModel::templateExists(name))
	{
		name = tr("New Template (%1)").arg(QString::number(n++));
	}

	OptionsModel *options = new OptionsModel();
	saveOptions(options);

	if(options->equals(m_defaults))
	{
		QMessageBox::warning (this, tr("Oups"), tr("<nobr>It makes no sense to save the default settings!</nobr>"));
		cbxTemplate->blockSignals(true);
		cbxTemplate->setCurrentIndex(0);
		cbxTemplate->blockSignals(false);
		REMOVE_USAFED_ITEM;
		X264_DELETE(options);
		return;
	}

	for(int i = 0; i < cbxTemplate->count(); i++)
	{
		const QString tempName = cbxTemplate->itemText(i);
		if(tempName.contains('<') || tempName.contains('>'))
		{
			continue;
		}
		OptionsModel* test = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(i).value<void*>());
		if(test != NULL)
		{
			if(options->equals(test))
			{
				QMessageBox::warning (this, tr("Oups"), tr("<nobr>There already is a template for the current settings!</nobr>"));
				cbxTemplate->blockSignals(true);
				cbxTemplate->setCurrentIndex(i);
				cbxTemplate->blockSignals(false);
				REMOVE_USAFED_ITEM;
				X264_DELETE(options);
				return;
			}
		}
	}

	forever
	{
		bool ok = false;
		name = QInputDialog::getText(this, tr("Save Template"), tr("Please enter the name of the template:").leftJustified(144, ' '), QLineEdit::Normal, name, &ok).simplified();
		if(!ok)
		{
			X264_DELETE(options);
			return;
		}
		if(name.contains('<') || name.contains('>') || name.contains('\\') || name.contains('/') || name.contains('"'))
		{
			QMessageBox::warning (this, tr("Invalid Name"), tr("<nobr>Sorry, the name you have entered is invalid!</nobr>"));
			while(name.contains('<')) name.remove('<');
			while(name.contains('>')) name.remove('>');
			while(name.contains('\\')) name.remove('\\');
			while(name.contains('/')) name.remove('/');
			while(name.contains('"')) name.remove('"');
			name = name.simplified();
			continue;
		}
		if(OptionsModel::templateExists(name))
		{
			int ret = QMessageBox::warning (this, tr("Already Exists"), tr("<nobr>A template of that name already exists! Overwrite?</nobr>"), QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
			if(ret != QMessageBox::Yes)
			{
				continue;
			}
		}
		break;
	}
	
	if(!OptionsModel::saveTemplate(options, name))
	{
		QMessageBox::critical(this, tr("Save Failed"), tr("Sorry, the template could not be saved!"));
		X264_DELETE(options);
		return;
	}
	
	int index = cbxTemplate->model()->rowCount();
	cbxTemplate->blockSignals(true);
	for(int i = 0; i < cbxTemplate->count(); i++)
	{
		if(cbxTemplate->itemText(i).compare(name, Qt::CaseInsensitive) == 0)
		{
			index = -1; //Do not append new template
			OptionsModel *oldItem = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(i).value<void*>());
			cbxTemplate->setItemData(i, QVariant::fromValue<void*>(options));
			cbxTemplate->setCurrentIndex(i);
			X264_DELETE(oldItem);
		}
	}
	if(index >= 0)
	{
		cbxTemplate->insertItem(index, name, QVariant::fromValue<void*>(options));
		cbxTemplate->setCurrentIndex(index);
	}
	cbxTemplate->blockSignals(false);

	REMOVE_USAFED_ITEM;
}

void AddJobDialog::deleteTemplateButtonClicked(void)
{
	const int index = cbxTemplate->currentIndex();
	QString name = cbxTemplate->itemText(index);

	if(name.contains('<') || name.contains('>') || name.contains('\\') || name.contains('/'))
	{
		QMessageBox::warning (this, tr("Invalid Item"), tr("Sorry, the selected item cannot be deleted!"));
		return;
	}

	int ret = QMessageBox::question (this, tr("Delete Template"), tr("<nobr>Do you really want to delete the selected template?</nobr>"), QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
	if(ret != QMessageBox::Yes)
	{
		return;
	}


	OptionsModel::deleteTemplate(name);
	OptionsModel *item = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(index).value<void*>());
	cbxTemplate->removeItem(index);
	X264_DELETE(item);
}

void AddJobDialog::editorActionTriggered(void)
{

	if(QAction *action = dynamic_cast<QAction*>(QObject::sender()))
	{
		QLineEdit *lineEdit = reinterpret_cast<QLineEdit*>(action->data().value<void*>());
		
		EditorDialog *editor = new EditorDialog(this);
		editor->setEditText(lineEdit->text());

		if(editor->exec() == QDialog::Accepted)
		{
			lineEdit->setText(editor->getEditText());
		}

		X264_DELETE(editor);
	}
}

void AddJobDialog::copyActionTriggered(void)
{
	if(QAction *action = dynamic_cast<QAction*>(QObject::sender()))
	{
		QClipboard *clipboard = QApplication::clipboard();
		QLineEdit *lineEdit = reinterpret_cast<QLineEdit*>(action->data().value<void*>());
		QString text = lineEdit->hasSelectedText() ? lineEdit->selectedText() : lineEdit->text();
		clipboard->setText(text);
	}
}

void AddJobDialog::pasteActionTriggered(void)
{
	if(QAction *action = dynamic_cast<QAction*>(QObject::sender()))
	{
		QClipboard *clipboard = QApplication::clipboard();
		QLineEdit *lineEdit = reinterpret_cast<QLineEdit*>(action->data().value<void*>());
		QString text = clipboard->text();
		if(!text.isEmpty()) lineEdit->setText(text);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Public functions
///////////////////////////////////////////////////////////////////////////////

QString AddJobDialog::sourceFile(void)
{
	return QDir::fromNativeSeparators(editSource->text());
}

QString AddJobDialog::outputFile(void)
{
	return QDir::fromNativeSeparators(editOutput->text());
}

///////////////////////////////////////////////////////////////////////////////
// Private functions
///////////////////////////////////////////////////////////////////////////////

void AddJobDialog::loadTemplateList(void)
{
	cbxTemplate->addItem(tr("<Default>"), QVariant::fromValue<void*>(m_defaults));
	cbxTemplate->setCurrentIndex(0);

	QMap<QString, OptionsModel*> templates = OptionsModel::loadAllTemplates();
	QStringList templateNames = templates.keys();
	templateNames.sort();

	while(!templateNames.isEmpty())
	{
		QString current = templateNames.takeFirst();
		cbxTemplate->addItem(current, QVariant::fromValue<void*>(templates.value(current)));

		if(templates.value(current)->equals(m_options))
		{
			cbxTemplate->setCurrentIndex(cbxTemplate->count() - 1);
		}
	}

	if((cbxTemplate->currentIndex() == 0) && (!m_options->equals(m_defaults)))
	{
		cbxTemplate->insertItem(1, tr("<Recently Used>"), QVariant::fromValue<void*>(m_options));
		cbxTemplate->setCurrentIndex(1);
	}
}

void AddJobDialog::updateComboBox(QComboBox *cbox, const QString &text)
{
	for(int i = 0; i < cbox->model()->rowCount(); i++)
	{
		if(cbox->model()->data(cbox->model()->index(i, 0, QModelIndex())).toString().compare(text, Qt::CaseInsensitive) == 0)
		{
			cbox->setCurrentIndex(i);
			break;
		}
	}
}

void AddJobDialog::restoreOptions(OptionsModel *options)
{
	cbxRateControlMode->blockSignals(true);
	spinQuantizer->blockSignals(true);
	spinBitrate->blockSignals(true);
	cbxPreset->blockSignals(true);
	cbxTuning->blockSignals(true);
	cbxProfile->blockSignals(true);
	editCustomX264Params->blockSignals(true);
	editCustomAvs2YUVParams->blockSignals(true);

	cbxRateControlMode->setCurrentIndex(options->rcMode());
	spinQuantizer->setValue(options->quantizer());
	spinBitrate->setValue(options->bitrate());
	updateComboBox(cbxPreset, options->preset());
	updateComboBox(cbxTuning, options->tune());
	updateComboBox(cbxProfile, options->profile());
	editCustomX264Params->setText(options->customX264());
	editCustomAvs2YUVParams->setText(options->customAvs2YUV());

	cbxRateControlMode->blockSignals(false);
	spinQuantizer->blockSignals(false);
	spinBitrate->blockSignals(false);
	cbxPreset->blockSignals(false);
	cbxTuning->blockSignals(false);
	cbxProfile->blockSignals(false);
	editCustomX264Params->blockSignals(false);
	editCustomAvs2YUVParams->blockSignals(false);
}

void AddJobDialog::saveOptions(OptionsModel *options)
{
	options->setRCMode(static_cast<OptionsModel::RCMode>(cbxRateControlMode->currentIndex()));
	options->setQuantizer(spinQuantizer->value());
	options->setBitrate(spinBitrate->value());
	options->setPreset(cbxPreset->model()->data(cbxPreset->model()->index(cbxPreset->currentIndex(), 0)).toString());
	options->setTune(cbxTuning->model()->data(cbxTuning->model()->index(cbxTuning->currentIndex(), 0)).toString());
	options->setProfile(cbxProfile->model()->data(cbxProfile->model()->index(cbxProfile->currentIndex(), 0)).toString());
	options->setCustomX264(editCustomX264Params->hasAcceptableInput() ? editCustomX264Params->text().simplified() : QString());
	options->setCustomAvs2YUV(editCustomAvs2YUVParams->hasAcceptableInput() ? editCustomAvs2YUVParams->text().simplified() : QString());
}

QString AddJobDialog::currentSourcePath(const bool bWithName)
{
	QString path = m_recentlyUsed->sourceDirectory();
	QString currentSourceFile = this->sourceFile();
	
	if(!currentSourceFile.isEmpty())
	{
		QString currentSourceDir = QFileInfo(currentSourceFile).absolutePath();
		if(VALID_DIR(currentSourceDir))
		{
			path = currentSourceDir;
		}
		if(bWithName)
		{
			path.append("/").append(QFileInfo(currentSourceFile).fileName());
		}
	}

	return path;
}

QString AddJobDialog::currentOutputPath(const bool bWithName)
{
	QString path = m_recentlyUsed->outputDirectory();
	QString currentOutputFile = this->outputFile();
	
	if(!currentOutputFile.isEmpty())
	{
		QString currentOutputDir = QFileInfo(currentOutputFile).absolutePath();
		if(VALID_DIR(currentOutputDir))
		{
			path = currentOutputDir;
		}
		if(bWithName)
		{
			path.append("/").append(QFileInfo(currentOutputFile).fileName());
		}
	}

	return path;
}

int AddJobDialog::currentOutputIndx(void)
{
	int index = m_recentlyUsed->filterIndex();
	QString currentOutputFile = this->outputFile();
	
	if(!currentOutputFile.isEmpty())
	{
		const QString currentOutputExtn = QFileInfo(currentOutputFile).suffix();
		const int tempIndex = getFilterIdx(currentOutputExtn);
		if(tempIndex >= 0)
		{
			index = tempIndex;
		}
	}

	return index;
}

///////////////////////////////////////////////////////////////////////////////
// Static functions
///////////////////////////////////////////////////////////////////////////////

QString AddJobDialog::generateOutputFileName(const QString &sourceFilePath, const QString &destinationDirectory, const int filterIndex, const bool saveToSourceDir)
{
	QString name = QFileInfo(sourceFilePath).completeBaseName();
	QString path = saveToSourceDir ? QFileInfo(sourceFilePath).canonicalPath() : destinationDirectory;
	QString fext = getFilterExt(filterIndex);
	
	if(!VALID_DIR(path))
	{
		RecentlyUsed defaults;
		path = defaults.outputDirectory();
	}

	QString outPath = QString("%1/%2.%3").arg(path, name, fext);

	int n = 2;
	while(QFileInfo(outPath).exists())
	{
		outPath = QString("%1/%2 (%3).%4").arg(path, name, QString::number(n++), fext);
	}

	return outPath;
}

/* ------------------------------------------------------------------------- */

QString AddJobDialog::getFilterExt(const int filterIndex)
{
	const int count = ARRAY_SIZE(X264_FILE_TYPE_FILTERS);

	if((filterIndex >= 0) && (filterIndex < count))
	{
		return QString::fromLatin1(X264_FILE_TYPE_FILTERS[filterIndex].pcExt);
	}

	return QString::fromLatin1(X264_FILE_TYPE_FILTERS[0].pcExt);
}

int AddJobDialog::getFilterIdx(const QString &fileExt)
{
	const int count = ARRAY_SIZE(X264_FILE_TYPE_FILTERS);

	for(int i = 0; i < count; i++)
	{
		if(fileExt.compare(QString::fromLatin1(X264_FILE_TYPE_FILTERS[i].pcExt), Qt::CaseInsensitive) == 0)
		{
			return i;
		}
	}

	return -1;
}

QString AddJobDialog::getFilterStr(const int filterIndex)
{
	const int count = ARRAY_SIZE(X264_FILE_TYPE_FILTERS);

	if((filterIndex >= 0) && (filterIndex < count))
	{
		return QString("%1 (*.%2)").arg(QString::fromLatin1(X264_FILE_TYPE_FILTERS[filterIndex].pcStr), QString::fromLatin1(X264_FILE_TYPE_FILTERS[filterIndex].pcExt));
	}

	return QString("%1 (*.%2)").arg(QString::fromLatin1(X264_FILE_TYPE_FILTERS[0].pcStr), QString::fromLatin1(X264_FILE_TYPE_FILTERS[0].pcExt));
}

QString AddJobDialog::getFilterLst(void)
{
	QStringList filters;
	const int count = ARRAY_SIZE(X264_FILE_TYPE_FILTERS);
	
	for(int i = 0; i < count; i++)
	{
		filters << QString("%1 (*.%2)").arg(QString::fromLatin1(X264_FILE_TYPE_FILTERS[i].pcStr), QString::fromLatin1(X264_FILE_TYPE_FILTERS[i].pcExt));
	}

	return filters.join(";;");
}

QString AddJobDialog::getInputFilterLst(void)
{
	static const struct
	{
		const char *name;
		const char *fext;
	}
	s_filters[] =
	{
		{"Avisynth Scripts", "avs"},
		{"VapourSynth Scripts", "vpy"},
		{"Matroska Files", "mkv"},
		{"MPEG-4 Part 14 Container", "mp4"},
		{"Audio Video Interleaved", "avi"},
		{"Flash Video", "flv"},
		{"YUV4MPEG2 Stream", "y4m"},
		{"Uncompresses YUV Data", "yuv"},
	};

	const int count = ARRAY_SIZE(s_filters);

	QString allTypes;
	for(size_t index = 0; index < count; index++)
	{

		allTypes += QString((index > 0) ? " *.%1" : "*.%1").arg(QString::fromLatin1(s_filters[index].fext));
	}
	
	QStringList filters;
	filters << QString("All supported files (%1)").arg(allTypes);

	for(size_t index = 0; index < count; index++)
	{
		filters << QString("%1 (*.%2)").arg(QString::fromLatin1(s_filters[index].name), QString::fromLatin1(s_filters[index].fext));
	}
		
	filters << QString("All files (*.*)");
	return filters.join(";;");
}
