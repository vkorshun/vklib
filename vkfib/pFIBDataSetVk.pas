unit pFIBDataSetVk;

interface

uses
  SysUtils, Classes, DB, FIBDataSet, pFIBDataSet;

type
  TSQLVkField = class(TField)
  private
    function GetLargeInt:Int64;
    procedure SetLargeInt(a:Int64);
  public
    property AsLargeInt:Int64 read GetLargeInt write SetLargeInt;
  end;



  TpFIBDataSetVk = class(TpFIBDataSet)
  private
    { Private declarations }
    FOnAfterFullrefresh: TNotifyEvent;
  protected
    { Protected declarations }
  public
    { Public declarations }
    function FieldByName(const afieldname:String):TSQLVkField;
    procedure Fullrefresh;
  published
    { Published declarations }
    property OnAfterFullrefresh: TNotifyEvent read FOnAfterFullRefresh write FOnAfterFullRefresh;
  end;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('vkfib', [TpFIBDataSetVk]);
end;

{ TPSQLMikkoField }

function TSQLVkField.GetLargeInt: Int64;
begin
  Result := TFIBBCDField(self).AsInt64;
  //BCDToInt64(NormBCD(TField(self).AsBCD));
{  if self is  TLargeIntField then
    Result := 0;
  if TLargeIntField(self).Value = null then
    Result := 0
  else
    Result := TLargeIntField(self).Value;}
end;


procedure TSQLVkField.SetLargeInt(a: Int64);
begin
  TFIBBCDField(self).AsInt64 := a;
end;

{ TpFIBDataSetVk }

function TpFIBDataSetVk.FieldByName(const afieldname: String): TSQLVkField;
begin
  Result := TSQLVkField( TpFIBDataSet(self).FieldByName(UpperCase(afieldname)));
end;


procedure TpFIBDataSetVk.Fullrefresh;
begin
  TpFIBDataSet(self).FullRefresh;
  if Assigned(FOnAfterFullrefresh) then
    FOnafterFullrefresh(Self) ;

end;

end.
