unit DbgXlsExport;

interface

uses
  SysUtils, Classes, Controls, GridsEh, DBGridEh, Dialogs,DbGridEhImpExp, DateVk,
  windows,DbGridColumnsParamList, strUtils, XLSExportComp, fm_wait,Graphics, Forms,
   XLSBase, XLSFile, XLSWorkbook, XLSFormat, XLSRects, DB ;

Type

  TDbgXlsExport = class(TComponent)
  private
    FXLSExportFile: TXLSExportFile;
    FFileName: String;
    FDbGrid: TDbGridEh;
    FormatKolIndex: Integer;
    procedure InternalExportData(aSheetIndex: Integer; aRow, aCol:Integer);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExportData(aDbg: TDbGridEh; aSheetIndex: Integer; aRow, aCol:Integer );

    property FileName: String Read FFileName write FFileName;

  end;


implementation

uses ShellAPI;

{ Procedure uses OS shell to open and view XLS file }
procedure OpenFileInOSShell(const AFile: string);
begin
  ShellExecute(0, 'open', PChar(AFile), nil, nil, SW_SHOW);
end;

{ TDbgXlsExport }

constructor TDbgXlsExport.Create(aOwner: TComponent);
begin
  Inherited ;
  FXLSExportFile:= TXLSExportFile.Create(Self);
  FXLSExportFile.Workbook.Clear;
  FormatKolIndex:= FXLSExportFile.Workbook.FormatStrings.AddFormat('#,##0.000_ ;[Red]-#,##0.000 ')
end;

destructor TDbgXlsExport.Destroy;
begin
  Inherited;
end;

procedure TDbgXlsExport.ExportData(aDbg: TDbGridEh; aSheetIndex: Integer; aRow, aCol:Integer);
var
  sDir: String;
begin
  FDbGrid := aDbg;
  sDir := ExtractFileDir(Application.ExeName);
  FFileName := NameLock(sDir,'xls');
  while FXLSExportFile.Workbook.Sheets.Count<(aSheetIndex+1) do
     FXLSExportFile.Workbook.Sheets.Add('Лист'+IntTostr(aSheetIndex+1));
//  FXLSExportFile.Workbook.Sheets[aShhetIndex].Cells.ClearCellsRange(0,65000,);

//  FXLSExportDBGrid.XLSExportFile:= XLSExportFile1;
  InternalExportData(0, 3, 0);
  FXLSExportFile.SaveToFile(FFileName);
  OpenFileInOSShell(FFileName);
end;

procedure TDbgXlsExport.InternalExportData(aSheetIndex, aRow, aCol: Integer);
var
  S: TSheet;
  R, C, I: integer;
  CalcType: TTotalCalcType;
  CalcRange: AnsiString;
  cFormat: String;
begin
  { do nothing if not binded to TXLSExportFile }
  if not Assigned(FXLSExportFile) then
    exit;

  S:= FXLSExportFile.Workbook.Sheets[ASheetIndex];
  with S do
  begin
    {save title}
    C:= ACol;
    R:= ARow;
//    if not (eoptNoColumnsTitles in FOptions) then
    begin
      for I:= 0 to FDBGrid.Columns.Count-1 do
      begin
        if FDBGrid.Columns[I].Field.Visible then
