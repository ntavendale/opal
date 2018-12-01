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
unit APMhttpContextTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Span,
  DefaultInstances;

type
  [TestFixture]
  TAPMhttpContextTest = class(TObject)
  public
    [Test]
    procedure ConstructorTest;
    [Test]
    procedure CopyConstructorTest;
    [Test]
    procedure DefaultJSONObjectTest;
    [Test]
    procedure DefaultJSONStringTest;
  end;

implementation

procedure TAPMhttpContextTest.ConstructorTest;
var
  LActual: TAPMhttpContext;
begin
  LActual := TAPMhttpContext.Create;
  try
    Assert.AreEqual(String.Empty, LActual.URL);
    Assert.AreEqual(Integer(0), LActual.StatusCode);
    Assert.AreEqual(String.Empty, LActual.Method);
  finally
    LActual.Free;
  end;
end;

procedure TAPMhttpContextTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMhttpContext;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMhttpContext;
  try
    LActual := TAPMhttpContext.Create(LExpected);
    try
      Assert.AreEqual(LExpected.URL, LActual.URL);
      Assert.AreEqual(LExpected.StatusCode, LActual.StatusCode);
      Assert.AreEqual(LExpected.Method, LActual.Method);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMhttpContextTest.DefaultJSONObjectTest;
var
  LExpected: TAPMhttpContext;
  LActual: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMhttpContext;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['url']);
      Assert.AreEqual(LExpected.URL, LActual.Values['url'].Value);
      Assert.IsNotNull(LActual.Values['status_code']);
      Assert.AreEqual(LExpected.StatusCode, StrToInt(LActual.Values['status_code'].Value));
      Assert.IsNotNull(LActual.Values['method']);
      Assert.AreEqual(LExpected.Method, LActual.Values['method'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMhttpContextTest.DefaultJSONStringTest;
var
  LhttpContext: TAPMhttpContext;
  LExpected, LActual: String;
begin
  LExpected := '{"url":"http:\/\/www.allthingssyslog.com","status_code":200,"method":"GET"}';
  LhttpContext := TDefaultInstances.CreateDefaultAPMhttpContext;
  try
    LActual := LhttpContext.GetJSONString;
  finally
    LhttpContext.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMhttpContextTest);
end.
