@echo off
echo ----------------------------------------------------------------
echo Solution File: %1
echo Configuration: %~n2
echo ----------------------------------------------------------------
call "D:\Microsoft Visual Studio 9.0\VC\bin\vcvars32.bat"
call "E:\Qt\MSVC\4.7.0\bin\qtvars.bat"
set "PATH=%PATH%;E:\7-Zip;E:\MPress"
msbuild.exe /property:Configuration=%~n2 /target:Clean,Rebuild /verbosity:d %1
