unit Unit_Commandline;

interface

uses
  Classes, SysUtils;


type
  TCommandline = class(TObject)
  private
    Data: TStringList;
    function GetText: String;
    function GetTextAt(Index: Integer): String;
    function GetCount:Integer;
  public
    constructor Create; overload;
    constructor Create(Commandline: String); overload;
    destructor Destroy; override;
    procedure Add(Text: String); overload;
    procedure Add(Text: array of String); overload;
    procedure Add(Text: TCommandline); overload;
    procedure Clear;
    property Text: String read GetText;
    property Arguments [Index: Integer]: String read GetTextAt; default;
    property Count: Integer read GetCount;
  end;

implementation

constructor TCommandline.Create;
begin
  Data := TStringList.Create;
  Data.Delimiter := #$20;
end;

constructor TCommandline.Create(Commandline: String);
begin
  Create;
  Data.DelimitedText := Commandline;
end;

destructor TCommandline.Destroy;
begin
  Data.Free;
end;

function TCommandline.GetText: String;
begin
  Result := Data.DelimitedText;
end;

function TCommandline.GetTextAt(Index: Integer): String;
begin
  Result := '';
  if (Index >= 0) and (Index < Data.Count) then
  begin
    Result := Data[Index];
  end;
end;

function TCommandline.GetCount;
begin
  Result := Data.Count;
end;

procedure TCommandline.Clear;
begin
  Data.Clear;
end;

procedure TCommandline.Add(Text: String);
var
  Temp: String;
begin
  Temp := Trim(Text);
  if Temp <> '' then Data.Append(Temp);
end;

procedure TCommandline.Add(Text: array of String);
var
  i: Integer;
begin
  for i := 0 to High(Text) do self.Add(Text[i]);
end;

procedure TCommandline.Add(Text: TCommandline);
var
  i: Integer;
begin
  for i := 0 to Text.Count-1 do self.Add(Text[i]);
end;

end.
