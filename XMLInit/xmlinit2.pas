unit xmlinit2;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Controls,Forms,
  Dialogs, xmldom, XMLIntf, msxmldom, XMLDoc, StdCtrls;

type
  TTypeNodeXml = (tnxList,tnxValue);

  TListNodeXml = class;
  TXmlIniFile = Class;

  PTreeNodeXml = ^RTreeNodeXml;
  RTreeNodeXml= record
    path:String;
    nodetype: TTypeNodeXml;
    List:TListNodeXml;
    v: Variant;
    tag: string;
  end;

  TListNodeXml = class(TList)
  private
    function GetItem(aI:Integer):PTreeNodeXml;
    procedure SetItem(aI:Integer;aP: PTreeNodeXml);
  public
    procedure Clear;override;
    procedure Delete(i:Integer);
    destructor Destroy;override;
    property Items[i:Integer]:PTreeNodeXml read GetItem write SetItem;default;
  end;

  TXmlIniKey = class(TObject)
  private
    FOwner: TXmlIniFile;
    FCurrentNode: IXMLNode;
    FCurrentKey: String;
  public
    constructor Create(Sender:TComponent;AXmlNode:IXMLNode; FName: String);
    destructor Destroy;override;
    procedure CreateKey(Key:String);
    procedure DeleteKey(Key:String);
    function FindKey(Key:String; bCreate:Boolean=True):IXMLnode;
    function GetKeyValue(Key: String; Default:Variant):Variant;
    procedure SetKeyValue(Key:String; Val: Variant; bCreate: Boolean = True);
  end;

  TXmlIniFile = Class (TObject)
  private
    FXMLDoc: TXMLDocument;
    FFileName: String;
    FCurrentNode: IXMLNode;
    FCurrentKey: String;
    FListNodeXml: TListNodeXml;
    FStrings: TStringList;
//    function GetNode(name: String):IXMlNode;
    class function GetNextKey(var Key:string):String;
    function FindKey(Key:String; bCreate:Boolean=True):IXMLnode;

  public
    constructor Create(Sender:TComponent;FName: String);
    destructor Destroy;override;
    function GoToKey(Key:String;bCreate:boolean =False ):TXmlIniKey;
    procedure FillListNodeXml;
    procedure SaveToFile;
    procedure Close;
//  published
    property CurrentKey:String read FCurrentKey;
    property FileName:String read FFileName ;
    property ListNodeXml:TListNodeXml read FListNodeXml;
    procedure GetSection(Key:String;var StringList:TStringList);
//    property CurrentNode:IXMLNode read FCurrentNode write FCurrentNode;
//    property XMLDoc:TXMLDocument read FXMLDoc;
  end;

implementation
uses DateVk;
{ TXmlIni }

procedure TXmlIniFile.Close;
begin
  if FXMLDoc.Active then
    FXMLDoc.Active := False;

end;

constructor TXmlIniFile.Create(Sender:TComponent;FName: String);
begin
  inherited Create;
  FXMLDoc := TXMLDocument.Create(Sender);
  FFileName:= FName;
  if not FileExists(FName) then
  begin
    FXMLDoc.Active := True;
    FXMLDoc.Encoding := 'WINDOWS-1251';
    FXMLDoc.AddChild('XMLIni');
    FXMLDoc.Options := FXMLDoc.Options+[doNodeautoIndent];
    FXMLDoc.SaveToFile(FFileName);
    FXMLDoc.Active := False;
  end;
  FXMLDoc.FileName := FFileName;
  FXMLDoc.Active   := true;
  FCurrentNode := FXMLDoc.DocumentElement;
  FListNodeXml := TListNodeXml.Create;
  FStrings := TStringList.Create;
end;

{procedure TXmlIniFile.CreateKey(Key: String);
var nodename:String;
    node:IXMLNode;
    nextnode :IXMLNode;
begin
  if not Assigned(FCurrentNode) then
  begin
    Raise Exception.Create('Error in XML! Current node - not defined!');
  end;
  node:=FCurrentNode;
  nodename:=GetNextKey(Key);
  while nodename<>'' do
  begin
    nextnode := node.ChildNodes.FindNode(nodename);
    if nextnode=nil then
    begin
      node:=node.AddChild(nodename);
      FXMLDoc.SaveToFile(FXMLDoc.FileName);
    end;
    nodename:=GetNextKey(Key);
  end;

end;}

{procedure TXmlIniFile.DeleteKey(Key: String);
var node,parent: IXMLNode;
begin
  node := Findkey(Key,False);
  if Assigned(node) then
  begin
    parent := node.ParentNode;
    parent.ChildNodes.Remove(node);
  end;
end;}

destructor TXmlIniFile.Destroy;
begin
  if FXMLDoc.Active then
    FXMLDoc.SaveToFile(FXMLDoc.FileName);
  FXMLDoc.Free;
  FListNodeXml.Free;
  FStrings.Free;
  inherited;
