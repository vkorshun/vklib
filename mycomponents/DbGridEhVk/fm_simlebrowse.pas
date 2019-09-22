unit fm_simlebrowse;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fm_simledialog, DBGridEhGrouping, DB, GridsEh, DBGridEh, DBGridEhVk;

type
  TFmSimpleDialog2 = class(TFmSimpleDialog)
    DBGridEhVk1: TDBGridEhVk;
    DataSource1: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Browse(aDataSet: TDataSet);
  end;

var
  FmSimpleDialog2: TFmSimpleDialog2;

implementation

{$R *.dfm}

{ TFmSimpleDialog2 }

procedure TFmSimpleDialog2.Browse(aDataSet: TDataSet);
begin
  DataSource1.DataSet := aDataSet;
  ShowModal;
end;

end.
