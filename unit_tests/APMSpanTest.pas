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
unit APMSpanTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Span,
  DefaultInstances;

type
  [TestFixture]
  TAPMSpanTest = class(TObject)
  public
    [Test]
    procedure ConstructorTest;
    [Test]
    procedure CopyConstructorTest;
    [Test]
    procedure DefaultJSONObjectTest;
    [Test]
    procedure SampleJSONObjectTest;
    [Test]
    procedure DefaultJSONStringTest;
    [Test]
    procedure SampleJSONStringTest;
  end;

implementation

procedure TAPMSpanTest.ConstructorTest;
var
  LActual: TAPMSpan;
  LInitialDouble: Double;
begin
  LInitialDouble := 0.00;
  LActual := TAPMSpan.Create;
  try
    Assert.AreEqual(String.Empty, LActual.ID);
    Assert.AreEqual(String.Empty, LActual.Name);
    Assert.AreEqual(String.Empty, LActual.TraceID);
    Assert.AreEqual(String.Empty, LActual.TransactionID);
    Assert.AreEqual(String.Empty, LActual.ParentID);
    Assert.AreEqual(Integer(0), LActual.Parent);
    Assert.AreEqual(String.Empty, LActual.SpanType);
    Assert.AreEqual(LInitialDouble, LActual.Start);
    Assert.AreEqual(LInitialDouble, LActual.Duration);
    Assert.AreEqual(0, LActual.StackTrace.Count);

    Assert.AreEqual(String.Empty, LActual.Context.DBContext.Instance);
    Assert.AreEqual(String.Empty, LActual.Context.DBContext.Statement);
    Assert.AreEqual(String.Empty, LActual.Context.DBContext.DBType);
    Assert.AreEqual(String.Empty, LActual.Context.DBContext.User);

    Assert.AreEqual(String.Empty, LActual.Context.httpContext.URL);
    Assert.AreEqual(Integer(0), LActual.Context.httpContext.StatusCode);
    Assert.AreEqual(String.Empty, LActual.Context.httpContext.Method);
  finally
    LActual.Free;
  end;
end;

procedure TAPMSpanTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMSpan;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMSpan;
  try
    LActual := TAPMSpan.Create(LExpected);
    try
      Assert.AreEqual(LExpected.ID, LActual.ID);
      Assert.AreEqual(LExpected.TraceID, LActual.TraceID);
      Assert.AreEqual(LExpected.TransactionID, LActual.TransactionID);
      Assert.AreEqual(LExpected.ParentID, LActual.ParentID);
      Assert.AreEqual(LExpected.Parent, LActual.Parent);
      Assert.AreEqual(LExpected.Name, LActual.Name);
      Assert.AreEqual(LExpected.SpanType, LActual.SpanType);
      Assert.AreEqual(LExpected.Start, LActual.Start);
      Assert.AreEqual(LExpected.Duration, LActual.Duration);
      Assert.AreEqual(LExpected.StackTrace.Count, LActual.StackTrace.Count);
      for i := 0 to (LExpected.StackTrace.Count - 1) do
        Assert.AreEqual(LExpected.StackTrace[i], LActual.StackTrace[i]);

      Assert.AreEqual(LExpected.Context.DBContext.Instance, LActual.Context.DBContext.Instance);
      Assert.AreEqual(LExpected.Context.DBContext.Statement, LActual.Context.DBContext.Statement);
      Assert.AreEqual(LExpected.Context.DBContext.DBType, LActual.Context.DBContext.DBType);
      Assert.AreEqual(LExpected.Context.DBContext.User, LActual.Context.DBContext.User);

      Assert.AreEqual(LExpected.Context.httpContext.URL, LActual.Context.httpContext.URL);
      Assert.AreEqual(LExpected.Context.httpContext.StatusCode, LActual.Context.httpContext.StatusCode);
      Assert.AreEqual(LExpected.Context.httpContext.Method, LActual.Context.httpContext.Method);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMSpanTest.DefaultJSONObjectTest;
