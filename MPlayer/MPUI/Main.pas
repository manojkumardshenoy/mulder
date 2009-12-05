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
unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Buttons, ExtCtrls, Menus, ShellAPI, AppEvnts, StdCtrls,
  Math, plist, ImgList, Clipbrd, ToolWin, TntMenus, TntDialogs, 
  TntComCtrls, TntExtCtrls, TntStdCtrls, TntButtons, TntForms, jpeg, TrayIcon;

function SetThreadExecutionState(esFlags:Cardinal):Cardinal; stdcall; external 'kernel32.dll';  
const
    ES_SYSTEM_REQUIRED  = $01;
    ES_DISPLAY_REQUIRED = $02;
const
    VK_MEDIA_NEXT_TRACK = $B0;
    VK_MEDIA_PREV_TRACK = $B1;
    VK_MEDIA_STOP       = $B2;
    VK_MEDIA_PLAY_PAUSE = $B3;

type
  TMainForm = class(TTntForm)
    MainMenu: TTntMainMenu;
    ControlPanel: TTntPanel;
    BPlay: TTntSpeedButton;
    BPause: TTntSpeedButton;
    UpdateTimer: TTimer;
    SeekBarFrame: TTntPanel;
    SeekBarSlider: TTntPanel;
    MSize50: TTntMenuItem;
    MSize100: TTntMenuItem;
    MSize200: TTntMenuItem;
    MFullscreen: TTntMenuItem;
    MSeekF10: TTntMenuItem;
    MSeekR10: TTntMenuItem;
    MSeekF60: TTntMenuItem;
    MSeekR60: TTntMenuItem;
    MSeekF600: TTntMenuItem;
    MSeekR600: TTntMenuItem;
    N2: TTntMenuItem;
    MPause: TTntMenuItem;
    MPlay: TTntMenuItem;
    N3: TTntMenuItem;
    MOSD: TTntMenuItem;
    MSizeAny: TTntMenuItem;
    MOnTop: TTntMenuItem;
    BFullscreen: TTntSpeedButton;
    BStreamInfo: TTntSpeedButton;
    OpenDialog: TTntOpenDialog;
    MAutoAspect: TTntMenuItem;
    MForce43: TTntMenuItem;
    MForce169: TTntMenuItem;
    MForceCinemascope: TTntMenuItem;
    OuterPanel: TTntPanel;
    Logo: TTntImage;
    InnerPanel: TTntPanel;
    LEscape: TTntLabel;
    BPrev: TTntSpeedButton;
    BNext: TTntSpeedButton;
    MPrev: TTntMenuItem;
    MNext: TTntMenuItem;
    MShowPlaylist: TTntMenuItem;
    N6: TTntMenuItem;
    BStop: TTntSpeedButton;
    BPlaylist: TTntSpeedButton;
    PStatus: TTntPanel;
    LTime: TTntLabel;
    Imagery: TImageList;
    SeekBar: TTntPanel;
    VolFrame: TTntPanel;
    VolSlider: TTntPanel;
    BMute: TTntSpeedButton;
    VolImage: TTntImage;
    N7: TTntMenuItem;
    MMute: TTntMenuItem;
    VolBoost: TTntPanel;
    BCompact: TTntSpeedButton;
    MCompact: TTntMenuItem;
    MPopup: TTntPopupMenu;
    MNoOSD: TTntMenuItem;
    MDefaultOSD: TTntMenuItem;
    MTimeOSD: TTntMenuItem;
    MFullOSD: TTntMenuItem;
    MStop: TTntMenuItem;
    LStatus: TTntLabel;
    MenuBar: TTntToolBar;
    MFile: TTntToolButton;
    MView: TTntToolButton;
    MSeek: TTntToolButton;
    MExtra: TTntToolButton;
    MHelp: TTntToolButton;
    MQuit: TTntMenuItem;
    N1: TTntMenuItem;
    MClose: TTntMenuItem;
    MOpenDrive: TTntMenuItem;
    MOpenURL: TTntMenuItem;
    MOpenFile: TTntMenuItem;
    OMHelp: TTntMenuItem;
    OMExtra: TTntMenuItem;
    OMSeek: TTntMenuItem;
    OMView: TTntMenuItem;
    OMFile: TTntMenuItem;
    MShowOutput: TTntMenuItem;
    MStreamInfo: TTntMenuItem;
    N4: TTntMenuItem;
    MLanguage: TTntMenuItem;
    MOptions: TTntMenuItem;
    N5: TTntMenuItem;
    MDeinterlace: TTntMenuItem;
    MAspect: TTntMenuItem;
    MSubtitle: TTntMenuItem;
    MAudio: TTntMenuItem;
    MAbout: TTntMenuItem;
    MKeyHelp: TTntMenuItem;
    MAdaptiveDeint: TTntMenuItem;
    MSimpleDeint: TTntMenuItem;
    MNoDeint: TTntMenuItem;
    MPQuit: TTntMenuItem;
    N9: TTntMenuItem;
    OSDMenu: TTntMenuItem;
    MPOnTop: TTntMenuItem;
    MPCompact: TTntMenuItem;
    MPFullscreenControls: TTntMenuItem;
    MPFullscreen: TTntMenuItem;
    N8: TTntMenuItem;
    MPNext: TTntMenuItem;
    MPPrev: TTntMenuItem;
    N10: TTntMenuItem;
    MPStop: TTntMenuItem;
    MPPause: TTntMenuItem;
    MPPlay: TTntMenuItem;
    AppEvent: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BPlayClick(Sender: TObject);
    procedure BPauseClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure SeekBarSliderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SeekBarSliderMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SeekBarSliderMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure SeekBarFrameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SimulateKey(Sender: TObject);
    procedure MSizeClick(Sender: TObject);
    procedure MShowOutputClick(Sender: TObject);
    procedure MOSDClick(Sender: TObject);
    procedure MCloseClick(Sender: TObject);
    procedure MAudioClick(Sender: TObject);
    procedure MSubtitleClick(Sender: TObject);
    procedure UpdateMenus(Sender: TObject);
    procedure MDeinterlaceClick(Sender: TObject);
    procedure MOpenFileClick(Sender: TObject);
    procedure MOpenURLClick(Sender: TObject);
    procedure MOpenDriveClick(Sender: TObject);
    procedure MKeyHelpClick(Sender: TObject);
    procedure MAboutClick(Sender: TObject);
    procedure MLanguageClick(Sender: TObject);
    procedure MAspectClick(Sender: TObject);
    procedure MOptionsClick(Sender: TObject);
    procedure MPauseClick(Sender: TObject);
    procedure BPrevNextClick(Sender: TObject);
    procedure MShowPlaylistClick(Sender: TObject);
    procedure BStopClick(Sender: TObject);
    procedure SeekBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VolSliderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VolSliderMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure VolSliderMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BMuteClick(Sender: TObject);
    procedure MStreamInfoClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure DisplayMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DisplayDblClick(Sender: TObject);
    procedure MPopupPopup(Sender: TObject);
    procedure OuterPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ControlPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MPFullscreenControlsClick(Sender: TObject);
    procedure LStatusClick(Sender: TObject);
    procedure VolBoostClick(Sender: TObject);
    procedure TntFormActivate(Sender: TObject);
    procedure TntFormClose(Sender: TObject; var Action: TCloseAction);
    procedure AppEventMessage(var Msg: tagMSG;
      var Handled: Boolean);
    procedure AppEventMinimize(Sender: TObject);
  private
    { Private declarations }
    FirstShow:boolean;
    Seeking:boolean;
    SeekMouseX,SeekBaseX:integer;
    ControlledResize:boolean;
    FS_PX,FS_PY,FS_SX,FS_SY:integer; FS_WasTopmost:boolean;
    FirstParameter:integer;
    ScreenSaverActive:Cardinal;
    FullscreenControls:boolean;
    DisableFullscreenControlsAt:Cardinal;
    ShowLogoAt:Cardinal;
    EnablePositionQueries:boolean;
    FirstActivate:boolean;
    TrayIcon:TTrayIcon;
    procedure OpenDroppedFile(Sender: TObject; var Done: Boolean);
    procedure FormDropFiles(var msg:TMessage); message WM_DROPFILES;
    procedure Init_MOpenDrive;
    procedure Init_MLanguage;
    procedure FormGetMinMaxInfo(var msg:TMessage); message WM_GETMINMAXINFO;
    procedure FormMove(var msg:TMessage); message WM_MOVE;
    procedure FormWantSpecialKey(var msg:TCMWantSpecialKey); message CM_WANTSPECIALKEY;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure Init_TrayIcon;
    procedure TrayIconClick(Sender: TObject);
  public
    { Public declarations }
    AllowOpen:boolean;
    WantCompact:boolean;
    WantFullscreen:boolean;
    WantLoop:boolean;
    AutoQuit:boolean;
    Fullscreen:boolean;
    Compact:boolean;
    procedure QueryPosition;
    procedure FixSize;
    procedure SetupStart;
    procedure SetupPlay;
    procedure SetupStop(Explicit:boolean);
    procedure UpdateSeekBar;
    procedure Unpaused;
    procedure VideoSizeChanged;
    procedure DoOpen(const URL:string);
    procedure ToggleAlwaysOnTop;
    procedure SetFullscreen(Mode:boolean);
    procedure SetCompact(Mode:boolean);
    procedure NextAudio;
    procedure NextFile(Direction:integer; ExitState:TPlaybackState);
    procedure OpenSingleItem(const URL:string);
    procedure UpdateStatus;
    procedure UpdateTime;
    procedure UpdateCaption;
    procedure SetVolumeRel(Increment:integer);
    procedure UpdateDockedWindows;
    procedure Localize;
    procedure SetFullscreenControls(Mode:boolean);
    procedure SetMouseVisible(Mode:boolean);
  end;

