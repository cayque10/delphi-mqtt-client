unit MQTT.Headers.UnsubscribeVar;

interface

uses
  MQTT.Headers.Variable,
  System.SysUtils;

type

  TMQTTUnsubscribeVarHeader = class(TMQTTVariableHeader)
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

{ TMQTTUnsubscribeVarHeader }

constructor TMQTTUnsubscribeVarHeader.Create(AMessageID: Integer);
begin
  inherited Create;
  FMessageID := MessageID;
end;

function TMQTTUnsubscribeVarHeader.GetMessageID: Integer;
begin
  Result := FMessageID;
end;

procedure TMQTTUnsubscribeVarHeader.SetMessageID(const Value: Integer);
begin
  FMessageID := Value;
end;

function TMQTTUnsubscribeVarHeader.ToBytes: TBytes;
begin
  ClearField;
  AddField(TMQTTUtils.IntToMSBLSB(FMessageID));
  Result := FBytes;
end;

end.
