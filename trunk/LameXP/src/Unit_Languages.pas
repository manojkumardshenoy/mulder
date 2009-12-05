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

unit Unit_Languages;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Contnrs, JvDataEmbedded, Unit_LockedFile, Unit_Utils;

type
  TForm_Languages = class(TForm)
    Locale_EN: TJvDataEmbedded;
    Locale_DE: TJvDataEmbedded;
    Locale_ES_America: TJvDataEmbedded;
    Locale_ES_Castilian: TJvDataEmbedded;
    Locale_IT: TJvDataEmbedded;
    Locale_CN: TJvDataEmbedded;
    Locale_TW: TJvDataEmbedded;
    Locale_FR: TJvDataEmbedded;
    Locale_JP: TJvDataEmbedded;
    Locale_HU: TJvDataEmbedded;
    Locale_NL: TJvDataEmbedded;
    Locale_EL: TJvDataEmbedded;
    Locale_RU: TJvDataEmbedded;
    Locale_RO: TJvDataEmbedded;
    Locale_PL: TJvDataEmbedded;
    Locale_SR: TJvDataEmbedded;
    Locale_UK: TJvDataEmbedded;
    Flag_EN: TJvDataEmbedded;
    Flag_EU: TJvDataEmbedded;
    Flag_DE: TJvDataEmbedded;
    Flag_CN: TJvDataEmbedded;
    Flag_EL: TJvDataEmbedded;
    Flag_ES_America: TJvDataEmbedded;
    Flag_ES_Castilian: TJvDataEmbedded;
    Flag_FR: TJvDataEmbedded;
    Flag_HU: TJvDataEmbedded;
    Flag_IT: TJvDataEmbedded;
    Flag_JP: TJvDataEmbedded;
    Flag_NL: TJvDataEmbedded;
    Flag_PL: TJvDataEmbedded;
    Flag_RO: TJvDataEmbedded;
    Flag_RU: TJvDataEmbedded;
    Flag_TW: TJvDataEmbedded;
    Flag_SR: TJvDataEmbedded;
    Flag_UK: TJvDataEmbedded;
  private
    Path: String;
    Languages: TStringList;
    Flags: TObjectList;
  public
    constructor Create(const AOwner: TComponent; const Path: String; const Languages: TStringList; const Flags: TObjectList);
    procedure MakeLanguage(const LangID: String); overload;
    procedure MakeLanguage(const LangID: String; const LangName: String); overload;
    procedure MakeLanguage(const LangID: String; const SubLang: String; const LangName: String); overload;
  end;

var
  Form_Languages: TForm_Languages;

implementation

const
  HashValuesLang: array [0..16] of TMapEntry =
  (
    ('EN', '11359B7A8E118AA997A721E8B11AE30B30E6C751'),
    ('DE', '0ED77EE4CB7BA8C94BE2FE5A89078D21841F0330'),
    ('CN', '9FE6F2071CEA38111815516C7658BB8BFEFACC55'),
    ('EL', '481447BCCF085281332BA4272CC52C05B6B97BEF'),
    ('ES.America', 'A0FE86FA7F4BEAB25CC60EC436230B54F90530D1'),
    ('ES.Castilian', 'B9B9D7FED2337CE78B5C7763565792C85C47B321'),
    ('FR', '42EBA8E52694324B9EC353C4E5E5F0D98418318A'),
    ('HU', 'BD01D08A60D234D3A0760C819CA76516D9024677'),
    ('IT', 'A7B21FC660A331AB4A120BB75353506D3EBEAFFA'),
    ('JP', '7A8BF5967B7FEBE8B1D0428C933A9111338F076F'),
    ('NL', '114C3B39030D6AF1DE5D3103B5BB060D942C4DDF'),
    ('PL', 'B752B6B3797DB266A20AD2465BC705FF6FA8A67E'),
    ('RO', 'CA0C6F852DF6741DBE0D00FFEEF157E645D56085'),
    ('RU', '7328B1D046785B12653EB01D8477921D8D139044'),
    ('SR', 'FEBEBE0A489596DDDC781251F4360C993D133B29'),
    ('TW', 'CD65390D176D71E33C0449376EF7F04E746D6C44'),
    ('UK', '38E6792369EC9470B721D20955D423EE4EE46F9E')
  );
  HashValuesFlag: array [0..17] of TMapEntry =
  (
    ('EN', '60EFB8A39B7C3C5B3D0A50A0B1D48DAC9F2D9050'),
    ('DE', '467880BAFE3DF4CC8550641130108B8903ED3C06'),
    ('EU', 'EABC7B0EC82015BAB512071F7741131F97EDE02F'),
    ('CN', '26DA0D8D15A2C8DCD19EE4871CCEE305D8064E12'),
    ('EL', '3AEF9DB1761952AA1BD170C70BF6FA3AFC13B50B'),
    ('ES.America', '7A12747EDE8CDAC1D36ADAD55421BAF1ECAB6DDC'),
    ('ES.Castilian', '9ED9CC31A46338D2EF449E4072BAC9E2A5D0B914'),
    ('FR', 'DC5EC6112BD9CFB83A9386C2D6B1EDC0C884DC77'),
    ('HU', '497AE47F727F0BABFBAAFB0F0ACC80A44EED7384'),
    ('IT', '05FC4734CD337FAA8D644AA6DE1A5F2E6063E97B'),
    ('JP', '91B1561981F5316826E6DDF639FD3C6BD9198DA8'),
    ('NL', 'FB13CA73A90F03B119E60730CEDA70100C760DD1'),
    ('PL', '681493ECC0205390449438F3B0BD3ED6A4DDC0EC'),
    ('RO', 'F6DB7D6AD6D4EC93BDA78C98CF3A6B8F3B88BA90'),
    ('RU', 'FF063231D463923947B52C73DF0AF4F35ABF8F43'),
    ('SR', '83DB2F741BC2AB60C45E32D8D9D20C7A6D44FCB1'),
    ('TW', '60CA6DBEB0CA8D9A1FE4394F72A09C1389FE9659'),
    ('UK', '7C5B87F7D6D1CFA0C1A6255645C7512B5168FFE0')
  );

