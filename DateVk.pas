unit DateVk ;
interface

uses
  SysUtils,Windows,  Messages, Classes, Vcl.Controls,StrUtils,
  Vcl.StdCtrls,Vcl.Forms, Vcl.Dialogs, Variants, winsock, math, Db, variantvalue,
  Generics.Collections, DecimalRounding_JH1, AnsiStrings  ;

type
TMyVariantOnSetValue = procedure(Sender:TObject;aControl:TWinControl;var v:Variant ) of object;

LargeInt = Int64;
TLargeInt = LargeInt;
TVariantValue= TCustomVariantValue;
TIntList     = TList<Integer>;
TLargeIntList = TList<Int64>;
//TRecordList<T>  = class (TCustomRecordList<T>);

function FirstDateMonth(d:TdateTime):TdateTime;
function LastDateMonth(d:TdateTime):TdateTime;
function StrDatePeriod(d:TdateTime):String;
function DataWrite(d:TdateTime):String;
function YearMonthWrite(const ym:String):String;
function YearMonth(d:TdateTime):String;
function StoDate(const s:String):TDateTime;
function CTOD(const s:String):TDateTime;
function GetNextYearMonth(const cYm: String; n: Integer): String;

function F_D_Month(d:Tdatetime;n:integer):TdateTime;
function IsDigit(s:String; lInteger: Boolean): Boolean;
//function PadL(s: string; c: char; nLen : byte): String;
function GetWpMonth(Text: string): string;
function seconds:double;
function seconds_ml:real;
function IfThen(lv,lr1,lr2:boolean):Boolean;overload;
function IfThen(lv:Boolean;const sr1,sr2:String):String;overload;
function IfThen(lv:Boolean;d1,d2: TDateTime): TDateTime;overload;
function IfThen(lv:Boolean;const v1,v2: Variant):Variant;overload;
function DTos(d:TDateTime):String;
function fMax(e1,e2:extended):extended;
function Ext_Max(d1,d2:double):Double;
procedure ExValid(b:boolean; smsg : String);
function Space(n: Integer): String;

function CheckDecimalSeparator(const s:String):String;
function CoalEsce(const v1,v2: Variant):Variant;
function VIsEmpty(v: Variant):Boolean;
function KodObjectIsEmpty(v: Variant):Boolean;

function Padl(const s:String;count:Integer;c:char=' '):String;
function PadR(const s:String;count:Integer;c:char=' '):String;
function Right(const s:string;count :Integer):String;
function Left(const s:string;count :Integer):String;
function Month(d:tDateTime):word;
function Coal1(d:double):double;
function MyDiv(d1,d2:Variant):double;
function Replicate(const aStr:String; nCount:Integer):String;
function StrZero(i,l:Integer):String;overload;
function StrZero(i,l:Int64):String;overload;
function Str11(d:Integer):String;
function NameLock(cDir,cExt:string;WithFirft:boolean=false):string;
//function ChangeExt(const cFileName,cExt:String):String;
function FirstToken(const s:String):String;
function GetExcelColumnName(aI: Integer):String;
function GetUNCName(PathStr: string): string;
//function get_ip_address(aName:String):longint;
function HostToIP(Name: Ansistring; var Ip: string): Boolean;
function CheckDirName(const aDir:String):String;
function RoundFloat(var Value, RoundToNearest: Double): Double;
function IbRound( Value: Double; Dec: Integer ): Double;
function DoubleRound( Value: Double; Dec: Integer ): Double;
procedure SetYesNo(cmb: TComboBox; nCount:Integer = 2);
function XbaseKeyFound(nKey, nStatus: Integer): Integer;
function GetCharFromVirtualKey(Key: Word): string;
function FindForm(aComponent:TWinControl):TForm;
function IfZero(d1,d2: double):double;


var bMessage: Boolean;

implementation
//uses  ComCtrls, selectmeditbox;

function FirstDateMonth(d:TdateTime):TdateTime;
  var Year, Month, Day: Word;
 begin
  DecodeDate(d, Year, Month, Day);
  Day:=1;
  result:=EncodeDate(Year,Month,Day)
