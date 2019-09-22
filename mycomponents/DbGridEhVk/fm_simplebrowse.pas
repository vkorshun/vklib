unit fm_simplebrowse;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  DBGridEhGrouping, DB, GridsEh, DBGridEh, DBGridEhVk, fmSimpledialog;

type
  TFmSimpleBrowse = class(TSimpleDialogFm)
    DBGridEhVk1: TDBGridEhVk;
    DataSource1: TDataSource;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Browse(aDataSet: TDataSet);
  end;

var
  FmSimpleBrowse: TFmSimpleBrowse;

implementation

{$R *.dfm}

{ TFmSimpleDialog2 }

procedure TFmSimpleBrowse.Browse(aDataSet: TDataSet);
begin
  DataSource1.DataSet := aDataSet;
  DBGridEhVk1.DataSource :=  DataSource1;
  ShowModal;
end;

procedure TFmSimpleBrowse.FormCreate(Sender: TObject);
begin
  inherited;
  WindowState := wsMaximized;
end;

end.
