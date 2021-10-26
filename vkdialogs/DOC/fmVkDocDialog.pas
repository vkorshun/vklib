unit fmVkDocDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Mask, MEditBox, DBCtrlsEh, Generics.Collections,
  variants, math, ComCtrls, Db, vkvariable, vkvariablebinding,
  vkvariablebindingdialog, ActnList, System.Actions, ControlPair, System.UITypes;

const
  MIN_WIDTH = 216;

type

  // TClassWinControl = class of TWinControl;
  TBoolFunction = function(Sender: TObject): Boolean of object;
  TAControls = array of TWinControl;
  TVkVariableBindingClass = class of TEditVkVariableBinding;

  PPageDescribe = ^TPageDescribe;

  TPageDescribe = record
    Owner: TWinControl;
    Parent: TWinControl;
    Fx: Integer;
    Fy: Integer;
    FWidth: Integer;
    FLen: Integer;
  end;

  TCustomPageDescribeList = TList<PPageDescribe>;

  TPageDescribeList = class(TCustomPageDescribeList)
  private
  public
    destructor Destroy; override;
    procedure AddPageDescribe(AOwner, AParent: TWinControl; AFx, AFy, AFLen: Integer);
    procedure Clear;
    function FindPageDescribe(const AName: String): PPageDescribe;
    function GetMaxFx: Integer;
    function GetMaxFy: Integer;
    function GetMaxFLen: Integer;
    procedure CheckScroll;
  end;

  TVkDocDialogFm = class(TForm)
    pnBottom: TPanel;
    btnOk: TButton;
    BtnCansel: TButton;
    Scrb: TScrollBox;
    ActionList1: TActionList;
    aOk: TAction;
    aCancel: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pnBottomResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure aOkExecute(Sender: TObject);
    procedure aCancelExecute(Sender: TObject);
  private
    { Private declarations }
    // Fx, Fy, FLen: Integer;
    FPageDescribeList: TPageDescribeList;
    FbFirst: Boolean;
    FbFree: Boolean;
    FMaxLen: Integer;
    FbDynamic: Boolean; // define call on show
    FBindingCollection: TEditVkVariableBindingCollection;
    FVariableCollection: TVkVariableCollection;
    FOnActionUpdate: TNotifyEvent;
    FControlPairList: TControlPairList;
    FOnSaveData: TBoolFunction;
    function GetMaxFLen: Integer;
    function GetMaxFy: Integer;
    // procedure AddPageDescribe(AControl: TWinControl; AFx,AFy,ALen: Integer);
    function FindPageDescribe(const APageName: String; bCreate: Boolean = True): PPageDescribe;
    procedure SetOnActionUpdate(const Value: TNotifyEvent);
  protected
    // FaControls   : TList;
    FOnChange: TNotifyEvent;
    FOnChangevariables: TNotifyEvent;
    FOnExitControl: TNotifyEvent;
    Ftag: Integer;
    FPages: TPageControl;
    procedure DoOnEnter(Sender: TObject);
    procedure DoOnExit(Sender: TObject);
  public
    { Public declarations }
    bEdit: Boolean;
    // FaLabels     : TList;
    OnValidData: TBoolFunction;
    OnCenter: TNotifyEvent;
    function GetPage(const AName: String): PPageDescribe;
    // function NewControl(t: Tclass; Caption:String; w: Integer ):TWinControl;
    function ReplaceControl(i: Integer; ATypeControl: TWinControlClass; Awidth: Integer;
      ATypeBinding: TVkVariableBindingClass = nil): TWinControl;

    function NewControl(ATypeControl: TWinControlClass; const ACaption: String; Awidth: Integer; const AName: String = '';
      ATypeItemBinding: TVkVariableBindingClass = nil; AVar: TVkVariable = nil; const APageName: String = ''): TWinControl;
      overload;

    function NewControl(const APageName: String; ATypeControl: TWinControlClass; const ACaption: String; Awidth: Integer;
      const AName: String = ''; ATypeItemBinding: TVkVariableBindingClass = nil; AVar: TVkVariable = nil): TWinControl; overload;

    function AddControl(ATypeItemBinding: TVkVariableBindingClass; const ACaption: String; Awidth: Integer;
      const AName: String = ''; AVar: TVkVariable = nil; const APageName: String = ''): TWinControl; overload;
    class function GetParrentForm(AControl: TWinControl): TVkDocDialogFm;
    // function LinkWithControl(aTypeControl: TWinControlClass;
    // aControl: TWinControl; aLabel: TLabel; aName: String): TWinControl;
    // procedure SaveControl( oControl:TWinControl; oParent: TWinControl);
    // procedure RegisterControls(aCtrl: TAControls);
    procedure TabPrevious;
    procedure TabNext;
    // procedure RegisterControl
    procedure SetStartSize;
    procedure DoCenter(Owner: TObject);
    procedure Clear;
    property bFirst: Boolean read FbFirst write FbFirst;
    property bDynamic: Boolean read FbDynamic write FbDynamic;
    Property MaxCharLen: Integer read FMaxLen write FMaxLen;
    // procedure DoEditChange(Sender: TObject);
    procedure DoChangeVariables(Sender: TObject);
    function GetControlByVarName(const AName:String):TWinControl;

    property OnChange: TNotifyEvent Read FOnChange write FOnChange;
    property OnChangeVariables: TNotifyEvent Read FOnChangevariables write FOnChangevariables;
    property OnExitControl: TNotifyEvent Read FOnExitControl Write FOnExitControl;
    property BindingList: TEditVkVariableBindingCollection read FBindingCollection;
    property cargo: Integer read Ftag write Ftag;
    property OnActionUpdate: TNotifyEvent read FOnActionUpdate write SetOnActionUpdate;
    property InternalVariables: TVkVariableCollection read FVariableCollection;
    property OnSaveData: TBoolFunction read FOnSaveData write FOnSaveData;
  end;

