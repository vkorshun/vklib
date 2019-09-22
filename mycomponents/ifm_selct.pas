unit ifm_select;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DateVk, Menus, MEditBox;

type
  // Права пользователя
  TUserRights = set of (urView,urEdit, urInsert, urDelete, urAdmin);
  // Методы выбора
//  TSelectObjectMethod = (somNil,somList,somOst, somParam, somAccount);
  TSelectObjectClass = class of TFmSelect;



  IFmSelect = interface(IInterface)
  private
    FSelected: TIntList;
    FbMultiSelect: Boolean;
  public
    currentkod: Integer;
    property Selected:TIntList read FSelected write FSelected;
    function Select:Boolean;overload;virtual; abstract;
    function Select(var VarList: TValueList):boolean;overload;virtual; abstract;
    function GetItemName(kod: Integer):String;virtual;abstract;
    function GetItemType(kod: Integer):String;virtual;abstract;
    property bMultiSelect:Boolean read FMultiSelect write SetMultiSelect;
  end;

  // Class SelectGrOrObj
  TSelectObject = class(Tobject)
  private
    Fm: TFmorm;
    oISelect: IFmSelect;
    function GetMultiSelect:Boolean;
    procedure SetMultiSelect(b: Boolean);
//    function GetOptions:TSelectOptions;
//    procedure SetOptions(opt: tSelectOptions);
    function GetFm: TFmSelect;
  public
    method: TSelectObjectClass;  // Метод
    ListRoot: TIntList;         // Массив первоначальных значений
    List: TIntList;            // Выбор
    property bMultiSelect: Boolean read GetMultiSelect write SetMultiSelect;     // Мультивыбор
    function GetItemName(kod: Integer):String;
    function GetItemType(kod: Integer):String;
    function Select: Boolean;
    function GetValue: Variant;
    procedure SetValue(v: Variant);
    constructor Create(meth:TSelectObjectClass );
    destructor Destroy;override;
//    property options: TSelectOptions read GetOptions write SetOptions;   // Для выбора из списка
    property FmSelect: TFmSelect read Fm;
  end;

  TSelectMEditBox= class (TMEditBox)
  private
    FSelectObject: TSelectObject;
    procedure OnMyClick(Sender: TObject);
    function GetSelectObject: TSelectObject;
  public
//    constructor Create;
    destructor Destroy;override;
    procedure SetSelectType(meth:TSelectObjectClass);
    procedure Setvalue(v:Variant);
    function  GetValue: Variant;
    property SelectObject: TSelectObject read GetSelectObject;
  end;

  TSelectWithLinkMEditBox = class (TObject)
  private
    FSelectObject: TSelectObject;
    FMEditBox: TMEditBox;
    procedure OnMyClick(Sender: TObject);
    function GetSelectObject: TSelectObject;
//    constructor Create;
  public
    constructor create(aControl:TMEditBox);
    destructor Destroy;override;
    procedure SetSelectType(meth:TSelectObjectClass);
    procedure Setvalue(v:Variant);
    function  GetValue: Variant;
    property SelectObject: TSelectObject read GetSelectObject;
    property MEditBox:TMEditBox read FMEditBox;
  end;
var
  FmSelect: TFmSelect;

implementation

//uses dm_main;

{$R *.dfm}
{ TSelectObject }

{*******************************************************
  Module: TSelectObject.Create
  Input:  meth - метод выбора . Определяет тип создаваемого объекта.
  Output:
  Description: основные действия при создании объекта.
*******************************************************}
constructor TSelectObject.Create(meth:TSelectObjectClass);
begin
  inherited Create;
  method := meth;
//  options := selAll;

  List := TIntList.Create;
  ListRoot := TIntList.Create;

  if Assigned(Fm) then
    FreeAndNil(Fm);

  Fm :=meth.Create(Application);
  Fm.SetSelAction;
  bMultiSelect := False;
end;

{*******************************************************
  Module: TSelectObject.destroy
  Input:
  Output:
  Description: Destroy.
*******************************************************}
destructor TSelectObject.Destroy;
begin
//  AdsQuery.Free;
  Inherited;
  List.Free;
  ListRoot.Free;

end;

{*******************************************************
  Module: TSelectObject.GetItemName
  Input:  kod - ключевой код.
  Output: Наименование объекта взависимости от типа выбора.
  Description:
*******************************************************}
function TSelectObject.GetFm: TFmSelect;
begin
  if (not Assigned(Fm))  then
  begin
    Result := nil;
    ShowMessage('Не определен тип формы выбора!');
  end
  else
    Result := Fm;
end;

