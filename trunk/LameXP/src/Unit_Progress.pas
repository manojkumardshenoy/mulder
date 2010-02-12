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

unit Unit_Progress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, ShellAPI, Unit_Encoder, MuldeR_Toolz,
  JvExControls, JvComponent, JvGradient, Contnrs, Unit_ProcessingThread,
  Unit_SpaceChecker, ImgList, JvExComCtrls, JvListView, JvExStdCtrls, JvListComb,
  Menus, Clipbrd, Unit_LogView, Unit_Translator, JvAnimatedImage, JvGIFCtrl,
  Math, Unit_Utils, mmsystem, JvComponentBase, JvTrayIcon, JvBalloonHint,
  JvBackgrounds, JvCheckBox, JvProgressBar, JvXPProgressBar, Unit_Win7Taskbar;

type
  TForm_Progress = class(TForm)
    Label_Total: TLabel;
    Image1: TImage;
    Button_Minimize: TBitBtn;
    Button_Abort: TBitBtn;
    Panel_Header: TPanel;
    JvGradient: TJvGradient;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label_Header: TLabel;
    Label_SubHeader: TLabel;
    Timer1: TTimer;
    ImageList1: TImageList;
    ListView: TJvImageListBox;
    Button_Close: TBitBtn;
    PopupMenu1: TPopupMenu;
    Menu_CopyToClipboard: TMenuItem;
    Label_Version: TLabel;
    Menu_ShowLog: TMenuItem;
    Panel_Loading: TPanel;
    TrayIcon: TJvTrayIcon;
    Timer2: TTimer;
    JvBackground1: TJvBackground;
    Check_ShutdownComputerWhenDone: TJvCheckBox;
    Progress_Total: TJvXPProgressBar;
    Animator: TJvGIFAnimator;
    Button_Pause: TBitBtn;
    Button_Resume: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button_MinimizeClick(Sender: TObject);
    procedure Button_CloseClick(Sender: TObject);
    procedure Button_AbortClick(Sender: TObject);
    procedure Menu_CopyToClipboardClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Menu_ShowLogClick(Sender: TObject);
    procedure TrayIconClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrayIconBalloonClick(Sender: TObject);
    procedure TrayIconMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer2Timer(Sender: TObject);
    procedure Check_ShutdownComputerWhenDoneMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure Button_PauseClick(Sender: TObject);
    procedure Button_ResumeClick(Sender: TObject);
    procedure Label_VersionMouseEnter(Sender: TObject);
    procedure Label_VersionMouseLeave(Sender: TObject);
    procedure Label_VersionClick(Sender: TObject);
  private
    Errors: Integer;
    Workers: Integer;
    Threads: Integer;
    JobList: TObjectQueue;
    Aborted: Boolean;
    HideConsole: Boolean;
    LogFileBucket: TObjectBucketList;
    PlayList: TStringList;
    WorkerThreads: TObjectList;
    StartTime: DWORD;
    PopopBalloon: Boolean;
    TaskbarProgress: Boolean;
    LastBalloon: Cardinal;
    SpaceChecker: TSpaceChecker;
    procedure RunNextJob;
    procedure AllJobsCompleted;
    procedure JobCompleted(Sender: TObject);
    procedure UpdateProgress;
    procedure ShowLogFile(Item: TObject);
    procedure UpdatePlaylist(Encoder: TEncoder);
    procedure SetTaskbarStatus(State: TTaskBarProgressState; Progress: Integer; ProgressMax: Integer; IconIndex: Integer; Text: String);
    procedure ShowNotification(Header: String; Text: String; Flags:Cardinal);
  public
    FirstShow: Boolean;
    CreatePlaylist: String;
    procedure ClearJobs;
    procedure AddJob(Job: TEncoder);
    procedure SetThreads(Threads: Integer);
    procedure SetConsole(HideConsole: Boolean);
  end;

var
  Form_Progress: TForm_Progress;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

{$R *.DFM}

uses
  Unit_Main, Unit_Core, Unit_RunProcess;

