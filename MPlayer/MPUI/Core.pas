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
unit Core;
interface
uses Windows, SysUtils, Classes, Forms, TntMenus, Controls, Dialogs, Messages;

const OSDFont='Arial.ttf';
const ABOVE_NORMAL_PRIORITY_CLASS:Cardinal=$00008000;

type TStatus=(sNone,sOpening,sClosing,sPlaying,sPaused,sStopped,sError);
var Status:TStatus;

type TWin9xWarnLevel=(wlWarn,wlReject,wlAccept);
var Win9xWarnLevel:TWin9xWarnLevel;

const protocolls:array [0..5] of String=('http','rtp','rtsp','ftp','mms','pnm');

type TGetLongPathNameA = function(lpszShortPath, lpszLongPath: PChar; cchBuffer: DWORD): DWORD; stdcall;
var GetLongPathNameA:TGetLongPathNameA;
var KernelDLL:THandle;

var HomeDir:string;
var MediaURL:string;
    DisplayURL:string;
    FirstOpen:boolean;
    AutoPlay:boolean;
var AudioID:integer;
    SubID:integer;
var AudioOut:integer;
    AudioDev:integer;
    Postproc:integer;
    Deinterlace:integer;
    Aspect:integer;
    ReIndex:boolean;
    SoftVol:boolean;
    PriorityBoost:boolean;
    Params:string;
    Duration:string;
var HaveAudio,HaveVideo:boolean;
    NativeWidth,NativeHeight:integer;
    PercentPos:integer;
    SecondPos:integer;
    OSDLevel:integer;
var Volume:integer;
    Mute:boolean;
    LastVolume:integer;
var HMutex:THandle;
    MsgHandshake:Cardinal;


var StreamInfo:record
      FileName, FileFormat, PlaybackTime: string;
      Video:record
        Decoder, Codec: string;
        Bitrate, Width, Height: integer;
        FPS, Aspect: real;
      end;
      Audio:record
        Decoder, Codec: string;
        Bitrate, Rate, Channels: integer;
      end;
      ClipInfo:array[0..9]of record
        Key, Value: string;
      end;
    end;

function SecondsToTime(Seconds:integer):string;
function EscapeParam(const Param:string):string;
procedure Init;
procedure Start;
procedure Stop;
procedure Restart;
procedure ForceStop;
function Running:boolean;
procedure Terminate;
procedure SendCommand(Command:string);
procedure SendVolumeChangeCommand(Volume:integer);
procedure SetOSDLevel(Level:integer);
procedure ResetStreamInfo;
procedure CheckInstances;
function AlreadyRunning:Boolean;
function ToLongPath(ShortPath:String):String;

implementation
uses Main,Log,plist,Info;

type TClientWaitThread=class(TThread)
                         private procedure ClientDone;
                         protected procedure Execute; override;
                         public hProcess:Cardinal;
                       end;
type TProcessor=class(TThread)
                  private Data:string;
                  private procedure Process;
                  protected procedure Execute; override;
                  public hPipe:Cardinal;
                end;

var ClientWaitThread:TClientWaitThread;
    Processor:TProcessor;
    ClientProcess,ReadPipe,WritePipe:Cardinal;
    FirstChance:boolean;
    ExplicitStop:boolean;
    ExitCode:DWORD;
    FontPath:string;
    LastLine:string;
    LineRepeatCount:integer;
    LastCacheFill:string;

procedure HandleInputLine(Line:string); forward;
procedure HandleIDLine(ID, Content: string); forward;


