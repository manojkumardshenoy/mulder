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

unit Unit_LameEncoder;

interface

uses
  Windows, SysUtils, Forms, Classes, Contnrs, Unit_Encoder, Unit_Decoder,
  Unit_LockedFile, MuldeR_Toolz, Unit_RunProcess;

type
  TLameEncoder = class(TEncoder)
  private
    Format: TFormatSettings;
    function Filter(const S: String): Boolean;
  protected
  public
    Bitrate: Integer;
    Mode: Integer;
    AlgorithmQuality: Integer;
    ManageBitrate: Boolean;
    MinBitrate: Integer;
    MaxBitrate: Integer;
    SampleRate: Integer;
    StereoMode: Integer;
    constructor Create(const ExeFile: TLockedFile); override;
    function DoEncode(const Process: TRunProcess): TProcessResult; override;
    function GetExt:String; override;
  end;

implementation

constructor TLameEncoder.Create(const ExeFile: TLockedFile);
begin
  inherited;

  GetLocaleFormatSettings(2057,Format);
  Format.DecimalSeparator := '.';

  Bitrate := 4;
  Mode := 0;
  AlgorithmQuality := 2;
  ManageBitrate := False;
  MinBitrate := 32;
  MaxBitrate := 320;
  SampleRate := 0;
  StereoMode := 0;
  DownMix := True;
end;

function TLameEncoder.DoEncode(const Process: TRunProcess):TProcessResult;
var
  cmd: String;
begin
  if (SourceFile = '') or (not SafeFileExists(SourceFile)) then
  begin
    Result := procFaild;
    Exit;
  end;

  ////////////////////////////////////////////////////////////////

  cmd := '"' + ExeFile.Location + '"';
  cmd := cmd + ' --nohist';
  cmd := cmd + ' -q ' + IntToStr(AlgorithmQuality);

  case mode of
    0: cmd := cmd + ' -V ' + IntToStr(Bitrate);
    1: cmd := cmd + ' --abr ' + IntToStr(Bitrate);
    2: cmd := cmd + ' -b ' + IntToStr(Bitrate);
  end;

  if (Mode <> 2) and ManageBitrate then
    cmd := cmd + ' -F -b ' + IntToStr(MinBitrate) + ' -B ' + IntToStr(MaxBitrate);

  if SampleRate > 0 then
    cmd := cmd + ' --resample ' + FloatToStr(SampleRate/1000, Format);

  case StereoMode of
    1: cmd := cmd + ' -m s';
    2: cmd := cmd + ' -m j';
    3: cmd := cmd + ' -m f';
    4: cmd := cmd + ' -m d';
    5: cmd := cmd + ' -m m';
  end;

  if Meta.Enabled then begin
    cmd := cmd + ' --add-id3v2';
    if Meta.Title <> '' then cmd := cmd + ' --tt "' + Meta.Title + '"';
    if Meta.Artist <> '' then cmd := cmd + ' --ta "' + Meta.Artist + '"';
    if Meta.Album <> '' then cmd := cmd + ' --tl "' + Meta.Album + '"';
    if Meta.Year <> 0 then cmd := cmd + ' --ty ' + IntToStr(Meta.Year);
    if Meta.Comment <> '' then cmd := cmd + ' --tc "' + Meta.Comment + '"';
    if Meta.Track <> 0 then cmd := cmd + ' --tn ' + IntToStr(Meta.Track);
    if Meta.Genre <> '' then cmd := cmd + ' --tg "' + Meta.Genre + '"';
  end;

  cmd := cmd + ' "' + SourceFile  + '" "' + OutputFile + '"';

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

function TLameEncoder.GetExt:String;
begin
  Result := '.mp3';
end;

function TLameEncoder.Filter(const S: String): Boolean;
var
  x,y: Integer;
begin
  x := pos('%)|', S);

  if(x > 2) then
  begin
    y := pos('(', S) + 1;
    if (y > 1) and (y < x) then
    begin
      SetProgress(StrToIntDef(Copy(S, y, x-y), -1));
    end;
  end;

  Result := (x = 0);
end;

end.
