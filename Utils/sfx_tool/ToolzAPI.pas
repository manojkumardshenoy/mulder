{ =========================================================================== }
{ === API for Toolz.dll ===================================================== }
{ =========================================================================== }

unit ToolzAPI;

interface

uses
  Windows, SysUtils, Classes;

{-----------------------------------------------------------------------------}
{--- Imports of the "Toolz.dll" functions ------------------------------------}
{-----------------------------------------------------------------------------}

const ToolzDLL = 'Toolz.dll';

function BrowseFolder(Title:AnsiString;InitDir:AnsiString;hWnd:Cardinal):AnsiString; overload; stdcall; external ToolzDLL name 'BrowseFolder';
function BrowseFolder(Title:AnsiString;InitDir:AnsiString):AnsiString; overload; stdcall; external ToolzDLL name 'BrowseFolder2';
function BrowseFolder(Title:AnsiString):AnsiString; overload; stdcall; external ToolzDLL name 'BrowseFolder3';
function BrowseFolder:AnsiString; overload; stdcall; external ToolzDLL name 'BrowseFolder4';
function CreateGUID:AnsiString; stdcall; external ToolzDLL name 'CreateGUID';
function DebuggerPresent:Boolean; stdcall; external ToolzDLL name 'DebuggerPresent';
function Exec(Commandline:AnsiString;Show:Cardinal;Wait:Boolean;ConsoleTitle:AnsiString):Int64; overload; stdcall; external ToolzDLL name 'Exec';
function Exec(Commandline:AnsiString;Show:Cardinal;Wait:Boolean):Int64; overload; stdcall; external ToolzDLL name 'Exec2';
function Exec(Commandline:AnsiString;Show:Cardinal):Int64; overload; stdcall; external ToolzDLL name 'Exec2';
function Exec(Commandline:AnsiString):Int64; overload; stdcall; external ToolzDLL name 'Exec2';
function ExecShell(FileName:AnsiString;Verb:AnsiString;Parameters:AnsiString;DefaultDir:AnsiString;Show:Cardinal):Boolean; overload; stdcall; external ToolzDLL name 'ExecShell';
function ExecShell(FileName:AnsiString;Verb:AnsiString;Parameters:AnsiString;DefaultDir:AnsiString):Boolean; overload; stdcall; external ToolzDLL name 'ExecShell2';
function ExecShell(FileName:AnsiString;Verb:AnsiString;Parameters:AnsiString):Boolean; overload; stdcall; external ToolzDLL name 'ExecShell3';
function ExecShell(FileName:AnsiString;Verb:AnsiString):Boolean; overload; stdcall; external ToolzDLL name 'ExecShell4';
function ExecShell(FileName:AnsiString):Boolean; overload; stdcall; external ToolzDLL name 'ExecShell5';
function ExtractDirectory(PathToFile:AnsiString):AnsiString; stdcall; external ToolzDLL name 'ExtractDirectory';
function ExtractExtension(PathToFile:AnsiString):AnsiString; stdcall; external ToolzDLL name 'ExtractExtension';
function ExtractFileName(PathToFile:AnsiString):AnsiString; stdcall; external ToolzDLL name 'ExtractFileName';
function GetBaseDir:AnsiString; stdcall; external ToolzDLL name 'GetBaseDir';
function GetEnvParam(Param:AnsiString):AnsiString; stdcall; external ToolzDLL name 'GetEnvParam';
function GetLastErrorMsg:AnsiString; stdcall; external ToolzDLL name 'GetLastErrorMsg';
function GetOS(var FullName:AnsiString):Byte; overload; stdcall; external ToolzDLL name 'GetOS';
function GetOS:Byte; overload; stdcall; external ToolzDLL name 'GetOS2';
function GetShellDir(CSIDL:Cardinal):AnsiString; stdcall; external ToolzDLL name 'GetShellDir';
function GetSysDir:AnsiString; stdcall; external ToolzDLL name 'GetSysDir';
function GetTempDir:AnsiString; stdcall; external ToolzDLL name 'GetTempDir';
function GetTempFile(Extension:AnsiString):AnsiString; overload; stdcall; external ToolzDLL name 'GetTempFile';
function GetTempFile:AnsiString; overload; stdcall; external ToolzDLL name 'GetTempFile2';
function GetWinDir:AnsiString; stdcall; external ToolzDLL name 'GetWinDir';
function MakeFileHash(FileName:AnsiString):AnsiString; stdcall; external ToolzDLL name 'MakeFileHash';
function MsgBox(Text:AnsiString;Title:AnsiString;Flags:Cardinal;hWnd:Cardinal):Cardinal; overload; stdcall; external ToolzDLL name 'MsgBox';
function MsgBox(Text:AnsiString;Title:AnsiString;Flags:Cardinal):Cardinal; overload; stdcall; external ToolzDLL name 'MsgBox2';
function MsgBox(Text:AnsiString;Title:AnsiString):Cardinal; overload; stdcall; external ToolzDLL name 'MsgBox3';
function MsgBox(Text:AnsiString):Cardinal; overload; stdcall; external ToolzDLL name 'MsgBox4';
function ReplaceString(BaseStr:AnsiString;SubStr:AnsiString;NewStr:AnsiString):AnsiString; stdcall; external ToolzDLL name 'ReplaceString';
function SearchFiles(SearchMask:AnsiString;var Files:TStringList;SearchFolders:Boolean):Cardinal; overload; stdcall; external ToolzDLL name 'SearchFiles';
function SearchFiles(SearchMask:AnsiString;var Files:TStringList):Cardinal; overload; stdcall; external ToolzDLL name 'SearchFiles2';
function SearchSubfolders(SearchDir:AnsiString;var Folders:TStringList):Cardinal; stdcall; external ToolzDLL name 'SearchSubfolders';
procedure SendMail(MailAdress,Subject,Body:AnsiString); stdcall; external ToolzDLL name 'SendMail';
function SetEnvParam(Param:AnsiString;Value:AnsiString):Boolean; stdcall; external ToolzDLL name 'SetEnvParam';
function StrToOem(Str:AnsiString):AnsiString; stdcall; external ToolzDLL name 'StrToOem';
function TestFileNameStr(FileNameStr:AnsiString):AnsiString; stdcall; external ToolzDLL name 'TestFileNameStr';
procedure VerifyFiles(Hash:array of String; LockFiles:Boolean); stdcall; external ToolzDLL name 'VerifyFiles';

