unit vkvariablebindingcustom;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Controls,
  StdCtrls, Forms, Dialogs, Variants, Db, vkvariable, variantutils;

type
  TCustomVkVariableBindingCollection = class;

  TCustomVkVariableBinding = class(TCollectionItem)
  private
    FOnBinding: TNotifyEvent;
    procedure SetOnBinding(const Value: TNotifyEvent);
  protected
    FoControl: TWinControl;
    FCurrentOnChange: TNotifyEvent;
    FCurrentOnChangeVariable: TNotifyEvent;
    FVariable: TVkVariable;
    FbFromControl: Boolean;
    FIsDummy: Boolean;
    FOwnerWhenDummy: TCustomVkVariableBindingCollection;
  public
    property IsDummy: Boolean read FIsDummy;
    constructor Create(AOwner: TPersistent);virtual;
    constructor CreateAsDummy(AOwnerWhenDummy: TCustomVkVariableBindingCollection); virtual;
    destructor Destroy; override;
    procedure DoChange(Sender: TObject);
    procedure DoInternalChangeVariable(Sender: TObject);
    function IsEqual(Value: TCustomVkVariableBinding): Boolean;
    function GetValue: Variant; virtual;
    procedure SetControl(const Value: TWinControl); Virtual;
    procedure SetControlValue(const Value: Variant); virtual;abstract;
    procedure ReInit; virtual;
    procedure Bind(AVkvariable:TVkVariable; AControl:TWinControl);virtual;
    property oControl: TWinControl read FoControl Write SetControl;
    property Variable: TVkVariable read FVariable;
    property bFromControl:Boolean read FbFromControl;
    property OnBinding: TNotifyEvent read FOnBinding write SetOnBinding;
  end;

  TCustomVkVariableBindingClass = class of TCustomVkVariableBinding;
  TCustomVkVariableBindingCollection = class(TCollection)
  private
    FDummyBinding: TCustomVkVariableBinding;
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
    function GetVkVariableBinding(const VarName: string): TCustomVkVariableBinding;
    function GetItem(Index: Integer): TCustomVkVariableBinding;
    procedure DeleteBinding(AVar: TCustomVkVariableBinding); overload;
    procedure SetItem(Index: Integer; Value: TCustomVkVariableBinding);
  protected
    function GetInitDummyBinding(AVarName: String): TCustomVkVariableBinding;
    function GetOwner: TPersistent; override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure CreateVkVariableBindingFromDummy(ADummyBinding: TCustomVkVariableBinding);
    procedure Update(Item: TCollectionItem); override;
    property DummyBinding: TCustomVkVariableBinding read FDummyBinding;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(Owner: TPersistent); overload;
    destructor Destroy; override;
    function GetVkVariableBindingClass: TCustomVkVariableBindingClass; virtual;
    function CreateVkVariableBinding( AControl:TWinControl; AVariable:TVkVariable): TCustomVkVariableBinding;
    function FindVkVariableBinding(const VarName: string) : TCustomVkVariableBinding;overload;
    function FindVkVariableBinding(AControl:TWinControl) : TCustomVkVariableBinding;overload;
    function FindVkVariableBinding(AVariable:TCustomVkVariable) : TCustomVkVariableBinding;overload;
    function IsEqual(Value: TCustomVkVariableBindingCollection): Boolean;
    function BindingExists(AControl:TWinControl; AVariable:TVkVariable): Boolean;
    procedure AddVkVariableBinding(ABinding:TCustomVkVariableBinding);
    procedure AssignValues(Value: TCustomVkVariableBindingCollection);
    procedure DeleteVkVariableBinding(const VarName: string); overload;
    procedure DeleteVkVariableBinding(const AControl: TWinControl); overload;
    procedure DeleteVkVariableBinding(const AVariable: TVkVariable); overload;
    procedure RemoveVkVariableBinding(const AVariableBinding: TCustomVkVariableBinding); overload;

    property Items[Index: Integer]: TCustomVkVariableBinding read GetItem write SetItem;
    property VkVariableBinding[const VarName: string]: TCustomVkVariableBinding read GetVkVariableBinding; default;
  end;



implementation


{ TCustomVkVariableBiding }

procedure TCustomVkVariableBinding.Bind(AVkvariable: TVkVariable; AControl: TWinControl);
begin
  FVariable := AVkVariable;
  SetControl(AControl);
