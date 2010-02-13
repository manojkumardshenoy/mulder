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

unit Unit_Utils;

interface

uses
  Windows, SysUtils, Controls, Forms, Classes, MMSystem, Math, Registry,
  Unit_Translator, MuldeR_Toolz;

type
  TMapEntry = array [0..1] of String;

procedure AddTimerEvent(const Text: String);
function BytesToStr(const Value: Int64):String;
procedure CleanUp(Files: TStringList);
function ExpandPath(Root:String; Path:String):String;
procedure ForceApplicationUpdate(const Cursor: TCursor);
function FilenameToTitle(FileName: String): String;
function FixString(Str: String): String;
function IntToCodepage(CodepageIdentifier: Cardinal): String;
function IntToStrF(Value: Integer):String;
function IsProcessElevated: Boolean;
function IsRegString(RegType: TRegDataType): Boolean;
function Lookup(const Map: array of TMapEntry; const Key: String; const Default: String): String;
function MillisecondsToStr(const msec: DWORD; const suffixes: array of String): String;
procedure MyCreateForm(const AppObject: TApplication; const InstanceClass: TComponentClass; var Reference); overload;
function MyCreateForm(const InstanceClass: TComponentClass; const AOwner: TComponent): TComponent;  overload;
function MyLangBox(const Parent: TWinControl; const Name: String; const Flags: UINT): Integer; overload;
function MyLangBox(const Parent: TWinControl; const Name: String; const Title: String; const Flags: UINT): Integer; overload;
function MyLangBoxEx(const Parent: TWinControl; const Name: String; const FormatStr: String; const Flags: UINT): Integer; overload;
function MyLangBoxEx(const Parent: TWinControl; const Name: String; const FormatStr: String; const Title: String; const Flags: UINT): Integer; overload;
function MyLangBoxFmt(const Parent: TWinControl; const Name: String; const Args: array of const; const Flags: UINT): Integer;
function MyLangBoxFmtEx(const Parent: TWinControl; const Name: String; const FormatStr: String; const Args: array of const; const Flags: UINT): Integer;
function MyMsgBox(const Parent: TWinControl; const Text: String; const Flags: UINT): Integer; overload;
function MyMsgBox(const Parent: TWinControl; const Text: String; const Title: String; const Flags: UINT): Integer; overload;
function MyMsgBox(const Text: String; const Flags: UINT): Integer; overload;
procedure MyPlaySound(const Name: String; const Async: Boolean);
function PlayResoureSound(const LibFile: String; const SoundId: Cardinal; const Async: Boolean): Boolean;
function PlaySystemSound(const Name: String; const Async: Boolean): Boolean; overload;
function PlaySystemSound(const Name: array of String; const Async: Boolean): Boolean; overload;
procedure SaveTimerEvents(const Filename: String);
function ShortenURL(const URL: String; const MaxLen: Integer): String;
function ShutdownComputer: Boolean;
function TrimEx(const Input: String; const MinChar: Char; const MaxChar: Char): String;
function VerStrToDate(const Str: String): Integer;

var
  CaptureTimerEvents: Boolean;

///////////////////////////////////////////////////////////////////////////////
implementation
///////////////////////////////////////////////////////////////////////////////

uses
  Unit_Main;

var
  SystemSoundCache: TStrings;
  TimerEvents: TStrings;
  InitialTickCount: Cardinal;
  PreviousTickCount: Cardinal;

procedure CleanUp(Files: TStringList);
var
  i,j: Integer;
  b: Boolean;
begin
  if Files.Count > 0 then
  begin
    for j := 1 to 100 do
    begin
      b := True;

      for i := 0 to Files.Count-1 do
      begin
        if not RemoveFile(Files[i]) then b := False;
      end;

      if b then break else Sleep(100);
    end;
  end;

  Files.Free;
end;

///////////////////////////////////////////////////////////////////////////////

function MillisecondsToStr(const msec: DWORD; const suffixes: array of String): String;
var
  sec, min, hrs: DWORD;
