unit Unit_Lang_EN;

interface

procedure LoadLanguage;

implementation

uses
  Unit_Main;

procedure LoadLanguage;
begin
  with Form_Main do begin
    LangStr_NoFiles := 'Please add at least one file to the list !!!';
    LangStr_Status_Header_Create := 'Creating archive';
    LangStr_Status_Header_Extract := 'Extract archive';
    LangStr_Status_Init := 'Initializing...';
    LangStr_Status_Searching := 'Searching and analyzing files, please wait...';
    LangStr_Status_Adding := 'Adding files to archive, please wait...';
    LangStr_Status_Extracting := 'Extracting files from archive, please wait...';
    LangStr_Status_Testing := 'Testing files in archive, please wait...';
    LangStr_Status_CreateSuccess := 'Archive created successfully.';
    LangStr_Status_ExtractSuccess := 'Archive extracted successfully.';
    LangStr_Status_Faild := 'Faild: An error has occured !!!';
    LangStr_Status_Aborted := 'Operation aborted by the user!';
    LangStr_ArchiveCreated := 'The archive was created successfully :-)';
    LangStr_ArchiveCreateFaild := 'Error: Faild to create archive !!!';
    LangStr_ArchiveExtracted := 'The archive was extracted successfully :-)';
    LangStr_ArchiveExtractFaild := 'Error: Faild to extract archive !!!';
    LangStr_ProcessTerminated := 'Process terminated!';
    LangStr_TimeLeft := 'Time left:';
    LangStr_Unknown := 'Unknown';
    LangStr_UpdateNotice1 := 'A new version of UHARC/GUI has been released:';
    LangStr_UpdateNotice2 := 'It''s highly recommended you update as soon as possible!';
    LangStr_ReenterPassword := 'The passwords you entered do not match. Try again!';
    LangStr_UnknownArchive := 'Sorry, this is not a supported archive file!';
    LangStr_PasswordRequired := 'This archive is encrypted. Please enter password:';
    LangStr_WrongPassword := 'Error on reading archive file. Wrong password?';
    LangStr_FaildOpenArchive := 'Error on reading archive file. Might be corrupted!';
    LangStr_ArchiveInfo_Archive := 'Archive:';
    LangStr_ArchiveInfo_Unknown := 'Unknown';
    LangStr_ArchiveInfo_Files := 'Files:';
    LangStr_ArchiveInfo_Compression := 'Compression:';
    LangStr_ArchiveInfo_Uncompressed := 'Uncompressed';
    LangStr_ArchiveInfo_Ratio := 'Ratio:';
    LangStr_NoArchiveOpen := 'Please open an archive first!';
    LangStr_None := '(none)';

    Sheet_Welcome.Caption := 'Main Menu';
    Label_Welcome.Caption := 'Welcome to UHARC/GUI';
    Label_WhatToDoNow.Caption := 'What do you want to do now, ' + ComputerInfo.Identification.LocalUserName + ' ???';
    Label_CreateArchive.Caption := 'Create new archive';
    Label_CreateArchive_Info.Caption := 'Creates a new archive and adds the specified files to it.';
    Label_ExtractArchive.Caption := 'Extract archive';
    Label_ExtractArchive_Info.Caption := 'Opens an existing archive and extracts the files.';
    Label_ConvertToSFX.Caption := 'Convert to SFX';
    Label_ConvertToSFX_Info.Caption := 'Converts an existing archive into a self-extracting archive.';
    Button_About.Caption := 'About...';
    Button_Language.Caption := 'Language';
    Button_Exit1.Caption := 'Exit Program';

    Sheet_CreateArchive.Caption := 'Create Archive';
    Label_CreateArchive_Header.Caption := 'Create a new archive';
    Label_CreateArchive_Header.Caption := 'Create a new archive';
    Label_SelectFiles.Caption := 'Please choose the files you want to add to the archive!';
    Button_AddFile.Caption := 'Add file(s)';
    Button_AddFolder.Caption := 'Add folder';
    Button_Remove.Caption := 'Remove file';
    Button_Clear.Caption := 'Clear all';
    Button_Create1.Caption := 'Create archive';
    Button_Options.Caption := 'Options...';
    Button_Back1.Caption := 'Back to main menu';
    Dialog_AddFile.Title := 'Add file(s)';
    Dialog_AddFile.Filter := 'All files (*.*)|*.*';
    Dialog_AddFolder.Title := 'Choose the folder you want to add!';
    Dialog_CreateArchive.Title := 'Create archive';
    Dialog_CreateArchive.Filter := 'UHARC archive (*.uha)|*.uha';

    Sheet_CreateOptions.Caption := 'Create Options';
    Label_CreateOptions_Header.Caption := 'Create archive options';
    Label_CompressionOptions.Caption := 'Compression settings:';
    Label_FileOptions.Caption := 'Directory processing settings:';
    Button_Create2.Caption := 'Create archive';
    Button_Files.Caption := 'Edit files...';
    Button_Back2.Caption := 'Back to main menu';
    Label_CompressionMode.Caption := 'Compression mode:';
    Label_DictionarySize.Caption := 'Dictionary size:';
    Label_MultimediaCompression.Caption := 'Multimedia Compresion:';
    with ComboBox_CompressionMode do begin
      Items[1] := 'ALZ (High)';
      Items[2] := 'ALZ (Normal)';
      Items[3] := 'ALZ (Fast)';
      Items[5] := 'Simple RLE';
      Items[7] := 'Uncompressed';
      ItemIndex := 2;
    end;
    with ComboBox_MultimediaCompression do begin
      Items[0] := 'Enabled';
      Items[1] := 'Disabled';
      ItemIndex := 0;
    end;
    Label_RecurseSubdirs.Caption := 'Recurse Subdirectories:';
    with ComboBox_RecurseSubdirs do begin
      Items[0] := 'Disabled';
      Items[1] := 'Only none-empty';
      Items[2] := 'Always';
      ItemIndex := 0;
    end;
    Label_StorePaths.Caption := 'Store Paths:';
    with ComboBox_StorePaths do begin
      Items[0] := 'Discard';
      Items[1] := 'Relative';
      Items[2] := 'Full';
      Items[3] := 'Including driver-letter';
      ItemIndex := 1;
    end;
    Label_SecurityOptions.Caption := 'Encryption Settings:';
    Label_EnterPassword1.Caption := 'Enter Password:';
    Label_EnterPassword2.Caption := 'Re-enter Password:';
    Label_EncryptionMode.Caption := 'Encryption mode:';
    with ComboBox_Encryption do begin
      Items[0] := 'Files only';
      Items[1] := 'Files and header';
      ItemIndex := 0;
    end;

    Sheet_Working.Caption := 'Working...';
    Button_Abort.Caption := 'Abort!';
    PopupItem_CopyToClipboard.Caption := 'Copy to clipboard';
    Button_Exit2.Caption := 'Exit Program';
    Button_Back3.Caption := 'Back to main menu';

    Sheet_About.Caption := 'About';
    Label_About_Header.Caption := 'About UHARC/GUI';
    Label_AboutUharcGui.Caption := 'UHARC/GUI front-end was developed by MuldeR';
    Label_Warrenty.Caption := 'This software is provided ''as-is'', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software. Use it at your own risk!';
    Label_AboutUharc.Caption := 'The UHARC archiver was developed by Uwe Herklotz';
    Label_UharcLicense.Caption := 'This software is freeware for *non-commercial* use. The current beta version is mainly intended for testing and evaluation!';
    Button_Back4.Caption := 'Back to main menu';

    Sheet_Language.Caption := 'Language';
    Label_LanguageHeader.Caption := 'Language Selection';
    Label_LanguageInfo.Caption := 'Please choose one of the following languages:';
    Button_Back5.Caption := 'Back to main menu';

    Sheet_ExtractArchive.Caption := 'Extract Archive';
    Label_ExtractArchiveHeader.Caption := 'Extract existing archive';
    Button_Back6.Caption := 'Back to main menu';
    Label_OpenArchive.Caption := 'Choose the archive you want to extract:';
    Button_OpenArchive.Caption := 'Open archive';
    Label_ReadingArchive.Caption := 'Reading archive content, please wait...';
    Dialog_OpenArchive.Title := 'Open archive';
    Dialog_OpenArchive.Filter := 'UHARC archive (*.uha)|*.uha';
    List_ExtractFiles.Columns[0].Caption := 'File name';
    List_ExtractFiles.Columns[1].Caption := 'Size (KB)';
    PopupItem_CopyToClipboard2.Caption := 'Copy to clipboard';
    Button_Extract.Caption := 'Extract files';
    Button_Verify.Caption := 'Verify files';
    Dialog_ExtractFiles.Title := 'Choose folder to extract files to:';
  end;
end;

end.
