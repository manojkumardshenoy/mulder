unit Unit_MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MuldeR_Process, StdCtrls, ExtCtrls, JvDialogs, Menus, ShellAPI,
  Math, Registry, Clipbrd, Unit_TrayIcon, AppEvnts, XPMan, ComCtrls, ImgList,
  Buttons, Spin, ShlObj, Mask, JvExMask, JvSpin, MuldeR_MD5, JvDataEmbedded,
  Unit_LinkTime, StrUtils;

type
  TForm1 = class(TForm)
    Memo_Log: TMemo;
    Bevel1: TBevel;
    Button_Create: TButton;
    OpenDialog: TJvOpenDialog;
    PopupMenu1: TPopupMenu;
    Button_Preview: TButton;
    CopytoClipboard: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    Button_Kill: TButton;
    XPManifest1: TXPManifest;
    PageControl: TPageControl;
    Tab_CustomScript: TTabSheet;
    ImageList1: TImageList;
    Button_Details: TButton;
    Group_CustomScript_Editor: TGroupBox;
    Tab_DirectShow: TTabSheet;
    GroupBox3: TGroupBox;
    Edit_DirectShow: TEdit;
    Button_Open_DirectShow: TButton;
    StatusBar: TStatusBar;
    Tab_ffmpegSource: TTabSheet;
    GroupBox2: TGroupBox;
    Edit_ffmpegSource: TEdit;
    Button_Open_ffmpegSource: TButton;
    CheckBox_Autostart: TCheckBox;
    CheckBox_DirectShow_ConvertFPS: TCheckBox;
    GroupBox_DirectShowOptions: TGroupBox;
    JvSpinEdit_DirectShow_ForceFPS: TJvSpinEdit;
    CheckBox_DirectShow_ForceFPS: TCheckBox;
    CheckBox_DirectShow_Seeking: TCheckBox;
    ComboBox_DirectShow_Seeking: TComboBox;
    GroupBox_ffmpegSourceOptions: TGroupBox;
    Label_Version: TLabel;
    CheckBox_ffmpegSource_VideoTrack: TCheckBox;
    JvSpinEdit_ffmpegSource_VideoTrack: TJvSpinEdit;
    CheckBox_ffmpegSource_Seeking: TCheckBox;
    ComboBox_ffmpegSource_Seeking: TComboBox;
    KillTimer: TTimer;
    Tab_DGIndex: TTabSheet;
    GroupBox4: TGroupBox;
    Edit_DGIndex: TEdit;
    Button_Open_DGIndex: TButton;
    JvData_AVSProxy: TJvDataEmbedded;
    CheckBox_DirectShow_DSS2: TCheckBox;
    Tab_Web: TTabSheet;
    GroupBox5: TGroupBox;
    Button_Link_Avisynth: TButton;
    Button_Link_FFmpeg: TButton;
    Button_Link_DGIndex: TButton;
    Button_Link_DGAVCIndex: TButton;
    Button_Link_DSS2: TButton;
    GroupBox6: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo_CustomScript: TMemo;
    PopupMenu2: TPopupMenu;
    Loadfromfile1: TMenuItem;
    Savetofile1: TMenuItem;
    N1: TMenuItem;
    Clear1: TMenuItem;
    SaveDialog: TSaveDialog;
    Tab_AVISource: TTabSheet;
    GroupBox7: TGroupBox;
    Edit_AVISource: TEdit;
    Button_Open_AVISource: TButton;
    Radio_CustomScript_Editor: TRadioButton;
    Radio_CustomScript_External: TRadioButton;
    Group_CustomScript_External: TGroupBox;
    Edit_CustomScript: TEdit;
    Button_Open_CustomScript: TButton;
    CheckBox_ffmpegSource_PostProc: TCheckBox;
    CheckBox_ffmpegSource_Deint: TCheckBox;
    JvSpinEdit_ffmpegSource_AudioTrack: TJvSpinEdit;
    CheckBox_ffmpegSource_AudioTrack: TCheckBox;
    CheckBox_DirectShow_NoAudio: TCheckBox;
    CheckBox_ffmpegSource_NoAudio: TCheckBox;
    GroupBox_DGIndexOptions: TGroupBox;
    Edit_DGIndex_Audio: TEdit;
    Button_Open_DGIndex_Audio: TButton;
    CheckBox_DGIndex_NoAudio: TCheckBox;
    JvSpinEdit_DGIndex_AudioDelay: TJvSpinEdit;
    Label_DGIndex_AudioDelay: TLabel;
    CheckBox_DGIndex_DeinterlaceEnabled: TCheckBox;
    CheckBox_DGIndex_DeinterlaceBob: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button_CreateClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button_PreviewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure CopytoClipboardClick(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure Button_KillClick(Sender: TObject);
    procedure Button_DetailsClick(Sender: TObject);
    procedure Button_Open_DirectShowClick(Sender: TObject);
    procedure Button_Open_ffmpegSourceClick(Sender: TObject);
    procedure PageControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure CheckBox_DirectShow_ForceFPSClick(Sender: TObject);
    procedure CheckBox_DirectShow_SeekingClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure CheckBox_ffmpegSource_VideoTrackClick(Sender: TObject);
    procedure CheckBox_ffmpegSource_SeekingClick(Sender: TObject);
    procedure KillTimerTimer(Sender: TObject);
    procedure Button_Open_DGIndexClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure Label_VersionClick(Sender: TObject);
    procedure Label_VersionMouseEnter(Sender: TObject);
    procedure Label_VersionMouseLeave(Sender: TObject);
    procedure CheckBox_DirectShow_DSS2Click(Sender: TObject);
    procedure Button_Link_AvisynthClick(Sender: TObject);
    procedure Button_Link_FFmpegClick(Sender: TObject);
    procedure Button_Link_DGIndexClick(Sender: TObject);
    procedure Button_Link_DGAVCIndexClick(Sender: TObject);
    procedure Button_Link_DSS2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Loadfromfile1Click(Sender: TObject);
    procedure Savetofile1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure Button_Open_AVISourceClick(Sender: TObject);
    procedure Radio_CustomScript_EditorClick(Sender: TObject);
    procedure Button_Open_CustomScriptClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CheckBox_ffmpegSource_AudioTrackClick(Sender: TObject);
    procedure CheckBox_ffmpegSource_NoAudioClick(Sender: TObject);
    procedure Button_Open_DGIndex_AudioClick(Sender: TObject);
    procedure CheckBox_DGIndex_NoAudioClick(Sender: TObject);
    procedure CheckBox_DGIndex_DeinterlaceEnabledClick(Sender: TObject);
    procedure Edit_DGIndexChange(Sender: TObject);
  private
    Process: TConsoleProcess;
    Tray: TTrayIcon;
    ErrorFlag: Boolean;
    ErrorFlag_Avisynth: Boolean;
    ErrorFlag_Network: Boolean;
    ErrorFlag_Plugin: Boolean;
    ErrorFlag_ColorSpace: Boolean;
    ErrorFlag_AudioFormat: Boolean;
    ExpectErrorMessageFlag: Boolean;
    AvisynthErrorMessage: String;
    CleanupList: TStringList;
    AVSProxyPath: String;
    AvisynthLib: HMODULE;
    AvisynthProc: FARPROC;
    procedure ReadLine(Line: String);
    procedure ProcessExit(ExitCode: DWORD);
    procedure TrayClick(Sender: TObject);
    procedure ToggleLog(Show: Boolean);
    procedure ConnectToProxy;
    function GetTempFile(Prefix: String; Extension: String): String;
    procedure CreateProxy;
    procedure CreatePreview;
    function CreateProxy_Avisynth: String;
    function CreateProxy_DirectShow: String;
    function CreateProxy_AVISource: String;
    function CreateProxy_ffmpegSource: String;
    function CreateProxy_DGIndex: String;
    procedure LoadConfig;
    procedure SaveConfig;
    function CreateProcess(Commandline: String): THandle;
    function GetFileExtension(Filename: String): String;
    procedure URL(Address: String);
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    function GetFullPath(ShortPath: String): String;
    procedure HandleDraggedFile(Filename: String);
    function CheckAvsPlugin(Filename: String): Boolean;
    function TryRegReadString(Reg: TRegistry; ValueName: String; DefaultValue: String): String;
    function TryRegReadInteger(Reg: TRegistry; ValueName: String; DefaultValue: Integer):Integer;
    function TryRegReadBoolean(Reg: TRegistry; ValueName: String; DefaultValue: Boolean):Boolean;
  public
    BaseDir: String;
    TempPath: String;
    DefaultCaption: String;
    AvsPluginsDir: String;
  end;

var
  Form1: TForm1;
  HandshakeMessage: Cardinal;

const
  AppVersion: String = '2.20';

implementation

{$R *.dfm}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Utils
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function TForm1.GetTempFile(Prefix: String; Extension: String): String;
var
  TempFile: String;
begin
  Randomize;

  repeat
    TempFile := TempPath + Prefix + AnsiLowerCase(IntToHex(random($FFFFFFFF),8) + '.' + Extension);
  until
    not FileExists(TempFile);

  Result := TempFile;
end;

function TForm1.GetFileExtension(Filename: String): String;
var
  i,x: Integer;
begin
  x := -1;

  if Length(Filename) > 0 then begin
    for i := 1 to Length(Filename) do
    begin
      if Filename[i] = '.' then x := i;
    end;
  end;

  if x > 0 then begin
    Result := AnsiLowerCase(Copy(Filename, x+1, Length(Filename)));
  end else begin
    Result := '';
  end;
end;

function TForm1.CreateProcess(Commandline: String): THandle;
var
  si: TStartupInfo;
  pi: TProcessInformation;
begin
  ZeroMemory(@si,SizeOf(TStartupInfo));
  ZeroMemory(@pi,SizeOf(TProcessInformation));

  if not Windows.CreateProcess(nil,PAnsiChar(Commandline),nil,nil,false,0,nil,nil,si,pi) then begin
    Result := INVALID_HANDLE_VALUE;
    Exit;
  end;

  Result := pi.hProcess;
end;

function TForm1.GetFullPath(ShortPath: String):String;
var
  x: Cardinal;
  p: PAnsiChar;
begin
  SetLength(Result, GetFullPathName(PAnsiChar(ShortPath), 0, nil, p));
  x := GetFullPathName(PAnsiChar(ShortPath), Length(Result), PAnsiChar(Result), p);

  if x > 0 then
  begin
    SetLength(Result, x);
  end else begin
    Result := ShortPath;
  end;
end;

function TForm1.CheckAvsPlugin(Filename: String):Boolean;
var
  h: HMODULE;
begin
  if not FileExists(Filename) then
  begin
    Result := False;
    Exit;
  end;

  h := SafeLoadLibrary(Filename);

  if h = 0 then
  begin
    Result := False;
    Exit;
  end;

  Result := Assigned(GetProcAddress(h, '_AvisynthPluginInit2@4'));
  FreeLibrary(h);
end;

function TForm1.TryRegReadString(Reg: TRegistry; ValueName: String; DefaultValue: String):String;
begin
  Result := DefaultValue;
  try
    if Reg.ValueExists(ValueName) then
    begin
      if Reg.GetDataType(ValueName) = rdString then
      begin
        Result := Reg.ReadString(ValueName);
      end;
    end;
  except
    Result := DefaultValue;
  end;
end;

function TForm1.TryRegReadInteger(Reg: TRegistry; ValueName: String; DefaultValue: Integer):Integer;
begin
  Result := DefaultValue;
  try
    if Reg.ValueExists(ValueName) then
    begin
      if Reg.GetDataType(ValueName) = rdInteger then
      begin
        Result := Reg.ReadInteger(ValueName);
      end;
    end;
  except
    Result := DefaultValue;
  end;
end;

function TForm1.TryRegReadBoolean(Reg: TRegistry; ValueName: String; DefaultValue: Boolean):Boolean;
begin
  Result := DefaultValue;
  try
    if Reg.ValueExists(ValueName) then
    begin
      if Reg.GetDataType(ValueName) = rdInteger then
      begin
        Result := Reg.ReadBool(ValueName);
      end;
    end;
  except
    Result := DefaultValue;
  end;
end;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Common Methods
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure TForm1.ProcessExit(ExitCode: DWORD);
begin
  Memo_CustomScript.ReadOnly := False;
  Edit_DirectShow.ReadOnly := False;
  Edit_AVISource.ReadOnly := False;
  Edit_ffmpegSource.ReadOnly := False;
  Edit_DGIndex.ReadOnly := False;
  Edit_CustomScript.ReadOnly := False;

  Button_Open_DirectShow.Enabled := True;
  Button_Open_AVISource.Enabled := True;
  Button_Open_ffmpegSource.Enabled := True;
  Button_Open_DGIndex.Enabled := True;
  Button_Open_DGIndex_Audio.Enabled := True;
  Button_Open_CustomScript.Enabled := True;

  Button_Create.Enabled := True;
  Button_Create.BringToFront;
  Button_Preview.Enabled := True;
  Button_Kill.Hide;
  Button_Kill.Enabled := False;

  GroupBox_DirectShowOptions.Enabled := True;
  GroupBox_ffmpegSourceOptions.Enabled := True;
  GroupBox_DGIndexOptions.Enabled := True;
  Radio_CustomScript_Editor.Enabled := True;
  Radio_CustomScript_External.Enabled := True;

  CheckBox_Autostart.Enabled := True;
  CheckBox_DGIndex_NoAudio.OnClick(Form1);
  Edit_DGIndex.OnChange(Form1);
  
  Memo_Log.Lines.Add('');
  Memo_Log.Lines.Add('> Exit Code: ' + IntToStr(Integer(ExitCode)));

  if AvisynthErrorMessage <> '' then
  begin
    Application.MessageBox(PAnsiChar('Avisynth Error Message:' + #10#10 + AvisynthErrorMessage), 'Avisynth Proxy', MB_ICONERROR or MB_TOPMOST);
  end;

  if ErrorFlag_Avisynth then begin
    Caption := DefaultCaption + ' - Error';
    StatusBar.SimpleText := 'Error: Proxy faild to initialize Avisynth! (unable to load avisynth.dll)';
    Application.MessageBox('Apparently Avisynth is not installed on your system. Please install Avisynth an try again!', 'Avisynth Proxy', MB_ICONERROR or MB_TOPMOST);
    ShellExecute(self.Handle, 'open', 'http://sourceforge.net/project/showfiles.php?group_id=57023', nil, nil, SW_MAXIMIZE);
    Exit;
  end;

  if ErrorFlag_Network then begin
    Caption := DefaultCaption + ' - Error';
    StatusBar.SimpleText := 'Error: Proxy faild to bind the network port! (port 9999 already in use)';
    Application.MessageBox('The network port could not be bound. Usually this happens when the Proxy is already running!', 'Avisynth Proxy', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  if ErrorFlag_Plugin then begin
    Caption := DefaultCaption + ' - Error';
    StatusBar.SimpleText := 'Error: Required Avisynth plugin could not be loaded.';
    Application.MessageBox('Apparently a required Avisynth plugin is not installed. You must download and install the missing plugin!'#10'Please note that all plugin DLL''s must be located in your "Avisynth\Plugins" directory.', 'Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Exit;
  end;

  if ErrorFlag_ColorSpace then begin
    Caption := DefaultCaption + ' - Error';
    StatusBar.SimpleText := 'Error: Invalid color space detected. Only YV12 is supported!';
    Application.MessageBox('AVS Proxy has detected an invlaid color space. Currently only the YV12 (YUV 4:2:0) color space is suppoted.'#10'Please try appending ''ConvertToYV12()'' to your script!', 'Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Exit;
  end;

  if ErrorFlag_AudioFormat then begin
    Caption := DefaultCaption + ' - Error';
    StatusBar.SimpleText := 'Error: Invalid color space detected. Only YV12 is supported!';
    Application.MessageBox('AVS Proxy has detected an invlaid audio format. Currently only the 16-Bit Integer format is suppoted.'#10'Please try appending ''ConvertAudioTo16Bit()'' to your script!', 'Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Exit;
  end;

  if ErrorFlag then begin
    Caption := DefaultCaption + ' - Error';
    StatusBar.SimpleText := 'Error: Avisynth has encountered a problem! (See log for details)';
    Application.MessageBox('Avisynth has encountered a problem. Please see the log for detailed information!'#10'This may be caused by a missing plugin, an invalid setting, an improper script or an unsupported input file.','Avisynth Proxy',MB_ICONWARNING or MB_TOPMOST);
    Exit;
  end;

  Caption := DefaultCaption + ' - Stopped';
  StatusBar.SimpleText := 'Proxy has stopped.';
end;

procedure TForm1.ReadLine(Line: String);
begin
  Memo_Log.Lines.Add(Line);

  if ExpectErrorMessageFlag then
  begin
    ExpectErrorMessageFlag := False;
    AvisynthErrorMessage := Line;
  end;

  if Line = 'Avisynth error:' then
  begin
    ErrorFlag := True;
    ExpectErrorMessageFlag := True;
    KillTimer.Enabled := True;
    Exit;
  end;

  if pos('bind() failed', Line) <> 0 then
  begin
    ErrorFlag_Network := True;
    KillTimer.Enabled := True;
    Exit;
  end;

  if pos('Script error: there is no function named', Line) <> 0 then
  begin
    ErrorFlag_Plugin := True;
    KillTimer.Enabled := True;
    Exit;
  end;

  if pos('LoadPlugin: unable to load', Line) <> 0 then
  begin
    ErrorFlag_Plugin := True;
    KillTimer.Enabled := True;
    Exit;
  end;

  if pos('Only yv12!', Line) <> 0 then
  begin
    ErrorFlag_ColorSpace := True;
    KillTimer.Enabled := True;
    Exit;
  end;

  if pos('Only int16 for audio', Line) <> 0 then
  begin
    ErrorFlag_AudioFormat := True;
    KillTimer.Enabled := True;
    Exit;
  end;

  ////////////////////////////////////////////
  if KillTimer.Enabled then Exit;
  ////////////////////////////////////////////

  if Line = 'Avisynth.dll loaded' then begin
    ErrorFlag_Avisynth := False;
    Exit;
  end;

  if Line = 'Waiting for client to connect...' then begin
    Caption := DefaultCaption + ' - Ready';
    StatusBar.SimpleText := 'Proxy has been created. Go to Avidemux and choose ''Connect to avsproxy'' from menu...';
    ErrorFlag := False;
    Button_Kill.Enabled := True;
    if CheckBox_Autostart.Checked then ConnectToProxy;
    Exit;
  end;

  if Line = 'Client connected.' then begin
    Caption := DefaultCaption + ' - Connected';
    StatusBar.SimpleText := 'Connection to proxy has been established successfully :-)';
    ErrorFlag := False;
    Exit;
  end;

  if pos('Error in receivedata: header', Line) <> 0 then
  begin
    KillTimer.Enabled := True;
    Exit;
  end;
end;

procedure TForm1.TrayClick(Sender: TObject);
begin
  Show;
  Application.Restore;
  SetForegroundWindow(WindowHandle);
  Tray.Hide;
end;

procedure TForm1.ToggleLog(Show: Boolean);
begin
  if Show then begin
    self.ClientHeight := CheckBox_Autostart.Top + CheckBox_Autostart.Height + StatusBar.Height + 12;
  end else begin
    self.ClientHeight := Button_Create.Top + Button_Create.Height + StatusBar.Height + 12;
  end;
end;

procedure TForm1.ConnectToProxy;
var
  Data: TStringList;
  i: Integer;
  ProxyFile: String;
  AvidemuxExec: String;
begin
  AvidemuxExec := '';

  if FileExists(BaseDir + 'avidemux2.exe') then
  begin
    AvidemuxExec := BaseDir + 'avidemux2.exe';
  end;

  if (AvidemuxExec = '') and FileExists(BaseDir + 'avidemux2_qt4.exe') then
  begin
    AvidemuxExec := BaseDir + 'avidemux2_qt4.exe';
  end;

  if (AvidemuxExec = '') and FileExists(BaseDir + 'avidemux2_gtk.exe') then
  begin
    AvidemuxExec := BaseDir + 'avidemux2_gtk.exe';
  end;

  if Length(AvidemuxExec) < 8 then
  begin
    Application.MessageBox('Failed to start Avidemux:'#10'The Avidemux executable could not be found in current directory!','AVS Proxy', MB_ICONERROR or MB_TOPMOST);
    Application.MessageBox('Please run Avidemux and connect to the AVS Proxy manually!','AVS Proxy', MB_ICONWARNING or MB_TOPMOST);
    Exit;
  end;

  Data := TStringList.Create;
  Data.Add('ADAP');

  for i := 1 to 5 do begin
    Data.Add('lkmlfdkmdlkdmlkdmflfkmkfmfdlkmflkfdmldkf');
  end;

  ProxyFile := GetTempFile('','avsproxy');
  Data.SaveToFile(ProxyFile);
  CleanupList.Add(ProxyFile);
  Data.Free;

  if CreateProcess('"' + AvidemuxExec + '" "' + ProxyFile + '"') = INVALID_HANDLE_VALUE then
  begin
    Application.MessageBox('Faild to run Avidemux. The process could not be created!','AVS Proxy', MB_ICONERROR or MB_TOPMOST);
  end;
end;

procedure TForm1.LoadConfig;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;

  if reg.OpenKeyReadOnly('SOFTWARE\MuldeR\AVS_Proxy') then
  begin
    Memo_CustomScript.Lines.CommaText := TryRegReadString(reg, 'avs_script', Memo_CustomScript.Lines.CommaText);
    Edit_DirectShow.Text := TryRegReadString(reg, 'dshow', Edit_DirectShow.Text);
    Edit_AVISource.Text := TryRegReadString(reg, 'avisrc', Edit_AVISource.Text);
    Edit_ffmpegSource.Text := TryRegReadString(reg, 'ffmpeg', Edit_ffmpegSource.Text);
    Edit_DGIndex.Text := TryRegReadString(reg, 'dgindex', Edit_DGIndex.Text);
    Edit_CustomScript.Text := TryRegReadString(reg, 'custom', Edit_CustomScript.Text);
    CheckBox_Autostart.Checked := TryRegReadBoolean(reg, 'autostart', CheckBox_Autostart.Checked);
    PageControl.ActivePageIndex := TryRegReadInteger(reg, 'input', PageControl.ActivePageIndex);
    CheckBox_DirectShow_ForceFPS.Checked := TryRegReadBoolean(reg, 'dshow_fps', CheckBox_DirectShow_ForceFPS.Checked);
    JvSpinEdit_DirectShow_ForceFPS.Value := TryRegReadInteger(reg, 'dshow_fps_value', JvSpinEdit_DirectShow_ForceFPS.AsInteger * 1000) / 1000;
    CheckBox_DirectShow_ConvertFPS.Checked := TryRegReadBoolean(reg, 'dshow_fps_convert', CheckBox_DirectShow_ConvertFPS.Checked);
    CheckBox_DirectShow_Seeking.Checked := TryRegReadBoolean(reg, 'dshow_seek', CheckBox_DirectShow_Seeking.Checked);
    ComboBox_DirectShow_Seeking.ItemIndex := TryRegReadInteger(reg, 'dshow_seek_mode', ComboBox_DirectShow_Seeking.ItemIndex);
    CheckBox_DirectShow_DSS2.Checked := TryRegReadBoolean(reg, 'dshow_dss2', CheckBox_DirectShow_DSS2.Checked);
    CheckBox_DirectShow_NoAudio.Checked := TryRegReadBoolean(reg, 'dshow_no_audio', CheckBox_DirectShow_NoAudio.Checked);
    CheckBox_ffmpegSource_NoAudio.Checked := TryRegReadBoolean(reg, 'ffmpeg_no_audio', CheckBox_ffmpegSource_NoAudio.Checked);
    CheckBox_ffmpegSource_VideoTrack.Checked := TryRegReadBoolean(reg, 'ffmpeg_track', CheckBox_ffmpegSource_VideoTrack.Checked);
    CheckBox_ffmpegSource_AudioTrack.Checked := TryRegReadBoolean(reg, 'ffmpeg_audio', CheckBox_ffmpegSource_AudioTrack.Checked);
    JvSpinEdit_ffmpegSource_VideoTrack.AsInteger := TryRegReadInteger(reg, 'ffmpeg_track_id', JvSpinEdit_ffmpegSource_VideoTrack.AsInteger);
    JvSpinEdit_ffmpegSource_AudioTrack.AsInteger := TryRegReadInteger(reg, 'ffmpeg_audio_id', JvSpinEdit_ffmpegSource_AudioTrack.AsInteger);
    CheckBox_ffmpegSource_Seeking.Checked := TryRegReadBoolean(reg, 'ffmpeg_seek', CheckBox_ffmpegSource_Seeking.Checked);
    ComboBox_ffmpegSource_Seeking.ItemIndex := TryRegReadInteger(reg, 'ffmpeg_seek_mode', ComboBox_ffmpegSource_Seeking.ItemIndex);
    CheckBox_ffmpegSource_Deint.Checked := TryRegReadBoolean(reg, 'ffmpeg_deint', CheckBox_ffmpegSource_Deint.Checked);
    CheckBox_ffmpegSource_PostProc.Checked := TryRegReadBoolean(reg, 'ffmpeg_pp', CheckBox_ffmpegSource_PostProc.Checked);
    Edit_DGIndex_Audio.Text := TryRegReadString(reg, 'dgindex_audio_file', Edit_DGIndex_Audio.Text);
    CheckBox_DGIndex_NoAudio.Checked := TryRegReadBoolean(reg, 'dgindex_no_audio', CheckBox_DGIndex_NoAudio.Checked);
    JvSpinEdit_DGIndex_AudioDelay.AsInteger := TryRegReadInteger(reg, 'dgindex_audio_dely', JvSpinEdit_DGIndex_AudioDelay.AsInteger);

    case TryRegReadInteger(reg, 'custom_mode', -1) of
      1: Radio_CustomScript_Editor.Checked := True;
      2: Radio_CustomScript_External.Checked := True;
    end;

    OpenDialog.InitialDir := TryRegReadString(reg, 'path_open', OpenDialog.InitialDir);
    SaveDialog.InitialDir := TryRegReadString(reg, 'path_open', SaveDialog.InitialDir);

    reg.CloseKey;
  end;

  Reg.Free;

  CheckBox_DirectShow_ForceFPS.OnClick(self);
  CheckBox_DirectShow_Seeking.OnClick(self);
  CheckBox_DirectShow_DSS2.OnClick(self);
  CheckBox_ffmpegSource_VideoTrack.OnClick(self);
  CheckBox_ffmpegSource_Seeking.OnClick(self);
  CheckBox_ffmpegSource_NoAudio.OnClick(self);
  CheckBox_DGIndex_NoAudio.OnClick(self);
  Radio_CustomScript_Editor.OnClick(self);
  Edit_DGIndex.OnChange(self);
end;

procedure TForm1.SaveConfig;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;

  if reg.OpenKey('SOFTWARE\MuldeR\AVS_Proxy', true) then
  begin
    reg.WriteString('avs_script', Memo_CustomScript.Lines.CommaText);
    reg.WriteString('dshow',Edit_DirectShow.Text);
    reg.WriteString('avisrc',Edit_AVISource.Text);
    reg.WriteString('ffmpeg',Edit_ffmpegSource.Text);
    reg.WriteString('dgindex',Edit_DGIndex.Text);
    reg.WriteString('custom',Edit_CustomScript.Text);
    reg.WriteBool('autostart',CheckBox_Autostart.Checked);
    reg.WriteInteger('input',PageControl.ActivePageIndex);
    reg.WriteBool('dshow_fps',CheckBox_DirectShow_ForceFPS.Checked);
    reg.WriteInteger('dshow_fps_value', Round(JvSpinEdit_DirectShow_ForceFPS.Value * 1000));
    reg.WriteBool('dshow_fps_convert',CheckBox_DirectShow_ConvertFPS.Checked);
    reg.WriteBool('dshow_seek',CheckBox_DirectShow_Seeking.Checked);
    reg.WriteInteger('dshow_seek_mode',ComboBox_DirectShow_Seeking.ItemIndex);
    reg.WriteBool('dshow_dss2',CheckBox_DirectShow_DSS2.Checked);
    reg.WriteBool('dshow_no_audio',CheckBox_DirectShow_NoAudio.Checked);
    reg.WriteBool('ffmpeg_no_audio',CheckBox_ffmpegSource_NoAudio.Checked);
    reg.WriteBool('ffmpeg_track',CheckBox_ffmpegSource_VideoTrack.Checked);
    reg.WriteBool('ffmpeg_audio',CheckBox_ffmpegSource_VideoTrack.Checked);
    reg.WriteInteger('ffmpeg_track_id',JvSpinEdit_ffmpegSource_VideoTrack.AsInteger);
    reg.WriteInteger('ffmpeg_audio_id',JvSpinEdit_ffmpegSource_AudioTrack.AsInteger);
    reg.WriteBool('ffmpeg_seek',CheckBox_ffmpegSource_Seeking.Checked);
    reg.WriteInteger('ffmpeg_seek_mode',ComboBox_ffmpegSource_Seeking.ItemIndex);
    reg.WriteBool('ffmpeg_deint',CheckBox_ffmpegSource_Deint.Checked);
    reg.WriteBool('ffmpeg_pp',CheckBox_ffmpegSource_PostProc.Checked);
    reg.WriteString('dgindex_audio_file',Edit_DGIndex_Audio.Text);
    reg.WriteBool('dgindex_no_audio',CheckBox_DGIndex_NoAudio.Checked);
    reg.WriteInteger('dgindex_audio_dely',JvSpinEdit_DGIndex_AudioDelay.AsInteger);

    if Radio_CustomScript_Editor.Checked then
    begin
      reg.WriteInteger('custom_mode',1);
    end;
    if Radio_CustomScript_External.Checked then
    begin
      reg.WriteInteger('custom_mode',2);
    end;
    if FileExists(OpenDialog.FileName) then
    begin
      reg.WriteString('path_open', ExtractFilePath(OpenDialog.FileName));
    end;
    if FileExists(SaveDialog.FileName) then
    begin
      reg.WriteString('path_save', ExtractFilePath(SaveDialog.FileName));
    end;
    reg.CloseKey;
  end;

  reg.Free;
end;

procedure TForm1.CreateProxy;
var
  ScriptFile: String;
begin
  if KillTimer.Enabled then Exit;

  ///////////////////////////////////////////////////////////////////////////////////////////

  if AvisynthLib = 0 then
  begin
    AvisynthLib := SafeLoadLibrary('avisynth.dll');
  end;

  if not Assigned(AvisynthProc) then
  begin
    if AvisynthLib <> 0 then
    begin
      AvisynthProc := GetProcAddress(AvisynthLib, 'CreateScriptEnvironment');
    end;  
  end;

  if not Assigned(AvisynthProc) then
  begin
    MessageBox(self.Handle,'Unable to load Avisynth library. Apparently Avisynth is not installed on this system.' + #10#10 + 'Please install Avisynth now and retry!','AVS Proxy', MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
    Exit;
  end;

  ///////////////////////////////////////////////////////////////////////////////////////////

  ScriptFile := '';

  if PageControl.ActivePage = Tab_CustomScript then begin
    ScriptFile := CreateProxy_Avisynth;
  end;

  if PageControl.ActivePage = Tab_DirectShow then begin
    ScriptFile := CreateProxy_DirectShow;
  end;

  if PageControl.ActivePage = Tab_AVISource then begin
    ScriptFile := CreateProxy_AVISource;
  end;

  if PageControl.ActivePage = Tab_ffmpegSource then begin
    ScriptFile := CreateProxy_ffmpegSource;
  end;

  if PageControl.ActivePage = Tab_DGIndex then begin
    ScriptFile := CreateProxy_DGIndex;
  end;

  ///////////////////////////////////////////////////////////////////////////////////////////

  if ScriptFile = '' then
  begin
    MessageBox(self.Handle,'Please choose one of the other tabs!','AVS Proxy', MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL);
    Exit;
  end;

  if ScriptFile = '?' then Exit;

  ///////////////////////////////////////////////////////////////////////////////////////////

  if (AVSProxyPath = '') or (not FileExists(AVSProxyPath)) then
  begin
    AVSProxyPath := GetTempFile('avsproxy_','exe');
    try
      JVData_AVSProxy.DataSaveToFile(AVSProxyPath);
      CleanupList.Add(AVSProxyPath);
    except
      AVSProxyPath := '';
      Exit;
    end;
  end;

  Memo_Log.Clear;

  ErrorFlag := True;
  ErrorFlag_Avisynth := True;
  ErrorFlag_Network := False;
  ErrorFlag_Plugin := False;
  ErrorFlag_ColorSpace := False;
  ErrorFlag_AudioFormat := False;

  ExpectErrorMessageFlag := False;
  AvisynthErrorMessage := '';

  Process.Priority := ppBelowNormal;
  try
    Process.Start('"' + AVSProxyPath + '" "' + ScriptFile + '"');
  except
    on e:Exception do begin
      Application.MessageBox(PAnsiChar(e.Message), 'Faild to create process', MB_ICONERROR or MB_TOPMOST);
      raise Exception.Create(e.Message);
    end;
  end;

  Caption := DefaultCaption + ' - Starting';

  Memo_CustomScript.ReadOnly := True;
  Edit_DirectShow.ReadOnly := True;
  Edit_AVISource.ReadOnly := True;
  Edit_ffmpegSource.ReadOnly := True;
  Edit_DGIndex.ReadOnly := True;
  Edit_CustomScript.ReadOnly := True;

  Button_Open_DirectShow.Enabled := False;
  Button_Open_AVISource.Enabled := False;
  Button_Open_ffmpegSource.Enabled := False;
  Button_Open_DGIndex.Enabled := False;
  Button_Open_DGIndex_Audio.Enabled := False;
  Button_Open_CustomScript.Enabled := False;

  GroupBox_DirectShowOptions.Enabled := False;
  GroupBox_ffmpegSourceOptions.Enabled := False;
  GroupBox_DGIndexOptions.Enabled := False;
  Radio_CustomScript_Editor.Enabled := False;
  Radio_CustomScript_External.Enabled := False;

  Button_Create.Enabled := False;
  Button_Preview.Enabled := False;
  Button_Kill.Show;
  Button_Kill.Enabled := False;
  Button_Kill.BringToFront;

  CheckBox_DGIndex_DeinterlaceEnabled.Enabled := False;
  CheckBox_DGIndex_DeinterlaceBob.Enabled := False;
  
  CheckBox_Autostart.Enabled := False;
  StatusBar.SimpleText := 'Creating proxy, please wait...';
end;

procedure TForm1.CreatePreview;
var
  ScriptFile: String;
  Reg: TRegistry;
  Instdir: String;
begin
  ScriptFile := '';

  if PageControl.ActivePage = Tab_CustomScript then begin
    ScriptFile := CreateProxy_Avisynth;
  end;

  if PageControl.ActivePage = Tab_DirectShow then begin
    ScriptFile := CreateProxy_DirectShow;
  end;

  if PageControl.ActivePage = Tab_AVISource then begin
    ScriptFile := CreateProxy_AVISource;
  end;

  if PageControl.ActivePage = Tab_ffmpegSource then begin
    ScriptFile := CreateProxy_ffmpegSource;
  end;

  if PageControl.ActivePage = Tab_DGIndex then begin
    ScriptFile := CreateProxy_DGIndex;
  end;

  ///////////////////////////////////////////////////////////////////////////////////////////

  if (ScriptFile = '') or (ScriptFile = '?') then Exit;

  Instdir := '';

  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_LOCAL_MACHINE;

  if Reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DB9E4EAB-2717-499F-8D56-4CC8A644AB60}') then
  begin
    Instdir := TryRegReadString(Reg, 'InstallLocation', '');
    Reg.CloseKey;
  end;

  Reg.Free;

  if (Instdir <> '') and FileExists(Instdir + '\MPlayer.exe') then
  begin
    if FileExists(Instdir + '\SMPlayer.exe') then
    begin
      CreateProcess('"' + Instdir + '\SMPlayer.exe" "' + ScriptFile + '"');
      Exit;
    end;
    if FileExists(Instdir + '\SMPlayer_portable.exe') then
    begin
      CreateProcess('"' + Instdir + '\SMPlayer_portable.exe" "' + ScriptFile + '"');
      Exit;
    end;
    if FileExists(Instdir + '\MPUI.exe') then
    begin
      CreateProcess('"' + Instdir + '\MPUI.exe" "' + ScriptFile + '"');
      Exit;
    end;
    CreateProcess('"' + Instdir + '\MPlayer.exe" "' + ScriptFile + '"');
  end
  else if FileExists(BaseDir + '\MPlayer.exe') then
  begin
    CreateProcess('"' + BaseDir + 'MPlayer.exe" "' + ScriptFile + '"');
    Exit;
  end else
  begin
    ShellExecute(WindowHandle, 'play', PAnsiChar(ScriptFile), nil, nil, SW_SHOW);
  end;
end;

procedure TForm1.HandleDraggedFile(Filename: String);
var
  Ext: String;
begin
  if not Button_Create.Enabled then
  begin
    MessageBeep(MB_ICONERROR);
    Button_Kill.SetFocus;
    Exit;
  end;

  Ext := GetFileExtension(Filename);

  if SameText(Ext, 'avs') then
  begin
    PageControl.ActivePage := Tab_CustomScript;
    Radio_CustomScript_External.Checked := True;
    Edit_CustomScript.Text := Filename;
  end
  else if SameText(Ext, 'dga') or SameText(Ext, 'd2v') or SameText(Ext, 'dgi') then
  begin
    PageControl.ActivePage := Tab_DGIndex;
    Edit_DGIndex.Text := Filename;
  end
  else if (SameText(Ext, 'avi') or SameText(Ext, 'divx')) and (PageControl.ActivePage = Tab_AVISource) then
  begin
    Edit_AVISource.Text := Filename;
  end
  else if PageControl.ActivePage = Tab_DirectShow then
  begin
    Edit_DirectShow.Text := Filename;
  end
  else begin
    PageControl.ActivePage := Tab_ffmpegSource;
    Edit_ffmpegSource.Text := Filename;
  end;

  CreateProxy;
end;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Source Types
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function TForm1.CreateProxy_Avisynth: String;
var
  ScriptFile: String;
begin
  if Radio_CustomScript_Editor.Checked then
  begin
    ScriptFile := GetTempFile('avisynth_','avs');
    try
      Memo_CustomScript.Lines.SaveToFile(ScriptFile);
    except
      Result := '?';
      Exit;
    end;
    CleanupList.Add(ScriptFile);
    Result := ScriptFile;
    Exit;
  end;

  ////////////////////////////////////////////////////

  if not FileExists(Edit_CustomScript.Text) then begin
    Application.MessageBox('Sorry, the selected video file could not be found!','Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Result := '?';
    Exit;
  end;

  ////////////////////////////////////////////////////

  Result := Edit_CustomScript.Text;
end;

function TForm1.CreateProxy_DirectShow: String;
var
  Script: TStringList;
  ScriptFile: String;
  Line:String;
  Format: TFormatSettings;
  Res: Integer;
begin
  if not FileExists(Edit_DirectShow.Text) then begin
    Application.MessageBox('Sorry, the selected video file could not be found!','Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Result := '?';
    Exit;
  end;

  ////////////////////////////////////////////////////

  if CheckBox_DirectShow_DSS2.Checked then
  begin
    while not ((AvsPluginsDir = '') or CheckAvsPlugin(AvsPluginsDir + '\avss.dll')) do
    begin
      Res := Application.MessageBox('Sorry, it appears that the required DirectShowSource2 plugin (avss.dll) is not installed.' + #10 + 'Please make sure the plugin is located in your Avisynth "Plugins" directory!', 'Avisynth Proxy', MB_ICONWARNING or MB_ABORTRETRYIGNORE);
      if Res = ID_ABORT then
      begin
        Result := '?';
        Exit;
      end;
      if Res = ID_IGNORE then
      begin
        Break;
      end;
    end;
  end;

  ////////////////////////////////////////////////////

  GetLocaleFormatSettings(0,Format);
  Format.DecimalSeparator := '.';

  Line := '"' + Edit_DirectShow.Text + '"';

  if not CheckBox_DirectShow_DSS2.Checked then
  begin
    if CheckBox_DirectShow_NoAudio.Checked then
    begin
      Line := Line + ', audio=false';
    end else begin
      Line := Line + ', audio=true';
    end;
  end;

  ////////////////////////////////////////////////////

  if CheckBox_DirectShow_ForceFPS.Checked then
  begin
    Line := Line + ', fps=' + FloatToStr(JvSpinEdit_DirectShow_ForceFPS.Value, Format);
  end;

  if CheckBox_DirectShow_ForceFPS.Checked and CheckBox_DirectShow_ConvertFPS.Checked and (not CheckBox_DirectShow_DSS2.Checked) then
  begin
    Line := Line + ', convertfps=true';
  end;

  if CheckBox_DirectShow_Seeking.Checked and (not CheckBox_DirectShow_DSS2.Checked) then
  begin
    case ComboBox_DirectShow_Seeking.ItemIndex of
      0: Line := Line + ', seekzero=true';
      1: Line := Line + ', seek=false';
    end;
  end;

  ////////////////////////////////////////////////////

  Script := TStringList.Create;

  if CheckBox_DirectShow_DSS2.Checked then
  begin
    Script.Add('DSS2(' + Line + ')');
  end else begin
    Script.Add('DirectShowSource(' + Line + ')');
  end;

  Script.Add('ConvertToYV12()');
  Script.Add('ConvertAudioTo16bit()');

  ScriptFile := GetTempFile('dshow_','avs');
  Script.SaveToFile(ScriptFile);
  CleanupList.Add(ScriptFile);
  Script.Free;

  Result := ScriptFile;
end;

function TForm1.CreateProxy_AVISource: String;
var
  Script: TStringList;
  ScriptFile: String;
begin
  if not FileExists(Edit_AVISource.Text) then begin
    Application.MessageBox('Sorry, the selected video file could not be found!','Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Result := '?';
    Exit;
  end;

  ////////////////////////////////////////////////////

  Script := TStringList.Create;

  Script.Add('AVISource("' + Edit_AVISource.Text + '")');
  Script.Add('ConvertToYV12()');
  Script.Add('ConvertAudioTo16bit()');

  ScriptFile := GetTempFile('avisource_','avs');
  Script.SaveToFile(ScriptFile);
  CleanupList.Add(ScriptFile);
  Script.Free;

  Result := ScriptFile;
end;

function TForm1.CreateProxy_ffmpegSource: String;
var
  Script: TStringList;
  ScriptFile: String;
  Line: String;
  Line2: String;
  PP: String;
  Res: Integer;
begin
  if not FileExists(Edit_ffmpegSource.Text) then begin
    Application.MessageBox('Sorry, the selected video file could not be found!','Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Result := '?';
    Exit;
  end;

  while not ((AvsPluginsDir = '') or CheckAvsPlugin(AvsPluginsDir + '\ffms2.dll')) do
  begin
    Res := Application.MessageBox('Sorry, it appears that the required FFmpegSource2 plugin (ffms2.dll) is not installed.' + #10 + 'Please make sure the plugin is located in your Avisynth "Plugins" directory!', 'Avisynth Proxy', MB_ICONWARNING or MB_ABORTRETRYIGNORE);
    if Res = ID_ABORT then
    begin
      Result := '?';
      Exit;
    end;
    if Res = ID_IGNORE then
    begin
      Break;
    end;
  end;

  ////////////////////////////////////////////////////

  Line := '"' + Edit_ffmpegSource.Text + '"';
  Line := Line + ', cachefile="' + TempPath + MD5Print(MD5String(Edit_ffmpegSource.Text)) + '.ffindex"';

  Line2 := '"' + Edit_ffmpegSource.Text + '"';
  Line2 := Line2 + ', cachefile="' + TempPath + MD5Print(MD5String(Edit_ffmpegSource.Text + '::Audio::')) + '.ffindex"';

  ////////////////////////////////////////////////////

  if CheckBox_ffmpegSource_VideoTrack.checked then begin
    Line := Line + ', track=' + IntToStr(JvSpinEdit_ffmpegSource_VideoTrack.AsInteger);
  end;

  if CheckBox_ffmpegSource_AudioTrack.checked then begin
    Line2 := Line2 + ', track=' + IntToStr(JvSpinEdit_ffmpegSource_AudioTrack.AsInteger);
  end;

  ////////////////////////////////////////////////////

  if CheckBox_ffmpegSource_Seeking.checked then begin
    case ComboBox_ffmpegSource_Seeking.ItemIndex of
      0: Line := Line + ', seekmode=-1';
      1: Line := Line + ', seekmode=0';
      2: Line := Line + ', seekmode=1';
      3: Line := Line + ', seekmode=2';
      4: Line := Line + ', seekmode=3';
    end;
  end;

  ////////////////////////////////////////////////////

  PP := '';

  if CheckBox_ffmpegSource_PostProc.Checked then
  begin
    PP := PP + 'ac';
  end;

  if CheckBox_ffmpegSource_Deint.Checked then
  begin
    if PP <> '' then PP := PP + ',';
    PP := PP + 'fd';
  end;

  if PP <> '' then
  begin
    Line := Line + ', pp="' + PP + '"';
  end;

  ////////////////////////////////////////////////////

  Line := Line + ', colorspace = "YV12"';

  ////////////////////////////////////////////////////

  Script := TStringList.Create;

  if not CheckBox_ffmpegSource_NoAudio.Checked then
  begin
    Script.Add('V = FFVideoSource(' + Line + ')');
    Script.Add('A = FFAudioSource(' + Line2 + ')');
    Script.Add('AudioDub(V,A)');
    Script.Add('ConvertAudioTo16bit()');
  end else begin
    Script.Add('FFVideoSource(' + Line + ')');
  end;

  ScriptFile := GetTempFile('ffmpeg_','avs');
  Script.SaveToFile(ScriptFile);
  CleanupList.Add(ScriptFile);
  Script.Free;

  Result := ScriptFile;
end;

function TForm1.CreateProxy_DGIndex: String;
var
  Script: TStringList;
  ScriptFile: String;
  Line: String;
  Line2: String;
  Mode: Integer;
  Mode2: Integer;
  Extension: String;
  Res: Integer;
  Delay: Integer;
  DeintMode: Integer;
begin
  if not FileExists(Edit_DGIndex.Text) then begin
    Application.MessageBox('Sorry, the selected project file could not be found!','Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Result := '?';
    Exit;
  end;

  if not CheckBox_DGIndex_NoAudio.Checked then
  begin
    if Trim(Edit_DGIndex_Audio.Text) = '' then
    begin
      if Application.MessageBox('No audio file selected. Do you want to disable audio delivery?','Avisynth Proxy', MB_YESNO or MB_DEFBUTTON2 or MB_ICONWARNING or MB_TOPMOST) = ID_YES then
      begin
        CheckBox_DGIndex_NoAudio.Checked := True;
      end;
      Result := '?';
      Exit;
    end;

    if not FileExists(Edit_DGIndex_Audio.Text) then begin
      Application.MessageBox('Sorry, the selected audio file could not be found!','Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
      Result := '?';
      Exit;
    end;
  end;

  ////////////////////////////////////////////////////

  if not CheckBox_DGIndex_NoAudio.Checked then
  begin
    while not ((AvsPluginsDir = '') or CheckAvsPlugin(AvsPluginsDir + '\NicAudio.dll')) do
    begin
      Res := Application.MessageBox('Sorry, it appears that the required NicAudio plugin (NicAudio.dll) is not installed.' + #10 + 'Please make sure the plugin is located in your Avisynth "Plugins" directory!', 'Avisynth Proxy', MB_ICONWARNING or MB_ABORTRETRYIGNORE);
      if Res = ID_ABORT then
      begin
        Result := '?';
        Exit;
      end;
      if Res = ID_IGNORE then
      begin
        Break;
      end;
    end;
  end;

  ////////////////////////////////////////////////////

  Extension := GetFileExtension(Edit_DGIndex.Text);

  Mode := -1;
  if Extension = 'd2v' then Mode := 0;
  if Extension = 'dga' then Mode := 1;
  if Extension = 'dgi' then Mode := 2;

  if Mode < 0 then
  begin
    Application.MessageBox('Sorry, you must select a D2V, DGA or DGI project file.'#10#10'Please use the DGIndex, DGAVCIndex or DGIndexNV program to create D2V, DGA or DGI project file from your source video file!','Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Result := '?';
    Exit;
  end;

  ////////////////////////////////////////////////////

  Extension := GetFileExtension(Edit_DGIndex_Audio.Text);

  Mode2 := -1;
  if Extension = 'mp2' then Mode2 := 0;
  if Extension = 'mp3' then Mode2 := 0;
  if Extension = 'ac3' then Mode2 := 1;
  if Extension = 'dts' then Mode2 := 2;

  if (Mode2 < 0) and (not CheckBox_DGIndex_NoAudio.Checked) then
  begin
    Application.MessageBox('Sorry, you must selected a supported audio file! This includes MP2, MP3, AC3 and DTS.','Avisynth Proxy', MB_ICONWARNING or MB_TOPMOST);
    Result := '?';
    Exit;
  end;

  ////////////////////////////////////////////////////

  if Mode = 0 then
  begin
    while not ((AvsPluginsDir = '') or CheckAvsPlugin(AvsPluginsDir + '\dgdecode.dll')) do
    begin
      Res := Application.MessageBox('Sorry, it appears that the required DGDecode/MPEG2Source plugin (dgdecode.dll) is not installed.' + #10 + 'Please make sure the plugin is located in your Avisynth "Plugins" directory!', 'Avisynth Proxy', MB_ICONWARNING or MB_ABORTRETRYIGNORE);
      if Res = ID_ABORT then
      begin
        Result := '?';
        Exit;
      end;
      if Res = ID_IGNORE then
      begin
        Break;
      end;
    end;
  end;

  if Mode = 1 then
  begin
    while not ((AvsPluginsDir = '') or CheckAvsPlugin(AvsPluginsDir + '\dgavcdecode.dll')) do
    begin
      Res := Application.MessageBox('Sorry, it appears that the required DGAVCDecode/AVCSource plugin (dgavcdecode.dll) is not installed.' + #10 + 'Please make sure the plugin is located in your Avisynth "Plugins" directory!', 'Avisynth Proxy', MB_ICONWARNING or MB_ABORTRETRYIGNORE);
      if Res = ID_ABORT then
      begin
        Result := '?';
        Exit;
      end;
      if Res = ID_IGNORE then
      begin
        Break;
      end;
    end;
  end;

  if Mode = 2 then
  begin
    while not ((AvsPluginsDir = '') or CheckAvsPlugin(AvsPluginsDir + '\dgdecodenv.dll')) do
    begin
      Res := Application.MessageBox('Sorry, it appears that the required DGDecNV/DGSource plugin (dgdecodenv.dll) is not installed.' + #10 + 'Please make sure the plugin is located in your Avisynth "Plugins" directory!', 'Avisynth Proxy', MB_ICONWARNING or MB_ABORTRETRYIGNORE);
      if Res = ID_ABORT then
      begin
        Result := '?';
        Exit;
      end;
      if Res = ID_IGNORE then
      begin
        Break;
      end;
    end;
  end;

  ////////////////////////////////////////////////////

  DeintMode := 0;

  if CheckBox_DGIndex_DeinterlaceEnabled.Checked then
  begin
    DeintMode := 1;
    if CheckBox_DGIndex_DeinterlaceBob.Checked then
    begin
      DeintMode := DeintMode + 1;
    end;
  end;

  ////////////////////////////////////////////////////

  Line := '"' + Edit_DGIndex.Text + '"';

  case Mode of
    0: Line := 'MPEG2Source(' + Line + ')';
    1: Line := 'AVCSource(' + Line + ')';
    2: Line := 'DGSource(' + Line + ', deinterlace=' + IntToStr(DeintMode) + ')';
  else
    raise Exception.Create('Undefined video encoder');
  end;

  ////////////////////////////////////////////////////

  Line2 := '';

  if not CheckBox_DGIndex_NoAudio.Checked then
  begin
    Line2 := '"' + Edit_DGIndex_Audio.Text + '"';

    case Mode2 of
      0: Line2 := 'NicMPG123Source(' + Line2 + ')';
      1: Line2 := 'NicAC3Source(' + Line2 + ')';
      2: Line2 := 'NicDTSSource(' + Line2 + ')';
    else
      raise Exception.Create('Undefined audio encoder');
    end;
  end;

  ////////////////////////////////////////////////////

  if (Line2 <> '') and (JvSpinEdit_DGIndex_AudioDelay.AsInteger <> 0) then
  begin
    Delay := JvSpinEdit_DGIndex_AudioDelay.AsInteger;
    Line2 := Line2 + '.DelayAudio(';
    if Delay < 0 then
    begin
      Line2 := Line2 + '-';
      Delay := -Delay;
    end;
    Line2 := Line2 + IntToStr(Delay div 1000);
    Line2 := Line2 + '.';
    Line2 := Line2 + IntToStr(Delay mod 1000);
    Line2 := Line2 + ')';
  end;

  ////////////////////////////////////////////////////

  Script := TStringList.Create;

  if Line2 <> '' then
  begin
    Script.Add('V = ' + Line);
    Script.Add('A = ' + Line2);
    Script.Add('AudioDub(V,A)');
    Script.Add('ConvertAudioTo16bit()');
  end else begin
    Script.Add(Line);
  end;

  ScriptFile := GetTempFile('dgindex_','avs');
  Script.SaveToFile(ScriptFile);
  CleanupList.Add(ScriptFile);
  Script.Free;

  Result := ScriptFile;
end;

procedure TForm1.URL(Address: String);
begin
  ShellExecute(self.Handle, nil, PAnsiChar(Address), nil, nil, SW_SHOWMAXIMIZED); 
end;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Misc
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormCreate(Sender: TObject);
const
 CSIDL_MYDOCUMENTS = $000c;
 CSIDL_MYMUSIC =     $000d;
 CSIDL_MYVIDEO =     $000e;
var
  a: array [0..4095] of Char;
  reg: TRegistry;
begin
  AVSProxyPath := '';
  AvsPluginsDir := '';
  AvisynthLib := 0;
  AvisynthProc := nil;

  DefaultCaption := Caption;
  Label_Version.Caption := 'Version: ' + AppVersion + ' (Built ' + GetImageLinkTimeStampAsString(false) + '). Written by MuldeR';

  BaseDir := Application.ExeName;
  while (Length(BaseDir) > 1) and (BaseDir[Length(BaseDir)] <> '\') do
  begin
    SetLength(BaseDir, Length(BaseDir)-1);
  end;

  GetTempPath(2048, a);
  TempPath := a;

  ///////////////////////////////////////////////////////////////////////////

  if SHGetSpecialFolderPath(self.Handle, a, CSIDL_MYVIDEO, true) then
  begin
    OpenDialog.InitialDir := a;
    SaveDialog.InitialDir := a;
  end else begin
    if SHGetSpecialFolderPath(self.Handle, a, CSIDL_MYDOCUMENTS, true) then
    begin
      OpenDialog.InitialDir := a;
      SaveDialog.InitialDir := a;
    end;
  end;

  ///////////////////////////////////////////////////////////////////////////

  reg := TRegistry.Create;
  reg.RootKey := HKEY_LOCAL_MACHINE;

  if reg.OpenKeyReadOnly('SOFTWARE\Wow6432Node\AviSynth') then
  begin
    AvsPluginsDir := TryRegReadString(reg, 'plugindir2_5', '');
    if AvsPluginsDir = '' then
    begin
      AvsPluginsDir := TryRegReadString(reg, '', '');
      if AvsPluginsDir <> '' then
      begin
        AvsPluginsDir := AvsPluginsDir + '\Plugins';
      end;
    end;
    reg.CloseKey;
  end;

  reg.Free;

  ///////////////////////////////////////////////////////////////////////////

  Process := TConsoleProcess.Create;
  Process.OnReadLine := ReadLine;
  Process.OnProcessExit := ProcessExit;

  CleanupList := TStringList.Create;

  Tray := TTrayIcon.Create(Application);
  Tray.OnDblClick := TrayClick;

  ToggleLog(false);
  LoadConfig;

  Radio_CustomScript_Editor.OnClick(Sender);
  DragAcceptFiles(Handle, True);
end;

procedure TForm1.WMDropFiles(var Msg: TMessage);
var
  Buffer: PAnsiChar;
  iSize, iFileCount: Integer;
  i: Integer;
  Filename, Temp: String;
begin
  Buffer := nil;
  Filename := '';
  iFileCount := DragQueryFile(Msg.wParam, $FFFFFFFF, Buffer, 255);
  iSize := 0;

  try
    for i := 0 to iFileCount - 1 do
    begin
      iSize := Max(iSize, DragQueryFile(Msg.wParam, i, nil, 0));
    end;

    GetMem(Buffer, iSize + 1);

    for i := 0 to iFileCount - 1 do
    begin
      DragQueryFile(Msg.wParam, i, Buffer, iSize+1);
      Temp := GetFullPath(Buffer);
      if FileExists(Temp) then
      begin
        Filename := Temp;
        break;
      end;
    end;

    FreeMem(Buffer);
  finally
    DragFinish(Msg.wParam);
  end;

  if Filename <> '' then
  begin
    HandleDraggedFile(Filename);
  end;
end;

procedure TForm1.Button_Open_DirectShowClick(Sender: TObject);
begin
  OpenDialog.FileName := Edit_DirectShow.Text;
  OpenDialog.Filter := 'Media Files|*.*';
  OpenDialog.Title := 'Open Media File';

  if not OpenDialog.Execute then Exit;
  Edit_DirectShow.Text := OpenDialog.FileName;
end;

procedure TForm1.Button_Open_ffmpegSourceClick(Sender: TObject);
begin
  OpenDialog.FileName := Edit_ffmpegSource.Text;
  OpenDialog.Filter := 'Media Files|*.*';
  OpenDialog.Title := 'Open Media File';

  if not OpenDialog.Execute then Exit;
  Edit_ffmpegSource.Text := OpenDialog.FileName;
end;

procedure TForm1.Button_CreateClick(Sender: TObject);
begin
  CreateProxy;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := Button_Create.Enabled;
  if not CanClose then MessageBeep(MB_ICONWARNING);
end;

procedure TForm1.Button_PreviewClick(Sender: TObject);
begin
  CreatePreview;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  SaveConfig;
  for i := 0 to CleanupList.Count-1 do begin
    DeleteFile(CleanupList[i]);
  end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Button_Create.SetFocus;
end;

procedure TForm1.CopytoClipboardClick(Sender: TObject);
begin
  Clipboard.AsText := Memo_Log.Lines.GetText;
end;

procedure TForm1.ApplicationEvents1Minimize(Sender: TObject);
begin
  Tray.Show;
  Hide;
end;

procedure TForm1.Button_KillClick(Sender: TObject);
begin
  if MessageBox(0,'The Proxy is still running. Do you want to kill the proxy now?','AVS Proxy',MB_YESNO or MB_DEFBUTTON2 or MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL) <> ID_YES then Exit;

  try
    Process.KillProcess(0);
  except
    Button_Kill.Enabled := False;
  end;
end;

procedure TForm1.Button_DetailsClick(Sender: TObject);
begin
  if Button_Details.Tag = 0 then begin
    Button_Details.Tag := 1;
    Button_Details.Caption := 'Hide Details <<';
    ToggleLog(true);
  end else begin
    Button_Details.Tag := 0;
    Button_Details.Caption := 'Show Details >>';
    ToggleLog(false);
  end;
end;

procedure TForm1.PageControlChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := Button_Create.Enabled;
  if not AllowChange then MessageBeep(MB_ICONWARNING);
end;

procedure TForm1.CheckBox_DirectShow_ForceFPSClick(Sender: TObject);
begin
  JvSpinEdit_DirectShow_ForceFPS.Enabled := CheckBox_DirectShow_ForceFPS.Checked;
  CheckBox_DirectShow_ConvertFPS.Enabled := CheckBox_DirectShow_ForceFPS.Checked and (not CheckBox_DirectShow_DSS2.Checked);
end;

procedure TForm1.CheckBox_DirectShow_SeekingClick(Sender: TObject);
begin
  ComboBox_DirectShow_Seeking.Enabled := CheckBox_DirectShow_Seeking.Checked;
end;

procedure TForm1.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  try
    Application.MessageBox('An unhandeled exception error has occured! Application will terminate...', 'Avisynth Proxy', MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
  finally
    halt(1);
  end;
end;

procedure TForm1.CheckBox_ffmpegSource_VideoTrackClick(Sender: TObject);
begin
  JvSpinEdit_ffmpegSource_VideoTrack.Enabled := CheckBox_ffmpegSource_VideoTrack.Checked;
end;

procedure TForm1.CheckBox_ffmpegSource_AudioTrackClick(Sender: TObject);
begin
  JvSpinEdit_ffmpegSource_AudioTrack.Enabled := CheckBox_ffmpegSource_AudioTrack.Enabled and CheckBox_ffmpegSource_AudioTrack.Checked;
end;

procedure TForm1.CheckBox_ffmpegSource_SeekingClick(Sender: TObject);
begin
  ComboBox_ffmpegSource_Seeking.Enabled := CheckBox_ffmpegSource_Seeking.Checked;
end;

procedure TForm1.CheckBox_ffmpegSource_NoAudioClick(Sender: TObject);
begin
  CheckBox_ffmpegSource_AudioTrack.Enabled := not CheckBox_ffmpegSource_NoAudio.Checked;
  CheckBox_ffmpegSource_AudioTrack.OnClick(Sender);
end;

procedure TForm1.KillTimerTimer(Sender: TObject);
begin
  KillTimer.Enabled := False;
  if Process.StillRunning then Process.KillProcess(1);
end;

procedure TForm1.Button_Open_DGIndexClick(Sender: TObject);
begin
  OpenDialog.FileName := Edit_ffmpegSource.Text;
  OpenDialog.Filter := 'DGIndex/DGAVCIndex/DGIndexNV files|*.d2v;*.dga;*.dgi';
  OpenDialog.Title := 'Open D2V/DGA/DGI Project';

  if not OpenDialog.Execute then Exit;
  Edit_DGIndex.Text := OpenDialog.FileName;
end;

procedure TForm1.Button_Open_DGIndex_AudioClick(Sender: TObject);
var
  Temp: String;
  Index: Integer;
  i,x: Integer;
begin
  OpenDialog.FileName := Edit_ffmpegSource.Text;
  OpenDialog.Filter := 'MP2/MP3/AC3/DTS Audio Files |*.mp2;*.mp3;*.ac3;*.dts';
  OpenDialog.Title := 'Open Audio File';

  if not OpenDialog.Execute then Exit;
  Edit_DGIndex_Audio.Text := OpenDialog.FileName;

  Index := 0;
  Temp := AnsiLowerCase(ExtractFileName(Edit_DGIndex_Audio.Text));
  x := -1;

  repeat
    x := PosEx('delay', Temp, x+1);
    if(x <> 0) then Index := x;
  until
    x = 0;

  if Index <> 0 then
  begin
    Temp := Trim(Copy(Temp, Index + 5, Length(Temp)));
    for i := 1 to Length(Temp) do
    begin
      if not (((ord(Temp[i]) >= $30) and (ord(Temp[i]) <= $39)) or (ord(Temp[i]) = $2D)) then
      begin
        Temp := Copy(Temp, 1, i-1);
        Break;
      end;
    end;
    JvSpinEdit_DGIndex_AudioDelay.AsInteger := StrToIntDef(Temp, 0);
  end;
end;

procedure TForm1.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if (Msg.message = HandshakeMessage) and (Msg.wParam = HWND_BROADCAST) then begin
    PostMessage(Msg.lParam, HandshakeMessage, Application.Handle, Form1.Handle);
    Handled:=True;
  end;
end;

procedure TForm1.CheckBox_DGIndex_NoAudioClick(Sender: TObject);
begin
  Edit_DGIndex_Audio.Enabled := not CheckBox_DGIndex_NoAudio.Checked;
  Button_Open_DGIndex_Audio.Enabled := not CheckBox_DGIndex_NoAudio.Checked;
  JvSpinEdit_DGIndex_AudioDelay.Enabled := not CheckBox_DGIndex_NoAudio.Checked;
  Label_DGIndex_AudioDelay.Enabled := not CheckBox_DGIndex_NoAudio.Checked;
end;

procedure TForm1.CheckBox_DGIndex_DeinterlaceEnabledClick(Sender: TObject);
begin
  CheckBox_DGIndex_DeinterlaceBob.Enabled := CheckBox_DGIndex_DeinterlaceEnabled.Enabled and CheckBox_DGIndex_DeinterlaceEnabled.Checked;
end;

procedure TForm1.Edit_DGIndexChange(Sender: TObject);
var
  Extension: String;
begin
  Extension := GetFileExtension(Edit_DGIndex.Text);
  CheckBox_DGIndex_DeinterlaceEnabled.Enabled := SameText(Extension, 'dgi');
  CheckBox_DGIndex_DeinterlaceEnabled.OnClick(Sender);
end;

procedure TForm1.Label_VersionClick(Sender: TObject);
begin
  ShellExecute(self.WindowHandle, 'open', 'http://avidemux.org/admForum/viewtopic.php?id=4397', nil, nil, SW_SHOW);
end;

procedure TForm1.Label_VersionMouseEnter(Sender: TObject);
begin
  Label_Version.Font.Color := clBlue;
  Label_Version.Font.Style := Label_Version.Font.Style + [fsUnderline];
end;

procedure TForm1.Label_VersionMouseLeave(Sender: TObject);
begin
  Label_Version.Font.Color := clWindowText;
  Label_Version.Font.Style := Label_Version.Font.Style - [fsUnderline];
end;

procedure TForm1.CheckBox_DirectShow_DSS2Click(Sender: TObject);
begin
  CheckBox_DirectShow_Seeking.Enabled := not CheckBox_DirectShow_DSS2.Checked;
  CheckBox_DirectShow_NoAudio.Enabled := not CheckBox_DirectShow_DSS2.Checked;
  CheckBox_DirectShow_ForceFPS.OnClick(Sender);
end;

procedure TForm1.Button_Link_AvisynthClick(Sender: TObject);
begin
  URL('http://sourceforge.net/project/showfiles.php?group_id=57023');
end;

procedure TForm1.Button_Link_FFmpegClick(Sender: TObject);
begin
  URL('http://code.google.com/p/ffmpegsource/');
end;

procedure TForm1.Button_Link_DGIndexClick(Sender: TObject);
begin
  URL('http://neuron2.net/dgmpgdec/dgmpgdec.html');
end;

procedure TForm1.Button_Link_DGAVCIndexClick(Sender: TObject);
begin
  URL('http://neuron2.net/dgdecnv/dgdecnv.html');
end;

procedure TForm1.Button_Link_DSS2Click(Sender: TObject);
begin
  URL('http://haali.cs.msu.ru/mkv/');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  URL('http://avisynth.org/mediawiki/Main_Page');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  URL('http://avisynth.org/warpenterprises/');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  URL('http://forum.doom9.org/forumdisplay.php?f=33');
end;

procedure TForm1.Loadfromfile1Click(Sender: TObject);
begin
  OpenDialog.FileName := '';
  OpenDialog.Filter := 'Avisynth Script File (.avs)|*.avs';
  OpenDialog.Title := 'Load Script';

  if not OpenDialog.Execute then Exit;

  try
    Memo_CustomScript.Lines.LoadFromFile(OpenDialog.FileName);
  except
    Memo_CustomScript.Lines.Clear;
  end;
end;

procedure TForm1.Savetofile1Click(Sender: TObject);
begin
  SaveDialog.FileName := '';
  SaveDialog.Filter := 'Avisynth Script File (.avs)|*.avs';
  SaveDialog.DefaultExt := 'avs';
  SaveDialog.Title := 'Save Script';

  if not SaveDialog.Execute then Exit;

  try
    Memo_CustomScript.Lines.SaveToFile(SaveDialog.FileName);
  except
    MessageBeep(MB_ICONERROR);
  end;
end;

procedure TForm1.Clear1Click(Sender: TObject);
begin
  Memo_CustomScript.Lines.Clear;
end;

procedure TForm1.Button_Open_AVISourceClick(Sender: TObject);
begin
  OpenDialog.FileName := Edit_DirectShow.Text;
  OpenDialog.Filter := 'AVI Files|*.avi';
  OpenDialog.Title := 'Open AVI File';

  if not OpenDialog.Execute then Exit;
  Edit_AVISource.Text := OpenDialog.FileName;
end;

procedure TForm1.Radio_CustomScript_EditorClick(Sender: TObject);
begin
  Group_CustomScript_Editor.Visible := Radio_CustomScript_Editor.Checked;
  Group_CustomScript_External.Visible := Radio_CustomScript_External.Checked;
end;

procedure TForm1.Button_Open_CustomScriptClick(Sender: TObject);
begin
  OpenDialog.FileName := Edit_DirectShow.Text;
  OpenDialog.Filter := 'Avisynth Script File|*.avs';
  OpenDialog.Title := 'Open Avisynth Script';

  if not OpenDialog.Execute then Exit;
  Edit_CustomScript.Text := OpenDialog.FileName;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if AvisynthLib <> 0 then
  begin
    AvisynthProc := nil;
    FreeLibrary(AvisynthLib);
    AvisynthLib := 0;
  end;
end;

end.
