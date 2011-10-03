Caption "StdUtils Test-Suite"

!addincludedir  "..\..\Include"

!ifdef NSIS_UNICODE
	!addplugindir "..\..\Plugins\Release_Unicode"
	OutFile "ShellExecWait-Unicode.exe"
!else
	!addplugindir "..\..\Plugins\Release_ANSI"
	OutFile "ShellExecWait-ANSI.exe"
!endif

!include 'StdUtils.nsh'

RequestExecutionLevel user
ShowInstDetails show

Section
	DetailPrint 'ExecShellWait: "$SYSDIR\mspaint.exe"'
	Sleep 1000
	${StdUtils.ExecShellWait} $0 "$SYSDIR\mspaint.exe" "open" "" ;try to launch the process
	DetailPrint "Result: $0" ;returns process handle. Might be "no_wait". Failure indicated by "error".
	StrCmp $0 "error" WaitFailed ;check if process failed to create.
	StrCmp $0 "no_wait" WaitNotPossible ;check if process can be waited for. Always check this!
	
	DetailPrint "Waiting for process. ZZZzzzZZZzzz..."
	StdUtils::WaitForProc /NOUNLOAD $0
	DetailPrint "Process just terminated."
	Goto WaitDone
	
	WaitFailed:
	DetailPrint "Failed to create process !!!"
	Goto WaitDone

	WaitNotPossible:
	DetailPrint "Can not wait for process."
	Goto WaitDone
	
	WaitDone:
	${StdUtils.Unload} ;please do not forget to unload!
SectionEnd
