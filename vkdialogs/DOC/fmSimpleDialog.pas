unit fmSimpleDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ExtCtrls,ComCtrls, DbGridEh, Db;

type
  TSimpleDialogFm = class(TForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FExcludeTab: TList;
    FbEscapeExit: Boolean; // Поддержка выхода по Escape
    FOnMinimize: TNotifyEvent;
    procedure TabNext;
    procedure TabPrevious;
  public
    { Public declarations }
    constructor Create(aOwner:TComponent);override;
    destructor Destroy;Override;
    Procedure WMSysCommand(var message: TWMSysCommand); message WM_SysCommand;
    property bEscapeExit: Boolean read FbEscapeExit write FbEscapeExit;
    property OnMinimize :TNotifyEvent read FOnMinimize write FOnMinimize;
  end;

var
  SimpleDialogFm: TSimpleDialogFm;

implementation

{$R *.dfm}

constructor TSimpleDialogFm.Create(aOwner: TComponent);
begin
  inherited;
  FExcludeTab := TList.Create;
  FOnMinimize := nil;
end;

destructor TSimpleDialogFm.Destroy;
begin
  FreeAndNil(FExcludeTab);
  inherited;
end;

procedure TSimpleDialogFm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  bIsCombo: Boolean;
  bIsMemo: Boolean;
  bIsExclude: Boolean;
begin
  Inherited;
  bIsCombo := ActiveControl is TComboBox;
  bIsMemo := (ActiveControl is TMemo); //or (ActiveControl is TSynEdit) ;
  bIsExclude := (FExcludeTab.IndexOf(ActiveControl)>-1) or (ActiveControl is TDbGridEh);

  if (Shift = []) and not bIsMemo and not bIsExclude then
  begin
    case Key of
      VK_DOWN:
        begin
          if not bIsCombo or not(TComboBox(ActiveControl).DroppedDown) then
          begin
            Key := 0;
            TabNext;
          end;
        end;
      VK_UP:
        begin
          if not bIsCombo or not(TComboBox(ActiveControl).DroppedDown) then
          begin
            Key := 0;
            TabPrevious;
          end;
        end;
    end;
  end;
  if (Key= VK_ESCAPE) and ((ActiveControl is TDbGridEh) or FbEscapeExit) then
  begin
     if (TDbGridEh(ActiveControl).DataSource.State <> dsEdit) and
        (TDbGridEh(ActiveControl).DataSource.State <> dsInsert)
     then

     ModalResult := MrCancel;
  end;


end;

procedure TSimpleDialogFm.TabNext;
var
  wc: TWinControl;
begin
  wc := FindNextControl(ActiveControl, true, true, False);
  if Assigned(wc) then
    ActiveControl := wc;
end;

procedure TSimpleDialogFm.TabPrevious;
var
  wc: TWinControl;
begin
  wc := FindNextControl(ActiveControl, False, true, False);
  if Assigned(wc) then
    ActiveControl := wc;
end;

procedure TSimpleDialogFm.WMSysCommand(var message: TWMSysCommand);
begin
  Inherited;
  If message.CmdType = SC_MINIMIZE then
  begin
//    Application.Minimize;
    if Assigned(FOnMinimize) then
      FOnMinimize(self);
    //PostMessage(Application.Handle,SC_MINIMIZE,0,0)
  end;
end;

end.