var
  MainForm: TMainForm;

implementation
uses Locale, Core, Config, Log, URL, Help, About, Options, Info, LocaleData;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
  function CheckOption(OPTN:string):boolean; begin
    OPTN:=LowerCase(OPTN); Result:=False;
    if OPTN='-fs' then begin WantFullscreen:=True; Result:=True; end;
    if OPTN='-topmost' then begin SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE OR SWP_NOSIZE); Result:=True; end;
    if OPTN='-compact' then begin WantCompact:=True; Result:=True; end;
    if OPTN='-noopen' then begin AllowOpen:=False; Result:=True; end;
    if OPTN='-autoquit' then begin AutoQuit:=True; Result:=True; end;
    if OPTN='-loop' then begin WantLoop:=True; Result:=True; end;
    if OPTN='-enqueue' then Result:=True;
    if OPTN='-multiple' then Result:=True;
  end;
begin
  //AllocConsole;
  randomize();
{$IFDEF VER150}
  // some fixes for Delphi>=7 VCLs
  OuterPanel.ParentBackground:=False;
  InnerPanel.ParentBackground:=False;
  PStatus.ParentBackground:=False;
  SeekBar.ParentBackground:=False;
{$ENDIF}
  FirstActivate:=True;
  AllowOpen:=True;
  OuterPanel.DoubleBuffered:=True;
  EnablePositionQueries:=false;
  FirstShow:=true;
  Seeking:=false;
  WantFullscreen:=false;
  WantLoop:=false;
  WantCompact:=false;
  AutoQuit:=false;
  Core.Init;
  InitLocaleSystem;
  Config.Load(HomeDir+'autorun.inf');
  Config.Load(HomeDir+DefaultFileName);
  Init_MLanguage;
  with Logo do ControlStyle:=ControlStyle+[csOpaque];
  with InnerPanel do ControlStyle:=ControlStyle+[csOpaque];
  FirstParameter:=1;
  while CheckOption(ParamStr(FirstParameter)) do inc(FirstParameter);
  if not AllowOpen then begin
    OMFile.Remove(MOpenFile);
    OMFile.Remove(MOpenURL);
    OMFile.Remove(MOpenDrive);
  end;
  Init_MOpenDrive;
  Init_TrayIcon;
  Fullscreen:=false; Compact:=False;
  FullscreenControls:=false;
  ControlledResize:=true;
  ShowLogoAt:=0;
  if WantCompact then SetCompact(True);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Core.ForceStop;
end;

