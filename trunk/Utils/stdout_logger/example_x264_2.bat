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
if not exist "%Samples%\foreman_cif.352x288.avi" (
  echo Error: This script requires "foreman_cif.352x288.avi" to be loacted at "%Samples%"
  pause
  exit
)
REM ---------------------------------------------------------------------------------------------------------------------------
if not exist "%CD%\x264.exe" (
  echo Error: This script requires "x264.exe" to be loacted at "%CD%"
  pause
  exit
)
REM ---------------------------------------------------------------------------------------------------------------------------
"%CD%\x264.exe" --output NUL "%Samples%\foreman_cif.352x288.avi" 2>&1 | "%CD%\logger.exe" -filter "x264 [iNfO]" -ignorecase -invert -format full -log "%Output%\*" : -
REM ---------------------------------------------------------------------------------------------------------------------------
pause
