unit hostdate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DateUtils;

type
   TTimeArray = Array of int64;
    PTime_of_day = ^TTime_of_day;
    TTime_of_day = record
    tod_elapsedt: DWORD;
    tod_msecs:DWORD;
    tod_hours:DWORD;
    tod_mins:DWORD;
    tod_secs:DWORD;
    tod_hunds:DWORD;
    tod_timezone:integer;
    tod_tinterval:DWORD;
    tod_day:DWORD;
    tod_month:DWORD;
    tod_year:DWORD;
    tod_weekday:DWORD;
    end;

  function GetRemoteTime(Host: String): TDateTime;
  procedure NetRemoteTOD(UncServerName: PWideString; out BufferPtr:    PTime_of_Day);stdcall; external 'netapi32.dll';
  procedure NetApiBufferFree(Buffer: Pointer); stdcall; external 'netapi32.dll';
function TzSpecificLocalTimeToSystemTime(lpTimeZoneInformation: PTimeZoneInformation; var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall;
  function SysDtToLocalTimeZone(dt:TDateTime):TDateTime;
  function DtToSysDt(dt:TDateTime):TDateTime;

implementation

 function TzSpecificLocalTimeToSystemTime; external kernel32 name 'TzSpecificLocalTimeToSystemTime';

function GetRemoteTime(Host: String): TDateTime;
var Pt: PTime_Of_Day;
    SWStr: WideString;
//    i: integer;
    Dt: TDateTime;
    STime,LTime: _SYSTEMTIME;
    Tz_info: _TIME_ZONE_INFORMATION;
//    AYear,AMonth,ADay,AHour,AMinute,ASec: WORD;
   // CTime, NetTime: TDateTime;
Begin
  SWStr:=Host;
  //'\\' + Host;
  try
    GetTimeZoneInformation(Tz_info);
    NetRemoteTod(@SWStr[1],Pt);
    if (Pt.tod_month > 0) and (Pt.tod_day > 0) and (Pt.tod_year > 0) then
    Begin
      Dt:=EncodeDateTime(Pt.tod_year,Pt.tod_month,Pt.tod_day,Pt.tod_hours,Pt.tod_mins,Pt.tod_secs,0{Pt.tod_msecs and $0FFFF});
      DateTimeToSystemtime(Dt,STIME);
      SystemTimeToTzSpecificLocalTime(@Tz_info,STime,LTime);
      Dt:=SystemTimeToDateTime(LTime);
      Result:= Dt;
    end
    else
      Result:=Now;
  except
    Result:=Now;
    Exit;
  end;
  NetApiBufferFree(Pt);
end;

function SysDtToLocalTimeZone(dt:TDateTime):TDateTime;
var
  STime,LTime: _SYSTEMTIME;
  Tz_info: _TIME_ZONE_INFORMATION;
begin
  GetTimeZoneInformation(Tz_info);
  DateTimeToSystemtime(Dt,STIME);
  SystemTimeToTzSpecificLocalTime(@Tz_info,STime,LTime);
  Result := SystemTimeToDateTime(LTime);
end;

function DtToSysDt(dt:TDateTime):TDateTime;
var
  STime, LocalTime: _SYSTEMTIME;
  Tz_info: _TIME_ZONE_INFORMATION;

  procedure AddHoer(ADelta: LongInt);
  begin
    if ADelta>0 then
    begin
      STIME.wHour := STIME.wHour + ADelta;
      if STIME.wHour<0 then
      begin

      end;

    end;
  end;
begin
  GetTimeZoneInformation(Tz_info);
  DateTimeToSystemtime(Dt,STIME);
 // if (24-STIME.wHour)< ( Tz_info.Bias div 60) then
 //   STIME.wHour := 24 + (STIME.wHour + Tz_info.Bias div 60);
 //   STIME.wDay := STIME.wDay +1;
 // else
 //   STIME.wHour := STIME.wHour + Tz_info.Bias div 60;
 // if Tz_info.DaylightDate.wMonth > 0 then
 //    STIME.wHour := STIME.wHour + Tz_info.DaylightBias div 60;
  TzSpecificLocalTimeToSystemTime(@tz_info,STIME,LocalTime);
  Result := SystemTimeToDateTime(LocalTime);
end;

end.
