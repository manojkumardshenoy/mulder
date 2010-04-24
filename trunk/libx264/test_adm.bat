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

pause
goto END_OF_FILE

REM ----------------------------------------------------------------
:DO_SOMETHING
REM ----------------------------------------------------------------

set "CurrentName=%~n1%~x1"
set "CurrentFile=%CD%\%CurrentName%\libx264-%CoreVersion%.dll"
set "OutputFile=%CD%\%CurrentName%"

echo.
echo ----------------------------------------------------------------------------
echo "%CurrentFile%"
echo ----------------------------------------------------------------------------
echo.

if exist "%AvidemuxFolder%\libx264-%CoreVersion%.dll" del /F "%AvidemuxFolder%\libx264-%CoreVersion%.dll"
if exist "%AvidemuxFolder%\libx264-%CoreVersion%.dll" goto END_OF_FILE

copy "%CurrentFile%" "%AvidemuxFolder%\libx264-%CoreVersion%.dll"
"%AvidemuxFolder%\avidemux2_cli.exe" --run "%AvidemuxFolder%\test_gcc.js" --save "%OutputFile%.avi" > "%OutputFile%.log"

REM ----------------------------------------------------------------
:END_OF_FILE
REM ----------------------------------------------------------------

set CurrentName=
set CurrentFile=
set OutputFile=
