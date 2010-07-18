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

unit Unit_About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DateUtils, MMSystem, JvGIF, JvComponentBase,
  Math, JvThreadTimer, JvDotNetControls, JvExStdCtrls, JvButton,
  Unit_Translator, JvStartMenuButton, JvExControls, JvTransparentButton,
  OleCtrls, SHDocVw, JvExExtCtrls, JvImage, MuldeR_Toolz, JvStaticText,
  JvThread, JvTimer, Buttons, ShellAPI, Contnrs, JvBaseDlg,
  JvJVCLAboutForm, JvPoweredBy, JvExForms, JvScrollBox, ComCtrls;

type
  TForm_About = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label_LameXP: TLabel;
    Label_Homepage: TLabel;
    Label_Lame: TLabel;
    Label3: TLabel;
    Label_Link2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label_OggVorbisEnc: TLabel;
    Label_Link3: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label16: TLabel;
    Image4: TImage;
    Shape2: TShape;
    Label1: TLabel;
    Label_Link11: TLabel;
    Label9: TLabel;
    Image5: TImage;
    Bevel1: TBevel;
    EasterEgg: TImage;
    Button_Close: TBitBtn;
    JvImage1: TJvImage;
    JvImage2: TJvImage;
    JvImage3: TJvImage;
    JvImage4: TJvImage;
    Panel1: TPanel;
    Panel2: TPanel;
    Button_License: TSpeedButton;
    Bevel2: TBevel;
    Label2: TLabel;
    Button_Accept: TBitBtn;
    Panel_Accept: TPanel;
    Button_Decline: TBitBtn;
    JvScrollBox1: TJvScrollBox;
    Image6: TImage;
    Label4: TLabel;
    Label7: TLabel;
    JvImage5: TJvImage;
    Label_Link6: TLabel;
    Label_FLAC: TLabel;
    Image7: TImage;
    Label10: TLabel;
    Label_FAAD: TLabel;
    Label14: TLabel;
    Label_Link5: TLabel;
    JvImage6: TJvImage;
    Image8: TImage;
    Label13: TLabel;
    Label_Speex: TLabel;
    Label18: TLabel;
    JvImage7: TJvImage;
    Label_Link7: TLabel;
    Image9: TImage;
    Label20: TLabel;
    Label22: TLabel;
    JvImage8: TJvImage;
    Label_Link4: TLabel;
    Image10: TImage;
    Label17: TLabel;
    Label_WavPack: TLabel;
    Label24: TLabel;
    JvImage9: TJvImage;
    Label_Link8: TLabel;
    JvImage10: TJvImage;
    Image12: TImage;
    Label29: TLabel;
    Label_Musepack: TLabel;
    Label31: TLabel;
    JvImage11: TJvImage;
    Label_Link9: TLabel;
    Image13: TImage;
    Label30: TLabel;
    Label_Monkey: TLabel;
    Label34: TLabel;
    JvImage12: TJvImage;
    Label_Link10: TLabel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Image14: TImage;
    Label8: TLabel;
    Label15: TLabel;
    JvImage13: TJvImage;
    Label_Link12: TLabel;
    Image15: TImage;
    Label19: TLabel;
    Label23: TLabel;
    JvImage14: TJvImage;
    Label_Link13: TLabel;
    Bevel5: TBevel;
    Image17: TImage;
    Label25: TLabel;
    Label_AC3Filter: TLabel;
    Label33: TLabel;
    JvImage15: TJvImage;
    Label_Link14: TLabel;
    JvPoweredByJVCL1: TJvPoweredByJVCL;
    JvJVCLAboutComponent: TJvJVCLAboutComponent;
    JvPoweredByJCL1: TJvPoweredByJCL;
    Image16: TImage;
    Label32: TLabel;
    Label_MediaInfo: TLabel;
    Label36: TLabel;
    JvImage16: TJvImage;
    Label_Link15: TLabel;
    Image18: TImage;
    Image19: TImage;
    Label21: TLabel;
    Label_Shorten: TLabel;
    Label27: TLabel;
    Label_Link16: TLabel;
    JvImage17: TJvImage;
    Label35: TLabel;
    Label_TTA: TLabel;
    Label38: TLabel;
    JvImage18: TJvImage;
    Label_Link17: TLabel;
    Label_NeroAAC: TLabel;
    Image11: TImage;
    Label26: TLabel;
    Label_MPG123: TLabel;
    Label37: TLabel;
    JvImage19: TJvImage;
    Label_Link22: TLabel;
    Memo_Header: TRichEdit;
    Memo_GPL: TRichEdit;
    Image20: TImage;
    Bevel6: TBevel;
    Label_FreeSoftware: TLabel;
    Image21: TImage;
    Label28: TLabel;
    Label_TAK: TLabel;
    Label41: TLabel;
    Label_Link18: TLabel;
    JvImage20: TJvImage;
    Image22: TImage;
    Label40: TLabel;
    Label_Volumax: TLabel;
    Label43: TLabel;
    JvImage21: TJvImage;
    Label_Link19: TLabel;
    Timer_Accept: TTimer;
    Image23: TImage;
    Label42: TLabel;
    Label_GnuPG: TLabel;
    Label45: TLabel;
    JvImage22: TJvImage;
    Label_Link20: TLabel;
    Image24: TImage;
    Label44: TLabel;
    Label_WGet: TLabel;
    Label47: TLabel;
    JvImage23: TJvImage;
    Label_Link21: TLabel;
    Image25: TImage;
    Label39: TLabel;
    Label_OggVorbisDec: TLabel;
    Label48: TLabel;
    JvImage24: TJvImage;
    Label49: TLabel;
    procedure Label1MouseEnter(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Label_HomepageClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Button_CloseClick(Sender: TObject);
    procedure EasterEggMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image6Click(Sender: TObject);
    procedure Button_LicenseClick(Sender: TObject);
    procedure Button_AcceptClick(Sender: TObject);
    procedure Button_DeclineClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure JvImage1Click(Sender: TObject);
    procedure JvImage1MouseEnter(Sender: TObject);
    procedure JvImage1MouseLeave(Sender: TObject);
    procedure JvPoweredByJVCL1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Timer_AcceptTimer(Sender: TObject);
  private
    Ready: Boolean;
    FirstActivation: Boolean;
    Eggs: TObjectList;
    procedure SetVersionLabel(ALabel: TLabel);
  public
    FirstRun: Boolean;
  end;

type
  TEasterThread = class(TThread)
  private
    move_x: Boolean;
    move_y: Boolean;
  protected
    procedure MoveThem;
    procedure Execute; override;
  end;

type
  TStaticControl = class(TObject)
  private
    DefWinProc: TWndMethod;
    procedure MyWinProc(var Message: TMessage);
  public
    constructor Create(Control: TControl);
  end;

var
  Form_About: TForm_About;
  EasterThread: TEasterThread;

implementation

uses
  Unit_Main, Unit_Utils, Unit_Core, Unit_LinkTime, Unit_EasterEgg;

{$R *.dfm}

procedure TForm_About.FormCreate(Sender: TObject);
var
  Year, Month, Day: Integer;
begin
  EnableMenuItem(GetSystemMenu(Handle,False),SC_CLOSE,MF_BYCOMMAND or MF_GRAYED);
  FirstRun := False;

  TStaticControl.Create(Memo_Header);
  TStaticControl.Create(Memo_GPL);

  JvScrollBox1.VertScrollBar.Position := 0;
  EasterEgg.Top := 0;
  EasterEgg.Left := 0;

  Label_LameXP.Caption := Format('%s, Build %d (%s)', [Unit_Main.VersionStr, Unit_Main.BuildNo, GetImageLinkTimeStampAsString(True)]);
  Label_Homepage.Caption := Unit_Main.URL_Homepage;

  SetVersionLabel(Label_Lame);
  SetVersionLabel(Label_OggVorbisEnc);
  SetVersionLabel(Label_OggVorbisDec);
  SetVersionLabel(Label_FAAD);
  SetVersionLabel(Label_MPG123);
  SetVersionLabel(Label_FLAC);
  SetVersionLabel(Label_Speex);
  SetVersionLabel(Label_WavPack);
  SetVersionLabel(Label_Musepack);
  SetVersionLabel(Label_Monkey);
  SetVersionLabel(Label_AC3Filter);
  SetVersionLabel(Label_Shorten);
  SetVersionLabel(Label_TTA);
  SetVersionLabel(Label_TAK);
  SetVersionLabel(Label_MediaInfo);
  SetVersionLabel(Label_Volumax);
  SetVersionLabel(Label_GnuPG);
  SetVersionLabel(Label_WGet);


  GetImageLinkTimeStampAsIntegers(Year, Month, Day);
  Year := Max(YearOf(Date), Year);
  Memo_Header.Lines[1] := Format(Memo_Header.Lines[1], [Year]);

  Panel1.DoubleBuffered := True;
  JvScrollBox1.DoubleBuffered := True;
  Panel_Accept.DoubleBuffered := True;

  Eggs := TObjectList.Create(True);
end;

procedure TForm_About.FormShow(Sender: TObject);
var
  Temp1,Temp2: String;
const
  MinDist = 8;
begin
  Translate(self);

  with Label_FreeSoftware do
  begin
    Canvas.Font.Assign(Font);
    if Canvas.TextWidth(Caption) > Width - MinDist then
    begin
      Caption := Caption + '...';
      while (Length(Caption) > 4) and (Canvas.TextWidth(Caption) > Width - MinDist) do
      begin
        Caption := Copy(Caption, 1, Length(Caption) - 4) + '...';
      end;
    end;
  end;
  
  Ready := False;
  FirstActivation := True;

  if not FirstRun then
  begin
    DetectNeroVersion(Temp1, Temp2);
    if Temp1 <> '' then
    begin
      Label_NeroAAC.Caption := 'v' + Temp1;
      if Temp2 <> '' then
      begin
        Label_NeroAAC.Caption := Label_NeroAAC.Caption + ' (' + Temp2 + ')';
      end;
    end else begin
      Label_NeroAAC.Caption := LangStr('Message_Unknown', 'Core');
    end;
  end;

  EasterThread := TEasterThread.Create(false);

  Button_License.Down := FirstRun;
  Button_License.OnClick(Sender);

  if FirstRun then
  begin
    Panel_Accept.Show;
    Panel_Accept.BringToFront;
    Button_License.Enabled := False;
    Button_Close.Enabled := False;
    Button_Accept.Enabled := False;
    Button_Decline.Enabled := True;
    ActiveControl := nil;
  end else begin
    Panel_Accept.SendToBack;
    Panel_Accept.Hide;
    Button_License.Enabled := True;
    Button_Close.Enabled := True;
    Button_Accept.Enabled := False;
    Button_Decline.Enabled := False;
    Button_Close.SetFocus;
  end;

  EasterEgg.Visible := True;
end;

procedure TForm_About.FormActivate(Sender: TObject);
begin
  if not FirstActivation then
  begin
    Exit;
  end;

  FirstActivation := False;

  if FirstRun then
  begin
    Button_Accept.Tag := Length(Button_Accept.Caption);
    Timer_Accept.Tag := 9;
    Timer_Accept.OnTimer(Sender);
    if not PlayResoureSound('imageres.dll', 5080, True) then
    begin
      if not PlaySystemSound(['SystemStart', 'WindowsLogon'], True) then
      begin
        MessageBeep(MB_ICONINFORMATION);
      end;
    end;
    Timer_Accept.Enabled := True;
  end else begin
    MyPlaySound('ABOUT', True);
  end;
end;

procedure TForm_About.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer_Accept.Enabled := False;
  PlaySound(nil,hInstance,SND_ASYNC);

  with EasterThread do
  begin
    Terminate;
    WaitFor;
    Free;
  end;

  Eggs.Clear;
end;

procedure TForm_About.Label1MouseEnter(Sender: TObject);
begin
  with Sender as TLabel do font.Color := clRed;
end;

procedure TForm_About.Label1MouseLeave(Sender: TObject);
begin
  with Sender as TLabel do font.Color := clBlue;
end;

procedure TForm_About.Label_HomepageClick(Sender: TObject);
begin
  if Sender.ClassName = 'TLabel' then
  begin
    with Sender as TLabel do HandleURL(Caption);
  end; 
end;

procedure TForm_About.JvImage1MouseEnter(Sender: TObject);
var
  i,x: Integer;
  l: TLabel;
begin
  x := TControl(Sender).Tag;

  for i := 0 to ComponentCount-1 do
  begin
    if Components[i].Tag <> x then continue;
    if Components[i].ClassType <> TLabel then continue;
    l := Components[i] as TLabel;
    l.OnMouseEnter(l);
    Break;
  end;
end;

procedure TForm_About.JvImage1MouseLeave(Sender: TObject);
var
  i,x: Integer;
  l: TLabel;
begin
  x := TControl(Sender).Tag;

  for i := 0 to ComponentCount-1 do
  begin
    if Components[i].Tag <> x then continue;
    if Components[i].ClassType <> TLabel then continue;
    l := Components[i] as TLabel;
    l.OnMouseLeave(l);
    Break;
  end;
end;

procedure TForm_About.JvImage1Click(Sender: TObject);
var
  i,x: Integer;
  l: TLabel;
begin
  x := TControl(Sender).Tag;

  for i := 0 to ComponentCount-1 do
  begin
    if Components[i].Tag <> x then continue;
    if Components[i].ClassType <> TLabel then continue;
    l := Components[i] as TLabel;
    l.OnClick(l);
    Break;
  end;
end;

procedure TForm_About.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm_About.Button_CloseClick(Sender: TObject);
begin
  Ready := True;
  ModalResult := mrOK;
end;

procedure TForm_About.EasterEggMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  f: TForm_EasterEgg;
begin
  Randomize;

  for i := 1 to 25 do
  begin
    f := TForm_EasterEgg.Create(Application);
    with f do
    begin
      Left := Random(Screen.WorkAreaWidth);
      Top := Random(Screen.WorkAreaHeight);
      a := Random(100) >= 50;
      b := Random(100) >= 50;
      Show;
    end;
    Eggs.Add(f);
  end;

  EasterEgg.Visible := False;
end;

procedure TForm_About.Image6Click(Sender: TObject);
begin
  Label_Homepage.OnClick(Label_Homepage);
end;

procedure TForm_About.Button_LicenseClick(Sender: TObject);
begin
  if Button_License.Down then
  begin
    Panel2.BringToFront;
  end else begin
    Panel1.BringToFront;
  end;
end;

procedure TForm_About.Button_AcceptClick(Sender: TObject);
begin
  Ready := True;
  ModalResult := mrOK;
end;

procedure TForm_About.Button_DeclineClick(Sender: TObject);
begin
  Ready := True;
  ModalResult := mrAbort;
end;

procedure TForm_About.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := Ready;
end;

procedure TForm_About.JvPoweredByJVCL1Click(Sender: TObject);
begin
  JvJVCLAboutComponent.Execute;
end;

procedure TForm_About.Label2Click(Sender: TObject);
begin
  if SafeFileExists(Form_Main.Path.AppRoot + '\License.txt') then
  begin
    if ShellExecute(WindowHandle, '', PAnsiChar(Form_Main.Path.AppRoot + '\License.txt'), nil, nil, SW_MAXIMIZE) > 32 then
    begin
      Exit;
    end;
  end;

  with Sender as TLabel do
  begin
    HandleURL(Caption);
  end;
end;

procedure TForm_About.Timer_AcceptTimer(Sender: TObject);
begin
  if Timer_Accept.Tag > 0 then
  begin
    Button_Accept.Caption := Format('%s (%d)', [Copy(Button_Accept.Caption, 1, Button_Accept.Tag), Timer_Accept.Tag]);
    Timer_Accept.Tag := Timer_Accept.Tag - 1;
  end else begin
    Timer_Accept.Enabled := False;
    Button_Accept.Caption := Copy(Button_Accept.Caption, 1, Button_Accept.Tag);
    Button_Accept.Enabled := True;
  end;
end;

procedure TForm_About.SetVersionLabel(ALabel: TLabel);
var
  Index: Integer;
begin
  Index := pos('_', ALabel.Name);

  if Index > 0 then
  begin
    ALabel.Caption := Lookup(ToolVersionStr, Copy(ALabel.Name, Index + 1, Length(ALabel.Name)), '(Unknown Version)');
  end;
end;

//------------------{TEasterThread}------------------//

procedure TEasterThread.Execute;
var
  Counter: Integer;
begin
  move_x := True;
  move_y := True;

  Counter := 0;

  while not Terminated do
  begin
    MoveThem;
    Counter := (Counter + 1) mod 8;
    if Counter = 0 then
    begin
      Synchronize(Application.ProcessMessages);
    end;
  end;
end;

procedure TEasterThread.MoveThem;
const
  Delta: Integer = 1;
var
  i: Integer;
begin
  for i := 0 to Form_About.Eggs.Count-1 do
  begin
    if Terminated then Break;
    with Form_About.Eggs[i] as TForm_EasterEgg do MoveIt;
  end;

  if Terminated or (not Form_About.EasterEgg.Visible) or Form_About.Button_License.Down then
  begin
    Exit;
  end;

  if Form_About.EasterEgg.Left >= Form_About.JvScrollBox1.ClientWidth - 32 then move_x := false;
  if Form_About.EasterEgg.Left <= 0 then move_x := true;

  if Form_About.EasterEgg.Top >= Form_About.JvScrollBox1.ClientHeight - 32 then move_y := false;
  if Form_About.EasterEgg.Top <= 0 then move_y := true;

  if move_x then
  begin
    Form_About.EasterEgg.Left := Form_About.EasterEgg.Left + delta
  end else begin
    Form_About.EasterEgg.Left := Form_About.EasterEgg.Left - delta;
  end;

  if move_y then
  begin
    Form_About.EasterEgg.Top := Form_About.EasterEgg.Top + delta
  end else begin
    Form_About.EasterEgg.Top := Form_About.EasterEgg.Top - delta;
  end;

  Form_About.JvScrollBox1.Repaint;
end;

//------------------{TStaticControl}------------------//

constructor TStaticControl.Create(Control: TControl);
begin
  self.DefWinProc := Control.WindowProc;
  Control.WindowProc := self.MyWinProc;
end;

procedure TStaticControl.MyWinProc(var Message: TMessage);
const
  WM_XBUTTONDOWN =   $020B;
  WM_XBUTTONUP =     $020C;
  WM_XBUTTONDBLCLK = $020D;
  WM_UNICHAR =       $0109;
begin
  case Message.Msg of
    WM_MOUSEACTIVATE:
    begin
      Message.Result := MA_NOACTIVATEANDEAT;
      Exit;
    end;
    WM_LBUTTONDBLCLK, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_MBUTTONDBLCLK,
      WM_MBUTTONDOWN, WM_MBUTTONUP, WM_MOUSEHOVER, WM_MOUSELEAVE, WM_MOUSEMOVE,
      WM_MOUSEWHEEL, WM_NCHITTEST, WM_NCLBUTTONDBLCLK, WM_NCLBUTTONDOWN,
      WM_NCLBUTTONUP, WM_NCMBUTTONDBLCLK, WM_NCMBUTTONDOWN, WM_NCMBUTTONUP,
      WM_NCMOUSEHOVER, WM_NCMOUSELEAVE, WM_NCMOUSEMOVE, WM_NCRBUTTONDBLCLK,
      WM_NCRBUTTONDOWN, WM_NCRBUTTONUP, WM_NCXBUTTONDBLCLK, WM_NCXBUTTONDOWN,
      WM_NCXBUTTONUP, WM_RBUTTONDBLCLK, WM_RBUTTONDOWN, WM_RBUTTONUP,
      WM_XBUTTONDBLCLK, WM_XBUTTONDOWN, WM_XBUTTONUP:
    begin
      Message.Result := 0;
      SetCursor(Screen.Cursors[crArrow]);
      Exit;
    end;
    WM_ACTIVATE, WM_APPCOMMAND, WM_CHAR, WM_DEADCHAR, WM_HOTKEY, WM_KEYDOWN,
      WM_KEYUP, WM_KILLFOCUS, WM_SETFOCUS, WM_SYSDEADCHAR, WM_SYSKEYDOWN,
      WM_SYSKEYUP, WM_UNICHAR:
    begin
      Message.Result := 0;
      Exit;
    end;
  else
    self.DefWinProc(Message);
  end;
end;

end.
