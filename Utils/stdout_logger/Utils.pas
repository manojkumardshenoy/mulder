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

unit Utils;

interface

uses
  Windows, SysUtils, Unit_WideStrUtils;

function IsValidHandle(const AHandle: THandle): Boolean;
procedure ReleaseHandle(var AHandle: THandle);
function ExceptionHandler: Longint; stdcall;
procedure AddLogMessage(const hLogFile: THandle; const hStdHandle: THandle; const Text: WideString; const AddTimestamps: Boolean; const AddPrefixes: Boolean; const SilentMode: Boolean; const Codepage: UINT);
function TimeToStr(const Time: Int64): String;

implementation

function IsValidHandle(const AHandle: THandle): Boolean;
begin
  Result := (AHandle <> 0) and (AHandle <> INVALID_HANDLE_VALUE);
end;

procedure ReleaseHandle(var AHandle: THandle);
begin
  if IsValidHandle(AHandle) then
  begin
    CloseHandle(AHandle);
    AHandle := 0;
  end;
end;

function ExceptionHandler: Longint; stdcall;
begin
  try
    WriteLn(ErrOutput, 'Error: Unhandled exception encountered !!!'#10);
  finally
    ExitProcess(DWORD(-1));
  end;
  Result := 0;
end;

procedure AddLogMessage(const hLogFile: THandle; const hStdHandle: THandle; const Text: WideString; const AddTimestamps: Boolean; const AddPrefixes: Boolean; const SilentMode: Boolean; const Codepage: UINT);
var
  TimeStamp: TSystemTime;
  TempBuffer: array [0..255] of AnsiChar;
  Len, Temp: Cardinal;
begin
  if IsValidHandle(hLogFile) then
  begin
    if AddTimestamps and AddPrefixes then
    begin
      GetLocalTime(TimeStamp);
      Len := FormatBuf(TempBuffer, 256, '[%.2d:%.2d:%.2d.%.3d|LOGGER] ', 29, [TimeStamp.wHour, TimeStamp.wMinute, TimeStamp.wSecond, TimeStamp.wMilliseconds]);
      WriteFile(hLogFile, TempBuffer, Len, Temp, nil);
    end
    else if AddTimestamps then
    begin
      GetLocalTime(TimeStamp);
      Len := FormatBuf(TempBuffer, 256, '[%.2d:%.2d:%.2d.%.3d] ', 22, [TimeStamp.wHour, TimeStamp.wMinute, TimeStamp.wSecond, TimeStamp.wMilliseconds]);
      WriteFile(hLogFile, TempBuffer, Len, Temp, nil);
    end;
    WriteFileW(hLogFile, PWideChar(Text + #$0D#$0A), Codepage);
  end;

  if IsValidHandle(hStdHandle) and (not SilentMode) then
  begin
    WriteConsoleW(hStdHandle, Text + #$0A#$0A, False);
  end;
end;

function TimeToStr(const Time: Int64): String;
begin
  if Time < 60 then
  begin
    Result := Format('%d seconds(s)', [Time]);
  end
  else if Time < 3600 then
  begin
    Result := Format('%d minute(s), %d second(s)', [Time div 60, Time mod 60]);
  end
  else begin
    Result := Format('%d hour(s), %d minute(s)', [Time div 3600, (Time mod 3600) div 60]);
  end;
end;

end.
