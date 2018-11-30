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
program APMUnitTests;
{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  APMUserTest in 'APMUserTest.pas',
  APM.Metadata in '..\apm_client\APM.Metadata.pas',
  DefaultInstances in 'DefaultInstances.pas',
  APMSystemTest in 'APMSystemTest.pas',
  APMProcessTest in 'APMProcessTest.pas',
  APMAgentTest in 'APMAgentTest.pas',
  APMFrameworkTest in 'APMFrameworkTest.pas',
  APMLanguageTest in 'APMLanguageTest.pas',
  APMRuntimeTest in 'APMRuntimeTest.pas',
  APMServiceTest in 'APMServiceTest.pas',
  APMMetadataTest in 'APMMetadataTest.pas',
  APM.Transaction in '..\apm_client\APM.Transaction.pas',
  APMTransactionTest in 'APMTransactionTest.pas',
  APM.Error in '..\apm_client\APM.Error.pas',
  APMExceptionTest in 'APMExceptionTest.pas',
  APMLogTest in 'APMLogTest.pas',
  APMErrorTest in 'APMErrorTest.pas',
  APM.Span in '..\apm_client\APM.Span.pas',
  APMDBContextTest in 'APMDBContextTest.pas',
  APMhttpContextTest in 'APMhttpContextTest.pas',
  APMContextTest in 'APMContextTest.pas',
  APMSpanTest in 'APMSpanTest.pas',
  APM.Metricset in '..\apm_client\APM.Metricset.pas',
  APMMetricsetTest in 'APMMetricsetTest.pas',
  APM.Utils in '..\apm_client\APM.Utils.pas',
  APMUtilsTest in 'APMUtilsTest.pas',
  APM.Context in '..\apm_client\APM.Context.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.













