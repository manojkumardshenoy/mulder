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

unit Unit_NeroEncoder;

interface

uses
  Windows, SysUtils, Forms, Contnrs, Classes, Unit_Encoder, Unit_Decoder,
  MuldeR_Toolz, Unit_RunProcess, Unit_LockedFile, Math;

type
  TNeroEncoder = class(TEncoder)
  private
    Format: TFormatSettings;
    ExeFileTagger: TLockedFile;
    UpdateSkip: Integer;
    function Filter(const S: String): Boolean;
  protected
  public
    Bitrate: Integer;
    Quality: Double;
    Mode: Integer;
    TwoPass: Boolean;
    Profile: Integer;
    constructor Create(const ExeFileEncoder: TLockedFile; const ExeFileTagger: TLockedFile);
    function DoEncode(const Process: TRunProcess):TProcessResult; override;
    function GetExt:String; override;
  end;

implementation

constructor TNeroEncoder.Create(const ExeFileEncoder: TLockedFile; const ExeFileTagger: TLockedFile);
begin
  inherited Create(ExeFileEncoder);
  self.ExeFileTagger := ExeFileTagger;

  GetLocaleFormatSettings(2057,Format);
  Format.DecimalSeparator := '.';

  Bitrate := 4;
  Mode := 0;
  TwoPass := True;
  Profile := 0;
end;

function TNeroEncoder.DoEncode(const Process: TRunProcess):TProcessResult;
var
  cmd: String;
begin
  if (SourceFile = '') or (not FileExists(SourceFile)) then
  begin
    Result := procFaild;
    Exit;
  end;

  UpdateSkip := 0;

  ////////////////////////////////////////////////////////////////

  cmd := '"' + ExeFile.Location + '"';

  case mode of
    0: cmd := cmd + ' -q ' + FloatToStr(Quality, Format);
    1: cmd := cmd + ' -br ' + IntToStr(Bitrate) + '000';
    2: cmd := cmd + ' -cbr ' + IntToStr(Bitrate) + '000';
  end;

  if (mode = 1) and TwoPass then
  begin
    cmd := cmd + ' -2pass';
  end;

  case Profile of
    1: cmd := cmd + ' -lc';
    2: cmd := cmd + ' -he';
    3: cmd := cmd + ' -hev2';
  end;

  cmd := cmd + ' -if "' + SourceFile  + '" -of "' + OutputFile + '"';

  Process.AddToLog('');
  Process.AddToLog('--------------------------------------------------------------------------');
  Process.AddToLog('');
  Process.AddToLog('Source File: ' + SourceFile);
  Process.AddToLog('Output File: ' + OutputFile);
  Process.AddToLog('Commandline: ' + cmd);
  Process.AddToLog('');

  Process.Filter := Filter;
  Result := Process.Execute(cmd);

  ////////////////////////////////////////////////////////////////
  if (Result <> procDone) or (not Meta.Enabled) then Exit;
  ////////////////////////////////////////////////////////////////

  cmd := '"' + ExeFileTagger.Location + '"';
  cmd := cmd + ' "' + OutputFile + '"';

  if Meta.Title <> '' then cmd := cmd + ' -meta:title="' + Meta.Title + '"';
  if Meta.Artist <> '' then cmd := cmd + ' -meta:artist="' + Meta.Artist + '"';
  if Meta.Album <> '' then cmd := cmd + ' -meta:album="' + Meta.Album + '"';
  if Meta.Year <> 0 then cmd := cmd + ' -meta:year=' + IntToStr(Meta.Year);
  if Meta.Comment <> '' then cmd := cmd + ' -meta:comment="' + Meta.Comment + '"';
  if Meta.Track <> 0 then cmd := cmd + ' -meta:track=' + IntToStr(Meta.Track);
  if Meta.Genre <> '' then cmd := cmd + ' -meta:genre="' + Meta.Genre + '"';

  Process.AddToLog('');
  Process.AddToLog('--------------------------------------------------------------------------');
  Process.AddToLog('');
  Process.AddToLog('Target File: ' + OutputFile);
  Process.AddToLog('Commandline: ' + cmd);
  Process.AddToLog('');

  Result := Process.Execute(cmd);
end;

function TNeroEncoder.GetExt:String;
begin
  Result := '.mp4';
end;

function TNeroEncoder.Filter(const S: String): Boolean;
var
  x,y,p: Integer;
begin
  x := Max(pos('processed', S), pos('Processed', S));
  y := pos('seconds', S);

  if (ApproxDuration > 0) and (x > 0) and (y > x) then
  begin
    UpdateSkip := (UpdateSkip + 1) mod 10;

    if UpdateSkip = 0 then
    begin
      p := StrToIntDef(Copy(S, x + 10, y - x - 11), 0);

      if pos('First pass:', S) > 0 then
      begin
        SetProgress(Round(p / ApproxDuration * 50));
      end else
      if pos('Second pass:', S) > 0 then
      begin
        SetProgress(Round(p / ApproxDuration * 50) + 50);
      end else
      begin
        SetProgress(Round(p / ApproxDuration * 100));
      end;
    end;  
  end;

  Result := (x = 0) and (y = 0);
end;

end.
