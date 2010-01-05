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

unit Unit_QueryBox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Unit_Translator;

type
  TForm_QueryBox = class(TForm)
    Edit_Input: TEdit;
    Label_Prompt: TLabel;
    Button_OK: TBitBtn;
    Button_Cancel: TBitBtn;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Edit_InputChange(Sender: TObject);
    procedure Edit_InputExit(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    Parent: TForm;
    AllowEmpty: Boolean;
    AutoTrim: Boolean;
  end;

var
  Form_QueryBox: TForm_QueryBox;

function MyInputQuery(AParent: TForm; const ACaption, APrompt: string; var Value: string; AAllowEmpty: Boolean; AAutoTrim: Boolean): Boolean;

implementation

{$R *.dfm}

var
  MyQueryBox: TForm_QueryBox;

function MyInputQuery(AParent: TForm; const ACaption, APrompt: string; var Value: string; AAllowEmpty: Boolean; AAutoTrim: Boolean): Boolean;
begin
  Result := False;

  if Assigned(MyQueryBox) then
  begin
    MessageBeep(MB_ICONERROR);
    Exit;
  end else begin
    MyQueryBox := TForm_QueryBox.Create(Application);
  end;

  with MyQueryBox do
  begin
    if not Visible then
    begin
      Parent := AParent;
      Caption := ACaption;
      Label_Prompt.Caption := APrompt;
      Edit_Input.Text := Value;
      AllowEmpty := AAllowEmpty;
      AutoTrim := AAutoTrim;

      if ShowModal = mrOK then
      begin
        Result := True;
        Value := Edit_Input.Text;
      end;
    end;
  end;

  FreeAndNil(MyQueryBox);
end;


procedure TForm_QueryBox.FormShow(Sender: TObject);
begin
  Translate(self);
  EnableMenuItem(GetSystemMenu(Handle,False),SC_CLOSE,MF_BYCOMMAND or MF_GRAYED);

  ClientHeight := Button_OK.Top + Button_OK.Height + 16;
  Constraints.MinWidth := Width;
  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;

  Left := Parent.Left + ((Parent.Width - Width) div 2);
  Top := Parent.Top + ((Parent.Height - Height) div 2);
end;

procedure TForm_QueryBox.FormResize(Sender: TObject);
var
  x: Integer;
begin
  Edit_Input.Width := ClientWidth - Edit_Input.Left - Edit_Input.Left;
  Label_Prompt.Left := Edit_Input.Left;
  Label_Prompt.Width := Edit_Input.Width;
  x := (ClientWidth - Button_OK.Width - Button_Cancel.Width) div 5;
  Button_OK.Left := x + x;
  Button_Cancel.Left := Button_OK.Width + x + x + x;
end;

procedure TForm_QueryBox.Edit_InputChange(Sender: TObject);
begin
  Button_OK.Enabled := AllowEmpty or (Edit_Input.Text <> '');
end;

procedure TForm_QueryBox.Edit_InputExit(Sender: TObject);
begin
  if AutoTrim then
  begin
    Edit_Input.Text := Trim(Edit_Input.Text);
  end;
end;

initialization
  MyQueryBox := nil;

end.
