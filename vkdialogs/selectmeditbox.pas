unit selectmeditbox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DateVk, Menus, MEditBox, i_vkinterface;

type
  TClassForm = class of TForm;

  TSelectMEditBox= class (TMEditBox)
  private
    FoIFmSelectObject: IFmSelect;
    procedure OnMyClick(Sender: TObject);
  public
    destructor Destroy;override;
    function  GetValue: Variant;
    function  GetList:Variant;
    procedure MyKeyDown(Sender:TObject;var Key:Word;Shift:TShiftState);
    procedure SetInterface(IInterf:IFmSelect);
    procedure Setvalue(v:Variant);
    property  oIFmSelectObject:IFmselect read FoIFmSelectObject;
  end;

  TSelectWithLinkMEditBox = class (TObject)
  private
    FMEditBox: TMEditBox;
    FoIFmSelectObject: IFmSelect;
    procedure OnMyClick(Sender: TObject);
  public
//    procedure SetForm(CForm:TClassForm);
    constructor create(aControl:TMEditBox);
    destructor Destroy;override;
    procedure Setvalue(v:Variant);
    function  GetValue: Variant;
    procedure SetInterface(IInterf:IFmSelect);
    property  oIFmSelectObject: IFmSelect read FoIFmSelectObject;
    property  MEditBox:TMEditBox read FMEditBox;
//    property  FmSelect:TForm read FSelectForm;
  end;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('HopeComp', [TSelectMEditBox]);
end;


{ TSelectMEditBox }


{*******************************************************
  Module: TSelectMEditBox.Destroy
  Input:
  Output:
  Description:
*******************************************************}
destructor TSelectMEditBox.Destroy;
begin
  if Assigned(FoIFmSelectObject) then
    FoIFmSelectObject.DestroyInterface(FoIFmSelectObject);
//  if Assigned(FFmSelect) then
//    FFmSelect.Free;
  FoIFmSelectObject := nil;
  Inherited;
end;

{*******************************************************
  Module: TSelectMEditBox.GetValue
  Input:
  Output: FSelectObject.GetValue
  Description:
*******************************************************}

function TSelectMEditBox.GetList: Variant;
begin
  if Assigned(oIFmSelectObject) then
  begin
    Result:= GetValue;
  end;
end;

function TSelectMEditBox.GetValue: Variant;
begin
  if Assigned(oIFmSelectObject) then
    Result := oIFmSelectObject.GetValue
  else
    Result := null;
end;

procedure TSelectMEditBox.MyKeyDown(Sender: TObject;var Key: Word;
  Shift: TShiftState);
begin
//  inherited OnKeyDown(Sender,Key,Shift);
  if (Key=VK_DELETE)  then
    if Assigned(oIFmSelectObject) then
    begin
      Setvalue(0);
      oIFmSelectObject.Selected.Clear;
    end;
  inherited;
end;

{*******************************************************
  Module: TSelectMEditBox.OnMyClick
  Input:
  Output:
  Description: Процедура на кнопку.
*******************************************************}
procedure TSelectMEditBox.OnMyClick(Sender: TObject);
var v:Variant;
//    oP: TWinControl;
begin
  if Assigned(oIFmSelectObject) then
  begin
    v:= GetValue;
    //if VarIsArray(v) then
    //    v:=v[0];
//    oIFmSelectObject.currentkod:= v;
    if oIFmSelectObject.Select then
    begin
      Assert(oIFmSelectObject.Selected.Count>0,' oIFmSelectObject.List.Count=0');
      if oIFmSelectObject.Selected.Count=1 then
        Self.Text := oIFmSelectObject.GetItemName(oIFmSelectObject.Selected[0])
      else
        Self.Text := 'Выбрано '+IntToStr(oIFmSelectObject.Selected.Count)+' элементов';
      if Assigned(OnChange) then
        OnChange(self);
      PostMessage(TWinControl(Self).Handle,WM_KEYDOWN,VK_DOWN,0);
    end
    else       // Востанавливаем при отказе
       SetValue(v);  // RestoreValue ???  { TODO : RESTORE VALUE }
  end;
end;



