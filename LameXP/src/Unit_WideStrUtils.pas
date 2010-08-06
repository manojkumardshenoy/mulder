///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2010 LoRd_MuldeR <MuldeR2@GMX.de>
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

unit Unit_WideStrUtils;

//////////////////////////////////////////////////////////////////////////////////////////////
interface
//////////////////////////////////////////////////////////////////////////////////////////////

uses
  Windows, SysUtils, ShellAPI, StrUtils;

function EncodeDoubleQuotesW(const Str: WideString): WideString;
function ExpandFileNameW(const AFilename: WideString): WideString;
function ExtractFileDirectoryW(const APath: WideString): WideString;
function ExtractFileNameW(const APath: WideString): WideString;
function FixDriveDelimiterW(const AString: WideString): WideString;
function FixFileNameW(const AFilename: WideString): WideString;
function FixPathDelimitersW(const AString: WideString): WideString;
function FixPathNameW(const AFilename: WideString): WideString;
function ForceDirectoriesW(const ADirectory: WideString): Boolean;
function GetCurrentDirW: WideString;
function GetEnvironmentVarW(const Name: WideString; const Default: WideString): WideString;
function GetExecutablePathW: WideString;
function ParamCountW: Integer;
function ParamStrW(const Index: Integer): WideString;
function SameStrW(const Str1: WideString; const Str2: WideString): Boolean;
function SameTextW(const Str1: WideString; const Str2: WideString): Boolean;
function SetStringW(var Str: WideString; Src: PWideChar; Len: Integer): Boolean;
function WriteConsoleW(const Handle: THandle; const Str: WideString): Boolean; overload;
function WriteConsoleW(const Handle: THandle; const Str: WideString; const LineBreak: Boolean): Boolean; overload;
function WriteFileW(const Handle: THandle; const Str: PWideChar; const Codepade: UINT): Boolean;

function IsAsciiW(const c: WideChar): Integer; cdecl;
function StrCompW(const Str1: PWideChar; const Str2: PWideChar): Integer; cdecl;
function StrCopyW(const Dest: PWideChar; const Src: PWideChar; const Cnt: Cardinal): PWideChar; cdecl;
function StrICompW(const Str1: PWideChar; const Str2: PWideChar): Integer; cdecl;
function StrLenW(const Str: PWideChar): Cardinal; cdecl;
function StrPosW(const BaseStr: PWideChar; const SubStr: PWideChar): PWideChar; cdecl;
function StrToIntW(const Str: PWideChar): Integer; cdecl;
function ToLowerW(const c: WideChar): WideChar; cdecl;

//////////////////////////////////////////////////////////////////////////////////////////////
implementation
//////////////////////////////////////////////////////////////////////////////////////////////

var
  BigWideStrLock: TRTLCriticalSection;

var
  CommandLineArgs: PPWideChar;
  CommandLineCount: Integer;

//////////////////////////////////////////////////////////////////////////////////////////////

function SetStringW(var Str: WideString; Src: PWideChar; Len: Integer): Boolean;
begin
  try
    SetLength(Str, Len);
  except
    Result := False;
    Exit;
  end;

  if Len > 0 then
  begin
    Result := StrCopyW(Addr(Str[1]), Src, Len) <> nil;
  end else
  begin
    Result := True;
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function InitCommandlineArgs: Boolean;
begin
  EnterCriticalSection(BigWideStrLock);

  try
    if CommandLineArgs <> nil then
    begin
      Result := True;
    end else
    begin
      CommandLineArgs := CommandLineToArgvW(GetCommandLineW, CommandLineCount);
      Result := (CommandLineArgs <> nil) and (CommandLineCount > 0);
    end;  
  finally
    LeaveCriticalSection(BigWideStrLock);
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function GetExecutablePathW: WideString;
var
  Buffer: PWideChar;
  BuffSize: Cardinal;
  Len: DWORD;
begin
  Buffer := nil;
  BuffSize := 256;

  try
    Buffer := AllocMem(BuffSize * SizeOf(WideChar));
    Len := GetModuleFileNameW(0, Buffer, BuffSize);
    while (Len >= BuffSize) and (BuffSize < 1048576) do
    begin
      BuffSize := BuffSize + BuffSize;
      ReallocMem(Buffer, BuffSize * SizeOf(WideChar));
      Len := GetModuleFileNameW(0, Buffer, BuffSize);
    end;
    SetStringW(Result, Buffer, Len);
    FreeMem(Buffer);
  except
    if Buffer <> nil then FreeMem(Buffer);
    Result := '';
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function ParamCountW: Integer;
begin
  if not InitCommandlineArgs then
  begin
    Result := 0;
    Exit;
  end;

  Result := CommandLineCount;