begin
  if Length(suffixes) < 3 then Exit;

  sec := Round(msec / 1000);
  min := 0;

  Result := IntToStr(sec) +  ' ' + suffixes[0];

  if sec >= 60 then
  begin
    min := sec div 60;
    sec := sec mod 60;
    Result := IntToStr(min) + ' ' + suffixes[1] + ', ' + IntToStr(sec) +  ' ' + suffixes[0];
  end;

  if min >= 60 then
  begin
    hrs := min div 60;
    min := min mod 60;
    Result := IntToStr(hrs) + ' ' + suffixes[2] + ', ' + IntToStr(min) +  ' ' + suffixes[1];
  end;
end;

///////////////////////////////////////////////////////////////////////////////

function FixString(Str: String): String;
var
  i: Integer;
begin
  Result := Trim(Str);

  if Length(Result) > 0 then
  begin
    for i := 1 to Length(Result) do
    begin
      if Result[i] = Chr($22) then Result[i] := Chr($60);
    end;
  end;  
end;

///////////////////////////////////////////////////////////////////////////////

function FilenameToTitle(FileName: String): String;
var
  s: String;
  i: Integer;
begin
  s := RemoveExtension(ExtractFileName(FileName));
  for i := 1 to Length(s) do
    if s[i] = '_' then s[i] := ' ';

  repeat
    i := pos(' - ',s);
    if (length(s) > 3) and (i > 0) then s := Copy(s,i+3,Length(s));
  until
    i = 0;

  Result := s;
end;

///////////////////////////////////////////////////////////////////////////////

procedure MyPlaySound(const Name: String; const Async: Boolean);
var
  Flags: Cardinal;
begin
  if Form_Main.Options.SoundsEnabled then
  begin
    Flags := SND_RESOURCE;
    if Async then
    begin
      Flags := Flags or SND_ASYNC;
    end
    else begin
      Flags := Flags or SND_SYNC;
    end;
    PlaySound(PAnsiChar(Name), hInstance, Flags);
  end;
end;

///////////////////////////////////////////////////////////////////////////////

function ExpandPath(Root:String; Path:String):String;
begin
  Result := Path;

  if (Result[1] = '\') and (Result[2] <> '\') then
  begin
    Result := Root[1] + ':' + Result;
  end;

  if Result[2] <> ':' then
  begin
    Result := Root + '\' + Result;
  end;

  Result := GetFullPath(Result);
end;

///////////////////////////////////////////////////////////////////////////////

function IntToStrF(Value: Integer):String;
var
  Temp: Integer;
begin
  if Value = 0 then
  begin
    Result := '0';
    Exit;
  end;

  Temp := Abs(Value);
  Result := '';

  while Temp > 0 do
  begin
    if Result <> '' then
    begin
      Result := '.' + Result;
    end;
    Result := IntToStr(Temp mod 1000) + Result;
    Temp := Temp div 1000;
  end;

  if Value < 0 then
  begin
    Result := '-' + Result;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

function BytesToStr(const Value: Int64):String;
const
  Suffix: array [0..4] of String = ('Byte','KB','MB','GB','TB');
var
  x,y: Int64;
  i: Integer;
begin
  i := 0;
  x := Value;
  y := 0;

  while x >= 1024 do
  begin
    y := x mod 1024;
    x := x div 1024;
    i := i + 1;
    if i >= 4 then Break;
  end;

  Result := IntToStr(x) + '.' + IntToStr(y) + ' ' + Suffix[Min(i,4)];
end;

///////////////////////////////////////////////////////////////////////////////

function ShutdownComputer: Boolean;
var
  a: PAnsiChar;
  tkp: TOKEN_PRIVILEGES;
  c,hToken: Cardinal;
const
  SHTDN_REASON_MAJOR_APPLICATION: Cardinal = $00040000;
begin
  Result := False;

  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
  LookupPrivilegeValue(nil, 'SeShutdownPrivilege', tkp.Privileges[0].Luid);
  tkp.PrivilegeCount := 1;
  tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  AdjustTokenPrivileges(hToken, False, tkp, 0, PTokenPrivileges(nil), c);

  if InitiateSystemShutdown(nil, 'LameXP Shutdown Sequence', 10, True, False) then
  begin
    Result := True;
    Exit;
  end;

  if ExitWindowsEx(EWX_POWEROFF or EWX_FORCE, SHTDN_REASON_MAJOR_APPLICATION) then
  begin
    Result := True;
    Exit;
  end;

  a := AllocMem(4096);
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError, 0, a, 4096, nil);
  MessageBox(0, a, 'ExitWindowsEx', MB_TOPMOST or MB_ICONERROR);
  FreeMem(a);
