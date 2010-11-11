@echo off
set "LAMEXP_ERROR=1"
echo ----------------------------------------------------------------
echo Solution File: %1
echo Configuration: %~2
echo ----------------------------------------------------------------
call _paths.bat
if not "%LAMEXP_ERROR%"=="0" GOTO:EOF
REM -----------------------------------------------------------------
call "%PATH_MSVC90%\VC\bin\vcvars32.bat" x86
call "%PATH_QTMSVC%\bin\qtvars.bat"
REM -----------------------------------------------------------------
set "LAMEXP_ERROR=1"
msbuild.exe /property:Configuration=%2 /property:Platform=Win32 /target:Clean /verbosity:detailed %1
if exist "%~d1%~p1bin\%~n2\*.exe" GOTO:EOF
if exist "%~d1%~p1obj\%~n2\*.obj" GOTO:EOF
echo ----------------------------------------------------------------
msbuild.exe /property:Configuration=%2 /property:Platform=Win32 /target:Rebuild /verbosity:detailed %1
echo ----------------------------------------------------------------
if not exist "%~d1%~p1bin\%~n2\%~n1.exe" GOTO:EOF
REM -----------------------------------------------------------------
set "LAMEXP_ERROR=0"
