unit MQTT.Headers.Variable;

interface

uses
  System.SysUtils;

type
  TMQTTVariableHeader = class
  private
  protected
    FBytes: TBytes;
    procedure AddField(AByte: Byte); overload;
    procedure AddField(ABytes: TBytes); overload;
    procedure ClearField;
  public
    constructor Create;
    function ToBytes: TBytes; virtual;
  end;

implementation

{ TMQTTVariableHeader }

procedure TMQTTVariableHeader.AddField(AByte: Byte);
var
  lDestUpperBnd: Integer;
begin
  lDestUpperBnd := Length(FBytes);
  SetLength(FBytes, lDestUpperBnd + SizeOf(AByte));
  Move(AByte, FBytes[lDestUpperBnd], SizeOf(AByte));
end;

procedure TMQTTVariableHeader.AddField(ABytes: TBytes);
var
  lDestUpperBnd: Integer;
begin
  lDestUpperBnd := Length(FBytes);
  SetLength(FBytes, lDestUpperBnd + Length(ABytes));
  Move(ABytes[0], FBytes[lDestUpperBnd], Length(ABytes));
end;

procedure TMQTTVariableHeader.ClearField;
begin
  SetLength(FBytes, 0);
end;

constructor TMQTTVariableHeader.Create;
begin
end;

function TMQTTVariableHeader.ToBytes: TBytes;
begin
  Result := FBytes;
end;

end.
