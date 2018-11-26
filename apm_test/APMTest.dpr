program APMTest;

uses
  Vcl.Forms,
  APMTestMain in 'APMTestMain.pas' {fmAPMTestMain},
  APM.Error in '..\apm_client\APM.Error.pas',
  APM.Metadata in '..\apm_client\APM.Metadata.pas',
  APM.Metricset in '..\apm_client\APM.Metricset.pas',
  APM.Span in '..\apm_client\APM.Span.pas',
  APM.Transaction in '..\apm_client\APM.Transaction.pas',
  EndPointClient in 'EndPointClient.pas',
  TransactionTest in 'TransactionTest.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmAPMTestMain, fmAPMTestMain);
  Application.Run;
end.
