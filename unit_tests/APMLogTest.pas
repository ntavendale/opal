(*******************************************************************************
*                      Copyright 2018 Oamaru Group Inc.                        *
*                                                                              *
*Permission is hereby granted, free of charge, to any person obtaining a copy  *
*of this software and associated documentation files (the "Software"), to deal *
*in the Software without restriction, including without limitation the rights  *
*to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     *
*copies of the Software, and to permit persons to whom the Software is         *
*furnished to do so, subject to the following conditions:                      *
*                                                                              *
*The above copyright notice and this permission notice shall be included in all*
*copies or substantial portions of the Software.                               *
*                                                                              *
*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
*IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      *
*FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   *
*AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        *
*LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, *
*OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE *
*SOFTWARE.                                                                     *
*******************************************************************************)
unit APMLogTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Error,
  DefaultInstances;

type
  [TestFixture]
  TAPMLogTest = class(TObject)
  public
    [Test]
    procedure ConstructorTest;
    [Test]
    procedure CopyConstructorTest;
    [Test]
    procedure JSONObjectTest;
    [Test]
    procedure JSONStringTest;
  end;

implementation

procedure TAPMLogTest.ConstructorTest;
var
  LActual: TAPMLog;
begin
  LActual := TAPMLog.Create;
  try
    Assert.AreEqual(String.Empty, LActual.Level);
    Assert.AreEqual(String.Empty, LActual.LoggerName);
    Assert.AreEqual(String.Empty, LActual.LogMessage);
    Assert.AreEqual(String.Empty, LActual.ParamMessage);
    Assert.AreEqual(0, LActual.StackTrace.Count);
  finally
    LActual.Free;
  end;
end;

procedure TAPMLogTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMLog;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMLog;
  try
    LActual := TAPMLog.Create(LExpected);
    try
      Assert.AreEqual(LExpected.Level, LActual.Level);
      Assert.AreEqual(LExpected.LogMessage, LActual.LogMessage);
      Assert.AreEqual(LExpected.ParamMessage, LActual.ParamMessage);
      Assert.AreEqual(LExpected.LoggerName, LActual.LoggerName);
      Assert.AreEqual(LExpected.StackTrace.Count, LActual.StackTrace.Count);
      for i := 0 to LExpected.StackTrace.Count - 1 do
        Assert.AreEqual(LExpected.StackTrace[i], LActual.StackTrace[i]);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMLogTest.JSONObjectTest;
var
  LExpected: TAPMLog;
  LActual: TJSONObject;
  LStackTrace: TJSONArray;
  LValue: TJSONValue;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMLog;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['level']);
      Assert.AreEqual(LExpected.Level, LActual.Values['level'].Value);
      Assert.IsNotNull(LActual.Values['logger_name']);
      Assert.AreEqual(LExpected.LoggerName, LActual.Values['logger_name'].Value);
      Assert.IsNotNull(LActual.Values['message']);
      Assert.AreEqual(LExpected.LogMessage, LActual.Values['message'].Value);
      Assert.IsNotNull(LActual.Values['param_message']);
      Assert.AreEqual(LExpected.ParamMessage, LActual.Values['param_message'].Value);
      LStackTrace := LActual.Values['stacktrace'] as TJSONArray;
      Assert.IsNotNull(LStackTrace);
      for LValue in LStackTrace do
        Assert.Contains(['StackTrace Line 1', 'StackTrace Line 2'], LValue.Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMLogTest.JSONStringTest;
var
  LLog: TAPMLog;
  LExpected, LActual: String;
begin
  LExpected := '{"level":"DEBUG","logger_name":"File Loger","message":"Access Denied","param_message":"Test Module","stacktrace":["StackTrace Line 1","StackTrace Line 2"]}';
  LLog := TDefaultInstances.CreateDefaultAPMLog;
  try
    LActual := LLog.GetJSONString;
  finally
    LLog.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMLogTest);
end.

