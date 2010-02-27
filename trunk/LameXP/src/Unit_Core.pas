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

unit Unit_Core;

interface

uses
  Windows, SysUtils, Controls, Forms, Classes, StdCtrls, CommDlg, Menus, MuldeR_Toolz,
  Registry,  ShlObj, Contnrs, JclSysInfo, JvComputerInfoEx, JvSpin, Math,
  IniFiles, Unit_Encoder, Unit_RunProcess, Unit_Decoder, Unit_MetaData,
  JVCLVer, Unit_MetaDisplay, Unit_LockedFile, Unit_Translator, JvSimpleXML,
  Messages, ShellAPI, Unit_Win7Taskbar, Unit_LogView;

///////////////////////////////////////////////////////////////////////////////
//{$DEFINE BUILD_DEBUG}
///////////////////////////////////////////////////////////////////////////////

function AddInputFile(const FileName: String; const SkipPlaylists: Boolean; const Verbose: Boolean): Boolean;
function AddSourceFolder(const FolderPath: String; const Recursive: Boolean; var Aborted: Boolean): Boolean;
procedure AnalyzeMediaFiles(const Filenames: TStrings);
function CheckCodepage(const Silent: Boolean): Boolean;
procedure CheckForCompatibilityMode;
procedure CheckJVCLVersion;
function CheckNeroVersion(const VersionStr:String): Boolean;
function CheckOSVersion: Boolean;
function DetectMetaInfo(const FileName: String): TMetaData;
function ImportPlaylist(const FileName:String): Boolean;
function MakeFLACEncoder: TEncoder;
function MakeLameEncoder: TEncoder;
function MakeNeroEncoder: TEncoder;
function MakeOggEncoder: TEncoder;
function SwitchLanguage(const Name: String): Boolean;
procedure CheckDebugger;
procedure CheckUpdate;
procedure CheckVersionInfo;
procedure CleanRegistry;
procedure CleanTemporaryFiles;
procedure CreateFileAssocs;
procedure DetectNeroVersion(var Version: String; var Date: String);
procedure DisplayMetaInfo(const Data: TMetaData);
procedure EncodeFiles;
function FetchUpdateInfo(const Process: TRunProcess; const URL: String; const TempFile:String): Boolean;
procedure HandleDroppedFiles(var Msg: TMessage);
procedure ImportPlaylistASX(const FileName:String);
procedure ImportPlaylistCUE(const FileName:String);
procedure ImportPlaylistM3U(const FileName:String);
procedure ImportPlaylistPLS(const FileName:String);
procedure InitializeLanguages;
procedure InitRegistry;
procedure InstallWMADecoder;
procedure LoadConfig;
procedure MakeNewFolder;
procedure OpenFiles;
procedure OpenFilesEx;
procedure RemoveFileAssocs;
procedure SaveConfig;
procedure SetDefaultLanguage;
procedure ShowDebugInfo;
procedure ShowStatusPanel(const Show: Boolean);
procedure SortListItemsAlphabetical(const ByFilename: Boolean; const Reverse: Boolean);
procedure SortListItemsByTrack(const Reverse: Boolean);
procedure SwitchListItems(const i: Integer; const j: Integer);
procedure ToggleShellIntegration(const Enable: Boolean);
procedure UpdateIndex;
procedure UpdateStatusPanel(const Index: Integer; const Text: String);
procedure UpdateTrackbar;

///////////////////////////////////////////////////////////////////////////////

type
  TEncoderEnum =
  (
    ENCODER_NONE =   -1,
    ENCODER_LAME =    0,
    ENCODER_VORBIS =  1,
    ENCODER_NERO =    2,
    ENCODER_WAVE =    3,
    ENCODER_FLAC =    4
 );

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

uses
  Unit_Main, Unit_Progress, Unit_Utils, Unit_LameEncoder,
  Unit_OggEncoder, Unit_NeroEncoder, Unit_WaveEncoder, Unit_FLACEncoder,
  Unit_NormalizationFilter, Unit_DropBox, Unit_QueryBox;

///////////////////////////////////////////////////////////////////////////////

procedure InitRegistry;
const
  WM_SETTINGCHANGE: UINT = 26;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;

  try
    if Reg.OpenKey('SOFTWARE\MuldeR\LameXP', true) then
    begin
      Reg.WriteString('WindowHandle', Format('0x%.8x', [Form_Main.Handle]));
      Reg.WriteString('CurrentVersion', VersionStr);
      Reg.CloseKey;
    end;

    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', false) then
    begin
      if Reg.GetDataType('EnableBalloonTips') = rdInteger then
      begin
        if Reg.ReadInteger('EnableBalloonTips') <> 1 then
        begin
          Reg.WriteInteger('EnableBalloonTips', 1);
          Reg.CloseKey;
          PostMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, WPARAM(PAnsiChar('EnableBalloonTips')));
          PostMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 0);
          Form_Main.Flags.DisableBalloons := True;
        end;
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;  
end;

procedure CleanRegistry;
var
  Reg: TRegistry;
  Temp: TStringList;
  i: Integer;
begin
  Temp := TStringList.Create;

  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;

  try
    if Reg.OpenKey('SOFTWARE\MuldeR\LameXP', true) then
    begin
      Reg.WriteString('WindowHandle', 'NOT_RUNNING');
      Reg.DeleteValue('Directory');
      Reg.DeleteValue('Version');
      Reg.GetKeyNames(Temp);
      Reg.CloseKey;
    end;

    if Temp.Count > 0 then
    begin
      for i := 0 to Temp.Count-1 do
      begin
        Reg.DeleteKey('SOFTWARE\MuldeR\LameXP\' + Temp[i]);
      end;
    end;

    if Form_Main.Flags.DisableBalloons then
    begin
      if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', false) then
      begin
        Reg.WriteInteger('EnableBalloonTips', 0);
        Reg.CloseKey;
        PostMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, WPARAM(PAnsiChar('EnableBalloonTips')));
        PostMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 0);
      end;
    end;
  finally
    Temp.Free;
    Reg.Free;
  end;  
end;

///////////////////////////////////////////////////////////////////////////////

procedure CreateFileAssocs;
var
  Reg: TRegistry;
  ExistingTypes: TStringList;
  MissingTypes: TStringList;
  i,j: Integer;
  Temp: String;
