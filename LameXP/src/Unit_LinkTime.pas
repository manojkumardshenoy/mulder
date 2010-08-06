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

///////////////////////////////////////////////////////////////////////////////
// The code in this file was ported from an excerpt posted on Delphi-PRAXiS:
// http://www.delphipraxis.net/85748-post1.html
///////////////////////////////////////////////////////////////////////////////

unit Unit_LinkTime;

/////////////////////////////////////////////////////////////////
interface
/////////////////////////////////////////////////////////////////

uses
  Windows, SysUtils, DateUtils, Unit_WideStrUtils;

function GetImageLinkTimeStampAsDate: TDateTime;
function GetImageLinkTimeStampAsString(const Full: Boolean): String;
procedure GetImageLinkTimeStampAsIntegers(var Year: Integer; var Month: Integer; var Day: Integer);

/////////////////////////////////////////////////////////////////
implementation
/////////////////////////////////////////////////////////////////

var
  LinkTimeStamp: TDateTime;
  CriticalSection: TRTLCriticalSection;

/////////////////////////////////////////////////////////////////
// Internal functions
/////////////////////////////////////////////////////////////////

function GetImageLinkTimeStamp(const FileName: WideString): DWORD;
const
  INVALID_SET_FILE_POINTER = DWORD(-1);
  BorlandMagicTimeStamp = $2A425E19; // Delphi 4-6 (and above?)
  FileTime1970: TFileTime = (dwLowDateTime:$D53E8000; dwHighDateTime:$019DB1DE);
type
  PImageSectionHeaders = ^TImageSectionHeaders;
  TImageSectionHeaders = array [Word] of TImageSectionHeader;
type
  PImageResourceDirectory = ^TImageResourceDirectory;
  TImageResourceDirectory = packed record
    Characteristics: DWORD;
    TimeDateStamp: DWORD;
    MajorVersion: Word;
    MinorVersion: Word;
    NumberOfNamedEntries: Word;
    NumberOfIdEntries: Word;
  end;
var
  FileHandle: THandle;
  BytesRead: DWORD;
  ImageDosHeader: TImageDosHeader;
  ImageNtHeaders: TImageNtHeaders;
  SectionHeaders: PImageSectionHeaders;
  Section: Word;
  ResDirRVA: DWORD;
  ResDirSize: DWORD;
  ResDirRaw: DWORD;
  ResDirTable: TImageResourceDirectory;
  FileTime: TFileTime;
