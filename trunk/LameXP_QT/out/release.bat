@echo off
call _build.bat "..\LameXP.sln" Release
for %%f in (".\Release\*.exe") do (mpress.exe -s "%%f")
del "LameXP.%DATE:.=-%.Release.zip"
7z.exe a -tzip "LameXP.%DATE:.=-%.%~n2.zip" ".\Release\*.exe" "%QTDIR%\bin\qtcore4.dll" "%QTDIR%\bin\qtgui4.dll" "..\etc\redist\*.*" "..\License.txt"
pause
