///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2010 LoRd_MuldeR <MuldeR2@GMX.de>
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

//Qt includes
#include <QMessageBox>
#include <QTimer>
#include <QDesktopWidget>
#include <QDate>
#include <QFileDialog>
#include <QInputDialog>

//Win32 includes
#include <Windows.h>

////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////

MainWindow::MainWindow(QWidget *parent)
: QMainWindow(parent)
{
	//Init the dialog, from the .ui file
	setupUi(this);
	
	//Update window title
	if(lamexp_version_demo())
	{
		setWindowTitle(windowTitle().append(" [DEMO VERSION]"));
	}

	//Enabled main buttons
	connect(buttonAbout, SIGNAL(clicked()), this, SLOT(aboutButtonClicked()));
	connect(buttonStart, SIGNAL(clicked()), this, SLOT(encodeButtonClicked()));

	//Setup tab widget
	tabWidget->setCurrentIndex(0);
	connect(tabWidget, SIGNAL(currentChanged(int)), this, SLOT(tabPageChanged(int)));
	tabPageChanged(tabWidget->currentIndex());

	//Setup "Source" tab
	sourceFileView->setModel(&m_fileListModel);
	sourceFileView->verticalHeader()->setResizeMode(QHeaderView::ResizeToContents);
	sourceFileView->horizontalHeader()->setResizeMode(QHeaderView::ResizeToContents);
	connect(buttonAddFiles, SIGNAL(clicked()), this, SLOT(addFilesButtonClicked()));
	connect(buttonRemoveFile, SIGNAL(clicked()), this, SLOT(removeFileButtonClicked()));
	connect(buttonClearFiles, SIGNAL(clicked()), this, SLOT(clearFilesButtonClicked()));
	connect(buttonFileUp, SIGNAL(clicked()), this, SLOT(fileUpButtonClicked()));
	connect(buttonFileDown, SIGNAL(clicked()), this, SLOT(fileDownButtonClicked()));
	connect(buttonEditMeta, SIGNAL(clicked()), this, SLOT(editMetaButtonClicked()));
	
	//Activate view actions
	connect(actionSourceFiles, SIGNAL(triggered()), this, SLOT(tabActionActivated()));
	connect(actionOutputDirectory, SIGNAL(triggered()), this, SLOT(tabActionActivated()));
	connect(actionCompression, SIGNAL(triggered()), this, SLOT(tabActionActivated()));
	connect(actionMetaData, SIGNAL(triggered()), this, SLOT(tabActionActivated()));
	connect(actionAdvancedOptions, SIGNAL(triggered()), this, SLOT(tabActionActivated()));

	//Center window in screen
	QRect desktopRect = QApplication::desktop()->screenGeometry();
	QRect thisRect = this->geometry();
	move((desktopRect.width() - thisRect.width()) / 2, (desktopRect.height() - thisRect.height()) / 2);
	setMinimumSize(thisRect.width(), thisRect.height());
}

////////////////////////////////////////////////////////////
// Destructor
////////////////////////////////////////////////////////////

MainWindow::~MainWindow(void)
{
}

////////////////////////////////////////////////////////////
// PUBLIC FUNCTIONS
////////////////////////////////////////////////////////////

/*NONE*/

////////////////////////////////////////////////////////////
// Slots
////////////////////////////////////////////////////////////

/*
 * About button
 */
void MainWindow::aboutButtonClicked(void)
{
	QString aboutText;
	
	aboutText += "<b><font size=\"+1\">LameXP - Audio Encoder Front-end</font></b><br>";
	aboutText += "Copyright (C) 2004-2010 LoRd_MuldeR <a href=\"mailto:mulder2@gmx.de\">&lt;MuldeR2@GMX.de&gt;</a><br>";
	aboutText += QString().sprintf("Version %d.%02d %s, Build %d [%s]<br><br>", lamexp_version_major(), lamexp_version_minor(), lamexp_version_release(), lamexp_version_build(), lamexp_version_date().toString(Qt::ISODate).toLatin1().constData());
	aboutText += "Please visit <a href=\"http://mulder.dummwiedeutsch.de/\">http://mulder.dummwiedeutsch.de/</a> for news and updates!<br><hr><br>";
	aboutText += "This program is free software; you can redistribute it and/or<br>";
	aboutText += "modify it under the terms of the GNU General Public License<br>";
	aboutText += "as published by the Free Software Foundation; either version 2<br>";
	aboutText += "of the License, or (at your option) any later version.<br><br>";
	aboutText += "This program is distributed in the hope that it will be useful,<br>";
	aboutText += "but WITHOUT ANY WARRANTY; without even the implied warranty of<br>";
	aboutText += "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the<br>";
	aboutText += "GNU General Public License for more details.<br><br>";
	aboutText += "You should have received a copy of the GNU General Public License<br>";
	aboutText += "along with this program; if not, write to the Free Software<br>";
	aboutText += "Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.<br><hr><br>";
	aboutText += "This software uses the 'slick' icon set by <a href=\"http://www.famfamfam.com/lab/icons/silk/\">http://www.famfamfam.com/</a>.<br>";
	aboutText += "Released under the Creative Commons Attribution 2.5 License.<br>";
	
	QApplication::setOverrideCursor(QCursor(Qt::WaitCursor));
	PlaySound(MAKEINTRESOURCE(IDR_WAVE_ABOUT), GetModuleHandle(NULL), SND_RESOURCE | SND_SYNC);
	QApplication::restoreOverrideCursor();

	while(1)
	{
		switch(QMessageBox::information(this, "About LameXP", aboutText, " More about... ", " About Qt... ", " Discard "))
		{
		case 0:
			{
				QString moreAboutText;
				moreAboutText += "The following third-party software is used in LameXP:<br><br>";
				moreAboutText += "<b>LAME - OpenSource mp3 Encoder</b><br>Released under the terms of the GNU Leser General Public License.<br><a href=\"http://lame.sourceforge.net/\">http://lame.sourceforge.net/</a><br><br>";
				moreAboutText += "<b>OggEnc - Ogg Vorbis Encoder</b><br>Completely open and patent-free audio encoding technology.<br><a href=\"http://www.vorbis.com/\">http://www.vorbis.com/</a><br><br>";
				moreAboutText += "<b>Nero AAC reference MPEG-4 Encoder</b><br>Freeware state-of-the-art HE-AAC encoder with 2-Pass support.<br><a href=\"http://www.nero.com/eng/technologies-aac-codec.html\">http://www.nero.com/eng/technologies-aac-codec.html</a><br>";
				QMessageBox::information(this, "About third-party tools", moreAboutText, "Discard");
				break;
			}
		case 1:
			QMessageBox::aboutQt(this);
			break;
		default:
			return;
		}
	}
}

