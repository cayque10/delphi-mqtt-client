unit MQTT.Headers.ConnectFlags;

interface

type
  {
    Description	    7	6	5	4	3	2	1	0
    Connect Flags
    byte 10	        1	1	0	0	1	1	1	x
    Will RETAIN (0)
    Will QoS (01)
    Will flag (1)
    Clean Start (1)
    Username Flag (1)
    Password Flag (1)
  }

  TMQTTConnectFlags = packed record
  private
    FFlags: Byte;
    function GetBits(const AIndex: Integer): Integer;
    procedure SetBits(const AIndex: Integer; const AValue: Integer);
  public
    property Flags: Byte read FFlags write FFlags;
    property CleanStart: Integer index $0101 read GetBits write SetBits;
    // 1 bit at offset 1
    property WillFlag: Integer index $0201 read GetBits write SetBits;
    // 1 bit at offset 2
    property WillQoS: Integer index $0302 read GetBits write SetBits;
    // 2 bits at offset 3
    property WillRetain: Integer index $0501 read GetBits write SetBits;
    // 1 bit at offset 5
    property Password: Integer index $0601 read GetBits write SetBits;
    // 1 bit at offset 6
    property UserName: Integer index $0701 read GetBits write SetBits;
    // 1 bit at offset 7
  end;

implementation

uses
  MQTT.Utils;

{ TMQTTConnectFlags }

function TMQTTConnectFlags.GetBits(const AIndex: Integer): Integer;
begin
  Result := TMQTTUtils.GetDWordBits(FFlags, AIndex);
end;

procedure TMQTTConnectFlags.SetBits(const AIndex, AValue: Integer);
begin
  TMQTTUtils.SetDWordBits(FFlags, AIndex, AValue);
end;

end.