///////////////////////////////////////////////////////////////////////////////
// Constructor & Destructor
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.FormCreate(Sender: TObject);
begin
  JobList := TObjectQueue.Create;
  LogFileBucket := TObjectBucketList.Create;
  PlayList := TStringList.Create;
  WorkerThreads := TObjectList.Create(False);
  ListView.DoubleBuffered := True;
  TaskbarProgress := False;

  Constraints.MinWidth := self.Width;
  Constraints.MinHeight := self.Height;

  Panel_Header.DoubleBuffered := True;
  Form_Main.Background_Form.Clients.Add(self);
end;

///////////////////////////////////////////////////////////////////////////////
// Show Form
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.FormShow(Sender: TObject);
const
  ABOVE_NORMAL_PRIORITY_CLASS: DWORD = $00008000;
var
  Instances: Integer;
begin
  if not FirstShow then Exit;
  FirstShow := False;

  Translate(self);
  SetPriorityClass(GetCurrentProcess, ABOVE_NORMAL_PRIORITY_CLASS);
  KillRunningJobs;

  Aborted := false;
  Errors := 0;
  WorkerThreads.Clear;
  Workers := 0;
  StartTime := 0;
  PopopBalloon := False;
  LastBalloon := 0;

  PlayList.Clear;
  PlayList.Add('#EXTM3U');

  ListView.Items.Clear;
  Progress_Total.Max := JobList.Count;
  Progress_Total.Min := 0;
  Progress_Total.Position := 0;

  Button_Abort.Enabled := True;
  Button_Close.Visible := False;
  Button_Minimize.BringToFront;
  Button_Resume.Visible := False;
  Button_Pause.Visible := True;
  Button_Pause.Enabled := True;
  Button_Pause.BringToFront;
  Menu_ShowLog.Enabled := False;
  Check_ShutdownComputerWhenDone.ReadOnly := False;
  Check_ShutdownComputerWhenDone.Checked := False;
  Label_Total.Caption := 'Initializing...';

  Instances := Min(Threads, self.JobList.Count);
  if Instances > 1 then begin
    with ListView.Items.Add do begin
      ImageIndex := 3;
      Text := Format(LangStr('Message_Multithreading', self.Name), [Instances]);
    end;
  end;

  TaskbarProgress := True;
  Animator.Animate := True;
  Timer1.Enabled := True;
end;

///////////////////////////////////////////////////////////////////////////////
// Close Form
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.FormClose(Sender: TObject;  var Action: TCloseAction);
begin
  SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);

  with SpaceChecker do
  begin
    Terminate;
    WaitFor;
    Free;
  end;  

  CleanUp(SearchFiles(Form_Main.Path.Temp + '\LameXP_????????.wav', True));
  CleanUp(SearchFiles(Form_Main.Path.Temp + '\LameXP_????????.wav.volumax.tmp', True));

  LogFileBucket.Clear;
  TrayIcon.Active := False;
  Timer2.Enabled := False;
  SetTaskbarStatus(tbpsNone, -1, -1, -1, '');
end;

procedure TForm_Progress.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := Button_Close.Visible;
  if not Button_Close.Visible then MessageBeep(MB_ICONWARNING);
end;

procedure TForm_Progress.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

///////////////////////////////////////////////////////////////////////////////
// Resize Form
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.FormResize(Sender: TObject);
var
  x: Integer;
const
  MinDist = 25;
begin
  x := ClientWidth - 32;
  Progress_Total.Width := x;
  ListView.Width := x;
  Check_ShutdownComputerWhenDone.Width := x;

  Animator.Left := ClientWidth - Animator.Width - 8;
  ListView.Height := ClientHeight - ListView.Top - Check_ShutdownComputerWhenDone.Height - Button_Abort.Height - 28;
  Check_ShutdownComputerWhenDone.Top := ListView.Top + ListView.Height + 4;
  Bevel2.Height := ClientHeight - Panel_Header.Height - Button_Abort.Height - 16;

  x := ClientHeight - Button_Abort.Height - 8;
  Button_Abort.Top := x;
  Button_Close.Top := x;
  Button_Minimize.Top := x;
  Button_Resume.Top := x;
  Button_Pause.Top := x;

  Button_Close.Left := ClientWidth - Button_Close.Width - 16;
  Button_Minimize.Left := Button_Close.Left;
  Button_Abort.Left := ClientWidth - Button_Close.Width - Button_Abort.Width - 20;
  Button_Resume.Left := ClientWidth - Button_Close.Width - Button_Abort.Width - Button_Pause.Width - 24;
  Button_Pause.Left := Button_Resume.Left;

  Label_Version.Top := ClientHeight - Label_Version.Height - 10;
  Label_Version.Caption := Format('%s (Build #%d)', [Unit_Main.VersionStr, Unit_Main.BuildNo]);

  if Label_Version.Width > (Button_Pause.Left - Label_Version.Left - MinDist) then
  begin
    Label_Version.Caption := Format('%s (#%d)', [Unit_Main.VersionStr, Unit_Main.BuildNo]);
  end;
  if Label_Version.Width > (Button_Pause.Left - Label_Version.Left - MinDist) then
  begin
    Label_Version.Caption := Unit_Main.VersionStr;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Initialization
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.Timer1Timer(Sender: TObject);
var
  i: Integer;
