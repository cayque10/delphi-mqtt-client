unit MQTTReadThread;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  SyncObjs,
  IdTCPClient,
  IdGlobal,
  MQTT.Events,
  MQTT.Headers.RecvState;

type
  TMQTTRecvUtilities = class
  public
    class function MSBLSBToInt(ALengthBytes: TBytes): integer;
    class function RLBytesToInt(ARlBytes: TBytes): integer;
  end;

  TUnparsedMsg = record
  public
    FixedHeader: Byte;
    RL: TBytes;
    Data: TBytes;
  end;

  TMQTTReadThread = class(TThread)
  private
    { Private declarations }
    FLink: TIdTCPClient;
    FCriticalSection: TCriticalSection;
    FCurrentMsg: TUnparsedMsg;
    FCurrentRecvState: TMQTTRecvState;

    // Events
    FConnAckEvent: TConnAckEvent;
    FPublishEvent: TPublishEvent;
    FPingRespEvent: TPingRespEvent;
    FPingReqEvent: TPingReqEvent;
    FSubAckEvent: TSubAckEvent;
    FUnSubAckEvent: TUnSubAckEvent;
    FPubAckEvent: TPubAckEvent;
    FPubRelEvent: TPubRelEvent;
    FPubRecEvent: TPubRecEvent;
    FPubCompEvent: TPubCompEvent;

    procedure ProcessMessage;
    function readSingleString(const ADataStream: TBytes; const AIndexStartAt: integer; var AStringRead: string)
      : integer;
    function readStringWithoutPrefix(const ADataStream: TBytes; const AIndexStartAt: integer;
      var AStringRead: string): integer;
    procedure SynchronizeEvent(const pEvent: TProc);
    procedure ProcessPingResp;
    procedure ProcessPingReq;
    procedure ProcessConnAck;
    procedure ProcessPublish;
    procedure ProcessSubAck;
    procedure ProcessUnSubAck;
    procedure ProcessPubRec;
    procedure ProcessPubRel;
    procedure ProcessPubAck;
    procedure ProcessPubComp;
  protected
    procedure CleanStart;
    procedure Execute; override;
  public
    // ==============================================================================
    // HammerOh
    constructor Create(var ASocket: TIdTCPClient; var ACSSock: TCriticalSection);
    destructor Destroy; override;
    // ==============================================================================

    // Event properties.
    property OnConnAck: TConnAckEvent read FConnAckEvent write FConnAckEvent;
    property OnPublish: TPublishEvent read FPublishEvent write FPublishEvent;
    property OnPingResp: TPingRespEvent read FPingRespEvent write FPingRespEvent;
    property OnPingReq: TPingRespEvent read FPingRespEvent write FPingRespEvent;
    property OnSubAck: TSubAckEvent read FSubAckEvent write FSubAckEvent;
    property OnUnSubAck: TUnSubAckEvent read FUnSubAckEvent write FUnSubAckEvent;
    property OnPubAck: TUnSubAckEvent read FUnSubAckEvent write FUnSubAckEvent;
    property OnPubRec: TUnSubAckEvent read FUnSubAckEvent write FUnSubAckEvent;
    property OnPubRel: TUnSubAckEvent read FUnSubAckEvent write FUnSubAckEvent;
    property OnPubComp: TUnSubAckEvent read FUnSubAckEvent write FUnSubAckEvent;
  end;

implementation

uses
  MQTT.Headers.Types;

class function TMQTTRecvUtilities.MSBLSBToInt(ALengthBytes: TBytes): integer;
begin
  Assert(ALengthBytes <> nil, 'O método não pode receber valor nulo');
  Assert(Length(ALengthBytes) = 2, 'The MSB-LSB 2 bytes structure must be 2 Bytes in length');
  Result := ALengthBytes[0] shl 8;
  Result := Result + ALengthBytes[1];
end;