end;

function LastDateMonth(d:TdateTime):TdateTime;
  var Year, Month, Day: Word;
 begin
  DecodeDate(d, Year, Month, Day);
  day:=1;
  IF (Month=12) then begin
    Month:=1;
    inc(Year);
  end else inc(Month);
  result:=EncodeDate(Year,Month,Day);
  result:=result-1;
end;

function StrDatePeriod(d:TdateTime):String;
  var Year, Month, Day: Word;
 begin
  DecodeDate(d, Year, Month, Day);
  result:=FormatSettings.LongMonthNames[Month]+IntToStr(Year);
end;

function YearMonth(d:TdateTime):String;
  var Year, Month, Day: Word;
begin
  DecodeDate(d, Year, Month, Day);
  if Month<10 then
    Result := IntToStr(Year)+'0'+IntToStr(Month)
  else
    Result := IntToStr(Year)+IntToStr(Month);
end;

function DataWrite(d:TdateTime):String;
  var Year, Month, Day: Word;
      aM:array[1..12]of String;
 begin
  DecodeDate(d, Year, Month, Day);
  aM[1]:=' Января ';
  aM[2]:=' Февраля ';
  aM[3]:=' Марта ';
  aM[4]:=' Апреля ';
  aM[5]:=' Мая ';
  aM[6]:=' Июня ';
  aM[7]:=' Июля ';
  aM[8]:=' Августа ';
  aM[9]:=' Сентября ';
  aM[10]:=' Октября ';
  aM[11]:=' Ноября ';
  aM[12]:=' Декабря ';
  result:=IntToStr(Day)+aM[Month]+IntToStr(Year)+' г.';
end;

function YearMonthWrite(const ym:String):String;
var
  aM:array[1..12]of String;
  Month: word;
begin
  aM[1]:=' Январь ';
  aM[2]:=' Февраль ';
  aM[3]:=' Март ';
  aM[4]:=' Апрель ';
  aM[5]:=' Май ';
  aM[6]:=' Июнь ';
  aM[7]:=' Июль ';
  aM[8]:=' Август ';
  aM[9]:=' Сентябрь ';
  aM[10]:=' Октябрь ';
  aM[11]:=' Ноябрь ';
  aM[12]:=' Декабрь ';
  if length(ym)>=6 then
  begin
    Month := StrToInt(Copy(ym,5,2));
    result:=aM[Month]+Copy(ym,1,4)+' г.';
  end
  else
    result := '';
end;


function F_D_Month(d:TDateTime;n:integer):TdateTime;
var
  m,y,dy: word;
  st: string;
begin
  DecodeDate(d,y,m,dy);
//  m:=MONTH(d);
//  y:=YEAR(d);
  dy:=n div 12;
  n:= n- 12*dy;
  m:= m+n;
  y:= y+dy;
  if m<1 then begin
     y:=y-1;
     m:=m+12;
  end;
  if m>12 then begin
     y:=y+1;
     m:=m-12;
  end;
  st:='01.'+IntToStr(m)+'.'+IntToStr(y);
  result:=StrToDate(st);
end;


function DTos(d:TDateTime):String;
var
  m,y,dy: word;
  st: string;
begin
  DecodeDate(d,y,m,dy);
  Result:= IntToStr(y);
  while Length(Result)<4 do
    Result := '0'+Result;
  st :=IntToStr(m);
  if length(st)=1 then st:='0'+st;
  Result := Result + st;
  st :=IntToStr(dy);
  if length(st)=1 then st:='0'+st;
  Result := Result + st;
end;

{ Является ли строка числом }
function IsDigit(s: string; lInteger: boolean): Boolean;
var i:integer;
    bMinus, bComa: byte;
begin
  s := Trim(s);
  bcoma:= 0;
  bMinus := 0;
  Result := (length(s) > 0 );

  for i:=1 to Length(s) do begin
    if (pos(s[i],'0123456789') = 0) then begin
      if lInteger then begin
        Result := False;
        Exit;
      end else begin
        if s[i] = FormatSettings.DecimalSeparator then
          inc(bComa);
        if s[i] = '-' then
          inc(bMinus);
        if (bComa >1) or ((bMinus= 1) and (i >0) ) then begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

