unit Unit_InputPassword;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

function InputPassword(Title:String; Prompt:String; var Password:String):Boolean;

type
  TForm_InputPassword = class(TForm)
    Edit_Input: TEdit;
    Image11: TImage;
    Label_Prompt: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form_InputPassword: TForm_InputPassword;

implementation

{$R *.dfm}

procedure TForm_InputPassword.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TForm_InputPassword.Button1Click(Sender: TObject);
begin
  if Edit_Input.Text = '' then Exit;
  ModalResult := mrOK;
end;

function InputPassword(Title:String; Prompt:String; var Password:String):Boolean;
begin
  Password := '';

  Form_InputPassword := TForm_InputPassword.Create(Application.MainForm);
  Form_InputPassword.Caption := Title;
  Form_InputPassword.Label_Prompt.Caption := Prompt;

  if Form_InputPassword.ShowModal = idOK then begin
    Password := Form_InputPassword.Edit_Input.Text;
    Result := True;
  end else begin
    Result := False;
  end;

  Form_InputPassword.Free;
end;

end.
