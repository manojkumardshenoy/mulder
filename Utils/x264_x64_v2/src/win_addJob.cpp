///////////////////////////////////////////////////////////////////////////////
// Simple x264 Launcher
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

#include "win_addJob.h"

#include "global.h"
#include "model_options.h"
#include "win_help.h"

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

static const struct
{
	const char *name;
	const char *fext;
}
g_filters[] =
{
	{"Avisynth Scripts", "avs"},
	{"Matroska Files", "mkv"},
	{"MPEG-4 Part 14 Container", "mp4"},
	{"Audio Video Interleaved", "avi"},
	{"Flash Video", "flv"},
	{NULL, NULL}
};

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

///////////////////////////////////////////////////////////////////////////////
// Validator
///////////////////////////////////////////////////////////////////////////////

class StringValidator : public QValidator
{
public:
	StringValidator(QLabel *notifier) : m_notifier(notifier) { m_notifier->hide(); }
	
	virtual State validate(QString &input, int &pos) const
	{
		bool invalid = false;
		
		invalid = invalid || (input.contains(" -B") || input.startsWith("-B"));
		invalid = invalid || (input.contains(" -o") || input.startsWith("-o"));
		invalid = invalid || (input.contains(" -h") || input.startsWith("-h"));
		invalid = invalid || (input.contains(" -p") || input.startsWith("-p"));

		invalid = invalid || input.contains("--fps", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--frames", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--preset", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--tune", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--profile", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--stdin", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--crf", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--bitrate", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--qp", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--pass", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--stats", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--output", Qt::CaseInsensitive);
		invalid = invalid || input.contains("--help", Qt::CaseInsensitive);

		if(invalid)
		{
			MessageBeep(MB_ICONWARNING);
			if(m_notifier->isHidden())
			{
				m_notifier->show();
				QTimer::singleShot(1000, m_notifier, SLOT(hide()));
			}
		}

		return invalid ? QValidator::Invalid : QValidator::Acceptable;
	}

	virtual void fixup(QString &input) const
	{
		input = input.simplified();
	}

protected:
	QLabel *const m_notifier;
};

///////////////////////////////////////////////////////////////////////////////
// Constructor & Destructor
///////////////////////////////////////////////////////////////////////////////

AddJobDialog::AddJobDialog(QWidget *parent, OptionsModel *options, bool x64supported)
:
	QDialog(parent),
	m_defaults(new OptionsModel()),
	m_options(options),
	m_x64supported(x64supported),
	initialDir_src(QDesktopServices::storageLocation(QDesktopServices::MoviesLocation)),
	initialDir_out(QDesktopServices::storageLocation(QDesktopServices::MoviesLocation))

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

	//Monitor RC mode combobox
	connect(cbxRateControlMode, SIGNAL(currentIndexChanged(int)), this, SLOT(modeIndexChanged(int)));

	//Activate buttons
	connect(buttonBrowseSource, SIGNAL(clicked()), this, SLOT(browseButtonClicked()));
	connect(buttonBrowseOutput, SIGNAL(clicked()), this, SLOT(browseButtonClicked()));
	connect(buttonSaveTemplate, SIGNAL(clicked()), this, SLOT(saveTemplateButtonClicked()));
	connect(buttonDeleteTemplate, SIGNAL(clicked()), this, SLOT(deleteTemplateButtonClicked()));

	//Setup validator
	editCustomParams->installEventFilter(this);
	editCustomParams->setValidator(new StringValidator(labelNotification));
	editCustomParams->clear();

	//Install event filter
	labelHelpScreen->installEventFilter(this);

	//Monitor for options changes
	connect(cbxRateControlMode, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationChanged()));
	connect(spinQuantizer, SIGNAL(valueChanged(int)), this, SLOT(configurationChanged()));
	connect(spinBitrate, SIGNAL(valueChanged(int)), this, SLOT(configurationChanged()));
	connect(cbxPreset, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationChanged()));
	connect(cbxTuning, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationChanged()));
	connect(cbxProfile, SIGNAL(currentIndexChanged(int)), this, SLOT(configurationChanged()));
	connect(editCustomParams, SIGNAL(textChanged(QString)), this, SLOT(configurationChanged()));

	//Setup template selector
	loadTemplateList();
	connect(cbxTemplate, SIGNAL(currentIndexChanged(int)), this, SLOT(templateSelected()));

	//Load directories
	const QString appDir = QDesktopServices::storageLocation(QDesktopServices::DataLocation);
	QSettings settings(QString("%1/last.ini").arg(appDir), QSettings::IniFormat);
	initialDir_src = settings.value("path/directory_openFrom", initialDir_src).toString();
	initialDir_out = settings.value("path/directory_saveTo", initialDir_out).toString();
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
	
	X264_DELETE(m_defaults);
}

///////////////////////////////////////////////////////////////////////////////
// Events
///////////////////////////////////////////////////////////////////////////////