{$R *.dfm}

constructor TForm_Languages.Create(const AOwner: TComponent; const Path: String; const Languages: TStringList; const Flags: TObjectList);
begin
  inherited Create(AOwner);

  Self.Path := Path;
  Self.Languages := Languages;
  Self.Flags := Flags;
end;

procedure TForm_Languages.MakeLanguage(const LangID: String);
begin
  MakeLanguage(LangID, '', '');
end;

procedure TForm_Languages.MakeLanguage(const LangID: String; const LangName: String);
begin
  MakeLanguage(LangID, '', LangName);
end;

procedure TForm_Languages.MakeLanguage(const LangID: String; const SubLang: String; const LangName: String);
var
  Data: TComponent;
  HashValue: String;

  function ComponentID(Prefix: String): String;
  begin
    if SubLang <> '' then
    begin
      Result := Format('%s_%s_%s', [Prefix, LangID, SubLang]);
    end else begin
      Result := Format('%s_%s', [Prefix, LangID]);
    end;
  end;
  function HashID: String;
  begin
    if SubLang <> '' then
    begin
      Result := Format('%s.%s', [LangID, SubLang]);
    end else begin
      Result := LangID;
    end;
  end;
  function FileID(Extension: String): String;
  begin
    if SubLang <> '' then
    begin
      Result := Format('%s\locale_%s_%s.%s', [Path, AnsiLowerCase(LangID), AnsiLowerCase(SubLang), AnsiLowerCase(Extension)]);
    end else begin
      Result := Format('%s\locale_%s.%s', [Path, AnsiLowerCase(LangID), AnsiLowerCase(Extension)]);
    end;
  end;

begin
  if LangID = '' then
  begin
    Assert(False, 'LangID must not be empty!');
    Exit;
  end;

  if LangName <> '' then
  begin
    Data := FindComponent(ComponentID('Locale'));

    if Assigned(Data) then
    begin
      if Data.ClassNameIs('TJvDataEmbedded') then
      begin
        HashValue := Lookup(HashValuesLang, HashID, '');
        if HashValue <> '' then
        begin
          Languages.AddObject(Format('[%s] %s', [LangID, LangName]), TLockedFile.Create(TJvDataEmbedded(Data), HashValue, FileID('LOC')));
        end else begin
          FatalAppExit(0, 'Data verification failed. File checksum is missing!');
          TerminateProcess(GetCurrentProcess, DWORD(-1));
        end;
      end else begin
        Assert(False, 'Invalid LangID specified!');
      end;
    end else begin
      Assert(False, 'Invalid LangID specified!');
    end;
  end else begin
    Languages.Add('---');
  end;

  Data := FindComponent(ComponentID('Flag'));

  if Assigned(Data) then
  begin
    if Data.ClassNameIs('TJvDataEmbedded') then
    begin
      HashValue := Lookup(HashValuesFlag, HashID, '');
      if HashValue <> '' then
      begin
        Flags.Add(TLockedFile.Create(TJvDataEmbedded(Data), HashValue, FileID('BMP')));
      end else begin
        FatalAppExit(0, 'Data verification failed. File checksum is missing!');
        TerminateProcess(GetCurrentProcess, DWORD(-1));
      end;
    end;
  end;
end;

end.