class function TMQTTRecvUtilities.RLBytesToInt(ARlBytes: TBytes): integer;
var
  lMulti: integer;
  i: integer;
  lDigit: Byte;
begin
  Assert(ARlBytes <> nil, 'O método não pode receber valor nulo');

  lMulti := 1;
  i := 0;
  Result := 0;

  if ((Length(ARlBytes) > 0) and (Length(ARlBytes) <= 4)) then
  begin
    lDigit := ARlBytes[i];
    repeat
      // lDigit := ARlBytes[i];
      Result := Result + (lDigit and 127) * lMulti;
      lMulti := lMulti * 128;
      // Inc(i);
    until ((lDigit and 128) = 0);
  end;
end;

procedure AppendBytes(var DestArray: TBytes; const NewBytes: TBytes);
var
  lDestLen: integer;
begin
  if Length(NewBytes) > 0 then
  begin
    lDestLen := Length(DestArray);
    SetLength(DestArray, lDestLen + Length(NewBytes));
    Move(NewBytes[0], DestArray[lDestLen], Length(NewBytes));
  end;
end;

{ TMQTTReadThread }

procedure TMQTTReadThread.CleanStart;
begin
  FCurrentRecvState := TMQTTRecvState.FixedHeaderByte;
end;

constructor TMQTTReadThread.Create(var ASocket: TIdTCPClient; var ACSSock: TCriticalSection);
begin
  inherited Create(false);

  FLink := ASocket;
  FCriticalSection := ACSSock;
  FreeOnTerminate := false;

  CleanStart;
end;

destructor TMQTTReadThread.Destroy;
begin

  inherited;
end;

procedure TMQTTReadThread.ProcessPubComp;
begin
  begin
    if Length(FCurrentMsg.Data) = 2 then
    begin
      if Assigned(FPubCompEvent) then
        SynchronizeEvent(
          procedure
          begin
            OnPubComp(Self, TMQTTRecvUtilities.MSBLSBToInt(FCurrentMsg.Data));
          end);
    end;
  end;
end;

procedure TMQTTReadThread.ProcessPubAck;
begin
  begin
    if Length(FCurrentMsg.Data) = 2 then
    begin
      if Assigned(FPubAckEvent) then
        SynchronizeEvent(
          procedure
          begin
            OnPubAck(Self, TMQTTRecvUtilities.MSBLSBToInt(FCurrentMsg.Data));
          end);
    end;
  end;
end;

procedure TMQTTReadThread.ProcessPubRel;
begin
  begin
    if Length(FCurrentMsg.Data) = 2 then
    begin
      if Assigned(FPubRelEvent) then
        SynchronizeEvent(
          procedure
          begin
            OnPubRel(Self, TMQTTRecvUtilities.MSBLSBToInt(FCurrentMsg.Data));
          end);

    end;
  end;
end;

procedure TMQTTReadThread.ProcessPubRec;
begin
  begin
    if Length(FCurrentMsg.Data) = 2 then
    begin
      if Assigned(FPubRecEvent) then
        SynchronizeEvent(
          procedure
          begin
            OnPubRec(Self, TMQTTRecvUtilities.MSBLSBToInt(FCurrentMsg.Data));
          end);
    end;
  end;
end;

procedure TMQTTReadThread.ProcessUnSubAck;
begin
  begin
    if Length(FCurrentMsg.Data) = 2 then
    begin
      if Assigned(FUnSubAckEvent) then
        SynchronizeEvent(
          procedure
          begin
            OnUnSubAck(Self, TMQTTRecvUtilities.MSBLSBToInt(FCurrentMsg.Data));
          end);
    end;
  end;
end;

procedure TMQTTReadThread.ProcessPublish;
var
  lTopic: string;
  lPayload: string;
  lDataCaret: integer;
