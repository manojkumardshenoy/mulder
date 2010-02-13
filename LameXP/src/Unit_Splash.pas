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

unit Unit_Splash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, JvExControls, JvAnimatedImage, JvGIFCtrl, Unit_Utils;

type
  TForm_Splash = class(TForm)
    Image: TImage;
    Animator: TJvGIFAnimator;
    Shape: TShape;
    Panel: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure ForceUpdate(const Loops: Integer);
  public
    procedure CreateForm(InstanceClass: TComponentClass; var Reference);
  end;

var
  Form_Splash: TForm_Splash;

implementation

{$R *.dfm}

procedure TForm_Splash.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  Panel.DoubleBuffered := True;
end;

procedure TForm_Splash.FormShow(Sender: TObject);
begin
  ClientWidth := Image.Picture.Width + (2 * Shape.Pen.Width);
  ClientHeight := Image.Picture.Height + (2 * Shape.Pen.Width);
  Animator.Top := ClientHeight - Animator.Height - 6;
  Animator.Left := ClientWidth - Animator.Width - 6;

  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
end;

procedure TForm_Splash.FormActivate(Sender: TObject);
begin
  ForceUpdate(10);
  SetCursor(Screen.Cursors[crHourGlass]);
  Animator.Animate := True;
end;

procedure TForm_Splash.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Animator.Animate := False;
  Release;
end;

procedure TForm_Splash.CreateForm(InstanceClass: TComponentClass; var Reference);
begin
  ForceUpdate(1);
  SetCursor(Screen.Cursors[crHourGlass]);
  MyCreateForm(Application, InstanceClass, Reference);
  Sleep(125);
end;

procedure TForm_Splash.ForceUpdate(const Loops: Integer);
var
  i: Integer;
begin
  for i := 1 to Loops do
  begin
    with Application do
    begin
      Invalidate;
      Update;
      ProcessMessages;
    end;
  end;
end;

end.
