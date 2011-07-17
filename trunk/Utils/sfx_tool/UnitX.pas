unit UnitX;

interface

uses
  Windows, Classes, SysUtils, ToolzAPI;

const
  ProgVersion:AnsiString = '1.01';
  NsisVersion:AnsiString = '2.11';

type
  TColorEx = record
    R: Byte;
    G: Byte;
    B: Byte;
  end;
  
type
  TSFX = record
    OutputFile:AnsiString;
    Compressor:Byte;
    Title:AnsiString;
    InstallDir:AnsiString;
    SourceFiles:TStringList;

    BGWindow:Boolean;
    BGImageFile:AnsiString;
    BGBrandingImageFile:AnsiString;
    BGBrandingImageWidth:Cardinal;
    BGColors:array [0..2] of TColorEx;

    CreateUninstaller:Boolean;
    RegisterUninstaller:Boolean;
    LinkUninstaller:Boolean;

    FileMode:Byte;

    IconFile:AnsiString;
    HeaderImage:AnsiString;
    WizardImage:AnsiString;
    LicenseFile:AnsiString;

    Languages:TStringList;
    SMNames:TStringList;
    SMTargets:TStringList;
    DesktopName:AnsiString;
    DesktopTarget:AnsiString;

    ExecutableFile1:AnsiString;
    ExecutableParams1:AnsiString;
    ExecutableWait1:Boolean;
    ExecutableFile2:AnsiString;
    ExecutableParams2:AnsiString;
    ExecutableWait2:Boolean;

    FinalExecutable:AnsiString;
    FinalParameters:AnsiString;
    FinalReadme:AnsiString;
    FinalLinkURL:AnsiString;
  end;

const
  PathVars:array [0..15] of AnsiString =
    (
    'INSTDIR',
    'EXEDIR',
    'PROGRAMFILES',
    'COMMONFILES',
    'DESKTOP',
    'WINDIR',
    'SYSDIR',
    'TEMP',
    'DOCUMENTS',
    'MUSIC',
    'PICTURES',
    'VIDEOS',
    'FONTS',
    'PROFILE',
    'RESOURCES',
    'RESOURCES_LOCALIZED'
    );

function TestFileName(Str:AnsiString;AllowPaths:Boolean):AnsiString;
function PrepareString(Str:AnsiString;HasPathVars:Boolean):AnsiString;
procedure GenerateScript(SFX:TSFX;Script:TStrings);
procedure TestFiles;
procedure ConvertColor(Color:Longword; var Output:TColorEx);

implementation

function TestFileName(Str:AnsiString;AllowPaths:Boolean):AnsiString;
 var i,x:Cardinal;s:AnsiString;
