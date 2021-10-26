unit xbase_utils;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Vcl.Controls,StrUtils,
  Vcl.StdCtrls,Vcl.Forms, Vcl.Dialogs, Variants, winsock, math, Db, variantvalue, Generics.Collections  ;

function XbaseStrToFloat(const aStr:String):Extended;
function XbaseFloatToStr(const aFloat:Extended):String;

implementation


function XbaseStrToFloat(const aStr:String):Extended;
var s: String;
begin
  s := StringReplace(aStr,'.',FormatSettings.DecimalSeparator,[rfReplaceAll]);
  if length(Trim(s))=0 then
    Result := 0
  else
    Result := StrToFloat(s);
end;

function XbaseFloatToStr(const aFloat:Extended):String;
begin
  Result := FloatToStr(aFloat);
  Result := StringReplace(Result,FormatSettings.DecimalSeparator,'.',[rfReplaceAll]);
end;

end.