{function PadL(s: string; c: char; nlen: byte): String;
begin
  while length(s) < nlen do
    s:= c + s;
 Result := Copy(s,1,nlen);
end;}

function GetWpMonth(Text: string): string;
var sm: string;
begin
    sm := copy(Text,1,2);
    if sm = '01' then
      sm := 'Январь';
    if sm = '02' then
      sm := 'Февраль';
    if sm = '03' then
      sm := 'Март';
    if sm = '04' then
      sm := 'Апрель';
    if sm = '05' then
      sm := 'Май';
    if sm = '06' then
      sm := 'Июнь';
    if sm = '07' then
      sm := 'Июль';
    if sm = '08' then
      sm := 'Август';
    if sm = '09' then
      sm := 'Сентябрь';
    if sm = '10' then
      sm := 'Октябрь';
    if sm = '11' then
      sm := 'Ноябрь';
    if sm = '12' then
      sm := 'Декабрь';

    Result := copy(Text,3,4)+'г. '+ sm;
end;

//************************************
//  Секунды
//************************************
function seconds:double;export;
{  var h,m,s,ms: word;
      tt:TdateTime;}
begin
 { tt:=now;
  DecodeTime(tt,h,m,s,ms);
  result:=h*3600+m*60+s+ms*0.001  ;}
  Result:= GetTickCount / 1000  ;
end;

function seconds_ml:real;export;
begin
  Result:= GetTickCount / 1000  ;
end;


function IfThen(lv,lr1,lr2: Boolean): Boolean;
begin
  if lv then
    Result := lr1
  else
    Result := lr2;
end;

function fMax(e1,e2:Extended):Extended;
begin
  if e1>=e2 then
    Result := e1
  else
    Result := e2;
end;



function IfThen(lv:Boolean;const sr1,sr2:String):String;
begin
  if lv then
    Result := sr1
  else
    Result := sr2;
end;

function IfThen(lv:Boolean;const v1,v2:Variant):Variant;
begin
  if lv then
    Result := v1
  else
    Result := v2;
end;


function IfThen(lv:Boolean;d1,d2: TDateTime): TDateTime;
begin
  if lv then
    Result := d1
  else
    Result := d2;
end;

function Ext_Max(d1,d2:double):Double;
begin
  if d1 < d2 then
    Result := d2
  else
    Result := d1;
end;

procedure ExValid(b:boolean; smsg : String);
begin
  if not b then
    Raise Exception.Create(smsg);
end;

function CheckDecimalSeparator(const s:String):String;
begin
  if FormatSettings.DecimalSeparator<>'.' then
    Result := ReplaceStr(s,'.',FormatSettings.DecimalSeparator)
  else
    Result := s;
end;

function CoalEsce(const v1,v2: Variant):Variant;
begin
  if (v1=null) or varIsnull(v1)   then
     Result :=v2
  else
  begin
    if VarIsStr(v1) and (v1='') and not VarIsStr(v2) then
       Result := v2
    else
    begin
      if VarIsStr(v1) and VarIsNumeric(v2) then
        Result := CheckDecimalSeparator(v1)
      else
        Result := v1;
    end;
  end;
end;

function PadR(const s:String;count:Integer;c:char=' '):String;
var k: Integer;
begin
  k:= Length(s);
  if  k > count then
  begin
    Result := Copy(Result,1,count);
  end
  else
  begin
    Result := s+space(count-k);
  end;
end;

function PadL(const s:String;count:Integer;c:char=' '):String;
var k: Integer;
begin
  k:= Length(s);
  if  k > count then
  begin
    Result := Copy(s,1,count);
  end
  else
  begin
    Result :=Space(Count-k)+s;
  end;
end;

function VIsEmpty(v: Variant):Boolean;
begin
  Result := varIsEmpty(v) or VarIsClear(v) or varIsNull(v);
  if not Result then
  begin
    if (VarType(v) and varString) = varString then
      Result := (Trim(v)='') or (Trim(v)='.  .');
  end;
