unit VkSynEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SynEditRegexSearch, SynEditOptionsDialog, SynEditMiscClasses,
  SynEditSearch, SynEditHighlighter, SynHighlighterCAC, Menus, ComCtrls,
  SynEdit, StdCtrls, Registry, System.UITypes;

//uses
//  SysUtils, Classes, Controls, SynEdit,Registry,Windows;

const
  register_string = '\SOFTWARE\mikko\texteditor';

  IDE_EMPTY        = 0;
  IDE_SAVE         = 1;
  IDE_SAVEINFILE   = 2;
  IDE_LOADFROMFILE = 3;
  IDE_GOTOLINE     = 4;
  IDE_FIND         = 5;
  IDE_CONTINUE     = 6;
  IDE_REPLACE      = 7;
  IDE_CUT          = 8;
  IDE_COPY         = 9;
  IDE_PASTE        = 10;
  IDE_SELECTALL    = 11;
  IDE_CODEPAGE     = 12;

type
  TVkSynEdit = class(TSynEdit)
  private
//    sys_reg : TRegistry;
    FFileLoad: TFileName;
    FLangId: String;
    FAnsi: Boolean;
    FSearchFromCaret: boolean;
//    CmbFont: TComboBox;
    OEM1: TMenuItem;
    procedure AddItem(const resname,hint,aShortCut:String; aIdEvent:Integer);
    procedure InitPopUpMenu;
    function GetAnsi: boolean;
    procedure SetAnsi(const Value: boolean);
    procedure SetLangId(const Value: String);
    { Private declarations }
//    procedure ReadOptions;
//    function GetSystemFontName:String;
//    function GetVersionNt:Integer;
//    function GetFontMetrics(Font:TFont):TTextMetric;
    procedure InternalOpen(aFileName:TFileName);
//    function IsFontMonoSpaced(Font : TFont) : boolean;
//    function CurPosText: String;
//    procedure OnChangeFont(sender: TObject);
//    procedure GetMonoFonts(Proc: TGetStrProc);
//    procedure StrAdd(const s: String);
//    procedure SetAnsi(b:Boolean);
//    function  GetAnsi:boolean;
//    procedure SetLangId(const pLangId:String);
    procedure CreateBookMarkMenus;
//    procedure DestroyBookMarkMenus;
//    function GetFontMetrics(Font: TFont): TTextMetric;
//    procedure GetMonoFonts(Proc: TGetStrProc);
//    function GetSystemFontName: String;
//    function GetVersionNt: Integer;
//    function IsFontMonoSpaced(Font: TFont): boolean;
//    procedure OnChangeFont(sender: TObject);
//    procedure ReadOptions;
//    procedure StrAdd(const s: String);
{    procedure MemoReplaceText(Sender: TObject; const ASearch,
      AReplace: WideString; Line, Column: Integer;
      var Action: TSynReplaceAction);}
  protected
    { Protected declarations }
    FPopUpMenu: TPopUpMenu;
    SaveDialog: TSaveDialog;
    SynCACSyn1: TSynCACSyn;
    SynEditSearch: TSynEditSearch;
    OpenDialog1: TOpenDialog;
    SynEditOptionsDialog1: TSynEditOptionsDialog;
    SynEditRegexSearch: TSynEditRegexSearch;
    procedure DoEvent(Sender:TObject);virtual;
    procedure DoEnter; Override;
  public
    { Public declarations }
    hSignal: THandle;
    procedure InitInterface;
    procedure InternalSave(sFileName: String);
    procedure JumpToLine;
    procedure DoSearchReplaceText(AReplace: boolean;  ABackwards: boolean);
    procedure LoadFromFile;
    procedure SaveAs;
    procedure ShowSearchReplaceDialog(AReplace: boolean);
    procedure OnBookmarkClick(Sender: TObject);
    procedure OnGoToBookmarkClick(Sender: TObject);
    constructor Create(aOwner:TComponent);override;
    property  bAnsi: boolean read GetAnsi write SetAnsi;
    property  LangId:String read FLangId write SetLangId;
  published
    { Published declarations }
  end;

procedure Register;

implementation

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


procedure Register;
begin
  RegisterComponents('SynEdit', [TVkSynEdit]);
