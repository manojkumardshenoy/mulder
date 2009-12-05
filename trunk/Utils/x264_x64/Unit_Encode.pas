unit Unit_Encode;

///////////////////////////////////////////////////////////////////////////////
interface
///////////////////////////////////////////////////////////////////////////////

uses
  Classes, SysUtils, StdCtrls, ShlObj, JvListBox, Unit_RunProcess, Unit_Commandline, MuldeR_Toolz;

type
  TProgressHandler = procedure(Progess: Integer) of object;

type
  TRCMode = (RC_CRF, RC_QP, RC_ABR);

type
  TEncode = class(TThread)
  public
    constructor Create(Source:String; Output:String; RCMode:TRCMode; RCValue:Integer; Pass:Byte; Preset: String; Tune:String; Profile:String; Params:String; LogFile:TJvListBox; Status:TEdit; ProgressHandler:TProgressHandler; x64: Boolean; BuffSize:Integer);
    destructor Destroy; override;
    function GetReturnValue: Integer;
    procedure AbortEncode;
    function PauseEncode(Pause: Boolean): Boolean;
  private
    Source: String;
    Output: String;
    RCMode: TRCMode;
    RCValue: Integer;
    Pass: Byte;
    Preset: String;
    Tune: String;
    Profile: String;
    Params: TCommandline;
    x64: Boolean;
    BuffSize: Integer;
    LogFile: TJvListBox;
    Status: TEdit;
    Process: TRunProcess;
    ProgressHandler: TProgressHandler;
    DataDir: String;
    HomeDir: String;
    SysDir: String;
    _TextBuffer: String;
    _Progress: Integer;
    procedure WriteLog(Text: String);
    procedure WriteLogSync;
    procedure WriteStatus(Text: String);
    procedure WriteStatusSync;
    procedure SetProgress(Progress: Integer);
    procedure SetProgressSync;
    function Filter(Line: String): Boolean;
  protected
    procedure Execute; override;
  end;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

uses Unit_Main;

///////////////////////////////////////////////////////////////////////////////
// Constructor & Destructor
///////////////////////////////////////////////////////////////////////////////

constructor TEncode.Create(Source:String; Output:String; RCMode:TRCMode; RCValue:Integer; Pass:Byte; Preset: String; Tune:String; Profile:String; Params:String; LogFile:TJvListBox; Status:TEdit; ProgressHandler:TProgressHandler; x64: Boolean; BuffSize:Integer);
begin
  inherited Create(true);

  self.Source := Source;
  self.Output := Output;
  self.RCMode := RCMode;
  self.RCValue := RCValue;
  self.Pass := Pass;
  self.Preset := Preset;
  self.Tune := Tune;
  self.Profile := Profile;
  self.Params := TCommandline.Create(Params);
  self.LogFile := LogFile;
  self.Status := Status;
  self.ProgressHandler := ProgressHandler;
  self.x64 := x64;
  self.BuffSize := BuffSize;

  SysDir := GetSysDirectory;
  DataDir := GetShellDirectory(CSIDL_APPDATA);
  HomeDir := GetAppDirectory;

  _Progress := -1;
  _TextBuffer := '';

  Process := TRunProcess.Create;
  Process.Priority := ppBelowNormal;
end;

destructor TEncode.Destroy;
var
  Temp: TStringList;
begin
  Temp := TStringList.Create;
  Process.GetLog(Temp);

  try
    Temp.SaveToFile(DataDir + '\x264_x64.log');
  except
    Beep;
  end;

  Temp.Free;
  Process.Free;
  Params.Free;
end;

///////////////////////////////////////////////////////////////////////////////
// Utils
///////////////////////////////////////////////////////////////////////////////

function gcd(a:Integer; b:Integer):Integer;
var g,z: Integer;
begin
  g := b;
  while g <> 0 do
  begin
    z := a mod g;
    a := g;
    g := z;
  end;
  Result := a;
end;

procedure ShortenFraction(var a:Integer; var b:Integer);
var
  t: Integer;