end;

function KodObjectIsEmpty(v: Variant):Boolean;
begin
  Result := True;
  try
    Result := (v=0) or (v=5);
  except
    ShowMessage(' Bad value v-'+v);
  end;
end;


function Month(d:tDateTime):word;
var   m,y,dy: word;
begin
  DecodeDate(d,y,m,dy);
  Result := m;
end;

function Coal1(d:double):double;
begin
  if d=0 then
    Result:=1
  else
    Result := d;
end;

function MyDiv(d1,d2:variant):double;
begin
  d1:=coalesce(d1,0);
  d2:=coalesce(d2,0);
  if d2<>0 then
    Result := d1/d2
  else
    Result := d1;
end;

function Replicate(const aStr:String; nCount:Integer):String;
var i: Integer;
begin
  Result := aStr;
  for I := 1 to nCount - 1 do
    Result := Result + aStr;
end;

function StrZero(i,l:Integer):String;
begin
  Result := intToStr(i);
  Result :=  StringOfChar('0',l-Length(Result))+Result;
end;

function StrZero(i,l:Int64):String;
begin
  Result := intToStr(i);
  Result :=  StringOfChar('0',l-Length(Result))+Result;
end;

function Right(const s:string; count:Integer):String;
var nLen:Word;
begin
  nLen := Length(s)-count+1;
  if nLen<1 then nLen:=1;
  Result := Copy(s,nLen,Count)
end;

function Left(const s:string; count:Integer):String;
begin
  Result := Copy(s,1,Count)
end;

// Уникальное имя файла
function NameLock(cDir,cExt:string;WithFirft:boolean=false):string;
var t,iError: integer;
    Hour,Min,Sec,Msec,MsecOld: Word;
begin
  iError:=0;
  while iError<10 do  begin
    DecodeTime(Now, Hour, Min, Sec, MSec);
    MsecOld := sec;
    while sec=MSecOld do DecodeTime(Now, Hour, Min, Sec, MSec);
    t:= (Hour*10+Min)*100+Sec;
    if WithFirft then begin
      result:=cDir+IntToStr(t)+'.'+cExt;
    end else begin
      if cDir[Length(Cdir)]<>'\' then cDir := cDir +'\';
      result:=cDir+'tmp'+IntToStr(t)+'.'+cExt;
    end;
    if FileExists(result)
      then inc(iError)
      else break;
  end;
end;

{function ChangeExt(const cFileName,cExt:String):String;
var curExt:String;
begin
  curExt := ExtractFileExt(cFileName);
  Result := Copy(cFileName,1,length(cFilename)-length(curExt))+cExt;
end; }

function FirstToken(const s:String):String;
var k: Integer;
begin
  Result :=Trim(s);
  k:=Pos(' ',Result);
  if k>0 then
    Result := Copy(Result,1,k-1);
end;

function GetExcelColumnName(aI: Integer):String;
const Zag: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var k: Integer;
begin
  if aI<27 then
  begin
    Result := Zag[aI];
    Exit;
  end;
  k := aI div 26;
  Result:= Zag[k];
  k:= aI-26;
  Result:= Result+Zag[k];
end;

function GetUNCName(PathStr: string): string;
var
  bufSize: DWord;
  buf:array [0..1000] of byte;
  msg: string;
  p:pChar;
  bb:PUniversalNameInfo;
begin
//  Result := PathStr;
//  Exit;
  Result:='';
  msg:='';