end;

{ TVkSynEdit }

procedure TVkSynEdit.AddItem(const resname,hint,aShortCut:String; aIdEvent:Integer);
  var mi: TMenuItem;
begin
  with FPopUpMenu do
  begin
    mi := TMenuItem.Create(FPopUpMenu);
    if resname<>'EMPTY' then
    begin
      mi.Caption := hint;
      mi.OnClick := DoEvent;
    end
    else
      mi.Caption := '-';
    mi.Tag := aIdEvent;
    if aShortCut<>'' then
        mi.ShortCut := TextToShortCut(aShortCut);
    FPopUpMenu.Items.Add(mi);
    if aIdEvent = IDE_CODEPAGE then
      OEM1 := mi;
  end;
end;

constructor TVkSynEdit.Create(aOwner: TComponent);
begin
  inherited;
{  sys_reg := TRegistry.Create;
  sys_reg.OpenKey( register_string, true );
  sTab :=sys_reg.ReadString('count_char_tab');

  if Trim(sTab)='' then sTab := '8';
  sys_reg.CloseKey;}
  LangId := 'ru';
end;

procedure TVkSynEdit.CreateBookMarkMenus;
var mi: TMenuItem;
    i: Integer;
begin
  mi := TMenuItem.Create(FPopUpMenu);
  mi.Caption := '-';
  mi.Tag := 999;
  FPopupMenu.Items.Add(mi);
  mi := TMenuItem.Create(FPopUpMenu);
  if FLangId = 'ru' then
     mi.Caption := 'Переключить закладку';
  if FLangId = 'ukr' then
     mi.Caption := 'Переключити закладку';
  if FLangId = 'en' then
     mi.Caption := 'Toggle Bookmarks';
  mi.Tag := 1000;
  FPopupMenu.Items.Add(mi);
  for i:=0 to 9 do
  begin
    mi := TMenuItem.Create(FPopUpMenu);
    mi.Tag := 10+i;
    if FLangId = 'ru' then
      mi.Caption := ' Закладка '+IntToStr(i);;
    if FLangId = 'ukr' then
      mi.Caption := ' Закладка '+IntToStr(i);
    if FLangId = 'en' then
      mi.Caption := ' Bookmark '+IntToStr(i);
    mi.OnClick := OnBookMarkClick;
    FPopupMenu.Items[FPopupMenu.Items.Count-1].Add(mi);
  end;

  mi := TMenuItem.Create(FPopUpMenu);
  if FLangId = 'ru' then
     mi.Caption := 'Перейти к закладке';
  if FLangId = 'ukr' then
     mi.Caption := 'Перейти до закладки';
  if FLangId = 'en' then
     mi.Caption := 'Goto Bookmarks';
  mi.Tag := 1001;
  FPopUpMenu.Items.Add(mi);
  for i:=0 to 9 do
  begin
    mi := TMenuItem.Create(FPopUpMenu);
    mi.Tag := 100+i;
    if FLangId = 'ru' then
      mi.Caption := ' Закладка '+IntToStr(i);;
    if FLangId = 'ukr' then
      mi.Caption := ' Закладка '+IntToStr(i);
    if FLangId = 'en' then
      mi.Caption := ' Bookmark '+IntToStr(i);
    mi.OnClick := OnGotoBookMarkClick;
    FPopUpMenu.Items[FPopUpMenu.Items.Count-1].Add(mi);
  end;
end;

{function TVkSynEdit.CurPosText: String;
begin
  Result := IntToStr(CaretY)+':'+IntToStr(CaretX)+'  ';
end; }

{procedure TVkSynEdit.DestroyBookMarkMenus;
var i:Integer;
begin
  with FPopUpMenu do
  begin
    i:=0;
    while i<= FPopUpMenu.Items.Count-1 do
    begin
      if FPopUpMenu.Items[i].Tag>=999 then
      begin
        FPopUpMenu.Items[i].Free;
//        FPopUpMenu.Items.Delete(i);
      end
      else
        Inc(i);
    end;
  end;
end;}

procedure TVkSynEdit.DoEnter;
begin
  inherited;
  CaretX := 0;
end;