function SplitLine(var Line:string):string;
var i:integer;
begin
  i:=Pos(#32,Line);
  if (length(Line)<72) OR (i<1) then begin
    Result:=Line;
    Line:='';
    exit;
  end;
  if(i>71) then begin
    Result:=Copy(Line,1,i-1);
    Delete(Line,1,i);
    exit;
  end;
  i:=72; while Line[i]<>#32 do dec(i);
  Result:=Copy(Line,1,i-1);
  Delete(Line,1,i);
end;

function EscapeParam(const Param:string):string;
begin
  if Pos(#32,Param)>0 then Result:=#34+Param+#34 else Result:=Param;
end;

function SecondsToTime(Seconds:integer):string;
var m,s:integer;
begin
  if Seconds<0 then Seconds:=0;
  m:=(Seconds DIV 60) MOD 60;
  s:= Seconds MOD 60;
  Result:=IntToStr(Seconds DIV 3600)
          +':'+char(48+m DIV 10)+char(48+m MOD 10)
          +':'+char(48+s DIV 10)+char(48+s MOD 10);
end;


procedure Init;
var WinDir:array[0..MAX_PATH]of char;
var OSVersion:_OSVERSIONINFOA;
begin
//  GetWindowsDirectory(@WinDir[0],MAX_PATH);
  GetEnvironmentVariable('windir',@WinDir[0],MAX_PATH);
  FontPath:=IncludeTrailingPathDelimiter(WinDir)+'Fonts\'+OSDFont;
  if FileExists(FontPath) then
    FontPath:=' -font '+EscapeParam(FontPath)
  else
    FontPath:='';
  HomeDir:=IncludeTrailingPathDelimiter(ExtractFileDir(ExpandFileName(ParamStr(0))));

  // check for Win9x
  FillChar(OSVersion,sizeof(OSVersion),0);
  OSVersion.dwOSVersionInfoSize:=sizeof(OSVersion);
  GetVersionEx(OSVersion);
  if OSVersion.dwPlatformId<VER_PLATFORM_WIN32_NT
    then Win9xWarnLevel:=wlWarn
    else Win9xWarnLevel:=wlAccept;

  KernelDLL := LoadLibrary(kernel32);
  if KernelDLL <> 0 then GetLongPathNameA := GetProcAddress(KernelDLL,'GetLongPathNameA');
end;

procedure Start;
var DummyPipe1,DummyPipe2:THandle;
    si:TStartupInfo;
    pi:TProcessInformation;
    sec:TSecurityAttributes;
    CmdLine,s:string;
    Success:boolean; Error:DWORD;
    ErrorMessage:array[0..1023]of char;
begin
  if ClientProcess<>0 then exit;
  if length(MediaURL)=0 then exit;

  if FirstOpen then begin
    with MainForm do begin
      MAudio.Clear;
      MAudio.Enabled:=false;
      MSubtitle.Clear;
      MSubtitle.Enabled:=false;
    end;
    AudioID:=-1; SubID:=-1;
  end;

  Status:=sOpening; MainForm.UpdateStatus;

  if Win9xWarnLevel=wlWarn then begin
    case MessageDlg(
           'MPUI will not run properly on Win9x systems. Continue anyway?',
           mtWarning,[mbYes,mbNo],0)
    of
      mrYes:Win9xWarnLevel:=wlAccept;
      mrNo:Win9xWarnLevel:=wlReject;
    end;
  end;
  if Win9xWarnLevel=wlReject then begin
    LogForm.TheLog.Text:='not executing MPlayer: invalid Operating System version';
    Status:=sError;
    MainForm.UpdateStatus;
    MainForm.SetupStop(True);
    exit;
  end;

  FirstChance:=true;

  ////////////////////////////////////////////////
  //Patch by M.C. Botha <biolight@mweb.co.za>
  ////////////////////////////////////////////////
  //if Assigned(ClientWaitThread) then begin
  //  ClientWaitThread.Terminate;
  //  FreeAndNil(ClientWaitThread);
  //end;
  //if Assigned(Processor) then begin
  //  Processor.Terminate;
  //  FreeAndNil(Processor);
  //end;
  //ClientWaitThread:=TClientWaitThread.Create(True);
  //Processor:=TProcessor.Create(True);

  ClientWaitThread:=TClientWaitThread.Create(true);
  Processor:=TProcessor.Create(true);

  CmdLine:=EscapeParam(HomeDir+'mplayer.exe')+' -slave -identify -noquiet'
          +' -wid '+IntToStr(MainForm.InnerPanel.Handle)+' -colorkey 0x101010'
          +' -nokeepaspect -framedrop -autosync 100 -vf screenshot'+FontPath;
  if ReIndex then CmdLine:=CmdLine+' -idx';
  if SoftVol then CmdLine:=CmdLine+' -softvol -softvol-max 1000';
  if PriorityBoost then begin
    CmdLine:=CmdLine+' -priority abovenormal';
    SetPriorityClass(GetCurrentProcess,HIGH_PRIORITY_CLASS);
  end else begin
    SetPriorityClass(GetCurrentProcess,ABOVE_NORMAL_PRIORITY_CLASS);
  end;
  case AudioOut of
    0:CmdLine:=CmdLine+' -nosound';
    1:CmdLine:=CmdLine+' -ao null';
    2:CmdLine:=CmdLine+' -ao win32';
    3:CmdLine:=CmdLine+' -ao dsound:device='+IntToStr(AudioDev);
  end;
  if (AudioID>=0) AND (AudioOut>0) then CmdLine:=CmdLine+' -aid '+IntToStr(AudioID);
  if SubID>=0 then CmdLine:=CmdLine+' -sid '+IntToStr(SubID);
  case Aspect of
    1:CmdLine:=CmdLine+' -aspect 4:3';
    2:CmdLine:=CmdLine+' -aspect 16:9';
    3:CmdLine:=CmdLine+' -aspect 2.35';
  end;
  case Postproc of
    1:CmdLine:=CmdLine+' -autoq 10 -vf-add pp';
    2:CmdLine:=CmdLine+' -vf-add pp=hb/vb/dr';
  end;
  case Deinterlace of
    1:CmdLine:=CmdLine+' -vf-add lavcdeint';
    2:CmdLine:=CmdLine+' -vf-add kerndeint=5';
  end;
  if length(Params)>0 then
    CmdLine:=CmdLine+#32+Params;
  CmdLine:=CmdLine+#32+MediaURL;

  with LogForm do begin
    TheLog.Clear;
    AddLine('command line:');
    s:=CmdLine;
    while length(s)>0 do
      AddLine(SplitLine(s));
    AddLine('');
  end;

  HaveAudio:=true;
  HaveVideo:=true;
  NativeWidth:=0;
  NativeHeight:=0;
  PercentPos:=0;
  SecondPos:=-1;
  OSDLevel:=1;
  ExplicitStop:=false;
  Duration:='0:00:00';
  ResetStreamInfo;
  StreamInfo.FileName:=MediaURL;
  LastLine:=''; LineRepeatCount:=0;
  LastCacheFill:='';

  with sec do begin
    nLength:=sizeof(sec);
    lpSecurityDescriptor:=nil;
    bInheritHandle:=true;
  end;
  CreatePipe(ReadPipe,DummyPipe1,@sec,0);

  with sec do begin
    nLength:=sizeof(sec);
    lpSecurityDescriptor:=nil;
    bInheritHandle:=true;
  end;
  CreatePipe(DummyPipe2,WritePipe,@sec,0);

  FillChar(si,sizeof(si),0);
  si.cb:=sizeof(si);
  si.dwFlags:=STARTF_USESTDHANDLES;
  si.hStdInput:=DummyPipe2;
  si.hStdOutput:=DummyPipe1;
  si.hStdError:=DummyPipe1;
  Success:=CreateProcess(nil,PChar(CmdLine),nil,nil,true,DETACHED_PROCESS,nil,PChar(HomeDir),si,pi);
  Error:=GetLastError();

  CloseHandle(DummyPipe1);
  CloseHandle(DummyPipe2);

  if not Success then begin
    LogForm.AddLine('Error '+IntToStr(Error)+' while starting MPlayer:');
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,nil,Error,0,@ErrorMessage[0],1023,nil);
    LogForm.AddLine(ErrorMessage);
    if Error=2 then LogForm.AddLine('Please check if MPlayer.exe is installed in the same directory as MPUI.');
    ClientWaitThread.ClientDone;  // this is a synchronized function, so I may
                                  // call it here from this thread as well
    exit;
  end;

  ClientProcess:=pi.hProcess;
  ClientWaitThread.hProcess:=ClientProcess;
  Processor.hPipe:=ReadPipe;

  ClientWaitThread.Resume;
  Processor.Resume;
  MainForm.SetupStart;

  if AudioOut>1 then begin
    // init volume adjustments
    if AudioOut=3 then LastVolume:=100;  // DirectSound always starts at 100%
    if SoftVol then LastVolume:=-1;  // SoftVol always starts ... somewhere else
    if Volume<>LastVolume then
      SendVolumeChangeCommand(Volume);
    if Mute then SendCommand('mute');
  end;
end;

procedure TClientWaitThread.ClientDone;
var WasExplicit:boolean;
begin
  ClientProcess:=0;
  CloseHandle(ReadPipe); ReadPipe:=0;
  CloseHandle(WritePipe); WritePipe:=0;
  ClientWaitThread.Terminate;
  if Assigned(Processor) then Processor.Terminate;
  FirstOpen:=false;
  if (Status=sOpening) OR (ExitCode<>0) then Status:=sError else Status:=sStopped;
  DisplayURL:='';
  WasExplicit:=ExplicitStop OR (Status=sError);
  MainForm.UpdateStatus;
  MainForm.SetupStop(WasExplicit);
  MainForm.UpdateCaption;
  ExplicitStop:=false;
  if not WasExplicit then
    MainForm.NextFile(1,psPlayed);
end;

procedure TClientWaitThread.Execute;
begin
  WaitForSingleObject(hProcess,INFINITE);
  GetExitCodeProcess(hProcess,ExitCode);
  Synchronize(ClientDone);
end;

procedure TProcessor.Process;
var LastEOL,EOL,Len:integer;
begin
  Len:=length(Data);
  LastEOL:=0;
  for EOL:=1 to Len do
    if (EOL>LastEOL) AND ((Data[EOL]=#13) OR (Data[EOL]=#10)) then begin
      HandleInputLine(Copy(Data,LastEOL+1,EOL-LastEOL-1));
      LastEOL:=EOL;
      if (LastEOL<Len) AND (Data[LastEOL+1]=#10) then inc(LastEOL);
    end;
  if LastEOL<>0 then Delete(Data,1,LastEOL);
end;

procedure TProcessor.Execute;
const BufSize=1024;
var Buffer:array[0..BufSize]of char;
    BytesRead:cardinal;
begin
  Data:='';
  repeat
    BytesRead:=0;
    if not ReadFile(hPipe,Buffer[0],BufSize,BytesRead,nil) then break;
    Buffer[BytesRead]:=#0;
    Data:=Data+Buffer;
    Synchronize(Process);
  until BytesRead=0;
end;

function Running:boolean;
begin
  Result:=(ClientProcess<>0);
end;

procedure Stop;
begin
  Status:=sClosing; MainForm.UpdateStatus;
  ExplicitStop:=true;
  if FirstChance then begin
    SendCommand('quit');
    FirstChance:=false;
  end else
    Terminate;
end;

procedure Terminate;
begin
  if ClientProcess=0 then exit;
  TerminateProcess(ClientProcess,cardinal(-1));

  ////////////////////////////////////////////////
  //Patch by M.C. Botha <biolight@mweb.co.za>
  ////////////////////////////////////////////////
  //try
  //  if(ClientProcess=0) and (not Assigned(ClientWaitThread)) and (not Assigned(Processor)) then
  //  begin
  //    exit;
  //  end;
  //  ClientWaitThread.Terminate;
  //  ClientWaitThread.Free;
  //  Processor.Terminate;
  //  Processor.Free;
  //except
  //end;
end;

procedure ForceStop;
begin
  ExplicitStop:=true;
  if FirstChance then begin
    SendCommand('quit');
    FirstChance:=false;
    if WaitForSingleObject(ClientProcess,1000)<>WAIT_TIMEOUT then exit;
  end;
  Terminate;
end;

procedure SendCommand(Command:string);
var Dummy:cardinal;
begin
  if (ClientProcess=0) OR (WritePipe=0) then exit;
  Command:=Command+#10;
  WriteFile(WritePipe,Command[1],length(Command),Dummy,nil);
end;

procedure SendVolumeChangeCommand(Volume:integer);
begin
  if Mute then exit; 
  LastVolume:=Volume;
  if SoftVol then Volume:=Volume DIV 10;
  SendCommand('volume '+IntToStr(Volume)+' 1');
end;

procedure SetOSDLevel(Level:integer);
begin
  if Level<0 then OSDLevel:=OSDLevel+1
             else OSDLevel:=Level;
  OSDLevel:=OSDLevel AND 3;
  SendCommand('osd '+IntToStr(OSDLevel));
end;

procedure Restart;
var LastPos,LastOSD:integer;
begin
  if not Running then exit;
  LastPos:=PercentPos;
  LastOSD:=OSDLevel;
  ForceStop;
  Sleep(50); // wait for the processing threads to finish
  Application.ProcessMessages;
  Start;
  SendCommand('seek '+IntToStr(LastPos)+' 1');
  SetOSDLevel(LastOSD);
  MainForm.QueryPosition;
end;

////////////////////////////////////////////////////////////////////////////////



procedure HandleInputLine(Line:string);
var r,i,j,p:integer; c:char;

  procedure SubMenu_Add(Menu:TTntMenuItem; ID,SelectedID:integer; Handler:TNotifyEvent);
  var j:integer; Item:TTntMenuItem;
  begin
    with MainForm.MAudio do
      for j:=0 to Menu.Count-1 do
        if Menu.Items[j].Tag=ID then exit;
    Item:=TTntMenuItem.Create(Menu);
    with Item do begin
      Caption:=IntToStr(ID);
      Tag:=ID;
      GroupIndex:=$0A;
      RadioItem:=true;
      if ID=SelectedID then Checked:=true else
      if (SelectedID<0) AND (Menu.Count=0) then Checked:=true;
      OnClick:=Handler;
    end;
    Menu.Add(Item);
    Menu.Enabled:=true;
  end;

  procedure SubMenu_SetLang(Menu:TTntMenuItem; ID:integer; Lang:string);
  var j:integer;
  begin
    with MainForm.MAudio do
      for j:=0 to Menu.Count-1 do
        with Menu.Items[j] do
          if Tag=ID then begin
            Caption:=IntToStr(ID)+' ('+Lang+')';
            exit;
          end;
  end;

  function CheckNativeResolutionLine:boolean;
  begin
    Result:=false;
    if Copy(Line,1,5)<>'VO: [' then exit;
    p:=Pos(' => ',Line); if p=0 then exit; Delete(Line,1,p+3);
    p:=Pos(#32,Line);    if p=0 then exit; SetLength(Line,p-1);
    p:=Pos('x',Line);    if p=0 then exit;
    Val(Copy(Line,1,p-1),i,r); if (r<>0) OR (i<16) OR (i>=4096) then exit;
    Val(Copy(Line,p+1,5),j,r); if (r<>0) OR (j<16) OR (j>=4096) then exit;
    NativeWidth:=i; NativeHeight:=j;
    MainForm.VideoSizeChanged;
    Status:=sPlaying; MainForm.UpdateStatus;
    Result:=true;
  end;

  function CheckNoAudio:boolean;
  begin
    Result:=false;
    if Line<>'Audio: no sound' then exit;
    HaveAudio:=false;
    Result:=true;
  end;

  function CheckNoVideo:boolean;
  begin
    Result:=false;
    if Line<>'Video: no video' then exit;
    HaveVideo:=false;
    Result:=true;
  end;

  function CheckStartPlayback:boolean;
  begin
    Result:=false;
    if Line<>'Starting playback...' then exit;
    MainForm.SetupPlay;
    if not(HaveVideo) then begin
      Status:=sPlaying; MainForm.UpdateStatus;
    end;
    Result:=true;
  end;

  function CheckAudioID:boolean;
  begin
    Result:=false;
    if Copy(Line,1,12)='ID_AUDIO_ID=' then begin
      Val(Copy(Line,13,9),i,r);
      if (r=0) AND (i>=0) AND (i<8191) then begin
        SubMenu_Add(MainForm.MAudio,i,AudioID,MainForm.MAudioClick);
        Result:=true;
      end;
    end;
  end;

  function CheckAudioLang:boolean;
  var s:string; p:integer;
  begin
    Result:=false;
    if Copy(Line,1,7)='ID_AID_' then begin
      s:=Copy(Line,8,20);
      p:=Pos('_LANG=',s);
      if p<=0 then exit;
      Val(Copy(s,1,p-1),i,r);
      if (r=0) AND (i>=0) AND (i<256) then begin
       SubMenu_SetLang(MainForm.MAudio,i,copy(s,p+6,8));
        Result:=true;
      end;
    end;
  end;

  function CheckSubID:boolean;
  begin
    Result:=false;
    if Copy(Line,1,15)='ID_SUBTITLE_ID=' then begin
      Val(Copy(Line,16,9),i,r);
      if (r=0) AND (i>=0) AND (i<256) then begin
        SubMenu_Add(MainForm.MSubtitle,i,SubID,MainForm.MSubtitleClick);
        Result:=true;
      end;
    end;
  end;

  function CheckSubLang:boolean;
  var s:string; p:integer;
  begin
    Result:=false;
    if Copy(Line,1,7)='ID_SID_' then begin
      s:=Copy(Line,8,20);
      p:=Pos('_LANG=',s);
      if p<=0 then exit;
      Val(Copy(s,1,p-1),i,r);
      if (r=0) AND (i>=0) AND (i<256) then begin
        SubMenu_SetLang(MainForm.MSubtitle,i,copy(s,p+6,8));
        Result:=true;
      end;
    end;
  end;

  function CheckLength:boolean;
  var f:real;
  begin
    Result:=(Copy(Line,1,10)='ID_LENGTH=');
    if Result then begin
      Val(Copy(Line,11,10),f,r);
      if r=0 then Duration:=SecondsToTime(round(f));
    end;
  end;

  function CheckFileFormat:boolean;
  begin
    p:=length(Line)-21;
    Result:=(p>0) AND (Copy(Line,p,22)=' file format detected.');
    if Result then
      StreamInfo.FileFormat:=Copy(Line,1,p-1);
  end;

  function CheckDecoder:boolean;
  begin
    Result:=(Copy(Line,1,8)='Opening ') AND (Copy(Line,13,12)='o decoder: [');
    if not Result then exit;
    p:=Pos('] ',Line); Result:=(p>24);
    if not Result then exit;
    if Copy(Line,9,4)='vide' then
      StreamInfo.Video.Decoder:=Copy(Line,p+2,length(Line))
    else if Copy(Line,9,4)='audi' then
      StreamInfo.Audio.Decoder:=Copy(Line,p+2,length(Line))
    else Result:=false;
  end;

  function CheckCodec:boolean;
  begin
    Result:=(Copy(Line,1,9)='Selected ') AND (Copy(Line,14,10)='o codec: [');
    if not Result then exit;
    p:=Pos(' (',Line); Result:=(p>23);
    if not Result then exit;
    if Copy(Line,10,4)='vide' then
      StreamInfo.Video.Codec:=Copy(Line,p+2,length(Line)-p-2)
    else if Copy(Line,10,4)='audi' then
      StreamInfo.Audio.Codec:=Copy(Line,p+2,length(Line)-p-2)
    else Result:=false;
  end;

  function CheckICYInfo:boolean;
  var P:integer;
  begin
    Result:=False;
    if Copy(Line,1,10)<>'ICY Info: ' then exit;
    P:=Pos('StreamTitle=''',Line); if P<10 then exit;
    Delete(Line,1,P+12);
    P:=Pos(''';',Line); if P<1 then exit;
    SetLength(Line,P-1);
    if length(Line)=0 then exit;
    P:=0; while (P<9)
            AND (length(StreamInfo.ClipInfo[P].Key)>0)
            AND (StreamInfo.ClipInfo[P].Key<>'Title')
          do inc(P);
    StreamInfo.ClipInfo[P].Key:='Title';
    if StreamInfo.ClipInfo[P].Value<>Line then begin
      StreamInfo.ClipInfo[P].Value:=Line;
      InfoForm.UpdateInfo;
    end;
  end;

begin
  // Time position indicators are "first-class citizens", because they
  // make up for 99.999% of all traffic. So we have to handle them *FAST*!
  if (length(Line)>7) then begin
    if Line[1]=^J then j:=4 else j:=3;
    if ((Line[j-2]='A') OR (Line[j-2]='V')) AND (Line[j-1]=':') then begin
      p:=0;
      for i:=0 to 3 do begin
        c:=Line[i+j];
        case c of
          '-': begin p:=-1; break; end;
          '0'..'9': p:=p*10+ord(c)-48;
        end;
      end;
      if p<>SecondPos then begin
        SecondPos:=p;
        MainForm.UpdateTime;
      end;
      exit;
    end;
  end;
  // normal line handling: check for "cache fill"
  Line:=Trim(Line);
  if (length(Line)>=18) AND (Line[11]=':') AND (Line[18]='%') AND (Copy(Line,1,10)='Cache fill') then begin
    if Copy(Line,12,6)=LastCacheFill then exit;
    MainForm.LStatus.Caption:=Line;
    if (Copy(LogForm.TheLog.Lines[LogForm.TheLog.Lines.Count-1],1,11)='Cache fill:') then
      LogForm.TheLog.Lines[LogForm.TheLog.Lines.Count-1]:=Line;
    Sleep(0);  // "yield"
    exit;
  end;
  // check percent_position indicator (hidden from log)
  if Copy(Line,1,21)='ANS_PERCENT_POSITION=' then begin
    Val(Copy(Line,22,4),i,r);
    if (r=0) AND (i>=0) AND (i<=100) then begin
      PercentPos:=i;
      MainForm.UpdateSeekBar;
    end;
    exit;
  end;
  // suppress repetitive lines
  if (length(Line)>0) AND (Line=LastLine) then begin
    inc(LineRepeatCount);
    exit;
  end;
  if LineRepeatCount=1 then
    LogForm.AddLine(Line)
  else if LineRepeatCount>1 then
    LogForm.AddLine('(last message repeated '+IntToStr(LineRepeatCount)+' times)');
  LastLine:=Line;
  LineRepeatCount:=0;
  // add line to log and check for special patterns
  LogForm.AddLine(Line);
  if not CheckNativeResolutionLine then
  if not CheckNoAudio then
  if not CheckNoVideo then
  if not CheckStartPlayback then
  if not CheckAudioID then
  if not CheckAudioLang then
  if not CheckSubID then
  if not CheckSubLang then
  if not CheckLength then
  if not CheckFileFormat then
  if not CheckDecoder then
  if not CheckCodec then
  if not CheckICYInfo then  // modifies Line, should be last
  ;
  // check for generic ID_ pattern
  if Copy(Line,1,3)='ID_' then begin
    p:=Pos('=',Line);
    HandleIDLine(Copy(Line,4,p-4), Trim(Copy(Line,p+1,length(Line))));
  end;
end;


////////////////////////////////////////////////////////////////////////////////

procedure HandleIDLine(ID, Content: string);
var AsInt,r:integer; AsFloat:real;
begin with StreamInfo do begin
  // convert to int and float
  val(Content,AsInt,r);
  if r<>0 then begin
    val(Content,AsFloat,r);
    if r<>0 then begin
      AsInt:=0; AsFloat:=0;
    end else AsInt:=trunc(AsFloat);
  end else AsFloat:=AsInt;

  // handle some common ID fields
       if ID='FILENAME'      then FileName:=Content
  else if ID='VIDEO_BITRATE' then Video.Bitrate:=AsInt
  else if ID='VIDEO_WIDTH'   then Video.Width:=AsInt
  else if ID='VIDEO_HEIGHT'  then Video.Height:=AsInt
  else if ID='VIDEO_FPS'     then Video.FPS:=AsFloat
  else if ID='VIDEO_ASPECT'  then Video.Aspect:=AsFloat
  else if ID='AUDIO_BITRATE' then Audio.Bitrate:=AsInt
  else if ID='AUDIO_RATE'    then Audio.Rate:=AsInt
  else if ID='AUDIO_NCH'     then Audio.Channels:=AsInt
  else if (ID='DEMUXER') AND (length(FileFormat)=0) then FileFormat:=Content
  else if (ID='VIDEO_FORMAT') AND (length(Video.Decoder)=0) then Video.Decoder:=Content
  else if (ID='VIDEO_CODEC') AND (length(Video.Codec)=0) then Video.Codec:=Content
  else if (ID='AUDIO_FORMAT') AND (length(Audio.Decoder)=0) then Audio.Decoder:=Content
  else if (ID='AUDIO_CODEC') AND (length(Audio.Codec)=0) then Audio.Codec:=Content
  else if (ID='LENGTH') AND (AsFloat>0.001) then begin
    AsFloat:=Frac(AsFloat);
    if (AsFloat>0.0009) then begin
      str(AsFloat:0:3, PlaybackTime);
      PlaybackTime:=SecondsToTime(AsInt) + Copy(PlaybackTime,2,20);
    end else
      PlaybackTime:=SecondsToTime(AsInt);
  end else if (Copy(ID,1,14)='CLIP_INFO_NAME') AND (length(ID)=15) then begin
    r:=Ord(ID[15])-Ord('0');
    if (r>=0) AND (r<=9) then ClipInfo[r].Key:=Content;
  end else if (Copy(ID,1,15)='CLIP_INFO_VALUE') AND (length(ID)=16) then begin
    r:=Ord(ID[16])-Ord('0');
    if (r>=0) AND (r<=9) then ClipInfo[r].Value:=Content;
  end;
end; end;


procedure ResetStreamInfo;
var i:integer;
begin with StreamInfo do begin
  FileName:='';
  FileFormat:='';
  PlaybackTime:='';
  with Video do begin
    Decoder:=''; Codec:='';
    Bitrate:=0; Width:=0; Height:=0; FPS:=0.0; Aspect:=0.0;
  end;
  with Audio do begin
    Decoder:=''; Codec:='';
    Bitrate:=0; Rate:=0; Channels:=0;
  end;
  for i:=0 to 9 do
    with ClipInfo[i] do begin
      Key:=''; Value:='';
    end;
end; end;


procedure CheckInstances;
begin
  MsgHandshake:=RegisterWindowMessage('{CABD1190-878A-458C-A376-A527F402C7E3}');
  HMutex:=CreateMutex(nil,True,'{B85F1D28-0E67-4EFF-B565-C9711965033C}');

  if (GetLastError = ERROR_ALREADY_EXISTS) then if AlreadyRunning then begin
    CloseHandle(HMutex);
    Halt;
  end;

  if CreateFile(PAnsiChar(SysUtils.ExtractFileDir(Application.ExeName) + '\MPLAYER.EXE'),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0) = INVALID_HANDLE_VALUE then begin
    Application.MessageBox('MPLAYER.EXE could not be found. MPUI is not installed properly!','MPlayer for Windows',MB_OK+MB_ICONERROR+MB_TOPMOST);
    Halt;
  end;
end;


function AlreadyRunning:Boolean;
var
  msg:TMsg;
  Recieved:Boolean;
  Timeout:Integer;
  cds:TCopyDataStruct;
  media:String;
  i,enqueue:Integer;
  s:String;
begin
  enqueue := 0;
  for i:=1 to ParamCount do begin
    s := AnsiLowerCase(ParamStr(i));
    if s = '-multiple' then begin
      Result := False;
      Exit;
    end;
    if s = '-enqueue' then enqueue := i;
  end;

  Recieved:=False;
  Timeout:=0;
  PostMessage(HWND_BROADCAST,MsgHandshake,1,Application.Handle);
  while Timeout < 120 do begin
    if PeekMessage(msg,application.Handle,MsgHandshake,MsgHandshake,PM_REMOVE) then
      if (msg.WParam = 2) then begin
        Recieved := True;
        Break;
      end;
    Timeout:=Timeout+1;
    Sleep(100);
  end;

  if not Recieved then begin
    Result:=False;
    Exit;
  end;

  if enqueue > 0 then begin
    cds.dwData := 42;
    media := ParamStr(enqueue+1);
  end else begin
    cds.dwData := 43;
    media := ParamStr(1);
  end;

  cds.cbData := Length(media) + 1;
  cds.lpData := PAnsiChar(media);
  SendMessage(msg.LParam,WM_COPYDATA,application.Handle,Integer(@cds));

  Result:=True;
end;


function ToLongPath(ShortPath:String):String;
var a:PAnsiChar; r:Cardinal; i:integer;
begin
  Result := ShortPath;

  for i := 0 to Length(protocolls)-1 do
    if pos(protocolls[i]+'://',ShortPath) > 0 then Exit;

  if not Assigned(GetLongPathNameA) then Exit;
  r := GetLongPathNameA(PAnsiChar(ShortPath),a,0);
  if r > 0 then begin
    a := AllocMem(r);
    GetLongPathNameA(PAnsiChar(ShortPath),a,r);
    Result := a;
    FreeMem(a);
  end;  
end;


begin
  GetLongPathNameA:=nil;
  DecimalSeparator:='.';
  NativeWidth:=0; NativeHeight:=0;
  MediaURL:=''; DisplayURL:=''; FirstOpen:=true;
  AudioID:=-1; SubID:=-1; OSDLevel:=1;
  Deinterlace:=0; Aspect:=0; Postproc:=0;
  AudioOut:=3; AudioDev:=0;
  ReIndex:=false; SoftVol:=false; PriorityBoost:=true;
  Params:='';
  Duration:='';
  Status:=sNone;
  Volume:=100; Mute:=False;
  LastVolume:=-1;
  ResetStreamInfo;
end.

