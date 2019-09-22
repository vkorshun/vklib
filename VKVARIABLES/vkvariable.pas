unit vkvariable;

interface


uses
  Classes, SysUtils, Variants, VariantUtils;

const
  SDuplicateVkVariableName = 'Dublicate variable %s';
type
  TCustomVkVariableCollection = class;

  TCustomVkVariable = class(TCollectionItem)
  private
    FData : Variant;
    FInitData: Variant;
    FOldValue: Variant;
    FIsDummy: Boolean;
    FIsDelta: Boolean;
    FName: string;
    F_Id: Integer;
    FOwnerWhenDummy: TCustomVkVariableCollection;
    function GetAsBoolean: Boolean;
    function GetAsCurrency: Currency;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Double;
    function GetAsInteger: Longint;
    function GetAsRefObject: TObject;
    function GetAsString: string;
    function GetIsNull: Boolean;
    function IsEqual(Value: TCustomVkVariable): Boolean;
    procedure SetAsBoolean(Value: Boolean);
    procedure SetAsCurrency(const Value: Currency);
    procedure SetAsDateTime(const Value: TDateTime);
    procedure SetAsFloat(const Value: Double);
    procedure SetAsInteger(Value: Longint);
    procedure SetAsRefObject(const Value: TObject);
    procedure SetAsString(const Value: string);
    procedure SetData(const Value: Variant);
    procedure SetName(const Value: string);
    procedure SetInitData(const Value: Variant);
    procedure SetOnChangevariable(const Value: TNotifyEvent);
    procedure SetOnInternalChangevariable(const Value: TNotifyEvent);
    function GetAsLargeInt: Int64;
    procedure SetAsLargeInt(const Value: Int64);
  protected
    FOnChangeVariable: TNotifyEvent;
    FOnInternalChangeVariable: TNotifyEvent;
    procedure DoChangeVariable; virtual;
    procedure DoInternalChangeVariable; virtual;
    procedure AssignTo(Dest: TPersistent); override;
    property IsDummy: Boolean read FIsDummy;

    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsInteger: LongInt read GetAsInteger write SetAsInteger;
    property AsLargeInt: Int64 read GetAsLargeInt write SetAsLargeInt;
    property AsRefObject: TObject read GetAsRefObject write SetAsRefObject;
    property AsString: string read GetAsString write SetAsString;
    property IsNull: Boolean read GetIsNull;
    property Name: string read FName write SetName;
    property Value: Variant read FData write SetData;
    property OldValue: Variant read FOldValue write FOldValue;
    property InitValue: Variant read FInitData write SetInitData;
    property IsDelta: Boolean read FIsDelta write FIsDelta;
  public
    constructor Create(Collection: TCollection); override;
    constructor CreateAsDummy(AOwnerWhenDummy: TCustomVkVariableCollection); virtual;
    function VarCollection: TCustomVkVariableCollection;
    class function IsEmptyString(const AValue: variant): Boolean;
    class function IsEmptyStringAsDate(const AValue: variant): Boolean;
    procedure Clear;
    property OnChangeVariable:TNotifyEvent read FOnChangevariable write SetOnChangevariable;
    property OnInternalChangeVariable:TNotifyEvent read FOnInternalChangevariable write SetOnInternalChangevariable;
    class var gid: Integer;
  end;

  TCustomVkVariableClass = class of TCustomVkVariable;

  TVkVariable = class(TCustomVkVariable)
  public
    property AsBoolean;
    property AsCurrency;
    property AsDateTime;
    property AsFloat;
    property AsInteger;
    property AsLargeInt;
    property AsRefObject;
    property AsString;
    property IsNull;
    property InitValue;
    property OldValue;
    property IsDelta;
  published
    property Name;
    property Value;
  end;

  TCustomVkVariableCollection = class(TCollection)
  private
    FDummyVar: TCustomVkVariable;
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
    FIsChanged: Boolean;
    function GetVkVariable(const VarName: string): TCustomVkVariable;
    function GetItem(Index: Integer): TCustomVkVariable;
    procedure DeleteVkVariable(AVar: TCustomVkVariable); overload;
    procedure SetItem(Index: Integer; Value: TCustomVkVariable);
    function GetValue(Index: Integer): Variant;
    procedure SetValue(Index: Integer; const Value: Variant);
    function GetIsChanged: Boolean;
  protected
    function GetInitDummyVar(AVarName: String): TCustomVkVariable;
    function GetOwner: TPersistent; override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure CreateVkVariableFromDummy(ADummyVar: TCustomVkVariable);
    procedure Update(Item: TCollectionItem); override;
    property DummyVar: TCustomVkVariable read FDummyVar;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(Owner: TPersistent); overload;
    destructor Destroy; override;
    procedure AddItem(const VarName: string; const AValue: TObject);overload;
    procedure AddItem(const VarName: string; const AValue: Variant);overload;
    function GetVkVariableClass: TCustomVkVariableClass; virtual;
    function CreateVkVariable(const VarName: string; const AValue: TObject): TCustomVkVariable; overload;
    function CreateVkVariable(const VarName: string; const AValue: Variant): TCustomVkVariable; overload;
    function FindVkVariable(const VarName: string) : TCustomVkVariable;
    function IndexOf(const VarName: string) : Integer;
    function IsEqual(Value: TCustomVkVariableCollection): Boolean;
    function VarExists(const VarName: string): Boolean;
    procedure InitBlank;
    procedure GetChangedList(const AList:TStrings;const ANames:TStrings = nil);
    procedure AddVkVariable(Value: TCustomVkVariable);
    procedure AssignValues(Value: TCustomVkVariableCollection);
    procedure DeleteVkVariable(const VarName: string); overload;
    procedure RemoveVkVariable(Value: TCustomVkVariable);

    property Items[Index: Integer]: TCustomVkVariable read GetItem write SetItem;
    property VkVariable[const VarName: string]: TCustomVkVariable read GetVkVariable; default;
    property Value[Index: Integer]: Variant read GetValue write SetValue;
    property IsChanged:Boolean read GetIsChanged;
  end;

  TVkVariableCollection = class(TCustomVkVariableCollection)
  private
    function GetVkVariable(const VarName: string): TVkvariable;
    function GetItem(Index: Integer): TVkVariable;
    procedure SetItem(Index: Integer; Value: TVkVariable);
  public
    function CreateVkVariable(const VarName: string; const AValue: TObject): TVkVariable; overload;
    function CreateVkVariable(const VarName: string; const AValue: Variant): TVkVariable; overload;
    function FindVkVariable(const VarName: string) : TVkVariable;
    function GetVkVariableClass: TCustomVkVariableClass; override;
    function VarByName(AName: String):TVkVariable;
    property Items[Index: Integer]: TVkVariable read GetItem write SetItem;
    property DynVar[const VarName: string]: TVkVariable read GetVkVariable; default;
  end;

