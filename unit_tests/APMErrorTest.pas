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
unit APMErrorTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Error,
  DefaultInstances;

type
  [TestFixture]
  TAPMErrorTest = class(TObject)
  public
    [Test]
    procedure ConstructorTest;
    [Test]
    procedure CopyConstructorTest;
    [Test]
    procedure SampleJSONObjectTest;
    [Test]
    procedure DefaultJSONObjectTest;
    [Test]
    procedure SampleJSONStringTest;
    [Test]
    procedure DefaultJSONStringTest;
    [Test]
    procedure RequestBodyFormatJSONStringTest;
  end;

implementation

procedure TAPMErrorTest.ConstructorTest;
var
  LActual: TAPMError;
begin
  LActual := TAPMError.Create;
  try
    Assert.AreEqual(String.Empty, LActual.ID);
    Assert.AreEqual(Int64(0), LActual.TimeStamp);
    Assert.AreEqual(String.Empty, LActual.TraceID);
    Assert.AreEqual(String.Empty, LActual.TransactionID);
    Assert.AreEqual(String.Empty, LActual.ParentID);
    Assert.AreEqual(String.Empty, LActual.Culprit);

    Assert.AreEqual(String.Empty, LActual.Exception.Code);
    Assert.AreEqual(String.Empty, LActual.Exception.ExceptionMessage);
    Assert.AreEqual(String.Empty, LActual.Exception.Module);
    Assert.AreEqual(0, LActual.Exception.StackTrace.Count);
    Assert.AreEqual(String.Empty, LActual.Exception.ExceptionType);
    Assert.IsFalse(LActual.Exception.Handled);

    Assert.AreEqual(String.Empty, LActual.Log.Level);
    Assert.AreEqual(String.Empty, LActual.Log.LoggerName);
    Assert.AreEqual(String.Empty, LActual.Log.LogMessage);
    Assert.AreEqual(String.Empty, LActual.Log.ParamMessage);
    Assert.AreEqual(0, LActual.Log.StackTrace.Count);
  finally
    LActual.Free;
  end;
end;

procedure TAPMErrorTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMError;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMError;
  try
    LActual := TAPMError.Create(LExpected);
    try
      Assert.AreEqual(LExpected.ID, LActual.ID);
      Assert.AreEqual(LExpected.TimeStamp, LActual.TimeStamp);
      Assert.AreEqual(LExpected.TraceID, LActual.TraceID);
      Assert.AreEqual(LExpected.TransactionID, LActual.TransactionID);
      Assert.AreEqual(LExpected.ParentID, LActual.ParentID);
      Assert.AreEqual(LExpected.Culprit, LActual.Culprit);

      Assert.AreEqual(LExpected.Exception.Code, LActual.Exception.Code);
      Assert.AreEqual(LExpected.Exception.ExceptionMessage, LActual.Exception.ExceptionMessage);
      Assert.AreEqual(LExpected.Exception.Module, LActual.Exception.Module);
      Assert.AreEqual(LExpected.Exception.StackTrace.Count, LActual.Exception.StackTrace.Count);
      for i := 0 to LExpected.Exception.StackTrace.Count - 1 do
        Assert.AreEqual(LExpected.Exception.StackTrace[i], LActual.Exception.StackTrace[i]);
      Assert.AreEqual(LExpected.Exception.ExceptionType, LActual.Exception.ExceptionType);
      Assert.AreEqual(LExpected.Exception.Handled, LActual.Exception.Handled);

      Assert.AreEqual(LExpected.Log.Level, LActual.Log.Level);
      Assert.AreEqual(LExpected.Log.LogMessage, LActual.Log.LogMessage);
      Assert.AreEqual(LExpected.Log.ParamMessage, LActual.Log.ParamMessage);
      Assert.AreEqual(LExpected.Log.LoggerName, LActual.Log.LoggerName);
      Assert.AreEqual(LExpected.Log.StackTrace.Count, LActual.Log.StackTrace.Count);
      for i := 0 to LExpected.Log.StackTrace.Count - 1 do
        Assert.AreEqual(LExpected.Log.StackTrace[i], LActual.Log.StackTrace[i]);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMErrorTest.SampleJSONObjectTest;
var
  LExpected: TAPMError;
  LActual, LLog: TJSONObject;
  LStackTrace: TJSONArray;
  LValue: TJSONValue;
begin
  LExpected := TDefaultInstances.CreateSampleAPMError;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['id']);
      Assert.AreEqual(LExpected.ID, LActual.Values['id'].Value);
      Assert.IsNull(LActual.Values['trace_id']);
      Assert.IsNull(LActual.Values['parent_id']);
      Assert.IsNull(LActual.Values['transaction_id']);
      Assert.IsNull(LActual.Values['culprit']);
      Assert.IsNull(LActual.Values['exception']);

      LLog := LActual.Values['log'] as TJSONObject;
      Assert.IsNotNull(LLog);
      Assert.IsNotNull(LLog.Values['level']);
      Assert.AreEqual(LExpected.Log.Level, LLog.Values['level'].Value);
      Assert.IsNotNull(LLog.Values['message']);
      Assert.AreEqual(LExpected.Log.LogMessage, LLog.Values['message'].Value);
      Assert.IsNull(LLog.Values['logger_name']);
      Assert.IsNull(LLog.Values['param_message']);
      Assert.IsNull(LLog.Values['stacktrace']);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMErrorTest.DefaultJSONObjectTest;