procedure TMainForm.DoOpen(const URL:string);
begin
  Core.ForceStop;
  Sleep(50); // wait for the processing threads to finish
  Application.ProcessMessages;  // let the VCL process the finish messages
  Core.MediaURL:=MakeURL(URL,Core.DisplayURL);
  UpdateCaption;
  Core.FirstOpen:=true;
  Core.Start;
end;

procedure TMainForm.BPlayClick(Sender: TObject);
begin
  BPlay.Down:=Core.Running;
  if Core.Running AND BPause.Down then begin
    SendCommand('pause');
    Unpaused;
  end else if not Core.Running then
    NextFile(0,psPlaying);
end;

procedure TMainForm.BPauseClick(Sender: TObject);
begin
  if not Core.Running then begin
    BPause.Down:=false; exit;
  end;
  BPause.Down:=True;
  EnablePositionQueries:=False;
  if Core.Status=sPaused then begin
    SendCommand('frame_step');
  end else begin
    SendCommand('pause');
    Core.Status:=sPaused;
    UpdateStatus;
  end;
end;


procedure TMainForm.SetVolumeRel(Increment:integer);
begin
  if (Core.Volume>100) OR ((Core.Volume=100) AND (Increment>0))
    then Increment:=Increment*10 DIV 3;  // bigger volume change steps if >100%
  inc(Core.Volume, Increment);
  if Core.Volume<0 then Core.Volume:=0;
  if (Core.Volume>100) AND not(Core.SoftVol) then Core.Volume:=100;
  if Core.Volume>9999 then Core.Volume:=9999;
  Core.SendVolumeChangeCommand(Core.Volume);
  Unpaused;
  if Core.Volume>100 then begin
    VolBoost.Visible:=True;
    VolBoost.Caption:=IntToStr(Core.Volume)+'%';
  end else begin
    VolBoost.Visible:=False;
    VolSlider.Left:=Core.Volume*(VolFrame.ClientWidth-VolSlider.Width) DIV 100;
  end;
end;


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  procedure HandleCommand(const Command:string); begin
    Core.SendCommand(Command);
    Unpaused;
  end;
  procedure HandleSeekCommand(const Command:string); begin
    HandleCommand(Command);
    QueryPosition;
  end;
begin
  if Key=VK_ESCAPE then begin
    if Fullscreen then Key:=Ord('F')
    else if Compact then Key:=Ord('C');
  end;
if ssCtrl in Shift then begin
  case Key of
    Ord('0'):   HandleCommand('speed_set 1.0');
    VK_DIVIDE:  HandleCommand('speed_mult 0.9090909');
    VK_MULTIPLY:HandleCommand('speed_mult 1.1');
    Ord('O'):   MOpenFileClick(nil);
    Ord('L'):   MOpenURLClick(nil);
    Ord('W'):   MCloseClick(nil);
  end;
end else if ssAlt in Shift then begin
  case Key of
    Ord('0'):   MSizeAny.Checked:=True;
    Ord('1'):   MSizeClick(MSize50);
    Ord('2'):   MSizeClick(MSize100);
    Ord('3'):   MSizeClick(MSize200);
    Ord('4'):   MFile.CheckMenuDropdown;
    Ord('5'):   MView.CheckMenuDropdown;
    Ord('6'):   MSeek.CheckMenuDropdown;
    Ord('7'):   MExtra.CheckMenuDropdown;
    Ord('8'):   MHelp.CheckMenuDropdown;
    VK_F4:      Close;
    VK_RETURN:  SetFullscreen(not(Fullscreen));
  end;
end else begin
  case Key of
    VK_RIGHT:   HandleSeekCommand('seek +10');
    VK_LEFT:    HandleSeekCommand('seek -10');
    VK_UP:      HandleSeekCommand('seek +60');
    VK_DOWN:    HandleSeekCommand('seek -60');
    VK_PRIOR:   HandleSeekCommand('seek +600');
    VK_NEXT:    HandleSeekCommand('seek -600');
    VK_SUBTRACT:HandleCommand('audio_delay 0.100');
    VK_ADD:     HandleCommand('audio_delay -0.100');
    Ord('M'):   BMuteClick(nil);
    Ord('9'):   SetVolumeRel(-3);
    Ord('0'):   SetVolumeRel(+3);
    VK_DIVIDE:  SetVolumeRel(-3);
    VK_MULTIPLY:SetVolumeRel(+3);
    Ord('O'):   begin SetOSDLevel(-1); Unpaused; end;
    Ord('1'):   HandleCommand('contrast -1');
    Ord('2'):   HandleCommand('contrast +1');
    Ord('3'):   HandleCommand('brightness -1');
    Ord('4'):   HandleCommand('brightness +1');
    Ord('5'):   HandleCommand('hue -1');
    Ord('6'):   HandleCommand('hue +1');
    Ord('7'):   HandleCommand('saturation -1');
    Ord('8'):   HandleCommand('saturation +1');
    Ord('D'):   HandleCommand('frame_drop');
    Ord('F'):   SetFullscreen(not(Fullscreen));
    Ord('C'):   SetCompact(not(Compact));
    Ord('T'):   ToggleAlwaysOnTop;
    Ord('S'):   HandleCommand('screenshot');
    Ord('L'):   MShowPlaylistClick(nil);
    191:        NextAudio;
    Ord('Q'):   Close;
    VK_RETURN:  BPlayClick(nil);
    Ord('P'),VK_SPACE:if BPause.Down then BPlayClick(nil) else MPauseClick(nil);   
    VK_TAB:     MPFullscreenControlsClick(nil);
    VK_MEDIA_PLAY_PAUSE:if Core.Running then MPauseClick(nil) else BPlayClick(nil);
    VK_MEDIA_STOP:      if BStop.Enabled then BStopClick(nil);
    VK_MEDIA_PREV_TRACK:if BPrev.Enabled then BPrevNextClick(BPrev);
    VK_MEDIA_NEXT_TRACK:if BNext.Enabled then BPrevNextClick(BNext);
  end;
end;
  Key:=0;
end;

