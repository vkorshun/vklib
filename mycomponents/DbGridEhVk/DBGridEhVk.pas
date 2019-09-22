
unit DBGridEhVk;
{$R DBGridEhVk.res}
interface

uses
  SysUtils, Classes, Controls, GridsEh, DBGridEh, Dialogs,DbGridEhImpExp,
  windows,DbGridColumnsParamList, strUtils, XlsReport, fm_wait, Forms, DbgXlsExport ;

type

  TDBGridEhVk = class (TDBGridEh)
  private
    { Private declarations }
  protected
    { Protected declarations }
    FListDbGridColumnsParam:TDbGridColumnsParamList;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    class var OnAltP: TNotifyEvent;
    class var OnCreate: TNotifyEvent;
//    class var OnDefaultApplayUserOrder: TNotifyEvent;
//    class var OnApplayUserFilterG:TNotifyEvent;
    constructor Create(aOwner: TComponent);override;
    destructor Destroy;override;
//    procedure RefreshUserFliterImages;
    procedure ReportToExcel(asender:TObject);
    procedure ReportToCalc;
    procedure ReadDbGridColumnsSize( aList:TDbGridColumnsParamList = nil);// List:TListDbGridColumnsParams);
    procedure SetDbGridColumnsSize(aList: TDbGridColumnsParamList);
//    procedure DefaultApplayUserFilter;
    procedure Find(bContinue:Boolean);
    property   ListDbGridColumnsParam:TDbGridColumnsParamList read FListDbGridColumnsParam;
    procedure ScrollActiveToRow(Grid : TDBGridEh; ARow : Integer);

    //    procedure ClearUserFliterImages;
//    procedure ClearUserFilterParams;
//    procedure ClearUserOrderParams;
//    procedure ClearUserParams;

//    property MainSql:TStringList read FmainSql;
//    property OrderSql:TStringList read FOrderSql;
//    property ListUserFilterParams: TStringList read FListUserFilterParams;
//    property ListUserOrderParams: TStringList read FListUserOrderParams;
//    property OnUserFilterSetValue: TChangeValueUserFilterParams read FOnUserFilterSetValue write FOnUserFilterSetValue;
//    property OnUserFilterGetValue: TChangeValueUserFilterParams read FOnUserFilterGetValue write FOnUserFilterGetValue;
//    procedure SetColWidths(aList:TStringList);
  published
    { Published declarations }
//    property AfterApplayUserFilter:TNotifyEvent read FAfterApplayUserFilter write FAfterApplayUserFilter;
//    property DefineUserFilters: Boolean read FbDefineUserFilters write FbDefineUserFilters;
//    property OnApplayUserFilter: TNotifyEvent read FOnApplayUserFilter write FOnApplayUserFilter;
  end;
  var id_grid: Integer;
      sDirName: String;
procedure Register;

implementation
uses db,  graphics, listparams, Fm_Find;

procedure Register;
begin
  RegisterComponents('EhLib', [TDBGridEhVk]);
end;

{ TDBGridEhVk }

{procedure TDBGridEhVk.ClearUserFilterParams;
var p:TUserFilterParams;
begin
  while FListUserFilterParams.Count>0 do
  begin
    p := TUserFilterParams(FListUserFilterparams.Objects[0]);
    p.Free;
    FListUserFilterparams.Delete(0);
  end;
end;

procedure TDBGridEhVk.ClearUserFliterImages;
var i: Integer;
begin
  for I := 0 to Columns.Count - 1 do
  begin
    if FListUserFilterParams.IndexOf(Columns[i].FieldName)>-1 then
          Columns[i].Title.ImageIndex := 0;
  end;

end;

procedure TDBGridEhVk.ClearUserOrderParams;
var p:PInteger;
begin
  while FListUserOrderParams.Count>0 do
  begin
    p := PInteger(FListUserOrderParams.Objects[0]);
    Dispose(p);
    FListUserOrderParams.Delete(0);
  end;
  FOrderSql.Clear;
end;

procedure TDBGridEhVk.ClearUserParams;
begin
  ClearUserFilterParams;
  ClearUserOrderParams;
end;
 }
constructor TDBGridEhVk.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
//  ColumnDefValues.Title.Color := clSilver;
//  FixedColor := clSilver;
  FListDbGridColumnsParam := TDbGridColumnsParamList.Create;
  ColumnDefValues.Title.Alignment := taCenter;
  OptionsEh := OptionsEh+[dghRowHighlight] ;
//  OptionsEh := OptionsEh+[dghAutoSortMarking,dghMultiSortMarking] ;
  Flat := True;
  UseMultiTitle := True;
  if Assigned(OnCreate) then
    OnCreate(Self);

