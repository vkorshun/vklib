{***********************************************************
 Проект AccessMDI
 Демонстрация интерфейса MDI в стиле Access

 Григорьев Антон, 2005
 Специально для Королевства Delphi
 http://www.delphikingdom.com

 Модуль, реализующий невидимое окно, отвечающее за кнопку на
 панели задач. Этот же класс окна используется для создания
 невидимого окна, помогающего "отжать" кнопки при
 сворачивании главного окна. Поведение формы зависит от того,
 кто является его владельцем - главная форма или форма с
 документом.
 ***********************************************************}
unit TaskBarButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TButtonForm = class(TForm)
   private
    procedure WMNCActivate(var Msg:TWMNCActivate);message WM_NCActivate;
    procedure WMSysCommand(var Msg:TWMSysCommand);message WM_SysCommand;
    procedure WMInitMenu(var Msg:TWMInitMenu);message WM_InitMenu;
   protected
    procedure CreateParams(var Params: TCreateParams);override;
   public
    { Public declarations }
  end;

var
  ButtonForm: TButtonForm;

implementation

uses i_vkinterface;
//  AMMain, AMChild;

{$R *.dfm}

var AppActivating:Boolean=False;


procedure TButtonForm.CreateParams(var Params: TCreateParams);
 begin
  inherited;
  Params.Style:=WS_Visible or WS_Popup or WS_SysMenu;
  // Если владелец - главная форма, устанавливаем флаг
  // WS_EX_ToolWindow, т.к. данный экземпляр формы будет
  // использован для "отжатия" кнопок.
  if Owner=Application.MainForm then
   Params.ExStyle:=WS_EX_ToolWindow;
  // Чтобы появилась кнопка на панели задач, делаем форму
  // без родителя и владельца. В данном случае этот способ
  // предпочтительнее флага WS_EX_AppWindow, т.к. окно
  // получается независимым от невидимого окна приложения.
  Params.WndParent:=0;
  Params.Width:=0;
  Params.Height:=0
 end;

procedure TButtonForm.WMNCActivate(var Msg:TWMNCActivate);
var oIFmMainMDI: IFmMainMdi;
begin
  inherited;
  if not Assigned(Application.MainForm) then
    Exit;
  oIFmMainMdi := (Application.MainForm) as IFmMainMDI;
  if (Owner<>Application.MainForm) and Msg.Active and not AppActivating and not (csDestroying in ComponentState) and not oIFmMainMDI.Minimizing then
   begin
    WindowState:=wsMinimized;
    (Owner as IFmChildMDI).DocActivate
   end
 end;

procedure TButtonForm.WMSysCommand(var Msg:TWMSysCommand);
 begin
  if Owner<>Application.MainForm then
   case Msg.CmdType of
    SC_Close:
     (Owner as TForm).Release;
    SC_Minimize:
      (Owner as TForm).WindowState:=wsMinimized;
    SC_Maximize:
     (Owner as TForm).WindowState:=wsMaximized;
    SC_Restore:
     (Owner as TForm).WindowState:=wsNormal;
    SC_Move,SC_Size:
     begin
     end
   else
    inherited
   end
  else
   inherited
 end;

procedure TButtonForm.WMInitMenu(var Msg:TWMInitMenu);
 begin
  if Owner<>Application.MainForm then
   begin
    EnableMenuItem(Msg.Menu,SC_Move,MF_ByCommand or MF_Grayed);
    EnableMenuItem(Msg.Menu,SC_Size,MF_ByCommand or MF_Grayed);
    if (Owner as TForm).WindowState=wsMinimized then
     EnableMenuItem(Msg.Menu,SC_Minimize,MF_ByCommand or MF_Grayed)
    else
     EnableMenuItem(Msg.Menu,SC_Minimize,MF_ByCommand or MF_Enabled);
    if (Owner as TForm).WindowState=wsMaximized then
     EnableMenuItem(Msg.Menu,SC_Maximize,MF_ByCommand or MF_Grayed)
    else
     EnableMenuItem(Msg.Menu,SC_Maximize,MF_ByCommand or MF_Enabled);
    if (Owner as TForm).WindowState=wsNormal then
     EnableMenuItem(Msg.Menu,SC_Restore,MF_ByCommand or MF_Grayed)
    else
     EnableMenuItem(Msg.Menu,SC_Restore,MF_ByCommand or MF_Enabled);
   end;
  inherited
 end;

end.
