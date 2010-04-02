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

unit Unit_Main;

///////////////////////////////////////////////////////////////////////////////
interface
///////////////////////////////////////////////////////////////////////////////

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, CommDlg, Registry, ShlObj, ShellAPI, ImgList,
  XPMan, Buttons, AppEvnts, MuldeR_Toolz, Mask, Contnrs, JvExMask, JvSpin,
  JvExStdCtrls, JvCombobox, JvDriveCtrls, JvListBox, JvDialogs, Math, mmsystem,
  JvComponentBase, JvComputerInfoEx, Menus, JvDebugHandler,
  JvSystemPopup, JvMenus, Unit_LockedFile, Unit_Encoder, Unit_Utils, Unit_Core,
  JvTimer, JvBaseDlg, JvBrowseFolder, Unit_MetaData, JvBalloonHint,
  JvDataEmbedded, JvBackgrounds, Unit_DropBox, Unit_Win7Taskbar,
  JvExExtCtrls, JvExtComponent, JvPanel;

///////////////////////////////////////////////////////////////////////////////

const
  VersionStr: String = 'v3.18 Hotfix-1';
  BuildNo: Integer = 87;
  BuildDate: String = '2010-04-02';

///////////////////////////////////////////////////////////////////////////////
//{$DEFINE BUILD_DEBUG}
//{$DEFINE DISABLE_ENCODE}
///////////////////////////////////////////////////////////////////////////////

const
  URL_Homepage: String = 'http://mulder.dummwiedeutsch.de/';

const
  ToolVersionStr: array [0..18] of TMapEntry =
  (
    ('Lame', 'v3.98.4, Final (2010-03-23)'), 
    ('OggVorbisEnc', 'v2.85, libVorbis v1.2.1 RC2, aoTuV b5.7 (2009-03-04)'),
    ('OggVorbisDec', 'v1.9.7 (2010-03-29)'), 
    ('NeroAAC', '1.5.3.0'), // <-- Used for update-check!
    ('MPG123', 'v1.12.1 (2010-03-31)'),
    ('FAAD', 'v2.7 (2009-05-13)'), 
    ('FLAC', 'v1.2.1b (2009-10-01)'), 
    ('Speex', 'v1.2rc1 (2009-07-04)'), 
    ('WavPack', 'v4.60.1 (2009-11-29)'), 
    ('Musepack', 'v1.0.0 VS8 (2009-04-02)'), 
    ('Monkey', 'v4.06 (2009-03-17)'), 
    ('AC3Filter', 'v0.31b (2009-10-01)'), 
    ('Shorten', 'v3.6.1 (2007-05-26)'), 
    ('TTA', 'v3.4.1 (2007-07-27)'), 
    ('TAK', 'v2.0.0 (2010-01-07)'), 
    ('MediaInfo', 'v0.7.30 (2010-03-26)'), 
    ('Volumax', 'v0.41 (2009-06-16)'), 
    ('GnuPG', 'v1.4.10b (2009-09-03)'), 
    ('WGet', 'v1.11.4 (2008-06-29)')
  );

///////////////////////////////////////////////////////////////////////////////

{$IF Defined(BUILD_DEBUG)}
  IsDebugBuild: Boolean = True;
{$ELSE}
  IsDebugBuild: Boolean = False;
{$IFEND}

///////////////////////////////////////////////////////////////////////////////

