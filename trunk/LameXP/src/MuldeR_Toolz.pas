///////////////////////////////////////////////////////////////////////////////
// MuldeR's Delphi Toolz
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

unit MuldeR_Toolz;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
interface
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

uses
  Windows, SysUtils, StrUtils, Classes, ShFolder, ShellAPI, ShlObj, ComObj, ActiveX;

//-----------------------------------------------------------------------------

type
  TExecWaitPriority = (ewpNormal, ewpBelowNormal, ewpHigh, ewpIdle, ewpRealtime);

//-----------------------------------------------------------------------------

function CheckFileName(const FileName: String): String;
procedure CreateShortcut(const PathTarget: String; const PathShortcut: String; const Desc: String; const Params: String);
function ExecWait(const Commandline: String; const Hidden:Boolean; const LogFile:String; const Priority: TExecWaitPriority): DWORD;
function ExpandEnvStr(const EnvStr: String): String;
function ExplodeStr(const Separator: String; const Text: String): TStringList;
function ExtractDirectory(const FullPath: String): String;
function ExtractExtension(const FileName: String): String;
function ExtractFileName(const FullPath: String): String;
function GetAppDirectory: String;
function GetAppVerStr(const Keys: array of String; var Values:array of String): Boolean; overload;
function GetAppVerStr(var VerInfo:VS_FIXEDFILEINFO): Boolean; overload;
function GetAppVerStr(const VerStr: String): String; overload;
function GetFreeDiskspace(const Root: String): Int64;
function GetFullPath(const ShortPath: String): String;
function GetLastErrorMsg: String;
function GetShellDirectory(const Folder_CSIDL: DWORD): String;
function GetShortPath(const LongPath: String): String;
function GetSysDirectory:String;
function GetSystemLanguage: String;
function GetTempDirectory:String;
function GetTempFile(const Directory: String; const Prefix: String; const Extension: String): String;
function GetWinDirectory: String;
procedure HandleURL(const URL: String);
function IntToStrEx(const Value: Int64; const Digits:Integer): String; overload;
function IntToStrEx(const Value: Integer; const Digits:Integer): String; overload;
function IsDebuggerPresent: Boolean;
function IsDriveReady(const Path: String): Boolean;
function IsFixedDrive(const Path: String):Boolean;
function IsWow64Process: Boolean;
function MakeTempFolder(const RootDirectory: String; const Prefix: String; const Extension: String): String;
function MsgBox(const Parent: THandle; const Text: String; const Title: String; const Flags: Cardinal): Cardinal; overload;
function MsgBox(const Text: String): Cardinal; overload;
function MsgBox(const Text: String; const Flags: Cardinal): Cardinal; overload;
function MsgBox(const Text: String; const Title: String; const Flags: Cardinal): Cardinal; overload;
function RemoveExtension(const FileName: String): String;
function RemoveFile(const FileName: String): Boolean;
function ReplaceSubStr(const Str: String; const SubStr: String; const NewStr: String): String;
function SafeDirectoryExists(const Path: String): Boolean;
function SearchFiles(const Filter: String; const ReturnFullPath: Boolean): TStringList;
function StrEq(const Str1: String; const Str2: String): Boolean; deprecated;
function StrToAnsi(const Str: String): String;
function StrToOem(const Str: String): String;
function TokenizeStr(const Separators: String; const Text: String): TStringList;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
implementation
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//--- Dynamically loaded libraries ---//
var
  DLL_Kernel: HMODULE;
  DLL_URL: HMODULE;

//--- Dynamically allocated Win32 API functions ---//
type
  TIsDebuggerPresenProc = function:Boolean; stdcall;
  TFileProtocolHandler = procedure(Handle: HWND; HInstance: HINST; Command: PAnsiChar; Show: Integer); stdcall;
  TIsWow64ProcessProc = function(hProcess: THANDLE; Wow64Process:PBOOL):Boolean; stdcall;
var
  IsDebuggerPresenProc: TIsDebuggerPresenProc;
  FileProtocolHandlerProc: TFileProtocolHandler;
  IsWow64ProcessProc: TIsWow64ProcessProc;

