unit xlsreport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActiveX, ExcelXP, OleServer, DB, Contnrs, DateVk, memtableeh;

const
  LCID = 1049;

type
  TAcells = array of integer;

type

  TXlsReportColumn = class(Tobject)
  private
  public
    fieldname: String;
    fieldtype: TFieldType;
    id: Int64;
    ListLabel: TStringList;
    bPrint: Boolean;
    Index: integer;
    constructor Create;
    destructor Destroy; override;
    procedure SetLabel(const aLabel: string);
  end;

  TListXlsColumns = class(Tobject)
  private
    FList: TList;
    FMaxRowCount: integer;
    function GetCount: integer;
    function GetItem(aIndex: integer): TXlsReportColumn;
    procedure SetItem(aIndex: integer; aObj: TXlsReportColumn);
    function GetCountToPrint: integer;
  public
    Constructor Create;
    Destructor Destroy; override;
    procedure Add;
    procedure Delete(aIndex: integer);
    procedure Clear;
    procedure ReadFromDataset(const aDataSet: TDataSet);
    property Items[aIndex: integer]: TXlsReportColumn read GetItem
      write SetItem; default;
    property Count: integer read GetCount;
    property CountToPrint: integer read GetCountToPrint;
    property MaxRowCount: integer read FMaxRowCount write FMaxRowCount;
    procedure Sort(pCompare: TListSortCompare);
  end;

  TXlsReport = class(TComponent)
  private
    bConnected: Boolean;
    FExcelApplication: TExcelApplication;
    FExcelWorkBook: TExcelWorkBook;
    FExcelWorkSheet: TExcelWorkSheet;
  public
    aColumns: TObjectList;
    procedure AddColumn;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    function GetRcName(r, c: integer): String;
    function GetColumnNumber(const aName: String): integer;
    function FindIn(aAr: TIntList; aKey: integer): integer;
    procedure MergeZag(r1, c1, r2, c2: integer);
    procedure MergeCells(r1, c1, r2, c2: integer);
    procedure ExportDs(aDs: TDataSet);
    procedure FreezeColumns(aIndex: integer);
    procedure FreezeRows(aIndex: integer);

    property ExcelApplication: TExcelApplication read FExcelApplication;
    property ExcelWorkBook: TExcelWorkBook read FExcelWorkBook;
    property ExcelWorkSheet: TExcelWorkSheet read FExcelWorkSheet;

  end;

implementation

{ TXlsReport }

procedure TXlsReport.AddColumn;
var
  oColumn: TXlsReportColumn;
begin
  oColumn := TXlsReportColumn.Create;
  aColumns.Add(oColumn);
end;

procedure TXlsReport.Connect;
begin
  FExcelApplication.Connect;
  FExcelApplication.AutoQuit := False;
  // FExcelApplication.Interactive[lcid] := False;
  FExcelApplication.Workbooks.Add(EmptyParam, LCID);
  FExcelWorkBook.ConnectTo(FExcelApplication.ActiveWorkbook);
  FExcelWorkSheet.ConnectTo(FExcelWorkBook.Worksheets[1] as _WorkSheet);
  FExcelWorkSheet.PageSetUp.Orientation := xlLandscape;
  // XL.ActiveSheet.PageSetup.Orientation := xlLandscape;

  bConnected := true;
end;

constructor TXlsReport.Create(aOwner: TComponent);
begin
  Inherited Create(aOwner);
  OleInitialize(nil);
  // Owner := aOwner;
  FExcelApplication := TExcelApplication.Create(nil);
  FExcelWorkBook := TExcelWorkBook.Create(nil);
  FExcelWorkSheet := TExcelWorkSheet.Create(nil);
  FExcelApplication.AutoConnect := False;
  FExcelApplication.ConnectKind := ckRunningOrNew;
  aColumns := TObjectList.Create;
  aColumns.OwnsObjects := true;
  bConnected := False;
end;

destructor TXlsReport.Destroy;
begin
  if bConnected then
    Disconnect;
  aColumns.Free;
  OleUninitialize;
  FreeAndNil(FExcelWorkBook);
  FreeAndNil(FExcelWorkSheet);
  FreeAndNil(FExcelApplication);
  inherited;
end;

procedure TXlsReport.Disconnect;
begin
  FExcelApplication.UserControl := true;
  { if FExcelApplication.Visible then
    FExcelApplication.Quit; }

  // FExcelApplication.Interactive[lcid] := True;
  FExcelWorkSheet.Disconnect;
  // FExcelWorkBook.Close(0);
  // FExcelApplication.DisplayAlerts[LCID] := True;
  // FExcelApplication.Quit;
  FExcelWorkBook.Disconnect;
  FExcelApplication.Disconnect;
  bConnected := False;
