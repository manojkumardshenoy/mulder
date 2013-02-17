@echo off

REM Build Number (adjust manually!)
set "BUILD_NO=100"

REM Path to NSIS, Unicode version highly recommended!
set "MAKE_NSIS=D:\NSIS\_Unicode\makensis.exe"

REM Path to UPX executable compressor program
set "UPX_PATH=%~dp0\Utils\UPX.exe"

REM --------------------------------------------------------------------------
REM Do NOT modify any lines below!
REM --------------------------------------------------------------------------

REM Get current Date
set ISO_DATE=
for /F "tokens=1,2 delims=:" %%a in ('"%~dp0\Utils\Date.exe" +ISODATE:%%Y-%%m-%%d') do (
	if "%%a"=="ISODATE" set "ISO_DATE=%%b"
)

REM Check for MakeNSIS
if not exist "%MAKE_NSIS%" (
	echo MAKENSIS.EXE not found, check path!
	pause
	goto:eof
)

REM Print some Info
echo Build #%BUILD_NO%, Date: %ISO_DATE%
echo.

REM Create outputfolder, if not exists yet
mkdir "%~dp0\.Release" 2> NUL

REM Build main installer
"%MAKE_NSIS%" "/DMPLAYER_BUILDNO=%BUILD_NO%" "/DMPLAYER_DATE=%ISO_DATE%" "/DUPX_PATH=%UPX_PATH%" "/DMPLAYER_OUTFILE=%~dp0\.Release\MPUI.%ISO_DATE%.exe" "%~dp0\MPUI_Setup.nsi"

pause