begin
  Timer1.Enabled := False;

  Workers := 0;
  StartTime := GetTickCount;

  UpdateProgress;
  SpaceChecker := TSpaceChecker.Create(Form_Main.Path.Temp, Self.ListView);

  for i := 1 to Threads do
  begin
    RunNextJob;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// External Interface
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.ClearJobs;
begin
  JobList.Free;
  JobList := TObjectQueue.Create;
end;

procedure TForm_Progress.AddJob(Job: TEncoder);
begin
  JobList.Push(Job);
end;

procedure TForm_Progress.SetThreads(Threads: Integer);
begin
  self.Threads := Max(1, Threads);
end;

procedure TForm_Progress.SetConsole(HideConsole: Boolean);
begin
  self.HideConsole := HideConsole;
end;

///////////////////////////////////////////////////////////////////////////////
// Job Control
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.RunNextJob;
var
  Encoder: TEncoder;
  ListItem: TJvImageItem;
  Thread: TProcessingThread;
begin
  if (JobList.Count < 1) or Aborted then
  begin
    if Workers < 1 then
    begin
      AllJobsCompleted;
    end;
    Exit;
  end;

  Encoder := TEncoder(JobList.Pop);

  ListItem := ListView.Items.Add;
  with ListItem do
  begin
    Text := LangStr('Message_CreatingJob', self.Name);
    ImageIndex := 0;
  end;
  ListView.ItemIndex := ListView.Items.Count - 1;

  Thread := TProcessingThread.Create(Encoder, HideConsole, ListItem);

  Thread.FreeOnTerminate := true;
  Thread.OnTerminate := JobCompleted;
  Workers := Workers + 1;
  WorkerThreads.Add(Thread);
  Thread.Resume;

  if CreatePlaylist <> '' then UpdatePlaylist(Encoder);
end;

procedure TForm_Progress.AllJobsCompleted;
var
  EndTime: DWORD;
  TotalTime: DWORD;
  PeakMemory: Cardinal;
  Str: array [0..2] of String;
