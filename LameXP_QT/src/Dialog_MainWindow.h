#pragma once

#include <QtGui/QFileSystemModel>
#include <QtGui/QSound>
#include <QtGui/QSystemTrayIcon>
#include <QtCore/QTemporaryFile>
#include <QtCore/QProcess>

#include "../tmp/UIC_MainWindow.h"

class MainWindow: public QMainWindow, private Ui::MainWindow
{
	Q_OBJECT

public:
	MainWindow(QWidget *parent = 0);
	~MainWindow(void);
};
