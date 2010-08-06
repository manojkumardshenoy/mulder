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

unit RedirectThread;

///////////////////////////////////////////////////////////////////////////////
interface
///////////////////////////////////////////////////////////////////////////////

uses
  Windows, SysUtils, Classes, Unit_WideStrUtils;

const
  MAX_FILTER_COUNT = 64;

type
  TRedirectThread = class(TThread)
  private
    SourceHandle: THandle;
    DestinationHandle: THandle;
    LogFile: THandle;
    InputCodepage: UINT;
    OutputCodepage: UINT;
    PipeBuffer: array[0..4095] of Byte;
    LineBuffer: array[0..102399] of Byte;
    FilterStr: array[0..MAX_FILTER_COUNT-1] of PWideChar;
    PrefixStr: PAnsiChar;
    FilterCount: Integer;
    Timestamps: Boolean;
    InvertFilter: Boolean;
    CaseSensitiveFilter: Boolean;
    CurrentPos: Cardinal;
    LineCounter: Cardinal;
    SkipCounter: Cardinal;
  protected
    procedure Execute; override;
    procedure ProcessBuffer(const Len: Cardinal);
    procedure ProcessLine;
  public
    constructor Create(const SourceHandle: THandle; const DestinationHandle: THandle; const LogFile: THandle; const Timestamps: Boolean);
    destructor Destroy; override;
    procedure AddFilterStr(const FilterStr: PWideChar);
    procedure SetInvertFilter(const InvertFilter: Boolean);
    procedure SetPrefixStr(const PrefixStr: PAnsiChar);
    procedure SetCaseSensitiveFilter(const CaseSensitiveFilter: Boolean);
    procedure SetInputCodepage(const InputCodepage: UINT);
    procedure SetOutputCodepage(const OutputCodepage: UINT);
    function GetSkippedLines: Cardinal;
    function GetProcessedLines: Cardinal;
  end;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

var
  CriticalSection: TRTLCriticalSection;

constructor TRedirectThread.Create(const SourceHandle: THandle; const DestinationHandle: THandle; const LogFile: THandle; const Timestamps: Boolean);
var
  i: Integer;
begin
  inherited Create(true);

  ZeroMemory(Addr(PipeBuffer[0]), 4096);
  ZeroMemory(Addr(LineBuffer[0]), 102400);

  CurrentPos := 0;
  FilterCount := 0;
  InvertFilter := False;
  CaseSensitiveFilter := True;
  PrefixStr := nil;
  LineCounter := 0;
  SkipCounter := 0;
  InputCodepage := CP_UTF8;
  OutputCodepage := CP_UTF8;

  for i := 0 to MAX_FILTER_COUNT-1 do
  begin
    Self.FilterStr[i] := nil;
  end;

  Self.SourceHandle := SourceHandle;
  Self.DestinationHandle := DestinationHandle;
  Self.LogFile := LogFile;
  Self.Timestamps := Timestamps;
end;

destructor TRedirectThread.Destroy;
var
  i: Integer;
begin
  for i := 0 to MAX_FILTER_COUNT-1 do
  begin
    if FilterStr[i] <> nil then
    begin
      FreeMem(FilterStr[i]);
      FilterStr[i] := nil;
    end;
  end;

  if PrefixStr <> nil then
  begin
    FreeMem(PrefixStr);
    PrefixStr := nil;
  end;

  inherited Destroy;
end;

///////////////////////////////////////////////////////////////////////////////

procedure TRedirectThread.AddFilterStr(const FilterStr: PWideChar);
var
  Len: Cardinal;
begin
  if FilterCount < MAX_FILTER_COUNT then
  begin
    Len := StrLenW(FilterStr) + 1;
    Self.FilterStr[FilterCount] := AllocMem(Len * SizeOf(WideChar));
    StrCopyW(Self.FilterStr[FilterCount], FilterStr, Len);
    if not CaseSensitiveFilter then
    begin
      CharLowerBuffW(Self.FilterStr[FilterCount], Len-1);
    end;
    FilterCount := FilterCount + 1;
  end;
end;

procedure TRedirectThread.SetInvertFilter(const InvertFilter: Boolean);
begin
  Self.InvertFilter := InvertFilter;
end;

procedure TRedirectThread.SetPrefixStr(const PrefixStr: PAnsiChar);
var
  Len: Cardinal;
begin
  if Self.PrefixStr <> nil then
  begin
    FreeMem(Self.PrefixStr);
  end;
  Len := StrLen(PrefixStr);
  Self.PrefixStr := AllocMem(Len + 1);
  StrMove(Self.PrefixStr, PrefixStr, Len);
end;

procedure TRedirectThread.SetCaseSensitiveFilter(const CaseSensitiveFilter: Boolean);
begin
  if FilterCount = 0 then
  begin
    Self.CaseSensitiveFilter := CaseSensitiveFilter;
  end else
  begin
    raise Exception.Create('Cannot change filter case-sensitivity after filter strings have been added!');
  end;
end;

function TRedirectThread.GetProcessedLines: Cardinal;
begin
  Result := Self.LineCounter;
end;

function TRedirectThread.GetSkippedLines: Cardinal;
begin
  Result := Self.SkipCounter;
end;

procedure TRedirectThread.SetInputCodepage(const InputCodepage: UINT);
begin
  self.InputCodepage := InputCodepage;
end;

procedure TRedirectThread.SetOutputCodepage(const OutputCodepage: UINT);
begin
  self.OutputCodepage := OutputCodepage;
end;

///////////////////////////////////////////////////////////////////////////////

procedure TRedirectThread.Execute;
var
  Temp, Len: Cardinal;