{-----------------------------------------------------------------------------}
{-- Definition of common constains -------------------------------------------}
{-----------------------------------------------------------------------------}

const
  CSIDL_FLAG_CREATE:Cardinal = $8000;
  CSIDL_ADMINTOOLS:Cardinal = $0030;
  CSIDL_ALTSTARTUP:Cardinal = $001d;
  CSIDL_APPDATA:Cardinal = $001a;
  CSIDL_BITBUCKET:Cardinal = $000a;
  CSIDL_CDBURN_AREA:Cardinal = $003b;
  CSIDL_COMMON_ADMINTOOLS:Cardinal = $002f;
  CSIDL_COMMON_ALTSTARTUP:Cardinal = $001e;
  CSIDL_COMMON_APPDATA:Cardinal = $0023;
  CSIDL_COMMON_DESKTOPDIRECTORY:Cardinal = $0019;
  CSIDL_COMMON_DOCUMENTS:Cardinal = $002e;
  CSIDL_COMMON_FAVORITES:Cardinal = $001f;
  CSIDL_COMMON_MUSIC:Cardinal = $0035;
  CSIDL_COMMON_PICTURES:Cardinal = $0036;
  CSIDL_COMMON_PROGRAMS:Cardinal = $0017;
  CSIDL_COMMON_STARTMENU:Cardinal = $0016;
  CSIDL_COMMON_STARTUP:Cardinal = $0018;
  CSIDL_COMMON_TEMPLATES:Cardinal = $002d;
  CSIDL_COMMON_VIDEO:Cardinal = $0037;
  CSIDL_CONTROLS:Cardinal = $0003;
  CSIDL_COOKIES:Cardinal = $0021;
  CSIDL_DESKTOP:Cardinal = $0000;
  CSIDL_DESKTOPDIRECTORY:Cardinal = $0010;
  CSIDL_DRIVES:Cardinal = $0011;
  CSIDL_FAVORITES:Cardinal = $0006;
  CSIDL_FONTS:Cardinal = $0014;
  CSIDL_HISTORY:Cardinal = $0022;
  CSIDL_INTERNET:Cardinal = $0001;
  CSIDL_INTERNET_CACHE:Cardinal = $0020;
  CSIDL_LOCAL_APPDATA:Cardinal = $001c;
  CSIDL_MYDOCUMENTS:Cardinal = $000c;
  CSIDL_MYMUSIC:Cardinal = $000d;
  CSIDL_MYPICTURES:Cardinal = $0027;
  CSIDL_MYVIDEO:Cardinal = $000e;
  CSIDL_NETHOOD:Cardinal = $0013;
  CSIDL_NETWORK:Cardinal = $0012;
  CSIDL_PERSONAL:Cardinal = $0005;
  CSIDL_PRINTERS:Cardinal = $0004;
  CSIDL_PRINTHOOD:Cardinal = $001b;
  CSIDL_PROFILE:Cardinal = $0028;
  CSIDL_PROFILES:Cardinal = $003e;
  CSIDL_PROGRAM_FILES:Cardinal = $0026;
  CSIDL_PROGRAM_FILES_COMMON:Cardinal = $002b;
  CSIDL_PROGRAMS:Cardinal = $0002;
  CSIDL_RECENT:Cardinal = $0008;
  CSIDL_SENDTO:Cardinal = $0009;
  CSIDL_STARTMENU:Cardinal = $000b;
  CSIDL_STARTUP:Cardinal = $0007;
  CSIDL_SYSTEM:Cardinal = $0025;
  CSIDL_TEMPLATES:Cardinal = $0015;
  CSIDL_WINDOWS:Cardinal = $0024;

