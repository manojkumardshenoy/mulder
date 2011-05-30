unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolzAPI, StdCtrls, ComCtrls, ExtCtrls, Buttons,
  JvComponentBase, JvCreateProcess, Clipbrd, Menus;

type
  TForm5 = class(TForm)
    Panel1: TPanel;
    Bevel1: TBevel;
    ProgressBar: TProgressBar;
    Label_Status: TLabel;
    Bevel2: TBevel;
    BitBtn_Close: TBitBtn;
    BitBtn_ViewLog: TBitBtn;
    Timer1: TTimer;
    BitBtn_Minimize: TBitBtn;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Process1: TJvCreateProcess;
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    CopytoClipoard1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn_CloseClick(Sender: TObject);
    procedure BitBtn_MinimizeClick(Sender: TObject);
    procedure BitBtn_ViewLogClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Process1Terminate(Sender: TObject; ExitCode: Cardinal);
    procedure Process1Read(Sender: TObject; const S: String;
      const StartsOnNewLine: Boolean);
    procedure CopytoClipoard1Click(Sender: TObject);
  private
  public
  end;

var
  Form5: TForm5;

implementation

uses
  Unit4, Unit3, Unit1;

{$R *.dfm}

var
  ScriptFile:AnsiString;

procedure TForm5.FormShow(Sender: TObject);
begin
  ClientHeight := 225;
  ClientWidth := 466;

  Memo1.Hide;
  ProgressBar.Position := 0;
  Memo1.Clear;

  BitBtn_ViewLog.Enabled := True;
  Form5.BitBtn_Close.Enabled := False;
  Form5.BitBtn_Minimize.BringToFront;

  ScriptFile := GetTempFile('nsi');

  try
    Form3.Memo_Script.Lines.SaveToFile(ScriptFile);
  except
    Label_Status.Caption := 'ERROR: Faild to save script file !!!';
    MsgBox('Faild to save script file: "' + ScriptFile + '"',Form1.Caption,MB_OK+MB_ICONERROR+MB_TOPMOST);
    Exit;
  end;

  Label_Status.Caption := 'Compiler is running, this might take a few minutes...';

  Process1.CommandLine := '"' + GetBaseDir + '\Resources\makensis.exe" "' + ScriptFile + '"';

  Memo1.Lines.Add('Command-Line:');
  Memo1.Lines.Add(Process1.CommandLine);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');

  try
    Process1.Run;
  except;
    Form5.BitBtn_Close.Enabled := True;
    Application.Restore;
    Form5.BitBtn_Close.BringToFront;
    Label_Status.Caption := 'ERROR: Faild to run NSIS compiler!';
    MessageBeep(MB_ICONERROR);
  end;


  Timer1.Enabled := True;
end;

procedure TForm5.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := BitBtn_Close.Enabled;
  if not BitBtn_Close.Enabled then Application.Minimize;
end;

procedure TForm5.Timer1Timer(Sender: TObject);
begin
  if ProgressBar.Position < 100
    then ProgressBar.StepBy(10)
    else ProgressBar.Position := 0;
  Update;
end;

procedure TForm5.BitBtn_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm5.BitBtn_MinimizeClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TForm5.BitBtn_ViewLogClick(Sender: TObject);
var
  x: Integer;
begin
  Memo1.Show;

  x := ClientHeight;
  ClientHeight := ClientHeight + 200;
  Top := Top - ((ClientHeight - x) div 2);

  x := ClientWidth;
  ClientWidth := ClientWidth + 150;
  Left := Left - ((ClientWidth - x) div 2);

  BitBtn_ViewLog.Enabled := False;
end;

procedure TForm5.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
  DeleteFile(ScriptFile);
  BitBtn_ViewLog.Enabled := False;
end;

procedure TForm5.Process1Terminate(Sender: TObject; ExitCode: Cardinal);
begin
  Timer1.Enabled := False;
  ProgressBar.Position := 100;

  case ExitCode of
    0: Label_Status.Caption := 'Completed: Script has been compiled successfully !!!';
  else
    Label_Status.Caption := 'ERROR: Faild to compile script. Please see log-file for details...';
  end;

  if ExitCode <> 0
    then MessageBeep(MB_ICONERROR)
    else MessageBeep(MB_ICONINFORMATION);

  Form5.BitBtn_Close.Enabled := True;
  Application.Restore;
  Form5.BitBtn_Close.BringToFront;
end;

procedure TForm5.Process1Read(Sender: TObject; const S: String;
  const StartsOnNewLine: Boolean);
begin
  if StartsOnNewLine then
    Memo1.Lines.Add(S)
  else begin
    if Memo1.Lines.Count > 0 then
      Memo1.Lines.Delete(Memo1.Lines.Count-1);
    Memo1.Lines.Add(S)
  end;
end;

procedure TForm5.CopytoClipoard1Click(Sender: TObject);
begin
  Clipboard.AsText := Memo1.Lines.Text;
end;

end.
