@echo off

REM ----------------------------------------------------------------

set "CoreVersion=94"
set "AvidemuxFolder=D:\Avidemux 2.5"
set "OutputFoldr=%CD%\test"

REM ----------------------------------------------------------------
if not [%1]==[] goto DO_SOMETHING
if not [%1]==[] goto DO_SOMETHING
REM ----------------------------------------------------------------

for /D %%f in (*.*) do (
    if exist "%%f\libx264-%CoreVersion%.dll" call "%0" "%%f"
)

REM ----------------------------------------------------------------

echo.
echo Calculating MD5 sums, please wait...

"%CD%\md5sums.exe" -n -e "%OutputFoldr%\*.avi" > "%OutputFoldr%\~md5sums.txt"

REM ----------------------------------------------------------------

echo.
echo Done.
echo.

pause
goto END_OF_FILE

REM ----------------------------------------------------------------
:DO_SOMETHING
REM ----------------------------------------------------------------

set "CurrentName=%~n1%~x1"
set "CurrentFile=%CD%\%CurrentName%\libx264-%CoreVersion%.dll"

if not "%CurrentName%"=="%CurrentName:noasm=%" goto END_OF_FILE

echo.
echo ----------------------------------------------------------------------------
echo "%CurrentFile%"
echo ----------------------------------------------------------------------------
echo.

if not exist "%OutputFoldr%" mkdir "%OutputFoldr%"
if not exist "%OutputFoldr%" goto ERROR_FAILED_TO_CREATE

if exist "%AvidemuxFolder%\libx264-%CoreVersion%.dll" del /F "%AvidemuxFolder%\libx264-%CoreVersion%.dll"
if exist "%AvidemuxFolder%\libx264-%CoreVersion%.dll" goto ERROR_FAILED_TO_COPY

copy "%CurrentFile%" "%AvidemuxFolder%\libx264-%CoreVersion%.dll" > NUL
if not exist "%AvidemuxFolder%\libx264-%CoreVersion%.dll" goto ERROR_FAILED_TO_COPY

REM ----------------------------------------------------------------

echo Encoding, please wait...
echo.

"%AvidemuxFolder%\avidemux2_cli.exe" --run "%CD%\test_adm.js" --save "%OutputFoldr%\%CurrentName%.avi" > "%OutputFoldr%\%CurrentName%.out"

goto END_OF_FILE

REM ----------------------------------------------------------------
:ERROR_FAILED_TO_CREATE
REM ----------------------------------------------------------------

echo ERROR: Failed to create output folder at "%OutputFoldr%"
goto END_OF_FILE

REM ----------------------------------------------------------------
:ERROR_FAILED_TO_COPY
REM ----------------------------------------------------------------

echo ERROR: Failed to copy "libx264-%CoreVersion%.dll" to Avidemux folder!
goto END_OF_FILE

REM ----------------------------------------------------------------
:END_OF_FILE
REM ----------------------------------------------------------------

set CurrentName=
set CurrentFile=
set OutputFile=
