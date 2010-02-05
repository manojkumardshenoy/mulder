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

unit Unit_OggDecoder;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz, Unit_Decoder, Unit_RunProcess;

type
  TOggDecoder = class(TDecoder)
  private
    function Filter(const S: String): Boolean;
  protected
  public
    function DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult; override;
    function IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean; override;
    function IsExtensionSupported(const Extension: String): Boolean; override;
  end;

implementation

function TOggDecoder.DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult;
var
  cmd: String;
begin
  cmd := '"' + ExeFile.Location + '"';
  cmd := cmd + ' --wavout "' + Output + '"';
  if Downmix then
  begin
    cmd := cmd + ' --downmix';
  end;
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

  if (Result = procDone) and (not SafeFileExists(Output)) then
  begin
    Result := procError;
  end;
end;

function TOggDecoder.IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean;
begin
  Result := False;

  if SameText(Container, 'OGG') then
  begin
    if SameText(Format, 'Vorbis') then
    begin
      Result := True;
    end;
  end;
end;

function TOggDecoder.IsExtensionSupported(const Extension: String): Boolean;
begin
  Result := (Extension = 'ogg') or (Extension = 'oga') or (Extension = 'ogm') or (Extension = 'vrbs');
end;

function TOggDecoder.Filter(const S: String): Boolean;
begin
  Result := pos('% decoded.', S) = 0;
end;

end.
