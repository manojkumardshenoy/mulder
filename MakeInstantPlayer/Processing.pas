///////////////////////////////////////////////////////////////////////////////
// Make Instant Player
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

unit Processing;

interface

uses
  Classes, SysUtils, StdCtrls, Unit_RunProcess;

type
  TProcessingThread = class(TThread)
  public
    constructor Create(Commandline: String; LogFile: TMemo);
    destructor Destroy; override;
    function GetExitCode: Integer;
    procedure Abort;
    function GetLog: TStringList;
  private
    Process: TRunProcess;
    Commandline: String;
    LogFile: TMemo;
    Line: String;
    function Filter(const S: String): Boolean;
    procedure WriteLine;
  protected
    procedure Execute; override;
  end;

implementation

constructor TProcessingThread.Create(Commandline: String; LogFile: TMemo);
begin
  inherited Create(True);

  self.Commandline := Commandline;
  self.LogFile := LogFile;

  Process := TRunProcess.Create;
end;

destructor TProcessingThread.Destroy;
begin
  Process.Free;
end;

procedure TProcessingThread.Execute;
begin
  Process.Priority := ppBelowNormal;

  if Assigned(LogFile) then
  begin
    Process.Filter := self.Filter;
  end;

  case Process.Execute(Commandline) of
    procDone: self.ReturnValue := Process.ExitCode;
    procFaild: self.ReturnValue := -1;
    procError: self.ReturnValue := -2;
    procAborted: self.ReturnValue := -3;
  end;
end;

function TProcessingThread.Filter(const S: String): Boolean;
begin
  Line := Trim(S);
  if Line <> '' then
  begin
    Synchronize(WriteLine);
  end;
  Result := True;
end;

procedure TProcessingThread.WriteLine;
begin
  LogFile.Lines.Add(Line);
end;

function TProcessingThread.GetExitCode:Integer;
begin
  Result := self.ReturnValue;
end;

procedure TProcessingThread.Abort;
begin
  Process.Kill(42, True);
end;

function TProcessingThread.GetLog: TStringList;
begin
  Result := TStringList.Create;
  Process.GetLog(Result);
end;

end.
