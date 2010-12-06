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

#include "Dialog_Update.h"

#include "Global.h"
#include "Resource.h"
#include "Dialog_LogView.h"
#include "Model_Settings.h"

#include <QClipboard>
#include <QFileDialog>
#include <QTimer>
#include <QProcess>
#include <QUuid>
#include <QDate>
#include <QRegExp>
#include <QDesktopServices>
#include <QUrl>
#include <QCloseEvent>

#include <Windows.h>

///////////////////////////////////////////////////////////////////////////////

static const char *section_id = "LameXP";

static const char *mirror_url_postfix = "update_beta.ver";

static const char *mirrors[] =
{
	"http://mulder.dummwiedeutsch.de/",
	"http://mulder.brhack.net/",
	"http://free.pages.at/borschdfresser/",
	"http://mplayer.savedonthe.net/",
	"http://www.tricksoft.de/",
	NULL
};

///////////////////////////////////////////////////////////////////////////////

class UpdateInfo
{
public:
	UpdateInfo(void)
	:
		m_buildNo(0),
		m_buildDate(1900, 1, 1),
		m_downloadSite(""),
		m_downloadAddress(""),
		m_downloadFilename(""),
		m_downloadFilecode("")
	{
	}
	
	unsigned int m_buildNo;
	QDate m_buildDate;
	QString m_downloadSite;
	QString m_downloadAddress;
	QString m_downloadFilename;
	QString m_downloadFilecode;
};

///////////////////////////////////////////////////////////////////////////////

UpdateDialog::UpdateDialog(SettingsModel *settings, QWidget *parent)
:
	QDialog(parent),
	m_binaryWGet(lamexp_lookup_tool("wget.exe")),
	m_binaryGnuPG(lamexp_lookup_tool("gpgv.exe")),
	m_binaryUpdater(lamexp_lookup_tool("wupdate.exe")),
	m_binaryKeys(lamexp_lookup_tool("gpgv.gpg")),
	m_updateInfo(NULL),
	m_settings(settings),
	m_logFile(new QStringList()),
	m_success(false)
{
	if(m_binaryWGet.isEmpty() || m_binaryGnuPG.isEmpty() || m_binaryUpdater.isEmpty() || m_binaryKeys.isEmpty())
	{
		throw "Tools not initialized correctly!";
	}
	
	//Init the dialog, from the .ui file
	setupUi(this);
	setWindowFlags(windowFlags() ^ Qt::WindowContextHelpButtonHint);

	//Disable "X" button
	HMENU hMenu = GetSystemMenu((HWND) winId(), FALSE);
	EnableMenuItem(hMenu, SC_CLOSE, MF_BYCOMMAND | MF_GRAYED);

	//Enable button
	connect(retryButton, SIGNAL(clicked()), this, SLOT(checkForUpdates()));
	connect(installButton, SIGNAL(clicked()), this, SLOT(applyUpdate()));
	connect(infoLabel, SIGNAL(linkActivated(QString)), this, SLOT(linkActivated(QString)));
	connect(logButton, SIGNAL(clicked()), this, SLOT(logButtonClicked()));
}

UpdateDialog::~UpdateDialog(void)
{
	LAMEXP_DELETE(m_updateInfo);
	LAMEXP_DELETE(m_logFile);
}

void UpdateDialog::showEvent(QShowEvent *event)
{
	QDialog::showEvent(event);
	
	statusLabel->setText("Checking for new updates online, please wait...");
	labelVersionInstalled->setText(QString("Build %1 (%2)").arg(QString::number(lamexp_version_build()), lamexp_version_date().toString(Qt::ISODate)));
	labelVersionLatest->setText("(Unknown)");

	QTimer::singleShot(0, this, SLOT(updateInit()));
	installButton->setEnabled(false);
	closeButton->setEnabled(false);
	retryButton->setEnabled(false);
	logButton->setEnabled(false);
	retryButton->hide();
	logButton->hide();
	infoLabel->hide();
	
	for(int i = 0; mirrors[i]; i++)
	{
		progressBar->setMaximum(i+2);
	}

	progressBar->setValue(0);
}