end;

procedure TXlsReport.ExportDs(aDs: TDataSet);
var
  bTree: Boolean;
  i, j: integer;
  // List: TList;
  ListColumns: TListXlsColumns;
  nCount_Columns: integer;
  nCount_range: integer;
  vRange: Variant;
  bk: TBookMark;
  r, c: integer;
  sRc1, sRc2: String;
  XLS: Variant;
  s: String;
  // nLen, k, kold: Integer;
  List: TIntList;
  ListMemo: TIntList;
  FirstKodG: Variant;
  curkey: Variant;
  pPoint: ^TPoint;
  ListPoint: TList;

  function CompareF(aItem1, aItem2: Pointer): integer;
  begin
    Result := CompareStr(IntToStr(TXlsReportColumn(aItem1).Index),
      IntToStr(TXlsReportColumn(aItem2).Index));
  end;

  var bDisplayText : Boolean;
      fField: TField;
      cFormat: String;
begin
  r := 0;
  if not aDs.active then
    Exit;

  ListColumns := TListXlsColumns.Create;
  bk := aDs.GetBookmark;
  ListColumns.ReadFromDataset(aDs);
  aDs.DisableControls;
  List := TIntList.Create;
  ListMemo := TIntList.Create;
  bTree := False;
  if aDs is TMemTableEh then
  begin
    with TMemTableEh(aDs) do
    begin
      bTree := TreeList.Active;
      if bTree then
      begin
        New(pPoint);
        pPoint.X := 0;
        TreeList.FullExpand;
      end;
    end;
  end;
  ListPoint := TList.Create;
  with aDs do
  begin
    try
      if not(aDs is TMemTableEh) then
        ListColumns.Sort(@CompareF);

      nCount_Columns := ListColumns.Count;
      // ShowMessage(IntToStr(ListColumns3.MaxRowCount));
      Last;
      nCount_range := RecordCount + ListColumns.MaxRowCount;
      vRange := VarArrayCreate([1, nCount_range, 1, nCount_Columns],
        varVariant);

      // Create Zag
      // r :=  1;
      c := 1;
      for i := 0 to ListColumns.Count - 1 do
      begin
        r := 1;
        for j := 0 to ListColumns[i].ListLabel.Count - 1 do
        begin
          vRange[r, c] := ListColumns[i].ListLabel[j];
          Inc(r);
        end;
        j := ListColumns[i].ListLabel.Count;
        while j < ListColumns.MaxRowCount - 1 do
        begin
          vRange[r, c] := '';
          Inc(r);
          Inc(j);
        end;
        Inc(c);
      end;

      // —одержимое
      r := ListColumns.MaxRowCount + 1;
      First;

      // Tree First
      if bTree then
        with TMemTableEh(aDs) do
        begin
          FirstKodG := FieldByName(TreeList.RefParentFieldName).Value;
          curkey := FieldByName(TreeList.KeyFieldName).Value;
        end;
      while not Eof do
      begin
        c := 1;
        for i := 0 to ListColumns.Count - 1 do
        begin
          fField :=  FieldByName(ListColumns[i].fieldname);
          if fField.DataType = ftDate then
            vRange[r, c] := fField.AsString
          else if (fField.DataType = ftMemo) or(fField.DataType = ftString) then
          begin
            bDisplayText := true;
            s := fField.AsString;
            if Assigned(fField.OnGetText) then
              fField.OnGetText(fField,s,bDisplayText);
            s := StringReplace(Trim(s), #10, ' ', [rfReplaceAll]);
            s := StringReplace(Trim(s), #13, '', [rfReplaceAll]);
            vRange[r, c] := s; // vRange[r,c]+ Trim(Copy(s,kold+1,k-kold));
            if ListMemo.IndexOf(c) = -1 then
              ListMemo.Add(c);

          end
          else
            if (fField.DataType = ftFloat) or (fField.DataType=ftFMTBcd) then
            begin
              vRange[r, c] := fField.AsFloat;
            end
          else
            vRange[r, c] := fField.AsString;
          Inc(c);
        end;


        if bTree then
        begin
          with TMemTableEh(aDs) do
          begin
            if FieldByName(TreeList.RefParentFieldName).Value = FirstKodG then
            begin
              curkey := FieldByName(TreeList.KeyFieldName).Value;
              // --- New Group
              if Assigned(pPoint) and (pPoint.X > 0) then
              begin
                pPoint.y := r - 1;
                ListPoint.Add(Pointer(pPoint));
                New(pPoint);
                pPoint.X := 0;
              end;
            end
            else
            begin
              if FieldByName(TreeList.KeyFieldName).Value <> curkey then
              begin
                if FieldByName(TreeList.RefParentFieldName).Value = curkey then
                begin
                  if pPoint.X = 0 then
                    pPoint.X := r;
                end
                else
                begin
                  // --- New SubGroup
                  if pPoint.X > 0 then
                  begin
                    pPoint.y := r - 1;
                    ListPoint.Add(Pointer(pPoint));
                    New(pPoint);
                    pPoint.X := r;
                  end;
                end;
              end;
            end;
          end;
        end;
        Next;
        Inc(r);
      end;

        // Write Range
        try
          r := 3;
          sRc1 := GetRcName(r, 1);
          sRc2 := GetRcName(r + nCount_range - 1, ListColumns.Count);
          with ExcelWorkSheet.Range[sRc1, sRc2] do
          begin
            Value2 := vRange;
            Borders.LineStyle := xlContinuous;
            Borders.Item[xlEdgeLeft].Weight := xlThin;
            Borders.Item[xlEdgeRight].Weight := xlThin;
            Borders.Item[xlEdgeTop].Weight := xlThin;
            Borders.Item[xlEdgeBottom].Weight := xlThin;
            EntireColumn.AutoFit;
            EntireColumn.VerticalAlignment := xlTop;
            // EntireColumn.Interior ;
          end;
          for i := 0 to ListMemo.Count - 1 do
          begin
            c := ListMemo[i];
            r := 3;
            sRc1 := GetRcName(r, c);
            sRc2 := GetRcName(r + nCount_range - 1, c);
            with ExcelWorkSheet.Range[sRc1, sRc2] do
            begin
              // Width := 80;
              Cells.WrapText := true;
              if Columns.ColumnWidth > 60 then
                Columns.ColumnWidth := 60;
            end;

          end;

          sRc1 := GetRcName(r + ListColumns.MaxRowCount - 1, 1);
          sRc2 := GetRcName(r + ListColumns.MaxRowCount - 1, ListColumns.Count);
          XLS := FExcelWorkSheet.DefaultInterface;
          XLS.Range[sRc1, sRc2].AutoFilter;
          sRc1 := GetRcName(r, 1);
          XLS.Range[sRc1, sRc2].Interior.Pattern := xlSolid;
          XLS.Range[sRc1, sRc2].Interior.PatternColorIndex := xlAutomatic;
          XLS.Range[sRc1, sRc2].Interior.Color := 16761992;



          // Format
          for I := 0 to ListColumns.Count-1 do
          begin
            cFormat := '';
            if ((ListColumns[i].fieldtype = ftFloat) or (ListColumns[i].fieldtype = ftFmtBCD)) then
            begin
              cFormat :=    TNumericField(aDs.FieldByName(ListColumns[i].fieldname)).DisplayFormat;
              if pos('.000',cFormat)>0 then
                cFormat := '# ##0,000_ ;[ расный]-# ##0,000\ ;;'
              else
                if pos('.00',cFormat)>0 then
                  cFormat := '# ##0,00_ ;[ расный]-# ##0,00'// \ ;;     <- закомментировано не показывать нули
                  //cFormat := '#,##0.00_ ;[Red]-#,##0.00'
              else
                cFormat := '';
            end;

            if ((ListColumns[i].fieldtype = ftString) or (ListColumns[i].fieldtype = ftMemo)) then
              cFormat := '@';
              if length(cFormat)>0 then
              begin
                r := 3+ListColumns.MaxRowCount;
                sRc1 := GetRcName(r,i+1);
                sRc2 := GetRcName(3+nCount_range - 1,i+1);
                with ExcelWorkSheet.Range[sRc1,sRc2] do
                begin
                  NumberFormat := cFormat;
                  EntireColumn.AutoFit;
                end;
              end;

          end;

          // 16770250;    15263976
          // XLS.Range[sRc1,sRc2].Interior.TintAndShade := 0.799981688894314;
          // XLS.Range[sRc1,sRc2].Interior.PatternTintAndShade := 0;
          // ќбъединение €чеек
          // ListXlsRange3.Add;
          MergeZag(r, 1, r + ListColumns.MaxRowCount - 1, ListColumns.Count);
        finally
        end;
    finally
      if bTree then
      begin
          //--- Write Groups
          for I := 0 to ListPoint.Count-1 do
          begin
            pPoint := ListPoint[i];
            sRc1 := GetRcName(r + pPoint.X - 1, 1);
            sRc2 := GetRcName(r + pPoint.Y - 1, ListColumns.Count);
            XLS.Range[sRc1, sRc2].rows.group;
            //XLS.Range[sRc1, sRc2].rows.Hidden := True;
          end;
        with TMemTableEh(aDs) do
        begin
          GotoBookmark(bk);
          TreeList.FullCollapse;
          //--- —ворачиваем группы ----
          XLS.Outline.ShowLevels(1);
        end;
      end
      else
        GotoBookmark(bk);
      ListColumns.Free;
      aDs.EnableControls;
      aDs.FreeBookMark(bk);
      List.Free;
      ListMemo.Free;
      for i := 0 to ListPoint.Count - 1 do
        Dispose(Pointer(ListPoint[i]));
      FreeAndNil(ListPoint)
    end;
  end;
end;

function TXlsReport.FindIn(aAr: TIntList; aKey: integer): integer;
begin
  Result := aAr.IndexOf(aKey);
end;

procedure TXlsReport.FreezeColumns(aIndex: integer);
begin
  FExcelApplication.ActiveWindow.SplitColumn := aIndex;
  FExcelApplication.ActiveWindow.FreezePanes := true;
end;

procedure TXlsReport.FreezeRows(aIndex: integer);
begin
  FExcelApplication.ActiveWindow.SplitRow := aIndex;
  FExcelApplication.ActiveWindow.FreezePanes := true;
end;

function TXlsReport.GetColumnNumber(const aName: String): integer;
const
  Zag: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  LenZag = 26;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to Length(aName) do
  begin
    if i < Length(aName) then
      Result := Result + LenZag * Pos(aName[i], Zag)
    else
      Result := Result + Pos(aName[i], Zag);
  end;
end;

function TXlsReport.GetRcName(r, c: integer): String;
const
  Zag: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  LenZag = 26;
var
  k: integer;

begin
  { if c<=LenZag then
    begin
    Result := Zag[c]+IntToStr(r);
    Exit;
    end; }
  k := (c - 1) div LenZag;
  if k > 0 then
    Result := Zag[k]
  else
    Result := '';
  k := c - LenZag * k;
  Result := Result + Zag[k] + IntToStr(r);

end;

procedure TXlsReport.MergeCells(r1, c1, r2, c2: integer);
var
  sRc1, sRc2: String;
begin
  sRc1 := GetRcName(r1, c1);
  sRc2 := GetRcName(r2, c2);
  with ExcelWorkSheet.Range[sRc1, sRc2] do
  begin
    if r1 = r2 then
    begin
      Merge(1);
      HorizontalAlignment := xlCenter;
    end
    else if c1 = c2 then
    begin
      Merge(0);
      // HorizontalAlignment := xlGeneral;
      VerticalAlignment := xlCenter;

    end
    else
      Raise (Exception.Create(' Invalid merge range!'));

  end;

end;

procedure TXlsReport.MergeZag(r1, c1, r2, c2: integer);
var
  r, c: integer;
  i: integer;
  rold, cold: integer;
  // sRc1, sRc2: String;
  rmerge, cmerge: integer;
  aMerge: TList;
  rcurr: integer;
  // nLen: Integer;
  bNext: Boolean;
  aList: TIntList;
begin
  r := r1;
  rold := r1 - 1;
  // SetLength(aMerge,r2-r1+1);

  if r1 = r2 then
    Exit;

  aMerge := TList.Create;
  for i := r1 to r2 do
  begin
    aList := TIntList.Create;
    aMerge.Add(aList)
  end;

  try
    while r <= r2 do
    begin
      Inc(rold);
      cold := c1;
      c := c1;
      rmerge := 0;
      cmerge := 0;
      while c <= c2 do
      begin
        bNext := False;
        if FindIn(aMerge[r - r1], c) = -1 then
        begin
          // Down
          rcurr := r + 1;
          if (ExcelWorkSheet.Cells.Item[r, c].Text = ExcelWorkSheet.Cells.Item
            [rold, cold].Text) and (Length(ExcelWorkSheet.Cells.Item[r, c].Text)
            > 0) and (Length(ExcelWorkSheet.Cells.Item[r, c].Text) > 0) then
            while rcurr <= r2 do
            begin
              if Length(ExcelWorkSheet.Cells.Item[rcurr, c].Text) = 0 then
              begin
                rmerge := rcurr;
                if cmerge = 0 then
                  cmerge := c;
                TIntList(aMerge[rcurr - r1]).Add(c);
              end
              else
                Break;
              Inc(rcurr);
            end;

          Inc(c);
          // LEFT
          if FindIn(aMerge[r - r1], c) = -1 then
          begin
            if rmerge = 0 then
              rmerge := r;
            if (ExcelWorkSheet.Cells.Item[r, c].Text = ExcelWorkSheet.Cells.Item
              [rold, cold].Text) and
              (Length(ExcelWorkSheet.Cells.Item[r, c].Text) > 0) and
              (Length(ExcelWorkSheet.Cells.Item[r, c].Text) > 0) then
            begin
              ExcelWorkSheet.Cells.Item[r, c].Value2 := '';
              cmerge := c;
            end
            else
              bNext := true
          end
          else
            bNext := true;
        end
        else
        begin
          bNext := true;
          Inc(c);
        end;

        if bNext then
        begin
          if (rmerge > rold) or (cmerge > cold) then
          begin
            MergeCells(rold, cold, rmerge, cmerge);
          end;
          rold := r;
          cold := c;
          rmerge := 0;
          cmerge := 0;
          // end;
        end;

      end;
      Inc(r);
    end;

  finally
    for i := 0 to aMerge.Count - 1 do
      TIntList(aMerge[i]).Free;
    aMerge.Free;
  end;

end;

{ TXlsReportColumn }

constructor TXlsReportColumn.Create;
begin
  ListLabel := TStringList.Create;
end;

destructor TXlsReportColumn.Destroy;
begin
  ListLabel.Free;
  Inherited;
end;

procedure TXlsReportColumn.SetLabel(const aLabel: string);
var
  i: integer;
  nCount: integer;
  nFirst: integer;
begin
  i := 1;
  nFirst := 1;
  nCount := Length(aLabel);
  while i <= nCount do
  begin
    if aLabel[i] = '|' then
    begin
      ListLabel.Add(Copy(aLabel, nFirst, i - nFirst));
      nFirst := i + 1;
    end;
    Inc(i);
  end;
  if i > nFirst then
    ListLabel.Add(Copy(aLabel, nFirst, i - nFirst));

end;

{ TListXlsColumns }

procedure TListXlsColumns.Add;
var
  oColumn: TXlsReportColumn;
begin
  oColumn := TXlsReportColumn.Create;
  FList.Add(oColumn);
end;

procedure TListXlsColumns.Clear;
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do
    TXlsReportColumn(FList[i]).Free;
  FList.Clear;
end;

constructor TListXlsColumns.Create;
begin
  inherited;
  FList := TList.Create;
end;

procedure TListXlsColumns.Delete(aIndex: integer);
var
  oColumn: TXlsReportColumn;
begin
  oColumn := Items[aIndex];
  oColumn.Free;
  FList.Delete(aIndex);
end;

destructor TListXlsColumns.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TListXlsColumns.GetCount: integer;
begin
  Result := FList.Count;
end;

function TListXlsColumns.GetCountToPrint: integer;
var
  obj: Pointer;
begin
  Result := 0;
  for obj in FList do
  begin
    if TXlsReportColumn(obj).bPrint then
      Inc(Result)
  end;

end;

function TListXlsColumns.GetItem(aIndex: integer): TXlsReportColumn;
begin
  Result := TXlsReportColumn(FList[aIndex]);
end;

procedure TListXlsColumns.ReadFromDataset(const aDataSet: TDataSet);
var
  i: integer;
  oColumn: TXlsReportColumn;
begin
  Clear;
  FMaxRowCount := 0;
  with aDataSet do
    for i := 0 to FieldCount - 1 do
    begin
      if Fields[i].Visible then
      begin
        Add;
        oColumn := Items[GetCount - 1];
        with oColumn do
        begin
          fieldname := Fields[i].fieldname;
          Index := FieldByName(Fields[i].fieldname).Index;
          fieldtype := FieldByName(Fields[i].fieldname).DataType;
          SetLabel(Fields[i].DisplayLabel);
          if ListLabel.Count > FMaxRowCount then
            FMaxRowCount := ListLabel.Count
        end;
      end;
    end;
end;

procedure TListXlsColumns.SetItem(aIndex: integer; aObj: TXlsReportColumn);
var
  oColumn: TXlsReportColumn;
begin
  oColumn := GetItem(aIndex);
  oColumn.Free;
  FList[aIndex] := aObj;
end;

procedure TListXlsColumns.Sort(pCompare: TListSortCompare);
begin
  FList.Sort(pCompare);
end;

end.
