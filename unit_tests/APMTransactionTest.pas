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
unit APMTransactionTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Transaction,
  DefaultInstances;

type
  [TestFixture]
  TAPMTransactionTest = class(TObject)
  public
    [Test]
    procedure ConstructorTest;
    [Test]
    procedure CopyConstructorTest;
    [Test]
    procedure JSONObjectTest;
    [Test]
    procedure JSONStringTest;
    [Test]
    procedure RequestBodyFormatJSONStringTest;
  end;

implementation

procedure TAPMTransactionTest.ConstructorTest;
var
  LActual: TAPMTransaction;
  LExpectedDuration: Double;
begin
  LExpectedDuration := 0.00;
  LActual := TAPMTransaction.Create;
  try
    Assert.AreEqual(String.Empty, LActual.ID);
    Assert.AreEqual(String.Empty, LActual.TraceID);
    Assert.AreEqual(String.Empty, LActual.ParentID);
    Assert.AreEqual(String.Empty, LActual.TxResult);
    Assert.AreEqual(String.Empty, LActual.TxType);
    Assert.AreEqual(LExpectedDuration, LActual.Duration);
    Assert.IsTrue(LActual.Sampled);
    Assert.AreEqual(String.Empty, LActual.Name);
    Assert.AreEqual(Int64(0), LActual.Timestamp);
    Assert.AreEqual(Cardinal(0), LActual.SpanCount.Started);
    Assert.AreEqual(Integer(-1), LActual.SpanCount.Dropped);
  finally
    LActual.Free;
  end;
end;

procedure TAPMTransactionTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMTransaction;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMTransaction;
  try
    LExpected.Sampled := FALSE;
    LActual := TAPMTransaction.Create(LExpected);
    try
      Assert.AreEqual(LExpected.ID, LActual.ID);
      Assert.AreEqual(LExpected.TraceID, LActual.TraceID);
      Assert.AreEqual(LExpected.ParentID, LActual.ParentID);
      Assert.AreEqual(LExpected.TxResult, LActual.TxResult);
      Assert.AreEqual(LExpected.TxType, LActual.TxType);
      Assert.AreEqual(LExpected.Duration, LActual.Duration);
      Assert.AreEqual(LExpected.Name, LActual.Name);
      Assert.AreEqual(LExpected.Sampled, LActual.Sampled);
      Assert.AreEqual(LExpected.Timestamp, LActual.Timestamp);
      Assert.AreEqual(LExpected.SpanCount.Started, LActual.SpanCount.Started);
      Assert.AreEqual(LExpected.SpanCount.Dropped, LActual.SpanCount.Dropped);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMTransactionTest.JSONObjectTest;
var
  LExpected: TAPMTransaction;
  LActual: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMTransaction;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['id']);
      Assert.AreEqual(LExpected.ID, LActual.Values['id'].Value);
      Assert.IsNotNull(LActual.Values['trace_id']);
      Assert.AreEqual(LExpected.TraceID, LActual.Values['trace_id'].Value);
      Assert.IsNull(LActual.Values['parent_id']);

      Assert.IsNotNull(LActual.Values['type']);
      Assert.AreEqual(LExpected.TxType, LActual.Values['type'].Value);
      Assert.IsNotNull(LActual.Values['result']);
      Assert.AreEqual(LExpected.TxResult, LActual.Values['result'].Value);

      Assert.AreEqual('null', LActual.Values['spans'].Value);
      Assert.AreEqual('null', LActual.Values['sampled'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMTransactionTest.JSONStringTest;
var
  LTransaction: TAPMTransaction;
  LExpected, LActual: String;
begin
  LExpected := '{"trace_id":"01234567890123456789abcdefabcdef","id":"abcdef1478523690",' +
               '"type":"request","duration":32.592981,"timestamp":1535655207154000,' +
               '"result":"200","spans":null,"sampled":null,"span_count":{"started":0},"context":{"system":{"architecture":"x86","hostname":"hooded.claw","platform":"Windows"}}}';
  LTransaction := TDefaultInstances.CreateDefaultAPMTransaction;
  try
    LActual := LTransaction.GetJSONString;
  finally
    LTransaction.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

procedure TAPMTransactionTest.RequestBodyFormatJSONStringTest;
var
  LTransaction: TAPMTransaction;
  LExpected, LActual: String;
begin
  LExpected := '{"transaction":{"trace_id":"01234567890123456789abcdefabcdef","id":"abcdef1478523690",' +
               '"type":"request","duration":32.592981,"timestamp":1535655207154000,' +
               '"result":"200","spans":null,"sampled":null,"span_count":{"started":0},"context":{"system":{"architecture":"x86","hostname":"hooded.claw","platform":"Windows"}}}}';
  LTransaction := TDefaultInstances.CreateDefaultAPMTransaction;
  try
    LActual := LTransaction.GetJSONString(TRUE);
  finally
    LTransaction.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMTransactionTest);
end.