end;

{**************************
   Function FindKey
   Parameters Key;bCreate
   Return IXMLnode
***************************}
procedure TXmlIniFile.FillListNodeXml;
var p:PTreeNodeXml;
   procedure AddChild(aP:PTreeNodeXml);
     var Names:TStringList;
         p:PTreeNodeXml;
         i: Integer;
   begin
     Names := TStringList.Create;
     GetSection(aP.Path,Names);
     if (Names.Count>0) and (Names[0]<>'#text') then
     begin
       aP.nodetype := tnxList;
       for I := 0 to Names.Count - 1 do
       begin
         New(p);
         p.path:= aP.path+'\'+Names[i];
         p.List := TListNodeXml.Create;
         p.tag  := Names[i];
         AddChild(p);
         aP.List.Add(p);
       end;
     end
     else
     begin
        aP.nodetype := tnxValue;
        aP.v        := GetKeyValue(aP.path,'');
     end;
   end;
begin
  FListNodeXml.Clear;
  New(p);
  p.path:= 'ROOT';
  p.nodetype := tnxList;
  p.v := 'ROOT';
  p.List := TListNodeXml.Create;
  AddChild(p);
  FListNodeXml.Add(p);
end;

function TXmlIniFile.FindKey(Key: String; bCreate: Boolean): IXMLnode;
var nodename:String;
    node:IXMLNode;
    nextnode :IXMLNode;
begin
  node:=FCurrentNode;
  if not Assigned(FCurrentNode) then
  begin
    Raise Exception.Create('Error in XML! Current node - not defined!');
  end;
  nodename:=GetNextKey(Key);
  if UpperCase(nodename)='ROOT' then
  begin
    node := FXMLDoc.DocumentElement;
    nodename:= GetNextKey(Key);
  end;

  while nodename<>'' do
  begin
    nextnode := node.ChildNodes.FindNode(nodename);
    if nextnode=nil then
    begin
      if bCreate then
      begin
        node:=node.AddChild(nodename);
        FXMLDoc.SaveToFile(FXMLDoc.FileName);
      end
      else
      begin
        node := nil;
        Exit;
      end;
    end
    else
      node := nextnode;
    nodename:=GetNextKey(Key);
  end;
  Result := node;
end;

{function TXmlIniFile.GetKeyValue(Key: String; Default:Variant): Variant;
var node, nodenext:IXMLNode;
    nodename: String;
begin
  if pos('ROOT',UpperCase(Key))=1 then
  begin
    GoToKey('ROOT');
    Key:=Copy(Key,6,Length(Key));
  end;
  if not Assigned(FCurrentNode) then
  begin
    Result := Default;
    Exit;
  end;
  node:=FCurrentNode;
  nodename:=GetNextKey(Key);
  while nodename<>'' do
  begin
    nodenext := node.ChildNodes.FindNode(nodename);
    if not Assigned(nodenext) then
    begin
      //nodenext:= node.AddChild(nodename);
      //FXMLDoc.SaveToFile(FXMLDoc.FileName);
      Raise Exception.Create('Key not found '+nodename);
    end;
    node:=nodenext;
    nodename:=GetNextKey(Key);
  end;
  Result := node.NodeValue;
  if varIsNull(Result) then
    Result:= Default;
end;}

