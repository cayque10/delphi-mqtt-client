unit MQTT.Headers.PublishVar;

interface

uses
  MQTT.Headers.Variable,
  System.SysUtils;

type

  TMQTTPublishVarHeader = class(TMQTTVariableHeader)
  private
    FTopic: UTF8String;
    FQoSLevel: Integer;
    FMessageID: Integer;
    function GetMessageID: Integer;
    function GetQoSLevel: Integer;
    procedure SetMessageID(const Value: Integer);
    procedure SetQoSLevel(const Value: Integer);
    function GetTopic: UTF8String;
    procedure SetTopic(const Value: UTF8String);
    procedure rebuildHeader;
  public
    constructor Create(QoSLevel: Integer); overload;
    property MessageID: Integer read GetMessageID write SetMessageID;
    property QoSLevel: Integer read GetQoSLevel write SetQoSLevel;
    property topic: UTF8String read GetTopic write SetTopic;
    function ToBytes: TBytes; override;
  end;

implementation

uses
  MQTT.Utils;

{ TMQTTPublishVarHeader }

constructor TMQTTPublishVarHeader.Create(QoSLevel: Integer);
begin
  inherited Create;
  FQoSLevel := QoSLevel;
end;

function TMQTTPublishVarHeader.GetMessageID: Integer;
begin
  Result := FMessageID;
end;

function TMQTTPublishVarHeader.GetQoSLevel: Integer;
begin
  Result := FQoSLevel;
end;

function TMQTTPublishVarHeader.GetTopic: UTF8String;
begin
  Result := FTopic;
end;

procedure TMQTTPublishVarHeader.rebuildHeader;
begin
  ClearField;
  AddField(TMQTTUtils.UTF8EncodeToBytes(FTopic));
  if (FQoSLevel > 0) then
  begin
    AddField(TMQTTUtils.IntToMSBLSB(FMessageID));
  end;
end;

procedure TMQTTPublishVarHeader.SetMessageID(const Value: Integer);
begin
  FMessageID := Value;
end;

procedure TMQTTPublishVarHeader.SetQoSLevel(const Value: Integer);
begin
  FQoSLevel := Value;
end;

procedure TMQTTPublishVarHeader.SetTopic(const Value: UTF8String);
begin
  FTopic := Value;
end;

function TMQTTPublishVarHeader.ToBytes: TBytes;
begin
  Self.rebuildHeader;
  Result := Self.FBytes;
end;

end.
