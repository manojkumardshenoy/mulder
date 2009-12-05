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

unit Unit_SendTo;

interface

uses
  Windows, Forms, Registry, Messages, SysUtils, MuldeR_Toolz;

procedure SendFilesToRunningInstance;

implementation

uses
  Unit_Main;

procedure DisplayErrorMessage;
var
  h: THandle;
begin
  h := CreateMutex(nil, true, '{59c60a69-cb09-4a8f-bb91-e2e9f4372fa7}');

  if (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    CloseHandle(h);
    Exit;
  end;

  MessageBox(0, 'LameXP is alread running, but the running instance doesn''t respond!', 'LameXP', MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
  CloseHandle(h);
end;

procedure SendFilesToRunningInstance;
var
  cds:TCopyDataStruct;
  Handle: THandle;
  Reg: TRegistry;
  CheckVer: String;
  Info: TWindowInfo;
  i: Integer;
  s: String;
  b: Boolean;
begin
  CheckVer := '<UNKNOWN>';
  Handle := INVALID_HANDLE_VALUE;
  b := False;

  Reg := TRegistry.Create;

  for i := 1 to 60 do
  begin
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.KeyExists('SOFTWARE\MuldeR\LameXP') then
    begin
      if Reg.OpenKeyReadOnly('SOFTWARE\MuldeR\LameXP') then
      begin
        if Reg.GetDataType('CurrentVersion') = rdString then
        begin
          CheckVer := Trim(Reg.ReadString('CurrentVersion'));
        end;
        if Reg.GetDataType('WindowHandle') = rdString then
        begin
          Handle := StrToIntDef(Reg.ReadString('WindowHandle'), Handle);
        end;
        Reg.CloseKey;
      end;
    end;

    if SameText(CheckVer, Unit_Main.VersionStr) and (Handle <> INVALID_HANDLE_VALUE) then
    begin
      if GetWindowInfo(Handle, Info) then
      begin
        b := True;
        Break;
      end;  
    end;

    Sleep(250);
  end;

  Reg.Free;

  if not b then
  begin
    DisplayErrorMessage;
    Exit;
  end;

  if not ((ParamCount > 1) and SameText(ParamStr(1), '-add')) then
  begin
    cds.dwData := 42;
    cds.cbData := 0;
    cds.lpData := nil;
    if SendMessage(Handle, WM_COPYDATA, Application.Handle, Integer(@cds)) <> Integer(True) then
    begin
      DisplayErrorMessage;
    end;
    Exit;
  end;

  for i := 2 to ParamCount do
  begin
    s := GetFullPath(ExpandEnvStr(Trim(ParamStr(i))));
    cds.dwData := 42;
    cds.cbData := Length(s) + 1;
    cds.lpData := PAnsiChar(s);
    if SendMessage(Handle, WM_COPYDATA, Application.Handle, Integer(@cds)) <> Integer(True) then
    begin
      DisplayErrorMessage;
      Break;
    end;
  end;
end;

end.
