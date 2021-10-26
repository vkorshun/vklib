{**************************************************************************
  TListActionManagerDescription - Массив описаний Actions для ActionManager
Основное назаначение - динамическое формирование ActionList, ActionToolBar,
ActionPopUpMenu
***************************************************************************}
unit ActionManagerDescription;

interface

uses
  Windows,  SysUtils, Variants, Classes, Graphics,
  Controls, Dialogs, ComCtrls,Menus,
  ActnPopup, ActnList, ToolWin, ActnMan,
  ActnCtrls, PlatformDefaultStyleActnCtrls, System.Actions;

type
  TTypeDescription =(tdAll,tdPopUpOnly,tdBarOnly);
  PActionManagerDescription = ^RActionManagerDescription;
  RActionManagerDescription = record
    CategoryName: String;
    ActionName:   String;
    ResName:      String;
    Hint:         String;
    ShortCut:       String;
    id_event:     Integer;
    td:           TTypeDescription;
    OnExecuteAction :TNotifyEvent;
    SubItems: TList;
  end;

  TListActionManagerDescription = class(TObject)
  private
    FItems: TList;
  public
    constructor Create;
    destructor Destroy;override;
    procedure AddDescription(const aCategoryName:String;aIdEvent:Integer;const aResname,
      aHint,aShortCut: String;aTd: TTypeDescription = tdAll;aOnExecuteAction:TNotifyEvent = nil);overload;
    procedure AddDescription(const aCategoryName,aActionName,aResname,aHint,
       aShortCut: String;aTd: TTypeDescription = tdAll;aOnExecuteAction:TNotifyEvent = nil);overload;
   ///<summary> AddSubDescription </summary>
    procedure AddSubDescription(aIndex:Integer;const aCategoryName:String;aIdEvent:Integer;const aResname,
      aHint,aShortCut: String;aTd: TTypeDescription = tdAll;aOnExecuteAction:TNotifyEvent = nil);overload;

    procedure InsertDescription(aIndex:Integer;const aCategoryName:String;aIdEvent:Integer;const aResname,
      aHint,aShortCut: String;aTd: TTypeDescription = tdAll;aOnExecuteAction:TNotifyEvent = nil);overload;
    procedure DefaultOnClic(Sender:TObject);
    procedure Delete(aIndex:Integer);
    function  GetDescription(aIndex:Integer):PActionManagerDescription;
    procedure InitActionManager(aActionManager:TActionManager; aPopUpMenu:TPopUpMenu; aOnExecuteAction:TNotifyEvent= nil);

    property Items:TList read FItems;
  end;
  // Rename Type
  TActionManagerDescriptionList = TListActionManagerDescription;

  PActionListDescriptionItem = ^RActionListDescriptionItem;
  RActionListDescriptionItem = record
    CategoryName: String;
    Action: TAction;
    ResName:      String;
    id_event:     Integer;
    td:           TTypeDescription;
    SubItems: TList;
  end;

  TActionListDescriptionList = class(TObject)
  private
    FItems: TList;
  public
    constructor Create;
    destructor Destroy;override;
    procedure AddDescription(const ACategoryName:String; AAction:TAction;const AResname: String;
     ATd: TTypeDescription = tdAll);
   ///<summary> AddSubDescription </summary>
    procedure AddSubDescription(AIndex:Integer;const ACategoryName:String; AAction:TAction;const AResname: String;
     ATd: TTypeDescription = tdAll);
    procedure InsertDescription(AIndex:Integer;const ACategoryName:String; AAction:TAction;const AResname: String;
     ATd: TTypeDescription = tdAll);
    procedure DefaultOnClic(Sender:TObject);
    procedure Delete(AIndex:Integer);
    function  GetDescription(AIndex:Integer):PActionListDescriptionItem;
    procedure InitActionManager(AActionManager:TActionManager; APopUpMenu:TPopUpMenu; AOnExecuteAction:TNotifyEvent= nil);
    function IndexOf(AAction:TAction):Integer;
    property Items:TList read FItems;
  end;

  procedure LoadBitmapFromResourceName(aBitMap:TBitmap;const aResourceName:String);



implementation


{$R *.res}
uses Buttons;