procedure TVkSynEdit.DoEvent(Sender: TObject);
var id:Integer;
begin
  id := TMenuItem(Sender).Tag;
  case id of
    IDE_SAVE:
      begin
        if  (FFileLoad)<>'' then
          InternalSave(FFileLoad);
      end;
    IDE_SAVEINFILE:   SaveAs;
    IDE_LOADFROMFILE: LoadFromFile;
    IDE_GOTOLINE:     JumpToLine;
    IDE_FIND:         ShowSearchReplaceDialog(FALSE);
    IDE_CONTINUE:     DoSearchReplaceText(FALSE, FALSE);
    IDE_REPLACE:      ShowSearchReplaceDialog(TRUE);
    IDE_CUT:          CutToClipboard;
    IDE_COPY:         CopyToClipboard;
    IDE_PASTE:        PasteFromClipboard;
    IDE_SELECTALL:    SelectAll;
    IDE_CODEPAGE:     bAnsi := not bAnsi;
  end;
end;

procedure TVkSynEdit.DoSearchReplaceText(AReplace, ABackwards: boolean);
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
  begin
    SearchEngine := SynEditRegexSearch;
  end
  else
    SearchEngine := SynEditSearch;
  gbSearchTextAtCaret := True;
  if SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    if ssoBackwards in Options then
      BlockEnd := BlockBegin
    else
      BlockBegin := BlockEnd;
    CaretXY := BlockBegin;
    ShowMessage('Not found!');
  end;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

function TVkSynEdit.GetAnsi: boolean;
begin
  Result := FAnsi;
end;


procedure TVkSynEdit.InitInterface;
begin
  SaveDialog:= TSaveDialog.Create(self);
  SynCACSyn1:= TSynCACSyn.Create(self);
  SynEditSearch:= TSynEditSearch.Create(self);
  OpenDialog1:= TOpenDialog.Create(self);
  SynEditOptionsDialog1:= TSynEditOptionsDialog.Create(self);
  SynEditRegexSearch:= TSynEditRegexSearch.Create(self);
  FPopUpMenu := TPopUpMenu.Create(self);
  if not Assigned(PopUpMenu) then
  begin
    InitPopUpMenu;
    PopupMenu := FPopUpMenu;
    CreateBookMarkMenus;
  end;
  bAnsi := True;

end;

procedure TVkSynEdit.InitPopUpMenu;
begin
  AddItem('','Сохранить','F2',IDE_SAVE);
  AddItem('','Сохранить в файл','Alt+S',IDE_SAVEINFILE);
  AddItem('','Загрузить из файла','Ctrl+O',IDE_LOADFROMFILE);
  AddItem('EMPTY','','',IDE_EMPTY);
  AddItem('','Перейти на строку','Ctrl+J',IDE_GOTOLINE);
  AddItem('','Поиск','Ctrl+F',IDE_FIND);
  AddItem('','Продолжение поиска','F3',IDE_CONTINUE);
  AddItem('','Поиск и замена','Ctrl+R',IDE_REPLACE);
  AddItem('EMPTY','','',IDE_EMPTY);
  AddItem('','Вырезать','Сеrl+X',IDE_CUT);
  AddItem('','Корировать','Ctrl+С',IDE_COPY);
  AddItem('','Вставить','Ctrl+V',IDE_PASTE);
  AddItem('EMPTY','','',IDE_EMPTY);
  AddItem('','Выделить все','Ctrl+A',IDE_SELECTALL);
  AddItem('EMPTY','','',IDE_EMPTY);
  AddItem('','OEM','',IDE_CODEPAGE);

end;

procedure TVkSynEdit.InternalOpen(aFileName: TFileName);
const c:char =#0;
var
  st: TMemoryStream;
begin
  FFileLoad := aFileName;
  st := TMemoryStream.Create;
  try
    st.LoadFromFile(FFileLoad );
    if not bAnsi then
    begin
      OemToAnsi( PAnsiChar(st.Memory), PAnsiChar(st.Memory) );
    end;
    Lines.LoadFromStream( st );
    Modified := True;
  finally
    st.free;
  end;
end;

