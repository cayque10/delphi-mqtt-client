unit uMQTTSubscription;

interface

type
  TMQTTSubscription = class
  private
    FTopicName: UTF8String;
    FValue: Cardinal;
  public
    property TopicName: UTF8String read FTopicName write FTopicName;
    property Value: Cardinal read FValue write FValue;

  end;

implementation

end.