procedure LoadBitmapFromResourceName(aBitMap:TBitmap;const aResourceName:String);
begin
  aBitmap.LoadFromResourceName(hInstance,aResourceName);
end;

{ TListActionManagerDescription }

procedure TListActionManagerDescription.AddDescription(const aCategoryName,
  aActionName, aResname, aHint, aShortCut: String; aTd:TTypeDescription = tdAll;aOnExecuteAction: TNotifyEvent = nil);
var
  pDescription :PActionManagerDescription;
begin
  New(pDescription);
  with pDescription^ do
  begin
    CategoryName := aCategoryName;
    ActionName   := aActionName;
    ResName      := aResName;
    Hint         := aHint;
    ShortCut     := aShortCut;
    td           := aTd;
    id_event     := 0;
    OnExecuteAction := aOnExecuteAction;
    SubItems := nil;
  end;
  FItems.Add(pDescription);
end;

procedure TListActionManagerDescription.AddSubDescription(aIndex: Integer; const aCategoryName: String;
  aIdEvent: Integer; const aResname, aHint, aShortCut: String; aTd: TTypeDescription;
  aOnExecuteAction: TNotifyEvent);
var
  pDescription :PActionManagerDescription;
  pOwner: PActionManagerDescription;
begin
  New(pDescription);
  with pDescription^ do
  begin
    CategoryName := aCategoryName;
    ActionName   := '';
    ResName      := aResName;
    Hint         := aHint;
    ShortCut     := aShortCut;
    id_event     := aIdEvent;
    OnExecuteAction := aOnExecuteAction;
    td           := aTd;
    SubItems := nil;
  end;
  pOwner := GetDescription(aIndex);
  if Assigned(pOwner) then
  begin
    if not Assigned(pOwner.SubItems) then
      pOwner.SubItems := TList.Create;
    pOwner.SubItems.Add(pDescription);
  end;

end;

procedure TListActionManagerDescription.AddDescription(
  const aCategoryName: String; aIdEvent: Integer; const aResname, aHint,
  aShortCut: String;aTd: TTypeDescription; aOnExecuteAction: TNotifyEvent );
var
  pDescription :PActionManagerDescription;
begin
  New(pDescription);
  with pDescription^ do
  begin
    CategoryName := aCategoryName;
    ActionName   := '';
    ResName      := aResName;
    Hint         := aHint;
    ShortCut     := aShortCut;
    id_event     := aIdEvent;
    OnExecuteAction := aOnExecuteAction;
    td           := aTd;
    SubItems := nil;
  end;
  FItems.Add(pDescription)

end;

constructor TListActionManagerDescription.Create;
begin
  Inherited;
  FItems := TList.Create;
end;

procedure TListActionManagerDescription.DefaultOnClic(Sender: TObject);
begin
  if Assigned(TSpeedButton(Sender).Action) then
    TSpeedButton(Sender).Action.Execute;
end;

procedure TListActionManagerDescription.Delete(aIndex: Integer);
var p: PActionManagerDescription;
begin
  p := GetDescription(aIndex);
  Finalize(p^);
  if Assigned(p.SubItems) then
    FreeAndNil(p.SubItems);
  Dispose(FItems[aIndex]);
  FItems.Delete(aIndex);
end;

destructor TListActionManagerDescription.Destroy;
begin
  while FItems.Count>0 do
    Delete(0);
  inherited;
end;

function TListActionManagerDescription.GetDescription(
  aIndex: Integer): PActionManagerDescription;
begin
  Result := FItems[aIndex];
end;

//=============== TListActionManagerDescription.InitActionManager ============================================
procedure TListActionManagerDescription.InitActionManager(
  aActionManager: TActionManager; aPopUpMenu:TPopUpMenu; aOnExecuteAction:TNotifyEvent= nil);
var i:Integer;
    mAction: TAction;
    mBarItem: TActionClientItem;
    Bitmap:TBitmap;
    aImageList: TImageList;
    bImage: Boolean;

