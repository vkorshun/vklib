unit simplebrowse;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBGridEh,  Mask, DBCtrlsEh,db, fm_simledialog, DbGridEhVk;

implementation

type
  TFmSimpleBrowse = class(TFmSimpleDialog)
  private
    DbGridVk: TDbGridEhVk;
  public
    constructor Create(aOwner:TComponent);override;
  end;

{ TFmSimpleBrowse }

constructor TFmSimpleBrowse.Create(aOwner: TComponent);
begin
  inherited;
  DbGridVk := TDbGridEhVk.Create(self);
  DbGridVk.Parent := self;
  DbGridVk.Align := alClient;
  DbGridVk.AllowOperations
end;

end.
