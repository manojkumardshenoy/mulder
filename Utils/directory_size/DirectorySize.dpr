/////////////////////////////////////////////////////////////////////
// Directory Size Calculator                                       //                                           //
// Written by MuldeR <MuldeR2@GMX.de>                              //
// Released under the terms of the GNU GENERAL PUBLIC LICENSE      //
/////////////////////////////////////////////////////////////////////

program DirectorySize;

uses
  Forms,
  Main in 'Main.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Dir Size Calc';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
