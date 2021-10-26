object VkDocDialogFm: TVkDocDialogFm
  Left = 350
  Top = 343
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'FmVkDocDialog'
  ClientHeight = 34
  ClientWidth = 144
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnBottom: TPanel
    Left = 0
    Top = 0
    Width = 144
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    OnResize = pnBottomResize
    object btnOk: TButton
      Left = 2
      Top = 7
      Width = 61
      Height = 24
      Action = aOk
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 0
    end
    object BtnCansel: TButton
      Left = 67
      Top = 7
      Width = 74
      Height = 24
      Action = aCancel
      Cancel = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 1
    end
  end
  object Scrb: TScrollBox
    Left = 0
    Top = 0
    Width = 144
    Height = 0
    HorzScrollBar.Visible = False
    VertScrollBar.Visible = False
    Align = alClient
    BorderStyle = bsNone
    TabOrder = 1
  end
  object ActionList1: TActionList
    OnUpdate = ActionList1Update
    Left = 32
    Top = 65528
    object aOk: TAction
      Caption = #1054#1082
      OnExecute = aOkExecute
    end
    object aCancel: TAction
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      OnExecute = aCancelExecute
    end
  end
end
