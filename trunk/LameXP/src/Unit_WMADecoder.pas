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

unit Unit_WMADecoder;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz, Unit_Decoder, Unit_RunProcess;

type
  TWMADecoder = class(TDecoder)
  private
  protected
  public
    function DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult; override;
    function IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean; override;
    function IsExtensionSupported(const Extension: String): Boolean; override;
  end;

implementation

function TWMADecoder.DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult;
var
  cmd: String;
  Mutex: THandle;
const
  MutexUUID = '{31c5f63a-ce23-407d-3bfb-04f52042b666-668610de}';
begin
  if (Input = '') or (not SafeFileExists(Input)) then
  begin
    Result := procFaild;
    Exit;
  end;
  
  Mutex := CreateMutex(nil, False, MutexUUID);

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

  try
    if (Mutex <> 0) then
    begin
      if WaitForSingleObject(Mutex, 600000) <> WAIT_OBJECT_0 then
      begin
        ReleaseMutex(Mutex);
        CloseHandle(Mutex);
        Result := procFaild;
        Exit;
      end;
    end;
    Result := Process.Execute(cmd);
  finally
    if (Mutex <> 0) then
    begin
      ReleaseMutex(Mutex);
      CloseHandle(Mutex);
    end;
  end;

  if (Result = procDone) and (not SafeFileExists(Output)) then
  begin
    Result := procError;
  end;
end;

function TWMADecoder.IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean;
begin
  Result := False;

  if SameText(Container, 'Windows Media') then
  begin
    if SameText(Format, 'WMA') then
    begin
      if SameText(Version, 'Version 1') or SameText(Version, 'Version 2') or SameText(Version, 'Version 3') or SameText(Profile, 'Pro') or SameText(Profile, 'Lossless') then
      begin
        Result := True;
      end;
    end
    else if SameText(Format, 'WMA1') or SameText(Format, 'WMA2') or SameText(Format, 'WMA3') or SameText(Format, 'WMA Lossless') then
    begin
      Result := True;
    end;
  end;
end;

function TWMADecoder.IsExtensionSupported(const Extension: String): Boolean;
begin
  Result := SameText(Extension, 'wma') or SameText(Extension, 'asf');
end;

end.