//  if Assigned(FVariable.OnChangeVariable) then
//    FCurrentOnChangeVariable := FVariable.OnChangevariable;
  FVariable.OnInternalChangeVariable := DoInternalChangeVariable;
  SetControlValue(FVariable.Value);
  if Assigned(OnBinding) then
    OnBinding(self);
end;

constructor TCustomVkVariableBinding.Create(AOwner: TPersistent);
begin
  inherited Create(Collection);
  FVariable := nil;
  FoControl := nil;
end;

constructor TCustomVkVariableBinding.CreateAsDummy(AOwnerWhenDummy: TCustomVkVariableBindingCollection);
begin
  inherited Create(nil);
  FIsDummy := True;
  FOwnerWhenDummy := AOwnerWhenDummy;
end;

destructor TCustomVkVariableBinding.Destroy;
begin

  inherited;
end;

procedure TCustomVkVariableBinding.DoChange(Sender: TObject);
var
  v: Variant;
begin
  FbFromControl := true;
  try
  if Assigned(FCurrentOnChange) then
    FCurrentOnChange(Sender)
  else
  begin
    begin
      v := GetValue;
      if not VariantIsEquel(FVariable.Value,v) then
        FVariable.value := v;
    end;
  end;
  finally
    FbFromControl := False;
  end;

end;

procedure TCustomVkVariableBinding.DoInternalChangeVariable(Sender: TObject);
begin
//  if Assigned(FCurrentOnChangeVariable) then
//    FCurrentOnChangeVariable(Sender);
  if not FbFromControl then
    SetControlValue(TVkVariable(Sender).Value);
 { if Assigned(TVkVariable(Sender).OnChangeVariable) then
    TVkVariable(Sender).OnChangeVariable(Sender);}
end;

function TCustomVkVariableBinding.GetValue: Variant;
begin
  if Assigned(FVariable) then
    Result := FVariable.Value
  else
    Result := Unassigned;
end;

function TCustomVkVariableBinding.IsEqual(Value: TCustomVkVariableBinding): Boolean;
begin
  Result := (self.oControl = Value.oControl) and (self.Variable = self.Variable);
end;

procedure TCustomVkVariableBinding.ReInit;
begin
  SetControl(FoControl);
end;

procedure TCustomVkVariableBinding.SetControl(const Value: TWinControl);
begin
  FoControl := Value;
end;

procedure TCustomVkVariableBinding.SetOnBinding(const Value: TNotifyEvent);
begin
  FOnBinding := Value;
end;

{procedure TCustomVkVariableBiding.SetControlValue(const Value: Variant);
begin
end;}

{ TCustomVkVariableBindingCollection }

procedure TCustomVkVariableBindingCollection.AddVkVariableBinding(ABinding: TCustomVkVariableBinding);
begin
  if Assigned(ABinding.oControl) and Assigned(ABinding.Variable) then
    ABinding.Collection := self
  else
    raise Exception.Create('Binding is not full asigned');
end;

procedure TCustomVkVariableBindingCollection.AssignTo(Dest: TPersistent);
begin
  if Dest is TCustomVkVariableBindingCollection
    then TCustomVkVariableBindingCollection(Dest).Assign(Self)
    else inherited AssignTo(Dest);
end;

procedure TCustomVkVariableBindingCollection.AssignValues(Value: TCustomVkVariableBindingCollection);
var
  I: Integer;
  P: TCustomVkVariableBinding;
begin
  for I := 0 to Value.Count - 1 do
  begin
    P := FindVkVariableBinding(Value.Items[I].Variable.Name);
    if P <> nil then
      P.Assign(Items[I]);
  end;
end;

function TCustomVkVariableBindingCollection.BindingExists(AControl: TWinControl;
  AVariable: TVkVariable): Boolean;
begin
 Result := Assigned(FindVkVariableBinding(AControl)) or Assigned(FindVkVariableBinding(AVariable));
end;

constructor TCustomVkVariableBindingCollection.Create(Owner: TPersistent);
begin
  FOwner := Owner;
  inherited Create(GetVkVariableBindingClass);
  FDummyBinding := GetVkVariableBindingClass.CreateAsDummy(Self);
end;

function TCustomVkVariableBindingCollection.CreateVkVariableBinding(AControl: TWinControl;
  AVariable: TVkVariable): TCustomVkVariableBinding;
