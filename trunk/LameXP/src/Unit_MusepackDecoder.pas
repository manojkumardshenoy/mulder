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

unit Unit_MusepackDecoder;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz, Unit_Decoder, Unit_RunProcess;

type
  TMusepackDecoder = class(TDecoder)
  private
  protected
  public
    function DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult; override;
    function IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean; override;
    function IsExtensionSupported(const Extension: String): Boolean; override;
  end;

implementation

function TMusepackDecoder.DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult;
var
  cmd: String;
begin
  cmd := '"' + ExeFile.Location + '"';
  cmd := cmd + ' "' + Input + '"';
  cmd := cmd + ' "' + Output + '"';

  Process.AddToLog('');
  Process.AddToLog('--------------------------------------------------------------------------');
  Process.AddToLog('');
  Process.AddToLog('Source File: ' + Input);
  Process.AddToLog('Output File: ' + Output);
  Process.AddToLog('Commandline: ' + cmd);
  Process.AddToLog('');

  Result := Process.Execute(cmd);

  if (Result = procDone) and (not SafeFileExists(Output)) then
  begin
    Result := procError;
  end;
end;

function TMusepackDecoder.IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean;
begin
  Result := False;

  if SameText(Container, 'MusePack SV7') or SameText(Container, 'MusePack SV8') then
  begin
    if SameText(Format, 'MusePack SV7') or SameText(Format, 'MusePack SV8') then
    begin
      Result := True;
    end;
  end;
end;

function TMusepackDecoder.IsExtensionSupported(const Extension: String): Boolean;
begin
  Result := (Extension = 'mpc') or (Extension = 'mpp') or (Extension = 'mp+');
end;

end.
