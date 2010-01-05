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

unit Unit_Filter;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz, Unit_RunProcess, Unit_LockedFile;

type
  TFilter = class(TObject)
  private
    LogFile: String;
  protected
    ExeFile: TLockedFile;
    function GetNewLog:String;
  public
    constructor Create(const ExeFile: TLockedFile); virtual;
    function ProcessFile(const Filename: String; const Process: TRunProcess): TProcessResult; virtual;
    function GetLog:String;
  end;

implementation

uses
  Unit_Main;

constructor TFilter.Create(const ExeFile: TLockedFile);
begin
  Self.ExeFile := ExeFile;
  LogFile := '';
end;

function TFilter.GetNewLog:String;
begin
  LogFile := GetTempFile(Form_Main.Path.Temp, 'LameXP_', 'log');
  Result := LogFile;
end;

function TFilter.GetLog:String;
begin
  Result := LogFile;
end;

function TFilter.ProcessFile(const Filename: String; const Process: TRunProcess): TProcessResult;
begin
  Result := procFaild;
end;

end.
