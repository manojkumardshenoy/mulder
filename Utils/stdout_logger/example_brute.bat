@echo off
REM ---------------------------------------------------------------------------------------------------------------------------
REM PLEASE NOTE:
REM 1. For some reason passing Unicode commands form Batch files works on Win7, but *not* on WinXP
REM 2. The "Lucidia Console" font must me used in order to display Unicode characters in the console window
REM 3. Even with the "Lucidia Console" font some Unicode characters still don't show up properly
REM ---------------------------------------------------------------------------------------------------------------------------
chcp 65001
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
set TEST_LOOPS=999999
set TEST_DELAY=10
"%CD%\logger.exe" -filter "Фед" -ignorecase -format full -log "%Output%\д本مα\*" : "%CD%\test.exe" "United Kingdom" "Российская Федерация" "Ελληνική Δημοκρατία" "الإمارات العربيّة المتّحدة" "日本"
REM ---------------------------------------------------------------------------------------------------------------------------
pause
