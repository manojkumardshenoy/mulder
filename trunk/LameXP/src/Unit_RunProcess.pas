///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2009 LoRd_MuldeR <MuldeR2@GMX.de>
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

///////////////////////////////////////////////////////////////////////////////
// The code in this file was inspired by the following article:
// http://support.microsoft.com/kb/190351
///////////////////////////////////////////////////////////////////////////////

unit Unit_RunProcess;

//-----------------------------------------------------------------------------
interface
//-----------------------------------------------------------------------------

uses
  SysUtils, Classes, Windows;

type
  TProcessPriority = (ppIdle, ppBelowNormal, ppNormal, ppAboveNormal, ppHigh, ppCritical);
  TProcessResult = (procDone, procFaild, procError, procAborted);
  TProcessOutputFilter = function(const S: String): Boolean of object;

type
  TRunProcess = class(TObject)
  public
    Directory: String;
    ExitCode: Cardinal;
    Priority: TProcessPriority;
    HideConsole: Boolean;
    CommandShellMode: Boolean;
    Filter: TProcessOutputFilter;
    ConvertOemToChar: Boolean;
    JobControl: Boolean;
    constructor Create;
    destructor Destroy; override;
    function Execute(const CmdLine: String): TProcessResult;
    procedure Kill(const ForceExitCode: DWORD; const KillEntireJob: Boolean);
    function StillRunning: Boolean;
    function GetHandle: Cardinal;
    procedure AddToLog(const TextMessage: String);
    procedure GetLog(const Log: TStringList);
    function SuspendProcess: Boolean;
    function ResumeProcess: Boolean;
    function SuspendJob: Boolean;
    function ResumeJob: Boolean;
  protected
    Log: TStringList;
  private
    Aborted: Boolean;
    Running: Boolean;
    Suspended: Boolean;
    ClientProcess: Cardinal;
    ClientId: Cardinal;
    ReadPipe: THandle;
    Output: AnsiString;
    FilterCache: String;
    TotalRead: Cardinal;
    procedure FetchConsoleOutput;
    procedure ProcessOutput;
    procedure ProcessLine(const Line: String);
  end;

function KillRunningJobs: Boolean;
function GetPeakJobMemoryUsed: Cardinal;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
implementation
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

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
  TThreadEntry32 = record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ThreadID: DWORD;
    th32OwnerProcessID: DWORD;
    tpBasePri: Longint;
    tpDeltaPri: Longint;
    dwFlags: DWORD;
  end;
  PThreadEntry32 = ^TThreadEntry32;
  TProcessIdList = array [0..255] of DWORD;
  PProcessIdList = ^TProcessIdList;
  TJobObjectProcessList = record
    NumberOfAssignedProcesses: DWORD;
    NumberOfProcessIdsInList: DWORD;
    ProcessIdList: TProcessIdList;
  end;
  PJobObjectProcessList = ^TJobObjectProcessList;

type
  TCreateJobObject = function(JobAttributes: PSecurityAttributes; Name: PAnsiChar): THandle; stdcall;
  TAssignProcessToJobObject = function(Job: THandle; Process: THandle): LongBool; stdcall;
  TSetInformationJobObject = function(Job: THandle; InfoClass: DWORD; JobObjectInfo: PJobObjectExtendedLimitInformation; ObjectInfoLength: DWORD): LongBool; stdcall;
  TQueryInformationJobObject = function(Job: THandle; InfoClass: DWORD; JobObjectInfo: PJobObjectExtendedLimitInformation; ObjectInfoLength: DWORD; RetrunLength: LPDWORD): LongBool; stdcall;
  TTerminateJobObject = function(Job: THandle; ExitCode: DWORD): LongBool; stdcall;
  TOpenThread = function(Access: DWORD; InheritHandle: Boolean; TID:DWORD): THandle; stdcall;
  TCreateToolhelp32Snapshot = function(dwFlags: DWORD; th32ProcessID: DWORD): THandle stdcall;
  TThread32First = function(hSnapshot: THandle; lpte: PThreadEntry32): BOOL; stdcall;
  TThread32Next = function(hSnapshot: THandle; lpte: PThreadENtry32): BOOL; stdcall;

