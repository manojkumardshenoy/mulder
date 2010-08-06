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

unit Unit_Encode;

///////////////////////////////////////////////////////////////////////////////
interface
///////////////////////////////////////////////////////////////////////////////

uses
  Classes, SysUtils, StdCtrls, ShlObj, Windows, JvListBox, Unit_RunProcess,
  Unit_Commandline, Unit_RIPEMD160, MuldeR_Toolz, Unit_LinkTime;

type
  TProgressHandler = procedure(Progess: Integer) of object;

type
  TRCMode = (RC_CRF, RC_QP, RC_ABR);

type
  TEncode = class(TThread)
  public
    constructor Create(const Source: String; const Output: String; const RCMode: TRCMode; const RCValue: Integer; const Pass: Byte; const Preset: String; const Tune: String; const Profile:String; const Params:String; const LogFile: TJvListBox; const Status: TEdit; const ProgressHandler: TProgressHandler; const x64: Boolean; const BuffSize:Integer);
    destructor Destroy; override;
    function GetReturnValue: Integer;
    procedure AbortEncode;
    function PauseEncode(const Pause: Boolean): Boolean;
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
    TempDir: String;
    _TextBuffer: String;
    _Progress: Integer;
  protected
    procedure ApplyGeneralSettings(const Commandline: TCommandline);
    function CheckEncoderVersion(const Commandline: TCommandline): Boolean;
    procedure Execute; override;
    function Filter(const Line: String): Boolean;
    function PrepareSourceAVS(const Commandline: TCommandline): Boolean;
    function PrepareSourceFFMS2(const Commandline: TCommandline): Boolean;
    procedure SetProgress(const Progress: Integer);
    procedure SetProgressSync;
    procedure WriteLog(Text: String);
    procedure WriteLogSync;
    procedure WriteStatus(const Text: String);
    procedure WriteStatusSync;
  end;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

uses Unit_Main;

///////////////////////////////////////////////////////////////////////////////
// Constructor & Destructor
///////////////////////////////////////////////////////////////////////////////

constructor TEncode.Create(const Source: String; const Output: String; const RCMode: TRCMode; const RCValue: Integer; const Pass: Byte; const Preset: String; const Tune: String; const Profile:String; const Params:String; const LogFile: TJvListBox; const Status: TEdit; const ProgressHandler: TProgressHandler; const x64: Boolean; const BuffSize:Integer);
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
  TempDir := GetTempDirectory;

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
    SysUtils.Beep;
  end;

  FreeAndNil(Temp);
  FreeAndNil(Process);
  FreeAndNil(Params);
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
  Commandline: TCommandline;
  Success: Boolean;
begin
  self.ReturnValue := 0;
  Commandline := TCommandline.Create;

  //----------------------- Check x264 version -----------------------//

  WriteStatus('Initializing x264 encoder, please wait...');

  if not CheckEncoderVersion(Commandline) then
  begin
    self.ReturnValue := -1;
    WriteLog('');
    WriteLog('Fatal Error: Failed to create the process!');
    WriteStatus('Encoder stopped.');
    Commandline.Free;
    Exit;
  end;

  //----------------------- Prepare Source -----------------------//

  WriteStatus('Preparing source for encode, please wait...');

  if SameText(ExtractExtension(Source), 'avs') then
  begin
    Success := PrepareSourceAVS(Commandline);
  end else begin
    Success := PrepareSourceFFMS2(Commandline);
  end;

  if not Success then
  begin
    self.ReturnValue := -1;
    WriteLog('');
    WriteLog('Fatal Error: Failed to create the process!');
    WriteStatus('Encoder stopped.');
    Commandline.Free;
    Exit;
  end;

  //----------------------- Now launch x264 -----------------------//

  WriteStatus('Creating encoder processes, please wait...');

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
// Make Avisynth command-line
///////////////////////////////////////////////////////////////////////////////

function TEncode.PrepareSourceAVS(const Commandline: TCommandline): Boolean;
var
  LogData: TStringList;
  Width: Integer;
  Height:Integer;
  FPS1: Integer;
  FPS2: Integer;
  Frames: Integer;
  BuffSize: Integer;
  i: Integer;
  j: Integer;
  s: String;
  t: TStringList;
  r: TStringList;
begin
  if not Assigned(Commandline) then
  begin
    Result := False;
    Exit;
  end;

  Commandline.Clear;
  BuffSize := self.BuffSize;

  //----------------------- Analyze Source -----------------------//

  WriteLog('Analyzing source file:');

  Commandline.Clear;
  Commandline.Add(HomeDir + '\avs2yuv.exe');
  Commandline.Add(Source);
  Commandline.Add(['-frames', '1']);
  Commandline.Add('NUL');

  Process.Filter := Self.Filter;

  case Process.Execute(Commandline.Text) of
    procFaild:
    begin
      WriteLog('');
      WriteLog('Fatal Error: Failed to create the process!');
      WriteStatus('Encoder stopped.');
      Result := False;
      Exit;
    end;
    procError:
    begin
      WriteLog('');
      WriteLog('Fatal Error: Failed to analyze the source video!');
      WriteStatus('Encoder stopped.');
      Result := False;
      Exit;
    end;
    procAborted:
    begin
      WriteLog('');
      WriteLog('Aborted: Process was terminated prematurely!');
      WriteStatus('Encoder stopped.');
      Result := False;
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

  if Frames < 1 then
  begin
    WriteLog('Fatal Error: Failed to analyze the source video!');
    WriteStatus('Encoder stopped.');
    Result := False;
    Exit;
  end;

  if BuffSize < 0 then
  begin
    BuffSize := (Width * Height * 120) div 1048576;
  end;

  //----------------------- Build x264 command-line -----------------------//

  Commandline.Clear;

  if x64 then
  begin
    Commandline.Add(HomeDir + '\pipebuf.exe');
    Commandline.Add(HomeDir + '\avs2yuv.exe');
    Commandline.Add(Source);
    Commandline.Add('-');
    Commandline.Add(':');
    Commandline.Add(HomeDir + '\x264_x64.exe');
  end else begin
    Commandline.Add(HomeDir + '\x264.exe');
  end;

  ApplyGeneralSettings(Commandline);

  if x64 then
  begin
    Commandline.Add(['--frames', IntToStr(Frames)]);
    Commandline.Add(['--demuxer', 'y4m']);
    Commandline.Add(['--stdin', 'y4m', '-']);
    Commandline.Add(':');
    Commandline.Add(IntToStr(BuffSize));
  end else begin
    Commandline.Add(['--demuxer', 'avs']);
    Commandline.Add(Source);
  end;

  Result := True;