function GetLocateLine(oOwner: TObject; sTitle: String; sCaption: String; nwidth: Integer; var sResult: String): Boolean;
function GetEditLine(Sender: TObject; sTitle: String; sCaption: String; nwidth: Integer; var s: string): Boolean;
function GetTextWidth(cmb: TWinControl; s: string): Integer;
function GetAveWidth(cmb: TWinControl): Integer;
procedure TestEd;

var
  VkDocDialogFm: TVkDocDialogFm;
  FmLocate: TVkDocDialogFm;
  s_gPoisk: String; // Глобальная строка поиска

implementation

{$R *.DFM}

function TVkDocDialogFm.AddControl(ATypeItemBinding: TVkVariableBindingClass; const ACaption: String; Awidth: Integer;
  const AName: String = ''; AVar: TVkVariable = nil; const APageName: String = ''): TWinControl;
begin
  Result := NewControl(APageName, TWinControlClass(ATypeItemBinding.GetDefaultTypeOfControl), ACaption, Awidth, AName,
    ATypeItemBinding, AVar);
end;

function TVkDocDialogFm.NewControl(const APageName: String; ATypeControl: TWinControlClass; const ACaption: String; Awidth: Integer;
  const AName: String = ''; ATypeItemBinding: TVkVariableBindingClass = nil; AVar: TVkVariable = nil): TWinControl;
var
  Lb: TLabel;
  nLen, i: Integer;
  _Item: TEditVkVariableBinding;
  cVarName: String;
  oControl: TWinControl;
  _Var: TVkVariable;
  _Parent: TWinControl;
  _PageDescribe: PPageDescribe;
begin
  _PageDescribe := GetPage(APageName);
  _Parent := _PageDescribe.Parent;
  Lb := TLabel.Create(Self);
  Lb.Font.Style := Lb.Font.Style + [fsBold];
  Lb.Caption := ACaption;
  Lb.left := _PageDescribe.Fx;
  Lb.Top := _PageDescribe.Fy;
  Lb.Parent := _Parent;

  if AName = '' then
    cVarName := 'Item' + IntToStr(FBindingCollection.Count)
  else
    cVarName := AName;

  if Assigned(ATypeItemBinding) then
    _Item := ATypeItemBinding.Create(BindingList)
  else
  begin
    _item := BindingList.GetBindinClassgOnTypeControl(ATypeControl).Create(BindingList);
  end;

  if Assigned(AVar) then
    _Var := AVar
  else
    _Var := FVariableCollection.CreateVkVariable(cVarName, null);

  _Var.OnChangeVariable := DoChangeVariables;
  _Item.Name := AName;

  { if APageName<>'' then
    _Parent := GetPage(APageName)
    else
    _Parent := self.Scrb;
  }
  // ----------------------------------- !!! ----------------------------------
  // mItem.oControl можно присваивать только когда у oControl определен parent
  // ----------------------------------- !!! ----------------------------------
  oControl := ATypeControl.Create(Self);
  oControl.Parent := _Parent;
  oControl.Name := AName;
  // Выше Component.Name - вызывает OnChange
  _Item.Bind(_Var, oControl);

  // Присваем контрол только после назначения OnChange

  TEdit(_Item.oControl).OnEnter := DoOnEnter;
  TEdit(_Item.oControl).OnExit := DoOnExit;
