///////////////////////////////////////////////////////////////////////////////
// stdout/stderr logging utility
// Copyright (C) 2010 LoRd_MuldeR <MuldeR2@GMX.de>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
// http://www.gnu.org/licenses/gpl-2.0.txt
///////////////////////////////////////////////////////////////////////////////

program logger;

{$APPTYPE CONSOLE}
//{$DEFINE MEMLEAK}

uses
  Windows,
  SysUtils,
  StrUtils,
  Classes,
  Utils in 'Utils.pas',
  RedirectThread in 'RedirectThread.pas',
  Unit_LinkTime in '..\LameXP_NEW\Unit_LinkTime.pas',
  Unit_WideStrUtils in '..\LameXP_NEW\Unit_WideStrUtils.pas';

///////////////////////////////////////////////////////////////////////////////

const
  JOBOBJECT_EXTENDED_LIMIT_INFORMATION: DWORD = 9;
  JOBOBJECT_BASIC_PROCESS_ID_LIST = 3;
  JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION: DWORD = $00000400;
  JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE: DWORD = $00002000;
  CREATE_BREAKAWAY_FROM_JOB: Cardinal = $01000000;
  UTF16_BOM: WideString = #$FEFF;
  BELOW_NORMAL_PRIORITY_CLASS = $00004000;
  ABOVE_NORMAL_PRIORITY_CLASS = $00008000;
  MAX_UNIT = 4294967295;

type
  TIoInfo = record
    ReadOperationCount: Int64;
    WriteOperationCount: Int64;
    OtherOperationCount: Int64;
    ReadTransferCount: Int64;
    WriteTransferCount: Int64;
    OtherTransferCount: Int64;
  end;
  TJobObjectExtendedLimitInformation = record
    BasicLimitInformation: record
      PerProcessUserTimeLimit: LARGE_INTEGER;
      PerJobUserTimeLimit: LARGE_INTEGER;
      LimitFlags: DWORD;
      MinimumWorkingSetSize: ULONG;
      MaximumWorkingSetSize: ULONG;
      ActiveProcessLimit: DWORD;
      Affinity: ULONG;
      PriorityClass: DWORD;
      SchedulingClass: DWORD;
    end;
    IoInfo: TIoInfo;
    ProcessMemoryLimit: ULONG;
    JobMemoryLimit: ULONG;
    PeakProcessMemoryUsed: ULONG;
    PeakJobMemoryUsed: ULONG;
  end;
  PJobObjectExtendedLimitInformation = ^TJobObjectExtendedLimitInformation;
  TCreateJobObject = function(JobAttributes: PSecurityAttributes; Name: PAnsiChar): THandle; stdcall;
  TAssignProcessToJobObject = function(Job: THandle; Process: THandle): LongBool; stdcall;
  TSetInformationJobObject = function(Job: THandle; InfoClass: DWORD; JobObjectInfo: PJobObjectExtendedLimitInformation; ObjectInfoLength: DWORD): LongBool; stdcall;

///////////////////////////////////////////////////////////////////////////////

var
  FirstArgIndex: Integer;
  FilterCount: Integer;
  LogStdOut: Boolean;
  LogStdErr: Boolean;
  AddTimestamps: Boolean;
  AddPrefixes: Boolean;
  AppendLog: Boolean;
  JobControl: Boolean;
  SilentMode: Boolean;
  InvertFilter: Boolean;
  CaseSensitiveFilter: Boolean;
  EscapeDoubleQuotes: Boolean;
  StdInputMode: Boolean;
  FilterStr: array[0..MAX_FILTER_COUNT-1] of PWideChar;
  LogFileName: WideString;
  PriorityClass: DWORD;
  InputCodepage: UINT;
  OutputCodepage: UINT;

var
  hStdInput: THandle;
  hStdOutput: THandle;
  hStdError: THandle;
  hLogFile: THandle;
  hStdPipeRead: THandle;
  hStdPipeWrite: THandle;
  hStdPipeTemp: THandle;
  hErrPipeRead: THandle;
  hErrPipeWrite: THandle;
  hErrPipeTemp: THandle;
  hJobObject: THandle;
  ModKernel32: HMODULE;