//=========== CreateAction =======================================
procedure CreateAction(aDescription:PActionManagerDescription);
begin
  //----- Action -----
  mAction := TAction.Create(aPopUpMenu);
  with mAction do
  begin
    Category := aDescription.CategoryName;
    Name     := aDescription.ActionName;
    Caption  := aDescription.Hint;
    Hint     := aDescription.Hint;
    Tag      := aDescription.id_event;
    if Assigned(aDescription.OnExecuteAction) then
       OnExecute:= aDescription.OnExecuteAction
    else
       OnExecute:= aOnExecuteAction;
    if aDescription.td<> tdPopUpOnly then
    begin
      ActionList := aActionManager;
      if (aDescription.ResName<> '')  and bImage then
      begin
        //----- ImageList -----
        Bitmap.LoadFromResourceName(hInstance,aDescription.ResName);
        aImageList.AddMasked(Bitmap,Bitmap.TransparentColor);
        ImageIndex := aImageList.Count-1;
      end;
    end;
  end;
end;

//================ AddPopUpMenuItem ==================================================
procedure AddPopUpItem(aDescription: PActionManagerDescription;aItem: TMenuItem);
var mi: TMenuItem;
  j: Integer;
  SubList: TList;
begin
  with aPopUpMenu do
  begin
    mi := TMenuItem.Create(aPopUpMenu);
    if aDescription.resname<>'EMPTY' then
    begin
      mi.Caption := aDescription.hint;
      mi.Action := mAction;
//      mi.OnClick := mAction.OnExecute;
//      Mi.OnClick(mi);
      if bImage and (aDescription.td<> tdPopUpOnly) then
        mi.ImageIndex := aImageList.Count-1;
    end
    else
      mi.Caption := '-';
    mi.Tag := i;
    if aDescription.ShortCut<>'' then
        mi.ShortCut := TextToShortCut(aDescription.ShortCut);
    if not Assigned(aItem) then
    begin
      aPopUpMenu.Items.Add(mi);
    end
    else
    begin
      aItem.Add(mi);
    end;

    //================= Add SubItems =================
    if Assigned(aDescription.SubItems) then
    begin
       SubList := aDescription.SubItems ;
       for j := 0 to SubList.Count - 1 do
       begin
         CreateAction(SubList[j]);
         AddPopUpItem(SubList[j],mi)
       end;
    end;

  end;
end;

var
    pDescription: PActionManagerDescription;
    bPopUpMenu: Boolean;

var
  CatList: TStringList;
begin
  aImageList := TImageList(aActionManager.Images);
  Bitmap  := TBitmap.Create;
  CatList := TStringList.Create;
  try
  if not Assigned(aImageList) then
    if Assigned(aActionManager.LargeImages) then
      aImageList := TImageList(aActionManager.LargeImages)
    else
      Raise Exception.Create(' ImageList not define');
//  aActionManager.Images := aImageList;
  bPopUpMenu := Assigned(aPopUpMenu);
  bImage     := Assigned(aImageList);
  if aActionManager.ActionBars.Count=0 then
  begin
    ShowMessage('Acction bars count is null');
    Exit;
  end;

  if bPopUpMenu then
  begin
    aPopUpMenu.Items.Clear;
  end;

  aImageList.Clear;

  for I := 0 to FItems.Count - 1 do
  begin
    pDescription := FItems[i];
    if UpperCase(pDescription.ActionName)<>'SEPARATOR' then
    begin
      CreateAction(pDescription);
      if pDescription.td<> tdPopUpOnly then
      begin
        mBarItem := aActionManager.ActionBars[0].Items.Add;
        mBarItem.Action := mAction;
        mBarItem.Caption := '';
      end;
      if bPopUpMenu then
      begin
        AddPopUpItem(pDescription,nil);
      end;
    end
    else
    begin
      //mAction := nil;
      if pDescription.td<> tdPopUpOnly then
        aActionManager.AddSeparator(aActionManager.ActionBars[0].Items[aActionManager.ActionBars[0].Items.Count-1]);
      if bPopUpMenu then
      begin
        AddPopUpItem(pDescription,nil)
      end;
    end;

  end;
  finally
    Bitmap.Free;
    CatList.Free;
  end;
end;

procedure TListActionManagerDescription.InsertDescription(aIndex: Integer;
  const aCategoryName: String; aIdEvent: Integer; const aResname, aHint,
  aShortCut: String; aTd: TTypeDescription; aOnExecuteAction: TNotifyEvent);
var
  pDescription :PActionManagerDescription;
