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
unit APMMetricsetTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Metricset,
  DefaultInstances;

type
  [TestFixture]
  TAPMMetricsetTest = class(TObject)
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

procedure TAPMMetricsetTest.ConstructorTest;
var
  LActual: TAPMMetricset;
begin
  LActual := TAPMMetricset.Create;
  try
    Assert.AreEqual(Int64(0), LActual.TimeStamp);
    Assert.AreEqual(0, LActual.COunt);
  finally
    LActual.Free;
  end;
end;

procedure TAPMMetricsetTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMMetricset;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMMetricset;
  try
    LActual := TAPMMetricset.Create(LExpected);
    try
      Assert.AreEqual(LExpected.TimeStamp, LActual.TimeStamp);
      Assert.AreEqual(LExpected.Count, LActual.Count);
      for i := 0 to (LExpected.Count - 1) do
      begin
        Assert.AreEqual(LExpected[i].Name, LActual[i].Name);
        Assert.AreEqual(LExpected[i].Value, LActual[i].Value);
      end;
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMMetricsetTest.SampleJSONObjectTest;
var
  LExpected: TAPMMetricset;
  LActual, LSamples, LSample: TJSonObject;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMMetricset;
  try
    LActual := LExpected.GetJSONObject;
    try
      LSamples := LActual.Values['samples'] As TJSONObject;
      Assert.IsNotNull(LSamples);
      for i := 0 to (LExpected.Count - 1) do
      begin
        LSample := LSamples.Values[LExpected[i].Name] as TJSONObject;
        Assert.IsNotNull(LSample);
        Assert.IsNotNull(LSample.Values['value']);
        Assert.AreEqual(FloatToStr(LExpected[i].Value), LSample.Values['value'].Value);
      end;

      Assert.IsNotNull(LActual.Values['timestamp']);
      Assert.AreEqual( LExpected.TimeStamp, StrToInt64(LActual.Values['timestamp'].Value) );
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMMetricsetTest.DefaultJSONObjectTest;
var
  LExpected: TAPMMetricset;
  LActual, LSamples, LSample: TJSonObject;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMMetricset;
  try
    LActual := LExpected.GetJSONObject;
    try
      LSamples := LActual.Values['samples'] As TJSONObject;
      Assert.IsNotNull(LSamples);
      for i := 0 to (LExpected.Count - 1) do
      begin
        LSample := LSamples.Values[LExpected[i].Name] as TJSONObject;
        Assert.IsNotNull(LSample);
        Assert.IsNotNull(LSample.Values['value']);
        Assert.AreEqual(FloatToStr(LExpected[i].Value), LSample.Values['value'].Value);
      end;

      Assert.IsNotNull(LActual.Values['timestamp']);
      Assert.AreEqual( LExpected.TimeStamp, StrToInt64(LActual.Values['timestamp'].Value) );
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMMetricsetTest.SampleJSONStringTest;
var
  LMetricset: TAPMMetricset;
  LExpected, LActual: String;
begin
  LExpected := '{"samples":{"go.memstats.heap.sys.bytes":{"value":61235}},"timestamp":1496170422281000}';
  LMetricset := TDefaultInstances.CreateSampleAPMMetricset;
  try
    LActual := LMetricset.GetJSONString;
  finally
    LMetricset.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

procedure TAPMMetricsetTest.DefaultJSONStringTest;
var
  LMetricset: TAPMMetricset;
  LExpected, LActual: String;
begin
  LExpected := '{"samples":{"byte_counter":{"value":1},"short_counter":{"value":227},'+
               '"integer_gauge":{"value":42767},"long_gauge":{"value":3147483648},'+
               '"float_gauge":{"value":9.16},"double_gauge":{"value":3.14159265358979},'+
               '"dotted.float.gauge":{"value":6.12},"negative.d.o.t.t.e.d":{"value":-1022}},"timestamp":1496170422281000}';
  LMetricset := TDefaultInstances.CreateDefaultAPMMetricset;
  try
    LActual := LMetricset.GetJSONString;
  finally
    LMetricset.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

procedure TAPMMetricsetTest.RequestBodyFormatJSONStringTest;
var
  LMetricset: TAPMMetricset;
  LExpected, LActual: String;
begin
  LExpected := '{"metricset":{"samples":{"byte_counter":{"value":1},"short_counter":{"value":227},'+
               '"integer_gauge":{"value":42767},"long_gauge":{"value":3147483648},'+
               '"float_gauge":{"value":9.16},"double_gauge":{"value":3.14159265358979},'+
               '"dotted.float.gauge":{"value":6.12},"negative.d.o.t.t.e.d":{"value":-1022}},"timestamp":1496170422281000}}';
  LMetricset := TDefaultInstances.CreateDefaultAPMMetricset;
  try
    LActual := LMetricset.GetJSONString(TRUE);
  finally
    LMetricset.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMMetricsetTest);
end.
