unit Unit_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, MuldeR_Toolz, MuldeR_Process,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, XPMan, ExtCtrls,
  Buttons, ShellAPI, jpeg, AppEvnts, ImgList, Mask, JvComputerInfoEx, JvDialogs,
  JvComponentBase, JvBaseDlg, JvBrowseFolder, JvExStdCtrls, JvListBox,
  JvExControls, JvComponent, JvPoweredBy, Menus, Clipbrd, MMSystem,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Registry;

type
  TArchiveType = (arcUnknown,arcUHA4,arcUHA6);

type
  TUpdateThread = class(TThread)
  private
    LatestVersion:String;
    procedure UpdateFound;
  protected
    procedure Execute; override;
  end;
  
type
  TForm_Main = class(TForm)
    PageControl: TPageControl;
    Sheet_Welcome: TTabSheet;
    Image1: TImage;
    Bevel1: TBevel;
    StatusBar1: TStatusBar;
    Button_Exit1: TBitBtn;
    Label_Welcome: TLabel;
    Bevel2: TBevel;
    SpeedButton_Create: TSpeedButton;
    Label_CreateArchive: TLabel;
    SpeedButton_Extract: TSpeedButton;
    Label_CreateArchive_Info: TLabel;
    SpeedButton_Convert: TSpeedButton;
    Label_WhatToDoNow: TLabel;
    Label_ExtractArchive: TLabel;
    Label_ExtractArchive_Info: TLabel;
    Label_ConvertToSFX: TLabel;
    Label_ConvertToSFX_Info: TLabel;
    Button_About: TBitBtn;
    Button_Language: TBitBtn;
    Sheet_CreateArchive: TTabSheet;
    Bevel3: TBevel;
    Label_CreateArchive_Header: TLabel;
    List_AddFiles: TListView;
    Label_SelectFiles: TLabel;
    Bevel4: TBevel;
    Button_AddFile: TBitBtn;
    Button_AddFolder: TBitBtn;
    Button_Clear: TBitBtn;
    Dialog_AddFile: TJvOpenDialog;
    Dialog_AddFolder: TJvBrowseForFolderDialog;
    ImageList1: TImageList;
    Button_Remove: TBitBtn;
    Button_Options: TBitBtn;
    Button_Back1: TBitBtn;
    Sheet_CreateOptions: TTabSheet;
    Label_CreateOptions_Header: TLabel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Button_Files: TBitBtn;
    Button_Create2: TBitBtn;
    Dialog_CreateArchive: TJvSaveDialog;
    Sheet_Working: TTabSheet;
    Label_Working: TLabel;
    Bevel7: TBevel;
    Label_Working_Status: TLabel;
    Bevel8: TBevel;
    ProgressBar: TProgressBar;
    Button_Back3: TBitBtn;
    Button_Create1: TBitBtn;
    Button_Exit2: TBitBtn;
    Button_Back2: TBitBtn;
    Button_Abort: TBitBtn;
    Sheet_About: TTabSheet;
    Bevel9: TBevel;
    Bevel10: TBevel;
    Label_About_Header: TLabel;
    Button_Back4: TBitBtn;
    Image2: TImage;
    Label_CompressionOptions: TLabel;
    Label_DictionarySize: TLabel;
    Image3: TImage;
    ComboBox_CompressionMode: TComboBox;
    Label_CompressionMode: TLabel;
    ComboBox_MultimediaCompression: TComboBox;
    Label_MultimediaCompression: TLabel;
    List_Log: TJvListBox;
    ApplicationEvents1: TApplicationEvents;
    Label_FileOptions: TLabel;
    ComboBox_RecurseSubdirs: TComboBox;
    Label_RecurseSubdirs: TLabel;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    ComboBox_StorePaths: TComboBox;
    Label_StorePaths: TLabel;
    Image7: TImage;
    Shape1: TShape;
    ComputerInfo: TJvComputerInfoEx;
    Sheet_Language: TTabSheet;
    Label_LanguageHeader: TLabel;
    Bevel12: TBevel;
    Bevel13: TBevel;
    Label_LanguageInfo: TLabel;
    Button_Back5: TBitBtn;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Image8: TImage;
    SpeedButton6: TSpeedButton;
    Image9: TImage;
    Label_UharcAbout: TLabel;
    Label_AboutUharcGui: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label_MailMulder: TLabel;
    Label_Homepage: TLabel;
    Image10: TImage;
    Label6: TLabel;
    Label_AboutUharc: TLabel;
    Label1: TLabel;
    Label_MailUwe: TLabel;
    ComboBox_DictionarySize: TComboBox;
    ImageList2: TImageList;
    Label_Warrenty: TLabel;
    Shape2: TShape;
    JvPoweredByJVCL1: TJvPoweredByJVCL;
    Timer_TimeLeft: TTimer;
    Label_TimeLeft: TLabel;
    Popup_LogFile: TPopupMenu;
    PopupItem_CopyToClipboard: TMenuItem;
    Label_UharcLicense: TLabel;
    HttpClient: TIdHTTP;
    Label_SecurityOptions: TLabel;
    Image11: TImage;
    Edit_Password1: TEdit;
    Label_EnterPassword1: TLabel;
    Edit_Password2: TEdit;
    Label_EnterPassword2: TLabel;
    Image12: TImage;
    ComboBox_Encryption: TComboBox;
    Label_EncryptionMode: TLabel;
    Image13: TImage;
    Label4: TLabel;
    Label5: TLabel;
    Sheet_ExtractArchive: TTabSheet;
    Bevel11: TBevel;
    Button_Back6: TBitBtn;
    Label_ExtractArchiveHeader: TLabel;
    Bevel14: TBevel;
    Label_OpenArchive: TLabel;
    Button_OpenArchive: TBitBtn;
    Edit_ArchiveFile: TEdit;
    Dialog_OpenArchive: TJvOpenDialog;
    List_ExtractFiles: TListView;
    Panel_OpenArchive: TPanel;
    Image14: TImage;
    Label_ReadingArchive: TLabel;
    Popup_ExtractFiles: TPopupMenu;
    PopupItem_CopyToClipboard2: TMenuItem;
    Label_ArchiveInfo: TLabel;
    Button_Extract: TBitBtn;
    Dialog_ExtractFiles: TJvBrowseForFolderDialog;
    Button_Verify: TBitBtn;
    Label7: TLabel;
    procedure Button_Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SpeedButton_CreateClick(Sender: TObject);
    procedure Button_AddFileClick(Sender: TObject);
    procedure Button_ClearClick(Sender: TObject);
    procedure Button_AddFolderClick(Sender: TObject);
    procedure Button_RemoveClick(Sender: TObject);
    procedure Button_Back1Click(Sender: TObject);
    procedure Button_OptionsClick(Sender: TObject);
    procedure SpeedButton_ExtractClick(Sender: TObject);
    procedure SpeedButton_ConvertClick(Sender: TObject);
    procedure Button_FilesClick(Sender: TObject);
    procedure Button_Create2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button_Back3Click(Sender: TObject);
    procedure Button_Exit2Click(Sender: TObject);
    procedure Button_Back2Click(Sender: TObject);
    procedure Button_AbortClick(Sender: TObject);
    procedure Button_LanguageClick(Sender: TObject);
    procedure Button_AboutClick(Sender: TObject);
    procedure Button_Back4Click(Sender: TObject);
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure List_LogAddString(Sender: TObject; Item: String);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure List_AddFilesDblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Label_HomepageClick(Sender: TObject);
    procedure Label_MailUweClick(Sender: TObject);
    procedure Label_MailMulderClick(Sender: TObject);
    procedure Timer_TimeLeftTimer(Sender: TObject);
    procedure PopupItem_CopyToClipboardClick(Sender: TObject);
    procedure Label_MailUweMouseEnter(Sender: TObject);
    procedure Label_MailUweMouseLeave(Sender: TObject);
    procedure Label_HomepageMouseEnter(Sender: TObject);
    procedure Label_HomepageMouseLeave(Sender: TObject);
    procedure Label_MailMulderMouseEnter(Sender: TObject);
    procedure Label_MailMulderMouseLeave(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button_Back6Click(Sender: TObject);
    procedure Button_OpenArchiveClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PopupItem_CopyToClipboard2Click(Sender: TObject);
    procedure Button_ExtractClick(Sender: TObject);
    procedure Dialog_AddFolderAcceptChange(Sender: TObject;
      const NewFolder: String; var Accept: Boolean);
    procedure Dialog_ExtractFilesAcceptChange(Sender: TObject;
      const NewFolder: String; var Accept: Boolean);
    procedure Button_VerifyClick(Sender: TObject);
  private
    Path_Home:String;
    Path_Temp:String;
    Path_Out:String;
    DisableClose:Boolean;
    Process:TConsoleProcess;
    ExeFile:array [0..2] of String;
    ExeFileHandle:array [0..2] of Cardinal;
    ListFile:String;
    Time_Start:Cardinal;
    Time_Total:Cardinal;
    ListFlag:Boolean;
    PasswordReqFlag:Boolean;
    FileList:TStringList;
    ArchiveFileTemp:String;
    PasswordTemp:String;
    Password:String;
    ArchiveType:TArchiveType;
    ArchiveTypeTemp:TArchiveType;
    CompModeTemp:String;
    RatioTemp:String;
    procedure HideTabs;
    procedure SelectTab(Tab:TTabSheet);
    procedure CreateArchive(ArchiveFile:String);
    procedure ProcessRead_Create(S:String);
    procedure ProcessTerminate_Create(ExitCode:DWORD);
    procedure ProcessRead_List(S:String);
    procedure ProcessTerminate_List(ExitCode:DWORD);
    procedure ProcessRead_Extract(S:String);
    procedure ProcessTerminate_Extract(ExitCode:DWORD);
    procedure AddFolderToList(Folder: String);
    procedure AddFileToList(FileName: String);
    function GetArchiveType(FileName:String):TArchiveType;
    procedure OpenArchive(FileName:String;PW:String);
    procedure ExtractArchive(FileName:String; PW:String; OutDir:String);
  public
    VerStr:String;
    LangStr_NoFiles:String;
    LangStr_Status_Header_Create:String;
    LangStr_Status_Header_Extract:String;
    LangStr_Status_Init:String;
    LangStr_Status_Searching:String;
    LangStr_Status_Adding:String;
    LangStr_Status_Extracting:String;
    LangStr_Status_Testing:String;
    LangStr_Status_CreateSuccess:String;
    LangStr_Status_ExtractSuccess:String;
    LangStr_Status_Faild:String;
    LangStr_Status_Aborted:String;
    LangStr_ArchiveCreated:String;
    LangStr_ArchiveCreateFaild:String;
    LangStr_ArchiveExtracted:String;
    LangStr_ArchiveExtractFaild:String;
    LangStr_ProcessTerminated:String;
    LangStr_TimeLeft:String;
    LangStr_Unknown:String;
    LangStr_UpdateNotice1:String;
    LangStr_UpdateNotice2:String;
    LangStr_ReenterPassword:String;
    LangStr_UnknownArchive:String;
    LangStr_PasswordRequired:String;
    LangStr_WrongPassword:String;
    LangStr_FaildOpenArchive:String;
    LangStr_ArchiveInfo_Archive:String;
    LangStr_ArchiveInfo_Unknown:String;
    LangStr_ArchiveInfo_Files:String;
    LangStr_ArchiveInfo_Compression:String;
    LangStr_ArchiveInfo_Uncompressed:String;
    LangStr_ArchiveInfo_Ratio:String;
    LangStr_NoArchiveOpen:String;
    LangStr_None:String;
  end;

var
  Form_Main: TForm_Main;

implementation

{$R *.dfm}

uses
  Unit_Lang_EN, Unit_Data, Unit_InputPassword;

procedure TForm_Main.Button_Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm_Main.HideTabs;
var
  i:Integer;
begin
  for i := 0 to PageControl.PageCount-1 do
    PageControl.Pages[i].TabVisible := False;
end;

procedure TForm_Main.SelectTab(Tab:TTabSheet);
begin
  HideTabs;
  Tab.TabVisible := True;
  PageControl.ActivePage := Tab;
  Caption := 'UHARC/GUI - ' + Tab.Caption;

  DragAcceptFiles(Self.Handle, (Tab = Sheet_Welcome) or (Tab = Sheet_CreateArchive) or (Tab = Sheet_ExtractArchive));

  if Tab = Sheet_About then
    PlaySound('SND_SERJ',hInstance,SND_ASYNC + SND_RESOURCE)
  else
    PlaySound(nil,hInstance,SND_ASYNC)
end;

procedure TForm_Main.FormCreate(Sender: TObject);
var
  reg:TRegistry;
begin
  VerStr := GetAppVerStr('StringFileInfo\080904E4\FileVersion');

  Path_Home := GetAppDirectory;
  Path_Temp := GetTempDirectory;
  Path_Out := Path_Temp;

  Process := TConsoleProcess.Create;
  DisableClose := False;

  LangStr_NoFiles := '@';
  LangStr_Status_Header_Create := '@';
  LangStr_Status_Header_Extract := '@';
  LangStr_Status_Init := '@';
  LangStr_Status_Searching := '@';
  LangStr_Status_Adding := '@';
  LangStr_Status_Extracting := '@';
  LangStr_Status_Testing := '@';
  LangStr_Status_CreateSuccess := '@';
  LangStr_Status_ExtractSuccess := '@';
  LangStr_Status_Faild := '@';
  LangStr_Status_Aborted := '@';
  LangStr_ArchiveCreated := '@';
  LangStr_ArchiveCreateFaild := '@';
  LangStr_ArchiveExtracted := '@';
  LangStr_ArchiveExtractFaild := '@';
  LangStr_ProcessTerminated := '@';
  LangStr_TimeLeft := '@';
  LangStr_Unknown := '@';
  LangStr_UpdateNotice1 := '@';
  LangStr_UpdateNotice2 := '@';
  LangStr_ReenterPassword := '@';
  LangStr_UnknownArchive := '@';
  LangStr_PasswordRequired := '@';
  LangStr_WrongPassword := '@';
  LangStr_FaildOpenArchive := '@';
  LangStr_ArchiveInfo_Archive := '@';
  LangStr_ArchiveInfo_Unknown := '@';
  LangStr_ArchiveInfo_Files := '@';
  LangStr_ArchiveInfo_Compression := '@';
  LangStr_ArchiveInfo_Uncompressed := '@';
  LangStr_ArchiveInfo_Ratio := '@';
  LangStr_NoArchiveOpen := '@';
  LangStr_None := '@';

  StatusBar1.Panels[3].Text := 'v' + VerStr;
  Label_UharcAbout.Caption := 'UHARC/GUI v' + VerStr;

  Dialog_AddFile.InitialDir := ComputerInfo.Folders.Personal;
  Dialog_CreateArchive.InitialDir := ComputerInfo.Folders.Personal;
  Dialog_AddFolder.Directory := ComputerInfo.Folders.Personal;

  ExeFile[0] := GetTempFile(Path_Temp,'UHARC_','exe');
  with TForm_Data.Create(nil) do begin
    Data_UHARC_06.DataSaveToFile(ExeFile[0]);
    Free;
  end;
  ExeFileHandle[0] := CreateFile(PAnsiChar(ExeFile[0]),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);

  ExeFile[1] := '';
  ExeFileHandle[1] := INVALID_HANDLE_VALUE;
  ExeFile[2] := '';
  ExeFileHandle[2] := INVALID_HANDLE_VALUE;

  try
    reg := TRegistry.Create;
    reg.DeleteKey('.uha');
    reg.DeleteKey('UHARC');
    reg.RootKey := HKEY_CLASSES_ROOT;
    reg.OpenKey('uharcgui',true);
    reg.WriteString('','UHARC');
    reg.OpenKey('DefaultIcon',true);
    reg.WriteString('',Application.ExeName);
    reg.CloseKey;
    reg.OpenKey('uharcgui\shell\open\command',true);
    reg.WriteString('','"' + Application.ExeName + '" /open "%1"');
    reg.CloseKey;
    reg.OpenKey('.uha',true);
    reg.WriteString('','uharcgui');
    reg.CloseKey;
    reg.Free;
  except
  end;  
end;

procedure TForm_Main.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if DisableClose then begin
    MessageBeep(MB_ICONWARNING);
    CanClose := False;
    Exit;
  end;

  if PageControl.ActivePage <> Sheet_Welcome then begin
    CanClose := False;
    SelectTab(Sheet_Welcome);
    Exit;
  end;
end;

procedure TForm_Main.SpeedButton_CreateClick(Sender: TObject);
begin
  List_AddFiles.Items.Clear;
  SelectTab(Sheet_CreateArchive);
end;

procedure TForm_Main.Button_AddFileClick(Sender: TObject);
var
  i:Integer;
begin
  if not Dialog_AddFile.Execute then Exit;

  for i := 0 to Dialog_AddFile.Files.Count-1 do
    AddFileToList(Dialog_AddFile.Files[i]);

  Dialog_AddFolder.Directory := ExtractDirectory(Dialog_AddFile.Files[0]);  
end;

procedure TForm_Main.AddFileToList(FileName: String);
var
  j:Integer;
  b:Boolean;
begin
  b := False;

  if List_AddFiles.Items.Count > 0 then
    for j := 0 to List_AddFiles.Items.Count-1 do
      if StrEq(List_AddFiles.Items[j].Caption,FileName) then begin
        b := True;
        Break;
      end;

  if b then Exit;

  with List_AddFiles.Items.Add do begin
    ImageIndex := 0;
    Caption := FileName;
  end;
end;

procedure TForm_Main.Button_ClearClick(Sender: TObject);
begin
  List_AddFiles.Items.Clear;
end;

procedure TForm_Main.Button_AddFolderClick(Sender: TObject);
var
  Dir:String;
begin
  if not Dialog_AddFolder.Execute then Exit;

  Dir := Dialog_AddFolder.Directory;
  if Dir[Length(Dir)] <> '\' then Dir := Dir + '\';
  Dir := Dir + '*.*';

  AddFolderToList(Dir);
  Dialog_AddFile.InitialDir := Dialog_AddFolder.Directory;
end;

procedure TForm_Main.AddFolderToList(Folder: String);
var
  i:Integer;
  b:Boolean;
begin
  b := False;

  if List_AddFiles.Items.Count > 0 then
    for i := 0 to List_AddFiles.Items.Count-1 do
      if StrEq(List_AddFiles.Items[i].Caption,Folder) then begin
        b := True;
        Break;
      end;

  if b then Exit;

  with List_AddFiles.Items.Add do begin
    ImageIndex := 1;
    Caption := Folder;
  end;
end;

procedure TForm_Main.Button_RemoveClick(Sender: TObject);
var
  x:Integer;
begin
  x := List_AddFiles.ItemIndex;

  if Assigned(List_AddFiles.Selected) then
    List_AddFiles.Selected.Delete;

  if List_AddFiles.Items.Count > x then
    List_AddFiles.ItemIndex := x
  else
    List_AddFiles.ItemIndex := List_AddFiles.Items.Count-1;
end;

procedure TForm_Main.Button_Back1Click(Sender: TObject);
begin
  SelectTab(Sheet_Welcome);
end;

procedure TForm_Main.Button_OptionsClick(Sender: TObject);
begin
  SelectTab(Sheet_CreateOptions);
end;

procedure TForm_Main.SpeedButton_ExtractClick(Sender: TObject);
begin
  SetCursor(Screen.Cursors[crHourGlass]);
  Edit_ArchiveFile.Text := '';
  List_ExtractFiles.Items.Clear;
  Label_ArchiveInfo.Caption := LangStr_None;
  SelectTab(Sheet_ExtractArchive);
end;

procedure TForm_Main.SpeedButton_ConvertClick(Sender: TObject);
begin
  MsgBox('This feature is not implemented yet :-(','Still to do!',MB_OK+MB_ICONWARNING);
  //MessageBeep(MB_ICONERROR);
end;

procedure TForm_Main.Button_FilesClick(Sender: TObject);
begin
  SelectTab(Sheet_CreateArchive);
end;

procedure TForm_Main.Button_Create2Click(Sender: TObject);
begin
  if List_AddFiles.Items.Count < 1 then begin
    SelectTab(Sheet_CreateArchive);
    MsgBox(LangStr_NoFiles,Form_Main.Caption,MB_OK+MB_ICONWARNING);
    Exit;
  end;

  if Edit_Password1.Text <> Edit_Password2.Text then begin
    SelectTab(Sheet_CreateOptions);
    Edit_Password1.SetFocus;
    MsgBox(LangStr_ReenterPassword,Form_Main.Caption,MB_OK+MB_ICONWARNING);
    Exit;
  end;

  if not Dialog_CreateArchive.Execute then Exit;
  CreateArchive(Dialog_CreateArchive.FileName);
end;

procedure TForm_Main.CreateArchive(ArchiveFile:String);
var
  List:TStringList;
  i:Integer;
  CmdLine:String;
begin
  SelectTab(Sheet_Working);
  Button_Abort.Enabled := True;
  Button_Back3.Enabled := False;
  Button_Exit2.Enabled := False;
  List_Log.Items.Clear;
  ProgressBar.Position := 0;
  Label_Working.Caption := LangStr_Status_Header_Create;
  Label_Working_Status.Caption := LangStr_Status_Init;
  Label_TimeLeft.Caption := LangStr_TimeLeft + ' ' + LangStr_Unknown;
  DisableClose := True;

  List := TStringList.Create;

  for i := 0 to List_AddFiles.Items.Count-1 do
    if pos(' ',List_AddFiles.Items[i].Caption) <> 0
      then List.Add('"' + StrToOem(List_AddFiles.Items[i].Caption) + '"')
      else List.Add(StrToOem(List_AddFiles.Items[i].Caption));

  ListFile := GetTempFile(Path_Temp,'UHARC_','lst');
  List.SaveToFile(ListFile);

  CmdLine := '"' + ExeFile[0] + '" a -y+ ';
  case ComboBox_CompressionMode.ItemIndex of
    0: CmdLine := CmdLine + '-mx ';
    1: CmdLine := CmdLine + '-m3 ';
    2: CmdLine := CmdLine + '-m2 ';
    3: CmdLine := CmdLine + '-m1 ';
    4: CmdLine := CmdLine + '-mz ';
    5: CmdLine := CmdLine + '-mr ';
    6: CmdLine := CmdLine + '-mw ';
    7: CmdLine := CmdLine + '-m0 ';
  end;
  case ComboBox_DictionarySize.ItemIndex of
    0: CmdLine := CmdLine + '-md32768 ';
    1: CmdLine := CmdLine + '-md16384 ';
    2: CmdLine := CmdLine + '-md8192 ';
    3: CmdLine := CmdLine + '-md4096 ';
    4: CmdLine := CmdLine + '-md2048 ';
    5: CmdLine := CmdLine + '-md1024 ';
  end;
  case ComboBox_MultimediaCompression.ItemIndex of
    0: CmdLine := CmdLine + '-mm+ ';
    1: CmdLine := CmdLine + '-mm- ';
  end;
  case ComboBox_RecurseSubdirs.ItemIndex of
    1: CmdLine := CmdLine + '-r+ ';
    2: CmdLine := CmdLine + '-r+ -ed ';
  end;
  case ComboBox_StorePaths.ItemIndex of
    0: CmdLine := CmdLine + '-p- ';
    1: CmdLine := CmdLine + '-pe ';
    2: CmdLine := CmdLine + '-pr ';
    3: CmdLine := CmdLine + '-pf ';
  end;
  if Edit_Password1.Text <> '' then begin
    CmdLine := CmdLine + '-pw"' + StrToOem(Edit_Password1.Text) + '" ';
    case ComboBox_StorePaths.ItemIndex of
      0: CmdLine := CmdLine + '-ph- ';
      1: CmdLine := CmdLine + '-ph+ ';
    end;
  end;

  CmdLine := CmdLine + '"' + ArchiveFile + '" @"' + ListFile + '"';

  Path_Out := ExtractDirectory(ArchiveFile);

  Time_Start := GetTickCount;
  Time_Total := 0;
  Timer_TimeLeft.Enabled := True;

  Process.OnReadLine := ProcessRead_Create;
  Process.OnProcessExit := ProcessTerminate_Create;
  Process.Priority := ppBelowNormal;
  Process.Start(CmdLine);
end;

procedure TForm_Main.ProcessRead_Create(S:String);
var
  x,y:Integer;
  Str:String;
begin
  List_Log.Items.Add(S);

      x := pos('Total:',S);
      if x <> 0 then
        if S[x+9] = '%' then begin
          Str := Copy(S,x+6,3);
          while (Length(Str) > 0) and (Str[1] = ' ') do Delete(Str,1,1);
          y := StrToIntDef(Str,0);
          if ProgressBar.Position <> y then begin
            ProgressBar.Position := y;
            Time_Total := Round(((GetTickCount - Time_Start) / y) * 100);
            Form_Main.Caption := IntToStr(ProgressBar.Position) + '% � UHARC/GUI - ' + PageControl.ActivePage.Caption;
          end;
        end;
      if pos('Searching files ...',S) = 1 then
        Label_Working_Status.Caption := LangStr_Status_Searching;
      if pos('Analysing files ...',S) = 1 then
        Label_Working_Status.Caption := LangStr_Status_Searching;
      if pos('Adding',S) = 1 then
        Label_Working_Status.Caption := LangStr_Status_Adding;
      if pos('Completed successfully',S) = 1 then
        Label_Working_Status.Caption := LangStr_Status_CreateSuccess;
end;

procedure TForm_Main.ProcessTerminate_Create(ExitCode:DWORD);
var
  t:TStringList;
begin
  DeleteFile(ListFile);
  ProgressBar.Position := 100;

  Timer_TimeLeft.Enabled := False;
  Label_TimeLeft.Caption := LangStr_TimeLeft + ' 0:00';

  Form_Main.Caption := IntToStr(ProgressBar.Position) + '% � UHARC/GUI - ' + PageControl.ActivePage.Caption;
  Button_Abort.Enabled := False;
  Button_Back3.Enabled := True;
  Button_Exit2.Enabled := True;
  DisableClose := False;

  if ExitCode <> 0 then begin
    t := SearchFiles(Path_Out + '\UHA$*.$$$');
    while t.Count > 0 do begin
      DeleteFile(t[0]);
      t.Delete(0);
    end;
    FreeAndNil(t);
  end;

  case ExitCode of
    0: begin
         Label_Working_Status.Caption := LangStr_Status_CreateSuccess;
         MessageBeep(MB_ICONINFORMATION);
         List_Log.Items.Add('');
         List_Log.Items.Add('> ' + LangStr_ArchiveCreated);
       end;
    42: begin
          Label_Working_Status.Caption := LangStr_Status_Aborted;
          MessageBeep(MB_ICONWARNING);
          List_Log.Items.Add('');
          List_Log.Items.Add('> ' + LangStr_ProcessTerminated);
        end;
  else
    begin
      Label_Working_Status.Caption := LangStr_Status_Faild;
      MessageBeep(MB_ICONERROR);
      List_Log.Items.Add('');
      List_Log.Items.Add('> ' + LangStr_ArchiveCreateFaild);
    end;
  end;
end;

procedure TForm_Main.FormShow(Sender: TObject);
begin
  Application.BringToFront;
  //SetForegroundWindow(Handle);

  if ComputerInfo.Misc.Online then
    with TUpdateThread.Create(true) do begin
      Priority := tpLower;
      FreeOnTerminate := True;
      Resume;
    end;

  Unit_Lang_EN.LoadLanguage;
  SelectTab(Sheet_Welcome);
end;

procedure TForm_Main.Button_Back3Click(Sender: TObject);
begin
  SelectTab(Sheet_Welcome);
end;

procedure TForm_Main.Button_Exit2Click(Sender: TObject);
begin
  Close;
  Close;
end;

procedure TForm_Main.Button_Back2Click(Sender: TObject);
begin
  SelectTab(Sheet_Welcome);
end;

procedure TForm_Main.Button_AbortClick(Sender: TObject);
begin
  Process.KillProcess(42);
  MessageBeep(MB_ICONWARNING);
end;

procedure TForm_Main.Button_LanguageClick(Sender: TObject);
begin
  SelectTab(Sheet_Language);
end;

procedure TForm_Main.Button_AboutClick(Sender: TObject);
begin
  SelectTab(Sheet_About);
end;

procedure TForm_Main.Button_Back4Click(Sender: TObject);
begin
  SelectTab(Sheet_Welcome);
end;

procedure TForm_Main.WMDropFiles(var Msg: TMessage);
var
  aFilename: PChar;
  i, iSize, iFileCount: integer;
  Files:TStringList;
begin
  inherited;

  aFilename := '';
  Files := TStringList.Create;
  iFileCount := DragQueryFile(Msg.wParam, $FFFFFFFF, aFilename, 255);

  try
    for I := 0 to iFileCount - 1 do
      begin
        iSize := DragQueryFile(Msg.wParam, i, nil, 0) + 1;
        aFilename := StrAlloc(iSize);
        DragQueryFile(Msg.wParam, i, aFilename, iSize);
        Files.Add(aFilename);
        StrDispose(aFilename);
     end;
  finally
    DragFinish(Msg.wParam);
  end;

  if Files.Count < 1 then begin
    Files.Free;
    Exit;
  end;

  if PageControl.ActivePage = Sheet_Welcome then
    if StrEq(ExtractExtension(Files[0]),'UHA') then begin
      Edit_ArchiveFile.Text := '';
      List_ExtractFiles.Items.Clear;
      Label_ArchiveInfo.Caption := LangStr_None;
      SelectTab(Sheet_ExtractArchive);
      OpenArchive(Files[0],'');
      Files.Free;
      Exit;
    end;

  if PageControl.ActivePage = Sheet_ExtractArchive then begin
    OpenArchive(Files[0],'');
    Files.Free;
    Exit;
  end;

  if PageControl.ActivePage <> Sheet_CreateArchive then begin
    List_AddFiles.Items.Clear;
    SelectTab(Sheet_CreateArchive);
  end;

  for i := 0 to Files.Count-1 do begin
    if FileExists(Files[i]) then
      AddFileToList(Files[i]);
    if DirectoryExists(Files[i]) then
      AddFolderToList(Files[i] + '\*.*');
  end;

  Files.Free;
end;


procedure TForm_Main.List_LogAddString(Sender: TObject; Item: String);
begin
  List_Log.ItemIndex := List_Log.Items.Count - 1;
end;

procedure TForm_Main.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  FatalAppExit(0,'This application has encountered an internal error and must close!');
end;

procedure TForm_Main.List_AddFilesDblClick(Sender: TObject);
begin
  if Assigned(List_AddFiles.Selected) then
    case List_AddFiles.Selected.ImageIndex of
      0: ShellExecute(Form_Main.Handle,'open',PAnsiChar(List_AddFiles.Selected.Caption),nil,nil,SW_SHOW);
      1: ShellExecute(Form_Main.Handle,'explore',PAnsiChar(ExtractDirectory(List_AddFiles.Selected.Caption)),nil,nil,SW_SHOW);
    end;
end;

procedure TForm_Main.SpeedButton1Click(Sender: TObject);
begin
  Unit_Lang_EN.LoadLanguage;
end;

procedure TForm_Main.Label_HomepageClick(Sender: TObject);
begin
  ShellExecute(Form_Main.Handle,'open','http://mulder.at.gg/',nil,nil,SW_SHOW);
end;

procedure TForm_Main.Label_MailUweClick(Sender: TObject);
begin
  ShellExecute(Form_Main.Handle,'open','mailto:uwe.herklotz@gmx.de',nil,nil,SW_SHOW);
end;

procedure TForm_Main.Label_MailMulderClick(Sender: TObject);
begin
  ShellExecute(Form_Main.Handle,'open','mailto:mulder2@gmx.de',nil,nil,SW_SHOW);
end;

procedure TForm_Main.Timer_TimeLeftTimer(Sender: TObject);
var
  x: Cardinal;
  m,s: String;
begin
  if Time_Total < 1 then Exit;

  x := Time_Total - (GetTickCount - Time_Start);
  if x < 1 then Exit;

  m := IntToStr((x div 1000) div 60);
  s := IntToStr((x div 1000) mod 60);
  while Length(s) < 2 do s := '0' + s;

  Label_TimeLeft.Caption := LangStr_TimeLeft + ' ' + m + ':' + s;
end;

procedure TForm_Main.PopupItem_CopyToClipboardClick(Sender: TObject);
begin
  Clipboard.SetTextBuf(List_Log.Items.GetText);
end;

procedure TForm_Main.Label_MailUweMouseEnter(Sender: TObject);
begin
  Label_MailUwe.Font.Color := clRed;
end;

procedure TForm_Main.Label_MailUweMouseLeave(Sender: TObject);
begin
  Label_MailUwe.Font.Color := clBlue;
end;

procedure TForm_Main.Label_HomepageMouseEnter(Sender: TObject);
begin
  Label_Homepage.Font.Color := clRed;
end;

procedure TForm_Main.Label_HomepageMouseLeave(Sender: TObject);
begin
  Label_Homepage.Font.Color := clBlue;
end;

procedure TUpdateThread.Execute;
var
  Stream:TMemoryStream;
  Lines:TStringList;
  i:Integer;
const
  Sig:String = 'UHARC_GUI=';
begin
  LatestVersion := '';
  Stream := TMemoryStream.Create;
  Form_Main.HttpClient.Get('http://update.mulder.at.gg/',Stream);

  Stream.Seek(0,soFromBeginning);
  Lines := TStringList.Create;
  Lines.LoadFromStream(Stream);
  Stream.Free;

  if Lines.Count > 0 then
    for i := 0 to Lines.Count-1 do
      if pos(Sig,Lines[i]) <> 0 then begin
        LatestVersion := Copy(Lines[i],Length(Sig)+1,Length(Lines[i]));
        break;
      end;

  Lines.Free;

  if LatestVersion <> '' then
    if LatestVersion <> Form_Main.VerStr then
      Synchronize(UpdateFound);
end;

procedure TUpdateThread.UpdateFound;
begin
  if MsgBox(Form_Main.LangStr_UpdateNotice1 + ' v' + LatestVersion + #10 + Form_Main.LangStr_UpdateNotice2,Application.Title,MB_OKCANCEL+MB_ICONINFORMATION+MB_TASKMODAL+MB_TOPMOST) = idOK then begin
    ShellExecute(Form_Main.Handle,'open','http://mulder.at.gg/',nil,nil,SW_SHOWMAXIMIZED);
    Application.Minimize;
    Sleep(1000);
    Application.Terminate;
  end;
end;

procedure TForm_Main.Label_MailMulderMouseEnter(Sender: TObject);
begin
  Label_MailMulder.Font.Color := clRed;
end;

procedure TForm_Main.Label_MailMulderMouseLeave(Sender: TObject);
begin
  Label_MailMulder.Font.Color := clBlue;
end;

procedure TForm_Main.FormDestroy(Sender: TObject);
var
  i:Integer;
begin
  for i := 0 to 2 do begin
    if ExeFileHandle[i] <> INVALID_HANDLE_VALUE then
      CloseHandle(ExeFileHandle[i]);
    DeleteFile(ExeFile[i]);
  end;
end;

function TForm_Main.GetArchiveType(FileName:String):TArchiveType;
var
  h:DWORD;
  b:array [0..3] of byte;
  x:Cardinal;
begin
  h := CreateFile(PAnsiChar(FileName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);

  if h = INVALID_HANDLE_VALUE then begin
    Result := arcUnknown;
    Exit;
  end;

  ReadFile(h,b,4,x,nil);
  CloseHandle(h);

  if x <> 4 then begin
    Result := arcUnknown;
    Exit;
  end;

  if (b[0] <> $55) or (b[1] <> $48) or (b[2] <> $41) then begin
    Result := arcUnknown;
    Exit;
  end;

  case b[3] of
    $03: Result := arcUHA4;
    $06: Result := arcUHA6;
  else
    Result := arcUnknown;
  end;
end;

procedure TForm_Main.Button_Back6Click(Sender: TObject);
begin
  SelectTab(Sheet_Welcome);
end;

procedure TForm_Main.Button_OpenArchiveClick(Sender: TObject);
begin
  if not Dialog_OpenArchive.Execute then Exit;
  OpenArchive(Dialog_OpenArchive.FileName,'');
end;

procedure TForm_Main.OpenArchive(FileName:String;PW:String);
var
  CmdLine:String;
begin
  ArchiveTypeTemp := GetArchiveType(FileName);

  if ArchiveTypeTemp = arcUnknown then begin
    MsgBox(LangStr_UnknownArchive,Application.Title,MB_OK+MB_ICONWARNING);
    Exit;
  end;

  Button_OpenArchive.Enabled := False;
  Button_Back6.Enabled := False;
  Button_Extract.Enabled := False;
  Panel_OpenArchive.Visible := True;
  DisableClose := True;
  ArchiveFileTemp := FileName;
  ListFlag := False;
  PasswordTemp := '';
  CompModeTemp := '';
  RatioTemp := '';
  PasswordReqFlag := False;
  FileList := TStringList.Create;
  Form_Main.Update;

  Process.OnReadLine := ProcessRead_List;
  Process.OnProcessExit := ProcessTerminate_List;
  Process.Priority := ppBelowNormal;

  CmdLine := '"' + ExeFile[0] + '" l -y+ -d2 ';
  if PW <> '' then begin
    CmdLine := CmdLine + '-pw"' + StrToOem(PW) + '" ';
    PasswordTemp := PW;
  end;
  CmdLine := CmdLine + '"' + FileName + '"';

  Process.Start(CmdLine);
end;

procedure TForm_Main.ProcessRead_List(S:String);
begin
  if pos('ERROR: Archive requires a password to access',S) = 1 then
    PasswordReqFlag := True;

  if pos('-------------------------------------------------------------------------------',S) = 1 then begin
    ListFlag := not ListFlag;
    Exit;
  end;

  if not ListFlag then begin
    if pos(' (PPM-mode)',S) <> 0 then
      CompModeTemp := 'PPM';
    if pos(' (ALZ:3-mode)',S) <> 0 then
      CompModeTemp := 'ALZ:3';
    if pos(' (ALZ:2-mode)',S) <> 0 then
      CompModeTemp := 'ALZ:2';
    if pos(' (ALZ:1-mode)',S) <> 0 then
      CompModeTemp := 'ALZ:1';
    if pos(' (LZP-mode)',S) <> 0 then
      CompModeTemp := 'LZP';
    if pos(' (RLE-mode)',S) <> 0 then
      CompModeTemp := 'RLE';
    if pos(' (LZ78-mode)',S) <> 0 then
      CompModeTemp := 'LZ78';
    if pos(' ratio: ',S) <> 0 then begin
      RatioTemp := Copy(S,pos(' ratio: ',S) + 8,Length(S));
    end;
  end else begin
    if S <> '' then FileList.Add(S);
  end;
end;

procedure TForm_Main.ProcessTerminate_List(ExitCode:DWORD);
var
  i:Integer;
  s:String;
begin
  SetCursor(Screen.Cursors[crHourGlass]);
  DisableClose := False;

  if PasswordReqFlag then begin
    s := '';
    if not InputPassword(Application.Title,LangStr_PasswordRequired,s) then begin
      Button_OpenArchive.Enabled := True;
      Button_Back6.Enabled := True;
      Button_Extract.Enabled := True;
      Panel_OpenArchive.Visible := False;
      Exit;
    end;
    OpenArchive(ArchiveFileTemp,s);
    Exit;
  end;

  if ExitCode <> 0 then begin
    if PasswordTemp <> ''
      then MsgBox(LangStr_WrongPassword,Application.Title,MB_OK+MB_ICONERROR)
      else MsgBox(LangStr_FaildOpenArchive,Application.Title,MB_OK+MB_ICONERROR);
    Button_OpenArchive.Enabled := True;
    Button_Back6.Enabled := True;
    Button_Extract.Enabled := True;
    Panel_OpenArchive.Visible := False;
    Exit;
  end;

  Password := PasswordTemp;
  ArchiveType := ArchiveTypeTemp;
  Edit_ArchiveFile.Text := ArchiveFileTemp;

  //------------------------------------------------------------------

  case ArchiveType of
    arcUHA4: Label_ArchiveInfo.Caption := LangStr_ArchiveInfo_Archive + ' ' + 'UHARC 0.4';
    arcUHA6: Label_ArchiveInfo.Caption := LangStr_ArchiveInfo_Archive + ' ' + 'UHARC 0.6';
  else
    Label_ArchiveInfo.Caption := LangStr_ArchiveInfo_Archive + ' ' + LangStr_ArchiveInfo_Unknown;
  end;

  Label_ArchiveInfo.Caption := Label_ArchiveInfo.Caption + ' | ' + LangStr_ArchiveInfo_Files + ' ' + FloatToStrF(FileList.Count div 2, ffNumber, 10, 0);

  if CompModeTemp <> '' then
    Label_ArchiveInfo.Caption := Label_ArchiveInfo.Caption + ' | ' + LangStr_ArchiveInfo_Compression + ' ' + CompModeTemp
  else
    Label_ArchiveInfo.Caption := Label_ArchiveInfo.Caption + ' | ' + LangStr_ArchiveInfo_Compression + ' ' + LangStr_ArchiveInfo_Uncompressed;

  if RatioTemp <> '' then
    Label_ArchiveInfo.Caption := Label_ArchiveInfo.Caption + ' | ' + LangStr_ArchiveInfo_Ratio + ' ' + RatioTemp;

  Form_Main.Update;

  //------------------------------------------------------------------

  List_ExtractFiles.Items.Clear;
  List_ExtractFiles.SortType := stNone;
  Form_Main.Update;

  if Form_Main.FileList.Count > 1 then
    for i := 0 to ((FileList.Count-1) div 2) do begin
      with List_ExtractFiles.Items.Add do begin
        Caption := StrToAnsi(FileList[2*i]);
        s := FileList[2*i + 1];
        while pos(' ',s) = 1 do
          s := Copy(s,2,Length(s));
        if pos(' ',s) <> 0 then
          s := Copy(s,1,pos(' ',s)-1);
        SubItems.Add(FloatToStrF(StrToIntDef(s,0) div 1024, ffNumber, 10, 0));
      end;
    end;

  List_ExtractFiles.SortType := stText;
  FileList.Free;

  Button_OpenArchive.Enabled := True;
  Button_Back6.Enabled := True;
  Button_Extract.Enabled := True;
  Panel_OpenArchive.Visible := False;
end;

procedure TForm_Main.FormActivate(Sender: TObject);
var
  i:Integer;
begin
  if ParamCount > 0 then
    for i := 1 to ParamCount do
      if StrEq(ParamStr(i),'/OPEN') then begin
        SelectTab(Sheet_ExtractArchive);
        OpenArchive(ParamStr(i+1),'');
      end;
end;

procedure TForm_Main.PopupItem_CopyToClipboard2Click(Sender: TObject);
var
  i:Integer;
  t:TStringList;
begin
  if List_ExtractFiles.Items.Count < 1 then Exit;

  t := TStringList.Create;
  for i := 0 to List_ExtractFiles.Items.Count-1 do
    t.Add(List_ExtractFiles.Items[i].Caption + ' <' + List_ExtractFiles.Items[i].SubItems[0] + ' KB>');

  Clipboard.SetTextBuf(t.GetText);
  t.Free;
end;

procedure TForm_Main.Dialog_AddFolderAcceptChange(Sender: TObject;
  const NewFolder: String; var Accept: Boolean);
begin
  Accept := DirectoryExists(NewFolder);
end;

procedure TForm_Main.Dialog_ExtractFilesAcceptChange(Sender: TObject;
  const NewFolder: String; var Accept: Boolean);
var
  a:array[0..4] of Char;
  x,y:int64;
begin
  if not DirectoryExists(NewFolder) then begin
    Accept := False;
    Exit;
  end;

  a[0] := NewFolder[1];
  a[1] := ':';
  a[2] := '\';
  a[3] := #0;

  GetDiskFreeSpaceEx(a,x,y,nil);
  Accept := x > 0;
end;

procedure TForm_Main.Button_ExtractClick(Sender: TObject);
var
  s:String;
begin
  if Edit_ArchiveFile.Text = '' then begin
     MsgBox(LangStr_NoArchiveOpen,Application.Title,MB_OK+MB_ICONWARNING);
     Exit;
  end;

  if not Dialog_ExtractFiles.Execute then Exit;

  s := Dialog_ExtractFiles.Directory;
  if s[Length(s)] = '\' then
    s := Copy(s,1,Length(s)-1);
  ExtractArchive(Edit_ArchiveFile.Text, Password, s);
end;

procedure TForm_Main.ExtractArchive(FileName:String; PW:String; OutDir:String);
var
  CmdLine:String;
begin
  SelectTab(Sheet_Working);
  Button_Abort.Enabled := True;
  Button_Back3.Enabled := False;
  Button_Exit2.Enabled := False;
  List_Log.Items.Clear;
  ProgressBar.Position := 0;
  Label_Working.Caption := LangStr_Status_Header_Extract;
  Label_Working_Status.Caption := LangStr_Status_Init;
  Label_TimeLeft.Caption := LangStr_TimeLeft + ' ' + LangStr_Unknown;
  DisableClose := True;

  CmdLine := '"' + ExeFile[0] + '"';
  if OutDir <> '' then
    CmdLine := CmdLine + ' x -y+ -t"' + OutDir + '"'
   else
    CmdLine := CmdLine + ' t -y+';
  if PW <> '' then
    CmdLine := CmdLine + ' -pw"' + StrToOem(PW) + '"';
  CmdLine := CmdLine + ' "' + FileName + '"';

  Time_Start := GetTickCount;
  Time_Total := 0;
  Timer_TimeLeft.Enabled := True;

  List_Log.Items.Add(CMDLine);

  Process.OnReadLine := ProcessRead_Extract;
  Process.OnProcessExit := ProcessTerminate_Extract;
  Process.Priority := ppBelowNormal;
  Process.Start(CmdLine);
end;

procedure TForm_Main.ProcessRead_Extract(S:String);
var
  x,y:Integer;
  Str:String;
begin
  List_Log.Items.Add(S);

  x := pos('Total:',S);
  if x <> 0 then
    if S[x+9] = '%' then begin
      Str := Copy(S,x+6,3);
      while (Length(Str) > 0) and (Str[1] = ' ') do Delete(Str,1,1);
      y := StrToIntDef(Str,0);
      if ProgressBar.Position <> y then begin
        ProgressBar.Position := y;
        Time_Total := Round(((GetTickCount - Time_Start) / y) * 100);
        Form_Main.Caption := IntToStr(ProgressBar.Position) + '% � UHARC/GUI - ' + PageControl.ActivePage.Caption;
      end;
    end;

  if pos('Completed successfully',S) = 1 then
    Label_Working_Status.Caption := LangStr_Status_ExtractSuccess;
  if pos('Extracting',S) = 1 then
    Label_Working_Status.Caption := LangStr_Status_Extracting;
  if pos('Testing',S) = 1 then
    Label_Working_Status.Caption := LangStr_Status_Testing;
end;

procedure TForm_Main.ProcessTerminate_Extract(ExitCode:DWORD);
begin
  DeleteFile(ListFile);
  ProgressBar.Position := 100;

  Timer_TimeLeft.Enabled := False;
  Label_TimeLeft.Caption := LangStr_TimeLeft + ' 0:00';

  Form_Main.Caption := IntToStr(ProgressBar.Position) + '% � UHARC/GUI - ' + PageControl.ActivePage.Caption;
  Button_Abort.Enabled := False;
  Button_Back3.Enabled := True;
  Button_Exit2.Enabled := True;
  DisableClose := False;

  case ExitCode of
    0: begin
         Label_Working_Status.Caption := LangStr_Status_ExtractSuccess;
         MessageBeep(MB_ICONINFORMATION);
         List_Log.Items.Add('');
         List_Log.Items.Add('> ' + LangStr_ArchiveExtracted);
       end;
    42: begin
          Label_Working_Status.Caption := LangStr_Status_Aborted;
          MessageBeep(MB_ICONWARNING);
          List_Log.Items.Add('');
          List_Log.Items.Add('> ' + LangStr_ProcessTerminated);
        end;
  else
    begin
      Label_Working_Status.Caption := LangStr_Status_Faild;
      MessageBeep(MB_ICONERROR);
      List_Log.Items.Add('');
      List_Log.Items.Add('> ' + LangStr_ArchiveExtractFaild);
    end;
  end;
end;

procedure TForm_Main.Button_VerifyClick(Sender: TObject);
begin
  if Edit_ArchiveFile.Text = '' then begin
     MsgBox(LangStr_NoArchiveOpen,Application.Title,MB_OK+MB_ICONWARNING);
     Exit;
  end;

  ExtractArchive(Edit_ArchiveFile.Text, Password, '');
end;

end.