void UpdateDialog::closeEvent(QCloseEvent *event)
{
	if(!closeButton->isEnabled()) event->ignore();
}

void UpdateDialog::updateInit(void)
{
	setMinimumSize(size());
	setMaximumHeight(height());

	checkForUpdates();
}

void UpdateDialog::checkForUpdates(void)
{
	bool success = false;
	m_updateInfo = new UpdateInfo;

	progressBar->setValue(0);
	installButton->setEnabled(false);
	closeButton->setEnabled(false);
	retryButton->setEnabled(false);
	logButton->setEnabled(false);
	if(infoLabel->isVisible()) infoLabel->hide();

	QApplication::processEvents();
	QApplication::setOverrideCursor(Qt::WaitCursor);

	m_logFile->clear();
	m_logFile->append("Checking for updates online...");
	
	for(int i = 0; mirrors[i]; i++)
	{
		progressBar->setValue(i+1);
		if(tryUpdateMirror(m_updateInfo, mirrors[i]))
		{
			success = true;
			break;
		}
	}
	
	QApplication::restoreOverrideCursor();

	if(!success)
	{
		if(!retryButton->isVisible()) retryButton->show();
		if(!logButton->isVisible()) logButton->show();
		closeButton->setEnabled(true);
		retryButton->setEnabled(true);
		logButton->setEnabled(true);
		statusLabel->setText("Failed to fetch update information. Check your internet connection!");
		progressBar->setValue(progressBar->maximum());
		LAMEXP_DELETE(m_updateInfo);
		if(m_settings->soundsEnabled()) PlaySound(MAKEINTRESOURCE(IDR_WAVE_ERROR), GetModuleHandle(NULL), SND_RESOURCE | SND_ASYNC);
		return;
	}

	labelVersionLatest->setText(QString("Build %1 (%2)").arg(QString::number(m_updateInfo->m_buildNo), m_updateInfo->m_buildDate.toString(Qt::ISODate)));
	infoLabel->show();
	infoLabel->setText(QString("More information available at:<br><a href=\"%1\">%1</a>").arg(m_updateInfo->m_downloadSite));
	QApplication::processEvents();
	
	if(m_updateInfo->m_buildNo > lamexp_version_build())
	{
		installButton->setEnabled(true);
		statusLabel->setText("A new version of LameXP is available. Update highly recommended!");
		MessageBeep(MB_ICONINFORMATION);
	}
	else if(m_updateInfo->m_buildNo == lamexp_version_build())
	{
		statusLabel->setText("No new updates avialbale. Your version of LameXP is up-to-date.");
		MessageBeep(MB_ICONINFORMATION);
	}
	else
	{
		statusLabel->setText("Your version appears to be newer than the latest release.");
		MessageBeep(MB_ICONEXCLAMATION);
	}

	closeButton->setEnabled(true);
	if(retryButton->isVisible()) retryButton->hide();
	if(logButton->isVisible()) logButton->hide();
	progressBar->setValue(progressBar->maximum());

	m_success = true;
}

bool UpdateDialog::tryUpdateMirror(UpdateInfo *updateInfo, const QString &url)
{
	bool success = false;
	m_logFile->append(QStringList() << "" << "Trying mirror:" << url);
	
	QUuid uuid = QUuid::createUuid();
	QString outFileVersionInfo = QString("%1/%2.ver").arg(QDir::tempPath(), uuid.toString());
	QString outFileSignature = QString("%1/%2.sig").arg(QDir::tempPath(), uuid.toString());

	m_logFile->append(QStringList() << "" << "Downloading update info:");
	bool ok1 = getFile(QString("%1%2").arg(url,mirror_url_postfix), outFileVersionInfo);

	m_logFile->append(QStringList() << "" << "Downloading signature:");
	bool ok2 = getFile(QString("%1%2.sig").arg(url,mirror_url_postfix), outFileSignature);

	if(ok1 && ok2)
	{
		m_logFile->append(QStringList() << "" << "Download okay, checking signature:");
		if(checkSignature(outFileVersionInfo, outFileSignature))
		{
			m_logFile->append(QStringList() << "" << "Signature okay, parsing info:");
			success = parseVersionInfo(outFileVersionInfo, updateInfo);
		}
		else
		{
			m_logFile->append(QStringList() << "" << "Bad signature, take care!");
		}
	}
	else
	{
		m_logFile->append(QStringList() << "" << "Download has failed!");
	}

	QFile::remove(outFileVersionInfo);
	QFile::remove(outFileSignature);
	
	return success;
}

