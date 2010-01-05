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

unit Unit_FLACDecoder;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz, Unit_Decoder, Unit_RunProcess;

type
  TFLACDecoder = class(TDecoder)
  private
    function Filter(const S: String): Boolean;
  protected
  public
    function DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult; override;
    function IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean; override;
    function IsExtensionSupported(const Extension: String): Boolean; override;
  end;

implementation

function TFLACDecoder.DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult;
var
  cmd: String;
begin
  cmd := '"' + ExeFile.Location + '"';
  cmd := cmd + ' --decode --force --decode-through-errors';
  cmd := cmd + ' --output-name="' + Output + '"';
  cmd := cmd + ' "' + Input + '"';

  Process.AddToLog('');
  Process.AddToLog('--------------------------------------------------------------------------');
  Process.AddToLog('');
  Process.AddToLog('Source File: ' + Input);
  Process.AddToLog('Output File: ' + Output);
  Process.AddToLog('Commandline: ' + cmd);
  Process.AddToLog('');

  Process.Filter := Filter;
  Result := Process.Execute(cmd);

  if (Result = procDone) and (not FileExists(Output)) then
  begin
    Result := procError;
  end;
end;

function TFLACDecoder.IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean;
begin
  Result := False;

  if SameText(Container, 'FLAC') or SameText(Container, 'OGG') then
  begin
    if SameText(Format, 'FLAC') then
    begin
      Result := True;
    end;
  end;
end;

function TFLACDecoder.IsExtensionSupported(const Extension: String): Boolean;
begin
  Result := (Extension = 'fla') or (Extension = 'flac');
end;

function TFLACDecoder.Filter(const S: String): Boolean;
begin
  Result := pos('% complete', S) = 0;
end;

end.