procedure TMainForm.UpdateTimerTimer(Sender: TObject);
var Now:Cardinal;
begin
  Now:=GetTickCount();
  if EnablePositionQueries then QueryPosition;
  if FullscreenControls AND (Now>=DisableFullscreenControlsAt) then
    SetFullscreenControls(False);
  if Core.Running then begin
    if HaveVideo then SetThreadExecutionState(ES_DISPLAY_REQUIRED)
                 else SetThreadExecutionState(ES_SYSTEM_REQUIRED);
  end else if not(Core.Running) AND not(Logo.Visible) AND (Now>ShowLogoAt) then begin
    Logo.Visible:=True;
    LEscape.Visible:=Fullscreen;
    OuterPanel.Color:=clWhite;
  end;
end;

procedure TMainForm.QueryPosition;
begin
  Core.SendCommand('get_percent_pos'); Unpaused;
end;

procedure TMainForm.FixSize;
var SX,SY,NX,NY:integer;
begin
  if not InnerPanel.Visible then exit;
  if (NativeHeight=0) OR (NativeWidth=0) then begin
    InnerPanel.Align:=alClient;
    exit;
  end else
    InnerPanel.Align:=alNone;
  SX:=OuterPanel.ClientWidth;
  SY:=OuterPanel.ClientHeight;
  NY:=SY; NX:=NativeWidth*SY DIV NativeHeight;
  if NX>SX then begin NX:=SX; NY:=NativeHeight*SX DIV NativeWidth; end;
  with InnerPanel do begin
    Left:=(SX-NX) DIV 2;
    Top:=(SY-NY) DIV 2;
    Width:=NX;
    Height:=NY;
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
var CX,CY:integer;
begin
  if SeekBarSlider.Visible then UpdateSeekBar;
  FixSize;
  CX:=OuterPanel.ClientWidth;
  CY:=OuterPanel.ClientHeight;
  Logo.Left:=(CX-Logo.Width) DIV 2;
  Logo.Top:=(CY-Logo.Height) DIV 2;
  LEscape.Left:=(CX-LEscape.Width) DIV 2;
  LEscape.Top:=Max(Logo.Top+Logo.Height,CY*3 DIV 4);
  UpdateDockedWindows;
  if ControlledResize then
    ControlledResize:=false
  else if not MSizeAny.Checked then
    MSizeAny.Checked:=true;
end;

procedure TMainForm.SetupStart;
var PLI:integer;
begin
  BPlay.Enabled:=true;
  BPlay.Down:=true;
  BStop.Enabled:=true;
  SeekBarSlider.Visible:=true;
  SeekBarSlider.Left:=0;
  EnablePositionQueries:=true;
  BPause.Enabled:=true;
  BPause.Down:=false;
  BStreamInfo.Enabled:=true;
  PLI:=Playlist.GetCurrent;
  BPrev.Enabled:=(PLI>0) OR Playlist.Shuffle;
  BNext.Enabled:=(PLI+1<Playlist.Count) OR Playlist.Shuffle;
end;

procedure TMainForm.SetupPlay;
begin
  InnerPanel.Visible:=HaveVideo;
  Logo.Visible:=not(HaveVideo);
  if Logo.Visible then OuterPanel.Color:=clWhite else OuterPanel.Color:=clBlack;
  LEscape.Visible:=not(HaveVideo) AND Fullscreen;
  Seeking:=false;
  if HaveVideo then FixSize;
  BMute.Enabled:=HaveAudio;
  BPause.Enabled:=true;
  UpdateTime;
  InfoForm.UpdateInfo;
end;

procedure TMainForm.SetupStop(Explicit:boolean);
var PLI:integer;
begin
  BPlay.Down:=false;
  BPlay.Enabled:=(Playlist.Count>0);
  BStop.Enabled:=false;
  SeekBarSlider.Visible:=false;
  EnablePositionQueries:=false;
  InnerPanel.Visible:=false;
  BPause.Enabled:=false;
  BPause.Down:=false;
  BStreamInfo.Enabled:=false;
  if Explicit then ShowLogoAt:=GetTickCount()+1500;
  //LEscape.Visible:=Fullscreen;
  PLI:=Playlist.GetCurrent;
  BPrev.Enabled:=(Status=sError) AND ((PLI>0) OR Playlist.Shuffle);
  BNext.Enabled:=(Status=sError) AND ((PLI+1<Playlist.Count) OR Playlist.Shuffle);
end;

procedure TMainForm.FormShow(Sender: TObject);
var i:integer; FileName:string;
begin
  UpdateDockedWindows;
  if FirstShow then begin
    FirstShow:=false;
    if not ActivateLocale(DefaultLocale) then ActivateLocale('auto');
    Application.ProcessMessages;
    if ParamStr(FirstParameter)<>'' then begin
      Playlist.Clear();
      for i:=FirstParameter to ParamCount do begin
        FileName:=ToLongPath(ParamStr(i));
        Playlist.Add(FileName);
      end;  
      Application.OnIdle:=OpenDroppedFile;
    end else if AutoPlay then begin
      Playlist.Add('.');
      if Playlist.Count>0 then
        Application.OnIdle:=OpenDroppedFile;
    end;
  end;
  if AllowOpen then DragAcceptFiles(Handle,true);
end;

procedure TMainForm.FormHide(Sender: TObject);
begin
  DragAcceptFiles(Handle,false);
end;

procedure TMainForm.FormDropFiles(var msg:TMessage);
var hDrop:THandle;
    i,DropCount:integer;
    fnbuf:array[0..1024]of char;
begin
  hDrop:=msg.wParam;
  DropCount:=DragQueryFile(hDrop,cardinal(-1),nil,0);
  Playlist.Clear;
  for i:=0 to DropCount-1 do begin
    DragQueryFile(hDrop,i,@fnbuf[0],1024);
    Playlist.Add(fnbuf);
  end;
  DragFinish(hDrop);
  Application.OnIdle:=OpenDroppedFile;
  msg.Result:=0;
end;

procedure TMainForm.OpenDroppedFile(Sender: TObject; var Done: Boolean);
begin
  Done:=true;
  Application.OnIdle:=nil;
  NextFile(0,psPlaying);
end;

procedure TMainForm.UpdateSeekBar;
begin
  if Seeking then exit;
  SeekBarSlider.Left:=(SeekBarFrame.ClientWidth-SeekBarSlider.Width)*PercentPos DIV 100;
end;

