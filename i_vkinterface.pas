{*************************************
   Модуль i_vkinterface
***************************************}

unit i_vkinterface;

interface

uses
  SysUtils, Classes, Messages, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DateVk;

const
  WM_SETCHILDWINDOW = WM_USER+501;

type

  TInterfaceEvent = procedure(oI:IInterface ) of object;
//  TVarList = class;

  IVkInterface = interface
  ['{8F56E976-D452-423C-81DD-4D7FB0F32F00}']
    function GetPInterface:Pointer;
    procedure SetPInterface(const aP:Pointer);
    property PInterface:Pointer read GetPInterface write  SetPInterface;
  end;
  TGetVkInterface = function (owner:TComponent):IVkInterface;


  IFmMainMDI = Interface
  ['{7BCE1B3A-A68E-44A8-8413-8EFFAAE8A7FE}']
    function GetMinimizing:Boolean;
    property Minimizing:Boolean read GetMinimizing;
    procedure SetMDIPosition(aFm:TForm);
  End;

  IFmChildMdi = Interface
  ['{A7385B7B-72D6-4E61-A015-86995C0ECF0B}']
    procedure DocActivate;
//    procedure Release;
  End;

  IFmView   = Interface(IVkInterface)
    ['{5BA132F3-6D1B-4637-8672-0F5E2EC56704}']
    procedure View;
  End;

  IFmSelect = Interface(IFmView)
    ['{9E374369-13D0-4EFF-BF19-7089DC433B7B}']
    function Select( VarList: TObject = nil):boolean;  // Метод выбора
    function GetBeforeSelect:TInterfaceEvent;          // OnBeforeSelect
    function GetItemName(kod: Integer):String;         // Наименование
    function GetSelectedList:TLargeIntList;                // Selected
    function GetMultiSelect:Boolean;                  // bMultiSelect
    function GetValue:Variant;                        // Возвращает либо Selected[0] либо 0
    procedure DestroyInterface(var oI);               // IFmSelect(oI).PInterface := nil;
    procedure SetBeforeSelect(const aF:TInterfaceEvent);    // OnBeforeSelect
    procedure SetMultiSelect(const b:Boolean);              // bMultiSelect
    procedure SetValue(const aV: variant);                  // Инициализирует Selected, позиционирование + первоначальные установки
    property Selected:TLargeIntList read GetSelectedList ;  // Список выбранных значений
    property bMultiSelect:Boolean read GetMultiSelect write SetMultiSelect;
    property OnBeforeSelect:TInterfaceEvent read GetBeforeSelect write SetBeforeSelect;

//   function GetItemType(kod: Integer):String;
//    function GetCurrentKod:Integer;
//   function GetListRoot:TIntList;
//    procedure SetCurrentKod(aKod:Integer);
//    procedure SetPInterface(aP:Pointer);
//    function GetPInterface:Pointer;
//    property currentkod: Integer read GetCurrentKod write SetCurrentKod;
//    property List:TIntList read GetSelectedList ;
//    property ListRoot:TIntList read GetListRoot ;





{    procedure Select;
    procedure SetBeforeSelect(p: TInterfaceEvent);

    function GetBeforeSelect:TInterfaceEvent;
    property BeforeSelect: TInterfaceEvent read GetBeforeSelect write SetBeforeSelect;}
  End;


  IDmRegKey = Interface(IVkInterface)
  ['{553D4FB2-923C-4C45-9E7E-1E8DB6EB5CC4}']
    procedure SetRootKey(const aKey:String);
    function  GetRootKey:String;
    procedure CreateKey(const Key:String);
    function GoToKey(const Key:String;bCreate:boolean =False ):Boolean;
    function GetKeyValue(const Key: String; Default:Variant):Variant;
    function IsKey(const aKey:String):Boolean;
    procedure SetKeyValue(const Key:String; Val: Variant;const cType:String; bCreate: Boolean = True);
    procedure GetSection(const Key:String;var List:TList);
    procedure DeleteKey(const Key:String);
    property RootKey: String read GetRootKey write SetRootKey;

  end;




implementation
end.