end;

///////////////////////////////////////////////////////////////////////////////
// Make FFMS2 command-line
///////////////////////////////////////////////////////////////////////////////

function TEncode.PrepareSourceFFMS2(const Commandline: TCommandline): Boolean;
var
  IndexFile: String;
  Year, Month, Day: Integer;
begin
  if not Assigned(Commandline) then
  begin
    Result := False;
    Exit;
  end;

  Commandline.Clear;

  with TRipemd160.Create do
  begin
    Init;
    GetImageLinkTimeStampAsIntegers(Year, Month, Day);
    UpdateStr(Format('file://%s?age=%08x&release=%d', [Source, FileAge(Source), (Year * 10000) + (Month * 100) + Day]));
    FinalStr(IndexFile);
    Free;
  end;

  if x64 then
  begin
    Commandline.Add(HomeDir + '\x264_x64.exe');
  end else begin
    Commandline.Add(HomeDir + '\x264.exe');
  end;

  ApplyGeneralSettings(Commandline);

  Commandline.Add(['--demuxer', 'ffms']);
  Commandline.Add(['--index', Format('%s\~%s.x264-index', [TempDir, IndexFile])]);
  Commandline.Add(Source);

  Result := True;
end;

///////////////////////////////////////////////////////////////////////////////
// Apply general x264 settings
///////////////////////////////////////////////////////////////////////////////

procedure TEncode.ApplyGeneralSettings(const Commandline: TCommandline);
begin
  if not Assigned(Commandline) then
  begin
    Exit;
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
end;

///////////////////////////////////////////////////////////////////////////////
// Check x264 version
///////////////////////////////////////////////////////////////////////////////

function TEncode.CheckEncoderVersion(const Commandline: TCommandline): Boolean;
var
  LogData: TStringList;
  i: Integer;
  j: Integer;
  s: String;
  t: TStringList;
  r: TStringList;
  v: Integer;
begin
  if not Assigned(Commandline) then
  begin
    Result := False;
    Exit;
  end;

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
      WriteLog('');
      WriteLog('Fatal Error: Failed to create the process!');
      WriteStatus('Encoder stopped.');
      Result := False;
      Exit;
    end;
    procError:
    begin
      WriteLog('');
      WriteLog('Fatal Error: The encoder has encountered an unexpected error!');
      WriteStatus('Encoder stopped.');
      Result := False;
      Exit;
    end;
    procAborted:
    begin
      WriteLog('');
      WriteLog('Aborted: Process was terminated prematurely!');
      WriteStatus('Encoder stopped.');
      Result := False;
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
    WriteLog('');
  end else begin
    WriteLog('Revision: N/A');
  end;

  if (v < Unit_Main.MinRev) then
  begin
    WriteLog('');
    WriteLog(Format('Fatal Error: Detected an outdated revision of x264. Minimum revision required is r%d.', [Unit_Main.MinRev]));
    WriteLog('Please update your x264 binaries to a suitable version!');
    WriteStatus('Encoder stopped.');
    Result := False;
    Exit;
  end;

  Result := True;
end;

///////////////////////////////////////////////////////////////////////////////
// Output Parsing
///////////////////////////////////////////////////////////////////////////////

function TEncode.Filter(const Line: String): Boolean;
var
  a,b,x:Integer;
  Temp: String;
begin
  if (not Assigned(Process)) or (not Process.StillRunning) then
  begin
    Result := True;
    Exit;
  end;

  if SameText(Copy(Line,1,7), '[info]:') then
  begin
    Temp := Trim(Copy(Line, 8, Length(Line)));
  end else begin
    Temp := Trim(Line);
  end;

  Result := pos('%]', Temp) = 0;

  if Result then
  begin
    if Temp <> '' then WriteLog(Line);
  end else
  begin
    a := pos('[', Temp);
    b := pos('%]', Temp);
    if (a > 0) and (b > a) then
    begin
      x := StrToIntDef(Copy(Temp, a+1, b-a-3), -1);
      if x <> -1 then
      begin
        SetProgress(x);
      end;
    end;
    WriteStatus(Temp);
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

procedure TEncode.WriteStatus(const Text: String);
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

procedure TEncode.SetProgress(const Progress: Integer);
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
  if Assigned(Process) then Process.Kill(42, True);
end;

function TEncode.PauseEncode(const Pause: Boolean): Boolean;
begin
  if Pause then
  begin
    Result := Process.SuspendJob;
  end else begin
    Result := Process.ResumeJob;
  end;
end;

end.
