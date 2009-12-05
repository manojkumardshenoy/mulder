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

unit Unit_MetaDisplay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, JvSpin, Clipbrd, Menus, ExtCtrls, Math,
  Unit_Translator, Unit_Utils;

type
  TForm_DisplayMetaData = class(TForm)
    Group_MetaInformation: TGroupBox;
    Edit_Title: TEdit;
    Label_Title: TLabel;
    Label_Artist: TLabel;
    Edit_Artist: TEdit;
    Label_Album: TLabel;
    Edit_Album: TEdit;
    Label_Genre: TLabel;
    Edit_Genre: TEdit;
    Label_Year: TLabel;
    Edit_Year: TEdit;
    Label_Comment: TLabel;
    Edit_Comment: TEdit;
    Group_MoreInformation: TGroupBox;
    ListView: TListView;
    Button_Discard: TBitBtn;
    Button_CopyMetaData: TBitBtn;
    PopupMenu1: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    Bevel1: TBevel;
    Label_FileType: TLabel;
    procedure Button_DiscardClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button_CopyMetaDataClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form_DisplayMetaData: TForm_DisplayMetaData;

implementation

uses
  Unit_Main;

{$R *.dfm}

procedure TForm_DisplayMetaData.Button_DiscardClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_DisplayMetaData.FormResize(Sender: TObject);
var
  i: Integer;
begin
  i := ListView.ClientWidth;
  ListView.Columns[0].Width := 175;
  ListView.Columns[1].Width := i - 175;
end;

procedure TForm_DisplayMetaData.Button_CopyMetaDataClick(Sender: TObject);
var
  b: Boolean;
  Unknown: String;

  function Sync(From: TEdit; Dest: TEdit):Boolean; overload;
  begin
    if not SameText(From.Text, Unknown) then
    begin
      Dest.Text := From.Text;
      Result := True;
    end else begin
      Result := False;
      Dest.Text := '';
    end;
  end;

  function Sync(From: TEdit; Dest: TJvSpinEdit):Boolean; overload;
  begin
    if not SameText(From.Text, Unknown) then
    begin
      Dest.AsInteger := StrToIntDef(From.Text, 0);
      Result := True;
    end else begin
      Dest.AsInteger := 0;
      Result := False;
    end;
  end;

  function Sync(From: TEdit; Dest: TComboBox):Boolean; overload;
  var
    i: Integer;
  begin
    Result := False;

    if not SameText(From.Text, Unknown) then
    begin
      for i := 0 to Dest.Items.Count do
      begin
        if SameText(Dest.Items[i], From.Text) then
        begin
          Dest.ItemIndex := i;
          Result := True;
          Exit;
        end;
      end;
    end else begin
      Dest.ItemIndex := -1;
    end;
  end;

begin
  b := False;
  Unknown := LangStr('Message_Unknown', 'Core');

  if not SameText(self.Edit_Artist.Text, Unknown) then b := True;
  if not SameText(self.Edit_Album.Text, Unknown) then b := True;
  if not SameText(self.Edit_Genre.Text, Unknown) then b := True;
  if not SameText(self.Edit_Year.Text, Unknown) then b := True;
  if not SameText(self.Edit_Comment.Text, Unknown) then b := True;

  if b then
  begin
    Sync(self.Edit_Artist, Form_Main.Edit_Artist);
    Sync(self.Edit_Album, Form_Main.Edit_Album);
    Sync(self.Edit_Genre, Form_Main.Edit_Genre);
    Sync(self.Edit_Year, Form_Main.Edit_Year);
    Sync(self.Edit_Comment, Form_Main.Edit_Comment);

    MyLangBox(self, 'Message_CopyDataDone', MB_ICONINFORMATION);
    Form_Main.PageControl.ActivePage := Form_Main.Sheet_MetaData;
  end else begin
    MyLangBox(self, 'Message_CopyDataFailed', MB_ICONWARNING);
  end;

  Close;
end;

procedure TForm_DisplayMetaData.FormActivate(Sender: TObject);
begin
  self.OnResize(Sender);
  Button_Discard.SetFocus;
end;

procedure TForm_DisplayMetaData.CopytoClipboard1Click(Sender: TObject);
var
  i,m: Integer;
  Text: String;

  function BlowUp(Str: String; Len: Integer): String;
  begin
    Result := Str;
    while Length(Result) < Len do
    begin
      Result := Result + ' ';
    end;
  end;

begin
  m := 0;

  for i := 0 to ListView.Items.Count-1 do
  begin
    m := Max(m, Length(ListView.Items[i].Caption) + 2);
  end;

  Text := '';

  for i := 0 to ListView.Items.Count-1 do
  begin
    if ListView.Items[i].SubItems[0] <> '' then
    begin
      Text := Text + BlowUp(ListView.Items[i].Caption + ':', m) + ListView.Items[i].SubItems[0] + #13#10;
    end else begin
      if Text <> '' then Text := Text + #13#10;
      Text := Text + ListView.Items[i].Caption + #13#10;
    end;
  end;

  Text := Text + #13#10 + '[ Meta Data ]' + #13#10;
  Text := Text + BlowUp(Label_Title.Caption, m) + Edit_Title.Text + #13#10;
  Text := Text + BlowUp(Label_Artist.Caption, m) + Edit_Artist.Text + #13#10;
  Text := Text + BlowUp(Label_Album.Caption, m) + Edit_Album.Text + #13#10;
  Text := Text + BlowUp(Label_Genre.Caption, m) + Edit_Genre.Text + #13#10;
  Text := Text + BlowUp(Label_Year.Caption, m) + Edit_Year.Text + #13#10;
  Text := Text + BlowUp(Label_Comment.Caption, m) + Edit_Comment.Text + #13#10;

  Clipboard.SetTextBuf(PAnsiChar(Text));
  MessageBeep(MB_ICONINFORMATION);
end;

procedure TForm_DisplayMetaData.FormShow(Sender: TObject);
begin
  Translate(self);
end;

end.
