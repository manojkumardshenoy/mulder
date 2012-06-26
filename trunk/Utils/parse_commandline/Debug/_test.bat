@echo off

program.exe abc def ghj
pause

program.exe "abc def ghj"
pause

program.exe "abc def" ghj
pause

program.exe abc "def ghj"
pause

program.exe abc"def"ghj
pause

program.exe abc"def ghj
pause

program.exe abc "def ghj
pause

program.exe "abc \"def\" ghj"
pause

program.exe "abc \\"def\\" ghj"
pause

program.exe "abc \\\"def\\\" ghj"
pause

program.exe "abc \\\\"def\\\\" ghj"
pause

program.exe "abc 'def' ghj"
pause

program.exe "abc \'def\' ghj"
pause

program.exe "abc \\'def\\' ghj"
pause
