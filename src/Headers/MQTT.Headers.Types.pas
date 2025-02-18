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

implementation

end.
