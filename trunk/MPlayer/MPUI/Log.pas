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
unit Log;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, TntStdCtrls, TntExtCtrls, TntForms;

type
  TLogForm = class(TTntForm)
    TheLog: TTntMemo;
    ControlPanel: TTntPanel;
    BClose: TTntButton;
    Command: TTntEdit;
    procedure BCloseClick(Sender: TObject);
    procedure CommandKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CommandKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    History:TStringList;
    HistoryPos:integer;
  public
    { Public declarations }
    procedure AddLine(const Line:string);
  end;

var
  LogForm: TLogForm;

implementation
uses Core;

{$R *.dfm}

procedure TLogForm.BCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TLogForm.CommandKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=^M then begin
    TheLog.Lines.Add('> '+Command.Text);
    Core.SendCommand(Command.Text);
    History.Add(Command.Text);
    HistoryPos:=History.Count;
    Command.Text:='';
  end;
end;

procedure TLogForm.FormCreate(Sender: TObject);
begin
  History:=TStringList.Create;
end;

procedure TLogForm.FormDestroy(Sender: TObject);
begin
  History.Free;
end;

procedure TLogForm.CommandKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key=VK_UP) AND (HistoryPos>0) then begin
    dec(HistoryPos);
    Command.Text:=History[HistoryPos];
  end;
  if (Key=VK_DOWN) AND (HistoryPos<History.Count) then begin
    inc(HistoryPos);
    if HistoryPos>=History.Count
      then Command.Text:=''
      else Command.Text:=History[HistoryPos];
  end;
end;

procedure TLogForm.FormShow(Sender: TObject);
begin
  TheLog.Perform(EM_LINESCROLL,0,32767);
end;

procedure TLogForm.AddLine(const Line:string);
begin
  TheLog.Lines.Add(Line);
  if Visible then TheLog.Perform(EM_LINESCROLL,0,32767);
end;

end.
