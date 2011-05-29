program MakeInstantPlayer;

uses
  Forms,
  Windows,
  SysUtils,
  Main in 'Main.pas' {Form1},
  MuldeR_MD5 in '..\!_Toolz\MuldeR_MD5.pas',
  Processing in 'Processing.pas',
  Unit_RunProcess in '..\LameXP_NEW\Unit_RunProcess.pas',
  Unit_Win7Taskbar in '..\LameXP_NEW\Unit_Win7Taskbar.pas',
  MuldeR_Toolz in '..\!_Toolz\MuldeR_Toolz.pas',
  MuldeR_CheckFiles in '..\!_Toolz\MuldeR_CheckFiles.pas',
  Unit_LinkTime in '..\LameXP_NEW\Unit_LinkTime.pas',
  Unit_WideStrUtils in '..\LameXP_NEW\Unit_WideStrUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'MakeInstantPlayer';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