{*******************************************************
  Module: TSelectMEditBox.Setvalue
  Input: V Variant
  Output:
  Description: Устанавливает значение SelectObject.List
    и Text этого значения
*******************************************************}
{procedure TSelectMEditBox.SetForm(CForm: TClassForm);
begin

end; }

procedure TSelectMEditBox.SetInterface(IInterf:IFmSelect);
begin
//  FFmSelect := CForm.Create(self);
//  if not Assigned(FSelectForm) then
//    ShowMessage('Не определен объект выбора!');
  FoIFmSelectObject := IInterf;
  FoIFmSelectObject.PInterface := @FoIFmSelectObject;
  OnButtonClick:= OnMyClick;
  OnKeyDown    := MyKeyDown;

end;

procedure TSelectMEditBox.Setvalue(v: Variant);
begin
  if not Assigned(oIFmSelectObject) then
    Exit;
  if VarIsStr(v) and (v='') then
    v := 0;
  oIFmSelectObject.SetValue(CoalEsce(v,0));
  if oIFmSelectObject.Selected.Count = 1 then
    Text := oIFmSelectObject.GetItemname(oIFmSelectObject.Selected[0])
  else
    Text := ' Выбрано '+IntTostr(oIFmSelectObject.Selected.Count)+' элементов';
end;

{ TSelectWithLinkMEditBox }

constructor TSelectWithLinkMEditBox.create(aControl: TMEditBox);
begin
  inherited create;
  FMEditBox := aControl;
end;

destructor TSelectWithLinkMEditBox.Destroy;
begin
//  if Assigned(FSelectForm) then
//    FSelectForm.Free;
  if Assigned(FoIFmSelectObject) then
    oIFmSelectObject.DestroyInterface(FoIFmSelectObject);
  inherited;
end;


function TSelectWithLinkMEditBox.GetValue: Variant;
begin
  Result := oIFmSelectObject.GetValue;
end;

procedure TSelectWithLinkMEditBox.OnMyClick(Sender: TObject);
var v:Variant;
begin
  if Assigned(oIFmSelectObject) then
  begin
    v:= GetValue;
    if VarIsArray(v) then
      v:=v[0]
    else
      v := coalesce(v,0);
//    oIFmSelectObject.currentkod:= v;
    if oIFmSelectObject.Select then
    begin
      Assert(oIFmSelectObject.Selected.Count>0,' FSelectObject.List.Count=0');
      FMEditBox.Text := oIFmSelectObject.GetItemName(oIFmSelectObject.Selected[0]);
      PostMessage(FMEditBox.Handle,WM_KEYDOWN,VK_TAB,0);
      if Assigned(FMEditBox.OnChange) then
        FMEditBox.OnChange(FMEditBox);
    end
    else
      FMEditBox.Text := '';
  end;

end;

{procedure TSelectWithLinkMEditBox.SetSelectType(CForm: TCalssForm);
begin
  if Assigned(FSelectForm) then
    FSelectForm.Free;
  FSelectForm:= TSelectForm.Create(CForm);
  FMEditBox.OnButtonClick:= OnMyClick;
end;}

{procedure TSelectWithLinkMEditBox.SetForm(CForm: TClassForm);
begin

end;}

procedure TSelectWithLinkMEditBox.SetInterface(IInterf: IFmSelect);
begin
  FoIFmSelectObject := nil;
  //if Assigned(FSelectForm) then
  //  FSelectForm.Free;
  //FSelectForm:= CForm.Create(Application);
  FoIFmSelectObject := IInterf;
  FoIFmSelectObject.PInterface := @FoIFmSelectObject;
  FMEditBox.OnButtonClick:= OnMyClick;
//  IInterface(FSelectForm).QueryInterface(IFmSelectObject,);
end;

procedure TSelectWithLinkMEditBox.Setvalue(v: Variant);
begin
  oIFmSelectObject.SetValue(v);
  if oIFmSelectObject.Selected.Count = 1 then
    FMEditBox.Text := oIFmSelectObject.GetItemname(oIFmSelectObject.Selected[0])
  else
    FMEditBox.Text := ' Выбрано '+IntTostr(oIFmSelectObject.Selected.Count)+' элементов';

end;

end.