//--- Critical Section for Thread-Safety ---//
var
  CriticalSectionObject: TRTLCriticalSection;

//-----------------------------------------------------------------------------
// Internal Support Functions
//-----------------------------------------------------------------------------

procedure MyInitLibraray(var h: HMODULE; Name: String);
begin
  EnterCriticalSection(CriticalSectionObject);
  if h = 0 then
  begin
    h := SafeLoadLibrary(PAnsiChar(Name));
  end;
  LeaveCriticalSection(CriticalSectionObject);
end;

procedure MyFreeLibrary(var h: HMODULE);
begin
  EnterCriticalSection(CriticalSectionObject);
  if h <> 0 then
  begin
    FreeLibrary(h);
    h := 0;
  end;
  LeaveCriticalSection(CriticalSectionObject);
end;

procedure MyInitFunction(h: HMODULE; Name: String; var p: Pointer);
begin
  EnterCriticalSection(CriticalSectionObject);
  if (not Assigned(p)) and (h <> 0) then
  begin
    p := GetProcAddress(h, PAnsiChar(Name));
  end;
  LeaveCriticalSection(CriticalSectionObject);
end;

function MyInitBuffer(var Buffer: PAnsiChar; Size: Cardinal): Cardinal;
begin
  try
    Buffer := AllocMem(Size + 2);
    Result := Size + 1;
  except
    Buffer := nil;
    Result := 0;
  end;
end;

procedure MyFreeBuffer(var Buffer: PAnsiChar);
begin
  if Buffer <> nil then
  begin
    FreeMem(Buffer);
    Buffer := nil;
  end;
end;

//-----------------------------------------------------------------------------
// External Functions
//-----------------------------------------------------------------------------

function CheckFileName(const FileName: String): String;
var
  i:Integer;
  s: String;
  b: Boolean;
begin
  s := FileName;

  if Length(s) < 1 then begin
    Result := s;
    Exit;
  end;

  for i := 1 to Length(s) do begin
    b := False;

    if s[i] = '?' then b := True;
    if s[i] = '*' then b := True;
    if s[i] = '/' then b := True;
    if s[i] = '\' then b := True;
    if s[i] = '"' then b := True;
    if s[i] = '<' then b := True;
    if s[i] = '>' then b := True;
    if s[i] = '|' then b := True;
    if s[i] = ':' then b := True;

    if b then s[i] := '_';
  end;

  Result := s;
end;

//-----------------------------------------------------------------------------

function ExtractDirectory(const FullPath: String): String;
var
  s: String;
  x,i: Integer;
