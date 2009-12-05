object OptionsForm: TOptionsForm
  Left = 540
  Top = 318
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'OptionsForm'
  ClientHeight = 287
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010020000000000B00000001600000028000000100000002000
    0000010001000000000080000000000000000000000000000000000000000000
    0000FFFFFF000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000E7FF0000E3FF0000F3FF000033FF000003FF000081FF0000F8FF
    0000FC7F0000FE3F0000FF1F0000FF810000FFC00000FFCC0000FFCF0000FFC7
    0000FFE70000}
  OldCreateOrder = False
  Position = poMainFormCenter
  ScreenSnap = True
  SnapBuffer = 15
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    323
    287)
  PixelsPerInch = 96
  TextHeight = 13
  object LAudioOut: TTntLabel
    Left = 4
    Top = 7
    Width = 62
    Height = 13
    Caption = 'Audio output'
  end
  object LPostproc: TTntLabel
    Left = 4
    Top = 55
    Width = 72
    Height = 13
    Caption = 'Postprocessing'
  end
  object LAspect: TTntLabel
    Left = 4
    Top = 79
    Width = 58
    Height = 13
    Caption = 'Aspect ratio'
  end
  object LDeinterlace: TTntLabel
    Left = 4
    Top = 103
    Width = 54
    Height = 13
    Caption = 'Deinterlace'
  end
  object LParams: TTntLabel
    Left = 4
    Top = 214
    Width = 55
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Parameters'
  end
  object LHelp: TTntLabel
    Left = 297
    Top = 214
    Width = 21
    Height = 13
    Cursor = crHandPoint
    Alignment = taRightJustify
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Help'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = LHelpClick
  end
  object LLanguage: TTntLabel
    Left = 4
    Top = 127
    Width = 47
    Height = 13
    Caption = 'Language'
  end
  object LAudioDev: TTntLabel
    Left = 4
    Top = 31
    Width = 61
    Height = 13
    Caption = 'Audio device'
  end
  object BOK: TTntButton
    Left = 4
    Top = 258
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = BOKClick
  end
  object BApply: TTntButton
    Left = 84
    Top = 258
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Apply'
    TabOrder = 1
    OnClick = BApplyClick
  end
  object BSave: TTntButton
    Left = 164
    Top = 258
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Save'
    TabOrder = 2
    OnClick = BSaveClick
  end
  object BClose: TTntButton
    Left = 244
    Top = 258
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Close'
    TabOrder = 3
    OnClick = BCloseClick
  end
  object CAudioOut: TTntComboBox
    Left = 174
    Top = 4
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
    OnChange = CAudioOutChange
    Items.Strings = (
      'don'#39't decode'
      'dont'#39'play'
      'Win32'
      'DirectSound')
  end
  object CPostproc: TTntComboBox
    Left = 174
    Top = 52
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 5
    OnChange = SomethingChanged
    Items.Strings = (
      'off'
      'auto'
      'max')
  end
  object CAspect: TTntComboBox
    Left = 174
    Top = 76
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
    OnChange = SomethingChanged
    Items.Strings = (
      'auto'
      '4:3'
      '16:9'
      '2.35:1')
  end
  object CDeinterlace: TTntComboBox
    Left = 174
    Top = 100
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 7
    OnChange = SomethingChanged
    Items.Strings = (
      'off'
      'simple'
      'adaptive')
  end
  object CIndex: TTntCheckBox
    Left = 4
    Top = 150
    Width = 317
    Height = 17
    Caption = 'Re-Index'
    TabOrder = 8
    OnClick = SomethingChanged
  end
  object EParams: TTntEdit
    Left = 4
    Top = 229
    Width = 315
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 9
    OnChange = SomethingChanged
  end
  object CLanguage: TTntComboBox
    Left = 174
    Top = 124
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 10
    OnChange = CLanguageChange
    Items.Strings = (
      'auto'
      'file')
  end
  object CAudioDev: TTntComboBox
    Left = 174
    Top = 28
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 11
    OnChange = SomethingChanged
  end
  object CSoftVol: TTntCheckBox
    Left = 4
    Top = 170
    Width = 317
    Height = 17
    Caption = 'Software volume control'
    TabOrder = 12
    OnClick = SomethingChanged
  end
  object CPriorityBoost: TTntCheckBox
    Left = 4
    Top = 190
    Width = 317
    Height = 17
    Caption = 'Priority boost'
    TabOrder = 13
    OnClick = SomethingChanged
  end
  object OpenLocale: TOpenDialog
    DefaultExt = '.locale.txt'
    Filter = 
      'MPUI locale files (*.locale.txt)|*.locale.txt|All files (*.*)|*.' +
      '*'
    InitialDir = '.'
    Options = [ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Open external locale file'
    Left = 144
    Top = 120
  end
end
