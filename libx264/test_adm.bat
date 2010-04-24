@echo off

REM ----------------------------------------------------------------

set "CoreVersion=93"
set "AvidemuxFolder=D:\Avidemux 2.5"

REM ----------------------------------------------------------------

if not [%1]==[] goto DO_SOMETHING

for /D %%f in (*.*) do (
    REM if exist "%%f\libx264-%CoreVersion%.dll" call "%0" "%%f"
    if exist "%%f\libx264-%CoreVersion%.dll" call "%0" "%%f"
)

echo.
echo.
pause
goto END_OF_FILE

REM ----------------------------------------------------------------
:DO_SOMETHING
REM ----------------------------------------------------------------

set "CurrentName=%~n1%~x1"
set "CurrentFile=%CD%\%CurrentName%\libx264-%CoreVersion%.dll"
set "OutputFoldr=%CD%\test"

echo.
echo ----------------------------------------------------------------------------
echo "%CurrentFile%"
echo ----------------------------------------------------------------------------
echo.

if not exist "%OutputFoldr%" mkdir "%OutputFoldr%"
if not exist "%OutputFoldr%" goto END_OF_FILE

if exist "%AvidemuxFolder%\libx264-%CoreVersion%.dll" del /F "%AvidemuxFolder%\libx264-%CoreVersion%.dll"
if exist "%AvidemuxFolder%\libx264-%CoreVersion%.dll" goto END_OF_FILE

copy "%CurrentFile%" "%AvidemuxFolder%\libx264-%CoreVersion%.dll" > NUL
if not exist "%AvidemuxFolder%\libx264-%CoreVersion%.dll" goto END_OF_FILE

REM ----------------------------------------------------------------

echo Encoding, please wait...
"%AvidemuxFolder%\avidemux2_cli.exe" --run "%CD%\test_adm.js" --save "%OutputFoldr%\%CurrentName%.avi" > "%OutputFoldr%\%CurrentName%.out"

REM ----------------------------------------------------------------
:END_OF_FILE
REM ----------------------------------------------------------------

set CurrentName=
set CurrentFile=
set OutputFile=
