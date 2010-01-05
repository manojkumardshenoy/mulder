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

unit Unit_MP3Decoder;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz, Unit_Decoder, Unit_RunProcess;

type
  TMP3Decoder = class(TDecoder)
  private
    function Filter(const S: String): Boolean;
  protected
  public
    function DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult; override;
    function IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean; override;
    function IsExtensionSupported(const Extension: String): Boolean; override;
  end;

implementation

function TMP3Decoder.DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult;
var
  cmd: String;
begin
  cmd := '"' + ExeFile.Location + '"';
  cmd := cmd + ' --verbose';
  cmd := cmd + ' --wav "' + Output + '"';
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

function TMP3Decoder.IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean;
begin
  Result := False;

  if SameText(Container, 'MPEG Audio') or SameText(Container, 'Wave') then
  begin
    if SameText(Format, 'MPEG Audio') then
    begin
      if SameText(Profile, 'Layer 3') or SameText(Profile, 'Layer 2') or SameText(Profile, 'Layer 1') then
      begin
        Result := True;
      end;
    end;
  end;
end;

function TMP3Decoder.IsExtensionSupported(const Extension: String): Boolean;
begin
  Result := SameText(Extension, 'mp3') or SameText(Extension, 'mp2') or SameText(Extension, 'mpa');
end;

function TMP3Decoder.Filter(const S: String): Boolean;
begin
  Result := pos('Frame#', S) = 0;
end;

end.