//  InternalVariables.OnChangeVariable := DoChangeVariables;
  if ATypeControl = TComboBox then
  begin
    TComboBox(_Item.oControl).Style := csDropDownList;
  end;

  if _Item.oControl.Height < 24 then
    _Item.oControl.Height := 24;
  nLen := _PageDescribe.Fx + Lb.width + 10;

  _Item.Lb := Lb;
  if ATypeControl = TCheckBox then
    TCheckBox(_Item.oControl).Caption := '';

  BindingList.AddVkVariableBinding(_Item);

  if _PageDescribe.FLen < nLen then
  begin
    _Item.oControl.left := nLen;
    _PageDescribe.FLen := nLen;
    for i := 0 to BindingList.Count - 1 do
      if (BindingList.Items[i].oControl.left < nLen) and (BindingList.Items[i].oControl.Parent = _PageDescribe.Parent) then
        if BindingList.Items[i].oControl.left <> _PageDescribe.Fx then
          BindingList.Items[i].oControl.left := _PageDescribe.FLen;
  end
  else
  begin
    if _PageDescribe.FLen = 0 then
      _PageDescribe.FLen := nLen;
    _Item.oControl.left := _PageDescribe.FLen;
  end;
  _Item.oControl.Top := _PageDescribe.Fy;
  _Item.oControl.width := GetAveWidth(_Item.oControl) * MIN(Awidth, FMaxLen) + 4;

  // Не видно дату
  if _Item.oControl is TDBDateTimeEditEh then
    if Awidth <= 10 then
      _Item.oControl.width := _Item.oControl.width + 6;

  _Item.oControl.Visible := True;

  Lb.Top := Lb.Top + ((_Item.oControl.Height - Lb.Height) div 2);
  _PageDescribe.Fy := _PageDescribe.Fy + _Item.oControl.Height + 1;
  Result := _Item.oControl;
  Lb.Font.Style := Lb.Font.Style - [fsBold];
  FControlPairList.Add(Lb, _Item.oControl);
  _PageDescribe.FWidth := Max(_PageDescribe.FWidth, _Item.oControl.left + _Item.oControl.width + _PageDescribe.Fx);
  _PageDescribe.FWidth := Max(_PageDescribe.FWidth, TScrollBox(_PageDescribe.Parent).HorzScrollBar.Range +
    TScrollBox(_PageDescribe.Parent).HorzScrollBar.Size);

  if Assigned(FPages) then
  begin
    FPages.ClientHeight := Max(_PageDescribe.Fy + 35, FPages.ClientHeight);
    FPages.ClientHeight := Max(FPages.ClientHeight, TScrollBox(_PageDescribe.Parent).VertScrollBar.Range +
      TScrollBox(_PageDescribe.Parent).VertScrollBar.Size);
    FPages.ClientWidth := Max(_PageDescribe.FWidth, FPages.ClientWidth);
  end;
end;

function TVkDocDialogFm.ReplaceControl(i: Integer; ATypeControl: TWinControlClass; Awidth: Integer;
  ATypeBinding: TVkVariableBindingClass = nil): TWinControl;
var
  mItem, mOldItem: TEditVkVariableBinding;
  oNew: TWinControl;
  oldControl: TWinControl;
