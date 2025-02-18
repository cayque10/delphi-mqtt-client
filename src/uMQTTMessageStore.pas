unit uMQTTMessageStore;

interface

uses
  System.Generics.Collections,
  uMQTTMessage,
  uMQTT;

type

  TMQTTMessageStore = class
  private
    FList: TList<TMQTTMessage>;
    FStamp: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;

    function GetItem(AIndex: integer): TMQTTMessage;
    procedure SetItem(AIndex: integer; const Value: TMQTTMessage);
    property Items[AIndex: integer]: TMQTTMessage read GetItem write SetItem; default;
    function Count: integer;
    procedure Clear;
    procedure Assign(AFrom: TMQTTMessageStore);
    function AddMsg(AAnID: Word; ATopic: UTF8String; AMessage: String; AQos: TMQTTQOSType; ARetry: cardinal;
      ACount: cardinal; ARetained: Boolean = false): TMQTTMessage;
    procedure DelMsg(AAnID: Word);
    function GetMsg(AAnID: Word): TMQTTMessage;
    procedure Remove(AMsg: TMQTTMessage);
    property List: TList<TMQTTMessage> read FList;
    property Stamp: TDateTime read FStamp write FStamp;

  end;

implementation

uses
  System.SysUtils;

{ TMQTTMessageStore }

function TMQTTMessageStore.AddMsg(AAnID: Word; ATopic: UTF8String; AMessage: String; AQos: TMQTTQOSType;
  ARetry, ACount: cardinal; ARetained: Boolean): TMQTTMessage;
begin
  Result := TMQTTMessage.Create;
  Result.ID := AAnID;
  Result.Topic := ATopic;
  Result.Message := AMessage;
  Result.Qos := AQos;
  Result.Counter := ACount;
  Result.Retries := ARetry;
  Result.Retained := ARetained;
  FList.Add(Result);
end;

procedure TMQTTMessageStore.Assign(AFrom: TMQTTMessageStore);
var
  i: integer;
  lMsgFrom, lNewMsg: TMQTTMessage;
begin
  Clear;
  for i := 0 to AFrom.Count - 1 do
  begin
    lMsgFrom := AFrom[i];
    lNewMsg := TMQTTMessage.Create;
    lNewMsg.Assign(lMsgFrom);
    FList.Add(lNewMsg);
  end;
end;

procedure TMQTTMessageStore.Clear;
var
  lMessage: TMQTTMessage;
begin
  for lMessage in FList do
    lMessage.Free;
end;

function TMQTTMessageStore.Count: integer;
begin
  Result := FList.Count;
end;

constructor TMQTTMessageStore.Create;
begin
  FStamp := Now;
  FList := TList<TMQTTMessage>.Create;
end;

procedure TMQTTMessageStore.DelMsg(AAnID: Word);
var
  i: integer;
  AMsg: TMQTTMessage;
begin
  for i := FList.Count - 1 downto 0 do
  begin
    AMsg := FList[i];
    if AMsg.ID = AAnID then
    begin
      FList.Remove(AMsg);
      AMsg.Free;
      exit;
    end;
  end;
end;

destructor TMQTTMessageStore.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TMQTTMessageStore.GetItem(AIndex: integer): TMQTTMessage;
begin
  if (AIndex >= 0) and (AIndex < Count) then
    Result := FList[AIndex]
  else
    Result := nil;
end;

function TMQTTMessageStore.GetMsg(AAnID: Word): TMQTTMessage;
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    Result := FList[i];
    if Result.ID = AAnID then
      exit;
  end;
  Result := nil;
end;

procedure TMQTTMessageStore.Remove(AMsg: TMQTTMessage);
begin
  FList.Remove(AMsg);
end;

procedure TMQTTMessageStore.SetItem(AIndex: integer; const Value: TMQTTMessage);
begin
  if (AIndex >= 0) and (AIndex < Count) then
    FList[AIndex] := Value;
end;

end.
