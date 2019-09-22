object FmFind: TFmFind
  Left = 0
  Top = 0
  ActiveControl = CbText
  BorderStyle = bsDialog
  Caption = 'FmFind'
  ClientHeight = 73
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 6
    Top = 24
    Width = 18
    Height = 13
    Caption = 'Key'
  end
  object CbText: TComboBox
    Left = 97
    Top = 16
    Width = 235
    Height = 21
    TabOrder = 0
    Text = 'CbText'
  end
  object BtnCancel: TButton
    Left = 265
    Top = 44
    Width = 67
    Height = 24
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtnCancelClick
  end
  object BtnFind: TButton
    Left = 185
    Top = 44
    Width = 67
    Height = 24
    Caption = 'Find'
    Default = True
    TabOrder = 2
    OnClick = BtnFindClick
  end
  object cbCharCase: TDBCheckBoxEh
    Left = 12
    Top = 54
    Width = 134
    Height = 13
    Caption = 'Match &Case'
    DynProps = <>
    TabOrder = 3
  end
end