procedure TMainForm.SeekBarSliderMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button<>mbLeft then exit;
  Seeking:=true;
  SeekBarSlider.BevelInner:=bvLowered;
  SeekMouseX:=X; SeekBaseX:=SeekBarSlider.Left;
end;

procedure TMainForm.SeekBarSliderMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var MaxPos:integer; WasPaused:Boolean;
begin
  if Button<>mbLeft then exit;
  WasPaused:=(Core.Status=sPaused);
  Seeking:=false;
  SeekBarSlider.BevelInner:=bvRaised;
  MaxPos:=SeekBarFrame.ClientWidth-SeekBarSlider.Width;
  SendCommand('seek '+IntToStr((SeekBarSlider.Left*100+(MaxPos SHR 1)) DIV MaxPos)+' 1');
  QueryPosition;
  Unpaused;
  if WasPaused then BPause.OnClick(Sender);
end;

procedure TMainForm.SeekBarSliderMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var NewX,MaxX:integer;
begin
  if not(ssLeft in Shift) OR not(Seeking) then exit;
  NewX:=X-SeekMouseX+SeekBarSlider.Left;
  MaxX:=SeekBarFrame.ClientWidth-SeekBarSlider.Width;
  if NewX<0 then NewX:=0;
  if NewX>MaxX then NewX:=MaxX;
  SeekBarSlider.Left:=NewX;
end;

procedure TMainForm.SeekBarFrameMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var MaxPos:integer;
begin
  if not SeekBarSlider.Visible then exit;
  dec(X,SeekBarSlider.Width DIV 2);
  MaxPos:=SeekBarFrame.ClientWidth-SeekBarSlider.Width;
  SendCommand('seek '+IntToStr((X*100+(MaxPos SHR 1)) DIV MaxPos)+' 1');
  QueryPosition;
  Unpaused;
end;

procedure TMainForm.SeekBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var P:TPoint;
begin
  P:=SeekBarFrame.ScreenToClient(SeekBar.ClientToScreen(Point(X,Y)));
  SeekBarFrameMouseDown(Sender,Button,Shift,P.X,P.Y);
end;

procedure TMainForm.Unpaused;
begin
  BPause.Down:=false;
  if Core.Running then EnablePositionQueries:=true;
  if Core.Status=sPaused then begin Core.Status:=sPlaying; UpdateStatus; end;
end;

procedure TMainForm.SimulateKey(Sender: TObject);
var Key:word;
begin
  Key:=(Sender as TComponent).Tag;
  FormKeyDown(Sender,Key,[]);
end;

procedure TMainForm.VideoSizeChanged;
var SX,SY,PX,PY:integer;
begin
  if Core.Status = sStopped then Exit;
  if {MSizeAny.Checked OR} (NativeWidth=0) OR (NativeHeight=0) OR Fullscreen then begin
    FixSize;
    exit;
  end;
  SX:=NativeWidth; SY:=NativeHeight;
  if MSize50.Checked then begin SX:=SX DIV 2; SY:=SY DIV 2; end;
  if MSize200.Checked then begin SX:=SX*2; SY:=SY*2; end;
  SX:=Width-OuterPanel.ClientWidth+SX;
  SY:=Height-OuterPanel.ClientHeight+SY;
  PX:=Left; PY:=Top;
  ControlledResize:=true;
  InnerPanel.Visible:=true;
  SetBounds(PX,PY,SX,SY);
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;
  if WantFullscreen then begin
    SetFullscreen(True);
    WantFullscreen:=False;
  end;
end;

procedure TMainForm.MSizeClick(Sender: TObject);
begin
  if Fullscreen then exit;
  (Sender as TTntMenuItem).Checked:=True;
  if Core.Status<>sStopped then VideoSizeChanged;
  if Core.Status=sPaused then BPause.OnClick(Sender);
end;

procedure TMainForm.MShowOutputClick(Sender: TObject);
begin
  LogForm.Show;
end;

procedure TMainForm.MOSDClick(Sender: TObject);
begin
  with Sender as TTntMenuItem do
    SetOSDLevel(Tag);
  Unpaused;
end;

procedure TMainForm.ToggleAlwaysOnTop;
var IsTopmost:HWND;
begin
  if Fullscreen then begin
    FS_WasTopmost:=not(FS_WasTopmost);
    exit;
  end;
  if (GetWindowLong(Handle,GWL_EXSTYLE) AND WS_EX_TOPMOST)=0
    then IsTopmost:=HWND_TOPMOST
    else IsTopmost:=HWND_NOTOPMOST;
  SetWindowPos(Handle,IsTopmost,0,0,0,0,SWP_NOMOVE OR SWP_NOSIZE);
end;

procedure TMainForm.MCloseClick(Sender: TObject);
begin
  Stop;
  MediaURL:='';
  BPlay.Enabled:=false;
end;

procedure TMainForm.MAudioClick(Sender: TObject);
begin
  AudioID:=(Sender as TTntMenuItem).Tag;
  Core.Restart;
  (Sender as TTntMenuItem).Checked:=True;
end;

procedure TMainForm.MSubtitleClick(Sender: TObject);
begin
  SubID:=(Sender as TTntMenuItem).Tag;
  Core.Restart;
  (Sender as TTntMenuItem).Checked:=True;
end;

procedure TMainForm.UpdateMenus(Sender: TObject);
begin
  case Core.Deinterlace of
    0:MNoDeint.Checked:=true;
    1:MSimpleDeint.Checked:=true;
    2:MAdaptiveDeint.Checked:=true;
  end;
  case Core.Aspect of
    0:MAutoAspect.Checked:=true;
    1:MForce43.Checked:=true;
    2:MForce169.Checked:=true;
    3:MForceCinemascope.Checked:=true;
  end;
  MKeyHelp.Checked:=HelpForm.Visible;
  MPlay.Enabled:=BPlay.Enabled;
  MPause.Enabled:=BPause.Enabled;
  MStop.Enabled:=BStop.Enabled;
  MPrev.Enabled:=BPrev.Enabled;
  MNext.Enabled:=BNext.Enabled;
  MPlay.Checked:=BPlay.Down;
  MPause.Checked:=BPause.Down;
  MOnTop.Checked:=((GetWindowLong(Handle,GWL_EXSTYLE) AND WS_EX_TOPMOST)<>0);
  MMute.Checked:=BMute.Down;
