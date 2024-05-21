unit uMQTTSessionStore;

interface

uses
  System.Generics.Collections,
  uMQTTSession,
  uMQTTComps;

type
  TMQTTSessionStore = class
  private
    FList: TList<TMQTTSession>;
    FStamp: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    function GetItem(Index: integer): TMQTTSession;
    procedure SetItem(Index: integer; const Value: TMQTTSession);
    property Items[Index: integer]: TMQTTSession read GetItem write SetItem; default;
    function Count: integer;
    procedure Clear;
    function GetSession(ClientID: UTF8String): TMQTTSession;
    procedure StoreSession(ClientID: UTF8String; aClient: TMQTTClient); overload;
    procedure DeleteSession(ClientID: UTF8String);
    procedure RestoreSession(ClientID: UTF8String; aClient: TMQTTClient); overload;
    property List: TList<TMQTTSession> read FList;
    property Stamp: TDateTime read FStamp write FStamp;
  end;

implementation

uses
  System.SysUtils;

{ TMQTTSessionStore }

procedure TMQTTSessionStore.Clear;
var
  lSession: TMQTTSession;
begin
  for lSession in FList do
    lSession.DisposeOf;
end;

function TMQTTSessionStore.Count: integer;
begin
  result := FList.Count;
end;

constructor TMQTTSessionStore.Create;
begin
  FStamp := Now;
  FList := TList<TMQTTSession>.Create;
end;

procedure TMQTTSessionStore.DeleteSession(ClientID: UTF8String);
var
  aSession: TMQTTSession;
begin
  aSession := GetSession(ClientID);
  if aSession <> nil then
  begin
    FList.Remove(aSession);
    aSession.DisposeOf;
  end;
end;

destructor TMQTTSessionStore.Destroy;
begin
  Clear;
  FList.DisposeOf;
  inherited;
end;

function TMQTTSessionStore.GetItem(Index: integer): TMQTTSession;
begin
  if (Index >= 0) and (Index < Count) then
    result := FList[Index]
  else
    result := nil;
end;

function TMQTTSessionStore.GetSession(ClientID: UTF8String): TMQTTSession;
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    result := FList[i];
    if result.ClientID = ClientID then
      exit;
  end;
  result := nil;
end;

procedure TMQTTSessionStore.RestoreSession(ClientID: UTF8String; aClient: TMQTTClient);
var
  aSession: TMQTTSession;
begin
  aClient.InFlight.Clear;
  aClient.Releasables.Clear;
  aSession := GetSession(ClientID);
  if aSession <> nil then
  begin
    aClient.InFlight.Assign(aSession.InFlight);
    aClient.Releasables.Assign(aSession.Releasables);
  end;
end;

procedure TMQTTSessionStore.StoreSession(ClientID: UTF8String; aClient: TMQTTClient);
var
  aSession: TMQTTSession;
begin
  aSession := GetSession(ClientID);
  if aSession <> nil then
  begin
    aSession := TMQTTSession.Create;
    aSession.ClientID := ClientID;
    FList.Add(aSession);
  end;

  aSession.InFlight.Assign(aClient.InFlight);
  aSession.Releasables.Assign(aClient.Releasables);
end;

procedure TMQTTSessionStore.SetItem(Index: integer; const Value: TMQTTSession);
begin
  if (Index >= 0) and (Index < Count) then
    FList[Index] := Value;
end;

end.