begin
  while ReadFile(SourceHandle, PipeBuffer, 4096, Len, nil) do
  begin
    if Len < 1 then
    begin
      ReturnValue := 99999;
      break;
    end;

    WriteFile(DestinationHandle, PipeBuffer, Len, Temp, nil);
    FlushFileBuffers(DestinationHandle);

    if LogFile <> INVALID_HANDLE_VALUE then
    begin
      ProcessBuffer(Len);
    end;
  end;

  ReturnValue := GetLastError;
end;

procedure TRedirectThread.ProcessBuffer(const Len: Cardinal);
var
  i: Cardinal;
begin
  for i := 0 to Len-1 do
  begin
    if (CurrentPos > 102396) or (PipeBuffer[i] = $00) or (PipeBuffer[i] = $08) or (PipeBuffer[i] = $0A) or (PipeBuffer[i] = $0D) then
    begin
      if(CurrentPos > 0) then
      begin
        try
          EnterCriticalSection(CriticalSection);
          ProcessLine;
        finally
          LeaveCriticalSection(CriticalSection);
        end;
        CurrentPos := 0;
      end;
    end else begin
      LineBuffer[CurrentPos] := PipeBuffer[i];
      CurrentPos := CurrentPos + 1;
    end;
  end;
end;

procedure TRedirectThread.ProcessLine;
var
  i: Integer;
  Len, Temp: Cardinal;
  AnsiBuffer: array [0..255] of AnsiChar;
  TimeStamp: TSystemTime;
  MatchFilter: Boolean;
  WideBuffer, CaseBuffer: PWideChar;
begin
  WideBuffer := nil;
  CaseBuffer := nil;

  while LineBuffer[CurrentPos-1] = $20 do
  begin
    CurrentPos := CurrentPos - 1;
    if CurrentPos < 1 then Exit;
  end;

  LineCounter := LineCounter + 1;

  LineBuffer[CurrentPos] := $0D;
  LineBuffer[CurrentPos+1] := $0A;
  LineBuffer[CurrentPos+2] := $00;

  Len := MultiByteToWideChar(InputCodepage, 0, Addr(LineBuffer[0]), -1, nil, 0) + 1;

  try
    WideBuffer := AllocMem(Len * SizeOf(WideChar));
  except
    WriteLn(ErrOutput, 'Error: MultiByteToWideChar failed to allocate memory !!!'#10);
    Exit;
  end;

  Len := MultiByteToWideChar(InputCodepage, 0, Addr(LineBuffer[0]), -1, WideBuffer, Len);

  if Len < 1 then
  begin
    if (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
    begin
      WriteLn(ErrOutput, 'Error: MultiByteToWideChar has insufficient buffer !!!'#10);
    end;
    if WideBuffer <> nil then FreeMem(WideBuffer);
    if CaseBuffer <> nil then FreeMem(CaseBuffer);
    Exit;
  end;

  if (not CaseSensitiveFilter) and (FilterCount > 0) then
  begin
    try
      CaseBuffer := AllocMem((Len + 1) * SizeOf(WideChar));
    except
      WriteLn(ErrOutput, 'Error: MultiByteToWideChar failed to allocate memory !!!'#10);
      if WideBuffer <> nil then FreeMem(WideBuffer);
      Exit;
    end;
    StrCopyW(CaseBuffer, WideBuffer, Len);
    CharLowerBuffW(CaseBuffer, Len-1);
  end;

  MatchFilter := False;

  for i := 0 to FilterCount-1 do
  begin
    if CaseSensitiveFilter then
    begin
      if (StrPosW(Addr(WideBuffer[0]), FilterStr[i]) <> nil) then
      begin
        MatchFilter := True;
        Break;
      end;
    end else
    begin
      if (StrPosW(Addr(CaseBuffer[0]), FilterStr[i]) <> nil) then
      begin
        MatchFilter := True;
        Break;
      end;
    end;
  end;

  if MatchFilter xor InvertFilter then
  begin
    SkipCounter := SkipCounter + 1;
    if WideBuffer <> nil then FreeMem(WideBuffer);
    if CaseBuffer <> nil then FreeMem(CaseBuffer);
    Exit;
  end;

  try
    if Timestamps and (PrefixStr <> nil) then
    begin
      GetLocalTime(TimeStamp);
      Len := FormatBuf(AnsiBuffer, 256, '[%.2d:%.2d:%.2d.%.3d|%s] ', 25, [TimeStamp.wHour, TimeStamp.wMinute, TimeStamp.wSecond, TimeStamp.wMilliseconds, PrefixStr]);
      WriteFile(LogFile, AnsiBuffer, Len, Temp, nil);
    end
    else if Timestamps then
    begin
      GetLocalTime(TimeStamp);
      Len := FormatBuf(AnsiBuffer, 256, '[%.2d:%.2d:%.2d.%.3d] ', 22, [TimeStamp.wHour, TimeStamp.wMinute, TimeStamp.wSecond, TimeStamp.wMilliseconds]);
      WriteFile(LogFile, AnsiBuffer, Len, Temp, nil);
    end;
    WriteFileW(LogFile, WideBuffer, OutputCodepage);
  finally
    if WideBuffer <> nil then FreeMem(WideBuffer);
    if CaseBuffer <> nil then FreeMem(CaseBuffer);
  end;
end;

///////////////////////////////////////////////////////////////////////////////

initialization
begin
  InitializeCriticalSection(CriticalSection);
end;

finalization
begin
  DeleteCriticalSection(CriticalSection);
end;

///////////////////////////////////////////////////////////////////////////////

end.
