unit EditContext;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, db;

type
  TEditContext = class(TEdit)
  procedure MyChange(Sender: TObject);
  private
    { Private declarations }
    FActiveControl: TWinControl;
    FDataLink: TDataLink;
    FKeyField: String;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure SetDataSource(ds:TDataSource);
    function GetDataSource:TDataSource;
  protected
    { Protected declarations }
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure MyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//    procedure MyKeyPress(Sender: TObject; var Key: Char);
//    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
  public
    { Public declarations }
    Constructor Create(Sender: TComponent);override;
    Destructor Destroy;override;
    procedure Repaint;override;
  published
    { Published declarations }
    property ActiveControl:TWinControl read FActiveControl write FActiveControl;
    property DataSource:TDataSource read GetDataSource write SetDataSource;
    property KeyField:String read FKeyField write FKeyField;
  end;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('VkComp', [TEditContext]);
end;

constructor TEditContext.Create(Sender : TComponent);
begin
  inherited Create(Sender);
  Text:='';
  FDataLink := TDataLink.Create;
//  OnKeyDown:= MyKeyDown;
//  OnKeyPress := MyKeyPress;
  OnChange := MyChange;
  OnKeyDown := MyKeyDown;
end;

procedure TEditContext.Repaint;
begin
  inherited ;
end;


Destructor TEditContext.Destroy;
begin
  inherited;
end;

procedure TEditContext.WMSetFocus(var Message: TWMSetFocus);
begin
//  SendMessage(Handle,EM_SETMARGINS,EC_RIGHTMARGIN OR EC_LEFTMARGIN,25 shl 16);
  inherited;
  SendMessage(Handle,WM_KEYDOWN,VK_END,0);
end;

procedure TEditContext.WMKillFocus(var Message: TWMSetFocus);
begin
  Visible := False;
  inherited;
end;




procedure TEditContext.MyChange(Sender: TObject);
var bk: TBookmark;
    sKey: String;
    bFound: Boolean;
begin
  if Not Assigned(FDataLink.DataSet) then
    Exit;
  sKey := AnsiUpperCase(Text);
  with FDataLink.DataSet do
  begin
    bk := GetBookMark;
    DisableControls;
    bFound := False;
    try
      if not Visible then
      begin
        Visible := True;
        First;
      end;
//      else
//        Next;

      if sKey='' then
      begin
        First;
        bFound:= True;
      end
      else
      while (not eof) and (not bFound) do
      begin
        bFound := pos(sKey,AnsiUpperCase(FieldByName(FKeyField).AsString))=1;
        if not bFound then
          Next;
      end;
    finally
      if not bFound then
        GoToBookMark(bk);
      FreeBookMark(bk);
      EnableControls;
    end;
  end;
end;

function TEditContext.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TEditContext.SetDataSource(ds: TDataSource);
begin
  FDataLink.DataSource:=ds;
end;

procedure TEditContext.MyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_ESCAPE then
  begin
   Visible := False;
   if Assigned(FActiveControl) then
     FActiveControl.SetFocus;
  end;
  inherited;
end;

end.

