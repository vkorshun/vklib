unit numbermaskedit;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Mask, StrUtils, Windows, Messages,
  variants, math;

type
  TNumberMaskEdit = class(TMaskEdit)
  private
    FCurrency: Boolean;
    FDecimalPlaces: Cardinal;
    FEditFormat: String;
    FInternalTextSetting: Boolean;
    bFocus: Boolean;
    { Private declarations }
    function CurrencyEditFormat: String;
    function FormatFloatStr(const S: string; Thousands: Boolean): string;
    function TextToValText(const AValue: string): string;
    procedure SetDecimalPlaces(const Value: Cardinal);
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
  protected
    { Protected declarations }
    procedure Change;override;
    procedure InternalSetControlText(AText: String);
    function IsValidChar(Key: Char): Boolean;
    procedure KeyPress(var Key: Char); override;
    procedure CMWantSpecialKey(var Message: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;

    procedure ReformatEditText(NewText: String); dynamic;

  public
    { Public declarations }
    constructor Create(aOwner:TComponent);override;
  published
    { Published declarations }
    property Currency:Boolean Read FCurrency write FCurrency;
    property DecimalPlaces:Cardinal read FDecimalPlaces write SetDecimalPlaces;
    property Value:Variant read GetValue Write SetValue;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('vkcomp', [TNumberMaskEdit]);
end;

function DelBSpace(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  Result := Copy(S, I, MaxInt);
end;

function DelESpace(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] <= ' ') do Dec(I);
  Result := Copy(S, 1, I);
end;

function DelRSpace(const S: string): string;
begin
  Result := DelBSpace(DelESpace(S));
end;

function IsValidFloat(const Value: string; var RetValue: Extended): Boolean;
var
  I: Integer;
  Buffer: array[0..63] of Char;
{$IFDEF CIL}
  DValue: Double;
{$ENDIF}
begin
  Result := False;
  for I := 1 to Length(Value) do
    if not ((Value[I] = FormatSettings.DecimalSeparator) or CharInSet(Value[I], [ '-', '+', '0'..'9', 'e', 'E'])) then
      Exit;
  if (Value = '+') or (Value = '-') then
  begin
    RetValue := 0;
    Result := True;
  end else
{$IFDEF CIL}
  begin
    DValue := RetValue;
    Result := TryStrToFloat(Value, DValue);
    RetValue := DValue;
  end;
{$ELSE}
    Result := TextToFloat(StrPLCopy(Buffer, Value,
      SizeOf(Buffer) - 1), RetValue, fvExtended);
{$ENDIF}
end;

{ TNumberMaskEdit }

procedure TNumberMaskEdit.Change;
begin
  ReformatEditText(inherited Text);
  inherited;
end;

procedure TNumberMaskEdit.CMWantSpecialKey(var Message: TCMWantSpecialKey);
begin
  if (Message.CharCode = VK_ESCAPE) and Modified then
    Message.Result := 1;
//  if (Message.CharCode = VK_RETURN) and FInplaceMode then
//    Message.Result := 1;

end;

constructor TNumberMaskEdit.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  DecimalPlaces := 0;
  EditText := '0';
  Alignment := taRightJustify;
  FCurrency := False;
  FEditFormat := '';
  bFocus := False;
//  Mask := ',#.';
end;

function TNumberMaskEdit.CurrencyEditFormat: String;
var i: Integer;
begin
  Result := ',#.';
  for i := 1 to FormatSettings.CurrencyDecimals do
    Result := Result + '0';
end;

function TNumberMaskEdit.FormatFloatStr(const S: string;
  Thousands: Boolean): string;
var
  I, MaxSym, MinSym, Group: Integer;
  IsSign: Boolean;
begin
  Result := '';
  MaxSym := Length(S);
  IsSign := (MaxSym > 0) and CharInSet(S[1], ['-', '+']);
  if IsSign then MinSym := 2
  else MinSym := 1;
  I := Pos(FormatSettings.DecimalSeparator, S);
  if I > 0 then MaxSym := I - 1;
  I := Pos('E', UpperCase(S));
  if I > 0 then MaxSym := Min(I - 1, MaxSym);
  Result := Copy(S, MaxSym + 1, MaxInt);
  Group := 0;
  for I := MaxSym downto MinSym do
  begin
    Result := S[I] + Result;
    Inc(Group);
    if (Group = 3) and Thousands and (I > MinSym) then
    begin
      Group := 0;
      Result := FormatSettings.ThousandSeparator + Result;
    end;
  end;
  if IsSign then Result := S[1] + Result;

end;

function TNumberMaskEdit.GetValue: Variant;
var d:double;
begin
  if TryStrToFloat(EditText,d) then
    Result := d
  else
    Result := null;
end;

procedure TNumberMaskEdit.InternalSetControlText(AText: String);
begin
  if FInternalTextSetting then Exit;
  FInternalTextSetting := True;
  try
    inherited Text := AText;
  finally
    FInternalTextSetting := False;
  end;

end;

function TNumberMaskEdit.IsValidChar(Key: Char): Boolean;
var
  S: string;
  SelStart, SelStop, DecPos: Integer;
  RetValue: Extended;
  bEnd: Boolean;
  oldPos,oldPos2,i : Integer;
begin
  if CharInSet(Key,['.',',']) then
    Key := FormatSettings.DecimalSeparator;

  Result := False;
  S := EditText;
  oldPos2 := Pos(FormatSettings.DecimalSeparator, S);
  GetSel(SelStart, SelStop);
  {System.}Delete(S, SelStart + 1, SelStop - SelStart);
  {System.}Insert(Key, S, SelStart + 1);
  bEnd := SelStart+1 = length(s);
  oldPos := SelStart;
  S := TextToValText(S);
  DecPos := Pos(Formatsettings.DecimalSeparator, S);
  if (DecPos > 0) then
  begin
    SelStart := Pos('E', UpperCase(S));
    if (SelStart > DecPos) then DecPos := SelStart - DecPos
    else DecPos := Length(S) - DecPos;
    if DecPos > Integer(FDecimalPlaces) then
    begin
      if Key=Formatsettings.DecimalSeparator then
      begin
        if oldpos2> oldpos then
           for i:=0 to oldpos2-oldPos-1 do
             SendMessage(Handle,WM_KEYDOWN,VK_RIGHT,VK_RIGHT)
        else
           for i:=0 to oldpos-oldPos2-1 do
             SendMessage(Handle,WM_KEYDOWN,VK_LEFT,VK_LEFT);
        Exit;
      end
      else
      begin
        if bEnd then
           Exit;
        SendMessage(Handle,WM_KEYDOWN,VK_DELETE,VK_DELETE)
      end;
    end
    else
      if (Key=FormatSettings.DecimalSeparator) and (oldpos2>0) then
      begin
        if oldpos2> oldpos then
           for i:=0 to oldpos2-oldPos-1 do
             SendMessage(Handle,WM_KEYDOWN,VK_RIGHT,VK_RIGHT)
        else
           for i:=0 to oldpos-oldPos2-1 do
             SendMessage(Handle,WM_KEYDOWN,VK_LEFT,VK_LEFT);
        Exit;
      end;
  end;
  if S  = '' then
    Result := True
  else
  begin
    Result := IsValidFloat(S, RetValue);
    //if Result and (FMinValue >= 0) and (FMaxValue > 0) and (RetValue < 0) then
    //  Result := False;
  end;

end;

procedure TNumberMaskEdit.KeyPress(var Key: Char);
begin
//  inherited;
//  CheckInplaceEditHolderKeyPress(Key);
  if Key = #0 then Exit;
  inherited KeyPress(Key);
  //if not DataIndepended then
    if (Key >= #32) and not IsValidChar(Key) then
    begin
      MessageBeep(0);
      Key := #0;
    end;
  if (Key = #8) and (SelStart > 0) and (Text[SelStart] = FormatSettings.ThousandSeparator) then
  begin
    SelStart := SelStart - 1;
    Key := #0;
  end;
  inherited KeyPress(Key);
  if CharInSet(Key, ['.', ',']) then
   if (FDecimalPlaces>0) then Key := Copy(Formatsettings.DecimalSeparator, 1, 1)[1]
    else
      Key := #0;

  if (Key >= #32) and not IsValidChar(Key) then
  begin
    Key := #0;
  end
  else if Key = #27 then
  begin
    Reset;
    Key := #0;
  end;

{  case Key of
    ^H, ^V, ^X, #32..High(Char):
      if not ReadOnly then FDataLink.Edit;
    #27:
      begin
        FDataLink.Reset;
        SelectAll;
        Key := #0;
      end;
  end;
  if (Integer(Key) = VK_BACK) and MRUList.Active and Showing and not FDroppedDown and (Text = '') then
    MRUList.DropDown;
  }
end;

procedure TNumberMaskEdit.ReformatEditText(NewText: String);
var
  S: string;
  IsEmpty: Boolean;
  OldLen, SelStart, SelStop: Integer;
begin
  //FFormatting := True;
  try
    S := NewText;
    OldLen := Length(S);
    IsEmpty := (OldLen = 0) or (S = '-');
    if HandleAllocated then GetSel(SelStart, SelStop);
    if not IsEmpty then S := TextToValText(S);
    if FCurrency then
      FEditFormat := CurrencyEditFormat;
    S := FormatFloatStr(S, Pos(',', FEditFormat) > 0);
    if S <> Text then
    begin
      InternalSetControlText(S);
      if HandleAllocated and (GetFocus = Handle) and not (csDesigning in ComponentState) then
      begin
        Inc(SelStart, Length(S) - OldLen);
        SetCursor(SelStart);
      end;
    end;
  finally
    //FFormatting := False;
  end;

end;

procedure TNumberMaskEdit.SetDecimalPlaces(const Value: Cardinal);
begin
  FDecimalPlaces := Value;
end;

procedure TNumberMaskEdit.SetValue(const Value: Variant);
begin
  EditText := Value;
end;

function TNumberMaskEdit.TextToValText(const AValue: string): string;
begin
  Result := DelRSpace(AValue);
  if Formatsettings.DecimalSeparator <> FormatSettings.ThousandSeparator then
    Result := StringReplace(Result, FormatSettings.ThousandSeparator, '', [rfReplaceAll]);
  if (FormatSettings.DecimalSeparator <> '.') and (FormatSettings.ThousandSeparator <> '.') then
    Result := ReplaceStr(Result, '.', FormatSettings.DecimalSeparator);
  if (FormatSettings.DecimalSeparator <> ',') and (FormatSettings.ThousandSeparator <> ',') then
    Result := ReplaceStr(Result, ',', FormatSettings.DecimalSeparator);

end;


procedure TNumberMaskEdit.WMLButtonUp(var Message: TWMLButtonUp);
//var
//  SelStart, SelStop : Integer;
begin
  inherited;
  if bFocus then
  begin
    bFocus := False;
    SelectAll;
    Exit
  end;
//  SelectAll;
//  if (IsMasked) then
{  begin
    GetSel(SelStart, SelStop);
    CaretPos := SelStart;
    if (SelStart <> SelStop) and (Message.XPos > FBtnDownX) then
      FCaretPos := SelStop
    else
    begin
    end;
  end;
 }
end;

procedure TNumberMaskEdit.WMSetFocus(var Message: TWMSetFocus);
begin
//  PostMessage(Handle, EM_SETSEL, 0, -1);
  bFocus := True;
  Inherited;
end;

end.
