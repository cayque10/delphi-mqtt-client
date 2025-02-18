unit MQTT.Headers.Message;

interface

uses
  System.SysUtils,
  MQTT.Headers.Fixed,
  MQTT.Headers.Variable,
  MQTT.Headers.Payload;

type

  TMQTTMessage = class
  private
    FRemainingLength: Integer;
  public
    FixedHeader: TMQTTFixedHeader;
    VariableHeader: TMQTTVariableHeader;
    Payload: TMQTTPayload;
    constructor Create;
    destructor Destroy; override;
    function ToBytes: TBytes;
    property RemainingLength: Integer read FRemainingLength;
  end;

implementation

uses
  MQTT.Utils;

{ TMQTTMessage }

constructor TMQTTMessage.Create;
begin
  inherited;
  // Fill our Fixed Header with Zeros to wipe any unintended noise.
  // FillChar(FixedHeader, SizeOf(FixedHeader), #0);
end;

destructor TMQTTMessage.Destroy;
begin
  if Assigned(VariableHeader) then
    VariableHeader.Free;
  if Assigned(Payload) then
    Payload.Free;
  inherited;
end;

function TMQTTMessage.ToBytes: TBytes;
var
  lRemainingLength: Integer;
  lRemainingLengthBytes: TBytes;
begin
  lRemainingLength := 0;
  if Assigned(VariableHeader) then
    lRemainingLength := lRemainingLength + Length(VariableHeader.ToBytes);
  if Assigned(Payload) then
    lRemainingLength := lRemainingLength + Length(Payload.ToBytes);

  FRemainingLength := lRemainingLength;
  lRemainingLengthBytes := TMQTTUtils.RLIntToBytes(FRemainingLength);

  TMQTTUtils.AppendToByteArray(FixedHeader.Flags, Result);
  TMQTTUtils.AppendToByteArray(lRemainingLengthBytes, Result);
  if Assigned(VariableHeader) then
    TMQTTUtils.AppendToByteArray(VariableHeader.ToBytes, Result);
  if Assigned(Payload) then
    TMQTTUtils.AppendToByteArray(Payload.ToBytes, Result);
end;

end.
