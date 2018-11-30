(*******************************************************************************
*                                                                              *
*                      Copyright 2018 Oamaru Group Inc.                        *
*                                                                              *
* Permission is hereby granted, free of charge, to any person obtaining a copy *
* of this software and associated documentation files (the "Software"), to     *
* deal in the Software without restriction, including without limitation the   *
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or  *
* sell copies of the Software, and to permit persons to whom the Software is   *
* furnished to do so, subject to the following conditions:                     *
*                                                                              *
* The above copyright notice and this permission notice shall be included in   *
* all copies or substantial portions of the Software.                          *
*                                                                              *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS *
* IN THE SOFTWARE.                                                             *
*                                                                              *
*******************************************************************************)
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
  TransactionTest in 'TransactionTest.pas',
  TransactionWithSpansTest in 'TransactionWithSpansTest.pas',
  UtilityRoutines in 'UtilityRoutines.pas',
  APM.Utils in '..\apm_client\APM.Utils.pas',
  APM.Context in '..\apm_client\APM.Context.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmAPMTestMain, fmAPMTestMain);
  Application.Run;
end.
