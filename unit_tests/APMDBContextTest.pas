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
unit APMDBContextTest;

interface

uses
  System.SysUtils, System.Classes, System.JSON, DUnitX.TestFramework, APM.Span,
  DefaultInstances;

type
  [TestFixture]
  TAPMDBContextTest = class(TObject)
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

procedure TAPMDBContextTest.ConstructorTest;
var
  LActual: TAPMDBContext;
begin
  LActual := TAPMDBContext.Create;
  try
    Assert.AreEqual(String.Empty, LActual.Instance);
    Assert.AreEqual(String.Empty, LActual.Statement);
    Assert.AreEqual(String.Empty, LActual.DBType);
    Assert.AreEqual(String.Empty, LActual.User);
  finally
    LActual.Free;
  end;
end;

procedure TAPMDBContextTest.CopyConstructorTest;
var
  LExpected, LActual: TAPMDBContext;
  i: Integer;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMDBContext;
  try
    LActual := TAPMDBContext.Create(LExpected);
    try
      Assert.AreEqual(LExpected.Instance, LActual.Instance);
      Assert.AreEqual(LExpected.Statement, LActual.Statement);
      Assert.AreEqual(LExpected.DBType, LActual.DBType);
      Assert.AreEqual(LExpected.User, LActual.User);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMDBContextTest.DefaultJSONObjectTest;
var
  LExpected: TAPMDBContext;
  LActual: TJSONObject;
begin
  LExpected := TDefaultInstances.CreateDefaultAPMDBContext;
  try
    LActual := LExpected.GetJSONObject;
    try
      Assert.IsNotNull(LActual.Values['instance']);
      Assert.AreEqual(LExpected.Instance, LActual.Values['instance'].Value);
      Assert.IsNotNull(LActual.Values['statement']);
      Assert.AreEqual(LExpected.Statement, LActual.Values['statement'].Value);
      Assert.IsNotNull(LActual.Values['type']);
      Assert.AreEqual(LExpected.DBType, LActual.Values['type'].Value);
      Assert.IsNotNull(LActual.Values['user']);
      Assert.AreEqual(LExpected.User, LActual.Values['user'].Value);
    finally
      LActual.Free;
    end;
  finally
    LExpected.Free;
  end;
end;

procedure TAPMDBContextTest.DefaultJSONStringTest;
var
  LDBContext: TAPMDBContext;
  LExpected, LActual: String;
begin
  LExpected := '{"instance":"localhost\\default","statement":"Select LastName + '', '' + FirstName FullName, Age From Employee","type":"MSSQL","user":"sa"}';
  LDBContext := TDefaultInstances.CreateDefaultAPMDBContext;
  try
    LActual := LDBContext.GetJSONString;
  finally
    LDBContext.Free;
  end;
  Assert.AreEqual(LExpected, LActual);
end;

initialization
  TDUnitX.RegisterTestFixture(TAPMDBContextTest);
end.