type
  TForm_Main = class(TForm)
    ApplicationEvents1: TApplicationEvents;
    Background_Form: TJvBackground;
    BalloonHint: TJvBalloonHint;
    Button_About: TBitBtn;
    Button_Add: TBitBtn;
    Button_Clear: TBitBtn;
    Button_DesktopFolder: TBitBtn;
    Button_Down: TBitBtn;
    Button_Edit: TBitBtn;
    Button_Encode: TBitBtn;
    Button_Exit: TBitBtn;
    Button_HomeFolder: TBitBtn;
    Button_NewFolder: TBitBtn;
    Button_Remove: TBitBtn;
    Button_Up: TBitBtn;
    Check_EnforceBitrates: TCheckBox;
    Check_MetaData: TCheckBox;
    Check_NeroTwoPass: TCheckBox;
    Check_Playlist: TCheckBox;
    Check_SaveToSourceDir: TCheckBox;
    Combo_Channels: TComboBox;
    Combo_Resample: TComboBox;
    ComputerInfo: TJvComputerInfoEx;
    DebugHandler: TJvDebugHandler;
    Dialog_AddFiles: TJvOpenDialog;
    Dialog_BrowseTempFolder: TJvBrowseForFolderDialog;
    Dialog_OpenFolder: TJvBrowseForFolderDialog;
    DirectoryListBox: TJvDirectoryListBox;
    Edit_Album: TEdit;
    Edit_Artist: TEdit;
    Edit_Bitrate_Max: TJvSpinEdit;
    Edit_Bitrate_Min: TJvSpinEdit;
    Edit_Comment: TEdit;
    Edit_Genre: TComboBox;
    Edit_Year: TJvSpinEdit;
    Group_BitrateManagment: TGroupBox;
    Group_ChannelMode: TGroupBox;
    Group_CompressionMode: TGroupBox;
    Group_Encoder: TGroupBox;
    Group_LameQuality: TGroupBox;
    Group_MetaData: TGroupBox;
    Group_NeroAAC: TGroupBox;
    Group_Quality: TGroupBox;
    Group_SampleRate: TGroupBox;
    ImageList1: TImageList;
    JvDriveCombo1: TJvDriveCombo;
    JvSystemPopup1: TJvSystemPopup;
    Label3: TLabel;
    Label6: TLabel;
    Label_Album: TLabel;
    Label_AlgorithmQuality: TLabel;
    Label_Artist: TLabel;
    Label_Comment: TLabel;
    Label_Genre: TLabel;
    Label_Max: TLabel;
    Label_MaxQuality: TLabel;
    Label_MaxSpeed: TLabel;
    Label_Min: TLabel;
    Label_Outdir: TLabel;
    Label_Quality: TLabel;
    Label_QualityMax: TLabel;
    Label_QualityMin: TLabel;
    Label_Year: TLabel;
    ListView: TListView;
    Menu_AddFiles: TMenuItem;
    Menu_AddFolderRecursive: TMenuItem;
    Menu_AddSingleFolder: TMenuItem;
    Menu_AdvancedOptions: TMenuItem;
    Menu_AnalyzeMediaFile: TMenuItem;
    Menu_BrowseFolder: TMenuItem;
    Menu_CheckforUpdates: TMenuItem;
    Menu_DisableAllSounds: TMenuItem;
    Menu_DisableMultiThreading: TMenuItem;
    Menu_DisableShellIntegration: TMenuItem;
    Menu_DisableUpdateReminder: TMenuItem;
    Menu_DontDetectMetaData: TMenuItem;
    Menu_DontHideConsole: TMenuItem;
    Menu_EnableNormalizationFilter: TMenuItem;
    Menu_InstallWMADecoder: TMenuItem;
    Menu_LanguageSelect: TMenuItem;
    Menu_NeroOverride: TMenuItem;
    Menu_NeroOverride_Auto: TMenuItem;
    Menu_NeroOverride_HEv1: TMenuItem;
    Menu_NeroOverride_HEv2: TMenuItem;
    Menu_NeroOverride_LC: TMenuItem;
    Menu_SetTempFolder: TMenuItem;
    Menu_ShowDebugInfo: TMenuItem;
    Menu_ShowDropBox: TMenuItem;
    Menu_ShowExceptionLog: TMenuItem;
    Menu_SourcesAdd: TMenuItem;
    Menu_SourcesBrowse: TMenuItem;
    Menu_SourcesClear: TMenuItem;
    Menu_SourcesInfo: TMenuItem;
    Menu_SourcesPlay: TMenuItem;
    Menu_SourcesRemove: TMenuItem;
    Menu_SourcesSort: TMenuItem;
    Menu_SourcesSort_ByFilename: TMenuItem;
    Menu_SourcesSort_ByFilenameRev: TMenuItem;
    Menu_SourcesSort_ByTitle: TMenuItem;
    Menu_SourcesSort_ByTitleRev: TMenuItem;
    Menu_SourcesSort_ByTrack: TMenuItem;
    Menu_SourcesSort_ByTrackRev: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    PageControl: TPageControl;
    Panel_DragIn: TPanel;
    Panel_Working_Outer: TPanel;
    Popup_AddFiles: TPopupMenu;
    Popup_DevTools: TJvPopupMenu;
    Popup_Folder: TPopupMenu;
    Popup_Open: TPopupMenu;
    Radio_Encoder_FLAC: TRadioButton;
    Radio_Encoder_Lame: TRadioButton;
    Radio_Encoder_Nero: TRadioButton;
    Radio_Encoder_Vorbis: TRadioButton;
    Radio_Encoder_Wave: TRadioButton;
    Radio_Mode_Average: TRadioButton;
    Radio_Mode_Constant: TRadioButton;
    Radio_Mode_Quality: TRadioButton;
    SaveDialog: TSaveDialog;
    Sheet_Compress: TTabSheet;
    Sheet_Config: TTabSheet;
    Sheet_MetaData: TTabSheet;
    Sheet_Output: TTabSheet;
    Sheet_Sources: TTabSheet;
    Timer_AddFiles: TTimer;
    TrackBar: TTrackBar;
    Trackbar_AlogorithmQuality: TTrackBar;
    XPManifest1: TXPManifest;
    Panel_Working_Middle: TPanel;
    Icon_Working: TImage;
    ImageList2: TImageList;
    Panel_Working_Inner: TJvPanel;
    Menu_AddFiles_Unicode: TMenuItem;
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure Button5Click(Sender: TObject);
    procedure Button_AboutClick(Sender: TObject);
    procedure Button_AddMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Button_ClearFiles(Sender: TObject);
    procedure Button_DesktopFolderClick(Sender: TObject);
    procedure Button_DownClick(Sender: TObject);
    procedure Button_EditClick(Sender: TObject);
    procedure Button_EncodeClick(Sender: TObject);
    procedure Button_HomeFolderClick(Sender: TObject);
    procedure Button_NewFolderClick(Sender: TObject);
    procedure Button_RemoveClick(Sender: TObject);
    procedure Button_UpClick(Sender: TObject);
    procedure Check_EnforceBitratesClick(Sender: TObject);
    procedure Check_MetaDataClick(Sender: TObject);
    procedure Check_SaveToSourceDirClick(Sender: TObject);
    procedure Dialog_BrowseTempFolderAcceptChange(Sender: TObject; const NewFolder: String; var Accept: Boolean);
    procedure DirectoryListBoxChange(Sender: TObject);
    procedure DriveComboBox1Click(Sender: TObject);
    procedure Edit1Enter(Sender: TObject);
    procedure Edit_ArtistExit(Sender: TObject);
    procedure Edit_Bitrate_MaxChange(Sender: TObject);
    procedure Edit_Bitrate_MinChange(Sender: TObject);
    procedure Edit_GenreChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label_OutdirClick(Sender: TObject);
    procedure Label_OutdirMouseEnter(Sender: TObject);
    procedure Label_OutdirMouseLeave(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ListViewClick(Sender: TObject);
    procedure ListViewDblClick(Sender: TObject);
    procedure Menu_AddFilesClick(Sender: TObject);
    procedure Menu_AddFolderRecursiveClick(Sender: TObject);
    procedure Menu_AnalyzeMediaFileClick(Sender: TObject);
    procedure Menu_BrowseFolderClick(Sender: TObject);
    procedure Menu_CheckforUpdatesClick(Sender: TObject);
    procedure Menu_DisableAllSoundsClick(Sender: TObject);
    procedure Menu_DisableMultiThreadingClick(Sender: TObject);
    procedure Menu_DisableShellIntegrationClick(Sender: TObject);
    procedure Menu_DisableUpdateReminderClick(Sender: TObject);
    procedure Menu_DontDetectMetaDataClick(Sender: TObject);
    procedure Menu_DontHideConsoleClick(Sender: TObject);
    procedure Menu_EnableNormalizationFilterClick(Sender: TObject);
    procedure Menu_InstallWMADecoderClick(Sender: TObject);
    procedure Menu_LanguageSelectorClick(Sender: TObject);
    procedure Menu_NeroOverride_Click(Sender: TObject);
    procedure Menu_SetTempFolderClick(Sender: TObject);
    procedure Menu_ShowDebugInfoClick(Sender: TObject);
    procedure Menu_ShowDropBoxClick(Sender: TObject);
    procedure Menu_ShowExceptionLogClick(Sender: TObject);
    procedure Menu_SourcesAddClick(Sender: TObject);
    procedure Menu_SourcesBrowseClick(Sender: TObject);
    procedure Menu_SourcesClearClick(Sender: TObject);
    procedure Menu_SourcesInfoClick(Sender: TObject);
    procedure Menu_SourcesPlayClick(Sender: TObject);
    procedure Menu_SourcesRemoveClick(Sender: TObject);
    procedure Menu_SourcesSort_ByFilenameClick(Sender: TObject);
    procedure Menu_SourcesSort_ByFilenameRevClick(Sender: TObject);
    procedure Menu_SourcesSort_ByTitleClick(Sender: TObject);
    procedure Menu_SourcesSort_ByTitleRevClick(Sender: TObject);
    procedure Menu_SourcesSort_ByTrackClick(Sender: TObject);
    procedure Menu_SourcesSort_ByTrackRevClick(Sender: TObject);
    procedure Radio_Encoder_FLACClick(Sender: TObject);
    procedure Radio_Encoder_LameClick(Sender: TObject);
    procedure Radio_Encoder_NeroClick(Sender: TObject);
    procedure Radio_Encoder_VorbisClick(Sender: TObject);
    procedure Radio_Encoder_WaveClick(Sender: TObject);
    procedure Radio_Mode_AverageClick(Sender: TObject);
    procedure Radio_Mode_ConstantClick(Sender: TObject);
    procedure Radio_Mode_QualityClick(Sender: TObject);
    procedure Timer_AddFilesTimer(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure Trackbar_AlogorithmQualityChange(Sender: TObject);
    procedure Menu_AddFiles_UnicodeClick(Sender: TObject);
  private
    {$IF NOT Defined(BUILD_DEBUG)}
    AppOnIdleProc: TIdleEvent;
    procedure AppOnIdle(Sender: TObject; var Done: Boolean);
    {$IFEND}
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    Path: record
      AppRoot: String;
      StartFrom: String;
      Personal: String;
      Desktop: String;
      Music: String;
      Programs: String;
      Temp: String;
      Tools: String;
      AppData: String;
      System: String;
      LameXP: String;
    end;
    Tools: record
      LameEnc: TLockedFile;
      MP3Dec: TLockedFile;
      OggEnc_i386: TLockedFile;
      OggEnc_SSE2: TLockedFile;
      OggDec: TLockedFile;
      AacDec: TLockedFile;
      AlacDec: TLockedFile;
      NeroEnc_Enc: TLockedFile;
      NeroEnc_Tag: TLockedFile;
      FLAC: TLockedFile;
      SpeexDec: TLockedFile;
      WavpackDec: TLockedFile;
      MusepackDec: TLockedFile;
      MonkeyDec: TLockedFile;
      ValibDec: TLockedFile;
      ShortenDec: TLockedFile;
      TTADec: TLockedFile;
      TAKDec: TLockedFile;
      Volumax: TLockedFile;
      WGet: TLockedFile;
      WMADec: TLockedFile;
      MediaInfo: TLockedFile;
      WUpdate: TLockedFile;
      GnuPG: TLockedFile;
      Keyring: TLockedFile;
      SelfDel: TLockedFile;
    end;
    Options: record
      Encoder: TEncoderEnum;
      EncMode: Integer;
      Bitrate: Integer;
      NeroAccepted: Boolean;
      WMADecoderNoWarn: Boolean;
      GPLAccepted: Integer;
      CurrentLanguage: String;
      LastUpdateCheck: Integer;
      SoundsEnabled: Boolean;
      SilentMode: Boolean;
      ShellIntegration: Boolean;
      UpdateReminder: Boolean;
      DetectMetaData: Boolean;
      NormalizationPeak: Real;
      MultiThreading: Boolean;
      NeroOverride: Integer;
    end;
    Flags: record
      FirstView: Boolean;
      UnsupportedDPI: Boolean;
      NeroEncoder: Boolean;
      WMADecoder: Boolean;
      ShutdownOnTerminate: Boolean;
      ShowDropbox: Boolean;
      DisableBalloons: Boolean;
    end;
    FilesToAdd: TStringList;
    DecoderList: TObjectList;
    LanguageFiles: TStringList;
    LanguageFlags: TObjectList;
    WMsg_Terminate: Cardinal;
    WMsg_Taskbar: Cardinal;
  end;

///////////////////////////////////////////////////////////////////////////////

var
  Form_Main: TForm_Main;

///////////////////////////////////////////////////////////////////////////////

const
  FileTypes_Exts: array [0..17,0..3] of String =
  (
    ('wav','','',''),
    ('mp3','','',''),
    ('mp2','mpa','',''),
    ('ogg','oga','ogm','vrbs'),
    ('mp4','aac','m4a','m4b'),
    ('flac','fla','',''),
    ('spx','','',''),
    ('wv','wvc','',''),
    ('mpc','mpp','mp+',''),
    ('shn','','',''),
    ('ape','','',''),
    ('tta','','',''),
    ('tak','','',''),
    ('ac3','a52','',''),
    ('dts','dca','',''),
    ('wma','asf','',''),
    ('m3u','pls','asx',''),
    ('cue','','','')
  );

  FileTypes_Names: array [0..17] of String =
  (
    'PCM Wave Audio (.wav)',
    'MPEG Audio Layer-3 (.mp3)',
    'MPEG Audio Layer-2 (.mp2)',
    'Ogg Vorbis (.ogg)',
    'Advanced Audio Coding (.mp4)',
    'Free Lossless Audio Codec (.flac)',
    'Speex (.spx)',
    'WavPack Hybrid Audio (.wv)',
    'Musepack (.mpc)',
    'Shorten Lossless Audio (.shn)',
    'Monkey''s Audio (.ape)',
    'The True Audio (.tta)',
    'Tom''s lossless Audio Kompressor (.tak)',
    'ATSC A/52 aka AC-3 (.ac3)',
    'Digital Theater Systems (.dts)',
    'Windows Media Audio (.wma)',
    'Playlist Files (.m3u)',
    'Cuesheet (.cue)'
  );

  NeroDownloadURL: String = 'http://www.nero.com/eng/downloads-nerodigital-nero-aac-codec.php';

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

uses
  Unit_About,
  Unit_Data,
  Unit_LicenseView,
  Unit_Translator,
  Unit_Languages,
  Unit_RunProcess,
  Unit_QueryBox,

  Unit_WaveDecoder,
  Unit_MP3Decoder,
  Unit_OggDecoder,
  Unit_AACDecoder,
  Unit_ALACDecoder,
  Unit_FlacDecoder,
  Unit_SpeexDecoder,
  Unit_WavpackDecoder,
  Unit_MusepackDecoder,
  Unit_MonkeyDecoder,
  Unit_ValibDecoder,
  Unit_ShortenDecoder,
  Unit_TTADecoder,
  Unit_TAKDecoder,
  Unit_WMADecoder;

var
  InitialCurrentDir: String;

{$R *.DFM}
{$R Waves.res}

///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.FormCreate(Sender: TObject);
const
  CSIDL_PROGRAM_FILES = $0026;
  CSIDL_MYMUSIC = $000d;
begin
  if Application.Terminated then
  begin
    Exit;
  end;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////
  
  {$IF NOT Defined(BUILD_DEBUG)}
  AppOnIdleProc := Application.OnIdle;
  Application.OnIdle := AppOnIdle;
  CheckDebugger;
  CheckJVCLVersion;
  CheckForCompatibilityMode;
  CheckVersionInfo;
  {$IFEND}

  /////////////////////////////////////////////////////////////////

  DebugHandler.LogFileName := 'C:\LameXP.log';
  WMsg_Terminate := RegisterWindowMessage('{a5756250-c439-44c0-a158-a066e2438e71}');
  WMsg_Taskbar := RegisterWindowMessage('TaskbarButtonCreated');

  /////////////////////////////////////////////////////////////////

  Application.HintPause := 1000;
  Application.HintHidePause := -1;
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  DragAcceptFiles(Handle, True);

  Flags.FirstView := True;
  Flags.NeroEncoder := False;
  Flags.WMADecoder := False;
  Flags.UnsupportedDPI := False;
  Flags.ShutdownOnTerminate := False;
  Flags.DisableBalloons := False;

  Options.NeroAccepted := False;
  Options.GPLAccepted := 0;
  Options.WMADecoderNoWarn := False;
  Options.LastUpdateCheck := 0;
  Options.SoundsEnabled := True;
  Options.SilentMode := False;
  Options.ShellIntegration := False;
  Options.UpdateReminder := True;
  Options.DetectMetaData := True;
  Options.CurrentLanguage := '';
  Options.NormalizationPeak := -0.1;
  Options.MultiThreading := True;
  Options.NeroOverride := 0;

  FilesToAdd := TStringList.Create;
  LanguageFiles := TStringList.Create;
  LanguageFlags := TObjectList.Create;
  DecoderList := TObjectList.Create;

  /////////////////////////////////////////////////////////////////

  if not CheckOSVersion then
  begin
    OnDestroy(Sender);
    TerminateProcess(GetCurrentProcess, DWORD(-1));
  end;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  Path.AppRoot := GetAppDirectory;
  Path.StartFrom := InitialCurrentDir;
  Path.System := GetSysDirectory;
  Path.Personal := GetShellDirectory(CSIDL_PERSONAL);
  Path.Desktop := GetShellDirectory(CSIDL_DESKTOP);
  Path.Programs := GetShellDirectory(CSIDL_PROGRAM_FILES);
  Path.AppData := GetShellDirectory(CSIDL_APPDATA);
  Path.Music := GetShellDirectory(CSIDL_MYMUSIC);
  Path.Temp := GetTempDirectory;

  if (Path.AppData <> '?') and SafeDirectoryExists(Path.AppData) then
  begin
    Path.LameXP := Path.AppData + '\MuldeR\LameXP';
    ForceDirectories(Path.LameXP);
  end else begin
    Path.LameXP := Path.AppRoot;
  end;

  DebugHandler.LogFileName := Path.LameXP + '\Debug.log';

  if Path.Music <> '?' then
    DirectoryListBox.Directory := Path.Music
  else
    DirectoryListBox.Directory := Path.Desktop;

  if Path.Music <> '?' then
  begin
    Dialog_AddFiles.InitialDir := Path.Music;
    Dialog_OpenFolder.Directory := Path.Music;
  end else begin
    Dialog_AddFiles.InitialDir := Path.Personal;
    Dialog_OpenFolder.Directory := Path.Personal;
  end;

  Path.Tools := MakeTempFolder(GetTempDirectory,'LameXP_','tmp');

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  with TForm_Data.Create(self, Path.Tools, Path.AppRoot, Path.LameXP, BuildNo) do
  begin
    MakeTool(Tools.LameEnc, 'LameEnc');
    MakeTool(Tools.MP3Dec, 'MPG123Dec');
    MakeTool(Tools.OggEnc_i386, 'OggEnc_i386');
    MakeTool(Tools.OggEnc_SSE2, 'OggEnc_SSE2');
    MakeTool(Tools.OggDec, 'OggDec');
    MakeTool(Tools.AacDec, 'FAAD');
    MakeTool(Tools.AlacDec, 'ALAC');
    MakeTool(Tools.FLAC, 'FLAC');
    MakeTool(Tools.SpeexDec, 'SpeexDec');
    MakeTool(Tools.WavpackDec, 'WavpackDec');
    MakeTool(Tools.MusepackDec, 'MusepackDec');
    MakeTool(Tools.MonkeyDec, 'MonkeyDec');
    MakeTool(Tools.ValibDec, 'ValibDec');
    MakeTool(Tools.ShortenDec, 'ShortenDec');
    MakeTool(Tools.TTADec, 'TTADec');
    MakeTool(Tools.TAKDec, 'TAKDec');
    MakeTool(Tools.MediaInfo, 'MediaInfo');
    MakeTool(Tools.WGet, 'WGet');
    MakeTool(Tools.Volumax, 'Volumax');
    MakeTool(Tools.WUpdate, 'WUpdate');
    MakeTool(Tools.GnuPG, 'GnuPG');
    MakeTool(Tools.Keyring, 'Keyring', 'mykeys.gpg');
    MakeTool(Tools.SelfDel, 'SelfDel');
    Free;
  end;

  Tools.NeroEnc_Enc := nil;
  Tools.NeroEnc_Tag := nil;
  Tools.WMADec := nil;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  with TForm_Languages.Create(self, Path.Tools, LanguageFiles, LanguageFlags) do
  begin
    MakeLanguage('EN', 'English');
    MakeLanguage('DE', 'Deutsch');
    MakeLanguage('EU');
    MakeLanguage('CN', 'Chinese (Simplified)');
    MakeLanguage('EL', 'Greek');
    MakeLanguage('ES', 'Castilian', 'Spanish (Castilian)');
    MakeLanguage('ES', 'America', 'Spanish (Latin America)');
    MakeLanguage('FR', 'French');
    MakeLanguage('HU', 'Hungarian');
    MakeLanguage('IT', 'Italian');
    MakeLanguage('JP', 'Japanese');
    MakeLanguage('NL', 'Dutch');
    MakeLanguage('PL', 'Polish');
    MakeLanguage('RO', 'Romanian');
    MakeLanguage('RU', 'Russian');
    MakeLanguage('SR', 'Serbian (Latin)');
    MakeLanguage('TW', 'Taiwanese/Chinese (Traditional)');
    MakeLanguage('UK', 'Ukrainian');
    Free;
  end;

  InitializeLanguages;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  if ((not Assigned(Tools.NeroEnc_Enc)) or (not Assigned(Tools.NeroEnc_Tag))) and SafeFileExists(Path.AppRoot + '\neroAacEnc.exe') and SafeFileExists(Path.AppRoot + '\neroAacTag.exe') then
  begin
    Tools.NeroEnc_Enc := TLockedFile.Create(Path.AppRoot + '\neroAacEnc.exe');
    Tools.NeroEnc_Tag := TLockedFile.Create(Path.AppRoot + '\neroAacTag.exe');
  end;

  if ((not Assigned(Tools.NeroEnc_Enc)) or (not Assigned(Tools.NeroEnc_Tag))) and SafeFileExists(Path.LameXP + '\neroAacEnc.exe') and SafeFileExists(Path.LameXP + '\neroAacTag.exe') then
  begin
    Tools.NeroEnc_Enc := TLockedFile.Create(Path.LameXP + '\neroAacEnc.exe');
    Tools.NeroEnc_Tag := TLockedFile.Create(Path.LameXP + '\neroAacTag.exe');
  end;

  if ((not Assigned(Tools.NeroEnc_Enc)) or (not Assigned(Tools.NeroEnc_Tag))) and SafeFileExists(Path.System + '\neroAacEnc.exe') and SafeFileExists(Path.System + '\neroAacTag.exe') then
  begin
    Tools.NeroEnc_Enc := TLockedFile.Create(Path.System + '\neroAacEnc.exe');
    Tools.NeroEnc_Tag := TLockedFile.Create(Path.System + '\neroAacTag.exe');
  end;

  if Assigned(Tools.NeroEnc_Enc) and Assigned(Tools.NeroEnc_Tag) then
  begin
    Flags.NeroEncoder := True;
  end;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  DecoderList.Add(TWaveDecoder.Create(nil));
  DecoderList.Add(TMP3Decoder.Create(Tools.MP3Dec));
  DecoderList.Add(TOggDecoder.Create(Tools.OggDec));
  DecoderList.Add(TAACDecoder.Create(Tools.AacDec));
  DecoderList.Add(TALACDecoder.Create(Tools.AlacDec));
  DecoderList.Add(TFLACDecoder.Create(Tools.FLAC));
  DecoderList.Add(TSpeexDecoder.Create(Tools.SpeexDec));
  DecoderList.Add(TWavpackDecoder.Create(Tools.WavpackDec));
  DecoderList.Add(TMusepackDecoder.Create(Tools.MusepackDec));
  DecoderList.Add(TMonkeyDecoder.Create(Tools.MonkeyDec));
  DecoderList.Add(TValibDecoder.Create(Tools.ValibDec));
  DecoderList.Add(TShortenDecoder.Create(Tools.ShortenDec));
  DecoderList.Add(TTTADecoder.Create(Tools.TTADec));
  DecoderList.Add(TTAKDecoder.Create(Tools.TAKDec));

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  if (not Assigned(Tools.WMADec)) and SafeFileExists(Path.AppRoot + '\wmawav.exe') then
  begin
    Tools.WMADec := TLockedFile.Create(Path.AppRoot + '\wmawav.exe');
  end;

  if (not Assigned(Tools.WMADec)) and SafeFileExists(Path.LameXP + '\wmawav.exe') then
  begin
    Tools.WMADec := TLockedFile.Create(Path.LameXP + '\wmawav.exe');
  end;

  if (not Assigned(Tools.WMADec)) and SafeFileExists(Path.Programs + '\NCH Software\Components\wmawav\wmawav.exe') then
  begin
    Tools.WMADec := TLockedFile.Create(Path.Programs + '\NCH Software\Components\wmawav\wmawav.exe');
  end;

  if (not Assigned(Tools.WMADec)) and SafeFileExists(Path.AppData + '\NCH Software\Components\wmawav\wmawav.exe') then
  begin
    Tools.WMADec := TLockedFile.Create(Path.AppData + '\NCH Software\Components\wmawav\wmawav.exe');
  end;

  if Assigned(Tools.WMADec) then
  begin
    DecoderList.Add(TWMADecoder.Create(Tools.WMADec));
    Flags.WMADecoder := True;
  end;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  try
    if SafeFileExists(Path.AppRoot + '\background.bmp') then
    begin
      Background_Form.Image.Picture.LoadFromFile(Path.AppRoot + '\background.bmp');
    end;
  except
    Background_Form.Image.Picture.Bitmap.FreeImage;
  end;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  try
    LoadConfig;
  except
    MyLangBox(self, 'Message_LoadConfigError', MB_ICONERROR or MB_TOPMOST);
  end;

  while IsProcessElevated do
  begin
    case MyLangBox(self, 'Message_ProcessRunningElevated', MB_ABORTRETRYIGNORE or MB_ICONERROR or MB_TOPMOST) of
      IDABORT:
      begin
        Application.Terminate;
        Exit;
      end;
      IDIGNORE:
      begin
        Break;
      end;
    end;
  end;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  if Options.ShellIntegration then
  begin
    try
      CreateFileAssocs;
    except
      MyLangBox(self, 'Message_FileAssocsError', MB_ICONERROR or MB_TOPMOST)
    end;
  end else begin
    Menu_DisableShellIntegration.Checked := True;
  end;

  /////////////////////////////////////////////////////////////////
  ForceApplicationUpdate(crHourGlass);
  /////////////////////////////////////////////////////////////////

  try
    InitRegistry;
  except
    MyLangBox(self, 'Message_SaveHandleError', MB_ICONERROR or MB_TOPMOST);
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  DecoderList.Free;

  if Assigned(Tools.LameEnc) then Tools.LameEnc.Free;
  if Assigned(Tools.MP3Dec) then Tools.MP3Dec.Free;
  if Assigned(Tools.OggEnc_i386) then Tools.OggEnc_i386.Free;
  if Assigned(Tools.OggEnc_SSE2) then Tools.OggEnc_SSE2.Free;
  if Assigned(Tools.OggDec) then Tools.OggDec.Free;
  if Assigned(Tools.AacDec) then Tools.AacDec.Free;
  if Assigned(Tools.AlacDec) then Tools.AlacDec.Free;
  if Assigned(Tools.FLAC) then Tools.FLAC.Free;
  if Assigned(Tools.SpeexDec) then Tools.SpeexDec.Free;
  if Assigned(Tools.WavpackDec) then Tools.WavpackDec.Free;
  if Assigned(Tools.MusepackDec) then Tools.MusepackDec.Free;
  if Assigned(Tools.MonkeyDec) then Tools.MonkeyDec.Free;
  if Assigned(Tools.ValibDec) then Tools.ValibDec.Free;
  if Assigned(Tools.ShortenDec) then Tools.ShortenDec.Free;
  if Assigned(Tools.TTADec) then Tools.TTADec.Free;
  if Assigned(Tools.TAKDec) then Tools.TAKDec.Free;
  if Assigned(Tools.WGet) then Tools.WGet.Free;
  if Assigned(Tools.NeroEnc_Enc) then Tools.NeroEnc_Enc.Free;
  if Assigned(Tools.NeroEnc_Tag) then Tools.NeroEnc_Tag.Free;
  if Assigned(Tools.Volumax) then Tools.Volumax.Free;
  if Assigned(Tools.MediaInfo) then Tools.MediaInfo.Free;
  if Assigned(Tools.WUpdate) then Tools.WUpdate.Free;
  if Assigned(Tools.GnuPG) then Tools.GnuPG.Free;
  if Assigned(Tools.Keyring) then Tools.Keyring.Free;
  if Assigned(Tools.SelfDel) then Tools.SelfDel.Free;

  for i := 0 to LanguageFiles.Count-1 do
  begin
    if Assigned(LanguageFiles.Objects[i]) then TLockedFile(LanguageFiles.Objects[i]).Free;
  end;

  LanguageFiles.Free;
  LanguageFlags.Free;

  try
    CleanRegistry;
  except
    if (not Flags.ShutdownOnTerminate) then
    begin
      MyLangBox(self, 'Message_CleanRegistryError', MB_ICONWARNING or MB_TOPMOST);
    end;
  end;

  CleanTemporaryFiles;

  for i := 1 to 100 do
  begin
    if not SafeDirectoryExists(Path.Tools) then break;
    RemoveDirectory(PAnsiChar(Path.Tools));
    Sleep(100);
  end;

  if SafeDirectoryExists(Path.Tools) and (not Flags.ShutdownOnTerminate) then
  begin
    MyLangBox(self, 'Message_CleanTempFilesError', MB_ICONWARNING or MB_TOPMOST);
  end;

  if Flags.ShutdownOnTerminate then
  begin
    ShutdownComputer;
  end;

  SaveTimerEvents(Format('%s\TimerEvents.log', [Path.LameXP]));
end;

///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfig;
end;

///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.FormActivate(Sender: TObject);
var
  i: Integer;
  Today: Integer;
begin
  if (not Flags.FirstView) or Application.Terminated then
  begin
    Exit;
  end;

  Flags.FirstView := False;
  SetCurrentDir(Path.StartFrom);
  OnResize(Sender);

  {Workaround for Windows 7 taskbar}
  if (ComputerInfo.OS.VersionMajor = 6) and (ComputerInfo.OS.VersionMinor > 0) then
  begin
     InitializeTaskbarAPI;
  end;

  if Flags.UnsupportedDPI then
  begin
    MyLangBox(self, 'Message_UnsupportedDPI', MB_TOPMOST or MB_ICONERROR or MB_TASKMODAL);
  end;

  if (Options.GPLAccepted < 1) then
  begin
    Form_About.FirstRun := True;
    if (Options.GPLAccepted < 0) or (Form_About.ShowModal <> mrOK) then
    begin
      Application.Minimize;
      MyPlaySound('ERROR', False);
      Options.GPLAccepted := -1;
      MyLangBox(self, 'Message_LicenseNotAccepted', MB_TOPMOST or MB_ICONERROR or MB_TASKMODAL);
      try
        if SafeFileExists(Format('%s\Uninstall.exe', [Path.AppRoot])) then
        begin
          WinExec(PAnsiChar(Format('"%s\Uninstall.exe"', [Path.AppRoot])), SW_SHOW);
        end else begin
          ExecWait(Format('"%s" "%s"', [Tools.SelfDel.Location, Application.ExeName]), True, '', ewpHigh);
        end;
      except
        MessageBeep(MB_ICONERROR);
      end;
      Close;
      Application.Terminate;
      Exit;
    end;
    MyPlaySound('WOOHOO', False);
  end;

  {$IF Defined(BUILD_DEBUG)}
  MyLangBox(self, 'Message_WarningPreRelease', 'LameXP ' + VersionStr, MB_ICONERROR or MB_TOPMOST);
  {$IFEND}

  Today := Floor(Date);

  if Today > (VerStrToDate(BuildDate) + 365) then
  begin
    if ID_OK = MyLangBox(self, 'Message_ForceUpdate', MB_OKCANCEL or MB_ICONERROR or MB_TOPMOST) then
    begin
      Menu_CheckforUpdates.OnClick(Sender);
      if Application.Terminated then Exit;
    end else begin
      Close;
      Application.Terminate;
      Exit;
    end;
  end
  else if Options.UpdateReminder then
  begin
    if Options.GPLAccepted > 0 then
    begin
      if Options.LastUpdateCheck < (Today - 6) then
      begin
        if ID_YES = MyLangBox(self, 'Message_UpdateReminder', MB_YESNO or MB_ICONQUESTION or MB_TOPMOST) then
        begin
          Menu_CheckforUpdates.OnClick(Sender);
          if Application.Terminated then Exit;
        end;
      end;
      if not CheckNeroVersion(Lookup(ToolVersionStr, 'NeroAAC', 'N/A')) then
      begin
        if ID_YES = MyLangBoxEx(self, 'Message_NeroAacUpdateSuggestion', '%s' + #10#10 + ShortenURL(NeroDownloadURL, 56), MB_ICONQUESTION or MB_YESNO) then
        begin
          HandleURL(NeroDownloadURL);
        end;
      end;
    end;
  end else begin
    Menu_DisableUpdateReminder.Checked := True;
  end;

  if Flags.WMADecoder then
  begin
    Options.WMADecoderNoWarn := False;
  end else begin
    if (not Options.WMADecoderNoWarn) then
    begin
      if MyLangBox(self, 'Message_WMADecoderInstall', MB_ICONQUESTION or MB_TOPMOST or MB_YESNO) = ID_YES then
      begin
        InstallWMADecoder;
      end else begin
        if MyLangBox(self, 'Message_WMADecoderReminder', MB_ICONWARNING or MB_YESNO or MB_TOPMOST) = ID_NO then
        begin
          Options.WMADecoderNoWarn := True;
          MyLangBox(self, 'Message_WMADecoderManual', MB_ICONINFORMATION or MB_TOPMOST);
        end;
      end;
    end;
  end;

  if (not Options.DetectMetaData) then
  begin
    Menu_DontDetectMetaData.Checked := True;
  end;

  if (not Options.MultiThreading) then
  begin
    Menu_DisableMultiThreading.Checked := True;
  end;

  Menu_NeroOverride_Click(nil);

  if Options.GPLAccepted < 1 then
  begin
    Options.GPLAccepted := 1;
    if MyLangBox(self, 'Message_ShellIntegrationInstall', MB_TOPMOST or MB_ICONQUESTION or MB_YESNO) = IDNO then
    begin
      ToggleShellIntegration(False);
      MyLangBox(self, 'Message_ShellIntegrationManual', MB_TOPMOST or MB_ICONINFORMATION)
    end else begin
      ToggleShellIntegration(True);
    end;
    Menu_DisableShellIntegration.Checked := not Options.ShellIntegration;
    BalloonHint.DefaultBalloonPosition := bpRightDown;
    BalloonHint.ActivateHintPos(Form_Main, Point(50,0), PAnsiChar(LangStr('Message_AdvancedOptionsTitle', self.Name)), PAnsiChar(LangStr('Message_AdvancedOptionsText', self.Name)), MaxInt);
  end;

  if (ParamCount > 1) and SameText(ParamStr(1), '-add') then
  begin
    for i := 2 to ParamCount do
    begin
      FilesToAdd.Add(GetFullPath(ExpandEnvStr(Trim(ParamStr(i)))));
    end;
  end;

  if FilesToAdd.Count > 0 then
  begin
    Timer_AddFiles.Enabled := True;
  end;

  Timer_AddFiles.Tag := 1;
end;

///////////////////////////////////////////////////////////////////////////////

procedure TForm_Main.Button_RemoveClick(Sender: TObject);
var
  i,x: Integer;
  DeleteItems: TObjectList;
begin
  if (ListView.Items.Count = 0) or (ListView.SelCount < 1) then Exit;
  x := ListView.Selected.Index;

  DeleteItems := TObjectList.Create(false);

  for i := 0 to ListView.Items.Count-1 do
  begin
    if ListView.Items.Item[i].Selected then
    begin
      DeleteItems.Add(ListView.Items.Item[i]);
    end;
  end;

  while DeleteItems.Count > 0 do
  begin
    with DeleteItems.Last as TListItem do
    begin
      if Assigned(Data) then TMetaData(Data).Free;
      Delete;
    end;
    DeleteItems.Delete(DeleteItems.Count-1);
  end;

  DeleteItems.Free;

  if ListView.Items.Count > 0 then
  begin
    if x >= ListView.Items.Count then
    begin
      ListView.Items.Item[ListView.Items.Count-1].Selected := True;
    end else begin
      ListView.Items.Item[x].Selected := True;
    end;
  end;

  if ListView.Items.Count <= 0 then
  begin
    Panel_DragIn.Show;
  end;

  UpdateIndex;
  Form_DropBox.Update;
end;

procedure TForm_Main.Button_ClearFiles(Sender: TObject);
var
  i: Integer;
begin
  if ListView.Items.Count > 0 then
  begin
    for i := 0 to ListView.Items.Count-1 do
    begin
      if Assigned(ListView.Items.Item[i]) then TMetaData(ListView.Items.Item[i]).Free;
    end;
  end;

  ListView.Items.Clear;
  Panel_DragIn.Show;
  Form_DropBox.Update;
end;

procedure TForm_Main.Edit1Enter(Sender: TObject);
begin
 ActiveControl := nil;
end;

procedure TForm_Main.FormShow(Sender: TObject);
begin
  Translate(self);

  {$IF Defined(BUILD_DEBUG)}
  Caption := Caption + ' ' + LangStr('Message_PreReleaseCaption', self.Name);
  {$IFEND}

  UpdateTrackBar;
  Trackbar_AlogorithmQuality.OnChange(Sender);
  PageControl.ActivePage := Sheet_Sources;

  if Flags.ShowDropbox then
  begin
    Form_DropBox.Show;
  end;

  if not Flags.FirstView then
  begin
    if FilesToAdd.Count > 0 then
    begin
      Timer_AddFiles.Enabled := True;
    end;
  end;
end;

procedure TForm_Main.DriveComboBox1Click(Sender: TObject);
begin
  ActiveControl := DirectoryListBox;
end;

procedure TForm_Main.Button_EncodeClick(Sender: TObject);
const
  MinSpace_MB = 1024;
var
  FreeSpace: Int64;
  RequiredSpace: Int64;
begin
  {$IF Defined(DISABLE_ENCODE)}
  MyMsgBox('Sorry, encoding is disabled in this special build!', MB_ICONWARNING);
  Exit;
  {$IFEND}

  if Timer_AddFiles.Enabled then
  begin
    MessageBeep(MB_ICONWARNING);
    Exit;
  end;

  if Options.Encoder = ENCODER_NERO then
  begin
    if not CheckNeroVersion(Lookup(ToolVersionStr, 'NeroAAC', 'N/A')) then
    begin
      if ID_YES = MyLangBoxEx(self, 'Message_NeroAacUpdateSuggestion', '%s' + #10#10 + ShortenURL(NeroDownloadURL, 56), MB_ICONWARNING or MB_YESNO) then
      begin
        HandleURL(NeroDownloadURL);
        Exit;
      end;
    end;
  end;  

  RequiredSpace := MinSpace_MB * 1048576;
  FreeSpace := GetFreeDiskspace(Path.Temp);

  if (FreeSpace >= 0) and (FreeSpace < RequiredSpace) then
  begin
    MyLangBoxFmt(self, 'Message_LowDiskspaceWarning', [MinSpace_MB],  MB_ICONWARNING or MB_TOPMOST);
    if MyLangBox(self, 'Message_ChangeTempFolderSuggestion', MB_ICONWARNING or MB_TOPMOST or MB_YESNO) = IDYES then
    begin
      Menu_SetTempFolder.OnClick(Sender);
      Exit;
    end;
  end;

  if ListView.Items.Count < 1 then
  begin
    MyLangBox(self, 'Message_NoSourceFilesOnList', MB_ICONWARNING or MB_TOPMOST);
    Exit;
  end;

  Form_DropBox.Hide;
  EncodeFiles;
end;

procedure TForm_Main.Button5Click(Sender: TObject);
begin
  Close;
end;

procedure TForm_Main.Button_HomeFolderClick(Sender: TObject);
begin
  DirectoryListBox.Directory := Path.Personal;
end;

procedure TForm_Main.Button_DesktopFolderClick(Sender: TObject);
begin
  DirectoryListBox.Directory := Path.Desktop;
end;

procedure TForm_Main.ListViewClick(Sender: TObject);
begin
 if ListView.SelCount > 0
  then ListView.Hint := ListView.Selected.Caption
  else ListView.Hint := '';
end;

procedure TForm_Main.Trackbar_AlogorithmQualityChange(Sender: TObject);
begin
  Label_AlgorithmQuality.Caption := LangStr('Message_LameAlgoQuality.Value_' + IntToStr(Trackbar_AlogorithmQuality.Position), self.Name);
end;

procedure TForm_Main.Button_AboutClick(Sender: TObject);
begin
  if Timer_AddFiles.Enabled or Form_About.Visible then
  begin
    MessageBeep(MB_ICONWARNING);
    Exit;
  end;

  Form_DropBox.Hide;
  Form_About.FirstRun := False;
  Form_About.ShowModal;

  if Flags.ShowDropbox then
  begin
    Form_DropBox.Show;
  end;
end;

procedure TForm_Main.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  KillRunningJobs;

  {$IF Defined(BUILD_DEBUG)}
    FatalAppExit(0,PAnsiChar('[' + E.ClassName + '] ' + E.Message));
  {$ELSE}
    FatalAppExit(0,'LameXP has encountered an unexpected problem and will exit right now!');
  {$IFEND}

  TerminateProcess(GetCurrentProcess, 1);
end;

procedure TForm_Main.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
begin
  if Msg.message = WMsg_Terminate then
  begin
    Handled := True;
    Application.Terminate;
  end
  else if Msg.message = WMsg_Taskbar then
  begin
    Handled := True;
    InitializeTaskbarAPI;
  end else begin
    Handled := False;
  end;  
end;

procedure TForm_Main.TrackBarChange(Sender: TObject);
begin
  UpdateTrackbar;
end;

procedure TForm_Main.Radio_Mode_QualityClick(Sender: TObject);
begin
  Options.EncMode := 0;
  UpdateTrackbar;
end;

procedure TForm_Main.Radio_Mode_AverageClick(Sender: TObject);
begin
  Options.EncMode := 1;
  UpdateTrackbar;
end;

procedure TForm_Main.Radio_Mode_ConstantClick(Sender: TObject);
begin
  Options.EncMode := 2;
  UpdateTrackbar;
end;

procedure TForm_Main.Radio_Encoder_LameClick(Sender: TObject);
begin
  Options.Encoder := ENCODER_LAME;
  UpdateTrackbar;
end;

procedure TForm_Main.Radio_Encoder_VorbisClick(Sender: TObject);
begin
  Options.Encoder := ENCODER_VORBIS;
  UpdateTrackbar;
end;

procedure TForm_Main.Radio_Encoder_WaveClick(Sender: TObject);
begin
  Options.Encoder := ENCODER_WAVE;
  UpdateTrackbar;
end;

procedure TForm_Main.Radio_Encoder_FLACClick(Sender: TObject);
begin
  Options.Encoder := ENCODER_FLAC;
  UpdateTrackbar;
end;

procedure TForm_Main.Edit_Bitrate_MinChange(Sender: TObject);
begin
  If Edit_Bitrate_Min.Value > Edit_Bitrate_Max.Value then
    Edit_Bitrate_Max.Value := Edit_Bitrate_Min.Value;
end;

procedure TForm_Main.Edit_Bitrate_MaxChange(Sender: TObject);
begin
  If Edit_Bitrate_Min.Value > Edit_Bitrate_Max.Value then
    Edit_Bitrate_Min.Value := Edit_Bitrate_Max.Value;
end;

procedure TForm_Main.Check_EnforceBitratesClick(Sender: TObject);
begin
  Edit_Bitrate_Min.Enabled := Check_EnforceBitrates.Checked and Check_EnforceBitrates.Enabled;
  Edit_Bitrate_Max.Enabled := Check_EnforceBitrates.Checked and Check_EnforceBitrates.Enabled;
end;

procedure TForm_Main.Button_NewFolderClick(Sender: TObject);
begin
  MakeNewFolder;
end;

procedure TForm_Main.ListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  Panel_DragIn.Hide;
end;

procedure TForm_Main.WMDropFiles(var Msg: TMessage);
begin
  inherited;
  HandleDroppedFiles(Msg);
end;

procedure TForm_Main.ListViewDblClick(Sender: TObject);
begin
  if Options.DetectMetaData then
  begin
    ListView.PopupMenu.Items[0].OnClick(Sender);
  end else begin
    ListView.PopupMenu.Items[1].OnClick(Sender);
  end;
end;

procedure TForm_Main.Button_EditClick(Sender: TObject);
var
  s: String;
  i: Integer;
begin
  if ListView.SelCount < 1 then Exit;
  i := ListView.Selected.Index;

  while i < ListView.Items.Count do begin
    s := ListView.Items[i].SubItems[0];
    if not MyInputQuery(self, LangStr('Message_EditTitle', self.Name), ExtractFileName(ListView.Items[i].SubItems[1]), s, False, True) then
    begin
      Exit;
    end;  
    ListView.Items[i].SubItems[0] := s;
    if Assigned(ListView.Items[i].Data) then
    begin
      TMetaData(ListView.Items[i].Data).Title := s;
    end;
    i := i + 1;
  end;
end;

procedure TForm_Main.Button_DownClick(Sender: TObject);
var
  i: Integer;
begin
  if ListView.SelCount < 1 then Exit;
  if ListView.Items.Item[ListView.Items.Count-1].Selected then Exit;

  for i := ListView.Items.Count-2 downto 0 do
  begin
    if ListView.Items.Item[i].Selected then
    begin
      SwitchListItems(i, i+1);
    end;
  end;
end;

procedure TForm_Main.Button_UpClick(Sender: TObject);
var
  i: Integer;
begin
  if ListView.SelCount < 1 then Exit;
  if ListView.Items.Item[0].Selected then Exit;

  for i := 1 to ListView.Items.Count-1 do
  begin
    if ListView.Items.Item[i].Selected then
    begin
      SwitchListItems(i, i-1);
    end;
  end;
end;

procedure TForm_Main.Edit_ArtistExit(Sender: TObject);
var
  Edit: TEdit;
  Str: String;
begin
  if Sender.ClassNameIs('TEdit') then
  begin
    Edit := Sender as TEdit;
    Str := FixString(Edit.Text);

    if Str <> Edit.Text then
    begin
      Edit.Text := Str;
      MessageBeep(MB_ICONWARNING);
      Edit.SetFocus;
    end;
  end;
end;

procedure TForm_Main.Edit_GenreChange(Sender: TObject);
begin
  if Edit_Genre.ItemIndex = Edit_Genre.Items.Count - 1 then
  begin
    Edit_Genre.ItemIndex := -1;
  end;
end;

procedure TForm_Main.Check_MetaDataClick(Sender: TObject);
begin
  Edit_Artist.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
  Edit_Album.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
  Edit_Genre.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
  Edit_Year.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
  Edit_Comment.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;

  Label_Artist.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
  Label_Album.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
  Label_Genre.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
  Label_Year.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
  Label_Comment.Enabled := Check_MetaData.Checked and Check_MetaData.Enabled;
end;

procedure TForm_Main.Radio_Encoder_NeroClick(Sender: TObject);
begin
  if Flags.NeroEncoder then
  begin
    if Options.NeroAccepted then
    begin
      Options.Encoder := ENCODER_NERO;
    end
    else with TForm_License.Create(self) do
    begin
      if ShowLicense_Nero = mrOK then
      begin
        Options.Encoder := ENCODER_NERO;
        Options.NeroAccepted := true;
      end else begin
        Options.Encoder := ENCODER_NONE;
        Options.NeroAccepted := false;
      end;
      Free;
    end;
  end else begin
    Options.Encoder := ENCODER_NONE;
    Options.NeroAccepted := false;
    MyLangBox(self, 'Message_NeroAacNotAvailable', 'Nero AAC', MB_ICONWARNING or MB_TOPMOST);
    MyLangBox(self, 'Message_NeroAacInstallInfo', 'Nero AAC', MB_ICONINFORMATION or MB_TOPMOST);
    if ID_YES = MyLangBoxEx(self, 'Message_NeroAacDownloadSuggestion', '%s' + #10#10 + ShortenURL(NeroDownloadURL, 56), 'Nero AAC', MB_ICONQUESTION or MB_YESNO) then
    begin
      HandleURL(NeroDownloadURL);
    end;
  end;
  UpdateTrackbar;
end;

procedure TForm_Main.FormResize(Sender: TObject);
var
  x: Integer;
begin
  PageControl.Width := ClientWidth - 16;
  PageControl.Height := ClientHeight - Button_Encode.Height - 24;

  x := ClientHeight - Button_Encode.Height - 8;
  Button_Encode.Top := x;
  Button_About.Top := x;
  Button_Exit.Top := x;

  Button_About.Left := (ClientWidth - Button_About.Width) div 2;
  Button_Exit.Left := ClientWidth - Button_Exit.Width - 8;

  //////////////////////////////////////////////////////////////////////

  ListView.Columns[0].MinWidth := 50;
  ListView.Columns[0].MaxWidth := 50;
  ListView.Columns[0].Width := 50;

  x := Round((ListView.ClientWidth - ListView.Columns[0].Width) * 0.4);
  ListView.Columns[1].MinWidth := x;
  ListView.Columns[1].MaxWidth := x;
  ListView.Columns[1].Width := x;

  x := ListView.ClientWidth - ListView.Columns[0].Width - ListView.Columns[1].Width;
  ListView.Columns[2].MinWidth := x;
  ListView.Columns[2].MaxWidth := x;
  ListView.Columns[2].Width := x;

  //////////////////////////////////////////////////////////////////////

  x := (Edit_Comment.Width - 16) div 2;

  Edit_Artist.Width := x;
  Edit_Album.Width := x;
  Edit_Album.Left := x + 40;
  Label_Album.Left := x + 40;

  Edit_Genre.Width := x;
  Edit_Year.Width := x;
  Edit_Year.Left := x + 40;
  Label_Year.Left := x + 40;

  Check_Playlist.Left := x + 40;
end;

procedure TForm_Main.Menu_SourcesPlayClick(Sender: TObject);
begin
  if Assigned(ListView.Selected) then ShellExecute(Self.Handle,'open',PAnsiChar(ListView.Selected.SubItems[1]),nil,nil,SW_SHOW);
end;

procedure TForm_Main.Menu_SourcesRemoveClick(Sender: TObject);
begin
  Button_Remove.OnClick(Sender);
end;

procedure TForm_Main.Menu_SourcesClearClick(Sender: TObject);
begin
  Button_Clear.OnClick(Sender);
end;

procedure TForm_Main.Menu_SourcesSort_ByTitleClick(Sender: TObject);
begin
  SortListItemsAlphabetical(False, False);
end;

procedure TForm_Main.Menu_SourcesSort_ByTitleRevClick(Sender: TObject);
begin
  SortListItemsAlphabetical(False, True);
end;

procedure TForm_Main.Menu_SourcesSort_ByFilenameClick(Sender: TObject);
begin
  SortListItemsAlphabetical(True, False);
end;

procedure TForm_Main.Menu_SourcesSort_ByFilenameRevClick(Sender: TObject);
begin
  SortListItemsAlphabetical(True, True);
end;

procedure TForm_Main.Menu_SourcesSort_ByTrackClick(Sender: TObject);
begin
  SortListItemsByTrack(False);
end;

procedure TForm_Main.Menu_SourcesSort_ByTrackRevClick(Sender: TObject);
begin
  SortListItemsByTrack(True);
end;

procedure TForm_Main.WMCopyData(var Msg: TWMCopyData);
var
  Media: String;
begin
  if Msg.CopyDataStruct.dwData = 42 then
  begin
    Media := '';

    if Msg.CopyDataStruct.cbData > 0 then
    begin
      Media := PAnsiChar(Msg.CopyDataStruct.lpData);
      Media := GetFullPath(ExpandEnvStr(Trim(Media)));
    end;

    if Length(Media) > 0 then
    begin
      if Timer_AddFiles.Enabled then
      begin
        Timer_AddFiles.Enabled := False;
      end;  
      
      FilesToAdd.Add(Media);
      
      if Self.Visible and (Timer_AddFiles.Tag > 0) then
      begin
        Timer_AddFiles.Enabled := True;
      end;
    end else begin
      MyLangBox(self, 'Message_AlreadyRunningMessage', MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL);
    end;

    Msg.Result := Integer(True);
    Exit;
  end;

  Msg.Result := Integer(False);
end;

procedure TForm_Main.Timer_AddFilesTimer(Sender: TObject);
var
  i: Integer;
  a: Boolean;
begin
  Timer_AddFiles.Enabled := False;

  if FilesToAdd.Count < 1 then
  begin
    Exit;
  end;

  if Self.Visible and IsWindowEnabled(WindowHandle) then
  begin
    Application.Restore;
    SetForegroundWindow(WindowHandle);
  end;

  FilesToAdd.Sort;
  PageControl.ActivePage := Sheet_Sources;
  ShowStatusPanel(True);

  for i := 0 to FilesToAdd.Count-1 do
  begin
    if GetAsyncKeyState(VK_ESCAPE) <> 0 then Break;

    if Pos('?', FilesToAdd[i]) <> 0 then
    begin
      Continue;
    end;

    if SafeFileExists(FilesToAdd[i]) then
    begin
      AddInputFile(FilesToAdd[i], False, True);
    end
    else if SafeDirectoryExists(FilesToAdd[i]) then
    begin
      a := False;
      AddSourceFolder(FilesToAdd[i], False, a);
    end;
  end;

  FilesToAdd.Clear;
  ShowStatusPanel(False);

  OnResize(self);
  UpdateIndex;
end;

procedure TForm_Main.Menu_SourcesBrowseClick(Sender: TObject);
begin
  if Assigned(ListView.Selected) then WinExec(PAnsiChar(GetWinDirectory + '\explorer.exe /select,"' + ListView.Selected.SubItems[1] + '"'), SW_SHOW);
end;

procedure TForm_Main.Menu_BrowseFolderClick(Sender: TObject);
begin
  ShellExecute(self.Handle, 'explore', PAnsiChar(DirectoryListBox.Directory), nil, nil, SW_SHOW);
end;

procedure TForm_Main.Label_OutdirMouseEnter(Sender: TObject);
begin
  Label_Outdir.Font.Color := clRed;
end;

procedure TForm_Main.Label_OutdirMouseLeave(Sender: TObject);
begin
  Label_Outdir.Font.Color := clWindowText;
end;

procedure TForm_Main.Label_OutdirClick(Sender: TObject);
begin
  DirectoryListBox.PopupMenu.Items[0].OnClick(Sender);
end;

procedure TForm_Main.Menu_ShowDebugInfoClick(Sender: TObject);
begin
  ShowDebugInfo;
end;

procedure TForm_Main.Menu_ShowExceptionLogClick(Sender: TObject);
begin
  ShellExecute(self.WindowHandle, nil, PAnsiChar(DebugHandler.LogFileName), nil, nil, SW_SHOW);
end;

// procedure TForm_Main.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
// begin
//   CheckSynchronize;
// end;

procedure TForm_Main.Check_SaveToSourceDirClick(Sender: TObject);
begin
  if Check_SaveToSourceDir.Checked then
    DirectoryListBox.Font.Color := clGrayText
  else
    DirectoryListBox.Font.Color := clWindowText;

  DirectoryListBox.Enabled := not Check_SaveToSourceDir.Checked;
  JvDriveCombo1.Enabled := not Check_SaveToSourceDir.Checked;
  Button_NewFolder.Enabled := not Check_SaveToSourceDir.Checked;
  Button_HomeFolder.Enabled := not Check_SaveToSourceDir.Checked;
  Button_DesktopFolder.Enabled := not Check_SaveToSourceDir.Checked;
  Label_OutDir.Enabled := not Check_SaveToSourceDir.Checked;
  Check_Playlist.Enabled := not Check_SaveToSourceDir.Checked;
end;

procedure TForm_Main.Menu_DisableShellIntegrationClick(Sender: TObject);
begin
  if Menu_DisableShellIntegration.Checked then
  begin
    if MyLangBox(self, 'Message_ShellIntegrationRemoveWarning', MB_ICONWARNING or MB_OKCANCEL or MB_DEFBUTTON2) = ID_OK then
    begin
      ToggleShellIntegration(False);
      MyLangBox(self, 'Message_ShellIntegrationRemoveDone', MB_ICONINFORMATION);
    end else begin
      Menu_DisableShellIntegration.Checked := False;
    end;
  end else begin
    ToggleShellIntegration(True);
    MyLangBox(self, 'Message_ShellIntegrationCreated', MB_ICONINFORMATION);
  end;
end;

procedure TForm_Main.Menu_CheckforUpdatesClick(Sender: TObject);
begin
  ShowStatusPanel(true);
  UpdateStatusPanel(2, LangStr('Message_CheckUpdatesWait', self.Name));
  CheckUpdate;
  ShowStatusPanel(false);
end;

procedure TForm_Main.Menu_DisableAllSoundsClick(Sender: TObject);
begin
  Options.SoundsEnabled := not Menu_DisableAllSounds.Checked;

  if Menu_DisableAllSounds.Checked then
  begin
    MyLangBox(self, 'Message_SoundDisabledDone', MB_ICONINFORMATION);
  end else begin
    MyLangBox(self, 'Message_SoundEnabledDone', MB_ICONINFORMATION);
  end;
end;

procedure TForm_Main.Menu_SetTempFolderClick(Sender: TObject);
var
  Temp: String;

  procedure DisplayNewTempDir;
  begin
    MyLangBoxEx(self, 'Message_TempFolderChanged', '%s' + #10 + Path.Temp, MB_ICONINFORMATION);
  end;

  function TestNewTempDir(NewDir: String): Boolean;
  const
    b: Byte = 42;
    u = '{15fc2ca6-5942-c9e0-2646-3639e175617a-a8a82a9c}';
  var
    h: THandle;
    c: Cardinal;
  begin
    Result := False;
    h := CreateFile(PAnsiChar(NewDir + '\' + u + '.tmp'), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_ALWAYS, 0, 0);
    if h <> 0 then
    begin
      if WriteFile(h, b, 1, c, nil) then
      begin
        if c = 1 then Result := True;
      end;
      CloseHandle(h);
      DeleteFile(PAnsiChar(NewDir + '\' + u + '.tmp'));
    end;
  end;

begin
  Temp := GetTempDirectory;

  if GetShortPath(Path.Temp) <> GetShortPath(Temp) then
  begin
    if MyLangBox(self, 'Message_TempFolderRestore', MB_ICONQUESTION or MB_YESNO) = ID_YES then
    begin
      CleanTemporaryFiles;
      Path.Temp := Temp;
      DisplayNewTempDir;
      Exit;
    end;
  end;

  Dialog_BrowseTempFolder.Directory := Path.Temp;

  while Dialog_BrowseTempFolder.Execute do
  begin
    if IsFixedDrive(Dialog_BrowseTempFolder.Directory) then
    begin
      if TestNewTempDir(Dialog_BrowseTempFolder.Directory) then
      begin
        CleanTemporaryFiles;
        Path.Temp := Dialog_BrowseTempFolder.Directory;
        DisplayNewTempDir;
        Break;
      end;
    end;
  end;
end;

procedure TForm_Main.Dialog_BrowseTempFolderAcceptChange(Sender: TObject;
  const NewFolder: String; var Accept: Boolean);
begin
  Accept := IsFixedDrive(NewFolder) and (GetShortPath(NewFolder) <> GetShortPath(Path.Tools));
end;

procedure TForm_Main.Menu_EnableNormalizationFilterClick(Sender: TObject);
var
  Peak: Real;
  Temp: String;
  Format: TFormatSettings;
begin
  GetLocaleFormatSettings(2057, Format);
  Format.DecimalSeparator := '.';

  if Menu_EnableNormalizationFilter.Checked then
  begin
    Peak := Options.NormalizationPeak;
    while true do
    begin
      if Peak > 0.0 then Peak := -0.1;
      if Peak < -12.0 then Peak := -12.0;
      Temp := FloatToStrF(Peak, ffFixed, 5, 2, Format);
      if not MyInputQuery(self, LangStr('Message_FilterVolnormTitle', self.Name), LangStr('Message_FilterVolnormQuery', self.Name), Temp, False, True) then
      begin
        Menu_EnableNormalizationFilter.Checked := False;
        Exit;
      end;
      Peak := StrToFloatDef(Temp, 1.0, Format);
      if (Peak <= 0.0) and (Peak >= -12.0) then
      begin
        Options.NormalizationPeak := Peak;
        MyLangBoxFmt(self, 'Message_FilterVolnormEnabled', [FloatToStrF(Peak, ffFixed, 5, 2, Format)], MB_ICONINFORMATION);
        Break;
      end;
    end;
  end else begin
    MyLangBox(self, 'Message_FilterVolnormDisabled', MB_ICONINFORMATION);
  end;
end;

procedure TForm_Main.Menu_DontHideConsoleClick(Sender: TObject);
begin
  if Menu_DontHideConsole.Checked then
  begin
    if MyLangBox(self, 'Message_HideConsoleQuery', MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) <> ID_YES then
    begin
      Menu_DontHideConsole.Checked := False;
    end else begin
      MyLangBox(self, 'Message_HideConsoleDisabled', MB_ICONWARNING);
    end;
  end else begin
    MyLangBox(self, 'Message_HideConsoleEnabled', MB_ICONINFORMATION);
  end;
end;

procedure TForm_Main.Menu_InstallWMADecoderClick(Sender: TObject);
begin
  if MyLangBox(self, 'Message_WMADecoderQuery', MB_ICONQUESTION or MB_TOPMOST or MB_YESNO) = ID_YES then
  begin
    InstallWMADecoder;
  end;
end;

procedure TForm_Main.Menu_DontDetectMetaDataClick(Sender: TObject);
begin
  if Menu_DontDetectMetaData.Checked then
  begin
    if MyLangBox(self, 'Message_MetaDataReadQuery', MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) = ID_YES then
    begin
      MyLangBox(self, 'Message_MetaDataReadDisabled', MB_ICONINFORMATION);
      Options.DetectMetaData := False;
    end else begin
      Menu_DontDetectMetaData.Checked := False;
    end;
  end else begin
    MyLangBox(self, 'Message_MetaDataReadEnabled', MB_ICONINFORMATION);
    Options.DetectMetaData := True;
    if ListView.Items.Count > 0 then
    begin
      Form_Main.Button_Clear.OnClick(Sender);
      MyLangBox(self, 'Message_MetaDataReadReopen', MB_ICONWARNING);
    end;
  end;
end;

procedure TForm_Main.Menu_DisableMultiThreadingClick(Sender: TObject);
begin
  if Menu_DisableMultiThreading.Checked then
  begin
    if MyLangBox(self, 'Message_MultiThreadingQuery', MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) = ID_YES then
    begin
      MyLangBox(self, 'Message_MultiThreadingDisabled', MB_ICONINFORMATION);
      Options.MultiThreading := False;
    end else begin
      Menu_DisableMultiThreading.Checked := False;
    end;
  end else begin
    MyLangBox(self, 'Message_MultiThreadingEnabled', MB_ICONINFORMATION);
    Options.MultiThreading := True;
  end;
end;

procedure TForm_Main.Menu_NeroOverride_Click(Sender: TObject);
var
  Profile: String;

  procedure UpdateMenuItems;
  begin
    Options.NeroOverride := Max(Min(Options.NeroOverride, 3), 0);
    Menu_NeroOverride_Auto.Checked := Options.NeroOverride = 0;
    Menu_NeroOverride_LC.Checked := Options.NeroOverride = 1;
    Menu_NeroOverride_HEv1.Checked := Options.NeroOverride = 2;
    Menu_NeroOverride_HEv2.Checked := Options.NeroOverride = 3;
  end;

begin
  if not Assigned(Sender) then
  begin
    UpdateMenuItems;
    Exit;
  end;

  if not Sender.ClassNameIs('TMenuItem') then
  begin
    UpdateMenuItems;
    Exit;
  end;

  with Sender as TMenuItem do
  begin
    if Checked then
    begin
      Options.NeroOverride := Max(Min(Tag, 3), 0);
      UpdateMenuItems;
      Exit;
    end;

    case Tag of
      1: Profile := 'LC-AAC';
      2: Profile := 'HE-AAC v1';
      3: Profile := 'HE-AAC v2';
    else
      Options.NeroOverride := 0;
      UpdateMenuItems;
      MyLangBox(self, 'Message_NeroOverrideDefault', MB_ICONINFORMATION);
      Exit;
    end;

    if MyLangBoxFmt(self, 'Message_NeroOverrideConfirm', [Profile], MB_ICONWARNING or MB_YESNO or MB_DEFBUTTON2) = IDYES then
    begin
      Options.NeroOverride := Tag;
      UpdateMenuItems;
      MyLangBoxFmt(self, 'Message_NeroOverrideChanged', [Profile], MB_ICONINFORMATION);
    end
    else if Options.NeroOverride <> 0 then
    begin
      Options.NeroOverride := 0;
      UpdateMenuItems;
      MyLangBox(self, 'Message_NeroOverrideDefault', MB_ICONINFORMATION);
    end;
  end;
end;

procedure TForm_Main.Menu_SourcesInfoClick(Sender: TObject);
begin
  if Assigned(ListView.Selected) then
  begin
    if (not Options.DetectMetaData) then
    begin
      MyLangBox(self, 'Message_MetaDataReadWarning', MB_ICONINFORMATION);
    end else begin
      if Assigned(ListView.Selected.Data) then DisplayMetaInfo(TMetaData(ListView.Selected.Data));
    end;
  end;
end;

procedure TForm_Main.Menu_DisableUpdateReminderClick(Sender: TObject);
begin
  if Menu_DisableUpdateReminder.Checked then
  begin
    if MyLangBox(self, 'Message_UpdateReminderQuery', MB_ICONWARNING or MB_OKCANCEL or MB_DEFBUTTON2) = ID_OK then
    begin
      Options.UpdateReminder := False;
      MyLangBox(self, 'Message_UpdateReminderDisabled', MB_ICONINFORMATION);
    end else begin
      Menu_DisableUpdateReminder.Checked := False;
    end;
  end else begin
    Options.UpdateReminder := True;
    MyLangBox(self, 'Message_UpdateReminderEnabled', MB_ICONINFORMATION);
  end;
end;

procedure TForm_Main.Menu_LanguageSelectorClick(Sender: TObject);
begin
  with Sender as TMenuItem do
  begin
    if SwitchLanguage(Caption) then
    begin
      OnShow(Sender);
      Form_DropBox.OnShow(Sender);
      CheckCodepage(False);
      MyLangBoxFmt(self, 'Message_LanguageChanged', [LangStr('Language', 'Translation'), LangStr('Contributor', 'Translation')], MB_ICONINFORMATION or MB_TOPMOST);
    end;
  end;
end;

procedure TForm_Main.Button_AddMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p1,p2: TPoint;
begin
  if Button = mbLeft then
  begin
    p1.X := X; p1.Y := Y;
    p1 := Button_Add.ClientToScreen(p1);

    p2.X := Button_Add.Left; p2.Y := Button_Add.Top;
    p2 := Sheet_Sources.ClientToScreen(p2);

    if (p1.X >= p2.X) and (p1.Y >= p2.Y) and (p1.X <= p2.X + Button_Add.Width) and (p1.Y <= p2.Y + Button_Add.Height) then
    begin
      Popup_AddFiles.Popup(p1.X,p1.Y);
    end;  
  end;  
end;

procedure TForm_Main.Menu_AddFilesClick(Sender: TObject);
begin
  OpenFiles;
end;

procedure TForm_Main.Menu_AddFiles_UnicodeClick(Sender: TObject);
begin
  OpenFilesEx;
end;

procedure TForm_Main.Menu_AddFolderRecursiveClick(Sender: TObject);
var
  a,b: Boolean;
begin
  if not Dialog_OpenFolder.Execute then Exit;
  ShowStatusPanel(True);

  a := False;
  b := AddSourceFolder(Dialog_OpenFolder.Directory, (Sender = Menu_AddFolderRecursive), a);

  ShowStatusPanel(False);
  UpdateIndex;
  FormResize(Sender);

  if a or (not b) then
  begin
    MessageBeep(MB_ICONERROR);
  end;
end;

procedure TForm_Main.Menu_SourcesAddClick(Sender: TObject);
begin
  Popup_AddFiles.Popup(Popup_Open.PopupPoint.X + 25, Popup_Open.PopupPoint.Y + 25);
end;

procedure TForm_Main.Menu_ShowDropBoxClick(Sender: TObject);
var
  p: TPoint;
begin
  p.X := 0;
  p.Y := 0;
  if not Flags.ShowDropbox then
  begin
    Flags.ShowDropbox := True;
    Form_DropBox.Show;
  end;
  SetForegroundWindow(Form_DropBox.Handle);
  BalloonHint.DefaultBalloonPosition := bpLeftUp;
  BalloonHint.ActivateHintPos(Form_DropBox, p, 'Dropbox', LangStr('Message_DropboxInformation', self.Name), MaxInt);
end;

procedure TForm_Main.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
  q: Word;
begin
  if Button <> mbRight then Exit;

  p.X := X; p.Y := Y;
  p := TControl(Sender).ClientToScreen(p);

  q := Word(TrackPopupMenu(Popup_DevTools.Handle, TPM_RETURNCMD, p.X, p.Y, 0, self.Handle, nil));

  if q <> 0 then
  begin
    Popup_DevTools.DispatchCommand(q);
  end;
end;

procedure TForm_Main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Timer_AddFiles.Enabled;
  if not CanClose then MessageBeep(MB_ICONWARNING);
end;

procedure TForm_Main.DirectoryListBoxChange(Sender: TObject);
begin
  SetCurrentDirectory(PAnsiChar(Path.StartFrom));
end;

procedure TForm_Main.Menu_AnalyzeMediaFileClick(Sender: TObject);
begin
  if Dialog_AddFiles.Execute then
  begin
    AnalyzeMediaFiles(Dialog_AddFiles.Files);
  end;
end;

///////////////////////////////////////////////////////////////////////////////

{$IF NOT Defined(BUILD_DEBUG)}
var
  SaveInitProc: Pointer;

procedure TForm_Main.AppOnIdle(Sender: TObject; var Done: Boolean);
begin
  CheckDebugger;
  if (@AppOnIdleProc <> nil) then AppOnIdleProc(Sender, Done);
end;

procedure FormMainInitProc;
begin
  if (SaveInitProc <> nil) then TProcedure(SaveInitProc);
  CheckDebugger;
end;
{$IFEND}

initialization
begin
{$IF NOT Defined(BUILD_DEBUG)}
  SaveInitProc := InitProc;
  InitProc := @FormMainInitProc;
{$IFEND}
  InitialCurrentDir := GetCurrentDir;
end;

///////////////////////////////////////////////////////////////////////////////

end.