//  buf.lpUniversalName:='                             ';
  bufSize := 1000;
  p:= StrAlloc(Length(PathStr)+1);
  StrPCopy(p,PathStr);
  bb:=@buf;
  try
    if (WNetGetUniversalName(p,UNIVERSAL_NAME_INFO_LEVEL, @buf, bufsize) > 0) then
      case GetLastError of
        ERROR_BAD_DEVICE: msg := 'ERROR_BAD_DEVICE';
        ERROR_CONNECTION_UNAVAIL: msg := 'ERROR_CONNECTION_UNAVAIL';
        ERROR_EXTENDED_ERROR: msg := 'ERROR_EXTENDED_ERROR';
        ERROR_MORE_DATA: msg := 'ERROR_MORE_DATA';
        ERROR_NOT_SUPPORTED: msg := 'ERROR_NOT_SUPPORTED';
        ERROR_NO_NET_OR_BAD_PATH: msg := 'ERROR_NO_NET_OR_BAD_PATH';
        ERROR_NO_NETWORK: msg := 'ERROR_NO_NETWORK';
        ERROR_NOT_CONNECTED: msg := 'ERROR_NOT_CONNECTED';
      end
    else
      msg:=StrPas(bb^.lpUniversalName);
    Result := msg;
  finally
  end;
end;



function HostToIP(Name: AnsiString; var Ip: string): Boolean;
var
  wsdata : TWSAData;
  hostName : array [0..255] of AnsiChar;
  hostEnt : PHostEnt;
  addr : PAnsiChar;
begin
  WSAStartup ($0101, wsdata);
  try
    gethostname (hostName, sizeof (hostName));
    AnsiStrings.StrPCopy(hostName, Name);
    hostEnt := gethostbyname (hostName);
    if Assigned (hostEnt) then
       if Assigned (hostEnt^.h_addr_list) then
       begin
          addr := hostEnt^.h_addr_list^;
          if Assigned (addr) then
          begin
            IP := Format ('%d.%d.%d.%d', [byte (addr [0]),
            byte (addr [1]), byte (addr [2]), byte (addr [3])]);
            Result := True;
          end
       else
       Result := False;
     end
     else
       Result := False
  else
  begin
    Result := False;
  end;

 finally
   WSACleanup;
 end
end;

