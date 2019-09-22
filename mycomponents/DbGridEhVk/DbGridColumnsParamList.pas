unit DbGridColumnsParamList;

interface
uses classes,SysUtils, Registry, windows,generics.collections, generics.defaults ;

type

  PItemDbGridColumnsParam  = ^RItemDbGridColumnsParam;
  RItemDbGridColumnsParam = record
    name: String;
    id: Integer;
    width: Integer;
  end;

//  TItemDbGridColumnsParamComparer = class (TInterfecedObject,IComparer<PItemDbGridColumnsParam>)

  TDbGridColumnsParamList = class(TObject)
  private
    FList: TList<PItemDbGridColumnsParam>;
    FbInit: Boolean;
    FRegKey: String;
    function GetItem(aI:Integer):PItemDbGridColumnsParam;
    function GetLast:PItemDbGridColumnsParam;
    function GetCount:Integer;
    procedure SetRegKey(const Value: String);
  public
    constructor Create;
    destructor Destroy;override;
    property bInit:Boolean read FbInit write FbInit;
    property Count:Integer read GetCount;
    property Items[aI:Integer]:PItemDbGridColumnsParam read GetItem; default;
    property Last:PItemDbGridColumnsParam read GetLast;
    procedure AddItem;
    procedure Add(aName:String; aId:Integer; aWidth:Integer);
    procedure Sort;
    procedure Delete(aI:Integer);
    procedure Clear;
    function IndexOf(aname:String):Integer;
    procedure InitFromReg;
    procedure SaveToReg;

    property RegKey:String read FRegKey write SetRegKey;
    property List:TList<PItemDbGridColumnsParam> read FList;
  end;
  function fCompare(const p1, p2:PItemDbGridColumnsParam): Integer;

implementation

{ TListDbGridColumnsParams }

procedure TDbGridColumnsParamList.Add(aName: String; aId, aWidth: Integer);
begin
  AddItem;
  Last.name := aName;
  Last.id   := aId;
  Last.width:= aWidth;
end;

procedure TDbGridColumnsParamList.AddItem;
var p: PItemDbGridColumnsParam;
begin
  New(p);
  FList.Add(p);
end;

procedure TDbGridColumnsParamList.Clear;
begin
  while FList.Count>0 do
  begin
    Delete(0);
  end;
end;


constructor TDbGridColumnsParamList.Create;
begin
  inherited;
  FList := TList<PItemDbGridColumnsParam>.Create;
  FbInit := False;
end;

procedure TDbGridColumnsParamList.Delete(aI: Integer);
begin
  Dispose(GetItem(aI));
  FList.Delete(aI);
end;

destructor TDbGridColumnsParamList.Destroy;
begin
  if FList.Count>0 then
    Clear;
  FList.Free;
end;

function TDbGridColumnsParamList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDbGridColumnsParamList.GetItem(aI: Integer): PItemDbGridColumnsParam;
begin
  Result := FList[aI];
end;

function TDbGridColumnsParamList.GetLast: PItemDbGridColumnsParam;
begin
  if FList.Count>0 then
    Result := Flist[FList.Count-1]
  else
    Result := nil;
end;

function TDbGridColumnsParamList.IndexOf(aname: String): Integer;
var i: Integer;
begin
  Result := -1;
  for i := 0 to FList.Count - 1 do
   if UpperCase(FList[i].name)= UpperCase(aName) then
   begin
     Result := i;
     Break;
   end;

end;



procedure TDbGridColumnsParamList.InitFromReg;
var Reg: TRegistry;
    i:Integer;
    KeyList: TStringList;
begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey(FregKey,True);
  KeyList := TStringList.Create;
  try
    Reg.GetKeyNames(KeyList);
    if KeyList.Count>0 then
    begin
      for i := 0 to KeyList.Count - 1 do
      begin
        Reg.OpenKey(FRegKey+KeyList[i],True);
        Add(KeyList[i],Reg.ReadInteger('id'),Reg.ReadInteger('width'));
      end;
      bInit := True;
    end;
    Sort;

  finally
    KeyList.Free;
    Reg.Free;
  end;

end;


procedure TDbGridColumnsParamList.SaveToReg;
var Reg: TRegistry;
    i:Integer;
begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey(FRegKey,True);
  for i := 0 to Count - 1 do
  begin
    Reg.OpenKey(FRegKey+Items[i].name,True);
    Reg.WriteInteger('id',Items[i].id);
    Reg.WriteInteger('width',Items[i].width);
  end;

  Reg.Free;
end;

procedure TDbGridColumnsParamList.SetRegKey(const Value: String);
begin
  FRegKey := Value;
end;

procedure TDbGridColumnsParamList.Sort;
begin
  FList.Sort(TComparer<PItemDbGridColumnsParam>.Construct(fCompare));
end;

function fCompare(const p1, p2: PItemDbGridColumnsParam): Integer;
begin
  if PItemDbGridColumnsParam(p1).id>PItemDbGridColumnsParam(p2).id then
     Result :=1
  else
    Result := 0;
end;

end.