begin

  mOldItem := BindingList.Items[i];
  oldControl := mOldItem.oControl;
  if Assigned(ATypeBinding) then
  begin
    mItem := ATypeBinding.Create(BindingList);
    mItem.Name := mOldItem.Name;
    // mOldItem.oControl.Free;
  end
  else
  begin
    mItem := TVkVariableBindingClass(mOldItem.ClassType).Create(BindingList);
    mItem.Name := mOldItem.Name;
    // mItem.oControl.Free;
  end;
  try
    oNew := ATypeControl.Create(Self);
    oNew.Parent := oldControl.Parent;
    oNew.left := oldControl.left;
    if oNew.Height < 24 then
      oNew.Height := 24;
    oNew.Top := oldControl.Top;
    oNew.width := GetAveWidth(oNew) * MIN(Awidth, FMaxLen);
    oNew.Visible := True;
    oNew.Enabled := oldControl.Enabled;

    mItem.oControl := oNew;
    Result := mItem.oControl;

    mItem.Bind(mOldItem.Variable, oNew);

    BindingList.Items[i] := mItem; // old free;
  finally
    FreeAndNil(oldControl);
    { if Assigned(ATypeItemDocControlLink) then
      FreeAndNil(mOldItem); }
  end;
end;

procedure TVkDocDialogFm.FormShow(Sender: TObject);
var
  nH, nW, i: Integer;
begin
  Inherited;

  if not bDynamic then
    Exit;
  bFirst := False;
  if Assigned(FPages) then
  begin
    // FPages.Height := FPages.TabHeight+ FPageDescribeList.GetMaxFy;
    // FPages.Width :=  Max(FPageDescribeList.GetMaxFLen, FPages.TabWidth);
  end;
  nH := Height - Scrb.Height + GetMaxFy + FPageDescribeList.GetMaxFx;
  if Assigned(FPages) then
    nW := width - Scrb.width + Max(Scrb.HorzScrollBar.Range, FPages.width) + FPageDescribeList.GetMaxFx
  else
    nW := width - Scrb.width + Scrb.HorzScrollBar.Range + FPageDescribeList.GetMaxFx;
  if nH > Screen.Height - 40 then
  begin
    nH := Screen.Height - 40;
    // bMaxH := True;
  end;
  if nW > Screen.width - 40 then
  begin
    nW := Screen.width - 40;
  end;

  for i := 0 to BindingList.Count - 1 do
  begin
    if BindingList.Items[i].oControl.Enabled then
    begin
      BindingList.Items[i].oControl.SetFocus;
      Break;
    end;
  end;
  btnOk.Top := (pnBottom.Height - btnOk.Height) div 2;
  BtnCansel.Top := btnOk.Top;
  width := nW;
  Height := nH;

  if BindingList.Count > 0 then
  begin
    if TWinControl(BindingList.Items[Pred(BindingList.Count)].oControl).Top >= (pnBottom.Top - 25) then
      Scrb.VertScrollBar.Visible := True;
  end;
  if Scrb.VertScrollBar.Visible then
    width := width + 15;
  if Scrb.HorzScrollBar.Visible then
    Height := Height + 25;

  if Assigned(Owner) then
  begin
    if Owner is TForm then
    begin
      left := TForm(Owner).left + (TForm(Owner).width - width) div 2 + 1;
      Top := Max(TForm(Owner).Top + (TForm(Owner).Height - Height) div 2 + 1, 10);
    end;
    if Assigned(TFrame(Owner).Owner) then
    begin
      { if TFrame(Owner).Owner is TForm then
        begin
        left := TForm(TFrame(Owner).Owner).left +
        (TForm(TFrame(Owner).Owner).width - width) div 2 + 1;
        Top := Max(TForm(TFrame(Owner).Owner).Top + (TForm(TFrame(Owner).Owner)
        .Height - Height) div 2 + 1, 10);
        end; }
    end;
  end;

  if width < MIN_WIDTH then
    width := MIN_WIDTH;

  if Assigned(FPages) then
  begin
    FPages.width := ClientWidth;
    // FPages.CheckScroll;
  end;

  if Assigned(OnCenter) then
    OnCenter(Self);

  { if Assigned(FPages) then
    begin
    //FPages.Height := FPages.TabHeight+ FPageDescribeList.GetMaxFy;
    FPages.Width :=  width;
    end; }

end;

function TVkDocDialogFm.GetMaxFy: Integer;
begin
  Result := FPageDescribeList[0].Fy;
  if Assigned(FPages) then
    Result := Result + FPages.Height;
end;

function TVkDocDialogFm.GetControlByVarName(const AName:String): TWinControl;
begin
  var binding := FBindingCollection.FindVkVariableBinding(AName);
  if Assigned(binding) then
    Result := binding.GetControl
  else
    raise Exception.CreateFmt('Control not found: %s',[AName]);
end;

