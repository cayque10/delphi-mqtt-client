unit MQTT.Types;

interface

type

  TMQTTQOSType = (qtAT_MOST_ONCE, // 0 At most once Fire and Forget        <=1
    qtAT_LEAST_ONCE, // 1 At least once Acknowledged delivery >=1
    qtEXACTLY_ONCE, // 2 Exactly once Assured delivery       =1
    qtReserved3 // 3	Reserved
    );

const
  QOSNames: array [TMQTTQOSType] of string = ('AT_MOST_ONCE',
    // 0 At most once Fire and Forget        <=1
    'AT_LEAST_ONCE', // 1 At least once Acknowledged delivery >=1
    'EXACTLY_ONCE', // 2 Exactly once Assured delivery       =1
    'RESERVED' // 3	Reserved
    );

implementation

end.
