unit IntList;

interface

uses
  SysUtils, Classes, Controls, Generics.Collections;

type

TCustomIntList = TList<Integer>;
TCustumLargeIntList= TList<Int64>;

{TCustomIntList = class (TObject)
private
  FList: TList;
  procedure SetInteger(i,v: integer);
  function  GetInteger(i: integer): integer;
  function  GetCount: integer;
public
  constructor Create;
  destructor  Destroy;override;
  procedure DoSort;
  procedure Add(i:integer);
  procedure Clear;
  procedure Delete(i: integer);
  procedure Invert(aI:Integer);

  property  Item[i: integer]:integer read GetInteger write SetInteger;default;
  property  Count: integer read GetCount;
  function  IndexOf(i: integer): integer;
end;

TCustomRecordList<T> = class(TList)
public
  procedure Add(aP:Pointer=nil);
//  function GetRecord(aIndex:Integer):T;
  procedure SetItem(i: integer; p:T);
  function  GetItem(i: integer): T;
  procedure Clear;
  procedure Delete(aIndex:Integer);
  destructor Destroy;override;
  property  Items[i: integer]:T read GetItem write SetItem;default;
end;

TCustomLargeIntList = class(TObject)
private
  FList: TList;
  procedure SetLargeInt(i:Integer;v: int64);
  function  GetLargeInt(i: integer): int64;
  function  GetCount: integer;
public
  constructor Create;
  destructor  Destroy;override;
  procedure DoSort;
  procedure Add(ai:int64);
  procedure Clear;
  procedure Delete(i: integer);
  procedure Invert(aI:Integer);

  property  Item[i: integer]:int64 read GetLargeInt write SetLargeInt;default;
  property  Count: integer read GetCount;
  function  IndexOf(ai: integer): integer;
end;
//TCustomLargeIntList = class(TList<Int64>);
    }
implementation


{ TCustomIntList }

  function fCompare(Item1, Item2: Pointer): integer;
  begin
    Result := 0;
    if (PInteger(Item1)^ > PInteger(Item2)^) then
      Result := 1;
    if PInteger(Item1)^ = PInteger(Item2)^ then
      Result := 0;
    if PInteger(Item1)^ < PInteger(Item2)^ then
      Result := -1;
  end;

  function fCompare64(Item1, Item2: Pointer): integer;
  begin
    Result := 0;
    if (PInt64(Item1)^ > PInt64(Item2)^) then
      Result := 1;
    if PInt64(Item1)^ = PInt64(Item2)^ then
      Result := 0;
    if PInt64(Item1)^ < PInt64(Item2)^ then
      Result := -1;
  end;

{
procedure TCustomIntList.Add(i: integer);
var p: Pinteger;
begin
  New(p);
  p^ := i;
  FList.Add(p);
end;

procedure TCustomIntList.Clear;
begin
  while FList.Count >0 do Delete(0);
end;

constructor TCustomIntList.Create;
begin
  Inherited;
  FList := TList.Create;
end;

procedure TCustomIntList.Delete(i: integer);
var p: Pinteger;
begin
  p := Pinteger(FList.Items[i]);
  Dispose(p);
  FList.Delete(i);
end;

destructor TCustomIntList.Destroy;
begin
  while FList.Count > 0 do Delete(0);
  FList.Free;
  Inherited;
end;

procedure TCustomIntList.DoSort;
begin
  FList.Sort(fCompare);
end;

function TCustomIntList.GetCount: integer;
begin
  Result := FList.Count;
end;

function TCustomIntList.GetInteger(i: integer): integer;
begin
  Result := Pinteger(FList.Items[i])^;
end;

function TCustomIntList.IndexOf(i: integer): integer;
var k: integer;
begin
  Result := -1;
//  Assert(FList = nil, 'List not defined!' );
  if not Assigned(FList) then
  begin
    Result := -1;
    Exit;
  end;
  for k:=0 to Pred(FList.Count) do
    if GetInteger(k) = i then
    begin
      Result := k;
      Break;
    end;
end;

procedure TCustomIntList.Invert(aI: Integer);
var i:Integer;
begin
  i:= IndexOf(ai);
  if i=-1 then
    Add(aI)
  else
    Delete(i);
end;

procedure TCustomIntList.SetInteger(i, v: integer);
begin
  PInteger(FList.Items[i])^:= v;
end;


}
{ TCustomRecordList<T> }

{
procedure TCustomRecordList<T>.Add(aP:Pointer=nil);
var p:^T;
begin
  if Assigned(aP) then
    p := aP
  else
    New(p);
    TList(self).Add(p);
//  end;
end;

procedure TCustomRecordList<T>.Clear;
begin
  while Count>0  do
   Delete(0);
end;

procedure TCustomRecordList<T>.Delete(aIndex: Integer);
var p:^T;
begin
   p := TList(self).Items[aIndex];
   Dispose(p);
   TList(self).Delete(0);
end;

destructor TCustomRecordList<T>.Destroy;
begin
  while count>0 do
     delete(0);
  inherited;
end;

function TCustomRecordList<T>.GetItem(i: integer): T;
var p: ^T;
begin
  p :=   pointer(TList(self).Items[i]);
  Result := T(p^);
end;

procedure TCustomRecordList<T>.SetItem(i: integer; p: T);
begin

end;
}
{function TCustomRecordList<T>.GetRecord<T>(aIndex: Integer): T;
var p:^T;
begin
  p := (TList(self).Items[aIndex]);
  Result := p^;
end; }

{ TCustomLargeIntList }
{
procedure TCustomLargeIntList.Add(ai: int64);
var p:PInt64;
begin
   New(p);
   p^ := ai;
   FList.Add(p);
end;

procedure TCustomLargeIntList.Clear;
begin
  while FList.Count >0 do Delete(0);
end;

constructor TCustomLargeIntList.Create;
begin
  FList := TList.Create;
end;

procedure TCustomLargeIntList.Delete(i: integer);
begin
  Dispose(FList[i]);
  FList.Delete(i);
end;

destructor TCustomLargeIntList.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  inherited;
end;

procedure TCustomLargeIntList.DoSort;
begin
  FList.Sort(fCompare64);
end;

function TCustomLargeIntList.GetCount: integer;
begin
  Result := FList.Count;
end;

function TCustomLargeIntList.GetLargeInt(i: integer): int64;
var p: PInt64;
begin
  p := FList[i];
  Result := p^;
end;

function TCustomLargeIntList.IndexOf(ai: integer): integer;
var k: integer;
begin
  Result := -1;
//  Assert(FList = nil, 'List not defined!' );
  if not Assigned(FList) then
  begin
    Result := -1;
    Exit;
  end;
  for k:=0 to Pred(FList.Count) do
    if GetLargeInt(k) = ai then
    begin
      Result := k;
      Break;
    end;
end;

procedure TCustomLargeIntList.Invert(aI: Integer);
var i:Integer;
begin
  i:= IndexOf(ai);
  if i=-1 then
    Add(aI)
  else
    Delete(i);
end;

procedure TCustomLargeIntList.SetLargeInt(i:Integer; v: int64);
begin
  PInt64(FList[i])^:= v;
end;
}
end.
