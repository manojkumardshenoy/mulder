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

unit Unit_WaveDecoder;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz, Unit_Decoder, Unit_RunProcess;

type
  TWaveDecoder = class(TDecoder)
  private
  protected
  public
    function DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult; override;
    function IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean; override;
    function IsExtensionSupported(const Extension: String): Boolean; override;
  end;

implementation

function TWaveDecoder.DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult;
begin
  if (Input = '') or (not FileExists(Input)) then
  begin
    Result := procFaild;
    Exit;
  end;

  ////////////////////////////////////////////////////////////////

  Process.AddToLog('');
  Process.AddToLog('--------------------------------------------------------------------------');
  Process.AddToLog('');
  Process.AddToLog('Source File: ' + Input);
  Process.AddToLog('Output File: ' + Output);
  Process.AddToLog('');

  Process.AddToLog('CopyFile: "' + Input + '" to "' + Output + '"');
  if CopyFile(PAnsiChar(Input), PAnsiChar(Output), false) then
  begin
    Process.AddToLog('Successfull.');
    Result := procDone;
  end else begin
    Process.AddToLog(GetLastErrorMsg);
    Result := procError;
  end;
end;

function TWaveDecoder.IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean;
begin
  Result := False;

  if SameText(Container, 'Wave') then
  begin
    if SameText(Format, 'PCM') then
    begin
      Result := True;
    end;
  end;
end;

function TWaveDecoder.IsExtensionSupported(const Extension: String): Boolean;
begin
  Result := (Extension = 'wav');
end;

end.