bool UpdateDialog::getFile(const QString &url, const QString &outFile)
{
	QFileInfo output(outFile);
	output.setCaching(false);

	if(output.exists())
	{
		QFile::remove(output.canonicalFilePath());
		if(output.exists())
		{
			return false;
		}
	}

	QProcess process;
	process.setProcessChannelMode(QProcess::MergedChannels);
	process.setReadChannel(QProcess::StandardOutput);

	QEventLoop loop;
	connect(&process, SIGNAL(error(QProcess::ProcessError)), &loop, SLOT(quit()));
	connect(&process, SIGNAL(finished(int,QProcess::ExitStatus)), &loop, SLOT(quit()));
	connect(&process, SIGNAL(readyRead()), &loop, SLOT(quit()));

	process.start(m_binaryWGet, QStringList() << "-O" << output.absoluteFilePath() << url);
	
	if(!process.waitForStarted())
	{
		return false;
	}

	while(process.state() == QProcess::Running)
	{
		loop.exec();
		while(process.canReadLine())
		{
			m_logFile->append(QString::fromLatin1(process.readLine()).simplified());
		}
	}
	
	m_logFile->append(QString().sprintf("Exited with code %d", process.exitCode()));
	return (process.exitCode() == 0) && output.exists() && output.isFile();
}

bool UpdateDialog::checkSignature(const QString &file, const QString &signature)
{
	QProcess process;
	process.setProcessChannelMode(QProcess::MergedChannels);
	process.setReadChannel(QProcess::StandardOutput);

	QEventLoop loop;
	connect(&process, SIGNAL(error(QProcess::ProcessError)), &loop, SLOT(quit()));
	connect(&process, SIGNAL(finished(int,QProcess::ExitStatus)), &loop, SLOT(quit()));
	connect(&process, SIGNAL(readyRead()), &loop, SLOT(quit()));
	
	process.start(m_binaryGnuPG, QStringList() << "--homedir" << lamexp_temp_folder() << "--keyring" << QDir::toNativeSeparators(m_binaryKeys) << QDir::toNativeSeparators(signature) << QDir::toNativeSeparators(file));

	if(!process.waitForStarted())
	{
		return false;
	}

	while(process.state() == QProcess::Running)
	{
		loop.exec();
		while(process.canReadLine())
		{
			m_logFile->append(QString::fromLatin1(process.readLine()).simplified());
		}
	}
	
	m_logFile->append(QString().sprintf("Exited with code %d", process.exitCode()));
	return (process.exitCode() == 0);
}