void AddJobDialog::showEvent(QShowEvent *event)
{
	QDialog::showEvent(event);
	templateSelected();

	if(!editSource->text().isEmpty()) initialDir_src = QFileInfo(QDir::fromNativeSeparators(editSource->text())).path();
	if(!editOutput->text().isEmpty()) initialDir_out = QFileInfo(QDir::fromNativeSeparators(editOutput->text())).path();

	if((!editSource->text().isEmpty()) && editOutput->text().isEmpty())
	{
		generateOutputFileName(QDir::fromNativeSeparators(editSource->text()));
		buttonAccept->setFocus();
	}
}

bool AddJobDialog::eventFilter(QObject *o, QEvent *e)
{
	if((o == labelHelpScreen) && (e->type() == QEvent::MouseButtonPress))
	{
		HelpDialog *helpScreen = new HelpDialog(this, m_x64supported);
		helpScreen->exec();
		X264_DELETE(helpScreen);
	}
	else if((o == editCustomParams) && (e->type() == QEvent::FocusOut))
	{
		editCustomParams->setText(editCustomParams->text().simplified());
	}
	return false;
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
	if(editSource->text().trimmed().isEmpty())
	{
		QMessageBox::warning(this, tr("Not Found!"), tr("Please select a valid source file first!"));
		return;
	}
	
	if(editOutput->text().trimmed().isEmpty())
	{
		QMessageBox::warning(this, tr("Not Selected!"), tr("Please select a valid output file first!"));
		return;
	}

	QFileInfo sourceFile = QFileInfo(editSource->text());
	if(!(sourceFile.exists() && sourceFile.isFile()))
	{
		QMessageBox::warning(this, tr("Not Found!"), tr("The selected source file could not be found!"));
		return;
	}

	QFileInfo outputDir = QFileInfo(QFileInfo(editOutput->text()).path());
	if(!(outputDir.exists() && outputDir.isDir() && outputDir.isWritable()))
	{
		QMessageBox::warning(this, tr("Not Writable!"), tr("Output directory does not exist or is not writable!"));
		return;
	}

	QFileInfo outputFile = QFileInfo(editOutput->text());
	if(outputFile.exists() && outputFile.isFile())
	{
		if(QMessageBox::question(this, tr("Already Exists!"), tr("Output file already exists! Overwrite?"), QMessageBox::Yes | QMessageBox::No, QMessageBox::No) != QMessageBox::Yes)
		{
			return;
		}
	}
	if(outputFile.exists() && (!outputFile.isFile()))
	{
		QMessageBox::warning(this, tr("Not a File!"), tr("Selected output files does not appear to be a file!"));
		return;
	}

	//Save directories
	const QString appDir = QDesktopServices::storageLocation(QDesktopServices::DataLocation);
	QSettings settings(QString("%1/last.ini").arg(appDir), QSettings::IniFormat);
	if(settings.isWritable())
	{
		settings.setValue("path/directory_openFrom", initialDir_src);
		settings.setValue("path/directory_saveTo", initialDir_out);
		settings.sync();
	}

	saveOptions(m_options);
	QDialog::accept();
}