end;

///////////////////////////////////////////////////////////////////////////////

function IntToCodepage(CodepageIdentifier: Cardinal): String;
begin
  case CodepageIdentifier of
    037: Result := 'IBM037 (IBM EBCDIC US-Canada)';
    437: Result := 'IBM437 (OEM United States)';
    500: Result := 'IBM500 (IBM EBCDIC International)';
    708: Result := 'ASMO-708 (Arabic ASMO 708)';
    709: Result := 'Arabic (ASMO-449+ BCON V4)';
    710: Result := 'Arabic (Transparent Arabic)';
    720: Result := 'DOS-720 (Arabic DOS)';
    737: Result := 'ibm737 (Greek DOS)';
    775: Result := 'ibm775 (Baltic DOS)';
    850: Result := 'ibm850 (Western European DOS)';
    852: Result := 'ibm852 (Central European DOS)';
    855: Result := 'IBM855 (Cyrillic, primarily Russian)';
    857: Result := 'ibm857 (Turkish DOS)';
    858: Result := 'IBM00858 (OEM Multilingual Latin 1)';
    860: Result := 'IBM860 (Portuguese DOS)';
    861: Result := 'ibm861 (Icelandic DOS)';
    862: Result := 'DOS-862 (Hebrew DOS)';
    863: Result := 'IBM863 (French Canadian DOS)';
    864: Result := 'IBM864 (Arabic 864)';
    865: Result := 'IBM865 (Nordic DOS)';
    866: Result := 'cp866 (Russian Cyrillic DOS)';
    869: Result := 'ibm869 (Modern Greek DOS)';
    870: Result := 'IBM870 (IBM EBCDIC Multilingual Latin 2)';
    874: Result := 'windows-874 (Thai Windows)';
    875: Result := 'cp875 (IBM EBCDIC Greek Modern)';
    932: Result := 'shift_jis (Japanese Shift-JIS)';
    936: Result := 'gb2312 (Chinese Simplified GB2312)';
    949: Result := 'ks_c_5601-1987 (Korean, Unified Hangul Code)';
    950: Result := 'big5 (Chinese Traditional Big5)';
    1026: Result := 'IBM1026 (IBM EBCDIC Turkish)';
    1047: Result := 'IBM01047 (IBM EBCDIC Latin 1)';
    1140: Result := 'IBM01140 (IBM EBCDIC US-Canada)';
    1141: Result := 'IBM01141 (IBM EBCDIC Germany)';
    1142: Result := 'IBM01142 (IBM EBCDIC Denmark-Norway)';
    1143: Result := 'IBM01143 (IBM EBCDIC Finland-Sweden)';
    1144: Result := 'IBM01144 (IBM EBCDIC Italy)';
    1145: Result := 'IBM01145 (IBM EBCDIC Latin America-Spain)';
    1146: Result := 'IBM01146 (IBM EBCDIC United Kingdom)';
    1147: Result := 'IBM01147 (IBM EBCDIC France)';
    1148: Result := 'IBM01148 (IBM EBCDIC International)';
    1149: Result := 'IBM01149 (IBM EBCDIC Icelandic)';
    1200: Result := 'utf-16 (Unicode UTF-16, little endian byte order)';
    1201: Result := 'unicodeFFFE (Unicode UTF-16, big endian byte order)';
    1250: Result := 'windows-1250 (Central European Windows)';
    1251: Result := 'windows-1251 (Cyrillic Windows)';
    1252: Result := 'windows-1252 (Western European Windows)';
    1253: Result := 'windows-1253 (Greek Windows)';
    1254: Result := 'windows-1254 (Turkish Windows)';
    1255: Result := 'windows-1255 (Hebrew Windows)';
    1256: Result := 'windows-1256 (Arabic Windows)';
    1257: Result := 'windows-1257 (Baltic Windows)';
    1258: Result := 'windows-1258 (Vietnamese Windows)';
    1361: Result := 'Johab (Korean)';
    12000: 	Result := 'utf-32 (Unicode UTF-32)';
    12001: 	Result := 'utf-32BE (Unicode UTF-32, big endian byte order)';
    28591: 	Result := 'iso-8859-1 (Western European ISO)';
    28592: 	Result := 'iso-8859-2 (Central European ISO)';
    28593: 	Result := 'iso-8859-3 (Latin 3 ISO)';
    28594: 	Result := 'iso-8859-4 (Baltic ISO)';
    28595: 	Result := 'iso-8859-5 (Cyrillic ISO)';
    28596: 	Result := 'iso-8859-6 (Arabic ISO)';
    28597: 	Result := 'iso-8859-7 (Greek ISO)';
    28598: 	Result := 'iso-8859-8 (Hebrew ISO-Visual)';
    28599: 	Result := 'iso-8859-9 (Turkish ISO)';
    28603: 	Result := 'iso-8859-13 (Estonian ISO)';
    28605: 	Result := 'iso-8859-15 (Latin 9 ISO)';
    29001: 	Result := 'x-Europa (Europa 3)';
    38598: 	Result := 'iso-8859-8-i (Hebrew ISO-Logical)';
    50220: 	Result := 'iso-2022-jp (Japanese with no halfwidth Katakana)';
    50221: 	Result := 'csISO2022JP (Japanese with halfwidth Katakana)';
    50222: 	Result := 'iso-2022-jp (Japanese JIS X 0201-1989)';
    50225: 	Result := 'iso-2022-kr (Korean ISO)';
    50227: 	Result := 'x-cp50227 (Simplified Chinese ISO 2022)';
    54936:  Result := 'GB18030 (Chinese Simplified 4-Byte)';
    65000: 	Result := 'utf-7 (Unicode UTF-7)';
    65001:  Result := 'utf-8 (Unicode UTF-8)';
  else
    Result := 'codepage-' + IntToStr(CodepageIdentifier) + ' (Other/Unknown)';
  end;
