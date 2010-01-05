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

unit Unit_OggEncoder;

interface

uses
  Windows, SysUtils, Classes, Contnrs, Unit_Encoder, Unit_Decoder,
  MuldeR_Toolz, Unit_RunProcess, Unit_LockedFile, Unit_Utils;

type
  TOggEncoder = class(TEncoder)
  private
    Format: TFormatSettings;
    function Filter(const S: String): Boolean;
  protected
  public
    Bitrate: Integer;
    Mode: Integer;
    ManageBitrate: Boolean;
    MinBitrate: Integer;
    MaxBitrate: Integer;
    SampleRate: Integer;
    constructor Create(const ExeFile: TLockedFile); override;
    function DoEncode(const Process: TRunProcess):TProcessResult; override;
    function GetExt:String; override;
  end;

implementation

uses
  Unit_Main;

constructor TOggEncoder.Create(const ExeFile: TLockedFile);
begin
  inherited;

  GetLocaleFormatSettings(2057,Format);
  Format.DecimalSeparator := '.';

  Bitrate := 5;
  Mode := 0;
  ManageBitrate := False;
  MinBitrate := 32;
  MaxBitrate := 500;
  SampleRate := 0;
end;

function TOggEncoder.DoEncode(const Process: TRunProcess):TProcessResult;
var
  cmd: String;
begin
  if (SourceFile = '') or (not FileExists(SourceFile)) then
  begin
    Result := procFaild;
    Exit;
  end;

  ////////////////////////////////////////////////////////////////

  cmd := '"' + ExeFile.Location + '"';

  case mode of
    0: cmd := cmd + ' -q ' + IntToStr(Bitrate);
    1: cmd := cmd + ' -b ' + IntToStr(Bitrate);
  end;

  if (Mode <> 2) and ManageBitrate then
    cmd := cmd + ' --managed -m ' + IntToStr(MinBitrate) + ' -M ' + IntToStr(MaxBitrate);

  if SampleRate > 0 then
    cmd := cmd + ' --resample ' + IntToStr(SampleRate);

  if Meta.Enabled then begin
    if Meta.Title <> '' then cmd := cmd + ' -t "' + Meta.Title + '"';
    if Meta.Artist <> '' then cmd := cmd + ' -a "' + Meta.Artist + '"';
    if Meta.Album <> '' then cmd := cmd + ' -l "' + Meta.Album + '"';
    if Meta.Year <> 0 then cmd := cmd + ' -d ' + IntToStr(Meta.Year);
    cmd := cmd + ' -c "encoder=LameXP ' + Unit_Main.VersionStr + '"';
    if Meta.Comment <> '' then cmd := cmd + ' -c "comment=' + Meta.Comment + '"';
    if Meta.Track <> 0 then cmd := cmd + ' -N ' + IntToStr(Meta.Track);
    if Meta.Genre <> '' then cmd := cmd + ' -G "' + Meta.Genre + '"';
  end;

  cmd := cmd + ' -o "' + OutputFile + '" "' + SourceFile + '"';

  Process.AddToLog('');
  Process.AddToLog('--------------------------------------------------------------------------');
  Process.AddToLog('');
  Process.AddToLog('Source File: ' + SourceFile);
  Process.AddToLog('Output File: ' + OutputFile);
  Process.AddToLog('Commandline: ' + cmd);
  Process.AddToLog('');

  Process.Filter := Filter;
  Result := Process.Execute(cmd);
end;

function TOggEncoder.GetExt:String;
begin
  Result := '.ogg';
end;

function TOggEncoder.Filter(const S: String): Boolean;
begin
  Result := True;

  if(Pos('%]', S) = 7) then
  begin
    Result := False;
    SetProgress(StrToIntDef(Trim(Copy(S, 2, 3)), -1));
  end;
end;

end.
