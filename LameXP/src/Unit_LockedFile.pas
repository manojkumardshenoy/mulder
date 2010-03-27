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

unit Unit_LockedFile;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, MuldeR_Toolz,
  JvDataEmbedded, Unit_RIPEMD160;

type
  ELockedFile = class(Exception);
  TLockedFile = class(TObject)
    private
      Handle: THandle;
      Filename: String;
      HashValue: String;
      Delete: Boolean;
      TagData: Integer;
      CriticalSection: TRTLCriticalSection;
      function GetLocation: String;
    public
      constructor Create(Filename: String); overload;
      constructor Create(Data: TJvDataEmbedded; HashValue: String; Filename: String); overload;
      destructor Destroy; override;
      procedure CheckHashValue;
      property Location: String read GetLocation;
      property Tag: Integer read TagData;
    end;

implementation

constructor TLockedFile.Create(Filename: String);
begin
  Create(nil, '', Filename);
end;

constructor TLockedFile.Create(Data: TJvDataEmbedded; HashValue: String; Filename: String);
var
  Temp: THandle;
  Stream: THandleStream;
begin
  InitializeCriticalSection(CriticalSection);

  Self.Filename := Trim(Filename);
  Self.HashValue := Trim(HashValue);

  Handle := INVALID_HANDLE_VALUE;
  Delete := False;
  TagData := 0;

  if Assigned(Data) then
  begin
    Temp := CreateFile(PAnsiChar(Filename), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, 0, 0);
    if Temp = INVALID_HANDLE_VALUE then
    begin
      raise ELockedFile.Create('Faild to create file at: ' + Filename);
    end;
    try
      Stream := THandleStream.Create(Temp);
      Data.DataSaveToStream(Stream);
      Stream.Free;
      CloseHandle(Temp);
      Delete := True;
      TagData := Data.Tag;
    except
      raise ELockedFile.Create('Faild to save data to: ' + Filename);
    end;
  end;

  Handle := CreateFile(PAnsiChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if Handle = INVALID_HANDLE_VALUE then
  begin
    raise ELockedFile.Create('Faild to lock file at: ' + Filename);
  end;

  GetLocation; {Will check the hash initally}
end;

destructor TLockedFile.Destroy;
var
  i: Integer;
begin
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(Handle);
  end;

  if Delete then
  begin
    for i := 1 to 100 do
    begin
      if RemoveFile(Filename) then Break;
      Sleep(100);
    end;
  end;

  DeleteCriticalSection(CriticalSection);
end;

procedure TLockedFile.CheckHashValue;
var
  Stream: THandleStream;
  HashAlgo: TRipemd160;
  DigestStr: String;
begin
  EnterCriticalSection(CriticalSection);
  try
    if (HashValue = '') or (Handle = INVALID_HANDLE_VALUE) then
    begin
      Exit;
    end;

    DigestStr := 'N/A';
    HashAlgo := TRipemd160.Create;
    Stream := THandleStream.Create(Handle);
    SetFilePointer(Handle, 0, nil, FILE_BEGIN);

    try
      HashAlgo.Init;
      HashAlgo.UpdateStream(Stream, Stream.Size);
      HashAlgo.FinalStr(DigestStr);
    finally
      Stream.Free;
      HashAlgo.Free;
    end;

    if not SameText(HashValue, DigestStr) then
    begin
      raise ELockedFile.Create(Format('Hashvalue of "%s" is invalid (got "%s", expected "%s").',[Filename, DigestStr, HashValue]));
    end;
  finally
    LeaveCriticalSection(CriticalSection);
  end;
end;

function TLockedFile.GetLocation: String;
begin
  try
    CheckHashValue;
  except
    FatalAppExit(0, PAnsiChar(Format('Data verification failed: File ''%s'' seems to be corrupted. LameXP was either built incorrectly or it was hacked (amateurishly) afterwards. Take care!', [ExtractFileName(Filename)])));
    TerminateProcess(GetCurrentProcess, DWORD(-1));
  end;

  Result := Filename;
end;

end.