function TSelectObject.GetItemName(kod: Integer): String;
begin
{  case method of
    somList: Result := DmMain.pFIBDatabaseHope.QueryValueAsStr(' SELECT name FROM objects WHERE kodobj=:kodobj',0,[kod]);
    somParam: Result := DmMain.pFIBDatabaseHope.QueryValueAsStr(' SELECT name FROM paramlist WHERE kodpar=:kodpar',0,[kod]);
    somAccount: Result := DmMain.pFIBDatabaseHope.QueryValueAsStr(' SELECT name FROM account WHERE kodacc=:kodacc',0,[kod]);
  end;}
  Result := Fm.GetItemName(kod);
end;

{*******************************************************
  Module: TSelectObject.GetItemType
  Input:  kod - ключевой код.
  Output: Тип объекта ('G','O') для method=(объекты) и тип параметра для metod=somParam
  Description:
*******************************************************}
function TSelectObject.GetItemType(kod: Integer): String;
begin
{  case method of
    somList: Result :=
      DmMain.pFIBDatabaseHope.QueryValueAsStr(' SELECT type FROM objects WHERE kodobj=:kodobj',0,[kod]);
    somParam: Result :=
      DmMain.pFIBDatabaseHope.QueryValueAsStr(' SELECT priznak FROM paramlist WHERE id=:id',0,[kod]);
//    somList: Result :=
//      DmMain.pFIBDatabaseHope.QueryValueAsStr(' SELECT type FROM objects WHERE kodobj=:kodobj',0,[kod]);
  end;}
  Fm.GetItemType(kod);
end;

{*******************************************************
  Module: TSelectObject.GetMultiSelect
  Input:
  Output: Boolean - возможность мульти выбора.
  Description:
*******************************************************}
function TSelectObject.GetMultiSelect: Boolean;
begin
  if Assigned(Fm) then
     Result := Fm.bMultiSelect
  else
     Result := False;
end;


{*******************************************************
  Module: TSelectObject.GetValue
  Input:
  Output: Variant - массив выбранное значение.
  Description: - массив даже если одно значение.
*******************************************************}
function TSelectObject.GetValue: Variant;
var i: Integer;
begin
  if List.Count > 0 then
  begin
    Result := VarArrayCreate([0,Pred(List.Count)],varInteger);
    for i:=0 to Pred(List.Count) do
      Result[i] := List[i];
  end
  else
  begin
    Result := VarArrayCreate([0,0],varInteger);
    Result[0] := 0;
  end;
end;

{*******************************************************
  Module: TSelectObject.Select
  Input:
  Output: True - если был выбор.
  Description: Визуализирует форму для выбора.
*******************************************************}
function TSelectObject.Select: Boolean;
begin
  Fm.ListRoot := ListRoot;
//  Fm.currentkod := GetValue;
  Fm.FSelected := List;
  Result := Fm.Select;

//  Fm.SetSelaction;
{  if (method=somList) or (method= somparam) then
  begin
    if List.Count>0 then
       kod := List.item[0]
    else
       kod := 0;
    List.Clear;
    if ListRoot.Count > 0  then
      Result := Fm.Select(ListRoot,kod, List)
    else
      Result := Fm.Select(nil,0,List);
  end;
  if (method=somAccount) then
  begin
    if ListRoot.Count = 0  then
       ListRoot.Add(0);
    if List.Count>0 then
       kod := List.item[0]
    else
       kod := 0;
    List.Clear;
    Result := TFmAccount(Fm).SelectAccount(List,TFmAccount(Fm).AccountOptions);
  end;}
end;


{*******************************************************
  Module: TSelectObject.SetMultiSelect
  Input:  Boolean.
  Output:
  Description: Set MultiSelect.
*******************************************************}
procedure TSelectObject.SetMultiSelect(b: Boolean);
begin
  if Assigned(Fm) then
    Fm.bMultiSelect := b;
end;


{*******************************************************
  Module: TSelectObject.SetValue
  Input:  Variant.
  Output:
  Description: Очищает массив выбора(List) и добавляет в него v.
*******************************************************}
procedure TSelectObject.SetValue(v: variant);
var i: Integer;
begin
  if List.Count > 0 then
    List.Clear;
  if (VarIsArray(v)) then
  begin
    for i:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do
      List.Add(v[i]);
  end
  else
    List.Add(CoalEsce(v,0));
end;




{ TSelectMEditBox }

{constructor TSelectMEditBox.Create;
begin
  inherited;
end;}

{*******************************************************
  Module: TSelectMEditBox.Destroy
  Input:
  Output:
  Description:
*******************************************************}
destructor TSelectMEditBox.Destroy;
begin
  if Assigned(FSelectObject) then
    FSelectObject.Free;
  Inherited;
end;

