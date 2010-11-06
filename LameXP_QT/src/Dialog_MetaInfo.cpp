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

#include "Dialog_MetaInfo.h"

#include "Global.h"
#include "Model_MetaInfo.h"

#include <QFileInfo>

MetaInfoDialog::MetaInfoDialog(QWidget *parent)
	: QDialog(parent)
{
	//Init the dialog, from the .ui file
	setupUi(this);

	//Fix size
	setMinimumSize(this->size());

	//Setup table view
	tableView->verticalHeader()->setVisible(false);
	tableView->verticalHeader()->setResizeMode(QHeaderView::ResizeToContents);
	tableView->horizontalHeader()->setResizeMode(QHeaderView::ResizeToContents);
	tableView->horizontalHeader()->setStretchLastSection(true);
}

MetaInfoDialog::~MetaInfoDialog(void)
{
}

int MetaInfoDialog::exec(AudioFileModel &audioFile)
{
	MetaInfoModel *model = new MetaInfoModel(&audioFile);
	tableView->setModel(model);
	setWindowTitle(QString("Meta Information: ").append(QFileInfo(audioFile.filePath()).fileName()));

	int iResult = QDialog::exec();
	
	tableView->setModel(NULL);
	LAMEXP_DELETE(model);

	return iResult;
}