//{$IFNDEF XLF_D3}
//                or ((eoptVisibleColumnsOnly in FOptions) and (not FDBGrid.Columns[I].Visible))
//{$ENDIF}
//               ) then
        begin
          Cells[R, C].Value:= FDBGrid.Columns[I].Title.Caption;
          Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(
            FDBGrid.Columns[I].Title.Alignment);
          Cells[R, C].FontName:= FDBGrid.Columns[I].Title.Font.Name;
          Cells[R, C].FontBold:= True; //(fsBold in FDBGrid.Columns[I].Title.Font.Style);
          Cells[R, C].FontItalic:= (fsItalic in FDBGrid.Columns[I].Title.Font.Style);
          Cells[R, C].FontUnderline:= (fsUnderline in FDBGrid.Columns[I].Title.Font.Style);
          Cells[R, C].FontStrikeOut:= (fsStrikeOut in FDBGrid.Columns[I].Title.Font.Style);

          Cells[R, C].FontHeight:= FDBGrid.Columns[I].Title.Font.Size;
          if FDBGrid.Columns[I].Title.Font.Color <> clBlack then
            Cells[R, C].FontColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Title.Font.Color);
          if (FDBGrid.Columns[I].Title.Color <> clWindow) and
             (FDBGrid.Columns[I].Title.Color <> clBtnFace) then
          begin
            Cells[R, C].FillPattern:= xlPatternSolid;
            Cells[R, C].FillPatternBGColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Title.Color);
          end;
          Cells[R, C].BorderStyle[xlBorderAll] := bsThin;
          Cells[R, C].BorderColorIndex[xlBorderAll] := xlColorBlack;
          Cells[R, C].FillPattern:= xlPatternSolid;
          Cells[R, C].FillPatternBGColorIndex := 33;//xlColorBlue;
          Columns[C].Width:= PixToXLSWidth(FDBGrid.Columns[I].Width);
          {if Assigned(FOnSaveTitle) then
            FOnSaveTitle(I, Cells[R, C]);
           }
          Inc(C);
        end;
      end;
    end;

    {save data}
    FDBGrid.DataSource.DataSet.DisableControls;
    try
 //     if not (eoptNoColumnsTitles in FOptions) then
      R:= ARow + 1;
      FDBGrid.DataSource.DataSet.First;
      while not FDBGrid.DataSource.DataSet.Eof do
      begin
        C:= ACol;
        for I:= 0 to FDBGrid.Columns.Count-1 do
        begin
          if FDBGrid.Columns[I].Field.Visible then
          begin
            if not FDBGrid.Columns[I].Field.IsNull then

              if FDBGrid.Columns[I].Field.DataType = ftTimeStamp then
                Cells[R, C].Value:= FDBGrid.Columns[I].Field.AsDateTime
              else
                if (FDBGrid.Columns[I].Field.DataType = ftFMTBcd) or
                  (FDBGrid.Columns[I].Field.DataType = ftFloat) then
                begin
                  Cells[R, C].Value:= FDBGrid.Columns[I].Field.AsFloat;
                  cFormat :=    TNumericField(FDBGrid.Columns[I].Field).DisplayFormat;
                  if pos('.000',cFormat)>0 then
                     //cFormat := '# ##0,000_ ;[Красный]-# ##0,000\ ;;'
                     Cells[R, C].FormatStringIndex := FormatKolIndex
                  else
                  if pos('.00',cFormat)>0 then
                    // cFormat := '# ##0,00_ ;[Красный]-# ##0,00';// \ ;;     <- закомментировано не показывать нули
                    Cells[R, C].FormatStringIndex := 30;
                end
              else

              if FDBGrid.Columns[I].Field.AsString <> '' then
                Cells[R, C].Value:= FDBGrid.Columns[I].Field.Value;
            Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(FDBGrid.Columns[I].Alignment);
            Cells[R, C].FontName:= FDBGrid.Columns[I].Font.Name;
            Cells[R, C].FontBold:= (fsBold in FDBGrid.Columns[I].Font.Style);
            Cells[R, C].FontItalic:= (fsItalic in FDBGrid.Columns[I].Font.Style);
            Cells[R, C].FontUnderline:= (fsUnderline in FDBGrid.Columns[I].Font.Style);
            Cells[R, C].FontStrikeOut:= (fsStrikeOut in FDBGrid.Columns[I].Font.Style);
            Cells[R, C].FontHeight:= FDBGrid.Columns[I].Font.Size;

            if FDBGrid.Columns[I].Font.Color <> clBlack then
              Cells[R, C].FontColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Font.Color);
            if (FDBGrid.Columns[I].Color <> clWindow) then
            begin
              Cells[R, C].FillPattern:= xlPatternGrid;
              Cells[R, C].FillPatternBGColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Color);
            end;

//            if Assigned(FOnSaveColumn) then
//              FOnSaveColumn(FDBGrid.Columns[I], Cells[R, C]);
            Inc(C);
          end;
        end;

        FDBGrid.DataSource.DataSet.Next;
        Inc(R);
      end;
    finally
      FDBGrid.DataSource.DataSet.First;
      FDBGrid.DataSource.DataSet.EnableControls;
    end;

    {save totals}
    {if Assigned(FOnSaveFooter) then
    begin
      C:= AColumn;
      for I:= 0 to FDBGrid.Columns.Count-1 do
      begin
        if FDBGrid.Columns[I].Field.Visible
                then
        begin
          Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(FDBGrid.Columns[I].Alignment);
          Cells[R, C].FontName:= FDBGrid.Columns[I].Font.Name;
          Cells[R, C].FontBold:= (fsBold in FDBGrid.Columns[I].Font.Style);
          Cells[R, C].FontItalic:= (fsItalic in FDBGrid.Columns[I].Font.Style);
          Cells[R, C].FontUnderline:= (fsUnderline in FDBGrid.Columns[I].Font.Style);
          Cells[R, C].FontStrikeOut:= (fsStrikeOut in FDBGrid.Columns[I].Font.Style);

          Cells[R, C].FontHeight:= FDBGrid.Columns[I].Font.Size;

          if FDBGrid.Columns[I].Font.Color <> clBlack then
            Cells[R, C].FontColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Font.Color);
          if (FDBGrid.Columns[I].Color <> clWindow) then
          begin
            Cells[R, C].FillPattern:= xlPatternSolid;
            Cells[R, C].FillPatternBGColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Color);
          end;

          CalcRange:= ColIndexToColName(C) + AnsiString(IntToStr(ARow + 2)) + ':' +
            ColIndexToColName(C) +  AnsiString(IntToStr(R));
          CalcType:= tcNone;

          FOnSaveFooter(I, Cells[R, C], CalcType, CalcRange);

          case CalcType of
            tcNone:
              begin
                Cells[R, C].Clear;
              end;
            tcUserDef: ;
            else
              if CalcRange <> '' then
                Cells[R, C].Formula:= xlTotalCalcFunctions[CalcType] +
                  '(' + CalcRange + ')';
          end;
          Inc(C);
        end;
      end;
    end;}
  end;

end;

end.
