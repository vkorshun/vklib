unit fm_texteditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus,  SynEdit,
  frame_texteditor;

type
  TFmTextEditor = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btCancel: TButton;
    btOK: TButton;
    procedure FormShow(Sender: TObject);
    procedure SaveandExit1Click(Sender: TObject);
    procedure Exitwithoutsaving1Click(Sender: TObject);
    procedure MemoExKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FBreak: Boolean;
    FNeedCheckNotEmpty: Boolean;
    procedure OkClick(Sender:TObject);
  public
    { Public declarations }
    FrameTextEdit: TFrameTextEditor;
    property IsBreak:Boolean read FBreak;
    property NeedCheckNotEmpty: Boolean read FNeedCheckNotEmpty write FNeedCheckNotEmpty;
  end;
  function TextEdit(const sCaption,S:String; checkNotEmpty: Boolean = false):String;

var
  FmTextEditor: TFmTextEditor;

implementation

{$R *.DFM}

procedure TFmTextEditor.FormShow(Sender: TObject);
begin
  ActiveControl := FrameTextEdit.Memo;
end;

procedure TFmTextEditor.SaveandExit1Click(Sender: TObject);
begin
  btOK.Click;
end;

procedure TFmTextEditor.Exitwithoutsaving1Click(Sender: TObject);
begin
  btCancel.Click;
end;



procedure TFmTextEditor.MemoExKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_F2 then
    btOK.Click;
  if key = VK_ESCAPE then
    btCancel.Click;
end;

procedure TFmTextEditor.FormActivate(Sender: TObject);
begin
  FrameTextEdit.Memo.CaretX:=0;
  FrameTextEdit.Memo.CaretY:=0;
end;



procedure TFmTextEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (length(FrameTextEdit.Memo.Text)=0) then
  begin
    ShowMessage('Необходимо ввести информацию');
    CanClose := False;
  end
  else
  begin
    if (ModalResult <> mrOk) and FrameTextEdit.Memo.Modified then
      if (MessageDlg(' Сохранить изменения?',mtConfirmation,[mbYes,mbNo],0)= mrYes) then
        ModalResult := mrOk;
  end;
end;

procedure TFmTextEditor.FormCreate(Sender: TObject);
begin
  inherited;
//SynMemo1.RightMargin := Screen.Width div GetAveWidth(SynMemo1)+10;
  FrameTextEdit := TFrameTextEditor.Create(self);
  FrameTextEdit.Parent := self;
  FrameTextEdit.Align := alClient;
  FrameTextEdit.langId := 'en';
  FrameTextEdit.imSave.OnClick := OkClick;
end;


procedure TFmTextEditor.OkClick(Sender: TObject);
begin
  ModalResult := MrOk;
end;

function TextEdit(const sCaption,S:String; checkNotEmpty:Boolean ):String;
var fm: TFmTextEditor;
begin
  fm := TFmTextEditor.Create(Application);
  try
    fm.Caption := sCaption;
    fm.FrameTextEdit.Memo.Lines.Text :=s;
    if fm.ShowModal = mrOk then
      Result:= fm.FrameTextEdit.Memo.Lines.Text
    else
      Result := s;
  finally
    fm.Free;
  end;
end;

end.