begin
  New(pDescription);
  with pDescription^ do
  begin
    CategoryName := aCategoryName;
    ActionName   := '';
    ResName      := aResName;
    Hint         := aHint;
    ShortCut     := aShortCut;
    id_event     := aIdEvent;
    OnExecuteAction := aOnExecuteAction;
    td           := aTd;
  end;
  FItems.Insert(aIndex,pDescription)

end;

{ TActionListDescriptopnList }

procedure TActionListDescriptionList.AddDescription(const ACategoryName: String; AAction: TAction;
  const AResname: String; ATd: TTypeDescription);
var
  pDescription :PActionListDescriptionItem;
begin
  New(pDescription);
  with pDescription^ do
  begin
    CategoryName := aCategoryName;
    Action := AAction;
    ResName      := aResName;
    td           := aTd;
    SubItems := nil;
  end;
  FItems.Add(pDescription)

end;

procedure TActionListDescriptionList.AddSubDescription(AIndex: Integer; const ACategoryName: String;
  AAction: TAction; const AResname: String; ATd: TTypeDescription);
var
  pDescription :PActionListDescriptionItem;
  pOwner: PActionListDescriptionItem;
begin
  New(pDescription);
  with pDescription^ do
  begin
    CategoryName := aCategoryName;
    Action   := AAction;
    ResName      := aResName;
    td           := ATd;
    SubItems := nil;
  end;
  pOwner := GetDescription(AIndex);
  if Assigned(pOwner) then
  begin
    if not Assigned(pOwner.SubItems) then
      pOwner.SubItems := TList.Create;
    pOwner.SubItems.Add(pDescription);
  end;
end;

constructor TActionListDescriptionList.Create;
begin
  FItems := TList.Create;
end;

procedure TActionListDescriptionList.DefaultOnClic(Sender: TObject);
begin
  if Assigned(TSpeedButton(Sender).Action) then
    TSpeedButton(Sender).Action.Execute;
end;

procedure TActionListDescriptionList.Delete(AIndex: Integer);
var p: PActionListDescriptionItem;
begin
  p := FItems[AIndex];
  if Assigned(p.SubItems) then
  begin
    for var a in p.SubItems do
    begin
      FreeAndNil(a);
    end;
    p.SubItems.Clear;
    FreeAndNil(p.SubItems);
  end;
  Finalize(p^);
  Dispose(p);
  FItems.Delete(aIndex);
end;

destructor TActionListDescriptionList.Destroy;
begin
  while FItems.Count>0 do
  begin
    Finalize(FItems[0]^);
    Delete(0);
  end;
  FItems.Free;
  inherited;
end;

function TActionListDescriptionList.GetDescription(AIndex: Integer): PActionListDescriptionItem;
begin
  Result := FItems[AIndex];
end;

function TActionListDescriptionList.IndexOf(AAction: TAction): Integer;
var
    p: PActionListDescriptionItem;
begin
{  for i:=0 to FItems.Count-1 do
  begin
    p := PActionListDescriptionItem(FItems[i]);
    if p.Action = AAction then
    begin
      Result := i;
      Break;
    end;
  end;}
  Result := -1;
  for p in FItems do
  if p.Action=AAction then
  begin
    Result := FItems.IndexOf(p);
    Break;
  end;

end;

procedure TActionListDescriptionList.InitActionManager(AActionManager: TActionManager; APopUpMenu: TPopUpMenu;
  AOnExecuteAction: TNotifyEvent);