begin
  if Str = '' then begin
    Result := '';
    Exit;
  end;

 s := Str;
 s := ReplaceString(s,'"','');
 s := ReplaceString(s,'*','');
 s := ReplaceString(s,'?','');
 s := ReplaceString(s,'|','');
 s := ReplaceString(s,'/','\');
 s := ReplaceString(s,'\.','\');
 s := ReplaceString(s,'.\','\');
 s := ReplaceString(s,'\ ','\');
 s := ReplaceString(s,' \','\');
 s := ReplaceString(s,'\.','\');
 s := ReplaceString(s,'.\','\');
 s := ReplaceString(s,'\\','\');
 while (Length(s) > 0) and ((s[Length(s)] = '.') or (s[Length(s)] = ' ') or (s[Length(s)] = '\')) do Delete(s,Length(s),1);
 while (Length(s) > 0) and ((s[1] = '.') or (s[1] = ' ') or (s[1] = '\')) do Delete(s,1,1);

 if AllowPaths then begin
   x := $FFFFFFFF;

   for i := 0 to Length(PathVars) do
     if Length(s) > Length(PathVars[i])+1 then
       if AnsiUpperCase(Copy(s,1,Length(PathVars[i])+2)) = '<' + PathVars[i] + '>' then begin
         x := i;
         Delete(s,1,Length(PathVars[i])+2);
         if (Length(s) > 0) then
           if (s[1] <> '\') then
             s := '\' + s;
         Break;
       end;

   s := ReplaceString(s,'<','');
   s := ReplaceString(s,'>','');

   if x <> $FFFFFFFF then begin
     s := ReplaceString(s,':','_');
     s := '<' + PathVars[x] + '>' + s;
   end else begin
     if Length(s) < 3 then
       s := 'C:\' + s
     else
       if (Ord(UpCase(s[1])) < 65) or (Ord(UpCase(s[1])) > 90) or (s[2] <> ':') or (s[3] <> '\') then
         s := 'C:\' + s;
     for i := 1 to Length(s) do
       if (i <> 2) and (s[i] = ':') then s[i] := '_';
   end;
 end else begin
   s := ReplaceString(s,':','_');
   s := ReplaceString(s,'<','_');
   s := ReplaceString(s,'>','_');
   s := ReplaceString(s,'\','_');
 end;

 if s <> Str then MessageBeep(MB_ICONWARNING);
 Result := s;
end;

function PrepareString(Str:AnsiString;HasPathVars:Boolean):AnsiString;
  var s:AnsiString;i:Integer;
begin
  s := Str;

  i := 1;
  while i <= Length(s) do begin
    if s[i] = '$' then begin
      Insert('$',s,i);
      i := i + 1;
    end;
    i := i + 1;
  end;

  i := 1;
  while i <= Length(s) do begin
    if s[i] = '"' then begin
      Delete(s,i,1);
      Insert('$\"',s,i);
      i := i + 2;
    end;
    i := i + 1;
  end;

  for i := 0 to Length(PathVars)-1 do
    s := ReplaceString(s,'<' + PathVars[i] + '>','$' + PathVars[i]);

  Result := s;
end;

procedure ConvertColor(Color:Longword; var Output:TColorEx);
begin
  Output.R := Lobyte(Loword(Color));
  Output.G := Hibyte(Loword(Color));
  Output.B := Lobyte(Hiword(Color));
end;

procedure GenerateScript(SFX:TSFX;Script:TStrings);
  var i:Cardinal;
begin
  Randomize;

  with Script do begin
    Clear;
    Add('# ===================================================================');
    Add('# This NSIS Script has been generated by SFX Tool');
    Add('# Version ' + ProgVersion);
    Add('# Written by MuldeR (MuldeR2@GMX.de)');
    Add('# Visit http://mulder.at.gg for further information!');
    Add('#');
    Add('# This application is based on NSIS v' + NsisVersion + ' by Nullsoft');
    Add('# ===================================================================');
    Add('');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# Set Working Directory');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('!cd "' + GetBaseDir + '\Resources"');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# Define Variables');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('var STARTMENU_FOLDER');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# Choosing Compressor');
    Add('# -------------------------------------------------------------------');
    Add('');
    case SFX.Compressor of
      0: begin
           Add('SetCompressor LZMA');
           Add('SetCompressorDictSize 32');
         end;
      1: begin
           Add('SetCompressor LZMA');
           Add('SetCompressorDictSize 8');
         end;
      2: Add('SetCompressor BZip2');
      3: Add('SetCompressor ZLib');
    end;
    Add('SetCompress Auto');
    Add('SetDatablockOptimize On');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# SFX Definitions');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('!define SFX_AppID "' + CreateGUID + '"; a unique ID for your SFX (It''s real GUID)');
    Add('!define SFX_BaseDir "' + GetBaseDir + '"; the SFX Tool install folder - do NOT edit!');
    Add('!define SFX_Title "' + SFX.Title + '"; the installer title');
    Add('!define SFX_InstallDir "' + SFX.InstallDir + '"; the *default* destination directory');
    Add('!define SFX_OutFile "' + SFX.OutputFile + '"; the file to save the installer EXE to');
    Add('!define SFX_IconFile "' + SFX.IconFile + '"; the installer icon');
    Add('!define SFX_HeaderImage "' + SFX.HeaderImage + '"; the herader image');
    Add('!define SFX_WizardImage "' + SFX.WizardImage + '"; the wizard image');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# Reserve Files');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('ReserveFile "Plugins\InstallOptions.dll"');
    Add('ReserveFile "Plugins\LangDLL.dll"');
    Add('ReserveFile "Plugins\StartMenu.dll"');
    Add('ReserveFile "Plugins\UserInfo.dll"');
    if SFX.BGWindow then
      Add('ReserveFile "Plugins\BGImage.dll"');
    Add('ReserveFile "Contrib\Graphics\Wizard\${SFX_WizardImage}.bmp"');
    Add('ReserveFile "Contrib\Graphics\Header\${SFX_HeaderImage}.bmp"');
    Add('ReserveFile "Contrib\Graphics\Header\${SFX_HeaderImage}-R.bmp"');
    Add('ReserveFile "Contrib\Modern UI\ioSpecial.ini"');
    if SFX.BGImageFile <> '' then
      Add('ReserveFile "' + SFX.BGImageFile + '"');
    if SFX.BGBrandingImageFile <> '' then
      Add('ReserveFile "' + SFX.BGBrandingImageFile + '"');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# General Settings');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('XPStyle On');
    Add('CRCCheck Force');
    Add('ShowInstDetails Show');
    Add('ShowUninstDetails Show');
    Add('BrandingText "SFX Tool v' + ProgVersion + ', NSIS v' + NsisVersion + '"');
    Add('Name "${SFX_Title}"');
    Add('OutFile "${SFX_OutFile}"');
    Add('InstallDir "${SFX_InstallDir}"');
    Add('InstallDirRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}" "InstallDirectory"');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# Modern Interface Settings');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('!include "MUI.nsh"');
    Add('');
    Add('!define MUI_ICON "Contrib\Graphics\Icons\${SFX_IconFile}-Install.ico"');
    Add('!define MUI_WELCOMEFINISHPAGE_BITMAP "Contrib\Graphics\Wizard\${SFX_WizardImage}.bmp"');
    Add('!define MUI_HEADERIMAGE');
    Add('!define MUI_HEADERIMAGE_BITMAP "Contrib\Graphics\Header\${SFX_HeaderImage}.bmp"');
    Add('!define MUI_HEADERIMAGE_BITMAP_RTL "Contrib\Graphics\Header\${SFX_HeaderImage}-R.bmp"');
    Add('!define MUI_ABORTWARNING');
    Add('!define MUI_WELCOMEPAGE_TITLE_3LINES');
    Add('!define MUI_FINISHPAGE_TITLE_3LINES');
    Add('!define MUI_FINISHPAGE_NOAUTOCLOSE');
    Add('!define MUI_LANGDLL_REGISTRY_ROOT "HKLM"');
    Add('!define MUI_LANGDLL_REGISTRY_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}"');
    Add('!define MUI_LANGDLL_REGISTRY_VALUENAME "InstallLanguage"');
    Add('!define MUI_LANGDLL_ALWAYSSHOW');
    if SFX.FinalExecutable <> '' then begin
      Add('!define MUI_FINISHPAGE_RUN "' + SFX.FinalExecutable + '"');
      Add('!define MUI_FINISHPAGE_RUN_PARAMETERS "' + SFX.FinalParameters + '"');
    end;
    if SFX.FinalReadme <> '' then
      Add('!define MUI_FINISHPAGE_SHOWREADME "' + SFX.FinalReadme + '"');
    if SFX.FinalLinkURL <> '' then begin
      Add('!define MUI_FINISHPAGE_LINK "' + SFX.FinalLinkURL + '"');
      Add('!define MUI_FINISHPAGE_LINK_LOCATION "' + SFX.FinalLinkURL + '"');
    end;
    if (SFX.SMNames.Count > 0) or SFX.LinkUninstaller then begin
      Add('!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"');
      Add('!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}"');
      Add('!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "StartmenuFolder"');
    end;
    if SFX.LicenseFile <> '' then
      Add('!define MUI_LICENSEPAGE_RADIOBUTTONS');
    if SFX.CreateUninstaller then begin
      Add('!define MUI_UNICON "Contrib\Graphics\Icons\${SFX_IconFile}-Uninstall.ico"');
      Add('!define MUI_UNWELCOMEFINISHPAGE_BITMAP "Contrib\Graphics\Wizard\${SFX_WizardImage}.bmp"');
      Add('!define MUI_UNFINISHPAGE_NOAUTOCLOSE');
      Add('!define MUI_UNABORTWARNING');
      if SFX.BGWindow then
        Add('!define MUI_CUSTOMFUNCTION_UNGUIINIT un.InitializeGUI');
    end;
    if SFX.BGWindow then
      Add('!define MUI_CUSTOMFUNCTION_GUIINIT InitializeGUI');
    Add('');
    Add('!insertmacro MUI_PAGE_WELCOME');
    if SFX.LicenseFile <> '' then
      Add('!insertmacro MUI_PAGE_LICENSE "' + SFX.LicenseFile + '"');
    Add('!insertmacro MUI_PAGE_DIRECTORY');
    if (SFX.SMNames.Count > 0) or SFX.LinkUninstaller then
      Add('!insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER');
    Add('!insertmacro MUI_PAGE_INSTFILES');
    Add('!insertmacro MUI_PAGE_FINISH');
    if SFX.CreateUninstaller then begin
      Add('!insertmacro MUI_UNPAGE_WELCOME');
      Add('!insertmacro MUI_UNPAGE_CONFIRM');
      Add('!insertmacro MUI_UNPAGE_INSTFILES');
      Add('!insertmacro MUI_UNPAGE_FINISH');
    end;
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# Multi-Language Support');
    Add('# -------------------------------------------------------------------');
    Add('');
    for i := 0 to (SFX.Languages.Count-1) do
      Add('!insertmacro MUI_LANGUAGE "' + SFX.Languages[i] + '"');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# Install Files Section');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('Section');
    Add('  SetOutPath "$INSTDIR"');
    for i := 0 to SFX.SourceFiles.Count-1 do
      case SFX.FileMode of
        0: Add('  File "' + SFX.SourceFiles[i] + '"');
        1: Add('  File /r "' + SFX.SourceFiles[i] + '"');
        2: Add('  File /a "' + SFX.SourceFiles[i] + '"');
        3: Add('  File /a /r "' + SFX.SourceFiles[i] + '"');
      end;
    Add('SectionEnd');
    Add('');
    Add('');
    if (SFX.ExecutableFile1 <> '') or (SFX.ExecutableFile2 <> '') then begin
      Add('# -------------------------------------------------------------------');
      Add('# Run Executables');
      Add('# -------------------------------------------------------------------');
      Add('');
      Add('Section');
      if SFX.ExecutableFile1 <> '' then
        if SFX.ExecutableWait1
          then Add('  ExecWait "$\"' + SFX.ExecutableFile1 + '$\" ' + SFX.ExecutableParams1 + '"')
          else Add('  Exec "$\"' + SFX.ExecutableFile1 + '$\" ' + SFX.ExecutableParams1 + '"');
      if SFX.ExecutableFile2 <> '' then
        if SFX.ExecutableWait2
          then Add('  ExecWait "$\"' + SFX.ExecutableFile2 + '$\" ' + SFX.ExecutableParams2 + '"')
          else Add('  Exec "$\"' + SFX.ExecutableFile2 + '$\" ' + SFX.ExecutableParams2 + '"');
      Add('SectionEnd');
      Add('');
      Add('');
    end;
    if SFX.CreateUninstaller then begin
      Add('# -------------------------------------------------------------------');
      Add('# Create Uninstaller Section');
      Add('# -------------------------------------------------------------------');
      Add('');
      Add('Section');
      Add('  SetOutPath "$INSTDIR"');
      Add('  WriteUninstaller "$INSTDIR\Uninstall.exe"');
      if SFX.RegisterUninstaller then begin
        Add('  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}" "DisplayName" "${SFX_Title}"');
        Add('  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}" "DisplayIcon" "$\"$INSTDIR\Uninstall.exe$\""');
        Add('  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""');
        Add('  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}" "NoModify" 1');
        Add('  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}" "NoRepair" 1');
      end;
      Add('SectionEnd');
      Add('');
      Add('');
    end;
    if (SFX.SMNames.Count > 0) or SFX.LinkUninstaller then begin
      Add('# -------------------------------------------------------------------');
      Add('# Startmenu Section');
      Add('# -------------------------------------------------------------------');
      Add('');
      Add('Section');
      Add('  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application');
      Add('');
      Add('  SetShellVarContext all');
      Add('  CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"');
      if SFX.SMNames.Count > 0 then
        for i := 0 to SFX.SMNames.Count-1 do
          Add('  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\' + SFX.SMNames[i] + '.lnk" "' + SFX.SMTargets[i] + '"');
      if SFX.LinkUninstaller then
        Add('  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\$(^UninstallCaption).lnk" "$INSTDIR\Uninstall.exe"');
      Add('  SetShellVarContext current');
      Add('');
      Add('  !insertmacro MUI_STARTMENU_WRITE_END');
      Add('SectionEnd');
      Add('');
      Add('');
    end;
    if (SFX.DesktopName <> '') and (SFX.DesktopTarget <> '') then begin
      Add('# -------------------------------------------------------------------');
      Add('# Desktop Section');
      Add('# -------------------------------------------------------------------');
      Add('');
      Add('Section');
      Add('  SetShellVarContext all');
      Add('  CreateShortCut "$DESKTOP\' + SFX.DesktopName + '.lnk" "' + SFX.DesktopTarget + '"');
      Add('  SetShellVarContext current');
      Add('SectionEnd');
      Add('');
      Add('');
    end;
    Add('# -------------------------------------------------------------------');
    Add('# Registry Section');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('Section');
    Add('  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}" "" "${SFX_Title}"');
    Add('  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}" "InstallDirectory" "$INSTDIR"');
    Add('SectionEnd');
    Add('');
    Add('');
    Add('# -------------------------------------------------------------------');
    Add('# Initialization Functions');
    Add('# -------------------------------------------------------------------');
    Add('');
    Add('Function .onInit');
    Add('  InitPluginsDir');
    Add('');
    Add('  ClearErrors');
    Add('  UserInfo::GetName');
    Add('  IfErrors RunTheInstaller');
    Add('  Pop $0');
    Add('  UserInfo::GetAccountType');
    Add('  Pop $1');
    Add('');
    Add('  StrCmp $1 "Admin" RunTheInstaller');
    Add('  StrCmp $1 "Power" RunTheInstaller');
    Add('  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "The user $\"$0$\" is not allowed to install this application.$\nPlease ask your administrator''s permission !!!"');
    Add('  Quit');
    Add('');
    Add('  RunTheInstaller:');
    Add('  !insertmacro MUI_LANGDLL_DISPLAY');
    Add('FunctionEnd');
    Add('');
    if SFX.BGWindow then begin
      Add('Function InitializeGUI');
      if SFX.BGImageFile <> '' then begin
        Add('  SetOutPath "$PLUGINSDIR"');
        Add('  File /oname=BGImage.bmp "' + SFX.BGImageFile + '"');
        Add('  BGImage::SetBG /NOUNLOAD /FILLSCREEN "$PLUGINSDIR\BGImage.bmp"');
        Add('  Delete "$PLUGINSDIR\BGImage.bmp"');
      end else
        Add('  BGImage::SetBG /NOUNLOAD /GRADIENT 0x' + IntToHex(SFX.BGColors[0].R,2) + ' 0x' + IntToHex(SFX.BGColors[0].G,2) + ' 0x' + IntToHex(SFX.BGColors[0].B,2) + ' 0x' + IntToHex(SFX.BGColors[1].R,2) + ' 0x' + IntToHex(SFX.BGColors[1].G,2) + ' 0x' + IntToHex(SFX.BGColors[1].B,2));
      if SFX.BGBrandingImageFile <> '' then begin
        Add('  SetOutPath "$PLUGINSDIR"');
        Add('  File /oname=BGBrandingImage.bmp "' + SFX.BGBrandingImageFile + '"');
        Add('  BGImage::AddImage /NOUNLOAD "$PLUGINSDIR\BGBrandingImage.bmp" ' + IntToStr(-SFX.BGBrandingImageWidth-10) + ' 10');
        Add('  Delete "$PLUGINSDIR\BGBrandingImage.bmp"');
      end;
      Add('  CreateFont $R0 "Verdana" 22 700');
      Add('  BGImage::AddText /NOUNLOAD "$(^SetupCaption)" $R0 0x' + IntToHex(SFX.BGColors[2].R,2) + ' 0x' + IntToHex(SFX.BGColors[2].G,2) + ' 0x' + IntToHex(SFX.BGColors[2].B,2) + ' 10 10 -10 -10');
      Add('  BGImage::Redraw /NOUNLOAD');
      Add('FunctionEnd');
      Add('');
      Add('Function .onGUIEnd');
      Add('  BGImage::Destroy');
      Add('FunctionEnd');
      Add('');
    end;
    Add('');
    Add('');
    if SFX.CreateUninstaller then begin
      Add('# -------------------------------------------------------------------');
      Add('# Uninstaller Section');
      Add('# -------------------------------------------------------------------');
      Add('');
      Add('Section "Uninstall"');
      Add('  RMDir /r "$INSTDIR"');
      Add('');
      if (SFX.SMNames.Count > 0) or SFX.LinkUninstaller then begin
        Add('  !insertmacro MUI_STARTMENU_GETFOLDER Application $R0');
        Add('  SetShellVarContext all');
        Add('  RMDir /r "$SMPROGRAMS\$R0"');
        Add('  SetShellVarContext current');
        Add('');
      end;
      if (SFX.DesktopName <> '') and (SFX.DesktopTarget <> '') then begin
        Add('  SetShellVarContext all');
        Add('  Delete "$DESKTOP\' + SFX.DesktopName + '.lnk"');
        Add('  SetShellVarContext current');
        Add('');
      end;
      Add('  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SFX_AppID}"');
      Add('SectionEnd');
      Add('');
      Add('');
      Add('# -------------------------------------------------------------------');
      Add('# Uninstaller Initialization Function');
      Add('# -------------------------------------------------------------------');
      Add('');
      Add('Function un.onInit');
      Add('  InitPluginsDir');
      Add('');
      Add('  ClearErrors');
      Add('  UserInfo::GetName');
      Add('  IfErrors RunTheUninstaller');
      Add('  Pop $0');
      Add('  UserInfo::GetAccountType');
      Add('  Pop $1');
      Add('');
      Add('  StrCmp $1 "Admin" RunTheUninstaller');
      Add('  StrCmp $1 "Power" RunTheUninstaller');
      Add('  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "The user $\"$0$\" is not allowed to uninstall this application.$\nPlease ask your administrator''s permission !!!"');
      Add('  Quit');
      Add('');
      Add('  RunTheUninstaller:');
      Add('  !insertmacro MUI_LANGDLL_DISPLAY');
      Add('FunctionEnd');
      Add('');
      if SFX.BGWindow then begin
        Add('Function un.InitializeGUI');
        if SFX.BGImageFile <> '' then begin
          Add('  SetOutPath "$PLUGINSDIR"');
          Add('  File /oname=BGImage.bmp "' + SFX.BGImageFile + '"');
          Add('  BGImage::SetBG /NOUNLOAD /FILLSCREEN "$PLUGINSDIR\BGImage.bmp"');
          Add('  Delete "$PLUGINSDIR\BGImage.bmp"');
        end else
          Add('  BGImage::SetBG /NOUNLOAD /GRADIENT 0x' + IntToHex(SFX.BGColors[0].R,2) + ' 0x' + IntToHex(SFX.BGColors[0].G,2) + ' 0x' + IntToHex(SFX.BGColors[0].B,2) + ' 0x' + IntToHex(SFX.BGColors[1].R,2) + ' 0x' + IntToHex(SFX.BGColors[1].G,2) + ' 0x' + IntToHex(SFX.BGColors[1].B,2));
        if SFX.BGBrandingImageFile <> '' then begin
          Add('  SetOutPath "$PLUGINSDIR"');
          Add('  File /oname=BGBrandingImage.bmp "' + SFX.BGBrandingImageFile + '"');
          Add('  BGImage::AddImage /NOUNLOAD "$PLUGINSDIR\BGBrandingImage.bmp" ' + IntToStr(-SFX.BGBrandingImageWidth-10) + ' 10');
          Add('  Delete "$PLUGINSDIR\BGBrandingImage.bmp"');
        end;
        Add('  CreateFont $R0 "Verdana" 22 700');
        Add('  BGImage::AddText /NOUNLOAD "$(^SetupCaption)" $R0 0x' + IntToHex(SFX.BGColors[2].R,2) + ' 0x' + IntToHex(SFX.BGColors[2].G,2) + ' 0x' + IntToHex(SFX.BGColors[2].B,2) + ' 10 10 -10 -10');
        Add('  BGImage::Redraw /NOUNLOAD');
        Add('FunctionEnd');
        Add('');
        Add('Function un.onGUIEnd');
        Add('  BGImage::Destroy');
        Add('FunctionEnd');
        Add('');
      end;
      Add('');
    end;
    Add('');
    Add('# ===================================================================');
    Add('# End of File');
    Add('# ===================================================================');
  end;
end;

procedure TestFiles;
const
  FileHash: array [0..146] of String = (
    'Help\Blank.html?153287599a833c268f633bc22f5f264d',
    'Help\Index.html?980ede2315249f9091b4b875af30216b',
    'Help\Readme.html?c4a10dbaec24561b6ac3db353ad90e36',
    'Resources\makensis.exe?f10deccfd0b98f5a7ba40268ff5cb85f',
    'Resources\Contrib\Graphics\Checks\Big.bmp?ea6d4785ab8d073ee28a5484afa568c5',
    'Resources\Contrib\Graphics\Checks\Classic.bmp?cfe377bc9fc0622bec69bb72d3c3bf80',
    'Resources\Contrib\Graphics\Checks\Classic-Cross.bmp?a1f55cd0853872d5d1923cc7a5daba34',
    'Resources\Contrib\Graphics\Checks\Colorful.bmp?9e607d1df83db89026831faa71badad0',
    'Resources\Contrib\Graphics\Checks\Grey.bmp?9c4cf578eee36746421778420ddf9e8d',
    'Resources\Contrib\Graphics\Checks\Grey-Cross.bmp?a2e4650361227448ad999c3516ec3f04',
    'Resources\Contrib\Graphics\Checks\Modern.bmp?60d2a10c7daac29b36ca1c303f13d0a2',
    'Resources\Contrib\Graphics\Checks\Red.bmp?3a06d1f71836c6f30dd25b156231c648',
    'Resources\Contrib\Graphics\Checks\Red-Round.bmp?7d1a612e0b8063104578a14a9a26bb0b',
    'Resources\Contrib\Graphics\Checks\Simple.bmp?bcd206077c42dc63c334543546eae1b5',
    'Resources\Contrib\Graphics\Checks\Simple-Round.bmp?d5e694db0a5934750d1f83e5ea7763d1',
    'Resources\Contrib\Graphics\Checks\Simple-Round2.bmp?82972b5d44cea4604c4fa647fa6a1a9b',
    'Resources\Contrib\Graphics\Header\NSIS.bmp?940c56737bf9bb69ce7a31c623d4e87a',
    'Resources\Contrib\Graphics\Header\NSIS-R.bmp?1b1176cf517f1bea1ed4315f672589dd',
    'Resources\Contrib\Graphics\Header\Win.bmp?eadf80c79f88337c58ca0fb5032cb579',
    'Resources\Contrib\Graphics\Header\Win-R.bmp?e5a7b658d1198332f1768e437a00cf38',
    'Resources\Contrib\Graphics\Icons\Arrow-Install.ico?a732b92b6262bb6a61e3b2b1ca4359c3',
    'Resources\Contrib\Graphics\Icons\Arrow-Uninstall.ico?0243196a60b08b1f31208ad8960879b1',
    'Resources\Contrib\Graphics\Icons\Box-Install.ico?034ed0f6ec784b34577b89bf045b4063',
    'Resources\Contrib\Graphics\Icons\Box-Uninstall.ico?4c21bb2d1c41488bcb614d49fa69b20a',
    'Resources\Contrib\Graphics\Icons\Classic-Install.ico?28151c77b90e6fbd9b194c32e9c9d405',
    'Resources\Contrib\Graphics\Icons\Classic-Uninstall.ico?9994a299bf19e1260b0be53af4675ed2',
    'Resources\Contrib\Graphics\Icons\Llama-Install.ico?2e2c96cb50ec0b34d541004d5398854b',
    'Resources\Contrib\Graphics\Icons\Llama-Uninstall.ico?4594824ab309855d19ff533aadbd11d5',
    'Resources\Contrib\Graphics\Icons\Modern-Blue-Install.ico?b6d66ee2e36cc41fd4cced07a02043ff',
    'Resources\Contrib\Graphics\Icons\Modern-Blue-Uninstall.ico?3ba26092cac1be9afd78ec88a07308c5',
    'Resources\Contrib\Graphics\Icons\Modern-Colorful-Install.ico?795dfadd194c56269bfb0b45cd7fd05f',
    'Resources\Contrib\Graphics\Icons\Modern-Colorful-Uninstall.ico?4d0146850bda3b604837889d80667a76',
    'Resources\Contrib\Graphics\Icons\Modern-Default-Install.ico?f4126775f2aa973682b1c9e142338135',
    'Resources\Contrib\Graphics\Icons\Modern-Default-Uninstall.ico?79edcb4aaca3eacb0bf679ce2edfc7ba',
    'Resources\Contrib\Graphics\Icons\Pixel-Install.ico?f49764fb2a99809ce599ff60f6207c61',
    'Resources\Contrib\Graphics\Icons\Pixel-Uninstall.ico?753ba77269d7052d696773d87bdee996',
    'Resources\Contrib\Graphics\Icons\Windows-Install.ico?f31ab27282cf444ef1f263320be6b705',
    'Resources\Contrib\Graphics\Icons\Windows-Uninstall.ico?62a385296a57632959a5abac36369b60',
    'Resources\Contrib\Graphics\Icons\WinXP-Install.ico?6e8508b4042b0a00c6acc1e900331212',
    'Resources\Contrib\Graphics\Icons\WinXP-Uninstall.ico?0f7226ee8b3d00c007615e0a313282ae',
    'Resources\Contrib\Graphics\Wizard\Arrow.bmp?404be80f012c5445d2d1034fb381751b',
    'Resources\Contrib\Graphics\Wizard\Llama.bmp?a72996789e121eba43a54a9a761c78cf',
    'Resources\Contrib\Graphics\Wizard\NSIS.bmp?e58e3b3163d1d85ce72df18b0e9c5ed4',
    'Resources\Contrib\Graphics\Wizard\Nullsoft.bmp?3d2a79a829946435acded3832780723f',
    'Resources\Contrib\Graphics\Wizard\Win.bmp?cbe40fd2b1ec96daedc65da172d90022',
    'Resources\Contrib\Language Files\Arabic.nlf?18088fece01b04446eb8cdab772d1e19',
    'Resources\Contrib\Language Files\Bulgarian.nlf?17023afee9edc40961f0f22e8cdb707d',
    'Resources\Contrib\Language Files\Catalan.nlf?8ff714cea88cc71725c6c5bb1fc9ab8b',
    'Resources\Contrib\Language Files\Croatian.nlf?20cb7dface30d36391a29f9cd0c28457',
    'Resources\Contrib\Language Files\Czech.nlf?e65416c2dd337c862bcf9666a8cd163b',
    'Resources\Contrib\Language Files\Danish.nlf?d64c67cbf2dd05014f7a658f06f9bba9',
    'Resources\Contrib\Language Files\Dutch.nlf?449c13fdcf448dbd156c80a696d232cb',
    'Resources\Contrib\Language Files\English.nlf?b977decff958127334efd935d2bbc844',
    'Resources\Contrib\Language Files\Estonian.nlf?1483e05299b195492fa5b887111fb2e2',
    'Resources\Contrib\Language Files\Farsi.nlf?86c76e92559c45eca3e74917a1e2519a',
    'Resources\Contrib\Language Files\Finnish.nlf?4f1dbee0ae7d7af0daf0060d10dfa6f6',
    'Resources\Contrib\Language Files\French.nlf?c65ee286734839a32b823977e8ca4f57',
    'Resources\Contrib\Language Files\German.nlf?05ff87a6485b99ace0071db44164993e',
    'Resources\Contrib\Language Files\Greek.nlf?5ad549206a8979ce28c155eb158e4848',
    'Resources\Contrib\Language Files\Hebrew.nlf?0584d5b7e095607b25cfbb61a635fd0f',
    'Resources\Contrib\Language Files\Hungarian.nlf?ae322221d11c53fde4f9edcab2d4b23f',
    'Resources\Contrib\Language Files\Indonesian.nlf?6e75434573f77528e27d23a2393217f2',
    'Resources\Contrib\Language Files\Italian.nlf?a31c7a875e90691f5d0eb7028db335a1',
    'Resources\Contrib\Language Files\Japanese.nlf?b21e2368e601caad254f542815b10d59',
    'Resources\Contrib\Language Files\Korean.nlf?c76a9db56c1a98e6831ceb4b823f3829',
    'Resources\Contrib\Language Files\Latvian.nlf?76b3a4840ab60f68f84cb9f3a341532f',
    'Resources\Contrib\Language Files\Lithuanian.nlf?6e6faeb699a61de5edc92173ce39caf5',
    'Resources\Contrib\Language Files\Macedonian.nlf?8a880db121e32e81a42ffc41a3709a9f',
    'Resources\Contrib\Language Files\Norwegian.nlf?7f457a7a064bdd9749e075ad2b2637fb',
    'Resources\Contrib\Language Files\Polish.nlf?de95c462dc223a994322ecc137749e2b',
    'Resources\Contrib\Language Files\Portuguese.nlf?0bacd7d6a11f8885aa308ea5cae4f858',
    'Resources\Contrib\Language Files\PortugueseBR.nlf?820c83551f8e4517fd0224ed7dbe2aae',
    'Resources\Contrib\Language Files\Romanian.nlf?a301adf1642e0d0b46ef19e6e4db616a',
    'Resources\Contrib\Language Files\Russian.nlf?ab9ed4c8f9a1920f8de1512e33c6c1cd',
    'Resources\Contrib\Language Files\Serbian.nlf?da735e7c8fd95a65ffaf5713f48f75d4',
    'Resources\Contrib\Language Files\SerbianLatin.nlf?1d025ef8c5d495e27042cf98efcd1c58',
    'Resources\Contrib\Language Files\SimpChinese.nlf?1bbacf54a704006ff10ec487be7ae4d3',
    'Resources\Contrib\Language Files\Slovak.nlf?c45601b9e6aa9d62453fd4196bb56df7',
    'Resources\Contrib\Language Files\Slovenian.nlf?fba01c7f6ce7efdf58c467aa736b2538',
    'Resources\Contrib\Language Files\Spanish.nlf?2877eae7678d8661964f1a2e791f33d9',
    'Resources\Contrib\Language Files\Swedish.nlf?e01960a06fa8ada33eea2bd76cc51005',
    'Resources\Contrib\Language Files\Thai.nlf?9f4a1fd744f6ff63ca2eda95f0c3ecb4',
    'Resources\Contrib\Language Files\TradChinese.nlf?0367172c94cb3fa30713959cb47d95a9',
    'Resources\Contrib\Language Files\Turkish.nlf?33b2bd4908641d87f18a8d3bad5ce6ae',
    'Resources\Contrib\Language Files\Ukrainian.nlf?9f355c0ca6590a0d84649ddbec7d3a26',
    'Resources\Contrib\Modern UI\ioSpecial.ini?e2d5070bc28db1ac745613689ff86067',
    'Resources\Contrib\Modern UI\System.nsh?0aa2813fb3b97f3477adb0047813c71c',
    'Resources\Contrib\Modern UI\Language Files\Arabic.nsh?96d0bcdfb0ca73bf9f6dc028a8526080',
    'Resources\Contrib\Modern UI\Language Files\Bulgarian.nsh?a7b499acc0bd6413301c8f44be832238',
    'Resources\Contrib\Modern UI\Language Files\Catalan.nsh?c7001a46436b2f1555f8b136573496f8',
    'Resources\Contrib\Modern UI\Language Files\Croatian.nsh?2630ba275b3dcf36f00fcd692880bdc4',
    'Resources\Contrib\Modern UI\Language Files\Czech.nsh?2cb6c35eb505226d91073c1e3ea3b2aa',
    'Resources\Contrib\Modern UI\Language Files\Danish.nsh?ed541eea96866ac0c83c25921c491a82',
    'Resources\Contrib\Modern UI\Language Files\Default.nsh?5c9d6b4f490cc916fe42db6bdbc06cca',
    'Resources\Contrib\Modern UI\Language Files\Dutch.nsh?bb07372cf3637f3834d7a77f6d013f20',
    'Resources\Contrib\Modern UI\Language Files\English.nsh?c68357b5dd3eb00e26ab8197100bbb65',
    'Resources\Contrib\Modern UI\Language Files\Estonian.nsh?0cd0b3b3a21e9fc4e9cbc14089ffba96',
    'Resources\Contrib\Modern UI\Language Files\Farsi.nsh?c581996230b0f0ec460a7981a3b74bf3',
    'Resources\Contrib\Modern UI\Language Files\Finnish.nsh?57fcded337d5abf93a09d2057f771f86',
    'Resources\Contrib\Modern UI\Language Files\French.nsh?c9cbcbd4c74270ae0a2fe3e61c2f9593',
    'Resources\Contrib\Modern UI\Language Files\German.nsh?e36595e1db758a9c900be62cd77ccd78',
    'Resources\Contrib\Modern UI\Language Files\Greek.nsh?7f0b8cdc1fd18b2ff3fed28aba922288',
    'Resources\Contrib\Modern UI\Language Files\Hebrew.nsh?637721a0b192211236a0128a44bc6428',
    'Resources\Contrib\Modern UI\Language Files\Hungarian.nsh?2af995195ff25d45dd4bb0ae2340325a',
    'Resources\Contrib\Modern UI\Language Files\Indonesian.nsh?9ab5ece1a8f35ac0a55afc373a5cc071',
    'Resources\Contrib\Modern UI\Language Files\Italian.nsh?4cd5c17c3a026826c6d2a1e641c33649',
    'Resources\Contrib\Modern UI\Language Files\Japanese.nsh?a7159a1f8e1b4de66f0bb68d45fc5ccf',
    'Resources\Contrib\Modern UI\Language Files\Korean.nsh?e7b1066eba25d41ee4026210e8d10878',
    'Resources\Contrib\Modern UI\Language Files\Latvian.nsh?c7c8fdf7e5a1d5b5032c5a77970c02e9',
    'Resources\Contrib\Modern UI\Language Files\Lithuanian.nsh?251eebd81c1e277afb7f029baeb84cbf',
    'Resources\Contrib\Modern UI\Language Files\Macedonian.nsh?6d72a0a2ad65ab46b20f3d3be8e3087b',
    'Resources\Contrib\Modern UI\Language Files\Norwegian.nsh?3331e45dab774740a743cab66e74d6c7',
    'Resources\Contrib\Modern UI\Language Files\Polish.nsh?b529e56bb894a3686a2544f5e30f261e',
    'Resources\Contrib\Modern UI\Language Files\Portuguese.nsh?79c8ae8f9bc44be2769d227bb39c1b50',
    'Resources\Contrib\Modern UI\Language Files\PortugueseBR.nsh?27c934328424e0b7631a2facc3a5e230',
    'Resources\Contrib\Modern UI\Language Files\Romanian.nsh?b685275815a801ec3d8c0f8b0cf621e1',
    'Resources\Contrib\Modern UI\Language Files\Russian.nsh?5c4ed713f1ecd567218029895f3ef2f5',
    'Resources\Contrib\Modern UI\Language Files\Serbian.nsh?6c2a806a2594a60a021ddb5d3e0d61c9',
    'Resources\Contrib\Modern UI\Language Files\SerbianLatin.nsh?1feae7e88987e2ebb20f97eb4c378933',
    'Resources\Contrib\Modern UI\Language Files\SimpChinese.nsh?9b6b9ed5d3ad8db29c0295570b4586e6',
    'Resources\Contrib\Modern UI\Language Files\Slovak.nsh?61cfee8e92466f4d405c4d401a89ec2b',
    'Resources\Contrib\Modern UI\Language Files\Slovenian.nsh?d3d95145765e1d28eca96b572429d96c',
    'Resources\Contrib\Modern UI\Language Files\Spanish.nsh?b7c87875b58bedd495aec133f8cb94f0',
    'Resources\Contrib\Modern UI\Language Files\Swedish.nsh?f5c117753dec9ecc5e1c6742caddb0df',
    'Resources\Contrib\Modern UI\Language Files\Thai.nsh?0a5ff1b52f00547b0f85427d86f92125',
    'Resources\Contrib\Modern UI\Language Files\TradChinese.nsh?bfc472c30adc3ef8eba3fcad62033014',
    'Resources\Contrib\Modern UI\Language Files\Turkish.nsh?8aab43e6c419a6d1cf406420807d2554',
    'Resources\Contrib\Modern UI\Language Files\Ukrainian.nsh?8ff427de79f403add6dae206b8818e9b',
    'Resources\Contrib\UIs\Modern.exe?f0c7f9496233e70a4b77489f5b9f10f6',
    'Resources\Contrib\UIs\Modern_HeaderBMP.exe?4866abca310fc69c96faf1e75839dc6a',
    'Resources\Contrib\UIs\Modern_HeaderBMPR.exe?3caad4a040f2dc63eaaba0ebc97c811b',
    'Resources\Contrib\UIs\Modern_NoDesc.exe?22379d337d4e83e620a34aed794008cb',
    'Resources\Contrib\UIs\Modern_SmallDesc.exe?f7e4944d5a360e94f0c756c0d57ad904',
    'Resources\Include\MUI.nsh?4878d0b853088d60453fcb61a2128ddb',
    'Resources\Include\WinMessages.nsh?a41318a8b6effde52ee6f1ac228be350',
    'Resources\Plugins\BGImage.dll?f03d59e2e8b4c488546e40c799c0bd63',
    'Resources\Plugins\InstallOptions.dll?4c7d97d0786ff08b20d0e8315b5fc3cb',
    'Resources\Plugins\LangDLL.dll?2c3c8976d729d28478a789217a882291',
    'Resources\Plugins\StartMenu.dll?388c408cff35a38d04e3cda18f63af07',
    'Resources\Plugins\UserInfo.dll?419d642fe3436fda8bb22eea9c37a6ca',
    'Resources\Stubs\bzip2?0c657e3d7effe18cba331add773f5de8',
    'Resources\Stubs\bzip2_solid?35bccfd127faec5e5382879e735f8385',
    'Resources\Stubs\lzma?39ed41abed6b4d13542e5cc8830e3af2',
    'Resources\Stubs\lzma_solid?a57f92e22eb8b8874333f61c24aa830f',
    'Resources\Stubs\uninst?4023b710d3b47d9101c27f5da22aa5ef',
    'Resources\Stubs\zlib?08d0d8cc075f1121d6041838ea0ce870',
    'Resources\Stubs\zlib_solid?45f2e68adc27b94c7de3e5f3e2c7e290'
    );
begin
  VerifyFiles(FileHash,true);
end;

end.