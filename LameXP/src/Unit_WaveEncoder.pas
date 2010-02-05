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

unit Unit_WaveEncoder;

interface

uses
  Windows, SysUtils, Forms, Contnrs, Classes, Unit_Encoder, Unit_Decoder, MuldeR_Toolz, Unit_RunProcess;

type
  TWaveEncoder = class(TEncoder)
  private
  protected
  public
    constructor Create;
    function DoEncode(const Process: TRunProcess):TProcessResult; override;
    function GetExt:String; override;
  end;

implementation

constructor TWaveEncoder.Create;
begin
  inherited Create(nil);
end;

function TWaveEncoder.DoEncode(const Process: TRunProcess):TProcessResult;
begin
  if (SourceFile = '') or (not SafeFileExists(SourceFile)) then
  begin
    Result := procFaild;
    Exit;
  end;

  ////////////////////////////////////////////////////////////////

  Process.AddToLog('');
  Process.AddToLog('--------------------------------------------------------------------------');
  Process.AddToLog('');
  Process.AddToLog('Source File: ' + SourceFile);
  Process.AddToLog('Output File: ' + OutputFile);
  Process.AddToLog('');

  Process.AddToLog('CopyFile: "' + SourceFile + '" to "' + OutputFile + '"');
  if CopyFile(PAnsiChar(SourceFile), PAnsiChar(OutputFile), false) then
  begin
    Process.AddToLog('Successfull.');
    Result := procDone;
  end else begin
    Process.AddToLog(GetLastErrorMsg);
    Result := procError;
  end;
end;

function TWaveEncoder.GetExt:String;
begin
  Result := '.wav';
end;

end. 
