unit uMQTTPacketStore;

interface

uses
  System.Generics.Collections,
  uMQTTPacket,
  System.Classes;

type

  TMQTTPacketStore = class
  private
    FList: TList<TMQTTPacket>;
    FStamp: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    function GetItem(AIndex: integer): TMQTTPacket;
    procedure SetItem(AIndex: integer; const Value: TMQTTPacket);
    property Items[AIndex: integer]: TMQTTPacket read GetItem write SetItem; default;
    function Count: integer;
    procedure Clear;
    procedure Assign(AFrom: TMQTTPacketStore);
    function AddPacket(APacketID: Word; AMessageStream: TMemoryStream; ARetryCount: cardinal; ACounterValue: cardinal)
      : TMQTTPacket;
    procedure DelPacket(AAnID: Word);
    function GetPacket(AAnID: Word): TMQTTPacket;
    procedure Remove(APacket: TMQTTPacket);
    property List: TList<TMQTTPacket> read FList;
    property Stamp: TDateTime read FStamp write FStamp;
  end;

implementation

uses
  System.SysUtils;

{ TMQTTPacketStore }

function TMQTTPacketStore.AddPacket(APacketID: Word; AMessageStream: TMemoryStream; ARetryCount: cardinal;
  ACounterValue: cardinal): TMQTTPacket;
begin
  // Create a new TMQTTPacket instance
  Result := TMQTTPacket.Create;

  // Set packet properties
  Result.ID := APacketID;
  Result.Counter := ACounterValue;
  Result.Retries := ARetryCount;

  // Reset the message stream position to the beginning
  AMessageStream.Seek(0, soFromBeginning);

  // Copy message content from the provided stream to the packet
  Result.Msg.CopyFrom(AMessageStream, AMessageStream.Size);

  // Add the packet to the packet store's list
  FList.Add(Result);
end;

procedure TMQTTPacketStore.Assign(AFrom: TMQTTPacketStore);
var
  i: integer;
  APacket, bPacket: TMQTTPacket;
begin
  Clear;
  for i := 0 to AFrom.Count - 1 do
  begin
    APacket := AFrom[i];
    bPacket := TMQTTPacket.Create;
    bPacket.Assign(APacket);
    FList.Add(bPacket);
  end;
end;

procedure TMQTTPacketStore.Clear;
var
  lPacket: TMQTTPacket;
begin
  for lPacket in FList do
    lPacket.DisposeOf;
end;

function TMQTTPacketStore.Count: integer;
begin
  Result := FList.Count;
end;

constructor TMQTTPacketStore.Create;
begin
  FStamp := Now;
  FList := TList<TMQTTPacket>.Create;
end;

procedure TMQTTPacketStore.DelPacket(AAnID: Word);
var
  i: integer;
  APacket: TMQTTPacket;
begin
  for i := FList.Count - 1 downto 0 do
  begin
    APacket := FList[i];
    if APacket.ID = AAnID then
    begin
      FList.Remove(APacket);
      APacket.DisposeOf;
      exit;
    end;
  end;
end;

destructor TMQTTPacketStore.Destroy;
begin
  Clear;
  FList.DisposeOf;
  inherited;
end;

function TMQTTPacketStore.GetItem(AIndex: integer): TMQTTPacket;
begin
  if (AIndex >= 0) and (AIndex < Count) then
    Result := FList[AIndex]
  else
    Result := nil;
end;

function TMQTTPacketStore.GetPacket(AAnID: Word): TMQTTPacket;
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

procedure TMQTTPacketStore.Remove(APacket: TMQTTPacket);
begin
  FList.Remove(APacket);
end;

procedure TMQTTPacketStore.SetItem(AIndex: integer; const Value: TMQTTPacket);
begin
  if (AIndex >= 0) and (AIndex < Count) then
    FList[AIndex] := Value;
end;

end.