begin
  lDataCaret := 0;

  // Todo: This only applies for QoS level 0 messages.
  lDataCaret := readSingleString(FCurrentMsg.Data, lDataCaret, lTopic);
  readStringWithoutPrefix(FCurrentMsg.Data, lDataCaret, lPayload);
  if Assigned(FPublishEvent) then
    SynchronizeEvent(
      procedure
      begin
        OnPublish(Self, UTF8Encode(lTopic), UTF8Encode(lPayload));
      end);
end;

procedure TMQTTReadThread.ProcessSubAck;
var
  lQrantedQoS: Array of integer;
  i: integer;
begin
  if (Length(FCurrentMsg.Data) > 2) then
  begin
    SetLength(lQrantedQoS, Length(FCurrentMsg.Data) - 2);
    for i := 0 to Length(lQrantedQoS) - 1 do
    begin
      lQrantedQoS[i] := FCurrentMsg.Data[i + 2];
    end;

    if Assigned(FSubAckEvent) then
      SynchronizeEvent(
        procedure
        begin
          OnSubAck(Self, TMQTTRecvUtilities.MSBLSBToInt(Copy(FCurrentMsg.Data, 0, 2)), lQrantedQoS);
        end);
  end;
end;

procedure TMQTTReadThread.ProcessPingReq;
begin
  if Assigned(FPingReqEvent) then
    SynchronizeEvent(
      procedure
      begin
        OnPingReq(Self);
      end);
end;

procedure TMQTTReadThread.ProcessPingResp;
begin
  if Assigned(FPingRespEvent) then
  begin
    SynchronizeEvent(
      procedure
      begin
        OnPingResp(Self);
      end);
  end;
end;

procedure TMQTTReadThread.Execute;
var
  lCurrentMessage: TUnparsedMsg;
  lRLInt: integer;
  lBuffer: TBytes;
  i: integer;
  lSize: integer;
  lIndyBuffer: TIdBytes;
  lCount: integer;
  lIndex: integer;
begin
  lRLInt := 0;
  lIndex := 0;
  lCount := 0;

  while not Terminated do
  begin
    FCriticalSection.Acquire;
    try
      if FLink.IOHandler.CheckForDataOnSource(1000) then
        if not FLink.IOHandler.InputBufferIsEmpty then
        begin
          lSize := FLink.IOHandler.InputBuffer.Size;
          lIndyBuffer := nil;
          FLink.IOHandler.ReadBytes(lIndyBuffer, lSize);
          for i := 0 to lSize - 1 do
          begin
            case FCurrentRecvState of
              TMQTTRecvState.FixedHeaderByte:
                begin
                  lCurrentMessage.FixedHeader := 0;
                  lCurrentMessage.FixedHeader := lIndyBuffer[i];
                  if (lCurrentMessage.FixedHeader <> 0) then
                    FCurrentRecvState := TMQTTRecvState.RemainingLength;
                end;

              TMQTTRecvState.RemainingLength:
                begin
                  lRLInt := 0;
                  SetLength(lCurrentMessage.RL, 1);
                  SetLength(lBuffer, 1);
                  lCurrentMessage.RL[0] := lIndyBuffer[i];
                  if lCurrentMessage.RL[0] = 0 then
                  begin
                    FCurrentMsg := lCurrentMessage;
                    ProcessMessage;
                    lCurrentMessage := Default (TUnparsedMsg);
                    FCurrentRecvState := TMQTTRecvState.FixedHeaderByte;
                  end
                  else
                  begin
                    FCurrentRecvState := TMQTTRecvState.RemainingLength1;
                    lIndex := 0;
                  end;
                end;

              TMQTTRecvState.RemainingLength1:
                begin
                  if ((lCurrentMessage.RL[lIndex] and 128) <> 0) then
                  begin
                    lBuffer[0] := lIndyBuffer[i];
                    AppendBytes(lCurrentMessage.RL, lBuffer);
                    Inc(lIndex);
                  end
                  else
                  begin
                    lIndex := 5;
                  end;

                  if (lIndex = 4) or (lIndex = 5) then
                  begin
                    lRLInt := TMQTTRecvUtilities.RLBytesToInt(lCurrentMessage.RL);
                    if lRLInt > 0 then
                    begin
                      SetLength(lCurrentMessage.Data, lRLInt);
                      lCount := 0;
                      if lIndex = 5 then
                      begin
                        lCurrentMessage.Data[lCount] := lIndyBuffer[i];
                        Inc(lCount);
                      end;
                      FCurrentRecvState := TMQTTRecvState.Data;
                    end
                    else
                    begin
                      FCurrentMsg := lCurrentMessage;
                      ProcessMessage;
                      lCurrentMessage := Default (TUnparsedMsg);
                      FCurrentRecvState := TMQTTRecvState.FixedHeaderByte;
                    end;
                  end;
                end;

              TMQTTRecvState.Data:
                begin
                  lCurrentMessage.Data[lCount] := lIndyBuffer[i];
                  Inc(lCount);
                  if lCount = lRLInt then
                  begin
                    FCurrentMsg := lCurrentMessage;
                    ProcessMessage;
                    lCurrentMessage := Default (TUnparsedMsg);
                    FCurrentRecvState := TMQTTRecvState.FixedHeaderByte;
                  end;
                end;
            end;
          end;
        end;
    finally
      FCriticalSection.Release;
    end;
  end;
