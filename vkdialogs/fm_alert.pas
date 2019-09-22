unit fm_alert;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons;

const
  WM_DEFAULT = WM_USER+ 1013;
type
  PParamAlert = ^RparamAlert;
  RParamAlert = record
    aFontName: String;
    aFontSize: Integer;
    aFontStyle:TFontStyles;
    aFontColor: TColor;
  end;

  TFmAlert = class(TForm)
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FButtonId: Integer;
    LabelList: TList;
    FButtonsList: TList;
    bNormal: Boolean;
    m_lx: Integer;
    m_ly: Integer;
    m_bx: Integer;
    m_by: Integer;
    w_label:Integer;
    h_button: Integer;
    procedure ButtonClick(aSender: TObject);
    procedure DoShow2;
    function GetTextWidth(s:String; oFont:TFont):Integer;
    procedure InitFirst;
    procedure SetCancelButtonId(aIndex:Integer);
  public
    { Public declarations }
    procedure Clear;
    procedure AddButton(aCaption:String; aP:PParamAlert = nil);
    procedure AddLabel(aCaption:String; aP:PParamAlert = nil );
    procedure wmDefault(var aMes:TMessage); message WM_DEFAULT;
    property ButtonId:Integer read FButtonId;
    property ButtonList:TList read FButtonsList;
    property CancelButtonId:Integer write SetCancelButtonId;
    class function SetAlert(aOwner:TComponent;aMes, aBut:array of String; aIdCancel:Integer):Integer;
  end;

var
  FmAlert: TFmAlert;

implementation

{$R *.dfm}
uses math;


{ TFmAlert }

procedure TFmAlert.AddButton(aCaption: String; aP:PParamAlert);
var
  mBtn: TBitBtn;
begin
  mBtn := TBitBtn.create(Panel1);
  with mBtn do
  begin
//    mBtn.AutoSize   := True;
    if Assigned(aP) then
    begin
      Height     := aP.aFontSize+30;
      if aP.aFontname<>'' then
        Font.Name  := aP.aFontName;
      if aP.aFontSize<>0 then
        Font.Size  := aP.aFontSize;
      Font.Style := aP.aFontStyle;
      Font.Color := aP.aFontColor;
    end;
    Parent     := Panel1;
    Top        := m_by;
    Left       := m_bx;
    Caption    := aCaption;

    Width      :=    Max(75,GetTextWidth(aCaption,Font)+20);
//    GetTextWidth(mBtn.Handle,aCaption)));
//    AdjustSize;
    m_bx := m_bx + mBtn.Width+10;
    OnClick := ButtonClick;
  end;
  if h_button < mBtn.Height then
    h_button := mBtn.Height;
  FButtonsList.Add(mBtn);
end;


procedure TFmAlert.AddLabel(aCaption: String; aP:PParamAlert);
var lb:TLabel;
begin

  lb := TLabel.create(ScrollBox1);
  lb.Caption    := aCaption;
  if Assigned(aP) then
  begin
    if aP.aFontname<>'' then
      lb.Font.Name  := aP.aFontName;
    if aP.aFontSize>0  then
      lb.Font.Size  := aP.aFontSize;
    lb.Font.Style := aP.aFontStyle;
//  if aSsigned(aFontColor) then
    lb.Font.Color := aP.aFontColor;
  end;
  lb.Parent     := ScrollBox1;
  lb.Top        := m_ly;
  lb.Left       := m_lx;
  m_ly := m_ly + lb.Height+10;
  if w_label<lb.Width then
    w_label := lb.Width;

  LabelList.Add(lb);
end;

procedure TFmAlert.ButtonClick(aSender: TObject);
var i: Integer;
begin
//    ShowMessage(IntToStr(TButton(aSender).Caption),));
  for I := 0 to FButtonsList.Count - 1 do
  if aSender= TObject(FButtonsList[i]) then
    FButtonId := i;

  ModalResult := MrOk;
end;

procedure TFmAlert.Clear;
var i: Integer;
begin
  for I := 0 to LabelList.Count - 1 do
    TLabel(LabelList[i]).Free;

  for I := 0 to FButtonsList.Count - 1 do
    TButton(FButtonsList[i]).Free;

  LabelList.Clear;
  FButtonsList.Clear;

  //---- Востан. высоту
  Height := Height- m_ly;

  InitFirst;
end;


procedure TFmAlert.DoShow2;
var i:Integer;
begin

   //----- Расчет размеров ------
   Width := MAX(w_label+2*m_lx,m_bx+5);
   Height := Height- Panel1.Height;
   Panel1.Height := h_button+20;
   Height:= Height+m_ly+Panel1.Height;
   bNormal := True;

   //----- Центрирование
   with ScrollBox1 do
   for i := 0 to ComponentCount - 1 do
   begin
     if Components[i] is TLabel then
       TLabel(Components[i]).Left := (ScrollBox1.Width- TLabel(Components[i]).width ) div 2;
   end;

   with panel1 do
   begin
     for i := 0 to ComponentCount - 1 do
     begin
       if Components[i] is TButton then
         TButton(Components[i]).Left := TButton(Components[i]).Left +(Panel1.Width-m_bx-5)div 2;
     end;
     Caption := '';
   end;


  // ShowModal;
end;

procedure TFmAlert.FormCreate(Sender: TObject);
begin
  InitFirst;
  LabelList := TList.Create;
  FButtonsList := TList.Create;
end;



procedure TFmAlert.FormDestroy(Sender: TObject);
begin
  LabelList.Free;
  FButtonsList.Free;
end;

procedure TFmAlert.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_ESCAPE then
    ModalResult := MrCancel;
end;

procedure TFmAlert.FormShow(Sender: TObject);
begin
  FButtonId := -1;
  if not bNormal then
    DoShow2;
end;

function TFmAlert.GetTextWidth(S:String;oFont:TFont):integer;
//  var sSize:TSize;
begin
//  GetTextExtentPoint32(GetDc(handle),PChar(s),StrLen(PChar(s)),sSize);
//  result:= sSize.cx;
   Label1.Font.Assign(oFont);
   Label1.Caption := s;
   Label1.Visible := False;
   Result :=  Label1.Width;

end;


procedure TFmAlert.InitFirst;
begin
  m_lx := 10;
  m_ly := 10;
  m_bx := 10;
  m_by := 10;

  bNormal := False;
  w_label := 0;
  h_button:= 0;

end;

class function TFmAlert.SetAlert(aOwner:TComponent;aMes, aBut: array of String;
  aIdCancel:Integer): Integer;
var fm: TFmalert;
    i: Integer;
begin
  fm := TFmAlert.Create(aOwner);
  with fm do
  begin
    for I := Low(ames) to High(aMes) do
      AddLabel(aMes[i]);
    for I := Low(aBut) to High(aBut) do
      AddButton(aBut[i]);
    if aIdCancel>-1 then
      SetCancelButtonId(aIdCancel);
    if ShowModal= mrOk then
      Result := FButtonId
    else
      Result := -1;
  end;
end;

procedure TFmAlert.SetCancelButtonId(aIndex:Integer);
begin
  TButton(FButtonsList[aIndex]).Cancel := True;
end;

procedure TFmAlert.wmDefault(var aMes: TMessage);
begin
  FButtonId := 0;
  Close;
end;

end.
