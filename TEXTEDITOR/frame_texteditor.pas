unit frame_texteditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SynEditRegexSearch, SynEditOptionsDialog, SynEditMiscClasses,
  SynEditSearch, SynEditHighlighter, SynHighlighterCAC, Menus, ComCtrls,
  SynEdit, StdCtrls, Registry;

const
  register_string = '\SOFTWARE\mikko\texteditor';
//  stream_name = 'options.bin';

type
  TFrameTextEditor = class(TFrame)
    Memo: TSynEdit;
    StBar: TStatusBar;
    PopupMenu1: TPopupMenu;
    imSave: TMenuItem;
    SaveAs1: TMenuItem;
    nLoadFromFile: TMenuItem;
    N1: TMenuItem;
    nGoToLine: TMenuItem;
    nFind: TMenuItem;
    nNext: TMenuItem;
    nReplace: TMenuItem;
    N4: TMenuItem;
    nCut: TMenuItem;
    nCopy: TMenuItem;
    nPaste: TMenuItem;
    N2: TMenuItem;
    nSelectAll: TMenuItem;
    SaveDialog: TSaveDialog;
    SynCACSyn1: TSynCACSyn;
    SynEditSearch: TSynEditSearch;
    OpenDialog1: TOpenDialog;
    SynEditOptionsDialog1: TSynEditOptionsDialog;
    SynEditRegexSearch: TSynEditRegexSearch;
    N3: TMenuItem;
    OEM1: TMenuItem;
    procedure SaveAs1Click(Sender: TObject);
    procedure nGoToLineClick(Sender: TObject);
    procedure nFindClick(Sender: TObject);
    procedure MemoReplaceText1(Sender: TObject; const ASearch,
      AReplace: String; Line, Column: Integer;
      var Action: TSynReplaceAction);
    procedure MemoStatusChange(Sender: TObject;
      Changes: TSynStatusChanges);
    procedure nNextClick(Sender: TObject);
    procedure nReplaceClick(Sender: TObject);
    procedure nCutClick(Sender: TObject);
    procedure nCopyClick(Sender: TObject);
    procedure nPasteClick(Sender: TObject);
    procedure nSelectAllClick(Sender: TObject);
    procedure nLoadFromFileClick(Sender: TObject);
    procedure StBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure OEM1Click(Sender: TObject);
    procedure MemoReplaceText(Sender: TObject; const ASearch,
      AReplace: WideString; Line, Column: Integer;
      var Action: TSynReplaceAction);
    procedure imSaveClick(Sender: TObject);
  private
    { Private declarations }
    sys_reg : TRegistry;
    FFileLoad: TFileName;
    FLangId: String;
    FAnsi: Boolean;
    FSearchFromCaret: boolean;
    CmbFont: TComboBox;
    procedure ReadOptions;
    function GetSystemFontName:String;
    function GetVersionNt:Integer;
    function GetFontMetrics(Font:TFont):TTextMetric;
    procedure InternalOpen(aFileName:TFileName);
    function IsFontMonoSpaced(Font : TFont) : boolean;
    function CurPosText: String;
    procedure OnChangeFont(sender: TObject);
    procedure GetMonoFonts(Proc: TGetStrProc);
    procedure StrAdd(const s: String);
    procedure SetAnsi(b:Boolean);
    function  GetAnsi:boolean;
    procedure SetLangId(const pLangId:String);
    procedure CreateBookMarkMenus;
    procedure DestroyBookMarkMenus;
  public
    { Public declarations }
    hSignal: THandle;
    procedure InternalSave(sFileName: String);
    procedure JumpToLine;
    procedure DoSearchReplaceText(AReplace: boolean;  ABackwards: boolean);
    procedure LoadFromFile(aFileName:TFileName);
    procedure ShowSearchReplaceDialog(AReplace: boolean);
    procedure OnBookmarkClick(Sender: TObject);
    procedure OnGoToBookmarkClick(Sender: TObject);
    constructor Create(aOwner:TComponent);override;
    property  bAnsi: boolean read GetAnsi write SetAnsi;
    property  LangId:String read FLangId write SetLangId;
  end;

implementation

{$R *.dfm}

{ TFrameTextEditor }

