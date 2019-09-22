unit FIBDatabaseVk;

interface

uses
  SysUtils, Classes, FIBDatabase;

type
  TFIBDatabaseVk = class(TFIBDatabase)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('vkfib', [TFIBDatabaseVk]);
end;

end.
