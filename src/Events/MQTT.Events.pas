unit MQTT.Events;

interface

uses
  System.Classes,
  MQTT.Headers.Types,
  MQTT.Types;

type
  TConnAckEvent = procedure(Sender: TObject; ReturnCode: Integer) of object;
  TPublishEvent = procedure(Sender: TObject; topic, payload: UTF8String) of object;
  TPingRespEvent = procedure(Sender: TObject) of object;
  TPingReqEvent = procedure(Sender: TObject) of object;
  TSubAckEvent = procedure(Sender: TObject; MessageID: Integer; GrantedQoS: Array of Integer) of object;
  TUnSubAckEvent = procedure(Sender: TObject; MessageID: Integer) of object;
  TPubAckEvent = procedure(Sender: TObject; MessageID: Integer) of object;
  TPubRelEvent = procedure(Sender: TObject; MessageID: Integer) of object;
  TPubRecEvent = procedure(Sender: TObject; MessageID: Integer) of object;
  TPubCompEvent = procedure(Sender: TObject; MessageID: Integer) of object;

  TMQTTStreamEvent = procedure(Sender: TObject; anID: Word; Retry: Integer; aStream: TMemoryStream) of object;
  TMQTTMonEvent = procedure(Sender: TObject; aStr: string) of object;
  TMQTTCheckUserEvent = procedure(Sender: TObject; aUser, aPass: UTF8String; var Allowed: boolean) of object;
  TMQTTPubResponseEvent = procedure(Sender: TObject; aMsg: TMQTTMessageType; anID: Word) of object;
  TMQTTIDEvent = procedure(Sender: TObject; anID: Word) of object;
  TMQTTAckEvent = procedure(Sender: TObject; aCode: Byte) of object;
  TMQTTDisconnectEvent = procedure(Sender: TObject; Graceful: boolean) of object;
  TMQTTSubscriptionEvent = procedure(Sender: TObject; aTopic: UTF8String; var RequestedQos: TMQTTQOSType) of object;
  TMQTTSubscribeEvent = procedure(Sender: TObject; anID: Word; Topics: TStringList) of object;
  TMQTTUnsubscribeEvent = procedure(Sender: TObject; anID: Word; Topics: TStringList) of object;
  TMQTTSubAckEvent = procedure(Sender: TObject; anID: Word; Qoss: array of TMQTTQOSType) of object;
  TMQTTFailureEvent = procedure(Sender: TObject; aReason: Integer; var CloseClient: boolean) of object;
  TMQTTMsgEvent = procedure(Sender: TObject; aTopic: UTF8String; aMessage: String; aQos: TMQTTQOSType;
    aRetained: boolean) of object;
  TMQTTRetainEvent = procedure(Sender: TObject; aTopic: UTF8String; aMessage: String; aQos: TMQTTQOSType) of object;
  TMQTTRetainedEvent = procedure(Sender: TObject; Subscribed: UTF8String; var aTopic: UTF8String; var aMessage: String;
    var aQos: TMQTTQOSType) of object;
  TMQTTPublishEvent = procedure(Sender: TObject; anID: Word; aTopic: UTF8String; aMessage: String) of object;
  TMQTTClientIDEvent = procedure(Sender: TObject; var aClientID: UTF8String) of object;
  TMQTTConnectEvent = procedure(Sender: TObject; Protocol: UTF8String; Version: Byte;
    ClientID, UserName, Password: UTF8String; KeepAlive: Word; Clean: boolean) of object;
  TMQTTWillEvent = procedure(Sender: TObject; aTopic, aMessage: UTF8String; aQos: TMQTTQOSType; aRetain: boolean)
    of object;
  TMQTTObituaryEvent = procedure(Sender: TObject; var aTopic, aMessage: UTF8String; var aQos: TMQTTQOSType) of object;
  TMQTTHeaderEvent = procedure(Sender: TObject; MsgType: TMQTTMessageType; Dup: boolean; Qos: TMQTTQOSType;
    Retain: boolean) of object;
  TMQTTSessionEvent = procedure(Sender: TObject; aClientID: UTF8String) of object;

implementation

end.