const
  JOBOBJECT_EXTENDED_LIMIT_INFORMATION: DWORD = 9;
  JOBOBJECT_BASIC_PROCESS_ID_LIST = 3;
  JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION: DWORD = $00000400;
  JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE: DWORD = $00002000;
  THREAD_SUSPEND_RESUME = $00000002;
  TH32CS_SNAPTHREAD = $00000004;
  
var
  Lib_Kernel32: HModule;
  JobObjectHandle: THandle;
  Proc_CreateJobObject: TCreateJobObject;
  Proc_AssignProcessToJobObject: TAssignProcessToJobObject;
  Proc_SetInformationJobObject: TSetInformationJobObject;
  Proc_QueryInformationJobObject: TQueryInformationJobObject;
  Proc_TerminateJobObject: TTerminateJobObject;
  Proc_OpenThread: TOpenThread;
  Proc_CreateToolhelp32Snapshot: TCreateToolhelp32Snapshot;
  Proc_Thread32First: TThread32First;
  Proc_Thread32Next: TThread32Next;
  CriticalSectionObject: TRTLCriticalSection;
  JobObjectSuspended: Boolean;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

procedure InitializeTheJobObject;
var
  JobObjectExtendedLimitInformation: TJobObjectExtendedLimitInformation;

  procedure InitProcedure(var Proc: Pointer; Name: PAnsiChar);
  begin
    if Proc = nil then
    begin
      Proc := GetProcAddress(Lib_Kernel32, Name);
    end;
  end;
  