uses  dlgSearchText, dlgReplaceText, dlgConfirmReplace, SynEditTypes, SynEditMiscProcs;
var
  gbSearchBackwards: boolean;
  gbSearchCaseSensitive: boolean;
  gbSearchFromCaret: boolean;
  gbSearchSelectionOnly: boolean;
  gbSearchTextAtCaret: boolean;
  gbSearchWholeWords: boolean;
  gbSearchRegex: boolean;

  gsSearchText: string;
  gsSearchTextHistory: string;
  gsReplaceText: string;
  gsReplaceTextHistory: string;

resourcestring
  STextNotFound = 'Text not found';

constructor TFrameTextEditor.Create(aOwner:TComponent);
var i: Integer;
    sTab: string;

begin
  Inherited;
  ReadOptions;
  FAnsi := True;
  Font.Name := GetSystemFontName;
  for i:=0 to ComponentCount-1 do
    if Components[i] is TWinControl then
       TEdit(Components[i]).Font.Name := Font.Name;
  Memo.Font.Charset := RUSSIAN_CHARSET;
  CmbFont := TComboBox.Create(self);
  CmbFont.OnChange := OnChangeFont;
  CmbFont.Parent := StBar;
  GetMonoFonts(StrAdd);
  i:= GetVersionNt;
  if (i>0) and (i< 5) then
    Memo.Font.Name := 'Courier'
  else
    Memo.Font.Name := 'Courier New';
  Memo.Font.Size := 10;
  CmbFont.Text := Memo.Font.Name;
  sys_reg := TRegistry.Create;
  sys_reg.OpenKey( register_string, true );
  sTab :=sys_reg.ReadString('count_char_tab');

  if Trim(sTab)='' then sTab := '8';
  Memo.OnStatusChange(Memo,[scCaretx]);
  sys_reg.CloseKey;
  LangId := 'ru';
  //CreateBookMarkMenus;
end;


procedure TFrameTextEditor.ReadOptions;
begin
 { oContOptions:= TSynEditorOptionsContainer.create(self);
  if FileExists(stream_name) then
  begin
    fStream := TFileStream.Create(stream_name,fmOpenRead	);
    try
       (fStream.ReadComponent(oContOptions));
    finally
      FStream.Free;
    end;
  end
  else
  begin
    oContOptions.Assign(Memo);
  end;}
end;


function TFrameTextEditor.GetSystemFontName:String;
var sys_reg:TRegistry;
    aBuf:array[0..128] of char;
    pf: PLogFont;
    wc: PWideChar;
begin
  Result := '';
  sys_reg := TRegistry.Create;
  FillChar(aBuf,128,' ');
  try
    if sys_reg.OpenKey( 'Control Panel\Desktop\WindowMetrics',false ) then
    begin
      sys_reg.ReadBinaryData('MenuFont',aBuf,SizeOf(aBuf)-1);
      pf := @aBuf;
      wc := @pf.lfFaceName;
      Result := WideCharToString(wc);
    end;
  finally
    sys_reg.closeKey;
    sys_reg.Free;
  end;
end;

procedure TFrameTextEditor.OnChangeFont(sender: TObject);
begin
  Memo.Font.Name := CmbFont.Text;
  Memo.Refresh;
end;

procedure TFrameTextEditor.GetMonoFonts(Proc: TGetStrProc);
var
  i : integer;
  f : TFont;
begin
  f := TFont.Create;
  try
    with Screen.Fonts do
      for i := 0 to Count - 1 do
        begin
          f.Name := Strings[i];
          if IsFontMonoSpaced(f) then
            Proc(f.Name);
        end;
  finally
    f.Free;
  end;
end;

procedure TFrameTextEditor.StrAdd(const s: String);
begin
  CmbFont.Items.Add(s);
end;

function TFrameTextEditor.GetVersionNt:Integer;
var p: TOSVersionInfo;
begin
  p.dwOSVersionInfoSize := sizeof(OSVERSIONINFO);
  GetVersionEx(p);
  Result := 0;
  if p.dwPlatformId=VER_PLATFORM_WIN32_NT then
    Result := p.dwMajorVersion;
end;

procedure TFrameTextEditor.imSaveClick(Sender: TObject);
begin
  if  (FFileLoad)<>'' then
    InternalSave(FFileLoad);
end;

function TFrameTextEditor.IsFontMonoSpaced(Font : TFont) : boolean;
begin
  result := (GetFontMetrics(Font).tmPitchAndFamily and TMPF_FIXED_PITCH) = 0;
end;

function TFrameTextEditor.GetFontMetrics(Font:TFont):TTextMetric;
var
  dc   : THandle;
  oldf : THandle;
