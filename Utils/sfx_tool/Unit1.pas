unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ToolzAPI, XPMan, ComCtrls, Buttons, ImgList,
  JvComponentBase, JvDragDrop, ShellAPI;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Panel1: TPanel;
    Bevel1: TBevel;
    XPManifest1: TXPManifest;
    GroupBox1: TGroupBox;
    ListView_SourceFiles: TListView;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ImageList1: TImageList;
    OpenDialog_AddFiles: TOpenDialog;
    Image1: TImage;
    BitBtn3: TBitBtn;
    GroupBox2: TGroupBox;
    Edit_InstallerName: TEdit;
    Label1: TLabel;
    Edit_InstallDirectory: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    RadioButton_CompressionLZMA32: TRadioButton;
    RadioButton_CompressionBZip2: TRadioButton;
    RadioButton_CompressionZLib: TRadioButton;
    Bevel2: TBevel;
    BitBtn_Generate: TBitBtn;
    BitBtn_Exit: TBitBtn;
    BitBtn_Options: TBitBtn;
    SaveDialog_GenerateSFX: TSaveDialog;
    RadioButton_CompressionLZMA8: TRadioButton;
    Label4: TLabel;
    Label5: TLabel;
    JvDropTarget1: TJvDropTarget;
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn_ExitClick(Sender: TObject);
    procedure Edit_InstallDirectoryExit(Sender: TObject);
    procedure BitBtn_GenerateClick(Sender: TObject);
    procedure BitBtn_OptionsClick(Sender: TObject);
    procedure Edit_InstallDirectorySelect(Sender: TObject);
  private
    procedure AddFileToList(FileName: AnsiString);
    procedure AddDirToList(Directory: AnsiString);
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Unit2, Unit3, Unit4, Unit5, UnitX;

var
  BrowseDir:AnsiString;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TestFiles;

  Form1.Caption := Form1.Caption + ' v' + ProgVersion;
  DragAcceptFiles(Self.Handle, True);

  BrowseDir := GetShellDir(CSIDL_PERSONAL);
  OpenDialog_AddFiles.InitialDir := GetShellDir(CSIDL_PERSONAL);
  SaveDialog_GenerateSFX.InitialDir := GetShellDir(CSIDL_PERSONAL);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;

  case Edit_InstallDirectory.ItemIndex of
    0: Edit_InstallDirectory.Text :='<EXEDIR>';
    1: Edit_InstallDirectory.Text :='<PROGRAMFILES>\My Company\Foo';
    2: Edit_InstallDirectory.Text :='<COMMONFILES>\My Company\Foo';
    3: Edit_InstallDirectory.Text :='<DESKTOP>';
    4: Edit_InstallDirectory.Text :='<WINDIR>';
    5: Edit_InstallDirectory.Text :='<SYSDIR>';
    6: Edit_InstallDirectory.Text :='<TEMP>\Extracted Files';
    7: Edit_InstallDirectory.Text :='<DOCUMENTS>';
    8: Edit_InstallDirectory.Text :='<MUSIC>';
    9: Edit_InstallDirectory.Text :='<PICTURES>';
    10: Edit_InstallDirectory.Text :='<VIDEOS>';
    11: Edit_InstallDirectory.Text :='<FONTS>';
    12: Edit_InstallDirectory.Text :='<PROFILE>';
    13: Edit_InstallDirectory.Text :='<RESOURCES>';
    14: Edit_InstallDirectory.Text :='<RESOURCES_LOCALIZED>';
  end;

  Edit_InstallDirectory.SelStart := Length(Edit_InstallDirectory.Text);
  Edit_InstallDirectory.SelLength := 0;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
  var s:AnsiString;
begin
  s := BrowseFolder('Choose a folder to add to the list:',BrowseDir,Form1.WindowHandle);
  if s = '?' then Exit;

  AddDirToList(s);

  BrowseDir := s;
  OpenDialog_AddFiles.InitialDir := s;
end;

procedure TForm1.AddDirToList(Directory: AnsiString);
  var i:Cardinal;
begin
  if ListView_SourceFiles.Items.Count > 0 then
    for i := 0 to ListView_SourceFiles.Items.Count-1 do
      if AnsiUpperCase(ListView_SourceFiles.Items[i].Caption) = AnsiUpperCase(Directory) then
        Exit;

  with ListView_SourceFiles.Items.Add do begin
    Caption := Directory;
    ImageIndex := 1;
  end;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
  var i:Cardinal;
