object FrameTextEditor: TFrameTextEditor
  Left = 0
  Top = 0
  Width = 539
  Height = 373
  TabOrder = 0
  TabStop = True
  object Memo: TSynEdit
    Left = 0
    Top = 0
    Width = 539
    Height = 349
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Courier New'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    PopupMenu = PopupMenu1
    TabOrder = 0
    OnKeyDown = MemoKeyDown
    CodeFolding.GutterShapeSize = 11
    CodeFolding.CollapsedLineColor = clGrayText
    CodeFolding.FolderBarLinesColor = clGrayText
    CodeFolding.IndentGuidesColor = clGray
    CodeFolding.IndentGuides = True
    CodeFolding.ShowCollapsedLine = False
    CodeFolding.ShowHintMark = True
    UseCodeFolding = False
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -13
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Highlighter = SynCACSyn1
    SearchEngine = SynEditSearch
    OnStatusChange = MemoStatusChange
  end
  object StBar: TStatusBar
    Left = 0
    Top = 349
    Width = 539
    Height = 24
    Panels = <
      item
        Alignment = taRightJustify
        Width = 60
      end
      item
        Alignment = taRightJustify
        Style = psOwnerDraw
        Width = 150
      end
      item
        Width = 200
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
    OnDrawPanel = StBarDrawPanel
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 136
    Top = 80
    object imSave: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '
      ShortCut = 113
      OnClick = imSaveClick
    end
    object SaveAs1: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083
      ShortCut = 32851
      OnClick = SaveAs1Click
    end
    object nLoadFromFile: TMenuItem
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1080#1079' '#1092#1072#1081#1083#1072
      ShortCut = 16463
      OnClick = nLoadFromFileClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object nGoToLine: TMenuItem
      Caption = #1055#1077#1088#1077#1081#1090#1080' '#1085#1072' '#1089#1090#1088#1086#1082#1091
      ShortCut = 16458
      OnClick = nGoToLineClick
    end
    object nFind: TMenuItem
      Caption = #1055#1086#1080#1089#1082
      ShortCut = 16454
      OnClick = nFindClick
    end
    object nNext: TMenuItem
      Caption = #1055#1088#1086#1076#1086#1083#1078#1077#1085#1080#1077' '#1087#1086#1080#1089#1082#1072
      ShortCut = 114
      OnClick = nNextClick
    end
    object nReplace: TMenuItem
      Caption = #1055#1086#1080#1089#1082' '#1080' '#1079#1072#1084#1077#1085#1072
      ShortCut = 16466
      OnClick = nReplaceClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object nCut: TMenuItem
      Caption = #1042#1099#1088#1077#1079#1072#1090#1100
      OnClick = nCutClick
    end
    object nCopy: TMenuItem
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      OnClick = nCopyClick
    end
    object nPaste: TMenuItem
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100
      OnClick = nPasteClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object nSelectAll: TMenuItem
      Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1077
      OnClick = nSelectAllClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object OEM1: TMenuItem
      Caption = 'OEM'
      OnClick = OEM1Click
    end
  end
  object SaveDialog: TSaveDialog
    Left = 184
    Top = 48
  end
  object SynCACSyn1: TSynCACSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    CommentAttri.Foreground = clGrayText
    KeyAttri.Foreground = clNavy
    NumberAttri.Foreground = clGreen
    StringAttri.Foreground = clMaroon
    Left = 192
    Top = 152
  end
  object SynEditSearch: TSynEditSearch
    Left = 304
    Top = 72
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.mac;*.*'
    Left = 336
    Top = 8
  end
  object SynEditOptionsDialog1: TSynEditOptionsDialog
    UseExtendedStrings = True
    Left = 344
    Top = 128
  end
  object SynEditRegexSearch: TSynEditRegexSearch
    Left = 416
    Top = 64
  end
end
