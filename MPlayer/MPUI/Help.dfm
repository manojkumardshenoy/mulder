object HelpForm: THelpForm
  Left = 191
  Top = 430
  ActiveControl = BClose
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'HelpForm'
  ClientHeight = 85
  ClientWidth = 310
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Icon.Data = {
    0000010001001010020000000000B00000001600000028000000100000002000
    0000010001000000000080000000000000000000000000000000000000000000
    0000FFFFFF000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000FFFF0000FFFF0000FE7F0000FE7F0000FFFF0000FE7F0000FE7F
    0000FE7F0000FF3F0000FF9F0000FF9F0000F99F0000F81F0000FC3F0000FFFF
    0000FFFF0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    310
    85)
  PixelsPerInch = 96
  TextHeight = 13
  object RefLabel: TTntLabel
    Left = 0
    Top = 64
    Width = 3
    Height = 13
  end
  object HelpText: TTntMemo
    Left = 4
    Top = 4
    Width = 303
    Height = 45
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object BClose: TTntButton
    Left = 230
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BClose'
    ModalResult = 1
    TabOrder = 1
    OnClick = BCloseClick
  end
end
