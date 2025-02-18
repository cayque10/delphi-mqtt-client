unit MQTT.Utils.Recv;

interface

uses
  System.SysUtils;

type
  TMQTTRecvUtils = class
  public
    class function MSBLSBToInt(ALengthBytes: TBytes): integer;
    class function RLBytesToInt(ARlBytes: TBytes): integer;
  end;

implementation

{ TMQTTRecvUtils }

class function TMQTTRecvUtils.MSBLSBToInt(ALengthBytes: TBytes): integer;
begin
  Assert(ALengthBytes <> nil, 'O método não pode receber valor nulo');
  Assert(Length(ALengthBytes) = 2, 'The MSB-LSB 2 bytes structure must be 2 Bytes in length');
  Result := ALengthBytes[0] shl 8;
  Result := Result + ALengthBytes[1];
end;

class function TMQTTRecvUtils.RLBytesToInt(ARlBytes: TBytes): integer;
var
  lMulti: integer;
  i: integer;
  lDigit: Byte;
begin
  Assert(ARlBytes <> nil, 'O método não pode receber valor nulo');

  lMulti := 1;
  i := 0;
  Result := 0;

  if ((Length(ARlBytes) > 0) and (Length(ARlBytes) <= 4)) then
  begin
    lDigit := ARlBytes[i];
    repeat
      // lDigit := ARlBytes[i];
      Result := Result + (lDigit and 127) * lMulti;
      lMulti := lMulti * 128;
      // Inc(i);
    until ((lDigit and 128) = 0);
  end;
end;

end.
