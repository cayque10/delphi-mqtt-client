unit uMQTTSession;

interface

uses
  uMQTTPacketStore,
  uMQTTMessageStore;

type
  TMQTTSession = class
  private
    FClientID: UTF8String;
    FStamp: TDateTime;
    FInFlight: TMQTTPacketStore;
    FReleasables: TMQTTMessageStore;
  public
    constructor Create;
    destructor Destroy; override;
    property ClientID: UTF8String read FClientID write FClientID;
    property Stamp: TDateTime read FStamp;
    property InFlight: TMQTTPacketStore read FInFlight;
    property Releasables: TMQTTMessageStore read FReleasables;
  end;

implementation

uses
  System.SysUtils;

{ TMQTTSession }

constructor TMQTTSession.Create;
begin
  FClientID := '';
  FStamp := Now;
  FInFlight := TMQTTPacketStore.Create;
  FReleasables := TMQTTMessageStore.Create;
end;

destructor TMQTTSession.Destroy;
begin
  FInFlight.Free;
  //FReleasables.Clear;
  FReleasables.Free;
  inherited;
end;

end.
