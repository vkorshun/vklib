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

//����������� ���� "C:\MyFolder\" � ������ ItemIDList
//���������� ��� ���������� ��������� ����� � ����� UNC "\\MyHost\C\MyFolder\"
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
   //���� ��������������
   ShellFolder.ParseDisplayName(0, NIL, PWideChar(CurDir), ChrCnt, Result, Attr);
  finally
   ShellFolder :=nil;
  end;
end;

//CallBack ������� ���������� ��� ����������� �������� ����
function SelFldrCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
 case uMsg of
  //����� ������� ��������� ���������� UNC � ��������� ����
  //� lpData ��������� �����. PItemIDList
  BFFM_INITIALIZED :SendMessage(Wnd, BFFM_SETSELECTION, 0, Integer(lpData));
  //����� ������� ��������� ���������� ������ ��������� ����
//  BFFM_INITIALIZED :SendMessage(Wnd, BFFM_SETSELECTION, 1, Integer(PChar(Sel)));
  //��������� � ����� ������ ������������
  //��� ����� �������� ������ ������ (��������)
//  BFFM_SELCHANGED  :SendMessage(Wnd, BFFM_SETSTATUSTEXT,0, Integer(PChar(Sel)));
 end;
 Result :=0;
end;

//���� ������� ������
//Selection - ���. ������� � ��������� ������
//False - ������������ ��������� �� ������, Selection =''
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
 TitleName :='�������� �������';
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
    SHGetPathFromIDList(ItemID, TempPath); //����������� PItemIDList � ����
    Result :=TempPath <> '';
    Selection :=TempPath;
   end;
 finally
  if SHGetMalloc(Malloc) = NO_ERROR then //����������� �������
   begin
    Malloc.Free(IDList); //������ ���������� GlobalFreePtr(...)
    Malloc.Free(ItemID); //�� ��������� �� ��� ??? ����������
   end;
  Malloc :=nil;
 end;
end;

end.
 