unit MQTT.Headers.SubscribeVar;

interface

uses
  System.SysUtils,
  MQTT.Headers.Variable;

type

  TMQTTSubscribeVarHeader = class(TMQTTVariableHeader)
  private
    FMessageID: Integer;
    function GetMessageID: Integer;
    procedure SetMessageID(const Value: Integer);
  public
    constructor Create(AMessageID: Integer); overload;
    property MessageID: Integer read GetMessageID write SetMessageID;
    function ToBytes: TBytes; override;
  end;

implementation

uses
  MQTT.Utils;

{ TMQTTSubscribeVarHeader }

constructor TMQTTSubscribeVarHeader.Create(AMessageID: Integer);
begin
  inherited Create;
  FMessageID := AMessageID;
end;

function TMQTTSubscribeVarHeader.GetMessageID: Integer;
begin
  Result := FMessageID;
end;

procedure TMQTTSubscribeVarHeader.SetMessageID(const Value: Integer);
begin
  FMessageID := Value;
end;

function TMQTTSubscribeVarHeader.ToBytes: TBytes;
begin
  ClearField;
  AddField(TMQTTUtils.IntToMSBLSB(FMessageID));
  Result := FBytes;
end;

end.
