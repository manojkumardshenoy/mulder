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

unit Unit_NormalizationFilter;

interface

uses
  Windows, SysUtils, Forms, Classes, Contnrs, Unit_Filter, MuldeR_Toolz, Unit_RunProcess, Unit_LockedFile;

type
  TNormalizationFilter = class(TFilter)
  private
    Format: TFormatSettings;
    Peak: Real;
    function Filter(const S: String): Boolean;
  protected
  public
    constructor Create(const ExeFile: TLockedFile); override;
    destructor Destroy; override;
    procedure SetPeak(const NewPeak: Real);
    function ProcessFile(const Filename: String; const Process: TRunProcess): TProcessResult; override;
  end;

implementation

constructor TNormalizationFilter.Create(const ExeFile: TLockedFile);
begin
  inherited Create(ExeFile);

  GetLocaleFormatSettings(2057,Format);
  Format.DecimalSeparator := '.';

  Peak := -0.1;
end;

destructor TNormalizationFilter.Destroy;
begin
  inherited;
end;

procedure TNormalizationFilter.SetPeak(const NewPeak: Real);
begin
  if (NewPeak >= -12.0) and (NewPeak <= 0.0) then
  begin
    Peak := NewPeak;
  end;
end;

function TNormalizationFilter.ProcessFile(const Filename: String; const Process: TRunProcess): TProcessResult;
var
  cmd: String;
begin
  if (Filename = '') or (not FileExists(Filename)) then
  begin
    Result := procFaild;
    Exit;
  end;

  ////////////////////////////////////////////////////////////////

  cmd := '"' + ExeFile.Location + '"';
  cmd := cmd + ' --gain ' + FloatToStrF(Peak, ffFixed, 5, 2, Format) + ' --apply "' + Filename + '"';

  Process.AddToLog('');
  Process.AddToLog('--------------------------------------------------------------------------');
  Process.AddToLog('');
  Process.AddToLog('Target File: ' + Filename);
  Process.AddToLog('Commandline: ' + cmd);
  Process.AddToLog('');

  Process.Filter := self.Filter;
  Result := Process.Execute(cmd);
end;

function TNormalizationFilter.Filter(const S: String): Boolean;
begin
  Result := pos('% done', S) = 0;
end;

end.