begin
  t := gcd(a,b);
  while (t > 1) do
  begin
    a := a div t;
    b := b div t;
    t := gcd(a,b);
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Main Encoder Function
///////////////////////////////////////////////////////////////////////////////

procedure TEncode.Execute;
var
  LogData: TStringList;
  Width: Integer;
  Height:Integer;
  FPS1: Integer;
  FPS2: Integer;
  Frames: Integer;
  Commandline: TCommandline;
  BuffSize: Integer;
  i: Integer;
  j: Integer;
  s: String;
  t: TStringList;
  r: TStringList;
  v: Integer;
begin
  BuffSize := self.BuffSize;
  self.ReturnValue := 0;
  Commandline := TCommandline.Create;

  //----------------------- Analyze Source -----------------------//

  WriteStatus('Preparing for encode, please wait...');
  WriteLog('Analayzing source file:');

  Commandline.Clear;
  Commandline.Add(HomeDir + '\avs2yuv.exe');
  Commandline.Add(Source);
  Commandline.Add(['-frames', '1']);
  Commandline.Add('NUL');

  Process.Filter := self.Filter;

  case Process.Execute(Commandline.Text) of
    procFaild:
    begin
      self.ReturnValue := -1;
      WriteLog('');
      WriteLog('Fatal Error: Failed to create the process!');
      WriteStatus('Encoder stopped.');
      Commandline.Free;
      Exit;
    end;
    procError:
    begin
      self.ReturnValue := -1;
      WriteLog('');
      WriteLog('Fatal Error: Failed to analyze the source video!');
      WriteStatus('Encoder stopped.');
      Commandline.Free;
      Exit;
    end;
    procAborted:
    begin
      self.ReturnValue := -2;
      WriteLog('');
      WriteLog('Aborted: Process was terminated prematurely!');
      WriteStatus('Encoder stopped.');
      Commandline.Free;
      Exit;
    end;
  end;

  WriteLog('');
  Process.AddToLog('');
  Process.AddToLog('');

  LogData := TStringList.Create;
  Process.GetLog(LogData);

  Width := -1;
  Height := -1;
  FPS1 := -1;
  FPS2 := -1;
  Frames := -1;

  //----------------------- Parse Source Attributes -----------------------//

  for i := 0 to LogData.Count-1 do
  begin
    s := LogData[i];

    repeat
      j := pos(':',s);
      if j > 0 then Delete(s,1,j);
    until
      j < 1;

    t := TokenizeStr(', ', s);

    if t.Count > 4 then
    begin
      if SameText(t[2],'fps') and SameText(t[4],'frames') then
      begin
        r := TokenizeStr('x', t[0]);
        Frames := StrToIntDef(t[3], -1);

        if r.Count > 1 then
        begin
          Width := StrToIntDef(r[0],-1);
          Height := StrToIntDef(r[1],-1);
        end;

        r.Free;
        r := TokenizeStr('/', t[1]);

        if r.Count > 1 then
        begin
          FPS1 := StrToIntDef(r[0],-1);
          FPS2 := StrToIntDef(r[1],-1);
        end
        else if r.Count > 0 then
        begin
          FPS1 := StrToIntDef(r[0],-1);
          FPS2 := 1;
        end;

        r.Free;
      end;
    end;

    t.Free;
  end;

  LogData.Free;

  //----------------------- Output Source Attributes -----------------------//

  ShortenFraction(FPS1, FPS2);

  WriteLog('Resolution: ' + IntToStr(Width) + ' x ' + IntToStr(Height));
  WriteLog('Frame No. : ' + IntToStr(Frames));
  WriteLog('Frame Rate: ' + IntToStr(FPS1) + '/' + IntToStr(FPS2));
  WriteLog('');

  if (Width < 1) or (Height < 1) or (FPS1 < 1) or (FPS2 < 1) or (Frames < 1) then
  begin
    self.ReturnValue := -1;
    WriteLog('Fatal Error: Failed to analyze the source video!');
    WriteStatus('Encoder stopped.');
    Exit;
  end;

  if BuffSize < 0 then
  begin
    BuffSize := (Width * Height * 120) div 1048576;
  end;

  //----------------------- Print x264 version -----------------------//

  WriteStatus('Creating encoder processes, please wait...');

  Commandline.Clear;
  if x64 then
  begin
    Commandline.Add(HomeDir + '\x264_x64.exe');
  end else begin
    Commandline.Add(HomeDir + '\x264.exe');
  end;
  Commandline.Add('--version');

  Process.Filter := self.Filter;

  case Process.Execute(Commandline.Text) of
    procFaild:
    begin
      self.ReturnValue := -1;
      WriteLog('');
      WriteLog('Fatal Error: Failed to create the process!');
      WriteStatus('Encoder stopped.');
      Commandline.Free;
      Exit;
    end;
    procError:
    begin
      self.ReturnValue := -1;
      WriteLog('');
      WriteLog('Fatal Error: The encoder has encountered an unexpected error!');
      WriteStatus('Encoder stopped.');
      Commandline.Free;
      Exit;
    end;
    procAborted:
    begin
      self.ReturnValue := -2;
      WriteLog('');
      WriteLog('Aborted: Process was terminated prematurely!');
      WriteStatus('Encoder stopped.');
      Commandline.Free;
      Exit;
    end;
  end;

  LogData := TStringList.Create;
  Process.GetLog(LogData);

  v := -1;

  for i := LogData.Count-1 downto 0 do
  begin
    s := Trim(LogData[i]);
    t := TokenizeStr(' ', s);

    if t.Count > 2 then
    begin
      if SameText(t[0], 'x264') then
      begin
        r := TokenizeStr('.', t[1]);
        if r.Count > 2 then
        begin
          for j := 0 to Length(r[2]) do
          begin
            v := StrToIntDef(Copy(r[2], 1, Length(r[2]) - j), -1);
            if v >= 0 then Break;
          end;
        end;
        r.Free;
      end;
    end;

    t.Free;
    if v >= 0 then Break;
  end;

  LogData.Free;

  if v >= 0 then
  begin
    WriteLog(Format('Revision: %d', [v]));
  end else begin
    WriteLog('Revision: N/A');
  end;

  if (v < Unit_Main.MinRev) then
  begin
    self.ReturnValue := -1;
    WriteLog('');
    WriteLog(Format('Fatal Error: Detected an outdated revision of x264. Minimum revision required is r%d.', [Unit_Main.MinRev]));
    WriteLog('Please update your x264 binaries to a suitable version!');
    WriteStatus('Encoder stopped.');
    Exit;
  end;

  //----------------------- Build x264 command-line -----------------------//

  Commandline.Clear;

  if x64 then
  begin
    Commandline.Add(HomeDir + '\pipebuf.exe');
    Commandline.Add(HomeDir + '\avs2yuv.exe');
    Commandline.Add(Source);
    Commandline.Add('-raw');
    Commandline.Add('-');
    Commandline.Add(':');
    Commandline.Add(HomeDir + '\x264_x64.exe');
  end else begin
    Commandline.Add(HomeDir + '\x264.exe');
  end;

  if (Preset <> '') and (not SameText(Preset, 'Medium')) then
  begin
    Commandline.Add(['--preset', AnsiLowerCase(Preset)]);
  end;
  if (Tune <> '') and (not SameText(Tune, 'None')) then
  begin
    Commandline.Add(['--tune', AnsiLowerCase(Tune)]);
  end;
  if (Profile <> '') and (not SameText(Profile, 'High')) then
  begin
    Commandline.Add(['--profile', AnsiLowerCase(Profile)]);
  end;

  case RCMode of
    RC_CRF:
    begin
      Commandline.Add(['--crf', Format('%d.%d', [RCValue div 100, RCValue mod 100])]);
    end;
    RC_QP:
    begin
      Commandline.Add(['--qp', IntToStr(Round(RCValue / 100))]);
    end;
    RC_ABR:
    begin
      Commandline.Add(['--bitrate', IntToStr(RCValue)]);
    end;
  end;

  if Pass > 0 then
  begin
    Commandline.Add(['--pass', IntToStr(Pass)]);
    Commandline.Add(['--stats', Output + '.x264-stats']);
  end;

  Commandline.Add(Params);
  Commandline.Add(['--output', Output]);

  if x64 then
  begin
    Commandline.Add(['--frames', IntToStr(Frames)]);
    Commandline.Add(['--fps', IntToStr(FPS1) + '/' + IntToStr(FPS2)]);
    Commandline.Add('-');
    Commandline.Add(IntToStr(Width) + 'x' + IntToStr(Height));
    Commandline.Add(':');
    Commandline.Add(IntToStr(BuffSize));
  end else begin
    Commandline.Add(Source);
  end;

  //----------------------- Now launch x264 -----------------------//

  WriteLog('');
  WriteLog('Commandline for x264:');
  WriteLog(Commandline.Text);
  WriteLog('');

  Process.AddToLog('');
  Process.AddToLog('');

  Process.Filter := self.Filter;

  case Process.Execute(Commandline.Text) of
    procFaild:
    begin
      self.ReturnValue := -1;
      WriteLog('');
      WriteLog('Fatal Error: Failed to create the process!');
      WriteStatus('Encoder stopped.');
    end;
    procError:
    begin
      self.ReturnValue := -1;
      WriteLog('');
      WriteLog('Fatal Error: The encoder has encountered an unexpected error!');
      WriteStatus('Encoder stopped.');
    end;
    procAborted:
    begin
      self.ReturnValue := -2;
      WriteLog('');
      WriteLog('Aborted: Process was terminated prematurely!');
      WriteStatus('Encoder stopped.');
    end;
    else
    begin
      self.ReturnValue := 1;
    end;
  end;

  Commandline.Free;
