unit Form.Main;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  MQTT.Client,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.Edit,
  FMX.ListBox,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Memo.Types;

type
  TFrmMain = class(TForm)
    MQTTClient1: TMQTTClient;
    LayBackground: TLayout;
    LayConfig: TLayout;
    RecConfigConnection: TRectangle;
    RecTopic: TRectangle;
    RecMessage: TRectangle;
    EdtHost: TEdit;
    EdtPort: TEdit;
    EdtUser: TEdit;
    EdtPassword: TEdit;
    LbHost: TLabel;
    LbPassword: TLabel;
    LbUser: TLabel;
    LbPort: TLabel;
    BtnDisconnect: TButton;
    BtnConnect: TButton;
    LbStatus: TLabel;
    LbTopic: TLabel;
    EdtTopic: TEdit;
    BtnSubscriber: TButton;
    BtnUnsubscriber: TButton;
    LbQos: TLabel;
    LbMessage: TLabel;
    MemMessage: TMemo;
    LbTopicMsg: TLabel;
    BtnInfo: TButton;
    BtnPublish: TButton;
    ChkRetain: TCheckBox;
    VsbBackground: TVertScrollBox;
    RecResponse: TRectangle;
    MemResponse: TMemo;
    LbResponse: TLabel;
    LayHost: TLayout;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    EdtTopicMsg: TEdit;
    CbQos: TComboBox;
    Rectangle1: TRectangle;
    MemInfo: TMemo;
    LbInfo: TLabel;
    procedure BtnConnectClick(Sender: TObject);
    procedure BtnDisconnectClick(Sender: TObject);
    procedure BtnSubscriberClick(Sender: TObject);
    procedure BtnUnsubscriberClick(Sender: TObject);
    procedure BtnPublishClick(Sender: TObject);
    procedure BtnInfoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MQTTClient1ClientID(Sender: TObject; var aClientID: UTF8String);
    procedure MQTTClient1Mon(Sender: TObject; aStr: string);
  private
    procedure ConfigConnection;
    procedure ShowInformation;
    procedure Log(AMsg: UTF8String);
    procedure OnConnAck(Sender: TObject; ReturnCode: Integer);
    procedure OnPingResp(Sender: TObject);
    procedure OnSubAck(Sender: TObject; AMessageID: Integer; AGrantedQoS: Array of Integer);
    procedure OnUnSubAck(Sender: TObject; AMessageID: Integer);
    procedure OnPublish(Sender: TObject; ATopic, APayload: UTF8String);
  public

  end;

var
  FrmMain: TFrmMain;

implementation

uses
  System.IOUtils,
  IdSSLOpenSSLHeaders,
  IdSSLOpenSSL,
  MQTT.Types;

{$R *.fmx}

procedure TFrmMain.BtnConnectClick(Sender: TObject);
begin
  ConfigConnection;

  MQTTClient1.Connect;

  if MQTTClient1.Online then
    LbStatus.Text := 'Connected';
end;

procedure TFrmMain.BtnDisconnectClick(Sender: TObject);
begin
  try
    MQTTClient1.Disconnect;
  finally
    LbStatus.Text := 'Disconnected';
  end;
end;

procedure TFrmMain.BtnInfoClick(Sender: TObject);
begin
  ShowInformation;
end;

procedure TFrmMain.BtnPublishClick(Sender: TObject);
begin
  MQTTClient1.Publish(UTF8String(EdtTopicMsg.Text), MemMessage.Lines.Text, TMQTTQOSType(CbQos.ItemIndex),
    ChkRetain.IsChecked);
end;

procedure TFrmMain.BtnSubscriberClick(Sender: TObject);
begin
  MQTTClient1.Subscribe(UTF8Encode(EdtTopic.Text), TMQTTQOSType(CbQos.ItemIndex));
end;

procedure TFrmMain.BtnUnsubscriberClick(Sender: TObject);
begin
  MQTTClient1.Unsubscribe(UTF8String(EdtTopic.Text));
end;

