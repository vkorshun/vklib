unit Vararrayutil;

interface
uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  variants, types, varutils;

function Ascan(aV:Variant;k:variant):integer;
procedure AADD(var aV:Variant;n:Variant);
procedure SetVar(var aV:Variant;aIndex:array of smallint;value: Variant);
procedure AINS(var aV:Variant;n:integer);
procedure ADEL(var aV:Variant;n:integer);
procedure AADDM(var aV:Variant;aIndex:array of smallint;value: Variant);
function ALEN(aV:Variant):integer;
procedure VarArrayRedim2(var A: TVarData; HighBound: Integer);

implementation


procedure AADD(var aV:Variant;n: Variant);
 var la:integer;
begin
  la:=VarArrayHighBound(aV,1);
  VarArrayRedim(aV,la+1);
  aV[la+1]:=n;
end;


function Ascan(aV:Variant;k:Variant):integer;
  var i:integer;
begin
  result:=0;
  for i:=VarArrayLowBound(av,1) to VarArrayHighBound(aV,1) do begin
    if  not (VarIsEmpty(aV[i])) and not (VarIsArray(aV[i])) then
    if aV[i]=k then begin
       result:=i;
       break;
    end;
  end;
end;


{ Присвоения значения элементу многомерного массива }
procedure SetVar(var aV:Variant;aIndex:array of smallint;value: Variant);
 var aVar:array[0..20]of Variant;
     i,j,k: integer;
     V: Variant;
begin
  j:= low(aIndex);
  k:= High(aIndex);
  V:=aV;
  i:=j;
  while i<k do begin
    aVar[i]:=V[aIndex[i]];
    V:=aVar[i];
    inc(i);
  end;
  V[aIndex[k]]:=value;
  i:=k-1;
  while i>j do begin
    aVar[i]:=V;
    V:=aVar[i-1];
    V[aIndex[i]]:=aVar[i];
    dec(i);
  end;
  if k<>j then
  aV[aIndex[j]]:=V
  else aV:=V;
end;

procedure AINS(var aV:Variant;n:integer);
  var  i:integer;
begin
  if (n>=VarArrayLowBound(aV,1)) and (n<= VarArrayHighBound(aV,1)) then begin
     AADD(aV,null);
     i:=VarArrayHighBound(aV,1);
     while i>n  do begin
       aV[i]:=aV[i-1];
       dec(i);
     end;
     aV[n]:=null;
  end;
end;

procedure ADEL(var aV:Variant;n:integer);
  var i,nlen,nfirst:integer;
begin
  nFirst:= VarArrayLowBound(aV,1);
  nLen  := VarArrayHighBound(aV,1);
  if (n>=nFirst) and (n<=nLen) then begin
     for i:=n to nLen-1 do aV[i]:=aV[i+1];
     VarArrayRedim(aV,nLen-1);
  end;
end;

{ Добавление элемента в многомерном массиве}
procedure AADDM(var aV:Variant;aIndex:array of smallint;value: Variant);
 var aVar:array[0..20]of Variant;
     i,j,k: integer;
     V: Variant;
begin
  j:= low(aIndex);
  k:= High(aIndex);
  V:=aV;
  i:=j;
  while i<=k do begin
    aVar[i]:=V[aIndex[i]];
    V:=aVar[i];
    inc(i);
  end;
  AADD(V,value);
  SetVar(aV,aIndex,V);
end;

function ALEN(aV:Variant):integer;
begin
  try
  result:=VarArrayHighBound(aV,1);
  except
   result:=0
  end;
end;

{ ----------------------------------------------------- }
{       Variant array support                           }
{ ----------------------------------------------------- }

function GetVarDataArrayInfo(const AVarData: TVarData; out AVarType: TVarType;
  out AVarArray: PVarArray): Boolean;
begin
  // variant that points to another variant?  lets go spelunking
  if AVarData.VType = varByRef or varVariant then
    Result := GetVarDataArrayInfo(PVarData(AVarData.VPointer)^, AVarType, AVarArray)
  else
  begin

    // make sure we are pointing to an array then
    AVarType := AVarData.VType;
    Result := (AVarType and varArray) <> 0;

    // figure out the array data pointer
    if Result then
      if (AVarType and varByRef) <> 0 then
        AVarArray := PVarArray(AVarData.VPointer^)
      else
        AVarArray := AVarData.VArray
    else
      AVarArray := nil;
  end;
end;


procedure VarArrayRedim2(var A: TVarData; HighBound: Integer);
var
  VarBound: TVarArrayBound;
  LVarType: TVarType;
  LVarArray: PVarArray;
begin
  if not GetVarDataArrayInfo(A, LVarType, LVarArray) then
    VarResultCheck(VAR_INVALIDARG);

  with LVarArray^ do
    VarBound.LowBound := Bounds[0].LowBound;

  VarBound.ElementCount := HighBound - VarBound.LowBound + 1;

  if SafeArrayRedim(LVarArray, VarBound) <> VAR_OK then
    VarArrayCreateError;
end;

end.
