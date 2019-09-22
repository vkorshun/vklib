unit filenameedit;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Mask, MEditBox,
  Dialogs;

type
  TFileNameEdit = class(TMEditBox)
  private
    function GetFileName: String;
    procedure SetFileName(const Value: String);
    { Private declarations }
    procedure FileNameEditButtonClick(Sender:TObject);
    function GetFilter: String;
    procedure SetFilter(const Value: String);
  protected
    { Protected declarations }
    FOpenDialog: TOpenDialog;
    property OnButtonClick;
  public
    { Public declarations }
    constructor Create(Owner:TComponent);override;
  published
    { Published declarations }
    property FileName: String  read GetFileName write SetFileName;
    property Filter: String read GetFilter write SetFilter;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('VkComp', [TFileNameEdit]);
end;

{ TFileNameEdit }

constructor TFileNameEdit.Create(Owner: TComponent);
begin
  Inherited Create(Owner);
  FOpenDialog := TOpenDialog.Create(self);
  OnButtonClick := FileNameEditButtonClick;
end;

procedure TFileNameEdit.FileNameEditButtonClick(Sender: TObject);
begin
  if FOpenDialog.Execute then
    Text := FOpenDialog.FileName;
  SetFocus;
end;

function TFileNameEdit.GetFileName: String;
begin
  Result := Text;
end;

function TFileNameEdit.GetFilter: String;
begin
  Result := FOpenDialog.Filter;
end;

procedure TFileNameEdit.SetFileName(const Value: String);
begin
  Text := Value;
end;

procedure TFileNameEdit.SetFilter(const Value: String);
begin
  if Not Assigned(FOpenDialog) then
    FOpenDialog := TOpenDialog.Create(self);

  FOpenDialog.Filter := Value;
end;

end.
