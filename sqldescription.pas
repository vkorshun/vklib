{******************************************************
  TSQLDescription - класс описывающий основные составные
  части  SQL выражения
******************************************************}
unit sqldescription;

interface

uses
  SysUtils, Messages, Classes, Vcl.Controls,
  Vcl.StdCtrls,Vcl.Forms, Vcl.Dialogs   ;

type

TSqlDescription = class (TObject)
private
  FSQLSelect:   TStringList;
  FSQLFrom:     TStringList;
  FSQLLeftJoin: TStringList;
  FSQLWhere:    TStringList;
  FSQLGroupBy:  TStringList;
  FSQLOrderBy:  TStringList;
public
  constructor Create;
  destructor  Destroy;override;
  function    GetSelectSql:String; // SQL выражние для Select

  property SQLSelect:TStringList   read FSQLSelect;
  property SQLFrom:TStringList     read FSQLFrom;
  property SQLLeftJoin:TStringList read FSQLLeftJoin;
  property SQLWhere:TStringList    read FSQLWhere;
  property SQLGroupBy:TStringList  read FSQLGroupBy;
  property SQLOrderBy:TStringList  read FSQLOrderBy;

end;

implementation

{ TSqlDescription }

constructor TSqlDescription.Create;
begin
  FSQLSelect   := TStringList.Create;
  FSQLFrom     := TStringList.Create;
  FSQLLeftJoin := TStringList.Create;
  FSQLWhere    := TStringList.Create;
  FSQLGroupBy  := TStringList.Create;
  FSQLOrderBy  := TStringList.Create;
end;

destructor TSqlDescription.Destroy;
begin
  FreeAndNil(FSQLSelect);
  FreeAndNil(FSQLFrom);
  FreeAndNil(FSQLLeftJoin);
  FreeAndNil(FSQLWhere);
  FreeAndNil(FSQLGroupBy);
  FreeAndNil(FSQLOrderBy);
end;

function TSqlDescription.GetSelectSql: String;
begin
  Result := FSQLSelect.Text +' ' +
     FSQLFrom.Text + ' ' +
     FSQLLeftJoin.Text + ' ' +
     FSQLWhere.Text + ' ' +
     FSQLGroupBy.Text + ' ' +
     FSQLOrderBy.Text;
end;

end.
