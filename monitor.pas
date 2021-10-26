unit monitor;

interface
uses
  Windows, Messages, SysUtils, Classes, AnsiStrings   ;

//const
// cFileName='debug_monitor.txt';

procedure DbgMonitor(v : Variant; aHandle:THandle = 0);
function SpMonitor(szStr: PAnsiChar; aHandle:THandle = 0):Integer; cdecl; export;
function TxtMonitor(szStr: String; aHandle:THandle = 0):Integer;
function GetDebugFileName:String;
var  CS: TRTLCriticalSection;


implementation
//uses udf_glob;

procedure DbgMonitor(v : Variant; aHandle:THandle = 0);
var Stru: TCopyDataStruct;
    hDbg: hWnd;
    s:    String;
    pc: PChar;
begin
  hDbg := FindWindow('TFmDebug',nil);

  if hDbg=0 then
  begin
     Exit;
  end;

//  s := StrNew(PChar(v));
  EnterCriticalsection(CS);
  try
    s := v;
    pc:= StrNew(PChar(s)); ;
    try
      with Stru do begin
        dwData := 0;
        cbData := Length(s)+5;
        lpData := pc;
      end;
      SendMessage(hDbg,WM_COPYDATA, aHandle, LongInt(@Stru));
    finally
      StrDispose(pc);
    end;
  finally
    LeaveCriticalsection(CS);
  end;
end;


function SpMonitor(szStr: PAnsiChar; aHandle:THandle = 0):integer; cdecl; export;
var Stru: TCopyDataStruct;
    hDbg: hWnd;
    Fh:Integer;
    s: AnsiString;
    cFileName: String;
begin
  hDbg := FindWindow('TfmSP_Event_Mon','SoftPro Event Monitor');
  cFileName := getDebugFileName;

  if hDbg<=0 then
  begin
    EnterCriticalsection(CS);
    try
      if FileExists(cFileName) then
        Fh:=FileOpen(cFileName,fmOpenReadWrite )
      else
        Fh:=FileCreate(cFileName);
      FileSeek(Fh,0,2);
//        szStr:=szStr+#13#10;
      s:= AnsiStrings.StrPas(szStr)+#13#10;
      if Fh>0 then
        FileWrite(Fh,PAnsiChar(s)^,Length(s));
      FileClose(Fh);
    finally
      LeaveCriticalsection(CS);
    end;
    Exit(0);
  end;
//  s := StrNew(PChar(v));
  with Stru do begin
    dwData := 579;
    cbData := AnsiStrings.StrLen(szStr)+5;
    lpData := szStr;
  end;
  SendMessage(hDbg,WM_COPYDATA, aHandle, LongInt(@Stru));
  Result:=1;
end;

function TxtMonitor(szStr: String; aHandle:THandle = 0):integer;
var Stru: TCopyDataStruct;
    hDbg: hWnd;
    Fh:Integer;
    s: AnsiString;
    cFileName: String;
begin
  hDbg := FindWindow('TfmSP_Event_Mon','SoftPro Event Monitor');
  s:= AnsiString(szStr)+#13#10#0;
  cFileName := GetDebugFileName;

  if hDbg<=0 then
  begin
    EnterCriticalsection(CS);
    try
      if FileExists(cFileName) then
        Fh:=FileOpen(cFileName,fmOpenReadWrite )
      else
        Fh:=FileCreate(cFileName);
      FileSeek(Fh,0,2);
//        szStr:=szStr+#13#10;
      if Fh>0 then
        FileWrite(Fh,PAnsiChar(s)^,Length(s));
      FileClose(Fh);
    finally
      LeaveCriticalsection(CS);
    end;
    Exit(0);
  end;
//  s := StrNew(PChar(v));
  with Stru do begin
    dwData := 579;
    cbData := Length(s)+5;
    lpData := PAnsiChar(s);
  end;
  SendMessage(hDbg,WM_COPYDATA, aHandle, LongInt(@Stru));
  Result:=1;
end;

{procedure WriteDebug(sz: String);
var
  BytesWritten: DWord;
begin
  EnterCriticalSection(csDebugFile);
  try
    WriteFile(hDebugFile, PChar(sz + #13 + #10)^, Length(sz) + 2, BytesWritten, nil);
  finally
    LeaveCriticalSection(csDebugFile);
  end;
end;}

function GetDebugFileName:String;
begin
  Result := ExtractFileDir(ExpandUNCFileName(ParamStr(0)))+'\vk_debug.txt';
end;

initialization;
  InitializeCriticalSection(CS);

finalization;
  DeleteCriticalSection(CS);

end.