begin
  Button_Abort.Enabled := False;
  Button_Resume.Visible := False;
  Button_Resume.Enabled := False;
  Button_Pause.Visible := True;
  Button_Pause.Enabled := False;
  Button_Pause.BringToFront;

  Check_ShutdownComputerWhenDone.ReadOnly := True;
  SpaceChecker.Terminate;
  
  if (CreatePlaylist <> '') and (PlayList.Count > 0) and (not Aborted) then
  begin
    try
      PlayList.SaveToFile(CreatePlaylist);
      with ListView.Items.Add do
      begin
        Text := LangStr('Message_PlaylistCreateDone', self.Name);
        ImageIndex := 1;
      end;
    except
      with ListView.Items.Add do
      begin
        Text := LangStr('Message_PlaylistCreateError', self.Name);
        ImageIndex := 2;
      end;
    end;
  end;

  Animator.Animate := False;
  EndTime := GetTickCount;

  if EndTime > StartTime then
  begin
    TotalTime := EndTime - StartTime;
  end else begin
    TotalTime := 0;
  end;  

  if Aborted then
  begin
    Application.ProcessMessages;
    SetTaskbarStatus(tbpsError, -1, -1, 8, 'Error');
    MyPlaySound('ERROR', TrayIcon.Active);
    ShowNotification(LangStr('Message_CompletetAbortedHeader', self.Name), LangStr('Message_CompletetAbortedTitle', self.Name), MB_ICONWARNING);
    Label_Total.Caption := Format(LangStr('Message_CompletetAbortedStatus', self.Name), [Progress_Total.Position-Errors, Progress_Total.Max]);
  end else begin
    if Errors > 0 then
    begin
      Application.ProcessMessages;
      SetTaskbarStatus(tbpsError, -1, -1, 8, 'Error');
      MyPlaySound('ERROR', TrayIcon.Active);
      ShowNotification(LangStr('Message_CompletetErrorsHeader', self.Name), LangStr('Message_CompletetErrorsTitle', self.Name), MB_ICONERROR);
      Label_Total.Caption := Format(LangStr('Message_CompletetErrorsStatus', self.Name), [Errors, Progress_Total.Max]);
    end else begin
      Application.ProcessMessages;
      SetTaskbarStatus(tbpsNormal, -1, -1, 9, 'Complete');
      MyPlaySound('DONE', TrayIcon.Active);
      ShowNotification(LangStr('Message_CompletetDoneHeader', self.Name), LangStr('Message_CompletetDoneTitle', self.Name), MB_ICONINFORMATION);
      Label_Total.Caption := Format(LangStr('Message_CompletetDoneStatus', self.Name), [Progress_Total.Max]);
    end;
  end;

  PeakMemory := GetPeakJobMemoryUsed;

  if PeakMemory > 0 then
  begin
    with ListView.Items.Add do
    begin
      Text := LangStr('Message_PeakMemoryUsage', self.Name) + ' ' + BytesToStr(PeakMemory);
      ImageIndex := 3;
    end;
  end;

  with ListView.Items.Add do
  begin
    Str[0] := LangStr('Message_TimeSeconds', self.Name);
    Str[1] := LangStr('Message_TimeMinutes', self.Name);
    Str[2] := LangStr('Message_TimeHours', self.Name);
    Text := Format(LangStr('Message_CompletetSummery', self.Name), [Progress_Total.Position - Errors, MillisecondsToStr(TotalTime, Str), Errors]);
    ImageIndex := 4;
  end;

  Menu_ShowLog.Enabled := True;
  Button_Close.Visible := True;
  Button_Close.BringToFront;
  ListView.ItemIndex := ListView.Items.Count - 1;

  if (not Aborted) and Check_ShutdownComputerWhenDone.Checked then
  begin
    Application.ProcessMessages;
    Sleep(1000);
    if TrayIcon.Active then
    begin
      TrayIcon.OnClick(self, mbLeft, [], 0, 0);
    end;
    MyPlaySound('SHUTDOWN', false);
    Timer2.Tag := 30;
    Timer2.Enabled := True;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Job Callback
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.JobCompleted(Sender: TObject);
var
  ListItem: TJvImageItem;
begin
  WorkerThreads.Remove(Sender);

  Progress_Total.StepBy(1);
  ListItem := TProcessingThread(Sender).GetListItem;

  with Sender as TProcessingThread do
  begin
    LogFileBucket.Add(ListItem, GetLogFile);
  end;

  if not TProcessingThread(Sender).GetResult then
  begin
    Errors := Errors + 1;
  end;

  if not Aborted then
  begin
    UpdateProgress;
  end;

  Workers := Workers - 1;
  RunNextJob;
end;

///////////////////////////////////////////////////////////////////////////////
// Progress Update
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.UpdateProgress;
begin
  Application.Title := 'LameXP [' + IntToStr(Progress_Total.Position) + '/' + IntToStr(Progress_Total.Max) + ']';
  Label_Total.Caption := Format(LangStr('Message_StatusProgress', self.Name), [Progress_Total.Position, Progress_Total.Max]);

  if TrayIcon.Active then
  begin
    TrayIcon.Hint := self.Caption + #10 + Label_Total.Caption;
  end;

  SetTaskbarStatus(tbpsNormal, Progress_Total.Position, Progress_Total.Max, 10, 'Working');
  Form_Progress.Update;
end;

