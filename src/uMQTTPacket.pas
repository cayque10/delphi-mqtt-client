unit uMQTTPacket;

interface

uses
  System.Classes;

type

  TMQTTPacket = class
  private
    FID: Word;
    FStamp: TDateTime;
    FCounter: cardinal;
    FRetries: integer;
    FPublishing: Boolean;
    FMsg: TMemoryStream;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(AFrom: TMQTTPacket);
    property Id: Word read FID write FID;
    property Stamp: TDateTime read FStamp write FStamp;
    property Counter: cardinal read FCounter write FCounter;
    property Retries: integer read FRetries write FRetries;
    property Publishing: Boolean read FPublishing write FPublishing;
    property Msg: TMemoryStream read FMsg write FMsg;
  end;

implementation

uses
  System.SysUtils;

{ TMQTTPacket }

procedure TMQTTPacket.Assign(AFrom: TMQTTPacket);
begin
  FID := AFrom.FID;
  FStamp := AFrom.FStamp;
  FCounter := AFrom.FCounter;
  FRetries := AFrom.FRetries;
  FMsg.Clear;
  AFrom.FMsg.Seek(0, soFromBeginning);
  FMsg.CopyFrom(AFrom.FMsg, AFrom.FMsg.Size);
  FPublishing := AFrom.FPublishing;
end;

constructor TMQTTPacket.Create;
begin
  FID := 0;
  FStamp := Now;
  FPublishing := True;
  FCounter := 0;
  FRetries := 0;
  FMsg := TMemoryStream.Create;
end;

destructor TMQTTPacket.Destroy;
begin
  FMsg.Free;
  inherited;
end;

end.
