unit fm_find;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBGridEh,  Mask, DBCtrlsEh,db;

type
//  TFindEvent = procedure (Sender:TObject; bContinue:Boolean) of object;

  TFmFind = class(TForm)
    CbText: TComboBox;
    Label1: TLabel;
    BtnCancel: TButton;
    BtnFind: TButton;
    cbCharCase: TDBCheckBoxEh;
    procedure FormCreate(Sender: TObject);
    procedure BtnFindClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    BackFind: Boolean;
    FGrid: TCustomDBGridEh;
    FOnFind: TNotifyEvent;
//    FFindColumnsList: TColumnsEhList;
    FCurInListColIndex: Integer;
    FIsFirstTry: Boolean ;
    function ColText(Col: TColumnEh): String;
    procedure SetCenter;
  public
    { Public declarations }
//    property Grid:TCustomDbGridEh read FGrid;
//    property OnFind: TNotifyEvent read FOnFind write FOnFind;
    property IsFirstTry: Boolean read FIsFirstTry write FIsFirstTry;
    function InternalGridFind(aGrid:TCustomDbGridEh):Boolean;
    function InternalDataSetFind(aDataSet:TDataSet;aGrid:TCustomDbGridEh):Boolean;
    procedure Find(bContinue:Boolean; AGrid:TCustomDbGridEh);overload;
    procedure Find(bContinue:Boolean; aOnFind:TNotifyEvent);overload;
    class function GetFmFind:TFmFind;
  end;

var
  FmFind: TFmFind;

implementation

{$R *.dfm}
// uses EhLibConsts;

function AnsiContainsText(const AText, ASubText: string): Boolean;
begin
  Result := AnsiPos(AnsiUppercase(ASubText), AnsiUppercase(AText)) > 0;
end;

function AnsiContainsStr(const AText, ASubText: string): Boolean;
begin
  Result := AnsiPos(ASubText, AText) > 0;
end;

procedure TFmFind.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFmFind.BtnFindClick(Sender: TObject);
var
  RecordFounded: Boolean;
begin
  if GetKeyState(VK_CONTROL) < 0
    then BackFind := True
    else BackFind := False;
  if cbText.Items.IndexOf(cbText.Text) = -1 then
    cbText.Items.Add(cbText.Text);

  //Если определена OnFind то поиск переопределен
  if Assigned(FOnFind) then
  begin
    FOnFind( self );
    Exit;
  end;

  RecordFounded := InternalGridFind(FGrid);

  if not RecordFounded then
     ShowMessage(Format('Строка %s не найдена', [cbText.Text]));
end;


function TFmFind.ColText(Col: TColumnEh): String;
var i: Integer;
begin
// First
  if FGrid.Visible then
    Result := Col.DisplayText
  else
  begin
    for I := 0 to fGrid.DataSource.DataSet.FieldCount - 1 do
    if FGrid.DataSource.DataSet.Fields[i].Index=FCurInListColIndex then
    begin
      Result := FGrid.dataSource.DataSet.FieldByName(FGrid.dataSource.DataSet.Fields[i].FieldName).AsString;
    end;
  end;


end;

procedure TFmFind.Find(bContinue: Boolean; AGrid:TCustomDbGridEh);
begin
  FGrid := AGrid;
  FIsFirstTry := not bContinue;
  FOnFind := nil;
  ShowModal;
end;

procedure TFmFind.Find(bContinue: Boolean; aOnFind: TNotifyEvent);
begin
  FGrid := nil;
  FIsFirstTry := not bContinue;
  FOnFind := aOnFind;
  ShowModal
end;

procedure TFmFind.FormCreate(Sender: TObject);
begin
  Caption := 'Контекстный поиск';
  Label1.Caption := 'Строка поиска';
  BtnCancel.Caption := 'Отмена';
  BtnFind.Caption   := 'Поиск';
//  Label3.Caption    := 'Вид поиска';
  cbCharCase.Caption := 'C учетом регистра';
  CbText.Text := '';
end;

procedure TFmFind.FormShow(Sender: TObject);
begin
  SetCenter;
  if not IsFirstTry then
  begin
    PostMessage(Handle,WM_COMMAND,0,BtnFind.Handle);
  end;
end;


class function TFmFind.GetFmFind: TFmFind;
begin
  if not Assigned(FmFind) then
    FmFind := TFmFind.Create(Application);
  Result := FmFind;
end;

function TFmFind.InternalDataSetFind(aDataSet: TDataSet;aGrid:TCustomDbGridEh): Boolean;
var
  DataText: String;
  i: Integer;
  bk: TBookMark;
  FldList: TStringList;

  function CheckEofBof: Boolean;
  begin
    if BackFind
      then Result := aDataSet.Bof
      else Result := aDataSet.Eof;
  end;

  procedure ToNextRec;
  begin
    if BackFind then
    begin
      aDataSet.Prior;
    end else
    begin
        aDataSet.Next;
    end;
  end;
