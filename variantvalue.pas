unit variantvalue;

interface

uses
  SysUtils, Classes, Vcl.Controls;

type
  TCustomVariantValue = class(TObject)
  private
    Foldvalue : Variant;
    Fnewvalue : Variant;
//    FInitValue: Variant;
    function  GetString:String;
    function  GetInteger:Integer;
    function  GetFloat:Double;
    function  GetBool:Boolean;
    function  GetDateTime:TDateTime;
    function  GetLargeInt: Int64;
    procedure SetString(s:String);
    procedure SetInteger(i:Integer);
    procedure SetFloat(d:Double);
    procedure SetBool(b:Boolean);
    procedure SetDateTime(d:TDateTime);
    procedure SetLargeInt(a:Int64);
  public
    function  GetValue:Variant;virtual;
    procedure SetValue(aValue:Variant);virtual;
    property AsBoolean:Boolean read GetBool write SetBool;
    property AsDateTime:TDateTime read GetDateTime write SetDateTime;
    property AsInteger:Integer read GetInteger write SetInteger;
    property AsFloat:Double read GetFloat write SetFloat;
    property AsLargeInt:Int64 read GetLargeInt write SetLargeInt;
    property AsString:String read GetString write SetString;
    constructor Create;
    property value:Variant read GetValue write SetValue;
    property oldvalue:Variant read Foldvalue write Foldvalue;
    property newvalue:Variant read Fnewvalue write Fnewvalue;
  end;


implementation

uses variants, datevk;

{ TCustomVariantValue }

constructor TCustomVariantValue.Create;
begin
  FOldValue := null;
  Fnewvalue := null;
end;

function TCustomVariantValue.GetBool: Boolean;
begin
  if VarIsStr(Value) then
  begin
    if (UpperCase(Value)='TRUE') or (UpperCase(Value)=String('T')) then
      Value := True
    else
    if (UpperCase(Value)='FALSE') or (UpperCase(Value)='F')then
      Value := False
    else
      Value := False;
  end;
  Result := CoalEsce(Value,False);
end;

function TCustomVariantValue.GetDateTime: TDateTime;
begin
  if VIsEmpty(Value) then
    Result := 0
  else
    Result := VarToDateTime(CoalEsce(Value,0))
end;

function TCustomVariantValue.GetFloat: Double;
begin
  if VIsEmpty(Value) then
    Result := 0
  else
    Result := CoalEsce(Value,0);
end;

function TCustomVariantValue.GetInteger: Integer;
begin
  if VIsEmpty(Value) then
    Result := 0
  else
    Result := CoalEsce(Value,0);
end;

function TCustomVariantValue.GetLargeInt: Int64;
begin
  Result := CoalEsce(Value,0);
end;

function TCustomVariantValue.GetString: String;
begin
  Result := CoalEsce(Value,' ');
end;

function TCustomVariantValue.GetValue: Variant;
begin
  Result := FNewValue;
end;

procedure TCustomVariantValue.SetBool(b: Boolean);
begin
  Value := b;
end;

procedure TCustomVariantValue.SetDateTime(d: TDateTime);
begin
  Value := d;
end;

procedure TCustomVariantValue.SetFloat(d: Double);
begin
  Value := d;
end;

{procedure TCustomVariantValue.SetInitValue(const aValue: Variant);
begin
  FInitValue := aValue;
  FNewValue  := aValue;
end; }

procedure TCustomVariantValue.SetInteger(i: Integer);
begin
  Value := i;
end;

procedure TCustomVariantValue.SetLargeInt(a: Int64);
begin
  Value := a;
end;

procedure TCustomVariantValue.SetString(s: String);
begin
  Value := s;
end;

procedure TCustomVariantValue.SetValue(aValue: Variant);
begin
  Foldvalue := FNewValue;
  FNewValue := aValue;
end;

end.
