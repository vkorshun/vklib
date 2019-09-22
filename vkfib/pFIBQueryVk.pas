unit pFIBQueryVk;

interface

uses
  SysUtils, Classes, FIBQuery, pFIBQuery;

type
  TpFIBQueryVk = class(TpFIBQuery)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    function IsEmpty: Boolean;
    procedure GoToRecNo(n: Integer);

  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('vkfib', [TpFIBQueryVk]);
end;

{ TpFIBQueryVk }

procedure TpFIBQueryVk.GoToRecNo(n: Integer);
var i: Integer;
begin
  for I := 1 to n-1 do
   Next;
end;

function TpFIBQueryVk.IsEmpty: Boolean;
begin
  Result := Eof and Bof;
end;

end.
