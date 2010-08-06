///////////////////////////////////////////////////////////////////////////////
// Simple x264 Launcher
// Copyright (C) 2009-2010 LoRd_MuldeR <MuldeR2@GMX.de>
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

unit Unit_Main;

///////////////////////////////////////////////////////////////////////////////
interface
///////////////////////////////////////////////////////////////////////////////

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan, JvDialogs, MuldeR_Toolz, Mask,
  JvExMask, JvSpin, ShlObj, ShellAPI, AppEvnts, Math, INIFiles, Unit_LinkTime,
  JvExStdCtrls, JvCombobox, Unit_Encode, Unit_RunProcess, Unit_Win7Taskbar;

const
  MinRev = 1688;

type
  TForm_Main = class(TForm)
    Edit_Source: TEdit;
    Label1: TLabel;
    Edit_Output: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    Button_Source: TButton;
    Button_Output: TButton;
    Button_Start: TButton;
    XPManifest1: TXPManifest;
    Dialog_Open: TJvOpenDialog;
    Dialog_Save: TJvSaveDialog;
    ApplicationEvents1: TApplicationEvents;
    Label_Date: TLabel;
    Edit_Params: TJvComboBox;
    Timer1: TTimer;
    Button_Benchmark: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    CBox_RCMode: TComboBox;
    Label4: TLabel;
    CBox_RCQuant: TJvSpinEdit;
    CBox_RCBitrate: TJvSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    GroupBox3: TGroupBox;
    CBox_Preset: TComboBox;
    Label7: TLabel;
    Label8: TLabel;
    CBox_Tune: TComboBox;
    Label9: TLabel;
    CBox_Profile: TComboBox;
    GroupBox4: TGroupBox;
    Label_Help: TLabel;
    procedure Button_SourceClick(Sender: TObject);
    procedure Button_OutputClick(Sender: TObject);
    procedure Button_StartClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure Edit_ParamsEnter(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button_BenchmarkClick(Sender: TObject);
    procedure Label_DateClick(Sender: TObject);
    procedure CBox_RCModeChange(Sender: TObject);
    procedure Label_HelpClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure CBox_RCBitrateExit(Sender: TObject);
    procedure Label_DateMouseEnter(Sender: TObject);
    procedure Label_DateMouseLeave(Sender: TObject);
  private
    OsIsWin64: Boolean;
    WM_TaskbarButtonCreated: UINT;
    FirstActivate: Boolean;
    SysDir: String;
    HomeDir: String;
    TempDir: String;
    DataDir: String;
    function CheckArgs:Boolean;
  public
    { Public-Deklarationen }
  end;

var
  Form_Main: TForm_Main;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

uses
  Unit_Progress, Unit_Results;

{$R *.dfm}

///////////////////////////////////////////////////////////////////////////////
// Constructor
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.FormCreate(Sender: TObject);
var
  Config: TINIFile;
  i: Integer;
  s: String;
begin
  FirstActivate := True;
  WM_TaskbarButtonCreated := RegisterWindowMessage('TaskbarButtonCreated');

  Label_Date.Caption := Format('by LoRd_MuldeR (Built: %s)', [GetImageLinkTimeStampAsString(True)]);
  OsIsWin64 := IsWow64Process;

  if OsIsWin64 then
  begin
    Caption := Format('%s (64-Bit Mode)', [Caption]);
  end else begin
    Caption := Format('%s (32-Bit Mode)', [Caption]);
  end;

  SysDir := GetSysDirectory;
  TempDir := GetTempDirectory;
  HomeDir := GetAppDirectory;
  DataDir := GetShellDirectory(CSIDL_APPDATA);

  Config := TINIFile.Create(DataDir + '\x264_x64.ini');
  try
    Edit_Source.Text := Config.ReadString('x264_x64', 'source', Edit_Source.Text);
    Edit_Output.Text := Config.ReadString('x264_x64', 'output', Edit_Output.Text);
    CBox_RCMode.ItemIndex := Config.ReadInteger('x264_x64', 'rc_mode', CBox_RCMode.ItemIndex);
    CBox_RCQuant.Value := Config.ReadFloat('x264_x64', 'quantizer', CBox_RCQuant.Value);
    CBox_RCBitrate.AsInteger := Config.ReadInteger('x264_x64', 'bitrate', CBox_RCBitrate.AsInteger);
    CBox_Preset.ItemIndex := Config.ReadInteger('x264_x64', 'preset', CBox_Preset.ItemIndex);
    CBox_Tune.ItemIndex := Config.ReadInteger('x264_x64', 'tune', CBox_Tune.ItemIndex);
    CBox_Profile.ItemIndex := Config.ReadInteger('x264_x64', 'profile', CBox_Profile.ItemIndex);
    Edit_Params.Text := Config.ReadString('x264_x64', 'params', Edit_Params.Text);
    for i := 0 to 7 do
    begin
      s := Trim(Config.ReadString('x264_x64', 'history_' + IntToStr(i+1), ''));
      if s <> '' then Edit_Params.Items.Add(s);
    end;
    Config.Free;
  except
    MessageBeep(MB_ICONERROR);
    Config.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Show & Close
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.FormShow(Sender: TObject);
begin
  Application.HintPause := 250;
  Application.HintHidePause := MaxInt;

  if OsIsWin64 then
  begin
    Application.Title := 'x264 x64';
  end else begin
    Application.Title := 'x264 x86';
  end;
  Button_Benchmark.Enabled := OsIsWin64;
  DragAcceptFiles(self.WindowHandle,True);
  CBox_RCMode.OnChange(Sender);
end;

procedure TForm_Main.FormActivate(Sender: TObject);
var
  h: HMODULE;
  b: Boolean;
begin
  if not FirstActivate then
  begin
    Exit;
  end;

  b := False;
  h := SafeLoadLibrary('avisynth.dll');

  if h <> 0 then
  begin
    b := Assigned(GetProcAddress(h, 'CreateScriptEnvironment'));
    FreeLibrary(h);
  end;

  if not b then
  begin
    MsgBox(self.WindowHandle, 'Unable to load the Avisynth library (avisynth.dll).' + #10 + 'Please install Avisynth (32-Bit) on your computer and try again!', 'Avisynth Error', MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
    Application.Terminate;
  end;

  FirstActivate := False;
end;

procedure TForm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Config: TINIFile;
  i: Integer;
begin
  Config := TINIFile.Create(DataDir + '\x264_x64.ini');
  try
    Config.WriteString('x264_x64', 'source', Edit_Source.Text);
    Config.WriteString('x264_x64', 'output', Edit_Output.Text);
    Config.WriteInteger('x264_x64', 'rc_mode', CBox_RCMode.ItemIndex);
    Config.WriteFloat('x264_x64', 'quantizer', CBox_RCQuant.Value);
    Config.WriteInteger('x264_x64', 'bitrate', CBox_RCBitrate.AsInteger);
    Config.WriteInteger('x264_x64', 'preset', CBox_Preset.ItemIndex);
    Config.WriteInteger('x264_x64', 'tune', CBox_Tune.ItemIndex);
    Config.WriteInteger('x264_x64', 'profile', CBox_Profile.ItemIndex);
    Config.WriteString('x264_x64', 'params', Edit_Params.Text);
    for i := 0 to Edit_Params.Items.Count-1 do
    begin
      Config.WriteString('x264_x64', 'history_' + IntToStr(i+1), Edit_Params.Items[i]);
    end;
    Config.Free;
  except
    MessageBeep(MB_ICONERROR);
    Config.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Encode
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.Button_StartClick(Sender: TObject);
const
  BuffSize = 4;
var
  s: String;
begin
  if not CheckArgs then
  begin
    Edit_Params.SetFocus;
    Exit;
  end;

  if FileExists(Edit_Output.Text) then
  begin
    if MsgBox(self.WindowHandle, 'The specified output file already exists. Overwrite file?', 'Overwrite?', MB_ICONWARNING or MB_YESNO or MB_DEFBUTTON2 or MB_TOPMOST) <> idYES then Exit;
  end;

  self.Hide;

  case CBox_RCMode.ItemIndex of
    0:
    begin
      Form_Progress.StartEncoder(Edit_Source.Text, Edit_Output.Text, RC_CRF, Round(CBox_RCQuant.Value * 100), 0, CBox_Preset.Text, CBox_Tune.Text, CBox_Profile.Text, Edit_Params.Text, OsIsWin64, False, BuffSize, 'Encoding', True);
    end;
    1:
    begin
      Form_Progress.StartEncoder(Edit_Source.Text, Edit_Output.Text, RC_QP, Round(CBox_RCQuant.Value * 100), 0, CBox_Preset.Text, CBox_Tune.Text, CBox_Profile.Text, Edit_Params.Text, OsIsWin64, False, BuffSize, 'Encoding', True);
    end;
    2:
    begin
      Form_Results.Memo_Result.Lines.Clear;
      Form_Results.Memo_Result.Lines.Add('[First Pass]');
      s := Form_Progress.StartEncoder(Edit_Source.Text, Edit_Output.Text, RC_ABR, CBox_RCBitrate.AsInteger, 1, CBox_Preset.Text, CBox_Tune.Text, CBox_Profile.Text, Edit_Params.Text, OsIsWin64, True, BuffSize, 'First Pass', True);
      Form_Results.Memo_Result.Lines.Add(s);
      Form_Results.Memo_Result.Lines.Add('');
      if Form_Progress.Success then
      begin
        Form_Results.Memo_Result.Lines.Add('[Second Pass]');
        s := Form_Progress.StartEncoder(Edit_Source.Text, Edit_Output.Text, RC_ABR, CBox_RCBitrate.AsInteger, 2, CBox_Preset.Text, CBox_Tune.Text, CBox_Profile.Text, Edit_Params.Text, OsIsWin64, True, BuffSize, 'Second Pass', True);
        Form_Results.Memo_Result.Lines.Add(s);
        Form_Results.Memo_Result.Lines.Add('');
      end;
      Form_Results.Memo_Result.Lines.Add('');
      Form_Results.Memo_Result.Lines.Add('-- [Detailed Report] --');
      Form_Results.Memo_Result.Lines.Add('');
      Form_Results.Memo_Result.Lines.AddStrings(Form_Progress.List_LogFile.Items);
    end;
    3:
    begin
      Form_Progress.StartEncoder(Edit_Source.Text, Edit_Output.Text, RC_ABR, CBox_RCBitrate.AsInteger, 0, CBox_Preset.Text, CBox_Tune.Text, CBox_Profile.Text, Edit_Params.Text, OsIsWin64, False, BuffSize, 'Encoding', True);
    end;
  end;

  self.Show;

  if CBox_RCMode.ItemIndex = 2 then
  begin
    Form_Results.Caption := '2-Pass Report';
    if Form_Progress.Success then
    begin
      SetTaskbarOverlayIcon(Form_Progress.ImageList, 2, 'Complete');
      Form_Results.Caption := Form_Results.Caption + ' (Completed)';
    end else begin
      SetTaskbarOverlayIcon(Form_Progress.ImageList, 1, 'Error');
      Form_Results.Caption := Form_Results.Caption + ' (Failed)';
    end;
    Form_Results.ShowModal;
    SetTaskbarOverlayIcon(nil, 'None');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Benchmark
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.Button_BenchmarkClick(Sender: TObject);
var
  Results: TStringList;
  TestRCMode: TRCMode;
  TestRCValue: Integer;
  j: Integer;

  function RunTest(x64: Boolean; BuffSize: Cardinal): Boolean;
  var
    i: Integer;
    s: String;
  begin
    self.Hide;
    if x64 then s := '64-Bit' else s := '32-Bit';
    Results.Add(Format('[Type: %s, Pipe Buffer Size: %d MByte]', [s, BuffSize]));
    Result := True;
    for i := 1 to 3 do
    begin
      s := Form_Progress.StartEncoder(Edit_Source.Text, 'NUL', TestRCMode, TestRCValue, 0, CBox_Preset.Text, CBox_Tune.Text, CBox_Profile.Text, Edit_Params.Text, x64, True, BuffSize, 'Benchmarking', False);
      Results.Add(s);
      if not Form_Progress.Success then
      begin
        Result := False;
        Results.Add('');
        Results.Add('');
        Results.Add('-- [Error Report] --');
        Results.Add('');
        Results.AddStrings(Form_Progress.List_LogFile.Items);
        Break;
      end;
    end;
    Results.Add('');
    self.Show;
    Refresh;
    Sleep(1000);
  end;
begin
  if not CheckArgs then
  begin
    Edit_Params.SetFocus;
    Exit;
  end;

  if not SameText(ExtractExtension(Edit_Source.Text), 'avs') then
  begin
    MsgBox(self.WindowHandle, 'Sorry, benchmarking requires an Avisynth script as input!', 'Benchmark', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  case CBox_RCMode.ItemIndex of
    0:
    begin
      TestRCMode := RC_CRF;
      TestRCValue := Round(CBox_RCQuant.Value * 100);
    end;
    1:
    begin
      TestRCMode := RC_QP;
      TestRCValue := Round(CBox_RCQuant.Value * 100);
    end;
    3:
    begin
      TestRCMode := RC_ABR;
      TestRCValue := CBox_RCBitrate.AsInteger;
    end;
  else
    MsgBox(self.WindowHandle, 'The selected rate control mode isn''t available for benchmarking yet!', 'Benchmark', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  if MsgBox(self.WindowHandle, 'I will run numerous test encodes now. Please do not interrupt the test!', 'Benchmark', MB_ICONINFORMATION or MB_TOPMOST or MB_OKCANCEL) <> mrOK then
  begin
    Exit;
  end;

  Results := TStringList.Create;

  Results.Add('Source: ' + Edit_Source.Text);
  Results.Add('Preset: ' + CBox_Preset.Text);
  Results.Add('Tuning: ' + CBox_Tune.Text);
  Results.Add('Profile: ' + CBox_Profile.Text);
  Results.Add('Params: ' + Edit_Params.Text);
  Results.Add('');

  if RunTest(False, 0) then
  begin
    if RunTest(True, 0) then
    begin
      for j := 0 to 3 do
      begin
        if not RunTest(True, Round(Math.Power(2, j))) then Break;
      end;
    end;
  end;

  try
    Results.SaveToFile(ExtractDirectory(Edit_Output.Text) + '\' + RemoveExtension(ExtractFilename(Edit_Output.Text)) + '.benchmark.txt');
  except
    Beep;
  end;

  Form_Results.Memo_Result.Lines.Clear;
  Form_Results.Memo_Result.Lines.AddStrings(Results);
  Results.Free;

  if not Form_Progress.Success then
  begin
    SetTaskbarOverlayIcon(Form_Progress.ImageList, 1, 'Error');
  end else begin
    SetTaskbarOverlayIcon(Form_Progress.ImageList, 2, 'Completed');
  end;

  Form_Results.Caption := 'Benchmark Results';
  Form_Results.ShowModal;

  SetTaskbarOverlayIcon(nil, 'None');
end;

///////////////////////////////////////////////////////////////////////////////
// Check Arguments
///////////////////////////////////////////////////////////////////////////////

function TForm_Main.CheckArgs:Boolean;
var
  s: String;
  i: Integer;
const
  Param_Obsolete: array [0..7] of String =
  (
    '8',
    '8x8dct',
    'mixed-refs',
    'no-psnr',
    'no-ssim',
    'progress',
    'w',
    'weightb'
  );

  Param_Forbidden: array [0..25] of String =
  (
    'B',
    'bitrate',
    'crf',
    'demuxer',
    'fps',
    'frames',
    'h',
    'help',
    'longhelp',
    'no-progress',
    'muxer',
    'o',
    'output',
    'p',
    'pass',
    'preset',
    'profile',
    'q',
    'qp',
    'quiet',
    'stdin',
    'stdout',
    'tune',
    'v',
    'verbose',
    'version'
  );

  //--------------------------------------------------------------------//

  procedure InvalidParam(ParamStr:String; Reason:String);
  var
    r: String;
  begin
    if Length(ParamStr) > 1 then
    begin
      r := Format('--%s', [ParamStr]);
    end else begin
      r := Format('-%s', [ParamStr]);
    end;

    MsgBox(self.WindowHandle, Format('Please don''t specify the "%s" parameter. %s', [r,Reason]), 'Invalid Parameter', MB_ICONWARNING or MB_TOPMOST);
  end;

  //--------------------------------------------------------------------//

  function CheckParamName(ParamStr:String): Boolean;
  var
    j: Integer;
  begin
    Result := True;

    if Length(ParamStr) < 1 then
    begin
      MsgBox(self.WindowHandle, 'Please don''t specify the an empty parameter!', 'Invalid Parameter', MB_ICONWARNING or MB_TOPMOST);
      Result := False;
      Exit;
    end;

    for j := 0 to High(Param_Obsolete) do
    begin
      if (CompareStr(ParamStr, Param_Obsolete[j]) = 0) then
      begin
        InvalidParam(ParamStr, 'That parameter is obsolete!');
        Result := False;
        Exit;
      end;
    end;

    for j := 0 to High(Param_Forbidden) do
    begin
      if (CompareStr(ParamStr, Param_Forbidden[j]) = 0) then
      begin
        InvalidParam(ParamStr, 'I will do this for you, if required!');
        Result := False;
        Exit;
      end;
    end;
  end;

  //--------------------------------------------------------------------//

  function CheckForParam(ParamStr:String): Boolean;
  begin
    Result := True;

    if Length(ParamStr) > 1 then
    begin
      if (ParamStr[1] = '-') and (ParamStr[2] = '-') then
      begin
        Result := CheckParamName(AnsiLowerCase(Copy(ParamStr, 3, Length(ParamStr))));
      end
      else if (ParamStr[1] = '-') then
      begin
        Result := CheckParamName(ParamStr[2]);
      end
    end
    else if Length(ParamStr) > 0 then
    begin
      if (ParamStr[1] = '-') then
      begin
        Result := CheckParamName('');
      end
    end
  end;

//------------------------------------------------------------------------//

begin
  Result := False;
  Edit_Params.Text := Trim(Edit_Params.Text);

  if not FileExists(HomeDir + '\pipebuf.exe') then
  begin
    MsgBox(self.WindowHandle, 'Sorry, I could not find "pipebuf.exe" in my home directory!', 'Error', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  if not FileExists(HomeDir + '\avs2yuv.exe') then
  begin
    MsgBox(self.WindowHandle, 'Sorry, I could not find "avs2yuv.exe" in my home directory!', 'Error', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  if not FileExists(HomeDir + '\x264.exe') then
  begin
    MsgBox(self.WindowHandle, 'Sorry, I could not find "x264.exe" in my home directory!', 'Error', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  if not FileExists(HomeDir + '\x264_x64.exe') then
  begin
    MsgBox(self.WindowHandle, 'Sorry, I could not find "x264_x64.exe" in my home directory!', 'Error', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  if not FileExists(Edit_Source.Text) then
  begin
    MsgBox(self.WindowHandle, 'Sorry, I could not find the source file!', 'Error', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  if not DirectoryExists(ExtractDirectory(Edit_Output.Text)) then
  begin
    MsgBox(self.WindowHandle, 'Sorry, I could not find the output directroy!', 'Error', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  //--------------------------------------------------------------------//

  s := '';
  Result := True;

  for i := 1 to Length(Edit_Params.Text) do
  begin
    if (Edit_Params.Text[i] <> ' ') then
    begin
      s := s + Edit_Params.Text[i];
      Continue;
    end;
    Result := Result and CheckForParam(s);
    s := '';
  end;

  Result := Result and CheckForParam(s);

  //--------------------------------------------------------------------//

  if Result and (Edit_Params.Text <> '') then
  begin
    if Edit_Params.Items.Count < 1 then
    begin
      Edit_Params.Items.Add(Edit_Params.Text);
    end
    else if (not SameText(Edit_Params.Items[0], Edit_Params.Text)) then
    begin
      Edit_Params.Items.Insert(0, Edit_Params.Text);
      while Edit_Params.Items.Count > 8 do Edit_Params.Items.Delete(8);
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Drag & Drop
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.WMDropFiles(var Msg: TMessage);
var
  Buffer: PAnsiChar;
  iSize,iFileCount: Integer;
  i,x: Integer;
  BaseDir: String;
  Filename: String;
begin
  Buffer := nil;
  Filename := '';
  iFileCount := DragQueryFile(Msg.wParam, $FFFFFFFF, nil, 0);
  iSize := 0;

  for i := 0 to iFileCount - 1 do
  begin
    iSize := Max(iSize, DragQueryFile(Msg.wParam, i, nil, 0) + 1);
  end;

  if iSize < 1 then
  begin
    Exit;
  end;

  try
    Buffer := AllocMem(iSize + 1);
    for i := 0 to iFileCount - 1 do
    begin
      SetString(Filename, Buffer, DragQueryFile(Msg.wParam, i, Buffer, iSize));
      Filename := GetFullPath(Trim(Filename));
      if (Filename <> '') and FileExists(Filename) then
      begin
        x := 1;
        Edit_Source.Text := Filename;
        BaseDir := ExtractDirectory(Filename);
        Filename := RemoveExtension(ExtractFileName(Filename));
        Edit_Output.Text := BaseDir + '\' + Filename + '.mkv';
        while FileExists(Edit_Output.Text) do
        begin
          x := x + 1;
          Edit_Output.Text := BaseDir + '\' + Filename + ' (' + IntToStr(x) + ').mkv';
        end;
        Break;
      end;
    end;
  finally
    DragFinish(Msg.wParam);
    if Assigned(Buffer) then FreeMem(Buffer);
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Help Screen
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.Label_HelpClick(Sender: TObject);
var
  Process: TRunProcess;
  i: Integer;
  b: boolean;
begin
  if not FileExists(HomeDir + '\x264.exe') then
  begin
    MsgBox(self.WindowHandle, 'Sorry, I could not find "x264.exe" in my home directory!', 'Error', MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  Process := TRunProcess.Create;
  Process.Execute(Format('"%s\x264.exe" --version', [HomeDir]));

  if Process.Execute(Format('"%s\x264.exe" --fullhelp', [HomeDir])) = procDone then
  begin
    Form_Results.Memo_Result.Clear;
    Process.GetLog(TStringList(Form_Results.Memo_Result.Lines));
    b := True;
    while b do
    begin
      b := False;
      for i := 0 to Form_Results.Memo_Result.Lines.Count - 1 do
      begin
        if (Pos('BYTES CAPTURED:', Form_Results.Memo_Result.Lines[i]) <> 0) or (Pos('EXIT CODE:', Form_Results.Memo_Result.Lines[i]) <> 0) then
        begin
          b := True;
          Form_Results.Memo_Result.Lines.Delete(i);
          Break;
        end;
      end;
    end;
    Form_Results.Caption := 'x264 Help';
    Form_Results.ShowModal;
  end else begin
    MsgBox('Sorry, failed to generate the help screen!', 'Error', MB_ICONERROR or MB_TOPMOST);
  end;

  Process.Free;
end;

///////////////////////////////////////////////////////////////////////////////
// Misc Callbacks
///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.Button_SourceClick(Sender: TObject);
const
  FileTypes: array [0..18] of String = ('3gp','asf','avi','divx','flv','m2p','m2ts','m2v','m4v','mkv','mov','mp4','mpeg','mpg','nsv','ogm','ts','vob','wmv');
var
  i: Integer;
  Temp, Filter: String;
begin
  Temp := Format('*.%s', [FileTypes[0]]);

  for i := 1 to High(FileTypes) do
  begin
    Temp := Format('%s;*.%s', [Temp, FileTypes[i]]);
  end;

  Filter := Format('Supported files|*.avs;%s', [Temp]);
  Filter := Format('%s|Only Avisynth script files|*.avs', [Filter, Temp]);
  Filter := Format('%s|Only media files|%s', [Filter, Temp]);
  Filter := Format('%s|All files (*.*)|*.*', [Filter]);

  Dialog_Open.Filter := Filter;
  Dialog_Open.FileName := Edit_Source.Text;

  if Dialog_Open.Execute then
  begin
    Edit_Source.Text := Dialog_Open.FileName;
  end;
end;

procedure TForm_Main.Button_OutputClick(Sender: TObject);
begin
  Dialog_Save.FileName := Edit_Output.Text;

  if Dialog_Save.Execute then
  begin
    Edit_Output.Text := Dialog_Save.FileName;
  end;
end;

procedure TForm_Main.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  FatalAppExit(0, PAnsiChar('EXCEPTION ERROR: ' + E.Message));
  TerminateProcess(GetCurrentProcess, 1);
end;

procedure TForm_Main.Edit_ParamsEnter(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TForm_Main.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  Edit_Params.SelLength := 0;
end;

procedure TForm_Main.Label_DateClick(Sender: TObject);
begin
  ShellExecute(self.WindowHandle, nil, 'http://forum.doom9.org/showthread.php?t=144140', nil, nil, SW_SHOW);
end;

procedure TForm_Main.CBox_RCModeChange(Sender: TObject);
var
  Temp: Integer;
begin
  CBox_RCQuant.Enabled := (CBox_RCMode.ItemIndex < 2);
  CBox_RCBitrate.Enabled := not CBox_RCQuant.Enabled;

  case CBox_RCMode.ItemIndex of
    0:
    begin
      if CBox_RCQuant.ValueType <> vtFloat then
      begin
        CBox_RCQuant.ValueType := vtFloat;
      end;
    end;
    1:
    begin
      if CBox_RCQuant.ValueType <> vtInteger then
      begin
        Temp := Round(CBox_RCQuant.Value);
        CBox_RCQuant.ValueType := vtInteger;
        CBox_RCQuant.AsInteger := Temp;
      end;
    end;
  end;
end;

procedure TForm_Main.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
begin
  if Msg.message = WM_TaskbarButtonCreated then
  begin
    InitializeTaskbarAPI;
    Handled := True;
  end;
end;

procedure TForm_Main.CBox_RCBitrateExit(Sender: TObject);
begin
  CBox_RCBitrate.AsInteger := Max(25, CBox_RCBitrate.AsInteger);
end;

procedure TForm_Main.Label_DateMouseEnter(Sender: TObject);
begin
  Label_Date.Font.Color := clBlue;
  Label_Date.Font.Style := Label_Date.Font.Style + [fsUnderline];
end;

procedure TForm_Main.Label_DateMouseLeave(Sender: TObject);
begin
  Label_Date.Font.Color := clWindowText;
  Label_Date.Font.Style := Label_Date.Font.Style - [fsUnderline];
end;

end.