procedure TForm_Progress.SetTaskbarStatus(State: TTaskBarProgressState; Progress: Integer; ProgressMax: Integer; IconIndex: Integer; Text: String);
begin
  if TaskbarProgress then
  begin
    if not SetTaskbarProgressState(State) then
    begin
      TaskbarProgress := False;
      SetTaskbarProgressState(tbpsNone);
      SetTaskbarOverlayIcon(nil, 'N/A');
      Exit;
    end;

    if not SetTaskbarOverlayIcon(ImageList1, IconIndex, Text) then
    begin
      TaskbarProgress := False;
      SetTaskbarProgressState(tbpsNone);
      SetTaskbarOverlayIcon(nil, 'N/A');
      Exit;
    end;

    if (Progress >= 0) and (ProgressMax > 0) then
    begin
      if not SetTaskbarProgressValue(Progress, ProgressMax) then
      begin
        TaskbarProgress := False;
        SetTaskbarProgressState(tbpsNone);
        SetTaskbarOverlayIcon(nil, 'N/A');
        Exit;
      end;
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Abort and Suspend/Resume
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.Button_AbortClick(Sender: TObject);
var
  i: Integer;
begin
  Aborted := True;
  Label_Total.Caption := LangStr('Message_StatusArborting', self.Name);
  Button_Abort.Enabled := False;
  Button_Resume.Enabled := False;
  Button_Pause.Enabled := False;

  if WorkerThreads.Count > 0 then
  begin
    for i := 0 to WorkerThreads.Count-1 do
    begin
      with WorkerThreads[i] as TProcessingThread do
      begin
        Abort;
        while Suspended do Resume;
      end;
    end;
  end;
end;

procedure TForm_Progress.Button_PauseClick(Sender: TObject);
var
  i: Integer;
  Success: Boolean;
begin
  Success := False;

  if (not Aborted) and (WorkerThreads.Count > 0) then
  begin
    for i := 0 to WorkerThreads.Count-1 do
    begin
      with WorkerThreads[i] as TProcessingThread do
      begin
        if PauseEncoder then Success := True;
      end;
    end;
  end;

  if Success then
  begin
    Button_Pause.Visible := False;
    Button_Resume.Visible := True;
    Button_Resume.Enabled := True;
    Button_Resume.BringToFront;
    SetTaskbarStatus(tbpsNormal, Progress_Total.Position, Progress_Total.Max, 11, 'Paused');
    Animator.Animate := False;
  end;
end;

procedure TForm_Progress.Button_ResumeClick(Sender: TObject);
var
  i: Integer;
  Success: Boolean;
begin
  Success := False;

  if WorkerThreads.Count > 0 then
  begin
    for i := 0 to WorkerThreads.Count-1 do
    begin
      with WorkerThreads[i] as TProcessingThread do
      begin
        if ResumeEncoder then Success := True;
      end;
    end;
  end;

  if Success then
  begin
    Button_Resume.Visible := False;
    Button_Pause.Visible := True;
    Button_Pause.Enabled := True;
    Button_Pause.BringToFront;
    SetTaskbarStatus(tbpsNormal, Progress_Total.Position, Progress_Total.Max, 10, 'Working');
    Animator.Animate := True;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Auto Shutdown
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.Timer2Timer(Sender: TObject);
begin
  if not Timer2.Enabled then Exit;

  if Timer2.Tag >= 0 then
  begin
    if (Timer2.Tag mod 5) = 0 then
    begin
      MessageBeep(MB_ICONWARNING);
      with ListView.Items.Add do
      begin
        Text := Format(LangStr('Message_ShutdownComputerInfo', self.Name), [Timer2.Tag]);
        ImageIndex := 7;
      end;
      ListView.ItemIndex := ListView.Items.Count - 1;
    end;
    Timer2.Tag := Timer2.Tag - 1;
    Exit;
  end;

  Timer2.Enabled := False;
  Form_Main.Flags.ShutdownOnTerminate := True;
  Application.Terminate;
end;

procedure TForm_Progress.Check_ShutdownComputerWhenDoneMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Check_ShutdownComputerWhenDone.ReadOnly then
  begin
    MessageBeep(MB_ICONWARNING);
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Log File Functions
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.Menu_ShowLogClick(Sender: TObject);
begin
  if Menu_ShowLog.Enabled then
  begin
    ShowLogFile(ListView.Items[ListView.ItemIndex]);
  end;
end;

procedure TForm_Progress.ShowLogFile(Item: TObject);
var
  Log: TStringList;
  Dummy: Pointer;
