unit MQTT.Utils;

interface

uses
  System.SysUtils;

type
  TMQTTUtils = class
  private
  public
    class function GetDWordBits(const ABits: Byte; const AIndex: Integer): Integer;
    class procedure SetDWordBits(var ABits: Byte; const AIndex: Cardinal; const AValue: Cardinal);
    class function UTF8EncodeToBytes(AStrToEncode: UTF8String): TBytes;
    class function UTF8EncodeToBytesNoLength(AStrToEncode: UTF8String): TBytes;
    class function RLIntToBytes(ARlInt: Integer): TBytes;
    class function IntToMSBLSB(ANumber: Word): TBytes;
    class procedure AppendToByteArray(ASourceBytes: TBytes; var ATargetBytes: TBytes); overload;
    class procedure AppendToByteArray(ASourceByte: Byte; var ATargetBytes: TBytes); overload;
  end;

implementation

uses
  System.Types;

{ TMQTTUtils }


class procedure TMQTTUtils.AppendToByteArray(ASourceBytes: TBytes; var ATargetBytes: TBytes);
var
  lUpperBnd: Integer;
begin
  if Length(ASourceBytes) > 0 then
  begin
    lUpperBnd := Length(ATargetBytes);
    SetLength(ATargetBytes, lUpperBnd + Length(ASourceBytes));
    Move(ASourceBytes[0], ATargetBytes[lUpperBnd], Length(ASourceBytes));
  end;
end;

class procedure TMQTTUtils.AppendToByteArray(ASourceByte: Byte; var ATargetBytes: TBytes);
var
  lUpperBnd: Integer;
begin
  lUpperBnd := Length(ATargetBytes);
  SetLength(ATargetBytes, lUpperBnd + 1);
  Move(ASourceByte, ATargetBytes[lUpperBnd], 1);
end;

class function TMQTTUtils.GetDWordBits(const ABits: Byte; const AIndex: Integer): Integer;
begin
  Result := (ABits shr (AIndex shr 8)) // offset
    and ((1 shl Byte(AIndex)) - 1); // mask
end;

class function TMQTTUtils.IntToMSBLSB(ANumber: Word): TBytes;
begin
  SetLength(Result, 2);
  Result[0] := ANumber div 256;
  Result[1] := ANumber mod 256;
end;

class function TMQTTUtils.RLIntToBytes(ARlInt: Integer): TBytes;
var
  lByteindex: Integer;
  lDigit: Integer;
begin
  SetLength(Result, 1);
  lByteindex := 0;
  while (ARlInt > 0) do
  begin
    lDigit := ARlInt mod 128;
    ARlInt := ARlInt div 128;
    if ARlInt > 0 then
    begin
      lDigit := lDigit or $80;
    end;
    Result[lByteindex] := lDigit;
    if ARlInt > 0 then
    begin
      inc(lByteindex);
      SetLength(Result, Length(Result) + 1);
    end;
  end;
end;

class procedure TMQTTUtils.SetDWordBits(var ABits: Byte; const AIndex, AValue: Cardinal);
var
  lOffset: Byte;
  lMask: Cardinal;
begin
  lMask := ((1 shl Byte(AIndex)) - 1);
  Assert(AValue <= lMask);

  lOffset := AIndex shr 8;
  ABits := (ABits and (not(lMask shl lOffset))) or DWORD(AValue shl lOffset);
end;

class function TMQTTUtils.UTF8EncodeToBytes(AStrToEncode: UTF8String): TBytes;
var
  i: Integer;
  lTemp: TBytes;
begin
  lTemp := TEncoding.UTF8.GetBytes(UTF8ToString(AStrToEncode));

  SetLength(Result, Length(AStrToEncode) + 2);

  Result[0] := Length(AStrToEncode) div 256;
  Result[1] := Length(AStrToEncode) mod 256;
  for i := 0 to Length(AStrToEncode) - 1 do
  begin
    Result[i + 2] := lTemp[i];
  end;
end;

class function TMQTTUtils.UTF8EncodeToBytesNoLength(AStrToEncode: UTF8String): TBytes;
var
  i: Integer;
  lTemp: TBytes;
begin
  lTemp := TEncoding.UTF8.GetBytes(UTF8ToString(AStrToEncode));
  SetLength(Result, Length(AStrToEncode));

  for i := 0 to Length(AStrToEncode) - 1 do
  begin
    Result[i] := lTemp[i];
  end;
end;

end.