void AddJobDialog::browseButtonClicked(void)
{
	if(QObject::sender() == buttonBrowseSource)
	{
		QString filePath = QFileDialog::getOpenFileName(this, tr("Open Source File"), VALID_DIR(initialDir_src) ? initialDir_src : QDesktopServices::storageLocation(QDesktopServices::MoviesLocation), makeFileFilter(), NULL, QFileDialog::DontUseNativeDialog);
		if(!(filePath.isNull() || filePath.isEmpty()))
		{
			editSource->setText(QDir::toNativeSeparators(filePath));
			generateOutputFileName(filePath);
			initialDir_src = QFileInfo(filePath).path();
		}
	}
	else if(QObject::sender() == buttonBrowseOutput)
	{
		QString filters;
		filters += tr("Matroska Files (*.mkv)").append(";;");
		filters += tr("MPEG-4 Part 14 Container (*.mp4)").append(";;");
		filters += tr("H.264 Elementary Stream (*.264)");

		QString filePath = QFileDialog::getSaveFileName(this, tr("Choose Output File"), VALID_DIR(initialDir_out) ? initialDir_out : QDesktopServices::storageLocation(QDesktopServices::MoviesLocation), filters, NULL, QFileDialog::DontUseNativeDialog | QFileDialog::DontConfirmOverwrite);

		if(!(filePath.isNull() || filePath.isEmpty()))
		{
			QString suffix = QFileInfo(filePath).suffix();
			if(suffix.compare("mkv", Qt::CaseInsensitive) && suffix.compare("mp4", Qt::CaseInsensitive) && suffix.compare("264", Qt::CaseInsensitive))
			{
				filePath = QString("%1.mkv").arg(filePath);
			}
			editOutput->setText(QDir::toNativeSeparators(filePath));
			initialDir_out = QFileInfo(filePath).path();
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

	OptionsModel *options = new OptionsModel();
	saveOptions(options);

	if(options->equals(m_defaults))
	{
		QMessageBox::warning (this, tr("Default"), tr("It makes no sense to save the defaults!"));
		cbxTemplate->blockSignals(true);
		cbxTemplate->setCurrentIndex(0);
		cbxTemplate->blockSignals(false);
		REMOVE_USAFED_ITEM;
		X264_DELETE(options);
		return;
	}

	for(int i = 0; i < cbxTemplate->count(); i++)
	{
		OptionsModel* test = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(i).value<void*>());
		if(test != NULL)
		{
			if(options->equals(test))
			{
				QMessageBox::warning (this, tr("Oups"), tr("<nobr>There already is a template for the current settings!"));
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
		name = QInputDialog::getText(this, tr("Save Template"), tr("Please enter the name of the template:").leftJustified(160, ' '), QLineEdit::Normal, name, &ok).simplified();
		if(!ok)
		{
			X264_DELETE(options);
			return;
		}
		if(name.contains('<') || name.contains('>') || name.contains('\\') || name.contains('/') || name.contains('"'))
		{
			QMessageBox::warning (this, tr("Invalid Name"), tr("Sorry, the name you have entered is invalid!"));
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
			QMessageBox::warning (this, tr("Already Exists"), tr("Sorry, a template of that name already exists!"));
			continue;
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
	cbxTemplate->insertItem(index, name, QVariant::fromValue<void*>(options));
	cbxTemplate->setCurrentIndex(index);
	cbxTemplate->blockSignals(false);

	REMOVE_USAFED_ITEM;
}

void AddJobDialog::deleteTemplateButtonClicked(void)
{
	const int index = cbxTemplate->currentIndex();
	QString name = cbxTemplate->itemText(index);

	if(name.contains('<') || name.contains('>'))
	{
		QMessageBox::warning (this, tr("Invalid Item"), tr("Sorry, the selected item cannot be deleted!"));
		return;
	}

	OptionsModel::deleteTemplate(name);
	OptionsModel *item = reinterpret_cast<OptionsModel*>(cbxTemplate->itemData(index).value<void*>());
	cbxTemplate->removeItem(index);
	X264_DELETE(item);
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
	editCustomParams->blockSignals(true);

	cbxRateControlMode->setCurrentIndex(options->rcMode());
	spinQuantizer->setValue(options->quantizer());
	spinBitrate->setValue(options->bitrate());
	updateComboBox(cbxPreset, options->preset());
	updateComboBox(cbxTuning, options->tune());
	updateComboBox(cbxProfile, options->profile());
	editCustomParams->setText(options->custom());

	cbxRateControlMode->blockSignals(false);
	spinQuantizer->blockSignals(false);
	spinBitrate->blockSignals(false);
	cbxPreset->blockSignals(false);
	cbxTuning->blockSignals(false);
	cbxProfile->blockSignals(false);
	editCustomParams->blockSignals(false);
}

void AddJobDialog::saveOptions(OptionsModel *options)
{
	options->setRCMode(static_cast<OptionsModel::RCMode>(cbxRateControlMode->currentIndex()));
	options->setQuantizer(spinQuantizer->value());
	options->setBitrate(spinBitrate->value());
	options->setPreset(cbxPreset->model()->data(cbxPreset->model()->index(cbxPreset->currentIndex(), 0)).toString());
	options->setTune(cbxTuning->model()->data(cbxTuning->model()->index(cbxTuning->currentIndex(), 0)).toString());
	options->setProfile(cbxProfile->model()->data(cbxProfile->model()->index(cbxProfile->currentIndex(), 0)).toString());
	options->setCustom(editCustomParams->text().simplified());
}

QString AddJobDialog::makeFileFilter(void)
{
	QString filters("All supported files (");

	for(size_t index = 0; g_filters[index].name && g_filters[index].fext; index++)
	{
		filters += QString((index > 0) ? " *.%1" : "*.%1").arg(QString::fromLatin1(g_filters[index].fext));
	}

	filters += QString(");;");

	for(size_t index = 0; g_filters[index].name && g_filters[index].fext; index++)
	{
		filters += QString("%1 (*.%2);;").arg(QString::fromLatin1(g_filters[index].name), QString::fromLatin1(g_filters[index].fext));
	}
		
	filters += QString("All files (*.*)");
	return filters;
}

void AddJobDialog::generateOutputFileName(const QString &filePath)
{
	QString name = QFileInfo(filePath).completeBaseName();
	QString path = VALID_DIR(initialDir_out) ? initialDir_out : QFileInfo(filePath).path();
			
	QString outPath = QString("%1/%2.mkv").arg(path, name);

	if(QFileInfo(outPath).exists())
	{
		int i = 2;
		while(QFileInfo(outPath).exists())
		{
			outPath = QString("%1/%2 (%3).mkv").arg(path, name, QString::number(i++));
		}
	}

	editOutput->setText(QDir::toNativeSeparators(outPath));
}
