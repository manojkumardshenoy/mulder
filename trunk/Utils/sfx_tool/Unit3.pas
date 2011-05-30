unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ToolzAPI;

type
  TForm3 = class(TForm)
    Memo_Script: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBox1: TCheckBox;
    Bevel1: TBevel;
    Panel1: TPanel;
    Bevel2: TBevel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure CheckBox1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm3.CheckBox1Click(Sender: TObject);
begin
  Memo_Script.ReadOnly := CheckBox1.Checked;

  if not CheckBox1.Checked then
    if MsgBox('WARNING: Edit the script at your own risk. Your modifications won''t be checked !!!',Form1.Caption,MB_OKCANCEL+MB_ICONWARNING+MB_DEFBUTTON2) = idCancel
      then CheckBox1.Checked := true
      else ShowWindow(Form3.WindowHandle,SW_MAXIMIZE);
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  ShowWindow(Self.WindowHandle,SW_RESTORE);
  Self.Width := Self.Constraints.MinWidth;
  Self.Height := Self.Constraints.MinHeight;
  CheckBox1.Checked := true;
  Memo_Script.ReadOnly := true;
end;

end.
