unit dirnameedit;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Mask, MEditBox,
  Dialogs, BrowseFldr;

type
  TDirNameEdit = class(TMEditBox)
  private
    function GetDirName: String;
    procedure SetDirName(const Value: String);
    { Private declarations }
    procedure DirNameEditButtonClick(Sender:TObject);
  protected
    { Protected declarations }
    property OnButtonClick;
  public
    { Public declarations }
    constructor Create(Owner:TComponent);override;
  published
    { Published declarations }
    property DirName: String  read GetDirName write SetDirName;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('VkComp', [TDirNameEdit]);
end;

{ TFileNameEdit }

constructor TDirNameEdit.Create(Owner: TComponent);
begin
  Inherited Create(Owner);
  OnButtonClick := DirNameEditButtonClick;
  bCanKeyInput  := True;
end;

procedure TDirNameEdit.DirNameEditButtonClick(Sender: TObject);
var sPath: String;
begin
  sPath := Text;
  if SelectFolder(sPath) then
    Text := spath;
  //if FOpenDialog.Execute then
  //  Text := FOpenDialog.FileName;
end;

function TDirNameEdit.GetDirName: String;
begin
  Result := Text;
end;



procedure TDirNameEdit.SetDirName(const Value: String);
begin
  Text := Value;
end;

end.