//  InplaceEditor.SetOnKeyPress(nil);

  //FListUserFilterParams := TStringList.Create;
  //FMainSql              := TStringList.Create;
  //FOrderSql             := TStringList.Create;
  //FListUserOrderParams  := TStringList.Create;
  //Bmp := TBitmap.Create;
  //FListDbgCP:= TListDbGridColumnsParams.Create;
  try
//    Bmp.LoadFromResourceName( HInstance, 'DBG_FILTER');
//    Bmp.TransparentColor := clSilver;
//    FDbGridEhFilterImageList := TImageList.CreateSize(Bmp.Width, Bmp.Height);
//    FDbGridEhFilterImageList.Masked := True;
//    FDbGridEhFilterImageList.AddMasked(Bmp,clSilver);
  finally
//    Bmp.Free;
  end;
end;



destructor TDBGridEhVk.Destroy;
begin
  FListDbGridColumnsParam.Free;
  Inherited;
end;

procedure TDBGridEhVk.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key=Ord('p')) or (Key=ORD('P')) then
  begin
    if (ssAlt in Shift) then
    begin
      if Assigned(OnAltP) then
        OnAltP(Self)
      else
//        SaveDBGridEhToExportFile(TDBGridEhExportAsXLS,self,sDirName+'dbgridrh_'+IntToStr(id_grid)+'.xls',True);
        reportToExcel(Self);
//      sFileName := ExtractFileDir(Application.Exename)
    end;
  end;
  if Assigned(DataSource)then
  begin
    if ((DataSource.State= dsEdit) or (DataSource.State= dsInsert)) then
    begin
      if (Key=VK_INSERT) then
        Exit;
      if (Key=VK_RETURN)  then
      begin
        if True then

        DataSource.DataSet.Post;
      end;
    end
    else
    begin
      if (Key=VK_RETURN) then
      begin
        if not DataSource.DataSet.FieldByName(SelectedField.FieldName).ReadOnly then
        begin
          DataSource.DataSet.Edit;
        end;
      end;
    end;

  end;

  inherited;

end;

procedure TDBGridEhVk.ReportToExcel(asender:TObject);
var FXls: TXlsReport;
    FmWait: TFmWait;
    {$ifdef ACTIVEX_FORM}
    oldhandle: THandle;
    {$endif}
     XExp: TDbgXlsExport;

  procedure CreateZag;
  begin
    FXls.ExcelWorkSheet.Cells.Item[1,1] := Caption;
  end;

begin


    {$ifdef ACTIVEX_FORM}
    oldhandle := Application.Handle;
    Application.Handle := 0;
    {$endif}
    XExp := TDbgXlsExport.Create(Self);
    FmWait := TFmWait.Create(self);
    FmWait.Caption := 'Ёкспорт в Excel';
    FmWait.sMessage := 'ќжидайте...';
    FmWait.Show;
    try
      XExp.ExportData(TDbGridEh(Self),0,3,0);
    finally
      FreeAndNil(XExp);
      FmWait.Free;
//      FXls.free;
    {$ifdef ACTIVEX_FORM}
      Application.Handle := oldhandle;
    {$endif}
    end;
{    Exit;


    FXls   := TXlsReport.Create(self);
    FmWait := TFmWait.Create(self);
    FmWait.Caption := 'Ёкспорт в Excel';
    FmWait.sMessage := 'ќжидайте...';
    FmWait.Show;
    try
      FXls.Connect;
      FXls.ExcelApplication.ScreenUpdating[LCID] := False;
      try
        FXls.ExportDs(TDbGridEh(aSender).DataSource.DataSet);
      finally
        FXls.ExcelApplication.ScreenUpdating[LCID] := True;
        FXls.ExcelApplication.Visible[LCID] := True;
        FXls.DisConnect;
      end; }
//    finally
//      FmWait.Free;
//      FXls.free;
    {$ifdef ACTIVEX_FORM}
//      Application.Handle := oldhandle;
    {$endif}
//      Close;
//    end;


end;


procedure TDBGridEhVk.Find(bContinue: Boolean);
var fm: TFmFind;
begin
  fm := TFmFind.GetFmFind;
  Fm.Find(bContinue,Self)
end;

procedure TDBGridEhVk.ReadDbGridColumnsSize(aList: TDbGridColumnsParamList);
var i,k: Integer;
    List: TDbGridColumnsParamList;
