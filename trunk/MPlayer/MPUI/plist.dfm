object PlaylistForm: TPlaylistForm
  Left = 582
  Top = 253
  Width = 384
  Height = 293
  BorderIcons = [biSystemMenu]
  Caption = 'PlaylistForm'
  Color = clBtnFace
  Constraints.MinHeight = 293
  Constraints.MinWidth = 384
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
    000000000000FFFF0000FFFF0000F7EF0000E2070000F7EF0000FFFF0000F7EF
    0000E2070000F7EF0000FFFF0000F7EF0000E2070000F7EF0000FFFF0000FFFF
    0000FFFF0000}
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefaultPosOnly
  ScreenSnap = True
  SnapBuffer = 15
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  DesignSize = (
    376
    261)
  PixelsPerInch = 96
  TextHeight = 13
  object PlaylistBox: TTntListBox
    Left = 4
    Top = 4
    Width = 272
    Height = 253
    Style = lbVirtualOwnerDraw
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 16
    MultiSelect = True
    TabOrder = 0
    OnDblClick = BPlayClick
    OnDrawItem = PlaylistBoxDrawItem
  end
  object BPlay: TTntBitBtn
    Left = 283
    Top = 4
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Play'
    TabOrder = 1
    OnClick = BPlayClick
  end
  object BAdd: TTntBitBtn
    Left = 283
    Top = 36
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Add'
    TabOrder = 2
    OnClick = BAddClick
  end
  object BMoveUp: TTntBitBtn
    Tag = 1
    Left = 283
    Top = 68
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Move up'
    TabOrder = 3
    OnClick = BMoveClick
  end
  object BMoveDown: TTntBitBtn
    Left = 283
    Top = 96
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Move down'
    TabOrder = 4
    OnClick = BMoveClick
  end
  object BDelete: TTntBitBtn
    Left = 283
    Top = 128
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Delete'
    TabOrder = 5
    OnClick = BDeleteClick
  end
  object BClose: TTntBitBtn
    Left = 283
    Top = 232
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 6
    OnClick = BCloseClick
  end
  object CShuffle: TTntCheckBox
    Left = 283
    Top = 160
    Width = 87
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Shuffle'
    TabOrder = 7
    OnClick = CShuffleClick
  end
  object CLoop: TTntCheckBox
    Left = 283
    Top = 180
    Width = 87
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Repeat'
    TabOrder = 8
    OnClick = CLoopClick
  end
  object BSave: TTntBitBtn
    Left = 283
    Top = 201
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save'
    TabOrder = 9
    OnClick = BSaveClick
  end
  object SavePlaylistDialog: TTntSaveDialog
    DefaultExt = 'm3u'
    Filter = 'M3U Playlist (*.m3u)|*.m3u|PLS Playlist (*.pls)|*.pls'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Save Playlist ...'
    Left = 336
    Top = 200
  end
end