bool UpdateDialog::parseVersionInfo(const QString &file, UpdateInfo *updateInfo)
{
	
	QRegExp value("^(\\w+)=(.+)$");
	QRegExp section("^\\[(.+)\\]$");

	QFile data(file);
	if(!data.open(QIODevice::ReadOnly))
	{
		qWarning("Cannot open update info file for reading!");
		return false;
	}
	
	bool inSection = false;
	
	while(!data.atEnd())
	{
		QString line = QString::fromLatin1(data.readLine()).trimmed();
		if(section.indexIn(line) >= 0)
		{
			m_logFile->append(QString("[%1]").arg(section.cap(1)));
			inSection = (section.cap(1).compare(section_id, Qt::CaseInsensitive) == 0);
			continue;
		}
		if(inSection && value.indexIn(line) >= 0)
		{
			m_logFile->append(QString("'%1' ==> '%2").arg(value.cap(1), value.cap(2)));
			if(value.cap(1).compare("BuildNo", Qt::CaseInsensitive) == 0)
			{
				bool ok = false;
				unsigned int temp = value.cap(2).toUInt(&ok);
				if(ok) updateInfo->m_buildNo = temp;
			}
			else if(value.cap(1).compare("BuildDate", Qt::CaseInsensitive) == 0)
			{
				QDate temp = QDate::fromString(value.cap(2).trimmed(), Qt::ISODate);
				if(temp.isValid()) updateInfo->m_buildDate = temp;
			}
			else if(value.cap(1).compare("DownloadSite", Qt::CaseInsensitive) == 0)
			{
				updateInfo->m_downloadSite = value.cap(2).trimmed();
			}
			else if(value.cap(1).compare("DownloadAddress", Qt::CaseInsensitive) == 0)
			{
				updateInfo->m_downloadAddress = value.cap(2).trimmed();
			}
			else if(value.cap(1).compare("DownloadFilename", Qt::CaseInsensitive) == 0)
			{
				updateInfo->m_downloadFilename = value.cap(2).trimmed();
			}
			else if(value.cap(1).compare("DownloadFilecode", Qt::CaseInsensitive) == 0)
			{
				updateInfo->m_downloadFilecode = value.cap(2).trimmed();
			}
		}
	}
	
	bool complete = true;

	if(!(updateInfo->m_buildNo > 0)) complete = false;
	if(!(updateInfo->m_buildDate.year() >= 2010)) complete = false;
	if(updateInfo->m_downloadSite.isEmpty()) complete = false;
	if(updateInfo->m_downloadAddress.isEmpty()) complete = false;
	if(updateInfo->m_downloadFilename.isEmpty()) complete = false;
	if(updateInfo->m_downloadFilecode.isEmpty()) complete = false;

	return complete;
}

void UpdateDialog::linkActivated(const QString &link)
{
	QDesktopServices::openUrl(QUrl(link));
}

void UpdateDialog::applyUpdate(void)
{
	installButton->setEnabled(false);
	closeButton->setEnabled(false);
	retryButton->setEnabled(false);

	if(m_updateInfo)
	{
		statusLabel->setText("Update is being downloaded, please be patient...");
		QApplication::processEvents();
		
		QProcess process;
		QStringList args;
		QEventLoop loop;

		connect(&process, SIGNAL(error(QProcess::ProcessError)), &loop, SLOT(quit()));
		connect(&process, SIGNAL(finished(int,QProcess::ExitStatus)), &loop, SLOT(quit()));

		args << QString("/Location=%1").arg(m_updateInfo->m_downloadAddress);
		args << QString("/Filename=%1").arg(m_updateInfo->m_downloadFilename);
		args << QString("/TicketID=%1").arg(m_updateInfo->m_downloadFilecode);
		args << QString("/ToFolder=%1").arg(QDir::toNativeSeparators(QApplication::applicationDirPath()));
		args << QString("/AppTitle=LameXP (Build #%1)").arg(QString::number(m_updateInfo->m_buildNo));

		QApplication::setOverrideCursor(Qt::WaitCursor);
		process.start(m_binaryUpdater, args);
		loop.exec();
		QApplication::restoreOverrideCursor();
		
		if(process.exitCode() == 0)
		{
			statusLabel->setText("Update ready to install. Applicaion will quit...");
			QApplication::quit();
			accept();
		}
		else
		{
			statusLabel->setText("Update failed. Please try again or download manually!");
		}
	}

	installButton->setEnabled(true);
	closeButton->setEnabled(true);
}

void UpdateDialog::logButtonClicked(void)
{
	LogViewDialog *logView = new LogViewDialog(this);
	logView->exec(*m_logFile);
	LAMEXP_DELETE(logView);
}