end;

function ParamStrW(const Index: Integer): WideString;
type
  TPWideCharArray = array of PWideChar;
begin
  if Index = 0 then
  begin
    Result := GetExecutablePathW;
    Exit;
  end;

  if not InitCommandlineArgs then
  begin
    Result := '';
    Exit;
  end;

  if not (Index < CommandLineCount) then
  begin
    Result := '';
    Exit;
  end;

  Result := TPWideCharArray(CommandLineArgs)[Index];
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function WriteFileW(const Handle: THandle; const Str: PWideChar; const Codepade: UINT): Boolean;
const
  MallocFailed: String = 'WriteFileW: Memory allocation failed !!!'#10;
var
  MultiByteBuffer: PAnsiChar;
  Len, Temp: Cardinal;
begin
  Result := False;
  Len := WideCharToMultiByte(Codepade, 0, Str, -1, nil, 0, nil, nil) + 1;

  try
    MultiByteBuffer := AllocMem(Len);
  except
    WriteFile(Handle, PAnsiChar(MallocFailed)^, Length(MallocFailed), Temp, nil);
    Exit;
  end;

  try
    Len := WideCharToMultiByte(Codepade, 0, Str, -1, MultiByteBuffer, Len, nil, nil);
    if Len > 0 then
    begin
      Result := WriteFile(Handle, MultiByteBuffer^, Len-1, Temp, nil);
    end;
  finally
    FreeMem(MultiByteBuffer);
  end;
end;

