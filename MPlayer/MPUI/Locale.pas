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
unit Locale;
interface
uses Graphics, SysUtils;

type TLocale=record
               Name:string[7];
               LangID,SubID:integer;
               Charset:TFontCharset;
               Data:string;
             end;
var LocaleNames:array of WideString;             

// locale texts that are not bound to controls
var _:record
  Title:WideString;
  OpenURL_Caption:WideString;
  OpenURL_Prompt:WideString;
  Status_Opening:WideString;
  Status_Closing:WideString;
  Status_Playing:WideString;
  Status_Paused:WideString;
  Status_Stopped:WideString;
  Status_Error:WideString;

  NoInfo:WideString;
  InfoFileFormat:WideString;
  InfoPlaybackTime:WideString;
  InfoTags:WideString;
  InfoVideo:WideString;
  InfoAudio:WideString;
  InfoDecoder:WideString;
  InfoCodec:WideString;
  InfoBitrate:WideString;
  InfoVideoSize:WideString;
  InfoVideoFPS:WideString;
  InfoVideoAspect:WideString;
  InfoAudioRate:WideString;
  InfoAudioChannels:WideString;
end;

procedure InitLocaleSystem;
function ActivateLocale(const Name:string):boolean;
function GetNextLocaleString:WideString;

implementation
uses Windows, Forms, Main, Help, Options, plist, About, Log, Info, LocaleData;


function ExtractString(const Data:string; Index:integer; var Dest:WideString):integer;
begin
  Result:=Index;
  while Data[Result]<>#0 do inc(Result);
  Dest:=UTF8Decode(copy(Data,Index,Result-Index));
  inc(Result);
end;


procedure InitLocaleSystem;
var i:integer; w:WideString;
begin
  SetLength(LocaleNames, length(Locales));
  for i:=0 to High(Locales) do
    with Locales[i] do begin
      ExtractString(Data, 1, w);
      LocaleNames[i]:=WideString('['+Name+'] ') + w;
    end;
end;


// locale string enumerator
var LocaleToActivate:integer;
var RealPos,RefPos:integer;
var StringsFromFile:array[0..StringCount-1]of string;
var RefStr:WideString;

function GetNextLocaleString:WideString;
begin
  RefPos:=ExtractString(Locales[FallbackLocale].Data, RefPos, RefStr);
  if LocaleToActivate<0 then begin
    Result:=UTF8Decode(StringsFromFile[RealPos]);
    inc(RealPos);
  end else
    RealPos:=ExtractString(Locales[LocaleToActivate].Data, RealPos, Result);
  if length(Result)=0 then Result:=RefStr;
end;


// locale file loader
var StringNameList:array[0..StringCount-1]of string;
var StringNameListValid:boolean=false;

function LoadLocaleFile(const Name:string):boolean;
var i, ss,se, Sep, Index:integer;
var s, Key, Text:string; t:System.text;
begin
  Result:=False;

  // build the string name list first
  if not StringNameListValid then begin
    ss:=1;
    for i:=0 to High(StringNameList) do begin
      se:=ss;
      while StringNames[se]<>#0 do inc(se);
      StringNameList[i]:=LowerCase(copy(StringNames,ss,se-ss));
      ss:=se+1;
    end;
    StringNameListValid:=True;
  end;

  // clear the string list
  for i:=0 to High(StringsFromFile) do
    StringsFromFile[i]:='';

  // parse the file
  AssignFile(t, Name);
  {$I-} Reset(t); {$I+}
  if IOresult<>0 then exit;
  while not EOF(t) do begin
    readln(t,s);
    s:=Trim(s);
    if (length(s)=0) OR (s[1]='#') then continue;
    Sep:=Pos('=',s); if Sep<1 then continue;
    Key:=Trim(copy(s,1,Sep-1));
    if length(Key)=0 then continue;
    Text:=Trim(copy(s,Sep+1,length(s)));
    s:=LowerCase(Key);
    Index:=-1;
    for i:=0 to High(StringNameList) do
      if s=StringNameList[i] then begin
        Index:=i;
        break;
      end;
    if Index>=0 then begin
      StringsFromFile[Index]:=Text;
    end else if s[1]<>'@' then begin
      AllocConsole;
      writeln('string name `', Key, #39' undefined'); 
    end;
  end;
  CloseFile(t);
  Result:=True;
end;


// locale activation function

function ActivateLocale(const Name:string):boolean;
var MangledName:string;
var i,WantedLangID,WantedSubID,MatchLevel,BestMatchLevel,LocaleIndex:integer;
begin
  Result:=False;
  MangledName:=LowerCase(Trim(Name));
  if (MangledName='auto') OR (length(Name)=0) then begin
    // auto-detect locale
    WantedLangID:=GetUserDefaultLCID();
    WantedSubID:=(WantedLangID SHR 10) AND 63;
    WantedLangID:=WantedLangID AND 1023;
    BestMatchLevel:=0; LocaleIndex:=FallbackLocale;
    for i:=Low(Locales) to High(Locales) do with Locales[i] do begin
      if LangID<>WantedLangID then MatchLevel:=0
      else if SubID<>WantedSubID then MatchLevel:=1
      else MatchLevel:=2;
      if MatchLevel>BestMatchLevel then begin
        BestMatchLevel:=MatchLevel;
        LocaleIndex:=i;
      end;
    end;
  end else begin
    // pick locale from list
    LocaleIndex:=-1;
    for i:=Low(Locales) to High(Locales) do
      if LowerCase(Locales[i].Name)=MangledName then begin
        LocaleIndex:=i;
        break;
      end;
  end;

  if LocaleIndex>=0 then begin
    // activate a built-in locale
    // we do have charset information for these, so use it
    MainForm.Font.Charset:=Locales[LocaleIndex].Charset;
    OptionsForm.Font.Charset:=Locales[LocaleIndex].Charset;
    PlaylistForm.Font.Charset:=Locales[LocaleIndex].Charset;
    HelpForm.Font.Charset:=Locales[LocaleIndex].Charset;
    InfoForm.Font.Charset:=Locales[LocaleIndex].Charset;
    MainForm.LEscape.Font.Charset:=Locales[LocaleIndex].Charset;
    OptionsForm.LHelp.Font.Charset:=Locales[LocaleIndex].Charset;
    AboutForm.Font.Charset:=Locales[LocaleIndex].Charset;
    AboutForm.MTitle.Font.Charset:=Locales[LocaleIndex].Charset;
    AboutForm.LVersionMPUI.Font.Charset:=Locales[LocaleIndex].Charset;
    AboutForm.LVersionMPlayer.Font.Charset:=Locales[LocaleIndex].Charset;
    // set up the enumerator
    RealPos:=1;
  end else begin
    // check if it is a file locale. if not, the locale name is invalid
    if not LoadLocaleFile(Name) then exit;
    // set up the enumerator
    RealPos:=0;
  end;

  // apply the strings
  LocaleToActivate:=LocaleIndex;
  RefPos:=1;
  ApplyLocaleStrings();

  // adjust some other stuff
  HelpForm.Format;
  OptionsForm.Localize;
  InfoForm.UpdateInfo;
  MainForm.Localize;
  MainForm.UpdateStatus;
  Application.Title:=_.Title;
  MainForm.UpdateCaption;
  with MainForm.MLanguage do
    if LocaleIndex>=0 then begin
      for i:=0 to Count-1 do
        if Items[i].Tag=LocaleIndex then
          Items[i].Checked:=true;
    end else begin
      for i:=0 to Count-1 do
        Items[i].Checked:=false;
    end;
  Result:=True;
end;

end.
