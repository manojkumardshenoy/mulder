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

unit Unit_ProcessingThread;

interface

uses
  Classes, Windows, SysUtils, Forms, JvListComb, Unit_Encoder, MuldeR_Toolz,
  Unit_RunProcess, Unit_Main, Unit_Translator;

type
  TProcessingThread = class(TThread)
  private
    Encoder: TEncoder;
    EncoderSuspended: Boolean;
    ProcessSuspended: Boolean;
    ListItem: TJvImageItem;
    Success: Boolean;
    Process: TRunProcess;
    Caption: String;
    Scratchpad: String;
    ImageIndex: Integer;
    
    LangStr_Aborted: String;
    LangStr_Encoder: String;
    LangStr_Decoder: String;
    LangStr_Filtering: String;
    LangStr_Encoding: String;
    LangStr_Decoding: String;
    LangStr_Filter: String;
    LangStr_Failed: String;
    LangStr_Error: String;
    LangStr_Complete: String;
    LangStr_NotFound: String;
    LangStr_File: String;
    LangStr_Paused: String;

    procedure DoCleanUp;
    procedure UpdateCaption(const Text: String; const Index: Integer);
    procedure UpdateCaptionSync;
    procedure UpdateProgress(const Progress: Integer);
    procedure UpdateProgressSync;
  protected
    procedure Execute; override;
  public
    constructor Create(const Encoder: TEncoder; const HideConsole: Boolean; const ListItem: TJvImageItem);
    destructor Destroy; override;
    procedure SetEncoder(const Encoder: TEncoder);
    function GetResult: Boolean;
    function GetLogFile: TStringList;
    function GetListItem: TJvImageItem;
    procedure Abort;
    function PauseEncoder: Boolean;
    procedure PauseEncoderSync;
    function ResumeEncoder: Boolean;
    procedure ResumeEncoderSync;
  end;

//-----------------------------------------------------------------------------
implementation
//-----------------------------------------------------------------------------

constructor TProcessingThread.Create(const Encoder: TEncoder; const HideConsole: Boolean; const ListItem: TJvImageItem);
begin
  inherited Create(true);

  Caption := '';
  EncoderSuspended := False;
  ProcessSuspended := False;
  Success := False;

  LangStr_Aborted := LangStr('Message_Aborted', 'ProcessingThread');
  LangStr_Encoder := LangStr('Message_Encoder', 'ProcessingThread');
  LangStr_Decoder := LangStr('Message_Decoder', 'ProcessingThread');
  LangStr_Filtering := LangStr('Message_Filtering', 'ProcessingThread');
  LangStr_Encoding := LangStr('Message_Encoding', 'ProcessingThread');
  LangStr_Decoding := LangStr('Message_Decoding', 'ProcessingThread');
  LangStr_Filter := LangStr('Message_Filter', 'ProcessingThread');
  LangStr_Failed := LangStr('Message_Failed', 'ProcessingThread');
  LangStr_Error := LangStr('Message_Error', 'ProcessingThread');
  LangStr_Complete := LangStr('Message_Complete', 'ProcessingThread');
  LangStr_NotFound := LangStr('Message_NotFound', 'ProcessingThread');
  LangStr_File := LangStr('Message_File', 'ProcessingThread');
  LangStr_Paused := LangStr('Message_Paused', 'ProcessingThread');

  self.Encoder := Encoder;
  self.ListItem := ListItem;

  Process := TRunProcess.Create;
  Process.Priority := ppBelowNormal;
  Process.HideConsole := HideConsole;

  Process.AddToLog('LameXP ' + Unit_Main.VersionStr + ' - Audio Encoder Front-End');
  Process.AddToLog('Written by LoRd_MuldeR <MuldeR2@GMX.de>');
end;

destructor TProcessingThread.Destroy;
begin
  Process.Free;
  inherited;
end;

//-----------------------------------------------------------------------------

procedure TProcessingThread.SetEncoder(const Encoder: TEncoder);
begin
  self.Encoder := Encoder;
end;

function TProcessingThread.GetResult:Boolean;
begin
  Result := Success;
end;

function TProcessingThread.GetListItem: TJvImageItem;
begin
  Result := ListItem;
end;

function TProcessingThread.GetLogFile:TStringList;
var
  Log: TStringList;
begin
  Log := TStringList.Create;
  Process.GetLog(Log);
  Result := Log;
end;

//-----------------------------------------------------------------------------

procedure TProcessingThread.Execute;
var
  Name_Input: String;
  Name_Output: String;
