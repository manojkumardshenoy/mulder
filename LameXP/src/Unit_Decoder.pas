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

unit Unit_Decoder;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz, Unit_LockedFile, Unit_RunProcess;

type
  TDecoder = class(TObject)
  private
    LogFile: String;
  protected
    ExeFile: TLockedFile;
    function GetNewLog: String;
  public
    DownMix: Boolean;
    constructor Create(const ExeFile: TLockedFile); virtual;
    function DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult; virtual;
    function IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean; virtual;
    function IsExtensionSupported(const Extension: String): Boolean; virtual;
    function GetLog: String;
  end;

implementation

uses
  Unit_Main;

constructor TDecoder.Create(const ExeFile: TLockedFile);
begin
  Self.ExeFile := ExeFile;
  LogFile := '';
  DownMix := False;
end;

function TDecoder.GetNewLog:String;
begin
  LogFile := GetTempFile(Form_Main.Path.Temp, 'LameXP_', 'log');
  Result := LogFile;
end;

function TDecoder.GetLog:String;
begin
  Result := LogFile;
end;

function TDecoder.DecodeFile(const Input: String; const Output: String; const Process: TRunProcess): TProcessResult;
begin
  Result := procFaild;
end;

function TDecoder.IsFormatSupported(const Container: String; const Flavor: String; const Format: String; const Version: String; const Profile: String): Boolean;
begin
  Result := False;
end;

function TDecoder.IsExtensionSupported(const Extension: String): Boolean;
begin
  Result := False;
end;
  
end.
