object FmTextEditor: TFmTextEditor
  Left = 160
  Top = 124
  Caption = 'Memo Editor'
  ClientHeight = 326
  ClientWidth = 522
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object Panel1: TPanel
    Left = 0
    Top = 296
    Width = 522
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Panel2: TPanel
      Left = 383
      Top = 0
      Width = 139
      Height = 30
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btCancel: TButton
        Left = 67
        Top = 4
        Width = 56
        Height = 25
        Cancel = True
        Caption = 'Cancel'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ModalResult = 2
        ParentFont = False
        TabOrder = 1
      end
      object btOK: TButton
        Left = 6
        Top = 4
        Width = 56
        Height = 25
        Caption = 'Ok'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ModalResult = 1
        ParentFont = False
        TabOrder = 0
      end
    end
  end
end