end;

///////////////////////////////////////////////////////////////////////////////

function TrimEx(const Input: String; const MinChar: Char; const  MaxChar:Char): String;
var
  b: Boolean;
  i,x,y: Integer;
begin
  x := 1;
  y := Length(Input) + 1;
  b := True;

  for i := 1 to Length(Input) do
  begin
    if b then
    begin
      if (Input[i] >= MinChar) and (Input[i] <= MaxChar) then
      begin
        x := i;
        b := False;
      end;
    end else begin
      if (Input[i] < MinChar) or (Input[i] > MaxChar) then
      begin
        y := i;
        Break;
      end;
    end;
  end;

  Result := Copy(Input, x, y-x);
end;

///////////////////////////////////////////////////////////////////////////////

{Convert a version string in the "yyyy-mm-dd" format to a TDateTime value}

function VerStrToDate(const Str: String): Integer;
var
  y,m,d: Integer;
begin
  y := StrToIntDef(Copy(Str, 1, 4), -1);
  m := StrToIntDef(Copy(Str, 6, 2), -1);
  d := StrToIntDef(Copy(Str, 9, 2), -1);

  if (y < 0) or (m < 0) or (d < 0) then
  begin
    raise Exception.Create('VerStrToDate: Invalid version string passed!');
  end;

  Result := Floor(EncodeDate(y, m, d));
end;

///////////////////////////////////////////////////////////////////////////////

function MyMsgBox(const Parent: TWinControl; const Text: String; const Title: String; const Flags: UINT): Integer; overload;
var
  HasParent: Boolean;
  MyFlags: UINT;
  MyHandle: THandle;
const
  MB_CANCELTRYCONTINUE: DWORD = $00000006;
