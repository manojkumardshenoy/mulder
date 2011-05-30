/////////////////////////////////////////////////////////////////////
// Directory Size Calculator                                       //                                           //
// Written by MuldeR <MuldeR2@GMX.de>                              //
// Released under the terms of the GNU GENERAL PUBLIC LICENSE      //
/////////////////////////////////////////////////////////////////////

unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ImgList, XPMan,AppEvnts, ShellAPI,
  Menus, Buttons, ActiveX, ShlObj, Clipbrd;

//----------------------------------------------------------------------

const Version: String = '1.08';

//----------------------------------------------------------------------

type
  TFile = class(TObject)
  private
    Name: String;
    Size: Int64;
  public
    constructor Create(Name: String; Size: Int64);
    function GetSize: Int64;
    function GetName: String;
  end;

//----------------------------------------------------------------------

type
  TDirectory = class(TObject)
  private
    RootDirectory: String;
    Size: Int64;
    SubDirectories: TList;
    Files: TList;
    Symlink: Boolean;
  public
    constructor Create(RootDirectory: String; Status: TEdit; IsSymlink: Boolean);
    destructor Destory;
    function GetSize: Int64;
    function GetDirectory: String;
    function GetSubDirectoryCount: Integer;
    function GetSubDirectory(Index: Integer): TDirectory;
    function GetFileCount: Integer;
    function GetFile(Index: Integer): TFile;
    function IsSymlink: Boolean;
  end;

//----------------------------------------------------------------------

