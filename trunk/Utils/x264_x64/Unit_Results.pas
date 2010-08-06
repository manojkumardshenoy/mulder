///////////////////////////////////////////////////////////////////////////////
// Simple x264 Launcher
// Copyright (C) 2009-2010 LoRd_MuldeR <MuldeR2@GMX.de>
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

unit Unit_Results;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, Clipbrd;

type
  TForm_Results = class(TForm)
    Memo_Result: TMemo;
    PopupMenu1: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form_Results: TForm_Results;

implementation

{$R *.dfm}

procedure TForm_Results.FormShow(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
end;

procedure TForm_Results.CopytoClipboard1Click(Sender: TObject);
begin
  Clipboard.SetTextBuf(Memo_Result.Lines.GetText);
end;

end.
