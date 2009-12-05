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

unit Unit_DropBox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, Math, ShellAPI, JvComponentBase, JvBalloonHint,
  StdCtrls, Unit_Translator, jpeg;

type
  TForm_DropBox = class(TForm)
    Image1: TImage;
    Popup_DropBox: TPopupMenu;
    Menu_Close: TMenuItem;
    Label_Counter: TLabel;
    N1: TMenuItem;
    Menu_Encode: TMenuItem;
    Menu_Clear: TMenuItem;
    Menu_Restore: TMenuItem;
    N2: TMenuItem;
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Menu_CloseClick(Sender: TObject);
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Update; override;
    procedure Menu_EncodeClick(Sender: TObject);
    procedure Menu_ClearClick(Sender: TObject);
    procedure Menu_RestoreClick(Sender: TObject);
  private
    LastPos: TPoint;
    LastWin: TPoint;
    Moving: Boolean;
    FirstShow: Boolean;
  public
  end;

var
  Form_DropBox: TForm_DropBox;

implementation

uses
  Unit_Main;

{$R *.dfm}

procedure TForm_DropBox.FormCreate(Sender: TObject);
begin
  Moving := False;
  FirstShow := True;
  DragAcceptFiles(Handle, True);
  ClientWidth := Image1.Picture.Width;
  ClientHeight := Image1.Picture.Height;
  Update;
end;

procedure TForm_DropBox.FormShow(Sender: TObject);
begin
  // Make window stay on top
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  // Set Parent to desktop
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  // Hide window from the taskbar
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);

  if FirstShow then
  begin
    FirstShow := False;
    Left := Screen.WorkAreaWidth + Screen.WorkAreaLeft - Width;
    Top := Screen.WorkAreaHeight + Screen.WorkAreaTop - Height;
  end;

  Translate(self);
end;

procedure TForm_DropBox.WMDropFiles(var Msg: TMessage);
begin
  Label_Counter.Font.Color := clTeal;
  DragAcceptFiles(Handle, False);
  Form_Main.WindowProc(Msg);
  DragAcceptFiles(Handle, True);
  Label_Counter.Font.Color := clBlack;
end;

procedure TForm_DropBox.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then Exit;
  SetCursor(Screen.Cursors[crSize]);

  LastPos.X := X;
  LastPos.Y := Y;
  LastPos := TControl(Sender).ClientToScreen(LastPos);
  LastWin.X := Left;
  LastWin.Y := Top;

  Moving := True;
end;

procedure TForm_DropBox.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  NewPos: TPoint;
begin
  if not Moving then Exit;

  NewPos.X := X;
  NewPos.Y := Y;
  NewPos := TControl(Sender).ClientToScreen(NewPos);

  Left := Min(Screen.WorkAreaWidth + Screen.WorkAreaLeft - Image1.Picture.Width, Max(Screen.WorkAreaLeft, LastWin.X + (NewPos.X - LastPos.X)));
  Top:= Min(Screen.WorkAreaHeight + Screen.WorkAreaTop - Image1.Picture.Height, Max(Screen.WorkAreaTop, LastWin.Y + (NewPos.Y - LastPos.Y)));
end;

procedure TForm_DropBox.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Moving := False;
  SetCursor(Screen.Cursors[crArrow]);
end;

procedure TForm_DropBox.Menu_CloseClick(Sender: TObject);
begin
  Form_Main.Flags.ShowDropbox := False;
  Form_Main.BalloonHint.CancelHint;
  SetForegroundWindow(Form_Main.Handle);
  Close;
end;

procedure TForm_DropBox.FormResize(Sender: TObject);
begin
  Label_Counter.Left := 0;
  Label_Counter.Top := ClientHeight - Label_Counter.Height - 16;
  Label_Counter.Width := ClientWidth;
end;

procedure TForm_DropBox.Update;
begin
  inherited;
  Label_Counter.Caption := IntToStr(Form_Main.ListView.Items.Count);
end;

procedure TForm_DropBox.Menu_EncodeClick(Sender: TObject);
begin
  Form_Main.Button_Encode.OnClick(Sender);
end;

procedure TForm_DropBox.Menu_ClearClick(Sender: TObject);
begin
  Form_Main.Button_Clear.OnClick(Sender);
end;

procedure TForm_DropBox.Menu_RestoreClick(Sender: TObject);
begin
  Application.Restore;
  SetForegroundWindow(Form_Main.Handle);
end;

end.
