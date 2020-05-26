unit variantutils;

interface
uses Windows, SysUtils, types, variants,varutils,FMTBcd, SQLTimSt;

function VariantIsEquel(const v1,v2:Variant):Boolean;
function VariantIsEmpty(const AData:variant):Boolean;
function VariantToStr(const AData:Variant):String;
function IfVarEmpty(const Adata1,Adata2:Variant):Variant;
function VariantIsEmptyAsDate(const AData:Variant):Boolean;
function VariantIsNull(AData:Variant): Boolean;


implementation

function VariantIsEmpty(const AData:variant):Boolean;
begin
  if (VarIsArray(AData)) then
  begin
    Result := VarArrayHighBound(AData,1)>0;
  end
  else
  case TVarData(AData).VType of
    varEmpty, varNull: Result := True;
    varBoolean: Result := TVarData(AData).VBoolean = False;
    varShortInt: Result := TVarData(AData).VShortInt = 0;
    varSmallint: Result := TVarData(AData).VSmallInt = 0;
    varInteger: Result := TVarData(AData).VInteger = 0;
    varSingle: Result := TVarData(AData).VSingle = 0;
    varDouble: Result := TVarData(AData).VDouble = 0;
    varCurrency: Result := TVarData(AData).VCurrency = 0;
    varDate: Result := TVarData(AData).VDate = 0;
    varOleStr: Result := TVarData(AData).VOleStr = '';
    varUnknown: Result := True;
    varByte: Result := TVarData(AData).VByte = 0;
    varWord: Result := TVarData(AData).VWord = 0;
    varLongWord: Result := TVarData(AData).VLongWord = 0;
    varInt64: Result := TVarData(AData).VInt64 = 0;
    varUInt64: Result := TVarData(AData).VUInt64 = 0;
    varString: Result := string(AnsiString(TVarData(AData).VString))='';
    varUString: Result := UnicodeString(TVarData(AData).VUString)='';
//    271,272,273: Result := Value;
  else
    if ( TVarData(AData).VType = varFMTBcd ) then Result := AData=0 else
    if (TVarData(AData).VType = varSQLTimeStamp) then Result :=
       SQLTimeStampToDateTime(VarToSQLTimeStamp(AData))=0
    else
    if (TVarData(AData).VType = varSQLTimeStampOffset) then Result :=
         SQLTimeStampOffsetToDateTime(VarToSQLTimeStampOffset(AData))=0
    else
      raise Exception.Create('Invalid Type cast');
  end;
end;

function VariantIsEquel(const v1,v2:Variant):Boolean;
begin
  if TVarData(v1).VType = TVarData(v2).VType then
    Result := v1=v2
  else
    Result := VariantToStr(v1) = VariantToStr(v2);
end;

function VarArrayToStr(const AData:Variant):String;
var i: Integer;
    sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  sb.Append('{');
  try
    for i:=VarArrayLowBound(AData,1) to VarArrayHighBound(AData,1) do
    begin
      sb.Append(VariantToStr(AData[i]));
      if i<VarArrayHighBound(AData,1) then
        sb.Append(',');
    end;
    sb.Append('}');
  finally
    Result :=  sb.ToString;
    sb.Free;
  end;

end;

function VariantToStr(const AData:Variant):String;
begin
  if VarIsArray(AData) then
  begin
    Result := VarArrayToStr(AData);
  end
  else
  case TVarData(AData).VType of
    varEmpty, varNull: Result := '';
    varBoolean: Result := 'False';
    varString,
    varUString: Result := AData;
    varDate: Result := DateTimeToStr(TVarData(AData).VDate);
    varShortInt,
    varSmallint,
    varInteger,
    varSingle,
    varByte,
    varWord,
    varLongWord,
    varInt64,
    varUInt64: Result := IntToStr(AData);
    varDouble,
    varCurrency: Result := FloatToStr(AData);
    varOleStr: Result := AData;
    varUnknown: Result := '';
//    271,272,273: Result := Value;
  else
    if ( TVarData(AData).VType = varFMTBcd ) then Result := AData else
    if (TVarData(AData).VType = varSQLTimeStamp) then Result := AData
    else
    if (TVarData(AData).VType = varSQLTimeStampOffset) then Result := AData
    else
      raise Exception.Create('Invalid Type cast');
  end;

end;

function IfVarEmpty(const AData1,AData2:Variant):Variant;
begin
  if VariantIsNull(AData1) or VariantIsEmpty(AData1) or
    VariantIsEmptyAsDate(AData1) then
    Result := AData2
  else
    Result := AData1;

end;

function VariantIsNull(AData:Variant): Boolean;
begin
  if VarIsArray(AData) then
    Result := False
  else
    Result :=  VarIsNull(AData) or (AData = Unassigned);
end;

function VariantIsEmptyAsDate(const AData:Variant):Boolean;
begin
  case TVarData(AData).VType of
    varOleStr: Result := Trim(TVarData(AData).VOleStr) = '.  .';
    varString: Result := Trim(string(AnsiString(TVarData(AData).VString)))='.  .';
    varUString: Result := Trim(UnicodeString(TVarData(AData).VUString))='.  .';
  else
    Result := False;
  end;
end;
end.
