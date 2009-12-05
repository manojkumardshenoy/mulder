program pipebuf;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  Classes;

const
  VerMajor: Byte = 1;
  VerMinor: Byte = 3;

const
  Separator: Char = ':';

var
  BuffSize: Cardinal;
  ExitCode: DWORD;

  Params1: TStringList;
  Params2: TStringList;
  Command1: String;
  Command2: String;

  Startup1: TStartupInfo;
  Startup2: TStartupInfo;
  ProcInf1: TProcessInformation;
  ProcInf2: TProcessInformation;

  PipeRead: THandle;
  PipeWrite: THandle;
  PipeInherit: THandle;

  StdOut: THandle;
  StdErr: THandle;
  StdIn: THandle;

  i: Integer;
  a: array [0..1023] of Char;
  b: Boolean;

begin
  BuffSize := 0;
  ExitCode := 0;

  ZeroMemory(@Startup1, SizeOf(TStartupInfo));
  ZeroMemory(@Startup2, SizeOf(TStartupInfo));
  ZeroMemory(@ProcInf1, SizeOf(TProcessInformation));
  ZeroMemory(@ProcInf2, SizeOf(TProcessInformation));

  ///////////////////////////////////////////////////////////////////////////
  // Parse commandline args
  ///////////////////////////////////////////////////////////////////////////

  b := False;

  Params1 := TStringList.Create;
  Params2 := TStringList.Create;

  for i := 1 to ParamCount do
  begin
    if SameText(Trim(ParamStr(i)), Separator) then
    begin
      if (not b) then
      begin
        b := True;
        Continue;
      end;
      if ParamStr(i+1) <> '' then
      begin
        BuffSize := StrToIntDef(ParamStr(i+1),0);
      end;
      Break;
    end;
    if (not b) then
    begin
      Params1.Add(ParamStr(i));
    end else begin
      Params2.Add(ParamStr(i));
    end;
  end;

  if (Params1.Count < 1) or (Params2.Count < 1) then
  begin
    WriteLn;
    WriteLn(Format('PipeBuffer by LoRd_MuldeR <mulder2@gmx.de>, Version %d.%0.2d', [VerMajor,VerMinor]));
    WriteLn;
    WriteLn('Usage:');
    WriteLn('  pipebuf.exe <program_out> [<args>] ' + Separator + ' <program_in> [<args>] ' + Separator + ' [<buffer_size>]');
    WriteLn;
    WriteLn('Options:');
    WriteLn('  <program_out>  Executable to read stdout from');
    WriteLn('  <program_in>   Executable to write stdin to');
    WriteLn('  <args>         Optional command-line arguments');
    WriteLn('  <buffer_size>  Pipe buffer in MByte [0]');
    WriteLn;
    Params1.Free;
    Params2.Free;
    Flush(Output);
    ExitProcess(DWORD(-1));
  end;

  ///////////////////////////////////////////////////////////////////////////
  // Build commandlines
  ///////////////////////////////////////////////////////////////////////////

  Command1 := '';
  Command2 := '';

  for i := 0 to Params1.Count-1 do
  begin
    if Command1 <> '' then Command1 := Command1 + ' ';
    if pos(' ', Params1[i]) <> 0 then
    begin
      Command1 := Command1 + '"' + Params1[i] + '"';
    end else begin
      Command1 := Command1 + Params1[i];
    end;
  end;

  for i := 0 to Params2.Count-1 do
  begin
    if Command2 <> '' then Command2 := Command2 + ' ';
    if pos(' ', Params2[i]) <> 0 then
    begin
      Command2 := Command2 + '"' + Params2[i] + '"';
    end else begin
      Command2 := Command2 + Params2[i];
    end;
  end;

  Params1.Free;
  Params2.Free;

  ///////////////////////////////////////////////////////////////////////////
  // Create the pipe
  ///////////////////////////////////////////////////////////////////////////

  StdOut := GetStdHandle(Windows.STD_OUTPUT_HANDLE);
  StdIn := GetStdHandle(Windows.STD_INPUT_HANDLE);
  StdErr := GetStdHandle(Windows.STD_ERROR_HANDLE);

  if (StdOut = INVALID_HANDLE_VALUE) or (StdIn = INVALID_HANDLE_VALUE) or (StdErr = INVALID_HANDLE_VALUE) then
  begin
    WriteLn;
    WriteLn('Error: Couldn''t get standard handles!');
    WriteLn;
    Flush(Output);
    ExitProcess(DWORD(-1));
  end;

  if not CreatePipe(PipeRead, PipeWrite, nil, 1048576 * BuffSize) then
  begin
    WriteLn;
    WriteLn('Error: Pipe creation failed!');
    WriteLn;
    Flush(Output);
    ExitProcess(DWORD(-1));
  end;

  ///////////////////////////////////////////////////////////////////////////
  // Create first process
  ///////////////////////////////////////////////////////////////////////////

  if not DuplicateHandle(GetCurrentProcess, PipeWrite, GetCurrentProcess, @PipeInherit, 0, True, DUPLICATE_SAME_ACCESS) then
  begin
    WriteLn;
    WriteLn('Error: Couldn''t duplicate handle!');
    WriteLn;
    CloseHandle(PipeWrite);
    CloseHandle(PipeRead);
    Flush(Output);
    ExitProcess(DWORD(-1));
  end;

  CloseHandle(PipeWrite);

  Startup1.dwFlags := STARTF_USESTDHANDLES;
  Startup1.hStdInput := StdIn;
  Startup1.hStdOutput := PipeInherit;
  Startup1.hStdError := StdErr;

  if not CreateProcess(nil, PAnsiChar(Command1), nil, nil, True, 0, nil, nil, Startup1, ProcInf1) then
  begin
    WriteLn;
    WriteLn('Failed to create process:');
    WriteLn(Command1);
    if FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError, 0 , @a[0], 1024, nil) > 0 then
    begin
      Write(a);
    end;
    WriteLn;
    CloseHandle(PipeInherit);
    CloseHandle(PipeRead);
    Flush(Output);
    ExitProcess(DWORD(-1));
  end;

  CloseHandle(ProcInf1.hThread);
  CloseHandle(PipeInherit);

  ///////////////////////////////////////////////////////////////////////////
  // Create second process
  ///////////////////////////////////////////////////////////////////////////

  if not DuplicateHandle(GetCurrentProcess, PipeRead, GetCurrentProcess, @PipeInherit, 0, True, DUPLICATE_SAME_ACCESS) then
    begin
    WriteLn;
    WriteLn('Error: Couldn''t duplicate handle!');
    WriteLn;
    CloseHandle(PipeRead);
    Flush(Output);
    ExitProcess(DWORD(-1));
  end;

  CloseHandle(PipeRead);

  Startup2.dwFlags := STARTF_USESTDHANDLES;
  Startup2.hStdInput := PipeInherit;
  Startup2.hStdOutput := StdOut;
  Startup2.hStdError := StdErr;

  if not CreateProcess(nil, PAnsiChar(Command2), nil, nil, True, 0, nil, nil, Startup2, ProcInf2) then
  begin
    WriteLn;
    WriteLn('Failed to create process:');
    WriteLn(Command2);
    if FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError, 0 , @a[0], 1024, nil) > 0 then
    begin
      Write(a);
    end;
    WriteLn;
    CloseHandle(PipeInherit);
    TerminateProcess(ProcInf1.hProcess,DWORD(-1));
    CloseHandle(ProcInf1.hProcess);
    Flush(Output);
    ExitProcess(DWORD(-1));
  end;

  CloseHandle(ProcInf2.hThread);
  CloseHandle(PipeInherit);

  ///////////////////////////////////////////////////////////////////////////
  // Wait for processes to terminate
  ///////////////////////////////////////////////////////////////////////////

  if ProcInf1.hProcess <> INVALID_HANDLE_VALUE then
  begin
    WaitForSingleObject(ProcInf1.hProcess, INFINITE);
    GetExitCodeProcess(ProcInf1.hProcess,ExitCode);
    CloseHandle(ProcInf1.hProcess);
  end;

  if ProcInf2.hProcess <> INVALID_HANDLE_VALUE then
  begin
    WaitForSingleObject(ProcInf2.hProcess, INFINITE);
    GetExitCodeProcess(ProcInf2.hProcess,ExitCode);
    CloseHandle(ProcInf2.hProcess);
  end;

  Flush(Output);
  ExitProcess(ExitCode);
end.
