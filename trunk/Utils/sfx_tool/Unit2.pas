unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, ImgList, CheckLst, ToolzAPI,
  ExtDlgs, OleCtrls, SHDocVw, Menus;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    Bevel1: TBevel;
    Image1: TImage;
    TreeView_Menu: TTreeView;
    Panel_PageInstaller: TPanel;
    BitBtn1: TBitBtn;
    Bevel2: TBevel;
    ImageList1: TImageList;
    Panel_Header: TPanel;
    Panel_PageAppearance: TPanel;
    GroupBox1: TGroupBox;
    CheckBox_CreateUninstaller: TCheckBox;
    CheckBox_LinkUninstaller: TCheckBox;
    Panel_PageCredits: TPanel;
    CheckBox_RegisterUninstaller: TCheckBox;
    Image2: TImage;
    GroupBox2: TGroupBox;
    Image3: TImage;
    CheckBox_RecurseSubdirs: TCheckBox;
    CheckBox_PreserveAttributes: TCheckBox;
    GroupBox3: TGroupBox;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    RadioButton_Icon1: TRadioButton;
    RadioButton_Icon2: TRadioButton;
    RadioButton_Icon5: TRadioButton;
    RadioButton_Icon3: TRadioButton;
    RadioButton_Icon4: TRadioButton;
    RadioButton_Icon10: TRadioButton;
    RadioButton_Icon8: TRadioButton;
    RadioButton_Icon9: TRadioButton;
    RadioButton_Icon7: TRadioButton;
    RadioButton_Icon6: TRadioButton;
    Image13: TImage;
    GroupBox4: TGroupBox;
    Image14: TImage;
    RadioButton_Header1: TRadioButton;
    Image15: TImage;
    RadioButton_Header2: TRadioButton;
    GroupBox5: TGroupBox;
    RadioButton_Wizard1: TRadioButton;
    RadioButton_Wizard2: TRadioButton;
    RadioButton_Wizard3: TRadioButton;
    RadioButton_Wizard4: TRadioButton;
    RadioButton_Wizard5: TRadioButton;
    Panel_PageLocalization: TPanel;
    GroupBox6: TGroupBox;
    Image17: TImage;
    CheckListBox_Languages: TCheckListBox;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Panel_PageStartmenu: TPanel;
    GroupBox7: TGroupBox;
    ListView_Startmenu: TListView;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    GroupBox8: TGroupBox;
    Edit_DesktopTarget: TComboBox;
    Edit_DesktopName: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Panel_PageFinalization: TPanel;
    GroupBox9: TGroupBox;
    GroupBox10: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Edit_FinalExecutable: TComboBox;
    Edit_FinalParameters: TEdit;
    Label13: TLabel;
    Edit_FinalReadme: TComboBox;
    GroupBox11: TGroupBox;
    Edit_FinalLinkURL: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Panel_PageExecutables: TPanel;
    GroupBox12: TGroupBox;
    Label18: TLabel;
    Edit_ExecutableFile1: TComboBox;
    Edit_ExecutableParams1: TEdit;
    Label19: TLabel;
    CheckBox_ExecutableWait1: TCheckBox;
    GroupBox13: TGroupBox;
    Label20: TLabel;
    Label21: TLabel;
    Edit_ExecutableFile2: TComboBox;
    Edit_ExecutableParams2: TEdit;
    CheckBox_ExecutableWait2: TCheckBox;
    Panel_PageLicense: TPanel;
    GroupBox14: TGroupBox;
    Memo_License: TMemo;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    OpenDialog_License: TOpenDialog;
    Label_LicenseCounter: TLabel;
    GroupBox15: TGroupBox;
    CheckBox_BGWindow: TCheckBox;
    Image18: TImage;
    Panel_PageBackground: TPanel;
    OpenPictureDialog: TOpenPictureDialog;
    GroupBox16: TGroupBox;
    Edit_BackgroundImage: TEdit;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    Label_BackgroundImage: TLabel;
    GroupBox17: TGroupBox;
    ColorBox_Top: TColorBox;
    ColorBox_Bottom: TColorBox;
    ColorBox_Text: TColorBox;
    Label14: TLabel;
    Label23: TLabel;
    Edit_BrandingImage: TEdit;
    Label_BrandingImage: TLabel;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    Label25: TLabel;
    Label26: TLabel;
    Label22: TLabel;
    WebBrowser: TWebBrowser;
    procedure BitBtn1Click(Sender: TObject);
    procedure TreeView_MenuCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure FormShow(Sender: TObject);
    procedure TreeView_MenuChange(Sender: TObject; Node: TTreeNode);
    procedure CheckBox_CreateUninstallerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckListBox_LanguagesClickCheck(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure Edit_DesktopNameExit(Sender: TObject);
    procedure Edit_DesktopTargetExit(Sender: TObject);
    procedure Edit_FinalExecutableExit(Sender: TObject);
    procedure Edit_FinalReadmeExit(Sender: TObject);
    procedure Edit_FinalLinkURLExit(Sender: TObject);
    procedure Edit_ExecutableFile1Exit(Sender: TObject);
    procedure Edit_ExecutableFile2Exit(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure Memo_LicenseChange(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure CheckBox_BGWindowClick(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn10Click(Sender: TObject);
    procedure Panel_PageCreditsEnter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses
  Unit6, UnitX, Unit1;

var
  ImgHandle:array [0..1] of Cardinal;

procedure TForm2.FormCreate(Sender: TObject);
begin
  CheckListBox_Languages.Checked[0] := True;
  CheckListBox_Languages.Checked[1] := True;
  CheckListBox_Languages.Checked[2] := True;
  CheckListBox_Languages.Checked[3] := True;

  OpenDialog_License.InitialDir := GetShellDir(CSIDL_PERSONAL);
  OpenPictureDialog.InitialDir := GetShellDir(CSIDL_MYPICTURES);

  ImgHandle[0] := INVALID_HANDLE_VALUE;
  ImgHandle[1] := INVALID_HANDLE_VALUE;
end;

procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm2.TreeView_MenuCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  AllowCollapse := False; 
end;

procedure TForm2.FormShow(Sender: TObject);
  var i:Cardinal;
begin
  TreeView_Menu.FullExpand;
  TreeView_Menu.Selected := TreeView_Menu.Items.Item[0];

  Edit_DesktopTarget.Items.Clear;
  Edit_FinalExecutable.Items.Clear;
  Edit_FinalReadme.Items.Clear;
  Edit_ExecutableFile1.Items.Clear;
  Edit_ExecutableFile2.Items.Clear;
  Form6.Edit_TargetFile.Items.Clear;

  if Form1.ListView_SourceFiles.Items.Count > 0 then
    for i := 0 to Form1.ListView_SourceFiles.Items.Count-1 do begin
      Form6.Edit_TargetFile.Items.Add('<INSTDIR>\' + ExtractFileName(Form1.ListView_SourceFiles.Items.Item[i].Caption));
      Edit_DesktopTarget.Items.Add('<INSTDIR>\' + ExtractFileName(Form1.ListView_SourceFiles.Items.Item[i].Caption));
      Edit_FinalExecutable.Items.Add('<INSTDIR>\' + ExtractFileName(Form1.ListView_SourceFiles.Items.Item[i].Caption));
      Edit_FinalReadme.Items.Add('<INSTDIR>\' + ExtractFileName(Form1.ListView_SourceFiles.Items.Item[i].Caption));
      Edit_ExecutableFile1.Items.Add('<INSTDIR>\' + ExtractFileName(Form1.ListView_SourceFiles.Items.Item[i].Caption));
      Edit_ExecutableFile2.Items.Add('<INSTDIR>\' + ExtractFileName(Form1.ListView_SourceFiles.Items.Item[i].Caption));
    end;

  for i := 0 to Length(PathVars)-1 do begin
    Form6.Edit_TargetFile.Items.Add('<' + PathVars[i] + '>');
    Edit_DesktopTarget.Items.Add('<' + PathVars[i] + '>');
    Edit_FinalExecutable.Items.Add('<' + PathVars[i] + '>');
    Edit_FinalReadme.Items.Add('<' + PathVars[i] + '>');
    Edit_ExecutableFile1.Items.Add('<' + PathVars[i] + '>');
    Edit_ExecutableFile2.Items.Add('<' + PathVars[i] + '>');
  end;

  WebBrowser.Navigate('file://' + GetBaseDir + '\Help\Readme.html');
end;

procedure TForm2.TreeView_MenuChange(Sender: TObject; Node: TTreeNode);
  var x:Integer;
begin
  case Node.Level of
    0: x := (Node.Index + 1) * 100;
    1: x := ((Node.Parent.Index + 1) * 100) + (Node.Index + 1);
  else
    x := -1;
  end;

  Panel_PageInstaller.Hide;
  Panel_PageAppearance.Hide;
  Panel_PageCredits.Hide;
  Panel_PageLocalization.Hide;
  Panel_PageStartmenu.Hide;
  Panel_PageFinalization.Hide;
  Panel_PageExecutables.Hide;
  Panel_PageLicense.Hide;
  Panel_PageBackground.Hide;

  case x of
    100: Panel_PageInstaller.Show;
    101: Panel_PageLicense.Show;
    102: Panel_PageStartmenu.Show;
    103: Panel_PageFinalization.Show;
    104: Panel_PageExecutables.Show;
    105: Panel_PageLocalization.Show;
    106: Panel_PageAppearance.Show;
    107: Panel_PageBackground.Show;
    200: Panel_PageCredits.Show;
  end;

  Panel_Header.Caption := Node.Text;
end;

procedure TForm2.CheckBox_CreateUninstallerClick(Sender: TObject);
begin
  CheckBox_LinkUninstaller.Enabled := CheckBox_CreateUninstaller.Checked;
  CheckBox_LinkUninstaller.Checked := CheckBox_CreateUninstaller.Checked;

  CheckBox_RegisterUninstaller.Enabled := CheckBox_CreateUninstaller.Checked;
  CheckBox_RegisterUninstaller.Checked := CheckBox_CreateUninstaller.Checked;
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
  var i:Cardinal;
begin
  for i := 0 to (CheckListBox_Languages.Items.Count-1) do
    CheckListBox_Languages.Checked[i] := True;
end;

procedure TForm2.Button1Click(Sender: TObject);
  var i:Cardinal;
begin
  for i := 0 to (CheckListBox_Languages.Items.Count-1) do
    CheckListBox_Languages.Checked[i] := False;
  CheckListBox_Languages.Checked[0] := True;
end;

procedure TForm2.CheckListBox_LanguagesClickCheck(Sender: TObject);
  var b:Boolean;i:Cardinal;
begin
  b := False;
  for i := 0 to (CheckListBox_Languages.Items.Count-1) do
    if CheckListBox_Languages.Checked[i] then b := True;

  if not b then begin
    CheckListBox_Languages.Checked[0] := True;
    CheckListBox_Languages.ItemIndex := 0;
    MessageBeep(MB_ICONWARNING);
  end;
end;

procedure TForm2.BitBtn3Click(Sender: TObject);
begin
  Form6.Caption := 'New Item';
  Form6.GroupBox1.Caption := ' New Item ';
  Form6.Edit_Name.Text := '';
  Form6.Edit_TargetFile.Text := '';
  Form6.Edit_Name.ReadOnly := False;

  if Form6.ShowModal = mrOK then
    with ListView_Startmenu.Items.Add do begin
      Caption := Form6.Edit_Name.Text;
      SubItems.Add(Form6.Edit_TargetFile.Text)
    end;
end;

procedure TForm2.BitBtn4Click(Sender: TObject);
begin
  if ListView_Startmenu.Selected = nil then Exit;

  Form6.Caption := 'Edit Item';
  Form6.GroupBox1.Caption := ' Edit Item ';
  Form6.Edit_Name.Text := ListView_Startmenu.Selected.Caption;
  Form6.Edit_TargetFile.Text := ListView_Startmenu.Selected.SubItems[0];
  Form6.Edit_Name.ReadOnly := True;

  if Form6.ShowModal = mrOK then
    ListView_Startmenu.Selected.SubItems[0] := Form6.Edit_TargetFile.Text;
end;

procedure TForm2.BitBtn5Click(Sender: TObject);
  var x:Integer;
begin
  if ListView_Startmenu.Selected = nil then Exit;

  x := ListView_Startmenu.ItemIndex;
  ListView_Startmenu.Selected.Delete;
  if x > (ListView_Startmenu.Items.Count-1) then
    x := ListView_Startmenu.Items.Count-1;
  ListView_Startmenu.ItemIndex := x;
end;

procedure TForm2.Edit_DesktopNameExit(Sender: TObject);
begin
  Edit_DesktopName.Text := TestFileName(Edit_DesktopName.Text,False)
end;

procedure TForm2.Edit_DesktopTargetExit(Sender: TObject);
begin
  Edit_DesktopTarget.Text := TestFileName(Edit_DesktopTarget.Text,True)
end;

procedure TForm2.Edit_FinalExecutableExit(Sender: TObject);
begin
  Edit_FinalExecutable.Text := TestFileName(Edit_FinalExecutable.Text,True);
end;

procedure TForm2.Edit_FinalReadmeExit(Sender: TObject);
begin
  Edit_FinalReadme.Text := TestFileName(Edit_FinalReadme.Text,True);
end;

procedure TForm2.Edit_FinalLinkURLExit(Sender: TObject);
  var s:AnsiString;b:Byte;
begin
  if Edit_FinalLinkURL.Text = '' then Exit;
  s := Edit_FinalLinkURL.Text;

  b := 0;
  if AnsiUpperCase(Copy(s,1,7)) = 'HTTP://' then begin
    b := 0;
    Delete(s,1,7);
  end;
  if AnsiUpperCase(Copy(s,1,8)) = 'HTTPS://' then begin
    b := 1;
    Delete(s,1,8);
  end;
  if AnsiUpperCase(Copy(s,1,6)) = 'FTP://' then begin
    b := 2;
    Delete(s,1,6);
  end;

  case b of
    1: s := 'https://' + s;
    2: s := 'ftp://' + s;
  else
    s := 'http://' + s;
  end;

  s := ReplaceString(s,'"','');
  if s <> Edit_FinalLinkURL.Text then MessageBeep(MB_ICONWARNING);
  Edit_FinalLinkURL.Text := s;
end;

procedure TForm2.Edit_ExecutableFile1Exit(Sender: TObject);
begin
  Edit_ExecutableFile1.Text := TestFileName(Edit_ExecutableFile1.Text,True);
end;

procedure TForm2.Edit_ExecutableFile2Exit(Sender: TObject);
begin
  Edit_ExecutableFile2.Text := TestFileName(Edit_ExecutableFile2.Text,True);
end;

procedure TForm2.BitBtn7Click(Sender: TObject);
begin
  Memo_License.Lines.Clear;
  Label_LicenseCounter.Caption := '0 Lines';
end;

procedure TForm2.BitBtn6Click(Sender: TObject);
begin
  if not OpenDialog_License.Execute then Exit;

  try
    Memo_License.Lines.LoadFromFile(OpenDialog_License.FileName);
  except
    Memo_License.Lines.Clear;
  end;  
end;

procedure TForm2.Memo_LicenseChange(Sender: TObject);
begin
  Label_LicenseCounter.Caption := IntToStr(Memo_License.Lines.Count) + ' Lines';
end;

procedure TForm2.BitBtn9Click(Sender: TObject);
  var Bitmap:TBitmap;
begin
  if not OpenPictureDialog.Execute then Exit;

  Bitmap := TBitmap.Create;
  try
    Bitmap.LoadFromFile(OpenPictureDialog.FileName);
  except
    MsgBox('Faild to load bitmap:' + #10 + '"' + OpenPictureDialog.FileName + '"' + #10#10 + 'File is invalid/damaged or access has been denied!',Form1.Caption,MB_OK+MB_ICONWARNING);
    Bitmap.Free;
    Exit;
  end;

  if ImgHandle[0] <> INVALID_HANDLE_VALUE then begin
    CloseHandle(ImgHandle[0]);
    ImgHandle[0] := INVALID_HANDLE_VALUE;
  end;

  ImgHandle[0] := CreateFile(PAnsiChar(OpenPictureDialog.FileName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);

  if (Bitmap.Width < 640) or (Bitmap.Height < 480) then
    MsgBox('Warning: The background image should have a size of a least 640 x 480 pixels !!!',Form1.Caption,MB_OK+MB_ICONWARNING);

  if (Bitmap.Width / Bitmap.Height) <> (4 / 3) then
    MsgBox('Warning: The image will be stretched to fit screen aspect, which usually is 4:3 !!!',Form1.Caption,MB_OK+MB_ICONWARNING);

  CheckBox_BGWindow.Checked := True;
  Label14.Enabled := False;
  Label22.Enabled := False;
  ColorBox_Top.Enabled := False;
  ColorBox_Bottom.Enabled := False;

  Edit_BackgroundImage.Text := OpenPictureDialog.FileName;
  Label_BackgroundImage.Caption := IntToStr(Bitmap.Width) + ' x ' + IntToStr(Bitmap.Height);
  Bitmap.Free;
end;

procedure TForm2.BitBtn8Click(Sender: TObject);
begin
  if ImgHandle[0] <> INVALID_HANDLE_VALUE then begin
    CloseHandle(ImgHandle[0]);
    ImgHandle[0] := INVALID_HANDLE_VALUE;
  end;

  Edit_BackgroundImage.Text := '';
  Label_BackgroundImage.Caption := '(None)';
  ColorBox_Top.Enabled := True;
  ColorBox_Bottom.Enabled := True;
  Label14.Enabled := True;
  Label22.Enabled := True;
end;

procedure TForm2.CheckBox_BGWindowClick(Sender: TObject);
begin
  if (Edit_BackgroundImage.Text <> '') or (Edit_BrandingImage.Text <> '') then begin
    CheckBox_BGWindow.Checked := True;
    MessageBeep(MB_ICONWARNING);
  end;
end;

procedure TForm2.BitBtn11Click(Sender: TObject);
  var Bitmap:TBitmap;
begin
  if not OpenPictureDialog.Execute then Exit;

  Bitmap := TBitmap.Create;
  try
    Bitmap.LoadFromFile(OpenPictureDialog.FileName);
  except
    MsgBox('Faild to load bitmap:' + #10 + '"' + OpenPictureDialog.FileName + '"' + #10#10 + 'File is invalid/damaged or access has been denied!',Form1.Caption,MB_OK+MB_ICONWARNING);
    Bitmap.Free;
    Exit;
  end;

  if (Bitmap.Width > 320) or (Bitmap.Height > 240) then begin
    MsgBox('The branding image must not exceed a size of 320 x 240 pixels !!!',Form1.Caption,MB_OK+MB_ICONWARNING);
    Bitmap.Free;
    Exit;
  end;

  if ImgHandle[1] <> INVALID_HANDLE_VALUE then begin
    CloseHandle(ImgHandle[1]);
    ImgHandle[1] := INVALID_HANDLE_VALUE;
  end;

  ImgHandle[1] := CreateFile(PAnsiChar(OpenPictureDialog.FileName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);

  CheckBox_BGWindow.Checked := True;
  Edit_BrandingImage.Text := OpenPictureDialog.FileName;
  Edit_BrandingImage.Tag := Bitmap.Width;
  Label_BrandingImage.Caption := IntToStr(Bitmap.Width) + ' x ' + IntToStr(Bitmap.Height);
  Bitmap.Free;
end;

procedure TForm2.BitBtn10Click(Sender: TObject);
begin
  if ImgHandle[1] <> INVALID_HANDLE_VALUE then begin
    CloseHandle(ImgHandle[1]);
    ImgHandle[1] := INVALID_HANDLE_VALUE;
  end;

  Edit_BrandingImage.Text := '';
  Label_BrandingImage.Caption := '(None)';
end;

procedure TForm2.Panel_PageCreditsEnter(Sender: TObject);
begin
  Beep;
end;

end.
