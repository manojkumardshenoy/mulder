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

unit Unit_Translator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, IniFiles, Menus, Buttons, ComCtrls,
  JvDriveCtrls, JvCheckBox;

type
  TString = class(TObject)
  private
    StrVal: String;
    procedure SetStr(const NewStr: String);
  public
    constructor Create(const Value: String);
    property Value: String read StrVal write SetStr;
  end;

function LoadLanguage(const Name: String): Boolean;
procedure Translate(const Form: TForm); overload;
function LangStr(const Name: String; const Parent: String): String;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

var
  Store: TStringList;

constructor TString.Create(const Value: String);
begin
  SetStr(Value);
end;

procedure TString.SetStr(const NewStr: String);
begin
  StrVal := Trim(NewStr);
end;

///////////////////////////////////////////////////////////////////////////////

function SetVal(const New: String; const Old: String):String;
begin
  if Pos('<MISSING_LANGSTR>', New) <> 0 then
  begin
    Result := Trim(Old);
  end else begin
    Result := Trim(New);
  end;
end;

function LangStr(const Name: String; const Parent: String): String;
var
  i: Integer;
begin
  Result := '<MISSING_LANGSTR>' + Parent + '/' + Name + '</MISSING_LANGSTR>';

  i := Store.IndexOf(Parent);
  if i = -1 then Exit;
  if not Assigned(Store.Objects[i]) then Exit;

  with Store.Objects[i] as TStringList do
  begin
    i := IndexOf(Name);
    if i = -1 then Exit;
    if not Assigned(Objects[i]) then Exit;

    Result := TString(Objects[i]).Value;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure Translate(const Button: TButton; const Parent: String); overload;
begin
  Button.Caption := SetVal(LangStr(Button.Name, Parent), Button.Caption);
  Button.Hint := SetVal(LangStr(Button.Name + '.Hint', Parent), Button.Hint);
  if Button.Hint <> '' then Button.ShowHint := True;
end;

procedure Translate(const Button: TBitBtn; const Parent: String); overload;
begin
  Button.Caption := SetVal(LangStr(Button.Name, Parent), Button.Caption);
  Button.Hint := SetVal(LangStr(Button.Name + '.Hint', Parent), Button.Hint);
  if Button.Hint <> '' then Button.ShowHint := True;
end;

procedure Translate(const Button: TSpeedButton; const Parent: String); overload;
begin
  Button.Caption := SetVal(LangStr(Button.Name, Parent), Button.Caption);
  Button.Hint := SetVal(LangStr(Button.Name + '.Hint', Parent), Button.Hint);
  if Button.Hint <> '' then Button.ShowHint := True;
end;

procedure Translate(const Lab: TLabel; const Parent: String); overload;
begin
  Lab.Caption := SetVal(LangStr(Lab.Name, Parent), Lab.Caption);
  Lab.Hint := SetVal(LangStr(Lab.Name + '.Hint', Parent), Lab.Hint);
  if Lab.Hint <> '' then Lab.ShowHint := True;
end;

procedure Translate(const Box: TCheckBox; const Parent: String); overload;
begin
  Box.Caption := ' ' + SetVal(LangStr(Box.Name, Parent), Box.Caption);
  Box.Hint := SetVal(LangStr(Box.Name + '.Hint', Parent), Box.Hint);
  if Box.Hint <> '' then Box.ShowHint := True;
end;

procedure Translate(const Button: TRadioButton; const Parent: String); overload;
begin
  Button.Caption := SetVal(LangStr(Button.Name, Parent), Button.Caption);
  Button.Hint := SetVal(LangStr(Button.Name + '.Hint', Parent), Button.Hint);
  if Button.Hint <> '' then Button.ShowHint := True;
end;

procedure Translate(const Box: TGroupBox; const Parent: String); overload;
begin
  Box.Caption := ' ' + SetVal(LangStr(Box.Name, Parent), Box.Caption) + ' ';
  Box.Hint := SetVal(LangStr(Box.Name + '.Hint', Parent), Box.Hint);
  if Box.Hint <> '' then Box.ShowHint := True;
end;

procedure Translate(const Panel: TPanel; const Parent: String); overload;
begin
  Panel.Caption := SetVal(LangStr(Panel.Name, Parent), Panel.Caption);
  Panel.Hint := SetVal(LangStr(Panel.Name + '.Hint', Parent), Panel.Hint);
  if Panel.Hint <> '' then Panel.ShowHint := True;
end;

procedure Translate(const Item: TMenuItem; const Parent: String); overload;
begin
  Item.Caption := SetVal(LangStr(Item.Name, Parent), Item.Caption);
  Item.Hint := SetVal(LangStr(Item.Name + '.Hint', Parent), Item.Hint);
