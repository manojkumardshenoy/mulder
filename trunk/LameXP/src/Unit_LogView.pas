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

unit Unit_LogView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, Clipbrd, ExtCtrls, Buttons, Unit_Translator,
  ComCtrls;

type
  TForm_LogView = class(TForm)
    Memo_Log: TRichEdit;
    PopupMenu1: TPopupMenu;
    Menu_CopyToClipboard: TMenuItem;
    Panel1: TPanel;
    Button_Discard: TBitBtn;
    procedure Menu_CopyToClipboardClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_DiscardClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    function ShowLog(LogData: TStringList): Integer;
  end;

var
  Form_LogView: TForm_LogView;

implementation

{$R *.dfm}

uses
  Unit_Progress;

procedure TForm_LogView.Menu_CopyToClipboardClick(Sender: TObject);
var
  Temp: PAnsiChar;
begin
  Temp := Memo_Log.Lines.GetText;
  Clipboard.SetTextBuf(Temp);
  StrDispose(Temp);
end;

procedure TForm_LogView.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Memo_Log.Lines.Clear;
end;

procedure TForm_LogView.Button_DiscardClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_LogView.FormShow(Sender: TObject);
begin
  Translate(self);
  
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
end;

function TForm_LogView.ShowLog(LogData: TStringList): Integer;
begin
  Memo_Log.Clear;
  Memo_Log.Lines.AddStrings(LogData);
  Memo_Log.SelStart := 0;
  Memo_Log.SelLength := 0;
  Result := self.ShowModal;
end;

end.