procedure TVkSynEdit.InternalSave(sFileName: String);
var st : TMemoryStream;
const c : char = #0;
begin
//  if Memo.ReadOnly then Exit;
  st := TMemoryStream.Create;
  try
    Lines.SaveToStream( st );
    st.Write( c, 1 );
    if not bAnsi then
      AnsiToOem ( PAnsiChar(st.Memory), PAnsiChar(st.Memory) );
    st.SetSize(st.Size-1);
    st.SaveToFile( sFileName );
    Modified := false;
  finally
    st.free;
  end;

end;


procedure TVkSynEdit.JumpToLine;
var s : string;
begin
  s := IntToStr( CaretY + 1 );
  if not InputQuery('Go To','Record Number', s) then Exit;
  CaretY := StrToInt(s)-1;
end;

procedure TVkSynEdit.LoadFromFile;
begin
  OpenDialog1.InitialDir := GetCurrentDir;
  if OpenDialog1.Execute then
    FFileLoad := OpenDialog1.FileName
  else
    Exit;
  InternalOpen(FFileLoad);
end;

{procedure TVkSynEdit.MemoReplaceText(Sender: TObject; const ASearch,
  AReplace: WideString; Line, Column: Integer; var Action: TSynReplaceAction);
var
  APos: TPoint;
  EditRect: TRect;
begin
  if ASearch = AReplace then
    Action := raSkip
  else begin
    APos := ClientToScreen(
      RowColumnToPixels(
      BufferToDisplayPos(
        BufferCoord(Column, Line) ) ) );
    EditRect := ClientRect;
    EditRect.TopLeft := ClientToScreen(EditRect.TopLeft);
    EditRect.BottomRight := ClientToScreen(EditRect.BottomRight);

    if ConfirmReplaceDialog = nil then
      ConfirmReplaceDialog := TConfirmReplaceDialog.Create(Application);
    ConfirmReplaceDialog.PrepareShow(EditRect, APos.X, APos.Y,
      APos.Y + LineHeight, ASearch);
    case ConfirmReplaceDialog.ShowModal of
      mrYes: Action := raReplace;
      mrYesToAll: Action := raReplaceAll;
      mrNo: Action := raSkip;
      else Action := raCancel;
    end;
  end;
end;}

procedure TVkSynEdit.OnBookmarkClick(Sender: TObject);
var mi: TMenuItem;
    nTag: Integer;
begin
  mi := TMenuItem(Sender);
  nTag := mi.Tag;
  if IsBookmark(nTag-10) then
     clearBookmark(nTag-10)
  else
    SetBookMark(nTag-10,CaretX,CaretY);
  mi.Checked := IsBookmark(nTag-10)
end;


procedure TVkSynEdit.OnGoToBookmarkClick(Sender: TObject);
var mi: TMenuItem;
    nTag: Integer;
begin
  mi := TMenuItem(Sender);
  nTag := mi.Tag;
  if IsBookmark(nTag-100) then
    GoToBookMark(nTag-100);
end;


procedure TVkSynEdit.SaveAs;
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

procedure TVkSynEdit.SetAnsi(const Value: boolean);
var s:string;
begin
  if FAnsi = Value then
    Exit;
  FAnsi:= Value;
  s := Lines.Text;
  if not bAnsi then
     AnsiToOEM(PAnsiChar(AnsiString(s)),PAnsiChar(AnsiString(s)))
  else
     OEMToAnsi(PAnsiChar(AnsiString(s)),PAnsiChar(AnsiString(s)));

  Lines.Text := s;

  // Показываем codepage
  if Assigned(OEM1) then
    if bAnsi then
      OEM1.Caption := 'ANSI'
    else
      OEM1.Caption := 'OEM';

end;

procedure TVkSynEdit.SetLangId(const Value: String);
begin
  FLangId := Value;
end;

procedure TVkSynEdit.ShowSearchReplaceDialog(AReplace: boolean);
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
      if SelAvail and (BlockBegin.Line = BlockEnd.Line)
      then
        SearchText := SelText
      else
      begin
        SearchText := GetWordAtRowCol(CaretXY);
        if (SearchText = '') and (CaretXY.Char>0) then
        begin
          CaretX := CaretX-1;
          SearchText := GetWordAtRowCol(CaretXY);
          CaretX := CaretX+1;
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


end.