begin
  if JobObjectHandle <> 0 then
  begin
    Exit;
  end;

  if Lib_Kernel32 = 0 then
  begin
    Lib_Kernel32 := SafeLoadLibrary(kernel32);
  end;

  if Lib_Kernel32 <> 0 then
  begin
    InitProcedure(@Proc_CreateJobObject, 'CreateJobObjectA');
    InitProcedure(@Proc_AssignProcessToJobObject, 'AssignProcessToJobObject');
    InitProcedure(@Proc_SetInformationJobObject, 'SetInformationJobObject');
    InitProcedure(@Proc_QueryInformationJobObject, 'QueryInformationJobObject');
    InitProcedure(@Proc_TerminateJobObject, 'TerminateJobObject');
    InitProcedure(@Proc_OpenThread, 'OpenThread');
    InitProcedure(@Proc_CreateToolhelp32Snapshot, 'CreateToolhelp32Snapshot');
    InitProcedure(@Proc_Thread32First, 'Thread32First');
    InitProcedure(@Proc_Thread32Next, 'Thread32Next');
  end;

  if Assigned(Proc_CreateJobObject) then
  begin
    JobObjectHandle := Proc_CreateJobObject(nil, nil);
  end;

  if Assigned(Proc_SetInformationJobObject) and (JobObjectHandle <> 0) then
  begin
    FillChar(JobObjectExtendedLimitInformation, SizeOf(TJobObjectExtendedLimitInformation), #0);
    JobObjectExtendedLimitInformation.BasicLimitInformation.LimitFlags := JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE or JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION;
    Proc_SetInformationJobObject(JobObjectHandle, JOBOBJECT_EXTENDED_LIMIT_INFORMATION, @JobObjectExtendedLimitInformation, SizeOf(TJobObjectExtendedLimitInformation));
  end;
end;

function KillRunningJobs: Boolean;
begin
  if Assigned(Proc_TerminateJobObject) and (JobObjectHandle <> 0) then
  begin
    Result := Proc_TerminateJobObject(JobObjectHandle, 42);
    CloseHandle(JobObjectHandle);
    JobObjectHandle := 0;
  end else begin
    Result := False;
  end;
end;

function GetPeakJobMemoryUsed: Cardinal;
var
  JobObjectExtendedLimitInformation: TJobObjectExtendedLimitInformation;
begin
  Result := 0;

  if Assigned(Proc_QueryInformationJobObject) and (JobObjectHandle <> 0) then
  begin
    FillChar(JobObjectExtendedLimitInformation, SizeOf(TJobObjectExtendedLimitInformation), #0);
    if Proc_QueryInformationJobObject(JobObjectHandle, JOBOBJECT_EXTENDED_LIMIT_INFORMATION, @JobObjectExtendedLimitInformation, SizeOf(TJobObjectExtendedLimitInformation), nil) then
    begin
      Result := JobObjectExtendedLimitInformation.PeakJobMemoryUsed;
    end;
  end;
end;

function SuspendProcesses(const ProcessId: PProcessIdList; const ProcessCount: Integer; const Suspend: Boolean): Boolean;
var
  i: Integer;
  SnapShot: THandle;
  ThreadEntry: TThreadEntry32;
  ThreadHandle: THandle;
begin
   Result := False;

   if not (Assigned(Proc_OpenThread) and Assigned(Proc_CreateToolhelp32Snapshot) and Assigned(Proc_Thread32First) and Assigned(Proc_Thread32Next)) then
   begin
     Exit;
   end;  

   SnapShot := Proc_CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);

   if (SnapShot = INVALID_HANDLE_VALUE) then
   begin
     Exit;
   end;

   ThreadEntry.dwSize := SizeOf(TThreadEntry32);

   if not Proc_Thread32First(SnapShot, @ThreadEntry) then
   begin
     CloseHandle(SnapShot);
     Exit;
   end;

   repeat
     for i := 0 to ProcessCount-1 do
     begin
       if ThreadEntry.th32OwnerProcessID = ProcessId[i] then
       begin
         ThreadHandle := Proc_OpenThread(THREAD_SUSPEND_RESUME, False, ThreadEntry.th32ThreadID);
         if ThreadHandle <> 0 then
         begin
           if Suspend then
           begin
             if SuspendThread(ThreadHandle) <> DWORD(-1) then Result := True;
           end else begin
             if ResumeThread(ThreadHandle) <> DWORD(-1) then Result := True;
           end;
           CloseHandle(ThreadHandle);
         end;
       end;
     end;
   until
     not Proc_Thread32Next(SnapShot, @ThreadEntry);

   CloseHandle(SnapShot);
end;

function SuspendJobObject(const Suspend: Boolean): Boolean;
var
  JobObjectProcessList: TJobObjectProcessList;
begin
  Result := False;

  if (Suspend = JobObjectSuspended) then
  begin
    Exit;
  end;

  if Assigned(Proc_QueryInformationJobObject) and (JobObjectHandle <> 0) then
  begin
    FillChar(JobObjectProcessList, SizeOf(TJobObjectProcessList), #0);
    if Proc_QueryInformationJobObject(JobObjectHandle, JOBOBJECT_BASIC_PROCESS_ID_LIST, @JobObjectProcessList, SizeOf(TJobObjectProcessList), nil) then
    begin
      Result := SuspendProcesses(@JobObjectProcessList.ProcessIdList, JobObjectProcessList.NumberOfProcessIdsInList, Suspend);
    end;
  end;

  if Result then
  begin
    JobObjectSuspended := Suspend;
  end;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

constructor TRunProcess.Create;
begin
  Directory := '';
  Priority := ppNormal;
  Log := TStringList.Create;

  Running := False;
  Aborted := False;
  ClientProcess := 0;
  ClientId := 0;
  ReadPipe := 0;
  ExitCode := 0;
  Output := '';
  Filter := nil;
  FilterCache := '';
  TotalRead := 0;
  HideConsole := True;
  CommandShellMode := False;
  ConvertOemToChar := False;
  JobControl := True;

  EnterCriticalSection(CriticalSectionObject);
  try
    InitializeTheJobObject;
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

destructor TRunProcess.Destroy;
begin
  Log.Free;
  inherited;
end;

function TRunProcess.Execute(const CmdLine: String): TProcessResult;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  SecAttr: TSecurityAttributes;
  Success: boolean;
  Flags: Cardinal;
  InitDir: PAnsiChar;
  WritePipe: THandle;
  ErrorPipe: THandle;
  ReadPipeTemp: THandle;
const
  CREATE_BREAKAWAY_FROM_JOB: Cardinal = $01000000;
begin
  // Only one thread can create a process at a time
  EnterCriticalSection(CriticalSectionObject);

  // Is the process running already?
  if (ClientProcess <> 0) or Running then
  begin
    Result := procFaild;
    LeaveCriticalSection(CriticalSectionObject);
    Exit;
  end;

  // Initialize varibales
  Flags := 0;
  InitDir := nil;
  Aborted := False;
  Suspended := False;
  Output := '';
  FilterCache := '';
  ReadPipeTemp := 0;
  ReadPipe := 0;
  WritePipe := 0;
  ErrorPipe := 0;
  TotalRead := 0;

  FillChar(ProcInfo, sizeof(TProcessInformation),0);
  FillChar(StartInfo, SizeOf(TStartupInfo), 0);
  StartInfo.cb := SizeOf(TStartupInfo);

  // Create pipe for redirecting STDOUT/STDERR and make sure the child process will use it
  if HideConsole then
  begin
    with SecAttr do
    begin
      nLength := SizeOf(SecAttr);
      lpSecurityDescriptor := nil;
      bInheritHandle := True; // Pipe handles must be inheritable
    end;

    // We use an unnamed pipe to redirect STDOUT and STDERR from the child process
    if CreatePipe(ReadPipeTemp,WritePipe,@SecAttr,0) then
    begin
      Flags := Flags or CREATE_NO_WINDOW;

      // Redirect STDOUT to our "write" handle
      StartInfo.dwFlags := STARTF_USESTDHANDLES;
      StartInfo.hStdOutput := WritePipe;

      // Redirect STDERR to a duplicate of our "write" handle
      if DuplicateHandle(GetCurrentProcess, WritePipe, GetCurrentProcess, @ErrorPipe, 0, True, DUPLICATE_SAME_ACCESS) then
      begin
        StartInfo.hStdError := ErrorPipe;
      end;

      // Create a none-inheritable duplicate of the "read" handle
      if not DuplicateHandle(GetCurrentProcess, ReadPipeTemp, GetCurrentProcess, @ReadPipe, 0, False, DUPLICATE_SAME_ACCESS) then
      begin
        ReadPipe := 0;
      end;

      // Now close the inheritable "read" handle, we'll use the none-inheritable duplicate instead
      CloseHandle(ReadPipeTemp);
    end;
  end;

  case Priority of
    ppIdle: Flags := Flags or IDLE_PRIORITY_CLASS;
    ppBelowNormal: Flags := Flags or $00004000;
    ppAboveNormal: Flags := Flags or $00008000;
    ppHigh: Flags := Flags or HIGH_PRIORITY_CLASS;
    ppCritical: Flags := Flags or REALTIME_PRIORITY_CLASS;
  end;

  if Directory <> '' then
  begin
    InitDir := PAnsiChar(Directory);
  end;

  // Supend proccess until it has been added to te JobObject
  if JobControl and Assigned(Proc_AssignProcessToJobObject) and (JobObjectHandle <> 0) then
  begin
    Flags := Flags or CREATE_SUSPENDED or CREATE_BREAKAWAY_FROM_JOB;
  end;

  // If the job object has been suspended, resume it now
  if JobControl and (JobObjectHandle <> 0) and JobObjectSuspended then
  begin
    SuspendJobObject(False);
    JobObjectSuspended := False;
  end;

  // Create the child process with "InheritHandles" enabled
  if CommandShellMode then
  begin
    Success := CreateProcess(nil,PAnsiChar('cmd.exe /c "' + CmdLine + '"'),nil,nil,true,Flags,nil,InitDir,StartInfo,ProcInfo);
  end else begin
    Success := CreateProcess(nil,PAnsiChar(CmdLine),nil,nil,true,Flags,nil,InitDir,StartInfo,ProcInfo);
  end;

  // We must close the "write" handles in the parent process now, otherwise we will encounter deadlocks (why?)
  if HideConsole then
  begin
    CloseHandle(WritePipe);
    WritePipe := 0;
    CloseHandle(ErrorPipe);
    ErrorPipe := 0;
  end;

  // Check whether the child process was created or not
  if not Success then begin
    Log.Add('FAILED TO CREATE PROCESS !!!');
    Result := procFaild;
    if HideConsole then
    begin
      CloseHandle(ReadPipe);
      ReadPipe := 0;
    end;
    LeaveCriticalSection(CriticalSectionObject);
    Exit;
  end;

  // Add Process to JobObject
  if JobControl and Assigned(Proc_AssignProcessToJobObject) and (JobObjectHandle <> 0) then
  begin
    Proc_AssignProcessToJobObject(JobObjectHandle, ProcInfo.hProcess);
    ResumeThread(ProcInfo.hThread);
  end;

  Running := True;
  Suspended := False;
  ExitCode := STILL_ACTIVE;
  ClientProcess := ProcInfo.hProcess;
  ClientId := ProcInfo.dwProcessId;

  // Release mutex
  LeaveCriticalSection(CriticalSectionObject);

  // Capture STDOUT and STDERR now (will not return until the child process terminates)
  if HideConsole then
  begin
    FetchConsoleOutput;
  end;

  // Wait for the process to terimate
  WaitForSingleObject(ClientProcess, INFINITE);
  GetExitCodeProcess(ClientProcess, ExitCode);

  // Only one thread can destroy a process at a time
  EnterCriticalSection(CriticalSectionObject);

  // We are done, so let's close our "read" handle now
  if HideConsole then
  begin
    CloseHandle(ReadPipe);
    ReadPipe := 0;

    if Length(FilterCache) > 0 then
    begin
      Log.Add(FilterCache);
      FilterCache := '';
    end;

    try
      Log.Add('');
      Log.Add('BYTES CAPTURED: ' + IntToStr(TotalRead));
    except
      MessageBeep(MB_ICONERROR);
    end;
  end;

  // Finally close the thread and process handles
  CloseHandle(ProcInfo.hThread);
  CloseHandle(ProcInfo.hProcess);

  Running := False;
  ClientId := 0;
  ClientProcess := 0;
  Filter := nil;

  if Aborted then begin
    try
      Log.Add('');
      Log.Add('PROCESS WAS ABORTED !!!');
    except
      MessageBeep(MB_ICONERROR);
    end;
    Result := procAborted;
    LeaveCriticalSection(CriticalSectionObject);
    Exit;
  end;

  try
    if not HideConsole then Log.Add('');
    Log.Add('EXIT CODE: ' + IntToStr(ExitCode));
  except
    MessageBeep(MB_ICONERROR);
  end;

  // Release mutex
  LeaveCriticalSection(CriticalSectionObject);

  case ExitCode of
    0: Result := procDone
  else
    Result := procError;
  end;
end;

procedure TRunProcess.FetchConsoleOutput;
const
  BuffSize = 4096;
var
  Buffer: array [0..BuffSize] of Char;
  BytesRead: Cardinal;
begin
  Output := '';

  repeat
    if not ReadFile(ReadPipe, Buffer, BuffSize, BytesRead, nil) then Break;
    TotalRead := TotalRead + BytesRead;
    Buffer[BytesRead] := #0;
    if ConvertOemToChar then
    begin
      OemToChar(Buffer,Buffer);
    end;  
    Output := Output + Buffer;
    ProcessOutput;
  until
    BytesRead = 0;
end;

procedure TRunProcess.ProcessOutput;
var
  i: Integer;
  Marker: Integer;
begin
  Marker := 1;

  for i := 0 to Length(Output) do
  begin
    if (Ord(Output[i]) < 32) then
    begin
      if i > Marker then
      begin
        ProcessLine(Copy(Output, Marker, i-Marker));
      end;
      Marker := i+1;
    end;
  end;

  Output := Copy(Output, Marker, Length(Output));
end;

procedure TRunProcess.ProcessLine(const Line: String);
begin
  if not Assigned(Filter) then
  begin
    Log.Add(Line);
    Exit;
  end;

  if Filter(Line) then
  begin
    if Length(FilterCache) > 0 then
    begin
      Log.Add(FilterCache);
      FilterCache := '';
    end;
    Log.Add(Line);
  end else begin
    if Length(FilterCache) = 0 then
    begin
      Log.Add(Line);
    end;
    FilterCache := Line;
  end;
end;

procedure TRunProcess.Kill(const ForceExitCode: DWORD; const KillEntireJob: Boolean);
begin
  EnterCriticalSection(CriticalSectionObject);
  try
    if Running then
    begin
      Aborted := True;
      Running := False;
      if(ClientProcess <> 0) then
      begin
        TerminateProcess(ClientProcess, ForceExitCode);
      end;
    end;
    if KillEntireJob then
    begin
      KillRunningJobs;
    end;
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

function TRunProcess.StillRunning: Boolean;
begin
  EnterCriticalSection(CriticalSectionObject);
  try
    Result := Running;
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

function TRunProcess.GetHandle: Cardinal;
begin
  EnterCriticalSection(CriticalSectionObject);
  try
    Result := ClientProcess;
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

procedure TRunProcess.AddToLog(const TextMessage: String);
begin
  EnterCriticalSection(CriticalSectionObject);
  try
    if (not Running) then
    begin
      Log.Add(TextMessage);
    end;
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

procedure TRunProcess.GetLog(const Log: TStringList);
begin
  EnterCriticalSection(CriticalSectionObject);
  try
    if (not Running) then
    begin
      Log.AddStrings(self.Log);
    end;
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

function TRunProcess.SuspendProcess: Boolean;
var
  ProcList: TProcessIdList;
begin
  Result := False;

  EnterCriticalSection(CriticalSectionObject);
  try
    if (not Suspended) and (ClientId <> 0) then
    begin
      ProcList[0] := ClientId;
      Result := SuspendProcesses(@ProcList, 1, True);
      if Result then Suspended := True;
    end;
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

function TRunProcess.ResumeProcess: Boolean;
var
  ProcList: TProcessIdList;
begin
  Result := False;

  EnterCriticalSection(CriticalSectionObject);
  try
    if Suspended and (ClientId <> 0) then
    begin
      ProcList[0] := ClientId;
      Result := SuspendProcesses(@ProcList, 1, False);
      if Result then Suspended := False;
    end;
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

function TRunProcess.SuspendJob: Boolean;
begin
  EnterCriticalSection(CriticalSectionObject);
  try
    Result := SuspendJobObject(True);
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

function TRunProcess.ResumeJob: Boolean;
begin
  EnterCriticalSection(CriticalSectionObject);
  try
    Result := SuspendJobObject(False);
  finally
    LeaveCriticalSection(CriticalSectionObject);
  end;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

initialization
  InitializeCriticalSection(CriticalSectionObject);
  Lib_Kernel32 := 0;
  JobObjectHandle := 0;
  JobObjectSuspended := False;
  Proc_CreateJobObject := nil;
  Proc_AssignProcessToJobObject := nil;
  Proc_SetInformationJobObject := nil;
  Proc_QueryInformationJobObject := nil;
  Proc_TerminateJobObject := nil;
  Proc_OpenThread := nil;
  Proc_CreateToolhelp32Snapshot := nil;
  Proc_Thread32First := nil;
  Proc_Thread32Next := nil;

finalization
  KillRunningJobs;
  CloseHandle(JobObjectHandle);
  DeleteCriticalSection(CriticalSectionObject);
  JobObjectHandle := 0;
  FreeLibrary(Lib_Kernel32);

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

end.