begin
  //Result := FindVkVariableBinding(VarName);
  if BindingExists(AControl, AVariable) then
    raise Exception.CreateFmt('Dublicate binding %s', [AVariable.Name])
  else
    begin
      Result := Add as TCustomVkVariableBinding;
      Result.Bind(AVariable, AControl);
    end;
end;

procedure TCustomVkVariableBindingCollection.CreateVkVariableBindingFromDummy(
  ADummyBinding: TCustomVkVariableBinding);
begin
  if ADummyBinding <> FDummyBinding then
    raise Exception.Create('DummyBinding must be same as collection DummyBinding');

  AddVkVariableBinding(FDummyBinding);
  FDummyBinding.FIsDummy := False;
  FDummyBinding.FOwnerWhenDummy := nil;

  FDummyBinding := GetVkVariableBindingClass.CreateAsDummy(Self);

end;

procedure TCustomVkVariableBindingCollection.DeleteBinding(AVar: TCustomVkVariableBinding);
begin
  if Assigned(AVar) then
    AVar.Free;
end;

procedure TCustomVkVariableBindingCollection.DeleteVkVariableBinding(const AVariable: TVkVariable);
var _Item: TCustomVkvariableBinding;
begin
  _Item := FindVkVariableBinding(AVariable);
  DeleteBinding(_Item);
end;

procedure TCustomVkVariableBindingCollection.DeleteVkVariableBinding(const AControl: TWinControl);
var _Item: TCustomVkvariableBinding;
begin
  _Item := FindVkVariableBinding(AControl);
  DeleteBinding(_Item);
end;

procedure TCustomVkVariableBindingCollection.DeleteVkVariableBinding(const VarName: string);
var _Item: TCustomVkvariableBinding;
begin
  _Item := FindVkVariableBinding(VarName);
  DeleteBinding(_Item);
end;

destructor TCustomVkVariableBindingCollection.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FDummyBinding);
end;

function TCustomVkVariableBindingCollection.FindVkVariableBinding(
  AControl: TWinControl): TCustomVkVariableBinding;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := TCustomVkVariableBinding(inherited Items[I]);
    if Result.oControl = AControl then
      Exit;
  end;
  Result := nil;
end;

function TCustomVkVariableBindingCollection.FindVkVariableBinding(
  AVariable: TCustomVkVariable): TCustomVkVariableBinding;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := TCustomVkVariableBinding(inherited Items[I]);
    if Result.Variable = AVariable then
      Exit;
  end;
  Result := nil;
end;

function TCustomVkVariableBindingCollection.FindVkVariableBinding(
  const VarName: string): TCustomVkVariableBinding;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := TCustomVkVariableBinding(inherited Items[I]);
    if SameText(Result.Variable.Name, VarName) then
      Exit;
  end;
  Result := nil;
end;

function TCustomVkVariableBindingCollection.GetInitDummyBinding(AVarName: String): TCustomVkVariableBinding;
begin
  FDummyBinding.Variable.Name := AVarName;
  Result := FDummyBinding;
end;

function TCustomVkVariableBindingCollection.GetItem(Index: Integer): TCustomVkVariableBinding;
begin
  Result := TCustomVkVariableBinding(inherited Items[Index]);
end;

function TCustomVkVariableBindingCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TCustomVkVariableBindingCollection.GetVkVariableBinding(
  const VarName: string): TCustomVkVariableBinding;
begin
  Result := FindVkVariableBinding(VarName);
end;

function TCustomVkVariableBindingCollection.GetVkVariableBindingClass: TCustomVkVariableBindingClass;
begin
  Result := TCustomVkVariableBinding;
end;

function TCustomVkVariableBindingCollection.IsEqual(Value: TCustomVkVariableBindingCollection): Boolean;
var
  I: Integer;
begin
  Result := Count = Value.Count;
  if Result then
    for I := 0 to Count - 1 do
    begin
      Result := Items[I].IsEqual(Value.Items[I]);
      if not Result then Break;
    end
end;

procedure TCustomVkVariableBindingCollection.RemoveVkVariableBinding(const AVariableBinding: TCustomVkVariableBinding);
begin
  if AvariableBinding.Collection = Self then
    AvariableBinding.Collection := nil;
end;

procedure TCustomVkVariableBindingCollection.SetItem(Index: Integer; Value: TCustomVkVariableBinding);
begin
  inherited SetItem(Index, TCollectionItem(Value));
end;

procedure TCustomVkVariableBindingCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(OnChange) then
    OnChange(Self);
end;

end.