end;

procedure TMQTTReadThread.ProcessConnAck;
begin
  if Length(FCurrentMsg.Data) > 0 then
  begin
    if Assigned(FConnAckEvent) then
      SynchronizeEvent(
        procedure
        begin
          OnConnAck(Self, FCurrentMsg.Data[0])
        end);
  end;
end;

procedure TMQTTReadThread.ProcessMessage;
var
  lHCode: Byte;
begin
  lHCode := FCurrentMsg.FixedHeader shr 4;

  case lHCode of
    Ord(TMQTTMessageType.mtCONNACK):
      ProcessConnAck;
    Ord(TMQTTMessageType.mtPINGREQ):
      ProcessPingReq;
    Ord(TMQTTMessageType.mtPINGRESP):
      ProcessPingResp;
    Ord(TMQTTMessageType.mtPUBLISH):
      ProcessPublish;
    Ord(TMQTTMessageType.mtSUBACK):
      ProcessSubAck;
    Ord(TMQTTMessageType.mtUNSUBACK):
      ProcessUnSubAck;
    Ord(TMQTTMessageType.mtPUBREC):
      ProcessPubRec;
    Ord(TMQTTMessageType.mtPUBREL):
      ProcessPubRel;
    Ord(TMQTTMessageType.mtPUBACK):
      ProcessPubAck;
    Ord(TMQTTMessageType.mtPUBCOMP):
      ProcessPubComp;
  end;
end;

function TMQTTReadThread.readStringWithoutPrefix(const ADataStream: TBytes; const AIndexStartAt: integer;
var AStringRead: string): integer;
var
  lLength: integer;
begin
  lLength := Length(ADataStream) - (AIndexStartAt + 1);
  if lLength > 0 then
  begin
    AStringRead := TEncoding.UTF8.GetString(ADataStream, AIndexStartAt + 2, lLength - 1);
  end;
  Result := AIndexStartAt + lLength;
end;

procedure TMQTTReadThread.SynchronizeEvent(const pEvent: TProc);
begin
  TThread.Synchronize(TThread.Current,
    procedure
    begin
      pEvent;
    end);
end;

function TMQTTReadThread.readSingleString(const ADataStream: TBytes; const AIndexStartAt: integer;
var AStringRead: string): integer;
var
  lLength: integer;
begin
  lLength := TMQTTRecvUtilities.MSBLSBToInt(Copy(ADataStream, AIndexStartAt, 2));
  if lLength > 0 then
  begin
    AStringRead := TEncoding.UTF8.GetString(ADataStream, AIndexStartAt + 2, lLength);
  end;
  Result := AIndexStartAt + lLength;
end;

end.
