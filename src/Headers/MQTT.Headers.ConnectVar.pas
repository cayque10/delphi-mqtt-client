unit MQTT.Headers.ConnectVar;

interface

uses
  MQTT.Headers.Variable,
  MQTT.Headers.ConnectFlags,
  System.SysUtils;

type

  TMQTTConnectVarHeader = class(TMQTTVariableHeader)
  const
    PROTOCOL_ID = 'MQIsdp';
    PROTOCOL_VER = 3;
  private
    FConnectFlags: TMQTTConnectFlags;
    FKeepAlive: Integer;
    function rebuildHeader: boolean;
    procedure setupDefaultValues;
    function GetCleanStart: Integer;
    function GetQoSLevel: Integer;
    function GetRetain: Integer;
    procedure SetCleanStart(const Value: Integer);
    procedure SetQoSLevel(const Value: Integer);
    procedure SetRetain(const Value: Integer);
    function GetWillFlag: Integer;
    procedure SetWillFlag(const Value: Integer);
    function GetUsername: Integer;
    procedure SetUsername(const Value: Integer);
    function GetPassword: Integer;
    procedure SetPassword(const Value: Integer);
  public
    constructor Create(AKeepAlive: Integer); overload;
    constructor Create; overload;
    constructor Create(ACleanStart: boolean); overload;
    property KeepAlive: Integer read FKeepAlive write FKeepAlive;
    property CleanStart: Integer read GetCleanStart write SetCleanStart;
    property QoSLevel: Integer read GetQoSLevel write SetQoSLevel;
    property Retain: Integer read GetRetain write SetRetain;
    property UserName: Integer read GetUsername write SetUsername;
    property Password: Integer read GetPassword write SetPassword;
    property WillFlag: Integer read GetWillFlag write SetWillFlag;
    function ToBytes: TBytes; override;
  end;

implementation

uses
  MQTT.Utils;

{ TMQTTConnectVarHeader }

constructor TMQTTConnectVarHeader.Create(ACleanStart: boolean);
begin
  inherited Create;
  setupDefaultValues;
  Self.FConnectFlags.CleanStart := Ord(ACleanStart);
end;

function TMQTTConnectVarHeader.GetCleanStart: Integer;
begin
  Result := Self.FConnectFlags.CleanStart;
end;

function TMQTTConnectVarHeader.GetPassword: Integer;
begin
  Result := Self.FConnectFlags.Password;
end;

function TMQTTConnectVarHeader.GetQoSLevel: Integer;
begin
  Result := Self.FConnectFlags.WillQoS;
end;

function TMQTTConnectVarHeader.GetRetain: Integer;
begin
  Result := Self.FConnectFlags.WillRetain;
end;

function TMQTTConnectVarHeader.GetUsername: Integer;
begin
  Result := Self.FConnectFlags.UserName;
end;

function TMQTTConnectVarHeader.GetWillFlag: Integer;
begin
  Result := Self.FConnectFlags.WillFlag;
end;

constructor TMQTTConnectVarHeader.Create(AKeepAlive: Integer);
begin
  inherited Create;
  setupDefaultValues;
  Self.FKeepAlive := AKeepAlive;
end;

constructor TMQTTConnectVarHeader.Create;
begin
  inherited Create;
  setupDefaultValues;
end;

function TMQTTConnectVarHeader.rebuildHeader: boolean;
begin
  Result := true;
  try
    ClearField;
    AddField(TMQTTUtils.UTF8EncodeToBytes(Self.PROTOCOL_ID));
    AddField(Byte(Self.PROTOCOL_VER));
    AddField(FConnectFlags.Flags);
    AddField(TMQTTUtils.IntToMSBLSB(FKeepAlive));
  except
    Result := false;
  end;
end;

procedure TMQTTConnectVarHeader.setupDefaultValues;
begin
  Self.FConnectFlags.Flags := 0;
  Self.FConnectFlags.CleanStart := 1;
  Self.FConnectFlags.WillQoS := 1;
  Self.FConnectFlags.WillRetain := 0;
  Self.FConnectFlags.WillFlag := 1;
  Self.FConnectFlags.UserName := 0;
  Self.FConnectFlags.Password := 0;
  Self.FKeepAlive := 10;
end;

procedure TMQTTConnectVarHeader.SetCleanStart(const Value: Integer);
begin
  Self.FConnectFlags.CleanStart := Value;
end;

procedure TMQTTConnectVarHeader.SetPassword(const Value: Integer);
begin
  Self.FConnectFlags.UserName := Value;
end;

procedure TMQTTConnectVarHeader.SetQoSLevel(const Value: Integer);
begin
  Self.FConnectFlags.WillQoS := Value;
end;

procedure TMQTTConnectVarHeader.SetRetain(const Value: Integer);
begin
  Self.FConnectFlags.WillRetain := Value;
end;

procedure TMQTTConnectVarHeader.SetUsername(const Value: Integer);
begin
  Self.FConnectFlags.Password := Value;
end;

procedure TMQTTConnectVarHeader.SetWillFlag(const Value: Integer);
begin
  Self.FConnectFlags.WillFlag := Value;
end;

function TMQTTConnectVarHeader.ToBytes: TBytes;
begin
  Self.rebuildHeader;
  Result := FBytes;
end;

end.