begin
  Result := 0;
  // Open file for read access
  FileHandle := CreateFileW(PWideChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if (FileHandle <> INVALID_HANDLE_VALUE) then
  try
    // Read MS-DOS header to get the offset of the PE32 header (not required on WinNT based systems - but mostly available)
    if not ReadFile(FileHandle, ImageDosHeader, SizeOf(TImageDosHeader), BytesRead, nil) or (BytesRead <> SizeOf(TImageDosHeader)) or (ImageDosHeader.e_magic <> IMAGE_DOS_SIGNATURE) then
    begin
      ImageDosHeader._lfanew := 0;
    end;
    // Read PE32 header (including optional header
    if (SetFilePointer(FileHandle, ImageDosHeader._lfanew, nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER) then
    begin
      Exit;
    end;
    if not(ReadFile(FileHandle, ImageNtHeaders, SizeOf(TImageNtHeaders), BytesRead, nil) and (BytesRead = SizeOf(TImageNtHeaders))) then
    begin
      Exit;
    end;
    // Validate PE32 image header
    if (ImageNtHeaders.Signature <> IMAGE_NT_SIGNATURE) then
    begin
      Exit;
    end;
    // Seconds since 1970 (UTC)
    Result := ImageNtHeaders.FileHeader.TimeDateStamp;

    // Check for Borland's magic value for the link time stamp (we take the time stamp from the resource directory table)
    if (ImageNtHeaders.FileHeader.TimeDateStamp = BorlandMagicTimeStamp) then
    with ImageNtHeaders, FileHeader, OptionalHeader do
    begin
      // Validate Optional header
      if (SizeOfOptionalHeader < IMAGE_SIZEOF_NT_OPTIONAL_HEADER) or (Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then
      begin
        Exit;
      end;
      // Read section headers
      SectionHeaders := GetMemory(NumberOfSections * SizeOf(TImageSectionHeader));
      if Assigned(SectionHeaders) then
      try
        if (SetFilePointer(FileHandle, SizeOfOptionalHeader - IMAGE_SIZEOF_NT_OPTIONAL_HEADER, nil, FILE_CURRENT) = INVALID_SET_FILE_POINTER) then
        begin
          Exit;
        end;
        if not(ReadFile(FileHandle, SectionHeaders^, NumberOfSections * SizeOf(TImageSectionHeader), BytesRead, nil) and (BytesRead = NumberOfSections * SizeOf(TImageSectionHeader))) then
        begin
          Exit;
        end;
        // Get RVA and size of the resource directory
        with DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE] do
        begin
          ResDirRVA := VirtualAddress;
          ResDirSize := Size;
        end;
        // Search for section which contains the resource directory
        ResDirRaw := 0;
        for Section := 0 to NumberOfSections - 1 do
        with SectionHeaders[Section] do
        begin
          if (VirtualAddress <= ResDirRVA) and (VirtualAddress + SizeOfRawData >= ResDirRVA + ResDirSize) then
          begin
            ResDirRaw := PointerToRawData - (VirtualAddress - ResDirRVA);
            Break;
          end;
        end;
        // Resource directory table found?
        if (ResDirRaw = 0) then
        begin
          Exit;
        end;
        // Read resource directory table
        if (SetFilePointer(FileHandle, ResDirRaw, nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER) then
        begin
          Exit;
        end;
        if not(ReadFile(FileHandle, ResDirTable, SizeOf(TImageResourceDirectory), BytesRead, nil) and (BytesRead = SizeOf(TImageResourceDirectory))) then
        begin
          Exit;
        end;
        // Convert from DosDateTime to SecondsSince1970
        if DosDateTimeToFileTime(HiWord(ResDirTable.TimeDateStamp), LoWord(ResDirTable.TimeDateStamp), FileTime) then
        begin
          Result := (ULARGE_INTEGER(FileTime).QuadPart - ULARGE_INTEGER(FileTime1970).QuadPart) div 10000000;
        end;
      finally
        FreeMemory(SectionHeaders);
      end;
    end;
  finally
    CloseHandle(FileHandle);
  end;
end;

function UpdateLinkTimeStamp: Boolean;
var
  TempTimeStamp: DWORD;
begin
  EnterCriticalSection(CriticalSection);
  try
    if LinkTimeStamp > 0.0 then
    begin
      Result := True;
    end else
    begin
      TempTimeStamp := GetImageLinkTimeStamp(ParamStrW(0));
      if TempTimeStamp > 0 then
      begin
        LinkTimeStamp := UnixToDateTime(TempTimeStamp);
        Result := True;
      end else
      begin
        Result := False;
      end;
    end;
  finally
    LeaveCriticalSection(CriticalSection);
  end;
end;

/////////////////////////////////////////////////////////////////
// Public functions
/////////////////////////////////////////////////////////////////

function GetImageLinkTimeStampAsDate: TDateTime;
begin
  if UpdateLinkTimeStamp then
  begin
    Result := LinkTimeStamp;
  end else
  begin
    Result := 0.0;
  end;
end;

function GetImageLinkTimeStampAsString(const Full: Boolean): String;
begin
  if UpdateLinkTimeStamp then
  begin
    Result := Format('%.4d-%.2d-%.2d', [YearOf(LinkTimeStamp), MonthOf(LinkTimeStamp), DayOfTheMonth(LinkTimeStamp)]);
    if Full then
    begin
      Result := Result + Format(', %.2d:%.2d:%.2d', [HourOf(LinkTimeStamp), MinuteOf(LinkTimeStamp), SecondOf(LinkTimeStamp)]);
    end;
  end else
  begin
    Result := 'N/A';
  end;
end;

procedure GetImageLinkTimeStampAsIntegers(var Year: Integer; var Month: Integer; var Day: Integer);
begin
  if UpdateLinkTimeStamp then
  begin
    Month := MonthOf(LinkTimeStamp);
    Year := YearOf(LinkTimeStamp);
    Day := DayOfTheMonth(LinkTimeStamp);
  end else
  begin
    Month := 0;
    Year := 0;
    Day := 0;
  end;
end;

/////////////////////////////////////////////////////////////////
// Initialization
/////////////////////////////////////////////////////////////////

initialization
begin
  InitializeCriticalSection(CriticalSection);
  LinkTimeStamp := 0.0;
end;

finalization
begin
  DeleteCriticalSection(CriticalSection);
end;

end.
