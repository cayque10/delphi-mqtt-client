unit MQTT.Headers.RecvState;

interface

type
  TMQTTRecvState = (FixedHeaderByte, RemainingLength, RemainingLength1, RemainingLength2, RemainingLength3,
    RemainingLength4, Data);

implementation

end.