begin
  if Form_Main.Options.SilentMode then
  begin
    if (Flags and MB_ABORTRETRYIGNORE = 0) and (Flags and MB_CANCELTRYCONTINUE = 0) and (Flags and MB_OKCANCEL = 0) and (Flags and MB_RETRYCANCEL = 0) and (Flags and MB_YESNO = 0) and (Flags and MB_YESNOCANCEL = 0) then
    begin
      if (Flags and MB_ICONEXCLAMATION <> 0) then MessageBeep(MB_ICONEXCLAMATION);
      if (Flags and MB_ICONHAND <> 0) then MessageBeep(MB_ICONHAND);
      if (Flags and MB_ICONQUESTION <> 0) then MessageBeep(MB_ICONQUESTION);
      Result := ID_OK;
      Exit;
    end;
  end;  

  HasParent := False;

  if Assigned(Parent) then
  begin
    HasParent := Parent.Visible;
  end;

  if HasParent then
  begin
    MyHandle := Parent.Handle;
    MyFlags := Flags;
  end else begin
    MyHandle := GetActiveWindow;
    MyFlags := Flags or MB_TASKMODAL or MB_TOPMOST;
  end;

  Result := MessageBox(MyHandle, PAnsiChar(Text), PAnsiChar(Title), MyFlags);
end;

function MyMsgBox(const Parent: TWinControl; const Text: String; const Flags: UINT): Integer; overload;
begin
  Result := MyMsgBox(Parent, Text, 'LameXP', Flags);
end;

function MyMsgBox(const Text: String; const Flags: UINT): Integer; overload;
begin
  Result := MyMsgBox(nil, Text, Flags);
end;

///////////////////////////////////////////////////////////////////////////////

function MyLangBox(const Parent: TWinControl; const Name: String; const Title: String; const Flags: UINT): Integer; overload;
begin
  Assert(Assigned(Parent), 'MyMsgBoxLang: Parent control must be assigned!');
  Result := MyMsgBox(Parent, LangStr(Name, Parent.Name), Title, Flags);
end;

function MyLangBox(const Parent: TWinControl; const Name: String; const Flags: UINT): Integer; overload;
begin
  Assert(Assigned(Parent), 'MyMsgBoxLang: Parent control must be assigned!');
  Result := MyMsgBox(Parent, LangStr(Name, Parent.Name), Flags);
end;

//----------------------------------------//

function MyLangBoxEx(const Parent: TWinControl; const Name: String; const FormatStr: String; const Flags: UINT): Integer; overload;
begin
  Assert(Assigned(Parent), 'MyMsgBoxLang: Parent control must be assigned!');
  Result := MyMsgBox(Parent, Format(FormatStr, [LangStr(Name, Parent.Name)]), Flags);
end;

function MyLangBoxEx(const Parent: TWinControl; const Name: String; const FormatStr: String; const Title: String; const Flags: UINT): Integer; overload;
begin
  Assert(Assigned(Parent), 'MyMsgBoxLang: Parent control must be assigned!');
  Result := MyMsgBox(Parent, Format(FormatStr, [LangStr(Name, Parent.Name)]), Title, Flags);
end;

//----------------------------------------//

function MyLangBoxFmt(const Parent: TWinControl; const Name: String; const Args: array of const; const Flags: UINT): Integer;
begin
  Assert(Assigned(Parent), 'MyMsgBoxLang: Parent control must be assigned!');
  Result := MyMsgBox(Parent, Format(LangStr(Name, Parent.Name), Args), Flags);
end;

function MyLangBoxFmtEx(const Parent: TWinControl; const Name: String; const FormatStr: String; const Args: array of const; const Flags: UINT): Integer;
begin
  Assert(Assigned(Parent), 'MyMsgBoxLang: Parent control must be assigned!');
  Result := MyMsgBox(Parent, Format(FormatStr, [Format(LangStr(Name, Parent.Name), Args)]), Flags);
end;

///////////////////////////////////////////////////////////////////////////////

function PlayResoureSound(const LibFile: String; const SoundId: Cardinal; const Async: Boolean): Boolean;
var
  Flags: DWORD;
  Module: HMODULE;