function TVkDocDialogFm.GetMaxFLen: Integer;
begin
  Result := FPageDescribeList.GetMaxFLen;
  if Assigned(FPages) then
  begin
    Result := Max(Result, FPages.TabWidth);
    FPages.width := Self.ClientWidth;
  end;
end;

function TVkDocDialogFm.GetPage(const AName: String): PPageDescribe;
begin
  if (AName = '') then
    Result := FPageDescribeList[0]
  else
  begin
    Result := FindPageDescribe(AName);
  end;
end;

function TVkDocDialogFm.FindPageDescribe(const APageName: String; bCreate: Boolean): PPageDescribe;
var
  p: TTabSheet;
  _sb: TScrollBox;
begin
  Result := FPageDescribeList.FindPageDescribe(APageName);
  if not Assigned(Result) then
  begin
    if not bCreate then
      raise Exception.CreateFmt('Page describe %s not found', [APageName]);

    if not Assigned(FPages) then
    begin
      FPages := TPageControl.Create(Self.Scrb);
      FPages.Top := FPageDescribeList[0].Fy + 5;
      FPages.Parent := Self.Scrb;
      FPages.Height := 25;
      FPages.width := Self.Scrb.width;
    end;
    p := TTabSheet.Create(FPages);
    p.PageControl := FPages;
    p.Caption := APageName;
    _sb := TScrollBox.Create(p);
    _sb.Parent := p;
    _sb.Align := alClient;
    FPageDescribeList.AddPageDescribe(p, _sb, 10, 10, 0);
    Result := FPageDescribeList[FPageDescribeList.Count - 1];
  end;
end;

class function TVkDocDialogFm.GetParrentForm(AControl: TWinControl): TVkDocDialogFm;
var
  _Control: TWinControl;
begin
  _Control := AControl;
  while Assigned(_Control) and not(_Control is TVkDocDialogFm) do
    _Control := _Control.Parent;
  Result := TVkDocDialogFm(_Control);
end;

function TVkDocDialogFm.NewControl(ATypeControl: TWinControlClass; const ACaption: String; Awidth: Integer; const AName: String;
  ATypeItemBinding: TVkVariableBindingClass; AVar: TVkVariable; const APageName: String): TWinControl;
begin
  Result := NewControl(APageName, ATypeControl, ACaption, Awidth, AName, ATypeItemBinding, AVar);
end;

procedure TVkDocDialogFm.FormCreate(Sender: TObject);
begin
  FBindingCollection := TEditVkVariableBindingCollection.Create(Self);
  FVariableCollection := TVkVariableCollection.Create(Self);
  // FaLabels  := TList.Create;
  FPageDescribeList := TPageDescribeList.Create;
  FPageDescribeList.AddPageDescribe(Self.Scrb, Self.Scrb, 10, 10, 0);
  { Fx := 10;
    Fy := 10;
    FLen := 0; }
  FMaxLen := Screen.width;
  FbFirst := True;
  FbDynamic := True;
  FControlPairList := TControlPairList.Create;
end;

procedure TVkDocDialogFm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FControlPairList);
  FPageDescribeList.Clear;
  FreeAndNil(FPageDescribeList);
  Inherited;
end;

{ Форма поиска }
function GetLocateLine(oOwner: TObject; sTitle: String; sCaption: String; nwidth: Integer; var sResult: String): Boolean;
var
  FmLocate: TVkDocDialogFm;
begin
  if (sTitle = '') then
    sTitle := 'Поиск';
  if sCaption = '' then
    sCaption := 'Строка поиска';
  if nwidth = 0 then
    nwidth := 20;

  FmLocate := TVkDocDialogFm.Create(TComponent(oOwner));
  FmLocate.FbFree := True;
  FmLocate.Scrb.BorderStyle := bsNone;
  FmLocate.NewControl(TItemEdit, sCaption, nwidth, 'edPoisk');
  TEdit(FmLocate.BindingList.Items[0].oControl).Text := sResult;
  FmLocate.Caption := sTitle;
  if FmLocate.ShowModal = mrOk then
  begin
    sResult := FmLocate.BindingList.vkvariablebinding['edPoisk'].Variable.AsString;
    Result := True;
  end
  else
  begin
    Result := False;
  end;

end;

{ Вычисление средней длины символа в пикселях }
function GetAveWidth(cmb: TWinControl): Integer;
var
  tm: TTextMetric;
