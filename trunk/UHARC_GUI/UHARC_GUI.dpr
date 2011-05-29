program UHARC_GUI;

uses
  //MuldeR_Debug,
  Forms,
  Windows,
  Unit_Main in 'Unit_Main.pas' {Form_Main},
  Unit_Lang_EN in 'Unit_Lang_EN.pas',
  Unit_Data in 'Unit_Data.pas' {Form_Data},
  Unit_InputPassword in 'Unit_InputPassword.pas' {Form_InputPassword};

{$R *.res}

begin
  //if MessageBox(0,'Warning: This is a beta release that is intended for testing!','UHARC/GUI - Alpha Version',MB_OKCANCEL+MB_TOPMOST+MB_ICONWARNING+MB_DEFBUTTON2) <> idOK then Exit;

  Application.Initialize;
  Application.Title := 'UHARC/GUI';
  Application.CreateForm(TForm_Main, Form_Main);
  Application.Run;
end.
