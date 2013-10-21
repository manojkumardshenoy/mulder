@echo off
set "LAMEXP_ERROR=1"
echo ----------------------------------------------------------------
echo Solution File: %1
echo Configuration: %~2
echo ----------------------------------------------------------------
call "%~dp0\_paths.bat"
if not "%LAMEXP_ERROR%"=="0" GOTO:EOF
REM -----------------------------------------------------------------
call "%PATH_MSCDIR%\VC\bin\vcvars32.bat" x86
if exist "%PATH_QTMSVC%\bin\qtenv2.bat" call "%PATH_QTMSVC%\bin\qtenv2.bat"
if exist "%PATH_QTMSVC%\bin\qtvars.bat" call "%PATH_QTMSVC%\bin\qtvars.bat"
REM -----------------------------------------------------------------
set "LAMEXP_ERROR=1"
msbuild.exe /property:Configuration=%2 /property:Platform=Win32 /target:Clean /verbosity:normal %1
if not "%ERRORLEVEL%"=="0" GOTO:EOF
echo ----------------------------------------------------------------
set "LAMEXP_ERROR=1"
msbuild.exe /property:Configuration=%2 /property:Platform=Win32 /target:Rebuild /verbosity:normal %1
msbuild.exe /property:Configuration=%2 /property:Platform=Win32 /target:Build /verbosity:normal %1
if not "%ERRORLEVEL%"=="0" GOTO:EOF
echo ----------------------------------------------------------------
set "LAMEXP_ERROR=0"