{*******************************************************
  Module: TSelectMEditBox.GetValue
  Input:
  Output: FSelectObject.GetValue
  Description:
*******************************************************}
function TSelectMEditBox.GetSelectObject: TSelectObject;
begin
  Result := FSelectObject;
  if not Assigned(FSelectObject) then
    ShowMessage('Не определен объект выбора!');
end;

function TSelectMEditBox.GetValue: Variant;
begin
  Result := FSelectObject.GetValue;
end;

{*******************************************************
  Module: TSelectMEditBox.OnMyClick
  Input:
  Output:
  Description: Процедура на кнопку.
*******************************************************}
procedure TSelectMEditBox.OnMyClick(Sender: TObject);
var v:Variant;
begin
  if Assigned(FSelectObject) then
  begin
    v:= GetValue;
    if VarIsArray(v) then
      v:=v[0]
    else
      v := coalesce(v,0);
    FSelectObject.FmSelect.currentkod:= v;
    if FSelectObject.Select then
    begin
      Assert(FSelectObject.List.Count>0,' FSelectObject.List.Count=0');
      Self.Text := FSelectObject.GetItemName(FSelectObject.List[0]);
      PostMessage(TWinControl(Self).Handle,WM_KEYDOWN,VK_TAB,0);
    end
    else
      Self.Text := '';
  end;
end;

{*******************************************************
  Module: TSelectMEditBox.SetSelectType
  Input: meth: TSelectObjectMethod
  Output:
  Description:
*******************************************************}
procedure TSelectMEditBox.SetSelectType(meth: TSelectObjectClass);
begin
  if Assigned(FSelectObject) then
    fSelectObject.Free;
  FSelectObject:= TSelectObject.Create(meth);
  Self.OnButtonClick:= OnMyClick;
end;



{ TFmSelect }

{*******************************************************
  Module: TFmSelect.SetMultiSelect
  Input: b: Boolean
  Output:
  Description:
*******************************************************}
{function TFmSelect.SelectAccount(var List: TIntList;
  options: TSelectAccountOptions): Boolean;
begin

end;}

procedure TFmSelect.SetMultiSelect(b: Boolean);
begin
  FMultiSelect := b;
end;

{*******************************************************
  Module: TSelectMEditBox.Setvalue
  Input: V Variant
  Output:
  Description: Устанавливает значение SelectObject.List
    и Text этого значения
*******************************************************}
procedure TSelectMEditBox.Setvalue(v: Variant);
begin
  SelectObject.SetValue(v);
  if SelectObject.List.Count = 1 then
    Text := SelectObject.GetItemname(SelectObject.List[0])
  else
    Text := ' Выбрано '+IntTostr(SelectObject.List.Count)+' элементов';
end;

{ TSelectWithLinkMEditBox }

constructor TSelectWithLinkMEditBox.create(aControl: TMEditBox);
begin
  inherited create;
  FMEditBox := aControl;
end;

destructor TSelectWithLinkMEditBox.Destroy;
begin
  if Assigned(FSelectObject) then
    FSelectObject.Free;
  inherited;
end;

function TSelectWithLinkMEditBox.GetSelectObject: TSelectObject;
begin
  Result := FSelectObject;
  if not Assigned(FSelectObject) then
    ShowMessage('Не определен объект выбора!');
end;

function TSelectWithLinkMEditBox.GetValue: Variant;
begin
  Result := FSelectObject.GetValue;
end;

procedure TSelectWithLinkMEditBox.OnMyClick(Sender: TObject);
var v:Variant;
begin
  if Assigned(FSelectObject) then
  begin
    v:= GetValue;
    if VarIsArray(v) then
      v:=v[0]
    else
      v := coalesce(v,0);
    FSelectObject.FmSelect.currentkod:= v;
    if FSelectObject.Select then
    begin
      Assert(FSelectObject.List.Count>0,' FSelectObject.List.Count=0');
      FMEditBox.Text := FSelectObject.GetItemName(FSelectObject.List[0]);
      PostMessage(FMEditBox.Handle,WM_KEYDOWN,VK_TAB,0);
    end
    else
      FMEditBox.Text := '';
  end;

end;

procedure TSelectWithLinkMEditBox.SetSelectType(meth: TSelectObjectClass);
begin
  if Assigned(FSelectObject) then
    fSelectObject.Free;
  FSelectObject:= TSelectObject.Create(meth);
  FMEditBox.OnButtonClick:= OnMyClick;
end;

procedure TSelectWithLinkMEditBox.Setvalue(v: Variant);
begin
  SelectObject.SetValue(v);
  if SelectObject.List.Count = 1 then
    FMEditBox.Text := SelectObject.GetItemname(SelectObject.List[0])
  else
    FMEditBox.Text := ' Выбрано '+IntTostr(SelectObject.List.Count)+' элементов';

end;

end.