/*
 * Encode button
 */
void MainWindow::encodeButtonClicked(void)
{
	QMessageBox::warning(this, "LameXP", "Not implemented yet, please try again with a later version!");
}

/*
 * Add file(s) button
 */
void MainWindow::addFilesButtonClicked(void)
{
	tabWidget->setCurrentIndex(0);
	QStringList selectedFiles = QFileDialog::getOpenFileNames(this, "Add file(s)", QString(), "All supported files (*.*)");

	QApplication::setOverrideCursor(QCursor(Qt::WaitCursor));
	selectedFiles.sort();

	while(!selectedFiles.isEmpty())
	{
		QString currentFile = selectedFiles.takeFirst();
		qDebug("Adding: %s\n", currentFile.toLatin1().constData());
		m_fileListModel.addFile(currentFile);
		sourceFileView->scrollToBottom();
	}

	qDebug("All files added.\n\n");
	QApplication::restoreOverrideCursor();
}

/*
 * Remove file button
 */
void MainWindow::removeFileButtonClicked(void)
{
	if(sourceFileView->currentIndex().isValid())
	{
		int iRow = sourceFileView->currentIndex().row();
		m_fileListModel.removeFile(sourceFileView->currentIndex());
		sourceFileView->selectRow(iRow < m_fileListModel.rowCount() ? iRow : m_fileListModel.rowCount()-1);
	}
}

/*
 * Clear files button
 */
void MainWindow::clearFilesButtonClicked(void)
{
	m_fileListModel.clearFiles();
}

/*
 * Move file up button
 */
void MainWindow::fileUpButtonClicked(void)
{
	if(sourceFileView->currentIndex().isValid())
	{
		int iRow = sourceFileView->currentIndex().row() - 1;
		m_fileListModel.moveFile(sourceFileView->currentIndex(), -1);
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
		m_fileListModel.moveFile(sourceFileView->currentIndex(), 1);
		sourceFileView->selectRow(iRow < m_fileListModel.rowCount() ? iRow : m_fileListModel.rowCount()-1);
	}
}

/*
 * Edit meta button
 */
void MainWindow::editMetaButtonClicked(void)
{
	if(sourceFileView->currentIndex().isValid())
	{
		AudioFileModel file = m_fileListModel.getFile(sourceFileView->currentIndex());
		bool bApplied = false;
		QString text = QInputDialog::getText(this, "Edit title", "Enter the new title:", QLineEdit::Normal, file.fileName(), &bApplied, Qt::WindowStaysOnTopHint);
		
		if(bApplied)
		{
			file.setFileName(text);
			m_fileListModel.setFile(sourceFileView->currentIndex(), file);
		}
	}
}

/*
 * Tab page changed
 */
void MainWindow::tabPageChanged(int idx)
{
	actionSourceFiles->setChecked(idx == 0);
	actionOutputDirectory->setChecked(idx == 1);
	actionCompression->setChecked(idx == 2);
	actionMetaData->setChecked(idx == 3);
	actionAdvancedOptions->setChecked(idx == 4);
}

/*
 * Tab action triggered
 */
void MainWindow::tabActionActivated()
{
	QAction *poSender = NULL;
	LAMEXP_DYNCAST(poSender, QAction*, sender());

	if(poSender)
	{
		int idx = -1;

		if(actionSourceFiles == poSender) idx = 0;
		if(actionOutputDirectory == poSender) idx = 1;
		if(actionCompression == poSender) idx = 2;
		if(actionMetaData == poSender) idx = 3;
		if(actionAdvancedOptions == poSender) idx = 4;

		if(idx >= 0)
		{
			tabWidget->setCurrentIndex(idx);
		}
	}
}