type
  TFormMain = class(TForm)
    Button_Start: TButton;
    TreeView1: TTreeView;
    ImageList1: TImageList;
    XPManifest1: TXPManifest;
    ListView1: TListView;
    Panel1: TPanel;
    Bevel1: TBevel;
    ApplicationEvents1: TApplicationEvents;
    Edit_Status: TEdit;
    Button_Exit: TButton;
    Button_About: TButton;
    PopupMenu1: TPopupMenu;
    ExploreDirectory1: TMenuItem;
    Button_Refresh: TBitBtn;
    N1: TMenuItem;
    TruncateDirectoryTree1: TMenuItem;
    CollapseDirectoryTree1: TMenuItem;
    PopupMenu2: TPopupMenu;
    OpenFile1: TMenuItem;
    N2: TMenuItem;
    DeleteFile1: TMenuItem;
    MoveFile1: TMenuItem;
    DeleteDirectory1: TMenuItem;
    N3: TMenuItem;
    MoveDirectory1: TMenuItem;
    ExploreFile1: TMenuItem;
    MoveToRecycle1: TMenuItem;
    DeletePermanently1: TMenuItem;
    MoveToRecycleBin1: TMenuItem;
    DeletePermanently2: TMenuItem;
    N4: TMenuItem;
    Properties1: TMenuItem;
    Panel2: TPanel;
    ExportasXMLDocuemnt1: TMenuItem;
    SaveDialog_XML: TSaveDialog;
    Clipbaord1: TMenuItem;
    File1: TMenuItem;
    procedure Button_StartClick(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure SelectDirectoryAcceptChange(Sender: TObject;
      const NewFolder: String; var Accept: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure ListView1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Edit_StatusEnter(Sender: TObject);
    procedure Button_ExitClick(Sender: TObject);
    procedure Button_AboutClick(Sender: TObject);
    procedure ExploreDirectory1Click(Sender: TObject);
    procedure Panel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button_RefreshClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TruncateDirectoryTree1Click(Sender: TObject);
    procedure CollapseDirectoryTree1Click(Sender: TObject);
    procedure OpenFile1Click(Sender: TObject);
    procedure MoveFile1Click(Sender: TObject);
    procedure MoveDirectory1Click(Sender: TObject);
    procedure ExploreFile1Click(Sender: TObject);
    procedure MoveToRecycle1Click(Sender: TObject);
    procedure DeletePermanently1Click(Sender: TObject);
    procedure MoveToRecycleBin1Click(Sender: TObject);
    procedure DeletePermanently2Click(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure Panel2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Clipbaord1Click(Sender: TObject);
    procedure File1Click(Sender: TObject);
  private
    CurrentDir: TDirectory;
    MouseY: Integer;
    LastBrowsedDir: String;
    LastBrowsedDir2: String;
    procedure DrawDirectory(Directory: TDirectory; Node: TTreeNode);
    procedure CreateDirectoryTree(RootDir: String);
    procedure ExportAsXML(Dir: TDirectory; OutputFile: String);
  public
    function BytesToStr(Bytes: Int64): String;
    function DirToFolder(Path: String): String;
    function ShellDelete(FileName: String; Permanently: Boolean): Boolean;
    function ShellMove(SourceFileName: String; DestFileName: String): Boolean;
    function EncodeSpecialChars(Str: String): String;
  end;

//----------------------------------------------------------------------

// TShBrowse Codes taken from:
// http://delphi.about.com/od/formsdialogs/l/aa010604a.htm

type
  TFolderCheck = function(Sender : TObject; Folder : string) : boolean of object;

  TShBrowseOption = (sboBrowseForComputer, sboBrowseForPrinter,
                     sboBrowseIncludeFiles, sboBrowseIncludeURLs,
                     sboDontGoBelowDomain, sboEditBox, sboNewDialogStyle,
                     sboNoNewFolderButton, sboReturnFSAncestors,
                     sboReturnOnlyFSDirs, sboShareable, sboStatusText,
                     sboUAHint, sboUseNewUI, sboValidate);
  TShBrowseOptions = set of TShBrowseOption;

  TShBrowse = class(TObject)
  private
    FBrowseWinHnd : THandle;
    FCaption : string;
    FFolder : string;
    FFolderCheck : TFolderCheck;
    FInitFolder : string;
    FLeft : integer;
    FOptions : TShBrowseOptions;
    FSelIconIndex : integer;
    FTop : integer;
    FUserMessage : string;
    WinFlags : DWord;
    procedure Callback(Handle : THandle; MsgId : integer; lParam : DWord);
    function GetUNCFolder : string;
    function IdFromPIdL(PtrIdL : PItemIdList; FreeMem : boolean) : string;
    procedure SetOptions(AValue : TShBrowseOptions);
  protected
    property BrowseWinHnd : THandle read FBrowseWinHnd write FBrowseWinHnd;
  public
    constructor Create;
    function Execute : boolean;
    property Caption : string write FCaption;
    property Folder : string read FFolder;
    property FolderCheck : TFolderCheck write FFolderCheck;
    property InitFolder : string write FInitFolder;
    property Left : integer write FLeft; // both Left & Top must be > 0 to position widow
    property Options : TShBrowseOptions read FOptions write SetOptions;
    property SelIconIndex : integer read FSelIconIndex;
    property Top : integer write FTop;
    property UNCFolder : string read GetUNCFolder;
    property UserMessage : string write FUserMessage;
  end;

const
  BIF_RETURNONLYFSDIRS    = $00000001;
  BIF_DONTGOBELOWDOMAIN   = $00000002;
  BIF_STATUSTEXT          = $00000004;
  BIF_RETURNFSANCESTORS   = $00000008;
  BIF_EDITBOX             = $00000010;
  BIF_VALIDATE            = $00000020;
  BIF_NEWDIALOGSTYLE      = $00000040;
  BIF_USENEWUI            = $00000040;
  BIF_BROWSEINCLUDEURLS   = $00000080;
  BIF_NONEWFOLDERBUTTON   = 0;
  BIF_UAHINT              = 0;
  BIF_BROWSEFORCOMPUTER   = $00001000;
  BIF_BROWSEFORPRINTER    = $00002000;
  BIF_BROWSEINCLUDEFILES  = $00004000;
  BIF_SHAREABLE           = $00008000;
  BFFM_VALIDATEFAILED     = 3;

  ShBrowseOptionArray : array[TShBrowseOption] of DWord =
                    (BIF_BROWSEFORCOMPUTER, BIF_BROWSEFORPRINTER,
                     BIF_BROWSEINCLUDEFILES, BIF_BROWSEINCLUDEURLS,
                     BIF_DONTGOBELOWDOMAIN, BIF_EDITBOX, BIF_NEWDIALOGSTYLE,
                     BIF_NONEWFOLDERBUTTON, BIF_RETURNFSANCESTORS,
                     BIF_RETURNONLYFSDIRS, BIF_SHAREABLE, BIF_STATUSTEXT,
                     BIF_UAHINT, BIF_USENEWUI, BIF_VALIDATE);

//----------------------------------------------------------------------

var
  FormMain: TFormMain;
  ClusterSize: Int64;

////////////////////////////////////////////////////////////////////////
implementation
////////////////////////////////////////////////////////////////////////

{$R *.dfm}

////////////////////////////////////////////////////////////////////////
// TFile                                                              //
////////////////////////////////////////////////////////////////////////

constructor TFile.Create(Name: String; Size: Int64);
begin
  self.Name := Name;
  self.Size := Size;
end;

function TFile.GetSize: Int64;
begin
  Result := Size;
end;

function TFile.GetName: String;
begin
  Result := Name;
end;

////////////////////////////////////////////////////////////////////////
// TDirectory
////////////////////////////////////////////////////////////////////////

function CompareDir(Item1, Item2: Pointer): Integer;
var
  Dir1, Dir2: TDirectory;
begin
  Dir1 := Item1;
  Dir2 := Item2;

  if Dir1.Size = Dir2.Size then
  begin
    Result := 0;
  end else begin
    if Dir1.Size < Dir2.Size then begin
      Result := 1;
    end else begin
      Result := -1;
    end;
  end;
end;

function CompareFile(Item1, Item2: Pointer): Integer;
var
  File1, File2: TFile;
begin
  File1 := Item1;
  File2 := Item2;

  if File1.Size = File2.Size then
  begin
    Result := 0;
  end else begin
    if File1.Size < File2.Size then begin
      Result := 1;
    end else begin
      Result := -1;
    end;
  end;
end;

constructor TDirectory.Create(RootDirectory: String; Status: TEdit; IsSymlink: Boolean);
var
  FindData: Win32_Find_Data;
  Handle: THandle;
  Size: Int64;
  Temp: TDirectory;
  Name: String;
const
  FILE_ATTRIBUTE_REPARSE_POINT: DWORD = $0400;
begin
  if Assigned(Status) then
  begin
    Status.Text := RootDirectory;
  end;

  Application.ProcessMessages;
  SetCursor(Screen.Cursors[crHourGlass]);

  self.RootDirectory := RootDirectory;
  self.Files := TList.Create;
  self.SubDirectories := TList.Create;
  self.Size := 0;
  self.Symlink := IsSymlink;

  Handle := INVALID_HANDLE_VALUE;

  if not IsSymlink then
  begin
    Handle := FindFirstFile(PAnsiChar(RootDirectory + '\*.*'), FindData);
  end;

  if Handle = INVALID_HANDLE_VALUE then Exit;

  repeat
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      Size := FindData.nFileSizeLow + (FindData.nFileSizeHigh * $100000000);
      Size := ((Size div ClusterSize) + 1) * ClusterSize;
      Files.Add(TFile.Create(FindData.cFileName, Size));
      self.Size := self.Size + Size;
    end
    else if (FindData.dwFileAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0 then
    begin
      Name := FindData.cFileName;
      if (Name <> '.') and (Name <> '..') then
      begin
        Temp := TDirectory.Create(RootDirectory + '\' + Name, Status, True);
        SubDirectories.Add(Temp);
      end;
    end
    else begin
      Name := FindData.cFileName;
      if (Name <> '.') and (Name <> '..') then
      begin
        Temp := TDirectory.Create(RootDirectory + '\' + Name, Status, False);
        SubDirectories.Add(Temp);
        self.Size := self.Size + Temp.GetSize;
      end;
    end;
  until
    not FindNextFile(Handle, FindData);

  Windows.FindClose(Handle);

  SubDirectories.Sort(CompareDir);
  Files.Sort(CompareDir);
end;

destructor TDirectory.Destory;
var
  i: Integer;
begin
  if Files.Count > 0 then
  begin
    for i := 0 to Files.Count-1 do
    begin
      TFile(Files[i]).Free;
    end;
  end;

  if SubDirectories.Count > 0 then
  begin
    for i := 0 to SubDirectories.Count-1 do
    begin
      TDirectory(SubDirectories[i]).Free;
    end;
  end;

  SubDirectories.Free;
  Files.Free;

  inherited;
end;

function TDirectory.GetSize: Int64;
begin
  Result := Size;
end;

function TDirectory.GetDirectory: String;
begin
  Result := RootDirectory;
end;

function TDirectory.GetSubDirectory(Index: Integer): TDirectory;
begin
  Result := SubDirectories[Index];
end;

function TDirectory.GetSubDirectoryCount: Integer;
begin
  Result := SubDirectories.Count;
end;

function TDirectory.GetFile(Index: Integer): TFile;
begin
  Result := Files[Index];
end;

function TDirectory.GetFileCount: Integer;
begin
  Result := Files.Count;
end;

function TDirectory.IsSymlink: Boolean;
begin
  Result := self.Symlink;
end;

////////////////////////////////////////////////////////////////////////
// TShBrowse
////////////////////////////////////////////////////////////////////////

// TShBrowse Codes taken from:
// http://delphi.about.com/od/formsdialogs/l/aa010604a.htm

function ShBFFCallback(hWnd : THandle; uMsg : integer;
                       lParam, lpData : DWord) : integer; stdcall;
{connects the ShBFF callback general function to the
 Delphi method which handles it}
begin
  TShBrowse(lpData).Callback(hWnd, uMsg, lParam); // calls object's method
  Result := 0;
end;

constructor TShBrowse.Create;
begin
  inherited Create;
  Caption := 'Browse for Folder';  // default
  UserMessage := 'Select folder';  // default
end;

procedure TShBrowse.Callback(Handle : THandle; MsgId : integer; lParam : DWord);
{Delphi method which handles the ShBFF callback}
var
  WorkArea, WindowSize : TRect;
  BFFWidth, BFFHeight : integer;
  SelOK : boolean;
begin
  FBrowseWinHnd := Handle;
  case MsgId of
    BFFM_INITIALIZED :
        begin
          if (FLeft = 0) or (FTop = 0) then begin
            {centre the browse window on screen}
            GetWindowRect(FBrowseWinHnd, WindowSize);  // get ShBFF window size
            with WindowSize do begin
              BFFWidth := Right - Left;
              BFFHeight := Bottom - Top;
            end;
            SystemParametersInfo(SPI_GETWORKAREA, 0, @WorkArea, 0); // get screen size
            with WorkArea do begin  // calculate ShBFF window position
              FLeft := (Right - Left - BFFWidth) div 2;
              FTop := (Bottom - Top - BFFHeight) div 2;
            end;
          end;
          {set browse window position}
          SetWindowPos(FBrowseWinHnd, HWND_TOP, FLeft, FTop, 0, 0, SWP_NOSIZE);
          if (FCaption <> '') then
            {set Caption}
            SendMessage(FBrowseWinHnd, WM_SETTEXT, 0, integer(PAnsiChar(FCaption)));
          if (FInitFolder <> '') then
            {set initial folder}
            SendMessage(FBrowseWinHnd, BFFM_SETSELECTION, integer(LongBool(true)),
                        integer(PAnsiChar(FInitFolder)));
        end;
    BFFM_SELCHANGED :
        begin
          {get folder and check for validity}
          if (lParam <> 0) then begin
            FFolder := IdFromPIdL(PItemIdList(lParam), false);
            {check folder ....}
            if Assigned(FFolderCheck) then
            begin
              SelOK := FFolderCheck(Self, FFolder);
            end else begin
              SelOK := DirectoryExists(FFolder);
            end;
            {... en/disable OK button}
            SendMessage(Handle, BFFM_ENABLEOK, 0, integer(SelOK));
          end; {if (lParam <> nil)}
          {end; if Assigned(FFolderCheck)}
        end;
  {  BFFM_IUNKNOWN :;
    BFFM_VALIDATEFAILED :;  }
  end;
end;

procedure TShBrowse.SetOptions(AValue : TShBrowseOptions);
var
  I : TShBrowseOption;
begin
  if (AValue <> FOptions) then begin
    FOptions := AValue;
    WinFlags := 0;
    for I := Low(TShBrowseOption) to High(TShBrowseOption) do
      if I in AValue then
        WinFlags := WinFlags or ShBrowseOptionArray[I];
    {end; for I := Low(TBrowseOption) to High(TBrowseOption)}
  end; {if (AValue <> FOptions)}
end;

function TShBrowse.Execute : boolean;
{called to display the ShBFF window and return the selected folder}
var
  BrowseInfo : TBrowseInfo;
  IconIndex : integer;
  PtrIDL : PItemIdList;
begin
  ZeroMemory(@BrowseInfo, SizeOf(TBrowseInfo));
  IconIndex := 0;
  with BrowseInfo do begin
    hwndOwner := FormMain.WindowHandle;
    SHGetSpecialFolderLocation(0, CSIDL_DRIVES, PIDLRoot);
    pszDisplayName := nil;
    lpszTitle := PAnsiChar(FUserMessage);
    ulFlags := WinFlags;
    lpfn := @ShBFFCallback;
    lParam := integer(Self); // this object's reference
    iImage := IconIndex;
  end;
  CoInitialize(nil);
  PtrIDL := ShBrowseForFolder(BrowseInfo);
  if PtrIDL = nil then
    Result := false
  else begin
    FSelIconIndex := BrowseInfo.iImage;
    FFolder := IdFromPIdL(PtrIDL, true);
    Result := true;
  end; {if PtrIDL = nil else}
end;

function TShBrowse.IdFromPIdL(PtrIdL : PItemIdList; FreeMem : boolean) : string;
var
  a: PAnsiChar;
begin
  a := AllocMem(MAX_PATH + 1);
  SHGetPathFromIDList(PtrIDL, a);
  Result := a;
  FreeMemory(a);
  // When a PIDL is passed via BFFM_SELCHANGED and that selection is OK'ed
  // then the PIDL memory is the same as that returned by ShBrowseForFolder.
  // This leads to the assumption that ShBFF frees the memory for the PIDL
  // passed by BFFM_SELCHANGED if that selection is NOT OK'ed. Hence one
  // should free memory ONLY when ShBFF returns, NOT for BFF_SELCHANGED
  //if FreeMem then begin
  //  {free PIDL memory ...}
  //  ShGetMalloc(AMalloc);
  //  AMalloc.Free(PtrIDL);
  //end;
end;

function TShBrowse.GetUNCFolder : string;
// sub-proc start = = = = = = = = = = = = = = = =
  function GetErrorStr(Error : integer) : string;
  begin
    Result := 'Unknown Error : ' + IntToStr(Error); // default
    case Error of
      ERROR_BAD_DEVICE :         Result := 'Invalid path';
      ERROR_CONNECTION_UNAVAIL : Result := 'No connection';
      ERROR_EXTENDED_ERROR :     Result := 'Network error';
      ERROR_MORE_DATA :          Result := 'Buffer too small';
      ERROR_NOT_SUPPORTED :      Result := 'UNC name not supported';
      ERROR_NO_NET_OR_BAD_PATH : Result := 'Unrecognised path';
      ERROR_NO_NETWORK :         Result := 'Network unavailable';
      ERROR_NOT_CONNECTED :      Result := 'Not connected';
    end;
  end;
// sub-proc end = = = = = = = = = = = = = = = = =
var
  LenResult, Error : Cardinal;
  PtrUNCInfo : PUniversalNameInfo;
begin
  {note that both the PAnsiChar _and_ the characters it
   points to are placed in UNCInfo by WNetGetUniversalName
   on return, hence the extra allocation for PtrUNCInfo}
  LenResult := 4 + MAX_PATH; // "4 +" for storage for lpUniversalName == @path
  SetLength(Result, LenResult);
  PtrUNCInfo := AllocMem(LenResult);
  Error := WNetGetUniversalName(PAnsiChar(FFolder), UNIVERSAL_NAME_INFO_LEVEL,
                                PtrUNCInfo, LenResult);
  if Error = NO_ERROR then begin
    Result := string(PtrUNCInfo^.lpUniversalName);
    SetLength(Result, Length(Result));
    end
  else
    Result := GetErrorStr(Error);
end;

////////////////////////////////////////////////////////////////////////
// TFormMain
////////////////////////////////////////////////////////////////////////

function TFormMain.BytesToStr(Bytes: Int64): String;
var
  Suffix: Integer;
  Value: Int64;
  Rest: Int64;
begin
  Result := '';

  Suffix := 0;
  Rest := 0;
  Value := Bytes;

  while Value > 1024 do
  begin
    Rest := Value mod 1024;
    Value := Value div 1024;
    Suffix := Suffix + 1;
  end;

  Result := IntToStr(Value) + '.' + IntToStr(Rest);

  case Suffix of
    0: Result := Result + ' Byte';
    1: Result := Result + ' KB';
    2: Result := Result + ' MB';
    3: Result := Result + ' GB';
    4: Result := Result + ' TB';
  else
    Result := Result + ' ?B';
  end;
end;

function TFormMain.DirToFolder(Path: String): String;
var
  x: Integer;
begin
  Result := Path;
  x := pos('\', Result);

  while x <> 0 do
  begin
    Result := Copy(Result, x+1, Length(Result));
    x := pos('\', Result);
  end;
end;

function TFormMain.ShellDelete(FileName: String; Permanently: Boolean): Boolean;
var
  FileOp: TSHFileOpStructA;
begin
  Result := False;

  ZeroMemory(@FileOp, SizeOf(TSHFileOpStructA));
  FileOp.Wnd := self.WindowHandle;
  FileOp.wFunc := FO_DELETE;
  FileOp.pFrom := PAnsiChar(FileName + #0#0);

  if not Permanently then
  begin
    FileOp.fFlags := FOF_ALLOWUNDO;
  end;
  
  if (SHFileOperationA(FileOp) = 0) and (not FileOp.fAnyOperationsAborted) then
  begin
    Result := True;
  end;
end;

function TFormMain.ShellMove(SourceFileName: String; DestFileName: String): Boolean;
var
  FileOp: TSHFileOpStructA;
begin
  Result := False;

  ZeroMemory(@FileOp, SizeOf(TSHFileOpStructA));
  FileOp.Wnd := self.WindowHandle;
  FileOp.wFunc := FO_Move;
  FileOp.pFrom := PAnsiChar(SourceFileName + #0#0);
  FileOp.pTo := PAnsiChar(DestFileName + #0#0);

  if (SHFileOperationA(FileOp) = 0) and (not FileOp.fAnyOperationsAborted) then
  begin
    Result := True;
  end;
end;

procedure TFormMain.CreateDirectoryTree(RootDir: String);
var
  NewNode: TTreeNode;
  Path: String;
  SectorPerCluster : Cardinal;
  BytesPerSector : Cardinal;
  NumberOfFreeClusters : Cardinal;
  TotalNumberOfClusters: Cardinal;
begin
  SetCursor(Screen.Cursors[crHourGlass]);
  Caption := 'Directory Size Calculator - [' + RootDir + ']';
  Button_Start.Enabled := False;
  Button_Refresh.Enabled := False;
  Button_About.Enabled := False;
  Button_Exit.Enabled := False;
  Edit_Status.Text := RootDir;
  Panel1.Show;

  TreeView1.Items.Clear;
  ListView1.Items.Clear;

  CurrentDir.Free;

  Application.ProcessMessages;
  SetCursor(Screen.Cursors[crHourGlass]);

  Path := RootDir;
  if Path[Length(Path)] = '\' then
  begin
    SetLength(Path, Length(Path)-1);
  end;

  GetDiskFreeSpace(PAnsiChar(RootDir[1] + ':\'), SectorPerCluster, BytesPerSector, NumberOfFreeClusters, TotalNumberOfClusters);
  ClusterSize := SectorPerCluster * BytesPerSector;

  CurrentDir := TDirectory.Create(Path, Edit_Status, False);

  Edit_Status.Text := 'Creating Tree Chart, plase wait...';
  Application.ProcessMessages;

  NewNode := TreeView1.Items.AddChild(TreeView1.TopItem, RootDir + ' <' + BytesToStr(CurrentDir.GetSize) + '>');
  NewNode.ImageIndex := 0;
  NewNode.SelectedIndex := 0;
  NewNode.Data := CurrentDir;

  DrawDirectory(CurrentDir, NewNode);

  if Assigned(TreeView1.Items.Item[0]) then
  begin
    TreeView1.TopItem.Expand(false);
    TreeView1.Selected := TreeView1.Items.Item[0];
    TreeView1.SetFocus;
    TreeView1.OnChange(self, TreeView1.Items.Item[0]);
  end;

  Button_Start.Enabled := True;
  Button_Refresh.Enabled := True;
  Button_About.Enabled := True;
  Button_Exit.Enabled := True;
  Panel1.Hide;
end;


procedure TFormMain.Button_StartClick(Sender: TObject);
begin
  with TShBrowse.Create do
  begin
    UserMessage := 'Choose Root Directory:';
    InitFolder := LastBrowsedDir;
    Options := Options + [sboReturnOnlyFSDirs,sboNewDialogStyle];
    if Execute then
    begin
      LastBrowsedDir := Folder;
      CreateDirectoryTree(Folder);
    end;
    Free;
  end;
end;

procedure TFormMain.DrawDirectory(Directory: TDirectory; Node: TTreeNode);
var
  NewNode: TTreeNode;
  i:Integer;
  s: String;
  Dir: TDirectory;
  Total: Int64;
  CurrentSize: Int64;
begin
  Total := Directory.GetSize;

  for i := 0 to Directory.GetSubDirectoryCount-1 do
  begin
    Dir := Directory.GetSubDirectory(i);
    CurrentSize := Dir.GetSize;
    if Dir.IsSymlink then
    begin
      s := DirToFolder(Dir.GetDirectory) + '  <Symbolic Link>';
    end else begin
      s := DirToFolder(Dir.GetDirectory) + '  <' + BytesToStr(CurrentSize) + '>';
      if Total > 0 then
      begin
        s := s + '  (' + FloatToStrF((CurrentSize/Total) * 100, ffFixed, 4, 2) + '%)';
      end;
    end;
    NewNode := TreeView1.Items.AddChild(Node, s);
    if Dir.IsSymlink then
    begin
      NewNode.ImageIndex := 7;
      NewNode.SelectedIndex := 7;
    end else begin
      NewNode.ImageIndex := 1;
      NewNode.SelectedIndex := 2;
    end;
    NewNode.Data := Dir;
    DrawDirectory(Dir, NewNode);
  end;
end;

procedure TFormMain.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  Dir: TDirectory;
  i: Integer;
  Item: TListItem;
  CurrentFile: TFile;
  CurrentSize: Int64;
  Total: Int64;
begin
  if Assigned(TreeView1.Selected) then
  begin
    TreeView1.Selected.Expand(false);
    if Assigned(TreeView1.Selected.Data) then
    begin
      ListView1.Items.Clear;
      Dir := TreeView1.Selected.Data;
      Edit_Status.Text := Dir.GetDirectory;
      if Length(Edit_Status.Text) < 3 then
      begin
        Edit_Status.Text := Edit_Status.Text + '\';
      end;
      if Dir.GetFileCount > 0 then
      begin
        Total := Dir.GetSize;
        for i := 0 to Dir.GetFileCount-1 do
        begin
          CurrentFile := Dir.GetFile(i);
          CurrentSize := CurrentFile.GetSize;
          Item := ListView1.Items.Add;
          Item.Caption := CurrentFile.Name + '  <' + BytesToStr(CurrentFile.GetSize) + '>';
          if Total > 0 then
          begin
            Item.Caption := Item.Caption + '  (' + FloatToStrF((CurrentSize/Total) * 100, ffFixed, 4, 2) + '%)';
          end;
          Item.ImageIndex := 3;
          Item.Data := CurrentFile;
        end;
      end else begin
        Item := ListView1.Items.Add;
        Item.Caption := '(empty)';
        Item.ImageIndex := 4;
      end;
      OnResize(Sender);
    end;
  end;
end;

procedure TFormMain.SelectDirectoryAcceptChange(Sender: TObject;
  const NewFolder: String; var Accept: Boolean);
begin
  Accept := DirectoryExists(NewFolder);
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := Button_Start.Enabled;
end;

procedure TFormMain.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  FatalAppExit(0, 'An unhandeled exception error has occurred, application will exit!');
  halt(1);
end;

procedure TFormMain.ListView1DblClick(Sender: TObject);
begin
  ExploreFile1Click(Sender);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Caption := 'Directory Size Calculator v' + Version;
  TreeView1.FullExpand;

  LastBrowsedDir := Application.ExeName[1] + ':\';
  LastBrowsedDir2 := Application.ExeName[1] + ':\';
end;

procedure TFormMain.FormResize(Sender: TObject);
var
  x: Integer;
begin
  ListView1.Columns[0].Width := ListView1.ClientWidth;
  Panel2.Top := TreeView1.Height + TreeView1.Top;

  if TreeView1.Height < 100 then
  begin
    x := 100 - TreeView1.Height;
    TreeView1.Height := TreeView1.Height + x;
    ListView1.Top := ListView1.Top + x;
    ListView1.Height := ListView1.Height - x;
  end;

  {
  while TreeView1.Height < 100 do
  begin
    TreeView1.Height := TreeView1.Height + 1;
    ListView1.Top := ListView1.Top + 1;
    ListView1.Height := ListView1.Height - 1;
  end;
  }

  Panel1.Left := TreeView1.Left + ((TreeView1.Width - Panel1.Width) div 2);
  Panel1.Top := TreeView1.Top + ((TreeView1.Height - Panel1.Height) div 2);

  Panel2.Left := TreeView1.Left;
  Panel2.Width := TreeView1.Width;
  Panel2.Top := TreeView1.Top + TreeView1.Height;
  Panel2.Height := ListView1.Top - (TreeView1.Top + TreeView1.Height)
end;

procedure TFormMain.Edit_StatusEnter(Sender: TObject);
begin
  Self.ActiveControl := nil;
end;

procedure TFormMain.Button_ExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.Button_AboutClick(Sender: TObject);
begin
  MessageBox(0, PAnsiChar('Directory Size Calculator v' + Version + #10#10 + 'Written by MuldeR <MuldeR2@GMX.de>' + #10 + 'Released under the terms of the GNU GENERAL PUBLIC LICENSE' + #10#10 + 'Check http://mulder.at.gg/ for updates!' + #10#10), 'About...', MB_OK + MB_ICONINFORMATION + MB_TOPMOST + MB_SETFOREGROUND + MB_TASKMODAL);
end;

procedure TFormMain.ExploreDirectory1Click(Sender: TObject);
var
  Dir: TDirectory;
begin
  if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
  begin
    Dir := TreeView1.Selected.Data;
    ShellExecute(self.WindowHandle, 'explore', PAnsiChar(Dir.GetDirectory), nil, nil, SW_SHOW);
  end;
end;

procedure TFormMain.Panel2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseY := Y;
end;

procedure TFormMain.Button_RefreshClick(Sender: TObject);
begin
  if Assigned(CurrentDir) then
  begin
    CreateDirectoryTree(CurrentDir.GetDirectory + '\');
  end else begin
    MessageBeep(MB_ICONERROR);
  end;
end;

procedure TFormMain.FormActivate(Sender: TObject);
begin
  Button_Start.SetFocus;
end;

procedure TFormMain.TruncateDirectoryTree1Click(Sender: TObject);
var
  Dir: TDirectory;
begin
  if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
  begin
    Dir := TreeView1.Selected.Data;
    CreateDirectoryTree(Dir.GetDirectory);
  end;
end;

procedure TFormMain.CollapseDirectoryTree1Click(Sender: TObject);
var
  Dir: TDirectory;
  sei: _SHELLEXECUTEINFOA;
begin
  if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
  begin
    Dir := TreeView1.Selected.Data;

    ZeroMemory(@sei, sizeof(_SHELLEXECUTEINFOA));
    sei.cbSize := sizeof(_SHELLEXECUTEINFOA);
    sei.lpFile := PAnsiChar(Dir.GetDirectory);
    sei.lpVerb := 'properties';
    sei.fMask  := SEE_MASK_INVOKEIDLIST;

    ShellExecuteEx(@sei);
  end;
end;

procedure TFormMain.OpenFile1Click(Sender: TObject);
var
  Path: String;
begin
  if Assigned(TreeView1.Selected) and Assigned(ListView1.Selected) and Assigned(ListView1.Selected.Data) then
  begin
    Path := TDirectory(TreeView1.Selected.Data).GetDirectory;
    Path := Path + '\' + TFile(ListView1.Selected.Data).GetName;
    ShellExecute(self.WindowHandle, nil, PAnsiChar(Path), nil, nil, SW_SHOW);
  end;
end;

procedure TFormMain.MoveFile1Click(Sender: TObject);
var
  Path: String;
begin
  if Assigned(TreeView1.Selected) and Assigned(ListView1.Selected) and Assigned(ListView1.Selected.Data) then
  begin
    with TShBrowse.Create do
    begin
      UserMessage := 'Choose Destination Directory:';
      InitFolder := LastBrowsedDir2;
      Options := Options + [sboReturnOnlyFSDirs,sboNewDialogStyle];
      if Execute then
      begin
        Path := TDirectory(TreeView1.Selected.Data).GetDirectory;
        Path := Path + '\' + TFile(ListView1.Selected.Data).GetName;
        if ShellMove(Path, Folder) then
        begin
          LastBrowsedDir2 := Folder;
          MessageBox(WindowHandle, 'File was moved. Directoy Tree will be updated now!', PAnsiChar(self.Caption), MB_OK or MB_ICONWARNING);
          Button_Refresh.OnClick(Sender);
        end;
      end;
      Free;
    end;
  end;
end;

procedure TFormMain.MoveDirectory1Click(Sender: TObject);
var
  Dir: TDirectory;
begin
  if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
  begin
    Dir := TreeView1.Selected.Data;
    with TShBrowse.Create do
    begin
      UserMessage := 'Choose Destination Directory:';
      InitFolder := LastBrowsedDir2;
      Options := Options + [sboReturnOnlyFSDirs,sboNewDialogStyle];
      if Execute then
      begin
        LastBrowsedDir2 := Folder;
        if ShellMove(Dir.GetDirectory, Folder) then
        begin
          MessageBox(WindowHandle, 'Directory was moved. Directoy Tree will be updated now!', PAnsiChar(self.Caption), MB_OK or MB_ICONWARNING);
          Button_Refresh.OnClick(Sender);
        end;
      end;
      Free;
    end;
  end;
end;

procedure TFormMain.ExploreFile1Click(Sender: TObject);
var
  Path: String;
begin
  if Assigned(TreeView1.Selected) and Assigned(ListView1.Selected) and Assigned(ListView1.Selected.Data) then
  begin
    Path := TDirectory(TreeView1.Selected.Data).GetDirectory;
    Path := Path + '\' + TFile(ListView1.Selected.Data).GetName;

    WinExec(PAnsiChar('explorer.exe /select,"' + Path + '"'), SW_SHOW);
  end;
end;

procedure TFormMain.MoveToRecycle1Click(Sender: TObject);
var
  Path: String;
begin
  if Assigned(TreeView1.Selected) and Assigned(ListView1.Selected) and Assigned(ListView1.Selected.Data) then
  begin
    Path := TDirectory(TreeView1.Selected.Data).GetDirectory;
    Path := Path + '\' + TFile(ListView1.Selected.Data).GetName;

    if ShellDelete(Path, False) then
    begin
      MessageBox(WindowHandle, 'File was moved to recycle bin. Directoy Tree will be updated now!', PAnsiChar(self.Caption), MB_OK or MB_ICONWARNING);
      Button_Refresh.OnClick(Sender);
    end;
  end;
end;

procedure TFormMain.DeletePermanently1Click(Sender: TObject);
var
  Path: String;
begin
  if Assigned(TreeView1.Selected) and Assigned(ListView1.Selected) and Assigned(ListView1.Selected.Data) then
  begin
    Path := TDirectory(TreeView1.Selected.Data).GetDirectory;
    Path := Path + '\' + TFile(ListView1.Selected.Data).GetName;

    if ShellDelete(Path, True) then
    begin
      MessageBox(WindowHandle, 'File was deleted. Directoy Tree will be updated now!', PAnsiChar(self.Caption), MB_OK or MB_ICONWARNING);
      Button_Refresh.OnClick(Sender);
    end;
  end;
end;

procedure TFormMain.MoveToRecycleBin1Click(Sender: TObject);
var
  Dir: TDirectory;
begin
  if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
  begin
    Dir := TreeView1.Selected.Data;
    if ShellDelete(Dir.GetDirectory, False) then
    begin
      MessageBox(WindowHandle, 'Directory was moved to recycle bin. Directoy Tree will be updated now!', PAnsiChar(Caption), MB_OK or MB_ICONWARNING);
      Button_Refresh.OnClick(Sender);
    end;
  end;
end;

procedure TFormMain.DeletePermanently2Click(Sender: TObject);
var
  Dir: TDirectory;
begin
  if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
  begin
    Dir := TreeView1.Selected.Data;
    if ShellDelete(Dir.GetDirectory, True) then
    begin
      MessageBox(WindowHandle, 'Directory was deleted. Directoy Tree will be updated now!', PAnsiChar(Caption), MB_OK or MB_ICONWARNING);
      Button_Refresh.OnClick(Sender);
    end;
  end;
end;

procedure TFormMain.Properties1Click(Sender: TObject);
var
  sei: _SHELLEXECUTEINFOA;
  Path: String;
begin
  if Assigned(TreeView1.Selected) and Assigned(ListView1.Selected) and Assigned(ListView1.Selected.Data) then
  begin
    Path := TDirectory(TreeView1.Selected.Data).GetDirectory;
    Path := Path + '\' + TFile(ListView1.Selected.Data).GetName;

    ZeroMemory(@sei, sizeof(_SHELLEXECUTEINFOA));
    sei.cbSize := sizeof(_SHELLEXECUTEINFOA);
    sei.lpFile := PAnsiChar(Path);
    sei.lpVerb := 'properties';
    sei.fMask  := SEE_MASK_INVOKEIDLIST;

    ShellExecuteEx(@sei);
  end;
end;

procedure TFormMain.Panel2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  DeltaY: Integer;
begin
  if not (ssLeft in Shift) then Exit;

  DeltaY := MouseY - Y;

  if (TreeView1.Height - DeltaY < 100) then
  begin
    DeltaY := TreeView1.Height - 100;
  end;

  if (ListView1.Height + DeltaY < 100) then
  begin
    DeltaY := 100 - ListView1.Height;
  end;

  TreeView1.Height := TreeView1.Height - DeltaY;
  ListView1.Height := ListView1.Height + DeltaY;
  ListView1.Top := ListView1.Top - DeltaY;

  OnResize(Sender);
end;

procedure TFormMain.ExportAsXML(Dir: TDirectory; OutputFile: String);
var
  XML: TStringList;
  s: String;

  procedure DoExportAsXML(ThisDir: TDirectory; Prefix: String; IsRoot:Boolean; ParentSize:Int64);
  var
    i: Integer;
    f: TFile;
    d: TDirectory;
    q: String;
  begin
    Application.ProcessMessages;
    SetCursor(Screen.Cursors[crHourglass]);

    if not IsRoot then
    begin
      q := '';
      if ParentSize > 0 then
      begin
        q := ' quota="' + FloatToStrF(100 * (ThisDir.GetSize / ParentSize), ffFixed, 4, 2) + '%"';
      end;
      XML.Add(Prefix + '<directory name="' + EncodeSpecialChars(DirToFolder(ThisDir.GetDirectory)) + '" size="' + BytesToStr(ThisDir.GetSize) + '"' + q + '>');
    end;
    if ThisDir.Files.Count > 0 then
    begin
      for i := 0 to ThisDir.Files.Count-1 do
      begin
        f := ThisDir.GetFile(i);
        q := '';
        if ParentSize > 0 then
        begin
          q := ' quota="' + FloatToStrF(100 * (f.GetSize / ParentSize), ffFixed, 4, 2) + '%"';
        end;
        XML.Add(Prefix + '  <file name="' + EncodeSpecialChars(f.GetName) + '" size="' + BytesToStr(f.GetSize) + '"' + q + '/>');
      end;
    end;
    if ThisDir.SubDirectories.Count > 0 then
    begin
      for i := 0 to ThisDir.SubDirectories.Count-1 do
      begin
        d := ThisDir.GetSubDirectory(i);
        DoExportAsXML(d, Prefix + '  ', false, ThisDir.GetSize);
      end;
    end;
    if not IsRoot then
    begin
      XML.Add(Prefix + '</directory>');
    end;
  end;

begin
  Application.ProcessMessages;
  SetCursor(Screen.Cursors[crHourglass]);

  XML := TStringList.Create;
  XML.Add('<?xml version="1.0"?>');
  XML.Add('');

  XML.Add('<!DOCTYPE directory_tree [');
	XML.Add('  <!ELEMENT directory_tree (file*,directory*)>');
	XML.Add('  <!ATTLIST directory_tree');
  XML.Add('    root CDATA #REQUIRED');
  XML.Add('    size CDATA #REQUIRED');
  XML.Add('  >');
	XML.Add('  <!ELEMENT file EMPTY>');
	XML.Add('  <!ATTLIST file');
  XML.Add('    name CDATA #REQUIRED');
  XML.Add('    size CDATA #REQUIRED');
  XML.Add('    quota CDATA #REQUIRED');
	XML.Add('  >');
	XML.Add('  <!ELEMENT directory (file*,directory*)>');
	XML.Add('  <!ATTLIST directory');
  XML.Add('    name CDATA #REQUIRED');
  XML.Add('    size CDATA #REQUIRED');
  XML.Add('    quota CDATA #REQUIRED');
	XML.Add('  >');
	XML.Add(']>');
  XML.Add('');

  s := Dir.GetDirectory;
  if Length(s) = 2 then
  begin
    if s[2] = ':' then s := s + '\';
  end;

  XML.Add('<directory_tree root="' + EncodeSpecialChars(s)+ '" size="' + BytesToStr(Dir.GetSize) + '">');
  DoExportAsXML(Dir, '', true, Dir.GetSize);
  XML.Add('</directory_tree>');

  try
    if OutputFile <> '' then
    begin
      XML.SaveToFile(OutputFile);
      ShellExecute(0, 'open', PAnsiChar(OutputFile), nil, nil, SW_SHOWMAXIMIZED);
      Beep;
    end else begin
      Clipboard.SetTextBuf(XML.GetText);
      Beep;
    end;
  except
    MessageBeep(MB_ICONERROR);
  end;

  Application.ProcessMessages;
  SetCursor(Screen.Cursors[crDefault]);

  FreeAndNil(XML);
end;

function TFormMain.EncodeSpecialChars(Str: String): String;
var
  i: Integer;
  a: String;
begin
  Result := '';
  for i := 1 to Length(Str) do
  begin
    a := Str[i];
    if Byte(Str[i]) > 127 then a := '&#' + IntToStr(Byte(Str[i])) + ';';
    if a = '&' then a := '&amp;';
    Result := Result + a;
  end;
end;

procedure TFormMain.Clipbaord1Click(Sender: TObject);
var
  Dir: TDirectory;
begin
  if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
  begin
    if SaveDialog_XML.Execute then
    begin
      Dir := TreeView1.Selected.Data;
      ExportAsXML(Dir, SaveDialog_XML.FileName);
    end;
  end;
end;

procedure TFormMain.File1Click(Sender: TObject);
var
  Dir: TDirectory;
begin
  if Assigned(TreeView1.Selected) and Assigned(TreeView1.Selected.Data) then
  begin
    Dir := TreeView1.Selected.Data;
    ExportAsXML(Dir, '');
  end;
end;

end.