end;

procedure Translate(const Sheet: TTabSheet; const Parent: String); overload;
begin
  Sheet.Caption := SetVal(LangStr(Sheet.Name, Parent), Sheet.Caption);
  Sheet.Hint := SetVal(LangStr(Sheet.Name + '.Hint', Parent), Sheet.Hint);
  if Sheet.Hint <> '' then Sheet.ShowHint := True;
end;

procedure Translate(const List: TJvDirectoryListBox; const Parent: String); overload;
begin
  List.Hint := SetVal(LangStr(List.Name + '.Hint', Parent), List.Hint);
  if List.Hint <> '' then List.ShowHint := True;
end;

procedure Translate(const List: TListView; const Parent: String); overload;
var
  i: Integer;
begin
  for i := 0 to List.Columns.Count-1 do
  begin
    List.Columns[i].Caption := SetVal(LangStr(List.Name + '.Column_' + IntToStr(i), Parent), List.Columns[i].Caption);
  end;
  List.Hint := SetVal(LangStr(List.Name + '.Hint', Parent), List.Hint);
  if List.Hint <> '' then List.ShowHint := True;
end;

procedure Translate(const Component: TComponent; const Parent: String); overload;
begin
  if Component.ClassType = TButton then Translate(Component as TButton, Parent);
  if Component.ClassType = TBitBtn then Translate(Component as TBitBtn, Parent);
  if Component.ClassType = TSpeedButton then Translate(Component as TSpeedButton, Parent);
  if Component.ClassType = TLabel then Translate(Component as TLabel, Parent);
  if Component.ClassType = TCheckBox then Translate(Component as TCheckBox, Parent);
  if Component.ClassType = TJvCheckBox then Translate(Component as TCheckBox, Parent);
  if Component.ClassType = TRadioButton then Translate(Component as TRadioButton, Parent);
  if Component.ClassType = TGroupBox then Translate(Component as TGroupBox, Parent);
  if Component.ClassType = TMenuItem then Translate(Component as TMenuItem, Parent);
  if Component.ClassType = TTabSheet then Translate(Component as TTabSheet, Parent);
  if Component.ClassType = TPanel then Translate(Component as TPanel, Parent);
  if Component.ClassType = TListView then Translate(Component as TListView, Parent);
  if Component.ClassType = TJvDirectoryListBox then Translate(Component as TJvDirectoryListBox, Parent);
end;

procedure Translate(const Form: TForm); overload;
var
  i: Integer;
begin
  Form.Caption := SetVal(LangStr(Form.Name, Form.Name), Form.Caption);

  for i := 0 to Form.ComponentCount-1 do
  begin
    Translate(Form.Components[i], Form.Name);
  end;
end;

procedure UnloadLanguage;
var
  i,j: Integer;
begin
  for i := 0 to Store.Count-1 do
  begin
    if Assigned(Store.Objects[i]) then
    begin
      with Store.Objects[i] as TStringList do
      begin
        for j := 0 to Count-1 do
        begin
          if Assigned(Objects[j]) then
          begin
            Objects[j].Free;
            Objects[j] := nil;
          end;
        end;
      end;
      Store.Objects[i].Free;
      Store.Objects[i] := nil;
    end;
  end;
  Store.Clear;
end;

///////////////////////////////////////////////////////////////////////////////

function LoadLanguage(const Name: String): Boolean;
var
  Ini: TIniFile;
  Temp: TStringList;
  i,j: Integer;
begin
  if not FileExists(Name) then
  begin
    Result := False;
    Exit;
  end;

  try
    Ini := TIniFile.Create(Name);
  except
    Result := False;
    Exit;
  end;

  if not Ini.SectionExists('Translation') then
  begin
    Ini.Free;
    Result := False;
    Exit;
  end;

  if not (Ini.ValueExists('Translation', 'Language') and Ini.ValueExists('Translation', 'Codepage')) then
  begin
    Ini.Free;
    Result := False;
    Exit;
  end;

  UnloadLanguage;
  Ini.ReadSections(Store);

  for i := 0 to Store.Count-1 do
  begin
    Temp := TStringList.Create;
    Ini.ReadSection(Store[i], Temp);
    for j := 0 to Temp.Count-1 do
    begin
      Temp.Objects[j] := TString.Create(Trim(Ini.ReadString(Store[i], Temp[j], '<ERROR>')));
    end;
    Store.Objects[i] := Temp;
  end;

  Ini.Free;
  Result := True;
end;

initialization
begin
  Store := TStringList.Create;
end;

finalization
begin
  try
    UnloadLanguage;
  finally
    Store.Free;
  end;
end;

end.

