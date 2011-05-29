///////////////////////////////////////////////////////////////////////////////
// Make Instant Player
// Copyright (C) 2004-2009 LoRd_MuldeR <MuldeR2@GMX.de>
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

unit Main;

///////////////////////////////////////////////////////////////////////////////
interface
///////////////////////////////////////////////////////////////////////////////

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MuldeR_Toolz, JvComponentBase, JvComputerInfoEx,
  ShellAPI, ExtCtrls, JvDialogs, XPMan, JvProgressBar, jvGif,
  JvXPProgressBar, JvTimer, MuldeR_CheckFiles, AppEvnts, jpeg, Clipbrd,
  Menus, Registry, JclStrings, JvBaseDlg, JvJVCLAboutForm, ExtDlgs,
  ComCtrls, MuldeR_MD5, Processing, JvDataEmbedded, Unit_Win7Taskbar,
  ImgList, Unit_LinkTime;

const
  AppVers = '1.60';

///////////////////////////////////////////////////////////////////////////////
//{$DEFINE DEBUG_BUILD}
///////////////////////////////////////////////////////////////////////////////

type
  TOptions = record
    fs: Boolean;
    autoquit: Boolean;
    compact: Boolean;
    topmost: Boolean;
    loop: Boolean;
  end;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    JvComputerInfoEx1: TJvComputerInfoEx;
    Memo1: TMemo;
    Bevel1: TBevel;
    JvOpenDialog1: TJvOpenDialog;
    JvSaveDialog1: TJvSaveDialog;
    XPManifest1: TXPManifest;
    JvTimer1: TJvTimer;
    Button2: TButton;
    Button3: TButton;
    Label4: TLabel;
    ApplicationEvents1: TApplicationEvents;
    Image1: TImage;
    Bevel2: TBevel;
    Label5: TLabel;
    PopupMenu1: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    Bevel3: TBevel;
    CheckBox1: TCheckBox;
    Edit3: TEdit;
    Label6: TLabel;
    CheckBox3: TCheckBox;
    Label7: TLabel;
    JvJVCLAboutComponent1: TJvJVCLAboutComponent;
    Label8: TLabel;
    Label9: TLabel;
    Edit4: TEdit;
    Label10: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    Bevel4: TBevel;
    CheckBox2: TCheckBox;
    CheckBox4: TCheckBox;
    Label12: TLabel;
    Label13: TLabel;
    JvXPProgressBar1: TProgressBar;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    Bevel5: TBevel;
    Label3: TLabel;
    ComboBox1: TComboBox;
    Label11: TLabel;
    Edit6: TEdit;
    Label14: TLabel;
    OpenPictureDialog2: TOpenPictureDialog;
    ComboBox2: TComboBox;
    PopupMenu2: TPopupMenu;
    Reset1: TMenuItem;
    PopupMenu3: TPopupMenu;
    Reset2: TMenuItem;
    PopupMenu4: TPopupMenu;
    Reset3: TMenuItem;
    PopupMenu5: TPopupMenu;
    Reset4: TMenuItem;
    ImageList: TImageList;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Edit2Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Label4MouseEnter(Sender: TObject);
    procedure Label4MouseLeave(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure Label5Click(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Edit3Exit(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Edit4Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure Edit6Click(Sender: TObject);
    procedure ComboBox2Exit(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Reset1Click(Sender: TObject);
    procedure Reset2Click(Sender: TObject);
    procedure Reset3Click(Sender: TObject);
    procedure Reset4Click(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure Label13MouseEnter(Sender: TObject);
    procedure Label13MouseLeave(Sender: TObject);
  private
    ScriptFile:String;
    IniFile:String;
    WorkDir:String;
    Process:TProcessingThread;
    Preview:Boolean;
    Tested:Boolean;
    WM_TaskbarButtonCreated: UINT;
    procedure DisableButtons(x:Boolean);
    function CheckSplash(FileName:String):Boolean;
    function CheckIcon(FileName:String):Boolean;
    function FullPath(Filename:String):String;
    function CheckFile(Filename:String; Default:String; MustExist: Boolean):String;
    procedure ProcessTerminate(Sender: TObject);
    function MakePlayer(SourceFile: String; OutputFile:String; SplashFile:String; IconFile:String; HomeURL:String; Params:String; Opts:TOptions; Locale:String; LogFile: TMemo): Boolean;
    procedure MakePreview(SourceFile: String; Opts:TOptions; Params:String; Locale:String; LogFile: TMemo);
    function CheckURL(URL:String):String;
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

{$R *.dfm}

///////////////////////////////////////////////////////////////////////////////
// Form Create
///////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormCreate(Sender: TObject);
var
  Files:TCheckFiles;
  reg: TRegistry;
begin
  WorkDir := GetAppDirectory;
  WM_TaskbarButtonCreated := RegisterWindowMessage('TaskbarButtonCreated');
  Label13.Caption := Format('Version %s (Built %s)', [AppVers, Unit_LinkTime.GetImageLinkTimeStampAsString(false)]);

  Application.HintHidePause := -1;
  Process := nil;

  Application.DialogHandle;

  {$IF Defined(DEBUG_BUILD)}
  MsgBox('Warning: This is a Debug Build, do not release this!', 'DEBUG BUILD', MB_ICONWARNING or MB_TOPMOST);
  {$IFEND}

  Files := TCheckFiles.Create('MakeInstantPlayer');
  try
    Files.Add('system\mplayer\mplayer.exe','a3a1a9ba3b706ebc4d00053bba69c976');
    Files.Add('system\mplayer\mpui.exe','3a840ddb501dc5d77ba70533a4c9f5ed');
    Files.Add('system\mplayer\mplayer\config','767dab36522a1e837f5dd1db841796ea');
    Files.Add('system\mplayer\mplayer\input.conf','4d7aa2d2303b5a8d707fa04bd2715819');
    Files.Add('system\mplayer\mplayer\subfont.ttf','dc755b5508fe707d38660d033b1faa89');
    Files.Add('system\mplayer\fonts\fonts.conf','5a515f2f5a236fc76957b7a3857e436a');
    Files.Add('system\mplayer\fonts\fonts.dtd','9a099c7722190e00548c0d8375bdc24b');
    Files.Add('system\nsis\makensis.exe','201a7f9b37579480c0118c3020ba7b79');
    Files.Add('system\nsis\include\messages.nsh','ec5cd908090641a33ff73b9a3fff39f7');
    Files.Add('system\nsis\include\params.nsh','8705d921061036abdd75fee086e702e6');
    Files.Add('system\nsis\include\trimstr.nsh','ac0c3761847716bab7414c05abf55feb');
    Files.Add('system\nsis\plugins\banner.dll','4a90d392c9da5f0b90a75baf67c37e4c');
    Files.Add('system\nsis\plugins\newadvsplashu.dll','820888931d6e1ba0a64bb34975541cf5');
    Files.Add('system\nsis\plugins\nsExec.dll','08e9796ca20c5fc5076e3ac05fb5709a');
    Files.Add('system\nsis\stubs\bzip2','b2be8fa3f3f6dce1b7bd0e79579ee6ac');
    Files.Add('system\nsis\stubs\bzip2_solid','99e632fa844fc4bebbebdcc2c82d15fd');
    Files.Add('system\nsis\stubs\lzma','91ce58259e6010ec0ac82ed8d69cb131');
    Files.Add('system\nsis\stubs\lzma_solid','8ed0809908f44eb6d1e03d7cf46e08e0');
    Files.Add('system\nsis\stubs\uninst','4023b710d3b47d9101c27f5da22aa5ef');
    Files.Add('system\nsis\stubs\zlib','7ceb033067a3b505a5ffe16d249956f5');
    Files.Add('system\nsis\stubs\zlib_solid','3c9beb3c32394ef22cf77c8c384a81ad');
    Files.Add('system\upx\upx.exe','308f709a8f01371a6dd088a793e65a5f');
    Files.Add('system\images\splash.gif','1fc4e2d0ae9171ec312f819bb0dd47fb');
    Files.Add('system\images\movie.ico','636546371127d44afb347bf1c7f31be7');
    Files.Add('system\etc\sample.avi','207d58620468089e7f7fd65e65f27357');
    if not Files.Run then
    begin
      FatalAppExit(0, 'File integrity check failure. Emergency shutdown!');
      ExitProcess(DWORD(-1));
    end;
  finally
    Files.Free;
  end;

  Reset1.OnClick(Sender);
  Reset2.OnClick(Sender);
  Reset3.OnClick(Sender);
  Reset4.OnClick(Sender);

  reg := TRegistry.Create;

  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKeyReadOnly('SOFTWARE\MuldeR\MakeInstantPlayer\v' + AppVers + '\Settings.' + MD5Print(MD5String(AnsiUpperCase(Application.ExeName))));
    if reg.ValueExists('SourceFile') then
      Edit1.Text := CheckFile(Trim(reg.ReadString('SourceFile')), Edit1.Text, True);
    if reg.ValueExists('OutputFile') then
      Edit2.Text := CheckFile(Trim(reg.ReadString('OutputFile')), Edit2.Text, False);
    if reg.ValueExists('SplashFile') then
      Edit4.Text := CheckFile(Trim(reg.ReadString('SplashFile')), Edit4.Text, True);
    if reg.ValueExists('IconFile') then
      Edit6.Text := CheckFile(Trim(reg.ReadString('IconFile')), Edit6.Text, True);
    if reg.ValueExists('Homepage') then
      Edit3.Text := Trim(reg.ReadString('Homepage'));
    if reg.ValueExists('Fullscreen') then
      CheckBox1.Checked := reg.ReadBool('Fullscreen');
    if reg.ValueExists('AutoQuit') then
      CheckBox2.Checked := reg.ReadBool('AutoQuit');
    if reg.ValueExists('Codecs') then
      CheckBox3.Checked := reg.ReadBool('Codecs');
    if reg.ValueExists('Compact') then
      CheckBox4.Checked := reg.ReadBool('Compact');
    if reg.ValueExists('Topmost') then
      CheckBox5.Checked := reg.ReadBool('Topmost');
    if reg.ValueExists('Loop') then
      CheckBox6.Checked := reg.ReadBool('Loop');
    if reg.ValueExists('Params') then
      ComboBox2.Text := Trim(reg.ReadString('Params'));
    if reg.ValueExists('Locale') then
      ComboBox1.ItemIndex := reg.ReadInteger('Locale');
    reg.CloseKey;
  finally
    reg.Free;
  end;

  Edit3.OnExit(Sender);
  Tested := False;
end;

///////////////////////////////////////////////////////////////////////////////
// Form Close
///////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;

  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey('SOFTWARE\MuldeR\MakeInstantPlayer\v' + AppVers + '\Settings.' + MD5Print(MD5String(AnsiUpperCase(Application.ExeName))), true);
    reg.WriteString('SourceFile',Edit1.Text);
    reg.WriteString('OutputFile',Edit2.Text);
    reg.WriteString('SplashFile',Edit4.Text);
    reg.WriteString('IconFile',Edit6.Text);
    reg.WriteString('Homepage',Edit3.Text);
    reg.WriteBool('Fullscreen',CheckBox1.Checked);
    reg.WriteBool('Autoquit',CheckBox2.Checked);
    reg.WriteBool('Codecs',CheckBox3.Checked);
    reg.WriteBool('Compact',CheckBox4.Checked);
    reg.WriteBool('Topmost',CheckBox5.Checked);
    reg.WriteBool('Loop',CheckBox6.Checked);
    reg.WriteString('Params',ComboBox2.Text);
    reg.WriteInteger('Locale',ComboBox1.ItemIndex);
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Create Instant Player
//////////////////////////////////////////////////////////////////////////////

function TForm1.MakePlayer(SourceFile: String; OutputFile:String; SplashFile:String; IconFile:String; HomeURL:String; Params:String; Opts:TOptions; Locale:String; LogFile: TMemo): Boolean;
var
  Script: TStringList;
  Ini: TStringList;
  Options: String;
  CmdLine: String;
begin
  Result := False;

  Options := ' -noopen -multiple';
  if Opts.fs then Options := Options + ' -fs';
  if Opts.autoquit then Options := Options + ' -autoquit';
  if Opts.compact then Options := Options + ' -compact';
  if Opts.topmost then Options := Options + ' -topmost';
  if Opts.loop then Options := Options + ' -loop';

  Ini := TStringList.Create;

  Ini.Add('[MPUI]');
  Ini.Add('Locale=' + AnsiLowerCase(Locale));

  if Params <> '' then
  begin
    Ini.Add('Params=' + Params);
  end;

  IniFile := GetTempFile(JvComputerInfoEx1.Folders.Temp,'config','ini');
  Ini.SaveToFile(IniFile);
  Ini.Free;

  Script := TStringList.Create;

  Script.Add(';---------------------------------------------------------------------------');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('!define SourceFile "' + SourceFile + '"');
  Script.Add('!define OutputFile "' + OutputFile + '"');
  Script.Add('!define SplashFile "' + SplashFile + '"');
  Script.Add('!define IconFile "' + IconFile + '"');
  Script.Add('!define SourceName "' + ExtractFileName(SourceFile) + '"');
  Script.Add('!define SplashExt "' + ExtractExtension(SplashFile) + '"');
  Script.Add('!define BaseDir "' + WorkDir + '"');
  Script.Add('!define UpxTemp "' + GetTempFile(JvComputerInfoEx1.Folders.Temp,'upx','tmp') + '"');
  Script.Add('!define ConfigFile "' + IniFile + '"');
  Script.Add('!define AppVers "' + AppVers + '"');
  Script.Add('!define AppDate "' + GetImageLinkTimeStampAsString(true) + '"');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('!include "${BaseDir}\system\nsis\include\messages.nsh"');
  Script.Add('!include "${BaseDir}\system\nsis\include\params.nsh"');
  Script.Add('!include "${BaseDir}\system\nsis\include\trimstr.nsh"');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('Name "InstantPlayer"');
  Script.Add('Caption "InstantPlayer"');
  Script.Add('Icon "${IconFile}"');
  Script.Add('OutFile "${OutputFile}"');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('RequestExecutionLevel user');
  Script.Add('SetCompressor LZMA');
  Script.Add('SetCompressorDictSize 32');
  Script.Add('XPStyle on');
  Script.Add('CRCCheck force');
  Script.Add('SilentInstall silent');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('!packhdr "${UpxTemp}" ''"${BaseDir}\system\upx\upx.exe" --brute "${UpxTemp}"''');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('ReserveFile "${BaseDir}\system\nsis\plugins\banner.dll"');
  Script.Add('ReserveFile "${BaseDir}\system\nsis\plugins\newadvsplashu.dll"');
  Script.Add('ReserveFile "${BaseDir}\system\nsis\plugins\nsExec.dll"');
  Script.Add('ReserveFile "${SplashFile}"');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('Function .onInit');
  Script.Add('  !insertmacro GetCommandlineParameter "?" "error" $0');
  Script.Add('  StrCmp $0 "error" NoHelp');
  Script.Add('  MessageBox MB_TOPMOST|MB_ICONINFORMATION "MakeInstantPlayer, written by Lord_MuldeR$\nVersion ${AppVers}, Released ${AppDate}$\n$\nCommandline Usage:$\n  InstantPlayer.exe [/NOSPLASH] [/NOGUI[=<Options>]] [/NOHOME] [/EXTRACT[=<Destination>]]"');
  Script.Add('  Quit');
  Script.Add('NoHelp:');
  Script.Add('  !insertmacro GetCommandlineParameter "EXTRACT" "error" $0');
  Script.Add('  StrCmp $0 "error" NoExtract');
  Script.Add('  Push $0');
  Script.Add('  Call ExtractMedia');
  Script.Add('NoExtract:');
  Script.Add('  InitPluginsDir');
  Script.Add('  SetOutPath "$PLUGINSDIR"');
  Script.Add('  Banner::Show ""');
  Script.Add('  Banner::getWindow');
  Script.Add('	Pop $1');
  Script.Add('	GetDlgItem $2 $1 1030');
  Script.Add('	SendMessage $2 ${WM_SETTEXT} 0 "STR:Initializing, please wait..."');
  Script.Add('  !insertmacro GetCommandlineParameter "NOSPLASH" "error" $0');
  Script.Add('  StrCmp $0 "error" ShowSplash SkipSplash');
  Script.Add('ShowSplash:');
  Script.Add('  File "/oname=splash.${SplashExt}" "${SplashFile}"');
  Script.Add('  StrCpy $0 "splash.${SplashExt}"');
  Script.Add('  newadvsplashu::Show /NOUNLOAD -1 1200 500 -1 /BANNER /NOCANCEL "$PLUGINSDIR\splash.${SplashExt}"');
  Script.Add('  Banner::Destroy');
  Script.Add('SkipSplash:');
  Script.Add('  Sleep 100');
  Script.Add('FunctionEnd');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('Function ExtractMedia');
  Script.Add('  Call Trim');
  Script.Add('  Pop $R0');
  Script.Add('  StrCmp $R0 "" 0 +2');
  Script.Add('  StrCpy $R0 "$EXEDIR"');
  Script.Add('  SetOutPath "$R0"');
  Script.Add('  IfFileExists "$OUTDIR\${SourceName}" ExtractFailed');
  Script.Add('  SetOverwrite try');
  Script.Add('  ClearErrors');
  Script.Add('  File "/oname=${SourceName}" "${SourceFile}"');
  Script.Add('  SetOverwrite on');
  Script.Add('  IfErrors ExtractFailed ExtractDone');
  Script.Add('ExtractFailed:');
  Script.Add('  MessageBox MB_ICONSTOP|MB_TOPMOST "Sorry, failed to extract media file:$\n$OUTDIR\${SourceName}$\n$\nFile already exists or access denied!"');
  Script.Add('  Quit');
  Script.Add('ExtractDone:');
  Script.Add('  MessageBox MB_ICONINFORMATION|MB_TOPMOST "Media file successfully extracted to:$\n$OUTDIR\${SourceName}"');
  Script.Add('  Quit');
  Script.Add('FunctionEnd');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('Section "-ExtractFiles"');
  if CheckBox3.Checked then
  begin
    Script.Add('  SetOutPath "$PLUGINSDIR\codecs"');
    Script.Add('  File /nonfatal "${BaseDir}\system\mplayer\codecs\*.acm"');
    Script.Add('  File /nonfatal "${BaseDir}\system\mplayer\codecs\*.ax"');
    Script.Add('  File /nonfatal "${BaseDir}\system\mplayer\codecs\*.dll"');
    Script.Add('  File /nonfatal "${BaseDir}\system\mplayer\codecs\*.drv"');
    Script.Add('  File /nonfatal "${BaseDir}\system\mplayer\codecs\*.qts"');
    Script.Add('  File /nonfatal "${BaseDir}\system\mplayer\codecs\*.qtx"');
    Script.Add('  File /nonfatal "${BaseDir}\system\mplayer\codecs\*.vwp"');
  end;
  Script.Add('  SetOutPath "$PLUGINSDIR"');
  Script.Add('  File "${BaseDir}\system\mplayer\mplayer.exe"');
  Script.Add('  File "${BaseDir}\system\mplayer\mpui.exe"');
  Script.Add('  File /oname=MPUI.ini "${ConfigFile}"');
  Script.Add('  File "${BaseDir}\system\etc\sample.avi"');
  Script.Add('  SetOutPath "$PLUGINSDIR\mplayer"');
  Script.Add('  File "${BaseDir}\system\mplayer\mplayer\config"');
  Script.Add('  File "${BaseDir}\system\mplayer\mplayer\input.conf"');
  Script.Add('  File "${BaseDir}\system\mplayer\mplayer\subfont.ttf"');
  Script.Add('  SetOutPath "$PLUGINSDIR\fonts"');
  Script.Add('  File "${BaseDir}\system\mplayer\fonts\fonts.conf"');
  Script.Add('  File "${BaseDir}\system\mplayer\fonts\fonts.dtd"');
  Script.Add('  SetOutPath "$PLUGINSDIR\fonts\conf.d"');
  Script.Add('  File "${BaseDir}\system\mplayer\fonts\conf.d\*.conf"');
  Script.Add('  SetOutPath "$PLUGINSDIR\media"');
  Script.Add('  File "/oname=${SourceName}" "${SourceFile}"');
  Script.Add('SectionEnd');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('Section "-UpdateFontCache"');
  Script.Add('  nsExec::ExecToStack /TIMEOUT=30000 `"$PLUGINSDIR\MPlayer.exe" -fontconfig -ass -vo null -ao null "$PLUGINSDIR\sample.avi"`');
  Script.Add('  Pop $0');
  Script.Add('  Pop $1');
  Script.Add('  StrCmp $0 "0" FontUpdateDone');
  Script.Add('  MessageBox MB_ICONSTOP|MB_TOPMOST "MPlayer failed to execute:$\n$\n$1"');
  Script.Add('  Abort');
  Script.Add('  FontUpdateDone:');
  Script.Add('SectionEnd');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add('Section "-LaunchPlayer"');
  Script.Add('  SetOutPath "$PLUGINSDIR"');
  Script.Add('  !insertmacro GetCommandlineParameter "NOSPLASH" "error" $0');
  Script.Add('  StrCmp $0 "error" FadeOut HideBanner');
  Script.Add('FadeOut:');
  Script.Add('  newadvsplashu::stop /FADEOUT');
  Script.Add('  Goto RunPlayer');
  Script.Add('HideBanner:');
  Script.Add('  Banner::Destroy');
  Script.Add('  Goto RunPlayer');
  Script.Add('RunPlayer:');
  Script.Add('  !insertmacro GetCommandlineParameter "NOGUI" "error" $0');
  Script.Add('  StrCmp $0 "error" RunMPUI RunMPlayer');
  Script.Add('RunMPlayer:');
  Script.Add('  Push $0');
  Script.Add('  Call Trim');
  Script.Add('  Pop $0');
  Script.Add('  StrCmp $0 "" 0 +2');
  Script.Add('  ReadINIStr $0 "$PLUGINSDIR\MPUI.ini" "MPUI" "Params"');
  Script.Add('  ExecWait ''"$PLUGINSDIR\mplayer.exe" $0 "$PLUGINSDIR\media\${SourceName}"''');
  Script.Add('  Goto PlayerDone');
  Script.Add('RunMPUI:');
  Script.Add('  ExecWait ''"$PLUGINSDIR\mpui.exe" ' + Options + ' "$PLUGINSDIR\media\${SourceName}"''');
  Script.Add('  Goto PlayerDone');
  Script.Add('PlayerDone:');
  if Length(Edit3.Text) > 0 then
  begin
    Script.Add('  !insertmacro GetCommandlineParameter "NOHOME" "error" $0');
    Script.Add('  StrCmp $0 "error" 0 +2');
    Script.Add('  ExecShell open `' + HomeURL + '` SW_SHOWMAXIMIZED');
  end;
  Script.Add('  Sleep 100');
  Script.Add('SectionEnd');
  Script.Add('');
  Script.Add(';---------------------------------------------------------------------------');
  Script.Add('');
  Script.Add(';eof');

  ScriptFile := GetTempFile(JvComputerInfoEx1.Folders.Temp,'player','nsi');
  Script.SaveToFile(ScriptFile);
  Script.Free;

  CmdLine := '"' + WorkDir + '\system\nsis\makensis.exe" "' + ScriptFile + '"';

  try
    Memo1.Lines.Clear;
    JvTimer1.Interval := 100;
    JvTimer1.Enabled := True;
    Preview := False;
    Process := TProcessingThread.Create(CmdLine, LogFile);
    Process.OnTerminate := ProcessTerminate;
    Process.Resume;
  except
    on e: Exception do
    begin
      DeleteFile(ScriptFile);
      Memo1.Lines.Add('Faild to create process:');
      Memo1.Lines.Add(CmdLine);
      Memo1.Lines.Add('');
      Memo1.Lines.Add(e.Message);
      SetTaskbarProgressState(tbpsNone);
      SetTaskbarOverlayIcon(nil, 'None');
    end;
  end;
end;

procedure TForm1.MakePreview(SourceFile: String; Opts:TOptions; Params:String; Locale:String; LogFile: TMemo);
var
  CmdLine:String;
  Ini:TStringList;
begin
  CmdLine := '"' + WorkDir + '\system\mplayer\mpui.exe" -noopen -multiple';

  if Opts.fs then CmdLine := CmdLine + ' -fs';
  if Opts.autoquit then CmdLine := CmdLine + ' -autoquit';
  if Opts.compact then CmdLine := CmdLine + ' -compact';
  if Opts.topmost then CmdLine := CmdLine + ' -topmost';
  if Opts.loop then CmdLine := CmdLine + ' -loop';
  CmdLine := CmdLine + ' "' + SourceFile + '"';

  Ini := TStringList.Create;
  Ini.Add('[MPUI]');
  Ini.Add('Locale=' + AnsiLowerCase(Locale));
  if Params <> '' then
    Ini.Add('Params=' + Params);
  IniFile := GetTempFile(JvComputerInfoEx1.Folders.Temp,'config','ini');

  LogFile.Lines.Clear;

  try
    Ini.SaveToFile(WorkDir + '\system\mplayer\MPUI.ini');
    Ini.Free;
  except
    on e: Exception do begin
      LogFile.Lines.Add('Faild to create INI file: ' + WorkDir + '\system\mplayer\MPUI.ini');
      LogFile.Lines.Add(e.Message);
    end;
  end;

  try
    Preview := True;
    JvTimer1.Interval := 100;
    JvTimer1.Enabled := True;
    LogFile.Lines.Add('Commandline:');
    LogFile.Lines.Add(CmdLine);
    LogFile.Lines.Add('');
    LogFile.Lines.Add('Preview in progress...');
    Process := TProcessingThread.Create(CmdLine, LogFile);
    Process.OnTerminate := ProcessTerminate;
    Process.Resume;
  except
    on e: Exception do begin
      LogFile.Lines.Add('Faild to create process: ' + CmdLine);
      LogFile.Lines.Add(e.Message);
    end;
  end;
end;

procedure TForm1.ProcessTerminate(Sender: TObject);
var
  ProcThread: TProcessingThread;
  ExitCode: Integer;
  Log: TStringList;
  h: THandle;
  p: PAnsiChar;
  c: Cardinal;
begin
  ProcThread := Sender as TProcessingThread;
  ExitCode := ProcThread.GetExitCode;

  if Preview then
  begin
    h := INVALID_HANDLE_VALUE;
  end else
  begin
    h := CreateFile(PAnsiChar(JvComputerInfoEx1.Folders.AppData + '\MakeInstantPlayer.log'), GENERIC_WRITE, 0, nil, OPEN_ALWAYS, 0, 0);
  end;

  if h <> INVALID_HANDLE_VALUE then
  begin
    Log := ProcThread.GetLog;
    Log.Insert(0, '');
    Log.Insert(0, Format('=========== MakeInstantPlayer, %s [%s, %s] ===========',[self.Label13.Caption,DateToStr(Date),TimeToStr(Time)]));
    Log.Add('');
    Log.Add('');
    p := Log.GetText;
    Log.Free;
    SetFilePointer(h, 0, nil, FILE_END);
    WriteFile(h, p^, StrLen(p), c, nil);
    StrDispose(p);
    CloseHandle(h);
  end;

  FreeAndNil(ProcThread);

  JvTimer1.Enabled := False;
  JvXPProgressBar1.Position := 100;

  DisableButtons(true);
  Process := nil;

  if Preview then begin
    Memo1.Lines.Add('Stopped.');
    Exit;
  end;

  DeleteFile(ScriptFile);
  DeleteFile(IniFile);

  if ExitCode <> 0 then
  begin
    SetTaskbarProgressState(tbpsError);
    SetTaskbarOverlayIcon(ImageList, 2, 'Failed');
  end else begin
    SetTaskbarProgressState(tbpsNormal);
    SetTaskbarOverlayIcon(ImageList, 1, 'Complete');
  end;

  SetTaskbarProgressValue(100,100);

  if ExitCode = 0 then
  begin
    MsgBox('Your InstantPlayer was created successfully!', 'Done', MB_OK+MB_ICONINFORMATION)
  end
  else if ExitCode = -3 then
  begin
    MsgBox('Process was aborted by the user!', 'Aborted', MB_OK+MB_ICONERROR);
  end else
  begin
    MsgBox('Somethimg went wrong, see log for details!', 'Faild', MB_OK+MB_ICONERROR);
  end;

  SetTaskbarProgressState(tbpsNone);
  SetTaskbarOverlayIcon(nil, 'None');
end;

///////////////////////////////////////////////////////////////////////////////
// Utilities
//////////////////////////////////////////////////////////////////////////////

procedure TForm1.DisableButtons(x: Boolean);
begin
  Button1.Enabled := x;
  Button2.Enabled := x;
  Edit3.ReadOnly := not x;
  CheckBox1.Enabled := x;
  CheckBox2.Enabled := x;
  CheckBox3.Enabled := x;
  CheckBox4.Enabled := x;
  CheckBox5.Enabled := x;
  CheckBox6.Enabled := x;
  ComboBox1.Enabled := x;
  ComboBox2.Enabled := x;
  Reset1.Enabled := x;
  Reset2.Enabled := x;
  Reset3.Enabled := x;
  Reset4.Enabled := x;

  if x then
  begin
    Button3.Caption := 'Quit';
  end else
  begin
    Button3.Caption := 'Abort';
  end;
end;

function TForm1.CheckSplash(FileName:String):Boolean;
var
  pic: TPicture;
begin
  pic := TPicture.Create;

  try
    pic.LoadFromFile(FileName);
  except
    MsgBox('Arrrggghhh, your splash file is not a vaild/supported image file !!!', 'Faild to load image', MB_OK+MB_ICONWARNING);
    pic.Free;
    Result := False;
    Exit;
  end;

  pic.Free;
  Result := True;
end;

function TForm1.CheckIcon(FileName:String):Boolean;
var
  ico: TIcon;
begin
  ico := TIcon.Create;

  try
    ico.LoadFromFile(FileName);
  except
    MsgBox('Arrrggghhh, your icon file is not a vaild/supported ICO file !!!', 'Faild to load image', MB_OK+MB_ICONWARNING);
    ico.Free;
    Result := False;
    Exit;
  end;

  ico.Free;
  Result := True;
end;

function TForm1.FullPath(Filename:String):String;
var
  Dummy: PAnsiChar;
begin
  SetLength(Result, GetFullPathName(@Filename[1], 0, nil, Dummy) + 1);
  SetLength(Result, GetFullPathName(@Filename[1], Length(Result), @Result[1], Dummy));
end;

function TForm1.CheckFile(Filename:String; Default:String; MustExist: Boolean):String;
begin
  Result := FullPath(Filename);

  StrReplace(Result,'/','\',[rfReplaceAll]);
  StrReplace(Result,':','_',[rfReplaceAll]);
  StrReplace(Result,'*','_',[rfReplaceAll]);
  StrReplace(Result,'?','_',[rfReplaceAll]);

  if Length(Result) > 1 then
  begin
    Result[2] := ':';
  end;

  if (Length(Result) < 4) or (MustExist and (not FileExists(Result))) then
  begin
    Result := Default;
  end;
end;

function TForm1.CheckURL(URL:String):String;
var
  Secure: Boolean;
begin
  Secure := False;
  Result := Trim(Edit3.Text);

  if SameText(StrLeft(Result,7), 'http://') then
  begin
    Secure := False;
    Result := Copy(Result, 8, Length(Result));
  end
  else if SameText(StrLeft(Result,8), 'https://') then
  begin
    Secure := True;
    Result := Copy(Result, 9, Length(Result));
  end;

  if Length(Result) < 3 then
  begin
    Result := '';
    Exit;
  end;

  StrReplace(Result,' ','%20',[rfReplaceAll]);
  StrReplace(Result,'"','%22',[rfReplaceAll]);
  StrReplace(Result,'`','''',[rfReplaceAll]);

  if pos('.', Result) = 0 then
  begin
    Result := Format('%s.com', [Result]);
  end;

  if pos('/', Result) = 0 then
  begin
    Result := Format('%s/', [Result]);
  end;

  if Secure then
  begin
    Result := Format('https://%s', [Result]);
  end else begin
    Result := Format('http://%s', [Result]);
  end;
end;

procedure CheckDebugBuild;
begin
  if IsDebuggerPresent then
  begin
    FatalAppExit(0, 'Sorry, this is not a debug build. Unload your debugger and try again!');
    TerminateProcess(GetCurrentProcess, Cardinal(-1));
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Callback Stuff
//////////////////////////////////////////////////////////////////////////////

procedure TForm1.Button1Click(Sender: TObject);
var
  Opts: TOptions;
begin
  if not FileExists(Edit1.Text) then begin
    MsgBox('Arrrggghhh, source file could not be found !!!', {'File not found',} MB_OK or MB_ICONWARNING);
    Exit;
  end;

  if not CheckSplash(Edit4.Text) then Exit;
  if not CheckIcon(Edit6.Text) then Exit;

  if not Tested then
  begin
    if MsgBox('You did not preview the player with the current configuration yet. Proceed anyway?','Make an untested player?', MB_YESNO or MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then Exit;
  end;

  if CheckBox3.Checked then
  begin
    if MsgBox('Warning: Including the Codecs with your InstantPlayer will make the file *much* bigger. So you should include the Codecs only when it''s absolutely necessary. '
      + 'MPlayer works 100% fine *without* the Codecs in most cases. Only a few proprietary formats like WMV9 or RealVideo require additional codecs. '
      + 'It''s highly recommended to avoid such formats and keep the Codecs setting disabled!',
      'MPlayer Codecs',MB_OKCANCEL+MB_DEFBUTTON2+MB_ICONWARNING) <> idOK then
    begin
      Exit;
    end;  
  end;

  if FileExists(Edit2.Text) then
  begin
    if MsgBox('Output file already exists. Overwrite this file ???','Overwrite?',MB_YESNO or MB_DEFBUTTON2 or MB_ICONQUESTION) <> idYes then Exit;
  end;

  DisableButtons(false);
  SetTaskbarProgressState(tbpsIndeterminate);
  SetTaskbarOverlayIcon(ImageList, 0, 'Working');

  Opts.fs := CheckBox1.Checked;
  Opts.autoquit := CheckBox2.Checked;
  Opts.compact := CheckBox4.Checked;
  Opts.topmost := CheckBox5.Checked;
  Opts.loop := CheckBox6.Checked;

  MakePlayer(Edit1.Text, Edit2.Text, Edit4.Text, Edit6.Text, Edit3.Text, ComboBox2.Text, Opts, ComboBox1.Text, Memo1);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Opts: TOptions;
begin
  if not FileExists(Edit1.Text) then Exit;

  DisableButtons(false);

  Opts.fs := CheckBox1.Checked;
  Opts.autoquit := CheckBox2.Checked;
  Opts.compact := CheckBox4.Checked;
  Opts.topmost := CheckBox5.Checked;
  Opts.loop := CheckBox6.Checked;

  MakePreview(Edit1.Text, Opts, ComboBox2.Text, ComboBox1.Text, Memo1);
  Tested := True;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if Assigned(Process) then
  begin
    Process.Abort;
    if Preview then Tested := False;
  end else
  begin
    Close;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Assigned(Process);
end;

procedure TForm1.Edit1Click(Sender: TObject);
begin
  if not Button1.Enabled then Exit;

  JvOpenDialog1.FileName := Edit1.Text;
  if not JvOpenDialog1.Execute then Exit;

  Edit1.Text := JvOpenDialog1.FileName;
  Tested := False;
end;

procedure TForm1.Edit2Click(Sender: TObject);
begin
  if not Button1.Enabled then Exit;

  JvSaveDialog1.FileName := Edit2.Text;
  if not JvSaveDialog1.Execute then Exit;
  Edit2.Text := JvSaveDialog1.FileName;
end;

procedure TForm1.JvTimer1Timer(Sender: TObject);
begin
  if JvXPProgressBar1.Position >= 100 then
  begin
    JvTimer1.Interval := 100;
    JvXPProgressBar1.Position := 0;
    Exit;
  end;

  JvXPProgressBar1.Position := JvXPProgressBar1.Position + 5;

  if JvXPProgressBar1.Position >= 100 then
  begin
    JvTimer1.Interval := 2000;
  end;
end;

procedure TForm1.Label4MouseEnter(Sender: TObject);
begin
  with Sender as TLabel do begin
    Font.Color := clAqua;
    Font.Style := Font.Style + [fsUnderline];
  end;
end;

procedure TForm1.Label4MouseLeave(Sender: TObject);
begin
  with Sender as TLabel do begin
    Font.Color := clYellow;
    Font.Style := Font.Style - [fsUnderline];
  end;
end;

procedure TForm1.Label13MouseEnter(Sender: TObject);
begin
  with Sender as TLabel do begin
    Font.Color := clBlue;
    Font.Style := Font.Style + [fsUnderline];
  end;
end;

procedure TForm1.Label13MouseLeave(Sender: TObject);
begin
  with Sender as TLabel do begin
    Font.Color := clMaroon;
    Font.Style := Font.Style - [fsUnderline];
  end;
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  if Button1.Enabled then ShellExecute(Form1.Handle,'open','http://mulder.at.gg/',nil,nil,SW_SHOWMAXIMIZED);
end;

procedure TForm1.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  FatalAppExit(0, 'This application has encountered an unexpected error and will exit right now!');
  TerminateProcess(GetCurrentProcess, Cardinal(-1));
end;

procedure TForm1.Label5Click(Sender: TObject);
begin
  if Button1.Enabled then ShellExecute(Form1.Handle,'open','http://www.mplayerhq.hu/',nil,nil,SW_SHOWMAXIMIZED);
end;

procedure TForm1.CopytoClipboard1Click(Sender: TObject);
begin
  Clipboard.AsText := Memo1.Lines.GetText;
end;

procedure TForm1.Edit3Exit(Sender: TObject);
begin
  Edit3.Text := CheckURL(Edit3.Text);
end;

procedure TForm1.Label7Click(Sender: TObject);
begin
  if Button1.Enabled then ShellExecute(Form1.Handle,'open','http://nsis.sourceforge.net/',nil,nil,SW_SHOWMAXIMIZED);
end;

procedure TForm1.Label8Click(Sender: TObject);
begin
  if Button1.Enabled then JvJVCLAboutComponent1.Execute;
end;

procedure TForm1.Edit4Click(Sender: TObject);
begin
  if not Button1.Enabled then Exit;

  OpenPictureDialog1.FileName := Edit4.Text;

  if not OpenPictureDialog1.Execute then Exit;
  if not CheckSplash(OpenPictureDialog1.FileName) then Exit;

  Edit4.Text := OpenPictureDialog1.FileName;
end;

procedure TForm1.Label12Click(Sender: TObject);
begin
  if Button1.Enabled then ShellExecute(Form1.Handle,'open','http://mpui.sf.net/',nil,nil,SW_SHOWMAXIMIZED);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked and CheckBox4.Checked then
  begin
    CheckBox4.Checked := False;
  end;
  
  Tested := False;
end;

procedure TForm1.CheckBox4Click(Sender: TObject);
begin
  if CheckBox4.Checked and CheckBox1.Checked then
    CheckBox1.Checked := False;

  Tested := False;
end;

procedure TForm1.Edit6Click(Sender: TObject);
begin
  if not Button1.Enabled then Exit;

  OpenPictureDialog2.FileName := Edit6.Text;

  if not OpenPictureDialog2.Execute then Exit;
  if not CheckIcon(OpenPictureDialog2.FileName) then Exit;

  Edit6.Text := OpenPictureDialog2.FileName;
end;

procedure TForm1.ComboBox2Exit(Sender: TObject);
begin
  ComboBox2.Text := Trim(ComboBox2.Text);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  Tested := False;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
  Tested := False;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  Tested := False;
end;

procedure TForm1.CheckBox5Click(Sender: TObject);
begin
  Tested := False;
end;

procedure TForm1.CheckBox6Click(Sender: TObject);
begin
  Tested := False;
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
  Tested := False;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
  if not SameText(StrRight(Edit2.Text, 4), '.exe') then
  begin
    Edit2.Text := Edit2.Text + '.exe';
  end;
end;

procedure TForm1.Reset1Click(Sender: TObject);
begin
  Edit1.Text := JvComputerInfoEx1.Folders.Personal + '\Clip.avi';
end;

procedure TForm1.Reset2Click(Sender: TObject);
begin
  Edit2.Text := JvComputerInfoEx1.Folders.Personal + '\InstantPlayer.exe';
end;

procedure TForm1.Reset3Click(Sender: TObject);
begin
  Edit4.Text := WorkDir + '\system\images\splash.gif';
end;

procedure TForm1.Reset4Click(Sender: TObject);
begin
  Edit6.Text := WorkDir + '\system\images\movie.ico';
end;

procedure TForm1.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
begin
  if Msg.message = WM_TaskbarButtonCreated then
  begin
    InitializeTaskbarAPI;
    Handled := True;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Initialization
//////////////////////////////////////////////////////////////////////////////

procedure TForm1.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
  {$IF NOT Defined(DEBUG_BUILD)}
  CheckDebugBuild;
  {$IFEND}
end;

initialization
  {$IF NOT Defined(DEBUG_BUILD)}
  CheckDebugBuild;
  {$IFEND}

end.