begin
  SetCursor(Screen.Cursors[crHourGlass]);
  CreateShortcut(Application.ExeName, GetShellDirectory(CSIDL_SENDTO) + '\LameXP - Audio Encoder.lnk', 'LameXP - Audio Encoder Front-End', '-add');

  ExistingTypes := TStringList.Create;
  ExistingTypes.Sorted := True;
  ExistingTypes.Duplicates := dupIgnore;
  ExistingTypes.Add('LameXP.SupportedAudioFile');

  MissingTypes := TStringList.Create;
  MissingTypes.Sorted := True;
  MissingTypes.Duplicates := dupIgnore;

  ///////////////////////////////////////////////////////////////////////////

  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CLASSES_ROOT;

  for i := 0 to Length(FileTypes_Exts)-1 do
  begin
    for j := 0 to Length(FileTypes_Exts[i])-1 do
    begin
      if FileTypes_Exts[i,j] = '' then Continue;
      if Reg.KeyExists('.' + FileTypes_Exts[i,j]) then
      begin
        if Reg.OpenKeyReadOnly('.' + FileTypes_Exts[i,j]) then
        begin
          Temp := '';
          if Reg.GetDataType('') = rdString then
          begin
            Temp := Reg.ReadString('');
          end;
          Reg.CloseKey;
          if Temp <> '' then
          begin
            ExistingTypes.Add(Temp);
            Continue;
          end;
        end;
      end;
      MissingTypes.Add(FileTypes_Exts[i,j])
    end;
  end;

  ///////////////////////////////////////////////////////////////////////////

  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.Access := KEY_ALL_ACCESS;

  for i := 0 to MissingTypes.Count-1 do
  begin
    if Reg.OpenKey('Software\Classes\.' + MissingTypes[i], true) then
    begin
      Reg.WriteString('', 'LameXP.SupportedAudioFile');
      Reg.CloseKey;
    end;
  end;

  for i := 0 to ExistingTypes.Count-1 do
  begin
    if Reg.KeyExists('Software\Classes\' + ExistingTypes[i] + '\shell\lame_xp') then
    begin
      Reg.DeleteKey('Software\Classes\' + ExistingTypes[i] + '\shell\lame_xp');
    end;
    if Reg.OpenKey('Software\Classes\' + ExistingTypes[i] + '\shell\ConvertWithLameXP', true) then
    begin
      Reg.WriteString('', LangStr('Message_ConvertWithLameXP', 'Core'));
      Reg.CloseKey;
    end;
    if Reg.OpenKey('Software\Classes\' + ExistingTypes[i] + '\shell\ConvertWithLameXP\command', true) then
    begin
      Reg.WriteString('', '"' + Application.ExeName + '" -add "%1"');
      Reg.CloseKey;
    end;
  end;

  ///////////////////////////////////////////////////////////////////////////

  ExistingTypes.Free;
  MissingTypes.Free;
  Reg.Free;

  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
end;

///////////////////////////////////////////////////////////////////////////////

procedure RemoveFileAssocs;
var
  Reg: TRegistry;
  Types: TStringList;
  List: TStringList;

  procedure DoRemove(Root: DWORD; Prefix: String);
  var
    i: Integer;
    Temp: String;
  begin
    Types.Clear;

    Reg.RootKey := Root;

    if Reg.OpenKeyReadOnly(Prefix) then
    begin
      Reg.GetKeyNames(Types);
      Reg.CloseKey;
    end else begin
      Exit;
    end;

    if Types.Count > 0 then
    begin
      for i := 0 to Types.Count-1 do
      begin
        Temp := '';

        if Reg.OpenKeyReadOnly(Prefix + Types[i]) then
        begin
          Temp := Reg.ReadString('');
          Reg.CloseKey;
        end;

        Reg.Access := KEY_ALL_ACCESS;

        if SameText(Temp, 'LameXP.SupportedAudioFile') then
        begin
          Reg.DeleteKey(Prefix + Types[i]);
          Continue;
        end;

        if Reg.KeyExists(Prefix + Types[i] + '\shell\ConvertWithLameXP') then
        begin
          Reg.DeleteKey(Prefix + Types[i] + '\shell\ConvertWithLameXP');
        end;

        if Reg.KeyExists(Prefix + Types[i] + '\shell\lame_xp') then
        begin
          Reg.DeleteKey(Prefix + Types[i] + '\shell\lame_xp');
        end;
      end;
    end;

    if Reg.KeyExists(Prefix + 'LameXP.SupportedAudioFile') then
    begin
      Reg.DeleteKey(Prefix + 'LameXP.SupportedAudioFile');
    end;
  end;

begin
  SetCursor(Screen.Cursors[crHourGlass]);
  Reg := TRegistry.Create;
  { Reg.LazyWrite := False; }

  Types := TStringList.Create;
  Types.Sorted := True;
  Types.Duplicates := dupIgnore;

  List := TStringList.Create;
  List.Add(GetShellDirectory(CSIDL_SENDTO) + '\LameXP - Audio Encoder.lnk');
  CleanUp(List);

  try
    DoRemove(HKEY_CURRENT_USER, 'Software\Classes\');
    DoRemove(HKEY_LOCAL_MACHINE, 'Software\Classes\');
  except
    on e: Exception do MyMsgBox(Form_Main, e.Message, MB_TOPMOST or MB_ICONERROR);
  end;

  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);

  Types.Free;
  Reg.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure ToggleShellIntegration(const Enable: Boolean);
begin
  if Enable then
  begin
    ShowStatusPanel(true);
    UpdateStatusPanel(0, LangStr('Message_CreateShellContextMenus', 'Core'));
    try
      CreateFileAssocs;
    except
      MessageBeep(MB_ICONERROR);
      Exit;
    end;
    ShowStatusPanel(false);
    Form_Main.Options.ShellIntegration := True;
  end else begin
    ShowStatusPanel(true);
    UpdateStatusPanel(0, LangStr('Message_RemoveShellContextMenus', 'Core'));
    try
      RemoveFileAssocs;
    except
      MessageBeep(MB_ICONERROR);
      Exit;
    end;
    ShowStatusPanel(false);
    Form_Main.Options.ShellIntegration := False;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure SaveConfig;
var
  Config: TIniFile;
  Section: String;

  procedure WriteSetting(Name: String; Value: String); overload;
  begin
    Config.WriteString(Section, Name, Value);
  end;

  procedure WriteSetting(Name: String; Value: Integer);  overload;
  begin
    Config.WriteInteger(Section, Name, Value);
  end;

  procedure WriteSetting(Name: String; Value: Boolean);  overload;
  begin
    Config.WriteBool(Section, Name, Value);
  end;

begin
  Section := 'LameXP_' + IntToHex(BuildNo,8);
  Config := TIniFile.Create(Form_Main.Path.LameXP + '\Settings.ini');

  WriteSetting('Language', Form_Main.Options.CurrentLanguage);
  WriteSetting('Encoder', Integer(Form_Main.Options.Encoder));
  WriteSetting('Mode', Form_Main.Options.EncMode);
  WriteSetting('Bitrate', Form_Main.Options.Bitrate);
  WriteSetting('Outpath', Form_Main.DirectoryListBox.Directory);
  WriteSetting('SaveToSourceDir', Form_Main.Check_SaveToSourceDir.Checked);
  if(Form_Main.Dialog_AddFiles.FileName <> '') then
  begin
    WriteSetting('Inpath', ExtractDirectory(Form_Main.Dialog_AddFiles.FileName));
  end;
  WriteSetting('Temp', Form_Main.Path.Temp);
  WriteSetting('Quality', Form_Main.Trackbar_AlogorithmQuality.Position);
  WriteSetting('MetaData', Form_Main.Check_MetaData.Checked);
  WriteSetting('MakePlaylist', Form_Main.Check_Playlist.Checked);
  WriteSetting('Restricted', Form_Main.Check_EnforceBitrates.Checked);
  WriteSetting('Minimum', Form_Main.Edit_Bitrate_Min.AsInteger);
  WriteSetting('Maximum', Form_Main.Edit_Bitrate_Max.AsInteger);
  WriteSetting('Samplerate', Form_Main.Combo_Resample.ItemIndex);
  WriteSetting('Channels', Form_Main.Combo_Channels.ItemIndex);
  WriteSetting('NeroTwoPass', Form_Main.Check_NeroTwoPass.Checked);
  WriteSetting('NeroLicenseAgreed', Form_Main.Options.NeroAccepted);
  WriteSetting('GNULicenseAgreed', Form_Main.Options.GPLAccepted);
  WriteSetting('LastUpdate', Form_Main.Options.LastUpdateCheck);
  WriteSetting('SoundsEnabled', Form_Main.Options.SoundsEnabled);
  WriteSetting('SilentMode', Form_Main.Options.SilentMode);
  WriteSetting('ShowConsole', not Form_Main.Menu_DontHideConsole.Checked);
  WriteSetting('FilterNormalize', Form_Main.Menu_EnableNormalizationFilter.Checked);
  WriteSetting('FilterNormalizePeak', Round(Form_Main.Options.NormalizationPeak * 100));
  WriteSetting('WMADecReminder', not Form_Main.Options.WMADecoderNoWarn);
  WriteSetting('DetectMetaData', Form_Main.Options.DetectMetaData);
  WriteSetting('MultiThreading', Form_Main.Options.MultiThreading);
  WriteSetting('NeroProfileOverride', Form_Main.Options.NeroOverride);
  WriteSetting('ShellIntegration', Form_Main.Options.ShellIntegration);
  WriteSetting('UpdateReminder', Form_Main.Options.UpdateReminder);
  WriteSetting('DropboxEnabled', Form_Main.Flags.ShowDropbox);

  Config.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure LoadConfig;
var
  Config: TIniFile;
  Section: String;
  i: Integer;
  Temp: String;

  function ReadSetting(Name: String; Default: Boolean): Boolean; overload;
  begin
    Result := Config.ReadBool(Section, Name, Default);
  end;

  function ReadSetting(Name: String; Default: Integer): Integer; overload;
  begin
    Result := Config.ReadInteger(Section, Name, Default);
  end;

  function ReadSetting(Name: String; Default: String): String; overload;
  begin
    Result := Config.ReadString(Section, Name, Default);
  end;

begin
  Section := 'LameXP_' + IntToHex(BuildNo,8);
  Config := TIniFile.Create(Form_Main.Path.LameXP + '\Settings.ini');

  Form_Main.Options.NeroAccepted := ReadSetting('NeroLicenseAgreed', Form_Main.Options.NeroAccepted);
  Form_Main.Options.GPLAccepted := ReadSetting('GNULicenseAgreed', Form_Main.Options.GPLAccepted);

  Temp := ReadSetting('Language', '');
  if Temp <> '' then
  begin
    if SwitchLanguage(Temp) then
    begin
      if not CheckCodepage(True) then
      begin
        SetDefaultLanguage;
      end;
    end;
  end;

  i := ReadSetting('Encoder', -1);
  if (i = 2) and ((not Form_Main.Flags.NeroEncoder) or (not Form_Main.Options.NeroAccepted)) then i := 0;
  case i of
    0: begin
         Form_Main.Radio_Encoder_Lame.Checked := True;
         Form_Main.Radio_Encoder_Lame.OnClick(Form_Main);
       end;
    1: begin
         Form_Main.Radio_Encoder_Vorbis.Checked := True;
         Form_Main.Radio_Encoder_Vorbis.OnClick(Form_Main);
       end;
    2: begin
         Form_Main.Radio_Encoder_Nero.Checked := True;
         Form_Main.Radio_Encoder_Nero.OnClick(Form_Main);
       end;
    3: begin
         Form_Main.Radio_Encoder_Wave.Checked := True;
         Form_Main.Radio_Encoder_Wave.OnClick(Form_Main);
       end;
    4: begin
         Form_Main.Radio_Encoder_FLAC.Checked := True;
         Form_Main.Radio_Encoder_FLAC.OnClick(Form_Main);
       end;
  end;

  i := ReadSetting('Mode', -1);
  case i of
    0: begin
         Form_Main.Radio_Mode_Quality.Checked := True;
         Form_Main.Radio_Mode_Quality.OnClick(Form_Main);
       end;
    1: begin
         Form_Main.Radio_Mode_Average.Checked := True;
         Form_Main.Radio_Mode_Average.OnClick(Form_Main);
       end;
    2: begin
         Form_Main.Radio_Mode_Constant.Checked := True;
         Form_Main.Radio_Mode_Constant.OnClick(Form_Main);
       end;
  end;

  Form_Main.TrackBar.Position := ReadSetting('Bitrate', Form_Main.TrackBar.Position);
  UpdateTrackbar;

  Temp := ReadSetting('Outpath', '');
  if (Temp <> '') and IsFixedDrive(Temp) and SafeDirectoryExists(Temp) then
  begin
    Form_Main.DirectoryListBox.Directory := Temp;
  end;

  Temp := ReadSetting('Inpath', '');
  if (Temp <> '') and SafeDirectoryExists(Temp) then
  begin
    Form_Main.Dialog_AddFiles.InitialDir := Temp;
  end;

  Temp := ReadSetting('Temp', '');
  if (Temp <> '') and IsFixedDrive(Temp) and SafeDirectoryExists(Temp) then
  begin
    Form_Main.Path.Temp := Temp;
  end;

  Form_Main.Check_SaveToSourceDir.Checked := ReadSetting('SaveToSourceDir', Form_Main.Check_SaveToSourceDir.Checked);
  Form_Main.Check_SaveToSourceDir.OnClick(Form_Main);

  Form_Main.Trackbar_AlogorithmQuality.Position := ReadSetting('Quality', Form_Main.Trackbar_AlogorithmQuality.Position);
  Form_Main.Check_MetaData.Checked := ReadSetting('MetaData', Form_Main.Check_MetaData.Checked);
  Form_Main.Check_MetaData.OnClick(Form_Main);
  Form_Main.Check_Playlist.Checked := ReadSetting('MakePlaylist', Form_Main.Check_Playlist.Checked);
  Form_Main.Edit_Bitrate_Min.AsInteger := ReadSetting('Minimum', Form_Main.Edit_Bitrate_Min.AsInteger);
  Form_Main.Edit_Bitrate_Max.AsInteger := ReadSetting('Maximum', Form_Main.Edit_Bitrate_Max.AsInteger);
  Form_Main.Check_EnforceBitrates.Checked := ReadSetting('Restricted', Form_Main.Check_EnforceBitrates.Checked);
  Form_Main.Combo_Resample.ItemIndex := ReadSetting('Samplerate', Form_Main.Combo_Resample.ItemIndex);
  Form_Main.Combo_Channels.ItemIndex := ReadSetting('Channels', Form_Main.Combo_Channels.ItemIndex);
  Form_Main.Check_NeroTwoPass.Checked := ReadSetting('NeroTwoPass', Form_Main.Check_NeroTwoPass.Checked);
  Form_Main.Options.LastUpdateCheck := ReadSetting('LastUpdate', Form_Main.Options.LastUpdateCheck);
  Form_Main.Options.SoundsEnabled := ReadSetting('SoundsEnabled', Form_Main.Options.SoundsEnabled);
  Form_Main.Options.SilentMode := ReadSetting('SilentMode', Form_Main.Options.SilentMode);
  Form_Main.Menu_DisableAllSounds.Checked := not Form_Main.Options.SoundsEnabled;
  Form_Main.Menu_DontHideConsole.Checked := not ReadSetting('ShowConsole', not Form_Main.Menu_DontHideConsole.Checked);
  Form_Main.Menu_EnableNormalizationFilter.Checked := ReadSetting('FilterNormalize', Form_Main.Menu_EnableNormalizationFilter.Checked);
  Form_Main.Options.WMADecoderNoWarn := not ReadSetting('WMADecReminder', not Form_Main.Options.WMADecoderNoWarn);
  Form_Main.Options.DetectMetaData := ReadSetting('DetectMetaData', Form_Main.Options.DetectMetaData);
  Form_Main.Options.MultiThreading := ReadSetting('MultiThreading', Form_Main.Options.MultiThreading);
  Form_Main.Options.NeroOverride := ReadSetting('NeroProfileOverride', Form_Main.Options.NeroOverride);
  Form_Main.Options.ShellIntegration := ReadSetting('ShellIntegration', Form_Main.Options.ShellIntegration);
  Form_Main.Options.UpdateReminder := ReadSetting('UpdateReminder', Form_Main.Options.UpdateReminder);
  Form_Main.Flags.ShowDropbox := ReadSetting('DropboxEnabled', Form_Main.Flags.ShowDropbox);
  Form_Main.Options.NormalizationPeak := ReadSetting('FilterNormalizePeak', Round(Form_Main.Options.NormalizationPeak * 100)) / 100;

  Config.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure UpdateTrackbar;
  const
    Captions_Lame_Bitrate: array [0..12] of String =
    (
      '32 kbps',
      '48 kbps',
      '56 kbps',
      '64 kbps',
      '80 kbps',
      '96 kbps',
      '112 kbps',
      '128 kbps',
      '160 kbps',
      '192 kbps',
      '224 kbps',
      '256 kbps',
      '320 kbps'
    );
    Captions_Vorbis_Quality: array [0..12] of String =
    (
      '-2 (~32 kbps)',
      '-1 (~48 kbps)',
      '0 (~64 kbps)',
      '1 (~80 kbps)',
      '2 (~96 kbps)',
      '3 (~112 kbps)',
      '4 (~128 kbps)',
      '5 (~160 kbps)',
      '6 (~192 kbps)',
      '7 (~224 kbps)',
      '8 (~256 kbps)',
      '9 (~320 kbps)',
      '10 (~500 kbps)'
    );
    Captions_Vorbis_Bitrate: array [0..15] of String =
    (
      '32 kbps',
      '48 kbps',
      '56 kbps',
      '64 kbps',
      '80 kbps',
      '96 kbps',
      '112 kbps',
      '128 kbps',
      '160 kbps',
      '192 kbps',
      '224 kbps',
      '256 kbps',
      '320 kbps',
      '384 kbps',
      '448 kbps',
      '500 kbps'
    );
    Captions_Nero_Bitrate: array [0..15] of String =
    (
      '32 kbps',
      '48 kbps',
      '56 kbps',
      '64 kbps',
      '80 kbps',
      '96 kbps',
      '112 kbps',
      '128 kbps',
      '160 kbps',
      '192 kbps',
      '224 kbps',
      '256 kbps',
      '320 kbps',
      '384 kbps',
      '448 kbps',
      '500 kbps'
    );
    Captions_Nero_Quality: array [0..20] of String =
    (
      '0.00 / 1.00',
      '0.05 / 1.00',
      '0.10 / 1.00',
      '0.15 / 1.00',
      '0.20 / 1.00',
      '0.25 / 1.00',
      '0.30 / 1.00',
      '0.35 / 1.00',
      '0.40 / 1.00',
      '0.45 / 1.00',
      '0.50 / 1.00',
      '0.55 / 1.00',
      '0.60 / 1.00',
      '0.65 / 1.00',
      '0.70 / 1.00',
      '0.75 / 1.00',
      '0.80 / 1.00',
      '0.85 / 1.00',
      '0.90 / 1.00',
      '0.95 / 1.00',
      '1.00 / 1.00'
    );
    Captions_FLAC: array [0..8] of String =
    (
      '0 / 8',
      '1 / 8',
      '2 / 8',
      '3 / 8',
      '4 / 8',
      '5 / 8',
      '6 / 8',
      '7 / 8',
      '8 / 8'
    );
begin
  Form_Main.TrackBar.Enabled := (Form_Main.Options.Encoder >= ENCODER_LAME) and (Form_Main.Options.Encoder <> ENCODER_WAVE);
  Form_Main.Button_Encode.Enabled := (Form_Main.Options.Encoder >= ENCODER_LAME);
  Form_Main.Radio_Mode_Constant.Enabled := (Form_Main.Options.Encoder = ENCODER_LAME) or (Form_Main.Options.Encoder = ENCODER_NERO);
  Form_Main.Radio_Mode_Quality.Enabled := (Form_Main.Options.Encoder >= ENCODER_LAME) and (Form_Main.Options.Encoder < ENCODER_WAVE);
  Form_Main.Radio_Mode_Average.Enabled := (Form_Main.Options.Encoder >= ENCODER_LAME) and (Form_Main.Options.Encoder < ENCODER_WAVE);
  Form_Main.Label_Quality.Enabled := (Form_Main.Options.Encoder >= ENCODER_LAME);
  Form_Main.Check_MetaData.Enabled := (Form_Main.Options.Encoder >= ENCODER_LAME) and (Form_Main.Options.Encoder <> ENCODER_WAVE);
  Form_Main.Check_MetaData.OnClick(Form_Main);
  Form_Main.Combo_Resample.Enabled := (Form_Main.Options.Encoder = ENCODER_LAME) or (Form_Main.Options.Encoder = ENCODER_VORBIS);
  Form_Main.Combo_Channels.Enabled := (Form_Main.Options.Encoder = ENCODER_LAME);
  Form_Main.Check_NeroTwoPass.Enabled := (Form_Main.Options.Encoder = ENCODER_NERO);
  Form_Main.Check_EnforceBitrates.Enabled := (Form_Main.Options.Encoder = ENCODER_LAME) or (Form_Main.Options.Encoder = ENCODER_VORBIS);
  Form_Main.Trackbar_AlogorithmQuality.Enabled := (Form_Main.Options.Encoder = ENCODER_LAME);
  Form_Main.Label_AlgorithmQuality.Enabled := Form_Main.Trackbar_AlogorithmQuality.Enabled;

  if (Form_Main.Radio_Mode_Constant.Checked) and (not Form_Main.Radio_Mode_Constant.Enabled) and Form_Main.Radio_Mode_Average.Enabled then
  begin
    Form_Main.Radio_Mode_Average.Checked := True;
  end;

  Form_Main.Check_EnforceBitrates.OnClick(Form_Main);

  case Form_Main.Options.Encoder of
    ENCODER_LAME:
    begin
      case Form_Main.Options.EncMode of
        0: begin
             Form_Main.TrackBar.Max := 9;
             Form_Main.Label_Quality.Caption := LangStr('Message_Quality', 'Core') + ' ' + IntToStr(9-Form_Main.TrackBar.Position);
           end;
        1: begin
             Form_Main.TrackBar.Max := Length(Captions_Lame_Bitrate)-1;
             Form_Main.Label_Quality.Caption := Captions_Lame_Bitrate[Form_Main.TrackBar.Position];
           end;
        2: begin
             Form_Main.TrackBar.Max := Length(Captions_Lame_Bitrate)-1;
             Form_Main.Label_Quality.Caption := Captions_Lame_Bitrate[Form_Main.TrackBar.Position];
           end;
       end;
    end;

    ENCODER_VORBIS:
    begin
      case Form_Main.Options.EncMode of
        0: begin
             Form_Main.TrackBar.Max := Length(Captions_Vorbis_Quality)-1;
             Form_Main.Label_Quality.Caption := LangStr('Message_Quality', 'Core') + ' ' + Captions_Vorbis_Quality[Form_Main.TrackBar.Position];
           end;
        1: begin
             Form_Main.TrackBar.Max := Length(Captions_Vorbis_Bitrate)-1;
             Form_Main.Label_Quality.Caption := Captions_Vorbis_Bitrate[Form_Main.TrackBar.Position];
           end;
      end;
    end;

    ENCODER_NERO:
    begin
      case Form_Main.Options.EncMode of
        0: begin
             Form_Main.TrackBar.Max := Length(Captions_Nero_Quality)-1;
             Form_Main.Label_Quality.Caption := LangStr('Message_Quality', 'Core') + ' ' + Captions_Nero_Quality[Form_Main.TrackBar.Position];
           end;
        1: begin
             Form_Main.TrackBar.Max := Length(Captions_Nero_Bitrate)-1;
             Form_Main.Label_Quality.Caption := Captions_Nero_Bitrate[Form_Main.TrackBar.Position];
           end;
        2: begin
             Form_Main.TrackBar.Max := Length(Captions_Nero_Bitrate)-1;
             Form_Main.Label_Quality.Caption := Captions_Nero_Bitrate[Form_Main.TrackBar.Position];
           end;
      end;
    end;

    ENCODER_WAVE:
    begin
      Form_Main.TrackBar.Max := 0;
      Form_Main.Label_Quality.Caption := LangStr('Message_Uncompressed', 'Core');
    end;
    
    ENCODER_FLAC:
    begin
      Form_Main.TrackBar.Max := Length(Captions_FLAC)-1;
      Form_Main.Label_Quality.Caption := Form_Main.Sheet_Compress.Caption + ' ' + Captions_FLAC[Form_Main.TrackBar.Position];
    end;
  else
    Form_Main.Label_Quality.Caption := 'N/A';
  end;

  Form_Main.Options.Bitrate := Form_Main.TrackBar.Position;
end;

///////////////////////////////////////////////////////////////////////////////

procedure UpdateIndex;
var
  i:Integer;
begin
  if Form_Main.ListView.Items.Count > 0 then
  begin
    for i := 0 to Form_Main.ListView.Items.Count-1 do begin
      if i < 9 then
        Form_Main.ListView.Items[i].Caption := ' 0' + IntToStr(i+1)
      else
        Form_Main.ListView.Items[i].Caption := ' ' + IntToStr(i+1);
    end;
  end;

  Form_Main.ListView.Invalidate;
  Form_Main.Update;
end;

///////////////////////////////////////////////////////////////////////////////

function AddInputFile(const FileName: String; const SkipPlaylists: Boolean; const Verbose: Boolean): Boolean;
var
  e:String;
  i,j: Integer;
  b:Boolean;
  m:TMetaData;
begin
  Result := False;
  UpdateStatusPanel(1, ExtractFileName(FileName));

  if not SafeFileExists(FileName) then
  begin
    Exit;
  end;

  if (not SkipPlaylists) then
  begin
    if ImportPlaylist(FileName) then
    begin
      Result := True;
      Exit;
    end;
  end;

  b := False;
  e := AnsiLowerCase(ExtractExtension(FileName));
  m := DetectMetaInfo(FileName);

  for i := 0 to Form_Main.DecoderList.Count-1 do
  begin
    if (m.Container <> '') and (m.Format <> '') then
    begin
      with Form_Main.DecoderList[i] as TDecoder do
      begin
        if IsFormatSupported(m.Container, m.Flavor, m.Format, m.Version, m.Profile) then
        begin
          b := True;
          m.Decoder := i;
        end;
      end;
    end else begin
      with Form_Main.DecoderList[i] as TDecoder do
      begin
        if IsExtensionSupported(e) then
        begin
          b := True;
          m.Decoder := i;
        end;
      end;
    end;
    if b then Break;
  end;

  if (not b) and Verbose then
  begin
    if SameText(m.Container, 'Unknown') then
    begin
      MyLangBoxFmt(Form_Main, 'Message_TypeUnknownError', [ExtractFileName(FileName)], MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
    end else begin
      MyLangBoxFmtEx(Form_Main, 'Message_TypeUnsupportedError', Format('%%s (%s/%s)', [m.Container, m.Format]), [ExtractFileName(FileName)], MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
    end;
  end;

  if b then
  begin
    Result := True;
    for j := 0 to Form_Main.ListView.Items.Count-1 do
    begin
      if SameText(Form_Main.ListView.Items[j].SubItems[1], FileName) then
      begin
        b := False;
        Break;
      end;
    end;
  end;

  if b then with Form_Main.ListView.Items.Add do
  begin
    ImageIndex := 5;
    Caption := ' - ';
    SubItems.Add(m.Title);
    SubItems.Add(FileName);
    Data := m;
  end else begin
    m.Free;
  end;

  Form_DropBox.Update;
end;

///////////////////////////////////////////////////////////////////////////////

procedure ShowDebugInfo;
var
  DebugInfo: TStringList;
  CPU_Type: String;
  CPU_SSE: String;
  OS_Version: String;
  OS_Type: String;
  Filename_NeroAAC: String;
  Filename_WMADec: String;

  procedure Append(var Base:String; const Str:String);
  begin
    if Length(Base) > 0 then
    begin
      Base := Base + ', ' + Str;
    end else begin
      Base := Str;
    end;
  end;

begin
  case Form_Main.ComputerInfo.CPU.CPUType of
    cpuIntel: CPU_Type := 'Intel';
    cpuCyrix: CPU_Type := 'Cyrix';
    cpuAMD: CPU_Type := 'AMD';
    cpuCrusoe: CPU_Type := 'Crusoe';
  else
    CPU_Type := 'Unknown';
  end;

  CPU_SSE := '';
  if sse in Form_Main.ComputerInfo.CPU.SSE then Append(CPU_SSE, 'SSE');
  if sse2 in Form_Main.ComputerInfo.CPU.SSE then Append(CPU_SSE, 'SSE2');
  if sse3 in Form_Main.ComputerInfo.CPU.SSE then Append(CPU_SSE, 'SSE3');
  if ssse3 in Form_Main.ComputerInfo.CPU.SSE then Append(CPU_SSE, 'SSSE3');
  if sse4A in Form_Main.ComputerInfo.CPU.SSE then Append(CPU_SSE, 'SSE4.1');
  if sse4B in Form_Main.ComputerInfo.CPU.SSE then Append(CPU_SSE, 'SSE4.2');
  if sse5 in Form_Main.ComputerInfo.CPU.SSE then Append(CPU_SSE, 'SSE5');
  if avx in Form_Main.ComputerInfo.CPU.SSE then Append(CPU_SSE, 'AVX');
  if Length(CPU_SSE) < 1 then CPU_SSE := 'None';

  case Form_Main.ComputerInfo.OS.OSVersion of
    wvWin95: OS_Version := 'Windows 95';
    wvWin95OSR2: OS_Version := 'Windows 95 (OSR 2)';
    wvWin98: OS_Version := 'Windows 98';
    wvWin98SE: OS_Version := 'Windows 98 SE';
    wvWinME: OS_Version := 'Windows Millenium Edition';
    wvWinNT31: OS_Version := 'Windows NT 3.1';
    wvWinNT35: OS_Version := 'Windows NT 3.5';
    wvWinNT351: OS_Version := 'Windows NT 3.51';
    wvWinNT4: OS_Version := 'Windows NT 4.0';
    wvWin2000: OS_Version := 'Windows 2000';
    wvWinXP: OS_Version := 'Windows XP';
    wvWin2003: OS_Version := 'Windows Server 2003';
    wvWinXP64: OS_Version := 'Windows XP (x64 Edition)';
    wvWin2003R2: OS_Version := 'Windows Server 2003 R2';
    wvWinVista: OS_Version := 'Windows Vista';
    wvWinServer2008: OS_Version := 'Windows Server 2008';
    wvWin7: OS_Version := 'Windows 7';
    wvWinServer2008R2: OS_Version := 'Windows Server 2008 R2';
  else
    OS_Version := 'Unknown';
  end;

  case Form_Main.ComputerInfo.OS.ProductType of
    ptWorkStation: OS_Type := 'Workstation';
    ptServer: OS_Type := 'Server';
    ptAdvancedServer: OS_Type := 'Advanced Server';
    ptPersonal: OS_Type := 'Personal';
    ptProfessional: OS_Type := 'Professional';
    ptDatacenterServer: OS_Type := 'Datacenter Server';
    ptEnterprise: OS_Type := 'Enterprise';
    ptWebEdition: OS_Type := 'Web Edition';
  else
    OS_Type := 'Unknown';
  end;

  if Assigned(Form_Main.Tools.NeroEnc_Enc) then
  begin
    Filename_NeroAAC := Form_Main.Tools.NeroEnc_Enc.Location;
  end else begin
    Filename_NeroAAC := 'N/A';
  end;

  if Assigned(Form_Main.Tools.WMADec) then
  begin
    Filename_WMADec := Form_Main.Tools.WMADec.Location;
  end else begin
    Filename_WMADec := 'N/A';
  end;

  ////////////////////////////////////////////////////////////

  DebugInfo := TStringList.Create;

  with DebugInfo do
  begin
    Add('LameXP ' + Unit_Main.VersionStr + ' - Audio Encoder Front-End');
    Add('Written by LoRd_MuldeR <MuldeR2@GMX.de>');
    Add('');
    Add('--------------------------------------------------------------------------');
    Add('');
    Add('Program Information:');
    Add('� Version: ' + Format('%s, Build %d (%s)', [Unit_Main.VersionStr, Unit_Main.BuildNo, Unit_Main.BuildDate]));
    Add('� Nero AAC Encoder found: ' + BoolToStr(Form_Main.Flags.NeroEncoder, True));
    Add('� WMA File Decoder found: ' + BoolToStr(Form_Main.Flags.WMADecoder, True));
    Add('� LameXP Sounds enabled: ' + BoolToStr(Form_Main.Options.SoundsEnabled, True));
    Add('� Shell Integration enabled: ' + BoolToStr(Form_Main.Options.ShellIntegration, True));
    Add('� Update Reminder enabled: ' + BoolToStr(Form_Main.Options.UpdateReminder, True));
    Add('� Meta Data detection enabled: ' + BoolToStr(Form_Main.Options.DetectMetaData, True));
    Add('� Multi-Threading enabled: ' + BoolToStr(Form_Main.Options.MultiThreading, True));
    Add('� GUI Language: ' + Form_Main.Options.CurrentLanguage);
    Add('');
    Add('Folder Information:');
    Add('� LameXP Executable File: ' + Application.ExeName);
    Add('� LameXP Install Folder: ' + Form_Main.Path.AppRoot);
    Add('� LameXP Data Folder: ' + Form_Main.Path.LameXP);
    Add('� LameXP Tools Folder: ' + Form_Main.Path.Tools);
    Add('� Windows Programs Folder: ' + Form_Main.Path.Programs);
    Add('� Windows System Folder: ' + Form_Main.Path.System);
    Add('� Windows AppData Folder: ' + Form_Main.Path.AppData);
    Add('� Windows Temp Folder: ' + Form_Main.Path.Temp);
    Add('� Nero AAC Encoder: ' + Filename_NeroAAC);
    Add('� WMA File Decoder: ' + Filename_WMADec);
    Add('');
    Add('CPU Information:');
    Add('� Type: ' + CPU_Type);
    Add('� Manufacturer: ' + Form_Main.ComputerInfo.CPU.Manufacturer);
    Add('� Vendor ID: ' +  Form_Main.ComputerInfo.CPU.VendorIDString);
    Add('� Name: ' + Form_Main.ComputerInfo.CPU.Name);
    Add('� Clock Speed: ' + IntToStr(Form_Main.ComputerInfo.CPU.RawFreq) + ' MHz');
    Add('� Family/Model/Stepping: ' + IntToStr(Form_Main.ComputerInfo.CPU.Family) + '/' + IntToStr(Form_Main.ComputerInfo.CPU.Model) + '/' + IntToStr(Form_Main.ComputerInfo.CPU.Stepping));
    Add('� MMX/MMXEX Support: ' + BoolToStr(Form_Main.ComputerInfo.CPU.MMX, True) + '/' + BoolToStr(Form_Main.ComputerInfo.CPU.ExMMX, True));
    Add('� 3DNow/3DNowEx Support: ' + BoolToStr(Form_Main.ComputerInfo.CPU._3DNow, True) + '/' + BoolToStr(Form_Main.ComputerInfo.CPU.Ex3DNow, True));
    Add('� SSE Support: ' + CPU_SSE);
    Add('� 64-Bit Extension: ' + BoolToStr(Form_Main.ComputerInfo.CPU.Is64Bits, True));
    Add('� Processor Count: ' + IntToStr(Form_Main.ComputerInfo.CPU.ProcessorCount));
    Add('� Physical/Logical Cores: ' + IntToStr(Form_Main.ComputerInfo.CPU.PhysicalCore) + '/' + IntToStr(Form_Main.ComputerInfo.CPU.LogicalCore));
    Add('� HyperTreading: ' + BoolToStr(Form_Main.ComputerInfo.CPU.HyperThreadingTechnology, True));
    Add('� L1/L2/L3 Cache: ' + IntToStr(Form_Main.ComputerInfo.CPU.L1DataCache) + '+' + IntToStr(Form_Main.ComputerInfo.CPU.L1CodeCache) + '/' + IntToStr(Form_Main.ComputerInfo.CPU.L2Cache) + '/' + IntToStr(Form_Main.ComputerInfo.CPU.L3Cache) + ' KB');
    Add('');
    Add('OS Information:');
    Add('� Name: ' + OS_Version);
    Add('� Type: ' + OS_Type);
    Add('� Version/Build: ' + IntToStr(Form_Main.ComputerInfo.OS.VersionMajor) + '.' + IntToStr(Form_Main.ComputerInfo.OS.VersionMinor) + '/' + IntToStr(Form_Main.ComputerInfo.OS.VersionBuild));
    Add('� Service Pack: ' + IntToStr(Form_Main.ComputerInfo.OS.ServicePackVersion));
    Add('� Product Name: ' + Form_Main.ComputerInfo.OS.ProductName);
    Add('� Product Version: ' + Form_Main.ComputerInfo.OS.VersionCSDString);
    Add('� Product ID: ' + Form_Main.ComputerInfo.OS.ProductID);
    Add('� Codepage: ' + IntToCodepage(GetACP));
    Add('� Prim. lang. identifier: 0x' + IntToHex(GetUserDefaultLangID and $00FF, 4));
  end;

  ////////////////////////////////////////////////////////////

  with TForm_LogView.Create(nil) do
  begin
    ShowLog(DebugInfo);
    Free;
  end;

  try
    DebugInfo.SaveToFile(Form_Main.Path.Desktop + '\LameXP-SysInfo.txt');
    MyLangBoxEx(Form_Main, '!!! TODO !!!', Format('Information saved to "%s" successfully.', [Form_Main.Path.Desktop + '\LameXP-SysInfo.txt']), MB_ICONINFORMATION or MB_TOPMOST);
  except
    MessageBeep(MB_ICONERROR);
  end;

  DebugInfo.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure AnalyzeMediaFiles(const Filenames: TStrings);
var
  Process: TRunProcess;
  Log: TStringList;
  i: Integer;
begin
  ShowStatusPanel(True);

  Log := TStringList.Create;
  Process := TRunProcess.Create;

  Process.AddToLog('LameXP ' + Unit_Main.VersionStr + ' - Audio Encoder Front-End');
  Process.AddToLog('Written by LoRd_MuldeR <MuldeR2@GMX.de>');

  for i := 0 to Filenames.Count-1 do
  begin
    UpdateStatusPanel(3, ExtractFileName(Filenames[i]));
    SetCursor(Screen.Cursors[crHourglass]);
    Process.AddToLog('');
    Process.AddToLog('--------------------------------------------------------------------------');
    Process.AddToLog('');
    Process.Execute(Format('"%s" "%s"', [Form_Main.Tools.MediaInfo.Location, Filenames[i]]));
  end;

  ShowStatusPanel(False);
  SetCursor(Screen.Cursors[crHourglass]);
  Process.GetLog(Log);

  with TForm_LogView.Create(nil) do
  begin
    ShowLog(Log);
    Free;
  end;

  Process.Free;
  Log.Free;
end;

///////////////////////////////////////////////////////////////////////////////

function CheckOSVersion: Boolean;
var
  x: Integer;
const
  Update = 'Supported OS versions include Windows 2000, Windows XP, Windows Vista and Windows 7.';
begin
  x := 0;
  Result := False;

  while not Result do
  begin
    case Form_Main.ComputerInfo.OS.OSVersion of
      wvWin95, wvWin95OSR2, wvWin98, wvWin98SE, wvWinME:
      begin
        x := MyMsgBox(Form_Main, 'Sorry, LameXP does not officially support Windows 95, Windows 98 or Windows ME !!!' + #10 + Update, MB_ABORTRETRYIGNORE or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
      end;
      wvWinNT31, wvWinNT35, wvWinNT351, wvWinNT4:
      begin
        x := MyMsgBox(Form_Main, 'Sorry, LameXP does not officially support Windows NT 4.0 or older !!!' + #10 + Update, MB_ABORTRETRYIGNORE or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
      end;
    else
      Result := True;
    end;

    if not Result then
    begin
      case x of
        IDIGNORE:
        begin
          Result := True;
        end;
        IDABORT:
        begin
          Break;
        end;
      end;
    end;
  end;

  // Check DPI setting on OS prior to Vista, Vista and newer handles DPI scaling much better
  if Form_Main.ComputerInfo.OS.VersionMajor < 6 then
  begin
    if Screen.PixelsPerInch <> 96 then
    begin
      Form_Main.Flags.UnsupportedDPI := True;
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure CheckUpdate;
const
  URL: array[0..4] of String =
  (
    'http://mulder.dummwiedeutsch.de/update.ver',
    'http://mplayer.somestuff.org/update.ver',
    'http://mulder.brhack.net/update.ver',
    'http://free.pages.at/borschdfresser/update.ver',
    'http://www.tricksoft.de/update.ver'
  );
var
  i: Integer;
  b: boolean;
  Process: TRunProcess;
  TempFile: String;
  Ini: TIniFile;
  UpdateVersion: Integer;
  UpdateWebsite: String;
  DownloadAddress: String;
  DownloadFilename: String;
  DownloadFilecode: String;
  Log: TStringList;
begin
  SetCursor(Screen.Cursors[crHourGlass]);
  TempFile := GetTempFile(Form_Main.Path.Temp, 'LameXP_', 'ini');

  Process := TRunProcess.Create;
  Process.HideConsole := True;

  b := False;

  for i := 0 to High(URL) do
  begin
    if FetchUpdateInfo(Process, URL[i], TempFile) then
    begin
      b := True;
      Break;
    end;
  end;

  if not b then
  begin
    Log := TStringList.Create;
    Process.GetLog(Log);
    Log.Insert(0, '');
    Log.Insert(0, LangStr('Message_UpdateDownloadFailed', 'Core'));
    MessageBox(Form_Main.Handle, Log.GetText, 'LameXP', MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
    Log.Free;
    RemoveFile(TempFile);
    Process.Free;
    Exit;
  end;

  Ini := TIniFile.Create(TempFile);
  try
    UpdateVersion := Ini.ReadInteger('LameXP', 'BuildNo', -1);
    UpdateWebsite := Trim(Ini.ReadString('LameXP', 'DownloadSite', ''));
    DownloadAddress := Trim(Ini.ReadString('LameXP', 'DownloadAddress', ''));
    DownloadFilename := Trim(Ini.ReadString('LameXP', 'DownloadFilename', ''));
    DownloadFilecode := Trim(Ini.ReadString('LameXP', 'DownloadFilecode', ''));
  finally
    Ini.Free;
  end;

  RemoveFile(TempFile);

  if (UpdateVersion = -1) or (UpdateWebsite = '') then
  begin
    MyMsgBox(Form_Main, LangStr('Message_UpdateInvalidInfo', 'Core'), MB_ICONERROR or MB_TOPMOST);
    Process.Free;
    Exit;
  end;

  if UpdateVersion < BuildNo then
  begin
    MyMsgBox(Form_Main, LangStr('Message_UpdateUnknownVersion', 'Core'), MB_ICONERROR or MB_TOPMOST);
    MyMsgBox(Form_Main, LangStr('Message_UpdateErrorPrerelease', 'Core'), MB_ICONWARNING or MB_TOPMOST);
    Process.Free;
    Exit;
  end;

  if UpdateVersion = BuildNo then
  begin
    Form_Main.Options.LastUpdateCheck := Floor(Date);
    MyMsgBox(Form_Main, LangStr('Message_UpdateStillUpToDate', 'Core'), MB_ICONINFORMATION or MB_TOPMOST);
    Process.Free;
    Exit;
  end;

  if idYes = MyMsgBox(Form_Main, LangStr('Message_UpdateNewVersionFound', 'Core') + #10#10 + UpdateWebsite, MB_YESNO or MB_ICONWARNING or MB_TOPMOST) then
  begin
    if((DownloadAddress <> '') and (DownloadFilename <> '') and (DownloadFilecode <> '')) then
    begin
      Application.Minimize;
      Process.JobControl := False;
      if Process.Execute(Format('"%s" "/Location=%s" "/Filename=%s" "/TicketID=%s" "/ToFolder=%s" "/AppTitle=LameXP (Build #%d)"', [Form_Main.Tools.WUpdate.Location, DownloadAddress, DownloadFilename, DownloadFilecode, Form_Main.Path.AppRoot, UpdateVersion])) = procDone then
      begin
        Form_Main.Close;
        Application.Terminate;
      end else begin
        HandleURL(UpdateWebsite);
        Application.Restore;
      end;
    end else begin
      HandleURL(UpdateWebsite);
      Form_Main.Close;
      Application.Terminate;
    end;
  end;

  Process.Free;
end;

function FetchUpdateInfo(const Process: TRunProcess; const URL: String; const TempFile:String): Boolean;
var
  SignFile: String;
begin
  Result := False;
  SignFile := GetTempFile(Form_Main.Path.Temp, 'LameXP_', 'sig');

  if Process.Execute('"' + Form_Main.Tools.WGet.Location + '" --output-document="' + TempFile + '" ' + URL) <> procDone then
  begin
    RemoveFile(TempFile);
    Exit;
  end;

  Process.AddToLog(#10);

  if Process.Execute('"' + Form_Main.Tools.WGet.Location + '" --output-document="' + SignFile + '" ' + URL + '.sig') <> procDone then
  begin
    RemoveFile(TempFile);
    RemoveFile(SignFile);
    Exit;
  end;

  Process.AddToLog(#10);

  if Process.Execute(Format('"%s" --homedir "%s" --keyring "%s" "%s" "%s" ', [Form_Main.Tools.GnuPG.Location, Form_Main.Path.Tools, Form_Main.Tools.Keyring.Location, SignFile, TempFile])) <> procDone then
  begin
    RemoveFile(TempFile);
    RemoveFile(SignFile);
    Exit;
  end;

  Result := True;
  RemoveFile(SignFile);
end;

///////////////////////////////////////////////////////////////////////////////

procedure EncodeFiles;
var
  q: TEncoder;
  i: Integer;
  j: Integer;
  FilesToCreate: TStringList;
  FilterList: TObjectList;
  BaseName: String;
  BaseDir: String;
  PlayList: String;
  Filter: TNormalizationFilter;
  Meta: TMetaData;
  Decoder: TDecoder;
begin
  Form_Progress.ClearJobs;
  FilterList := TObjectList.Create;
  FilesToCreate := TStringList.Create;
  FilesToCreate.CaseSensitive := False;

  if Form_Main.Menu_EnableNormalizationFilter.Checked then
  begin
    Filter := TNormalizationFilter.Create(Form_Main.Tools.Volumax);
    Filter.SetPeak(Form_Main.Options.NormalizationPeak);
    FilterList.Add(Filter);
  end;  

  for i := 0 to Form_Main.ListView.Items.Count-1 do begin
    Meta := TMetaData(Form_Main.ListView.Items[i].Data);

    if (Meta.Decoder < 0) or (Meta.Decoder >= Form_Main.DecoderList.Count) then
    begin
      Continue;
    end;

    Decoder := TDecoder(Form_Main.DecoderList[Meta.Decoder]);

    if Decoder.ClassNameIs('TWaveDecoder') and (FilterList.Count < 1) then
    begin
      Decoder := nil;
    end;

    case Form_Main.Options.Encoder of
      ENCODER_LAME: q := MakeLameEncoder;
      ENCODER_VORBIS: q := MakeOggEncoder;
      ENCODER_NERO: q := MakeNeroEncoder;
      ENCODER_WAVE: q := TWaveEncoder.Create;
      ENCODER_FLAC: q := MakeFlacEncoder;
    else
      q := nil;
    end;

    if not Assigned(q) then Continue;

    q.InputFile := Form_Main.ListView.Items[i].SubItems[1];
    q.Decoder := Decoder;
    q.Filters := FilterList;
    q.ApproxDuration := Meta.Duration;
    q.Meta.Enabled := Form_Main.Check_MetaData.Checked;
    q.Meta.Track := i + 1;

    with Meta do
    begin
      q.Meta.Title := Title;

      if Form_Main.Edit_Artist.Text <> '' then
      begin
        q.Meta.Artist := FixString(Form_Main.Edit_Artist.Text);
      end else begin
        q.Meta.Artist := FixString(Artist);
      end;

      if Form_Main.Edit_Album.Text <> '' then
      begin
        q.Meta.Album := FixString(Form_Main.Edit_Album.Text);
      end else begin
        q.Meta.Album := FixString(Album);
      end;

      if Form_Main.Edit_Genre.Text <> '' then
      begin
        q.Meta.Genre := FixString(Form_Main.Edit_Genre.Text);
      end else begin
        q.Meta.Genre := FixString(Genre);
      end;

      if Form_Main.Edit_Year.AsInteger > 0 then
      begin
        q.Meta.Year := Form_Main.Edit_Year.AsInteger;
      end else begin
        q.Meta.Year := Year;
      end;

      if Form_Main.Edit_Comment.Text <> '' then
      begin
        q.Meta.Comment := FixString(Form_Main.Edit_Comment.Text);
      end else begin
        q.Meta.Comment := FixString(Comment);
      end;
    end;

    j := 1;
    BaseName := RemoveExtension(ExtractFileName(Form_Main.ListView.Items[i].SubItems[1]));

    if Form_Main.Check_SaveToSourceDir.Checked then
      BaseDir := ExtractDirectory(Form_Main.ListView.Items[i].SubItems[1])
    else
      BaseDir := Form_Main.DirectoryListBox.Directory;

    q.OutputFile := BaseDir + '\' + BaseName + q.GetExt;

    while SafeFileExists(q.OutputFile) or (FilesToCreate.IndexOf(q.OutputFile) <> -1) do
    begin
      j := j + 1;
      q.OutputFile := BaseDir + '\' + BaseName + ' (' + IntToStr(j) + ')' + q.GetExt;
    end;

    FilesToCreate.Add(q.OutputFile);
    Form_Progress.AddJob(q);
  end;

  FilesToCreate.Free;

  if Form_Main.Options.MultiThreading then
  begin
    Form_Progress.SetThreads(
      Max(
        Max(Form_Main.ComputerInfo.CPU.ProcessorCount, 1),
        Min(Form_Main.ComputerInfo.CPU.PhysicalCore, Form_Main.ComputerInfo.CPU.LogicalCore)
      )
    );
  end else begin
    Form_Progress.SetThreads(1);
  end;

  Form_Progress.SetConsole(not Form_Main.Menu_DontHideConsole.Checked);

  PlayList := '';
  if Form_Main.Check_Playlist.Checked and (not Form_Main.Check_SaveToSourceDir.Checked) then
  begin
    if (Form_Main.Edit_Artist.Text <> '') and (Form_Main.Edit_Album.Text <> '') then
    begin
      PlayList := Form_Main.DirectoryListBox.Directory + '\' + CheckFileName(Form_Main.Edit_Artist.Text) + ' - ' + CheckFileName(Form_Main.Edit_Album.Text) + '.m3u';
    end else begin
      if Form_Main.Edit_Album.Text <> '' then
      begin
        PlayList := Form_Main.DirectoryListBox.Directory + '\' + CheckFileName(Form_Main.Edit_Album.Text) + '.m3u';
      end else begin
        PlayList := Form_Main.DirectoryListBox.Directory + '\Playlist.m3u';
      end;
    end;
  end;
  Form_Progress.CreatePlaylist := PlayList;
  Form_Progress.FirstShow := True;

  Form_Main.Hide;
  Form_Progress.ShowModal;
  Form_Main.Show;

  FilterList.Free;
  Application.Title := 'LameXP';
end;

///////////////////////////////////////////////////////////////////////////////

function MakeLameEncoder: TEncoder;
const
  QModes: array [0..9] of Integer = (9,8,7,6,5,4,3,2,1,0);
  Bitrates: array [0..12] of Integer = (32,48,56,64,80,96,112,128,160,192,224,256,320);
  AlgModes: array [0..4] of Integer = (9,7,5,2,0);
  SampleRates: array [0..9] of Integer = (0,8000,11025,12000,16000,22050,24000,32000,44100,48000);
var
  Lame: TLameEncoder;
begin
  Lame := TLameEncoder.Create(Form_Main.Tools.LameEnc);
  Lame.Mode := Form_Main.Options.EncMode;

  case Form_Main.Options.EncMode of
    0: Lame.Bitrate := QModes[Form_Main.Trackbar.Position];
    1: Lame.Bitrate := Bitrates[Form_Main.Trackbar.Position];
    2: Lame.Bitrate := Bitrates[Form_Main.Trackbar.Position];
  end;

  Lame.AlgorithmQuality := AlgModes[Form_Main.Trackbar_AlogorithmQuality.Position];
  Lame.ManageBitrate := Form_Main.Check_EnforceBitrates.Checked;

  if (Form_Main.Options.EncMode = 1) or (Form_Main.Options.EncMode = 2) then
  begin
    if Form_Main.Check_EnforceBitrates.Checked and ((Form_Main.Edit_Bitrate_Min.AsInteger > Lame.Bitrate) or (Form_Main.Edit_Bitrate_Max.AsInteger < Lame.Bitrate)) then
    begin
      MyMsgBox(Form_Main, LangStr('Message_BitrateRestrictionViolation', 'Core'), MB_ICONWARNING or MB_TOPMOST);
    end;
    Lame.MinBitrate := Min(Form_Main.Edit_Bitrate_Min.AsInteger, Lame.Bitrate);
    Lame.MaxBitrate := Max(Form_Main.Edit_Bitrate_Max.AsInteger, Lame.Bitrate);
  end else begin
    Lame.MinBitrate := Form_Main.Edit_Bitrate_Min.AsInteger;
    Lame.MaxBitrate := Form_Main.Edit_Bitrate_Max.AsInteger;
  end;

  if Lame.MaxBitrate > 320 then Lame.MaxBitrate := 320;
  Lame.SampleRate := Samplerates[Form_Main.Combo_Resample.ItemIndex];
  Lame.StereoMode := Form_Main.Combo_Channels.ItemIndex;

  Result := Lame;
end;

///////////////////////////////////////////////////////////////////////////////

function MakeOggEncoder: TEncoder;
const
  QModes: array [0..12] of Integer = (-2,-1,0,1,2,3,4,5,6,7,8,9,10);
  Bitrates: array [0..15] of Integer = (32,48,56,64,80,96,112,128,160,192,224,256,320,384,448,500);
  SampleRates: array [0..9] of Integer = (0,8000,11025,12000,16000,22050,24000,32000,44100,48000);
var
  Ogg: TOggEncoder;
begin
  with Form_Main.ComputerInfo do
  begin
    if CPU.MMX and (CPU.CPUType = cpuIntel) and (sse in CPU.SSE) and (sse2 in CPU.SSE) then
    begin
      Ogg := TOggEncoder.Create(Form_Main.Tools.OggEnc_SSE2);
    end else begin
      Ogg := TOggEncoder.Create(Form_Main.Tools.OggEnc_i386);
    end;
  end;

  Ogg.Mode := Form_Main.Options.EncMode;

  case Form_Main.Options.EncMode of
    0: Ogg.Bitrate := QModes[Form_Main.Trackbar.Position];
    1: Ogg.Bitrate := Bitrates[Form_Main.Trackbar.Position];
  end;

  Ogg.ManageBitrate := Form_Main.Check_EnforceBitrates.Checked;

  if (Form_Main.Options.EncMode = 1) then
  begin
    if Form_Main.Check_EnforceBitrates.Checked and ((Form_Main.Edit_Bitrate_Min.AsInteger > Ogg.Bitrate) or (Form_Main.Edit_Bitrate_Max.AsInteger < Ogg.Bitrate)) then
    begin
      MyMsgBox(Form_Main, LangStr('Message_BitrateRestrictionViolation', 'Core'), MB_ICONWARNING or MB_TOPMOST);
    end;
    Ogg.MinBitrate := Min(Form_Main.Edit_Bitrate_Min.AsInteger, Ogg.Bitrate);
    Ogg.MaxBitrate := Max(Form_Main.Edit_Bitrate_Max.AsInteger, Ogg.Bitrate);
  end else begin
    Ogg.MinBitrate := Form_Main.Edit_Bitrate_Min.AsInteger;
    Ogg.MaxBitrate := Form_Main.Edit_Bitrate_Max.AsInteger;
  end;

  Ogg.SampleRate := Samplerates[Form_Main.Combo_Resample.ItemIndex];

  Result := Ogg;
end;

///////////////////////////////////////////////////////////////////////////////

function MakeFLACEncoder: TEncoder;
var
  FLAC: TFLACEncoder;
begin
  FLAC := TFLACEncoder.Create(Form_Main.Tools.FLAC);
  FLAC.CompressionLevel := Form_Main.TrackBar.Position;
  Result := FLAC;
end;

///////////////////////////////////////////////////////////////////////////////

function MakeNeroEncoder: TEncoder;
const
  QModes: array [0..20] of Double = (0.00,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.65,0.70,0.75,0.80,0.85,0.90,0.95,1.00);
  Bitrates: array [0..15] of Integer = (32,48,56,64,80,96,112,128,160,192,224,256,320,384,448,500);
var
  Nero: TNeroEncoder;
begin
  Nero := TNeroEncoder.Create(Form_Main.Tools.NeroEnc_Enc, Form_Main.Tools.NeroEnc_Tag);
  Nero.Mode := Form_Main.Options.EncMode;
  Nero.TwoPass := Form_Main.Check_NeroTwoPass.Checked;
  Nero.Profile := Form_Main.Options.NeroOverride;

  case Form_Main.Options.EncMode of
    0: Nero.Quality := QModes[Form_Main.Trackbar.Position];
    1: Nero.Bitrate := Bitrates[Form_Main.Trackbar.Position];
    2: Nero.Bitrate := Bitrates[Form_Main.Trackbar.Position];
  end;

  Result := Nero;
end;

///////////////////////////////////////////////////////////////////////////////

procedure SwitchListItems(const i: Integer; const j: Integer);
var
  s,t: String;
  b: Boolean;
  p: Pointer;
begin
  if Form_Main.ListView.Items[i].SubItems.Count < 2 then Exit;
  if Form_Main.ListView.Items[j].SubItems.Count < 2 then Exit;

  s := Form_Main.ListView.Items[j].SubItems[0];
  t := Form_Main.ListView.Items[j].SubItems[1];
  b := Form_Main.ListView.Items[j].Selected;
  p := Form_Main.ListView.Items[j].Data;

  Form_Main.ListView.Items[j].SubItems[0] := Form_Main.ListView.Items[i].SubItems[0];
  Form_Main.ListView.Items[j].SubItems[1] := Form_Main.ListView.Items[i].SubItems[1];
  Form_Main.ListView.Items[j].Selected := Form_Main.ListView.Items[i].Selected;
  Form_Main.ListView.Items[j].Data := Form_Main.ListView.Items[i].Data;

  Form_Main.ListView.Items[i].SubItems[0] := s;
  Form_Main.ListView.Items[i].SubItems[1] := t;
  Form_Main.ListView.Items[i].Selected := b;
  Form_Main.ListView.Items[i].Data := p;
end;

///////////////////////////////////////////////////////////////////////////////

procedure SortListItemsAlphabetical(const ByFilename: Boolean; const Reverse: Boolean);
var
  i: Integer;
  j: Integer;
  b: Boolean;
  q: Integer;
begin
  if ByFilename then q := 1 else q := 0;

  for i := 0 to Form_Main.ListView.Items.Count-1 do
  begin
    b := False;
    for j := 0 to Form_Main.ListView.Items.Count-2 - i do
    begin
      if Form_Main.ListView.Items[j].SubItems.Count < 2 then Continue;
      if Form_Main.ListView.Items[j+1].SubItems.Count < 2 then Continue;
      if Reverse then
      begin
        if AnsiCompareStr(Form_Main.ListView.Items[j].SubItems[q], Form_Main.ListView.Items[j+1].SubItems[q]) < 0 then
        begin
          SwitchListItems(j, j+1);
          b := True;
        end;
      end else begin
        if AnsiCompareStr(Form_Main.ListView.Items[j].SubItems[q], Form_Main.ListView.Items[j+1].SubItems[q]) > 0 then
        begin
          SwitchListItems(j, j+1);
          b := True;
        end;
      end;
    end;
    if not b then break;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure SortListItemsByTrack(const Reverse: Boolean);
var
  i: Integer;
  j: Integer;
  b: Boolean;
begin
  for i := 0 to Form_Main.ListView.Items.Count-1 do
  begin
    b := False;
    for j := 0 to Form_Main.ListView.Items.Count-2 - i do
    begin
      if not Assigned(Form_Main.ListView.Items[j].Data) then Continue;
      if not Assigned(Form_Main.ListView.Items[j+1].Data) then Continue;
      if Reverse then
      begin
        if TMetaData(Form_Main.ListView.Items[j].Data).Track < TMetaData(Form_Main.ListView.Items[j+1].Data).Track then
        begin
          SwitchListItems(j, j+1);
          b := True;
        end;
      end else begin
        if TMetaData(Form_Main.ListView.Items[j].Data).Track > TMetaData(Form_Main.ListView.Items[j+1].Data).Track then
        begin
          SwitchListItems(j, j+1);
          b := True;
        end;
      end;
    end;
    if not b then break;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure CleanTemporaryFiles;
begin
  CleanUp(SearchFiles(Form_Main.Path.Temp + '\LameXP_????????.wav', True));
  CleanUp(SearchFiles(Form_Main.Path.Temp + '\LameXP_????????.log', True));
  CleanUp(SearchFiles(Form_Main.Path.Temp + '\LameXP_????????.ini', True));
end;

///////////////////////////////////////////////////////////////////////////////

procedure InstallWMADecoder;
const
  URL: String = 'http://www.nch.com.au/components/wmawav.exe';
var
  Process: TRunProcess;
  TempDir: String;
  TempFile: String;
  Log: TStringList;

  b: Boolean;
  p: PAnsiChar;
  i: Integer;
  s: String;

  procedure DeleteTemp;
  var
    i: Integer;
  begin
    for i := 1 to 100 do
    begin
      if not SafeDirectoryExists(TempDir) then break;
      RemoveFile(TempFile);
      RemoveDirectory(PAnsiChar(TempDir));
      Sleep(100);
    end;
  end;

begin
  TempDir := MakeTempFolder(GetTempDirectory, 'LameXP_', 'tmp');
  TempFile := TempDir + '\wmawav.exe';

  Process := TRunProcess.Create;
  Process.HideConsole := True;

  ShowStatusPanel(True);
  UpdateStatusPanel(4, LangStr('Message_WMADecInstallWait', 'Core'));
  SetCursor(Screen.Cursors[crHourGlass]);

  if Process.Execute('"' + Form_Main.Tools.WGet.Location + '" --output-document="' + TempFile + '" ' + URL) <>  procDone then
  begin
    ShowStatusPanel(False);
    MyMsgBox(Form_Main, LangStr('Message_WMADecInstallDownloadFailed', 'Core'), MB_ICONERROR + MB_TOPMOST);
    Process.Free;
    DeleteTemp;
    Exit;
  end;

  b := False;
  Log := TStringList.Create;
  Process.GetLog(Log);

  if Log.Count > 0 then
  begin
    for i := 0 to Log.Count-1 do
    begin
      s := AnsiLowerCase(Log[i]);
      if pos('response', s) = 0 then Continue;
      if pos(' 301 ', s) <> 0 then Break;
      if pos(' 302 ', s) <> 0 then Break;
      if pos(' 303 ', s) <> 0 then Break;
      if pos(' 400 ', s) <> 0 then Break;
      if pos(' 401 ', s) <> 0 then Break;
      if pos(' 402 ', s) <> 0 then Break;
      if pos(' 403 ', s) <> 0 then Break;
      if pos(' 404 ', s) <> 0 then Break;
      if pos(' 200 ', s) <> 0 then b := True;
    end;
  end;

  if (not b) then
  begin
    Log.Insert(0, '');
    Log.Insert(0, LangStr('Message_WMADecInstallDownloadFailed', 'Core'));
    p := Log.GetText;
    MessageBox(Form_Main.Handle, p, 'LameXP', MB_ICONERROR or MB_TOPMOST);
    StrDispose(p);
    Log.Free;
    Process.Free;
    DeleteTemp;
    ShowStatusPanel(False);
    Exit;
  end;

  Log.Free;

  if Process.Execute('"' + TempFile + '"') = procDone then
  begin
    MyMsgBox(Form_Main, LangStr('Message_WMADecInstallDone', 'Core'), MB_ICONWARNING + MB_TOPMOST);
  end else begin
    MyMsgBox(Form_Main, LangStr('Message_WMADecInstallError', 'Core'), MB_ICONERROR + MB_TOPMOST);
  end;

  Process.Free;
  DeleteTemp;

  ShowStatusPanel(False);
end;

///////////////////////////////////////////////////////////////////////////////

function ImportPlaylist(const FileName:String): Boolean;
type
  TPlaylistImporter = procedure(const FileName: String);
var
  Extension: String;

  procedure CheckPlaylistExtension(const CurrentExt: String; const Importer: TPlaylistImporter);
  begin
    if SameText(Extension, CurrentExt) then
    begin
      Importer(FileName);
      Result := True;
    end;
  end;

begin
  Result := False;
  Extension := ExtractExtension(FileName);

  CheckPlaylistExtension('m3u', ImportPlaylistM3U);
  CheckPlaylistExtension('pls', ImportPlaylistPLS);
  CheckPlaylistExtension('asx', ImportPlaylistASX);
  CheckPlaylistExtension('cue', ImportPlaylistCUE);
end;

///////////////////////////////////////////////////////////////////////////////

procedure ImportPlaylistM3U(const FileName: String);
var
  List: TStringList;
  Str: String;
  i: Integer;
  Found: Boolean;
begin
  Found := False;
  List := TStringList.Create;

  try
    List.LoadFromFile(FileName);
  except
    MyMsgBox(Form_Main, Format(LangStr('Message_PlaylistOpenFailed', 'Core'), [FileName]), MB_ICONERROR + MB_TOPMOST);
    List.Free;
    Exit;
  end;

  if List.Count > 0 then
  begin
    for i := 0 to List.Count-1 do
    begin
      Str := List[i];
      if Str[1] = '#' then Continue;

      Str := ExpandPath(ExtractDirectory(FileName), Str);

      if SafeFileExists(Str) then
      begin
        if AddInputFile(Str, True, False) then Found := True;
      end;
    end;
  end;

  if (not Found) then
  begin
    MyMsgBox(Form_Main, Format(LangStr('Message_PlaylistNoFilesFound', 'Core'), [FileName]), 'LameXP', MB_ICONERROR + MB_TOPMOST);
  end;

  List.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure ImportPlaylistPLS(const FileName: String);
var
  List: TINIFile;
  Count: Integer;
  Str: String;
  i: Integer;
  Found: Boolean;
begin
  Found := False;
  Count := 999;

  try
    List := TINIFile.Create(FileName);
  except
    MyMsgBox(Form_Main, Format(LangStr('Message_PlaylistOpenFailed', 'Core'), [FileName]), MB_ICONERROR or MB_TOPMOST);
    Exit;
  end;

  Count := List.ReadInteger('playlist', 'NumberOfEntries', Count);

  for i := 1 to Count do
  begin
    Str := List.ReadString('playlist', 'File' + IntToStr(i), '?');

    if Str = '?' then
    begin
      Continue;
    end;

    Str := ExpandPath(ExtractDirectory(FileName), Str);

    if SafeFileExists(Str) then
    begin
      if AddInputFile(Str, True, False) then Found := True;
    end;
  end;

  if (not Found) then
  begin
    MyMsgBox(Form_Main, Format(LangStr('Message_PlaylistNoFilesFound', 'Core'), [FileName]), MB_ICONERROR or MB_TOPMOST);
  end;

  List.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure ImportPlaylistASX(const FileName: String);
var
  List: TJvSimpleXML;
  Str: String;
  i,j: Integer;
  Found: Boolean;
begin
  Found := False;
  List := TJvSimpleXML.Create(Form_Main);

  try
    List.LoadFromFile(FileName);
  except
    on e:Exception do
    begin
      MyMsgBox(Form_Main, Format(LangStr('Message_PlaylistOpenFailed', 'Core'), [FileName]) + #10#10 + '"' + e.Message + '"', 'LameXP', MB_ICONERROR or MB_TOPMOST);
      List.Free;
      Exit;
    end;
  end;

  if not SameText(List.Root.Name, 'asx') then
  begin
    MyMsgBox(Form_Main, Format(LangStr('Message_PlaylistInvalidASX', 'Core'), [FileName]), MB_TOPMOST or MB_ICONERROR);
    List.Free;
    Exit;
  end;

  for i := 0 to List.Root.Items.Count-1 do
  begin
    if SameText(List.Root.Items[i].Name, 'entry') then
    begin
      for j := 0 to List.Root.Items[i].Items.Count-1 do
      begin
        if SameText(List.Root.Items[i].Items[j].Name, 'ref') then
        begin
          Str := List.Root.Items[i].Items[j].Properties.Value('href','');
          if Str <> '' then
          begin
            Str := ExpandPath(ExtractDirectory(FileName), Str);
            if SafeFileExists(Str) then
            begin
              if AddInputFile(Str, True, False) then Found := True;
            end;
          end;
        end;
      end;
    end;
  end;

  if (not Found) then
  begin
    MyMsgBox(Form_Main, Format(LangStr('Message_PlaylistNoFilesFound', 'Core'), [FileName]), MB_ICONERROR or MB_TOPMOST);
  end;

  List.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure ImportPlaylistCUE(const FileName: String);
var
  Sheet,SubStr: TStringList;
  Line,Str: String;
  i,j: Integer;
  Found,b: Boolean;
begin
  Sheet := TStringList.Create;

  try
    Sheet.LoadFromFile(FileName);
  except
    MyMsgBox(Form_Main, Format(LangStr('Message_CuesheetOpenFailed', 'Core'), [FileName]), 'LameXP', MB_ICONERROR + MB_TOPMOST);
    Sheet.Free;
    Exit;
  end;

  Found := False;
  SubStr := TStringList.Create;

  if Sheet.Count > 0 then
  begin
    for i := 0 to Sheet.Count-1 do
    begin
      Line := Sheet[i];
      SubStr.Clear;
      b := false;
      Str := '';

      if Length(Line) < 1 then Continue;
      for j := 1 to Length(Line) do
      begin
        if Line[j] = '"' then
        begin
          b := not b;
          Continue;
        end;
        if (Line[j] = ' ') and (not b) then
        begin
          if Length(Str) > 0 then SubStr.Add(Str);
          Str := '';
          Continue;
        end;
        Str := Str + Line[j];
      end;

      if Length(Str) > 0 then SubStr.Add(Str);

      if (SubStr.Count < 3) or (not SameText('FILE', SubStr[0])) then
      begin
        Continue;
      end;

      if (not SameText('AIFF', SubStr[2])) and (not SameText('WAVE', SubStr[2])) and (not SameText('MP3', SubStr[2])) and (not SameText('BINARY', SubStr[2])) and (not SameText('MOTOROLA', SubStr[2])) then
      begin
        Continue;
      end;

      Str := ExpandPath(ExtractDirectory(FileName), SubStr[1]);

      if SafeFileExists(Str) then
      begin
        if AddInputFile(Str, True, False) then Found := True;
      end else begin
        MyMsgBox(Form_Main, Format(LangStr('Message_CuesheetMissingFile', 'Core'), [Str]), MB_ICONWARNING or MB_TOPMOST);
      end;
    end;
  end;

  if (not Found) then
  begin
    MyMsgBox(Form_Main, Format(LangStr('Message_CuesheetNoFilesFound', 'Core'), [FileName]), MB_ICONERROR or MB_TOPMOST);
  end;

  SubStr.Free;
  Sheet.Free;
end;

///////////////////////////////////////////////////////////////////////////////

function GenreToStr(Text: String): String;
var
  i: Integer;
begin
  if pos('Genre_', Text) = 1 then
  begin
    i := StrToIntDef(Copy(Text, 7, Length(Text)), -1);
    if i >= 0 then
    begin
      Result := Form_Main.Edit_Genre.Items[i];
      Exit;
    end;
  end;

  Result := Text;
end;

///////////////////////////////////////////////////////////////////////////////

function DetectMetaInfo(const FileName: String): TMetaData;
type
  TSection = (Section_Other, Section_General, Section_Audio);
var
  Process: TRunProcess;
  Log: TStringList;
  Line: String;
  Name: String;
  Value: String;
  Section: TSection;
  i,x: Integer;
  {$IF Defined(BUILD_DEBUG)}
  p:PAnsiChar;
  {$IFEND}

  function DurationToInt(Duration: String):Integer;
  var
    i,t: Integer;
    s: String;
    x: Byte;
  begin
    Result := 0; t := 0; s := '';

    for i := 1 to Length(Duration) do
    begin
      x := Ord(Duration[i]);

      if (x = $0) or (x = $20) then
      begin
        Continue;
      end;
      if (x >= $30) and (x <= $39) then
      begin
        t := (10 * t) + (x - $30);
        Continue;
      end;

      s := s + Chr(x);

      if SameText(s, 'h') then
      begin
        Result := Result + (t * 3600);
        t := 0; s := '';
      end
      else if SameText(s, 'mn') then
      begin
        Result := Result + (t * 60);
        t := 0; s := '';
      end
      else if SameText(s, 's') then
      begin
        Result := Result + t;
        t := 0; s := '';
      end;
    end;
  end;

  function Update(Current: String; NewValue: String):String; overload;
  begin
    if (Current = '') and (NewValue <> '') then
    begin
      Result := NewValue;
      Exit;
    end;
    Result := Current;
  end;

  function Update(Current: Integer; NewValue: Integer):Integer; overload;
  begin
    if (Current = 0) and (NewValue <> 0) then
    begin
      Result := NewValue;
      Exit;
    end;
    Result := Current;
  end;

  function IsPrefix(SubStr: String; S:String): Boolean;
  begin
    Result := SameText(Copy(S, 1, Length(SubStr)), SubStr);
  end;

begin
  Result := TMetaData.Create;
  Section := Section_Other;

  if (not Form_Main.Options.DetectMetaData) then
  begin
    Result.Title := FilenameToTitle(FileName);
    Exit;
  end;

  Process := TRunProcess.Create;
  Process.HideConsole := True;

  SetCursor(Screen.Cursors[crHourGlass]);

  if Process.Execute('"' + Form_Main.Tools.MediaInfo.Location + '" "' + FileName + '"') <> procDone then
  begin
    Result.Title := FilenameToTitle(FileName);
    Process.Free;
    Exit;
  end;

  Log := TStringList.Create;
  Process.GetLog(Log);

  {$IF Defined(BUILD_DEBUG)}
  p := Log.GetText;
  MessageBox(Form_Main.Handle, p, 'LameXP', MB_TOPMOST);
  StrDispose(p);
  {$IFEND}

  if Log.Count > 0 then
  begin
    for i := 0 to Log.Count-1 do
    begin
      Line := Trim(Log[i]);

      if Length(Line) < 1 then
      begin
        Continue;
      end;

      x := Pos(':', Line);

      if x < 1 then
      begin
        if IsPrefix('General', Line) then
        begin
          Section := Section_General;
          Result.AddInfo(Format('[ %s ]', [Line]), '');
          Continue;
        end;
        if SameText('Audio', Line) or SameText('Audio #1', Line) then
        begin
          Section := Section_Audio;
          Result.AddInfo(Format('[ %s ]', [Line]), '');
          Continue;
        end;
        if IsPrefix('Audio', Line) or IsPrefix('Video', Line) or IsPrefix('Text', Line) or IsPrefix('Menu', Line) or IsPrefix('Image', Line) or IsPrefix('Chapters', Line) then
        begin
          Section := Section_Other;
          Result.AddInfo(Format('[ %s ]', [Line]), '');
          Continue;
        end;
        Result.AddInfo('Junk Data', Line);
        Continue;
      end;

      Name := FixString(Copy(Line,1, x-1));
      Value := FixString(Copy(Line,x+1, Length(Line)));

      if (Length(Name) < 1) or (Length(Value) < 1) or SameText('Exit Code', Name) or SameText('Bytes Captured', Name) then
      begin
        Continue;
      end;

      if SameText('Format', Name) then
      begin
        if Section = Section_General then
        begin
          Result.Container := Update(Result.Container, Value);
        end
        else if Section = Section_Audio then
        begin
          Result.Format := Update(Result.Format, Value);
        end;
      end;
      if SameText('Format Version', Name) then
      begin
        if Section = Section_Audio then
        begin
          Result.Version := Update(Result.Version, Value);
        end;
      end;
      if SameText('Format Profile', Name) then
      begin
        if Section = Section_Audio then
        begin
          Result.Profile := Update(Result.Profile, Value);
        end
        else if Section = Section_General then
        begin
          Result.Flavor := Update(Result.Flavor, Value);
        end;
      end;

      if SameText('Title', Name) or SameText('Track', Name) or SameText('Track Name', Name) then
      begin
        Result.Title := Update(Result.Title, Value);
        Continue;
      end;
      if SameText('Artist', Name) or SameText('Performer', Name) then
      begin
        Result.Artist := Update(Result.Artist, Value);
        Continue;
      end;
      if SameText('Album', Name) then
      begin
        Result.Album := Update(Result.Album, Value);
        Continue;
      end;
      if SameText('Genre', Name) then
      begin
        Result.Genre := Update(Result.Genre, GenreToStr(Value));
        Continue;
      end;
      if SameText('Year', Name) or SameText('Recorded Date', Name) or SameText('Encoded Date', Name) or SameText('Tagged Date', Name) then
      begin
        Result.Year := Update(Result.Year, StrToIntDef(Value, 0));
        Continue;
      end;
      if SameText('Comment', Name) then
      begin
        Result.Comment := Update(Result.Comment, Value);
        Continue;
      end;
      if SameText('Track Name/Position', Name) then
      begin
        Result.Track := Update(Result.Track, StrToIntDef(Value, 0));
      end;
      if SameText('Duration', Name) then
      begin
        if (Section = Section_General) or (Section = Section_Audio) then
        begin
          Result.Duration := Max(Result.Duration, DurationToInt(Value));
        end;
      end;

      Result.AddInfo(Name, Value);
    end;
  end;

  Result.Title := Update(Result.Title, FilenameToTitle(FileName));
  Result.Track := Update(Result.Track, MaxInt);
  Result.Container := Update(Result.Container, 'Unknown');
  Result.Flavor := Update(Result.Flavor, 'Unknown');
  Result.Format := Update(Result.Format, 'Unknown');
  Result.Profile := Update(Result.Profile, 'Unknown');
  Result.Version := Update(Result.Version, 'Unknown');

  {$IF Defined(BUILD_DEBUG)}
  MyMsgBox(
    Form_Main,
    Format('Container: %s', [Result.Container]) + #10 +
      Format('Format: %s', [Result.Format]) + #10 +
      Format('Version: %s', [Result.Version]) + #10 +
      Format('Profile: %s', [Result.Profile]),
    'LameXP',
    MB_TOPMOST
  );
  {$IFEND}

  Log.Free;
  Process.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure ShowStatusPanel(const Show: Boolean);
begin
  if (not Show) then
  begin
    if Form_Main.Panel_Working_Outer.Visible then
    begin
      Form_Main.Panel_Working_Outer.Hide;
      if not Form_Main.Enabled then
      begin
        Form_Main.Enabled := True;
        Application.ProcessMessages;
      end;
      SetTaskbarProgressState(tbpsNone);
      SetTaskbarOverlayIcon(THandle(nil), '');
    end;
    Exit;
  end;

  SetTaskbarProgressState(tbpsIndeterminate);
  SetTaskbarOverlayIcon(Form_Main.ImageList1, 27, 'Busy');

  with Form_Main.Panel_Working_Outer do
  begin
    DoubleBuffered := True;
    Form_Main.Panel_Working_Middle.DoubleBuffered := True;
    Form_Main.Panel_Working_Inner.DoubleBuffered := True;
    Form_Main.Panel_Working_Inner.Caption := LangStr('Message_Loading', 'Core');
    Width := Round(Form_Main.ClientWidth * 0.88);
    Height := 64;
    Left := (Form_Main.ClientWidth - Width) div 2;
    Top := Round((Form_Main.ClientHeight - Height) * 0.4);

    if Form_Main.Icon_Working.Tag <> 0 then
    begin
      Form_Main.ImageList2.GetIcon(0, Form_Main.Icon_Working.Picture.Icon);
      Form_Main.Icon_Working.Width := Form_Main.Icon_Working.Picture.Icon.Width;
      Form_Main.Icon_Working.Tag := 0;
    end;

    Show;
    BringToFront;
    Invalidate;
    Update;
  end;

  if IsWindowEnabled(Form_Main.Handle) then
  begin
    Form_Main.Enabled := False;
    Application.ProcessMessages;
  end;
end;

procedure UpdateStatusPanel(const Index: Integer; const Text: String);
var
  NewText: String;
const
  MinDist = 16;
begin
  if not Form_Main.Panel_Working_Outer.Visible then Exit;

  with Form_Main.Panel_Working_Inner do
  begin
    NewText := Trim(Text);

    if Canvas.TextWidth(NewText) > ClientWidth - MinDist then
    begin
      NewText := NewText + '...';
      while (Length(NewText) > 3) and ((Canvas.TextWidth(NewText) > ClientWidth - MinDist) or (NewText[Length(NewText)-3] < #$30)) do
      begin
        Delete(NewText, Length(NewText) - 3, 1);
      end;
    end;

    Caption := NewText;

    if (Index >= 0) and (Index < Form_Main.ImageList2.Count) then
    begin
      if Form_Main.Icon_Working.Tag <> Index then
      begin
        Form_Main.ImageList2.GetIcon(Index, Form_Main.Icon_Working.Picture.Icon);
        Form_Main.Icon_Working.Width := Form_Main.Icon_Working.Picture.Icon.Width;
        Form_Main.Icon_Working.Tag := Index;
      end;
    end;

    Invalidate;
    Update;
    Application.ProcessMessages;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure DisplayMetaInfo(const Data: TMetaData);
var
  Keys,Values: TStringList;
  i: Integer;

  function AddLine(Line: String): String; overload;
  begin
    if Length(Line) > 0 then  
    begin
      Result := Line;
    end else begin
      Result := LangStr('Message_Unknown', 'Core');
    end;
  end;

  function AddLine(Line: Integer): String; overload;
  begin
    if Line > 0 then
    begin
      Result := IntToStr(Line);
    end else begin
      Result := LangStr('Message_Unknown', 'Core');
    end;
  end;

begin
  if Form_DisplayMetaData.Visible then
  begin
    MessageBeep(MB_ICONERROR);
    Exit;
  end;

  Keys := TStringList.Create;
  Values := TStringList.Create;

  with Data do
  begin
    Form_DisplayMetaData.Edit_Title.Text := AddLine(Title);
    Form_DisplayMetaData.Edit_Artist.Text := AddLine(Artist);
    Form_DisplayMetaData.Edit_Album.Text := AddLine(Album);
    Form_DisplayMetaData.Edit_Genre.Text := AddLine(Genre);
    Form_DisplayMetaData.Edit_Year.Text := AddLine(Year);
    Form_DisplayMetaData.Edit_Comment.Text := AddLine(Comment);

    Form_DisplayMetaData.ListView.Items.Clear;

    GetAll(Keys, Values);
    if Keys.Count > 0 then
    begin
      for i := 0 to Keys.Count-1 do
      begin
        with Form_DisplayMetaData.ListView.Items.Add do
        begin
          Caption := Keys[i];
          SubItems.Add(Values[i]);
        end;
      end;
    end;

    if SameText(Container, Format) then
    begin
      Form_DisplayMetaData.Label_FileType.Caption := Format;
    end else begin
      Form_DisplayMetaData.Label_FileType.Caption := SysUtils.Format('%s / %s', [Container, Format]);
    end;

    Form_DisplayMetaData.Caption := LangStr('Message_FileInformation', 'Core') + ' ' + ExtractFileName(GetInfo('CompleteName'));

    Form_DisplayMetaData.Label_FileType.Hint := SysUtils.Format('Container: %s (Profile: %s)', [Container, Flavor]);
    Form_DisplayMetaData.Label_FileType.Hint := Form_DisplayMetaData.Label_FileType.Hint + #10 + SysUtils.Format('Format: %s (Profile: %s, Version: %s)', [Format, Profile, Version]);
    Form_DisplayMetaData.Label_FileType.Hint := Form_DisplayMetaData.Label_FileType.Hint + #10 + SysUtils.Format('Decoder: %s', [Form_Main.DecoderList[Decoder].ClassName]);
    Form_DisplayMetaData.Label_FileType.Hint := Form_DisplayMetaData.Label_FileType.Hint + #10 + SysUtils.Format('Time: %d sec', [Duration]);
  end;

  Form_DisplayMetaData.ShowModal;

  Keys.Free;
  Values.Free;
end;

///////////////////////////////////////////////////////////////////////////////

procedure InitializeLanguages;
var
  i: Integer;
  Item: TMenuItem;
  Files: TStringList;
  Temp: String;
begin
  Files := SearchFiles(Form_Main.Path.AppRoot + '\*.loc', False);

  if Files.Count > 0 then
  begin
    Form_Main.LanguageFiles.Add('---');
    for i := 0 to Files.Count-1 do
    begin
      Form_Main.LanguageFiles.AddObject(Files[i], TLockedFile.Create(Form_Main.Path.AppRoot + '\' + Files[i]))
    end;
  end;

  Files.Free;

  for i := 0 to Form_Main.LanguageFiles.Count-1 do
  begin
    if SameText(Form_Main.LanguageFiles[i], '---') then
    begin
      Form_Main.Menu_LanguageSelect.NewBottomLine;
      Continue;
    end;

    Item := TMenuItem.Create(Form_Main);

    with Item do
    begin
      Caption := Form_Main.LanguageFiles[i];
      OnClick := Form_Main.Menu_LanguageSelectorClick;
      if Assigned(Form_Main.LanguageFiles.Objects[i]) then
      begin
        Temp := ExtractDirectory(TLockedFile(Form_Main.LanguageFiles.Objects[i]).Location) + '\' + RemoveExtension(ExtractFileName(TLockedFile(Form_Main.LanguageFiles.Objects[i]).Location)) + '.bmp';
        if not SafeFileExists(Temp) then
        begin
          Temp := Form_Main.Path.Tools + '\locale_EU.bmp';
        end;
        try
          Bitmap.LoadFromFile(Temp);
          Bitmap.Transparent := False;
        except
          Form_Main.ImageList1.GetBitmap(18, Bitmap);
          Bitmap.Transparent := False;
        end;
      end;
    end;
    Form_Main.Menu_LanguageSelect.Add(Item);
  end;

  SetDefaultLanguage;
end;

procedure SetDefaultLanguage;
var
  i: Integer;
  Default: LANGID;
  Buffer: String;
const
  EnvID = 'AppLocaleID';
begin
  Default := 0;

  SetLength(Buffer, GetEnvironmentVariable(EnvID, nil, 0) + 1);
  SetLength(Buffer, GetEnvironmentVariable(EnvID, @Buffer[1], Length(Buffer)));
  Buffer := Trim(Buffer);

  if Length(Buffer) > 0 then
  begin
    Default := StrToIntDef('0x' + Buffer, 0) and $00FF;
  end;

  if Default <= 0 then
  begin
    Default := GetUserDefaultLangID and $00FF;
  end;

  // Find lanugauge that equals the default language and has a suitable Codepage
  for i := 0 to Form_Main.LanguageFiles.Count-1 do
  begin
    if Assigned(Form_Main.LanguageFiles.Objects[i]) then
    begin
      with Form_Main.LanguageFiles.Objects[i] as TLockedFile do
      begin
        if Tag = Default then
        begin
          if SwitchLanguage(Form_Main.LanguageFiles[i]) then
          begin
            if CheckCodepage(True) then Exit;
          end;
        end;
      end;
    end;
  end;

  // Fall back to English language
  SwitchLanguage('');
end;

///////////////////////////////////////////////////////////////////////////////

function SwitchLanguage(const Name: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := Max(Form_Main.LanguageFiles.IndexOf(Name), 0);

  if Assigned(Form_Main.LanguageFiles.Objects[i]) then
  begin
    with Form_Main.LanguageFiles.Objects[i] as TLockedFile do
    begin
      if LoadLanguage(Location) then
      begin
        Result := True;
        Form_Main.Options.CurrentLanguage := Form_Main.LanguageFiles[i];
        for i := 0 to Form_Main.Menu_LanguageSelect.Count-1 do
        begin
          Form_Main.Menu_LanguageSelect.Items[i].Checked := SameText(Form_Main.Menu_LanguageSelect.Items[i].Caption, Form_Main.Options.CurrentLanguage);
        end;
      end;
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

function CheckCodepage(const Silent: Boolean): Boolean;
var
  i: Cardinal;
begin
  i := StrToIntDef(LangStr('Codepage', 'Translation'), -1);

  if (i <> GetACP) and (i > 0) then
  begin
    if not Silent then
    begin
      MyMsgBox(Form_Main, Format('Your current Codepage is "%s", but the selected language requires the "%s" Codepage.' + #10#10 + 'LameXP won''t display texts properly for this language, unless you change the Codepage for None-Unicode applications accordingly !!!', [IntToCodepage(GetACP), IntToCodepage(i)]), MB_TOPMOST or MB_ICONWARNING);
      if MyMsgBox(Form_Main, 'You can use the Microsoft AppLocale Utility to switch the Codepage of LameXP quickly. Download that tool now?', MB_TOPMOST or MB_ICONQUESTION or MB_YESNO) = IDYES then
      begin
        HandleURL('http://www.microsoft.com/globaldev/tools/apploc.mspx');
      end;
    end;
    Result := False;
  end else begin
    Result := True;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure DetectNeroVersion(var Version: String; var Date: String);
const
  Key1: String = 'Package version:';
  Key2: String = 'Package build date:';
var
  Process: TRunProcess;
  Log: TStringList;
  i,x: Integer;

  function MyTrim(Str: String): String;
  var
    i: Integer;
  begin
    Result := Trim(Str);

    for i := 1 to Length(Result) do
    begin
      if Result[i] = '*' then
      begin
        Result := Trim(Copy(Result, 1, i-1));
        Break;
      end;
    end;
  end;

begin
  Version := '';
  Date := '';

  if not Assigned(Form_Main.Tools.NeroEnc_Enc) then
  begin
    Exit;
  end;

  Process := TRunProcess.Create;

  if Process.Execute('"' + Form_Main.Tools.NeroEnc_Enc.Location + '"') = procFaild then
  begin
    Process.Free;
    Exit;
  end;

  Log := TStringList.Create;
  Process.GetLog(Log);

  for i := 0 to Log.Count-1 do
  begin
    x := pos(Key1, Log[i]);
    if x > 0 then
    begin
      Version := MyTrim(Copy(Log[i], x + Length(Key1), Length(Log[i])));
    end;

    x := pos(Key2, Log[i]);
    if x > 0 then
    begin
      Date := MyTrim(Copy(Log[i], x + Length(Key2), Length(Log[i])));
    end;
  end;

  Log.Free;
  Process.Free;
end;

function CheckNeroVersion(const VersionStr: String): Boolean;
const
  Key: String = 'Package version:';
var
  Temp,Dummy: String;
  List1,List2: TStringList;
  i,x,y: Integer;
begin
  Result := True;
  DetectNeroVersion(Temp,Dummy);

  //MyMsgBox(Form_Main, '"' + Temp + '"' + #10 + '"' + Dummy + '"', nil, MB_TOPMOST);

  if Temp = '' then
  begin
    Exit;
  end;

  List1 := ExplodeStr('.', Temp);
  List2 := ExplodeStr('.', VersionStr);

  for i := 0 to Min(List1.Count, List2.Count) - 1 do
  begin
    x := StrToIntDef(Trim(List1[i]), 0);
    y := StrToIntDef(Trim(List2[i]), 0);

    //MyMsgBox(Form_Main, IntToStr(x) + '=' + IntToStr(y), nil, MB_TOPMOST);

    if x > y then
    begin
      Break;
    end;
    if x < y then
    begin
      Result := False;
      Break;
    end;
  end;

  List1.Free;
  List2.Free;
end;

///////////////////////////////////////////////////////////////////////////////

function AddSourceFolder(const FolderPath: String; const Recursive: Boolean; var Aborted: Boolean): Boolean;
var
  h: THandle;
  Filenames: TStringList;
  Subfolders: TStringList;
  Data: TWin32FindData;
  i: Integer;
begin
  Result := False;

  if (not SafeDirectoryExists(FolderPath)) or Aborted then
  begin
    Exit;
  end;  

  h := FindFirstFile(PAnsiChar(FolderPath + '\*.*'), Data);
  if h = INVALID_HANDLE_VALUE then Exit;

  Filenames := TStringList.Create;
  Filenames.CaseSensitive := False;

  if Recursive then
  begin
    Subfolders := TStringList.Create;
    Subfolders.CaseSensitive := False;
  end else begin
    Subfolders := nil;
  end;

  repeat
    if Data.cFileName[0] <> '.' then
    begin
      if (Data.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
      begin
        if Assigned(Subfolders) then Subfolders.Add(FolderPath + '\' + Data.cFileName);
      end else begin
        Filenames.Add(FolderPath + '\' + Data.cFileName);
      end;
    end;
  until
    not FindNextFile(h, Data);

  Filenames.Sort;
  if Assigned(Subfolders) then Subfolders.Sort;

  for i := 0 to Filenames.Count-1 do
  begin
    if GetAsyncKeyState(VK_ESCAPE) <> 0 then
    begin
      Aborted := True;
      Break;
    end;
    if AddInputFile(Filenames[i], True, False) then
    begin
      Result := True;
    end;
  end;

  Filenames.Free;

  if Assigned(Subfolders) then
  begin
    for i := 0 to Subfolders.Count-1 do
    begin
      if Aborted then Break;
      if GetAsyncKeyState(VK_ESCAPE) <> 0 then
      begin
        Aborted := True;
        Break;
      end;
      if AddSourceFolder(Subfolders[i], Recursive, Aborted) then
      begin
        Result := True;
      end;
    end;
    Subfolders.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure MakeNewFolder;
var
  s,t: String;
  m: TMetaData;
  i: Integer;
begin
  m := nil;
  s := '';

  if Assigned(Form_Main.ListView.Selected) then
  begin
    if Assigned(Form_Main.ListView.Selected.Data) then
    begin
      if (TMetaData(Form_Main.ListView.Selected.Data).Artist <> '') or (TMetaData(Form_Main.ListView.Selected.Data).Album <> '') then
      begin
        m := TMetaData(Form_Main.ListView.Selected.Data);
      end;
    end;
  end;

  if not Assigned(m) then
  begin
    for i := 0 to Form_Main.ListView.Items.Count-1 do
    begin
      if Assigned(Form_Main.ListView.Items[i].Data) then
      begin
        if (TMetaData(Form_Main.ListView.Items[i].Data).Artist <> '') or (TMetaData(Form_Main.ListView.Items[i].Data).Album <> '') then
        begin
          m := TMetaData(Form_Main.ListView.Items[i].Data);
          Break;
        end;
      end;
    end;
  end;

  if (Form_Main.Edit_Artist.Text <> '') or (Form_Main.Edit_Album.Text <> '') then
  begin
    if Form_Main.Edit_Artist.Text <> '' then
    begin
      s := Form_Main.Edit_Artist.Text;
    end;
    if Form_Main.Edit_Album.Text <> '' then
    begin
      if s <> '' then s := s + ' - ';
      s := s + Form_Main.Edit_Album.Text;
    end;
  end else begin
    if Assigned(m) then
    begin
      if m.Artist <> '' then
      begin
        s := m.Artist;
      end;
      if m.Album <> '' then
      begin
        if s <> '' then s := s + ' - ';
        s := s + m.Album;
      end;
    end;
  end;

  s := CheckFileName(s);

  repeat
    if not MyInputQuery(Form_Main, LangStr('Message_NewFolderQueryTitle', Form_Main.Name), LangStr('Message_NewFolderQueryText', Form_Main.Name), s, False, True) then
    begin
      Exit;
    end;
    t := Form_Main.DirectoryListBox.Directory + '\' + s;
    if s <> CheckFileName(s) then
    begin
      s := CheckFileName(s);
      MessageBeep(MB_ICONERROR);
      Continue;
    end;
  until
    (s <> '') and ForceDirectories(t);

  Form_Main.DirectoryListBox.Directory := t;
end;

///////////////////////////////////////////////////////////////////////////////

procedure HandleDroppedFiles(var Msg: TMessage);
var
  MaxSize: Cardinal;
  FileCount: Cardinal;
  Buffer: PAnsiChar;
  Filename: String;
  Files: TStringList;
  Dirs: TStringList;
  b: Boolean;
  i: Cardinal;
begin
  ShowStatusPanel(True);
  FileCount := DragQueryFile(Msg.wParam, $FFFFFFFF, nil, 0);

  if not (FileCount > 0) then
  begin
    DragFinish(Msg.wParam);
    ShowStatusPanel(False);
    Exit;
  end;

  MaxSize := 0;

  for i := 0 to FileCount - 1 do
  begin
    MaxSize := Max(MaxSize, DragQueryFile(Msg.wParam, i, nil, 0));
  end;

  if not (MaxSize > 0) then
  begin
    DragFinish(Msg.wParam);
    ShowStatusPanel(False);
    Exit;
  end;

  MaxSize := MaxSize + 1;

  //------------------------------------------//

  Buffer := nil;
  Dirs := nil;
  Files := nil;
  Filename := '';

  try
    Buffer := AllocMem(MaxSize + 1);
    Files := TStringList.Create;
    Files.CaseSensitive := False;
    Dirs := TStringList.Create;
    Dirs.CaseSensitive := False;
  except
    if Assigned(Buffer) then FreeMem(Buffer);
    if Assigned(Files) then FreeAndNil(Files);
    if Assigned(Dirs) then FreeAndNil(Dirs);
    DragFinish(Msg.wParam);
    ShowStatusPanel(False);
    Exit;
  end;

  //------------------------------------------//

  for i := 0 to FileCount - 1 do
  begin
    SetString(Filename, Buffer, DragQueryFile(Msg.wParam, i, Buffer, MaxSize));
    Filename := GetFullPath(ExpandEnvStr(Trim(Filename)));

    if Filename <> '' then
    begin
      if SafeDirectoryExists(Filename) then
      begin
        Dirs.Add(Filename);
      end
      else if SafeFileExists(Filename) then
      begin
        Files.Add(Filename);
      end;
    end;
  end;

  DragFinish(Msg.wParam);
  FreeMem(Buffer);

  //------------------------------------------//

  Files.Sort;
  Dirs.Sort;

  if Files.Count > 0 then
  begin
    Form_Main.PageControl.ActivePage := Form_Main.Sheet_Sources;
    for i := 0 to Files.Count-1 do
    begin
      AddInputFile(Files[i], False, False);
    end;
  end;

  if Dirs.Count > 0 then
  begin
    Form_Main.PageControl.ActivePage := Form_Main.Sheet_Sources;
    b := False;
    for i := 0 to Dirs.Count-1 do
    begin
      AddSourceFolder(Dirs[i], False, b);
      if b then Break;
    end;
    if b then
    begin
      MessageBeep(MB_ICONERROR);
    end;
  end;

  //------------------------------------------//

  Files.Free;
  Dirs.Free;

  ShowStatusPanel(False);
  UpdateIndex;
  Form_Main.FormResize(Form_Main);
end;

///////////////////////////////////////////////////////////////////////////////

procedure OpenFiles;
var
  i,j: Integer;
  s: TStringList;
  f: String;
  b: boolean;
begin
  b := False;
  f := MuldeR_Toolz.ReplaceSubStr(LangStr('Message_SupportedFileTypes', Form_Main.Name), '|', '_') + '|';
  for i := 0 to Length(FileTypes_Exts)-1 do
    for j := 0 to Length(FileTypes_Exts[i])-1 do
      if FileTypes_Exts[i,j] <> '' then
      begin
        if b then
          f := f + ';'
        else
          b := True;
        f := f + '*.' + FileTypes_Exts[i,j];
      end;

  for i := 0 to Length(FileTypes_Exts)-1 do
  begin
    f := f + '|' + FileTypes_Names[i] + '|';
    b := False;
    for j := 0 to Length(FileTypes_Exts[i])-1 do
      if FileTypes_Exts[i,j] <> '' then
      begin
        if b then
          f := f + ';'
        else
          b := True;
        f := f + '*.' + FileTypes_Exts[i,j];
      end;
  end;

  Form_Main.Dialog_AddFiles.Filter := f;
  if not Form_Main.Dialog_AddFiles.Execute then Exit;

  ShowStatusPanel(True);

  s := TStringList.Create;
  s.AddStrings(Form_Main.Dialog_AddFiles.Files);
  s.Sort;

  b := True;

  for i := 0 to s.Count-1 do
  begin
    if (Pos('?', s[i]) <> 0) or (Pos('*', s[i]) <> 0) then
    begin
      Continue;
    end;
    if GetAsyncKeyState(VK_ESCAPE) <> 0 then
    begin
      MessageBeep(MB_ICONERROR);
      Break;
    end;
    if not AddInputFile(s[i], False, True) then
    begin
      b := False;
    end;
  end;

  s.Free;

  ShowStatusPanel(False);
  UpdateIndex;
  Form_Main.FormResize(Form_Main);

  if (not b) then
  begin
    MyLangBox(Form_Main, 'Message_UnsupportedFileWarning', MB_ICONWARNING or MB_TOPMOST);
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure OpenFilesEx;
var
  b: boolean;
  i,j: Integer;
  LongFileNameW,ShortFileNameW: PWideChar;
  FileNameA: String;
  OpenFilenameW: TOpenFilenameW;
  FileFilter, InitFolder: WideString;
const
  BufferLength = 2048;
begin
  ZeroMemory(@OpenFilenameW, SizeOf(TOpenFilenameW));
  LongFileNameW := AllocMem(BufferLength * SizeOf(WideChar));
  ShortFileNameW := AllocMem(BufferLength * SizeOf(WideChar));
  InitFolder := Form_Main.Dialog_AddFiles.InitialDir;

  FileFilter := LangStr('Message_SupportedFileTypes', Form_Main.Name) + #0;
  b := False;

  for i := 0 to Length(FileTypes_Exts)-1 do
  begin
    for j := 0 to Length(FileTypes_Exts[i])-1 do
    begin
      if FileTypes_Exts[i,j] <> '' then
      begin
        if b then
        begin
          FileFilter := FileFilter + ';';
        end else begin
          b := True;
        end;
        FileFilter := FileFilter + '*.' + FileTypes_Exts[i,j];
      end;
    end;
  end;

  FileFilter := FileFilter + #0#0;

  with OpenFilenameW do
  begin
    lStructSize := SizeOf(TOpenFilenameW);
    hWndOwner := Form_Main.Handle;
    lpstrFile := LongFileNameW;
    nMaxFile := BufferLength - 1;
    lpstrFilter := PWChar(FileFilter);
    lpstrInitialDir := PWChar(InitFolder);
    Flags := OFN_PATHMUSTEXIST;
  end;

  if not GetOpenFileNameW(OpenFilenameW) then
  begin
    FreeMem(LongFileNameW);
    FreeMem(ShortFileNameW);
    Exit;
  end;

  if GetShortPathNameW(LongFileNameW, ShortFileNameW, 2047) = 0 then
  begin
    FreeMem(LongFileNameW);
    FreeMem(ShortFileNameW);
    Exit;
  end;

  FileNameA := WideCharToString(ShortFileNameW);
  Form_Main.Dialog_AddFiles.InitialDir := ExtractDirectory(FileNameA);

  FreeMem(LongFileNameW);
  FreeMem(ShortFileNameW);

  ShowStatusPanel(True);
  b := AddInputFile(FileNameA, False, True);

  ShowStatusPanel(False);
  UpdateIndex;
  Form_Main.FormResize(Form_Main);

  if (not b) then
  begin
    MyLangBox(Form_Main, 'Message_UnsupportedFileWarning', MB_ICONWARNING or MB_TOPMOST);
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure CheckForCompatibilityMode;
const
  X: DWORD = DWORD(-1);
var
  KernelDLL: HMODULE;
  VersionInfo: _OSVERSIONINFOA;

  procedure CheckForExport(Major: DWORD; Minor: DWORD; ExportName: PAnsiChar);
  var
    s,t: String;
  begin
    if ((Major = VersionInfo.dwMajorVersion) or (Major = X)) and ((Minor = VersionInfo.dwMinorVersion) or (Minor = X)) then
    begin
      if Assigned(GetProcAddress(KernelDLL, ExportName)) then
      begin
        try
          if (Major <> X) or (Minor <> X) then
          begin
            if Major <> X then s := IntToStr(Major) else s := 'x';
            if Minor <> X then t := IntToStr(Minor) else t := 'x';
            FatalAppExit(0, PAnsiChar(Format('Windows NT %s.%s compatibility mode detected. Please disable compatibility mode for this application and try again!', [s,t])));
          end else begin
            FatalAppExit(0, 'Windows 9x/ME compatibility mode detected. Please disable compatibility mode for this application and try again!');
          end;
        finally
          TerminateProcess(GetCurrentProcess, DWORD(-1));
        end;  
      end;
    end;
  end;

begin
  KernelDLL := SafeLoadLibrary('kernel32.dll');

  if KernelDLL = 0 then
  begin
    Exit;
  end;

  FillChar(VersionInfo, SizeOf(_OSVERSIONINFOA), #0);
  VersionInfo.dwOSVersionInfoSize := SizeOf(_OSVERSIONINFOA);
  GetVersionEx(VersionInfo);

  if VersionInfo.dwPlatformId <> VER_PLATFORM_WIN32_NT then
  begin
    CheckForExport(X, X, 'GetThreadPriorityBoost');
  end else begin
    CheckForExport(4, X, 'OpenThread');            {Windows NT 4.0}
    CheckForExport(5, 0, 'GetNativeSystemInfo');   {Windows 2000}
    CheckForExport(5, 1, 'GetLargePageMinimum');   {Windows XP}
    CheckForExport(5, 2, 'GetLocaleInfoEx');       {Windows Server 2003}
    CheckForExport(6, 0, 'CreateRemoteThreadEx');  {Windows Vista}
  end;

  FreeLibrary(KernelDLL);
end;

///////////////////////////////////////////////////////////////////////////////

procedure CheckVersionInfo;
const
  p = 'StringFileInfo\080904E4\';
  k: array [0..11] of String =
  (
    p + 'FileDescription',
    p + 'FileVersion',
    p + 'ProductVersion',
    p + 'ProductName',
    p + 'LegalCopyright',
    p + 'Author',
    p + 'OriginalFileName',
    p + 'Release Date',
    p + 'Comments',
    p + 'LegalTrademarks',
    p + 'CompanyName',
    p + 'Website'
  );
var
  q: VS_FIXEDFILEINFO;
  v: array [0..11] of String;
  b: Boolean;
begin
  b := True;

  if GetAppVerStr(q) then
  begin
    b := b and (q.dwProductVersionMS = q.dwFileVersionMS);
    b := b and (q.dwProductVersionLS = q.dwFileVersionLS);
    b := b and (q.dwFileVersionMS div 65536 = DWORD(StrToIntDef(VersionStr[2], -1)));
    b := b and (q.dwFileVersionMS mod 65536 = DWORD(StrToIntDef(VersionStr[4], -1)));
    b := b and (q.dwFileVersionLS div 65536 = DWORD(StrToIntDef(VersionStr[5], -1)));
    b := b and (q.dwFileVersionLS mod 65536 = DWORD(BuildNo));
  end;

  if GetAppVerStr(k,v) then
  begin
    b := b and SameText(v[$0], 'LameXP - Audio Encoder Frontend');
    b := b and SameText(v[$1], Format('%s.%s.%s.%d', [VersionStr[2], VersionStr[4], VersionStr[5], BuildNo]));
    b := b and SameText(v[$2], VersionStr);
    b := b and SameText(v[$3], 'LameXP');
    b := b and SameText(v[$4], Format('Copyright (c) 2004-%s LoRd_MuldeR', [Copy(BuildDate, 1, 4)]));
    b := b and SameText(v[$5], 'LoRd_MuldeR <mulder2@gmx.de>');
    b := b and SameText(v[$6], 'LameXP.exe');
    b := b and SameText(v[$7], BuildDate);
    b := b and SameText(v[$8], 'This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.');
    b := b and SameText(v[$9], 'GNU');
    b := b and SameText(v[$A], 'Free Software Foundation');
    b := b and SameText(v[$B], 'http://mulder.at.gg/');
  end;

  if (not b) then
  begin
    FatalAppExit(0, 'Invalid version information. LameXP was built incorrectly or hacked afterwards!');
    TerminateProcess(GetCurrentProcess, DWORD(-1));
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure CheckJVCLVersion;
const
  ExpectVersion = 339;
begin
  if JVCLVer.JVCL_VERSION <> ExpectVersion then
  begin
    FatalAppExit(0, 'LameXP was compiled with an unsupported or unknown version of the JEDI Visual Component Library!');
    TerminateProcess(GetCurrentProcess, DWORD(-1));
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure CheckDebugger;
begin
  if IsDebuggerPresent then
  begin
    KillRunningJobs;
    FatalAppExit(0, 'Sorry, this is not a debug build. Unload debugger and try again!');
    TerminateProcess(GetCurrentProcess, DWORD(-1));
  end;
end;

///////////////////////////////////////////////////////////////////////////////

{$IF Defined(BUILD_DEBUG)}
initialization Assert(Unit_Main.IsDebugBuild, 'Debug build not enabled in Main !!!');
{$IFEND}

end.

///////////////////////////////////////////////////////////////////////////////

