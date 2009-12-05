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

unit Unit_LicenseView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, Unit_Translator, ComCtrls;

type
  TForm_License = class(TForm)
    Memo_Nero: TRichEdit;
    Panel1: TPanel;
    Button_Accept: TBitBtn;
    Button_Decline: TBitBtn;
    procedure Button_AcceptClick(Sender: TObject);
    procedure Button_DeclineClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    function ShowLicense_Nero:Integer;
  end;

var
  Form_License: TForm_License;

implementation

{$R *.dfm}

procedure TForm_License.Button_AcceptClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TForm_License.Button_DeclineClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TForm_License.FormActivate(Sender: TObject);
begin
  ActiveControl := nil;
end;

function TForm_License.ShowLicense_Nero:Integer;
begin
  Caption := LangStr('Message_LicenseTitleNero', self.Name);
  Result := self.ShowModal;
end;

procedure TForm_License.FormShow(Sender: TObject);
begin
  Translate(self);
end;

end.
