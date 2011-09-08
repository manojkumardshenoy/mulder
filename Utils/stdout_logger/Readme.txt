
Yet another stdout/stderr logging utility [2011-09-08]
Copyright (C) 2010-2011 LoRd_MuldeR <MuldeR2@GMX.de>
Released under the terms of the GNU General Public License (see License.txt)

Usage:
  logger.exe [logger options] : program.exe [program arguments]
  program.exe [program arguments] | logger.exe [logger options] : -

Options:
  -log <file name>  Name of the log file to create (default: "<program> <time>.log")
  -append           Append to the log file instead of replacing the existing file
  -mode <mode>      Write 'stdout' or 'stderr' or 'both' to log file (default: 'both')
  -format <format>  Format of log file, 'raw' or 'time' or 'full' (default: 'time')
  -filter <filter>  Don't write lines to log file that contain this string
  -invert           Invert filter, i.e. write only lines to log file that match filter
  -ignorecase       Apply filter in a case-insensitive way (default: case-sensitive)
  -nojobctrl        Don't add child process to job object (applies to Win2k and later)
  -noescape         Don't escape double quotes when forwarding command-line arguments
  -silent           Don't print additional information to the console
  -priority <flag>  Change process priority (idle/belownormal/normal/abovenormal/high)
  -inputcp <cpid>   Use the specified codepage for input processing (default: 'utf8')
  -outputcp <cpid>  Use the specified codepage for log file output (default: 'utf8')

Examples:
  logger.exe x264.exe --crf 22 --output outfile.mkv infile.avs
  logger.exe -log mylogfile.txt : x264.exe --crf 22 --output outfile.mkv infile.avs
  logger.exe -mode stderr : x264.exe --output - infile.avs > outfile.264
  logger.exe -format raw -filter "%]" : x264.exe --output outfile.mkv infile.avs
  logger.exe -filter "x264 [info]" -invert : x264.exe --output outfile.mkv infile.avs
  logger.exe -log "my logfiles\some prefix*" : cmd.exe /c foobar.bat
  logger.exe cmd.exe /c "avs2yuv.exe in.avs -raw - | x264.exe -o out.mkv - 704x576"
  x264.exe --crf 22 --output outfile.mkv infile.avs 2>&1 | logger.exe -

Attention:
  All argument strings that contain whitspaces must be enclose within double quotes!
  However the escape sequence \" can be used the pass a single " character.
 
 
For discussion about 'stdout/stderr logging utility' visit: 
http://forum.doom9.org/showthread.php?t=155622 
 
Pre-compiled x264 binaries for Win32 available here: 
http://komisar.gin.by/index.html 