var
  LExpected: TAPMError;
  LActual, LLog, LException: TJSONObject;
  LStackTrace: TJSONArray;
  LValue: TJSONValue;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMError;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['id']);
      Assert.AreEqual(LExpected.ID, LActual.Values['id'].Value);
      Assert.IsNotNull(LActual.Values['trace_id']);
      Assert.AreEqual(LExpected.TraceID, LActual.Values['trace_id'].Value);
      Assert.IsNotNull(LActual.Values['parent_id']);
      Assert.AreEqual(LExpected.ParentID, LActual.Values['parent_id'].Value);
      Assert.IsNotNull(LActual.Values['transaction_id']);
      Assert.AreEqual(LExpected.TransactionID, LActual.Values['transaction_id'].Value);
      Assert.IsNotNull(LActual.Values['culprit']);
      Assert.AreEqual(LExpected.Culprit, LActual.Values['culprit'].Value);

      LException := LActual.Values['exception'] as TJSONObject;
      Assert.IsNotNull(LException);
      Assert.IsNotNull(LException.Values['code']);
      Assert.AreEqual(LExpected.Exception.Code, LException.Values['code'].Value);
      Assert.IsNotNull(LException.Values['message']);
      Assert.AreEqual(LExpected.Exception.ExceptionMessage, LException.Values['message'].Value);
      Assert.IsNotNull(LException.Values['module']);
      Assert.AreEqual(LExpected.Exception.Module, LException.Values['module'].Value);
      LStackTrace := LException.Values['stacktrace'] as TJSONArray;
      Assert.IsNotNull(LStackTrace);
      for LValue in LStackTrace do
        Assert.Contains(['StackTrace Line 1', 'StackTrace Line 2'], LValue.Value);
      Assert.IsNotNull(LException.Values['type']);
      Assert.AreEqual(LExpected.Exception.ExceptionType, LException.Values['type'].Value);
      Assert.IsNotNull(LException.Values['handled']);
      Assert.AreEqual(LExpected.Exception.Handled, StrToBool(LException.Values['handled'].Value));

      LLog := LActual.Values['log'] as TJSONObject;
      Assert.IsNotNull(LLog);
      Assert.IsNotNull(LLog.Values['level']);
      Assert.AreEqual(LExpected.Log.Level, LLog.Values['level'].Value);
      Assert.IsNotNull(LLog.Values['logger_name']);
      Assert.AreEqual(LExpected.Log.LoggerName, LLog.Values['logger_name'].Value);
      Assert.IsNotNull(LLog.Values['message']);
      Assert.AreEqual(LExpected.Log.LogMessage, LLog.Values['message'].Value);
      Assert.IsNotNull(LLog.Values['param_message']);
      Assert.AreEqual(LExpected.Log.ParamMessage, LLog.Values['param_message'].Value);
      LStackTrace := LLog.Values['stacktrace'] as TJSONArray;
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

procedure TAPMErrorTest.SampleJSONStringTest;
var
  LError: TAPMError;
  LExpected, LActual: String;
begin
  LExpected := '{"id":"abcdef0123456789","timestamp":1533827045999000,"log":{"level":"custom log level","message":"Cannot read property ''baz'' of undefined"}}';
  LError := TDefaultInstances.CreateSampleAPMError;
  try
    LActual := LError.GetJSONString;
  finally
    LError.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

procedure TAPMErrorTest.DefaultJSONStringTest;
var
  LError: TAPMError;
  LExpected, LActual: String;
begin
  LExpected := '{"id":"abcdef0123456789","timestamp":1533827045999000,"trace_id":"01234",' +
               '"transaction_id":"56789","parent_id":"abcdef","culprit":"Sending Socket","exception":{"code":' +
               '"5","message":"Access Denied","module":"Test Module","attributes":null,"stacktrace":'+
               '["StackTrace Line 1","StackTrace Line 2"],"type":"EAccessDenied",'+
               '"handled":true},"log":{"level":"DEBUG","logger_name":"File Loger",'+
               '"message":"Access Denied","param_message":"Test Module","stacktrace":'+
               '["StackTrace Line 1","StackTrace Line 2"]}}';
  LError := TDefaultInstances.CreateDefaultAPMError;
  try
    LActual := LError.GetJSONString;
  finally
    LError.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

procedure TAPMErrorTest.RequestBodyFormatJSONStringTest;
var
  LError: TAPMError;
  LExpected, LActual: String;
begin
  LExpected := '{"error":{"id":"abcdef0123456789","timestamp":1533827045999000,"trace_id":"01234",' +
               '"transaction_id":"56789","parent_id":"abcdef","culprit":"Sending Socket","exception":{"code":' +
               '"5","message":"Access Denied","module":"Test Module","attributes":null,"stacktrace":'+
               '["StackTrace Line 1","StackTrace Line 2"],"type":"EAccessDenied",'+
               '"handled":true},"log":{"level":"DEBUG","logger_name":"File Loger",'+
               '"message":"Access Denied","param_message":"Test Module","stacktrace":'+
               '["StackTrace Line 1","StackTrace Line 2"]}}}';
  LError := TDefaultInstances.CreateDefaultAPMError;
  try
    LActual := LError.GetJSONString(TRUE);
  finally
    LError.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMErrorTest);
end.
