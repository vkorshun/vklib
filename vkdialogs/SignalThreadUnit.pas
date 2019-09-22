unit SignalThreadUnit;

interface

uses
  Classes,SysUtils,Windows;

type

TSignalThread = class(TThread)
  protected
    FEventHandle:THandle;
    FWaitTime :Cardinal; {how long to wait for signal}
    //FCritSec:TCriticalSection; { critical section to prevent race condition at time of change of Signal states.}
    FOnWork:TNotifyEvent;

    FWorkCounter:Cardinal; { how many times have we been signalled }

    procedure Execute; override; { final; }

    //constructor Create(CreateSuspended: Boolean); { hide parent }
  public
    constructor Create;
    destructor Destroy; override;

    function WaitForSignal:Boolean; { returns TRUE if signal received, false if not received }

    function Active:Boolean; { is there work going on? }

    property WorkCounter:Cardinal read FWorkCounter; { how many times have we been signalled }

    procedure Sync(AMethod: TThreadMethod);

    procedure Start; { replaces method from TThread }
    procedure Stop; { provides an alternative to deprecated Suspend method }

    property Terminated; {make visible}

  published
      property WaitTime :Cardinal read FWaitTime write FWaitTime; {how long to wait for signal}

      property OnWork:TNotifyEvent read FOnWork write FOnWork;

end;

implementation

{ TSignalThread }

constructor TSignalThread.Create;
begin
  inherited Create({CreateSuspended}true);
 // must create event handle first!
  FEventHandle := CreateEvent(
          {security}      nil,
          {bManualReset}  true,
          {bInitialState} false,
          {name}          nil);

  FWaitTime := 10;
end;

destructor TSignalThread.Destroy;
begin
 if Self.Suspended or Self.Terminated then
    CloseHandle(FEventHandle);
  inherited;
end;



procedure TSignalThread.Execute;
begin
//  inherited; { not applicable here}
  while not Terminated do begin
      if WaitForSignal then begin
          Inc(FWorkCounter);
          if Assigned(FOnWork) then begin
              FOnWork(Self);
          end;
      end;
  end;
  OutputDebugString('TSignalThread shutting down');

end;

{ Active will return true when it is easily (instantly) apparent that
  we are not paused.  If we are not active, it is possible we are paused,
  or it is possible we are in some in-between state. }
function TSignalThread.Active: Boolean;
begin
 result := WaitForSingleObject(FEventHandle,0)= WAIT_OBJECT_0;
end;

procedure TSignalThread.Start;
begin
  SetEvent(FEventHandle); { when we are in a signalled state, we can do work}
  if Self.Suspended then
      inherited Start;

end;

procedure TSignalThread.Stop;
begin
    ResetEvent(FEventHandle);
end;

procedure TSignalThread.Sync(AMethod: TThreadMethod);
begin
 Synchronize(AMethod);
end;

function TSignalThread.WaitForSignal: Boolean;
var
 ret:Cardinal;
begin
  result := false;
  ret := WaitForSingleObject(FEventHandle,FWaitTime);
  if (ret=WAIT_OBJECT_0) then
      result := not Self.Terminated;
end;

end.