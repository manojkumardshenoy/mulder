unit Unit_Data;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvDataEmbedded;

type
  TForm_Data = class(TForm)
    Data_UHARC_06: TJvDataEmbedded;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form_Data: TForm_Data;

implementation

{$R *.dfm}

end.