{--SW_s---------------------------------------------------}

const
  SW_HIDE:Cardinal = Windows.SW_HIDE;
  SW_SHOWNORMAL:Cardinal = Windows.SW_SHOWNORMAL;
  SW_NORMAL:Cardinal = Windows.SW_NORMAL;
  SW_SHOWMINIMIZED:Cardinal = Windows.SW_SHOWMINIMIZED;
  SW_SHOWMAXIMIZED:Cardinal = Windows.SW_SHOWMAXIMIZED;
  SW_MAXIMIZE:Cardinal = Windows.SW_MAXIMIZE;
  SW_SHOWNOACTIVATE:Cardinal = Windows.SW_SHOWNOACTIVATE;
  SW_SHOW:Cardinal = Windows.SW_SHOW;
  SW_MINIMIZE:Cardinal = Windows.SW_MINIMIZE;
  SW_SHOWMINNOACTIVE:Cardinal = Windows.SW_SHOWMINNOACTIVE;
  SW_SHOWNA:Cardinal = Windows.SW_SHOWNA;
  SW_RESTORE:Cardinal = Windows.SW_RESTORE;
  SW_SHOWDEFAULT:Cardinal = Windows.SW_SHOWDEFAULT;
  SW_MAX:Cardinal = Windows.SW_MAX;

