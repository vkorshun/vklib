unit pFIBDatabaseVk;

interface

uses
  SysUtils, Classes, FIBDatabase, pFIBDatabase, pFIBProps;

type
  TpFIBDatabaseVk = class(TpFIBDatabase)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    function  GetNewTransactionReadOnly(aOwner:TComponent):TpFIBTransaction;
    procedure SetTransactionReadOnly(Tr:TpFIBTransaction);
    procedure SetTransactionStability(Tr: TpFIBTransaction);
    procedure SetTransactionConcurency(Tr: TpFIBTransaction);//to Report

    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('vkfib', [TpFIBDatabaseVk]);
end;

{ TpFIBDatabaseVk }

function TpFIBDatabaseVk.GetNewTransactionReadOnly(
  aOwner: TComponent): TpFIBTransaction;
begin
  Result := TpFIBTransaction.Create(aOwner);
  Result.DefaultDatabase := Self;
  SetTransactionReadOnly(Result);
end;

procedure TpFIBDatabaseVk.SetTransactionConcurency(Tr: TpFIBTransaction);
begin
  with Tr do
  begin
    TPBMode := tpbDefault;
    TRParams.Clear;
    TRParams.Add('read');
    TRParams.Add('nowait');
  end;
end;

procedure TpFIBDatabaseVk.SetTransactionReadOnly(Tr: TpFIBTransaction);
begin
  with Tr do
  begin
    TPBMode := tpbDefault;
    TRParams.Clear;
    TRParams.Add('read');
    TRParams.Add('read_committed');
    TRParams.Add('nowait');
    TRParams.Add('rec_version');
  end;
end;

procedure TpFIBDatabaseVk.SetTransactionStability(Tr: TpFIBTransaction);
begin
  with Tr do
  begin
    TPBMode := tpbDefault;
    TRParams.Clear;
    TRParams.Add('write');
    TRParams.Add('consistency');
    TRParams.Add('nowait');
  end;
end;

end.
