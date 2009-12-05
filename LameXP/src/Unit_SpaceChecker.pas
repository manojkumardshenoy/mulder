unit Unit_SpaceChecker;

interface

uses
  Classes, Windows, SysUtils, JvListComb, Unit_Utils, Unit_Translator, MuldeR_Toolz;

type
  TSpaceChecker = class(TThread)
  public
    constructor Create(const Directory: String; const ListView: TJvImageListBox);
  private
    Directory: String;
    ListView: TJvImageListBox;
    SpaceTooLow: Boolean;
    MaxWarning: Integer;
  protected
    procedure Execute; override;
    procedure NotifyLowDiscSpace;
  end;

implementation

const
  MinSpace: Int64 = $6400000;

constructor TSpaceChecker.Create(const Directory: String; const ListView: TJvImageListBox);
begin
  inherited Create(False);

  Self.SpaceTooLow := False;
  Self.MaxWarning := 0;
  Self.Directory := Trim(Directory);
  Self.ListView := ListView;
end;

procedure TSpaceChecker.Execute;
begin
  while not Terminated do
  begin
    if GetFreeDiskspace(Directory) < MinSpace then
    begin
      if (not SpaceTooLow) and (MaxWarning < 8) then
      begin
        SpaceTooLow := True;
        MaxWarning := MaxWarning + 1;
        if Assigned(ListView) then Synchronize(NotifyLowDiscSpace);
        MyPlaySound('ERROR', True);
      end;
    end else begin
      SpaceTooLow := False;
    end;
    Sleep(1000);
  end;
end;

procedure TSpaceChecker.NotifyLowDiscSpace;
begin
  with ListView.Items.Add do
  begin
    Text := Format(LangStr('Message_LowDiskspaceWarning', 'Form_Main'), [MinSpace div (1024 * 1024)]);
    ImageIndex := 12;
  end;
end;

end.
