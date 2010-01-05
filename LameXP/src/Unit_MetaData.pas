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

unit Unit_MetaData;

interface

uses
  Windows, SysUtils, Dialogs, Classes, MuldeR_Toolz;

type
  TMetaData = class(TObject)
  private
    Data_Title: String;
    Data_Artist: String;
    Data_Album: String;
    Data_Genre: String;
    Data_Year: Integer;
    Data_Comment: String;
    Data_Track: Integer;
    Data_Duration: Integer;
    Data_Container: String;    // Container Type
    Data_Flavor: String;       // Container Profile
    Data_Format: String;       // Audio Format Type
    Data_Version: String;      // Audio Format Version
    Data_Profile: String;      // Audio Format Profile
    Data_Decoder: Integer;     // Index of Decoder
    More_Keys: TStringList;
    More_Values: TStringList;
  protected
  public
    property Title: String read Data_Title write Data_Title;
    property Artist: String read Data_Artist write Data_Artist;
    property Album: String read Data_Album write Data_Album;
    property Genre: String read Data_Genre write Data_Genre;
    property Year: Integer read Data_Year write Data_Year;
    property Comment: String read Data_Comment write Data_Comment;
    property Track: Integer read Data_Track write Data_Track;
    property Duration: Integer read Data_Duration write Data_Duration;
    property Container: String read Data_Container write Data_Container;
    property Flavor: String read Data_Flavor write Data_Flavor;
    property Format: String read Data_Format write Data_Format;
    property Version: String  read Data_Version write Data_Version;
    property Profile: String read Data_Profile write Data_Profile;
    property Decoder: Integer read Data_Decoder write Data_Decoder;
    constructor Create;
    destructor Destroy; override;
    procedure AddInfo(Key: String; Value: String);
    function GetInfo(Key: String): String;
    procedure GetAll(Keys: TStringList; Values: TStringList);
  end;

implementation

constructor TMetaData.Create;
begin
  Data_Title := '';
  Data_Artist := '';
  Data_Album := '';
  Data_Genre := '';
  Data_Year := 0;
  Data_Comment := '';
  Data_Track := 0;
  Data_Duration := 0;
  Data_Container := '';
  Data_Flavor := '';
  Data_Format := '';
  Data_Version := '';
  Data_Profile := '';
  Data_Decoder := -1;

  More_Keys := TStringList.Create;
  More_Keys.CaseSensitive := False;
  More_Values := TStringList.Create;
end;

destructor TMetaData.Destroy;
begin
  More_Keys.Free;
  More_Values.Free;
end;

procedure TMetaData.AddInfo(Key: String; Value: String);
begin
  More_Keys.Add(Key);
  More_Values.Add(Value);
end;

function TMetaData.GetInfo(Key: String): String;
var
  i: Integer;
begin
  if More_Keys.Find(Key,i) then
  begin
    Result := More_Values[i];
    Exit;
  end;

  Result := '<UNKNOWN>';
end;

procedure TMetaData.GetAll(Keys: TStringList; Values: TStringList);
begin
  Keys.Clear;
  Values.Clear;
  Keys.AddStrings(More_Keys);
  Values.AddStrings(More_Values);
end;

end.