var i:Integer;
    mAction: TAction;
    mBarItem: TActionClientItem;
    Bitmap:TBitmap;
    aImageList: TImageList;
    bImage: Boolean;

  //=========== CreateAction =======================================
  procedure CreateAction(aDescription:PActionManagerDescription);
  begin
    //----- Action -----
    mAction := TAction.Create(aPopUpMenu);
    with mAction do
    begin
      Category := aDescription.CategoryName;
      Name     := aDescription.ActionName;
      Caption  := aDescription.Hint;
      Hint     := aDescription.Hint;
      Tag      := aDescription.id_event;
      if Assigned(aDescription.OnExecuteAction) then
         OnExecute:= aDescription.OnExecuteAction
      else
         OnExecute:= aOnExecuteAction;
      if aDescription.td<> tdPopUpOnly then
      begin
        ActionList := aActionManager;
        if (aDescription.ResName<> '')  and bImage then
        begin
          //----- ImageList -----
          Bitmap.LoadFromResourceName(hInstance,aDescription.ResName);
          aImageList.AddMasked(Bitmap,Bitmap.TransparentColor);
          ImageIndex := aImageList.Count-1;
        end;
      end;
    end;
  end;

  //================ AddPopUpMenuItem ==================================================
  procedure AddPopUpItem(aDescription: PActionListDescriptionItem;aItem: TMenuItem);
  var mi: TMenuItem;
    j: Integer;
    SubList: TList;
  begin
    with aPopUpMenu do
    begin
      mi := TMenuItem.Create(aPopUpMenu);
      if aDescription.resname<>'EMPTY' then
      begin
        mi.Action := mAction;
        if bImage and (aDescription.td<> tdPopUpOnly) then
          mi.ImageIndex := aImageList.Count-1;
      end
      else
        mi.Caption := '-';
      mi.Tag := i;
      //if aDescription.ShortCut<>'' then
      //    mi.ShortCut := TextToShortCut(aDescription.ShortCut);
      if not Assigned(aItem) then
      begin
        aPopUpMenu.Items.Add(mi);
      end
      else
      begin
        aItem.Add(mi);
      end;

      //================= Add SubItems =================
      if Assigned(aDescription.SubItems) then
      begin
         SubList := aDescription.SubItems ;
         for j := 0 to SubList.Count - 1 do
         begin
           CreateAction(SubList[j]);
           AddPopUpItem(SubList[j],mi)
         end;
      end;

    end;
  end;

var
    pDescription: PActionListDescriptionItem;
    bPopUpMenu: Boolean;

var
  CatList: TStringList;
begin
  AImageList := TImageList(aActionManager.Images);
  Bitmap  := TBitmap.Create;
  CatList := TStringList.Create;
  try
    if not Assigned(AImageList) then
      if Assigned(AActionManager.LargeImages) then
        AImageList := TImageList(aActionManager.LargeImages)
      else
        Raise Exception.Create(' ImageList not define');

    bPopUpMenu := Assigned(APopUpMenu);
    bImage     := Assigned(AImageList);
    if AActionManager.ActionBars.Count=0 then
    begin
      ShowMessage('Acction bars count is null');
      Exit;
    end;

    if bPopUpMenu then
    begin
      APopUpMenu.Items.Clear;
    end;

    AImageList.Clear;

    for I := 0 to FItems.Count - 1 do
    begin
      pDescription := FItems[i];
      mAction := pDescription.Action;
      if Assigned(pDescription.Action) and not SameText(pDescription.Action.Name,'SEPARATOR') then
      begin
      //CreateAction(pDescription);
        if (PDescription.ResName<> '')  and bImage then
        begin
          //----- ImageList -----
          Bitmap.LoadFromResourceName(hInstance,pDescription.ResName);
          aImageList.AddMasked(Bitmap,Bitmap.TransparentColor);
          mAction.ImageIndex := aImageList.Count-1;
        end;

        if pDescription.td<> tdPopUpOnly then
        begin
          mBarItem := AActionManager.ActionBars[0].Items.Add;
          mBarItem.Action := mAction;
          mBarItem.Caption := '';
          //mBarItem.Caption := '';
        end;
        if bPopUpMenu then
        begin
          AddPopUpItem(pDescription,nil);
        end;
      end
      else
      begin
        if pDescription.td<> tdPopUpOnly then
          aActionManager.AddSeparator(aActionManager.ActionBars[0].Items[aActionManager.ActionBars[0].Items.Count-1]);
        if bPopUpMenu then
        begin
          AddPopUpItem(pDescription,nil)
        end;
      end;
    end;
  finally
    Bitmap.Free;
    CatList.Free;
  end;
end;

procedure TActionListDescriptionList.InsertDescription(AIndex: Integer; const ACategoryName: String;
  AAction: TAction; const AResname: String; ATd: TTypeDescription);
var
  pDescription :PActionListDescriptionItem;
begin
  New(pDescription);
  with pDescription^ do
  begin
    CategoryName := aCategoryName;
    Action := AAction;
    ResName      := aResName;
    td           := aTd;
    SubItems := nil;
  end;
  FItems.Insert(AIndex,pDescription)
end;

end.
