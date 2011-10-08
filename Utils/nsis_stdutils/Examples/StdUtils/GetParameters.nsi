Caption "StdUtils Test-Suite"

!addincludedir  "..\..\Include"

!ifdef NSIS_UNICODE
	!addplugindir "..\..\Plugins\Release_Unicode"
	OutFile "GetParameters-Unicode.exe"
!else
	!addplugindir "..\..\Plugins\Release_ANSI"
	OutFile "GetParameters-ANSI.exe"
!endif

!include 'StdUtils.nsh'

RequestExecutionLevel user
ShowInstDetails show

Section
	${StdUtils.GetParameter} $R0 "Foobar" "<N/A>"
	
	StrCmp "$R0" "<N/A>" 0 +3
	DetailPrint "Parameter /Foobar is *not* specified!"
	Goto Finished
	
	StrCmp "$R0" "" 0 +3 ;'Installer.exe [...] /Foobar'
	DetailPrint "Parameter /Foobar specified without a value." 
	Goto Finished

	;'Installer.exe /Foobar=Foo' or 'Installer.exe "/Foobar=Foo Bar"'
	DetailPrint "Value of parameter /Foobar is: '$R0'"
	
	Finished:
	${StdUtils.Unload} ;please do not forget to unload!
SectionEnd
