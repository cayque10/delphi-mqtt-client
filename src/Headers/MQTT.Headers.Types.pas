unit MQTT.Headers.Types;

interface

type
  TMQTTMessageType = (
    // mtReserved0,	  //  0	Reserved
    mtBROKERCONNECT, // 0	Broker request to connect to Broker
    mtCONNECT, // 1	Client request to connect to Broker
    mtCONNACK, // 2	Connect Acknowledgment
    mtPUBLISH, // 3	Publish message
    mtPUBACK, // 4	Publish Acknowledgment
    mtPUBREC, // 5	Publish Received (assured delivery part 1)
    mtPUBREL, // 6	Publish Release (assured delivery part 2)
    mtPUBCOMP, // 7	Publish Complete (assured delivery part 3)
    mtSUBSCRIBE, // 8	Client Subscribe request
    mtSUBACK, // 9	Subscribe Acknowledgment
    mtUNSUBSCRIBE, // 10	Client Unsubscribe request
    mtUNSUBACK, // 11	Unsubscribe Acknowledgment
    mtPINGREQ, // 12	PING Request
    mtPINGRESP, // 13	PING Response
    mtDISCONNECT, // 14	Client is Disconnecting
    mtReserved15 // 15
    );

const
  MsgNames: array [TMQTTMessageType] of string = (
    // 'Reserved',	    //  0	Reserved
    'BROKERCONNECT', // 0	Broker request to connect to Broker
    'CONNECT', // 1	Client request to connect to Broker
    'CONNACK', // 2	Connect Acknowledgment
    'PUBLISH', // 3	Publish message
    'PUBACK', // 4	Publish Acknowledgment
    'PUBREC', // 5	Publish Received (assured delivery part 1)
    'PUBREL', // 6	Publish Release (assured delivery part 2)
    'PUBCOMP', // 7	Publish Complete (assured delivery part 3)
    'SUBSCRIBE', // 8	Client Subscribe request
    'SUBACK', // 9	Subscribe Acknowledgment
    'UNSUBSCRIBE', // 10	Client Unsubscribe request
    'UNSUBACK', // 11	Unsubscribe Acknowledgment
    'PINGREQ', // 12	PING Request
    'PINGRESP', // 13	PING Response
    'DISCONNECT', // 14	Client is Disconnecting
    'Reserved15' // 15
    );

implementation

end.
