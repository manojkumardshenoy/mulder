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

unit Unit_FLACEncoder;

interface

uses
  Windows, SysUtils, Forms, Classes, Contnrs, Math, Unit_Encoder, Unit_Decoder,
  Unit_LockedFile, MuldeR_Toolz, Unit_RunProcess;

type
  TFLACEncoder = class(TEncoder)
  private
    function Filter(const S: String): Boolean;
  protected
  public
    CompressionLevel: Integer;
    constructor Create(const ExeFile: TLockedFile); override;
    function DoEncode(const Process: TRunProcess): TProcessResult; override;
    function GetExt:String; override;
  end;

implementation

constructor TFLACEncoder.Create(const ExeFile: TLockedFile);
begin
  inherited;
  CompressionLevel := 5;
end;

function TFLACEncoder.DoEncode(const Process: TRunProcess):TProcessResult;
var
  cmd: String;
begin
  if (SourceFile = '') or (not SafeFileExists(SourceFile)) then
  begin
    Result := procFaild;
    Exit;
  end;

  CompressionLevel := Max(0, CompressionLevel);
  CompressionLevel := Min(8, CompressionLevel);

  ////////////////////////////////////////////////////////////////

  cmd := '"' + ExeFile.Location + '"';
  cmd := cmd + Format(' --compression-level-%d', [CompressionLevel]);

  if Meta.Enabled then begin
    if Meta.Title <> '' then cmd := cmd + ' --tag=Title="' + Meta.Title + '"';
    if Meta.Artist <> '' then cmd := cmd + ' --tag=Artist="' + Meta.Artist + '"';
    if Meta.Album <> '' then cmd := cmd + ' --tag=Album="' + Meta.Album + '"';
    if Meta.Year <> 0 then cmd := cmd + ' --tag=Year=' + IntToStr(Meta.Year);
    if Meta.Comment <> '' then cmd := cmd + ' --tag=Comment="' + Meta.Comment + '"';
    if Meta.Track <> 0 then cmd := cmd + ' --tag=Track=' + IntToStr(Meta.Track);
    if Meta.Genre <> '' then cmd := cmd + ' --tag=Genre="' + Meta.Genre + '"';
  end;

  cmd := cmd + Format(' --force --output-name="%s" "%s"', [OutputFile, SourceFile]);

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

function TFLACEncoder.GetExt:String;
begin
  Result := '.flac';
end;

function TFLACEncoder.Filter(const S: String): Boolean;
var
  x,y: Integer;
begin
  x := pos('% complete', S);

  if(x > 2) then
  begin
    y := pos(': ', S) + 2;
    if (y > 2) and (y < x) then
    begin
      SetProgress(StrToIntDef(Copy(S, y, x-y), -1));
    end;
  end;

  Result := (x = 0);
end;

end.