begin
  Result := False;

  if Async then
  begin
    Flags := SND_RESOURCE or SND_ASYNC;
  end else begin
    Flags := SND_RESOURCE or SND_SYNC;
  end;

  Module := SafeLoadLibrary(LibFile);

  if Module <> 0 then
  begin
    Result := PlaySound(PAnsiChar(SoundId), Module, Flags);
    FreeLibrary(Module);
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure InitSystemSounds;
var
  Reg: TRegistry;
  Keys: TStringList;
  i: Integer;
  j: Integer;
  s: String;
  p: Pointer;
const
  Profiles: array[0..1] of String = ('Current', 'Default');
begin
  if Assigned(SystemSoundCache) then
  begin
    for i := 0 to SystemSoundCache.Count - 1 do
    begin
      try
        FreeMem(Pointer(SystemSoundCache.Objects[i]));
      finally
        SystemSoundCache.Objects[i] := nil;
      end;
    end;
    FreeAndNil(SystemSoundCache);
  end;

  SystemSoundCache := TStringList.Create;

  Keys := TStringList.Create;
  Reg := TRegistry.Create;

  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly('AppEvents\Schemes\Apps\.Default') then
    begin
      Keys.Clear;
      Reg.GetKeyNames(Keys);
      Reg.CloseKey;
      for i := 0 to Keys.Count-1 do
      begin
        for j := 0 to 1 do
        begin
          if Reg.OpenKeyReadOnly(Format('AppEvents\Schemes\Apps\.Default\%s\.%s', [Keys[i], Profiles[j]])) then
          begin
            if IsRegString(Reg.GetDataType('')) then
            begin
              s := ExpandEnvStr(Trim(Reg.ReadString('')));
              if (s <> '') and SafeFileExists(s) then
              begin
                if SystemSoundCache.IndexOf(Keys[i]) < 0 then
                begin
                  try
                    GetMem(p, Length(s) + 1);
                    StrCopy(p, PAnsiChar(s));
                    SystemSoundCache.AddObject(Keys[i], p);
                  except
                    Reg.CloseKey;
                    Break;
                  end;
                end;
              end;
            end;
            Reg.CloseKey;
          end;
        end;
      end;
    end;
  finally
    Reg.Free;
    Keys.Free;
  end;
end;

function PlaySystemSound(const Name: String; const Async: Boolean): Boolean; overload;
var
  Flags: DWORD;
  Index: Integer;
begin
  Result := False;

  if Async then
  begin
    Flags := SND_FILENAME or SND_ASYNC;
  end else begin
    Flags := SND_FILENAME or SND_SYNC;
  end;

  if not Assigned(SystemSoundCache) then
  begin
    InitSystemSounds;
  end;

  Index := SystemSoundCache.IndexOf(Name);

  if Index >= 0 then
  begin
    Result := PlaySound(PAnsiChar(SystemSoundCache.Objects[Index]), 0, Flags);
  end;
end;

function PlaySystemSound(const Name: array of String; const Async: Boolean): Boolean; overload;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to Length(Name)-1 do
  begin
    Result := PlaySystemSound(Name[i], Async);
    if Result then Break;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

function IsProcessElevated: Boolean;
type
  TTokenElevationType = Cardinal;
const
  TokenElevationType: TTokenInformationClass = TTokenInformationClass(18);
  TokenElevationTypeFull: Cardinal = 2;
var
  OsVer: TOSVersionInfo;
  Token: THandle;
  Value: TTokenElevationType;
  Dummy: Cardinal;
begin
  Result := False;

  ZeroMemory(@OsVer, SizeOf(TOSVersionInfo));
  OsVer.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);

  if not GetVersionEx(OsVer) then
  begin
    Exit;
  end;

  if (OsVer.dwPlatformId <> VER_PLATFORM_WIN32_NT) or (OsVer.dwMajorVersion < 6) then
  begin
    Exit;
  end;

  if not Windows.OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, Token) then
  begin
    Exit;
  end;

  if not Windows.GetTokenInformation(Token, TokenElevationType, @Value, SizeOf(Value), Dummy) then
  begin
    CloseHandle(Token);
    Exit;
  end;

  CloseHandle(Token);

  if Dummy = SizeOf(Value) then
  begin
    Result := (Value = TokenElevationTypeFull);
  end;
end;

function IsRegString(RegType: TRegDataType): Boolean;
begin
  Result := (RegType = rdString) or (RegType = rdExpandString);
