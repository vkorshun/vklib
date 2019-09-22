unit vknumberedit;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Windows;

type
  TVkNumberEdit = class(TCustomEdit)
  private
    FDecimalPlaces: Cardinal;
    FEditText: String;
    function GetText:String;
    procedure SetDecimalPlaces(const Value: Cardinal);
    procedure SetEditText(const Value: String);
    { Private declarations }
//    FDecimalPlaces:Cardinal;
  protected
    { Protected declarations }
    function IsValidChar(Key: Char): Boolean;

  public
    { Public declarations }
  published
    { Published declarations }
    property DecimalPlaces: Cardinal read FDecimalPlaces write SetDecimalPlaces;
    property EditText:String read GetText write SetEditText;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('VkComp', [TVkNumberEdit]);
end;

{ TVkNumberEdit }

function TVkNumberEdit.GetText: String;
begin
  Result := Text;
end;

function TVkNumberEdit.IsValidChar(Key: Char): Boolean;
var
  S: string;
  SelStart, SelStop, DecPos: Integer;
  RetValue: Extended;
  bEnd: Boolean;
  oldPos,oldPos2,i : Integer;
begin
  Result := False;
  S := EditText;
  oldPos2 := Pos(DecimalSeparator, S);
  GetSel(SelStart, SelStop);
  {System.}Delete(S, SelStart + 1, SelStop - SelStart);
  {System.}Insert(Key, S, SelStart + 1);
  bEnd := SelStart+1 = length(s);
  oldPos := SelStart;
  S := TextToValText(S);
  DecPos := Pos(DecimalSeparator, S);
  if (DecPos > 0) then
  begin
    SelStart := Pos('E', UpperCase(S));
    if (SelStart > DecPos) then DecPos := SelStart - DecPos
    else DecPos := Length(S) - DecPos;
    if DecPos > Integer(FDecimalPlaces) then
    begin
      if Key=DecimalSeparator then
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
      if (Key=DecimalSeparator) and (oldpos2>0) then
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
    if Result and (FMinValue >= 0) and (FMaxValue > 0) and (RetValue < 0) then
      Result := False;
  end;

end;

procedure TVkNumberEdit.SetDecimalPlaces(const Value: Cardinal);
begin
  FDecimalPlaces := Value;
end;

procedure TVkNumberEdit.SetEditText(const Value: String);
begin
  Text := Value;
end;

end.
