unit vkvariablebindingdialog;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Vcl.Controls,
  StdCtrls,Forms, Dialogs, Variants, Db,  ExtCtrls, Mask,
  MEditBox,DBCtrlsEh,   math, ComCtrls, vkvariablebinding,vkvariable, monitor
  , DateVk, numbermaskedit, VariantUtils, VkVariableBindingCustom, System.RTTI;



type
  TItemEdit              = TEdit;
  TItemMaskEdit          = TMaskEdit;
  TItemComboBox          = TComboBox;
  TItemCheckBox          = TCheckBox;
  TItemDbNumberEditEh    = TDbNumberEditEh;
  TItemDbDateTimeEditEh  = TDbDateTimeEditEh;
  TItemMEditBox          = TMEditBox;
  TItemNumberMaskEdit    = TNumberMaskEdit;
  TWinControlClass = class of TWinControl;
  TEditVkVariableBindingClass = class of TEditVkVariableBinding;

  TEditVkVariableBinding = class(TVkVariableBinding)
  private
    FLabel: TLabel;
    FPageCaption: String;
  protected
    function MyGetValue(Sender: TObject): Variant;virtual;
    procedure MySetControl(Sender: TObject);virtual;
    procedure MySetValue(Sender: TObject;const Value:Variant);virtual;
  public
//    procedure Bind(AVkvariable:TVkVariable; AControl:TWinControl);override;
    constructor Create(AOwner: TPersistent);override;
    property Lb: TLabel read FLabel write FLabel;
    property PageCaption: String read FPageCaption write FPagecaption;
    class function GetDefaultTypeOfControl: TWinControlClass; Virtual;
  end;

  TEditVkVariableBindingCollection = class(TVkVariableBindingCollection)
  private
    function GetItem(AIndex:Integer): TEditVkVariableBinding;
    procedure SetItem(AIndex:Integer; const Avalue:tEditVkvariableBinding);
  public
//    function CreateVkVariable(const VarName: string; const AValue: TObject): TVkVariableBinding; overload;
    function IndexOfControl(AControl: TWinControl):Integer;
    function GetVkVariableBindingClass: TCustomVkVariableBindingClass; override;
    property Items[Index: Integer]: TEditVkVariableBinding read GetItem write SetItem;
    class function GetBindinClassgOnTypeControl(ATypeControl:TWinControlClass ): TEditVkVariableBindingClass;
  end;

  TMaskEditVkVariableBinding = class(TEditVkVariableBinding)
  public
    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;

  TPasswordVkVariableBinding = class(TEditVkVariableBinding)
  private
    procedure OnMyBinding(Sender: TObject);
  public
    constructor Create(AOwner: TPersistent);override;
//    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;


  TComboBoxVkVariableBinding = class(TEditVkVariableBinding)
  public
    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;

  TCheckBoxVkVariableBinding = class(TEditVkVariableBinding)
  public
    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;

  TDbNumberEditEhVkVariableBinding = class(TEditVkVariableBinding)
  public
    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;

  TDbDateTimeEditEhVkVariableBinding = class(TEditVkVariableBinding)
  public
    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;

  TMEditBoxVkVariableBinding = class(TEditVkVariableBinding)
  public
    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;

  TNumberMaskEditVariableBinding = class(TEditVkVariableBinding)
  public
    class function GetDefaultTypeOfControl: TWinControlClass; override;
  end;

implementation

{ TDocControlIntem }


constructor TEditVkVariableBinding.Create(AOwner: TPersistent);
begin
  inherited;
  OnGetValue := MyGetValue;
  OnSetValue := MySetValue;
  OnSetControl := MysetControl;
end;

class function TEditVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result := TItemEdit;
end;

function TEditVkVariableBinding.MyGetValue(Sender: TObject): Variant;
begin
  if oControl is TItemEdit then
     Result := TItemEdit(oControl).Text
  else
  if oControl is TItemMaskEdit then
     Result := TItemMaskEdit(oControl).Text
  else
  if oControl is TItemComboBox then
  begin
    Result := TItemComboBox(oControl).ItemIndex;
   {$IFDEF XBASE}
    Inc(result);
   {$ENDIF}
  end
  else
  if oControl is TItemCheckBox then
  begin
     Result := TItemCheckBox(oControl).Checked
  end
  else
  if oControl is TItemDbNumberEditEh then
  begin
     Result := TItemDbNumberEditEh(FoControl).Value;
  end
  else
  if oControl is TNumberMaskEdit then
  begin
     Result := TNumberMaskEdit(FoControl).Value;
  end
  else
  if oControl is TItemDbDateTimeEditEh then
     Result := TItemDbDateTimeEditEh(FoControl).Value
  else
  if oControl is TItemMEditBox then
     Result := TItemMEditBox(FoControl).Value.AsVariant
  else
    Result := null;
end;

procedure TEditVkVariableBinding.MySetControl(Sender: TObject);
//var v: Variant;
begin
//  SetValue(FDocVariable.VarValue);
  if oControl is TItemCheckBox then
      TEdit(FoControl).OnClick := DoChange
  else
    if oControl is TItemComboBox then
    begin
      TComboBox(oControl).Style := csDropDownList;
      TComboBox(oControl).OnChange := DoChange;
    end
    else
      TEdit(oControl).OnChange := DoChange;
end;


