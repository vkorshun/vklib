unit fm_wait;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,datevk, ImgList, SignalThreadUnit;

type
  TFmWait = class;

  TDrawThread = class (TSignalThread)
  private
    Fm:TFmWait;
    nC: Integer;
    Rect: TRect;
    MaxWidth: Integer;
    ListVelocity: TIntList;
  public
    sMessage:String;
    oCanvas: TCanvas;
    bQuit: Boolean;
    procedure Execute;override;
    procedure Check;
    Constructor Create(CreateSuspend: Boolean;aFm:TFmWait;aMaxWidth:Integer);
    destructor Destroy;override;
  end;

  TFmWait = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    bCancel: Boolean;
    Thread: TDrawThread;
  public
    { Public declarations }
    sMessage:String;
  end;

var
  FmWait: TFmWait;

implementation

{$R wait.res}

{$R *.dfm}

{ TDrawThread }

procedure TDrawThread.Check;
begin
  bQuit :=  Fm.bCancel;
  sMessage := Fm.sMessage;
end;

constructor TDrawThread.Create(CreateSuspend: Boolean;aFm:TFmWait;aMaxWidth:Integer);
begin
  inherited Create;
  sMessage := '';
  Fm := aFm;
  oCanvas := Fm.Canvas;
  Rect.Left  := 10;
  Rect.Top   := 40;
  Rect.Right := 50;
  Rect.Bottom:= 76;
  bQuit := False;
  MaxWidth := aMaxWidth;
  ListVelocity := TIntList.Create;
  ListVelocity.Add(4);
  ListVelocity.Add(6);
  ListVelocity.Add(6);
  ListVelocity.Add(6);
  ListVelocity.Add(6);
  ListVelocity.Add(6);
  ListVelocity.Add(6);
  ListVelocity.Add(4);
  ListVelocity.Add(4);
  ListVelocity.Add(0);
  ListVelocity.Add(0);
  ListVelocity.Add(0);
  ListVelocity.Add(0);
  ListVelocity.Add(0);
  ListVelocity.Add(0);
  ListVelocity.Add(0);
  ListVelocity.Add(0);
  ListVelocity.Add(0);
//  if not CreateSuspend then
//    Resume;
end;

destructor TDrawThread.Destroy;
begin
//  ListVelocity.Clear;
//  FreeAndNil(ListVelocity);
  inherited;
end;

procedure TDrawThread.Execute;
var Bitmap: TBitmap;
    sz:TSize;
    x,y: Integer;
begin
//  inherited;
  nC:=1;
  while not Terminated  do
  if WaitForSignal then
  begin
    if oCanvas.TryLock then
    begin
      sz := oCanvas.TextExtent(Fm.sMessage);
      x:= (oCanvas.ClipRect.Right- sz.cx) div 2;
      if x<0 then x:= 2;
      y:= 10;
      oCanvas.TextOut(x,y,Fm.sMessage);
      Bitmap := TBitmap.Create;
      try
        Bitmap.LoadFromResourceName(hInstance,'DOG'+IntToStr(nc));
        //Fm.ImageList1.GetBitmap(nC,Bitmap);
        oCanvas.StretchDraw(Rect,Bitmap);
      finally
        oCanvas.UnLock ;
        FreeAndNil(Bitmap);
      end;
    end;
    sleep(150);
    Inc(Rect.Left,ListVelocity[nC-1]);
    Inc(Rect.Right,ListVelocity[nC-1]);
    Inc(nC);
    if nC=ListVelocity.Count+1 then nC:=1;
    if Rect.Left> MaxWidth then
    begin
      Rect.Left:=10;
      Rect.Right:=60;
    end;
  end;
end;

procedure TFmWait.FormClose(Sender: TObject; var Action: TCloseAction);
begin
{  if Assigned(Thread) then
  begin
    Thread.Terminate;
//  WaitForSingleObject(Thread.Handle,0);
    Thread.WaitFor;
    FreeAndNil(Thread);
  end;}
  bCancel := True;
  Thread.Stop;
end;

procedure TFmWait.FormCreate(Sender: TObject);
begin
  bCancel  := False;
  sMessage := '';
  Thread := TDrawThread.Create(True,self,self.ClientWidth);
end;

procedure TFmWait.FormDestroy(Sender: TObject);
begin
//  if not Thread.suspended then
//    Thread.Suspend;
  if Assigned(Thread) then
  begin
    Thread.Terminate;
//  WaitForSingleObject(Thread.Handle,0);
    if Thread.Active then
      Thread.WaitFor;
    Thread.Free;
  end;
end;

procedure TFmWait.FormShow(Sender: TObject);
begin
  if not Thread.Active then
   Thread.Start;
end;

procedure TFmWait.FormHide(Sender: TObject);
begin
//  if not Thread.suspended then
  Thread.Stop;
{  if Assigned(Thread) then
  begin
    Thread.Terminate;
//  WaitForSingleObject(Thread.Handle,0);
    Thread.WaitFor;
  end; }
end;

end.
