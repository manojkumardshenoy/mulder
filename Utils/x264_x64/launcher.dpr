program launcher;

uses
  Forms,
  Unit_Main in 'Unit_Main.pas' {Form_Main},
  MuldeR_Toolz in '..\!_Toolz\MuldeR_Toolz.pas',
  Unit_Progress in 'Unit_Progress.pas' {Form_Progress},
  Unit_Encode in 'Unit_Encode.pas',
  Unit_RunProcess in '..\LameXP_NEW\Unit_RunProcess.pas',
  Unit_Results in 'Unit_Results.pas' {Form_Results},
  Unit_Commandline in 'Unit_Commandline.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'x264 x64';
  Application.CreateForm(TForm_Main, Form_Main);
  Application.CreateForm(TForm_Progress, Form_Progress);
  Application.CreateForm(TForm_Results, Form_Results);
  Application.Run;
end.