var
  LExpected: TAPMSpan;
  LStackTrace: TJSONArray;
  LArrayEntry: TJSONValue;
  LContext, LDBContext, LhttpContext, LActual: TJSONObject;
  LStackTraceArray: TArray<String>;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMSpan;
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
      Assert.IsNotNull(LActual.Values['name']);
      Assert.AreEqual(LExpected.Name, LActual.Values['name'].Value);
      Assert.IsNotNull(LActual.Values['start']);
      Assert.AreEqual(FloatToStr(LExpected.Start), LActual.Values['start'].Value);
      Assert.IsNotNull(LActual.Values['duration']);
      Assert.AreEqual(FloatToStr(LExpected.Duration), LActual.Values['duration'].Value);
      Assert.IsNotNull(LActual.Values['type']);
      Assert.AreEqual(LExpected.SpanType, LActual.Values['type'].Value);

      LStackTrace := LActual.Values['stacktrace'] as TJSONArray;
      Assert.IsNotNull(LStackTrace);
      LStackTraceArray := LExpected.StackTrace.ToArray;
      for LArrayEntry in LStackTrace do
        Assert.Contains(LStackTraceArray, LArrayEntry.Value);

      LContext := LActual.Values['context'] as TJsonObject;
      Assert.IsNotNull(LContext);
      LDBContext := LContext.Values['db'] as TJsonObject;
      Assert.IsNotNull(LDBContext);
      Assert.IsNotNull(LDBContext.Values['instance']);
      Assert.AreEqual(LExpected.Context.DBContext.Instance, LDBContext.Values['instance'].Value);
      Assert.IsNotNull(LDBContext.Values['statement']);
      Assert.AreEqual(LExpected.Context.DBContext.Statement, LDBContext.Values['statement'].Value);
      Assert.IsNotNull(LDBContext.Values['type']);
      Assert.AreEqual(LExpected.Context.DBContext.DBType, LDBContext.Values['type'].Value);
      Assert.IsNotNull(LDBContext.Values['user']);
      Assert.AreEqual(LExpected.Context.DBContext.User, LDBContext.Values['user'].Value);

      LhttpContext := LContext.Values['http'] as TJsonObject;
      Assert.IsNotNull(LhttpContext);
      Assert.IsNotNull(LhttpContext.Values['url']);
      Assert.AreEqual(LExpected.Context.httpContext.URL, LhttpContext.Values['url'].Value);
      Assert.IsNotNull(LhttpContext.Values['status_code']);
      Assert.AreEqual(LExpected.Context.httpContext.StatusCode, StrToInt(LhttpContext.Values['status_code'].Value));
      Assert.IsNotNull(LhttpContext.Values['method']);
      Assert.AreEqual(LExpected.Context.httpContext.Method, LhttpContext.Values['method'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMSpanTest.SampleJSONObjectTest;
var
  LExpected: TAPMSpan;
  LStackTrace: TJSONArray;
  LContext, LDBContext, LhttpContext, LActual: TJSONObject;
  LStackTraceArray: TArray<String>;
begin
  LExpected := TDefaultInstances.CreateSampleAPMSpan;
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
      Assert.IsNotNull(LActual.Values['name']);
      Assert.AreEqual(LExpected.Name, LActual.Values['name'].Value);
      Assert.IsNotNull(LActual.Values['start']);
      Assert.AreEqual(FloatToStr(LExpected.Start), LActual.Values['start'].Value);
      Assert.IsNotNull(LActual.Values['duration']);
      Assert.AreEqual(FloatToStr(LExpected.Duration), LActual.Values['duration'].Value);
      Assert.IsNotNull(LActual.Values['type']);
      Assert.AreEqual(LExpected.SpanType, LActual.Values['type'].Value);

      LStackTrace := LActual.Values['stacktrace'] as TJSONArray;
      Assert.IsNotNull(LStackTrace);
      Assert.AreEqual(0, LStackTrace.Count);

      LContext := LActual.Values['context'] as TJsonObject;
      Assert.IsNotNull(LContext);
      LDBContext := LContext.Values['db'] as TJsonObject;
      Assert.IsNull(LDBContext);

      LhttpContext := LContext.Values['http'] as TJsonObject;
      Assert.IsNull(LhttpContext);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMSpanTest.DefaultJSONStringTest;
var
  LSpan: TAPMSpan;
  LExpected, LActual: String;
begin
  LExpected := '{"id":"0123456a89012345","trace_id":"0123456789abcdef0123456789abcdef",'+
               '"parent_id":"ab23456a89012345","transaction_id":"ab23456a89012345",'+
               '"parent":1,"name":"GET \/api\/types","type":"request","start":1.845,'+
               '"duration":3.5642981,"stacktrace":["StackTrace Line 1","StackTrace Line 2"],'+
               '"context":{"db":{"instance":"localhost\\default","statement":'+
               '"Select LastName + '', '' + FirstName FullName, Age From Employee","type":"MSSQL",'+
               '"user":"sa"},"http":{"url":"http:\/\/www.allthingssyslog.com","status_code":200,"method":"GET"}}}';
  LSpan := TDefaultInstances.CreateDefaultAPMSpan;
  try
    LActual := LSpan.GetJSONString;
  finally
    LSpan.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

procedure TAPMSpanTest.SampleJSONStringTest;
var
  LSpan: TAPMSpan;
  LExpected, LActual: String;
begin
  LExpected := '{"id":"0123456a89012345","trace_id":"0123456789abcdef0123456789abcdef",'+
               '"parent_id":"ab23456a89012345","transaction_id":"ab23456a89012345",'+
               '"parent":1,"name":"GET \/api\/types","type":"request","start":1.845,'+
               '"duration":3.5642981,"stacktrace":[],"context":{}}';
  LSpan := TDefaultInstances.CreateSampleAPMSpan;
  try
    LActual := LSpan.GetJSONString;
  finally
    LSpan.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMSpanTest);
end.

