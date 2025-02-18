unit MQTT.Headers.Fixed;

interface

type

  {
    bit	    7	6	5	4	      3	        2	1	      0
    byte 1	Message Type	DUP flag	QoS level	RETAIN
    byte 2	Remaining Length
  }

  TMQTTFixedHeader = packed record
  private
    function GetBits(const aIndex: Integer): Integer;
    procedure SetBits(const aIndex: Integer; const aValue: Integer);
  public
    Flags: Byte;
    property Retain: Integer index $0001 read GetBits write SetBits;
    // 1 bits at offset 0
    property QoSLevel: Integer index $0102 read GetBits write SetBits;
    // 2 bits at offset 1
    property Duplicate: Integer index $0301 read GetBits write SetBits;
    // 1 bits at offset 3
    property MessageType: Integer index $0404 read GetBits write SetBits;
    // 4 bits at offset 4
  end;

implementation

uses
  MQTT.Utils;

{ TMQTTFixedHeader }

function TMQTTFixedHeader.GetBits(const aIndex: Integer): Integer;
begin
  Result := TMQTTUtils.GetDWordBits(Flags, aIndex);
end;

procedure TMQTTFixedHeader.SetBits(const aIndex, aValue: Integer);
begin
  TMQTTUtils.SetDWordBits(Flags, aIndex, aValue);
end;

end.