begin

  Result := False;
  if  Assigned(aDataSet)
    and aDataSet.Active
  then
  begin
//    if (FFindColumnsList.Count = 0) then Exit;
    with aDataSet do
    begin
      DisableControls;
      bk := GetBookMark;
      FldList := TStringList.Create;
      for I := 0 to FieldCount - 1 do
      begin
        if Fields[i].Visible then
          FldList.Add(Fields[i].FieldName);
      end;
      try
        if IsFirstTry then
          aDataSet.First;
        if not IsFirstTry then
          ToNextRec;
        while not CheckEofBof do
        begin
          for i := 0 to FldList.Count - 1 do
          begin
            FCurInListColIndex := i;
            DataText := aDataSet.FieldByName(FldList[FCurInListColIndex]).AsString;
            //CharCase
            if cbCharCase.Checked then
            begin
              //From any part of field
              if  ( AnsiContainsStr(DataText, cbText.Text) )  then
              begin
                Result := True;
                FIsFirstTry := False;
                Break;
              end
            end else
            //From any part of field
            if (  (
                AnsiContainsText(DataText, cbText.Text) )
               )
            //Whole field
            //From beging of field
            then
            begin
              Result := True;
              if Assigned(aGrid) then
               aGrid.SelectedField := aDataSet.FieldByName(FldList[FCurInListColIndex]);
              FIsFirstTry := False;
              Break;
            end;
          end;
          if not Result then
            ToNextRec
          else
            Break;
        end;
        if not Result then aDataSet.GotoBookmark(bk);
      finally
        aDataSet.EnableControls;
        aDataSet.FreeBookmark(bk);
        FldList.Free;
      end;
    end;
  end;
end;

function TFmFind.InternalGridFind(aGrid: TCustomDbGridEh):Boolean;
var
  oldGrid: TCustomDbGridEh;
  DataText: String;
  i: Integer;

  function CheckEofBof: Boolean;
  begin
    if BackFind
      then Result := FGrid.DataSource.DataSet.Bof
      else Result := FGrid.DataSource.DataSet.Eof;
  end;

  procedure ToNextRec;
  begin
    if BackFind then
    begin
      FGrid.DataSource.DataSet.Prior;
    end else
    begin
        FGrid.DataSource.DataSet.Next;
    end;
  end;
begin

  oldGrid := FGrid;
  FGrid := aGrid;
  Result := False;
  if Assigned(FGrid) and Assigned(FGrid.DataSource) and Assigned(FGrid.DataSource.DataSet)
    and FGrid.DataSource.DataSet.Active
  then
  begin
//    if (FFindColumnsList.Count = 0) then Exit;
    with FGrid do
    begin
      FGrid.DataSource.DataSet.DisableControls;
      SaveBookmark;
      try
        if IsFirstTry then
          FGrid.DataSource.DataSet.First;
        if not IsFirstTry then
          ToNextRec;
        while not CheckEofBof do
        begin
          for i := 0 to FGrid.Columns.Count - 1 do
          begin
            FCurInListColIndex := i;
            DataText := ColText(FGrid.Columns[FCurInListColIndex]);
            //CharCase
            if cbCharCase.Checked then
            begin
              //From any part of field
              if  ( AnsiContainsStr(DataText, cbText.Text) )  then
              begin
                Result := True;
                FIsFirstTry := False;
                Break;
              end
            end else
            //From any part of field
            if (  (
                AnsiContainsText(DataText, cbText.Text) )
               )
            //Whole field
            //From beging of field
            then
            begin
              Result := True;
              FGrid.SelectedIndex := FGrid.Columns[FCurInListColIndex].Index;
              FIsFirstTry := False;
              Break;
            end;
          end;
          if not Result then
            ToNextRec
          else
            Break;
        end;
        if not Result then RestoreBookmark;
      finally
        FGrid.DataSource.DataSet.EnableControls;
      end;
    end;
  end;
  FGrid := oldGrid;
end;

procedure TFmFind.SetCenter;
var Point:TPoint;
begin
  if not Assigned(FGrid) then
    Exit;
//  Position := poDesigned;
  Point.X := FGrid.Left;
  Point.Y := FGrid.Top;
  Point.X := Point.X+ (FGrid.Width - Width ) div  2;
  Point.Y := Point.Y + (FGrid.Height -Height) div 2;
  Point := FGrid.Parent.ClientToscreen(Point);
  if Point.X<0 then Point.X := 0;
  if Point.Y<0 then Point.Y := 0;
  Left := Point.X;
  Top  := Point.Y;
end;

initialization
  FmFind := nil;
finalization
  {if Assigned(FmFind) then
    FmFind.Free;}
end.
