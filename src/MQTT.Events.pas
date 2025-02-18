unit MQTT.Events;

interface

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

implementation

end.