function CheckDirName(const aDir:String):String;
var k: Integer;
begin
  Result := Trim(aDir);
  k := Length(Result);
  if (k>0) and (Result[k]<>'\') then
    Result := Result +'\';

end;

function RoundFloat(var Value, RoundToNearest: Double): Double;
var
  int_val, int_rnd, remainder: Integer;
begin
  {$ifdef FULDebug}
  WriteDebug('RoundFloat() - Enter');
  {$endif}
  int_val := Round(Value * 100.00);
  int_rnd := Round(RoundToNearest * 100.00);
  if int_rnd = 0 then begin
    result := 0;
    exit;
  end;
  remainder := int_val mod int_rnd;
  if (remainder > 0) then begin
    if (int_rnd div remainder > 2) then // round down
      result := int_val - remainder
    else                                // round up
      result := int_val + (int_rnd - remainder);
    // Now divide the result by 100 to get the proper result.
    result := result / 100;
  end else
    result := Value;
  {$ifdef FULDebug}
  WriteDebug('RoundFloat() - Exit');
  {$endif}
end;

function IbRound( Value: Double; Dec: Integer ): Double;
var
  int_val: Int64;
  prec_val: Double;
begin
  {$ifdef FULDebug}
  WriteDebug('IbRound - Enter');
  {$endif}
  prec_val := Power(10.00,Dec);
  int_val := Round(Value *prec_val );
  Result  := int_val / Power(10.00,Dec);
  {$ifdef FULDebug}
  WriteDebug('IbRound - Exit');
  {$endif}
end;

procedure SetYesNo(cmb: TComboBox; nCount:Integer = 2);
begin
  with cmb do
  begin
    Items.Add('Да');
    Items.Add('Нет');
    if nCount>=3 then
      Items.Add('Норма');
  end;
end;

function Space(n: integer): String;
begin
  Result := StringOfChar(' ',n);
end;


function Str11(d:Integer):String;
var k:Integer;
begin
  Result:= IntToStr(d);
  k:= Length(Result);
  if k>11 then
    Exception.Create('Bad len');
  if k<11 then
    Result := Space(11-k)+Result;
end;

function DoubleRound( Value: Double; Dec: Integer ): Double;
begin
  Result := DecimalRoundDbl( Value, Dec);
end;

function StoDate(const s:String):TDateTime;
var
    d,m,y: Word;
begin
  d := StrToInt(Copy(s,7,2));
  m := StrToInt(Copy(s,5,2));
  y := StrToInt(Copy(s,1,4));
  Result := EncodeDate(y,m,d);
end;

function GetNextYearMonth(const cYm: String; n: Integer): String;
var
  d: TDateTime;
begin
  d := F_D_Month(STODate(cYm + '01'), n);
  Result := YearMonth(d);

end;

function XbaseKeyFound(nKey, nStatus: Integer): Integer;
const
  xbeK_F1      =   65648;
  xbeK_SH_F1   =   196720;
  xbeK_CTRL_F1 =   589936;
  xbeK_ALT_F1  =   327792;
  ASC_am       =    97;
  ASC_AB       =    65;
  xbeK_CTRL_A  =    1;
  xbeK_ALT_A   =    327745;
  ASC_0        =    48;
  xbeK_ALT_1   =    327729;
  xbeK_CTRL_ENTER = 10;
  xbeK_ALT_ENTER  = 327693;

var nXbaseKey:Integer;
begin
  nXbaseKey   :=0;
  case  nKey of
    93:  nXbaseKey := 65629;

    112..121:
    begin
        case nStatus of
           0:  nXbaseKey := xbeK_F1      -112 + nKey;
           1:  nXbaseKey := xbeK_SH_F1   -112 + nKey;  // Shift
           2:  nXbaseKey := xbeK_CTRL_F1 -112 + nKey;  // Ctrl
           4:  nXbaseKey := xbeK_ALT_F1  -112  + nKey; // Alt
        end;
    end;
   65..90:
    begin
      case nStatus of
        0: nXbaseKey := ASC_am     -65 + nKey;
        1: nXbaseKey := ASC_AB     -65 + nKey;
        2: nXbaseKey := xbeK_CTRL_A  -65 + nKey;
        4: nXbaseKey := xbeK_ALT_A   -65 + nKey
      end;
    end;
   48..57:
    begin
       case nStatus of
         0,2: nXbaseKey := ASC_0     -48 + nKey;
         4:   nXbaseKey := xbeK_ALT_1   -48 + nKey;
       end;
    end;
    13: begin
          case nStatus of
            0: nXbaseKey := 13;
            2: nXbaseKey := xbeK_CTRL_ENTER;
            3: nXbaseKey := xbeK_ALT_ENTER;
          end;
        end;
{    8:begin
        case nStatus of
           0:  nXbaseKey := xbeK_F1      -112 + nKey;
           1:  nXbaseKey := xbeK_SH_F1   -112 + nKey;  // Shift
           2:  nXbaseKey := xbeK_CTRL_F1 -112 + nKey;  // Ctrl
           4:  nXbaseKey := xbeK_ALT_F1  -112  + nKey; // Alt
        end;}

  else
     nXbaseKey := nKey;
  end;
  Result := nXbaseKey ;
end;

function GetCharFromVirtualKey(Key: Word): string;
 var
    keyboardState: TKeyboardState;
    asciiResult: Integer;
 begin
    GetKeyboardState(keyboardState) ;

    SetLength(Result, 2) ;
    asciiResult := ToAscii(key, MapVirtualKey(key, 0), keyboardState, @Result[1], 0) ;
    case asciiResult of
      0: Result := '';
      1: SetLength(Result, 1) ;
      2:;
      else
        Result := '';
    end;
 end;

 function CTOD(const s:String):TDateTime;
 begin
   Result := StrTodate(s);
 end;

function FindForm(aComponent:TWinControl):TForm;
begin
  if (aComponent is TForm) or not Assigned(aComponent.Parent) then
  begin
    Result := TForm(aComponent);
    Exit
  end
  else
    Result := nil;

  while Assigned(aComponent.Parent) do
  begin
    if aComponent.Parent is TForm then
    begin
      Result := TForm(aComponent.Parent);
      Break;
    end;
    aComponent := aComponent.Parent;
  end;

end;

function IfZero(d1,d2: double):double;
begin
  if d1=0.0 then
    Result := d2
  else
    Result := d1;
end;
 initialization
  FormatSettings.ShortDateFormat:= 'dd.mm.yyyy';


end.