begin
  GetTextMetrics(GetDc(cmb.handle), tm);
  Result := tm.tmAveCharWidth;
end;

{ Вычисление длины техта в пикселях }
function GetTextWidth(cmb: TWinControl; s: string): Integer;
var
  sSize: TSize;
begin
  GetTextExtentPoint32(GetDc(cmb.handle), Pchar(s), StrLen(Pchar(s)), sSize);
  Result := sSize.cx;
end;

procedure TVkDocDialogFm.pnBottomResize(Sender: TObject);
begin
  BtnCansel.left := pnBottom.width - BtnCansel.width - 10;
  btnOk.left := BtnCansel.left - btnOk.width - 10;
end;

procedure TestEd;
var
  fm: TVkDocDialogFm;
begin
  fm := TVkDocDialogFm.Create(Application);
  fm.ShowModal;
  fm.Free;
end;

function GetEditLine(Sender: TObject; sTitle: String; sCaption: String; nwidth: Integer; var s: String): Boolean;
var
  fm: TVkDocDialogFm;
  ed: TEdit;
begin
  fm := TVkDocDialogFm(TComponent(Sender).FindComponent('fmEditLineAvto'));
  if fm = nil then
  begin
    fm := TVkDocDialogFm.Create(TForm(Sender));
    fm.Name := 'fmEditLineAvto';
    ed := TEdit(fm.NewControl(TItemEdit, sCaption, nwidth, 'ed'));
    ed.Text := s;
  end
  else
  begin
    ed := TEdit(fm.FindComponent('ed'));
    ed.Text := s;
  end;

  fm.Caption := sTitle;
  if fm.ShowModal = mrOk then
  begin
    s := ed.Text;
    if s = '' then
      ShowMessage(sCaption + ' - пустая строка!');
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

{ SetStartSize }
// Установка минимальных размеров окна
procedure TVkDocDialogFm.SetOnActionUpdate(const Value: TNotifyEvent);
begin
  FOnActionUpdate := Value;
end;

procedure TVkDocDialogFm.SetStartSize;
begin
  Height := 90;
  width := 238;
  FPageDescribeList.Clear;
  FPageDescribeList.AddPageDescribe(Self.Scrb, Self.Scrb, 10, 10, 0);
  { Fx := 10;
    Fy := 10;
    FLen := 0; }
end;

procedure TVkDocDialogFm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FbFree then
    Action := caFree;
end;

procedure TVkDocDialogFm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult = mrOk then
  begin
    if Assigned(OnValidData) then
      CanClose := OnValidData(Self);
    if CanClose and Assigned(OnSaveData) then
      CanClose := OnSaveData(Self);

  end;

end;

procedure TVkDocDialogFm.DoCenter(Owner: TObject);
begin
  if Assigned(Owner) then
  begin
    Top := TForm(Owner).Top + (TForm(Owner).Height - Height) div 2 + 1;
    left := TForm(Owner).left + (TForm(Owner).width - width) div 2 + 1;
  end
  else
  begin
    Top := (Screen.Height - Height) div 2 + 1;
    left := (Screen.width - width) div 2 + 1;
  end;
end;

procedure TVkDocDialogFm.DoChangeVariables(Sender: TObject);
begin
{  if not (Sender is TVkVariable) then
    Exit;
  if InternalVariables.InInit then
      Exit
  else
  begin
    InternalVariables.InInit := true;
    try}
      if Assigned(FOnChangeVariables) then
        FOnChangeVariables(Sender);
{    finally
       Intems.VarList.InInit := False;
    end;
  end;}
end;

procedure TVkDocDialogFm.aCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TVkDocDialogFm.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  inherited;
  if Assigned(FOnActionUpdate) then
    FOnActionUpdate(Self);
end;

procedure TVkDocDialogFm.aOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TVkDocDialogFm.Clear;
begin
  if Assigned(BindingList) then
  begin
    BindingList.Clear;
    FVariableCollection.Clear;
    FControlPairList.Clear;
    FPageDescribeList.Clear;
    FPageDescribeList.AddPageDescribe(Self.Scrb, Self.Scrb, 10, 10, 0);
    if Assigned(FPages) then
    begin
      while FPages.PageCount > 0 do
        FPages.Pages[0].Free;
      FreeAndNil(FPages);
    end;
  end;
  { Fx := 10;
    Fy := 10;
    FLen := 0; }
  width := 175;
  Height := 81;