var
  FormatSettings: TFormatSettings;
  JobObjectInfo: TJobObjectExtendedLimitInformation;
  ProcCreateJobObject: TCreateJobObject;
  ProcAssignProcessToJobObject: TAssignProcessToJobObject;
  ProcSetInformationJobObject: TSetInformationJobObject;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  SecAttributes: TSecurityAttributes;
  StdRedirThread: TRedirectThread;
  ErrRedirThread: TRedirectThread;

var
  Commandline: WideString;
  CreationFlags: DWORD;
  TimeStamp: TSystemTime;
  ProcExitCode: DWORD;
{$IF Defined(MEMLEAK)}
  InitialMemAlloc: Cardinal;
{$IFEND}

var
  Arg: WideString;
  Str: WideString;
  SkipNext: Boolean;
  WideBuffer: array [0..255] of WideChar;
  Len: Cardinal;
  Temp: Cardinal;
  TimeStart: Int64;
  TimeEnd: Int64;
  TimeFreq: Int64;
  i: Integer;

label
  TerminateOnError;

///////////////////////////////////////////////////////////////////////////////

begin
  SetUnhandledExceptionFilter(Addr(ExceptionHandler));
  WriteLn(ErrOutput, '');

{$IF Defined(MEMLEAK)}
  InitialMemAlloc := GetHeapStatus.TotalAllocated;
{$IFEND}

  if(ParamCountW < 2) then
  begin
    WriteLn('Yet another stdout/stderr logging utility [' + GetImageLinkTimeStampAsString(False) + ']');
    WriteLn('Copyright (C) 2010-2011 LoRd_MuldeR <MuldeR2@GMX.de>');
    WriteLn('Released under the terms of the GNU General Public License (see License.txt)');
    WriteLn('');
    WriteLn('Usage:');
    WriteLn('  logger.exe [logger options] : program.exe [program arguments]');
    WriteLn('  program.exe [program arguments] | logger.exe [logger options] : -');
    WriteLn('');
    WriteLn('Options:');
    WriteLn('  -log <file name>  Name of the log file to create (default: "<program> <time>.log")');
    WriteLn('  -append           Append to the log file instead of replacing the existing file');
    WriteLn('  -mode <mode>      Write ''stdout'' or ''stderr'' or ''both'' to log file (default: ''both'')');
    WriteLn('  -format <format>  Format of log file, ''raw'' or ''time'' or ''full'' (default: ''time'')');
    WriteLn('  -filter <filter>  Don''t write lines to log file that contain this string');
    WriteLn('  -invert           Invert filter, i.e. write only lines to log file that match filter');
    WriteLn('  -ignorecase       Apply filter in a case-insensitive way (default: case-sensitive)');
    WriteLn('  -nojobctrl        Don''t add child process to job object (applies to Win2k and later)');
    WriteLn('  -noescape         Don''t escape double quotes when forwarding command-line arguments');
    WriteLn('  -silent           Don''t print additional information to the console');
    WriteLn('  -priority <flag>  Change process priority (idle/belownormal/normal/abovenormal/high)');
    WriteLn('  -inputcp <cpid>   Use the specified codepage for input processing (default: ''utf8'')');
    WriteLn('  -outputcp <cpid>  Use the specified codepage for log file output (default: ''utf8'')');
    WriteLn('');
    WriteLn('Examples:');
    WriteLn('  logger.exe x264.exe --crf 22 --output outfile.mkv infile.avs');
    WriteLn('  logger.exe -log mylogfile.txt : x264.exe --crf 22 --output outfile.mkv infile.avs');
    WriteLn('  logger.exe -mode stderr : x264.exe --output - infile.avs > outfile.264');
    WriteLn('  logger.exe -format raw -filter "%]" : x264.exe --output outfile.mkv infile.avs');
    WriteLn('  logger.exe -filter "x264 [info]" -invert : x264.exe --output outfile.mkv infile.avs');
    WriteLn('  logger.exe -log "my logfiles\some prefix*" : cmd.exe /c foobar.bat');
    WriteLn('  logger.exe cmd.exe /c "avs2yuv.exe in.avs -raw - | x264.exe -o out.mkv - 704x576"');
    WriteLn('  x264.exe --crf 22 --output outfile.mkv infile.avs 2>&1 | logger.exe -');
    WriteLn('');
    WriteLn('Attention:');
    WriteLn('  All argument strings that contain whitspaces must be enclose within double quotes!');
    WriteLn('  However the escape sequence \" can be used the pass a single " character.');
    Exit;
  end;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  ExitCode := -1;

  hJobObject := 0;
  ModKernel32 := 0;
  CreationFlags := 0;

  hLogFile := INVALID_HANDLE_VALUE;
  hStdPipeRead := INVALID_HANDLE_VALUE;
  hStdPipeWrite := INVALID_HANDLE_VALUE;
  hStdPipeTemp := INVALID_HANDLE_VALUE;
  hErrPipeRead := INVALID_HANDLE_VALUE;
  hErrPipeWrite := INVALID_HANDLE_VALUE;
  hErrPipeTemp := INVALID_HANDLE_VALUE;

  ZeroMemory(@StartupInfo, SizeOf(TStartupInfo));
  ZeroMemory(@ProcessInfo, SizeOf(TProcessInformation));
  ZeroMemory(@JobObjectInfo, SizeOf(TJobObjectExtendedLimitInformation));
  ZeroMemory(@SecAttributes, SizeOf(TSecurityAttributes));
  ZeroMemory(@TimeStamp, SizeOf(TSystemTime));

  @ProcCreateJobObject := nil;
  @ProcAssignProcessToJobObject := nil;
  @ProcSetInformationJobObject := nil;
  StdRedirThread := nil;
  ErrRedirThread := nil;

  FirstArgIndex := 1;
  FilterCount := 0;
  LogFileName := '';
  LogStdOut := True;
  LogStdErr := True;
  Commandline := '';
  AddTimestamps := True;
  AddPrefixes := False;
  AppendLog := False;
  JobControl := True;
  SilentMode := False;
  InvertFilter := False;
  CaseSensitiveFilter := True;
  EscapeDoubleQuotes := True;
  StdInputMode := False;
  PriorityClass := 0;
  InputCodepage := CP_UTF8;
  OutputCodepage := CP_UTF8;
  TimeStart := 0;
  TimeEnd := 0;
  TimeFreq := 0;

  for i := 0 to MAX_FILTER_COUNT-1 do
  begin
    FilterStr[i] := nil;
  end;

  GetLocaleFormatSettings($0409, FormatSettings);
  QueryPerformanceFrequency(TimeFreq);

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  hStdInput := GetStdHandle(STD_INPUT_HANDLE);
  hStdOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  hStdError := GetStdHandle(STD_ERROR_HANDLE);

  if not (IsValidHandle(hStdInput) and IsValidHandle(hStdOutput) and IsValidHandle(hStdError)) then
  begin
    WriteLn(ErrOutput, 'Error: Failed to acquire std handles !!!'#10);
    goto TerminateOnError;
  end;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  for i := 1 to ParamCountW-1 do
  begin
    if SameTextW(ParamStrW(i), ':') then
    begin
      FirstArgIndex := i+1;
      Break;
    end;  
  end;

  SkipNext := False;

  for i := 1 to FirstArgIndex-2 do
  begin
    if SkipNext then
    begin
      SkipNext := False;
      Continue;
    end;
    Arg := ParamStrW(i);
    if SameTextW(Arg, '-log') and (i < FirstArgIndex-2) then
    begin
      Str := Trim(ParamStrW(i+1));
      if Length(Str) > 0 then
      begin
        LogFileName := Str;
      end;
      SkipNext := True;
    end
    else if SameTextW(Arg, '-mode') and (i < FirstArgIndex-2) then
    begin
      Str := Trim(ParamStrW(i+1));
      LogStdOut := SameTextW(Str, 'stdout') or SameTextW(Str, 'both');
      LogStdErr := SameTextW(Str, 'stderr') or SameTextW(Str, 'both');
      if not (LogStdOut or LogStdErr) then
      begin
        WriteLn(ErrOutput, 'Error: Invalid mode specified !!!'#10);
        goto TerminateOnError;
      end;
      SkipNext := True;
    end
    else if SameTextW(Arg, '-filter') and (i < FirstArgIndex-2) then
    begin
      Str := Trim(ParamStrW(i+1));
      if (Length(Str) > 0) and (FilterCount < MAX_FILTER_COUNT) then
      begin
        Len := StrLenW(PWideChar(Str)) + 1;
        FilterStr[FilterCount] := AllocMem(Len * SizeOf(WideChar));
        StrCopyW(FilterStr[FilterCount], PWideChar(Str), Len);
        FilterCount := FilterCount + 1;
      end;  
      SkipNext := True;
    end
    else if SameTextW(Arg, '-format') and (i < FirstArgIndex-2) then
    begin
      Str := Trim(ParamStrW(i+1));
      AddPrefixes := SameTextW(Str, 'full');
      AddTimestamps := SameTextW(Str, 'full') or SameTextW(Str, 'time');
      if not (AddPrefixes or AddTimestamps) then
      begin
        if not SameTextW(Str, 'raw') then
        begin
          WriteLn(ErrOutput, 'Error: Invalid format identifier specified !!!'#10);
          goto TerminateOnError;
        end;
      end;
      SkipNext := True;
    end
    else if SameTextW(Arg, '-append') then
    begin
      AppendLog := True;
    end
    else if SameTextW(Arg, '-nojobctrl') then
    begin
      JobControl := False;
    end
    else if SameTextW(Arg, '-silent') then
    begin
      SilentMode := True;
    end
    else if SameTextW(Arg, '-invert') then
    begin
      InvertFilter := True;
    end
    else if SameTextW(Arg, '-ignorecase') then
    begin
      CaseSensitiveFilter := False;
    end
    else if SameTextW(Arg, '-priority') and (i < FirstArgIndex-2) then
    begin
      PriorityClass := 0;
      Str := Trim(ParamStrW(i+1));
      if SameTextW(Str, 'idle') then PriorityClass := IDLE_PRIORITY_CLASS;
      if SameTextW(Str, 'belownormal') then PriorityClass := BELOW_NORMAL_PRIORITY_CLASS;
      if SameTextW(Str, 'normal') then PriorityClass := NORMAL_PRIORITY_CLASS;
      if SameTextW(Str, 'abovenormal') then PriorityClass := ABOVE_NORMAL_PRIORITY_CLASS;
      if SameTextW(Str, 'high') then PriorityClass := HIGH_PRIORITY_CLASS;
      if SameTextW(Str, 'realtime') then PriorityClass := REALTIME_PRIORITY_CLASS;
      if PriorityClass = 0 then
      begin
        WriteLn(ErrOutput, 'Error: Invalid priority class specified !!!'#10);
        goto TerminateOnError;
      end;
      SkipNext := True;
    end
    else if SameTextW(Arg, '-noescape') then
    begin
      EscapeDoubleQuotes := False;
    end
    else if SameTextW(Arg, '-inputcp') and (i < FirstArgIndex-2) then
    begin
      Str := Trim(ParamStrW(i+1));
      InputCodepage := MAX_UNIT;
      if SameTextW(Str, 'ansi') or SameTextW(Str, '0') then InputCodepage := CP_ACP;
      if SameTextW(Str, 'oem') or SameTextW(Str, '1') then InputCodepage := CP_OEMCP;
      if SameTextW(Str, 'mac') or SameTextW(Str, '2') then InputCodepage := CP_MACCP;
      if SameTextW(Str, 'symbol') or SameTextW(Str, '42') then InputCodepage := CP_SYMBOL;
      if SameTextW(Str, 'utf7') or SameTextW(Str, '65000') then InputCodepage := CP_UTF7;
      if SameTextW(Str, 'utf8') or SameTextW(Str, '65001') then InputCodepage := CP_UTF8;
      if InputCodepage = MAX_UNIT then
      begin
        WriteLn(ErrOutput, 'Error: Invalid input codepage identifier specified !!!'#10);
        WriteLn(ErrOutput, 'Supported codepages are ''ansi'' (0), ''oem'' (1), ''mac'' (2), ''symbol'' (42), ''utf7'' (65000) and ''utf8'' (65001)'#10);
        goto TerminateOnError;
      end;
      SkipNext := True;
    end
    else if SameTextW(Arg, '-outputcp') and (i < FirstArgIndex-2) then
    begin
      Str := Trim(ParamStrW(i+1));
      OutputCodepage := MAX_UNIT;
      if SameTextW(Str, 'ansi') or SameTextW(Str, '0') then OutputCodepage := CP_ACP;
      if SameTextW(Str, 'oem') or SameTextW(Str, '1') then OutputCodepage := CP_OEMCP;
      if SameTextW(Str, 'mac') or SameTextW(Str, '2') then OutputCodepage := CP_MACCP;
      if SameTextW(Str, 'symbol') or SameTextW(Str, '42') then OutputCodepage := CP_SYMBOL;
      if SameTextW(Str, 'utf7') or SameTextW(Str, '65000') then OutputCodepage := CP_UTF7;
      if SameTextW(Str, 'utf8') or SameTextW(Str, '65001') then OutputCodepage := CP_UTF8;
      if OutputCodepage = MAX_UNIT then
      begin
        WriteLn(ErrOutput, 'Error: Invalid output codepage identifier specified !!!'#10);
        WriteLn(ErrOutput, 'Supported codepages are ''ansi'' (0), ''oem'' (1), ''mac'' (2), ''symbol'' (42), ''utf7'' (65000) and ''utf8'' (65001)'#10);
        goto TerminateOnError;
      end;
      SkipNext := True;
    end
    else begin
      WriteConsoleW(hStdError, 'Error: Option "' + Arg + '" is unknown or parameter is missing !!!' + #10);
      goto TerminateOnError;
    end;
  end;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  if InvertFilter and (FilterCount < 1) then
  begin
    WriteLn(ErrOutput, 'Error: The "-invert" option requires at least one filter !!!'#10);
    goto TerminateOnError;
  end;

  LogFileName := FixDriveDelimiterW(FixPathDelimitersW(LogFileName));

  if (Length(LogFileName) < 1) then
  begin
    LogFileName := GetCurrentDirW + PathDelim;
  end
  else if SameTextW(LogFileName[Length(LogFileName)], DriveDelim) then
  begin
    LogFileName := LogFileName + PathDelim;
  end;

  Str := RightStr(LogFileName, 1);

  if SameTextW(Str, PathDelim) or SameTextW(Str, '?') or SameTextW(Str, '*') then
  begin
    while SameTextW(Str, '?') or SameTextW(Str, '*') do
    begin
      LogFileName := Trim(Copy(LogFileName, 1, Length(LogFileName) - 1));
      Str := RightStr(LogFileName, 1);
    end;
    if not (SameTextW(Str,'\') or SameTextW(Str,'')) then
    begin
      LogFileName := LogFileName + ' ';
    end;
    Str := FixFilenameW(Trim(ExtractFileNameW(Trim(ParamStrW(FirstArgIndex)))));
    if StrLenW(PWideChar(Str)) > 0 then
    begin
      if SameTextW(Str, '-') then
      begin
        Str := 'Logfile';
      end;
      LogFileName := LogFileName + Str + ' ';
    end;
    GetLocalTime(TimeStamp);
    LogFileName := LogFileName + Format('%.4d-%.2d-%.2d %.2d-%.2d-%.2d.log', [TimeStamp.wYear, TimeStamp.wMonth, TimeStamp.wDay, TimeStamp.wHour, TimeStamp.wMinute, TimeStamp.wSecond]);
  end;

  LogFileName := ExpandFileNameW(FixPathNameW(LogFileName));
  ForceDirectoriesW(ExtractFileDirectoryW(LogFileName));

  AddLogMessage(0, hStdError, 'Log file: ' + LogFileName, AddTimestamps, AddPrefixes, SilentMode, OutputCodepage);

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  if AppendLog then
  begin
    hLogFile := CreateFileW(PWideChar(LogFileName), GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_ALWAYS, 0, 0);
  end else begin
    hLogFile := CreateFileW(PWideChar(LogFileName), GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_ALWAYS, 0, 0);
  end;

  if not IsValidHandle(hLogFile) then
  begin
    Len := FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError, 0, Addr(WideBuffer[0]), 256, nil);
    WriteLn(ErrOutput, 'Error: Failed to open log file for writing !!!'#10);
    if Len > 0 then
    begin
      WriteConsoleW(hStdError, PWideChar(Addr(WideBuffer[0])));
    end;
    goto TerminateOnError;
  end;

  if AppendLog then
  begin
    SetFilePointer(hLogFile, 0, nil, FILE_END);  
  end;

  if (GetFileSize(hLogFile, nil) = 0) and ((OutputCodepage = CP_UTF8) or (OutputCodepage = CP_UTF7)) then
  begin
    WriteFileW(hLogFile, PWideChar(UTF16_BOM), OutputCodepage);
  end;  

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  if SameTextW(Trim(ParamStrW(FirstArgIndex)), '-') then
  begin
    StdInputMode := True;
  end;

  if not StdInputMode then
  begin
    for i := FirstArgIndex to ParamCountW do
    begin
      Str := Trim(ParamStrW(i));
      if EscapeDoubleQuotes and (StrPosW(PWideChar(Str), '"') <> nil) then
      begin
        Str := EncodeDoubleQuotesW(Str);
      end;
      if StrPosW(PWideChar(Str), ' ') <> nil then
      begin
        Str := '"' + Str + '"';
      end;
      if StrLenW(PWideChar(Str)) > 0 then
      begin
        if Length(Commandline) > 0 then
        begin
          Commandline := Commandline + ' ';
        end;
        Commandline := Commandline + Str;
      end;
    end;

    if Length(Commandline) < 1 then
    begin
      WriteLn(ErrOutput, 'Error: The command-line is too short !!!'#10);
      goto TerminateOnError;
    end;

    AddLogMessage(hLogFile, hStdError, 'Commandline: ' + Commandline, AddTimestamps, AddPrefixes, SilentMode, OutputCodepage);
  end;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  SecAttributes.bInheritHandle := True;
  SecAttributes.nLength := sizeof(TSecurityAttributes);

  if not StdInputMode then
  begin
    if not CreatePipe(hStdPipeTemp, hStdPipeWrite, Addr(SecAttributes), 0) then
    begin
      hStdPipeTemp := 0;
      hStdPipeWrite := 0;
      WriteLn(ErrOutput, 'Error: Failed to create pipe !!!'#10);
      goto TerminateOnError;
    end;
    if not CreatePipe(hErrPipeTemp, hErrPipeWrite, Addr(SecAttributes), 0) then
    begin
      hErrPipeTemp := 0;
      hErrPipeWrite := 0;
      WriteLn(ErrOutput, 'Error: Failed to create pipe !!!'#10);
      goto TerminateOnError;
    end;

    if not DuplicateHandle(GetCurrentProcess, hStdPipeTemp, GetCurrentProcess, Addr(hStdPipeRead), 0, false, DUPLICATE_SAME_ACCESS) then
    begin
      hStdPipeRead := 0;
      WriteLn(ErrOutput, 'Error: Failed to duplicate pipe !!!'#10);
      goto TerminateOnError;
    end;
    if not DuplicateHandle(GetCurrentProcess, hErrPipeTemp, GetCurrentProcess, Addr(hErrPipeRead), 0, false, DUPLICATE_SAME_ACCESS) then
    begin
      hStdPipeRead := 0;
      WriteLn(ErrOutput, 'Error: Failed to duplicate pipe !!!'#10);
      goto TerminateOnError;
    end;

    ReleaseHandle(hStdPipeTemp);
    ReleaseHandle(hErrPipeTemp);
  end;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  if (not StdInputMode) and JobControl then
  begin
    ModKernel32 := SafeLoadLibrary(kernel32);
    if ModKernel32 <> 0 then
    begin
      @ProcCreateJobObject := GetProcAddress(ModKernel32, 'CreateJobObjectA');
      @ProcAssignProcessToJobObject := GetProcAddress(ModKernel32, 'AssignProcessToJobObject');
      @ProcSetInformationJobObject := GetProcAddress(ModKernel32, 'SetInformationJobObject');
    end;

    if (@ProcCreateJobObject <> nil) and (@ProcAssignProcessToJobObject <> nil) and (@ProcSetInformationJobObject <> nil) then
    begin
      hJobObject := ProcCreateJobObject(nil, nil);
    end;

    if IsValidHandle(hJobObject) then
    begin
      JobObjectInfo.BasicLimitInformation.LimitFlags := JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE or JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION;
      ProcSetInformationJobObject(hJobObject, JOBOBJECT_EXTENDED_LIMIT_INFORMATION, @JobObjectInfo, SizeOf(TJobObjectExtendedLimitInformation));
    end else begin
      JobControl := False;
    end;
  end;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  if PriorityClass <> 0 then
  begin
    SetPriorityClass(GetCurrentProcess, PriorityClass);
  end;

  if not StdInputMode then
  begin
    StartupInfo.dwFlags := STARTF_USESTDHANDLES;
    StartupInfo.hStdInput := hStdInput;

    if LogStdOut then
    begin
      StartupInfo.hStdOutput := hStdPipeWrite;
    end else begin
      StartupInfo.hStdOutput := hStdOutput;
    end;

    if LogStdErr then
    begin
      StartupInfo.hStdError := hErrPipeWrite;
    end else begin
      StartupInfo.hStdError := hStdError;
    end;

    if JobControl then
    begin
      CreationFlags := CreationFlags or CREATE_SUSPENDED or CREATE_BREAKAWAY_FROM_JOB;
    end;

    if PriorityClass <> 0 then
    begin
      CreationFlags := CreationFlags or PriorityClass;
    end;

    if not CreateProcessW(nil, PWideChar(Commandline), nil, nil, true, CreationFlags, nil, nil, StartupInfo, ProcessInfo) then
    begin
      ProcessInfo.hProcess := 0;
      ProcessInfo.hThread := 0;
      Len := FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError, 0, Addr(WideBuffer[0]), 256, nil);
      AddLogMessage(hLogFile, hStdError, 'Error: Failed to create process !!!', AddTimestamps, AddPrefixes, SilentMode, OutputCodepage);
      if Len > 0 then
      begin
        AddLogMessage(hLogFile, hStdError, WideBuffer, AddTimestamps, AddPrefixes, SilentMode, OutputCodepage);
      end;
      goto TerminateOnError;
    end;

    ReleaseHandle(hStdPipeWrite);
    ReleaseHandle(hErrPipeWrite);

    if JobControl then
    begin
      ProcAssignProcessToJobObject(hJobObject, ProcessInfo.hProcess);
      ResumeThread(ProcessInfo.hThread);
    end;

    QueryPerformanceCounter(TimeStart);
  end;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  if not StdInputMode then
  begin
    if LogStdOut then
    begin
      StdRedirThread := TRedirectThread.Create(hStdPipeRead, hStdOutput, hLogFile, AddTimestamps);
    end;
    if LogStdErr then
    begin
      ErrRedirThread := TRedirectThread.Create(hErrPipeRead, hStdError, hLogFile, AddTimestamps);
    end;
  end else
  begin
    StdRedirThread := TRedirectThread.Create(hStdInput, hStdOutput, hLogFile, AddTimestamps);
  end;

  if AddPrefixes then
  begin
    if not StdInputMode then
    begin
      if Assigned(StdRedirThread) then StdRedirThread.SetPrefixStr('STDOUT');
      if Assigned(ErrRedirThread) then ErrRedirThread.SetPrefixStr('STDERR');
    end else
    begin
      if Assigned(StdRedirThread) then StdRedirThread.SetPrefixStr('STDINP');
    end;
  end;

  if InvertFilter then
  begin
    if Assigned(StdRedirThread) then StdRedirThread.SetInvertFilter(True);
    if Assigned(ErrRedirThread) then ErrRedirThread.SetInvertFilter(True);
  end;

  if not CaseSensitiveFilter then
  begin
    if Assigned(StdRedirThread) then StdRedirThread.SetCaseSensitiveFilter(False);
    if Assigned(ErrRedirThread) then ErrRedirThread.SetCaseSensitiveFilter(False);
  end;

  for i := 0 to FilterCount-1 do
  begin
    if Assigned(StdRedirThread) then StdRedirThread.AddFilterStr(FilterStr[i]);
    if Assigned(ErrRedirThread) then ErrRedirThread.AddFilterStr(FilterStr[i]);
  end;

  if Assigned(StdRedirThread) then
  begin
    StdRedirThread.SetInputCodepage(InputCodepage);
    StdRedirThread.SetOutputCodepage(OutputCodepage);
  end;
  if Assigned(ErrRedirThread) then
  begin
    ErrRedirThread.SetInputCodepage(InputCodepage);
    ErrRedirThread.SetOutputCodepage(OutputCodepage);
  end;

  if Assigned(StdRedirThread) then StdRedirThread.Resume;
  if Assigned(ErrRedirThread) then ErrRedirThread.Resume;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  if IsValidHandle(ProcessInfo.hProcess) then
  begin
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    QueryPerformanceCounter(TimeEnd);
  end;

  if Assigned(StdRedirThread) then
  begin
    i := StdRedirThread.WaitFor;
    if i <> ERROR_BROKEN_PIPE then
    begin
      WriteLn(ErrOutput, Format('Error: Thread returned error code %d !!!'#10, [i]));
    end;
  end;

  if Assigned(ErrRedirThread) then
  begin
    i := ErrRedirThread.WaitFor;
    if i <> ERROR_BROKEN_PIPE then
    begin
      WriteLn(ErrOutput, Format('Error: Thread returned error code %d !!!'#10, [i]));
    end;
  end;

  WriteLn(ErrOutput, '');

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  if GetExitCodeProcess(ProcessInfo.hProcess, ProcExitCode) then
  begin
    AddLogMessage(hLogFile, hStdError, Format('Process terminated with code: %u', [ProcExitCode]), AddTimestamps, AddPrefixes, SilentMode, OutputCodepage);
    ExitCode := ProcExitCode;
  end;

  if (TimeStart <> 0) and (TimeEnd <> 0) and (TimeFreq <> 0) then
  begin
    AddLogMessage(hLogFile, hStdError, Format('Execution took %s.', [TimeToStr((TimeEnd - TimeStart) div TimeFreq)]), AddTimestamps, AddPrefixes, SilentMode, OutputCodepage);
  end;

  if (not SilentMode) then
  begin
    if Assigned(StdRedirThread) and Assigned(ErrRedirThread) then
    begin
      if StdRedirThread.GetProcessedLines + ErrRedirThread.GetProcessedLines > 0 then
      begin
        i := Round(((StdRedirThread.GetSkippedLines + ErrRedirThread.GetSkippedLines) / (StdRedirThread.GetProcessedLines + ErrRedirThread.GetProcessedLines)) * 100);
      end else
      begin
        i := 0;
      end;
      WriteLn(ErrOutput, Format('Captured %u/%u lines from stdout/stderr, skipped %u/%u lines (%d%%).'#10, [StdRedirThread.GetProcessedLines, ErrRedirThread.GetProcessedLines, StdRedirThread.GetSkippedLines, ErrRedirThread.GetSkippedLines, i]));
    end
    else if Assigned(StdRedirThread) then
    begin
      if StdRedirThread.GetProcessedLines > 0 then
      begin
        i := Round((StdRedirThread.GetSkippedLines / StdRedirThread.GetProcessedLines) * 100);
      end else
      begin
        i := 0;
      end;
      WriteLn(ErrOutput, Format('Captured %u lines from stdout, skipped %u lines (%d%%).'#10, [StdRedirThread.GetProcessedLines, StdRedirThread.GetSkippedLines, i]));
    end
    else if Assigned(ErrRedirThread) then
    begin
      if ErrRedirThread.GetProcessedLines > 0 then
      begin
        i := Round((ErrRedirThread.GetSkippedLines / ErrRedirThread.GetProcessedLines) * 100);
      end else
      begin
        i := 0;
      end;
      WriteLn(ErrOutput, Format('Captured %u lines from stderr, skipped %u lines (%d%%).'#10, [ErrRedirThread.GetProcessedLines, ErrRedirThread.GetSkippedLines, i]));
    end;
  end;

  WriteFile(hLogFile, #$0D#$0A, 2, Temp, nil);

  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  TerminateOnError:

  if Assigned(StdRedirThread) then
  begin
    FreeAndNil(StdRedirThread);
  end;

  if Assigned(ErrRedirThread) then
  begin
    FreeAndNil(ErrRedirThread);
  end;

  ReleaseHandle(hJobObject);
  ReleaseHandle(ProcessInfo.hProcess);
  ReleaseHandle(ProcessInfo.hThread);
  ReleaseHandle(hStdPipeRead);
  ReleaseHandle(hErrPipeRead);
  ReleaseHandle(hStdPipeWrite);
  ReleaseHandle(hErrPipeWrite);
  ReleaseHandle(hStdPipeTemp);
  ReleaseHandle(hErrPipeTemp);
  ReleaseHandle(hLogFile);

  for i := 0 to MAX_FILTER_COUNT-1 do
  begin
    if FilterStr[i] <> nil then
    begin
      FreeMem(FilterStr[i]);
      FilterStr[i] := nil;
    end;
  end;

  if (ModKernel32 <> 0) then
  begin
    FreeLibrary(ModKernel32);
  end;

{$IF Defined(MEMLEAK)}
  WriteLn(ErrOutput, Format('Memory Leak: %d bytes are lost !!!'#10, [GetHeapStatus.TotalAllocated - InitialMemAlloc]));
{$IFEND}
end.

