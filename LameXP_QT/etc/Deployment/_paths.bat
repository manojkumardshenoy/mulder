@echo off
set "LAMEXP_ERROR=1"
REM ------------------------------------------
set "PATH_UPXBIN="
set "PATH_MKNSIS="
set "PATH_MSCDIR="
set "PATH_QTMSVC="
set "PATH_GNUPG1="
set "PATH_VCPROJ="
REM ------------------------------------------
set "BUILDENV_TXT=%~dp0\buildenv.txt"
if not "%~1"=="" (
	set "BUILDENV_TXT=%~1"
)
REM ------------------------------------------
if not exist "%BUILDENV_TXT%" (
	echo.
	echo Could not find 'buildenv.txt' in current directory^!
	echo Please create your 'buildenv.txt' file from 'buildenv.template.txt' first.
	echo.
	pause
	exit
)
REM ------------------------------------------
for /f "tokens=2,*" %%s in (%BUILDENV_TXT%) do (
	if "%%s"=="PATH_UPXBIN" set "PATH_UPXBIN=%%~t"
	if "%%s"=="PATH_MKNSIS" set "PATH_MKNSIS=%%~t"
	if "%%s"=="PATH_MSCDIR" set "PATH_MSCDIR=%%~t"
	if "%%s"=="PATH_QTMSVC" set "PATH_QTMSVC=%%~t"
	if "%%s"=="PATH_GNUPG1" set "PATH_GNUPG1=%%~t"
	if "%%s"=="PATH_VCPROJ" set "PATH_VCPROJ=%%~t"
)
REM ------------------------------------------
set "BUILDENV_TXT="
REM ------------------------------------------
echo === BEGIN PATHS ===
echo PATH_UPXBIN = "%PATH_UPXBIN%"
echo PATH_MKNSIS = "%PATH_MKNSIS%"
echo PATH_MSCDIR = "%PATH_MSCDIR%"
echo PATH_QTMSVC = "%PATH_QTMSVC%"
echo PATH_GNUPG1 = "%PATH_GNUPG1%"
echo PATH_VCPROJ = "%PATH_VCPROJ%"
echo === END PATHS ===
REM ------------------------------------------
set "LAMEXP_ERROR=1"
REM ------------------------------------------
if not exist "%PATH_UPXBIN%\upx.exe" GOTO:EOF
if not exist "%PATH_MKNSIS%\makensis.exe" GOTO:EOF
if not exist "%PATH_MSCDIR%\VC\vcvarsall.bat" GOTO:EOF
if not exist "%PATH_MSCDIR%\VC\bin\cl.exe" GOTO:EOF
if not exist "%PATH_QTMSVC%\bin\uic.exe" GOTO:EOF
if not exist "%PATH_QTMSVC%\bin\moc.exe" GOTO:EOF
if not exist "%PATH_QTMSVC%\bin\rcc.exe" GOTO:EOF
if not exist "%PATH_GNUPG1%\gpg.exe" GOTO:EOF
if not exist "%PATH_GNUPG1%\gpg.exe" GOTO:EOF
if not exist "%~dp0\..\..\%PATH_VCPROJ%" GOTO:EOF
REM ------------------------------------------
if exist "%PATH_QTMSVC%\bin\qtvars.bat" goto qtvars_found
if exist "%PATH_QTMSVC%\bin\qtenv2.bat" goto qtvars_found
GOTO:EOF
:qtvars_found
REM ------------------------------------------
set "LAMEXP_ERROR=0"
