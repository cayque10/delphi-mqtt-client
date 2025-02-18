unit MQTT.Client;

interface

uses
  Classes,
  IdTCPClient,
  IdSSLOpenSSL,
  MQTT.Read.Thread,
  System.SyncObjs,
  Fmx.Types,
  MQTT.Message.Store,
  MQTT.Packet.Store,
  System.Generics.Collections,
  MQTT.Subscription,
  MQTT.Events,
  MQTT.Types,
  MQTT.Parser;

(* Web Sites
  http://www.alphaworks.ibm.com/tech/rsmb
  http://www.mqtt.org

  Permission to copy and display the MQ Telemetry Transport specification (the
  "Specification"), in any medium without fee or royalty is hereby granted by Eurotech
  and International Business Machines Corporation (IBM) (collectively, the "Authors"),
  provided that you include the following on ALL copies of the Specification, or portions
  thereof, that you make:
  A link or URL to the Specification at one of
  1. the Authors' websites.
  2. The copyright notice as shown in the Specification.

  The Authors each agree to grant you a royalty-free license, under reasonable,
  non-discriminatory terms and conditions to their respective patents that they deem
  necessary to implement the Specification. THE SPECIFICATION IS PROVIDED "AS IS,"
  AND THE AUTHORS MAKE NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR
  IMPLIED, INCLUDING, BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, OR TITLE; THAT THE
  CONTENTS OF THE SPECIFICATION ARE SUITABLE FOR ANY PURPOSE; NOR THAT THE
  IMPLEMENTATION OF SUCH CONTENTS WILL NOT INFRINGE ANY THIRD PARTY
  PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS. THE AUTHORS WILL NOT
  BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL
  DAMAGES ARISING OUT OF OR RELATING TO ANY USE OR DISTRIBUTION OF THE
  SPECIFICATION *)

const
  AllCurrentPlatforms = pidWin32 or pidAndroidArm32 or pidAndroidArm64;