begin
  dc := GetDC(0);
  oldf := SelectObject(dc, Font.Handle);
  try
    GetTextMetrics(dc, result);
  finally
    SelectObject(dc, oldf);
    ReleaseDC(0, dc);
  end;
end;

procedure TFrameTextEditor.SaveAs1Click(Sender: TObject);
var sFileName: String;
    sMsg: String;
begin
  SaveDialog.DefaultExt := Copy(ExtractFileExt(Caption),2,3);
  SaveDialog.FileName   := Caption;
  if SaveDialog.Execute then
   sFileName := SaveDialog.FileName;

  if FLangId='ru' then
     sMsg := 'Перезаписать существующий файл?';
  if FLangId='ukr' then
     sMsg := 'Перезаписати iснуючий файл?';
  if FLangId='en' then
     sMsg := 'Owerwrite existing file?';

  if FileExists(sFileName) then
    if MessageDlg(sMsg,mtConfirmation, [mbYes,mbNo],0)=mrNo then
      Exit;

  if sFileName <> '' then
    InternalSave(sFileName);

end;

procedure TFrameTextEditor.InternalOpen(aFileName: TFileName);
var
  st: TMemoryStream;
const c:char =#0;
begin
  FFileLoad := aFileName;
  st := TMemoryStream.Create;
  try
    st.LoadFromFile(FFileLoad );
    if not bAnsi then
    begin
      OemToAnsi( PAnsiChar(st.Memory), PAnsiChar(st.Memory) );
    end;
    Memo.Lines.LoadFromStream( st );
    Memo.Modified := True;
  finally
    st.free;
  end;

end;

procedure TFrameTextEditor.InternalSave(sFileName: String);
var st : TMemoryStream;
const c : char = #0;
begin
//  if Memo.ReadOnly then Exit;
  st := TMemoryStream.Create;
  try
    Memo.Lines.SaveToStream( st );
    st.Write( c, 1 );
    if not bAnsi then
      AnsiToOem ( PAnsiChar(st.Memory), PAnsiChar(st.Memory) );
    st.SetSize(st.Size-1);
    st.SaveToFile( sFileName );
    Memo.Modified := false;
  finally
    st.free;
  end;
end;


procedure TFrameTextEditor.nGoToLineClick(Sender: TObject);
begin
  JumpToLine;
end;

procedure TFrameTextEditor.JumpToLine;
var s : string;
begin
  s := IntToStr( Memo.CaretY + 1 );
  if not InputQuery('Go To','Record Number', s) then Exit;
  Memo.CaretY := StrToInt(s)-1;
end;

procedure TFrameTextEditor.LoadFromFile(aFileName: TFileName);
begin
  InternalOpen(aFileName);
end;

procedure TFrameTextEditor.nFindClick(Sender: TObject);
begin
  ShowSearchReplaceDialog(FALSE);

end;

procedure TFrameTextEditor.DoSearchReplaceText(AReplace,
  ABackwards: boolean);
var  
  Options: TSynSearchOptions;
begin
  if AReplace then
    Options := [ssoPrompt, ssoReplace, ssoReplaceAll]
  else
    Options := [ssoPrompt];
  if ABackwards then
    Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then
    Include(Options, ssoMatchCase);
  if not fSearchFromCaret then
    Include(Options, ssoEntireScope);
  if gbSearchSelectionOnly then
    Include(Options, ssoSelectedOnly);
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);
  if gbSearchRegex then
    Memo.SearchEngine := SynEditRegexSearch
  else
    Memo.SearchEngine := SynEditSearch;
  gbSearchTextAtCaret := True;
  if Memo.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    if ssoBackwards in Options then
      Memo.BlockEnd := Memo.BlockBegin
    else
      Memo.BlockBegin := Memo.BlockEnd;
    Memo.CaretXY := Memo.BlockBegin;
    ShowMessage('Not found!');
  end;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

procedure TFrameTextEditor.ShowSearchReplaceDialog(AReplace: boolean);
var
  dlg: TTextSearchDialog;
