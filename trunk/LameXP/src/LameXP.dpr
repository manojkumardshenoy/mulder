///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
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

program LameXP;

///////////////////////////////////////////////////////////////////////////////

uses
  Forms,
  Windows,
  SysUtils,
  ComObj,
  MuldeR_Toolz in '..\!_Toolz\MuldeR_Toolz.pas',
  Unit_AACDecoder in 'Unit_AACDecoder.pas',
  Unit_About in 'Unit_About.pas' {Form_About},
  Unit_ALACDecoder in 'Unit_ALACDecoder.pas',
  Unit_Core in 'Unit_Core.pas',
  Unit_Data in 'Unit_Data.pas' {Form_Data},
  Unit_Decoder in 'Unit_Decoder.pas',
  Unit_DropBox in 'Unit_DropBox.pas' {Form_DropBox},
  Unit_EasterEgg in 'Unit_EasterEgg.pas' {Form_EasterEgg},
  Unit_Encoder in 'Unit_Encoder.pas',
  Unit_Filter in 'Unit_Filter.pas',
  Unit_FLACDecoder in 'Unit_FLACDecoder.pas',
  Unit_FLACEncoder in 'Unit_FLACEncoder.pas',
  Unit_LameEncoder in 'Unit_LameEncoder.pas',
  Unit_Languages in 'Unit_Languages.pas' {Form_Languages},
  Unit_LicenseView in 'Unit_LicenseView.pas' {Form_License},
  Unit_LockedFile in 'Unit_LockedFile.pas',
  Unit_LogView in 'Unit_LogView.pas' {Form_LogView},
  Unit_Main in 'Unit_Main.pas' {Form_Main},
  Unit_MetaData in 'Unit_MetaData.pas',
  Unit_MetaDisplay in 'Unit_MetaDisplay.pas' {Form_DisplayMetaData},
  Unit_MonkeyDecoder in 'Unit_MonkeyDecoder.pas',
  Unit_MP3Decoder in 'Unit_MP3Decoder.pas',
  Unit_MusepackDecoder in 'Unit_MusepackDecoder.pas',
  Unit_NeroEncoder in 'Unit_NeroEncoder.pas',
  Unit_NormalizationFilter in 'Unit_NormalizationFilter.pas',
  Unit_OggDecoder in 'Unit_OggDecoder.pas',
  Unit_OggEncoder in 'Unit_OggEncoder.pas',
  Unit_ProcessingThread in 'Unit_ProcessingThread.pas',
  Unit_Progress in 'Unit_Progress.pas' {Form_Progress},
  Unit_QueryBox in 'Unit_QueryBox.pas' {Form_QueryBox},
  Unit_RIPEMD160 in 'Unit_RIPEMD160.pas',
  Unit_RunProcess in 'Unit_RunProcess.pas' {RunProcess},
  Unit_SendTo in 'Unit_SendTo.pas',
  Unit_ShortenDecoder in 'Unit_ShortenDecoder.pas',
  Unit_SpaceChecker in 'Unit_SpaceChecker.pas',
  Unit_SpeexDecoder in 'Unit_SpeexDecoder.pas',
  Unit_Splash in 'Unit_Splash.pas' {Form_Splash},
  Unit_TAKDecoder in 'Unit_TAKDecoder.pas',
  Unit_Translator in 'Unit_Translator.pas',
  Unit_TTADecoder in 'Unit_TTADecoder.pas',
  Unit_Utils in 'Unit_Utils.pas',
  Unit_ValibDecoder in 'Unit_ValibDecoder.pas',
  Unit_WaveDecoder in 'Unit_WaveDecoder.pas',
  Unit_WaveEncoder in 'Unit_WaveEncoder.pas',
  Unit_WavpackDecoder in 'Unit_WavpackDecoder.pas',
  Unit_Win7Taskbar in 'Unit_Win7Taskbar.pas',
  Unit_WMADecoder in 'Unit_WMADecoder.pas';

{$R *.RES}

///////////////////////////////////////////////////////////////////////////////

begin
  if SameText(ParamStr(1), '--uninstall') then
  begin
    RemoveFileAssocs;
    PostMessage(HWND_BROADCAST, RegisterWindowMessage('{a5756250-c439-44c0-a158-a066e2438e71}'), 0, 0);
    Exit;
  end;

  CreateMutex(nil, true, '{e2019dd6-59a7-4902-a168-8dd57b20541e}');

  if (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    try
      SendFilesToRunningInstance;
    except
      MyMsgBox('LameXP encountered an error while checking for running instances!', MB_ICONERROR or MB_TOPMOST);
    end;
    Exit;
  end;

  Application.Initialize;
  Application.Title := 'LameXP';

  with TForm_Splash.Create(Application) do
  begin
    Show;
    CreateForm(TForm_Main, Form_Main);
    CreateForm(TForm_Progress, Form_Progress);
    CreateForm(TForm_About, Form_About);
    CreateForm(TForm_DisplayMetaData, Form_DisplayMetaData);
    CreateForm(TForm_Dropbox, Form_Dropbox);
    Close;
    Free;
  end;

  Application.Run;
end.
