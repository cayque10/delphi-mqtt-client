unit MQTT.Message;

interface

uses
  MQTT.Types;

type
  TMQTTMessage = class
  private
    FID: Word;
    FStamp: TDateTime;
    FLastUsed: TDateTime;
    FQos: TMQTTQOSType;
    FRetained: Boolean;
    FCounter: cardinal;
    FRetries: integer;
    FTopic: UTF8String;
    FMessage: String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(AFrom: TMQTTMessage);
    property Id: Word read FID write FID;
    property Stamp: TDateTime read FStamp write FStamp;
    property LastUsed: TDateTime read FLastUsed write FLastUsed;
    property QoS: TMQTTQOSType read FQos write FQos;
    property Retained: Boolean read FRetained write FRetained;
    property Counter: cardinal read FCounter write FCounter;
    property Retries: integer read FRetries write FRetries;
    property Topic: UTF8String read FTopic write FTopic;
    property &Message: String read FMessage write FMessage;

  end;

implementation

uses
  System.SysUtils;

{ TMQTTMessage }

procedure TMQTTMessage.Assign(AFrom: TMQTTMessage);
begin
  FID := AFrom.FID;
  FStamp := AFrom.FStamp;
  FLastUsed := AFrom.FLastUsed;
  FRetained := AFrom.FRetained;
  FCounter := AFrom.FCounter;
  FRetries := AFrom.FRetries;
  FTopic := AFrom.FTopic;
  FMessage := AFrom.Message;
  FQos := AFrom.FQos;
end;

constructor TMQTTMessage.Create;
begin
  FID := 0;
  FStamp := Now;
  FLastUsed := FStamp;
  FRetained := false;
  FCounter := 0;
  FRetries := 0;
  FQos := qtAT_MOST_ONCE;
  FTopic := '';
  FMessage := '';
end;

destructor TMQTTMessage.Destroy;
begin
  inherited;
end;

end.