implementation

uses  FMTBcd, SQLTimSt;
{ TCustomVkVariable }

procedure TCustomVkVariable.AssignTo(Dest: TPersistent);
begin
  if Dest is TCustomVkVariable then
  begin
    TCustomVkVariable(Dest).Name := Name;
    TCustomVkVariable(Dest).Value := FData;
  end else inherited AssignTo(Dest);
end;

procedure TCustomVkVariable.Clear;
begin
  FOldValue := FData;
  FData := Unassigned;
end;

constructor TCustomVkVariable.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FData := Unassigned;
  FInitData := Unassigned;
  FOldValue := Unassigned;
  Inc(gid,1);
  F_id := gid;
end;

constructor TCustomVkVariable.CreateAsDummy(AOwnerWhenDummy: TCustomVkVariableCollection);
begin
  inherited Create(nil);
  FIsDummy := True;
  FOwnerWhenDummy := AOwnerWhenDummy;
  Inc(gid,1);
  F_id := gid;
end;

procedure TCustomVkVariable.DoChangeVariable;
begin
  if Assigned(FOnChangeVariable) then
    FOnChangeVariable(self);
end;

procedure TCustomVkVariable.DoInternalChangeVariable;
begin
//  TLogWriter.Log('--Change '+IntToStr(F_Id));
  if Assigned(FOnInternalChangeVariable) then
   FOnInternalChangevariable(Self);
  DoChangeVariable;
end;

function TCustomVkVariable.GetAsBoolean: Boolean;
begin
  Result :=  IfVarEmpty(FData,False)
end;

function TCustomVkVariable.GetAsCurrency: Currency;
begin
  Result :=  IfVarEmpty(FData,0)