end;

///////////////////////////////////////////////////////////////////////////////

function Lookup(const Map: array of TMapEntry; const Key: String; const Default: String): String;
var
  i: Integer;
begin
  for i := 0 to High(Map) do
  begin
    if SameText(Key, Map[i,0]) then
    begin
      Result := Map[i,1];
      Exit;
    end;
  end;

  Result := Default;
end;

///////////////////////////////////////////////////////////////////////////////

function ShortenURL(const URL: String; const MaxLen: Integer): String;
var
  i,x: Integer;
  PreFix,PostFix: String;
begin
  if MaxLen < 9 then
  begin
    Result := URL;
    Exit;
  end;

  PreFix := '';
  PostFix := '';
  x := 0;

  for i := 1 to Length(URL) do
  begin
    if URL[i] = '/' then
    begin
      x := x + 1;
      if x = 3 then
      begin
        PreFix := Copy(URL, 1, i);
        PostFix := Copy(URL, i+1, Length(URL));
      end;
    end;
  end;

  if (PreFix = '') or (PostFix = '') then
  begin
    Result := URL;
    Exit;
  end;

  while (Length(PreFix) + Length(PostFix) + 3 > MaxLen) and (Length(PreFix) > 0) and (Length(PostFix) > 0) do
  begin
    if Length(PostFix) > 3 then
    begin
      PostFix := Copy(PostFix, 2, Length(PostFix));
    end else begin
      PreFix := Copy(PreFix, 1, Length(PreFix) - 1);
    end;
  end;

  Result := Format('%s...%s', [PreFix, PostFix]);
end;

///////////////////////////////////////////////////////////////////////////////

procedure MyCreateForm(const AppObject: TApplication; const InstanceClass: TComponentClass; var Reference);
var
  ErrorMode: UINT;
begin
  ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    AddTimerEvent('CreateForm: ' + InstanceClass.ClassName);
    AppObject.CreateForm(InstanceClass, Reference);
  finally
    SetErrorMode(ErrorMode);
  end;
end;

function MyCreateForm(const InstanceClass: TComponentClass; const AOwner: TComponent): TComponent;
var
  ErrorMode: UINT;
begin
  ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := InstanceClass.Create(AOwner);
  finally
    SetErrorMode(ErrorMode);
  end;
end;

///////////////////////////////////////////////////////////////////////////////

procedure ForceApplicationUpdate(const Cursor: TCursor);
begin
  Application.ProcessMessages;
  SetCursor(Screen.Cursors[Cursor]);
end;

///////////////////////////////////////////////////////////////////////////////

procedure AddTimerEvent(const Text: String);
var
  CurrentTickCount: Cardinal;
begin
  if not CaptureTimerEvents then
  begin
    Exit;
  end;  

  if not Assigned(TimerEvents) then
  begin
    InitialTickCount := GetTickCount;
    PreviousTickCount := InitialTickCount;
    try
      TimerEvents := TStringList.Create;
      TimerEvents.Add(Format('[%.8u] [%.8u] %s', [0, 0, Text]));
    except
      TimerEvents := nil;
    end;
  end else begin
    try
      CurrentTickCount := GetTickCount();
      TimerEvents.Add(Format('[%.8u] [%.8u] %s', [CurrentTickCount - InitialTickCount, CurrentTickCount - PreviousTickCount, Text]));
      PreviousTickCount := CurrentTickCount;
    except
      TimerEvents := nil;
    end;
  end;
end;

procedure SaveTimerEvents(const Filename: String);
begin
  if not CaptureTimerEvents then
  begin
    Exit;
  end;  

  if Assigned(TimerEvents) then
  begin
    try
      TimerEvents.SaveToFile(Filename);
    except
      MessageBeep(MB_ICONERROR);
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////

initialization
  SystemSoundCache := nil;
  CaptureTimerEvents := False;
  TimerEvents := nil;
  InitialTickCount := 0;
  PreviousTickCount := 0;

finalization
  if Assigned(SystemSoundCache) then FreeAndNil(SystemSoundCache);
  if Assigned(TimerEvents) then FreeAndNil(TimerEvents);

end.
