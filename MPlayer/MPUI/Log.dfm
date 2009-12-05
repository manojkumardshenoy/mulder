object LogForm: TLogForm
  Left = 708
  Top = 118
  Width = 550
  Height = 440
  ActiveControl = Command
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'LogForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010020000000000B00000001600000028000000100000002000
    0000010001000000000080000000000000000000000000000000000000000000
    0000FFFFFF000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000FFFF000083070000FFFF000080090000FFFF000080070000FFFF
    00009FFF0000FFFF0000830F0000FFFF000080030000FFFF000080070000FFFF
    0000FFFF0000}
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TheLog: TTntMemo
    Left = 0
    Top = 0
    Width = 542
    Height = 383
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object ControlPanel: TTntPanel
    Left = 0
    Top = 383
    Width = 542
    Height = 25
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      542
      25)
    object BClose: TTntButton
      Left = 480
      Top = 4
      Width = 62
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Close'
      TabOrder = 0
      OnClick = BCloseClick
    end
    object Command: TTntEdit
      Left = 0
      Top = 4
      Width = 477
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnKeyDown = CommandKeyDown
      OnKeyPress = CommandKeyPress
    end
  end
end
