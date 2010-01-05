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

unit Unit_Encoder;

interface

uses
  Windows, SysUtils, Dialogs, Classes, Contnrs, Math, Unit_LockedFile,
  MuldeR_Toolz, Unit_Decoder, Unit_Filter,Unit_RunProcess;

type
  TUpdateProgessProc = procedure(const Progress: Integer) of object;

type
  TEncoder = class(TObject)
  private
    TempFile: String;
    CurrentProgress: Integer;
  protected
    ExeFile: TLockedFile;
    SourceFile: String;
    DownMix: Boolean;
    procedure SetProgress(const NewProgress: Integer);
  public
    Meta: record
      Enabled: Boolean;
      Title: String;
      Artist: String;
      Album: String;
      Genre: String;
      Year: Integer;
      Track: Integer;
      Comment: String;
    end;
    InputFile: String;
    OutputFile: String;
    Decoder: TDecoder;
    Filters: TObjectList;
    UpdateProgessProc: TUpdateProgessProc;
    ApproxDuration: Integer;
    constructor Create(const ExeFile: TLockedFile); virtual;
    destructor Destroy; override;
    function DoEncode(const Process: TRunProcess): TProcessResult; virtual;
    function DecodeInput(const Process: TRunProcess): TProcessResult;
    function ApplyFilters(const Process: TRunProcess): TProcessResult;
    function GetExt: String; virtual;
  end;

implementation

uses
  Unit_Main, Unit_ProcessingThread;

constructor TEncoder.Create(const ExeFile: TLockedFile);
begin
  InputFile := '';
  OutputFile := '';
  Decoder := nil;
  Filters := nil;
  SourceFile := '';
  TempFile := '';
  DownMix := False;
  @UpdateProgessProc := nil;
  ApproxDuration := 0;
  CurrentProgress := -1;

  Meta.Enabled := True;
  Meta.Title := '';
  Meta.Artist := '';
  Meta.Album := '';
  Meta.Genre := '';
  Meta.Year := 0;
  Meta.Track := 0;
  Meta.Comment := '';

  self.ExeFile := ExeFile;
end;

function TEncoder.DoEncode(const Process: TRunProcess): TProcessResult;
begin
  Result := procFaild;
end;

function TEncoder.DecodeInput(const Process: TRunProcess): TProcessResult;
begin
  if Assigned(Decoder) then
  begin
    TempFile := GetTempFile(Form_Main.Path.Temp, 'LameXP_', 'wav');
    SourceFile := TempFile;
    Decoder.DownMix := self.DownMix;
    Result := Decoder.DecodeFile(InputFile, TempFile, Process);
  end else begin
    Process.AddToLog('');
    Process.AddToLog('Skipping decoder.');
    SourceFile := InputFile;
    Result := procDone;
  end;
end;

function TEncoder.ApplyFilters(const Process: TRunProcess): TProcessResult;
var
  i:Integer;
  flt: TFilter;
begin
  Result := procDone;

  if (not Assigned(Filters)) or (Filters.Count < 1) then
  begin
    Exit;
  end;

  for i := 0 to Filters.Count-1 do
  begin
    flt := Filters[i] as TFilter;
    Result := flt.ProcessFile(SourceFile, Process);
    if Result <> procDone then Break;
  end;
end;

function TEncoder.GetExt:String;
begin
  Result := '.foo';
end;

destructor TEncoder.Destroy;
begin
  if TempFile <> '' then RemoveFile(TempFile);
  inherited;
end;

procedure TEncoder.SetProgress(const NewProgress: Integer);
begin
  if (NewProgress >= 0) and (CurrentProgress <> NewProgress) and (@UpdateProgessProc <> nil) then
  begin
    CurrentProgress := Min(NewProgress, 100);
    UpdateProgessProc(CurrentProgress);
  end;
end;


end.