procedure TEditVkVariableBinding.MySetValue(Sender: TObject;const Value:Variant);
var _Variable: TVkVariable;
begin
  _Variable := TVkVariableBinding(Sender).Variable;
  _Variable.Value := Value;
  if Assigned(FoControl) then
  begin
    if FoControl is TItemEdit then
    begin
      TItemEdit(FoControl).Text:= _Variable.AsString;
    end
    else
    if (FoControl is TItemMaskEdit) and not (FoControl is  TItemMEditBox)
    then
    begin
      TItemMaskEdit(FoControl).Text := _Variable.AsString;
    end
    {$IFDEF XBASE}
    else
    if FoControl is TItemComboBox then
      with TItemComboBox(FoControl) do
      begin
        if Items.Count> _Variable.AsInteger then
          ItemIndex := _Variable.AsInteger-1;
      end
    {$ELSE}
    else
    if FoControl is TItemComboBox then
    with TItemComboBox(FoControl) do
    begin
      if Items.Count> _Variable.AsInteger then
        ItemIndex := _Variable.AsInteger;
    end
    {$ENDIF}
    else
    if FoControl is TItemCheckBox then
    begin
      TItemCheckBox(FoControl).Checked := _Variable.AsBoolean;
    end
    else
    if FoControl is TItemMEditBox then
    begin
      TItemMEditBox(FoControl).Text:= _Variable.AsString;
    end
    else
    if FoControl is TItemDbNumberEditEh then
    begin
      TItemDbNumberEditEh(FoControl).Value := _Variable.AsFloat;
    end
    else
    if FoControl is TNumberMaskEdit then
    begin
      TItemNumberMaskEdit(FoControl).Value := _Variable.AsFloat;
    end
    else
    if FoControl is TItemDbDateTimeEditEh then
    begin
      try
        if not VariantIsEmpty(_Variable.Value) then
          TDbdateTimeEditEh(FoControl).Value := _Variable.AsDateTime
        else
          TDbdateTimeEditEh(FoControl).Text := '  .  .  ';
      except
        ShowMessage(name + ' '+ _Variable.asString);
        ShowMessage(DateToStr(_Variable.AsDateTime)+' '+DatetoStr(TDateTimePicker(FoControl).MinDate));
        Raise;
      end;
    end
    else
    if FoControl is TItemMEditBox then
    begin
      TItemMEditBox(FoControl).Value.FromVariant(_Variable.Value);
    end
    else
    if FoControl is TMemo then
    begin
      TMemo(FoControl).Text:= _Variable.AsString ;
    end;
  end;
end;

{ TEditVkVariableBindingCollection }

class function TEditVkVariableBindingCollection.GetBindinClassgOnTypeControl(
  ATypeControl: TWinControlClass): TEditVkVariableBindingClass;
begin
   if ATypeControl=TMaskEdit  then
     Result := TMaskEditVkVariableBinding
   else
   if ATypeControl=TComboBox  then
     Result := TComboBoxVkVariableBinding
   else
   if ATypeControl=TCheckBox  then
     Result := TCheckBoxVkVariableBinding
   else
   if ATypeControl=TDbNumberEditEh  then
     Result := TDbNumberEditEhVkVariableBinding
   else
   if ATypeControl=TDbDateTimeEditEh  then
     Result := TDbDateTimeEditEhVkVariableBinding
   else
   if ATypeControl=TNumberMaskEdit  then
     Result := TNumberMaskEditVariableBinding
   else
     Result := TEditVkVariableBinding

end;

function TEditVkVariableBindingCollection.GetItem(AIndex: Integer): TEditVkVariableBinding;
begin
  Result := TEditVkVariableBinding(inherited GetItem(AIndex));
end;

function TEditVkVariableBindingCollection.GetVkVariableBindingClass: TCustomVkVariableBindingClass;
begin
  Result :=  TEditVkVariableBinding;
end;

function TEditVkVariableBindingCollection.IndexOfControl(AControl: TWinControl): Integer;
var i: Integer;
begin
  Result := -1;
  for i:=0 to Count-1 do
    if Items[i].oControl = AControl then
    begin
      Result := i;
      Break;
    end;
end;

procedure TEditVkVariableBindingCollection.SetItem(AIndex: Integer; const Avalue: tEditVkvariableBinding);
begin
  inherited SetItem(AIndex,AValue);
end;

{ TComboBoxVkVariableBinding }

class function TComboBoxVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result := TItemComboBox;
end;

{ TNumberMaskEditVariableBinding }

class function TNumberMaskEditVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result := TItemNumberMaskEdit;
end;

{ TMaskEditVkVariableBinding }

class function TMaskEditVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result := TItemMaskEdit;
end;

{ TCheckBoxVkVariableBinding }

class function TCheckBoxVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result := TItemCheckBox;
end;

{ TDbNumberEditEhVkVariableBinding }

class function TDbNumberEditEhVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result := TDbNumberEditEh;
end;

{ TDbDateTimeEditEhVkVariableBinding }

class function TDbDateTimeEditEhVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result :=  TDbDateTimeEditEh;
end;

{ TMEditBoxVkVariableBinding }

class function TMEditBoxVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  Result := TMEditBox;
end;

{ TPaswordVkVariableBinding }

constructor TPasswordVkVariableBinding.create(AOwner: TPersistent);
begin
  inherited;
  OnBinding := OnMyBinding;
end;

{class function TPasswordVkVariableBinding.GetDefaultTypeOfControl: TWinControlClass;
begin
  inherited;
end;}

procedure TPasswordVkVariableBinding.OnMyBinding(Sender: TObject);
begin
  TEdit(FoControl).PasswordChar := '*';
end;

end.