end;

function TCustomVkVariable.GetAsDateTime: TDateTime;
begin
  if IsNull or VariantIsEmpty(FData) or
     TCustomVkVariable.IsEmptyStringAsDate(FData)
    then Result := 0
    else Result := VarToDateTime(FData);
end;

function TCustomVkVariable.GetAsFloat: Double;
begin
  Result :=  IfVarEmpty(FData,0);
end;

function TCustomVkVariable.GetAsInteger: Longint;
begin
  Result :=  IfVarEmpty(FData,0);
end;

function TCustomVkVariable.GetAsLargeInt: Int64;
begin
  Result :=  IfVarEmpty(FData,0);
end;

function TCustomVkVariable.GetAsRefObject: TObject;
begin
  if VariantIsEmpty(FData) then
    Result := nil
  else
    Result :=  TObject(AsInteger);
end;

function TCustomVkVariable.GetAsString: string;
begin
  Result :=  IfVarEmpty(FData,'');
end;

function TCustomVkVariable.GetIsNull: Boolean;
begin
  Result := (FData = Unassigned) or VarIsNull(FData) or VarIsClear(FData);
end;

class function TCustomVkVariable.IsEmptyString(const AValue: Variant): Boolean;
begin
  case TVarData(AValue).VType of
    varOleStr: Result := TVarData(AValue).VOleStr = '';
    varString: Result := string(AnsiString(TVarData(AValue).VString))='';
    varUString: Result := UnicodeString(TVarData(AValue).VUString)='';
  else
    Result := False;
  end;
end;

class function TCustomVkVariable.IsEmptyStringAsDate(const AValue: variant): Boolean;
begin
  case TVarData(AValue).VType of
    varOleStr: Result := Trim(TVarData(AValue).VOleStr) = '.  .';
    varString: Result := Trim(string(AnsiString(TVarData(AValue).VString)))='.  .';
    varUString: Result := Trim(UnicodeString(TVarData(AValue).VUString))='.  .';
  else
    Result := False;
  end;
end;

function TCustomVkVariable.IsEqual(Value: TCustomVkVariable): Boolean;
begin
  Result := (VarType(FData) = VarType(Value.FData)) and
    (VarIsClear(FData) or (FData = Value.FData)) and
    (Name = Value.Name) and (IsNull = Value.IsNull);
end;

procedure TCustomVkVariable.SetAsBoolean(Value: Boolean);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Value) then
  begin
    OldValue := Self.Value;
    Self.Value := Value;
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetAsCurrency(const Value: Currency);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Value) then
  begin
    OldValue := Self.Value;
    Self.Value := Value;
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetAsDateTime(const Value: TDateTime);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Value) then
  begin
    OldValue := Self.Value;
    Self.Value := Value;
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetAsFloat(const Value: Double);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Value) then
  begin
    OldValue := Self.Value;
    Self.Value := Value;
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetAsInteger(Value: Integer);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Value) then
  begin
    OldValue := Self.Value;
    Self.Value := Value;
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetAsLargeInt(const Value: Int64);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Value) then
  begin
    OldValue := Self.Value;
    Self.Value := Value;
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetAsRefObject(const Value: TObject);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Integer(Value)) then
  begin
    OldValue := Self.Value;
    AsInteger := Integer(Value);
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetAsString(const Value: string);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Value) then
  begin
    OldValue := Self.Value;
    Self.Value := Value;
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetData(const Value: Variant);
begin
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  if not VariantIsEquel(Self.Value,Value) then
  begin
    OldValue := Self.Value;
    FData := Value;
    DoInternalChangeVariable;
  end;
end;

procedure TCustomVkVariable.SetInitData(const Value: Variant);
begin
  FInitData := Value;
  self.Value := FInitData;
end;

procedure TCustomVkVariable.SetName(const Value: string);
var
  _Var: TCustomVkVariable;
begin
  _Var := VarCollection.FindVkVariable(Value);
  if (_Var <> nil) and (_Var <> Self) then
    raise Exception.CreateFmt(SDuplicateVkVariableName, [Value]);
  if IsDummy then
    FOwnerWhenDummy.CreateVkVariableFromDummy(Self);
  FName := Value;
  Changed(False);
end;


