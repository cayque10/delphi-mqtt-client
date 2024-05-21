program MqttFmx;

uses
  System.StartUpCopy,
  FMX.Forms,
  Form.Main in 'Form.Main.pas' {FrmMain};

{$R *.res}

begin
{$IFDEF Debug}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;

end.
