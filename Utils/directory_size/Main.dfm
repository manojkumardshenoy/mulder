object FormMain: TFormMain
  Left = 397
  Top = 204
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Directory Size Calculator'
  ClientHeight = 636
  ClientWidth = 577
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 512
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    577
    636)
  PixelsPerInch = 96
  TextHeight = 13
  object Button_Start: TButton
    Left = 8
    Top = 600
    Width = 169
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Create Directory Tree'
    TabOrder = 0
    OnClick = Button_StartClick
  end
  object TreeView1: TTreeView
    Left = 8
    Top = 34
    Width = 561
    Height = 288
    Anchors = [akLeft, akTop, akRight, akBottom]
    Images = ImageList1
    Indent = 19
    PopupMenu = PopupMenu1
    ReadOnly = True
    TabOrder = 1
    OnChange = TreeView1Change
  end
  object ListView1: TListView
    Left = 8
    Top = 328
    Width = 561
    Height = 257
    Anchors = [akLeft, akRight, akBottom]
    Columns = <
      item
        Width = 150
      end>
    ColumnClick = False
    LargeImages = ImageList1
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu2
    ShowColumnHeaders = False
    SmallImages = ImageList1
    TabOrder = 2
    ViewStyle = vsReport
    OnDblClick = ListView1DblClick
  end
  object Panel1: TPanel
    Left = 192
    Top = 40
    Width = 369
    Height = 57
    Caption = 'Work in progress, please be patient...'
    TabOrder = 3
    Visible = False
    object Bevel1: TBevel
      Left = 8
      Top = 8
      Width = 353
      Height = 42
      Shape = bsFrame
    end
  end
  object Edit_Status: TEdit
    Left = 8
    Top = 8
    Width = 561
    Height = 21
    Cursor = crArrow
    Anchors = [akLeft, akTop, akRight]
    Color = clBtnFace
    PopupMenu = PopupMenu1
    ReadOnly = True
    TabOrder = 4
    Text = 
      'Welcome! Please click '#39'Create Directory Tree'#39' in order to begin.' +
      '..'
    OnEnter = Edit_StatusEnter
  end
  object Button_Exit: TButton
    Left = 472
    Top = 600
    Width = 97
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 5
    OnClick = Button_ExitClick
  end
  object Button_About: TButton
    Left = 360
    Top = 600
    Width = 97
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'About...'
    TabOrder = 6
    OnClick = Button_AboutClick
  end
  object Button_Refresh: TBitBtn
    Left = 184
    Top = 600
    Width = 33
    Height = 25
    Hint = 'Refresh'
    Anchors = [akLeft, akBottom]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    OnClick = Button_RefreshClick
    Glyph.Data = {
      A2050000424DA2050000000000001A0300000C0000002400120001000800FF00
      FF5252528585859595958383838E8E8E0CC6690CCC6C0DCE6E74747494949499
      99999B9B9B0BC2670CC86A0DD4710EDA740FE37A929292979797A0A0A0A5A5A5
      ACACAC0FE0780FE67BAAAAAAAEAEAE0EDC750FE27910E87C8C8C8C797979A6A6
      A6ABABABAFAFAF0FE17810E77C10ED7FB3B3B37B7B7B86868693939396969600
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000100000000000101010100000000000000000902000000020304040302
      000000000000000101000001010808070601010000000000000905020205090C
      0C0B0A090502000000000001110101100F0F08080E0D0D010000000000091609
      091514140C0C1312120500000000000118171710100F0F010101010100000000
      00091A19191515141409090909090200000000011D1C1C1B1B01010000000001
      010000000009222121202009051E1F1F1E050900000000012424232301000000
      0000000001000000000922221919090200000000000205000000000125242423
      2301000000000000000000000009262222191905020000000000000000000001
      01010101010101000000000000000000002A2905282709090900000000000000
      0000000000000000000000010101010101010100000000000000000000090909
      272805292A000000000000000000000001232324242501000000000000000000
      0002051919222226090000000001000000000000000123232424010000000005
      020000000000020919192222090000000001010000000001011B1B1C1C1D0100
      00000005091E1F1F1E0509202021212209000000000001010101010F0F101017
      171801000000000209090909091414151519191A090000000000010D0D0E0808
      0F0F10010111010000000000051212130C0C1414150909160900000000000001
      010607070801010000010100000000000205090A0B0B0C090502020509000000
      0000000000010101010000000000010000000000000002030404030200000002
      0500000000000000000000000000000000000000000000000000000000000000
      000000000000}
    NumGlyphs = 2
  end
  object Panel2: TPanel
    Left = 16
    Top = 376
    Width = 121
    Height = 25
    Cursor = crVSplit
    BevelOuter = bvNone
    TabOrder = 8
    OnMouseDown = Panel2MouseDown
    OnMouseMove = Panel2MouseMove
  end
  object ImageList1: TImageList
    Left = 16
    Top = 40
    Bitmap = {
      494C010108000900040010001000FFFFFFFFFF00FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E7E1DF00A9A6
      A6006A68680095929200785E5E00785E5E00785E5E00785E5E00785E5E00785E
      5E00785E5E00DBD7D700A09E9D008A8888000000000000000000000000000000
      0000000000000000000000000000000000000000000099333300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000EBE5E4008B75E4002900
      DF003C26A300615F5F00C1BEBD00FFDCB900FFDCB900FFDCB900FFDCB900FFDC
      B900CDC9C8005E4CAD002D07D800A09E9D000000000000000000000000000000
      0000000000000000000000000000000000009966330099333300000000000000
      000000000000000000000000000000000000000000000000000000000000D1DE
      D6006A8E6D001F632300015F050003650800036A0A002F7C330095BD9A000000
      0000000000000000000000000000000000000000000000000000010101000101
      0100010101000101010001010100010101000101010001010100010101000101
      010001010100010101000101010000000000E6E0DD00D2CAC800B4A5EA002900
      DF003009DA004F4A64007A787800D4D1D000FFFFFF00FFFFFF00FFFFFF00BFBA
      C6004327C0002900DF007865C700000000000000000000000000000000000000
      0000000000000000000000000000CC663300CC996600CC663300000000000000
      000000000000000000000000000000000000000000000000000095B09A001065
      14000191080002AE0C0007B017000AB21D000EB4260012B630000D982300308A
      3500C2DBC8000000000000000000000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000101010000000000A3A3A300A3A3A300A3A3A300826A
      E6002900DF003B1ACF005B5A59008E8C8B00D8D5D400FFE3B000BFBAC6003817
      CC002D07D8009D93BC00C4BBB700000000000000000000000000000000000000
      00000000000099663300CC660000CC660000FFECCC00CC663300993333000000
      0000000000000000000000000000000000000000000095B09A000168060001AD
      0A0005AF120009B21C001BB72E003DC3530013B6310018B83B001CBA45001DB6
      4600178B2300D1E5D60000000000000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0038383800313131003131310031313100FEFE
      FE00FEFEFE00FEFEFE000101010000000000A3A3A300F2E2D200FFE6CD007272
      7200755BE5002900DF004F35BF00605F5E008C8A8900AFAAB6003817CC002D07
      D8009D93BC00634F4500C4BBB70000000000000000000000000000000000CC66
      0000CC660000CC996600F0CAA600FFECCC00FFECCC00FFECCC00CC9966009933
      000099330000000000000000000000000000D1DED6001069140003AE0E0008B1
      19000BB21E000FB42700B5E8BE00FFFFFF0070D388001DBA460022BD520025BE
      590024B7540040A2460000000000000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00414141004B4B4B00444444002D2D2D00FDFDFD00FFFF
      FF00FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFE00FFFFFF007272
      7200FFFFFE00755BE5002900DF004E34BF004F4C58003211C6002C06D6009D93
      BC00785E5E00634F4500C4BBB700000000000000000000000000CC660000CC99
      6600FFECCC00FFECCC00CCCC9900F0CAA600FFECCC00FFECCC00FFECCC00FFEC
      CC00CC6633009933000000000000000000005B895E00069713000AB21D000CB3
      220012B62F0014B632009AE0AB00FFFFFF00FFFFFF0077D6950026BF5B002DC1
      67002FC26C0018A43800B3DBB900000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF004C4C4C005C5C5C00515151002F2F2F00FDFDFD00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFE00FFE3B0007272
      7200FFFFFE00FFFFFF00745AE3002900DF002C06D6002B05D500665D8500D1CE
      CD00785E5E00634F4500C4BBB7000000000000000000CC660000FF996600FFEC
      CC00F1F1F100F1F1F100CC660000CC663300CCCC9900FFECCC00FFECCC00FFEC
      CC00FFECCC00CC6633009933000000000000217927000BB21E0010B52B0013B6
      310016B839001BBA44001DBB4800ACE6BF00FFFFFF00FFFFFF007DD9A1002FC2
      6C002FC26C0029BB5F006ABD6D00000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF005C5C5C006F6F6F005656560032323200FEFEFE00FEFEFE003535
      3500FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFE00FFFFFF007272
      7200FFFFFE00FFE3B000BFBAC6002E08D9002900DF004529C0006F6E6D008B89
      8800CDC9C800634F4500C4BBB70000000000CC996600CC993300FFECCC00F1F1
      F100F1F1F100F1F1F100CC993300CC660000FFECCC00FFECCC00FFECCC00FFEC
      CC00FFECCC00F0CAA60099330000996666000678110012B6300015B735008BDC
      9D008DDDA2008EDDA30092DFAC0092DFAC00F1FBF500FFFFFF00FFFFFF007DD9
      A3002FC26C002FC26C003DAF3F00000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF0068686800838383006868680035353500FFFFFF00404040003535
      3500FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFE00FFE3B0007272
      7200FFFFFE00BFBAC6003817CC002D07D8006C57C600340EDE00573AD1007773
      8100807E7D00BBB8B800C4BBB70000000000FF990000FFCC6600F1F1F100F1F1
      F100F1F1F100F1F1F100F0CAA600CC660000F0CAA600FFECCC00FFECCC00FFEC
      CC00FFECCC00FFECCC00CC663300993300000B8D1C0018B83B001CBA4500FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0049CA7F002FC26C003DB53F00000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF00727272009A9A9A008080800068686800353535005E5E5E003232
      3200FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFE00FFFFFF007272
      7200BFBAC6003817CC002900DF008579B000FFE3B000CEC4EC00421DE0004726
      DB00756C950077757500ACA9A80000000000FF990000FFCC9900F1F1F100F8F8
      F800F8F8F800F8F8F800F1F1F100CC660000CC996600FFECCC00FFECCC00FFEC
      CC00FFECCC00FFECCC00CC66330099330000088014001DBA460022BD520092DF
      AC0095E0B10097E1B50097E1B500A4E4BE00FFFFFF00FFFFFF00FFFFFF007DD9
      A3002FC26C0034C36F003DB83F00000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000A2A2A2008484840065656500595959003030
      3000FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFE00FFE3B000B4AF
      BC003716CB002900DF006E5EB000FFFFFF00FFFFFF00E7B98800D1995C005B3C
      E300330DDD007768AD0084818100D2CFCE00FF990000FFCC6600F1F1F100F8F8
      F800FFFFFF00F8F8F800FFECCC00CC993300CC663300F1F1F100FFECCC00FFEC
      CC00FFECCC00FFECCC00CC663300CC66000031953A0024BE580026BF5B002DC1
      67002FC26C002FC26C003CC67500D8F4E300FFFFFF00FFFFFF007DD9A3002FC2
      6C0040C7770045C6660078D27B00000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF007D7D7D009B9B9B0073737300676767003232
      3200FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFE00BEB4DC003716
      CB002900DF005742B100DAD7D600FFFFFE00FFFFFE00E7B98800D1995C00BA72
      0D008E78E7002900DF00C7BFDA0000000000CC996600FF993300F1F1F100FFFF
      FF00FFFFFF00FFFFFF00F8F8F800F1F1F100FFECCC00FFECCC00FFECCC00FFEC
      CC00FFECCC00F0CAA600CC6600009966660086BE8A001BA73F002EC26B002FC2
      6C002FC26C002FC26C00A4E4BE00FFFFFF00FFFFFF007DD9A30036C4710053CC
      820073D5950032BE3D00D1ECD600000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF00FFFFFF005F5F5F0092929200969696008D8D8D007E7E7E003B3B
      3B00FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFE00401BDD002900
      DF004327C000CDC9C80072727200727272007272720072727200BA720D006C58
      5000BCB1AD00DCD6D300ECE8E7000000000000000000FF990000FFCC6600F8F8
      F800FFFFFF00F8F8F800F8F8F800F0CAA600FF990000F0CAA600FFECCC00FFEC
      CC00FFECCC00CC663300CC6600000000000000000000229528002CBF65002FC2
      6C002FC26C002FC26C0089DDAC00F2FBF60080DAA40045C87A0067D28E0082DA
      A00076D683006AD26C0000000000000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF005959590064646400616161005D5D5D00575757004C4C4C004040
      4000FFFFFF00FFFFFF000101010000000000A3A3A300FEFEFE00350FE0004B2A
      DE00D6D1DE00FFFCF900E7B98800D1995C00D1995C00BA720D006C585000BCB1
      AD00DBD5D200ECE8E700F3EFEE00000000000000000000000000FF990000FFCC
      6600F1F1F100F8F8F800F8F8F800FFECCC00FFCC6600FFECCC00FFECCC00F0CA
      A600CC993300CC660000000000000000000000000000C1E0C600189E250029BD
      5F002FC26C002FC26C002FC26C003BC574005BCE860077D7980098E0AD0078D7
      81003AC73C000000000000000000000000000000000001010100FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000101010000000000A3A3A300FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00E7B98800D1995C00BA720D0069564C00BAB0AB00DBD5
      D200ECE8E700F3EFEE000000000000000000000000000000000000000000FF99
      0000FF990000FFCC6600FFCC9900FFCC9900FFCC9900FFCC6600FF993300CC66
      0000CC6633000000000000000000000000000000000000000000C2E3C70040B2
      450018B137002EBF62004FCB80006BD391008CDCA60084DA910048CB4A006AD3
      6C00000000000000000000000000000000000000000000000000010101000101
      0100010101000101010001010100010101000101010001010100010101000101
      010001010100010101000101010000000000A3A3A300A3A3A300A3A3A300A3A3
      A300A3A3A300A3A3A300A3A3A300BA720D0057423700AFA39D00D7D1CD00ECE8
      E700F3EFEE000000000000000000000000000000000000000000000000000000
      000000000000CC993300FF993300FF990000FF990000FF993300CC9933000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000B3E1B8006AC96D003DBF3E003DC03E003DC63E0078D77B00D1EDD6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000E9E9E900B4B4B4007676
      76004E4E4E0040404000424242005656560082828200C6C6C600F1F1F1000000
      00000000000000000000000000000000000000000000F5F5F5FFDEDEDEFFD5D5
      D5FFD5D5D5FFD5D5D5FFD5D5D5FFD5D5D5FFD5D5D5FFD5D5D5FFD5D5D5FFD5D5
      D5FFD5D5D5FFD5D5D5FFDEDEDEFFF5F5F5FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F0EE
      EDFF727272FF785E5EFF785E5EFF785E5EFF785E5EFF785E5EFF785E5EFF785E
      5EFF785E5EFF785E5EFF665349FFCBC5C2FFEFEFEF00AAA0A000A3949400C1AE
      AE00C8B0B000C6A9A900B3949400876C6C00534D4D006C6C6C00C6C6C600F4F4
      F400F4F4F400000000000000000000000000F5F5F5FFC7C7C7FF828282FF6B6B
      6BFF6B6B6BFF6B6B6BFF6B6B6BFF6B6B6BFF6B6B6BFF6B6B6BFF6B6B6BFF6B6B
      6BFF6B6B6BFF6B6B6BFF828282FFC7C7C7FF00000000F4F4F4FFDCDCDCFFD0D0
      D0FFD0D0D0FFD0D0D0FFD0D0D0FFD0D0D0FFD0D0D0FFD0D0D0FFD0D0D0FFD0D0
      D0FFD0D0D0FFDCDCDCFFF4F4F4FF000000000000000000000000F4F2F2FFE6E4
      E2FF727272FFFFDCB9FFFFDCB9FFFFDCB9FFFFDCB9FFFFDCB9FFFFDCB9FFFFDC
      B9FFFFDCB9FF785E5EFF665349FFCBC5C2FFD6CCCC00DCD8D800E2E2E200DEDC
      DC00DAD2D200CBB2B200AE989800B68F8F00B88E8E005E545400A0A0A000D7D7
      D700CFCFCF00E0E0E000F1F1F10000000000DEDEDEFF1C82B5FF1A80B3FF177D
      B0FF157BAEFF1278ABFF0F75A8FF0C72A5FF0A70A3FF076DA0FF056B9EFF0369
      9CFF01679AFF006699FF4B4B4BFF828282FFF4F4F4FFC4C4C4FF888888FF7070
      70FF707070FF707070FF707070FF707070FF707070FF707070FF707070FF7070
      70FF707070FF888888FFC4C4C4FFF4F4F4FF00000000EFEDEBFFDAD6D4FFC6C0
      BCFF727272FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFDCB9FF785E5EFF665349FFCBC5C2FFCDB7B700EDEDED00F1F1F100E8E8
      E800DDD9D900D6BFBF00A58D8D00A8878700CFA5A50081686800737373007F76
      76005A5A5A0071717100AFAFAF00E0E0E0002187BAFF66CCFFFF1F85B8FF99FF
      FFFF6ED4FFFF6ED4FFFF6ED4FFFF6ED4FFFF6ED4FFFF6ED4FFFF6ED4FFFF6ED4
      FFFF3AA0D3FF99FFFFFF006699FF6C6C6CFFDCDCDCFF0C72A5FF0C72A5FF0C72
      A5FF0C72A5FF0C72A5FF0C72A5FF0C72A5FF0C72A5FF0C72A5FF0C72A5FF0C72
      A5FF0C72A5FF646464FF888888FFDCDCDCFF00000000A3A3A3FFA3A3A3FFA3A3
      A3FF727272FFFFFFFEFFFFE3B0FFFFE3B0FFFFE3B0FFFFE3B0FFFFE3B0FFFFE3
      B0FFFFDCB9FF785E5EFF665349FFCBC5C2FFDECFCF00F2F2F200F0E2E200ECEC
      EC00D5C5C500D4B2B200B47F7F00BC858500CEA4A40090737300A98C8C00BEAA
      AA009D909000615858005454540073737300248ABDFF66CCFFFF268CBFFF99FF
      FFFF7AE0FFFF7AE0FFFF7AE0FFFF7AE0FFFF7AE0FFFF7AE0FFFF7AE0FFFF7AE0
      FFFF43A9DCFF99FFFFFF01679AFF6B6B6BFF189AC6FF1B9CC7FF9CFFFFFF6BD7
      FFFF6BD7FFFF6BD7FFFF6BD7FFFF6BD7FFFF6BD7FFFF6BD7FFFF6BD7FFFF6BD7
      FFFF2899BFFF0C72A5FF707070FFD0D0D0FF00000000A3A3A3FFF2E2D2FFFFE6
      CDFF727272FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFDCB9FF785E5EFF665349FFCBC5C2FFF5F2F200DCC7C700D6ABAB00DCB9
      B900CEA2A200CA8C8C00C3707000C97E7E00D4B1B100DCC1C100D9B9B900BD9D
      9D00AD9E9E00AEA2A2008A837D0045454500278DC0FF66CCFFFF2C92C5FF99FF
      FFFF85EBFFFF85EBFFFF85EBFFFF85EBFFFF85EBFFFF85EBFFFF85EBFFFF85EB
      FFFF4DB3E6FF99FFFFFF03699CFF6B6B6BFF189AC6FF199AC6FF79E4F0FF9CFF
      FFFF7BE3FFFF7BE3FFFF7BE3FFFF7BE3FFFF7BE3FFFF7BE3FFFF7BE3FFFF7BDF
      FFFF42B2DEFF197A9DFF646464FFB8B8B8FF00000000A3A3A3FFFFFFFEFFFFFF
      FFFF727272FFFFFFFEFFFFE3B0FFFFE3B0FFFFE3B0FFFFE3B0FFFFE3B0FFFFE3
      B0FFFFDCB9FF785E5EFF665349FFCBC5C2FF00000000DAC6C600F0A34300FDBA
      5400F0C08E00C9939D00C96E6E00C5757500DCC0C000D2A8A800CE9F9F00BC93
      93009E717100A58181009EB096003F3F3F00298FC2FF66CCFFFF3298CBFF99FF
      FFFF91F7FFFF91F7FFFF91F7FFFF91F7FFFF91F7FFFF91F7FFFF91F7FFFF91F7
      FFFF56BCEFFF99FFFFFF056B9EFF6B6B6BFF189AC6FF25A2CFFF3FB8D7FF9CFF
      FFFF84EBFFFF84EBFFFF84EBFFFF84EBFFFF84EBFFFF84EBFFFF84EBFFFF84E7
      FFFF42BAEFFF189AC6FF646464FF888888FF00000000A3A3A3FFFFFFFEFFFFE3
      B0FF727272FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFDCB9FF785E5EFF665349FFCBC5C2FF00000000D6BABA00F3AA4100FFB3
      3500815B69008E696D00F1BC7800D7978700CC898900D6AEAE00D9B9B900BF98
      9800AE808000A77878009E6F6F003F3F3F002C92C5FF6ED4FFFF3399CCFF99FF
      FFFF99FFFFFF99FFFFFF99FFFFFF99FFFFFF99FFFFFF99FFFFFF99FFFFFF99FF
      FFFF5FC5F8FF99FFFFFF076DA0FF6C6C6CFF189AC6FF42B3E2FF20A0C9FFA5FF
      FFFF94F7FFFF94F7FFFF94F7FFFF94F7FFFF94F7FFFF94F7FFFF94F7FFFF94F7
      FFFF52BEE7FF5BBCCEFF0C72A5FF707070FF00000000A3A3A3FFFFFFFEFFFFFF
      FFFF727272FFFFFFFEFFFFE3B0FFFFE3B0FFFFE3B0FFFFE3B0FFFFE3B0FFFFE3
      B0FFFFDCB9FF785E5EFF665349FFCBC5C2FF00000000CFB1B100FFBA43009F77
      680031268D00513D8200FFC05000FFBD4900F3B25900D58C7E00D9B9B900C096
      9600C6939300CC999900B38282003F3F3F002E94C7FF7AE0FFFF2C92C5FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF80E6FFFFFFFFFFFF0A70A3FF8B8B8BFF189AC6FF6FD5FDFF189AC6FF89F0
      F7FF9CFFFFFF9CFFFFFF9CFFFFFF9CFFFFFF9CFFFFFF9CFFFFFF9CFFFFFF9CFF
      FFFF5AC7FFFF96F9FBFF187A9BFF707070FF00000000A3A3A3FFFFFFFEFFFFE3
      B0FF727272FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFDCB9FF785E5EFF67544AFFCBC5C2FFEDEBEB00E0BEA900DFAC60003128
      9100EFC16D0031289100EFBF6A00FFC96000FFC25400D7947F00D9B9B900C194
      9400AC7A7A00AC7A7A00B27C7C003F3F3F003096C9FF85EBFFFF80E6FFFF2C92
      C5FF2C92C5FF2C92C5FF2C92C5FF2C92C5FF2C92C5FF278DC0FF2389BCFF1F85
      B8FF1B81B4FF1A80B3FF1A80B3FFDEDEDEFF189AC6FF84D7FFFF189AC6FF6BBF
      DAFFFFFFFFFFFFFFFFFFF7FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF84E7FFFFFFFFFFFF187DA1FF888888FF00000000A3A3A3FFFFFFFEFFFFFF
      FFFF727272FFFFFFFEFFFFE3B0FFFFE3B0FFFFE3B0FFFFE3B0FFE7B988FFE7B9
      88FFE7B988FF785E5EFF6A5850FFCFC9C6FFDCD4D400E6C5A500FFCF6D00FFD6
      7A00FFDA81008F7C8C009F878800FFD37600FFCD6800CF979700D9B9B900BD85
      8500BF8C8C00AF7D7D00B77C7C003F3F3F003298CBFF91F7FFFF8EF4FFFF8EF4
      FFFF8EF4FFFF8EF4FFFF8EF4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF157BAEFF8B8B8BFFDDDDDDFFFEFEFEFF189AC6FF84EBFFFF4FC1E2FF189A
      C6FF189AC6FF189AC6FF189AC6FF189AC6FF189AC6FF189AC6FF189AC6FF189A
      C6FF189AC6FF189AC6FF1889B1FFC4C4C4FF00000000A3A3A3FFFFFFFEFFFFE3
      B0FF727272FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE7B988FFD199
      5CFFD1995CFFBA720DFF7C6C64FFD8D3D1FFD8D1D100EACA9A00FFD87F00FFE0
      8E00FFE69900DFCA9B0051479600FFDE8900FBCF7A00CF9D9D00D9B9B900C684
      8400B6797900BC878700B8787800404040003399CCFFFFFFFFFF99FFFFFF99FF
      FFFF99FFFFFF99FFFFFFFFFFFFFF248ABDFF2187BAFF1E84B7FF1C82B5FF1A80
      B3FF177DB0FFDEDEDEFFF6F6F6FF00000000189AC6FF9CF3FFFF8CF3FFFF8CF3
      FFFF8CF3FFFF8CF3FFFF8CF3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF189AC6FF197A9DFFC4C4C4FFF4F4F4FF00000000A3A3A3FFFFFFFEFFFFFF
      FFFF727272FFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFE7B988FFD199
      5CFFBA720DFF705F56FFC5BEBAFFEAE7E6FFDBD5D500F7D79200FFE08E00FFEA
      A100FFF0AF00FFF2B200413E9F00DFC99A00EEC48400DAB9B900E9D8D800E5C0
      C000D99C9C00C86F6F00C26E6E005D5D5D00000000003399CCFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF298FC2FFC7C7C7FFF5F5F5FFFEFEFEFFFEFEFEFFFEFE
      FEFFFEFEFEFFFEFEFEFF0000000000000000189AC6FFFFFFFFFF9CFFFFFF9CFF
      FFFF9CFFFFFF9CFFFFFFFFFFFFFF189AC6FF189AC6FF189AC6FF189AC6FF189A
      C6FF189AC6FFDCDCDCFFF4F4F4FF0000000000000000A3A3A3FFFFFFFEFFFFE3
      B0FF727272FF727272FF727272FF727272FF727272FF727272FF727272FFBA72
      0DFF6F5C54FFC3BBB8FFE5E2E0FFF6F5F5FFDFDDDD00BCAC9600D6C09500E8D7
      A500FFFBC300FFFECA00BFBBB600AFA2A100E9C28A00E1C4C400EEDDDD00EEDD
      DD00EEDDDD00EAD7D700D19B9B00E0E0E00000000000000000003399CCFF3298
      CBFF3096C9FF2E94C7FFDEDEDEFFF5F5F5FF0000000000000000000000000000
      0000000000000000000000000000000000000000000021A2CEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF189AC6FFC4C4C4FFF4F4F4FF00000000000000000000
      00000000000000000000000000000000000000000000A3A3A3FFFEFEFEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFCF9FFE7B988FFD1995CFFD1995CFFBA720DFF6F5C
      54FFC3BBB8FFE4E1DFFFF6F5F5FFFDFDFDFFD0D0D000E0DEDE00D1C9C900D6C9
      C900CCB8B800CEB9AF00D6C0AB00DCBF9900D0A58700C3A4A400D0B5B500D6C0
      C000E1D7D700E8E2E200F5F5F50000000000000000000000000000000000FEFE
      FEFFFEFEFEFFFEFEFEFFFEFEFEFF000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000021A2CEFF21A2
      CEFF21A2CEFF21A2CEFFDCDCDCFFF4F4F4FF0000000000000000000000000000
      00000000000000000000000000000000000000000000A3A3A3FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFE7B988FFD1995CFFBA720DFF6C5A50FFC1BA
      B5FFE4E1DFFFF6F5F5FFFDFDFDFF00000000000000000000000000000000EDEB
      EB00E1DBDB00DED4D400DAC8C800DBC3C300C09A9A00E3E3E300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A3A3A3FFA3A3A3FFA3A3
      A3FFA3A3A3FFA3A3A3FFA3A3A3FFA3A3A3FFBA720DFF59453AFFB5ACA7FFE0DD
      DAFFF6F5F5FFFDFDFDFF0000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000C000FFBFFFFFFFFF8000FF3FE01F8001
      0001FE3FC00780010001F81F800380010001E007000380010001C00300018001
      0001800100018001000100000001800100010000000180010001000000018001
      0000000000018001000100000001800100018001800380010001C00380078001
      0003E007C00F80010007F81FF01FFFFF801F8000FFFFE000000700008001C000
      0001000000008000000000000000800000000000000080000000000000008000
      8000000000008000800000000000800080000000000080000000000000008000
      0000000000008000000000010000800000008003000180000000C0FF807F8000
      0001E1FFC0FF8001E03FFFFFFFFF8003}
  end
  object XPManifest1: TXPManifest
    Left = 48
    Top = 40
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    Left = 80
    Top = 40
  end
  object PopupMenu1: TPopupMenu
    Left = 112
    Top = 40
    object ExploreDirectory1: TMenuItem
      Caption = 'Explore Directory'
      Default = True
      OnClick = ExploreDirectory1Click
    end
    object TruncateDirectoryTree1: TMenuItem
      Caption = 'Choose as Root Directory'
      OnClick = TruncateDirectoryTree1Click
    end
    object ExportasXMLDocuemnt1: TMenuItem
      Caption = 'Export XML Document'
      object File1: TMenuItem
        Caption = 'Copy to Clipbaord'
        OnClick = File1Click
      end
      object Clipbaord1: TMenuItem
        Caption = 'Save to File'
        OnClick = Clipbaord1Click
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object MoveDirectory1: TMenuItem
      Caption = 'Move Directory To...'
      OnClick = MoveDirectory1Click
    end
    object DeleteDirectory1: TMenuItem
      Caption = 'Delete Directory'
      object MoveToRecycleBin1: TMenuItem
        Caption = 'Move To Recycle Bin'
        OnClick = MoveToRecycleBin1Click
      end
      object DeletePermanently2: TMenuItem
        Caption = 'Delete Permanently'
        OnClick = DeletePermanently2Click
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object CollapseDirectoryTree1: TMenuItem
      Caption = 'Properties'
      OnClick = CollapseDirectoryTree1Click
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 16
    Top = 336
    object ExploreFile1: TMenuItem
      Caption = 'Show in Explorer'
      Default = True
      OnClick = ExploreFile1Click
    end
    object OpenFile1: TMenuItem
      Caption = 'Execute File'
      OnClick = OpenFile1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MoveFile1: TMenuItem
      Caption = 'Move File To...'
      OnClick = MoveFile1Click
    end
    object DeleteFile1: TMenuItem
      Caption = 'Delete File'
      object MoveToRecycle1: TMenuItem
        Caption = 'Move To Recycle Bin'
        OnClick = MoveToRecycle1Click
      end
      object DeletePermanently1: TMenuItem
        Caption = 'Delete Permanently'
        OnClick = DeletePermanently1Click
      end
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Properties1: TMenuItem
      Caption = 'Properties'
      OnClick = Properties1Click
    end
  end
  object SaveDialog_XML: TSaveDialog
    DefaultExt = 'xml'
    Filter = 'XML Document (.xml)|*.xml'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Export as XML Document...'
    Left = 148
    Top = 40
  end
end