unit ControlPair;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Controls, StdCtrls, Forms, Dialogs,
  Variants, Db, Generics.Collections;

type

  PControlPairItem = ^TControlPairItem;
  TControlPairItem = record
    oLabel: TControl;
    oControl: TControl
  end;

  TControlPairList = class(TObject)
  private
    FList : TList<PControlPairItem>;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Add(c1,c2:TControl);
    procedure DeleteItem(AIndex: Integer);
    procedure Clear;
  end;
implementation

{ TControlPairList }

procedure TControlPairList.Add(c1, c2: TControl);
var _Item: PControlPairItem;
begin
  New(_Item);
  _Item.oLabel := c1;
  _Item.oControl := c2;
  FList.Add(_Item);
end;

procedure TControlPairList.Clear;
begin
  while FList.Count>0 do
    DeleteItem(0);
end;

constructor TControlPairList.Create;
begin
  FList := TList<PControlPairItem>.Create;
end;

procedure TControlPairList.DeleteItem(AIndex: Integer);
begin
  FList[AIndex].oLabel.Free;
  FList[AIndex].oControl.Free;
  Dispose(FList[AIndex]);
  FList.Delete(AIndex);
end;

destructor TControlPairList.Destroy;
var _Item: PControlPairItem;
begin
  for _Item in FList do
     Dispose(_Item);
  FList.Free;
  Inherited
end;

end.
