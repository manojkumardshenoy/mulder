{   MPUI, an MPlayer frontend for Windows
    Copyright (C) 2005 Martin J. Fiedler <martin.fiedler@gmx.net>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit Help;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TntStdCtrls, TntForms;

type
  THelpForm = class(TTntForm)
    HelpText: TTntMemo;
    BClose: TTntButton;
    RefLabel: TTntLabel;
    procedure BCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Format;
  end;

var
  HelpForm: THelpForm;

implementation

{$R *.dfm}

procedure THelpForm.BCloseClick(Sender: TObject);
begin
  Close;
end;

procedure THelpForm.Format;
var NeededHeight:integer;
begin
  NeededHeight:=RefLabel.Height*HelpText.Lines.Count;
  Height:=Height-HelpText.Height+NeededHeight;
end;

end.
