object InfoForm: TInfoForm
  Left = 565
  Top = 235
  ActiveControl = BClose
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'InfoForm'
  ClientHeight = 296
  ClientWidth = 300
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
    000000000000FFFF0000F81F0000F00F0000E3C70000C1830000C18300008181
    0000818100008181000083810000C0030000C1830000E1870000F00F0000FC3F
    0000FFFF0000}
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    300
    296)
  PixelsPerInch = 96
  TextHeight = 13
  object InfoBox: TTntListBox
    Left = 4
    Top = 4
    Width = 292
    Height = 258
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 16
    TabOrder = 0
    OnDrawItem = InfoBoxDrawItem
  end
  object BClose: TTntButton
    Left = 221
    Top = 267
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    Default = True
    TabOrder = 1
    OnClick = BCloseClick
  end
end