procedure TCustomVkVariable.SetOnChangevariable(const Value: TNotifyEvent);
begin
  FOnChangevariable := Value;
end;

procedure TCustomVkVariable.SetOnInternalChangevariable(const Value: TNotifyEvent);
begin
  FOnInternalChangevariable := Value;
end;

function TCustomVkVariable.VarCollection: TCustomVkVariableCollection;
begin
  Result := TCustomVkVariableCollection(Collection);
end;

{ TCustomVkVariableList }

procedure TCustomVkVariableCollection.AddItem(const VarName: string;
  const AValue: TObject);
begin
  CreateVkVariable(VarName, AValue);
end;

procedure TCustomVkVariableCollection.AddItem(const VarName: string;
  const AValue: Variant);
begin
  CreateVkVariable(VarName,AValue);
end;

procedure TCustomVkVariableCollection.AddVkVariable(Value: TCustomVkVariable);
begin
  if Assigned(FindVkVariable(Value.Name)) then
    raise Exception.CreateFmt(SDuplicateVkVariableName, [Value.Name])
  else
    Value.Collection := Self;
end;

procedure TCustomVkVariableCollection.AssignTo(Dest: TPersistent);
begin
  if Dest is TCustomVkVariableCollection
    then TCustomVkVariableCollection(Dest).Assign(Self)
    else inherited AssignTo(Dest);
end;

procedure TCustomVkVariableCollection.AssignValues(Value: TCustomVkVariableCollection);
var
  I: Integer;
  P: TCustomVkVariable;
begin
  for I := 0 to Value.Count - 1 do
  begin
    P := FindVkVariable(Value.Items[I].Name);
    if P <> nil then
      P.Assign(Items[I]);
  end;
end;

constructor TCustomVkVariableCollection.Create(Owner: TPersistent);
begin
  FOwner := Owner;
  inherited Create(GetVkVariableClass);
//  ItemClass := GetVkVariableClass;
  FDummyVar := GetVkVariableClass.CreateAsDummy(Self);
end;

procedure TCustomVkVariableCollection.CreateVkVariableFromDummy(ADummyVar: TCustomVkVariable);
begin
  if ADummyVar <> FDummyVar then
    raise Exception.Create('DummyVar must be same as collection DummyVar');

  AddVkVariable(FDummyVar);
  FDummyVar.FIsDummy := False;
  FDummyVar.FOwnerWhenDummy := nil;

  FDummyVar := GetVkVariableClass.CreateAsDummy(Self);
end;

function TCustomVkVariableCollection.CreateVkVariable(const VarName: string;
  const AValue: TObject): TCustomVkVariable;
begin
  Result := CreateVkVariable(VarName, Integer(AValue));
end;

function TCustomVkVariableCollection.CreateVkVariable(const VarName: string;
  const AValue: Variant): TCustomVkVariable;
begin
  Result := FindVkVariable(VarName);
  if Assigned(Result) then
    raise Exception.CreateFmt(SDuplicateVkVariableName, [VarName])
  else
    begin
      Result := Add as TCustomVkVariable;
      Result.Name := VarName;
      Result.Value := AValue;
    end;
end;

procedure TCustomVkVariableCollection.DeleteVkVariable(AVar: TCustomVkVariable);
begin
  if Assigned(AVar) then
    AVar.Free;
end;

procedure TCustomVkVariableCollection.DeleteVkVariable(const VarName: string);
var
  _Var : TCustomVkVariable;
begin
  _Var := FindVkVariable(VarName);
  if Assigned(_Var) then
    DeleteVkVariable(_Var);
end;

destructor TCustomVkVariableCollection.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FDummyVar);
end;

function TCustomVkVariableCollection.FindVkVariable(const VarName: string): TCustomVkVariable;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := TVkVariable(inherited Items[I]);
    if SameText(Result.Name, VarName) then
      Exit;
  end;
  Result := nil;
end;

procedure TCustomVkVariableCollection.GetChangedList(const AList: TStrings; const ANames:TStrings = nil);
var i: Integer;
begin
  if not Assigned(Anames) then
  begin
  for I := 0 to Count-1 do
   if (not VariantIsEquel(Items[i].InitValue,Items[i].Value)) then
     AList.Add(Items[i].Name);
  end
  else
  begin
    for I := 0 to ANames.Count-1 do
     if (not VariantIsEquel(VkVariable[ANames[i]].InitValue,VkVariable[ANames[i]].Value)) then
       AList.Add(ANames[i]);
  end;
