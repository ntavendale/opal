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
unit APMContextTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Span,
  DefaultInstances;

type
  [TestFixture]
  TAPMContextTest = class(TObject)
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

procedure TAPMContextTest.ConstructorTest;
var
  LActual: TAPMContext;
begin
  LActual := TAPMContext.Create;
  try
    Assert.AreEqual(String.Empty, LActual.DBContext.Instance);
    Assert.AreEqual(String.Empty, LActual.DBContext.Statement);
    Assert.AreEqual(String.Empty, LActual.DBContext.DBType);
    Assert.AreEqual(String.Empty, LActual.DBContext.User);

    Assert.AreEqual(String.Empty, LActual.httpContext.URL);
    Assert.AreEqual(Integer(0), LActual.httpContext.StatusCode);
    Assert.AreEqual(String.Empty, LActual.httpContext.Method);
  finally
    LActual.Free;
  end;
end;

procedure TAPMContextTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMContext;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMContext;
  try
    LActual := TAPMContext.Create(LExpected);
    try
      Assert.AreEqual(LExpected.DBContext.Instance, LActual.DBContext.Instance);
      Assert.AreEqual(LExpected.DBContext.Statement, LActual.DBContext.Statement);
      Assert.AreEqual(LExpected.DBContext.DBType, LActual.DBContext.DBType);
      Assert.AreEqual(LExpected.DBContext.User, LActual.DBContext.User);

      Assert.AreEqual(LExpected.httpContext.URL, LActual.httpContext.URL);
      Assert.AreEqual(LExpected.httpContext.StatusCode, LActual.httpContext.StatusCode);
      Assert.AreEqual(LExpected.httpContext.Method, LActual.httpContext.Method);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMContextTest.DefaultJSONObjectTest;
var
  LExpected: TAPMContext;
  LDBContext, LhttpContext, LActual: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMContext;
  try
    LActual := LExpected.GetJSONObject;
    try
      LDBContext := LActual.Values['db'] as TJsonObject;
      Assert.IsNotNull(LDBContext);
      Assert.IsNotNull(LDBContext.Values['instance']);
      Assert.AreEqual(LExpected.DBContext.Instance, LDBContext.Values['instance'].Value);
      Assert.IsNotNull(LDBContext.Values['statement']);
      Assert.AreEqual(LExpected.DBContext.Statement, LDBContext.Values['statement'].Value);
      Assert.IsNotNull(LDBContext.Values['type']);
      Assert.AreEqual(LExpected.DBContext.DBType, LDBContext.Values['type'].Value);
      Assert.IsNotNull(LDBContext.Values['user']);
      Assert.AreEqual(LExpected.DBContext.User, LDBContext.Values['user'].Value);

      LhttpContext := LActual.Values['http'] as TJsonObject;
      Assert.IsNotNull(LhttpContext);
      Assert.IsNotNull(LhttpContext.Values['url']);
      Assert.AreEqual(LExpected.httpContext.URL, LhttpContext.Values['url'].Value);
      Assert.IsNotNull(LhttpContext.Values['status_code']);
      Assert.AreEqual(LExpected.httpContext.StatusCode, StrToInt(LhttpContext.Values['status_code'].Value));
      Assert.IsNotNull(LhttpContext.Values['method']);
      Assert.AreEqual(LExpected.httpContext.Method, LhttpContext.Values['method'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMContextTest.DefaultJSONStringTest;
var
  LContext: TAPMContext;
  LExpected, LActual: String;
begin
  LExpected := '{"db":{"instance":"localhost\\default","statement":"Select LastName + '', '' + FirstName FullName, Age From Employee","type":"MSSQL","user":"sa"},'+
               '"http":{"url":"http:\/\/www.allthingssyslog.com","status_code":200,"method":"GET"}}';
  LContext := TDefaultInstances.CreateDefaultAPMContext;
  try
    LActual := LContext.GetJSONString;
  finally
    LContext.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMContextTest);
end.