begin
  s := FullPath;

  if s = '' then
  begin
    Result := '';
    Exit;
  end;

  x := Length(s) + 1;

  for i := Length(s) downto 1 do
  begin
    if (s[i] = '\') or (s[i] = '/') then
    begin
      x := i;
      Break;
    end;
  end;

  Result := Copy(s, 1, x - 1);
end;

//-----------------------------------------------------------------------------

function ExtractFileName(const FullPath: String): String;
var
  x,i: Integer;
begin
  x := 0;

  for i := Length(FullPath) downto 1 do
  begin
    if (FullPath[i] = '\') or (FullPath[i] = '/') or (FullPath[i] = ':') then
    begin
      x := i;
      Break;
    end;
  end;

  Result := Copy(FullPath, x+1, Length(FullPath));
end;

//-----------------------------------------------------------------------------

function RemoveExtension(const FileName: String): String;
var
  i,x: Integer;
  s: String;
begin
  s := ExtractFileName(FileName);
  if Length(s) < 1 then Result := s;

  x := 0;
  for i := Length(s) downto 1 do
    if s[i] = '.' then begin
      x := i;
      break;
    end;

  if x > 1
    then Result := Copy(s,1,x-1)
    else Result := s;
end;

function ExtractExtension(const FileName: String): String;
var
  i,x: Integer;
  s: String;
begin
  s := ExtractFileName(FileName);
  if Length(s) < 1 then Result := s;

  x := 0;
  for i := Length(s) downto 1 do
    if s[i] = '.' then begin
      x := i;
      break;
    end;

  if x > 1
    then Result := Copy(s,x+1,Length(s)-x)
    else Result := s;
end;

//-----------------------------------------------------------------------------

function IntToStrEx(const Value: Integer; const Digits:Integer): String;
var
  s: String;
begin
  s := IntToStr(Value);
  while Length(s) < Digits do s := '0' + s;
  Result := s;
end;

function IntToStrEx(const Value: Int64; const Digits: Integer): String;
var
  s: String;
begin
  s := IntToStr(Value);
  while Length(s) < Digits do s := '0' + s;
  Result := s;
end;

//-----------------------------------------------------------------------------

function StrEq(const Str1: String; const Str2: String): Boolean;
begin
  Result := SameText(Str1, Str2);
end;

//-----------------------------------------------------------------------------

function GetAppDirectory:String;
begin
  Result := ExtractDirectory(ParamStr(0));
end;

function GetWinDirectory:String;
var
  Buffer: PAnsiChar;
  Length: Cardinal;
begin
  Result := '';
  Length := MyInitBuffer(Buffer, GetWindowsDirectory(nil, 0));
  SetString(Result, Buffer, GetWindowsDirectory(Buffer, Length));
  MyFreeBuffer(Buffer);
  if Result = '' then Result := '?';
end;

function GetSysDirectory:String;
var
  Buffer: PAnsiChar;
  Length: Cardinal;
begin
  Result := '';
  Length := MyInitBuffer(Buffer, GetSystemDirectory(nil, 0));
  SetString(Result, Buffer, GetSystemDirectory(Buffer, Length));
  MyFreeBuffer(Buffer);
  if Result = '' then Result := '?';
end;

function GetTempDirectory:String;
var
  Buffer: PAnsiChar;
  Length: Cardinal;
begin
  Result := '';
  Length := MyInitBuffer(Buffer, GetTempPath(0, nil));
  SetString(Result, Buffer, GetTempPath(Length, Buffer));
  MyFreeBuffer(Buffer);
  Result := Copy(Result, 1, System.Length(Result) - 1);
  if Result = '' then Result := '?';
end;

function GetShellDirectory(const Folder_CSIDL: DWORD): String;
var
  Buffer: PAnsiChar;
begin
  Result := '';
  MyInitBuffer(Buffer, MAX_PATH);
  if SHGetFolderPath(HWND(nil), Folder_CSIDL or CSIDL_FLAG_CREATE, 0, 0, Buffer) = S_OK then
  begin
    SetString(Result, Buffer, StrLen(Buffer));
  end;
  MyFreeBuffer(Buffer);
  if Result = '' then Result := '?';
end;

//-----------------------------------------------------------------------------

function GetTempFile(const Directory: String; const Prefix: String; const Extension: String):String;
var
  FileName: String;
  Ext,Pref: String;
begin
  if not SafeDirectoryExists(Directory) then begin
    Result := '';
    Exit;
  end;

  Ext := '';
  if Extension <> '' then Ext := '.' + CheckFileName(Extension);

  Pref := '';
  if Prefix <> '' then Pref := CheckFileName(Prefix);

  randomize;

  repeat
    FileName := Directory + '\' + Pref + IntToHex(Random($FFFFFFFF),8) + Ext;
  until
    not FileExists(FileName);

  Result := FileName;
end;

//-----------------------------------------------------------------------------

function MakeTempFolder(const RootDirectory: String; const Prefix: String; const Extension: String): String;
var
  FolderName: String;
  Ext,Pref: String;
begin
  if not SafeDirectoryExists(RootDirectory) then begin
    Result := '';
    Exit;
  end;

  Ext := '';
  if Extension <> '' then Ext := '.' + CheckFileName(Extension);

  Pref := '';
  if Prefix <> '' then Pref := CheckFileName(Prefix);

  randomize;

  repeat
    FolderName := RootDirectory + '\' + Pref + IntToHex(Random($FFFFFFFF),8) + Ext;
  until
    not (FileExists(FolderName) or SafeDirectoryExists(FolderName));

  ForceDirectories(FolderName);
  Result := FolderName;
end;

//-----------------------------------------------------------------------------

function GetLastErrorMsg:String;
var
  Buffer: PAnsiChar;
begin
  Buffer := nil;
  SetString(Result, Buffer, FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ALLOCATE_BUFFER, nil, GetLastError, 0 , @Buffer, 0, nil));
  if Assigned(Buffer) then LocalFree(DWORD(Buffer));
end;

//-----------------------------------------------------------------------------

function MsgBox(const Text:String): Cardinal;
begin
  Result := MsgBox(Text, MB_ICONINFORMATION);
end;

function MsgBox(const Text: String; const Flags: Cardinal): Cardinal;
begin
  Result := MsgBox(Text, RemoveExtension(ExtractFileName(ParamStr(0))), Flags);
end;

function MsgBox(const Text: String; const Title: String; const Flags: Cardinal): Cardinal;
begin
  Result := MsgBox(GetActiveWindow, Text, Title, Flags or MB_TASKMODAL);
end;

function MsgBox(const Parent: THandle; const Text: String; const Title: String; const Flags: Cardinal): Cardinal;
begin
  Result := MessageBox(Parent, PAnsiChar(Text), PAnsiChar(Title), Flags);
end;

//-----------------------------------------------------------------------------

function ReplaceSubStr(const Str: String; const SubStr: String; const NewStr: String): String;
var
  s: String;
  x: Integer;
begin
  if Str = '' then Result := Str;

  s := Str;
  x := PosEx(SubStr, s, 1);

  while x <> 0 do begin
    //MsgBox(s + #10 + IntToStr(x),'',0);
    Delete(s,x,Length(SubStr));
    Insert(NewStr,s,x);
    x := x + 1 + (Length(NewStr) - Length(SubStr));
    x := PosEx(SubStr, s, x);
  end;

  Result := s;
end;

//-----------------------------------------------------------------------------

function StrToOem(const Str: String): String;
var
  Buffer: PAnsiChar;
begin
  MyInitBuffer(Buffer, Length(Str));
  CharToOem(PAnsiChar(Str), Buffer);
  SetString(Result, Buffer, Length(Str));
  MyFreeBuffer(Buffer);
end;

function StrToAnsi(const Str:String): String;
var
  Buffer: PAnsiChar;
begin
  MyInitBuffer(Buffer, Length(Str));
  OemToChar(PAnsiChar(Str), Buffer);
  SetString(Result, Buffer, Length(Str));
  MyFreeBuffer(Buffer);
end;

//-----------------------------------------------------------------------------

function SearchFiles(const Filter: String; const ReturnFullPath: Boolean): TStringList;
var
  a:TWin32FindData;
  h:Cardinal;
  p:String;
begin
  Result := TStringList.Create;

  if ReturnFullPath then
    p := ExtractDirectory(Filter) + '\'
  else
    p := '';

  h := FindFirstFile(PAnsiChar(Filter), a);
  if h = INVALID_HANDLE_VALUE then Exit;

  repeat
    Result.Add(p + a.cFileName);
  until
    not FindNextFile(h,a);

  Windows.FindClose(h);
end;

//-----------------------------------------------------------------------------

//'CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks', 'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments';

function GetAppVerStr(const VerStr: String): String; overload;
var
  Temp: array[0..0] of String;
begin
  if GetAppVerStr([VerStr], Temp) then
  begin
    Result := Temp[0];
  end else begin
    Result := '???';
  end;
end;

function GetAppVerStr(const Keys:array of String; var Values:array of String):Boolean; overload;
var
  i: Integer;
  n, h, Len: DWORD;
  Buffer: PAnsiChar;
  Value: Pointer;
begin
  if Length(Values) < Length(Keys) then
  begin
    Result := False;
    Exit;
  end;

  n := GetFileVersionInfoSize(PAnsiChar(ParamStr(0)), h);

  if n > 0 then
  begin
    GetMem(Buffer, n+1);
    if GetFileVersionInfo(PAnsiChar(ParamStr(0)), h, n, Buffer) then
    begin
      for i := 0 to Length(Keys)-1 do
      begin
        if VerQueryValue(Buffer, PAnsiChar(Keys[i]), Value, Len) then
        begin
          Values[i] := PAnsiChar(Value);
        end else begin
          Values[i] := 'N/A';
        end;
      end;
      Result := True;
    end else begin
      Result := False;
    end;
    FreeMem(Buffer);
  end else begin
    Result := False;
  end;
end;

function GetAppVerStr(var VerInfo:VS_FIXEDFILEINFO):Boolean; overload;
var
  n, h, Len: DWORD;
  Buffer: PAnsiChar;
  Value: Pointer;
begin
  n := GetFileVersionInfoSize(PAnsiChar(ParamStr(0)), h);

  if n > 0 then
  begin
    GetMem(Buffer, n+1);
    if GetFileVersionInfo(PAnsiChar(ParamStr(0)), h, n, Buffer) then
    begin
      if VerQueryValue(Buffer, '\', Value, Len) then
      begin
        if Len = SizeOf(TVSFixedFileInfo) then
        begin
          VerInfo := PVSFixedFileInfo(Value)^;
          Result := True;
        end else begin
          Result := False;
        end;
      end else begin
        Result := False;
      end;
    end else begin
      Result := False;
    end;
    FreeMem(Buffer);
  end else begin
    Result := False;
  end;
end;

//-----------------------------------------------------------------------------

function ExecWait(const Commandline: String; const Hidden: Boolean; const LogFile: String; const Priority: TExecWaitPriority): DWORD;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Flags: Cardinal;
  ExitCode: DWORD;
  StdHandle: THandle;
  SecAtrrs: TSecurityAttributes;
begin
  Flags := 0;
  StdHandle := INVALID_HANDLE_VALUE;

  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  FillChar(ProcessInfo, SizeOf(ProcessInfo), #0);
  FillChar(SecAtrrs, SizeOf(SecAtrrs), #0);

  if (LogFile <> '') and Hidden then
  begin
    SecAtrrs.nLength := SizeOf(SecAtrrs);
    SecAtrrs.bInheritHandle := True;
    StdHandle := CreateFile(PChar(LogFile), GENERIC_WRITE, FILE_SHARE_WRITE, @SecAtrrs, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  end;

  case Priority of
    ewpNormal: Flags := Windows.NORMAL_PRIORITY_CLASS;
    ewpHigh: Flags := Windows.HIGH_PRIORITY_CLASS;
    ewpBelowNormal: Flags := $00004000;
    ewpIdle: Flags := Windows.IDLE_PRIORITY_CLASS;
    ewpRealtime: Flags := Windows.REALTIME_PRIORITY_CLASS;
  end;

  if Hidden then
  begin
    StartupInfo.cb := sizeof(StartupInfo);
    StartupInfo.wShowWindow := SW_HIDE;
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;

    if StdHandle <> INVALID_HANDLE_VALUE then
    begin
      StartupInfo.hStdInput := 0;
      StartupInfo.hStdError := StdHandle;
      StartupInfo.hStdOutput := StdHandle;
      StartupInfo.dwFlags := StartupInfo.dwFlags or STARTF_USESTDHANDLES;
    end;
  end;

  if not CreateProcess(nil, PAnsiChar(Commandline), nil, nil, true, Flags, nil, nil, StartupInfo, ProcessInfo) then
  begin
    if StdHandle <> INVALID_HANDLE_VALUE then CloseHandle(StdHandle);
    raise Exception.Create('Faild to create process: ' + GetLastErrorMsg + 'Commandline: ' + Commandline);
    Exit;
  end;

  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

  CloseHandle(ProcessInfo.hThread);
  CloseHandle(ProcessInfo.hProcess);
  if StdHandle <> INVALID_HANDLE_VALUE then CloseHandle(StdHandle);

  Result := ExitCode;
end;

//-----------------------------------------------------------------------------

function GetFreeDiskspace(const Root: String): Int64;
var
  FreeAvail, TotalSpace: Int64;
begin
  if GetDiskFreeSpaceEx(PAnsiChar(Root), FreeAvail, TotalSpace, nil) then
  begin
    Result := FreeAvail;
  end else begin
    Result := -1;
  end;  
end;

//-----------------------------------------------------------------------------

procedure HandleURL(const URL: String);
var
  URLStr: String;
  Index: Integer;
begin
  URLStr := Trim(URL);
  Index := pos(#$20, URLStr);

  if Index > 0 then
  begin
    URLStr := Copy(URLStr, 1, Index - 1);
  end;

  if URLStr = '' then
  begin
    Exit;
  end;

  MyInitLibraray(DLL_URL, 'url.dll');
  MyInitFunction(DLL_URL, 'FileProtocolHandler', @FileProtocolHandlerProc);

  if Assigned(FileProtocolHandlerProc) then
  begin
    FileProtocolHandlerProc(HWND(nil), DLL_URL, PAnsiChar(URLStr), SW_MAXIMIZE);
  end else begin
    ShellExecute(HWND(nil), 'open', PAnsiChar(URLStr), nil, nil, SW_MAXIMIZE);
  end;
end;

//-----------------------------------------------------------------------------

procedure CreateShortcut(const PathTarget: String; const PathShortcut: String; const Desc: String; const Params: String);
var
  IObject: IUnknown;
  SLink: IShellLink;
  PFile: IPersistFile;
begin
  IObject := CreateComObject(CLSID_ShellLink);
  SLink := IObject as IShellLink;
  PFile := IObject as IPersistFile;

  with SLink do
  begin
    SetArguments(PAnsiChar(Params));
    SetDescription(PAnsiChar(Desc));
    SetPath(PAnsiChar(PathTarget));
  end;

  PFile.Save(PWChar(WideString(PathShortcut)), FALSE);
end;

//-----------------------------------------------------------------------------

function RemoveFile(const FileName: String): Boolean;
begin
  if not FileExists(FileName) then
  begin
    Result := True;
    Exit;
  end;

  Windows.SetFileAttributes(PAnsiChar(FileName), Windows.FILE_ATTRIBUTE_NORMAL);

  if Windows.DeleteFile(PAnsiChar(FileName)) then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
end;

//-----------------------------------------------------------------------------

function GetShortPath(const LongPath: String): String;
var
  Buffer: PAnsiChar;
  Length: Cardinal;
begin
  Result := '';

  if LongPath <> '' then
  begin
    Length := MyInitBuffer(Buffer, GetShortPathName(PAnsiChar(LongPath), nil, 0));
    SetString(Result, Buffer, GetShortPathName(PAnsiChar(LongPath), Buffer, Length));
    MyFreeBuffer(Buffer);
  end;
end;

//-----------------------------------------------------------------------------

function GetFullPath(const ShortPath: String): String;
var
  Buffer: PAnsiChar;
  Unused: PAnsiChar;
  Length: Cardinal;
begin
  Result := '';
  Unused := nil;

  if ShortPath <> '' then
  begin
    Length := MyInitBuffer(Buffer, GetFullPathName(PAnsiChar(ShortPath), 0, nil, Unused));
    SetString(Result, Buffer, GetFullPathName(PAnsiChar(ShortPath), Length, Buffer, Unused));
    MyFreeBuffer(Buffer);
  end;
end;

//-----------------------------------------------------------------------------

function GetSystemLanguage: String;
var
  UserLangId: LANGID;
  Buffer: array [0..255] of AnsiChar;
begin
  UserLangId := GetUserDefaultLangID;
  FillChar(Buffer, 256, 0);
  SetString(Result, Buffer, VerLanguageName(UserLangId, Buffer, 256));
end;

//-----------------------------------------------------------------------------

function ExplodeStr(const Separator: String; const Text: String): TStringList;
var
  Temp: String;
  x: Integer;
begin
  Result := TStringList.Create;
  Temp := Text;

  while True do
  begin
    x := pos(Separator, Temp);
    if x = 0 then
    begin
      if Temp <> '' then Result.Add(Temp);
      Break;
    end;
    if x > 1 then
    begin
      Result.Add(Copy(Temp, 1, x-1));
    end;
    Delete(Temp, 1, x + Length(Separator) - 1);
  end;
end;

//-----------------------------------------------------------------------------

function TokenizeStr(const Separators: String; const Text: String): TStringList;
var
  Temp: String;
  i,j: Integer;
  b: Boolean;
begin
  Result := TStringList.Create;
  Temp := '';

  for i := 1 to Length(Text) do
  begin
    b := False;

    for j := 1 to Length(Separators) do
    begin
      if Text[i] = Separators[j] then
      begin
        b := True;
        Break;
      end;  
    end;

    if b then
    begin
      if Length(Temp) > 0 then Result.Add(Temp);
      Temp := '';
    end else
    begin
      Temp := Temp + Text[i];
    end;
  end;

  if Length(Temp) > 0 then Result.Add(Temp);
end;

//-----------------------------------------------------------------------------

function IsWow64Process: Boolean;
var
  Temp: Boolean;
begin
  Result := False;

  MyInitLibraray(DLL_Kernel, kernel32);
  MyInitFunction(DLL_Kernel, 'IsWow64Process', @IsWow64ProcessProc);

  if not Assigned(IsWow64ProcessProc) then
  begin
    Exit;
  end;

  if IsWow64ProcessProc(GetCurrentProcess, @Temp) then
  begin
    Result := Temp;
  end;
end;

//-----------------------------------------------------------------------------

function ExpandEnvStr(const EnvStr: String): String;
var
  Buffer: PAnsiChar;
  Length: Cardinal;
begin
  Result := '';

  if EnvStr <> '' then
  begin
    Length := MyInitBuffer(Buffer, ExpandEnvironmentStrings(PAnsiChar(EnvStr), nil, 0));
    SetString(Result, Buffer, ExpandEnvironmentStrings(PAnsiChar(EnvStr), Buffer, Length));
    MyFreeBuffer(Buffer);
  end;
end;

//-----------------------------------------------------------------------------

function SafeDirectoryExists(const Path: String): Boolean;
var
  ErrorMode: UINT;
begin
  ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := DirectoryExists(Trim(Path));
  finally
    SetErrorMode(ErrorMode);
  end;
end;

//-----------------------------------------------------------------------------

function IsDriveReady(const Path: String): Boolean;
var
  ErrorMode: UINT;
  c1,c2: Cardinal;
begin
  ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := GetVolumeInformation(PAnsiChar(Format('%s:\', [Copy(Trim(Path), 1, 1)])), nil, 0, nil, c1, c2, nil, 0);
  finally
    SetErrorMode(ErrorMode);
  end;
end;

//-----------------------------------------------------------------------------

function IsFixedDrive(const Path: String):Boolean;
begin
  Result := GetDriveType(PAnsiChar(Format('%s:\', [Copy(Trim(Path), 1, 1)]))) = DRIVE_FIXED;
end;

//-----------------------------------------------------------------------------

function IsDebuggerPresent: Boolean;
begin
  Result := False;

  if DebugHook <> 0 then
  begin
    Result := True;
    Exit;
  end;

  MyInitLibraray(DLL_Kernel, kernel32);
  MyInitFunction(DLL_Kernel, 'IsDebuggerPresent', @IsDebuggerPresenProc);

  if not Assigned(IsDebuggerPresenProc) then
  begin
    Exit;
  end;

  Result := IsDebuggerPresenProc;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

initialization
  InitializeCriticalSection(CriticalSectionObject);
  DLL_Kernel := 0;
  DLL_URL := 0;
  IsDebuggerPresenProc := nil;
  IsWow64ProcessProc := nil;
  FileProtocolHandlerProc := nil;

finalization
  MyFreeLibrary(DLL_URL);
  MyFreeLibrary(DLL_Kernel);
  DeleteCriticalSection(CriticalSectionObject);

end.

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
