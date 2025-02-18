unit MQTT.Headers.Payload;

interface

uses
  System.Classes,
  System.SysUtils,
  MQTT.Utils;

type

  TMQTTPayload = class
  private
    FContents: TStringList;
    FContainsIntLiterals: boolean;
    FPublishMessage: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function ToBytes: TBytes; overload;
    function ToBytes(WithIntegerLiterals: boolean): TBytes; overload;
    property Contents: TStringList read FContents;
    property ContainsIntLiterals: boolean read FContainsIntLiterals write FContainsIntLiterals;
    property PublishMessage: boolean read FPublishMessage write FPublishMessage;
  end;

implementation

{ TMQTTPayload }

constructor TMQTTPayload.Create;
begin
  FContents := TStringList.Create();
  FContainsIntLiterals := false;
  FPublishMessage := false;
end;

destructor TMQTTPayload.Destroy;
begin
  FContents.Free;
  inherited;
end;

function TMQTTPayload.ToBytes(WithIntegerLiterals: boolean): TBytes;
var
  lLine: String;
  lLineAsBytes: TBytes;
  lLineAsInt: Integer;
begin
  SetLength(Result, 0);
  for lLine in FContents do
  begin
    // This is really nasty and needs refactoring into subclasses
    if PublishMessage then
    begin
      lLineAsBytes := TMQTTUtils.UTF8EncodeToBytesNoLength(UTF8Encode(lLine));
      TMQTTUtils.AppendToByteArray(lLineAsBytes, Result);
    end
    else
    begin
      if (WithIntegerLiterals and TryStrToInt(lLine, lLineAsInt)) then
      begin
        TMQTTUtils.AppendToByteArray(Lo(lLineAsInt), Result);
      end
      else
      begin
        lLineAsBytes := TMQTTUtils.UTF8EncodeToBytes(UTF8Encode(lLine));
        TMQTTUtils.AppendToByteArray(lLineAsBytes, Result);
      end;
    end;
  end;
end;

function TMQTTPayload.ToBytes: TBytes;
begin
  Result := ToBytes(FContainsIntLiterals);
end;

end.
