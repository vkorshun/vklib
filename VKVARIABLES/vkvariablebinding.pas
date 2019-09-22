unit vkvariablebinding;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Controls, StdCtrls, Forms, Dialogs,
  Variants, Db, vkvariable, variantutils, vkvariablebindingcustom;

type
  TProcedureSetValue = procedure(Sender:TObject;const Value:Variant) of object;
  TFunctionGetValue  = function(Sender:TObject):Variant of object;

  TVkVariableBinding = class(TCustomVkVariableBinding)
  private
    FCaption: TCaption;
    FbSetControl: Boolean;
    FOnGetValue: TFunctionGetValue;
    FOnSetValue: TProcedureSetValue;
    FName: String;
    FOnSetControl: TNotifyEvent;
    procedure SetOnSetControl(const Value: TNotifyEvent);
  public
    procedure ClearControl;
    function GetControl:TWinControl;
    function GetValue:Variant;override;
    procedure SetControl(const AControl:TWinControl);override;
    procedure SetControlValue(const AValue:Variant);override;

    property Caption: TCaption read FCaption write FCaption;
    property bSetControl:Boolean read FbSetControl ;//write FbSetControl;
    property Name:String read FName write FName;
    property OnGetValue:TFunctionGetValue read FOnGetValue write FOnGetValue;
    property OnSetValue:TProcedureSetValue read FOnSetValue write FOnSetValue;
    property OnSetControl:TNotifyEvent  read FOnSetControl write SetOnSetControl;
  end;

  TVkVariableBindingCollection = class(TCustomVkVariableBindingCollection)
  private
    function GetVkVariableBinding(const VarName: string): TVkVariableBinding;
    function GetItem(Index: Integer): TVkVariableBinding;
    procedure SetItem(Index: Integer; Value: TVkVariableBinding);
  public
//    function CreateVkVariable(const VarName: string; const AValue: TObject): TVkVariableBinding; overload;
    function FindVkVariableBinding(const VarName: string) : TVkVariableBinding;
    function GetVkVariableBindingClass: TCustomVkVariableBindingClass; override;
    function BindingByName(AName: String):TVkVariableBinding;
    property Items[Index: Integer]: TVkVariableBinding read GetItem write SetItem;
    property DynVar[const VarName: string]: TVkVariableBinding read GetVkVariableBinding; default;
  end;

implementation


{ TVkVariableBiding }

procedure TVkVariableBinding.ClearControl;
begin
  if Assigned(FoControl) then
  begin
    TEdit(FoControl).OnChange := FCurrentOnChange;
    FoControl := nil;
  end;
  FoControl := nil;
end;

function TVkVariableBinding.GetControl: TWinControl;
begin
  Result := FoControl;
end;

function TVkVariableBinding.GetValue: Variant;
begin
  if Assigned(FOnGetValue) then
  begin
    Result := FOnGetValue(Self)
  end
  else
    Inherited;
end;

procedure TVkVariableBinding.SetControl(const AControl: TWinControl);
begin
  inherited;
  if not Assigned(AControl) then
  begin
    ClearControl;
  end
  else
  begin
    FoControl := AControl;
    if Assigned(TEdit(AControl).OnChange) then
    begin
      FCurrentOnChange := TEdit(AControl).OnChange;
    end;
    TEdit(AControl).OnChange := DoChange;

    if Assigned(FOnSetControl) then
      FOnSetControl(self);
    SetControlValue(FVariable.Value);
  end;
end;

procedure TVkVariableBinding.SetOnSetControl(const Value: TNotifyEvent);
begin
  FOnSetControl := Value;
end;

procedure TVkVariableBinding.SetControlValue(const AValue: Variant);
begin
  if bFromControl then
    Exit;
  FbSetControl := True;
  try
    if Assigned(FOnSetValue) then
    begin
      FOnSetValue(Self,AValue);
    end;
  finally
    FbSetControl := False;
  end;
end;

{ TVkVariableBindingCollection }

function TVkVariableBindingCollection.BindingByName(AName: String): TVkVariableBinding;
begin
  Result := TVkVariableBinding(FindVkVariableBinding(AName));
end;

{function TVkVariableBindingCollection.CreateVkVariable(const VarName: string;
  const AValue: TObject): TVkVariableBinding;
begin

end; }

function TVkVariableBindingCollection.FindVkVariableBinding(const VarName: string): TVkVariableBinding;
begin
  Result := TVkVariableBinding(inherited FindVkVariableBinding(Varname));
end;

function TVkVariableBindingCollection.GetItem(Index: Integer): TVkVariableBinding;
begin
  Result := TVkVariableBinding(inherited GetItem(Index));
end;

function TVkVariableBindingCollection.GetVkVariableBinding(const VarName: string): TVkVariableBinding;
begin
  Result := TVkVariableBinding(inherited FindVkVariableBinding(Varname));
end;

function TVkVariableBindingCollection.GetVkVariableBindingClass: TCustomVkVariableBindingClass;
begin
  Result := TVkVariableBinding;
end;

procedure TVkVariableBindingCollection.SetItem(Index: Integer; Value: TVkVariableBinding);
begin
  inherited SetItem(Index,Value);
end;

end.
