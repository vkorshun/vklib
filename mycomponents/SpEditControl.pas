unit SpEditControl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,  ComCtrls, Menus,   Registry,
  ExtCtrls,  SynEdit, SynEditHighlighter,
  SynEditMiscClasses, SynEditSearch,
  SynEditRegexSearch,  SynHighlighterCAC;

type
TSpEditControl = class(TWinControl)
private
  Memo: TSynEdit;
  StBar: TStatusBar;
  Panel1: TPanel;
  BtnApply: TButton;
  BtnCancel: TButton;
  PopupMenu1: TPopupMenu;
  SaveDialog: TSaveDialog;
  SynEditSearch: TSynEditSearch;
  OpenDialog1: TOpenDialog;
  SynEditRegexSearch: TSynEditRegexSearch;
  SynCACSyn1: TSynCACSyn;
  FOnApplyClick: TNotifyEvent;
  FOnCancelClick: TNotifyEvent;
public
  constructor Create(owner:TComponent);override;
  destructor Destroy;override;
  property OnApplyClick: TNotifyEvent read FOnApplyClick write FOnApplyClick;
  property OnCancelClick: TNotifyEvent read FOnCancelClick write FOnCancelClick;
end;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('VkComp', [TSpEditControl]);
end;

{ TSpEditControl }

constructor TSpEditControl.Create(Owner: TComponent);
begin
  Inherited;
  Memo := TSynEdit.Create(Owner);
  Memo.Parent := TWinControl(Self);
  Memo.Width := 640;
  Memo.Height := 350;
  Memo.Align := AlClient;
  StBar := TStatusBar.Create(Owner);
  StBar.Parent := Memo.Parent;
  StBar.Left := Memo.Left;
  StBar.Width := Memo.Width;
  StBar.Height := 24;
  StBar.Top := Memo.Top+Memo.Height;
  StBar.Align := AlBottom;
  Panel1 := TPanel.Create(Owner);
  with Panel1 do
  begin
    Parent := Memo.Parent;
    Left   := Memo.Left;
    Height := 36;
    Top    := StBar.Top+StBar.Height;
    Width  := Memo.Width;
    Align := AlBottom;
  end;
  BtnApply := TButton.Create(Panel1);
  with BtnApply do
  begin
    Parent := Panel1;
    Top    := 3;
    Left   := 9;
    Height := 30;
    Width  := 100;
    Caption := 'Применить';
    OnClick := FOnApplyClick;
  end;

  BtnCancel := TButton.Create(Panel1);
  with BtnCancel do
  begin
    Parent := Panel1;
    Top    := 3;
    Left   := 9+BtnApply.Width+16;
    Height := 30;
    Width  := 100;
    Caption := 'Отменить';
    OnClick := FOnCancelClick;
  end;

end;

destructor TSpEditControl.Destroy;
begin
  Inherited;
end;

end.