end;

///////////////////////////////////////////////////////////////////////////////
// Output Parsing
///////////////////////////////////////////////////////////////////////////////

function TEncode.Filter(Line: String): Boolean;
var
  a,b,x:Integer;
begin
  Result := pos('%] ', Line) = 0;

  if Result then
  begin
    WriteLog(Line);
  end else
  begin
    a := pos('[', Line);
    b := pos('%]', Line);
    if (a = 1) and (b > a) then
    begin
      x := StrToIntDef(Copy(Line, 2, b-4), -1);
      if x <> -1 then
      begin
        SetProgress(x);
      end;
    end;
    WriteStatus(Line);
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Support Functions
///////////////////////////////////////////////////////////////////////////////

procedure TEncode.WriteLog(Text: String);
begin
  _TextBuffer := Text;
  Synchronize(WriteLogSync);
end;

procedure TEncode.WriteStatus(Text: String);
begin
  _TextBuffer := Text;
  Synchronize(WriteStatusSync);
end;

procedure TEncode.WriteLogSync;
begin
  LogFile.Items.Add(_TextBuffer);
  LogFile.ItemIndex := LogFile.Items.Count-1;
end;

procedure TEncode.WriteStatusSync;
begin
  Status.Text := _TextBuffer;
end;

procedure TEncode.SetProgress(Progress: Integer);
begin
  if Progress <> _Progress then
  begin
    _Progress := Progress;
    Synchronize(SetProgressSync);
  end;
end;

procedure TEncode.SetProgressSync;
begin
  ProgressHandler(_Progress);
end;

function TEncode.GetReturnValue: Integer;
begin
  Result := self.ReturnValue;
end;

procedure TEncode.AbortEncode;
begin
  Process.Kill(42, True);
end;

function TEncode.PauseEncode(Pause: Boolean): Boolean;
begin
  if Pause then
  begin
    Result := Process.SuspendJob;
  end else begin
    Result := Process.ResumeJob;
  end;
end;

end.
