unit fm_childmdi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,i_vkinterface, taskbarbutton;

type
  TFmChildMdi = class(TForm,IFmChildMDI)
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    // ”казатель на форму, реализующую кнопку на панели
    // задач, св€занную с данным окном
    FTaskBarButton:TButtonForm;
    // ќбработчик WM_SetText перекрыт, чтобы при каждом
    // изменении заголовка формы с документом измен€лс€ бы
    // заголовок формы, реализующей кнопку
    procedure WMSetText(var Msg:TWMSetText);message WM_SetText;
    // ƒанный метод нажимает кнопку путЄм активации формы,
    // реализующей эту кнопку
    procedure PressTaskBarBtn;

  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
    procedure DocActivate;
  end;

var
  FmChildMdi: TFmChildMdi;

implementation

{$R *.dfm}

{ TForm1 }

constructor TFmChildMdi.Create(AOwner: TComponent);
begin
  inherited;
  FTaskBarButton:=TButtonForm.Create(Self)
end;

procedure TFmChildMdi.DocActivate;
begin
  // ƒл€ активации окна с документом сначала показываем
  // главное окно, разворачива€ его, если оно минимизировано,
  // затем, при необходимости, разворачиваем само окно, а
  // дл€ его активации используем сообщение
  // WM_MDDIActivate. –азработчики VCL почему-то сделали
  // свойство ActiveMDIChild доступным только дл€ чтени€,
  // поэтому приходитс€ использовать API.
  Application.MainForm.Show;
  if Application.MainForm.WindowState=wsMinimized then
   Application.MainForm.WindowState:=wsNormal;
  if WindowState=wsMinimized then
   WindowState:=wsNormal;
  SendMessage(Application.MainForm.ClientHandle,WM_MDIActivate,Handle,0)

end;

// ѕри активации окна, реализующего кнопку, оно
// сворачиваетс€ и передаЄт активность форме с документом,
// вызыва€ еЄ метод DocActivate. „тобы нажать кнопку, когда
// форма с документом активируетс€ иным образом, окно,
// создающее кнопку, активируетс€ вручную, что тут же
// приводит к активации св€занного с ним окна с документом.
// «ацикливани€ в данном случае не происходит потому, что
// при активации дочернего MDI-окна через WM_MDIActivate
// событие OnActivate не возникает.
procedure TFmChildMdi.FormActivate(Sender: TObject);
begin
  PressTaskBarBtn
end;

procedure TFmChildMdi.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;

procedure TFmChildMdi.PressTaskBarBtn;
begin
  // ѕроверка на существование FTaskBarButton добавлена
  // потому, что первое событие активации возникает во врем€
  // работы унаследованного конструктора, т.е. до создани€
  // FTaskBarButton.
  if Assigned(FTaskBarButton) then
   SetActiveWindow(FTaskBarButton.Handle)
end;

procedure TFmChildMdi.WMSetText(var Msg: TWMSetText);
begin
  inherited;
  // ѕервый раз сообщение WS_SetText поступает при работе
  // унаследованного конструктора, т.е. до создани€
  // FTaskBarButton, поэтому, чтобы не пытатьс€ изменить
  // заголовок несуществующего окна, провер€етс€, что
  // FTaskBarButton<>nil.
  if Assigned(FTaskBarButton) then
   FTaskBarButton.Caption:=Caption
end;

end.