procedure TFrmMain.ConfigConnection;
begin
  MQTTClient1.Username := UTF8String(EdtUser.Text);
  MQTTClient1.Password := UTF8String(EdtPassword.Text);
  MQTTClient1.Host := EdtHost.Text;
  MQTTClient1.Port := StrToInt(EdtPort.Text);
  MQTTClient1.KeepAlive := 30;
  MQTTClient1.OnConnAck := OnConnAck;
  MQTTClient1.OnPingResp := OnPingResp;
  MQTTClient1.OnPublish := OnPublish;
  MQTTClient1.OnSubAck := OnSubAck;
  MQTTClient1.OnUnSubAck := OnUnSubAck;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
{$IFDEF ANDROID}
var
  lError: String;
  lPath: String;
{$ENDIF}
begin
{$IFDEF ANDROID}
  lPath := TPath.GetLibraryPath;
  MemInfo.Lines.Add('Path: ' + lPath);

  IdOpenSSLSetLibPath(lPath);
  IdSSLOpenSSLHeaders.Load();
  lError := IdSSLOpenSSLHeaders.WhichFailedToLoad();
  if not lError.Trim.IsEmpty then
    MemInfo.Lines.Add('SSL-Errors(0): ' + lError);

  if TFile.Exists(lPath + PathDelim + 'libcrypto.so') then
    MemInfo.Lines.Add('File exists');

{$ELSE}
  IdOpenSSLSetLibPath(GetCurrentDir);
{$ENDIF}
end;

procedure TFrmMain.Log(AMsg: UTF8String);
begin
  MemResponse.Lines.Add(FormatDateTime('hh:mm:ss', Now) + ' = ' + String(AMsg));
end;

procedure TFrmMain.MQTTClient1ClientID(Sender: TObject; var aClientID: UTF8String);
begin
  Log('client: ' + aClientID);
end;

procedure TFrmMain.MQTTClient1Mon(Sender: TObject; aStr: string);
begin
  Log(UTF8String(aStr));
end;

procedure TFrmMain.OnConnAck(Sender: TObject; ReturnCode: Integer);
begin
  Log('Connection Acknowledged, Return Code: ' + UTF8String(IntToStr(Ord(ReturnCode))));
end;

procedure TFrmMain.OnPingResp(Sender: TObject);
begin
  Log('PING! PONG!');
end;

procedure TFrmMain.OnPublish(Sender: TObject; ATopic, APayload: UTF8String);
begin
  Log('Publish Received. Topic: ' + ATopic + ' Payload: ' + APayload);
end;

procedure TFrmMain.OnSubAck(Sender: TObject; AMessageID: Integer; AGrantedQoS: array of Integer);
begin
  Log('Sub Ack Received');
end;

procedure TFrmMain.OnUnSubAck(Sender: TObject; AMessageID: Integer);
begin
  Log('Unsubscribe Ack Received');
end;

procedure TFrmMain.ShowInformation;
var
  j: Integer;
  x: Cardinal;
begin
  MemInfo.Lines.Add('');
  MemInfo.Lines.Add(' Cliente :' + string(MQTTClient1.Parser.ClientID));
  MemInfo.Lines.Add(format('Usuário "%s" Senha "%s"', [MQTTClient1.Parser.Username, MQTTClient1.Parser.Password]));
  MemInfo.Lines.Add(format('Mantém "%d" Tempo de retentar "%d" Maximo de tentativas "%d"',
    [MQTTClient1.Parser.KeepAlive, MQTTClient1.Parser.RetryTime, MQTTClient1.Parser.MaxRetries]));
  MemInfo.Lines.Add('Inscrições :');
  for j := 0 to MQTTClient1.Subscriptions.Count - 1 do
  begin
    x := Cardinal(MQTTClient1.Subscriptions.Items[j].Value) and $3;
    if (Cardinal(MQTTClient1.Subscriptions.Items[j].Value) shr 8) and $FF = $FF then
      MemInfo.Lines.Add('  "' + String(MQTTClient1.Subscriptions.Items[j].TopicName) + '" @ ' + QosNames[TMQTTQOSType(x)
        ] + ' Acionado .')
    else
      MemInfo.Lines.Add('  "' + String(MQTTClient1.Subscriptions.Items[j].TopicName) + '" @ ' +
        QosNames[TMQTTQOSType(x)]);
  end;

end;

end.