end;

function TCustomVkVariableCollection.GetInitDummyVar(AVarName: String): TCustomVkVariable;
begin
  FDummyVar.FName := AVarName;
  Result := FDummyVar;
end;

function TCustomVkVariableCollection.GetIsChanged: Boolean;
{  function CompareVariants(V1,V2: Variant):Integer;
  begin
    if VarTypeOf(V1)=VarTypeOf(V2) then

  end; }
var i: Integer;
begin
  Result := False;
  try
    for I := 0 to Count-1 do
     if (VarCompareValue(Items[i].InitValue,Items[i].Value)<> vrEqual) and not( VariantIsNull(Items[i].InitValue) and
       VariantIsNull(Items[i].Value))
      then
     begin
       Result := True;
       Break;
     end;
  except
    on E: Exception do
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TCustomVkVariableCollection.GetItem(Index: Integer): TCustomVkVariable;
begin
  Result := TCustomVkVariable(inherited Items[Index]);
end;

function TCustomVkVariableCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TCustomVkVariableCollection.GetValue(Index: Integer): Variant;
begin
  Result := Items[Index].Value;
end;

function TCustomVkVariableCollection.GetVkVariable(const VarName: string): TCustomVkVariable;
var
  _Var : TCustomVkVariable;
begin
  _Var := FindVkVariable(VarName);
  if _Var <> nil then
    Result := _Var
  else
    Result := GetInitDummyVar(VarName);
end;

function TCustomVkVariableCollection.GetVkVariableClass: TCustomVkVariableClass;
begin
  Result := TCustomVkVariable;
end;

function TCustomVkVariableCollection.IndexOf(const VarName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if SameText(TVkVariable(inherited Items[I]).Name, VarName) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TCustomVkVariableCollection.InitBlank;
var i: Integer;
begin
  for i:=0 to Count-1 do
    Items[i].InitValue := null;
end;

function TCustomVkVariableCollection.IsEqual(Value: TCustomVkVariableCollection): Boolean;
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

procedure TCustomVkVariableCollection.RemoveVkVariable(Value: TCustomVkVariable);
begin
  if Value.Collection = Self then
    Value.Collection := nil;
end;

procedure TCustomVkVariableCollection.SetItem(Index: Integer; Value: TCustomVkVariable);
begin
  inherited SetItem(Index, TCollectionItem(Value));
end;

procedure TCustomVkVariableCollection.SetValue(Index: Integer; const Value: Variant);
begin
  Items[Index].Value := Value;
end;

procedure TCustomVkVariableCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(OnChange) then
    OnChange(Self);
end;

function TCustomVkVariableCollection.VarExists(const VarName: string): Boolean;
begin
  Result := (FindVkVariable(VarName) <> nil);
end;

{ TVkVariableCollection }

function TVkVariableCollection.CreateVkVariable(const VarName: string; const AValue: TObject): TVkVariable;
begin
  Result := TVkVariable(inherited CreateVkVariable(VarName, AValue));
end;

function TVkVariableCollection.CreateVkVariable(const VarName: string; const AValue: Variant): TVkVariable;
begin
  Result := TVkVariable(inherited CreateVkVariable(VarName, AValue));
end;

function TVkVariableCollection.FindVkVariable(const VarName: string): TVkVariable;
begin
  Result := TVkVariable(inherited FindVkVariable(VarName));
end;

function TVkVariableCollection.GetItem(Index: Integer): TVkVariable;
begin
  Result := TVkVariable(inherited Items[Index]);
end;

function TVkVariableCollection.GetVkVariable(const VarName: string): TVkvariable;
begin
  Result := TVkVariable(inherited VkVariable[VarName]);
end;

function TVkVariableCollection.GetVkVariableClass: TCustomVkVariableClass;
begin
  Result := TVkVariable;
end;

procedure TVkVariableCollection.SetItem(Index: Integer; Value: TVkVariable);
begin
  inherited Items[Index] := Value;
end;

function TVkVariableCollection.VarByName(AName: String): TVkVariable;
begin
  Result := FindVkVariable(AName);
end;

initialization
  TCustomVkVariable.gid := 0;
end.