end;

procedure TMainForm.MPopupPopup(Sender: TObject);
var i:integer;
begin
  MPPlay.Enabled:=BPlay.Enabled;
  MPPause.Enabled:=BPause.Enabled;
  MPStop.Enabled:=BStop.Enabled;
  MPPrev.Enabled:=BPrev.Enabled;
  MPNext.Enabled:=BNext.Enabled;
  MPPlay.Checked:=BPlay.Down;
  MPPause.Checked:=BPause.Down;
  MPFullscreen.Checked:=Fullscreen;
  MPFullscreenControls.Enabled:=Fullscreen;
  MPFullscreenControls.Checked:=FullscreenControls;
  MPCompact.Checked:=Compact;
  if Fullscreen then
    MPOnTop.Checked:=FS_WasTopmost
  else
    MPOnTop.Checked:=((GetWindowLong(Handle,GWL_EXSTYLE) AND WS_EX_TOPMOST)<>0);
  OSDMenu.Enabled:=Core.Running AND HaveVideo;
  for i:=0 to OSDMenu.Count-1 do
    if OSDMenu.Items[i].Tag=OSDLevel then begin
      OSDMenu.Items[i].Checked:=true;
      break;
    end;
end;

procedure TMainForm.MDeinterlaceClick(Sender: TObject);
begin
  Core.Deinterlace:=(Sender as TTntMenuItem).Tag;
  Core.Restart;
end;

procedure TMainForm.MAspectClick(Sender: TObject);
begin
  Core.Aspect:=(Sender as TTntMenuItem).Tag;
  Core.Restart;
end;

procedure TMainForm.MOpenFileClick(Sender: TObject);
begin
  with OpenDialog do begin
    Options:=Options-[ofAllowMultiSelect];
    if Execute then
      OpenSingleItem(FileName);
  end;
end;

procedure TMainForm.MOpenURLClick(Sender: TObject);
var s:string;
begin
  s:=Trim(Clipboard.AsText);
  if (Pos(^M,s)>0) OR (Pos(^J,s)>0) OR (Pos(^I,s)>0) OR
     ((Pos('//',s)=0) AND (Pos('\\',s)=0) AND (Pos(':',s)=0))
     then s:='';
  if InputQuery(_.OpenURL_Caption,_.OpenURL_Prompt,s)
    then OpenSingleItem(s);
end;

procedure TMainForm.Init_MOpenDrive;
var Mask:cardinal; Name:array[0..3]of char; Drive:char;
    Item:TTntMenuItem;
begin
  Name:='@:\';
  Mask:=GetLogicalDrives();
  for Drive:='A' to 'Z' do
    if (Mask AND (1 SHL (Ord(Drive)-65)))<>0 then begin
      Name[0]:=Drive;
      if GetDriveType(Name)=DRIVE_CDROM then begin
        Item:=TTntMenuItem.Create(MOpenDrive);
        with Item do begin
          Caption:=Drive+':';
          Tag:=Ord(Drive);
          OnClick:=MOpenDriveClick;
        end;
        MOpenDrive.Add(Item);
        MOpenDrive.Enabled:=true;
      end;
    end;
end;

procedure TMainForm.MOpenDriveClick(Sender: TObject);
begin
  OpenSingleItem(char((Sender as TTntMenuItem).Tag)+':'); 
end;

procedure TMainForm.MKeyHelpClick(Sender: TObject);
begin
  if HelpForm.Visible then HelpForm.Close else HelpForm.Show;
end;

procedure TMainForm.MAboutClick(Sender: TObject);
begin
  AboutForm.Show;  
end;

procedure TMainForm.Init_MLanguage;
var i:integer; Item:TTntMenuItem;
begin
  MLanguage.Clear;
  for i:=0 to High(Locales) do begin
    Item:=TTntMenuItem.Create(MLanguage);
    with Item do begin
      Caption:=LocaleNames[i];
      GroupIndex:=$70;
      RadioItem:=true;
      AutoCheck:=true;
      Tag:=i;
      OnClick:=MLanguageClick;
    end;
    MLanguage.Add(Item);
  end;
end;

procedure TMainForm.MLanguageClick(Sender: TObject);
begin
  ActivateLocale(Locales[(Sender as TTntMenuItem).Tag].Name);
end;

procedure TMainForm.MOptionsClick(Sender: TObject);
begin
  OptionsForm.Show;
end;

procedure TMainForm.MPauseClick(Sender: TObject);
begin
  BPause.Down:=not(BPause.Down);
  BPauseClick(nil);
end;

procedure TMainForm.SetFullscreen(Mode:boolean);
var Pivot:TPoint;
    PX,PY,SX,SY:integer;
    InsertAfter:THandle;
begin
  WindowState:=wsNormal;
  Fullscreen:=Mode;
  FullscreenControls:=False;
  BFullscreen.Down:=Fullscreen;
  if Compact AND not(ControlledResize) then begin
    ControlledResize:=True;
    SetCompact(False);
  end;
  ControlledResize:=False;
  if Fullscreen then begin
    ScreenSnap:=False;
    FS_PX:=Left; FS_PY:=Top;
    FS_SX:=Width; FS_SY:=Height;
    FS_WasTopmost:=((GetWindowLong(Handle,GWL_EXSTYLE) AND WS_EX_TOPMOST)<>0);
    Pivot:=OuterPanel.ClientToScreen(Point(0,0));
    PX:=FS_PX-Pivot.X;
    PY:=FS_PY-Pivot.Y;
    SX:=Screen.Width +FS_SX-OuterPanel.ClientWidth;
    SY:=Screen.Height+FS_SY-OuterPanel.ClientHeight;
    ControlledResize:=true;
    SetWindowPos(Handle,HWND_TOPMOST,PX,PY,SX,SY,0);
    SetMouseVisible(false);
    SystemParametersInfo(SPI_GETSCREENSAVEACTIVE, 0, @ScreenSaverActive, 0);
    SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, 0, nil, 0);
    LEscape.Visible:=not(Core.Running) OR not(HaveVideo);
  end else begin
    ScreenSnap:=True;
    LEscape.Visible:=false;
    SetMouseVisible(true);
    ControlledResize:=true;
    if FS_WasTopmost then InsertAfter:=HWND_TOPMOST
                     else InsertAfter:=HWND_NOTOPMOST;
    SetWindowPos(Handle,InsertAfter,FS_PX,FS_PY,FS_SX,FS_SY,0);
    SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, ScreenSaverActive, nil, 0);
  end;
  if Core.Status = sPaused then BPause.OnClick(self);
