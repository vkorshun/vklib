unit MEditBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask,Rtti;

type
  TNotifyMEditBoxGet = function (Sender:TObject):TValue of object;
  TNotifyMEditBoxSet = procedure (Sender:TObject; aValue:TValue) of object;
  TMEditBox = class(TMaskEdit)
  procedure MyClick(Sender: TObject);
  private
    { Private declarations }
    FButton :TButton;
    FOnButtonClick : TNotifyEvent;
    FValue: TValue;
    FOnGetValue: TNotifyMEditBoxGet;
    FOnSetValue: TNotifyMEditBoxSet;
    FOnClearValue: TNotifyMEditBoxGet;
    FbCanKeyInput: Boolean;
    procedure SetButton;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    function GetValue: TValue;
    procedure SetValue(const Value: TValue);
    procedure SetbCanKeyInput(const Value: Boolean);
  protected
    { Protected declarations }
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure MyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MyKeyPress(Sender: TObject; var Key: Char);
//    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
  public
    { Public declarations }
    Constructor Create(Sender: TComponent);override;
    Destructor Destroy;override;
    procedure ClearValue;
    procedure Repaint;override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;  public
    property Value:TValue read GetValue write SetValue;
    property OnClearValue:TNotifyMEditBoxGet read FOnClearValue write FOnClearValue;
    property OnGetValue:TNotifyMEditBoxGet read FOnGetValue write FOnGetValue;
    property OnSetValue:TNotifyMEditBoxSet read FOnSetValue write FOnSetValue;
  published
    { Published declarations }
//    property Button :TButton Read FButton Write FButton;
    property OnButtonClick : TNotifyEvent Read FOnButtonClick Write FOnButtonClick;
    property bCanKeyInput: Boolean read FbCanKeyInput write SetbCanKeyInput;
  end;

procedure Register;

implementation

{ ?????????? ??????? ????? ??????? ? ????????}
function GetAveWidth(cmb:TWinControl):integer;
 var tm:TTextMetric;
begin
  GetTextMetrics(GetDc(cmb.handle),tm);
  result:= tm.tmAveCharWidth;
end;


procedure Register;
begin
  RegisterComponents('VkComp', [TMEditBox]);
end;

procedure TMEditBox.ClearValue;
begin
  if Assigned(FOnClearValue) then
    FValue := FOnClearValue(Self)
  else
  begin
    Text := '';
    FValue := nil;
  end;
end;

constructor TMEditBox.Create(Sender : TComponent);
begin
  inherited Create(Sender);
  FbCanKeyInput := False;
  FButton := TButton.Create(Self);
  FButton.parent := TWinControl(Self);
  with FButton do begin
    Caption := '...';
    SetButton;
    OnClick := MyClick;
    TabStop := False;
    TabOrder := 0;
  end;
  OnKeyDown:= MyKeyDown;
  OnKeyPress := MyKeyPress;
  FValue := nil;
end;

procedure TMEditBox.Repaint;
begin
  inherited ;
  SetButton;
end;

procedure TMEditBox.MyClick(Sender : TObject);
begin
 if Visible then
  self.SetFocus;
 if Assigned(FOnButtonClick) then begin
   FOnButtonClick(Self);
 end;
end;

Destructor TMEditBox.Destroy;
begin
  FButton.Free;
  inherited;
end;

function TMEditBox.GetValue: TValue;
begin
  if Assigned(FOnGetValue) then
    Result := FOnGetValue(self)
  else
    Result := FValue;
end;

procedure TMEditBox.SetbCanKeyInput(const Value: Boolean);
begin
  FbCanKeyInput := Value;
end;

procedure TMEditBox.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  SetButton;
//  Refresh;
end;

procedure TMEditBox.SetButton;
begin
  if FButton <> nil then begin
    with FButton  do begin
      Height := Self.Height - 4 ;
      if Self.Parent <> nil then
      Width  := Round(GetAveWidth(Self)*2.5);
      Left   := Self.Width- Width-4;
      Top    := 0;
    end;
  end;
end;


procedure TMEditBox.SetValue(const Value: TValue);
begin
  if Assigned(FOnsetValue) then
    FOnSetValue(self, Value)
  else
    FValue := Value;
end;

procedure TMEditBox.WMSetFocus(var Message: TWMSetFocus);
begin
  SendMessage(Handle,EM_SETMARGINS,EC_RIGHTMARGIN OR EC_LEFTMARGIN,25 shl 16);
  inherited;
  if isMasked then
  CheckCursor;
//  SendMessage(Handle,WM_KEYDOWN,VK_HOME,0);
end;

procedure TMEditBox.WMKillFocus(var Message: TWMSetFocus);
begin
  SendMessage(Handle,WM_KEYDOWN,VK_HOME,0);
  inherited;
  ResetIme;
end;



procedure TMEditBox.MyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssAlt in Shift) and (key=VK_DOWN) then
    OnButtonClick(Sender);
  if (key=VK_RETURN) and (Shift= []  ) then
    OnButtonClick(Sender);
  if (key=VK_DELETE) then
    ClearValue;
  Inherited;
end;

procedure TMEditBox.MyKeyPress(Sender: TObject; var Key: Char);
begin
  if not FbCanKeyInput then
    Key := #0
  else
    Inherited;
end;

end.

