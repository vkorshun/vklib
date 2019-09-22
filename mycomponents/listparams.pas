unit listparams;

interface
uses
  SysUtils, Classes, variants;

type

  PParamDescription = ^RParamDescription;
  RParamDescription = record
    name: String;
    value: Variant;
  end;

  TListParams = class(TObject)
  private
    List:Tlist;
    function GetItem(aI:Integer):PParamDescription;
    function GetCount:Integer;
  public
    constructor Create;
    destructor  Destroy;override;
    procedure   Add(aName:String;v:Variant);
    procedure   Clear;
    procedure   Delete(aI:Integer);
    property    Items[i:Integer]:PParamDescription read GetItem; default;
    property    Count:Integer read GetCount;
  end;


implementation

{ TListParam }

procedure TListParams.Add(aName: String; v: Variant);
var p:PParamDescription;
begin
  p:= New(PParamDescription);
  p.name := aName;
  p.value:= v;
  List.Add(p);
end;

procedure TListParams.Clear;
begin
  while List.Count>0 do
  begin
     Delete(0);
  end;
end;

constructor TListParams.Create;
begin
  List := TList.Create;
end;

procedure TListParams.Delete(aI: Integer);
var p:PParamDescription;
begin
  p := GetItem(ai);
  Dispose(p);
  List.Delete(ai);
end;

destructor TListParams.Destroy;
begin
  if List.Count > 0 then
    Clear;
  FreeAndNil(List);
  Inherited;
end;

function TListParams.GetCount: Integer;
begin
  Result := List.Count;
end;

function TListParams.GetItem(aI:Integer): PParamDescription;
begin
  Result := PParamDescription(List[aI]);
end;


end.