begin
  if not OpenDialog_AddFiles.Execute then Exit;

  for i := 0 to OpenDialog_AddFiles.Files.Count-1 do
    AddFileToList(OpenDialog_AddFiles.Files[i]);

  BrowseDir := ExtractDirectory(OpenDialog_AddFiles.FileName);
end;

procedure TForm1.AddFileToList(FileName: AnsiString);
var i:Cardinal;
begin
  if ListView_SourceFiles.Items.Count > 0 then
    for i := 0 to ListView_SourceFiles.Items.Count-1 do
      if AnsiUpperCase(ListView_SourceFiles.Items[i].Caption) = AnsiUpperCase(FileName) then
        Exit;

  if AnsiUpperCase(FileName) = 'UNINSTALL.EXE' then begin
    MsgBox('Warning: The file "Uninstall.exe" won''t be added to the list!',Form1.Caption,MB_OK+MB_ICONWARNING);
    Exit;
  end;


  with ListView_SourceFiles.Items.Add do begin
    Caption := FileName;
    ImageIndex := 0;
  end;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
  var x:Integer;
begin
  if ListView_SourceFiles.Selected = nil then Exit;

  x := ListView_SourceFiles.ItemIndex;
  ListView_SourceFiles.Selected.Delete;
  if x > (ListView_SourceFiles.Items.Count-1) then
    x := ListView_SourceFiles.Items.Count-1;
  ListView_SourceFiles.ItemIndex := x;
end;

procedure TForm1.BitBtn_ExitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Edit_InstallDirectoryExit(Sender: TObject);
begin
  Edit_InstallDirectory.Text := TestFileName(Edit_InstallDirectory.Text,True)
end;

procedure TForm1.BitBtn_GenerateClick(Sender: TObject);
  var SFX:TSFX; i:Cardinal;
