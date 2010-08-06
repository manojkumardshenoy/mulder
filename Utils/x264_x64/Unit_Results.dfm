object Form_Results: TForm_Results
  Left = 577
  Top = 326
  Width = 848
  Height = 384
  BorderStyle = bsSizeToolWin
  Caption = 'Form_Results'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo_Result: TMemo
    Left = 0
    Top = 0
    Width = 832
    Height = 346
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Memo_Result')
    ParentFont = False
    PopupMenu = PopupMenu1
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object PopupMenu1: TPopupMenu
    Left = 8
    Top = 32
    object CopytoClipboard1: TMenuItem
      Caption = 'Copy to Clipboard'
      Default = True
      OnClick = CopytoClipboard1Click
    end
  end
end
