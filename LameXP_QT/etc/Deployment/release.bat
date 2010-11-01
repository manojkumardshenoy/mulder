@echo off
set "PATH=E:\7-Zip;E:\MPress;%PATH%
REM ------------------------------------------
set "TEMP_DIR=%TEMP%\_LameXP.tmp"
set "OUT_PATH=..\..\out\Release"
set "OUT_FILE=%OUT_PATH%\..\LameXP.%DATE:.=-%.%~n2.zip"
REM ------------------------------------------
del "%OUT_FILE%"
if exist "%OUT_FILE%" (
	echo.
	echo BUILD HAS FAILED !!!
	echo.
	pause
	exit
)
REM ------------------------------------------
call _build.bat "..\..\LameXP.sln" Release
REM ------------------------------------------
if not exist "%OUT_PATH%\LameXP.exe" (
	echo.
	echo BUILD HAS FAILED !!!
	echo.
	pause
	exit
)
REM ------------------------------------------
rd /S /Q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"
mkdir "%TEMP_DIR%\imageformats"
REM ------------------------------------------
copy "%OUT_PATH%\*.exe" "%TEMP_DIR%"
copy "%QTDIR%\bin\qtcore4.dll" "%TEMP_DIR%"
copy "%QTDIR%\bin\qtgui4.dll" "%TEMP_DIR%"
copy "%QTDIR%\plugins\imageformats\q???4.dll" "%TEMP_DIR%\imageformats"
copy "..\Redist\*.*" "%TEMP_DIR%"
copy "..\..\License.txt" "%TEMP_DIR%"
REM ------------------------------------------
for %%f in ("%TEMP_DIR%\*.exe") do (
	mpress.exe -s "%%f"
)
REM ------------------------------------------
7z.exe a -tzip -r "%OUT_FILE%" "%TEMP_DIR%\*"
rd /S /Q "%TEMP_DIR%"
REM ------------------------------------------
pause