begin
  if ListView_SourceFiles.Items.Count < 1 then begin
    MsgBox('Please add at least one item to the list !!!',Form1.Caption,MB_OK+MB_ICONWARNING);
    Exit;
  end;

  if not SaveDialog_GenerateSFX.Execute then Exit;

  ZeroMemory(@SFX,SizeOf(TSFX));
  SFX.OutputFile := SaveDialog_GenerateSFX.FileName;

  SFX.Compressor := 0;
  if RadioButton_CompressionLZMA8.Checked then SFX.Compressor := 1;
  if RadioButton_CompressionBZip2.Checked then SFX.Compressor := 2;
  if RadioButton_CompressionZLib.Checked then SFX.Compressor := 3;

  SFX.Title := PrepareString(Edit_InstallerName.Text,False);
  SFX.InstallDir := PrepareString(Edit_InstallDirectory.Text,True);

  SFX.SourceFiles := TStringList.Create;
  for i := 0 to (ListView_SourceFiles.Items.Count-1) do
    SFX.SourceFiles.Add(ListView_SourceFiles.Items.Item[i].Caption);

  SFX.CreateUninstaller := Form2.CheckBox_CreateUninstaller.Checked;
  SFX.RegisterUninstaller := Form2.CheckBox_RegisterUninstaller.Checked;
  SFX.LinkUninstaller := Form2.CheckBox_LinkUninstaller.Checked;

  SFX.FileMode := 0;
  if Form2.CheckBox_RecurseSubdirs.Checked then SFX.FileMode := SFX.FileMode + 1;
  if Form2.CheckBox_PreserveAttributes.Checked then SFX.FileMode := SFX.FileMode + 2;

  SFX.IconFile := 'Modern-Default';
  if Form2.RadioButton_Icon2.Checked then SFX.IconFile := 'Modern-Blue';
  if Form2.RadioButton_Icon3.Checked then SFX.IconFile := 'Modern-Colorful';
  if Form2.RadioButton_Icon4.Checked then SFX.IconFile := 'Llama';
  if Form2.RadioButton_Icon5.Checked then SFX.IconFile := 'Pixel';
  if Form2.RadioButton_Icon6.Checked then SFX.IconFile := 'WinXP';
  if Form2.RadioButton_Icon7.Checked then SFX.IconFile := 'Windows';
  if Form2.RadioButton_Icon8.Checked then SFX.IconFile := 'Classic';
  if Form2.RadioButton_Icon9.Checked then SFX.IconFile := 'Box';
  if Form2.RadioButton_Icon10.Checked then SFX.IconFile := 'Arrow';

  SFX.HeaderImage := 'NSIS';
  if Form2.RadioButton_Header2.Checked then SFX.HeaderImage := 'Win';

  SFX.WizardImage := 'Llama';
  if Form2.RadioButton_Wizard2.Checked then SFX.WizardImage := 'Nullsoft';
  if Form2.RadioButton_Wizard3.Checked then SFX.WizardImage := 'NSIS';
  if Form2.RadioButton_Wizard4.Checked then SFX.WizardImage := 'Arrow';
  if Form2.RadioButton_Wizard5.Checked then SFX.WizardImage := 'Win';

  SFX.Languages := TStringList.Create;
  if Form2.CheckListBox_Languages.Checked[0] then SFX.Languages.Add('English');
  if Form2.CheckListBox_Languages.Checked[1] then SFX.Languages.Add('French');
  if Form2.CheckListBox_Languages.Checked[2] then SFX.Languages.Add('German');
  if Form2.CheckListBox_Languages.Checked[3] then SFX.Languages.Add('Spanish');
  if Form2.CheckListBox_Languages.Checked[4] then SFX.Languages.Add('SimpChinese');
  if Form2.CheckListBox_Languages.Checked[5] then SFX.Languages.Add('TradChinese');
  if Form2.CheckListBox_Languages.Checked[6] then SFX.Languages.Add('Japanese');
  if Form2.CheckListBox_Languages.Checked[7] then SFX.Languages.Add('Korean');
  if Form2.CheckListBox_Languages.Checked[8] then SFX.Languages.Add('Italian');
  if Form2.CheckListBox_Languages.Checked[9] then SFX.Languages.Add('Dutch');
  if Form2.CheckListBox_Languages.Checked[10] then SFX.Languages.Add('Danish');
  if Form2.CheckListBox_Languages.Checked[11] then SFX.Languages.Add('Swedish');
  if Form2.CheckListBox_Languages.Checked[12] then SFX.Languages.Add('Norwegian');
  if Form2.CheckListBox_Languages.Checked[13] then SFX.Languages.Add('Finnish');
  if Form2.CheckListBox_Languages.Checked[14] then SFX.Languages.Add('Greek');
  if Form2.CheckListBox_Languages.Checked[15] then SFX.Languages.Add('Russian');
  if Form2.CheckListBox_Languages.Checked[16] then SFX.Languages.Add('Portuguese');
  if Form2.CheckListBox_Languages.Checked[17] then SFX.Languages.Add('PortugueseBR');
  if Form2.CheckListBox_Languages.Checked[18] then SFX.Languages.Add('Polish');
  if Form2.CheckListBox_Languages.Checked[19] then SFX.Languages.Add('Ukrainian');
  if Form2.CheckListBox_Languages.Checked[20] then SFX.Languages.Add('Czech');
  if Form2.CheckListBox_Languages.Checked[21] then SFX.Languages.Add('Slovak');
  if Form2.CheckListBox_Languages.Checked[22] then SFX.Languages.Add('Croatian');
  if Form2.CheckListBox_Languages.Checked[23] then SFX.Languages.Add('Bulgarian');
  if Form2.CheckListBox_Languages.Checked[24] then SFX.Languages.Add('Hungarian');
  if Form2.CheckListBox_Languages.Checked[25] then SFX.Languages.Add('Thai');
  if Form2.CheckListBox_Languages.Checked[26] then SFX.Languages.Add('Romanian');
  if Form2.CheckListBox_Languages.Checked[27] then SFX.Languages.Add('Latvian');
  if Form2.CheckListBox_Languages.Checked[28] then SFX.Languages.Add('Macedonian');
  if Form2.CheckListBox_Languages.Checked[29] then SFX.Languages.Add('Estonian');
  if Form2.CheckListBox_Languages.Checked[30] then SFX.Languages.Add('Turkish');
  if Form2.CheckListBox_Languages.Checked[31] then SFX.Languages.Add('Lithuanian');
  if Form2.CheckListBox_Languages.Checked[32] then SFX.Languages.Add('Catalan');
  if Form2.CheckListBox_Languages.Checked[33] then SFX.Languages.Add('Slovenian');
  if Form2.CheckListBox_Languages.Checked[34] then SFX.Languages.Add('Serbian');
  if Form2.CheckListBox_Languages.Checked[35] then SFX.Languages.Add('Arabic');
  if Form2.CheckListBox_Languages.Checked[36] then SFX.Languages.Add('Farsi');
  if Form2.CheckListBox_Languages.Checked[37] then SFX.Languages.Add('Hebrew');
  if Form2.CheckListBox_Languages.Checked[38] then SFX.Languages.Add('Indonesian');

  if Form2.Memo_License.Lines.Count > 0 then begin
    SFX.LicenseFile := GetTempFile('txt');
    Form2.Memo_License.Lines.SaveToFile(SFX.LicenseFile);
  end else
    SFX.LicenseFile := '';

  SFX.SMNames := TStringList.Create;
  SFX.SMTargets := TStringList.Create;
  if Form2.ListView_Startmenu.Items.Count > 0 then
    for i := 0 to Form2.ListView_Startmenu.Items.Count-1 do begin
      SFX.SMNames.Add(PrepareString(Form2.ListView_Startmenu.Items.Item[i].Caption,False));
      SFX.SMTargets.Add(PrepareString(Form2.ListView_Startmenu.Items.Item[i].SubItems[0],True));
    end;

  SFX.ExecutableFile1 := PrepareString(Form2.Edit_ExecutableFile1.Text,True);
  SFX.ExecutableFile2 := PrepareString(Form2.Edit_ExecutableFile2.Text,True);
  SFX.ExecutableParams1 := PrepareString(Form2.Edit_ExecutableParams1.Text,True);
  SFX.ExecutableParams2 := PrepareString(Form2.Edit_ExecutableParams2.Text,True);
  SFX.ExecutableWait1 := Form2.CheckBox_ExecutableWait1.Checked;
  SFX.ExecutableWait2 := Form2.CheckBox_ExecutableWait2.Checked;

  SFX.DesktopName := PrepareString(Form2.Edit_DesktopName.Text,False);
  SFX.DesktopTarget := PrepareString(Form2.Edit_DesktopTarget.Text,True);
  SFX.FinalExecutable := PrepareString(Form2.Edit_FinalExecutable.Text,True);
  SFX.FinalParameters := PrepareString(Form2.Edit_FinalParameters.Text,True);
  SFX.FinalReadme := PrepareString(Form2.Edit_FinalReadme.Text,True);
  SFX.FinalLinkURL := PrepareString(Form2.Edit_FinalLinkURL.Text,False);

  SFX.BGWindow := Form2.CheckBox_BGWindow.Checked;
  SFX.BGImageFile := Form2.Edit_BackgroundImage.Text;
  SFX.BGBrandingImageFile := Form2.Edit_BrandingImage.Text;
  SFX.BGBrandingImageWidth := Form2.Edit_BrandingImage.Tag;
  ConvertColor(Form2.ColorBox_Top.Selected,SFX.BGColors[0]);
  ConvertColor(Form2.ColorBox_Bottom.Selected,SFX.BGColors[1]);
  ConvertColor(Form2.ColorBox_Text.Selected,SFX.BGColors[2]);

  //---------------------------------------------------------------------------

  GenerateScript(SFX,Form3.Memo_Script.Lines);
  if Form3.ShowModal <> mrOK then Exit;

  Form1.Hide;
  Form5.ShowModal;
  Form1.Show;
  Form1.BringToFront;

  if SFX.LicenseFile <> '' then
    DeleteFile(SFX.LicenseFile);

  SFX.SourceFiles.Free;
  SFX.Languages.Free;
  SFX.SMNames.Free;
  SFX.SMTargets.Free;
end;

procedure TForm1.BitBtn_OptionsClick(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.Edit_InstallDirectorySelect(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TForm1.WMDROPFILES(var Msg: TMessage);
var
  aFilename: PChar;
  i, iSize, iFileCount: integer;
begin
  inherited;

  aFilename := '';
  iFileCount := DragQueryFile(Msg.wParam, $FFFFFFFF, aFilename, 255);

  try
    for I := 0 to iFileCount - 1 do
      begin
        iSize := DragQueryFile(Msg.wParam, i, nil, 0) + 1;
        aFilename := StrAlloc(iSize);
        DragQueryFile(Msg.wParam, i, aFilename, iSize);

        if FileExists(aFilename) then
          AddFileToList(aFileName)
        else
          if DirectoryExists(aFilename) then
            AddDirToList(aFilename);
        StrDispose(aFilename);
     end;

  finally
    DragFinish(Msg.wParam);
  end;
end;

end.
