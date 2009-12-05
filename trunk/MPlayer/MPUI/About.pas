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
unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ShellAPI, TntStdCtrls, TntExtCtrls, TntForms;

type
  TAboutForm = class(TTntForm)
    PLogo: TTntPanel;
    ILogo: TTntImage;
    VersionMPUI: TTntLabel;
    VersionMPlayer: TTntLabel;
    BClose: TTntButton;
    MCredits: TTntMemo;
    LVersionMPlayer: TTntLabel;
    LVersionMPUI: TTntLabel;
    MTitle: TTntMemo;
    LURL: TTntLabel;
    LMulder: TTntLabel;
    procedure FormShow(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
    procedure URLClick(Sender: TObject);
    procedure ReadOnlyItemEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LMulderClick(Sender: TObject);
    procedure LMulderMouseEnter(Sender: TObject);
    procedure LMulderMouseLeave(Sender: TObject);
    procedure LDummyMouseEnter(Sender: TObject);
    procedure LDummyMouseLeave(Sender: TObject);
    procedure ILogoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation
                
uses Main, Core, Locale;

{$R *.dfm}

function GetProductVersion(const FileName:string):string;
const BufSize=1024*1024;
var Buf:array of char;
var VerOut:PChar; VerLen:cardinal;
begin
  Result:='?';
  SetLength(Buf,BufSize);
  if not GetFileVersionInfo(PChar(FileName),0,BufSize,@Buf[0]) then exit;
  if not VerQueryValue(@Buf[0],'\StringFileInfo\000004B0\ProductVersion',Pointer(VerOut),VerLen) then exit;
  Result:=VerOut;
end;

function GetFileVersion(const FileName:string):string;
const BufSize=1024*1024;
var Buf:array of char;
    VerLen:cardinal; Info:^VS_FIXEDFILEINFO;
    Attributes:string;
begin
  Result:='?';
  SetLength(Buf,BufSize);
  if not GetFileVersionInfo(PChar(FileName),0,BufSize,@Buf[0]) then exit;
  if not VerQueryValue(@Buf[0],'\',Pointer(Info),VerLen) then exit;
  Attributes:='';
  if (Info.dwFileFlags AND VS_FF_PATCHED<>0)      then Attributes:=Attributes+' patched';
  if (Info.dwFileFlags AND VS_FF_DEBUG<>0)        then Attributes:=Attributes+' debug';
  if (Info.dwFileFlags AND VS_FF_PRIVATEBUILD<>0) then Attributes:=Attributes+' private';
  if (Info.dwFileFlags AND VS_FF_SPECIALBUILD<>0) then Attributes:=Attributes+' special';
  if Info.dwFileVersionLS > (900 SHL 16) then
    Result:=IntToStr(Info.dwFileVersionMS SHR 16)+'.'+
            IntToStr((Info.dwFileVersionMS AND $FFFF)+1)+'-pre'+
            IntToStr((Info.dwFileVersionLS SHR 16) MOD 100)+' build '+
            IntToStr(Info.dwFileVersionLS AND $FFFF)
  else begin
    Result:=IntToStr(Info.dwFileVersionMS SHR 16)+'.'+
            IntToStr(Info.dwFileVersionMS AND $FFFF)+'.'+
            IntToStr(Info.dwFileVersionLS SHR 16)+' build '+
            IntToStr(Info.dwFileVersionLS AND $FFFF);
    if (Info.dwFileFlags AND VS_FF_PRERELEASE<>0)   then Attributes:=Attributes+' pre-release';
  end;
  if length(Attributes)>0 then Result:=Result+' ('+Copy(Attributes,2,100)+')';
end;



procedure TAboutForm.FormShow(Sender: TObject);
begin
  //ILogo.Picture:=MainForm.Logo.Picture;
  MTitle.Text:=_.Title;
  VersionMPlayer.Caption:=GetProductVersion(HomeDir+'mplayer.exe');
  VersionMPUI.Caption:=GetFileVersion(HomeDir+ExtractFileName(ParamStr(0)));
  ActiveControl:=BClose;
end;

procedure TAboutForm.BCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.URLClick(Sender: TObject);
var s:string;
begin
  s:=(Sender as TTntLabel).Caption;
  ShellExecute(Handle,'open',PChar(s),nil,nil,SW_SHOW);
end;

procedure TAboutForm.ReadOnlyItemEnter(Sender: TObject);
begin
  ActiveControl:=BClose;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
{$IFDEF VER150}
  // some fixes for Delphi>=7 VCLs
  PLogo.ParentBackground:=False;
{$ENDIF}
end;

procedure TAboutForm.LMulderClick(Sender: TObject);
begin
  ShellExecute(self.WindowHandle,'open','http://mulder.at.gg/',nil,nil,SW_SHOWMAXIMIZED);
end;

procedure TAboutForm.LMulderMouseEnter(Sender: TObject);
begin
  with Sender as TTntLabel do begin
    Font.Style:=LMulder.Font.Style+[fsUnderline];
  end;
end;

procedure TAboutForm.LMulderMouseLeave(Sender: TObject);
begin
  with Sender as TTntLabel do begin
    Font.Style:=LMulder.Font.Style-[fsUnderline];
  end;
end;

procedure TAboutForm.LDummyMouseEnter(Sender: TObject);
begin
  PLogo.BevelInner := bvLowered;
end;

procedure TAboutForm.LDummyMouseLeave(Sender: TObject);
begin
  PLogo.BevelInner := bvRaised;
end;

procedure TAboutForm.ILogoClick(Sender: TObject);
begin
  ShellExecute(self.WindowHandle,'open','http://mplayerhq.hu/',nil,nil,SW_SHOWMAXIMIZED);
end;

end.
