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

unit Unit_EasterEgg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, JvTimer, MuldeR_Toolz;

type
  TForm_EasterEgg = class(TForm)
    Shape1: TShape;
    Image1: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
  public
    a: Boolean;
    b: Boolean;
    procedure MoveIt;
  end;

var
  Form_EasterEgg: TForm_EasterEgg;

implementation

uses
  Unit_About;

{$R *.dfm}

procedure TForm_EasterEgg.FormCreate(Sender: TObject);
begin
  a := True;
  b := True;
end;

procedure TForm_EasterEgg.FormShow(Sender: TObject);
begin
  // Make window stay on top
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  // Set Parent to desktop
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
  // Hide window from the taskbar
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);

  ClientWidth := Image1.Picture.Width;
  ClientHeight := Image1.Picture.Height;
end;

procedure TForm_EasterEgg.Image1Click(Sender: TObject);
begin
  HandleURL('http://www.youtube.com/watch?v=Wb6ULF76if8');
end;

procedure TForm_EasterEgg.MoveIt;
begin
  if a then Left := Left + 1 else Left := Left - 1;
  if b then Top := Top + 1 else Top := Top - 1;

  if a and (Left + Width >= Screen.WorkAreaLeft + Screen.WorkAreaWidth) then a := False;
  if b and (Top + Height >= Screen.WorkAreaTop + Screen.WorkAreaHeight) then b := False;
  if (not a) and (Left <= Screen.WorkAreaLeft) then a := True;
  if (not b) and (Top <= Screen.WorkAreaTop) then b := True;

  Update;
end;

end.