function WriteConsoleW(const Handle: THandle; const Str: WideString; const LineBreak: Boolean): Boolean; overload;
const
  EOL: array [0..1] of AnsiChar = (#$0D, #$0A);
var
  Temp: Cardinal;
  PrevConsoleCP: UINT;
begin
  EnterCriticalSection(BigWideStrLock);

  try
    FlushFileBuffers(Handle);
    PrevConsoleCP := GetConsoleOutputCP();
    SetConsoleOutputCP(CP_UTF8);

    Result := WriteFileW(Handle, PWideChar(Str), CP_UTF8);

    if LineBreak then
    begin
      WriteFile(Handle, EOL, 2, Temp, nil);
    end;

    FlushFileBuffers(Handle);
    SetConsoleOutputCP(PrevConsoleCP);
  finally
    LeaveCriticalSection(BigWideStrLock);
  end;
end;

function WriteConsoleW(const Handle: THandle; const Str: WideString): Boolean; overload;
begin
  Result := WriteConsoleW(Handle, Str, True);
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function LastDelimiterW(const Str: WideString; const Delim: WideChar): Integer;
var
  i: Integer;
begin
  Result := 0;

  for i := 1 to StrLenW(PWideChar(Str)) do
  begin
    if (IsAsciiW(Str[i]) <> 0) and (Str[i] = Delim) then Result := i;
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function ExtractFileNameW(const APath: WideString): WideString;
var
  i: Integer;
begin
  i := LastDelimiterW(APath, PathDelim);
  if i > 0 then
  begin
    Result := Copy(APath, i+1, MaxInt);
  end else
  begin
    Result := APath;
  end;
end;

function ExtractFileDirectoryW(const APath: WideString): WideString;
var
  i: Integer;
begin
  i := LastDelimiterW(APath, PathDelim);
  if i > 0 then
  begin
    Result := Copy(APath, 1, i-1);
  end else
  begin
    Result := '';
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function ForceDirectoriesW(const ADirectory: WideString): Boolean;
begin
  if Length(ADirectory) > 0 then
  begin
    if SameTextW(RightStr(ADirectory, 1), DriveDelim) or SameTextW(ADirectory, PathDelim) then
    begin
      Result := True;
      Exit;
    end;

    ForceDirectoriesW(ExtractFileDirectoryW(ADirectory));

    if CreateDirectoryW(PWideChar(ADirectory), nil) then
    begin
      Result := True;
    end else
    begin
      Result := (GetLastError = ERROR_ALREADY_EXISTS);
    end;
  end else
  begin
    Result := True;
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function ExpandFileNameW(const AFilename: WideString): WideString;
var
  Dummy: PWideChar;
  Buffer: PWideChar;
  Len: Integer;
begin
  Len := GetFullPathNameW(PWideChar(AFilename), 0, nil, Dummy) + 1;

  try
    Buffer := AllocMem(Len * SizeOf(WideChar));
  except
    Result := AFilename;
    Exit;
  end;

  try
    Len := GetFullPathNameW(PWideChar(AFilename), Len, Buffer, Dummy);
    SetStringW(Result, Buffer, Len);
  finally
    FreeMem(Buffer);
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function GetCurrentDirW: WideString;
var
  Buffer: PWideChar;
  Len: Integer;
begin
  Len := GetCurrentDirectoryW(0, nil) + 1;

  try
    Buffer := AllocMem(Len * SizeOf(WideChar));
  except
    Result := '';
    Exit;
  end;

  try
    Len := GetCurrentDirectoryW(Len, Buffer);
    SetStringW(Result, Buffer, Len);
  finally
    FreeMem(Buffer);
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function GetEnvironmentVarW(const Name: WideString; const Default: WideString): WideString;
var
  Buffer: PWideChar;
  Len: DWORD;
begin
  Len := GetEnvironmentVariableW(PWideChar(Name), nil, 0);

  if not (Len > 0) then
  begin
    Result := Default;
    Exit;
  end;

  try
    Buffer := AllocMem(Len * SizeOf(WideChar));
  except
    Result := '';
    Exit;
  end;

  try
    Len := GetEnvironmentVariableW(PWideChar(Name), Buffer, Len);
    SetStringW(Result, Buffer, Len);
  finally
    FreeMem(Buffer);
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function FixStringW(const AString: WideString; const SpecialChars: WideString): WideString;
var
  i,j: Integer;
begin
  Result := AString;
  for i := 1 to Length(Result) do
  begin
    for j := 1 to Length(SpecialChars) do
    begin
      if (IsAsciiW(Result[i]) <> 0) and (Result[i] = SpecialChars[j]) then
      begin
        Result[i] := WideChar('_');
        Break;
      end;
    end;
  end;
end;

function FixFileNameW(const AFilename: WideString): WideString;
begin
  Result := FixStringW(AFilename, '/\:?*"<>|');
end;

function FixPathNameW(const AFilename: WideString): WideString;
begin
  Result := FixStringW(AFilename, '?*"<>|');
end;

function FixPathDelimitersW(const AString: WideString): WideString;
var
  i: Integer;
begin
  Result := AString;
  for i := 1 to Length(Result) do
  begin
    if (IsAsciiW(Result[i]) <> 0) and (Result[i] = WideChar('/')) then
    begin
      Result[i] := WideChar('\');
    end;
  end;
end;

function FixDriveDelimiterW(const AString: WideString): WideString;
var
  i: Integer;
begin
  Result := AString;
  for i := 1 to Length(Result) do
  begin
    if (i <> 2) and (IsAsciiW(Result[i]) <> 0) and (Result[i] = WideChar(':')) then
    begin
      Result[i] := WideChar('_');
    end;
  end;
end;

function EncodeDoubleQuotesW(const Str: WideString): WideString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Str) do
  begin
    if (IsAsciiW(Str[i]) <> 0) and (Str[i] = WideChar('"')) then
    begin
      Result := Result + '\"';
    end else
    begin
      Result := Result + Str[i];
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function SameStrW(const Str1: WideString; const Str2: WideString): Boolean;
begin
  Result := (StrCompW(PWideChar(Str1), PWideChar(Str2)) = 0);
end;

function SameTextW(const Str1: WideString; const Str2: WideString): Boolean;
begin
  Result := (StrICompW(PWideChar(Str1), PWideChar(Str2)) = 0);
end;

//////////////////////////////////////////////////////////////////////////////////////////////

function IsAsciiW; external 'msvcrt.dll' name 'iswascii';
function StrCompW; external 'msvcrt.dll' name 'wcscmp';
function StrCopyW; external 'msvcrt.dll' name 'wcsncpy';
function StrICompW; external 'msvcrt.dll' name '_wcsicmp';
function StrLenW; external 'msvcrt.dll' name 'wcslen';
function StrPosW; external 'msvcrt.dll' name 'wcsstr';
function StrToIntW; external 'msvcrt.dll' name '_wtoi';
function ToLowerW; external 'msvcrt.dll' name 'towlower';

//////////////////////////////////////////////////////////////////////////////////////////////

initialization
begin
  CommandLineArgs := nil;
  CommandLineCount := 0;
  InitializeCriticalSection(BigWideStrLock);
end;

finalization
begin
  if CommandLineArgs <> nil then
  begin
    LocalFree(HLOCAL(CommandLineArgs));
    CommandLineArgs := nil;
  end;
  DeleteCriticalSection(BigWideStrLock);
end;

end.