begin
  if not LogFileBucket.Find(Item, Dummy) then
  begin
    MyLangBox(self, 'Message_LogCannotDisplay', MB_ICONWARNING);
    Exit;
  end;

  try
    Log := TStringList(Dummy);

    Panel_Loading.Top := ListView.Top + ((ListView.Height - Panel_Loading.Height) div 2);
    Panel_Loading.Left := ListView.Left + ((ListView.Width - Panel_Loading.Width) div 2);
    Panel_Loading.Visible := True;
    Form_Progress.Update;
    SetCursor(Screen.Cursors[crHourGlass]);

    with TForm_LogView.Create(nil) do
    begin
      Panel_Loading.Visible := False;
      Form_Progress.Update;
      ShowLog(Log);
      Free;
    end;
  except
    MessageBeep(MB_ICONERROR);
  end
end;

procedure TForm_Progress.Menu_CopyToClipboardClick(Sender: TObject);
var
  i: Integer;
  l: TStringList;
  s: String;
begin
  if ListView.Items.Count < 1 then Exit;
  l := TStringList.Create;

  for i := 0 to ListView.Items.Count-1 do begin
    case ListView.Items[i].ImageIndex of
      0: s := '[R] ';
      1: s := '[C] ';
      2: s := '[E] ';
      3: s := '[T] ';
      4: s := '[I] ';
    else
      s := '[?] ';
    end;

    s := s + ListView.Items[i].Text;
    l.Add(s);
  end;

  Clipboard.SetTextBuf(l.GetText);
  l.Free;
end;

///////////////////////////////////////////////////////////////////////////////
// Misc Callbacks
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.Button_MinimizeClick(Sender: TObject);
begin
  TrayIcon.Hint := self.Caption;
  TrayIcon.Active := True;
  Hide;
  TrayIcon.BalloonHint('LameXP', LangStr('Message_TrayRestoreInfo', self.Name), btNone, 2500, True);
  PopopBalloon := True;
end;

procedure TForm_Progress.UpdatePlaylist(Encoder: TEncoder);
begin
  if (Encoder.Meta.Artist <> '') and (Encoder.Meta.Title <> '') then
  begin
    PlayList.Add('#EXTINF:,' + Encoder.Meta.Artist + ' - ' + Encoder.Meta.Title);
  end else begin
    if Encoder.Meta.Title <> '' then
    begin
      PlayList.Add('#EXTINF:,' + Encoder.Meta.Title);
    end;
  end;
  PlayList.Add(ExtractFileName(Encoder.OutputFile));
end;

procedure TForm_Progress.ShowNotification(Header: String; Text: String; Flags:Cardinal);
var
  t: TBalloonType;
begin
  if (not Aborted) and Check_ShutdownComputerWhenDone.Checked then Exit;

  if TrayIcon.Active then
  begin
    PopopBalloon := False;
    t := btInfo;
    if (Flags and MB_ICONWARNING) <> 0 then t := btWarning;
    if (Flags and MB_ICONERROR) <> 0 then t := btError;
    TrayIcon.HideBalloon;
    Application.ProcessMessages;
    TrayIcon.Hint := Header + #10 + Text;
    TrayIcon.BalloonHint(Header, Text, t, MaxInt, True);
  end else begin
    MyMsgBox(self, Text, Header, MB_TOPMOST or Flags);
  end;
end;

procedure TForm_Progress.TrayIconClick(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Show;
  TrayIcon.Active := False;
end;

procedure TForm_Progress.TrayIconBalloonClick(Sender: TObject);
begin
  PopopBalloon := False;
  TrayIcon.OnClick(Sender, mbLeft, [], 0, 0);
end;

procedure TForm_Progress.TrayIconMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if PopopBalloon then
  begin
    if (GetTickCount - LastBalloon) > 3000 then
    begin
      TrayIcon.BalloonHint(self.Caption, Label_Total.Caption, btNone, 2500, True);
      LastBalloon := GetTickCount;
    end;
  end;  
end;

procedure TForm_Progress.Label_VersionMouseEnter(Sender: TObject);
begin
  Label_Version.Font.Color := clMaroon;
end;

procedure TForm_Progress.Label_VersionMouseLeave(Sender: TObject);
begin
  Label_Version.Font.Color := clWhite;
end;

procedure TForm_Progress.Label_VersionClick(Sender: TObject);
begin
  HandleURL(Unit_Main.URL_Homepage);
end;

end.
