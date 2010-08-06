@echo off
REM ---------------------------------------------------------------------------------------------------------------------------
set "Samples=E:\Samples\Lossless"
set "Output=LogFiles"
REM ---------------------------------------------------------------------------------------------------------------------------
if not exist "%CD%\logger.exe" (
  echo Error: This script requires "logger.exe" to be loacted at "%CD%"
  pause
  exit
)
REM ---------------------------------------------------------------------------------------------------------------------------
if not exist "%CD%\test.exe" (
  echo Error: This script requires "test.exe" to be loacted at "%CD%"
  pause
  exit
)
REM ---------------------------------------------------------------------------------------------------------------------------
"%CD%\logger.exe" -filter "CaNaRy" -ignorecase -format full -log "%Output%\*" : "%CD%\test.exe" dog cat horse canary cow
REM ---------------------------------------------------------------------------------------------------------------------------
pause