class function TXmlIniFile.GetNextKey(var Key: string): String;
var k: Integer;
begin
  k:= pos('\',Key);
  if k>0 then
  begin
     Result:=Copy(Key,1,k-1);
     Key:=Copy(Key,k+1,Length(Key));
  end
  else
  begin
     Result:= Key;
     Key:=''
  end;
end;

procedure TXmlIniFile.GetSection(Key: String; var StringList: TStringList);
var node: IXMLnode;
    i: Integer;
begin
  StringList.Clear;
  node := FindKey(Key,False);
  if not Assigned(node) then Exit;
  with node.ChildNodes do
  begin
    for i:=0 to pred(Count) do
      StringList.Add(Nodes[i].NodeName);
  end;
end;

function TXmlIniFile.GoToKey(Key: String; bCreate:Boolean): Boolean;
var node: IXMLNode;
    nodename: String;
    key2:String;
begin
  key2     :=Key;
  node     := FCurrentNode;
  nodename := GetNextKey(Key);
  if UpperCase(nodename)='ROOT' then
  begin
    node    := FXMLDoc.DocumentElement;
    nodename:= GetNextKey(Key);
  end;
//  Result:=False;
  while nodename<>'' do
  begin
    node := node.ChildNodes.FindNode(nodename);
    if node=nil then
    begin
//      FCurrentNode := node;
      Break;
    end;
    nodename:= GetNextKey(Key);
  end;
  if Assigned(node) then
    FCurrentNode := node;
  Result:= Assigned(node);
  if not Result and bCreate then
  begin
    SetKeyValue(Key2,'');
    Result := GoToKey(Key2,False);
  end;
end;

procedure TXmlIniFile.SaveToFile;
{var fStream: TFileStream;
    Items:TStringList;
  procedure ReadNode(aNode:String);
  begin
    ITems := TStringList.Create;

  end;}
  function SetOtstup(const s: String; nDelta:Integer):String;
  var i: Integer;
  begin
    Result := s;
    i:= 1;
    while i<=Length(Result) do
    begin
      if Result[i]=#10 then
         Result := Copy(Result,1,i)+space(nDelta)+Trim(Copy(Result,i+1,Length(s)));
      inc(i);
    end;

  end;

  function GetTag(const s:string ; nType:Integer):String ;
  begin
    Result := s;
    if s='#cdata-section' then
    begin
      if nType=1 then
        Result := '<![CDATA['
      else
        Result := ' ]]>';
    end
    else
    begin
      if nType=1 then
        Result := '<'+s+'>'
      else
        Result := '</'+s+'>';
    end;
  end;
  procedure AddChildStrings(aP:PTreeNodeXml; nDelta:Integer);
  var i:Integer;
  begin
    for I := 0 to aP.List.Count - 1 do
    begin
      if aP.List[i].nodetype= tnxList then
      begin
        FStrings.Add(Space(nDelta)+getTag(aP.List[i].tag,1));
        AddChildStrings(aP.List[i],nDelta+2);
        FStrings.Add(Space(nDelta)+getTag(aP.List[i].tag,2));
      end
      else
      begin
        FStrings.Add(Space(nDelta)+getTag(aP.List[i].tag,1)+SetOtstup(aP.List[i].v,nDelta)+getTag(aP.List[i].tag,2));
      end;
    end;
  end;
begin
   FillListNodeXml;
   FStrings.Clear;
   FStrings.Add('<?xml version="1.0" encoding="WINDOWS-1251"?>'+#13#10+'<XMLIni>');
   AddChildStrings(FListNodeXml[0],2);
   FStrings.Add('</XMLIni>');
   FStrings.SaveToFile(FXMLDoc.FileName);
  {fStream:=TFileStream.Create(FName,fmWrite and fmShareDenyNone);
  Items := TStringList.Create;
  try


  finally
    Items.Free;
    fStream.Free;
  end;
 }
end;

{procedure TXmlIniFile.SetKeyValue(Key: String; Val: Variant; BCreate: Boolean);
var node: IXMLNode;
begin
  node := FindKey(Key,bCreate);
  if Assigned(node) then
  begin
//    ShowMessage(Node.NodeName);
    node.NodeValue := Val;
    //FXMLDoc.SaveToFile(FXMLDoc.FileName);
  end;
end; }


{ TListNodeXml }


procedure TListNodeXml.Clear;
begin
  while Count>0 do
    Delete(0);
  inherited;
end;

procedure TListNodeXml.Delete(i: Integer);
var p:PTreeNodeXml;
begin
  p := Items[i];
  p.List.Free;
  Dispose(p);
  TList(self).Delete(i);
end;

destructor TListNodeXml.Destroy;
begin
  Clear;
  inherited;
end;

function TListNodeXml.GetItem(aI: Integer): PTreeNodeXml;
begin
  Result := PTreeNodeXml(TList(self)[aI]);
end;

procedure TListNodeXml.SetItem(aI: Integer; aP: PTreeNodeXml);
var p:PTreeNodeXml;
begin
   p := TList(self)[aI];
   p^ :=aP^;
end;

{ TXmlIniKey }

constructor TXmlIniKey.Create(Sender: TComponent;AXmlNode:IXMLNode; FName: String);
begin

    ;AXmlNode:IXMLNode
end;

procedure TXmlIniKey.CreateKey(Key: String);
var nodename:String;
    node:IXMLNode;
    nextnode :IXMLNode;
begin
  if not Assigned(FCurrentNode) then
  begin
    Raise Exception.Create('Error in XML! Current node - not defined!');
  end;
  node:=FCurrentNode;
  nodename := TXmlIniFile.GetNextKey(Key);
  while nodename<>'' do
  begin
    nextnode := node.ChildNodes.FindNode(nodename);
    if nextnode=nil then
    begin
      node:=node.AddChild(nodename);
//      FXMLDoc.SaveToFile(FXMLDoc.FileName);
    end;
    nodename:=TXmlIniFile.GetNextKey(Key);
  end;
end;

procedure TXmlIniKey.DeleteKey(Key: String);
begin

end;

destructor TXmlIniKey.Destroy;
begin

  inherited;
end;

function TXmlIniKey.FindKey(Key: String; bCreate: Boolean): IXMLnode;
begin

end;

function TXmlIniKey.GetKeyValue(Key: String; Default: Variant): Variant;
begin

end;

procedure TXmlIniKey.GetSection(Key: String; var StringList: TStringList);
begin

end;

procedure TXmlIniKey.SetKeyValue(Key: String; Val: Variant; bCreate: Boolean);
begin

end;

end.
