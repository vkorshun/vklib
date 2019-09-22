unit BrowseFldr;
interface
uses ShlObj;

function AddSlash(Value :string):string;
function PathToIDList(Value :string):PItemIDList;
function SelectFolder(var Selection :string):boolean;

implementation
uses ActiveX, ShellAPI, Windows;

function AddSlash(Value :string):string;
begin
 Result :=Value;
 if (Value <> '') AND (Value[Length(Value)] <> '\') then
  Result :=Result+'\';
end;

//ѕреобразует путь "C:\MyFolder\" в список ItemIDList
//Ќеобходимо дл€ корректной обработки путей в форме UNC "\\MyHost\C\MyFolder\"
function PathToIDList(Value :string):PItemIDList;
var
 ShellFolder  :IShellFolder;
 CurDir       :WideString;
 ChrCnt, Attr :ULONG;
begin
 Result :=nil;
 CurDir :=Value;
 if (SHGetDesktopFolder(ShellFolder) = NO_ERROR) then
  try
   //само преобразование
   ShellFolder.ParseDisplayName(0, NIL, PWideChar(CurDir), ChrCnt, Result, Attr);
  finally
   ShellFolder :=nil;
  end;
end;

//CallBack функци€ необходима дл€ отображени€ текущего пути
function SelFldrCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
 case uMsg of
  //“акой вариант правильно отображает UNC и локальные пути
  //в lpData находитс€ соотв. PItemIDList
  BFFM_INITIALIZED :SendMessage(Wnd, BFFM_SETSELECTION, 0, Integer(lpData));
  //“акой вариант правильно отображает только локальные пути
//  BFFM_INITIALIZED :SendMessage(Wnd, BFFM_SETSELECTION, 1, Integer(PChar(Sel)));
  //сообщение о смене выбора пользовател€
  //тут можно обновить статус строку (например)
//  BFFM_SELCHANGED  :SendMessage(Wnd, BFFM_SETSTATUSTEXT,0, Integer(PChar(Sel)));
 end;
 Result :=0;
end;

//сама функци€ выбора
//Selection - тек. каталог и результат выбора
//False - пользователь отказалс€ от выбора, Selection =''
function SelectFolder(var Selection :string):boolean;
var
 TitleName :string;
 ItemID, IDList :PItemIDList;
 Malloc      :IMalloc;
 BrowseInfo  :TBrowseInfo;
 DisplayName :array[0..MAX_PATH] of char;
 TempPath    :array[0..MAX_PATH] of char;
begin
 Result :=False;
 AddSlash(Selection);
 IDList :=PathToIDList(Selection);

 FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
 TitleName :='¬ыберите каталог';
 BrowseInfo.hwndOwner :=0;
 BrowseInfo.pszDisplayName := @DisplayName;
 BrowseInfo.lpszTitle := PChar(TitleName);
 BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS OR BIF_STATUSTEXT;
 BrowseInfo.lpfn :=SelFldrCallBack;
 BrowseInfo.lParam :=Integer(IDList);

 ItemID :=SHBrowseForFolder(BrowseInfo);
 try
  if ItemID <> nil then
   begin
    SHGetPathFromIDList(ItemID, TempPath); //преобразуем PItemIDList в путь
    Result :=TempPath <> '';
    Selection :=TempPath;
   end;
 finally
  if SHGetMalloc(Malloc) = NO_ERROR then //освобождаем ресурсы
   begin
    Malloc.Free(IDList); //иногда используют GlobalFreePtr(...)
    Malloc.Free(ItemID); //но правильно ли это ??? неизвестно
   end;
  Malloc :=nil;
 end;
end;

end.
 