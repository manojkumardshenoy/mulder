unit Unit6;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ToolzAPI;

type
  TForm6 = class(TForm)
    GroupBox1: TGroupBox;
    Edit_Name: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit_TargetFile: TComboBox;
    Image1: TImage;
    Bevel1: TBevel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure Edit_NameExit(Sender: TObject);
    procedure Edit_TargetFileExit(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}

uses
  Unit1,Unit2,UnitX;

procedure TForm6.FormShow(Sender: TObject);
begin
  if Edit_Name.ReadOnly
    then Edit_TargetFile.SetFocus
    else Edit_Name.SetFocus;
end;

procedure TForm6.Edit_NameExit(Sender: TObject);
begin
  Edit_Name.Text := TestFileName(Edit_Name.Text,False);
end;

procedure TForm6.Edit_TargetFileExit(Sender: TObject);
begin
  Edit_TargetFile.Text := TestFileName(Edit_TargetFile.Text,True);
end;

procedure TForm6.BitBtn2Click(Sender: TObject);
  var i:Cardinal;
begin
  if Edit_Name.Text = '' then begin
    Edit_Name.SetFocus;
    Exit;
  end;

  if Edit_TargetFile.Text = '' then begin
    Edit_TargetFile.SetFocus;
    Exit;
  end;

  if (not Edit_Name.ReadOnly) and (Form2.ListView_Startmenu.Items.Count > 0) then
    for i := 0 to Form2.ListView_Startmenu.Items.Count-1 do
      if AnsiUpperCase(Edit_Name.Text) = AnsiUpperCase(Form2.ListView_Startmenu.Items.Item[i].Caption) then begin
        Edit_Name.SetFocus;
        MsgBox('An item of that name is already on the list!',Form1.Caption,MB_OK+MB_ICONWARNING);
        Exit;
      end;

  ModalResult := mrOK;
end;

end.
