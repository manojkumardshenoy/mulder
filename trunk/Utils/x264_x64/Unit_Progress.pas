unit Unit_Progress;

///////////////////////////////////////////////////////////////////////////////
interface
///////////////////////////////////////////////////////////////////////////////

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, JvExStdCtrls, JvListBox, JvComboListBox, ExtCtrls,
  JvProgressBar, JvXPProgressBar, MuldeR_Toolz, Menus, Clipbrd, Unit_Encode,
  Buttons, Math, Unit_Win7Taskbar, ImgList;

type
  TForm_Progress = class(TForm)
    Edit_Status: TEdit;
    Timer_Start: TTimer;
    List_LogFile: TJvListBox;
    ProgressBar: TJvXPProgressBar;
    PopupMenu: TPopupMenu;
    CopytoClipbaord1: TMenuItem;
    Timer_Close: TTimer;
    ImageList: TImageList;
    Button_Minimize: TBitBtn;
    Button_Pause: TBitBtn;
    Button_Resume: TBitBtn;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Timer_StartTimer(Sender: TObject);
    procedure Edit_StatusEnter(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CopytoClipbaord1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure List_LogFileClick(Sender: TObject);
    procedure List_LogFileAddString(Sender: TObject; Item: String);
    procedure Timer_CloseTimer(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure Button_MinimizeClick(Sender: TObject);
    procedure Button_PauseClick(Sender: TObject);
    procedure Button_ResumeClick(Sender: TObject);
  private
    Ready: Boolean;
    Source: String;
    Output: String;
    RCMode: TRCMode;
    RCValue: Integer;
    Pass: Byte;
    Preset: String;
    Tune: String;
    Profile: String;
    Params: String;
    Encoder: TEncode;
    x64: Boolean;
    AutoClose: Boolean;
    BuffSize: Integer;
    Info: String;
    CanSuspend: Boolean;
    procedure EncodeTerminated(Sender: TObject);
    procedure UpdateProgress(Progress: Integer);
  public
    Success: Boolean;
    function StartEncoder(Source:String; Output:String; RCMode:TRCMode; RCValue:Integer; Pass:Byte; Preset: String; Tune:String; Profile:String; Params:String; x64:Boolean; AutoClose:Boolean; BuffSize:Integer; Info:String; CanSuspend: Boolean): String;
  end;

var
  Form_Progress: TForm_Progress;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

{$R *.dfm}

///////////////////////////////////////////////////////////////////////////////
// Constructor
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.FormCreate(Sender: TObject);
var
  Menu: HMENU;
begin
  Encoder := nil;
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;

  Menu := GetSystemMenu(self.WindowHandle, False);
  EnableMenuItem(Menu, SC_MINIMIZE, MF_BYCOMMAND or MF_GRAYED);
  EnableMenuItem(Menu, SC_RESTORE, MF_BYCOMMAND or MF_GRAYED);
end;

///////////////////////////////////////////////////////////////////////////////
// Public Interface
///////////////////////////////////////////////////////////////////////////////

function TForm_Progress.StartEncoder(Source:String; Output:String; RCMode:TRCMode; RCValue:Integer; Pass:Byte; Preset: String; Tune:String; Profile:String; Params:String; x64:Boolean; AutoClose:Boolean; BuffSize:Integer; Info:String; CanSuspend: Boolean): String;
begin
  Result := '';

  if self.Visible then
  begin
    Exit;
  end;

  self.Source := Source;
  self.Output := Output;
  self.RCMode := RCMode;
  self.RCValue := RCValue;
  self.Pass := Pass;
  self.Preset := Preset;
  self.Tune := Tune;
  self.Profile := Profile;
  self.Params := Params;
  self.AutoClose := AutoClose;
  self.x64 := x64;
  self.BuffSize := BuffSize;
  self.Info := Info;
  self.Success := False;
  self.Encoder := nil;
  self.CanSuspend := CanSuspend;

  Timer_Start.Enabled := False;
  ShowModal;

  if List_LogFile.Items.Count > 0 then
  begin
    Result := List_LogFile.Items[List_LogFile.Items.Count-1];
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Show & Close
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.FormShow(Sender: TObject);
begin
  List_LogFile.Items.Clear;
  Edit_Status.Text := '';
  Ready := False;
  UpdateProgress(0);
  Timer_Start.Enabled := True;
  Button_Resume.Enabled := False;
  Button_Pause.Enabled := False;
  Button_Pause.BringToFront;
end;

procedure TForm_Progress.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := Ready or (not Assigned(Encoder));

  if not Ready then
  begin
    Encoder.Suspend;
    SetTaskbarProgressState(tbpsPaused);
    SetTaskbarOverlayIcon(ImageList, 3, 'Paused');
    if MsgBox(self.WindowHandle, 'Do you really want to abort now?', 'Abort?', MB_YESNO or MB_DEFBUTTON2 or MB_ICONWARNING or MB_TOPMOST) = idYes then
    begin
       Encoder.AbortEncode;
    end;
    SetTaskbarProgressState(tbpsNormal);
    SetTaskbarOverlayIcon(ImageList, 0, 'Running');
    Encoder.Resume;
  end
end;

procedure TForm_Progress.FormClick(Sender: TObject);
begin
  SetTaskbarProgressState(tbpsNone);
  SetTaskbarOverlayIcon(nil, 'None');
end;

///////////////////////////////////////////////////////////////////////////////
// Initialize Encoder
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.Timer_StartTimer(Sender: TObject);
begin
  Timer_Start.Enabled := False;

  SetTaskbarProgressState(tbpsIndeterminate);
  SetTaskbarOverlayIcon(ImageList, 0, 'Running');

  List_LogFile.Items.Add('Source: ' + self.Source);
  List_LogFile.Items.Add('Output: ' + self.Output);
  List_LogFile.Items.Add('Preset: ' + self.Preset);
  List_LogFile.Items.Add('Tuning: ' + self.Tune);
  List_LogFile.Items.Add('Profile: ' + self.Profile);
  if self.Params <> '' then
  begin
    List_LogFile.Items.Add('Params: ' + self.Params);
  end else begin
    List_LogFile.Items.Add('Params: (Empty)');
  end;
  List_LogFile.Items.Add('');

  Encoder := TEncode.Create(Source, Output, RCMode, RCValue, Pass, Preset, Tune, Profile, Params, List_LogFile, Edit_Status, UpdateProgress, x64, BuffSize);

  with Encoder do
  begin
    OnTerminate := EncodeTerminated;
    Resume;
  end;

  Button_Pause.Enabled := CanSuspend;
end;

///////////////////////////////////////////////////////////////////////////////
// Terminate Encoder
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.EncodeTerminated(Sender: TObject);
begin
  Ready := True;
  Success := False;
  Button_Resume.Enabled := False;
  Button_Pause.Enabled := False;
  Application.Restore;

  if not Assigned(Encoder) then Exit;

  with Encoder do begin
    if Assigned(FatalException) then
    begin
      with FatalException as Exception do
      begin
        List_LogFile.Items.Add('');
        List_LogFile.Items.Add('Exception Error: ' + Message);
        Caption := Caption + ' (Error)';
        SetTaskbarProgressState(tbpsError);
        SetTaskbarOverlayIcon(ImageList, 1, 'Error');
        MsgBox(WindowHandle, 'An unexpected error has been encountered !!!', 'Exception', MB_TOPMOST or MB_ICONERROR);
      end;
    end else
    begin
      case GetReturnValue of
        1:
        begin
          Success := True;
          UpdateProgress(100);
          Caption := Caption + ' (Compleded)';
          SetTaskbarOverlayIcon(ImageList, 2, 'Complete');
          if not AutoClose then
          begin
            MsgBox(WindowHandle, 'Encoding process has completed successfully :-)', 'Completed', MB_TOPMOST or MB_ICONINFORMATION);
          end;
        end;
        -1:
        begin
          Caption := Caption + ' (Failed)';
          SetTaskbarProgressState(tbpsError);
          SetTaskbarOverlayIcon(ImageList, 1, 'Error');
          MsgBox(WindowHandle, 'Encoding process has failed !!!', 'Failed', MB_TOPMOST or MB_ICONERROR);
        end;
        -2:
        begin
          Caption := Caption + ' (Aborted)';
          SetTaskbarProgressState(tbpsError);
          SetTaskbarOverlayIcon(ImageList, 1, 'Error');
          MsgBox(WindowHandle, 'Encoding process was aborted the user !!!', 'Failed', MB_TOPMOST or MB_ICONERROR);
        end;
        else begin
          Caption := Caption + ' (Unknown)';
          SetTaskbarProgressState(tbpsError);
          SetTaskbarOverlayIcon(ImageList, 1, 'Error');
          MsgBox(WindowHandle, 'Unknown status code. This shouldn''t happen !!!', 'Failed', MB_TOPMOST or MB_ICONERROR);
        end;
      end;
    end;
  end;

  FreeAndNil(Encoder);

  if AutoClose and Success then
  begin
    Timer_Close.Enabled := True;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Misc Callbacks
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Progress.UpdateProgress(Progress: Integer);
begin
  ProgressBar.Position := Progress;

  SetTaskbarProgressState(tbpsNormal);
  SetTaskbarProgressValue(Progress, 100);

  if x64 then
  begin
    Caption := Format('%d%% - x264 x64 - %s', [Progress, Info]);
  end else begin
    Caption := Format('%d%% - x264 x86 - %s', [Progress, Info]);
  end;

  Application.Title := Format('%d%% - x264', [Progress]);
end;

procedure TForm_Progress.Edit_StatusEnter(Sender: TObject);
begin
  ActiveControl := List_LogFile;
end;

procedure TForm_Progress.FormActivate(Sender: TObject);
begin
  ActiveControl := List_LogFile;
end;

procedure TForm_Progress.CopytoClipbaord1Click(Sender: TObject);
begin
  Clipboard.SetTextBuf(List_LogFile.Items.GetText);
end;

function WrapStr(Str: String):String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Str) do
  begin
    Result := Result + Str[i];
    if (i mod 128 = 0) then
    begin
      Result := Result + #10;
    end;
  end;
end;

procedure TForm_Progress.List_LogFileClick(Sender: TObject);
begin
  if List_LogFile.ItemIndex < 0 then Exit;
  List_LogFile.Hint := WrapStr(List_LogFile.Items[List_LogFile.ItemIndex]);
end;

procedure TForm_Progress.List_LogFileAddString(Sender: TObject; Item: String);
begin
  List_LogFile.Hint := WrapStr(Item);
end;

procedure TForm_Progress.Timer_CloseTimer(Sender: TObject);
begin
  Timer_Close.Enabled := False;
  Close;
end;

procedure TForm_Progress.Button_MinimizeClick(Sender: TObject);
begin
  ActiveControl := List_LogFile;
  Application.Minimize;
end;

procedure TForm_Progress.Button_PauseClick(Sender: TObject);
begin
  if Assigned(Encoder) then
  begin
    if Encoder.PauseEncode(True) then
    begin
      Button_Resume.Enabled := True;
      Button_Pause.Enabled := False;
      Button_Resume.BringToFront;
    end;
  end;
end;

procedure TForm_Progress.Button_ResumeClick(Sender: TObject);
begin
  if Assigned(Encoder) then
  begin
    if Encoder.PauseEncode(False) then
    begin
      Button_Pause.Enabled := True;
      Button_Resume.Enabled := False;
      Button_Pause.BringToFront;
    end;
  end;  
end;

end.