end;

procedure TMainForm.SetCompact(Mode:boolean);
var MenuAndCaption:integer;
begin
  WindowState:=wsNormal;
  Compact:=Mode;
  BCompact.Down:=Compact;
  if Fullscreen AND not(ControlledResize) then begin
    ControlledResize:=True;
    SetFullscreen(False);
  end;
  ControlledResize:=False;
  MenuAndCaption:=MenuBar.Height+GetSystemMetrics(SM_CYCAPTION);
  if Compact then begin
    ControlPanel.Visible:=False;
    MenuBar.Visible:=False;
    SetWindowLong(Handle,GWL_STYLE,
      (DWORD(GetWindowLong(Handle,GWL_STYLE)) OR WS_POPUP) AND (NOT WS_DLGFRAME));
    ControlledResize:=true;
    SetBounds(Left,Top+MenuAndCaption,Width,Height-MenuAndCaption-ControlPanel.Height);
  end else begin
    SetWindowLong(Handle,GWL_STYLE,
      (DWORD(GetWindowLong(Handle,GWL_STYLE)) OR WS_DLGFRAME) AND (NOT WS_POPUP));
    MenuBar.Visible:=True;
    ControlPanel.Visible:=True;
    ControlledResize:=true;
    SetBounds(Left,Top-MenuAndCaption,Width,Height+MenuAndCaption+ControlPanel.Height);
  end;
end;

procedure TMainForm.FormGetMinMaxInfo(var msg:TMessage);
begin
  if Fullscreen then
    with PMinMaxInfo(msg.lParam)^.ptMaxTrackSize do begin
      X:=4095;
      Y:=4095;
    end;
  msg.Result:=0;
end;

procedure TMainForm.NextAudio;
var i,AudioIndex:integer;
begin
  if MAudio.Count<2 then exit;
  AudioIndex:=-1;
  for i:=0 to MAudio.Count-1 do
    if MAudio.Items[i].Checked then begin
      AudioIndex:=(i+1) MOD MAudio.Count;
    end;
  if AudioIndex<0 then exit;
  with MAudio.Items[AudioIndex] do begin
    Checked:=True;
    Core.AudioID:=Tag;
  end;
  Core.SendCommand('switch_audio');
  Unpaused;
end;

procedure TMainForm.NextFile(Direction:integer; ExitState:TPlaybackState);
var Index:integer;
begin
  Core.ForceStop;
  Index:=Playlist.GetNext(ExitState,Direction);
  if Index<0 then begin
    if AutoQuit then Close;
    exit;
  end;
  Playlist.NowPlaying(Index);
  DoOpen(Playlist[Index].FullURL);
end;

procedure TMainForm.BPrevNextClick(Sender: TObject);
begin
  NextFile((Sender as TComponent).Tag,psSkipped);
end;

procedure TMainForm.MShowPlaylistClick(Sender: TObject);
begin
  if PlaylistForm.Visible
    then PlaylistForm.Hide
    else PlaylistForm.Show;
end;

procedure TMainForm.MStreamInfoClick(Sender: TObject);
begin
  if MStreamInfo.Checked
    then InfoForm.Hide
    else InfoForm.Show;
end;

procedure TMainForm.OpenSingleItem(const URL:string);
begin
  Playlist.Clear;
  Playlist.Add(URL);
  NextFile(0,psPlaying);  
end;

procedure TMainForm.BStopClick(Sender: TObject);
begin
  Core.Stop;
  Playlist.GetNext(psSkipped,0);
end;

procedure TMainForm.UpdateStatus;
begin
  case Core.Status of
    sNone:    LStatus.Caption:='';
    sOpening: LStatus.Caption:=_.Status_Opening;
    sClosing: LStatus.Caption:=_.Status_Closing;
    sPlaying: LStatus.Caption:=_.Status_Playing;
    sPaused:  LStatus.Caption:=_.Status_Paused;
    sStopped: LStatus.Caption:=_.Status_Stopped;
    sError:   LStatus.Caption:=_.Status_Error;
  end;
  if Core.Status=sError
    then LStatus.Cursor:=crHandPoint
    else LStatus.Cursor:=crDefault;
  if (Core.Status<>sPlaying) AND (Core.Status<>sPaused) then
    LTime.Caption:='';
end;

procedure TMainForm.UpdateTime;
begin
  if (Core.Status<>sPlaying) AND (Core.Status<>sPaused)
    then LTime.Caption:=''
    else LTime.Caption:=SecondsToTime(Core.SecondPos)+' / '+Core.Duration;
end;

procedure TMainForm.UpdateCaption;
begin
  if length(Core.DisplayURL)<>0
    then Caption:=Core.DisplayURL+' - '+_.Title
    else Caption:=_.Title;
end;


procedure TMainForm.VolSliderMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button<>mbLeft then exit;
  VolSlider.BevelInner:=bvLowered;
  SeekMouseX:=X; SeekBaseX:=VolSlider.Left;
end;

procedure TMainForm.VolSliderMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var NewX,MaxX,NewVolume:integer;
begin
  if not(ssLeft in Shift) then exit;
  NewX:=X-SeekMouseX+VolSlider.Left;
  MaxX:=VolFrame.ClientWidth-VolSlider.Width;
  if NewX<0 then NewX:=0;
  if NewX>MaxX then NewX:=MaxX;
  VolSlider.Left:=NewX;
  NewVolume:=(NewX*100+(MaxX SHR 1)) DIV MaxX;
  if NewVolume=Core.Volume then exit;
  Core.Volume:=NewVolume;
  Core.SendVolumeChangeCommand(NewVolume);
  Unpaused;
end;

procedure TMainForm.VolSliderMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  VolSlider.BevelInner:=bvRaised;
end;