end;

procedure TVkDocDialogFm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  bIsCombo: Boolean;
  bIsMemo: Boolean;
  // bIsExclude: Boolean;
begin
  inherited;

  bIsCombo := ActiveControl is TComboBox;
  bIsMemo := (ActiveControl is TMemo); // or (ActiveControl is TSynEdit);

  if (Shift = []) and not bIsMemo then
  begin
    case Key of
      VK_DOWN:
        begin
          if not bIsCombo or not(TComboBox(ActiveControl).DroppedDown) then
          begin
            Key := 0;
            TabNext;
          end;
        end;
      VK_UP:
        begin
          if not bIsCombo or not(TComboBox(ActiveControl).DroppedDown) then
          begin
            Key := 0;
            TabPrevious;
          end;
        end;
    end;
  end
  else
  begin
    // TEdit(ActiveControl).OnKeyDown(ActiveControl,Key,Shift);
    if (ssCtrl in Shift) and (Key = VK_RETURN) then
    begin
      { if ActiveControl is TMEditBox then
        TMEditBox(ActiveControl).OnButtonClick(ActiveControl); }
      ModalResult := mrOk;
      // key:=0;
    end;
  end;
end;

procedure TVkDocDialogFm.TabPrevious;
var
  wc: TWinControl;
begin
  wc := FindNextControl(ActiveControl, False, True, False);
  if Assigned(wc) then
    ActiveControl := wc;
end;

procedure TVkDocDialogFm.TabNext;
var
  wc: TWinControl;
begin
  wc := FindNextControl(ActiveControl, True, True, False);
  if Assigned(wc) then
    ActiveControl := wc;
end;

{ procedure TFmDocDialog.DoEditChange(Sender: TObject);
  begin
  if not (Sender is TDocVariable) then
  Exit;
  if Items.VarList.InInit then
  Exit
  else
  begin
  Items.VarList.InInit := true;
  try
  if Assigned(FOnChange) then
  FOnChange(Sender);
  finally
  Items.VarList.InInit := False;
  end;
  end;
  end; }

procedure TVkDocDialogFm.DoOnEnter(Sender: TObject);
var
  i: Integer;
begin
  i := BindingList.IndexOfControl(TWinControl(Sender));
  if i > -1 then
    TEditVkVariableBinding(BindingList.Items[i]).Lb.Font.Style := BindingList.Items[i].Lb.Font.Style + [fsBold];

end;

procedure TVkDocDialogFm.DoOnExit(Sender: TObject);
var
  i: Integer;
begin
  i := BindingList.IndexOfControl(TWinControl(Sender));
  if i > -1 then
    TEditVkVariableBinding(BindingList.Items[i]).Lb.Font.Style := TEditVkVariableBinding(BindingList.Items[i]).Lb.Font.Style
      - [fsBold];
  if Assigned(OnExitControl) then
    OnExitControl(Sender);
end;

{ TPageDescribeList }

procedure TPageDescribeList.AddPageDescribe(AOwner, AParent: TWinControl; AFx, AFy, AFLen: Integer);
var
  _p: PPageDescribe;
begin
  New(_p);
  _p.Parent := AParent;
  _p.Owner := AOwner;
  _p.Fx := AFx;
  _p.Fy := AFy;
  _p.FLen := AFLen;
  _p.FWidth := 0;
  Add(_p);
end;

procedure TPageDescribeList.CheckScroll;
begin

end;

procedure TPageDescribeList.Clear;
begin
  while Count > 0 do
  begin
    Dispose(Items[0]);
    Delete(0);
  end;
end;

destructor TPageDescribeList.Destroy;
begin
  Clear;
  inherited;
end;

function TPageDescribeList.FindPageDescribe(const AName: String): PPageDescribe;
var
  i: Integer;
begin
  Result := nil;
  for i := 1 to Count - 1 do
  begin
    if SameText(AName, TTabSheet(Items[i].Owner).Caption) then
      Result := Items[i];
  end;
end;

function TPageDescribeList.GetMaxFLen: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Max(Result, Items[i].FLen)
end;

function TPageDescribeList.GetMaxFx: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Max(Result, Items[i].Fx)
end;

function TPageDescribeList.GetMaxFy: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    Result := Max(Result, Items[i].Fy)
end;

end.
