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
    // ��������� �� �����, ����������� ������ �� ������
    // �����, ��������� � ������ �����
    FTaskBarButton:TButtonForm;
    // ���������� WM_SetText ��������, ����� ��� ������
    // ��������� ��������� ����� � ���������� ��������� ��
    // ��������� �����, ����������� ������
    procedure WMSetText(var Msg:TWMSetText);message WM_SetText;
    // ������ ����� �������� ������ ���� ��������� �����,
    // ����������� ��� ������
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
  // ��� ��������� ���� � ���������� ������� ����������
  // ������� ����, ������������ ���, ���� ��� ��������������,
  // �����, ��� �������������, ������������� ���� ����, �
  // ��� ��� ��������� ���������� ���������
  // WM_MDDIActivate. ������������ VCL ������-�� �������
  // �������� ActiveMDIChild ��������� ������ ��� ������,
  // ������� ���������� ������������ API.
  Application.MainForm.Show;
  if Application.MainForm.WindowState=wsMinimized then
   Application.MainForm.WindowState:=wsNormal;
  if WindowState=wsMinimized then
   WindowState:=wsNormal;
  SendMessage(Application.MainForm.ClientHandle,WM_MDIActivate,Handle,0)

end;

// ��� ��������� ����, ������������ ������, ���
// ������������� � ������� ���������� ����� � ����������,
// ������� � ����� DocActivate. ����� ������ ������, �����
// ����� � ���������� ������������ ���� �������, ����,
// ��������� ������, ������������ �������, ��� ��� ��
// �������� � ��������� ���������� � ��� ���� � ����������.
// ������������ � ������ ������ �� ���������� ������, ���
// ��� ��������� ��������� MDI-���� ����� WM_MDIActivate
// ������� OnActivate �� ���������.
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
  // �������� �� ������������� FTaskBarButton ���������
  // ������, ��� ������ ������� ��������� ��������� �� �����
  // ������ ��������������� ������������, �.�. �� ��������
  // FTaskBarButton.
  if Assigned(FTaskBarButton) then
   SetActiveWindow(FTaskBarButton.Handle)
end;

procedure TFmChildMdi.WMSetText(var Msg: TWMSetText);
begin
  inherited;
  // ������ ��� ��������� WS_SetText ��������� ��� ������
  // ��������������� ������������, �.�. �� ��������
  // FTaskBarButton, �������, ����� �� �������� ��������
  // ��������� ��������������� ����, �����������, ���
  // FTaskBarButton<>nil.
  if Assigned(FTaskBarButton) then
   FTaskBarButton.Caption:=Caption
end;

end.