begin
//  Statusbar.SimpleText := '';
  if AReplace then
    dlg := TTextReplaceDialog.Create(Self)
  else
    dlg := TTextSearchDialog.Create(Self);
  with dlg do try
    // assign search options
    Position := poOwnerFormCenter;
    SearchBackwards := gbSearchBackwards;
    SearchCaseSensitive := gbSearchCaseSensitive;
    SearchFromCursor := gbSearchFromCaret;
    SearchInSelectionOnly := gbSearchSelectionOnly;
    // start with last search text
    SearchText := gsSearchText;
    gbSearchTextAtCaret := True;
    if  gbSearchTextAtCaret then begin
      // if something is selected search for that text
      if Memo.SelAvail and (Memo.BlockBegin.Line = Memo.BlockEnd.Line)
      then
        SearchText := Memo.SelText
      else
      begin
        SearchText := Memo.GetWordAtRowCol(Memo.CaretXY);
        if (SearchText = '') and (Memo.CaretXY.Char>0) then
        begin
          Memo.CaretX := Memo.CaretX-1;
          SearchText := Memo.GetWordAtRowCol(Memo.CaretXY);
          Memo.CaretX := Memo.CaretX+1;
        end;

      end;
    end;
    SearchTextHistory := gsSearchTextHistory;
    if AReplace then with dlg as TTextReplaceDialog do begin
      ReplaceText := gsReplaceText;
      ReplaceTextHistory := gsReplaceTextHistory;
    end;
    SearchWholeWords := gbSearchWholeWords;
    if ShowModal = mrOK then begin
      gbSearchBackwards := SearchBackwards;
      gbSearchCaseSensitive := SearchCaseSensitive;
      gbSearchFromCaret := SearchFromCursor;
      gbSearchSelectionOnly := SearchInSelectionOnly;
      gbSearchWholeWords := SearchWholeWords;
      gbSearchRegex := SearchRegularExpression;
      gsSearchText := SearchText;
      gsSearchTextHistory := SearchTextHistory;
      if AReplace then with dlg as TTextReplaceDialog do begin
        gsReplaceText := ReplaceText;
        gsReplaceTextHistory := ReplaceTextHistory;
      end;
      fSearchFromCaret := gbSearchFromCaret;
      if gsSearchText <> '' then begin
        DoSearchReplaceText(AReplace, gbSearchBackwards);
        fSearchFromCaret := TRUE;
      end;
    end;
  finally
    dlg.Free;
  end;
end;

procedure TFrameTextEditor.MemoReplaceText(Sender: TObject; const ASearch,
  AReplace: WideString; Line, Column: Integer; var Action: TSynReplaceAction);
var
  APos: TPoint;
  EditRect: TRect;
begin
  if ASearch = AReplace then
    Action := raSkip
  else begin
    APos := Memo.ClientToScreen(
      Memo.RowColumnToPixels(
      Memo.BufferToDisplayPos(
        BufferCoord(Column, Line) ) ) );
    EditRect := ClientRect;
    EditRect.TopLeft := ClientToScreen(EditRect.TopLeft);
    EditRect.BottomRight := ClientToScreen(EditRect.BottomRight);

    if ConfirmReplaceDialog = nil then
      ConfirmReplaceDialog := TConfirmReplaceDialog.Create(Application);
    ConfirmReplaceDialog.PrepareShow(EditRect, APos.X, APos.Y,
      APos.Y + Memo.LineHeight, ASearch);
    case ConfirmReplaceDialog.ShowModal of
      mrYes: Action := raReplace;
      mrYesToAll: Action := raReplaceAll;
      mrNo: Action := raSkip;
      else Action := raCancel;
    end;
  end;

end;

procedure TFrameTextEditor.MemoReplaceText1(Sender: TObject; const ASearch,
  AReplace: String; Line, Column: Integer; var Action: TSynReplaceAction);
var
  APos: TPoint;
  EditRect: TRect;
begin
  if ASearch = AReplace then
    Action := raSkip
  else begin
    APos := Memo.ClientToScreen(
      Memo.RowColumnToPixels(
      Memo.BufferToDisplayPos(
        BufferCoord(Column, Line) ) ) );
    EditRect := ClientRect;
    EditRect.TopLeft := ClientToScreen(EditRect.TopLeft);
    EditRect.BottomRight := ClientToScreen(EditRect.BottomRight);

    if ConfirmReplaceDialog = nil then
      ConfirmReplaceDialog := TConfirmReplaceDialog.Create(Application);
    ConfirmReplaceDialog.PrepareShow(EditRect, APos.X, APos.Y,
      APos.Y + Memo.LineHeight, ASearch);
    case ConfirmReplaceDialog.ShowModal of
      mrYes: Action := raReplace;
      mrYesToAll: Action := raReplaceAll;
      mrNo: Action := raSkip;
      else Action := raCancel;
    end;
  end;