procedure TMainForm.BMuteClick(Sender: TObject);
begin
  if Sender=BMute then
    Core.Mute:=BMute.Down
  else begin
    Mute:=not(Mute);
    BMute.Down:=Core.Mute;
  end;
  if not BMute.Down then
    Core.SendVolumeChangeCommand(Volume)
  else
    Core.SendCommand('mute');
  Unpaused;
end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  SetVolumeRel(WheelDelta DIV 40);
end;

procedure TMainForm.UpdateDockedWindows;
begin
  if plist.Docked then begin
    PlaylistForm.ControlledMove:=True;
    PlaylistForm.Left:=Left;
    PlaylistForm.ControlledMove:=True;
    PlaylistForm.Top:=Top+Height;
  end;
  if Info.Docked then begin
    InfoForm.ControlledMove:=True;
    InfoForm.Left:=Left+Width;
    InfoForm.ControlledMove:=True;
    InfoForm.Top:=Top;
  end;
end;

procedure TMainForm.FormMove(var msg:TMessage);
begin
  msg.Result:=0;
  SetCursor(Screen.Cursors[crSizeAll]);
  UpdateDockedWindows;
end;

procedure TMainForm.DisplayMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Fullscreen OR (Button<>mbLeft) then exit;
  SetCursor(Screen.Cursors[crSizeAll]);
  // I love these undocumented Windows messages ... [http://keyj.s2000.ws/?p=18]
  ReleaseCapture;
  SendMessage(Handle, WM_SYSCOMMAND, SC_MOVE+2, 0);
end;

procedure TMainForm.DisplayDblClick(Sender: TObject);
begin
  SetFullscreen(not(Fullscreen));
end;

procedure TMainForm.Localize;
begin
  MPPlay.Caption:=MPlay.Caption;
  MPPause.Caption:=MPause.Caption;
  MPStop.Caption:=MStop.Caption;
  MPPrev.Caption:=MPrev.Caption;
  MPNext.Caption:=MNext.Caption;
  MPFullscreen.Caption:=MFullscreen.Caption;
  MPCompact.Caption:=MCompact.Caption;
  MPOnTop.Caption:=MOnTop.Caption;
  MPQuit.Caption:=MQuit.Caption;  
end;

procedure TMainForm.OuterPanelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if Fullscreen AND not(FullscreenControls) AND (Y>=OuterPanel.ClientHeight-8)
    then SetFullscreenControls(True);
end;

procedure TMainForm.SetFullscreenControls(Mode:boolean);
begin
  if not Fullscreen then exit;
  FullscreenControls:=Mode;
  if FullscreenControls then begin
    SetMouseVisible(True);
    Height:=Height-ControlPanel.Height+PStatus.Height;
    FullscreenControls:=True;
    DisableFullscreenControlsAt:=GetTickCount()+3000;
  end else begin
    Height:=Height+ControlPanel.Height-PStatus.Height;
    FullscreenControls:=False;
    SetMouseVisible(False);
  end;
end;

procedure TMainForm.SetMouseVisible(Mode:boolean);
begin
  if Mode then begin
    Logo.Cursor:=crDefault;
    InnerPanel.Cursor:=crDefault;
    OuterPanel.Cursor:=crDefault;
    //ShowCursor(true);
  end else begin
    OuterPanel.Cursor:=-1;
    InnerPanel.Cursor:=-1;
    Logo.Cursor:=-1;
    //ShowCursor(false);
  end;
end;

procedure TMainForm.ControlPanelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FullscreenControls then DisableFullscreenControlsAt:=GetTickCount()+3000;
end;

procedure TMainForm.FormWantSpecialKey(var msg:TCMWantSpecialKey);
begin
  msg.Result:=1;
end;

procedure TMainForm.MPFullscreenControlsClick(Sender: TObject);
begin
  if not Fullscreen then exit;
  SetFullscreenControls(not(FullscreenControls));
  if FullscreenControls then
    DisableFullscreenControlsAt:=$FFFFFFFF;
end;

procedure TMainForm.LStatusClick(Sender: TObject);
begin
  if Core.Status=sError then begin
    LogForm.Show;
    LogForm.TheLog.ScrollBy(0,32767);
    LogForm.SetFocus;
  end;
end;

procedure TMainForm.VolBoostClick(Sender: TObject);
begin
  if Core.Volume>100 then begin
    Core.SendVolumeChangeCommand(100);
    Core.Volume:=100;
    Unpaused;
    VolBoost.Caption:='100%';
  end;
end;

procedure TMainForm.TntFormActivate(Sender: TObject);
begin
  if not FirstActivate then Exit;
  FirstActivate:=False;
end;

procedure TMainForm.TntFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  CloseHandle(HMutex);
end;

procedure TMainForm.WMCopyData(var Msg: TWMCopyData);
var media:String;
begin
  if TrayIcon.Visible then TrayIcon.OnClick(self);
  SetForegroundWindow(Application.Handle);
  media := ToLongPath(PAnsiChar(Msg.CopyDataStruct.lpData));
  case Msg.CopyDataStruct.dwData of
    42: begin
      if not PlaylistForm.Visible then PlaylistForm.Show;
      PlaylistForm.BringToFront;
      if media <> '' then Playlist.Add(media);
    end;
    43: begin
      MainForm.BringToFront;
      if media <> '' then OpenSingleItem(media);
    end;
  end;
  Msg.Result := Integer(True);
end;

procedure TMainForm.AppEventMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  if (Msg.message = MsgHandshake) and (Msg.wParam = 1) then begin
    PostMessage(Msg.lParam,MsgHandshake,2,self.Handle);
    Handled:=True;
  end;
end;

procedure TMainForm.AppEventMinimize(Sender: TObject);
begin
  TrayIcon.Hint := MainForm.Caption;
  try
    TrayIcon.Show;
    ShowWindow(Application.Handle,SW_HIDE);
  except
  end;
end;

procedure TMainForm.Init_TrayIcon;
begin
  TrayIcon := TTrayIcon.Create(self);
  TrayIcon.Icon := self.Icon;
  TrayIcon.OnClick := TrayIconClick;
end;

procedure TMainForm.TrayIconClick(Sender: TObject);
begin
  ShowWindow(Application.Handle,SW_RESTORE);
  SetForegroundWindow(Application.Handle);
  TrayIcon.Hide;
end;

end.
