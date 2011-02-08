///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2011 LoRd_MuldeR <MuldeR2@GMX.de>
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

#include "Model_Settings.h"

#include "Global.h"

#include <QSettings>
#include <QDesktopServices>
#include <QApplication>
#include <QString>
#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QLocale>

//Constants
static const char *g_settingsId_versionNumber = "VersionNumber";
static const char *g_settingsId_licenseAccepted = "LicenseAccepted";
static const char *g_settingsId_interfaceStyle = "InterfaceStyle";
static const char *g_settingsId_compressionEncoder = "Compression/Encoder";
static const char *g_settingsId_compressionRCMode = "Compression/RCMode";
static const char *g_settingsId_compressionBitrate = "Compression/Bitrate";
static const char *g_settingsId_outputDir = "OutputDirectory/SelectedPath";
static const char *g_settingsId_outputToSourceDir = "OutputDirectory/OutputToSourceFolder";
static const char *g_settingsId_prependRelativeSourcePath = "OutputDirectory/PrependRelativeSourcePath";
static const char *g_settingsId_writeMetaTags = "Flags/WriteMetaTags";
static const char *g_settingsId_createPlaylist = "Flags/AutoCreatePlaylist";
static const char *g_settingsId_autoUpdateLastCheck = "AutoUpdate/LastCheck";
static const char *g_settingsId_autoUpdateEnabled = "AutoUpdate/Enabled";
static const char *g_settingsId_soundsEnabled = "Flags/EnableSounds";
static const char *g_settingsId_neroAacNotificationsEnabled = "Flags/EnableNeroAacNotifications";
static const char *g_settingsId_wmaDecoderNotificationsEnabled = "Flags/EnableWmaDecoderNotifications";
static const char *g_settingsId_dropBoxWidgetEnabled = "Flags/EnableDropBoxWidget";
static const char *g_settingsId_shellIntegrationEnabled = "Flags/EnableShellIntegration";
static const char *g_settingsId_currentLanguage = "Localization/Language";
static const char *g_settingsId_lameAlgoQuality = "AdvancedOptions/LAME/AlgorithmQuality";
static const char *g_settingsId_lameChannelMode = "AdvancedOptions/LAME/ChannelMode";
static const char *g_settingsId_bitrateManagementEnabled = "AdvancedOptions/BitrateManagement/Enabled";
static const char *g_settingsId_bitrateManagementMinRate = "AdvancedOptions/BitrateManagement/MinRate";
static const char *g_settingsId_bitrateManagementMaxRate = "AdvancedOptions/BitrateManagement/MaxRate";
static const char *g_settingsId_samplingRate = "AdvancedOptions/Common/Resampling";
static const char *g_settingsId_neroAACEnable2Pass = "AdvancedOptions/NeroAAC/Enable2Pass";
static const char *g_settingsId_neroAACProfile = "AdvancedOptions/NeroAAC/ForceProfile";
static const char *g_settingsId_normalizationFilterEnabled = "AdvancedOptions/VolumeNormalization/Enabled";
static const char *g_settingsId_normalizationFilterMaxVolume = "AdvancedOptions/VolumeNormalization/MaxVolume";
static const char *g_settingsId_toneAdjustBass = "AdvancedOptions/ToneAdjustment/Bass";
static const char *g_settingsId_toneAdjustTreble = "AdvancedOptions/ToneAdjustment/Treble";