end;

procedure TFrameTextEditor.MemoStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
const
   cOverwrite:Array[boolean] of String=
     ('Overwrite','Insert');
   cModified:Array[boolean] of string=
     ('','Modified');
begin


  with StBar,Memo do begin
    if (scCaretX in Changes) or (scCaretY in Changes) then
      Panels[0].Text:=CurPosText;

//    if InsertMode then
      Panels[2].Text:=cOverwrite[InsertMode];

    if (Memo <> nil) and Memo.ReadOnly
    then Panels[4].Text:= 'Read only'
    else
//      if Modified then
//      begin
        Panels[4].Text:=cModified[Modified];
//        BtnApply.Enabled := Modified or bEnabled;
//      end;
    if bAnsi then
      Panels[3].Text := 'ANSI'
    else
      Panels[3].Text := 'OEM';
  end;
//  if length(Memo.Lines[Memo.Carety-1])> Memo.MaxScrollWidth then
//    Memo.MaxScrollWidth := length(Memo.Lines[Memo.Carety-1]);
end;

function TFrameTextEditor.CurPosText: String;
begin
  Result := IntToStr(Memo.CaretY)+':'+IntToStr(Memo.CaretX)+'  ';
end;

function TFrameTextEditor.GetAnsi: boolean;
begin
  Result := FAnsi;
end;

procedure TFrameTextEditor.SetAnsi(b: Boolean);
var s:string;
begin
  if FAnsi = b then
    Exit;
  FAnsi:= b;
  s := Memo.Lines.Text;
  if not bAnsi then
     AnsiToOEM(PAnsiChar(AnsiString(s)),PAnsiChar(AnsiString(s)))
  else
     OEMToAnsi(PAnsiChar(AnsiString(s)),PAnsiChar(AnsiString(s)));

  Memo.Lines.Text := s;

end;

procedure TFrameTextEditor.nNextClick(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, FALSE);
end;

procedure TFrameTextEditor.nReplaceClick(Sender: TObject);
begin
  ShowSearchReplaceDialog(TRUE);
end;

procedure TFrameTextEditor.nCutClick(Sender: TObject);
begin
  Memo.CutToClipboard;
end;

procedure TFrameTextEditor.nCopyClick(Sender: TObject);
begin
  Memo.CopyToClipboard;
end;

procedure TFrameTextEditor.nPasteClick(Sender: TObject);
begin
  Memo.PasteFromClipboard;
end;

procedure TFrameTextEditor.nSelectAllClick(Sender: TObject);
begin
  Memo.SelectAll;
end;

procedure TFrameTextEditor.nLoadFromFileClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := GetCurrentDir;
  if OpenDialog1.Execute then
    FFileLoad := OpenDialog1.FileName
  else
    Exit;
  InternalOpen(FFileLoad);

end;

procedure TFrameTextEditor.SetLangId(const pLangId: String);
begin
  FLangId := pLangId;
  if pLangId='ukr' then
  begin
    imSave.Caption := 'Зберегти';
    SaveAs1.Caption := 'Зберегти в файл ';
    nLoadFromFile.Caption :='Загрузити із файла';
    nCut.Caption := 'Вирiзати';
    nCopy.Caption := 'Копiювати';
    nPaste.Caption := 'Вiдновити';
    nSelectAll.Caption := 'Все помiтити';
    nGoToLine.Caption := 'Перейти до лiнiї';
    nFind.Caption := 'Пошук';
    nNext.Caption := 'Продовжити пошук';
    nReplace.Caption := 'Пошук і заміна';
  end;
  if pLangId='en' then
  begin
    imSave.Caption := 'Save';
    SaveAs1.Caption := 'Save as file  ';
    nLoadFromFile.Caption :='Load from file';
    nCut.Caption := 'Cut';
    nCopy.Caption := 'Copy';
    nPaste.Caption := 'Paste';
    nSelectAll.Caption := 'Select All';
    nGoToLine.Caption := 'Go to line';
    nFind.Caption := 'Find';
    nNext.Caption := 'Find next';
    nReplace.Caption := 'Find & Replace';
  end;
  DestroyBookMarkMenus;
  CreateBookMarkMenus;
end;

procedure TFrameTextEditor.CreateBookMarkMenus;
var mi: TMenuItem;
    i: Integer;
