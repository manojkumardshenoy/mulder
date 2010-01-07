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

unit Unit_Data;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvDataEmbedded, Unit_LockedFile, Unit_Utils;

type
  TForm_Data = class(TForm)
    Data_LameEnc: TJvDataEmbedded;
    Data_OggEnc_i386: TJvDataEmbedded;
    Data_OggEnc_SSE2: TJvDataEmbedded;
    Data_OggDec: TJvDataEmbedded;
    Data_FAAD: TJvDataEmbedded;
    Data_FLAC: TJvDataEmbedded;
    Data_SpeexDec: TJvDataEmbedded;
    Data_WavpackDec: TJvDataEmbedded;
    Data_MusepackDec: TJvDataEmbedded;
    Data_MonkeyDec: TJvDataEmbedded;
    Data_ValibDec: TJvDataEmbedded;
    Data_WGet: TJvDataEmbedded;
    Data_Volumax: TJvDataEmbedded;
    Data_MediaInfo: TJvDataEmbedded;
    Data_ShortenDec: TJvDataEmbedded;
    Data_TTADec: TJvDataEmbedded;
    Data_MPG123Dec: TJvDataEmbedded;
    Data_ALAC: TJvDataEmbedded;
    Data_TAKDec: TJvDataEmbedded;
    Data_WUpdate: TJvDataEmbedded;
    Data_GnuPG: TJvDataEmbedded;
    Data_Keyring: TJvDataEmbedded;
    Data_SelfDel: TJvDataEmbedded;
  private
    ToolsDir: String;
    AppDir: String;
    UserDir: String;
    Build: Integer;
  public
    constructor Create(const AOwner: TComponent; const ToolsDir: String; const AppDir: String; const UserDir: String; const Build: Integer);
    procedure MakeTool(var Store: TLockedFile; const ToolID: String); overload;
    procedure MakeTool(var Store: TLockedFile; const ToolID: String; const ExeName: String); overload;
  end;

var
  Form_Data: TForm_Data;

implementation

const
  HashValues: array [0..22] of TMapEntry =
  (
    ('LameEnc', '2B6C9622EF36F8E9D1FD329C6ADD1129DB6668C7'),
    ('OggEnc_i386', 'C188D0ADBECCC3F9263231E02A1180261FDF3A98'),
    ('OggEnc_SSE2', 'DF1DF84146B5F5F23D9AF0557298C3EDDB2F58F0'),
    ('FLAC', '0708F25D9AE35061DC48B5FBFA84FD78240BAD0F'),
    ('MPG123Dec', 'A944062DB7B05D2F91FA1C52A116BAC7429E450D'),
    ('OggDec', 'B5BA2FD4334D7DC7F5F2AF049CCF452AB7636B5F'),
    ('FAAD', 'B9E944078DD966E6B8AC1A48E195C47C9369D8C0'),
    ('SpeexDec', 'F26DA8C5FC18C03C56B7790077C3C24A4703E85E'),
    ('WavpackDec', 'BB919B52F83DC5D0BC80CF3C22FCC4E6D3948E0F'),
    ('MusepackDec', '917EF2BC4142B458ACDA4514CC0B2585475EC1A1'),
    ('MonkeyDec', 'C8F0DB29B992F80F2D21966B9C95B536997F5214'),
    ('ValibDec', '29396CF19B93A202908E793EDF79128FBB158F12'),
    ('ShortenDec', '6E800A13900A89B41717E7CE3400DD939F52CA9F'),
    ('TTADec', 'CF1603EA02EA8B530A7A91409A080D891C3DD85E'),
    ('ALAC', '79364E837ABA9E547285E6882338EF5E52152EDA'),
    ('TAKDec', '812A216705D3137820BBB0AA37C4BD7AFFD3D830'),
    ('MediaInfo', '1183D367228AFEBC7D599A9F7CF99AE6ADF506FB'),
    ('Volumax', 'A3BCD0BF45BB20BBE603462C34E20550FFF5F936'),
    ('WGet', 'C0F2E57ABACF1D1CC7DDBBD3C59A993C1CACDC3E'),
    ('WUpdate', '3EC102096C29E4871078F2F334C5B49E574897DD'),
    ('GnuPG', 'FD02E4845D4F5DF612F214E04EE83BFEDBBEEC89'),
    ('Keyring', '10C2049324B4B9505EEDB1E4BB772D5055A4674A'),
    ('SelfDel', '9F129668B4392E2176DAF233045ADC2E3ABCC7B1')
  );

{$R *.dfm}

constructor TForm_Data.Create(const AOwner: TComponent; const ToolsDir: String; const AppDir: String; const UserDir: String; const Build: Integer);
begin
  inherited Create(AOwner);

  Self.ToolsDir := ToolsDir;
  Self.AppDir := AppDir;
  Self.UserDir := UserDir;
  Self.Build := Build;
end;

procedure TForm_Data.MakeTool(var Store: TLockedFile; const ToolID: String);
begin
  MakeTool(Store, ToolID, Format('tool_%s.exe', [AnsiLowerCase(ToolID)]));
end;

procedure TForm_Data.MakeTool(var Store: TLockedFile; const ToolID: String; const ExeName: String);
var
  Data: TComponent;
  HashValue: String;
begin
  Store := nil;

  if ToolID = '' then
  begin
    Assert(False, 'ToolID must not be empty!');
    Exit;
  end;

  if FileExists(Format('%s\dev\%d\bin\%s', [UserDir, Build, AnsiLowerCase(ExeName)])) then
  begin
    Store := TLockedFile.Create(Format('%s\dev\%d\bin\%s', [UserDir, Build, AnsiLowerCase(ExeName)]));
    Exit;
  end;

  if FileExists(Format('%s\dev\%d\bin\%s', [AppDir, Build, AnsiLowerCase(ExeName)])) then
  begin
    Store := TLockedFile.Create(Format('%s\dev\%d\bin\%s', [AppDir, Build, AnsiLowerCase(ExeName)]));
    Exit;
  end;

  Data := FindComponent(Format('Data_%s', [ToolID]));

  if Assigned(Data) then
  begin
    if Data.ClassNameIs('TJvDataEmbedded') then
    begin
      HashValue := Lookup(HashValues, ToolID, '');
      if HashValue <> '' then
      begin
        Store := TLockedFile.Create(TJvDataEmbedded(Data), HashValue, Format('%s\%s', [ToolsDir, AnsiLowerCase(ExeName)]));
      end else begin
        FatalAppExit(0, 'Data verification failed. File checksum is missing!');
        TerminateProcess(GetCurrentProcess, DWORD(-1));
      end;
      Exit;
    end;
  end;

  Assert(False, 'Invalid ToolID specified!');
end;

end.