begin
  Success := False;
  EncoderSuspended := False;
  Name_Input := ExtractFilename(Encoder.InputFile);
  Name_Output := ExtractFilename(Encoder.OutputFile);
  Encoder.UpdateProgessProc := UpdateProgress;

  if not FileExists(Encoder.InputFile) then
  begin
    UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_NotFound + ']', 2);
    DoCleanUp;
    Exit;
  end;

  if Terminated then
  begin
    UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Aborted + ']', 2);
    DoCleanUp;
    Exit;
  end;

  /////////////////////////////////////////////////////////////////////////////

  UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Decoding + ']', 0);

  case Encoder.DecodeInput(Process) of
    procAborted:
    begin
      UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Decoder + ': ' + LangStr_Aborted + ']', 2);
      DoCleanUp;
      Exit;
    end;
    procFaild:
    begin
      UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Decoder + ': ' + LangStr_Failed + ']', 2);
      DoCleanUp;
      Exit;
    end;
    procError:
    begin
      UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Decoder + ': ' + LangStr_Error + ']', 2);
      DoCleanUp;
      Exit;
    end;
  end;

  if Terminated then
  begin
    UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Aborted + ']', 2);
    DoCleanUp;
    Exit;
  end;

  /////////////////////////////////////////////////////////////////////////////

  UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Filtering + ']', 0);

  case Encoder.ApplyFilters(Process) of
    procAborted:
    begin
      UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Filter + ': ' + LangStr_Aborted + ']', 2);
      DoCleanUp;
      Exit;
    end;
    procFaild:
    begin
      UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Filter + ': ' + LangStr_Failed + ']', 2);
      DoCleanUp;
      Exit;
    end;
    //procError:
    //begin
    //  UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Filter + ': ' + LangStr_Error + ']', 2);
    //  DoCleanUp;
    //  Exit;
    //end;
  end;

  if Terminated then
  begin
    UpdateCaption(LangStr_File + ': ' + Name_Input + ' [' + LangStr_Aborted + ']', 2);
    DoCleanUp;
    Exit;
  end;

  /////////////////////////////////////////////////////////////////////////////

  UpdateCaption(LangStr_File + ': ' + Name_Output + ' [' + LangStr_Encoding + ']', 0);

  case Encoder.DoEncode(Process) of
    procAborted:
    begin
      UpdateCaption(LangStr_File + ': ' + Name_Output + ' [' + LangStr_Encoder + ': ' + LangStr_Aborted + ']', 2);
      DoCleanUp;
      Exit;
    end;
    procFaild:
    begin
      UpdateCaption(LangStr_File + ': ' + Name_Output + ' [' + LangStr_Encoder + ': ' + LangStr_Failed + ']', 2);
      DoCleanUp;
      Exit;
    end;
    procError:
    begin
      UpdateCaption(LangStr_File + ': ' + Name_Output + ' [' + LangStr_Encoder + ': ' + LangStr_Error + ']', 2);
      DoCleanUp;
      Exit;
    end;
  end;

  /////////////////////////////////////////////////////////////////////////////

  UpdateCaption(LangStr_File + ': ' + Name_Output + ' [' + LangStr_Complete + ']', 1);
  Success := True;
  DoCleanUp;
end;

//-----------------------------------------------------------------------------

procedure TProcessingThread.UpdateCaption(const Text: String; const Index: Integer);
begin
  if Index >= 0 then
  begin
    ImageIndex := Index;
  end;

  if Text <> '' then
  begin
    Caption := Text;
  end;

  Synchronize(UpdateCaptionSync);
end;

procedure TProcessingThread.UpdateCaptionSync;
begin
  ListItem.Text := Caption;
  ListItem.ImageIndex := ImageIndex;
end;

//-----------------------------------------------------------------------------

procedure TProcessingThread.UpdateProgress(const Progress: Integer);
begin
  Scratchpad := Format('%s (%d%%)', [Caption, Progress]);
  Synchronize(UpdateProgressSync);
end;

procedure TProcessingThread.UpdateProgressSync;
begin
  ListItem.Text := Scratchpad;
end;

//-----------------------------------------------------------------------------

procedure TProcessingThread.DoCleanUp;
begin
  if (not Success) then
  begin
    RemoveFile(Encoder.OutputFile);
  end;
  Encoder.Free;
end;

//-----------------------------------------------------------------------------

procedure TProcessingThread.Abort;
begin
  Terminate;
  Process.Kill(42, True);
end;

//-----------------------------------------------------------------------------

function TProcessingThread.PauseEncoder: Boolean;
begin
  Result := False;

  if not EncoderSuspended then
  begin
    Self.Suspend;
    EncoderSuspended := True;
    ProcessSuspended := Process.SuspendProcess;
    Synchronize(PauseEncoderSync);
    Result := True;
  end;
end;

procedure TProcessingThread.PauseEncoderSync;
begin
  ListItem.ImageIndex := 11;
  ListItem.Text := Format('%s (%s)', [Caption, LangStr_Paused]);
end;

//-----------------------------------------------------------------------------

function TProcessingThread.ResumeEncoder: Boolean;
begin
  Result := False;

  if EncoderSuspended then
  begin
    if ProcessSuspended then
    begin
      if not Process.ResumeProcess then
      begin
        Process.Kill(1, False);
      end;
      ProcessSuspended := False;
    end;
    Self.Resume;
    Synchronize(ResumeEncoderSync);
    EncoderSuspended := False;
    Result := True;
  end;
end;

procedure TProcessingThread.ResumeEncoderSync;
begin
  ListItem.ImageIndex := 0;
  ListItem.Text := Caption;
end;

//-----------------------------------------------------------------------------

end.