begin
  mi := TMenuItem.Create(PopUpMenu1);
  mi.Caption := '-';
  mi.Tag := 999;
  PopupMenu1.Items.Add(mi);
  mi := TMenuItem.Create(PopUpMenu1);
  if FLangId = 'ru' then
     mi.Caption := 'Переключить закладку';
  if FLangId = 'ukr' then
     mi.Caption := 'Переключити закладку';
  if FLangId = 'en' then
     mi.Caption := 'Toggle Bookmarks';
  mi.Tag := 1000;
  PopupMenu1.Items.Add(mi);
  for i:=0 to 9 do
  begin
    mi := TMenuItem.Create(PopUpMenu1);
    mi.Tag := 10+i;
    if FLangId = 'ru' then
      mi.Caption := ' Закладка '+IntToStr(i);;
    if FLangId = 'ukr' then
      mi.Caption := ' Закладка '+IntToStr(i);
    if FLangId = 'en' then
      mi.Caption := ' Bookmark '+IntToStr(i);
    mi.OnClick := OnBookMarkClick;
    PopupMenu1.Items[PopupMenu1.Items.Count-1].Add(mi);
  end;

  mi := TMenuItem.Create(PopUpMenu1);
  if FLangId = 'ru' then
     mi.Caption := 'Перейти к закладке';
  if FLangId = 'ukr' then
     mi.Caption := 'Перейти до закладки';
  if FLangId = 'en' then
     mi.Caption := 'Goto Bookmarks';
  mi.Tag := 1001;
  PopupMenu1.Items.Add(mi);
  for i:=0 to 9 do
  begin
    mi := TMenuItem.Create(PopUpMenu1);
    mi.Tag := 100+i;
    if FLangId = 'ru' then
      mi.Caption := ' Закладка '+IntToStr(i);;
    if FLangId = 'ukr' then
      mi.Caption := ' Закладка '+IntToStr(i);
    if FLangId = 'en' then
      mi.Caption := ' Bookmark '+IntToStr(i);
    mi.OnClick := OnGotoBookMarkClick;
    PopupMenu1.Items[PopupMenu1.Items.Count-1].Add(mi);
  end;
//  mi := TMenuItem.Create(PopUpMenu1);
//  mi.Caption := 'Goto Bookmarks';
//  PopupMenu1.Items.Add(mi);
end;

procedure TFrameTextEditor.OnBookmarkClick(Sender: TObject);
var mi: TMenuItem;
    nTag: Integer;
begin
  mi := TMenuItem(Sender);
  nTag := mi.Tag;
  if Memo.IsBookmark(nTag-10) then
     Memo.clearBookmark(nTag-10)
  else
    Memo.SetBookMark(nTag-10,Memo.CaretX,Memo.CaretY);
  mi.Checked := Memo.IsBookmark(nTag-10)

end;

procedure TFrameTextEditor.OnGoToBookmarkClick(Sender: TObject);
var mi: TMenuItem;
    nTag: Integer;
begin
  mi := TMenuItem(Sender);
  nTag := mi.Tag;
  if Memo.IsBookmark(nTag-100) then
    Memo.GoToBookMark(nTag-100);
end;

procedure TFrameTextEditor.DestroyBookMarkMenus;
var i:Integer;
begin
  with PopUpMenu1 do
  begin
    i:=0;
    while i<= PopUpMenu1.Items.Count-1 do
    begin
      if PopUpMenu1.Items[i].Tag>=999 then
      begin
        PopUpMenu1.Items[i].Free;
//        PopUpMenu1.Items.Delete(i);
      end
      else
        Inc(i);
    end;
  end;
end;

procedure TFrameTextEditor.StBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
   CmbFont.Left := Rect.Left-1;
   CmbFont.Top := Rect.Top-1;
   CmbFont.Width := Rect.Right-Rect.Left;
   CmbFont.Height := Rect.Bottom- Rect.Top;
end;

procedure TFrameTextEditor.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key= VK_ESCAPE) and (self.Parent is TForm) then
  TForm(self.Parent).ModalResult := MrCancel;
end;

procedure TFrameTextEditor.PopupMenu1Popup(Sender: TObject);
begin
  if bAnsi then
    OEM1.Caption := 'ANSI'
  else
    OEM1.Caption := 'OEM';
end;

procedure TFrameTextEditor.OEM1Click(Sender: TObject);
begin
  bAnsi := not bAnsi;
end;

end.