begin

  if not Assigned(DataSource) then
    Exit;
  if not Assigned(DataSource.DataSet) then
    Exit;
  if not DataSource.DataSet.Active then
    Exit;
  if Assigned(aList) then
  begin
    List := aList
  end
  else
  begin
    List := FListDbGridColumnsParam
{    if aDbGrid.DataSource.DataSet = DmDoc.pFIBDataSetDoc  then
      List := FListDbGridColumnsParams1

      List := FListDbGridColumnsParams2;}
  end;

  for I := 0 to Columns.Count - 1 do
  begin
    if not Assigned(Columns[i].Field) then
      Exit;
    k := List.IndexOf(Columns[i].Field.FieldName);
    if k=-1 then
    begin
      if not  List.bInit then
        List.Add(Columns[i].Field.FieldName,Columns[i].Field.Index,Columns[i].Field.DisplayWidth);
    end
    else
    begin
      List.Items[k].Id := i; //aDbGrid.Columns[i].Index;
      List.Items[k].Width := Columns[i].Field.DisplayWidth;
    end;
  end;
  List.bInit := true;
end;


procedure TDBGridEhVk.ReportToCalc;
//var
//Ds: TDataSet;
//    i: Integer;
//    vRow: word;
//    bk: TBookMark;
begin

{   if Assigned(DataSource) and Assigned(DataSource.DataSet) then
      ds := DataSource.DataSet
   else
     ds := nil;
   if not Assigned(ds) or not ds.Active then
     Exit;
   bk := Ds.GetBookmark;
   ds.DisableControls;
   try
   ds.First;
   oCalc.connect;
   oCalc.loadDocument(False,'');
   oCalc.getSheet(0);
   for i:=0 to Pred(Ds.FieldCount) do
   begin
     if Ds.Fields[i].Visible then
     begin
       oCalc.putTextToCell(i,6,Ds.Fields[i].DisplayLabel);
       oCalc.setActiveColumnWidth(Ds.Fields[i].DisplayWidth);
     end;
   end;
   vRow:= 7;
   while not Ds.Eof do
   begin
     for i:=0 to Pred(Ds.FieldCount) do
     begin
       if Ds.Fields[i].Visible then
       begin
         oCalc.putTextToCell(i,vRow,Ds.Fields[i].AsString);
         oCalc.drawBorders(0);
       end;
     end;
     Inc(vRow);
     Ds.Next;
   end;
   finally
     Ds.GotoBookmark(bk);
     Ds.FreeBookmark(bk);
     Ds.EnableControls;
   end;}
end;

{ RUserFilterParams }

procedure TDBGridEhVk.ScrollActiveToRow(Grid: TDBGridEh; ARow: Integer);
var FTitleOffset, SDistance : Integer;
     NewRect : TRect;
     RowHeight : Integer;
     NewRow : Integer;
begin
 with Grid do begin
   NewRow:= Row;
   FTitleOffset:= 0;
   if dgTitles in Options then inc(FTitleOffset);
   if ARow = NewRow then Exit;
   with DataLink, DataSet do
    try
      BeginUpdate;
      Scroll(NewRow - ARow);
      if (NewRow - ARow) < 0 then ActiveRecord:= 0
                             else ActiveRecord:= VisibleRowCount - 1;
      SDistance:= MoveBy(NewRow - ARow);
      NewRow:= NewRow - SDistance;
      MoveBy(ARow - ActiveRecord - FTitleOffset);
      RowHeight:= DefaultRowHeight;
      NewRect:= BoxRect(0, FTitleOffset, ColCount - 1, 1000);
      ScrollWindowEx(Handle, 0, - RowHeight * SDistance, @NewRect, @NewRect, 0, nil, SW_Invalidate);
      MoveColRow(Col, NewRow, False, False);
    finally
      EndUpdate;
    end;
 end;
end;

procedure TDbGridEhVk.SetDbGridColumnsSize( aList: TDbGridColumnsParamList);
var i: Integer;
    List: TDbGridColumnsParamList;
begin
  if not Assigned(aList) then
    List := FListDbGridColumnsParam
  else
    List := aList;
  if not List.bInit then
    Exit;
  if not Assigned(DataSource) then
    Exit;
  if not Assigned(DataSource.DataSet) then
    Exit;
  if not DataSource.DataSet.Active then
    Exit;

  for I := 0 to List.Count - 1 do
  begin
    if Assigned(DataSource.DataSet.FindField(List.Items[i].name)) then
    with DataSource.DataSet.FieldByName(List.Items[i].name) do
    begin
      Index := List.Items[i].id;
      DisplayWidth := List.Items[i].width;
    end;
  end;
end;



{ TDBGridEh }



initialization
  id_grid := 1;
end.
