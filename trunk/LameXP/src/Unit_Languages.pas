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
    ('EN', 'E3F10D7239AE8E5988B7C3D90AC8B7E911F047F9'),
    ('DE', '497AE262998130FB86447126FE35891CF79CEA40'),
    ('CN', '26D6844EB8D1B87A422A832334DF3078CF1759D6'),
    ('EL', '9D61E6E0FB317C7D2F15B8CF146FCABDF2BDA14B'),
    ('ES.America', '21DEF672D72540F02F15D9E67FBCA39575B71112'),
    ('ES.Castilian', 'F669FD2BE6154CFA8B24F56853A2E285568F8915'),
    ('FR', '2A6F3656607BDE83DBB7CB14A12F804841C8863E'),
    ('HU', 'B4AC08A2A5F0DB04B7F1BFA1A6E1A280017FC59A'),
    ('IT', '3C81886803DA49D33A0C031DD68DFC1D3EF28592'),
    ('JP', 'F1BB5708EEE79B769C535F38246689C3D3E85468'),
    ('NL', '6E1308314767385E76CA4FCE6BF40E08EAED4792'),
    ('PL', 'F65EDC1642BC4CE67E198DC5D6F81D8433EDBA1F'),
    ('RO', 'EDD2E067714DAC2FB77558634F4CC24DA02DA106'),
    ('RU', 'E2B65A0A4BF35D026A4A0508B6D5EC3F0138978A'),
    ('SR', 'A9932B026577A6881D6E7CF752BD9C9EFB98EB42'),
    ('TW', '13657C8866C0D606F425175DD746B0C6D367583A'),
    ('UK', '80C5D2185B61BAE202A0E47CA07DEB275FD35D6B')
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

  ForceApplicationUpdate(crHourGlass);
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

  ForceApplicationUpdate(crHourGlass);
end;

end.
