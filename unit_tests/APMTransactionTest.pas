//Copyright 2018 Oamaru Group Inc.
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
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
    Assert.AreEqual(UInt64(0), LActual.Timestamp);
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

      Assert.AreEqual('null', LActual.Values['context'].Value);
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
               '"type":"request","duration":32.592981,"timestamp":1.535655207154E15,' +
               '"result":"200","context":null,"spans":null,"sampled":null,"span_count":{"started":0}}';
  LTransaction := TDefaultInstances.CreateDefaultAPMTransaction;
  try
    LActual := LTransaction.GetJSONString;
  finally
    LTransaction.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMTransactionTest);
end.