const
  MB_OK:Cardinal = Windows.MB_OK;
  MB_OKCANCEL:Cardinal = Windows.MB_OKCANCEL;
  MB_ABORTRETRYIGNORE:Cardinal = Windows.MB_ABORTRETRYIGNORE;
  MB_YESNOCANCEL:Cardinal = Windows.MB_YESNOCANCEL;
  MB_YESNO:Cardinal = Windows.MB_YESNO;
  MB_RETRYCANCEL:Cardinal = Windows.MB_RETRYCANCEL;

  MB_ICONHAND:Cardinal = Windows.MB_ICONHAND;
  MB_ICONQUESTION:Cardinal = Windows.MB_ICONQUESTION;
  MB_ICONEXCLAMATION:Cardinal = Windows.MB_ICONEXCLAMATION;
  MB_ICONASTERISK:Cardinal = Windows.MB_ICONASTERISK;
  MB_USERICON:Cardinal = Windows.MB_USERICON;
  MB_ICONWARNING:Cardinal = Windows.MB_ICONWARNING;
  MB_ICONERROR:Cardinal = Windows.MB_ICONERROR;
  MB_ICONINFORMATION:Cardinal = Windows.MB_ICONINFORMATION;
  MB_ICONSTOP:Cardinal = Windows.MB_ICONSTOP;

  MB_DEFBUTTON1:Cardinal = Windows.MB_DEFBUTTON1;
  MB_DEFBUTTON2:Cardinal = Windows.MB_DEFBUTTON2;
  MB_DEFBUTTON3:Cardinal = Windows.MB_DEFBUTTON3;
  MB_DEFBUTTON4:Cardinal = Windows.MB_DEFBUTTON4;

  MB_APPLMODAL:Cardinal = Windows.MB_APPLMODAL;
  MB_SYSTEMMODAL:Cardinal = Windows.MB_SYSTEMMODAL;
  MB_TASKMODAL:Cardinal = Windows.MB_TASKMODAL;
  MB_HELP:Cardinal = Windows.MB_HELP;

  MB_NOFOCUS:Cardinal = Windows.MB_NOFOCUS;
  MB_SETFOREGROUND:Cardinal = Windows.MB_SETFOREGROUND;
  MB_DEFAULT_DESKTOP_ONLY:Cardinal = Windows.MB_DEFAULT_DESKTOP_ONLY;

  MB_TOPMOST:Cardinal = Windows.MB_TOPMOST;
  MB_RIGHT:Cardinal = Windows.MB_RIGHT;
  MB_RTLREADING:Cardinal = Windows.MB_RTLREADING;

  MB_SERVICE_NOTIFICATION:Cardinal = Windows.MB_SERVICE_NOTIFICATION;
  MB_SERVICE_NOTIFICATION_NT3X:Cardinal = Windows.MB_SERVICE_NOTIFICATION_NT3X;

  MB_TYPEMASK:Cardinal = Windows.MB_TYPEMASK;
  MB_ICONMASK:Cardinal = Windows.MB_ICONMASK;
  MB_DEFMASK:Cardinal = Windows.MB_DEFMASK;
  MB_MODEMASK:Cardinal = Windows.MB_MODEMASK;
  MB_MISCMASK:Cardinal = Windows.MB_MISCMASK;

const
  IDOK:Byte = Windows.IDOK;
  IDCANCEL:Byte = Windows.IDCANCEL;
  IDABORT:Byte = Windows.IDABORT;
  IDRETRY:Byte = Windows.IDRETRY;
  IDIGNORE:Byte = Windows.IDIGNORE;
  IDYES:Byte = Windows.IDYES;
  IDNO:Byte = Windows.IDNO;
  IDCLOSE:Byte = Windows.IDCLOSE;
  IDHELP:Byte = Windows.IDHELP;
  IDTRYAGAIN:Byte = Windows.IDTRYAGAIN;
  IDCONTINUE:Byte = Windows.IDCONTINUE;

const
  STILL_ACTIVE:Cardinal = Windows.STILL_ACTIVE;

const
  OS_WIN32:Byte = 0; // Win32s on Windows 3.1
  OS_WIN9X:Byte = 1; // Windows 9x
  OS_WINNT:Byte = 2; // Windows NT

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}

implementation

end.