type

  [ComponentPlatforms(AllCurrentPlatforms)]
  TMQTTClient = class(TComponent)
  private
    FUsername, FPassword: UTF8String;
    FMessageID: Word;
    FHost: string;
    FPort: integer;
    FOnMon: TMQTTMonEvent;
    FOnOnline: TNotifyEvent;
    FOnOffline: TMQTTDisconnectEvent;
    FOnMsg: TMQTTMsgEvent;
    FOnFailure: TMQTTFailureEvent;
    FLocalBounce: Boolean;
    FAutoSubscribe: Boolean;
    FOnClientID: TMQTTClientIDEvent;
    FLink: TIdTCPClient;
    FIdHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
    FParser: TMQTTParser;
    FInFlight: TMQTTPacketStore;
    FReleasables: TMQTTMessageStore;
    FSubscriptions: TObjectList<TMQTTSubscription>;
    FRecvThread: TMQTTReadThread;
    FCriticalSection: TCriticalSection;
    FKeepAliveTimer: TTimer;

    // Event Fields
    FConnAckEvent: TConnAckEvent;
    FPublishEvent: TPublishEvent;
    FPingRespEvent: TPingRespEvent;
    FSubAckEvent: TSubAckEvent;
    FUnSubAckEvent: TUnSubAckEvent;
    FPubAckEvent: TPubAckEvent;
    FPubRelEvent: TPubRelEvent;
    FPubRecEvent: TPubRecEvent;
    FPubCompEvent: TPubCompEvent;

    procedure DoSend(Sender: TObject; anID: Word; aRetry: integer; aStream: TMemoryStream);

    procedure OnConnected(Sender: TObject);
    procedure OnDisconnected(Sender: TObject);

    function GetClientID: UTF8String;
    procedure SetClientID(const Value: UTF8String);
    function GetKeepAlive: Word;
    procedure SetKeepAlive(const Value: Word);
    function GetMaxRetries: integer;
    procedure SetMaxRetries(const Value: integer);
    function GetRetryTime: cardinal;
    procedure SetRetryTime(const Value: cardinal);
    function GetClean: Boolean;
    procedure SetClean(const Value: Boolean);
    function GetPassword: UTF8String;
    function GetUsername: UTF8String;
    procedure SetPassword(const Value: UTF8String);
    procedure SetUsername(const Value: UTF8String);
    procedure CreateAndResumeRecvThread(var ASocket: TIdTCPClient);

    // Recv Thread Event Handling Procedures.
    procedure GotConnAck(Sender: TObject; ReturnCode: integer);
    procedure GotPingResp(Sender: TObject);
    procedure GotSubAck(Sender: TObject; MessageID: integer; GrantedQoS: Array of integer);
    procedure GotUnSubAck(Sender: TObject; MessageID: integer);
    procedure GotPub(Sender: TObject; Topic, payload: UTF8String);
    procedure GotPubAck(Sender: TObject; MessageID: integer);
    procedure GotPubRec(Sender: TObject; MessageID: integer);
    procedure GotPubRel(Sender: TObject; MessageID: integer);
    procedure GotPubComp(Sender: TObject; MessageID: integer);
    procedure FinalizarRecThread;
    procedure KeepAliveTimerEvent(Sender: TObject);
    procedure ConfigureKeepAlive;

    procedure CheckConnection;

    function SubTopics(ATopic: UTF8String): TStringList;
    function IsSubscribed(ASubscription, ATopic: UTF8String): Boolean;
  public
    function Online: Boolean;
    function NextMessageID: Word;
    procedure Subscribe(ATopic: UTF8String; AQos: TMQTTQOSType); overload;
    procedure Unsubscribe(ATopic: UTF8String); overload;
    procedure Ping;
    procedure Publish(ATopic: UTF8String; aMessage: String; AQos: TMQTTQOSType; aRetain: Boolean);
    procedure SetWill(ATopic, aMessage: UTF8String; AQos: TMQTTQOSType; aRetain: Boolean = false);
    procedure Mon(aStr: string);
    procedure Connect;
    procedure Disconnect;

    property Parser: TMQTTParser read FParser;
    property Subscriptions: TObjectList<TMQTTSubscription> read FSubscriptions;
    property InFlight: TMQTTPacketStore read FInFlight;
    property Releasables: TMQTTMessageStore read FReleasables;

    // Event Handlers
    property OnConnAck: TConnAckEvent read FConnAckEvent write FConnAckEvent;
    property OnPublish: TPublishEvent read FPublishEvent write FPublishEvent;
    property OnPingResp: TPingRespEvent read FPingRespEvent write FPingRespEvent;
    property OnPingReq: TPingRespEvent read FPingRespEvent write FPingRespEvent;
    property OnSubAck: TSubAckEvent read FSubAckEvent write FSubAckEvent;
    property OnUnSubAck: TUnSubAckEvent read FUnSubAckEvent write FUnSubAckEvent;
    property OnPubAck: TPubAckEvent read FPubAckEvent write FPubAckEvent;
    property OnPubRec: TPubRecEvent read FPubRecEvent write FPubRecEvent;
    property OnPubRel: TPubRelEvent read FPubRelEvent write FPubRelEvent;
    property OnPubComp: TPubCompEvent read FPubCompEvent write FPubCompEvent;

    constructor Create(anOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ClientID: UTF8String read GetClientID write SetClientID;
    property KeepAlive: Word read GetKeepAlive write SetKeepAlive;
    property MaxRetries: integer read GetMaxRetries write SetMaxRetries;
    property RetryTime: cardinal read GetRetryTime write SetRetryTime;
    property Clean: Boolean read GetClean write SetClean;
    property AutoSubscribe: Boolean read FAutoSubscribe write FAutoSubscribe;
    property Username: UTF8String read GetUsername write SetUsername;
    property Password: UTF8String read GetPassword write SetPassword;
    property Host: string read FHost write FHost;
    property Port: integer read FPort write FPort;
    property LocalBounce: Boolean read FLocalBounce write FLocalBounce;
    property OnClientID: TMQTTClientIDEvent read FOnClientID write FOnClientID;
    property OnMon: TMQTTMonEvent read FOnMon write FOnMon;
    property OnOnline: TNotifyEvent read FOnOnline write FOnOnline;
    property OnOffline: TMQTTDisconnectEvent read FOnOffline write FOnOffline;
    property OnFailure: TMQTTFailureEvent read FOnFailure write FOnFailure;
    property OnMsg: TMQTTMsgEvent read FOnMsg write FOnMsg;
  end;

procedure Register;

implementation

uses
  SysUtils,
  MQTT.Packet,
  MQTT.Headers.Types;

procedure Register;
begin
  RegisterComponents('MQTTClient', [TMQTTClient]);
end;

procedure SetDup(aStream: TMemoryStream; aState: Boolean);
var
  x: byte;
begin
  if aStream.Size = 0 then
    exit;
  aStream.Seek(0, soFromBeginning);
  aStream.Read(x, 1);
  x := (x and $F7) or (ord(aState) * $08);
  aStream.Seek(0, soFromBeginning);
  aStream.Write(x, 1);
end;

{ TMQTTClient }

procedure TMQTTClient.Connect;
begin
  if FLink.Connected then
    exit;

  Mon('Connecting to ' + Host + ' on Port ' + IntToStr(Port));

  ConfigureKeepAlive;

  FLink.Host := FHost;
  FLink.Port := FPort;

  FLink.Connect;
  if FLink.Connected then
  begin
    CreateAndResumeRecvThread(FLink);
    FKeepAliveTimer.Enabled := True;
  end;

end;

constructor TMQTTClient.Create(anOwner: TComponent);

begin
  inherited;
  FCriticalSection := TCriticalSection.Create;
  FSubscriptions := TObjectList<TMQTTSubscription>.Create;
  FReleasables := TMQTTMessageStore.Create;

  FKeepAliveTimer := TTimer.Create(nil);
  FKeepAliveTimer.Enabled := false;
  FKeepAliveTimer.OnTimer := KeepAliveTimerEvent;

  FLink := TIdTCPClient.Create(nil);
  FIdHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(FLink);
  FParser := TMQTTParser.Create;
  FInFlight := TMQTTPacketStore.Create;

  FHost := '';
  FUsername := '';
  FPassword := '';
  FPort := 1883;
  FLocalBounce := false;
  FAutoSubscribe := false;
  FMessageID := 0;
  FParser.OnSend := DoSend;
  FParser.KeepAlive := 30;
  FIdHandlerSocket.SSLOptions.Mode := sslmClient;
  FIdHandlerSocket.SSLOptions.Method := sslvTLSv1_2;
  FIdHandlerSocket.PassThrough := false;
  // TODO: pendente implementacao
  // LIdHandlerSocket.SSLOptions.CertFile := '';
  // LIdHandlerSocket.SSLOptions.KeyFile := '';
  // LIdHandlerSocket.SSLOptions.RootCertFile := '';
  FLink.IOHandler := FIdHandlerSocket;
  FLink.OnConnected := OnConnected;
  FLink.OnDisconnected := OnDisconnected;
end;

procedure TMQTTClient.CreateAndResumeRecvThread(var ASocket: TIdTCPClient);
begin
  FRecvThread := TMQTTReadThread.Create(ASocket, FCriticalSection);
  FRecvThread.OnConnAck := Self.GotConnAck;
  FRecvThread.OnPublish := Self.GotPub;
  FRecvThread.OnPingResp := Self.GotPingResp;
  FRecvThread.OnSubAck := Self.GotSubAck;
  FRecvThread.OnPubAck := Self.GotPubAck;
  FRecvThread.OnUnSubAck := Self.GotUnSubAck;
  FRecvThread.OnPubRec := Self.GotPubRec;
  FRecvThread.OnPubRel := Self.GotPubRel;
  FRecvThread.OnPubComp := Self.GotPubComp;
end;

destructor TMQTTClient.Destroy;
begin
  FKeepAliveTimer.Enabled := false;
  FinalizarRecThread;
  if Assigned(FRecvThread) then
    FRecvThread.Free;
  Disconnect;
  FReleasables.Free;
  FSubscriptions.Free;
  FInFlight.Free;
  FKeepAliveTimer.Free;
  FParser.Free;

  if Assigned(FLink) then
    FLink.Free;

  if Assigned(FCriticalSection) then
    FCriticalSection.Free;
  inherited;
end;

procedure TMQTTClient.CheckConnection;
begin
  if not Online then
    raise Exception.Create('Service not connected!');
end;

procedure TMQTTClient.ConfigureKeepAlive;
begin
  if KeepAlive > 0 then
    FKeepAliveTimer.Interval := KeepAlive * 1000;
end;

procedure TMQTTClient.Disconnect;
begin
  try
    if FLink.Connected then
    begin
      FParser.SendDisconnect;
      FLink.Disconnect;
    end;
  except
    raise;
  end;
end;

procedure TMQTTClient.FinalizarRecThread;
begin
  // Terminate our socket receive thread.
  if Assigned(FRecvThread) then
  begin
    FRecvThread.Terminate;
    FRecvThread.WaitFor;
  end;
end;

procedure TMQTTClient.SetClean(const Value: Boolean);
begin
  FParser.Clean := Value;
end;

procedure TMQTTClient.SetClientID(const Value: UTF8String);
begin
  FParser.ClientID := Value;
end;

procedure TMQTTClient.SetKeepAlive(const Value: Word);
begin
  FParser.KeepAlive := Value;
end;

procedure TMQTTClient.SetMaxRetries(const Value: integer);
begin
  FParser.MaxRetries := Value;
end;

procedure TMQTTClient.SetPassword(const Value: UTF8String);
begin
  FParser.Password := Value;
end;

procedure TMQTTClient.SetRetryTime(const Value: cardinal);
begin
  FParser.RetryTime := Value;
end;

procedure TMQTTClient.SetUsername(const Value: UTF8String);
begin
  FParser.Username := Value;
end;

procedure TMQTTClient.SetWill(ATopic, aMessage: UTF8String; AQos: TMQTTQOSType; aRetain: Boolean);
begin
  FParser.SetWill(ATopic, aMessage, AQos, aRetain);
end;

procedure TMQTTClient.Subscribe(ATopic: UTF8String; AQos: TMQTTQOSType);
var
  i: integer;
  lValue: cardinal;
  found: Boolean;
  anID: Word;
begin
  CheckConnection;

  if ATopic = '' then
    exit;

  found := false;
  anID := NextMessageID;
  lValue := ord(AQos) + (anID shl 16);

  for i := 0 to FSubscriptions.Count - 1 do
    if FSubscriptions.Items[i].TopicName = ATopic then
    begin
      found := True;
      FSubscriptions.Items[i].Value := lValue;
      break;
    end;

  if not found then
  begin
    FSubscriptions.Add(TMQTTSubscription.Create);
    FSubscriptions.Last.TopicName := ATopic;
    FSubscriptions.Last.Value := lValue;
  end;
  FParser.SendSubscribe(anID, ATopic, AQos);
end;

function TMQTTClient.SubTopics(ATopic: UTF8String): TStringList;
var
  i: integer;
begin
  result := TStringList.Create;
  result.Add('');
  for i := 1 to length(ATopic) do
  begin
    if ATopic[i] = '/' then
      result.Add('')
    else
      result[result.Count - 1] := result[result.Count - 1] + Char(ATopic[i]);
  end;
end;

procedure TMQTTClient.DoSend(Sender: TObject; anID: Word; aRetry: integer; aStream: TMemoryStream);
var
  x: byte;
begin
  if FLink.Connected then
  begin
    // Reset the stream position to the beginning
    aStream.Seek(0, soFromBeginning);

    // Read the first byte from the stream
    aStream.Read(x, 1);

    // Check QoS and message type for conditions to add to in-flight
    if (TMQTTQOSType((x and $06) shr 1) in [qtAT_LEAST_ONCE, qtEXACTLY_ONCE]) and
      (TMQTTMessageType((x and $F0) shr 4) in [mtPUBLISH, mtSUBSCRIBE, mtUNSUBSCRIBE]) and (anID > 0) then
    begin
      // Add packet to in-flight packets
      FInFlight.AddPacket(anID, aStream, aRetry, FParser.RetryTime);
    end;

    // Reset the stream position to the beginning
    aStream.Position := 0;

    // Write the stream data to the socket
    FLink.Socket.Write(aStream, aStream.Size);

    // Introduce a small delay (100ms) to avoid flooding the socket
    Sleep(100);
  end;
end;

function TMQTTClient.GetClean: Boolean;
begin
  result := FParser.Clean;
end;

function TMQTTClient.GetClientID: UTF8String;
begin
  result := FParser.ClientID;
end;

function TMQTTClient.GetKeepAlive: Word;
begin
  result := FParser.KeepAlive;
end;

function TMQTTClient.GetMaxRetries: integer;
begin
  result := FParser.MaxRetries;
end;

function TMQTTClient.GetPassword: UTF8String;
begin
  result := FParser.Password;
end;

function TMQTTClient.GetRetryTime: cardinal;
begin
  result := FParser.RetryTime;
end;

function TMQTTClient.GetUsername: UTF8String;
begin
  result := FParser.Username;
end;

procedure TMQTTClient.GotConnAck(Sender: TObject; ReturnCode: integer);
begin
  if Assigned(FConnAckEvent) then
    OnConnAck(Self, ReturnCode);
end;

procedure TMQTTClient.GotPingResp(Sender: TObject);
begin
  if Assigned(FPingRespEvent) then
    OnPingResp(Self);
end;

procedure TMQTTClient.GotPub(Sender: TObject; Topic, payload: UTF8String);
begin
  if Assigned(FPublishEvent) then
    OnPublish(Self, Topic, payload);
end;

procedure TMQTTClient.GotPubAck(Sender: TObject; MessageID: integer);
begin
  if Assigned(FPubAckEvent) then
    OnPubAck(Self, MessageID);
end;

procedure TMQTTClient.GotPubComp(Sender: TObject; MessageID: integer);
begin
  if Assigned(FPubCompEvent) then
    OnPubComp(Self, MessageID);
end;

procedure TMQTTClient.GotPubRec(Sender: TObject; MessageID: integer);
begin
  if Assigned(FPubRecEvent) then
    OnPubRec(Self, MessageID);
end;

procedure TMQTTClient.GotPubRel(Sender: TObject; MessageID: integer);
begin
  if Assigned(FPubRelEvent) then
    OnPubRel(Self, MessageID);
end;

procedure TMQTTClient.GotSubAck(Sender: TObject; MessageID: integer; GrantedQoS: array of integer);
begin
  if Assigned(FSubAckEvent) then
    OnSubAck(Self, MessageID, GrantedQoS);
end;

procedure TMQTTClient.GotUnSubAck(Sender: TObject; MessageID: integer);
begin
  if Assigned(FUnSubAckEvent) then
    OnUnSubAck(Self, MessageID);
end;

function TMQTTClient.IsSubscribed(ASubscription, ATopic: UTF8String): Boolean;
var
  s, t: TStringList;
  i: integer;
  lMultiLevel: Boolean;
begin
  s := SubTopics(aSubscription);
  try
    t := SubTopics(ATopic);
    try
      lMultiLevel := (s[s.Count - 1] = '#'); // last field is #
      if not lMultiLevel then
        result := (s.Count = t.Count)
      else
        result := (s.Count <= t.Count + 1);
      if result then
      begin
        for i := 0 to s.Count - 1 do
        begin
          if (i >= t.Count) then
            result := lMultiLevel
          else if (i = s.Count - 1) and (s[i] = '#') then
            break
          else if s[i] = '+' then
            continue // they match
          else
            result := result and (s[i] = t[i]);
          if not result then
            break;
        end;
      end;
    finally
      t.Free;
    end;
  finally
    s.Free;
  end;
end;

procedure TMQTTClient.KeepAliveTimerEvent(Sender: TObject);
begin
  if Online then
    Ping;
end;

procedure TMQTTClient.OnConnected(Sender: TObject);
var
  aClientID: UTF8String;

  function TimeString: UTF8String;
  begin
    // 86400  secs
    result := UTF8String(IntToHex(Trunc(Date), 5) + IntToHex(Trunc(Frac(Time) * 864000), 7));
  end;

begin
  if FLink.Connected then
  begin
    FParser.Reset;
    aClientID := ClientID;
    if aClientID = '' then
      aClientID := UTF8Encode('ClientId' + IntToStr(Random(999999999)));
    if Assigned(FOnClientID) then
      FOnClientID(Self, aClientID);
    ClientID := aClientID;
    if FParser.Clean then
    begin
      FInFlight.Clear;
      FReleasables.Clear;
    end;
    FParser.SendConnect(aClientID, FParser.Username, FParser.Password, KeepAlive, FParser.Clean);
  end;
end;

procedure TMQTTClient.Mon(aStr: string);
begin
  if Assigned(FOnMon) then
    FOnMon(Self, aStr);
end;

function TMQTTClient.NextMessageID: Word;
var
  i: integer;
  Unused: Boolean;
  aMsg: TMQTTPacket;
begin
  repeat
    Unused := True;
    FMessageID := FMessageID + 1;
    if FMessageID = 0 then
      FMessageID := 1; // exclude 0
    for i := 0 to FInFlight.Count - 1 do
    begin
      aMsg := FInFlight.List[i];
      if aMsg.ID = FMessageID then
      begin
        Unused := false;
        break;
      end;
    end;
  until Unused;
  result := FMessageID;
end;

function TMQTTClient.Online: Boolean;
begin
  result := FLink.Connected;
end;

procedure TMQTTClient.Ping;
begin
  FParser.SendPing;
end;

procedure TMQTTClient.Publish(ATopic: UTF8String; aMessage: String; AQos: TMQTTQOSType; aRetain: Boolean);
var
  i: integer;
  found: Boolean;
begin
  CheckConnection;

  if FLocalBounce and Assigned(FOnMsg) then
  begin
    found := false;
    for i := 0 to Subscriptions.Count - 1 do
      if IsSubscribed(UTF8String(Subscriptions.Items[i].TopicName), ATopic) then
      begin
        found := True;
        break;
      end;
    if found then
    begin
      FParser.RxQos := AQos;
      FOnMsg(Self, ATopic, aMessage, AQos, false);
    end;
  end;
  FParser.SendPublish(NextMessageID, ATopic, aMessage, AQos, false, aRetain);
end;

procedure TMQTTClient.Unsubscribe(ATopic: UTF8String);
var
  i: integer;
begin
  CheckConnection;

  if ATopic = '' then
    exit;

  for i := Subscriptions.Count - 1 downto 0 do
    if Subscriptions.Items[i].TopicName = ATopic then
    begin
      Subscriptions.Delete(i);
      break;
    end;
  FParser.SendUnsubscribe(NextMessageID, ATopic);
end;

procedure TMQTTClient.OnDisconnected(Sender: TObject);
begin
  if Assigned(FOnOffline) then
    FOnOffline(Sender, FLink.Connected);
end;

end.