//Macros
#define MAKE_OPTION1(OPT,DEF) \
int SettingsModel::OPT(void) { return m_settings->value(g_settingsId_##OPT, DEF).toInt(); } \
void SettingsModel::OPT(int value) { m_settings->setValue(g_settingsId_##OPT, value); } \
int SettingsModel::OPT##Default(void) { return DEF; }

#define MAKE_OPTION2(OPT,DEF) \
QString SettingsModel::OPT(void) { return m_settings->value(g_settingsId_##OPT, DEF).toString().trimmed(); } \
void SettingsModel::OPT(const QString &value) { m_settings->setValue(g_settingsId_##OPT, value); } \
QString SettingsModel::OPT##Default(void) { return DEF; }

#define MAKE_OPTION3(OPT,DEF) \
bool SettingsModel::OPT(void) { return m_settings->value(g_settingsId_##OPT, DEF).toBool(); } \
void SettingsModel::OPT(bool value) { m_settings->setValue(g_settingsId_##OPT, value); } \
bool SettingsModel::OPT##Default(void) { return DEF; }

//LUT
const int SettingsModel::mp3Bitrates[15] = {32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, -1};
const int SettingsModel::samplingRates[8] = {0, 16000, 22050, 24000, 32000, 44100, 48000, -1};

////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////

SettingsModel::SettingsModel(void)
:
	m_defaultLanguage(NULL)
{
	QString configPath;
	
	if(!lamexp_portable_mode())
	{
		QString dataPath = QDir(QDesktopServices::storageLocation(QDesktopServices::DataLocation)).canonicalPath();
		if(dataPath.isEmpty()) dataPath = QDesktopServices::storageLocation(QDesktopServices::DataLocation);
		QDir(dataPath).mkpath(".");
		configPath = QString("%1/config.ini").arg(dataPath);
	}
	else
	{
		qDebug("LameXP is running in \"portable\" mode -> config in application dir!\n");
		QString appPath = QFileInfo(QApplication::applicationFilePath()).canonicalFilePath();
		if(appPath.isEmpty()) appPath = QApplication::applicationFilePath();
		configPath = QString("%1/%2.ini").arg(QFileInfo(appPath).absolutePath(), QFileInfo(appPath).completeBaseName());
	}

	m_settings = new QSettings(configPath, QSettings::IniFormat);
	m_settings->beginGroup(QString().sprintf("LameXP_%u%02u%05u", lamexp_version_major(), lamexp_version_minor(), lamexp_version_build()));
	m_settings->setValue(g_settingsId_versionNumber, QApplication::applicationVersion());
	m_settings->sync();
}

////////////////////////////////////////////////////////////
// Destructor
////////////////////////////////////////////////////////////

SettingsModel::~SettingsModel(void)
{
	LAMEXP_DELETE(m_settings);
	LAMEXP_DELETE(m_defaultLanguage);
}

////////////////////////////////////////////////////////////
// Public Functions
////////////////////////////////////////////////////////////

void SettingsModel::validate(void)
{
	if(this->compressionEncoder() < SettingsModel::MP3Encoder || this->compressionEncoder() > SettingsModel::PCMEncoder)
	{
		this->compressionEncoder(SettingsModel::MP3Encoder);
	}
	
	if(this->compressionRCMode() < SettingsModel::VBRMode || this->compressionRCMode() > SettingsModel::CBRMode)
	{
		this->compressionEncoder(SettingsModel::VBRMode);
	}
	
	if(!(lamexp_check_tool("neroAacEnc.exe") && lamexp_check_tool("neroAacDec.exe") && lamexp_check_tool("neroAacTag.exe")))
	{
		if(this->compressionEncoder() == SettingsModel::AACEncoder)
		{
			qWarning("Nero encoder selected, but not available any more. Reverting to MP3!");
			this->compressionEncoder(SettingsModel::MP3Encoder);
		}
	}
	
	if(this->outputDir().isEmpty() || !QFileInfo(this->outputDir()).isDir())
	{
		this->outputDir(QDesktopServices::storageLocation(QDesktopServices::MusicLocation));
	}

	if(!lamexp_query_translations().contains(this->currentLanguage(), Qt::CaseInsensitive))
	{
		qWarning("Current language \"%s\" is unknown, reverting to default language!", this->currentLanguage().toLatin1().constData());
			this->currentLanguage(defaultLanguage());
	}
}

////////////////////////////////////////////////////////////
// Private Functions
////////////////////////////////////////////////////////////

QString SettingsModel::defaultLanguage(void)
{
	if(m_defaultLanguage)
	{
		return *m_defaultLanguage;
	}
	
	//Check if we can use the default translation
	QLocale systemLanguage= QLocale::system();
	if(systemLanguage.language() == QLocale::English || systemLanguage.language() == QLocale::C)
	{
		m_defaultLanguage = new QString(LAMEXP_DEFAULT_LANGID);
		return LAMEXP_DEFAULT_LANGID;
	}

	//Try to find a suitable translation for the user's system language
	QStringList languages = lamexp_query_translations();
	while(!languages.isEmpty())
	{
		QString currentLangId = languages.takeFirst();
		if(lamexp_translation_sysid(currentLangId) == systemLanguage.language())
		{
			m_defaultLanguage = new QString(currentLangId);
			return currentLangId;
		}
	}

	//Fall back to the default translation
	m_defaultLanguage = new QString(LAMEXP_DEFAULT_LANGID);
	return LAMEXP_DEFAULT_LANGID;
}

////////////////////////////////////////////////////////////
// Getter and Setter
////////////////////////////////////////////////////////////

MAKE_OPTION1(licenseAccepted, 0)
MAKE_OPTION1(interfaceStyle, 0)
MAKE_OPTION1(compressionEncoder, 0)
MAKE_OPTION1(compressionRCMode, 0)
MAKE_OPTION1(compressionBitrate, 7)
MAKE_OPTION2(outputDir, QString())
MAKE_OPTION3(outputToSourceDir, false)
MAKE_OPTION3(prependRelativeSourcePath, false)
MAKE_OPTION3(writeMetaTags, true)
MAKE_OPTION3(createPlaylist, true)
MAKE_OPTION2(autoUpdateLastCheck, "Never")
MAKE_OPTION3(autoUpdateEnabled, true)
MAKE_OPTION3(soundsEnabled, true)
MAKE_OPTION3(neroAacNotificationsEnabled, true)
MAKE_OPTION3(wmaDecoderNotificationsEnabled, true)
MAKE_OPTION3(dropBoxWidgetEnabled, true)
MAKE_OPTION3(shellIntegrationEnabled, !lamexp_portable_mode())
MAKE_OPTION2(currentLanguage, defaultLanguage())
MAKE_OPTION1(lameAlgoQuality, 3)
MAKE_OPTION1(lameChannelMode, 0);
MAKE_OPTION3(bitrateManagementEnabled, false)
MAKE_OPTION1(bitrateManagementMinRate, 32)
MAKE_OPTION1(bitrateManagementMaxRate, 500)
MAKE_OPTION1(samplingRate, 0)
MAKE_OPTION3(neroAACEnable2Pass, true)
MAKE_OPTION1(neroAACProfile, 0)
MAKE_OPTION3(normalizationFilterEnabled, false)
MAKE_OPTION1(normalizationFilterMaxVolume, -50)
MAKE_OPTION1(toneAdjustBass, 0)
MAKE_OPTION1(toneAdjustTreble, 0)
